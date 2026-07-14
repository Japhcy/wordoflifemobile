class PostTag {
  final String id;
  final String postId;
  final String taggedUserId;
  final String taggedByUserId;
  final DateTime createdAt;

  PostTag({
    required this.id,
    required this.postId,
    required this.taggedUserId,
    required this.taggedByUserId,
    required this.createdAt,
  });

  factory PostTag.fromMap(Map<String, dynamic> map) {
    return PostTag(
      id: map['id'] ?? '',
      postId: map['post_id'] ?? '',
      taggedUserId: map['tagged_user_id'] ?? '',
      taggedByUserId: map['tagged_by_user_id'] ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'post_id': postId,
      'tagged_user_id': taggedUserId,
      'tagged_by_user_id': taggedByUserId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
