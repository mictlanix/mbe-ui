import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

import 'catalog_pagination.dart';

/// A column in a [DataTableView]. If [comparator] is provided, the column
/// header is sortable (only when the table is unpaginated — see
/// [DataTableView.pagination]).
class DataTableColumn<T> {
  const DataTableColumn({
    required this.label,
    required this.cellBuilder,
    this.comparator,
    this.numeric = false,
    this.size = ColumnSize.M,
    this.fixedWidth,
    this.header,
  });

  /// Convenience for a plain-text cell: wraps [text] in an ellipsis-on-
  /// overflow [Text] with a hover-tooltip fallback showing the full value
  /// (constitution §VI truncation rule). MUST NOT be used for totals/
  /// amounts, status badges, or other text the user needs in full — those
  /// MUST use the default constructor with a [cellBuilder] that never
  /// truncates, per the constitution's "never truncate critical info" rule.
  factory DataTableColumn.text({
    required String label,
    required String Function(T item) text,
    Comparator<T>? comparator,
    bool numeric = false,
    ColumnSize size = ColumnSize.M,
    double? fixedWidth,
  }) {
    return DataTableColumn<T>(
      label: label,
      numeric: numeric,
      comparator: comparator,
      size: size,
      fixedWidth: fixedWidth,
      cellBuilder: (context, item) {
        final value = text(item);
        return Tooltip(
          message: value,
          child: Text(value, overflow: TextOverflow.ellipsis, maxLines: 1),
        );
      },
    );
  }

  final String label;
  final Widget Function(BuildContext context, T item) cellBuilder;
  final Comparator<T>? comparator;
  final bool numeric;

  /// Relative column width (`data_table_2`'s [ColumnSize]) — lets a screen
  /// give a wide free-text column (e.g. a name) more room than narrow
  /// columns (e.g. a code or status) without affecting any other catalog.
  /// Ignored when [fixedWidth] is set.
  final ColumnSize size;

  /// Absolute column width in pixels, for short, bounded content (e.g. a
  /// code or status badge) that shouldn't grow with the table's relative
  /// `size` distribution. Takes precedence over [size] when set.
  final double? fixedWidth;

  /// Optional custom header content, replacing the default `Text(label)`
  /// header — for a column whose header needs more than a single string
  /// (e.g. several tooltip-wrapped sub-labels for a merged column). [label]
  /// is still required for accessibility/semantics purposes when this is set.
  final Widget? header;
}

/// Shared sortable/paginated data table for list screens (constitution
/// §VI — shared data tables MUST live in `core/widgets/`, not be
/// reimplemented per module). Backed by `data_table_2`: renders a plain
/// `DataTable2` when [pagination] is `null`, or a `PaginatedDataTable2`
/// driven by [pagination] otherwise (research.md §1/§2) — one widget, one
/// `fixedLeftColumns`/frozen-column code path for both. Optionally renders
/// trailing row actions (e.g. view/edit/delete), which callers gate with
/// `AccessControlService.can()`.
class DataTableView<T> extends StatefulWidget {
  const DataTableView({
    super.key,
    required this.columns,
    required this.rows,
    this.rowActionsBuilder,
    this.onRowTap,
    this.pagination,
    this.onPageChanged,
  }) : assert(
         pagination == null || onPageChanged != null,
         'onPageChanged is required when pagination is supplied',
       );

  final List<DataTableColumn<T>> columns;

  /// The rows to render. When [pagination] is supplied, this MUST be
  /// exactly [pagination]'s `items` (the current page).
  final List<T> rows;
  final List<Widget> Function(BuildContext context, T item)? rowActionsBuilder;
  final void Function(T item)? onRowTap;

  /// When non-null, renders via `PaginatedDataTable2` driven by this page
  /// state instead of a plain `DataTable2` (research.md §1/§2, FR-002).
  final CatalogPage<T>? pagination;

  /// Required when [pagination] is supplied. Called with the new 0-based
  /// page index when the user navigates pages.
  final ValueChanged<int>? onPageChanged;

  @override
  State<DataTableView<T>> createState() => _DataTableViewState<T>();
}

class _DataTableViewState<T> extends State<DataTableView<T>> {
  int? _sortColumnIndex;
  bool _sortAscending = true;
  _CatalogDataTableSource<T>? _source;

  @override
  void didUpdateWidget(DataTableView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _source?._update(widget);
  }

