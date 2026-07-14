import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wordoflifemobile/data/models/devotional.dart';
import 'package:wordoflifemobile/services/ai_generation_service.dart';

class DevotionalService {
  DevotionalService({SupabaseClient? supabase, AIGenerationService? aiService})
    : _supabase = supabase ?? Supabase.instance.client,
      _aiService = aiService ?? AIGenerationService();

  final SupabaseClient _supabase;
  final AIGenerationService _aiService;


  // Returns today's devotional. If missing, attempts generation once and retries.
  Future<Devotional?> getTodayDevotional() async {
    final user = _currentUser;
    if (user == null) {
      _log('❌ No authenticated user for today devotional');
      return null;
    }

    final today = _todayString();

    try {
      _log('📖 Fetching today\'s devotional for user: ${user.id}');

      var devotional = await _fetchDailyDevotional(
        userId: user.id,
        date: today,
      );

      if (devotional != null) {
        _log('✅ Today\'s devotional found');
        return devotional;
      }

      _log(
        '⚠️ No devotional found for today. Generating missing devotionals...',
      );
      await _generateMissingDevotionals(user.id);

      devotional = await _fetchDailyDevotional(userId: user.id, date: today);

      if (devotional != null) {
        _log('✅ Today\'s devotional found after generation');
        return devotional;
      }

      _log('❌ No devotional available for today after generation');
      return null;
    } catch (e, st) {
      _log('❌ Error getting today devotional: $e');
      _log('$st');
      return null;
    }
  }

  // Returns a devotional for a specific date.
  Future<Devotional?> getDevotionalByDate(DateTime date) async {
    final user = _currentUser;
    if (user == null) {
      _log('❌ No authenticated user for devotional-by-date request');
      return null;
    }

    try {
      return await _fetchDailyDevotional(
        userId: user.id,
        date: _formatDate(date),
      );
    } catch (e, st) {
      _log('❌ Error getting devotional by date: $e');
      _log('$st');
      return null;
    }
  }

  // Marks a devotional as read for the current user.
  Future<void> markDevotionalRead(String devotionalId) async {
    final user = _currentUser;
    if (user == null) {
      _log('❌ No authenticated user to mark devotional as read');
      return;
    }

    try {
      await _supabase.rpc(
        'mark_devotional_read',
        params: {
          'p_devotional_id': devotionalId,
          // Add this if your SQL function supports it:
          // 'p_user_id': user.id,
        },
      );

      _log('✅ Devotional marked as read');
    } catch (e, st) {
      _log('❌ Error marking devotional as read: $e');
      _log('$st');
    }
  }

  // Returns devotional history for the current user.
  Future<List<Devotional>> getDevotionalHistory({int limit = 30}) async {
    final user = _currentUser;
    if (user == null) {
      _log('❌ No authenticated user for devotional history');
      return const [];
    }

    try {
      _log('📚 Fetching devotional history for user: ${user.id}');

      final response = await _supabase.rpc(
        'get_user_devotional_history',
        params: {'p_user_id': user.id, 'p_limit': limit},
      );

      if (response == null) {
        _log('⚠️ History response was null');
        return const [];
      }

      final devotionals = (response as List)
          .map((item) => Devotional.fromMap(item))
          .toList();

      _log('✅ Found ${devotionals.length} devotionals in history');
      return devotionals;
    } catch (e, st) {
      _log('❌ Error getting devotional history: $e');
      _log('$st');
      return const [];
    }
  }

  // Toggles favorite status for a devotional.
  Future<void> toggleFavorite(String devotionalId, bool isFavorite) async {
    final user = _currentUser;
    if (user == null) {
      _log('❌ No authenticated user to toggle favorite');
      return;
    }

    try {
      await _supabase.from('user_devotionals').upsert({
        'user_id': user.id,
        'devotional_id': devotionalId,
        'is_favorite': isFavorite,
      });

      _log('✅ Favorite updated: $isFavorite');
    } catch (e, st) {
      _log('❌ Error toggling favorite: $e');
      _log('$st');
    }
  }

  // Returns favorite devotionals for the current user.
  Future<List<Devotional>> getFavoriteDevotionals({int limit = 30}) async {
    final user = _currentUser;
    if (user == null) {
      _log('❌ No authenticated user for favorite devotionals');
      return const [];
    }

    try {
      final response = await _supabase
          .from('user_devotionals')
          .select('devotionals(*)')
          .eq('user_id', user.id)
          .eq('is_favorite', true)
          .limit(limit);

      final devotionals = (response as List)
          .map((item) => item['devotionals'])
          .where((devotional) => devotional != null)
          .map((devotional) => Devotional.fromMap(devotional))
          .toList();

      _log('✅ Found ${devotionals.length} favorite devotionals');
      return devotionals;
    } catch (e, st) {
      _log('❌ Error getting favorite devotionals: $e');
      _log('$st');
      return const [];
    }
  }

  // INTERNAL HELPERS

  User? get _currentUser => _supabase.auth.currentUser;

  Future<void> _generateMissingDevotionals(String userId) async {
    try {
      _log('🔄 Generating missing devotionals for user: $userId');
      final summary = await _aiService.generateMissingDevotionals(userId);
      _log('✅ Missing devotionals generation finished: $summary');
    } catch (e, st) {
      _log('❌ Error generating missing devotionals: $e');
      _log('$st');
    }
  }

  Future<Devotional?> _fetchDailyDevotional({
    required String userId,
    required String date,
  }) async {
    final response = await _supabase.rpc(
      'get_daily_devotional',
      params: {'p_user_id': userId, 'p_date': date},
    );

    if (response == null || response.isEmpty) {
      return null;
    }

    debugPrint('📦 Raw response from Supabase: ${response[0]}');
    debugPrint('📦 Keys: ${(response[0] as Map).keys}');

    return Devotional.fromMap(response[0]);
  }

  String _todayString() => _formatDate(DateTime.now());

  String _formatDate(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final month = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$month-$day';
  }

  void _log(String message) {
    debugPrint('[DevotionalService] $message');
  }
}
