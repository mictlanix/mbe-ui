import 'package:flutter/material.dart';

import 'package:mbe_ui/core/widgets/app_side_sheet.dart';

/// Opens the catalog filter panel (research.md §1; constitution §VI) on the
/// shared responsive shell (`showAppSideSheet`, spec 027 research.md R6) —
/// modal bottom sheet on compact widths, right-anchored side sheet above
/// `LayoutBreakpoints.expanded`.
///
/// Filtering is applied live by [builder]'s controls, so nothing is
/// returned — dismissing the panel simply reveals the already-filtered list.
/// [onClearAll] is wired to the footer's "Clear all" action; the primary
/// "Apply" button just dismisses the panel.
Future<void> showCatalogFilterSheet(
  BuildContext context, {
  required String title,
  required WidgetBuilder builder,
  required String clearAllLabel,
  required String applyLabel,
  VoidCallback? onClearAll,
}) {
  return showAppSideSheet(
    context,
    title: title,
    builder: builder,
    footerBuilder: (context) => OverflowBar(
      // `OverflowBar`, not `Row` + `Spacer`: at the 336 px this row gets
      // inside the 360 px side sheet, a longer translation of either label
      // (e.g. es-MX's "Limpiar filtros", 15 chars vs "Clear all") can
      // overflow combined with the other button — discovered via spec 027's
      // own filter-drawer test, the first to open this footer under a real
      // (non-hardcoded) locale string rather than a hardcoded literal. A
      // `Spacer` can only shrink itself to zero; it can't shrink the
      // buttons, and giving them `Flexible` flex shares equal to the
      // `Spacer`'s pulled "Apply" away from the trailing edge even when
      // both fit comfortably. `OverflowBar` lays out exactly like the
      // original `Row` (`alignment: spaceBetween` keeps the two buttons
      // pinned to their edges) whenever they fit, and falls back to a
      // stacked column — no text ever truncated — only when they do not.
      alignment: MainAxisAlignment.spaceBetween,
      overflowAlignment: OverflowBarAlignment.end,
      overflowSpacing: 8,
      children: [
        TextButton(
          key: const Key('filter_sheet_clear_all_button'),
          onPressed: onClearAll,
          child: Text(clearAllLabel),
        ),
        FilledButton(
          key: const Key('filter_sheet_apply_button'),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(applyLabel),
        ),
      ],
    ),
  );
}
