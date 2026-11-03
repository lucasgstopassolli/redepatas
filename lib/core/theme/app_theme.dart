import 'package:flutter/material.dart';

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

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: lightBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: terracottaPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: lightOutline, width: 1),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: lightSurface,
        indicatorColor: lightSurfaceContainer,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
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
            return const IconThemeData(color: terracottaPrimary);
          }
          return const IconThemeData(color: lightSecondaryText);
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: terracottaPrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: terracottaPrimary,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: terracottaPrimary, width: 1.5),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: lightSecondaryText),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: lightOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: lightOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: terracottaPrimary, width: 2),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: lightOutline,
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: lightSurface,
        selectedColor: caramelSecondary.withValues(alpha: 0.22),
        checkmarkColor: terracottaPrimary,
        side: const BorderSide(color: lightOutline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
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

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkOnSurface,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: darkOutline, width: 1),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkSurface,
        indicatorColor: darkOutline,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
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
            return const IconThemeData(color: terracottaDarkPrimary);
          }
          return const IconThemeData(color: darkSecondaryText);
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: terracottaDarkPrimary,
          foregroundColor: darkBackground,
          minimumSize: const Size.fromHeight(52),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: terracottaDarkPrimary,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: terracottaDarkPrimary, width: 1.5),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: darkSecondaryText),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: darkOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: darkOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: terracottaDarkPrimary, width: 2),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: darkOutline,
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: darkSurface,
        selectedColor: caramelSecondary.withValues(alpha: 0.28),
        checkmarkColor: terracottaDarkPrimary,
        side: const BorderSide(color: darkOutline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
