// lib/data/models/comment.dart
class Comment {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final String? parentCommentId;
  final bool isEdited;
  final DateTime createdAt;
  final DateTime updatedAt;

  // User info (joined from profiles)
  final String fullName;
  final String? avatarUrl;

  // Nested replies
  final List<Comment> replies;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    this.parentCommentId,
    this.isEdited = false,
    required this.createdAt,
    required this.updatedAt,
    required this.fullName,
    this.avatarUrl,
    this.replies = const [],
  });

  factory Comment.fromMap(Map<String, dynamic> map) {
    // Get user info from nested profiles
    final profile = map['profiles'] as Map<String, dynamic>?;

    // Parse replies
    List<Comment> replies = [];
    final repliesData = map['replies'];
    if (repliesData != null && repliesData is List) {
      replies = repliesData
          .map((reply) => Comment.fromMap(reply as Map<String, dynamic>))
          .toList();
    }

    return Comment(
      id: map['id'] ?? '',
      postId: map['post_id'] ?? '',
      userId: map['user_id'] ?? '',
      content: map['content'] ?? '',
      parentCommentId: map['parent_comment_id'],
      isEdited: map['is_edited'] ?? false,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : DateTime.now(),
      fullName: profile?['full_name'] ?? map['full_name'] ?? 'Unknown User',
      avatarUrl: profile?['avatar_url'] ?? map['avatar_url'],
      replies: replies,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'content': content,
      'parent_comment_id': parentCommentId,
      'is_edited': isEdited,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'replies': replies.map((r) => r.toMap()).toList(),
    };
  }

  Comment copyWith({
    String? id,
    String? postId,
    String? userId,
    String? content,
    String? parentCommentId,
    bool? isEdited,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? fullName,
    String? avatarUrl,
    List<Comment>? replies,
  }) {
    return Comment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      isEdited: isEdited ?? this.isEdited,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      replies: replies ?? this.replies,
    );
  }

  // Helper: Check if comment has replies
  bool get hasReplies => replies.isNotEmpty;

  // Helper: Get reply count
  int get replyCount => replies.length;

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
