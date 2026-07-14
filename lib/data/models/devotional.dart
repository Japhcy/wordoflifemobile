import 'package:flutter/material.dart';

class Devotional {
  final String id;
  final String? title;
  final String scripture;
  final String reference;
  final String explanation;
  final List<String> tags;
  final DateTime date;
  final bool isRead;
  final bool isFavorite;

  Devotional({
    required this.id,
    this.title,
    required this.scripture,
    required this.reference,
    required this.explanation,
    required this.tags,
    required this.date,
    this.isRead = false,
    this.isFavorite = false,
  });

  String get displayTitle {
    if (title != null && title!.trim().isNotEmpty) {
      return title!;
    }
    if (scripture.isNotEmpty) {
      final words = scripture.split(' ');
      if (words.length <= 8) return scripture;
      return '${words.take(8).join(' ')}...';
    }
    return 'Devotional - ${_formatDate(date)}';
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$month/$day/${date.year}';
  }

  factory Devotional.fromMap(Map<String, dynamic> map) {
    debugPrint('📦 Map keys: ${map.keys}');

    final id = map['id'] ?? map['devotional_id'] ?? '';
    final title = map['title'] as String?;
    final dateStr = map['date'] ?? map['devotional_date'] ?? '';

    debugPrint('📝 Title: "$title"');
    debugPrint('📝 ID: "$id"');

    return Devotional(
      id: id.toString(),
      title: title?.isNotEmpty == true ? title : null,
      scripture: map['scripture'] ?? '',
      reference: map['reference'] ?? '',
      explanation: map['explanation'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      date: dateStr.isNotEmpty
          ? DateTime.parse(dateStr.toString())
          : DateTime.now(),
      isRead: map['is_read'] ?? false,
      isFavorite: map['is_favorite'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'scripture': scripture,
      'reference': reference,
      'explanation': explanation,
      'tags': tags,
      'date': date.toIso8601String().split('T').first,
      'is_read': isRead,
      'is_favorite': isFavorite,
    };
  }

  Devotional copyWith({
    String? id,
    String? title,
    String? scripture,
    String? reference,
    String? explanation,
    List<String>? tags,
    DateTime? date,
    bool? isRead,
    bool? isFavorite,
  }) {
    return Devotional(
      id: id ?? this.id,
      title: title ?? this.title,
      scripture: scripture ?? this.scripture,
      reference: reference ?? this.reference,
      explanation: explanation ?? this.explanation,
      tags: tags ?? this.tags,
      date: date ?? this.date,
      isRead: isRead ?? this.isRead,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  String toString() {
    return 'Devotional(id: $id, title: $title, date: $date)';
  }
}
