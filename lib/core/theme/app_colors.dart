import 'package:flutter/material.dart';

class AppColors {
  // PRIMARY COLORS - Navy Blue Family
  static const Color navy900 = Color(0xFF0A1628);
  static const Color navy800 = Color(0xFF132240);
  static const Color navy700 = Color(0xFF1A2F4F);
  static const Color navy600 = Color(0xFF1F3A5F);
  static const Color navy500 = Color(0xFF264773);
  static const Color navy400 = Color(0xFF2E5488);
  static const Color navy300 = Color(0xFF3B6BA8);
  static const Color navy200 = Color(0xFF5A8BC4);
  static const Color navy100 = Color(0xFF8AB0DA);
  static const Color navy50 = Color(0xFFC5D8EE);

  // SECONDARY COLORS - Soft Blues / Sky
  static const Color sky900 = Color(0xFF0B2B4A);
  static const Color sky800 = Color(0xFF124066);
  static const Color sky700 = Color(0xFF1A5582);
  static const Color sky600 = Color(0xFF226A9E);
  static const Color sky500 = Color(0xFF2A7FBA);
  static const Color sky400 = Color(0xFF4A9AD4);
  static const Color sky300 = Color(0xFF7AB8E0);
  static const Color sky200 = Color(0xFFA8D0EA);
  static const Color sky100 = Color(0xFFD0E6F5);
  static const Color sky50 = Color(0xFFEBF3FA);

  // ACCENT COLORS - Warm Gold / Light
  static const Color gold900 = Color(0xFF7A6400);
  static const Color gold800 = Color(0xFF9E8200);
  static const Color gold700 = Color(0xFFC2A000);
  static const Color gold600 = Color(0xFFE6BE00);
  static const Color gold500 = Color(0xFFFFD700);
  static const Color gold400 = Color(0xFFFFDF4D);
  static const Color gold300 = Color(0xFFFFE880);
  static const Color gold200 = Color(0xFFFFF0B3);
  static const Color gold100 = Color(0xFFFFF8D9);
  static const Color gold50 = Color(0xFFFFFCF0);

  // PASTEL COLORS - Soft & Calming
  static const Color pastelBlue = Color(0xFFE3EEF9);
  static const Color pastelLavender = Color(0xFFEBE6F7);
  static const Color pastelMint = Color(0xFFE6F5EE);
  static const Color pastelPeach = Color(0xFFFDF0E6);
  static const Color pastelRose = Color(0xFFFDE6EC);
  static const Color pastelSky = Color(0xFFE6F2FA);
  static const Color pastelCream = Color(0xFFFFFBF0);

  // NEUTRAL COLORS
  static const Color neutral900 = Color(0xFF1A1A1A);
  static const Color neutral800 = Color(0xFF2D2D2D);
  static const Color neutral700 = Color(0xFF404040);
  static const Color neutral600 = Color(0xFF595959);
  static const Color neutral500 = Color(0xFF737373);
  static const Color neutral400 = Color(0xFFA6A6A6);
  static const Color neutral300 = Color(0xFFBFBFBF);
  static const Color neutral200 = Color(0xFFD9D9D9);
  static const Color neutral100 = Color(0xFFF0F0F0);
  static const Color neutral50 = Color(0xFFFAFAFA);

  // STATUS COLORS
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFED6C02);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color error = Color(0xFFC62828);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF01579B);
  static const Color infoLight = Color(0xFFE1F5FE);

  // CHURCH THEME SPECIFIC
  static const Color scriptureGold = Color(0xFFC9A84C);
  static const Color doveWhite = Color(0xFFFDFDFD);
  static const Color peacefulBlue = Color(0xFFE8F0FE);
  static const Color warmBeige = Color(0xFFF5F0E8);
  static const Color chapelWood = Color(0xFF8B7355);

  // QUICK ACTIONS - AESTHETIC COLORS
  // Prayer Wall - Deep Purple (Meditation, Prayer, Spirituality)
  static const Color prayerPurple = Color(0xFF6C4A8C);
  static const Color prayerPurpleLight = Color(0xFFE8DCF0);
  static const Color prayerPurpleDark = Color(0xFF4A2D6A);

  // Bible Study - Warm Gold (Wisdom, Scripture, Light)
  static const Color studyGold = Color(0xFFC9A84C);
  static const Color studyGoldLight = Color(0xFFF5EDD6);
  static const Color studyGoldDark = Color(0xFFA8883A);

  // Reading Plans - Calming Teal (Growth, Learning, Peace)
  static const Color readingTeal = Color(0xFF2E86AB);
  static const Color readingTealLight = Color(0xFFD6EDF5);
  static const Color readingTealDark = Color(0xFF1D6A87);

  // Announcements - Warm Coral (Communication, Energy, Joy)
  static const Color announcementCoral = Color(0xFFE87766);
  static const Color announcementCoralLight = Color(0xFFFDE8E4);
  static const Color announcementCoralDark = Color(0xFFD15F4E);

  // Devotionals - Soft Rose (Love, Reflection, Grace)
  static const Color devotionalRose = Color(0xFFD4858A);
  static const Color devotionalRoseLight = Color(0xFFF5E4E6);
  static const Color devotionalRoseDark = Color(0xFFB86A6F);

  // Profile - Trustworthy Blue (Identity, Stability, Faith)
  static const Color profileBlue = Color(0xFF4A7FAA);
  static const Color profileBlueLight = Color(0xFFDEEAF5);
  static const Color profileBlueDark = Color(0xFF34658A);

  // ALTERNATE COLOR OPTIONS (Mix & Match)

  // Option: Forest Green (Growth, Life, Renewal)
  static const Color forestGreen = Color(0xFF4A7C59);

  // Option: Warm Amber (Comfort, Warmth, Welcome)
  static const Color warmAmber = Color(0xFFE8A04A);

  // Option: Soft Lavender (Peace, Calm, Serenity)
  static const Color softLavender = Color(0xFF9B8EC4);

  // Option: Ocean Blue (Depth, Trust, Stability)
  static const Color oceanBlue = Color(0xFF3A7CA5);

  // Option: Blush Pink (Gentleness, Love, Kindness)
  static const Color blushPink = Color(0xFFE8A0A8);

  // Option: Sage Green (Wisdom, Balance, Peace)
  static const Color sageGreen = Color(0xFF8BA89A);
}

