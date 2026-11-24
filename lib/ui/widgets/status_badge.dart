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
    final semantic =
        Theme.of(context).extension<AppSemanticColors>() ?? AppSemanticColors.light;

    final (Color bg, Color fg) = switch (status) {
      RequestStatus.open => (semantic.statusOpenBg, semantic.statusOpenFg),
      RequestStatus.inProgress => (
          semantic.statusInProgressBg,
          semantic.statusInProgressFg,
        ),
      RequestStatus.completed => (
          semantic.statusCompletedBg,
          semantic.statusCompletedFg,
        ),
    };

    return Semantics(
      label: 'Status: ${status.label}',
      child: AnimatedContainer(
        duration: AppMotion.duration(context, AppMotion.fast),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 12,
          vertical: compact ? 5 : 6,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppRadius.pillRadius,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: fg,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: AnimatedSwitcher(
                duration: AppMotion.duration(context, AppMotion.fast),
                child: Text(
                  status.label,
                  key: ValueKey(status),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: fg,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
