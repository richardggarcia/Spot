import 'package:flutter/material.dart';

/// Premium color system for professional crypto trading application
/// Supports both dark and light themes with sophisticated palettes
class AppColors {
  // ============ DARK THEME COLORS ============

  // Dark Theme - Premium ultra-dark backgrounds
  static const Color darkBackground = Color(0xFF0A0A0A); // Almost pure black
  static const Color darkSurface = Color(0xFF141414); // Subtle elevation
  static const Color darkCard = Color(0xFF1C1C1C); // Card background
  static const Color darkBorder = Color(0xFF2A2A2A); // Subtle borders
  static const Color darkDivider = Color(0xFF1A1A1A); // Dividers

  // Dark Theme - Text colors
  static const Color darkTextPrimary = Color(0xFFF0F4FF); // Bright white-blue
  static const Color darkTextSecondary = Color(0xFFB4BFDA); // Muted blue-gray
  static const Color darkTextTertiary = Color(0xFF7E8AA8); // Subtle gray
  static const Color darkTextDisabled = Color(0xFF4A5370); // Disabled state

  // Dark Theme - Accent colors
  static const Color darkAccentPrimary = Color(0xFF5B8FF9); // Premium blue
  static const Color darkAccentSecondary = Color(0xFF8B5CF6); // Premium purple
  static const Color darkAccentTertiary = Color(0xFF10B981); // Premium green

  // Dark Theme - State colors
  static const Color darkHover = Color(0xFF252525);
  static const Color darkSelected = Color(0xFF2E2E2E);
  static const Color darkDisabled = Color(0xFF1A1A1A);

  // ============ LIGHT THEME COLORS ============

  // Light Theme - Clean backgrounds
  static const Color lightBackground = Color(0xFFF8FAFC); // Soft blue-white
  static const Color lightSurface = Color(0xFFFFFFFF); // Pure white
  static const Color lightCard = Color(0xFFFFFFFF); // Card white
  static const Color lightBorder = Color(0xFFE2E8F0); // Light gray border
  static const Color lightDivider = Color(0xFFEFF4F9); // Subtle divider

  // Light Theme - Text colors
  static const Color lightTextPrimary = Color(0xFF0F172A); // Dark slate
  static const Color lightTextSecondary = Color(0xFF475569); // Medium slate
  static const Color lightTextTertiary = Color(0xFF94A3B8); // Light slate
  static const Color lightTextDisabled = Color(0xFFCBD5E1); // Disabled gray

  // Light Theme - Accent colors
  static const Color lightAccentPrimary = Color(0xFF3B82F6); // Bright blue
  static const Color lightAccentSecondary = Color(0xFF7C3AED); // Bright purple
  static const Color lightAccentTertiary = Color(0xFF059669); // Bright green

  // Light Theme - State colors
  static const Color lightHover = Color(0xFFF1F5F9);
  static const Color lightSelected = Color(0xFFE0E7FF);
  static const Color lightDisabled = Color(0xFFF8FAFC);

  // ============ SEMANTIC COLORS (Theme-independent) ============

  // Trading colors - Dark theme
  static const Color darkBullish = Color(0xFF10B981); // Premium green
  static const Color darkBearish = Color(0xFFEF4444); // Premium red
  static const Color darkNeutral = Color(0xFF5B8FF9); // Premium blue
  static const Color darkOpportunity = Color(0xFFFBBF24); // Golden yellow
  static const Color darkAlert = Color(0xFFEA580C); // Warm orange (matches light theme CTA)
  static const Color darkWarning = Color(0xFFF97316); // Deep orange

  // Trading colors - Light theme
  static const Color lightBullish = Color(0xFF059669); // Rich green
  static const Color lightBearish = Color(0xFFDC2626); // Rich red
  static const Color lightNeutral = Color(0xFF3B82F6); // Rich blue
  static const Color lightOpportunity = Color(0xFFEAB308); // Golden
  static const Color lightAlert = Color(0xFFEA580C); // Orange
  static const Color lightWarning = Color(0xFFDC2626); // Red-orange

  // ============ GRADIENT COLORS ============

