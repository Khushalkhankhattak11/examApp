// lib/core/theme/app_theme.dart
//
// Drop this file into lib/core/theme/ (or lib/const/ — wherever you keep
// AppColors).  Then import it in main.dart:
//   import 'core/theme/app_theme.dart';

import 'package:examace/const/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract class AppTheme {
  AppTheme._();

  // ──────────────────────────────────────────────────────────────
  //  DARK
  // ──────────────────────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // ── Color scheme ──────────────────────────────────────────
    colorScheme: const ColorScheme.dark(
      brightness: Brightness.dark,

      primary: AppColors.primaryDark,
      onPrimary: AppColors.onPrimaryDark,
      primaryContainer: AppColors.primaryContainerDark,
      onPrimaryContainer: AppColors.onPrimaryContainerDark,

      secondary: AppColors.secondaryDark,
      onSecondary: AppColors.onSecondaryDark,
      secondaryContainer: AppColors.secondaryContainerDark,
      onSecondaryContainer: AppColors.onSecondaryContainerDark,

      tertiary: AppColors.tertiaryDark,
      onTertiary: AppColors.onTertiaryDark,
      tertiaryContainer: AppColors.tertiaryContainerDark,
      onTertiaryContainer: AppColors.onTertiaryContainerDark,

      surface: AppColors.surfaceDark,
      onSurface: AppColors.onSurfaceDark,
      onSurfaceVariant: AppColors.onSurfaceVariantDark,

      error: AppColors.error,
      onError: AppColors.onError,

      outline: AppColors.outlineDark,
      outlineVariant: AppColors.outlineVariantDark,
    ),

    // ── Scaffold / canvas ─────────────────────────────────────
    scaffoldBackgroundColor: AppColors.surfaceDark,

    // ── AppBar ────────────────────────────────────────────────
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surfaceHighDark,
      foregroundColor: AppColors.onSurfaceDark,
      elevation: 0,
      scrolledUnderElevation: 1,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.onSurfaceDark,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.surfaceDark,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    ),

    // ── Card ──────────────────────────────────────────────────
    cardTheme: CardThemeData(
      color: AppColors.surfaceHighDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.outlineDark),
      ),
    ),

    // ── ElevatedButton ────────────────────────────────────────
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.onPrimaryDark,
        disabledBackgroundColor: AppColors.outlineDark,
        disabledForegroundColor: AppColors.onSurfaceVariantDark,
        elevation: 0,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    ),

    // ── OutlinedButton ────────────────────────────────────────
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryDark,
        side: const BorderSide(color: AppColors.primaryDark),
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),

    // ── TextButton ────────────────────────────────────────────
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryDark,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    ),

    // ── TextField / InputDecoration ───────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceHighDark,
      hintStyle: const TextStyle(color: AppColors.hintDark, fontSize: 14),
      prefixIconColor: AppColors.hintDark,
      suffixIconColor: AppColors.hintDark,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.outlineDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.outlineDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryDark, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
    ),

    // ── BottomNavigationBar ───────────────────────────────────
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceHighDark,
      selectedItemColor: AppColors.primaryDark,
      unselectedItemColor: AppColors.onSurfaceVariantDark,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),

    // ── NavigationBar (Material 3) ────────────────────────────
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surfaceHighDark,
      indicatorColor: AppColors.primaryContainerDark,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.primaryDark);
        }
        return const IconThemeData(color: AppColors.onSurfaceVariantDark);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            color: AppColors.primaryDark,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          );
        }
        return const TextStyle(
          color: AppColors.onSurfaceVariantDark,
          fontSize: 12,
        );
      }),
    ),

    // ── Divider ───────────────────────────────────────────────
    dividerTheme: const DividerThemeData(
      color: AppColors.outlineDark,
      thickness: 1,
      space: 1,
    ),

    // ── Switch ────────────────────────────────────────────────
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.onPrimaryDark
            : AppColors.onSurfaceVariantDark,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.primaryDark
            : AppColors.surfaceHighestDark,
      ),
    ),

    // ── Chip ──────────────────────────────────────────────────
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surfaceHighDark,
      selectedColor: AppColors.primaryContainerDark,
      labelStyle: const TextStyle(color: AppColors.onSurfaceDark, fontSize: 13),
      side: const BorderSide(color: AppColors.outlineDark),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),

    // ── Floating Action Button ────────────────────────────────
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryDark,
      foregroundColor: AppColors.onPrimaryDark,
      elevation: 2,
      shape: CircleBorder(),
    ),

    // ── Dialog ───────────────────────────────────────────────
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surfaceHighDark,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: const TextStyle(
        color: AppColors.onSurfaceDark,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      contentTextStyle: const TextStyle(
        color: AppColors.onSurfaceVariantDark,
        fontSize: 14,
        height: 1.5,
      ),
    ),

    // ── SnackBar ─────────────────────────────────────────────
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surfaceHighestDark,
      contentTextStyle: const TextStyle(color: AppColors.onSurfaceDark),
      actionTextColor: AppColors.primaryDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),

    // ── IconButton ────────────────────────────────────────────
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: AppColors.onSurfaceDark),
    ),

    // ── ListTile ─────────────────────────────────────────────
    listTileTheme: const ListTileThemeData(
      tileColor: Colors.transparent,
      iconColor: AppColors.onSurfaceVariantDark,
      textColor: AppColors.onSurfaceDark,
      subtitleTextStyle: TextStyle(color: AppColors.onSurfaceVariantDark),
    ),

    // ── Text theme ────────────────────────────────────────────
    textTheme: _buildTextTheme(
      AppColors.onSurfaceDark,
      AppColors.onSurfaceVariantDark,
    ),
  );

  // ──────────────────────────────────────────────────────────────
  //  LIGHT
  // ──────────────────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // ── Color scheme ──────────────────────────────────────────
    colorScheme: const ColorScheme.light(
      brightness: Brightness.light,

      primary: AppColors.primaryLight,
      onPrimary: AppColors.onPrimaryLight,
      primaryContainer: AppColors.primaryContainerLight,
      onPrimaryContainer: AppColors.onPrimaryContainerLight,

      secondary: AppColors.secondaryLight,
      onSecondary: AppColors.onSecondaryLight,
      secondaryContainer: AppColors.secondaryContainerLight,
      onSecondaryContainer: AppColors.onSecondaryContainerLight,

      tertiary: AppColors.tertiaryLight,
      onTertiary: AppColors.onTertiaryLight,
      tertiaryContainer: AppColors.tertiaryContainerLight,
      onTertiaryContainer: AppColors.onTertiaryContainerLight,

      surface: AppColors.surfaceLight,
      onSurface: AppColors.onSurfaceLight,
      onSurfaceVariant: AppColors.onSurfaceVariantLight,

      error: AppColors.error,
      onError: AppColors.onError,

      outline: AppColors.outlineLight,
      outlineVariant: AppColors.outlineVariantLight,
    ),

    // ── Scaffold / canvas ─────────────────────────────────────
    scaffoldBackgroundColor: AppColors.neutralLight,

    // ── AppBar ────────────────────────────────────────────────
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surfaceLight,
      foregroundColor: AppColors.onSurfaceLight,
      elevation: 0,
      scrolledUnderElevation: 1,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.onSurfaceLight,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.surfaceLight,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    ),

    // ── Card ──────────────────────────────────────────────────
    cardTheme: CardThemeData(
      color: AppColors.surfaceLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.outlineLight),
      ),
    ),

    // ── ElevatedButton ────────────────────────────────────────
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.onPrimaryLight,
        disabledBackgroundColor: AppColors.outlineLight,
        disabledForegroundColor: AppColors.onSurfaceVariantLight,
        elevation: 0,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    ),

    // ── OutlinedButton ────────────────────────────────────────
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryLight,
        side: const BorderSide(color: AppColors.primaryLight),
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),

    // ── TextButton ────────────────────────────────────────────
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryLight,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    ),

    // ── TextField / InputDecoration ───────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceLight,
      hintStyle: const TextStyle(color: AppColors.hintLight, fontSize: 14),
      prefixIconColor: AppColors.hintLight,
      suffixIconColor: AppColors.hintLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.outlineLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.outlineLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
    ),

    // ── BottomNavigationBar ───────────────────────────────────
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceLight,
      selectedItemColor: AppColors.primaryLight,
      unselectedItemColor: AppColors.onSurfaceVariantLight,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),

    // ── NavigationBar (Material 3) ────────────────────────────
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surfaceLight,
      indicatorColor: AppColors.primaryContainerLight,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.primaryLight);
        }
        return const IconThemeData(color: AppColors.onSurfaceVariantLight);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            color: AppColors.primaryLight,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          );
        }
        return const TextStyle(
          color: AppColors.onSurfaceVariantLight,
          fontSize: 12,
        );
      }),
    ),

    // ── Divider ───────────────────────────────────────────────
    dividerTheme: const DividerThemeData(
      color: AppColors.outlineLight,
      thickness: 1,
      space: 1,
    ),

    // ── Switch ────────────────────────────────────────────────
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.onPrimaryLight
            : AppColors.onSurfaceVariantLight,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.primaryLight
            : AppColors.surfaceHighestLight,
      ),
    ),

    // ── Chip ──────────────────────────────────────────────────
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surfaceHighLight,
      selectedColor: AppColors.primaryContainerLight,
      labelStyle: const TextStyle(
        color: AppColors.onSurfaceLight,
        fontSize: 13,
      ),
      side: const BorderSide(color: AppColors.outlineLight),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),

    // ── Floating Action Button ────────────────────────────────
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryLight,
      foregroundColor: AppColors.onPrimaryLight,
      elevation: 2,
      shape: CircleBorder(),
    ),

    // ── Dialog ───────────────────────────────────────────────
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surfaceLight,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: const TextStyle(
        color: AppColors.onSurfaceLight,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      contentTextStyle: const TextStyle(
        color: AppColors.onSurfaceVariantLight,
        fontSize: 14,
        height: 1.5,
      ),
    ),

    // ── SnackBar ─────────────────────────────────────────────
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.secondaryLight,
      contentTextStyle: const TextStyle(color: AppColors.onSecondaryLight),
      actionTextColor: AppColors.tertiaryLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),

    // ── IconButton ────────────────────────────────────────────
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: AppColors.onSurfaceLight),
    ),

    // ── ListTile ─────────────────────────────────────────────
    listTileTheme: const ListTileThemeData(
      tileColor: Colors.transparent,
      iconColor: AppColors.onSurfaceVariantLight,
      textColor: AppColors.onSurfaceLight,
      subtitleTextStyle: TextStyle(color: AppColors.onSurfaceVariantLight),
    ),

    // ── Text theme ────────────────────────────────────────────
    textTheme: _buildTextTheme(
      AppColors.onSurfaceLight,
      AppColors.onSurfaceVariantLight,
    ),
  );

  // ──────────────────────────────────────────────────────────────
  //  SHARED TEXT THEME
  // ──────────────────────────────────────────────────────────────
  static TextTheme _buildTextTheme(Color primary, Color secondary) => TextTheme(
    displayLarge: _ts(57, FontWeight.w700, primary, -0.25),
    displayMedium: _ts(45, FontWeight.w700, primary, 0),
    displaySmall: _ts(36, FontWeight.w700, primary, 0),

    headlineLarge: _ts(32, FontWeight.w700, primary, 0),
    headlineMedium: _ts(28, FontWeight.w700, primary, 0),
    headlineSmall: _ts(24, FontWeight.w600, primary, 0),

    titleLarge: _ts(22, FontWeight.w600, primary, 0),
    titleMedium: _ts(16, FontWeight.w600, primary, 0.15),
    titleSmall: _ts(14, FontWeight.w600, primary, 0.1),

    bodyLarge: _ts(16, FontWeight.w400, primary, 0.5),
    bodyMedium: _ts(14, FontWeight.w400, primary, 0.25),
    bodySmall: _ts(12, FontWeight.w400, secondary, 0.4),

    labelLarge: _ts(14, FontWeight.w500, primary, 0.1),
    labelMedium: _ts(12, FontWeight.w500, secondary, 0.5),
    labelSmall: _ts(11, FontWeight.w500, secondary, 0.5),
  );

  static TextStyle _ts(
    double size,
    FontWeight weight,
    Color color,
    double spacing,
  ) => TextStyle(
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: spacing,
    height: 1.4,
  );
}
