import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wordoflifemobile/core/ui/devotional_card.dart';
import 'package:wordoflifemobile/core/ui/loading_skeleton.dart';
import 'package:wordoflifemobile/screens/user/devotional_details_screen.dart';
import 'package:wordoflifemobile/services/auth_service.dart';
import 'package:wordoflifemobile/services/devotional_service.dart';
import 'package:wordoflifemobile/data/models/devotional.dart';
import 'package:wordoflifemobile/core/theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final DevotionalService _devotionalService = DevotionalService();

  // Profile
  Map<String, dynamic>? _profile;
  bool _isLoadingProfile = true;
  String? _profileError;

  // Devotional
  Devotional? _devotional;
  bool _isLoadingDevotional = true;
  String? _devotionalError;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // LOAD DATA
  Future<void> _loadData() async {
    await Future.wait([getCurrentUserProfile(), getTodayDevotional()]);
  }

  // GET CURRENT USER PROFILE
  Future<void> getCurrentUserProfile() async {
    setState(() {
      _isLoadingProfile = true;
      _profileError = null;
    });

    try {
      final profile = await _authService.getCurrentUserProfile();

      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
          _profileError = 'Failed to load profile';
        });
      }
      debugPrint('Error getting current user profile: $e');
    }
  }

  // GET TODAY'S DEVOTIONAL
  Future<void> getTodayDevotional() async {
    setState(() {
      _isLoadingDevotional = true;
      _devotionalError = null;
    });

    try {
      final devotional = await _devotionalService.getTodayDevotional();

      if (mounted) {
        setState(() {
          _devotional = devotional;
          _isLoadingDevotional = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingDevotional = false;
          _devotionalError = 'Failed to load devotional';
        });
      }
      debugPrint('Error getting devotional: $e');
    }
  }

  // REFRESH
  Future<void> _refresh() async {
    await Future.wait([getCurrentUserProfile(), getTodayDevotional()]);

    if (mounted && _profile != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Refreshed!'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  // GET GREETING MESSAGE
  String getGreetingMessage() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 0 && hour < 3) {
      return '🌙 Late Night';
    } else if (hour >= 3 && hour < 6) {
      return '🌅 Early Dawn';
    } else if (hour >= 6 && hour < 9) {
      return '🌤️ Good Morning';
    } else if (hour >= 9 && hour < 12) {
      return '☀️ Late Morning';
    } else if (hour >= 12 && hour < 14) {
      return '🌞 Good Afternoon';
    } else if (hour >= 14 && hour < 17) {
      return '🌇 Warm Afternoon';
    } else if (hour >= 17 && hour < 19) {
      return '🌅 Good Evening';
    } else if (hour >= 19 && hour < 21) {
      return '🌆 Quiet Evening';
    } else {
      return '🌙 Good Night';
    }
  }

  // GET FIRST NAME
  String _getFirstName(String fullName) {
    if (fullName.isEmpty) return 'User';
    final parts = fullName.split(' ');
    return parts.first;
  }

  // BUILD
  @override
  Widget build(BuildContext context) {
    final isLoading = _isLoadingProfile;
    final hasError = _profileError != null;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LOADING STATE
                if (isLoading) ...[
                  Shimmer.fromColors(
                    baseColor: AppColors.neutral200,
                    highlightColor: AppColors.neutral100,
                    child: const HomeScreenSkeleton(),
                  ),
                ]
                // ERROR STATE
                else if (hasError) ...[
                  _errorState(),
                ]
                // CONTENT
                else ...[
                  // HEADER
                  _buildHeader(),
                  const SizedBox(height: 20),

                  // DEVOTIONAL CARD
                  DevotionalCard(
                    devotional: _devotional,
                    isLoading: _isLoadingDevotional,
                    onRefresh: getTodayDevotional,
                    onTap: () {
                      if (_devotional != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DevotionalDetailScreen(
                              devotional: _devotional!,
                            ),
                          ),
                        );
                      }
                    },
                  ),

                  // QUICK ACTIONS
                  const SizedBox(height: 20),
                  _buildDivider(
                    "Quick Actions",
                    PhosphorIcons.acorn,
                    Colors.white,
                  ),
                  const SizedBox(height: 15),
                  _buildQuickActions(),
                  const SizedBox(height: 20),
                  // SUGGESTED FOR YOU
                  _buildDivider(
                    "Suggested for You",
                    PhosphorIcons.sparkle,
                    AppColors.gold600,
                  ),
                  const SizedBox(height: 15),
                  _buildSuggestedForYou(),
                  const SizedBox(height: 20),
                  // MEMORY VERSE
                  _buildMemDivider(
                    PhosphorIcons.starFourFill,
                    AppColors.gold600,
                  ),
                  const SizedBox(height: 15),
                  _buildMemoryVerseCard(),
                  const SizedBox(height: 80),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // error state
  Widget _errorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 12),
          Text(
            _profileError ?? _devotionalError ?? 'Something went wrong',
            style: TextStyle(color: AppColors.error, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _refresh, child: const Text('Retry')),
        ],
      ),
    );
  }

  // build header
  Widget _buildHeader() {
    final fullName = _profile?['full_name'] ?? '';
    final firstName = _getFirstName(fullName);
    final churchName = _profile?['church']?['name'];
    final hasChurch = _profile?['church_id'] != null;
    final role = _profile?['role'] ?? 'user';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 6),
              Text(
                getGreetingMessage(),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.neutral500,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: role == 'pastor'
                        ? [AppColors.prayerPurple, AppColors.prayerPurpleDark]
                        : [AppColors.navy600, AppColors.navy800],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      role == 'pastor'
                          ? Icons.auto_awesome
                          : Icons.person_outline,
                      color: Colors.white,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      role == 'pastor' ? 'Pastor' : 'Member',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      firstName,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy900,
                        letterSpacing: -0.5,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Decorative underline
                    Container(
                      width: 50,
                      height: 4,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.navy600, AppColors.navy400],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.navy600, AppColors.navy800],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.navy600.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          if (hasChurch) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.pastelBlue,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.navy200.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    PhosphorIconsFill.church,
                    color: AppColors.navy600,
                    size: 14,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    churchName ?? 'Member of a church',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.navy700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Joined',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    PhosphorIconsFill.warning,
                    color: AppColors.warning,
                    size: 14,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Join a church to connect with your community',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // build quick actions
  List<_ActionItems> quickActions = [
    _ActionItems(
      icon: PhosphorIcons.handsPraying,
      label: 'Prayer Wall',
      description: 'Share and Pray together',
      color: AppColors.prayerPurple,
      iconColor: Colors.white,
      onTap: () {},
    ),
    _ActionItems(
      icon: PhosphorIcons.bookOpenText,
      label: 'Bible Study',
      description: 'Study room and groups',
      color: AppColors.studyGold,
      iconColor: Colors.white,
      onTap: () {},
    ),
    _ActionItems(
      icon: PhosphorIcons.bookOpenUser,
      label: 'Reading Plans',
      description: 'Daily Bible reading schedule',
      color: AppColors.readingTeal,
      iconColor: Colors.white,
      onTap: () {},
    ),
    _ActionItems(
      icon: PhosphorIcons.megaphone,
      label: 'Announcements',
      description: 'Latest church news',
      color: AppColors.announcementCoral,
      iconColor: Colors.white,
      onTap: () {},
    ),
    _ActionItems(
      icon: PhosphorIcons.bookBookmark,
      label: 'Devotionals',
      description: 'Daily devotionals and reflections',
      color: AppColors.devotionalRose,
      iconColor: Colors.white,
      onTap: () {},
    ),
    _ActionItems(
      icon: PhosphorIcons.user,
      label: 'My Profile',
      description: 'View and edit your profile information',
      color: AppColors.profileBlue,
      iconColor: Colors.white,
      onTap: () {},
    ),
  ];

  Widget _buildQuickActions() {
    return GridView.builder(
      itemCount: quickActions.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemBuilder: (context, index) => _buildActionCard(index),
    );
  }

  Widget _buildActionCard(int index) {
    final action = quickActions[index];

    return InkWell(
      onTap: action.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              action.color.withValues(alpha: 0.85),
              action.color.withValues(alpha: 0.95),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: action.color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Icon(action.icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    action.label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    action.description,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // build suggested for you

  List<_SuggestedItems> suggestedForYou = [
    _SuggestedItems(
      title: 'Faith Over Doubt: Staying Anchored',
      description:
          'Based on your honest reflections about trusting God in uncertain times',
      icon: PhosphorIcons.anchor,
      color: AppColors.prayerPurple,
      onTap: () {},
    ),
    _SuggestedItems(
      title: 'The Revelation of Oneness: Deepening Connection',
      description:
          'In your Luke 3 journal, you expressed a desire for deeper community',
      icon: PhosphorIcons.waves,
      color: AppColors.readingTeal,
      onTap: () {},
    ),
    _SuggestedItems(
      title: 'Watch and Pray: Rekindling Spiritual Vigilance',
      description:
          'You recently journaled about the danger of spiritual complacency',
      icon: PhosphorIcons.fire,
      color: AppColors.announcementCoral,
      onTap: () {},
    ),
    _SuggestedItems(
      title: 'Grace in the Wilderness: Finding God\'s Presence',
      description: 'Based on your reflections about feeling distant from God',
      icon: PhosphorIcons.tree,
      color: AppColors.forestGreen,
      onTap: () {},
    ),
    _SuggestedItems(
      title: 'The Power of Forgiveness: Healing Relationships',
      description:
          'You wrote about struggling with forgiveness in your journal',
      icon: PhosphorIcons.heart,
      color: AppColors.devotionalRose,
      onTap: () {},
    ),
  ];

  Widget _buildSuggestedForYou() {
    return Column(
      children: [
        ListView.builder(
          itemCount: suggestedForYou.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) => _buildSuggestedCard(index),
        ),
        const SizedBox(height: 2),
        TextButton(
          onPressed: () {},
          style: ButtonStyle(
            padding: WidgetStatePropertyAll(const EdgeInsets.all(0)),
            overlayColor: WidgetStatePropertyAll(Colors.transparent),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "View All Reading Plans",
                style: TextStyle(
                  color: AppColors.navy600,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                PhosphorIconsBold.caretRight,
                color: AppColors.navy600,
                size: 16,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestedCard(int index) {
    final item = suggestedForYou[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral200, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral200.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [item.color, item.color.withValues(alpha: 0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: item.color.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(item.icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navy800,
                          height: 1.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.neutral600,
                          height: 1.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        width: 75,
                        decoration: BoxDecoration(
                          color: item.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              PhosphorIcons.bookOpen,
                              color: item.color,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "7 Days",
                              style: TextStyle(
                                fontSize: 12,
                                color: item.color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: item.color,
                    size: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMemoryVerseCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.navy800, AppColors.navy600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy600.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: AppColors.gold400,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Verse of the Day',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gold300,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.bookmark_border,
                  color: Colors.white.withValues(alpha: 0.6),
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '"For I know the plans I have for you, declares the Lord, plans to prosper you and not to harm you, plans to give you hope and a future."',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1.6,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 3,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.gold400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Jeremiah 29:11',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gold300,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: AppColors.gold400,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Memorize',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.share,
                  color: Colors.white.withValues(alpha: 0.8),
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // build divider

  Widget _buildDivider(String text, IconData icon, Color iconColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.navy600, AppColors.navy800],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: AppColors.navy600.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [AppColors.navy600, AppColors.navy800],
          ).createShader(bounds),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.navy600, Colors.transparent],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMemDivider(IconData icon, Color iconColor) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, AppColors.navy600],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, AppColors.navy600],
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionItems {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  _ActionItems({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });
}

class _SuggestedItems {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _SuggestedItems({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
