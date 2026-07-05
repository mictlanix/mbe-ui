import 'package:flutter/material.dart';

import 'package:mbe_ui/core/layout/breakpoints.dart';

/// Opens the catalog filter panel (research.md §1; constitution §VI):
///
/// * a **modal bottom sheet** on compact widths (`< LayoutBreakpoints.expanded`)
/// * a **right-anchored modal side sheet** on expanded+ widths.
///
/// Filtering is applied live by [builder]'s controls, so nothing is returned —
/// dismissing the panel simply reveals the already-filtered list. [onClearAll]
/// is wired to the footer's "Clear all" action; the primary "Apply" button just
/// dismisses the panel. Implemented once here so every catalog inherits the
/// same responsive behavior.
Future<void> showCatalogFilterSheet(
  BuildContext context, {
  required String title,
  required WidgetBuilder builder,
  required String clearAllLabel,
  required String applyLabel,
  VoidCallback? onClearAll,
}) {
  final width = MediaQuery.sizeOf(context).width;

  if (width < LayoutBreakpoints.expanded) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => _CatalogFilterSheet(
        title: title,
        clearAllLabel: clearAllLabel,
        applyLabel: applyLabel,
        onClearAll: onClearAll,
        isSideSheet: false,
        body: Builder(builder: builder),
      ),
    );
  }

  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: title,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (ctx, _, _) => Align(
      alignment: Alignment.centerRight,
      child: _CatalogFilterSheet(
        title: title,
        clearAllLabel: clearAllLabel,
        applyLabel: applyLabel,
        onClearAll: onClearAll,
        isSideSheet: true,
        body: Builder(builder: builder),
      ),
    ),
    transitionBuilder: (ctx, anim, _, child) => SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
      child: child,
    ),
  );
}

/// Shared panel chrome (title/close header, scrollable body, Clear all / Apply
/// footer) rendered for both the bottom-sheet and side-sheet presentations.
class _CatalogFilterSheet extends StatelessWidget {
  const _CatalogFilterSheet({
    required this.title,
    required this.clearAllLabel,
    required this.applyLabel,
    required this.onClearAll,
    required this.isSideSheet,
    required this.body,
  });

  final String title;
  final String clearAllLabel;
  final String applyLabel;
  final VoidCallback? onClearAll;
  final bool isSideSheet;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final scrollable = SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: body,
    );

    final footer = Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 16, 8),
      child: Row(
        children: [
          TextButton(
            key: const Key('filter_sheet_clear_all_button'),
            onPressed: onClearAll,
            child: Text(clearAllLabel),
          ),
          const Spacer(),
          FilledButton(
            key: const Key('filter_sheet_apply_button'),
            onPressed: () => Navigator.of(context).pop(),
            child: Text(applyLabel),
          ),
        ],
      ),
    );

    final column = Column(
      mainAxisSize: isSideSheet ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isSideSheet)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
            child: Row(
              children: [
                Expanded(child: Text(title, style: theme.textTheme.titleLarge)),
                IconButton(
                  key: const Key('filter_sheet_close_button'),
                  icon: const Icon(Icons.close),
                  tooltip: MaterialLocalizations.of(context).closeButtonLabel,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        if (isSideSheet)
          Expanded(child: scrollable)
        else
          Flexible(child: scrollable),
        footer,
      ],
    );

    if (isSideSheet) {
      return Material(
        color: theme.colorScheme.surface,
        elevation: 1,
        child: SafeArea(
          child: SizedBox(width: 360, height: double.infinity, child: column),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(top: false, child: column),
    );
  }
}
