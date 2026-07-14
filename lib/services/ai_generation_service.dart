// lib/services/ai_generation_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AIGenerationService {
  AIGenerationService({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client {
    final apiKey = dotenv.env['FREETHEAI_API_KEY']?.trim();

    if (apiKey != null && apiKey.isNotEmpty) {
      _apiKey = apiKey;
      _openAIClient = OpenAIClient(
        config: OpenAIConfig(
          baseUrl: 'https://api.freetheai.xyz/v1',
          authProvider: ApiKeyProvider(_apiKey!),
        ),
      );
      debugPrint('✅ FreeTheAi API initialized successfully');
    } else {
      debugPrint('❌ FREETHEAI_API_KEY not found in .env');
      _apiKey = null;
      _openAIClient = null;
    }
  }

  final SupabaseClient _supabase;
  late final String? _apiKey;
  OpenAIClient? _openAIClient;

  static const String _model = 'opc/deepseek-v4-flash-free';
  static const int _maxBatchConcurrency = 1;
  static const int _maxTitleLength = 60;

  // ✅ FreeTheAi limit: 10 requests/minute
  static const Duration _minDelayBetweenRequests = Duration(seconds: 7);

  bool get _hasApiKey => _apiKey != null && _apiKey.isNotEmpty;

  // =========================================================
  // PUBLIC API
  // =========================================================

  Future<GenerationSummary> generateMissingDevotionals(String userId) async {
    try {
      debugPrint('🔄 Starting devotional generation for user: $userId');

      if (!_hasApiKey) {
        debugPrint('❌ No API key found! Cannot generate devotionals.');
        return const GenerationSummary(
          requested: 0,
          generated: 0,
          skipped: 0,
          failed: 0,
        );
      }

      final profile = await _supabase
          .from('profiles')
          .select('created_at')
          .eq('id', userId)
          .maybeSingle();

      if (profile == null || profile['created_at'] == null) {
        debugPrint(
          '❌ Profile not found or created_at missing for user: $userId',
        );
        return const GenerationSummary(
          requested: 0,
          generated: 0,
          skipped: 0,
          failed: 0,
        );
      }

      final startDate = _dateOnly(DateTime.parse(profile['created_at']));
      final endDate = _dateOnly(DateTime.now());

      if (startDate.isAfter(endDate)) {
        debugPrint(
          '⚠️ Profile created_at is in the future. Nothing to generate.',
        );
        return const GenerationSummary(
          requested: 0,
          generated: 0,
          skipped: 0,
          failed: 0,
        );
      }

      debugPrint(
        '📅 Date range: ${_formatDate(startDate)} → ${_formatDate(endDate)}',
      );

      final existingRows = await _supabase
          .from('devotionals')
          .select('date')
          .gte('date', _formatDate(startDate))
          .lte('date', _formatDate(endDate));

      final existingDates = <String>{
        for (final row in existingRows) (row['date'] as String),
      };

      final allDates = _buildDateRange(startDate, endDate);
      final missingDates = allDates
          .map(_formatDate)
          .where((date) => !existingDates.contains(date))
          .toList();

      if (missingDates.isEmpty) {
        debugPrint('✅ No missing devotionals found.');
        return GenerationSummary(
          requested: allDates.length,
          generated: 0,
          skipped: allDates.length,
          failed: 0,
        );
      }

      debugPrint('📌 Missing devotionals to generate: ${missingDates.length}');
      debugPrint(
        '⏱️ With rate limits (1 concurrent, 10/min), this will take ~${missingDates.length * 7} seconds',
      );

      final results = await _processInBatchesWithRateLimit<String, bool>(
        missingDates,
        batchSize: 1, // ✅ Only 1 concurrent request
        delayBetween: _minDelayBetweenRequests,
        task: (date) async {
          try {
            final devotional = await _generateDevotional(date: date);
            await _saveDevotional(devotional);
            debugPrint('✅ Saved devotional for $date');
            return true;
          } catch (e, st) {
            debugPrint('❌ Failed generating devotional for $date: $e');
            debugPrint('$st');
            return false;
          }
        },
      );

      final generated = results.where((r) => r).length;
      final failed = results.length - generated;

      debugPrint(
        '🎉 Generation complete. Requested: ${missingDates.length}, '
        'Generated: $generated, Failed: $failed',
      );

      return GenerationSummary(
        requested: allDates.length,
        generated: generated,
        skipped: existingDates.length,
        failed: failed,
      );
    } catch (e, st) {
      debugPrint('❌ Error generating missing devotionals: $e');
      debugPrint('$st');
      rethrow;
    }
  }

  /// Generates a single devotional
  Future<Map<String, dynamic>> generateSingleDevotional({
    required String date,
  }) async {
    return _generateDevotional(date: date);
  }

  // =========================================================
  // CORE GENERATION
  // =========================================================

  Future<Map<String, dynamic>> _generateDevotional({
    required String date,
  }) async {
    final normalizedDate = _normalizeDateString(date);

    if (!_hasApiKey) {
      throw Exception('❌ No API key found. Cannot generate devotional.');
    }

    if (_openAIClient == null) {
      throw Exception('❌ OpenAI client not initialized.');
    }

    try {
      final prompt = _buildPrompt();

      debugPrint('🔄 Calling FreeTheAi API for date: $normalizedDate...');

      final response = await _openAIClient!.chat.completions.create(
        ChatCompletionCreateRequest(
          model: _model,
          messages: [
            ChatMessage.system(
              'You are a Christian apostolic oneness pentecostal devotional writer. Generate devotionals with a warm, encouraging, biblical tone.',
            ),
            ChatMessage.user(prompt),
          ],
          temperature: 0.7,
          maxTokens: 800,
        ),
      );

      final content = response.text;

      if (content == null || content.isEmpty) {
        throw Exception('❌ FreeTheAi returned empty response.');
      }

      debugPrint('✅ FreeTheAi response received (${content.length} chars)');

      final devotional = _parseDevotionalResponse(
        content: content,
        date: normalizedDate,
      );

      final devotionalWithTitle = _ensureTitle(devotional);

      if (!_isValidDevotional(devotionalWithTitle)) {
        throw Exception(
          '❌ Parsed devotional is invalid. AI response format may be incorrect.',
        );
      }

      debugPrint('✅ Devotional parsed successfully');
      return devotionalWithTitle;
    } catch (e) {
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('quota') ||
          errorStr.contains('rate limit') ||
          errorStr.contains('429') ||
          errorStr.contains('too many requests')) {
        debugPrint('⚠️ FreeTheAi rate limit exceeded. Slow down requests.');
      } else if (errorStr.contains('api key') ||
          errorStr.contains('unauthorized')) {
        debugPrint(
          '⚠️ Invalid FreeTheAi API key. Check your key or run /checkin in Discord.',
        );
      } else {
        debugPrint('❌ Error generating devotional for $normalizedDate: $e');
      }
      rethrow;
    }
  }

  // =========================================================
  // SAVE
  // =========================================================

  Future<void> _saveDevotional(Map<String, dynamic> devotional) async {
    final cleaned = _sanitizeDevotional(devotional);

    if (!_isValidDevotional(cleaned)) {
      throw Exception('Attempted to save invalid devotional data.');
    }

    try {
      await _supabase.rpc(
        'insert_devotional',
        params: {
          'p_title': cleaned['title'],
          'p_scripture': cleaned['scripture'],
          'p_reference': cleaned['reference'],
          'p_explanation': cleaned['explanation'],
          'p_tags': cleaned['tags'],
          'p_date': cleaned['date'],
        },
      );
      debugPrint('💾 Devotional saved to database');
    } catch (e, st) {
      debugPrint('❌ Error saving devotional: $e');
      debugPrint('$st');
      rethrow;
    }
  }

  // =========================================================
  // PROMPT
  // =========================================================

  String _buildPrompt() {
    return '''
      Write a Christian devotional for an Apostolic Pentecostal audience.

      Requirements:
      - A compelling, meaningful title (max 60 characters)
      - One Bible verse with reference
      - 2 paragraphs of warm, encouraging, biblical reflection
      - Practical for daily life
      - Pastoral, clear, and uplifting tone
      - Include 5-6 relevant tags
      - Do not use markdown headings or bullet points
      
      Return the response in EXACTLY this format:
      
      TITLE: [Devotional Title]
      SCRIPTURE: [Bible verse only]
      REFERENCE: [Book Chapter:Verse]
      EXPLANATION: [2-3 paragraph devotional reflection]
      TAGS: [comma, separated, 5-6 tags]
      ''';
  }

  // =========================================================
  // PARSING (unchanged)
  // =========================================================

  Map<String, dynamic> _parseDevotionalResponse({
    required String content,
    required String date,
  }) {
    final title = _extractSection(content, 'TITLE');
    final scripture = _extractSection(content, 'SCRIPTURE');
    final reference = _extractSection(content, 'REFERENCE');
    final explanation = _extractSection(content, 'EXPLANATION');
    final tagsRaw = _extractSection(content, 'TAGS');

    final cleanedTitle = _cleanInline(title);
    final cleanedScripture = _cleanInline(scripture);
    final cleanedReference = _cleanInline(reference);
    final cleanedExplanation = explanation.isNotEmpty
        ? _cleanParagraphs(explanation)
        : _extractFallbackExplanation(content);
    final tags = _parseTags(tagsRaw);

    if (cleanedScripture.isEmpty) {
      throw Exception('No scripture found in AI response');
    }

    final finalExplanation = cleanedExplanation.isNotEmpty
        ? cleanedExplanation
        : content.trim();

    final finalTitle = cleanedTitle.isNotEmpty
        ? cleanedTitle
        : _generateTitleFromScripture(cleanedScripture);

    final finalTags = tags.length >= 5 ? tags : _ensureMinimumTags(tags);

    return {
      'title': finalTitle,
      'scripture': cleanedScripture,
      'reference': cleanedReference.isNotEmpty
          ? cleanedReference
          : 'Scripture Reference',
      'explanation': finalExplanation,
      'tags': finalTags,
      'date': date,
    };
  }

  String _extractSection(String content, String key) {
    final pattern = RegExp(
      '$key\\s*:\\s*(.*?)(?=\\n(?:TITLE|SCRIPTURE|REFERENCE|EXPLANATION|TAGS)\\s*:|\\Z)',
      caseSensitive: false,
      dotAll: true,
    );

    final match = pattern.firstMatch(content);
    return match?.group(1)?.trim() ?? '';
  }

  String _extractFallbackExplanation(String content) {
    final cleaned = content
        .replaceAll(RegExp(r'TITLE\s*:', caseSensitive: false), '')
        .replaceAll(RegExp(r'SCRIPTURE\s*:', caseSensitive: false), '')
        .replaceAll(RegExp(r'REFERENCE\s*:', caseSensitive: false), '')
        .replaceAll(RegExp(r'EXPLANATION\s*:', caseSensitive: false), '')
        .replaceAll(RegExp(r'TAGS\s*:', caseSensitive: false), '')
        .trim();

    return _cleanParagraphs(cleaned);
  }

  List<String> _parseTags(String raw) {
    if (raw.trim().isEmpty) return [];

    return raw
        .split(',')
        .map((tag) => _cleanInline(tag))
        .where((tag) => tag.isNotEmpty)
        .toSet()
        .toList();
  }

  // =========================================================
  // TITLE HANDLING
  // =========================================================

  Map<String, dynamic> _ensureTitle(Map<String, dynamic> devotional) {
    var title = (devotional['title'] ?? '').toString().trim();

    if (title.isEmpty) {
      final scripture = (devotional['scripture'] ?? '').toString().trim();
      title = _generateTitleFromScripture(scripture);
      debugPrint('📝 Generated title from scripture: "$title"');
    }

    if (title.length > _maxTitleLength) {
      title = '${title.substring(0, _maxTitleLength - 3).trim()}...';
      debugPrint('✂️ Title truncated to $_maxTitleLength chars');
    }

    return {...devotional, 'title': title};
  }

  // =========================================================
  // HELPER METHODS
  // =========================================================

  String _generateTitleFromScripture(String scripture) {
    if (scripture.isEmpty) {
      return 'Daily Devotional';
    }

    final words = scripture.split(' ');
    if (words.length <= 7) {
      return scripture;
    }

    final shortened = words.take(7).join(' ');
    return '$shortened...';
  }

  List<String> _ensureMinimumTags(List<String> tags) {
    const defaultTags = [
      'Christian Living',
      'Faith',
      'Devotional',
      'Daily Bread',
      'Inspiration',
      'Encouragement',
    ];

    final combined = [...tags, ...defaultTags];
    return combined.take(6).toSet().toList();
  }

  // =========================================================
  // VALIDATION / SANITIZATION
  // =========================================================

  Map<String, dynamic> _sanitizeDevotional(Map<String, dynamic> devotional) {
    return {
      'title': _cleanInline((devotional['title'] ?? '').toString()),
      'scripture': _cleanInline((devotional['scripture'] ?? '').toString()),
      'reference': _cleanInline((devotional['reference'] ?? '').toString()),
      'explanation': _cleanParagraphs(
        (devotional['explanation'] ?? '').toString(),
      ),
      'tags': ((devotional['tags'] as List?) ?? [])
          .map((e) => _cleanInline(e.toString()))
          .where((e) => e.isNotEmpty)
          .toSet()
          .toList(),
      'date': _normalizeDateString((devotional['date'] ?? '').toString()),
    };
  }

  bool _isValidDevotional(Map<String, dynamic> devotional) {
    final title = (devotional['title'] ?? '').toString().trim();
    final scripture = (devotional['scripture'] ?? '').toString().trim();
    final reference = (devotional['reference'] ?? '').toString().trim();
    final explanation = (devotional['explanation'] ?? '').toString().trim();
    final date = (devotional['date'] ?? '').toString().trim();
    final tags = devotional['tags'];

    return title.isNotEmpty &&
        scripture.isNotEmpty &&
        explanation.isNotEmpty &&
        date.isNotEmpty &&
        reference.isNotEmpty &&
        tags is List &&
        tags.isNotEmpty;
  }

  // =========================================================
  // HELPERS
  // =========================================================

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  String _formatDate(DateTime date) {
    final d = _dateOnly(date);
    final month = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$month-$day';
  }

  String _normalizeDateString(String date) {
    try {
      return _formatDate(DateTime.parse(date));
    } catch (_) {
      return date.trim();
    }
  }

  List<DateTime> _buildDateRange(DateTime start, DateTime end) {
    final dates = <DateTime>[];
    var current = _dateOnly(start);
    final last = _dateOnly(end);

    while (!current.isAfter(last)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }

    return dates;
  }

  String _cleanInline(String value) {
    return value.replaceAll(RegExp(r'\s+'), ' ').replaceAll('"', '').trim();
  }

  String _cleanParagraphs(String value) {
    return value
        .replaceAll('\r', '')
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  // ✅ New: Rate-limited batch processor for FreeTheAi
  Future<List<R>> _processInBatchesWithRateLimit<T, R>(
    List<T> items, {
    required int batchSize,
    required Duration delayBetween,
    required Future<R> Function(T item) task,
  }) async {
    final results = <R>[];

    for (var i = 0; i < items.length; i += batchSize) {
      final batch = items.skip(i).take(batchSize).toList();
      final batchResults = await Future.wait(batch.map(task));
      results.addAll(batchResults);

      // ✅ Respect rate limits: wait between batches
      if (i + batchSize < items.length) {
        debugPrint(
          '⏳ Rate limit: waiting ${delayBetween.inSeconds}s before next request...',
        );
        await Future.delayed(delayBetween);
      }
    }

    return results;
  }

  Future<List<R>> _processInBatches<T, R>(
    List<T> items, {
    required int batchSize,
    required Future<R> Function(T item) task,
  }) async {
    return _processInBatchesWithRateLimit(
      items,
      batchSize: batchSize,
      delayBetween: _minDelayBetweenRequests,
      task: task,
    );
  }

  void dispose() {
    _openAIClient?.close();
  }
}

// =========================================================
// GENERATION SUMMARY
// =========================================================

class GenerationSummary {
  final int requested;
  final int generated;
  final int skipped;
  final int failed;

  const GenerationSummary({
    required this.requested,
    required this.generated,
    required this.skipped,
    required this.failed,
  });

  @override
  String toString() {
    return 'GenerationSummary('
        'requested: $requested, generated: $generated, skipped: $skipped, failed: $failed)';
  }
}
