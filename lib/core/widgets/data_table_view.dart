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
    this.frozen = false,
  });

  /// Convenience for a plain-text cell: wraps [text] in an ellipsis-on-
  /// overflow [Text] with a hover-tooltip fallback showing the full value
  /// (constitution §VI truncation rule). MUST NOT be used for [frozen]
  /// (identity) columns, totals/amounts, status badges, or other text the
  /// user needs in full — those MUST use the default constructor with a
  /// [cellBuilder] that never truncates, per the constitution's "never
  /// truncate critical info" rule. When [frozen] is true this falls back to
  /// plain, non-ellipsized text.
  factory DataTableColumn.text({
    required String label,
    required String Function(T item) text,
    Comparator<T>? comparator,
    bool numeric = false,
    bool frozen = false,
  }) {
    return DataTableColumn<T>(
      label: label,
      numeric: numeric,
      frozen: frozen,
      comparator: comparator,
      cellBuilder: (context, item) {
        final value = text(item);
        if (frozen) return Text(value);
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

  /// Pins this column to the left edge during horizontal scroll
  /// (constitution §VI; FR-007/FR-008 — the catalog's identity column,
  /// e.g. product code or username). At most one column per table should
  /// set this, and it MUST be the first column in [DataTableView.columns]
  /// — `data_table_2` only supports freezing a contiguous run of leading
  /// columns.
  final bool frozen;
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
  DataTableView({
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
       ),
       assert(
         columns.where((c) => c.frozen).length <= 1,
         'At most one column may be frozen',
       ),
       assert(
         columns.isEmpty || columns.indexWhere((c) => c.frozen) <= 0,
         'The frozen column must be the first column',
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

  int get _fixedLeftColumns =>
      widget.columns.isNotEmpty && widget.columns.first.frozen ? 1 : 0;

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
        DataColumn(
          label: Text(column.label),
          numeric: column.numeric,
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
        fixedLeftColumns: _fixedLeftColumns,
        rowsPerPage: pagination.pageSize,
        availableRowsPerPage: [pagination.pageSize],
        onRowsPerPageChanged: null,
        initialFirstRowIndex: pagination.pageIndex * pagination.pageSize,
        onPageChanged: (firstRowIndex) =>
            widget.onPageChanged!(firstRowIndex ~/ pagination.pageSize),
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

    return DataTable2(
      fixedLeftColumns: _fixedLeftColumns,
      sortColumnIndex: _sortColumnIndex,
      sortAscending: _sortAscending,
      columns: _buildColumns(sortable: true),
      rows: [for (final item in rows) _buildRow(item)],
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
