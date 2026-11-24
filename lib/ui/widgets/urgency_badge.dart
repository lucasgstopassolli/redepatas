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

    final theme = Theme.of(context);
    final semantic =
        theme.extension<AppSemanticColors>() ?? AppSemanticColors.light;

    final (Color bg, Color fg, String text) = switch (urgency) {
      UrgencyLevel.critical => (
          semantic.urgencyCriticalBg,
          semantic.urgencyCriticalFg,
          'Crítica',
        ),
      UrgencyLevel.high => (
          semantic.urgencyHighBg,
          semantic.urgencyHighFg,
          'Alta',
        ),
      UrgencyLevel.normal => (
          theme.colorScheme.surfaceContainer,
          theme.colorScheme.onSurfaceVariant,
          'Normal',
        ),
    };

    return Semantics(
      label: 'Urgência $text',
      child: AnimatedContainer(
        duration: AppMotion.duration(context, AppMotion.fast),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppRadius.pillRadius,
          border: urgency == UrgencyLevel.critical
              ? Border.all(color: fg.withValues(alpha: 0.35), width: 1)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              urgency == UrgencyLevel.critical
                  ? Icons.priority_high_rounded
                  : Icons.warning_amber_rounded,
              size: 15,
              color: fg,
            ),
            const SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(
                color: fg,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
