import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
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

    final (Color bg, Color fg, String text, IconData icon) = switch (urgency) {
      UrgencyLevel.critical => (
          isDark ? const Color(0xFF4F1814) : const Color(0xFFFCE8E6),
          isDark ? AppTheme.criticalUrgencyDark : AppTheme.criticalUrgency,
          'Urgência Crítica',
          Icons.warning_amber_rounded,
        ),
      UrgencyLevel.high => (
          isDark ? const Color(0xFF452E12) : const Color(0xFFFEF0DB),
          isDark ? const Color(0xFFFFCA7A) : const Color(0xFFA85D00),
          'Urgência Alta',
          Icons.priority_high_rounded,
        ),
      UrgencyLevel.normal => (
          isDark
              ? AppTheme.darkSurfaceContainer
              : AppTheme.lightSurfaceContainer,
          isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText,
          'Urgência Normal',
          Icons.info_outline_rounded,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: urgency == UrgencyLevel.critical
            ? Border.all(color: fg.withValues(alpha: 0.4))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
