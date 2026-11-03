import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_tokens.dart';

class AppTheme {
  // Cores base da identidade terrosa
  static const Color terracottaPrimary = Color(0xFFC85A32);
  static const Color terracottaDarkPrimary = Color(0xFFE07A5F);
  static const Color caramelSecondary = Color(0xFFD48C46);
  static const Color sageTertiary = Color(0xFF5F7A61);

  // Fundos e Superfícies (Modo Claro — Areia/Creme)
  static const Color lightBackground = Color(0xFFFAF6F0);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceContainer = Color(0xFFF3EAE1);
  static const Color lightOnSurface = Color(0xFF2D221E);
  static const Color lightSecondaryText = Color(0xFF6E5A53);
  static const Color lightOutline = Color(0xFFE2D5C8);

  // Fundos e Superfícies (Modo Escuro — Terra Noturna)
  static const Color darkBackground = Color(0xFF1A1412);
  static const Color darkSurface = Color(0xFF261E1B);
  static const Color darkSurfaceContainer = Color(0xFF362A26);
  static const Color darkOnSurface = Color(0xFFF5EBE6);
  static const Color darkSecondaryText = Color(0xFFB8A69E);
  static const Color darkOutline = Color(0xFF4A3B35);

  // Cores Semânticas (Status e Urgência)
  static const Color statusOpenText = Color(0xFFB84A24);
  static const Color statusOpenBgLight = Color(0xFFFDE8DF);
  static const Color statusOpenBgDark = Color(0xFF4A2318);
  static const Color statusOpenTextDark = Color(0xFFFFB59D);

  static const Color statusInProgressText = Color(0xFF9E6710);
  static const Color statusInProgressBgLight = Color(0xFFFEF3DC);
  static const Color statusInProgressBgDark = Color(0xFF453010);
  static const Color statusInProgressTextDark = Color(0xFFFFD88D);

  static const Color statusCompletedText = Color(0xFF2E6B3E);
  static const Color statusCompletedBgLight = Color(0xFFE3F5E8);
  static const Color statusCompletedBgDark = Color(0xFF193822);
  static const Color statusCompletedTextDark = Color(0xFFA8E5B5);

  static const Color criticalUrgency = Color(0xFFB3261E);
  static const Color criticalUrgencyDark = Color(0xFFFF897D);
  static const Color urgencyCriticalBgLight = Color(0xFFFBEBEA);
  static const Color urgencyCriticalBgDark = Color(0xFF421815);

  static const Color urgencyHighTextLight = Color(0xFFA65F17);
  static const Color urgencyHighTextDark = Color(0xFFFFCA7A);
  static const Color urgencyHighBgLight = Color(0xFFFBF1E6);
  static const Color urgencyHighBgDark = Color(0xFF382613);

