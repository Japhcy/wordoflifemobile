import 'package:wordoflifemobile/data/models/post.dart';

class FeedResponse {
  final List<Post> posts;
  final bool hasMore;
  final int totalCount;

  FeedResponse({
    required this.posts,
    required this.hasMore,
    required this.totalCount,
  });

  factory FeedResponse.fromMap(Map<String, dynamic> map) {
    return FeedResponse(
      posts: List<Post>.from(
          (map['posts'] ?? []).map((p) => Post.fromMap(p))
      ),
      hasMore: map['hasMore'] ?? false,
      totalCount: map['totalCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'posts': posts.map((p) => p.toMap()).toList(),
      'hasMore': hasMore,
      'totalCount': totalCount,
    };
  }

  FeedResponse copyWith({
    List<Post>? posts,
    bool? hasMore,
    int? totalCount,
  }) {
    return FeedResponse(
      posts: posts ?? this.posts,
      hasMore: hasMore ?? this.hasMore,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}