import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taskflow_flutter/core/theme/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBgPrimary,
      cardColor: AppColors.lightBgCard,
      colorScheme: const ColorScheme.light(
        primary: AppColors.lightAccentPrimary,
        secondary: AppColors.lightAccentHover,
        surface: AppColors.lightBgCard,
        error: AppColors.lightError,
        onPrimary: AppColors.lightAccentFg,
        onSecondary: AppColors.lightAccentFg,
        onSurface: AppColors.lightTextPrimary,
        onError: Colors.white,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          color: AppColors.lightTextPrimary,
          fontSize: AppTypography.size3xl,
          fontWeight: AppTypography.bold,
          letterSpacing: -0.5,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          color: AppColors.lightTextPrimary,
          fontSize: AppTypography.size2xl,
          fontWeight: AppTypography.bold,
          letterSpacing: -0.5,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          color: AppColors.lightTextPrimary,
          fontSize: AppTypography.xl,
          fontWeight: AppTypography.bold,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          color: AppColors.lightTextPrimary,
          fontSize: AppTypography.lg,
          fontWeight: AppTypography.semibold,
        ),
        titleSmall: baseTextTheme.titleSmall?.copyWith(
          color: AppColors.lightTextPrimary,
          fontSize: AppTypography.md,
          fontWeight: AppTypography.semibold,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: AppColors.lightTextPrimary,
          fontSize: AppTypography.base,
          fontWeight: AppTypography.regular,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: AppColors.lightTextSecondary,
          fontSize: AppTypography.sm,
          fontWeight: AppTypography.regular,
        ),
        bodySmall: baseTextTheme.bodySmall?.copyWith(
          color: AppColors.lightTextDisabled,
          fontSize: AppTypography.xs,
          fontWeight: AppTypography.regular,
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          color: AppColors.lightTextLabel,
          fontSize: AppTypography.sm,
          fontWeight: AppTypography.medium,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBgPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.lightTextPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: AppTypography.lg,
          fontWeight: AppTypography.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightBgCard,
        elevation: 1,
        shadowColor: const Color(0x0A000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.card),
          side: const BorderSide(color: AppColors.lightBorderSubtle, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightBgInput,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: const TextStyle(
          color: AppColors.lightTextPlaceholder,
          fontSize: AppTypography.base,
        ),
        labelStyle: const TextStyle(
          color: AppColors.lightTextLabel,
          fontSize: AppTypography.sm,
          fontWeight: AppTypography.medium,
        ),
        errorMaxLines: 3,
        errorStyle: const TextStyle(
          color: AppColors.lightError,
          fontSize: AppTypography.xs,
          fontWeight: AppTypography.medium,
          height: 1.25,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          borderSide: const BorderSide(color: AppColors.lightBorderInput, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          borderSide: const BorderSide(color: AppColors.lightBorderInput, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          borderSide: const BorderSide(color: AppColors.lightBorderFocus, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          borderSide: const BorderSide(color: AppColors.lightError, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          borderSide: const BorderSide(color: AppColors.lightError, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightAccentPrimary,
          foregroundColor: AppColors.lightAccentFg,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          ),
          textStyle: const TextStyle(
            fontSize: AppTypography.base,
            fontWeight: AppTypography.semibold,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.lightTextPrimary,
          side: const BorderSide(color: AppColors.lightBorderSubtle, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          ),
          textStyle: const TextStyle(
            fontSize: AppTypography.base,
            fontWeight: AppTypography.semibold,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightBorderSubtle,
        thickness: 1,
        space: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightBgCard,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.card),
          side: const BorderSide(color: AppColors.lightBorderSubtle, width: 1),
        ),
        titleTextStyle: const TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: AppTypography.lg,
          fontWeight: AppTypography.bold,
        ),
        contentTextStyle: const TextStyle(
          color: AppColors.lightTextSecondary,
          fontSize: AppTypography.sm,
          height: 1.4,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.lightTextPrimary,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightTabBarBg,
        selectedItemColor: AppColors.lightTabBarActive,
        unselectedItemColor: AppColors.lightTabBarInactive,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: AppTypography.semibold),
        unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: AppTypography.regular),
      ),
    );
  }

  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBgPrimary,
      cardColor: AppColors.darkBgCard,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkAccentPrimary,
        secondary: AppColors.darkAccentHover,
        surface: AppColors.darkBgCard,
        error: AppColors.darkError,
        onPrimary: AppColors.darkAccentFg,
        onSecondary: AppColors.darkAccentFg,
        onSurface: AppColors.darkTextPrimary,
        onError: Colors.white,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          color: AppColors.darkTextPrimary,
          fontSize: AppTypography.size3xl,
          fontWeight: AppTypography.bold,
          letterSpacing: -0.5,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          color: AppColors.darkTextPrimary,
          fontSize: AppTypography.size2xl,
          fontWeight: AppTypography.bold,
          letterSpacing: -0.5,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          color: AppColors.darkTextPrimary,
          fontSize: AppTypography.xl,
          fontWeight: AppTypography.bold,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          color: AppColors.darkTextPrimary,
          fontSize: AppTypography.lg,
          fontWeight: AppTypography.semibold,
        ),
        titleSmall: baseTextTheme.titleSmall?.copyWith(
          color: AppColors.darkTextPrimary,
          fontSize: AppTypography.md,
          fontWeight: AppTypography.semibold,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: AppColors.darkTextPrimary,
          fontSize: AppTypography.base,
          fontWeight: AppTypography.regular,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: AppColors.darkTextSecondary,
          fontSize: AppTypography.sm,
          fontWeight: AppTypography.regular,
        ),
        bodySmall: baseTextTheme.bodySmall?.copyWith(
          color: AppColors.darkTextDisabled,
          fontSize: AppTypography.xs,
          fontWeight: AppTypography.regular,
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          color: AppColors.darkTextLabel,
          fontSize: AppTypography.sm,
          fontWeight: AppTypography.medium,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBgPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: AppTypography.lg,
          fontWeight: AppTypography.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkBgCard,
        elevation: 1,
        shadowColor: const Color(0x1FFFFFFF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.card),
          side: const BorderSide(color: AppColors.darkBorderSubtle, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkBgInput,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: const TextStyle(
          color: AppColors.darkTextPlaceholder,
          fontSize: AppTypography.base,
        ),
        labelStyle: const TextStyle(
          color: AppColors.darkTextLabel,
          fontSize: AppTypography.sm,
          fontWeight: AppTypography.medium,
        ),
        errorMaxLines: 3,
        errorStyle: const TextStyle(
          color: AppColors.darkError,
          fontSize: AppTypography.xs,
          fontWeight: AppTypography.medium,
          height: 1.25,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          borderSide: const BorderSide(color: AppColors.darkBorderInput, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          borderSide: const BorderSide(color: AppColors.darkBorderInput, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          borderSide: const BorderSide(color: AppColors.darkBorderFocus, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          borderSide: const BorderSide(color: AppColors.darkError, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          borderSide: const BorderSide(color: AppColors.darkError, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkAccentPrimary,
          foregroundColor: AppColors.darkAccentFg,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          ),
          textStyle: const TextStyle(
            fontSize: AppTypography.base,
            fontWeight: AppTypography.semibold,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkTextPrimary,
          side: const BorderSide(color: AppColors.darkBorderSubtle, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          ),
          textStyle: const TextStyle(
            fontSize: AppTypography.base,
            fontWeight: AppTypography.semibold,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorderSubtle,
        thickness: 1,
        space: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkBgCard,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.card),
          side: const BorderSide(color: AppColors.darkBorderSubtle, width: 1),
        ),
        titleTextStyle: const TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: AppTypography.lg,
          fontWeight: AppTypography.bold,
        ),
        contentTextStyle: const TextStyle(
          color: AppColors.darkTextSecondary,
          fontSize: AppTypography.sm,
          height: 1.4,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.darkTextPrimary,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkTabBarBg,
        selectedItemColor: AppColors.darkTabBarActive,
        unselectedItemColor: AppColors.darkTabBarInactive,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: AppTypography.semibold),
        unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: AppTypography.regular),
      ),
    );
  }
}

