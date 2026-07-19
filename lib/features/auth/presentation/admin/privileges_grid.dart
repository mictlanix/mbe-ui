import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Renders a paginated data table with one row per [SystemObject] and a
/// C/R/U/D checkbox group. Paginated client-side over the fixed, in-memory
/// [SystemObject.values] list (100+ entries) via the shared
/// [DataTableView]/[CatalogPage] machinery (constitution §VI — pagination
/// implemented once, not per screen) — rendering every module at once forced
/// a long scroll before reaching the form's Save button. Read-only when
/// [onChanged] is null.
class PrivilegesGrid extends StatefulWidget {
  const PrivilegesGrid({super.key, required this.privileges, this.onChanged});

  final List<Privilege> privileges;

  /// Called when a checkbox is toggled. Receives the [SystemObject] and the
  /// new `rawValue` bitmask (`0`–`15`). Null = read-only.
  final void Function(SystemObject obj, int rawValue)? onChanged;

  @override
  State<PrivilegesGrid> createState() => _PrivilegesGridState();
}

class _PrivilegesGridState extends State<PrivilegesGrid> {
  // Deliberately smaller than the 20-row page size other catalog tables use
  // (catalog_pagination.dart): this grid sits inside the user form's own
  // SingleChildScrollView, so its box height (below) is sized to fit exactly
  // this many rows with no internal scrollbar — a nested scrollbar would be
  // worse UX than the pagination itself.
  static const _pageSize = 10;

  // PaginatedDataTable2's own layout formula (paginated_data_table_2.dart
  // `autoRowsToHeight`): headingRowHeight + footer(56, paginator shown) +
  // Card's default vertical margin(8, wrapInCard:true) + dataRowHeight per
  // row. Mirrored here — rather than measured empirically — so the box is
  // exactly tall enough for one full page with no internal scroll and no
  // wasted space.
  static const _headingRowHeight = 56.0;
  static const _footerHeight = 56.0;
  static const _cardVerticalMargin = 8.0;
  static const _tableHeight =
      _headingRowHeight +
      _footerHeight +
      _cardVerticalMargin +
      kMinInteractiveDimension /* dataRowHeight default */ * _pageSize;

  int _pageIndex = 0;

  static const _rights = [
    AccessRight.create,
    AccessRight.read,
    AccessRight.update,
    AccessRight.delete,
  ];

  // One checkbox's slot width within the merged permissions column.
  static const _checkboxSlotWidth = 48.0;
  // _rights.length isn't const-evaluable; kept in sync with _rights above.
  // The extra 40 covers DataTable2's own internal cell padding (column
  // spacing / horizontal margin) around the last column's content, so the
  // Row of 4 checkbox slots isn't squeezed narrower than it asked for.
  static const _permissionsColumnWidth = _checkboxSlotWidth * 4 + 40;

  @override
  Widget build(BuildContext context) {
    final byObject = {for (final p in widget.privileges) p.systemObject: p};
    final l10n = AppLocalizations.of(context)!;
    final allObjects = SystemObject.values;
    final start = _pageIndex * _pageSize;
    final page = allObjects.skip(start).take(_pageSize).toList();

    // PaginatedDataTable2 lays out its rows in an Expanded, so it needs a
    // bounded height — unlike the plain DataTable2 this replaces, which
    // could shrink-wrap freely inside the form's SingleChildScrollView.
    // _tableHeight is sized to fit exactly one full page, so this box never
    // needs its own internal scrollbar nested inside the form's.
    return SizedBox(
      height: _tableHeight,
      child: DataTableView<SystemObject>(
        key: const Key('privileges_table'),
        columns: [
          DataTableColumn<SystemObject>.text(
            label: l10n.privilegesModuleColumn,
            text: (obj) => obj.name,
            size: ColumnSize.L,
          ),
          // A single merged column, not four separate fixedWidth columns:
          // data_table_2's DataColumn2 mis-sizes every fixed-width column
          // but the last when several appear consecutively (upstream layout
          // bug — reproduced in isolation, unrelated to this app's code).
          // One fixedWidth column with an internal Row of checkboxes avoids
          // it entirely while keeping a stable, viewport-independent width
          // (unlike ColumnSize.S, which would shrink on narrow screens).
          DataTableColumn<SystemObject>(
            label: l10n.permissionsLabel,
            header: _permissionsHeader(l10n),
            fixedWidth: _permissionsColumnWidth,
            cellBuilder: (context, obj) => _permissionsRow(obj, byObject),
          ),
        ],
        rows: page,
        pagination: CatalogPage<SystemObject>(
          items: page,
          total: allObjects.length,
          pageIndex: _pageIndex,
          pageSize: _pageSize,
        ),
        onPageChanged: (index) => setState(() => _pageIndex = index),
      ),
    );
  }

  Widget _permissionsHeader(AppLocalizations l10n) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final right in _rights)
          SizedBox(
            width: _checkboxSlotWidth,
            child: Tooltip(
              message: _columnTooltip(l10n, right),
              child: Center(child: Text(_columnLabel(l10n, right))),
            ),
          ),
      ],
    );
  }

  Widget _permissionsRow(
    SystemObject obj,
    Map<SystemObject, Privilege> byObject,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final right in _rights)
          SizedBox(
            width: _checkboxSlotWidth,
            child: Checkbox(
              key: Key('privilege_${obj.name}_${right.name}'),
              value: (byObject[obj]?.rawValue ?? 0) & right.value != 0,
              onChanged: widget.onChanged == null
                  ? null
                  : (checked) => _toggle(obj, right, byObject, checked!),
            ),
          ),
      ],
    );
  }

  void _toggle(
    SystemObject obj,
    AccessRight right,
    Map<SystemObject, Privilege> byObject,
    bool checked,
  ) {
    final raw = byObject[obj]?.rawValue ?? 0;
    final newRaw = checked ? raw | right.value : raw & ~right.value;
    widget.onChanged!(obj, newRaw & 0xF);
  }

  static String _columnLabel(AppLocalizations l10n, AccessRight right) =>
      switch (right) {
        AccessRight.create => l10n.privilegesCreateColumn,
        AccessRight.read => l10n.privilegesReadColumn,
        AccessRight.update => l10n.privilegesUpdateColumn,
        AccessRight.delete => l10n.privilegesDeleteColumn,
        AccessRight.none => '',
      };

  static String _columnTooltip(AppLocalizations l10n, AccessRight right) =>
      switch (right) {
        AccessRight.create => l10n.privilegesCreateTooltip,
        AccessRight.read => l10n.privilegesReadTooltip,
        AccessRight.update => l10n.privilegesUpdateTooltip,
        AccessRight.delete => l10n.privilegesDeleteTooltip,
        AccessRight.none => '',
      };
}
