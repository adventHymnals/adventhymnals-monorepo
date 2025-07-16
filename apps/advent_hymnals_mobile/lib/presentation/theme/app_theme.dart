import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_constants.dart';

class AppTheme {
  static const Color _primaryBlue = Color(AppColors.primaryBlue);
  static const Color _secondaryBlue = Color(AppColors.secondaryBlue);
  static const Color _successGreen = Color(AppColors.successGreen);
  static const Color _warningOrange = Color(AppColors.warningOrange);
  static const Color _errorRed = Color(AppColors.errorRed);
  static const Color _purple = Color(AppColors.purple);
  static const Color _background = Color(AppColors.background);
  static const Color _white = Color(AppColors.white);
  static const Color _black = Color(AppColors.black);
  static const Color _gray100 = Color(AppColors.gray100);
  static const Color _gray300 = Color(AppColors.gray300);
  static const Color _gray500 = Color(AppColors.gray500);
  static const Color _gray700 = Color(AppColors.gray700);
  static const Color _gray900 = Color(AppColors.gray900);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: _primaryBlue,
        secondary: _secondaryBlue,
        surface: _white,
        error: _errorRed,
        onPrimary: _white,
        onSecondary: _white,
        onSurface: _gray900,
        onError: _white,
      ),
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: _primaryBlue,
        foregroundColor: _white,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: TextStyle(
          fontFamily: AppFonts.inter,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: _white,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: _primaryBlue,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),

      // Bottom Navigation Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: _white,
        selectedItemColor: _secondaryBlue,
        unselectedItemColor: _gray500,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontFamily: AppFonts.inter,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: AppFonts.inter,
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: _white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _secondaryBlue,
          foregroundColor: _white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          ),
          minimumSize: const Size(0, AppSizes.minTouchTarget),
          textStyle: const TextStyle(
            fontFamily: AppFonts.inter,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _secondaryBlue,
          side: const BorderSide(color: _secondaryBlue),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          ),
          minimumSize: const Size(0, AppSizes.minTouchTarget),
          textStyle: const TextStyle(
            fontFamily: AppFonts.inter,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _secondaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          ),
          minimumSize: const Size(0, AppSizes.minTouchTarget),
          textStyle: const TextStyle(
            fontFamily: AppFonts.inter,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Icon Button Theme
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: _gray700,
          minimumSize: const Size(AppSizes.minTouchTarget, AppSizes.minTouchTarget),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          borderSide: const BorderSide(color: _gray300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          borderSide: const BorderSide(color: _gray300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          borderSide: const BorderSide(color: _secondaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          borderSide: const BorderSide(color: _errorRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          borderSide: const BorderSide(color: _errorRed, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spacing16,
          vertical: AppSizes.spacing12,
        ),
        hintStyle: const TextStyle(
          fontFamily: AppFonts.inter,
          fontSize: 14,
          color: _gray500,
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: _gray100,
        selectedColor: const Color(0xFFEFF6FF), // Light blue
        secondarySelectedColor: const Color(0xFFEFF6FF),
        labelStyle: const TextStyle(
          fontFamily: AppFonts.inter,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: const TextStyle(
          fontFamily: AppFonts.inter,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: _secondaryBlue,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spacing12,
          vertical: AppSizes.spacing4,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
      ),

      // List Tile Theme
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSizes.spacing16,
          vertical: AppSizes.spacing8,
        ),
        titleTextStyle: TextStyle(
          fontFamily: AppFonts.inter,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: _gray900,
        ),
        subtitleTextStyle: TextStyle(
          fontFamily: AppFonts.inter,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: _gray500,
        ),
        minVerticalPadding: AppSizes.spacing8,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: _gray300,
        thickness: 1,
        space: 1,
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return _white;
            }
            return _gray300;
          },
        ),
        trackColor: WidgetStateProperty.resolveWith<Color>(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return _secondaryBlue;
            }
            return _gray300;
          },
        ),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _secondaryBlue,
        linearTrackColor: _gray300,
        circularTrackColor: _gray300,
      ),

      // Snack Bar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _gray900,
        contentTextStyle: const TextStyle(
          fontFamily: AppFonts.inter,
          fontSize: 14,
          color: _white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogTheme(
        backgroundColor: _white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: AppFonts.inter,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: _gray900,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: AppFonts.inter,
          fontSize: 14,
          color: _gray700,
        ),
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: AppFonts.inter,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: _gray900,
        ),
        displayMedium: TextStyle(
          fontFamily: AppFonts.inter,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: _gray900,
        ),
        displaySmall: TextStyle(
          fontFamily: AppFonts.inter,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: _gray900,
        ),
        headlineLarge: TextStyle(
          fontFamily: AppFonts.inter,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _gray900,
        ),
        headlineMedium: TextStyle(
          fontFamily: AppFonts.inter,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: _gray900,
        ),
        headlineSmall: TextStyle(
          fontFamily: AppFonts.inter,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: _gray900,
        ),
        titleLarge: TextStyle(
          fontFamily: AppFonts.inter,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: _gray900,
        ),
        titleMedium: TextStyle(
          fontFamily: AppFonts.inter,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: _gray900,
        ),
        titleSmall: TextStyle(
          fontFamily: AppFonts.inter,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: _gray900,
        ),
        bodyLarge: TextStyle(
          fontFamily: AppFonts.inter,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: _gray900,
        ),
        bodyMedium: TextStyle(
          fontFamily: AppFonts.inter,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: _gray900,
        ),
        bodySmall: TextStyle(
          fontFamily: AppFonts.inter,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: _gray700,
        ),
        labelLarge: TextStyle(
          fontFamily: AppFonts.inter,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: _gray900,
        ),
        labelMedium: TextStyle(
          fontFamily: AppFonts.inter,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: _gray700,
        ),
        labelSmall: TextStyle(
          fontFamily: AppFonts.inter,
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: _gray700,
        ),
      ),

      // Scaffold background color
      scaffoldBackgroundColor: _background,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: _secondaryBlue,
        secondary: _secondaryBlue,
        surface: _gray900,
        error: _errorRed,
        onPrimary: _white,
        onSecondary: _white,
        onSurface: _white,
        onError: _white,
      ),
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: _gray900,
        foregroundColor: _white,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: TextStyle(
          fontFamily: AppFonts.inter,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: _white,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: _gray900,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),

      // Bottom Navigation Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: _gray900,
        selectedItemColor: _secondaryBlue,
        unselectedItemColor: _gray500,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontFamily: AppFonts.inter,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: AppFonts.inter,
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: _gray900,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
      ),

      // Scaffold background color
      scaffoldBackgroundColor: _black,
    );
  }
}

