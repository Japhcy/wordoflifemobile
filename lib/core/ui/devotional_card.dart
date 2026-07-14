import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:wordoflifemobile/core/theme/app_colors.dart';
import 'package:wordoflifemobile/data/models/devotional.dart';
import 'package:wordoflifemobile/screens/user/devotional_screen.dart';

class DevotionalCard extends StatefulWidget {
  final Devotional? devotional;
  final bool isLoading;
  final VoidCallback? onRefresh;
  final VoidCallback? onTap;
  final bool showFullContent;

  const DevotionalCard({
    super.key,
    this.devotional,
    this.isLoading = false,
    this.onRefresh,
    this.onTap,
    this.showFullContent = false,
  });

  @override
  State<DevotionalCard> createState() => _DevotionalCardState();
}

class _DevotionalCardState extends State<DevotionalCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.devotional?.isFavorite ?? false;
  }

  @override
  void didUpdateWidget(covariant DevotionalCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.devotional?.isFavorite != widget.devotional?.isFavorite) {
      _isFavorite = widget.devotional?.isFavorite ?? false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) return _buildLoadingState();
    if (widget.devotional == null) return _buildEmptyState();

    final devotional = widget.devotional!;
    final isExpanded = widget.showFullContent || _isExpanded;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: widget.onTap,
        child: Container(
          decoration: _cardDecoration,
          child: Stack(
            children: [
              // soft glow / ambient accents
              Positioned(
                top: -20,
                right: -20,
                child: _blurOrb(
                  size: 120,
                  color: AppColors.gold400.withValues(alpha: 0.16),
                ),
              ),
              Positioned(
                bottom: -35,
                left: -20,
                child: _blurOrb(
                  size: 140,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),

              // subtle top highlight
              Positioned(
                top: 0,
                left: 24,
                right: 24,
                child: Container(
                  height: 1.2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.0),
                        Colors.white.withValues(alpha: 0.35),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(devotional),
                    const SizedBox(height: 18),
                    _buildTitle(devotional),
                    const SizedBox(height: 16),
                    _buildScriptureCard(devotional),
                    const SizedBox(height: 16),

                    AnimatedCrossFade(
                      firstChild: const SizedBox.shrink(),
                      secondChild: Column(
                        children: [
                          _buildExplanation(devotional),
                          if (devotional.tags.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            _buildTags(devotional),
                          ],
                        ],
                      ),
                      crossFadeState: isExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 250),
                      sizeCurve: Curves.easeOutCubic,
                    ),

                    const SizedBox(height: 8),
                    _buildPrimaryButton(),
                    const SizedBox(height: 14),
                    _buildBottomBar(devotional, isExpanded),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // MAIN CARD PIECES
  // =========================================================

  Widget _buildHeader(Devotional devotional) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.gold400.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.gold300.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      PhosphorIconsFill.sparkle,
                      size: 14,
                      color: AppColors.gold300,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Today’s Devotional',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gold300,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
              if (!devotional.isRead) ...[
                const SizedBox(width: 10),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.gold400,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold400.withValues(alpha: 0.45),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        _buildIconAction(
          icon: _isFavorite
              ? PhosphorIconsFill.heart
              : PhosphorIconsRegular.heart,
          color: _isFavorite ? AppColors.error : Colors.white70,
          onTap: () {
            setState(() => _isFavorite = !_isFavorite);
            // TODO: persist favorite state
          },
        ),
        if (widget.onRefresh != null) ...[
          const SizedBox(width: 8),
          _buildIconAction(
            icon: PhosphorIconsRegular.arrowClockwise,
            color: Colors.white70,
            onTap: widget.onRefresh!,
          ),
        ],
      ],
    );
  }

  Widget _buildTitle(Devotional devotional) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          devotional.displayTitle,
          style: const TextStyle(
            fontSize: 24,
            height: 1.15,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _formatDate(devotional.date),
          style: TextStyle(
            fontSize: 12.5,
            color: Colors.white.withValues(alpha: 0.65),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildScriptureCard(Devotional devotional) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                PhosphorIconsFill.quotes,
                size: 18,
                color: AppColors.gold300.withValues(alpha: 0.9),
              ),
              const SizedBox(height: 10),
              Text(
                devotional.scripture,
                style: const TextStyle(
                  fontSize: 17,
                  height: 1.7,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gold400.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    devotional.reference,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gold200,
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

  Widget _buildExplanation(Devotional devotional) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Text(
        devotional.explanation,
        style: TextStyle(
          fontSize: 14.5,
          height: 1.75,
          color: Colors.white.withValues(alpha: 0.88),
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildTags(Devotional devotional) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: devotional.tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Text(
            '#$tag',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.gold300,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPrimaryButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DevotionalScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: AppColors.navy800,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        icon: const Icon(PhosphorIconsRegular.bookOpenText, size: 18),
        label: const Text(
          'Open Devotional',
          style: TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(Devotional devotional, bool isExpanded) {
    return Row(
      children: [
        if (!widget.showFullContent)
          InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () {
              setState(() => _isExpanded = !_isExpanded);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
              child: Row(
                children: [
                  Icon(
                    isExpanded
                        ? PhosphorIconsRegular.caretUp
                        : PhosphorIconsRegular.caretDown,
                    color: Colors.white70,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isExpanded ? 'Show less' : 'Read more',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.75),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

        const Spacer(),

        _buildSmallAction(
          icon: PhosphorIconsRegular.shareNetwork,
          label: 'Share',
          onTap: () {
            // TODO: implement share
          },
        ),
      ],
    );
  }

  // =========================================================
  // STATES
  // =========================================================

  Widget _buildLoadingState() {
    return Container(
      decoration: _cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(20),
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
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: _cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Icon(
                PhosphorIconsRegular.bookOpenText,
                size: 30,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No devotional available yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later or refresh to load the latest devotional.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            if (widget.onRefresh != null) ...[
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: widget.onRefresh,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.22)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(PhosphorIconsRegular.arrowClockwise),
                label: const Text(
                  'Refresh',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // =========================================================
  // HELPERS / UI PARTS
  // =========================================================

  BoxDecoration get _cardDecoration {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(28),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1D3A74), Color(0xFF132A56), Color(0xFF0E1F42)],
      ),
      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      boxShadow: [
        BoxShadow(
          color: AppColors.navy900.withValues(alpha: 0.28),
          blurRadius: 28,
          offset: const Offset(0, 16),
        ),
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.03),
          blurRadius: 1,
          spreadRadius: 1,
        ),
      ],
    );
  }

  Widget _buildIconAction({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }

  Widget _buildSmallAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 15, color: Colors.white60),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                color: Colors.white.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _blurOrb({required double size, required Color color}) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: color, blurRadius: 70, spreadRadius: 18),
          ],
        ),
      ),
    );
  }

  Widget _skeletonBox({
    required double width,
    required double height,
    double radius = 12,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final difference = today.difference(dateOnly).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '$difference days ago';
    return '${date.month}/${date.day}/${date.year}';
  }
}
