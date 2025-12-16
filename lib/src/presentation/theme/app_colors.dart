import 'package:flutter/material.dart';

/// Premium color system for professional crypto trading application
/// Supports both dark and light themes with detailed palettes
class AppColors {
  // ============ DARK THEME COLORS ============

  // Dark Theme - Premium ultra-dark backgrounds
  static const Color darkBackground = Color(0xFF0A0A0A); // Original Black
  static const Color darkSurface = Color(0xFF141414); // Original Dark Grey
  static const Color darkCard = Color(0xFF1C1C1C); // Original Card Grey
  static const Color darkBorder = Color(0xFF2A2A2A); // Original Border
  static const Color darkDivider = Color(0xFF1A1A1A); // Original Divider

  // Dark Theme - Text colors
  static const Color darkTextPrimary = Color(0xFFF0F4FF); // Bright white-blue
  static const Color darkTextSecondary = Color(0xFFB4BFDA); // Muted blue-gray
  static const Color darkTextTertiary = Color(0xFF7E8AA8); // Subtle gray
  static const Color darkTextDisabled = Color(0xFF4A5370); // Disabled state

  // Dark Theme - Accent colors
  static const Color darkAccentPrimary = Color(0xFF5B8FF9); // Original Premium Blue
  static const Color darkAccentSecondary = Color(0xFF8B5CF6); // Premium purple
  static const Color darkAccentTertiary = Color(0xFF10B981); // Premium green

  // Dark Theme - Primary button color
  static const Color darkTerracotta = Color(0xFFF42A0B); // Original Red-Orange
  static const Color onDarkTerracotta = Color(0xFFFFFFFF); // White text

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

  // Light Theme - Primary button color
  static const Color lightTerracotta = Color(0xFFF42A0B); // Red-Orange
  static const Color onLightTerracotta = Color(0xFFFFFFFF); // White text

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
  static const Color darkAlert = Color(0xFFEA580C); // Warm orange
  static const Color darkWarning = Color(0xFFF97316); // Deep orange

  // Trading colors - Light theme
  static const Color lightBullish = Color(0xFF059669); // Rich green
  static const Color lightBearish = Color(0xFFDC2626); // Rich red
  static const Color lightNeutral = Color(0xFF3B82F6); // Rich blue
  static const Color lightOpportunity = Color(0xFFEAB308); // Golden
  static const Color lightAlert = Color(0xFFEA580C); // Orange
  static const Color lightWarning = Color(0xFFDC2626); // Red-orange

  // ============ GRADIENT COLORS ============

  // Dark theme gradients (Originals restyled if needed, keeping simple for now to match 'original' request but supporting new UI)
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

}
