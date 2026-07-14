import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wordoflifemobile/core/theme/app_colors.dart';

class LoadingSkeleton extends StatelessWidget {
  final Widget child;
  final bool isLoading;

  const LoadingSkeleton({
    super.key,
    required this.child,
    this.isLoading = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;

    return Shimmer.fromColors(
      baseColor: AppColors.neutral200,
      highlightColor: AppColors.neutral100,
      child: child,
    );
  }
}

// ============================================
// HOME SCREEN LOADING SKELETON
// ============================================
class HomeScreenSkeleton extends StatelessWidget {
  const HomeScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Skeleton
        _buildHeaderSkeleton(),
        const SizedBox(height: 20),
        // Devotional Card Skeleton
        _buildDevotionalCardSkeleton(),
        const SizedBox(height: 20),
        // Quick Actions Skeleton
        _buildQuickActionsSkeleton(),
        const SizedBox(height: 20),
        // Suggested For You Skeleton
        _buildSuggestedForYouSkeleton(),
        const SizedBox(height: 20),
        // Memory Verse Skeleton
        _buildMemoryVerseSkeleton(),
      ],
    );
  }

  Widget _buildHeaderSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _skeletonBox(width: 120, height: 18, radius: 8),
        const SizedBox(height: 6),
        _skeletonBox(width: 180, height: 32, radius: 10),
        const SizedBox(height: 4),
        _skeletonBox(width: 140, height: 16, radius: 8),
      ],
    );
  }

  Widget _buildDevotionalCardSkeleton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.navy800,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _skeletonBox(width: 130, height: 34, radius: 999),
          const SizedBox(height: 18),
          _skeletonBox(width: double.infinity, height: 28, radius: 10),
          const SizedBox(height: 10),
          _skeletonBox(width: 90, height: 14, radius: 8),
          const SizedBox(height: 16),
          _skeletonBox(width: double.infinity, height: 170, radius: 22),
          const SizedBox(height: 16),
          _skeletonBox(width: double.infinity, height: 54, radius: 18),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _skeletonBox(width: 140, height: 24, radius: 8),
        const SizedBox(height: 12),
        GridView.builder(
          itemCount: 6,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.6,
          ),
          itemBuilder: (context, index) => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                _skeletonBox(width: 48, height: 48, radius: 12),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _skeletonBox(
                        width: double.infinity,
                        height: 14,
                        radius: 6,
                      ),
                      const SizedBox(height: 4),
                      _skeletonBox(width: 60, height: 12, radius: 6),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestedForYouSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _skeletonBox(width: 160, height: 24, radius: 8),
        const SizedBox(height: 12),
        ListView.builder(
          itemCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                _skeletonBox(width: 52, height: 52, radius: 14),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _skeletonBox(
                        width: double.infinity,
                        height: 16,
                        radius: 6,
                      ),
                      const SizedBox(height: 4),
                      _skeletonBox(
                        width: double.infinity,
                        height: 14,
                        radius: 6,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMemoryVerseSkeleton() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.navy800, AppColors.navy600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _skeletonBox(width: 140, height: 28, radius: 20),
          const SizedBox(height: 20),
          _skeletonBox(width: double.infinity, height: 80, radius: 8),
          const SizedBox(height: 12),
          _skeletonBox(width: 120, height: 20, radius: 8),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _skeletonBox(
                  width: double.infinity,
                  height: 44,
                  radius: 12,
                ),
              ),
              const SizedBox(width: 12),
              _skeletonBox(width: 44, height: 44, radius: 12),
            ],
          ),
        ],
      ),
    );
  }

  Widget _skeletonBox({
    required double width,
    required double height,
    required double radius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