// APP THEME - Light Mode
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Primary Colors
    primaryColor: AppColors.navy600,
    primaryColorLight: AppColors.navy100,
    primaryColorDark: AppColors.navy800,

    // Color Scheme
    colorScheme: const ColorScheme.light(
      primary: AppColors.navy600,
      secondary: AppColors.gold500,
      tertiary: AppColors.sky500,
      surface: AppColors.neutral50,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: AppColors.neutral900,
      onSurface: AppColors.neutral900,
      onError: Colors.white,
      brightness: Brightness.light,
    ),

    // App Bar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.navy600,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),

    // Scaffold Background
    scaffoldBackgroundColor: AppColors.neutral50,

    // Card Theme
    cardTheme: const CardThemeData(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      shadowColor: AppColors.navy200,
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.neutral300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.neutral300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.navy500, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      labelStyle: const TextStyle(color: AppColors.neutral600),
      hintStyle: const TextStyle(color: AppColors.neutral400),
    ),

    // Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.navy600,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.navy600,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.navy600,
        side: const BorderSide(color: AppColors.navy600),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Floating Action Button
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.gold500,
      foregroundColor: AppColors.navy900,
      elevation: 4,
      shape: CircleBorder(),
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.pastelBlue,
      labelStyle: const TextStyle(color: AppColors.navy700),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.navy200),
      ),
    ),

    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.navy900,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.navy900,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.navy900,
      ),
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.navy800,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.navy800,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.navy700,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: AppColors.navy700,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.navy700,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.neutral700,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: AppColors.neutral800,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: AppColors.neutral700,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: AppColors.neutral600,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.navy700,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.neutral600,
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        color: AppColors.neutral500,
      ),
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: AppColors.neutral200,
      thickness: 1,
      space: 1,
    ),

    // Icon Theme
    iconTheme: const IconThemeData(
      color: AppColors.navy600,
      size: 24,
    ),
  );
}

// APP THEME - Dark Mode
class AppThemeDark {
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // Primary Colors
    primaryColor: AppColors.navy300,
    primaryColorLight: AppColors.navy100,
    primaryColorDark: AppColors.navy800,

    // Color Scheme
    colorScheme: const ColorScheme.dark(
      primary: AppColors.navy300,
      secondary: AppColors.gold400,
      tertiary: AppColors.sky300,
      surface: AppColors.neutral900,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: AppColors.neutral900,
      onSurface: AppColors.neutral50,
      onError: Colors.white,
      brightness: Brightness.dark,
    ),

    // App Bar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.navy900,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),

    // Scaffold Background
    scaffoldBackgroundColor: AppColors.navy900,

    // Card Theme
    cardTheme: CardThemeData(
      color: AppColors.navy800,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      shadowColor: Colors.black.withValues(alpha: 0.3),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.navy800,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.navy500),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.navy500),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.navy300, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      labelStyle: const TextStyle(color: AppColors.neutral400),
      hintStyle: const TextStyle(color: AppColors.neutral500),
    ),

    // Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.navy300,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.navy300,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.navy300,
        side: const BorderSide(color: AppColors.navy300),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Floating Action Button
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.gold400,
      foregroundColor: AppColors.navy900,
      elevation: 4,
      shape: CircleBorder(),
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.navy700,
      labelStyle: const TextStyle(color: AppColors.neutral200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.navy400),
      ),
    ),

    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.neutral50,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.neutral50,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.neutral50,
      ),
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.neutral100,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.neutral100,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.neutral200,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: AppColors.neutral100,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.neutral100,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.neutral300,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: AppColors.neutral200,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: AppColors.neutral300,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: AppColors.neutral400,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.neutral100,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.neutral400,
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        color: AppColors.neutral500,
      ),
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: AppColors.navy600,
      thickness: 1,
      space: 1,
    ),

    // Icon Theme
    iconTheme: const IconThemeData(
      color: AppColors.navy300,
      size: 24,
    ),
  );
}