import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/help_request_model.dart';

class StatusBadge extends StatelessWidget {
  final RequestStatus status;
  final bool compact;

  const StatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final (Color bg, Color fg, IconData icon) = switch (status) {
      RequestStatus.open => (
          isDark ? AppTheme.statusOpenBgDark : AppTheme.statusOpenBgLight,
          isDark ? AppTheme.statusOpenTextDark : AppTheme.statusOpenText,
          Icons.schedule_rounded,
        ),
      RequestStatus.inProgress => (
          isDark
              ? AppTheme.statusInProgressBgDark
              : AppTheme.statusInProgressBgLight,
          isDark
              ? AppTheme.statusInProgressTextDark
              : AppTheme.statusInProgressText,
          Icons.volunteer_activism_rounded,
        ),
      RequestStatus.completed => (
          isDark
              ? AppTheme.statusCompletedBgDark
              : AppTheme.statusCompletedBgLight,
          isDark
              ? AppTheme.statusCompletedTextDark
              : AppTheme.statusCompletedText,
          Icons.check_circle_rounded,
        ),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 13 : 15, color: fg),
          const SizedBox(width: 5),
          Text(
            status.label,
            style: TextStyle(
              color: fg,
              fontSize: compact ? 12 : 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
