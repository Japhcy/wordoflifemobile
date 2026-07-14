import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wordoflifemobile/core/constants/post_constants.dart';
import 'package:wordoflifemobile/core/theme/app_colors.dart';
import 'package:wordoflifemobile/data/models/comment.dart';
import 'package:wordoflifemobile/data/models/post.dart';
import 'package:wordoflifemobile/services/auth_service.dart';
import 'package:wordoflifemobile/services/feed_service.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final FeedService _feedService = FeedService();
  final AuthService _authService = AuthService();

  List<Post> _posts = [];
  bool _isLoading = true;
  bool _hasMore = true;
  int _currentPage = 0;
  String? _selectedFilter;
  String? _error;

  final ScrollController _scrollController = ScrollController();
  final int _limit = 10;

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ============================================
  // LOAD POSTS
  // ============================================
  Future<void> _loadPosts({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() {
        _currentPage = 0;
        _posts = [];
        _hasMore = true;
        _error = null;
      });
    }

    if (!_hasMore && !isRefresh) return;

    setState(() => _isLoading = true);

    try {
      final response = await _feedService.getFeedPosts(
        limit: _limit,
        offset: _currentPage * _limit,
        postType: _selectedFilter,
        sortBy: 'latest',
      );

      setState(() {
        if (isRefresh) {
          _posts = response.posts;
        } else {
          _posts.addAll(response.posts);
        }
        _hasMore = response.hasMore;
        _isLoading = false;
        if (_posts.isEmpty) {
          _error = 'No posts yet. Be the first to share!';
        } else {
          _error = null;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load posts: $e';
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore) {
        setState(() => _currentPage++);
        _loadPosts();
      }
    }
  }

  // ============================================
  // FILTERS
  // ============================================
  Future<void> _applyFilter(String? filter) async {
    setState(() {
      _selectedFilter = filter;
      _currentPage = 0;
      _posts = [];
      _hasMore = true;
    });
    await _loadPosts();
  }

  // ============================================
  // LIKE POST
  // ============================================
  Future<void> _toggleLike(String postId) async {
    try {
      final isLiked = await _feedService.toggleLike(postId);
      setState(() {
        final index = _posts.indexWhere((p) => p.id == postId);
        if (index != -1) {
          final post = _posts[index];
          _posts[index] = post.copyWith(
            isLiked: isLiked,
            likeCount: isLiked ? post.likeCount + 1 : post.likeCount - 1,
          );
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  // ============================================
  // CREATE POST
  // ============================================
  Future<void> _showCreatePostSheet() async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const CreatePostSheet(),
    );

    if (result == true) {
      await _loadPosts(isRefresh: true);
    }
  }

  // ============================================
  // VIEW COMMENTS
  // ============================================
  Future<void> _viewComments(Post post) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CommentsSheet(post: post),
    );

    if (result == true) {
      // Refresh to update comment count
      await _loadPosts(isRefresh: true);
    }
  }

  // ============================================
  // BUILD
  // ============================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePostSheet,
        backgroundColor: AppColors.navy600,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // ============================================
  // APP BAR
  // ============================================
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Feed',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: AppColors.navy600,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          icon: const Icon(PhosphorIcons.magnifyingGlass),
          onPressed: () {
            // TODO: Implement search
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: _buildFilterChips(),
      ),
    );
  }

  // ============================================
  // FILTER CHIPS
  // ============================================
  Widget _buildFilterChips() {
    final filters = [null, ...PostConstants.postTypeList];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;
          final label = filter == null
              ? 'All'
              : PostConstants.postTypes[filter]?.label ?? filter;

          return FilterChip(
            label: Text(label),
            selected: isSelected,
            onSelected: (_) => _applyFilter(filter),
            backgroundColor: Colors.white,
            selectedColor: AppColors.navy600,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.navy700,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? Colors.transparent : AppColors.neutral300,
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================
  // BODY
  // ============================================
  Widget _buildBody() {
    if (_isLoading && _posts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading posts...'),
          ],
        ),
      );
    }

    if (_error != null && _posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.neutral600, fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadPosts(isRefresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIcons.newspaper,
              size: 64,
              color: AppColors.neutral300,
            ),
            const SizedBox(height: 16),
            Text(
              'No posts yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.neutral500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to share something!',
              style: TextStyle(color: AppColors.neutral400),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _showCreatePostSheet,
              icon: const Icon(Icons.add),
              label: const Text('Create Post'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadPosts(isRefresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: _posts.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _posts.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return PostCard(
            post: _posts[index],
            onLike: _toggleLike,
            onComment: _viewComments,
            onRefresh: () => _loadPosts(isRefresh: true),
          );
        },
      ),
    );
  }
}

