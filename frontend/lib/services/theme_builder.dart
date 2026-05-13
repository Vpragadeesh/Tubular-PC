import 'package:flutter/material.dart';
import '../providers.dart';

/// Theme utility class for building ThemeData from CustomTheme
class ThemeBuilder {
  static ThemeData buildTheme(CustomTheme theme) {
    final Color textColor = theme.isDark ? Colors.white : Colors.black;
    final Color surfaceColor = theme.isAmoled
        ? const Color(0xFF000000)
        : (theme.isDark ? const Color(0xFF121212) : Colors.white);
    final Color cardColor = theme.isAmoled
        ? const Color(0xFF1A1A1A)
        : (theme.isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade50);

    return ThemeData(
      brightness: theme.isDark ? Brightness.dark : Brightness.light,
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: theme.isDark ? Brightness.dark : Brightness.light,
        primary: theme.primaryColor,
        onPrimary: Colors.white,
        secondary: theme.secondaryColor,
        onSecondary: Colors.white,
        error: Colors.red,
        onError: Colors.white,
        background: surfaceColor,
        onBackground: textColor,
        surface: surfaceColor,
        onSurface: textColor,
      ),
      scaffoldBackgroundColor: surfaceColor,
      appBarTheme: AppBarTheme(
        backgroundColor: cardColor,
        foregroundColor: textColor,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        color: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade800),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade800),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.primaryColor, width: 2),
        ),
      ),
      textTheme: TextTheme(
        headlineSmall: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        bodyMedium: TextStyle(color: textColor),
        bodySmall: TextStyle(color: textColor.withValues(alpha: 0.7)),
      ),
    );
  }

  static Map<PresetTheme, CustomTheme> getPresetThemes() {
    return {
      PresetTheme.dark: CustomTheme(
        preset: PresetTheme.dark,
        primaryColor: Colors.red,
        secondaryColor: Colors.red.shade700,
        isDark: true,
        isAmoled: false,
      ),
      PresetTheme.light: CustomTheme(
        preset: PresetTheme.light,
        primaryColor: Colors.red,
        secondaryColor: Colors.red.shade700,
        isDark: false,
        isAmoled: false,
      ),
      PresetTheme.amoled: CustomTheme(
        preset: PresetTheme.amoled,
        primaryColor: Colors.red,
        secondaryColor: Colors.red.shade700,
        isDark: true,
        isAmoled: true,
      ),
      PresetTheme.ocean: CustomTheme(
        preset: PresetTheme.ocean,
        primaryColor: const Color(0xFF0077BE),
        secondaryColor: const Color(0xFF005A8D),
        isDark: true,
        isAmoled: false,
      ),
      PresetTheme.forest: CustomTheme(
        preset: PresetTheme.forest,
        primaryColor: const Color(0xFF2D5016),
        secondaryColor: const Color(0xFF1B3209),
        isDark: true,
        isAmoled: false,
      ),
      PresetTheme.sunset: CustomTheme(
        preset: PresetTheme.sunset,
        primaryColor: const Color(0xFFFF6B35),
        secondaryColor: const Color(0xFFD94520),
        isDark: true,
        isAmoled: false,
      ),
      PresetTheme.monochrome: CustomTheme(
        preset: PresetTheme.monochrome,
        primaryColor: Colors.grey.shade600,
        secondaryColor: const Color(0xFF757575),
        isDark: true,
        isAmoled: false,
      ),
      PresetTheme.neon: CustomTheme(
        preset: PresetTheme.neon,
        primaryColor: const Color(0xFF00FF41),
        secondaryColor: const Color(0xFF00CC33),
        isDark: true,
        isAmoled: true,
      ),
    };
  }
}
