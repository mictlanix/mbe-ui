import 'package:flutter/material.dart';

import 'package:mbe_ui/core/layout/breakpoints.dart';

/// Opens a responsive panel (spec 022 research.md §1; constitution §VI;
/// extracted from `catalog_filter_sheet.dart` per spec 027 research.md R6
/// so the shift sheet — `cash_sessions_screen.dart`'s open/close-shift panel
/// — shares this shell instead of re-solving the same two problems):
///
/// * a **modal bottom sheet** on compact widths (`< LayoutBreakpoints.expanded`)
/// * a **right-anchored modal side sheet** on expanded+ widths.
///
/// [builder] is the panel's scrollable body. [footerBuilder] is an optional,
/// separate action row pinned below the scrollable body (a filter panel's
/// Clear all/Apply); omit it when the body already carries its own action —
/// the shift panel's Open/Close button is part of `_OpenForm`/`_OpenShiftCard`
/// itself, submitted inline like any other form, not lifted into a second
/// slot. When supplied, [footerBuilder] is built with the sheet's own
/// `BuildContext` so it can call `Navigator.of(context).pop()` itself.
/// Nothing is returned — a caller that needs to react to what happened
/// inside reads it from whatever state [builder]/[footerBuilder] already
/// write to (a Riverpod provider, a `ListQuery`/URL change), not from this
/// function's return value.
///
/// Pushed onto the **root** navigator (`useRootNavigator: true`), not the
/// nearest one — [builder]'s content can trigger `context.go`/`context.push`
/// navigation of its own (a live-apply filter facet; the shift sheet's
/// blocked-by-another-session error, which pushes to that session's detail
/// screen), and each catalog list lives inside its own `StatefulShellBranch`
/// with its own nested Navigator. A sheet attached to that nested (branch)
/// Navigator would be torn down by `go`'s declarative page-stack rebuild the
/// moment such a change fires; attaching to the true root Navigator (above
/// the shell) keeps it open across it, matching `showGeneralDialog`'s own
/// default (`useRootNavigator: true`) — explicit here so both presentation
/// paths agree instead of one accidentally relying on a library default.
Future<void> showAppSideSheet(
  BuildContext context, {
  required String title,
  required WidgetBuilder builder,
  WidgetBuilder? footerBuilder,
}) {
  final width = MediaQuery.sizeOf(context).width;
  final footer = footerBuilder == null ? null : Builder(builder: footerBuilder);

  if (width < LayoutBreakpoints.expanded) {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => _AppSideSheet(
        title: title,
        isSideSheet: false,
        body: Builder(builder: builder),
        footer: footer,
      ),
    );
  }

  return showGeneralDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: true,
    barrierLabel: title,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (ctx, _, _) => Align(
      alignment: Alignment.centerRight,
      child: _AppSideSheet(
        title: title,
        isSideSheet: true,
        body: Builder(builder: builder),
        footer: footer,
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

/// Shared panel chrome (title/close header, scrollable body, footer)
/// rendered for both the bottom-sheet and side-sheet presentations.
class _AppSideSheet extends StatelessWidget {
  const _AppSideSheet({
    required this.title,
    required this.isSideSheet,
    required this.body,
    required this.footer,
  });

  final String title;
  final bool isSideSheet;
  final Widget body;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final scrollable = SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: body,
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
        if (footer != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 16, 8),
            child: footer,
          ),
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
