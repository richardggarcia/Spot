import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import 'helpers/theme_aware_widget.dart';

/// Premium AppBar with gradient background and theme toggle
/// Provides an elegant, professional look with smooth animations
class PremiumAppBar extends StatelessWidget implements PreferredSizeWidget {

  const PremiumAppBar({
    super.key,
    required this.title,
    this.additionalActions,
    this.bottom,
    this.centerTitle = true,
  });
  final String title;
  final List<Widget>? additionalActions;
  final PreferredSizeWidget? bottom;
  final bool centerTitle;

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );

  @override
  Widget build(BuildContext context) => ThemeAwareWidget(
      builder: (context, isDark, themeManager) => ClipRRect(
        child: BackdropFilter(
          filter:ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        AppColors.darkSurface.withValues(alpha: 0.8),
                        AppColors.darkBackground.withValues(alpha: 0.8),
                      ]
                    : [
                        AppColors.lightSurface.withValues(alpha: 0.8),
                        AppColors.lightBackground.withValues(alpha: 0.8),
                      ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.05),
                ),
              ),
            ),
      child: AppBar(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: centerTitle,
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(
          color: isDark
              ? AppColors.darkTextPrimary
              : AppColors.lightTextPrimary,
        ),
        actions: [
          // Additional actions if provided
          if (additionalActions != null) ...additionalActions!,

          // Theme toggle button
          _ThemeToggleButton(
            isDark: isDark,
            onToggle: () => themeManager.toggleTheme(),
          ),
          const SizedBox(width: 8),
        ],
        bottom: bottom,
      ),
    ),
  ),
));
}

/// Theme toggle button with animated icon transition
class _ThemeToggleButton extends StatefulWidget {

  const _ThemeToggleButton({
    required this.isDark,
    required this.onToggle,
  });
  final bool isDark;
  final VoidCallback onToggle;

  @override
  State<_ThemeToggleButton> createState() => _ThemeToggleButtonState();
}

class _ThemeToggleButtonState extends State<_ThemeToggleButton> {

  @override
  Widget build(BuildContext context) => IconButton(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) => RotationTransition(
            turns: animation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          ),
        child: Icon(
          widget.isDark ? Icons.light_mode : Icons.dark_mode,
          key: ValueKey(widget.isDark),
          color: widget.isDark
              ? AppColors.darkTextPrimary
              : AppColors.lightTextPrimary,
          size: 24,
        ),
      ),
      onPressed: widget.onToggle,
      tooltip: widget.isDark ? 'Modo claro' : 'Modo oscuro',
      splashRadius: 24,
    );
}

/// Premium TabBar with matching style
class PremiumTabBar extends StatelessWidget implements PreferredSizeWidget {

  const PremiumTabBar({
    super.key,
    required this.tabs,
    this.controller,
  });
  final List<Tab> tabs;
  final TabController? controller;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) => ThemeAwareWidget(
      builder: (context, isDark, themeManager) => Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      child: TabBar(
        controller: controller,
        tabs: tabs,
        labelColor: isDark
            ? AppColors.darkAccentPrimary
            : AppColors.lightAccentPrimary,
        unselectedLabelColor: isDark
            ? AppColors.darkTextSecondary
            : AppColors.lightTextSecondary,
        indicatorColor: isDark
            ? AppColors.darkAccentPrimary
            : AppColors.lightAccentPrimary,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
        ),
    );
}
