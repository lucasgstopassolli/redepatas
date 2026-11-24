import 'package:flutter/material.dart';

import 'app_tokens.dart';

/// Cores semânticas interpoláveis entre tema claro e escuro.
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  final Color statusOpenFg;
  final Color statusOpenBg;
  final Color statusInProgressFg;
  final Color statusInProgressBg;
  final Color statusCompletedFg;
  final Color statusCompletedBg;
  final Color urgencyHighFg;
  final Color urgencyHighBg;
  final Color urgencyCriticalFg;
  final Color urgencyCriticalBg;
  final Color navShadow;

  const AppSemanticColors({
    required this.statusOpenFg,
    required this.statusOpenBg,
    required this.statusInProgressFg,
    required this.statusInProgressBg,
    required this.statusCompletedFg,
    required this.statusCompletedBg,
    required this.urgencyHighFg,
    required this.urgencyHighBg,
    required this.urgencyCriticalFg,
    required this.urgencyCriticalBg,
    required this.navShadow,
  });

  static const light = AppSemanticColors(
    statusOpenFg: AppTheme.statusOpenText,
    statusOpenBg: AppTheme.statusOpenBgLight,
    statusInProgressFg: AppTheme.statusInProgressText,
    statusInProgressBg: AppTheme.statusInProgressBgLight,
    statusCompletedFg: AppTheme.statusCompletedText,
    statusCompletedBg: AppTheme.statusCompletedBgLight,
    urgencyHighFg: AppTheme.urgencyHighTextLight,
    urgencyHighBg: AppTheme.urgencyHighBgLight,
    urgencyCriticalFg: AppTheme.criticalUrgency,
    urgencyCriticalBg: AppTheme.urgencyCriticalBgLight,
    navShadow: Color(0x1A000000),
  );

  static const dark = AppSemanticColors(
    statusOpenFg: AppTheme.statusOpenTextDark,
    statusOpenBg: AppTheme.statusOpenBgDark,
    statusInProgressFg: AppTheme.statusInProgressTextDark,
    statusInProgressBg: AppTheme.statusInProgressBgDark,
    statusCompletedFg: AppTheme.statusCompletedTextDark,
    statusCompletedBg: AppTheme.statusCompletedBgDark,
    urgencyHighFg: AppTheme.urgencyHighTextDark,
    urgencyHighBg: AppTheme.urgencyHighBgDark,
    urgencyCriticalFg: AppTheme.criticalUrgencyDark,
    urgencyCriticalBg: AppTheme.urgencyCriticalBgDark,
    navShadow: Color(0x61000000),
  );

  @override
  AppSemanticColors copyWith({
    Color? statusOpenFg,
    Color? statusOpenBg,
    Color? statusInProgressFg,
    Color? statusInProgressBg,
    Color? statusCompletedFg,
    Color? statusCompletedBg,
    Color? urgencyHighFg,
    Color? urgencyHighBg,
    Color? urgencyCriticalFg,
    Color? urgencyCriticalBg,
    Color? navShadow,
  }) {
    return AppSemanticColors(
      statusOpenFg: statusOpenFg ?? this.statusOpenFg,
      statusOpenBg: statusOpenBg ?? this.statusOpenBg,
      statusInProgressFg: statusInProgressFg ?? this.statusInProgressFg,
      statusInProgressBg: statusInProgressBg ?? this.statusInProgressBg,
      statusCompletedFg: statusCompletedFg ?? this.statusCompletedFg,
      statusCompletedBg: statusCompletedBg ?? this.statusCompletedBg,
      urgencyHighFg: urgencyHighFg ?? this.urgencyHighFg,
      urgencyHighBg: urgencyHighBg ?? this.urgencyHighBg,
      urgencyCriticalFg: urgencyCriticalFg ?? this.urgencyCriticalFg,
      urgencyCriticalBg: urgencyCriticalBg ?? this.urgencyCriticalBg,
      navShadow: navShadow ?? this.navShadow,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      statusOpenFg: Color.lerp(statusOpenFg, other.statusOpenFg, t)!,
      statusOpenBg: Color.lerp(statusOpenBg, other.statusOpenBg, t)!,
      statusInProgressFg:
          Color.lerp(statusInProgressFg, other.statusInProgressFg, t)!,
      statusInProgressBg:
          Color.lerp(statusInProgressBg, other.statusInProgressBg, t)!,
      statusCompletedFg:
          Color.lerp(statusCompletedFg, other.statusCompletedFg, t)!,
      statusCompletedBg:
          Color.lerp(statusCompletedBg, other.statusCompletedBg, t)!,
      urgencyHighFg: Color.lerp(urgencyHighFg, other.urgencyHighFg, t)!,
      urgencyHighBg: Color.lerp(urgencyHighBg, other.urgencyHighBg, t)!,
      urgencyCriticalFg:
          Color.lerp(urgencyCriticalFg, other.urgencyCriticalFg, t)!,
      urgencyCriticalBg:
          Color.lerp(urgencyCriticalBg, other.urgencyCriticalBg, t)!,
      navShadow: Color.lerp(navShadow, other.navShadow, t)!,
    );
  }
}

class _Palette {
  final Brightness brightness;
  final Color primary;
  final Color onPrimary;
  final Color background;
  final Color surface;
  final Color surfaceContainer;
  final Color onSurface;
  final Color secondaryText;
  final Color outline;
  final Color error;
  final AppSemanticColors semantic;

