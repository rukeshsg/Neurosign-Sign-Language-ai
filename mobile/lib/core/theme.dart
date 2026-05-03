import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NeuroColors {
  static const seed = Color(0xFF44976E);
  static const mintMist = Color(0xFFD1EADE);
  static const mintSoft = Color(0xFFDCEFE6);
  static const sage = Color(0xFF44976E);
  static const sageDeep = Color(0xFF1F6D49);
  static const charcoal = Color(0xFF1E1E1E);
  static const ink = Color(0xFF17212A);
  static const graphite = Color(0xFF6D7780);
  static const cloud = Color(0xFFF7FBF8);
  static const porcelain = Color(0xFFFFFFFF);
  static const darkBase = Color(0xFF0F1714);
  static const darkPanel = Color(0xFF182B24);
  static const darkPanelSoft = Color(0xFF1F3D33);
  static const blush = Color(0xFFF6E7F4);
  static const butter = Color(0xFFFFF2D6);
  static const sky = Color(0xFFE9EEF5);
  static const success = Color(0xFF34A66A);
  static const warning = Color(0xFFD99A2B);
  static const danger = Color(0xFFE05656);
}

class NeuroSpacing {
  static const xs = 6.0;
  static const sm = 10.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

class AppTheme {
  static ThemeData get lightTheme => _theme(Brightness.light);

  static ThemeData get darkTheme => _theme(Brightness.dark);

  static ThemeData _theme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: NeuroColors.seed,
      brightness: brightness,
      primary: NeuroColors.sage,
      secondary: NeuroColors.sageDeep,
      surface: isDark ? NeuroColors.darkPanel : NeuroColors.porcelain,
      error: NeuroColors.danger,
    );

    final baseText = GoogleFonts.interTextTheme(
      isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          isDark ? NeuroColors.darkBase : NeuroColors.cloud,
      primaryColor: NeuroColors.sage,
      textTheme: baseText.copyWith(
        displayLarge: baseText.displayLarge?.copyWith(
          fontSize: 36,
          fontWeight: FontWeight.w800,
          color: isDark ? Colors.white : NeuroColors.ink,
        ),
        headlineLarge: baseText.headlineLarge?.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: isDark ? Colors.white : NeuroColors.ink,
        ),
        headlineMedium: baseText.headlineMedium?.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : NeuroColors.ink,
        ),
        titleLarge: baseText.titleLarge?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : NeuroColors.ink,
        ),
        titleMedium: baseText.titleMedium?.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : NeuroColors.ink,
        ),
        bodyLarge: baseText.bodyLarge?.copyWith(
          fontSize: 16,
          height: 1.35,
          color: isDark ? const Color(0xFFE9F2EE) : NeuroColors.ink,
        ),
        bodyMedium: baseText.bodyMedium?.copyWith(
          fontSize: 14,
          height: 1.35,
          color: isDark ? const Color(0xFFC9D8D0) : NeuroColors.graphite,
        ),
        labelLarge: baseText.labelLarge?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : NeuroColors.ink,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? NeuroColors.darkPanel : NeuroColors.porcelain,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : NeuroColors.ink,
        titleTextStyle: baseText.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: isDark ? Colors.white : NeuroColors.ink,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 72,
        backgroundColor:
            isDark ? const Color(0xF0182420) : const Color(0xF8FFFFFF),
        indicatorColor:
            isDark ? NeuroColors.darkPanelSoft : NeuroColors.mintMist,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: NeuroColors.sage,
          foregroundColor: Colors.white,
          minimumSize: const Size(56, 52),
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: isDark ? Colors.white : NeuroColors.ink,
          minimumSize: const Size(44, 44),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF13201B) : Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
              color:
                  isDark ? const Color(0xFF2D4339) : const Color(0xFFE2ECE7)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
              color:
                  isDark ? const Color(0xFF2D4339) : const Color(0xFFE2ECE7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: NeuroColors.sage, width: 1.5),
        ),
      ),
    );
  }
}