// Custom text styles for hymn content
class HymnTextStyles {
  static const TextStyle hymnTitle = TextStyle(
    fontFamily: AppFonts.crimsonText,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: Color(AppColors.primaryBlue),
  );

  static const TextStyle hymnVerse = TextStyle(
    fontFamily: AppFonts.crimsonText,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: Color(AppColors.gray900),
    height: 1.6,
  );

  static const TextStyle hymnVerseNumber = TextStyle(
    fontFamily: AppFonts.inter,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Color(AppColors.primaryBlue),
  );

  static const TextStyle hymnMetadata = TextStyle(
    fontFamily: AppFonts.inter,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Color(AppColors.gray500),
  );
}

// Custom colors for specific use cases
class AppThemeColors {
  static const Color favoriteRed = Color(0xFFEF4444);
  static const Color downloadGreen = Color(AppColors.successGreen);
  static const Color progressBlue = Color(AppColors.secondaryBlue);
  static const Color warningOrange = Color(AppColors.warningOrange);
  static const Color offlineGray = Color(AppColors.gray500);
  
  // Collection colors
  static const Color sdahBlue = Color(AppColors.primaryBlue);
  static const Color chRed = Color(0xFF800020);
  static const Color csGreen = Color(AppColors.successGreen);
  static const Color mhGold = Color(0xFFD4AF37);
  static const Color nzkBrown = Color(0xFF7C2D12);
  static const Color wnTeal = Color(0xFF0F766E);
}

// Extension for context-aware theme access
extension ThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  bool get isLight => Theme.of(this).brightness == Brightness.light;
}