  const _Palette({
    required this.brightness,
    required this.primary,
    required this.onPrimary,
    required this.background,
    required this.surface,
    required this.surfaceContainer,
    required this.onSurface,
    required this.secondaryText,
    required this.outline,
    required this.error,
    required this.semantic,
  });

  static const light = _Palette(
    brightness: Brightness.light,
    primary: AppTheme.terracottaPrimary,
    onPrimary: Colors.white,
    background: AppTheme.lightBackground,
    surface: AppTheme.lightSurface,
    surfaceContainer: AppTheme.lightSurfaceContainer,
    onSurface: AppTheme.lightOnSurface,
    secondaryText: AppTheme.lightSecondaryText,
    outline: AppTheme.lightOutline,
    error: AppTheme.criticalUrgency,
    semantic: AppSemanticColors.light,
  );

  static const dark = _Palette(
    brightness: Brightness.dark,
    primary: AppTheme.terracottaDarkPrimary,
    onPrimary: AppTheme.darkBackground,
    background: AppTheme.darkBackground,
    surface: AppTheme.darkSurface,
    surfaceContainer: AppTheme.darkSurfaceContainer,
    onSurface: AppTheme.darkOnSurface,
    secondaryText: AppTheme.darkSecondaryText,
    outline: AppTheme.darkOutline,
    error: AppTheme.criticalUrgencyDark,
    semantic: AppSemanticColors.dark,
  );
}

class AppTheme {
  // Cores base da identidade terrosa (NÃO alterar)
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

  /// Temas pré-construídos e em cache (evita reconstrução cara na troca de tema).
  static final ThemeData lightTheme = _build(_Palette.light);
  static final ThemeData darkTheme = _build(_Palette.dark);

  static TextTheme _buildTextTheme(Color primaryColor, Color secondaryColor) {
    return TextTheme(
      headlineMedium: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: primaryColor,
        letterSpacing: -0.5,
        height: 1.2,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: primaryColor,
        letterSpacing: -0.4,
        height: 1.25,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: primaryColor,
        letterSpacing: -0.3,
      ),
      titleMedium: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        letterSpacing: -0.2,
      ),
      titleSmall: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: primaryColor,
        height: 1.45,
      ),
      bodyMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: secondaryColor,
        height: 1.45,
      ),
      bodySmall: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: secondaryColor,
        height: 1.35,
      ),
      labelLarge: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      labelMedium: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: secondaryColor,
      ),
      labelSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: secondaryColor,
      ),
    );
  }

  static ThemeData _build(_Palette p) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: terracottaPrimary,
      brightness: p.brightness,
      primary: p.primary,
      onPrimary: p.onPrimary,
      secondary: caramelSecondary,
      tertiary: sageTertiary,
      surface: p.surface,
      onSurface: p.onSurface,
      onSurfaceVariant: p.secondaryText,
      surfaceContainer: p.surfaceContainer,
      surfaceContainerHighest: p.surfaceContainer,
      outline: p.outline,
      error: p.error,
    );

    final textTheme = _buildTextTheme(p.onSurface, p.secondaryText);

    return ThemeData(
      useMaterial3: true,
      brightness: p.brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: p.background,
      textTheme: textTheme,
      extensions: [p.semantic],
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        foregroundColor: p.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: p.onSurface, size: AppSizes.iconMd),
        shape: Border(
          bottom: BorderSide(color: p.outline, width: 1),
        ),
      ),
      cardTheme: CardThemeData(
        color: p.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.controlRadius,
          side: BorderSide(color: p.outline, width: 1),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: p.onPrimary,
          minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          elevation: 0,
          iconSize: 22,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.controlRadius,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.primary,
          minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          side: BorderSide(color: p.primary, width: 1.4),
          elevation: 0,
          iconSize: 22,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.controlRadius,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.primary,
          minimumSize: const Size(64, AppSizes.buttonHeightSm),
          tapTargetSize: MaterialTapTargetSize.padded,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.controlRadius,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(AppSizes.tapMin, AppSizes.tapMin),
          iconSize: 26,
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: TextStyle(color: p.secondaryText, fontSize: 15),
        labelStyle: TextStyle(color: p.secondaryText, fontSize: 15),
        floatingLabelStyle: TextStyle(
          color: p.primary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.controlRadius,
          borderSide: BorderSide(color: p.outline, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.controlRadius,
          borderSide: BorderSide(color: p.outline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.controlRadius,
          borderSide: BorderSide(color: p.primary, width: 1.8),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: p.outline,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: p.surface,
        selectedColor: p.surfaceContainer,
        checkmarkColor: p.primary,
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        side: BorderSide(color: p.outline, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.controlRadius,
        ),
        labelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: p.onSurface,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(0, 52)),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: AppRadius.controlRadius),
          ),
          side: WidgetStatePropertyAll(
            BorderSide(color: p.outline, width: 1),
          ),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: p.primary,
        unselectedLabelColor: p.secondaryText,
        indicatorColor: p.primary,
        labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.controlRadius),
        contentTextStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.dialogRadius),
        backgroundColor: p.surface,
      ),
      listTileTheme: ListTileThemeData(
        minVerticalPadding: 12,
        titleTextStyle: textTheme.titleMedium?.copyWith(fontSize: 16),
        subtitleTextStyle: textTheme.bodyMedium?.copyWith(fontSize: 14),
      ),
    );
  }
}
