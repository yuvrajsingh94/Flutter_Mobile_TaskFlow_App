import 'package:flutter/material.dart';

/// Design tokens inspired by modern enterprise workspace apps (Acme / Linear / Vercel)
/// Exactly matching `src/constants/theme.ts`.
class AppColors {
  // ─── Light Mode ────────────────────────────────────────────────────────────
  static const Color lightBgPrimary = Color(0xFFF7F6F2);       // warm stone
  static const Color lightBgCard = Color(0xFFFFFFFF);          // crisp white
  static const Color lightBgInput = Color(0xFFFFFFFF);
  static const Color lightBgSidebar = Color(0xFFEFEFED);
  static const Color lightBorderSubtle = Color(0xFFEAE8E3);    // soft warm border
  static const Color lightBorderInput = Color(0xFFE3E1DA);
  static const Color lightBorderFocus = Color(0xFF18181B);     // deep charcoal
  static const Color lightTextPrimary = Color(0xFF18181B);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightTextLabel = Color(0xFF374151);
  static const Color lightTextDisabled = Color(0xFF9CA3AF);
  static const Color lightTextPlaceholder = Color(0xFF9CA3AF);
  static const Color lightAccentPrimary = Color(0xFF18181B);
  static const Color lightAccentHover = Color(0xFF27272A);
  static const Color lightAccentFg = Color(0xFFFFFFFF);
  static const Color lightBrandGreen = Color(0xFF10B981);
  static const Color lightSuccess = Color(0xFF15803D);
  static const Color lightSuccessBg = Color(0xFFDCFCE7);
  static const Color lightWarning = Color(0xFFB45309);
  static const Color lightWarningBg = Color(0xFFFEF3C7);
  static const Color lightError = Color(0xFFDC2626);
  static const Color lightErrorBg = Color(0xFFFEE2E2);
  static const Color lightInfo = Color(0xFF1D4ED8);
  static const Color lightInfoBg = Color(0xFFEFF6FF);
  static const Color lightOverlayLight = Color(0x06000000);   // rgba(0, 0, 0, 0.025)
  static const Color lightOverlayMedium = Color(0x0D000000);  // rgba(0, 0, 0, 0.05)
  static const Color lightOverlayStrong = Color(0x17000000);  // rgba(0, 0, 0, 0.09)
  static const Color lightTabBarBg = Color(0xFFFFFFFF);
  static const Color lightTabBarBorder = Color(0xFFEAE8E3);
  static const Color lightTabBarActive = Color(0xFF18181B);
  static const Color lightTabBarInactive = Color(0xFF9CA3AF);

  // ─── Dark Mode ─────────────────────────────────────────────────────────────
  static const Color darkBgPrimary = Color(0xFF121214);
  static const Color darkBgCard = Color(0xFF1C1C1F);
  static const Color darkBgInput = Color(0xFF232326);
  static const Color darkBgSidebar = Color(0xFF18181B);
  static const Color darkBorderSubtle = Color(0xFF2E2E32);
  static const Color darkBorderInput = Color(0xFF38383E);
  static const Color darkBorderFocus = Color(0xFFF5F5F5);
  static const Color darkTextPrimary = Color(0xFFF5F5F5);
  static const Color darkTextSecondary = Color(0xFF94949E);
  static const Color darkTextLabel = Color(0xFFC4C4C8);
  static const Color darkTextDisabled = Color(0xFF62626A);
  static const Color darkTextPlaceholder = Color(0xFF585860);
  static const Color darkAccentPrimary = Color(0xFFF5F5F5);
  static const Color darkAccentHover = Color(0xFFE4E4E7);
  static const Color darkAccentFg = Color(0xFF18181B);
  static const Color darkBrandGreen = Color(0xFF10B981);
  static const Color darkSuccess = Color(0xFF22C55E);
  static const Color darkSuccessBg = Color(0x2622C55E);        // rgba(34, 197, 94, 0.15)
  static const Color darkWarning = Color(0xFFF59E0B);
  static const Color darkWarningBg = Color(0x26F59E0B);        // rgba(245, 158, 11, 0.15)
  static const Color darkError = Color(0xFFEF4444);
  static const Color darkErrorBg = Color(0x26EF4444);          // rgba(239, 68, 68, 0.15)
  static const Color darkInfo = Color(0xFF3B82F6);
  static const Color darkInfoBg = Color(0x263B82F6);           // rgba(59, 130, 246, 0.15)
  static const Color darkOverlayLight = Color(0x08FFFFFF);    // rgba(255, 255, 255, 0.03)
  static const Color darkOverlayMedium = Color(0x0FFFFFFF);   // rgba(255, 255, 255, 0.06)
  static const Color darkOverlayStrong = Color(0x1AFFFFFF);   // rgba(255, 255, 255, 0.10)
  static const Color darkTabBarBg = Color(0xFF18181B);
  static const Color darkTabBarBorder = Color(0xFF2E2E32);
  static const Color darkTabBarActive = Color(0xFFF5F5F5);
  static const Color darkTabBarInactive = Color(0xFF71717A);

