import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:wordoflifemobile/core/theme/app_colors.dart';

class PostConstants {
  static final Map<String, PostTypeData> postTypes = {
    'general': const PostTypeData(
      label: 'General',
      icon: PhosphorIcons.chatCircle,
      color: AppColors.navy600,
      backgroundColor: AppColors.pastelBlue,
    ),
    'testimony': const PostTypeData(
      label: 'Testimony',
      icon: PhosphorIcons.sparkle,
      color: AppColors.studyGold,
      backgroundColor: AppColors.studyGoldLight,
    ),
    'prayer_request': const PostTypeData(
      label: 'Prayer Request',
      icon: PhosphorIcons.handsPraying,
      color: AppColors.prayerPurple,
      backgroundColor: AppColors.prayerPurpleLight,
    ),
    'announcement': const PostTypeData(
      label: 'Announcement',
      icon: PhosphorIcons.megaphone,
      color: AppColors.announcementCoral,
      backgroundColor: AppColors.announcementCoralLight,
    ),
    'question': const PostTypeData(
      label: 'Question',
      icon: PhosphorIcons.question,
      color: AppColors.readingTeal,
      backgroundColor: AppColors.readingTealLight,
    ),
    'praise_report': const PostTypeData(
      label: 'Praise Report',
      icon: PhosphorIcons.handsClapping,
      color: AppColors.devotionalRose,
      backgroundColor: AppColors.devotionalRoseLight,
    ),
    'scripture': PostTypeData(
      label: 'Scripture',
      icon: PhosphorIcons.bookOpen,
      color: AppColors.forestGreen,
      backgroundColor: AppColors.forestGreen,
    ),
  };

  static const List<String> postTypeList = [
    'general',
    'testimony',
    'prayer_request',
    'announcement',
    'question',
    'praise_report',
    'scripture',
  ];

  static const Map<String, int> mediaLimits = {
    'image': 10 * 1024 * 1024, // 10 MB
    'video': 50 * 1024 * 1024, // 50 MB
  };

  static const int maxPostLength = 5000;
  static const int defaultPostLimit = 10;
}

class PostTypeData {
  final String label;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const PostTypeData({
    required this.label,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });
}