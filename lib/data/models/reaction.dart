class Reaction {
  final String id;
  final String postId;
  final String userId;
  final String reactionType;
  final DateTime createdAt;

  Reaction({
    required this.id,
    required this.postId,
    required this.userId,
    this.reactionType = 'like',
    required this.createdAt,
  });

  factory Reaction.fromMap(Map<String, dynamic> map) {
    return Reaction(
      id: map['id'] ?? '',
      postId: map['post_id'] ?? '',
      userId: map['user_id'] ?? '',
      reactionType: map['reaction_type'] ?? 'like',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'reaction_type': reactionType,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Reaction copyWith({
    String? id,
    String? postId,
    String? userId,
    String? reactionType,
    DateTime? createdAt,
  }) {
    return Reaction(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      reactionType: reactionType ?? this.reactionType,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