  // Dark theme gradients
  static const List<Color> darkGradientPrimary = [
    Color(0xFF141414),
    Color(0xFF0A0A0A),
  ];

  static const List<Color> darkGradientAccent = [
    Color(0xFF5B8FF9),
    Color(0xFF8B5CF6),
  ];

  static const List<Color> darkGradientCard = [
    Color(0xFF1C1C1C),
    Color(0xFF141414),
  ];

  // Light theme gradients
  static const List<Color> lightGradientPrimary = [
    Color(0xFFFFFFFF),
    Color(0xFFF8FAFC),
  ];

  static const List<Color> lightGradientAccent = [
    Color(0xFF3B82F6),
    Color(0xFF7C3AED),
  ];

  static const List<Color> lightGradientCard = [
    Color(0xFFFFFFFF),
    Color(0xFFF8FAFC),
  ];

  // ============ SHADOW COLORS ============

  static Color darkShadow = Colors.black.withValues(alpha: 0.4);
  static Color lightShadow = Colors.black.withValues(alpha: 0.1);

  // ============ LEGACY COMPATIBILITY (deprecated) ============

  @Deprecated('Use darkBackground instead')
  static const Color cardBackground = darkCard;

  @Deprecated('Use darkSurface instead')
  static const Color surfaceColor = darkSurface;

  @Deprecated('Use darkBorder instead')
  static const Color borderColor = darkBorder;

  @Deprecated('Use darkDivider instead')
  static const Color dividerColor = darkDivider;

  @Deprecated('Use darkTextPrimary instead')
  static const Color primaryText = darkTextPrimary;

  @Deprecated('Use darkTextSecondary instead')
  static const Color secondaryText = darkTextSecondary;

  @Deprecated('Use darkTextTertiary instead')
  static const Color tertiaryText = darkTextTertiary;

  @Deprecated('Use darkTextDisabled instead')
  static const Color disabledText = darkTextDisabled;

  @Deprecated('Use darkBullish instead')
  static const Color bullish = darkBullish;

  @Deprecated('Use darkBearish instead')
  static const Color bearish = darkBearish;

  @Deprecated('Use darkNeutral instead')
  static const Color neutral = darkNeutral;

  @Deprecated('Use darkOpportunity instead')
  static const Color opportunity = darkOpportunity;

  @Deprecated('Use darkAlert instead')
  static const Color alert = darkAlert;

  @Deprecated('Use darkWarning instead')
  static const Color warning = darkWarning;

  @Deprecated('Use darkAccentPrimary instead')
  static const Color primaryAccent = darkAccentPrimary;

  @Deprecated('Use darkAccentSecondary instead')
  static const Color secondaryAccent = darkAccentSecondary;

  @Deprecated('Use darkAccentTertiary instead')
  static const Color successColor = darkAccentTertiary;

  @Deprecated('Use darkAccentPrimary instead')
  static const Color infoColor = darkAccentPrimary;

  @Deprecated('Use darkGradientPrimary instead')
  static const Color gradientStart = Color(0xFF141414);

  @Deprecated('Use darkGradientPrimary instead')
  static const Color gradientEnd = Color(0xFF0A0A0A);

  @Deprecated('Use darkHover instead')
  static const Color hoverColor = darkHover;

  @Deprecated('Use darkSelected instead')
  static const Color selectedColor = darkSelected;

  @Deprecated('Use darkDisabled instead')
  static const Color disabledColor = darkDisabled;

  @Deprecated('Use darkBullish instead')
  static const Color bullishLight = darkBullish;

  @Deprecated('Use darkBearish instead')
  static const Color bearishLight = darkBearish;

  @Deprecated('Use darkAlert instead')
  static const Color alertLight = darkAlert;

  @Deprecated('Use darkTextPrimary instead')
  static const Color iconPrimary = darkTextPrimary;

  @Deprecated('Use darkTextSecondary instead')
  static const Color iconSecondary = darkTextSecondary;

  @Deprecated('Use darkTextTertiary instead')
  static const Color iconTertiary = darkTextTertiary;
}