  static TextTheme _buildTextTheme(Color primaryColor, Color secondaryColor) {
    final base = ThemeData(brightness: Brightness.light).textTheme;
    final inter = GoogleFonts.interTextTheme(base);

    return inter.copyWith(
      titleLarge: inter.titleLarge?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        letterSpacing: -0.3,
      ),
      titleMedium: inter.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        letterSpacing: -0.2,
      ),
      titleSmall: inter.titleSmall?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      bodyLarge: inter.bodyLarge?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: primaryColor,
        height: 1.45,
      ),
      bodyMedium: inter.bodyMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: secondaryColor,
        height: 1.4,
      ),
      bodySmall: inter.bodySmall?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: secondaryColor,
      ),
      labelLarge: inter.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      labelMedium: inter.labelMedium?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: secondaryColor,
      ),
      labelSmall: inter.labelSmall?.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
        color: secondaryColor,
      ),
    );
  }

  // TEMA CLARO
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: terracottaPrimary,
      brightness: Brightness.light,
      primary: terracottaPrimary,
      secondary: caramelSecondary,
      tertiary: sageTertiary,
      surface: lightSurface,
      onSurface: lightOnSurface,
      onSurfaceVariant: lightSecondaryText,
      surfaceContainer: lightSurfaceContainer,
      surfaceContainerHighest: lightSurfaceContainer,
      outline: lightOutline,
      error: criticalUrgency,
    );

    final textTheme = _buildTextTheme(lightOnSurface, lightSecondaryText);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: lightBackground,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: lightBackground,
        foregroundColor: lightOnSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: lightOnSurface, size: 22),
        shape: const Border(
          bottom: BorderSide(color: lightOutline, width: 1),
        ),
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.controlRadius,
          side: const BorderSide(color: lightOutline, width: 1),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: lightSurface,
        indicatorColor: lightSurfaceContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: terracottaPrimary,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: lightSecondaryText,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: terracottaPrimary, size: 22);
          }
          return const IconThemeData(color: lightSecondaryText, size: 22);
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: terracottaPrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.controlRadius,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: terracottaPrimary,
          minimumSize: const Size.fromHeight(48),
          side: const BorderSide(color: terracottaPrimary, width: 1.2),
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.controlRadius,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: terracottaPrimary,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.controlRadius,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: const TextStyle(color: lightSecondaryText, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: AppRadius.controlRadius,
          borderSide: const BorderSide(color: lightOutline, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.controlRadius,
          borderSide: const BorderSide(color: lightOutline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.controlRadius,
          borderSide: const BorderSide(color: terracottaPrimary, width: 1.5),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: lightOutline,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: lightSurface,
        selectedColor: lightSurfaceContainer,
        checkmarkColor: terracottaPrimary,
        showCheckmark: false,
        side: const BorderSide(color: lightOutline, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.controlRadius,
        ),
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: lightOnSurface,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: AppRadius.controlRadius),
          ),
          side: const WidgetStatePropertyAll(
            BorderSide(color: lightOutline, width: 1),
          ),
        ),
      ),
    );
  }

  // TEMA ESCURO
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: terracottaPrimary,
      brightness: Brightness.dark,
      primary: terracottaDarkPrimary,
      secondary: caramelSecondary,
      tertiary: sageTertiary,
      surface: darkSurface,
      onSurface: darkOnSurface,
      onSurfaceVariant: darkSecondaryText,
      surfaceContainer: darkSurfaceContainer,
      surfaceContainerHighest: darkSurfaceContainer,
      outline: darkOutline,
      error: criticalUrgency,
    );

    final textTheme = _buildTextTheme(darkOnSurface, darkSecondaryText);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: darkBackground,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: darkOnSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: darkOnSurface, size: 22),
        shape: const Border(
          bottom: BorderSide(color: darkOutline, width: 1),
        ),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.controlRadius,
          side: const BorderSide(color: darkOutline, width: 1),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkSurface,
        indicatorColor: darkSurfaceContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: terracottaDarkPrimary,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: darkSecondaryText,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: terracottaDarkPrimary, size: 22);
          }
          return const IconThemeData(color: darkSecondaryText, size: 22);
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: terracottaDarkPrimary,
          foregroundColor: darkBackground,
          minimumSize: const Size.fromHeight(48),
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.controlRadius,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: terracottaDarkPrimary,
          minimumSize: const Size.fromHeight(48),
          side: const BorderSide(color: terracottaDarkPrimary, width: 1.2),
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.controlRadius,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: terracottaDarkPrimary,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.controlRadius,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: const TextStyle(color: darkSecondaryText, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: AppRadius.controlRadius,
          borderSide: const BorderSide(color: darkOutline, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.controlRadius,
          borderSide: const BorderSide(color: darkOutline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.controlRadius,
          borderSide: const BorderSide(color: terracottaDarkPrimary, width: 1.5),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: darkOutline,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: darkSurface,
        selectedColor: darkSurfaceContainer,
        checkmarkColor: terracottaDarkPrimary,
        showCheckmark: false,
        side: const BorderSide(color: darkOutline, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.controlRadius,
        ),
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: darkOnSurface,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: AppRadius.controlRadius),
          ),
          side: const WidgetStatePropertyAll(
            BorderSide(color: darkOutline, width: 1),
          ),
        ),
      ),
    );
  }
}
