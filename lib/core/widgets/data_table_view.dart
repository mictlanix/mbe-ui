import 'package:flutter/material.dart';

/// A column in a [DataTableView]. If [comparator] is provided, the column
/// header is sortable.
class DataTableColumn<T> {
  const DataTableColumn({
    required this.label,
    required this.cellBuilder,
    this.comparator,
    this.numeric = false,
  });

  final String label;
  final Widget Function(BuildContext context, T item) cellBuilder;
  final Comparator<T>? comparator;
  final bool numeric;
}

/// Shared sortable data table for list screens (constitution §VI — shared
/// data tables MUST live in `core/widgets/`, not be reimplemented per
/// module). Optionally renders trailing row actions (e.g. edit/delete),
/// which callers gate with `AccessControlService.can()`.
class DataTableView<T> extends StatefulWidget {
  const DataTableView({
    super.key,
    required this.columns,
    required this.rows,
    this.rowActionsBuilder,
    this.onRowTap,
  });

  final List<DataTableColumn<T>> columns;
  final List<T> rows;
  final List<Widget> Function(BuildContext context, T item)? rowActionsBuilder;
  final void Function(T item)? onRowTap;

  @override
  State<DataTableView<T>> createState() => _DataTableViewState<T>();
}

class _DataTableViewState<T> extends State<DataTableView<T>> {
  int? _sortColumnIndex;
  bool _sortAscending = true;

  @override
  Widget build(BuildContext context) {
    final rows = [...widget.rows];
    final sortColumnIndex = _sortColumnIndex;
    if (sortColumnIndex != null) {
      final comparator = widget.columns[sortColumnIndex].comparator;
      if (comparator != null) {
        rows.sort(_sortAscending ? comparator : (a, b) => comparator(b, a));
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        sortColumnIndex: _sortColumnIndex,
        sortAscending: _sortAscending,
        columns: [
          for (final column in widget.columns)
            DataColumn(
              label: Text(column.label),
              numeric: column.numeric,
              onSort: column.comparator == null
                  ? null
                  : (columnIndex, ascending) {
                      setState(() {
                        _sortColumnIndex = columnIndex;
                        _sortAscending = ascending;
                      });
                    },
            ),
          if (widget.rowActionsBuilder != null) const DataColumn(label: Text('')),
        ],
        rows: [
          for (final item in rows)
            DataRow(
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
            ),
        ],
      ),
    );
  }
}
