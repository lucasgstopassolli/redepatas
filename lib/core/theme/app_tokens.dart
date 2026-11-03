import 'package:flutter/material.dart';

/// Tokens de espaçamento e raios de borda do RedePatas (Design System Minimalista).
class AppSpacing {
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}

class AppRadius {
  /// Raio padrão consistente para cards, botões, inputs, chips e modais.
  static const double control = 8.0;
  static final BorderRadius controlRadius = BorderRadius.circular(control);

  /// Raio para badges e pills semânticos.
  static const double pill = 999.0;
  static final BorderRadius pillRadius = BorderRadius.circular(pill);
}
