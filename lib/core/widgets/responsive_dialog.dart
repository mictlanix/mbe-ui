import 'package:flutter/material.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';

/// One of a [ResponsiveDialog]'s two actions.
class ResponsiveDialogAction {
  const ResponsiveDialogAction({
    required this.label,
    required this.onPressed,
    this.busy = false,
    this.key,
  });

  final String label;

  /// `null` disables the action.
  final VoidCallback? onPressed;

  /// Shows a spinner before [label] and disables the action, so a second tap
  /// cannot start the same work twice.
  final bool busy;

  final Key? key;
}

/// A form dialog that is a regular dialog on wide screens and fills the
/// screen on a phone (spec 053 FR-015b) — `DocumentPreviewDialog`'s own
/// wide/compact switch, generalised so the next form dialog does not copy it.
///
/// Wide: a title, a scrollable [body] and a trailing action row,
/// `[secondaryAction] [primaryAction]`. Compact: a top bar with the close
/// control (leading), the title and the primary action (trailing), over a
/// scrollable body. [secondaryAction] is not shown on compact — the close
/// control takes its place.
///
/// While [dismissible] is false (work in flight), the dialog cannot be left:
/// back, Escape and a tap on the barrier all do nothing — `PopScope` blocks
/// the pop each of them asks for — and the close control and the secondary
/// action are disabled.
class ResponsiveDialog extends StatelessWidget {
  const ResponsiveDialog({
    super.key,
    required this.title,
    required this.body,
    required this.primaryAction,
    this.secondaryAction,
    this.dismissible = true,
    this.maxWidth = 560,
  });

  final String title;

  /// Scrolled by the dialog; callers must not wrap it in a scroll view.
  final Widget body;
  final ResponsiveDialogAction primaryAction;
  final ResponsiveDialogAction? secondaryAction;
  final bool dismissible;

  /// The widest the dialog gets on a wide screen.
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final compact = LayoutBreakpoints.isCompact(context);
    return PopScope(
      canPop: dismissible,
      child: compact
          ? Dialog.fullscreen(child: _compact(context))
          : Dialog(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: _wide(context),
              ),
            ),
    );
  }

  Widget _wide(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final secondary = secondaryAction;

    return Padding(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            key: const Key('responsive_dialog_title'),
            style: theme.textTheme.headlineSmall,
          ),
          SizedBox(height: spacing.md),
          Flexible(child: SingleChildScrollView(child: body)),
          SizedBox(height: spacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (secondary != null) ...[
                TextButton(
                  key: secondary.key,
                  onPressed: dismissible ? secondary.onPressed : null,
                  child: Text(secondary.label),
                ),
                SizedBox(width: spacing.xs),
              ],
              FilledButton(
                key: primaryAction.key,
                onPressed: primaryAction.busy ? null : primaryAction.onPressed,
                child: _label(context, primaryAction),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _compact(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.xs,
            vertical: spacing.xs,
          ),
          child: Row(
            children: [
              IconButton(
                key: const Key('responsive_dialog_close'),
                icon: const Icon(Icons.close),
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                onPressed: dismissible
                    ? () => Navigator.of(context).pop()
                    : null,
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: spacing.xs),
                  child: Text(
                    title,
                    key: const Key('responsive_dialog_title'),
                    style: theme.textTheme.titleLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              TextButton(
                key: primaryAction.key,
                onPressed: primaryAction.busy ? null : primaryAction.onPressed,
                child: _label(context, primaryAction),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(spacing.md),
            child: body,
          ),
        ),
      ],
    );
  }

  Widget _label(BuildContext context, ResponsiveDialogAction action) {
    if (!action.busy) return Text(action.label);
    final spacing = Theme.of(context).spacing;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox.square(
          dimension: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        SizedBox(width: spacing.xs),
        Text(action.label),
      ],
    );
  }
}

/// Opens a [ResponsiveDialog] built by [builder].
///
/// [barrierDismissible] only governs a tap on the barrier while the dialog is
/// itself dismissible; once a [ResponsiveDialog] sets `dismissible: false` its
/// `PopScope` blocks the barrier's pop too.
Future<T?> showResponsiveDialog<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: builder,
  );
}