  @override
  void dispose() {
    _source?.dispose();
    super.dispose();
  }

  List<DataColumn> _buildColumns({required bool sortable}) {
    return [
      for (final column in widget.columns)
        DataColumn2(
          label: column.header ?? Text(column.label),
          numeric: column.numeric,
          size: column.size,
          fixedWidth: column.fixedWidth,
          onSort: !sortable || column.comparator == null
              ? null
              : (columnIndex, ascending) {
                  setState(() {
                    _sortColumnIndex = columnIndex;
                    _sortAscending = ascending;
                  });
                },
        ),
      if (widget.rowActionsBuilder != null)
        const DataColumn2(label: Text(''), fixedWidth: 150),
    ];
  }

  DataRow _buildRow(T item) {
    return DataRow(
      onSelectChanged: widget.onRowTap == null
          ? null
          : (_) => widget.onRowTap!(item),
      cells: [
        for (final column in widget.columns)
          DataCell(column.cellBuilder(context, item)),
        if (widget.rowActionsBuilder != null)
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: widget.rowActionsBuilder!(context, item),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final pagination = widget.pagination;
    if (pagination != null) {
      _source ??= _CatalogDataTableSource<T>(widget, _buildRow);
      return PaginatedDataTable2(
        columns: _buildColumns(sortable: false),
        source: _source!,
        showCheckboxColumn: false,
        rowsPerPage: pagination.pageSize,
        availableRowsPerPage: [pagination.pageSize],
        onRowsPerPageChanged: null,
        initialFirstRowIndex: pagination.pageIndex * pagination.pageSize,
        onPageChanged: (firstRowIndex) =>
            widget.onPageChanged!(firstRowIndex ~/ pagination.pageSize),
        // Otherwise a result set smaller than one page (e.g. 3 price lists
        // on a 20-row page) renders 17 invisible blank rows, leaving a large
        // empty gap below the real data — this is what made a short
        // catalog's table look like it had "extra padding" compared to a
        // longer one that always fills its page.
        renderEmptyRowsInTheEnd: false,
      );
    }

    final rows = [...widget.rows];
    final sortColumnIndex = _sortColumnIndex;
    if (sortColumnIndex != null && sortColumnIndex < widget.columns.length) {
      final comparator = widget.columns[sortColumnIndex].comparator;
      if (comparator != null) {
        rows.sort(_sortAscending ? comparator : (a, b) => comparator(b, a));
      }
    }

    // `PaginatedDataTable2` wraps itself in a `Card` by default
    // (`wrapInCard: true`), giving every paginated catalog table a
    // consistent surface/elevation and internal padding. Plain `DataTable2`
    // has no such option, so a non-paginated table (e.g. the pricing tool's
    // per-product price grid, which has no meaningful "page 2") would
    // otherwise look inconsistent with the rest of the app — matched here
    // explicitly so all catalog/list tables render identically regardless
    // of whether they paginate (constitution §VI: implemented once, shared).
    return Card(
      semanticContainer: false,
      child: DataTable2(
        showCheckboxColumn: false,
        sortColumnIndex: _sortColumnIndex,
        sortAscending: _sortAscending,
        columns: _buildColumns(sortable: true),
        rows: [for (final item in rows) _buildRow(item)],
      ),
    );
  }
}

/// Adapts [DataTableView.rows]/[DataTableView.pagination] to the
/// `DataTableSource` model `PaginatedDataTable2` requires. Only the
/// current page's rows are ever held in memory — [getRow] returns `null`
/// for any other index, which `PaginatedDataTable2` renders as a blank/
/// loading row per `DataTableSource.getRow`'s documented contract.
class _CatalogDataTableSource<T> extends DataTableSource {
  _CatalogDataTableSource(this._widget, this._buildRow);

  DataTableView<T> _widget;
  final DataRow Function(T item) _buildRow;

  void _update(DataTableView<T> widget) {
    _widget = widget;
    notifyListeners();
  }

  @override
  DataRow? getRow(int index) {
    final pagination = _widget.pagination;
    if (pagination == null) return null;
    final firstIndex = pagination.pageIndex * pagination.pageSize;
    final localIndex = index - firstIndex;
    if (localIndex < 0 || localIndex >= _widget.rows.length) return null;
    return _buildRow(_widget.rows[localIndex]);
  }

  @override
  int get rowCount => _widget.pagination?.total ?? 0;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
