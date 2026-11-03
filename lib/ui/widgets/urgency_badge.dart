import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/app_tokens.dart';
import '../../models/help_request_model.dart';

class UrgencyBadge extends StatelessWidget {
  final UrgencyLevel urgency;
  final bool showNormal;

  const UrgencyBadge({
    super.key,
    required this.urgency,
    this.showNormal = false,
  });

  @override
  Widget build(BuildContext context) {
    if (urgency == UrgencyLevel.normal && !showNormal) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final (Color bg, Color fg, String text) = switch (urgency) {
      UrgencyLevel.critical => (
          isDark
              ? AppTheme.urgencyCriticalBgDark
              : AppTheme.urgencyCriticalBgLight,
          isDark ? AppTheme.criticalUrgencyDark : AppTheme.criticalUrgency,
          'Crítica',
        ),
      UrgencyLevel.high => (
          isDark ? AppTheme.urgencyHighBgDark : AppTheme.urgencyHighBgLight,
          isDark ? AppTheme.urgencyHighTextDark : AppTheme.urgencyHighTextLight,
          'Alta',
        ),
      UrgencyLevel.normal => (
          isDark
              ? AppTheme.darkSurfaceContainer
              : AppTheme.lightSurfaceContainer,
          isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText,
          'Normal',
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.pillRadius,
        border: urgency == UrgencyLevel.critical
            ? Border.all(color: fg.withValues(alpha: 0.3), width: 1)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: fg,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