// ============================================
// POST CARD
// ============================================
class PostCard extends StatelessWidget {
  final Post post;
  final Function(String) onLike;
  final Function(Post) onComment;
  final VoidCallback onRefresh;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final postTypeData = post.postTypeData;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.neutral200, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Avatar, Name, Time, Post Type
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.navy600,
                  child: Text(
                    post.fullName.isNotEmpty
                        ? post.fullName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.navy800,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            post.timeAgo,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.neutral500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 3,
                            height: 3,
                            decoration: const BoxDecoration(
                              color: AppColors.neutral400,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: postTypeData.backgroundColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  postTypeData.icon,
                                  size: 10,
                                  color: postTypeData.color,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  postTypeData.label,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: postTypeData.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (post.isPinned)
                  Icon(Icons.push_pin, color: AppColors.gold600, size: 16),
              ],
            ),

            const SizedBox(height: 12),

            // Content
            Text(
              post.content,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.neutral800,
                height: 1.5,
              ),
            ),

            // Scripture
            if (post.scriptureReference != null &&
                post.scriptureVerse != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.pastelBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.scriptureReference!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.navy700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      post.scriptureVerse!,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: AppColors.navy600,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Image
            if (post.imageUrl != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  post.imageUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 200,
                    color: AppColors.neutral200,
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: AppColors.neutral400,
                      ),
                    ),
                  ),
                ),
              ),
            ],

            // Video placeholder
            if (post.videoUrl != null) ...[
              const SizedBox(height: 12),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.neutral900,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(
                    Icons.play_circle_filled,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
            ],

            // Tags
            if (post.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: post.tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.neutral100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '#$tag',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.neutral600,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 12),
            Divider(color: AppColors.neutral200),

            // Actions
            Row(
              children: [
                // Like Button
                InkWell(
                  onTap: () => onLike(post.id),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          post.isLiked
                              ? PhosphorIconsFill.heart
                              : PhosphorIconsRegular.heart,
                          color: post.isLiked
                              ? AppColors.error
                              : AppColors.neutral500,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          post.likeCount > 0 ? '${post.likeCount}' : '',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.neutral600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Comment Button
                InkWell(
                  onTap: () => onComment(post),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          PhosphorIconsRegular.chat,
                          color: AppColors.neutral500,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          post.commentCount > 0 ? '${post.commentCount}' : '',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.neutral600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),

                // Share Button
                IconButton(
                  onPressed: () {
                    // TODO: Implement share
                  },
                  icon: Icon(
                    PhosphorIconsRegular.shareNetwork,
                    color: AppColors.neutral500,
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// CREATE POST SHEET
// ============================================
class CreatePostSheet extends StatefulWidget {
  const CreatePostSheet({super.key});

  @override
  State<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<CreatePostSheet> {
  final TextEditingController _contentController = TextEditingController();
  String _selectedType = 'general';
  bool _isSubmitting = false;
  String? _scriptureReference;
  String? _scriptureVerse;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Create Post',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy800,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Post Type Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: InputDecoration(
                  labelText: 'Post Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: PostConstants.postTypeList.map((type) {
                  final data = PostConstants.postTypes[type]!;
                  return DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Icon(data.icon, color: data.color, size: 18),
                        const SizedBox(width: 8),
                        Text(data.label),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedType = value!);
                },
              ),
              const SizedBox(height: 16),

              // Content
              TextField(
                controller: _contentController,
                maxLines: 6,
                maxLength: PostConstants.maxPostLength,
                decoration: InputDecoration(
                  hintText: 'What\'s on your heart?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Scripture Reference
              TextField(
                onChanged: (value) => _scriptureReference = value,
                decoration: InputDecoration(
                  hintText: 'Scripture Reference (e.g., John 3:16)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Scripture Verse
              TextField(
                onChanged: (value) => _scriptureVerse = value,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Scripture Verse',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Image/Video upload buttons
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Implement image picker
                    },
                    icon: const Icon(Icons.image),
                    label: const Text('Image'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Implement video picker
                    },
                    icon: const Icon(Icons.video_camera_front),
                    label: const Text('Video'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitPost,
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Post'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitPost() async {
    if (_contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write something'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('Not authenticated');

      final profile = await Supabase.instance.client
          .from('profiles')
          .select('church_id')
          .eq('id', user.id)
          .single();

      final churchId = profile['church_id'] as String?;
      if (churchId == null) throw Exception('No church found');

      await FeedService().createPost(
        content: _contentController.text.trim(),
        postType: _selectedType,
        churchId: churchId,
        scriptureReference: _scriptureReference,
        scriptureVerse: _scriptureVerse,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }
}

// ============================================
// COMMENTS SHEET
// ============================================
class CommentsSheet extends StatefulWidget {
  final Post post;

  const CommentsSheet({super.key, required this.post});

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final FeedService _feedService = FeedService();
  final TextEditingController _commentController = TextEditingController();

  List<Comment> _comments = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _replyingTo;
  String? _replyingToName;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    try {
      final comments = await _feedService.getComments(widget.post.id);
      setState(() {
        _comments = comments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitComment() async {
    if (_commentController.text.isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      await _feedService.createComment(
        postId: widget.post.id,
        content: _commentController.text.trim(),
        parentCommentId: _replyingTo,
      );

      _commentController.clear();
      _replyingTo = null;
      _replyingToName = null;
      await _loadComments();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Comments (${widget.post.commentCount})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy800,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Comment input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: _replyingTo != null
                        ? 'Replying to $_replyingToName...'
                        : 'Write a comment...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    suffixIcon: _replyingTo != null
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                _replyingTo = null;
                                _replyingToName = null;
                              });
                            },
                            icon: const Icon(Icons.close, size: 16),
                          )
                        : null,
                  ),
                  onSubmitted: (_) => _submitComment(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _isSubmitting ? null : _submitComment,
                icon: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                color: AppColors.navy600,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Comments list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _comments.isEmpty
                ? Center(
                    child: Text(
                      'No comments yet. Be the first!',
                      style: TextStyle(color: AppColors.neutral500),
                    ),
                  )
                : ListView.builder(
                    itemCount: _comments.length,
                    itemBuilder: (context, index) {
                      final comment = _comments[index];
                      return CommentTile(
                        comment: comment,
                        onReply: (id, name) {
                          setState(() {
                            _replyingTo = id;
                            _replyingToName = name;
                          });
                          FocusScope.of(context).requestFocus();
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// COMMENT TILE
// ============================================
class CommentTile extends StatelessWidget {
  final Comment comment;
  final Function(String, String) onReply;

  const CommentTile({super.key, required this.comment, required this.onReply});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.navy600,
            child: Text(
              comment.fullName.isNotEmpty
                  ? comment.fullName[0].toUpperCase()
                  : 'U',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.navy800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  comment.content,
                  style: TextStyle(fontSize: 14, color: AppColors.neutral700),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      comment.timeAgo,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.neutral400,
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () => onReply(comment.id, comment.fullName),
                      child: Text(
                        'Reply',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.navy600,
                        ),
                      ),
                    ),
                    if (comment.replies.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      Text(
                        '${comment.replies.length} replies',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.neutral400,
                        ),
                      ),
                    ],
                  ],
                ),
                // Replies
                if (comment.replies.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ...comment.replies.map(
                    (reply) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: CommentTile(comment: reply, onReply: onReply),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
