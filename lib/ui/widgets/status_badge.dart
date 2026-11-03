import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/app_tokens.dart';
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

    final (Color bg, Color fg) = switch (status) {
      RequestStatus.open => (
          isDark ? AppTheme.statusOpenBgDark : AppTheme.statusOpenBgLight,
          isDark ? AppTheme.statusOpenTextDark : AppTheme.statusOpenText,
        ),
      RequestStatus.inProgress => (
          isDark
              ? AppTheme.statusInProgressBgDark
              : AppTheme.statusInProgressBgLight,
          isDark
              ? AppTheme.statusInProgressTextDark
              : AppTheme.statusInProgressText,
        ),
      RequestStatus.completed => (
          isDark
              ? AppTheme.statusCompletedBgDark
              : AppTheme.statusCompletedBgLight,
          isDark
              ? AppTheme.statusCompletedTextDark
              : AppTheme.statusCompletedText,
        ),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.pillRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: fg,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: TextStyle(
              color: fg,
              fontSize: compact ? 11.5 : 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
