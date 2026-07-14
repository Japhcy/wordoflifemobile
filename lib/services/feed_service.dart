import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wordoflifemobile/core/constants/post_constants.dart';
import 'package:wordoflifemobile/data/models/comment.dart';
import 'package:wordoflifemobile/data/models/feed_response.dart';
import 'package:wordoflifemobile/data/models/post.dart';
import 'package:wordoflifemobile/data/models/reaction.dart';

class FeedService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ============================================
  // POST OPERATIONS (CRUD)
  // ============================================

  /// Get feed posts (filtering and pagination)
  Future<FeedResponse> getFeedPosts({
    required int limit,
    int offset = 0,
    String? postType,
    String? sortBy = 'latest',
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final res = await _supabase.rpc(
        'get_feed_posts',
        params: {
          'p_user_id': user.id,
          'p_limit': limit,
          'p_offset': offset,
          'p_post_type': postType,
        },
      );

      if (res != null) {
        final posts = List<Map<String, dynamic>>.from(
          res,
        ).map((json) => Post.fromMap(json)).toList();

        if (sortBy == 'popular') {
          posts.sort((a, b) => b.likeCount.compareTo(a.likeCount));
        }

        return FeedResponse(
          posts: posts,
          hasMore: posts.length == limit,
          totalCount: posts.length,
        );
      }
      return FeedResponse(posts: [], hasMore: false, totalCount: 0);
    } catch (e) {
      debugPrint('❌ Error getting feed posts: $e');
      rethrow;
    }
  }

  /// Create post
  Future<Post> createPost({
    required String content,
    required String postType,
    required String churchId,
    String? imageUrl,
    String? videoUrl,
    String? scriptureReference,
    String? scriptureVerse,
    List<String>? tags,
    bool isPinned = false,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      if (!PostConstants.postTypeList.contains(postType)) {
        throw Exception('Invalid post type');
      }

      final data = {
        'user_id': user.id,
        'church_id': churchId,
        'content': content,
        'post_type': postType,
        'is_pinned': isPinned,
        'image_url': ?imageUrl,
        'video_url': ?videoUrl,
        'scripture_reference': ?scriptureReference,
        'scripture_verse': ?scriptureVerse,
        if (tags != null && tags.isNotEmpty) 'tags': tags,
      };

      final res = await _supabase.from('posts').insert(data).select().single();
      return Post.fromMap(res);
    } catch (e) {
      debugPrint('❌ Error creating post: $e');
      rethrow;
    }
  }

  /// Update post
  Future<Post> updatePost({
    required String postId,
    String? content,
    String? imageUrl,
    String? videoUrl,
    String? scriptureReference,
    String? scriptureVerse,
    List<String>? tags,
    bool? isPinned,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final post = await getPost(postId);
      if (post.userId != user.id) {
        throw Exception('You can only edit your own posts');
      }

      final data = {
        'updated_at': DateTime.now().toIso8601String(),
        'content': ?content,
        'image_url': ?imageUrl,
        'video_url': ?videoUrl,
        'scripture_reference': ?scriptureReference,
        'scripture_verse': ?scriptureVerse,
        'tags': ?tags,
        'is_pinned': ?isPinned,
      };

      final res = await _supabase
          .from('posts')
          .update(data)
          .eq('id', postId)
          .eq('user_id', user.id)
          .select()
          .single();

      return Post.fromMap(res);
    } catch (e) {
      debugPrint('❌ Error updating post: $e');
      rethrow;
    }
  }

  /// Delete post
  Future<void> deletePost(String postId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final hasPermission = await _canDeletePost(postId, user.id);
      if (!hasPermission) {
        throw Exception('You do not have permission to delete this post');
      }

      await _supabase.from('posts').delete().eq('id', postId);
      debugPrint('✅ Post deleted successfully');
    } catch (e) {
      debugPrint('❌ Error deleting post: $e');
      rethrow;
    }
  }

  /// Get single post
  Future<Post> getPost(String postId) async {
    try {
      final response = await _supabase
          .from('posts')
          .select('''
            *,
            profiles!posts_user_id_fkey (
              id,
              full_name,
              avatar_url
            ),
            churches!posts_church_id_fkey (
              id,
              name
            )
          ''')
          .eq('id', postId)
          .single();

      final likeCount = await _getLikeCount(postId);
      final commentCount = await _getCommentCount(postId);

      final user = _supabase.auth.currentUser;
      bool isLiked = false;
      if (user != null) {
        isLiked = await _isPostLiked(postId, user.id);
      }

      return Post.fromMap({
        ...response,
        'like_count': likeCount,
        'comment_count': commentCount,
        'is_liked': isLiked,
      });
    } catch (e) {
      debugPrint('❌ Error getting post: $e');
      rethrow;
    }
  }

  // ============================================
  // COMMENT OPERATIONS
  // ============================================

  /// Get comments with nested replies
  Future<List<Comment>> getComments(String postId) async {
    try {
      final response = await _supabase.rpc(
        'get_post_comments',
        params: {'p_post_id': postId},
      );

      if (response != null) {
        return List<Map<String, dynamic>>.from(
          response,
        ).map((json) => Comment.fromMap(json)).toList();
      }

      return [];
    } catch (e) {
      debugPrint('❌ Error getting comments: $e');
      rethrow;
    }
  }

  /// Create comment
  Future<Comment> createComment({
    required String postId,
    required String content,
    String? parentCommentId,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final data = {
        'post_id': postId,
        'user_id': user.id,
        'content': content,
        'parent_comment_id': ?parentCommentId,
      };

      final response = await _supabase.from('comments').insert(data).select('''
            *,
            profiles!comments_user_id_fkey (
              id,
              full_name,
              avatar_url
            )
          ''').single();

      return Comment.fromMap(response);
    } catch (e) {
      debugPrint('❌ Error creating comment: $e');
      rethrow;
    }
  }

  /// Update comment
  Future<Comment> updateComment({
    required String commentId,
    required String content,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final data = {
        'content': content,
        'is_edited': true,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('comments')
          .update(data)
          .eq('id', commentId)
          .eq('user_id', user.id)
          .select('''
            *,
            profiles!comments_user_id_fkey (
              id,
              full_name,
              avatar_url
            )
          ''')
          .single();

      return Comment.fromMap(response);
    } catch (e) {
      debugPrint('❌ Error updating comment: $e');
      rethrow;
    }
  }

  /// Delete comment
  Future<void> deleteComment(String commentId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final comment = await _getComment(commentId);
      if (comment.userId != user.id) {
        final isPastor = await _isUserPastor(user.id);
        if (!isPastor) {
          throw Exception('You do not have permission to delete this comment');
        }
      }

      await _supabase.from('comments').delete().eq('id', commentId);
      debugPrint('✅ Comment deleted: $commentId');
    } catch (e) {
      debugPrint('❌ Error deleting comment: $e');
      rethrow;
    }
  }

  // ============================================
  // REACTION (LIKE) OPERATIONS
  // ============================================

  /// Toggle like
  Future<bool> toggleLike(String postId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final isLiked = await _isPostLiked(postId, user.id);

      if (isLiked) {
        await _supabase
            .from('reactions')
            .delete()
            .eq('post_id', postId)
            .eq('user_id', user.id);
        return false;
      } else {
        await _supabase.from('reactions').insert({
          'post_id': postId,
          'user_id': user.id,
          'reaction_type': 'like',
        });
        return true;
      }
    } catch (e) {
      debugPrint('❌ Error toggling like: $e');
      rethrow;
    }
  }

  /// Get like count
  Future<int> getLikeCount(String postId) async {
    try {
      final response = await _supabase
          .from('reactions')
          .select('id')
          .eq('post_id', postId);

      return response.length;
    } catch (e) {
      debugPrint('❌ Error getting like count: $e');
      return 0;
    }
  }

  // ============================================
  // TAG OPERATIONS
  // ============================================

  /// Tag users in a post
  Future<void> tagUsers({
    required String postId,
    required List<String> userIds,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final tags = userIds
          .map(
            (userId) => {
              'post_id': postId,
              'tagged_user_id': userId,
              'tagged_by_user_id': user.id,
            },
          )
          .toList();

      await _supabase.from('post_tags').insert(tags);
      debugPrint('✅ Users tagged in post: $postId');
    } catch (e) {
      debugPrint('❌ Error tagging users: $e');
      rethrow;
    }
  }

  // ============================================
  // MEDIA OPERATIONS
  // ============================================

  /// Upload image or video
  Future<String> uploadMedia({
    required File file,
    required String postId,
    required String mediaType,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final maxSize = PostConstants.mediaLimits[mediaType] ?? 10 * 1024 * 1024;
      final fileSize = await file.length();
      if (fileSize > maxSize) {
        throw Exception(
          'File too large. Maximum size is ${maxSize ~/ (1024 * 1024)} MB',
        );
      }

      final extension = file.path.split('.').last;
      final fileName =
          '${postId}_${DateTime.now().millisecondsSinceEpoch}.$extension';
      final filePath = 'posts/$postId/$fileName';

      await _supabase.storage
          .from('post_media')
          .upload(
            filePath,
            file,
            fileOptions: FileOptions(
              contentType: mediaType == 'image' ? 'image/jpeg' : 'video/mp4',
            ),
          );

      final publicUrl = _supabase.storage
          .from('post_media')
          .getPublicUrl(filePath);

      await _supabase.from('post_media').insert({
        'post_id': postId,
        'media_url': publicUrl,
        'media_type': mediaType,
        'file_size': fileSize,
        if (mediaType == 'image') ...{'width': 0, 'height': 0},
        if (mediaType == 'video') ...{'duration': 0},
      });

      return publicUrl;
    } catch (e) {
      debugPrint('❌ Error uploading media: $e');
      rethrow;
    }
  }

  /// Delete media
  Future<void> deleteMedia(String mediaUrl) async {
    try {
      final uri = Uri.parse(mediaUrl);
      final path = uri.pathSegments.last;

      await _supabase.storage.from('post_media').remove([path]);
      debugPrint('✅ Media deleted: $mediaUrl');
    } catch (e) {
      debugPrint('❌ Error deleting media: $e');
      rethrow;
    }
  }

  // ============================================
  // REAL-TIME SUBSCRIPTIONS
  // ============================================

  /// Subscribe to new posts (FIXED - removed .execute())
  Stream<List<Post>> subscribeToPosts(String churchId) {
    return _supabase
        .from('posts')
        .stream(primaryKey: ['id'])
        .eq('church_id', churchId)
        .order('created_at', ascending: false)
        .map((data) {
          return data.map((json) {
            return Post.fromMap({
              ...json,
              'like_count': 0,
              'comment_count': 0,
              'is_liked': false,
            });
          }).toList();
        });
  }

  /// Subscribe to new comments (FIXED - removed .execute())
  Stream<List<Comment>> subscribeToComments(String postId) {
    return _supabase
        .from('comments')
        .stream(primaryKey: ['id'])
        .eq('post_id', postId)
        .order('created_at', ascending: true)
        .map((data) {
          return data.map((json) {
            return Comment.fromMap(json);
          }).toList();
        });
  }

  /// Subscribe to new reactions (FIXED - removed .execute())
  Stream<List<Reaction>> subscribeToReactions(String postId) {
    return _supabase
        .from('reactions')
        .stream(primaryKey: ['id'])
        .eq('post_id', postId)
        .map((data) {
          return data.map((json) {
            return Reaction.fromMap(json);
          }).toList();
        });
  }

  // ============================================
  // PRIVATE HELPERS
  // ============================================

  Future<bool> _canDeletePost(String postId, String userId) async {
    final post = await getPost(postId);
    if (post.userId == userId) return true;
    return _isUserPastor(userId);
  }

  Future<bool> _isUserPastor(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('is_pastor_with_church')
          .eq('id', userId)
          .maybeSingle();

      return response != null && (response['is_pastor_with_church'] ?? false);
    } catch (e) {
      return false;
    }
  }

  Future<bool> _isPostLiked(String postId, String userId) async {
    try {
      final response = await _supabase
          .from('reactions')
          .select('id')
          .eq('post_id', postId)
          .eq('user_id', userId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  Future<int> _getLikeCount(String postId) async {
    try {
      final response = await _supabase
          .from('reactions')
          .select('id')
          .eq('post_id', postId);

      return response.length;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _getCommentCount(String postId) async {
    try {
      final response = await _supabase
          .from('comments')
          .select('id')
          .eq('post_id', postId);

      return response.length;
    } catch (e) {
      return 0;
    }
  }

  Future<Comment> _getComment(String commentId) async {
    try {
      final response = await _supabase
          .from('comments')
          .select('*')
          .eq('id', commentId)
          .single();

      return Comment.fromMap(response);
    } catch (e) {
      rethrow;
    }
  }
}
