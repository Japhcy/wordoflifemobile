import 'package:wordoflifemobile/core/constants/post_constants.dart';

class Post {
  final String id;
  final String userId;
  final String churchId;
  final String content;
  final String postType;
  final String? imageUrl;
  final String? videoUrl;
  final String? scriptureReference;
  final String? scriptureVerse;
  final List<String> tags;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;

  // User info (joined from profiles)
  final String fullName;
  final String? avatarUrl;
  final String churchName;

  // Aggregated counts
  final int likeCount;
  final int commentCount;
  final bool isLiked;

  Post({
    required this.id,
    required this.userId,
    required this.churchId,
    required this.content,
    required this.postType,
    this.imageUrl,
    this.videoUrl,
    this.scriptureReference,
    this.scriptureVerse,
    this.tags = const [],
    this.isPinned = false,
    required this.createdAt,
    required this.updatedAt,
    required this.fullName,
    this.avatarUrl,
    required this.churchName,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
  });

  factory Post.fromMap(Map<String, dynamic> map) {
    // Get user info from nested profiles
    final profile = map['profiles'] as Map<String, dynamic>?;
    final church = map['churches'] as Map<String, dynamic>?;

    return Post(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      churchId: map['church_id'] ?? '',
      content: map['content'] ?? '',
      postType: map['post_type'] ?? 'general',
      imageUrl: map['image_url'],
      videoUrl: map['video_url'],
      scriptureReference: map['scripture_reference'],
      scriptureVerse: map['scripture_verse'],
      tags: List<String>.from(map['tags'] ?? []),
      isPinned: map['is_pinned'] ?? false,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : DateTime.now(),
      fullName: profile?['full_name'] ?? map['full_name'] ?? 'Unknown User',
      avatarUrl: profile?['avatar_url'] ?? map['avatar_url'],
      churchName: church?['name'] ?? map['church_name'] ?? 'Unknown Church',
      likeCount: map['like_count'] ?? 0,
      commentCount: map['comment_count'] ?? 0,
      isLiked: map['is_liked'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'church_id': churchId,
      'content': content,
      'post_type': postType,
      'image_url': imageUrl,
      'video_url': videoUrl,
      'scripture_reference': scriptureReference,
      'scripture_verse': scriptureVerse,
      'tags': tags,
      'is_pinned': isPinned,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'church_name': churchName,
      'like_count': likeCount,
      'comment_count': commentCount,
      'is_liked': isLiked,
    };
  }

  Post copyWith({
    String? id,
    String? userId,
    String? churchId,
    String? content,
    String? postType,
    String? imageUrl,
    String? videoUrl,
    String? scriptureReference,
    String? scriptureVerse,
    List<String>? tags,
    bool? isPinned,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? fullName,
    String? avatarUrl,
    String? churchName,
    int? likeCount,
    int? commentCount,
    bool? isLiked,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      churchId: churchId ?? this.churchId,
      content: content ?? this.content,
      postType: postType ?? this.postType,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      scriptureReference: scriptureReference ?? this.scriptureReference,
      scriptureVerse: scriptureVerse ?? this.scriptureVerse,
      tags: tags ?? this.tags,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      churchName: churchName ?? this.churchName,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  // Helper: Get post type display data
  PostTypeData get postTypeData {
    return PostConstants.postTypes[postType] ??
        PostConstants.postTypes['general']!;
  }

  // Helper: Get formatted time
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 30) {
      return '${createdAt.month}/${createdAt.day}/${createdAt.year}';
    } else if (difference.inDays > 7) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} min${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
