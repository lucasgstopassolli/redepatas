import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';

enum AppButtonKind { primary, secondary, text, danger }

class AppButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final AppButtonKind kind;
  final bool loading;
  final bool expand;

  const AppButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.kind = AppButtonKind.primary,
    this.loading = false,
    this.expand = true,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = widget.onPressed == null || widget.loading;

    final content = AnimatedSwitcher(
      duration: AppMotion.duration(context, AppMotion.fast),
      child: widget.loading
          ? SizedBox(
              key: const ValueKey('loading'),
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: widget.kind == AppButtonKind.primary ||
                        widget.kind == AppButtonKind.danger
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.primary,
              ),
            )
          : Row(
              key: const ValueKey('label'),
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, size: 22),
                  const SizedBox(width: AppSpacing.xs),
                ],
                Flexible(
                  child: Text(
                    widget.label,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
    );

    final VoidCallback? handler = isDisabled ? null : widget.onPressed;

    Widget button = switch (widget.kind) {
      AppButtonKind.primary => FilledButton(
          onPressed: handler,
          child: content,
        ),
      AppButtonKind.secondary => OutlinedButton(
          onPressed: handler,
          child: content,
        ),
      AppButtonKind.text => TextButton(
          onPressed: handler,
          child: content,
        ),
      AppButtonKind.danger => FilledButton(
          onPressed: handler,
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: Colors.white,
          ),
          child: content,
        ),
    };

    if (widget.expand && widget.kind != AppButtonKind.text) {
      button = SizedBox(width: double.infinity, child: button);
    }

    return Listener(
      onPointerDown: isDisabled ? null : (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: AppMotion.duration(context, const Duration(milliseconds: 100)),
        child: button,
      ),
    );
  }
}
