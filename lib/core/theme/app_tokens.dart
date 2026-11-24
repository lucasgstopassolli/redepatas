import 'package:flutter/material.dart';

/// Tokens de espaçamento, tamanhos, raios e movimento do RedePatas.
class AppSpacing {
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}

class AppSizes {
  /// Mínimo absoluto de qualquer alvo de toque (acessibilidade).
  static const double tapMin = 48.0;

  /// Botões principais (FilledButton / OutlinedButton).
  static const double buttonHeight = 56.0;

  /// Botões secundários / TextButton.
  static const double buttonHeightSm = 48.0;

  /// Ícones padrão e grandes.
  static const double iconMd = 24.0;
  static const double iconLg = 28.0;

  /// Diâmetro dos itens da barra de navegação flutuante.
  static const double navItem = 56.0;

  /// Altura mínima de chips interativos.
  static const double chipHeight = 44.0;
}

class AppRadius {
  /// Raio padrão consistente para cards, botões, inputs, chips e modais.
  static const double control = 12.0;
  static final BorderRadius controlRadius = BorderRadius.circular(control);

  /// Raio para diálogos e bottom sheets.
  static const double dialog = 16.0;
  static final BorderRadius dialogRadius = BorderRadius.circular(dialog);

  /// Raio para badges e pills semânticos.
  static const double pill = 999.0;
  static final BorderRadius pillRadius = BorderRadius.circular(pill);
}

class AppMotion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 450);
  static const Curve curve = Curves.easeInOutCubic;
  static const Curve emphasized = Curves.easeOutCubic;

  static Duration duration(BuildContext context, Duration base) {
    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
      return Duration.zero;
    }
    return base;
  }
}
