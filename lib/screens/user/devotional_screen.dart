import 'package:flutter/material.dart';
import 'package:wordoflifemobile/core/theme/app_colors.dart';
import 'package:wordoflifemobile/data/models/devotional.dart';
import 'package:wordoflifemobile/services/devotional_service.dart';

class DevotionalScreen extends StatefulWidget {
  const DevotionalScreen({super.key});

  @override
  State<DevotionalScreen> createState() => _DevotionalScreenState();
}

class _DevotionalScreenState extends State<DevotionalScreen> {
  late final DevotionalService _devotionalService;
  int _selectedTab = 0;

  Future<Devotional?>? _todayFuture;
  Future<List<Devotional>>? _historyFuture;
  Future<List<Devotional>>? _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _devotionalService = DevotionalService();
    _loadAllData();
  }

  void _loadAllData() {
    setState(() {
      _todayFuture = _devotionalService.getTodayDevotional();
      _historyFuture = _devotionalService.getDevotionalHistory(limit: 30);
      _favoritesFuture = _devotionalService.getFavoriteDevotionals(limit: 30);
    });
  }

  Future<void> _refreshAll() async {
    _loadAllData();
    await Future.wait([
      _todayFuture ?? Future.value(null),
      _historyFuture ?? Future.value(<Devotional>[]),
      _favoritesFuture ?? Future.value(<Devotional>[]),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: const Text('Devotionals'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.navy800,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            color: AppColors.navy600,
            onPressed: _refreshAll,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                _buildTabButton('Today', 0),
                _buildTabButton('History', 1),
                _buildTabButton('Favorites', 2),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Content
          Expanded(
            child: RefreshIndicator(
              color: AppColors.navy600,
              onRefresh: _refreshAll,
              child: IndexedStack(
                index: _selectedTab,
                children: [
                  _buildTodayTab(),
                  _buildHistoryTab(),
                  _buildFavoritesTab(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.navy900.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.navy800 : AppColors.neutral500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTodayTab() {
    if (_todayFuture == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.navy600),
      );
    }

    return FutureBuilder<Devotional?>(
      future: _todayFuture!,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.navy600),
          );
        }

        if (snapshot.hasError) {
          return _buildEmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Error loading today\'s devotional',
            subtitle: snapshot.error.toString(),
            actionLabel: 'Retry',
            onAction: _refreshAll,
          );
        }

        final devotional = snapshot.data;
        if (devotional == null) {
          return _buildEmptyState(
            icon: Icons.calendar_today_rounded,
            title: 'No devotional for today',
            subtitle: 'Check back later or refresh',
            actionLabel: 'Refresh',
            onAction: _refreshAll,
          );
        }

        return _buildDevotionalCard(devotional, isToday: true);
      },
    );
  }

  // HISTORY TAB
  Widget _buildHistoryTab() {
    if (_historyFuture == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.navy600),
      );
    }

    return FutureBuilder<List<Devotional>>(
      future: _historyFuture!,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.navy600),
          );
        }

        if (snapshot.hasError) {
          return _buildEmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Error loading history',
            actionLabel: 'Retry',
            onAction: _refreshAll,
          );
        }

        final history = snapshot.data ?? [];
        if (history.isEmpty) {
          return _buildEmptyState(
            icon: Icons.history_rounded,
            title: 'No devotional history',
            subtitle: 'Start reading devotionals to build your history',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: history.length,
          itemBuilder: (context, index) {
            return _buildHistoryItem(history[index]);
          },
        );
      },
    );
  }

  // FAVORITES TAB
  Widget _buildFavoritesTab() {
    if (_favoritesFuture == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.navy600),
      );
    }

    return FutureBuilder<List<Devotional>>(
      future: _favoritesFuture!,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.navy600),
          );
        }

        if (snapshot.hasError) {
          return _buildEmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Error loading favorites',
            actionLabel: 'Retry',
            onAction: _refreshAll,
          );
        }

        final favorites = snapshot.data ?? [];
        if (favorites.isEmpty) {
          return _buildEmptyState(
            icon: Icons.favorite_border_rounded,
            title: 'No favorite devotionals',
            subtitle: 'Tap the heart icon to save devotionals',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            return _buildHistoryItem(favorites[index], isFavorite: true);
          },
        );
      },
    );
  }

  // =========================================================
  // SHARED EMPTY / ERROR STATE
  // =========================================================
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    String? subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.pastelBlue,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: AppColors.navy400),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.navy800,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.neutral500,
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy600,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(actionLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // =========================================================
  // UI BUILDERS
  // =========================================================

  Widget _buildDevotionalCard(Devotional devotional, {bool isToday = false}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.neutral200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  if (isToday)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.pastelBlue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Today's Devotional",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.navy700,
                        ),
                      ),
                    ),
                  const Spacer(),
                  FutureBuilder<List<Devotional>>(
                    future: _favoritesFuture,
                    builder: (context, favSnapshot) {
                      final isFavorite = favSnapshot.hasData
                          ? favSnapshot.data!.any((d) => d.id == devotional.id)
                          : false;
                      return _buildFavoriteButton(
                        isFavorite: isFavorite,
                        onTap: () => _toggleFavorite(devotional),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Title
              Text(
                devotional.displayTitle,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy900,
                ),
              ),
              const SizedBox(height: 8),
              // Date
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: AppColors.neutral500,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    devotional.date.toIso8601String().split('T').first,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.neutral500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Scripture
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.pastelBlue,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '"${devotional.scripture}"',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.navy800,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ),
                    if (devotional.reference.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        '— ${devotional.reference}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.navy600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Content
              Text(
                devotional.explanation,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: AppColors.neutral800,
                ),
              ),
              const SizedBox(height: 16),
              // Tags
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: devotional.tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.neutral50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.neutral200),
                    ),
                    child: Text(
                      '#$tag',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.navy600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              // Actions
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _markAsRead(devotional);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Marked as read'),
                        duration: Duration(seconds: 2),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Mark as Read'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navy600,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteButton({
    required bool isFavorite,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: isFavorite ? AppColors.pastelRose : AppColors.neutral100,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          size: 18,
          color: isFavorite ? AppColors.error : AppColors.neutral500,
        ),
      ),
    );
  }

  Widget _buildHistoryItem(Devotional devotional, {bool isFavorite = false}) {
    return FutureBuilder<List<Devotional>>(
      future: _favoritesFuture,
      builder: (context, favSnapshot) {
        final isFav = favSnapshot.hasData
            ? favSnapshot.data!.any((d) => d.id == devotional.id)
            : isFavorite;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.neutral200),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _showDevotionalDetail(devotional),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isFav
                            ? AppColors.pastelRose
                            : AppColors.pastelBlue,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFav ? Icons.favorite_rounded : Icons.book_rounded,
                        color: isFav ? AppColors.error : AppColors.navy600,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            devotional.displayTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: AppColors.navy800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            devotional.date.toIso8601String().split('T').first,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.neutral500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            devotional.scripture.length > 60
                                ? '${devotional.scripture.substring(0, 60)}...'
                                : devotional.scripture,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.neutral500,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildFavoriteButton(
                      isFavorite: isFav,
                      onTap: () => _toggleFavorite(devotional),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // =========================================================
  // ACTIONS
  // =========================================================

  Future<void> _toggleFavorite(Devotional devotional) async {
    final isCurrentlyFavorite = await _isFavorite(devotional.id);
    await _devotionalService.toggleFavorite(
      devotional.id,
      !isCurrentlyFavorite,
    );
    // Refresh favorites
    setState(() {
      _favoritesFuture = _devotionalService.getFavoriteDevotionals(limit: 30);
    });
  }

  Future<bool> _isFavorite(String devotionalId) async {
    final favorites = await _favoritesFuture;
    return favorites?.any((d) => d.id == devotionalId) ?? false;
  }

  Future<void> _markAsRead(Devotional devotional) async {
    await _devotionalService.markDevotionalRead(devotional.id);
  }

  void _showDevotionalDetail(Devotional devotional) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.neutral200,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  devotional.displayTitle,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.navy900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  devotional.date.toIso8601String().split('T').first,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.neutral500,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.pastelBlue,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '"${devotional.scripture}"',
                        style: const TextStyle(
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          color: AppColors.navy800,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '— ${devotional.reference}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.navy600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  devotional.explanation,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.7,
                    color: AppColors.neutral800,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: devotional.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.neutral100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '#$tag',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.neutral700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: FutureBuilder<List<Devotional>>(
                        future: _favoritesFuture,
                        builder: (context, favSnapshot) {
                          final isFav = favSnapshot.hasData
                              ? favSnapshot.data!.any(
                                  (d) => d.id == devotional.id,
                                )
                              : false;
                          return OutlinedButton.icon(
                            onPressed: () => _toggleFavorite(devotional),
                            icon: Icon(
                              isFav
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              size: 18,
                            ),
                            label: Text(isFav ? 'Remove' : 'Favorite'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isFav
                                  ? AppColors.error
                                  : AppColors.navy600,
                              side: BorderSide(
                                color: isFav
                                    ? AppColors.error
                                    : AppColors.navy600,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _markAsRead(devotional),
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: const Text('Mark Read'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.navy600,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