  // ─── Priority Strips (Universal) ───────────────────────────────────────────
  static const Color priorityUrgent = Color(0xFFEF4444);
  static const Color priorityHigh = Color(0xFFF59E0B);
  static const Color priorityMedium = Color(0xFF3B82F6);
  static const Color priorityLow = Color(0xFF9CA3AF);

  // ─── Direct Aliases (Default Light for convenient usage) ───────────────────
  static const Color canvas = lightBgPrimary;
  static const Color surfaceElevated = lightBgCard;
  static const Color surfaceStone = lightBgPrimary;
  static const Color surfaceSubtle = lightOverlayMedium;
  static const Color textPrimary = lightTextPrimary;
  static const Color textSecondary = lightTextSecondary;
  static const Color textTertiary = lightTextDisabled;
  static const Color textPlaceholder = lightTextPlaceholder;
  static const Color primary = lightAccentPrimary;
  static const Color secondary = lightAccentHover;
  static const Color success = lightSuccess;
  static const Color successBg = lightSuccessBg;
  static const Color successBorder = Color(0x3315803D);
  static const Color warning = lightWarning;
  static const Color warningBg = lightWarningBg;
  static const Color warningBorder = Color(0x33B45309);
  static const Color error = lightError;
  static const Color errorBg = lightErrorBg;
  static const Color errorBorder = Color(0x33DC2626);
  static const Color info = lightInfo;
  static const Color infoBg = lightInfoBg;
  static const Color infoBorder = Color(0x331D4ED8);
  static const Color borderSubtle = lightBorderSubtle;
  static const Color borderHairline = lightBorderInput;
  static const Color borderInput = lightBorderInput;
  static const Color borderFocus = lightBorderFocus;
  static const Color card = lightBgCard;
  static const Color background = lightBgPrimary;
  static const Color surface = lightBgCard;
  static const Color bgInput = lightBgInput;
  static const Color accentPrimary = lightAccentPrimary;
  static const Color accentFg = lightAccentFg;
  static const Color overlayLight = lightOverlayLight;
  static const Color overlayMedium = lightOverlayMedium;
  static const Color overlayStrong = lightOverlayStrong;
  static const Color darkBackground = darkBgPrimary;
  static const Color darkCard = darkBgCard;
  static const Color darkBgElevated = darkBgCard;
  static const Color darkBorder = darkBorderInput;
  static const Color primaryHover = lightAccentHover;
  static const Color surfaceMuted = lightBgSidebar;
}

/// Exact typography sizes matching React Native typography token
class AppTypography {
  static const double tiny = 10.0;
  static const double xs = 11.0;
  static const double sm = 13.0;
  static const double base = 14.0;
  static const double md = 15.0;
  static const double lg = 17.0;
  static const double xl = 19.0;
  static const double xxl = 23.0;
  static const double size2xl = 24.0;
  static const double size3xl = 30.0;
  static const double title = 26.0;

  static const double fontSizeTiny = tiny;
  static const double fontSizeXs = xs;
  static const double fontSizeSm = sm;
  static const double fontSizeBase = base;
  static const double fontSizeMd = md;
  static const double fontSizeLg = lg;
  static const double fontSizeXl = xl;
  static const double fontSize2xl = size2xl;
  static const double fontSize3xl = size3xl;
  static const double fontSizeTitle = title;

  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semibold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  static const FontWeight fontWeightRegular = regular;
  static const FontWeight fontWeightMedium = medium;
  static const FontWeight fontWeightSemibold = semibold;
  static const FontWeight fontWeightBold = bold;
}

/// Spacing scale matching React Native spacing token
class AppSpacing {
  static const double tiny = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double huge = 32.0;
  static const double gutter = 16.0;
  static const double cardGap = 10.0;
  static const double cardPadding = 14.0;
}

/// Border radius scale matching React Native borderRadius token
class AppBorderRadius {
  static const double xs = 4.0;
  static const double sm = 6.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 14.0;
  static const double card = 16.0;
  static const double pill = 9999.0;
  static const double round = 9999.0;
  static const double full = 9999.0;
}
