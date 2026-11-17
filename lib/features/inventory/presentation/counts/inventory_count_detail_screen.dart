import 'dart:math' as math;

import 'package:data_table_2/data_table_2.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/app_formatters.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/core/widgets/catalog_search_bar.dart';
import 'package:mbe_ui/core/widgets/compact_field.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/fact_strip_row.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart' show toAppError;
import 'package:mbe_ui/core/widgets/responsive_form_grid.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_count.dart';
import 'package:mbe_ui/features/inventory/presentation/counts/add_count_line_dialog.dart';
import 'package:mbe_ui/features/inventory/presentation/counts/count_confirm_notice.dart';
import 'package:mbe_ui/features/inventory/presentation/counts/count_dialogs.dart';
import 'package:mbe_ui/features/inventory/presentation/counts/count_header_dialog.dart';
import 'package:mbe_ui/features/inventory/presentation/counts/count_paste_dialog.dart';
import 'package:mbe_ui/features/inventory/presentation/counts/count_quick_entry.dart';
import 'package:mbe_ui/features/inventory/presentation/counts/inventory_count_actions.dart';
import 'package:mbe_ui/features/inventory/presentation/counts/inventory_count_detail_controller.dart';
import 'package:mbe_ui/features/inventory/presentation/counts/inventory_count_status_chip.dart';
import 'package:mbe_ui/features/inventory/presentation/counts/inventory_counts_list_screen.dart';
import 'package:mbe_ui/features/inventory/presentation/shared/inventory_name_cells.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// One physical count (spec 070 contracts/ui-contract.md "Detail screen"):
/// the header facts, the lines and the action area.
///
/// A full screen with its own address, because a count owns lines (§VI
/// document reading). `AppBar.actions` stays empty; every action is in the
/// body. A draft is edited in place and is blind: no expected stock and no
/// difference is shown until the count is completed (SC-003).
class InventoryCountDetailScreen extends ConsumerWidget {
  /// [countId] is `null` for an address whose id isn't a number, which shows
  /// the not-found state instead of throwing.
  const InventoryCountDetailScreen({super.key, required this.countId});

  final int? countId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final id = countId;
    if (id == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.navInventoryCounts)),
        body: const _NotFound(),
      );
    }
    final detail = ref.watch(inventoryCountDetailControllerProvider(id));
    final count = detail.value;

    return Scaffold(
      appBar: AppBar(
        // Only a completed count has a folio; a cancelled one was a draft
        // and keeps the draft title (FR-004a).
        title: Text(
          count == null
              ? l10n.navInventoryCounts
              : count.isCompleted && count.serial != null
              ? l10n.inventoryCountTitle('${count.serial}')
              : l10n.inventoryCountTitleDraft('${count.id}'),
        ),
      ),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => error is NotFoundError
            ? const _NotFound()
            : _LoadFailed(
                error: toAppError(error),
                onRetry: () =>
                    ref.invalidate(inventoryCountDetailControllerProvider(id)),
              ),
        data: (count) => _CountBody(count: count),
      ),
    );
  }
}

/// Back to the list: pops when the list is underneath, otherwise goes there.
void _backToList(BuildContext context) =>
    context.canPop() ? context.pop() : context.go(inventoryCountsPath);

class _NotFound extends StatelessWidget {
  const _NotFound();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    return Padding(
      padding: EdgeInsets.all(spacing.screenMargin),
      child: Column(
        key: const Key('inventory_count_not_found'),
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.fieldGapVertical,
        children: [
          const ErrorBanner(error: AppError.notFound()),
          OutlinedButton(
            key: const Key('inventory_count_back_to_list'),
            onPressed: () => _backToList(context),
            child: Text(l10n.inventoryCountBackToList),
          ),
        ],
      ),
    );
  }
}

class _LoadFailed extends StatelessWidget {
  const _LoadFailed({required this.error, required this.onRetry});

  final AppError error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    return Padding(
      padding: EdgeInsets.all(spacing.screenMargin),
      child: Column(
        key: const Key('inventory_count_load_failed'),
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.fieldGapVertical,
        children: [
          ErrorBanner(error: error),
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            children: [
              OutlinedButton(
                key: const Key('inventory_count_back_to_list'),
                onPressed: () => _backToList(context),
                child: Text(l10n.inventoryCountBackToList),
              ),
              FilledButton(
                key: const Key('inventory_count_retry_button'),
                onPressed: onRetry,
                child: Text(l10n.retryButton),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The loaded count, as a column of sections: facts, lines, refusal, action
/// area.
///
/// Stateful so a refusal survives the reload a write triggers: every write
/// goes through `InventoryCountActions`, which puts the returned count into
/// the detail provider, so this body is rebuilt with it.
class _CountBody extends ConsumerStatefulWidget {
  const _CountBody({required this.count});

  final InventoryCount count;

  @override
  ConsumerState<_CountBody> createState() => _CountBodyState();
}

class _CountBodyState extends ConsumerState<_CountBody> {
  /// The last action's refusal, shown above the action area.
  AppError? _actionError;

  /// A confirm or cancel is in flight: both are disabled meanwhile, so
  /// neither can be sent twice.
  bool _busy = false;

  InventoryCount get _count => widget.count;

  Future<void> _confirm() async {
    setState(() => _actionError = null);
    final warehouseId = _count.warehouseId;
    final warehouse =
        ref.read(warehouseDisplayNameProvider(warehouseId)).value ??
        '#$warehouseId';
    final includeUncounted = await showConfirmCountDialog(
      context,
      warehouse: warehouse,
    );
    if (!mounted || includeUncounted == null || _busy) return;
    final id = _count.id;
    setState(() => _busy = true);
    final outcome = await ref
        .read(inventoryCountActionsProvider.notifier)
        .confirm(id, includeUncounted: includeUncounted);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _actionError = outcome.error;
    });
    // FR-013: the server returns the warnings only here, so the notice
    // holds them for this screen session (research R9).
    if (!outcome.warnings.isEmpty) {
      ref.read(countConfirmNoticeProvider(id).notifier).show(outcome.warnings);
    }
  }

  Future<void> _cancel() async {
    setState(() => _actionError = null);
    final accepted = await showCancelCountDialog(context, countId: _count.id);
    if (!mounted || !accepted || _busy) return;
    setState(() => _busy = true);
    final error = await ref
        .read(inventoryCountActionsProvider.notifier)
        .cancel(_count.id);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _actionError = error;
    });
  }

  Future<void> _editHeader() async {
    setState(() => _actionError = null);
    await showCountHeaderDialog(context, _count);
  }

  Future<void> _addProduct() async {
    setState(() => _actionError = null);
    await showAddCountLineDialog(
      context,
      countId: _count.id,
      lines: _count.lines,
    );
  }

  Future<void> _paste() async {
    setState(() => _actionError = null);
    await showCountPasteDialog(context, countId: _count.id);
  }

  Future<void> _editLine(InventoryCountLine line) async {
    setState(() => _actionError = null);
    await showCountLineQuantityDialog(context, countId: _count.id, line: line);
  }

  Future<void> _removeLine(InventoryCountLine line) async {
    setState(() => _actionError = null);
    await showRemoveCountLineDialog(context, countId: _count.id, line: line);
  }

  /// The action area, left to right (ui-contract "Action area"). Each
  /// follows data-model "Action availability" and is absent, never
  /// disabled, without its right.
  List<Widget> _actionButtons({
    required bool canEdit,
    required bool canCancel,
    required bool canReadProducts,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final error = Theme.of(context).colorScheme.error;
    return [
      // PhysicalCountAdjustment (74) delete, on a draft only: a completed
      // count can't be cancelled (FR-014).
      if (canCancel)
        OutlinedButton(
          key: const Key('inventory_count_cancel'),
          style: OutlinedButton.styleFrom(
            foregroundColor: error,
            side: BorderSide(color: error),
          ),
          onPressed: _busy ? null : _cancel,
          child: Text(l10n.inventoryCountActionCancel),
        ),
      // PhysicalCountAdjustment (74) update on a draft.
      if (canEdit)
        OutlinedButton(
          key: const Key('inventory_count_edit_header'),
          onPressed: _editHeader,
          child: Text(l10n.inventoryCountActionEditHeader),
        ),
      // PhysicalCountAdjustment (74) update on a draft.
      if (canEdit)
        OutlinedButton.icon(
          key: const Key('inventory_count_paste'),
          onPressed: _paste,
          icon: const Icon(Icons.content_paste),
          label: Text(l10n.inventoryCountActionPaste),
        ),
      // PhysicalCountAdjustment (74) update on a draft, plus Products (2)
      // read for the picker.
      if (canEdit && canReadProducts)
        OutlinedButton.icon(
          key: const Key('inventory_count_add_product'),
          onPressed: _addProduct,
          icon: Icon(CatalogAction.create.icon),
          label: Text(l10n.inventoryCountActionAddProduct),
        ),
      // PhysicalCountAdjustment (74) update on a draft.
      if (canEdit)
        FilledButton(
          key: const Key('inventory_count_confirm'),
          onPressed: _busy ? null : _confirm,
          child: Text(l10n.inventoryCountActionConfirm),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).spacing;
    final access = ref.watch(accessControlProvider);
    final count = _count;
    // PhysicalCountAdjustment (74) update: lines and header are editable
    // only on a draft.
    final canEdit =
        count.isDraft &&
        access.can(SystemObject.physicalCountAdjustment, AccessRight.update);
    final buttons = _actionButtons(
      canEdit: canEdit,
      // PhysicalCountAdjustment (74) delete.
      canCancel:
          count.isDraft &&
          access.can(SystemObject.physicalCountAdjustment, AccessRight.delete),
      canReadProducts: access.can(SystemObject.products, AccessRight.read),
    );
    final actionError = _actionError;
    final warnings = ref.watch(countConfirmNoticeProvider(count.id));

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.screenMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.sectionGap,
        children: [
          _HeaderFacts(count: count),
          // PhysicalCountAdjustment (74) update on a draft.
          if (canEdit) CountQuickEntry(count: count),
          if (!warnings.isEmpty)
            CountWarningsBand(
              warnings: warnings,
              onClose: () => ref
                  .read(countConfirmNoticeProvider(count.id).notifier)
                  .dismiss(),
            ),
          _LinesSection(
            count: count,
            onEditLine: canEdit ? _editLine : null,
            onRemoveLine: canEdit ? _removeLine : null,
          ),
          if (actionError != null)
            ErrorBanner(
              key: const Key('inventory_count_refusal'),
              error: actionError,
            ),
          if (buttons.isNotEmpty)
            Align(
              key: const Key('inventory_count_actions'),
              alignment: AlignmentDirectional.centerEnd,
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: spacing.sm,
                runSpacing: spacing.sm,
                children: buttons,
              ),
            ),
        ],
      ),
    );
  }
}

/// The header: Estado, Folio, Almacén and Sucursal on one strip, then the
/// comment, the line count and who created and last changed it.
class _HeaderFacts extends ConsumerWidget {
  const _HeaderFacts({required this.count});

  final InventoryCount count;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final fmt = ref.watch(formattersProvider);
    final comment = count.comment;

    Widget byAt(int employeeId, DateTime at) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: InventoryEmployeeName(employeeId: employeeId)),
        Text(' · ${fmt.display.dateTime(at)}'),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: spacing.fieldGapVertical,
      children: [
        FactStripRow(
          key: const Key('inventory_count_facts'),
          facts: [
            CompactField(
              label: l10n.inventoryCountColStatus,
              child: InventoryCountStatusChip(status: count.status),
            ),
            CompactField(
              label: l10n.inventoryCountColFolio,
              child: Text(
                count.serial == null
                    ? emptyValuePlaceholder
                    : '${count.serial}',
                key: const Key('inventory_count_serial'),
              ),
            ),
            CompactField(
              label: l10n.inventoryCountColWarehouse,
              child: InventoryWarehouseName(warehouseId: count.warehouseId),
            ),
            CompactField(
              label: l10n.inventoryCountColFacility,
              child: InventoryFacilityName(facilityId: count.facilityId),
            ),
          ],
          trailing: const SizedBox.shrink(),
        ),
        ResponsiveFormGrid(
          key: const Key('inventory_count_detail_band'),
          spacing: spacing.fieldGapHorizontal,
          alignment: AlignmentDirectional.centerStart.resolve(
            Directionality.of(context),
          ),
          children: [
            FormGridChild(
              CompactField(
                label: l10n.inventoryCountFactComment,
                child: Text(
                  comment == null || comment.isEmpty
                      ? emptyValuePlaceholder
                      : comment,
                  key: const Key('inventory_count_comment'),
                ),
              ),
            ),
            FormGridChild(
              CompactField(
                label: l10n.inventoryCountFactLines,
                child: Text(
                  fmt.display.count(count.lines.length),
                  key: const Key('inventory_count_line_count'),
                ),
              ),
            ),
            FormGridChild(
              CompactField(
                label: l10n.inventoryCountColCreatedBy,
                child: byAt(count.creatorId, count.createdAt),
              ),
            ),
            FormGridChild(
              CompactField(
                label: l10n.inventoryCountFactModifiedBy,
                child: byAt(count.updaterId, count.updatedAt),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// The lines: a search over the loaded lines, then Código, Producto,
/// Contado, plus Esperado and Diferencia once the count is completed. On an
/// editable draft each row has ✎ (quantity) and 🗑 (remove).
///
/// Paged in memory (research R5), as `privileges_grid.dart` does: the
/// server returns every line at once.
// simplified: the whole count is held in memory, a count of ~15,000 lines is
// fine; if counts grow past that, page on the server.
class _LinesSection extends ConsumerStatefulWidget {
  const _LinesSection({
    required this.count,
    this.onEditLine,
    this.onRemoveLine,
  });

  final InventoryCount count;

  /// Each `null` hides its row icon.
  final void Function(InventoryCountLine line)? onEditLine;
  final void Function(InventoryCountLine line)? onRemoveLine;

  @override
  ConsumerState<_LinesSection> createState() => _LinesSectionState();
}

class _LinesSectionState extends ConsumerState<_LinesSection> {
  static const _pageSize = 100;

  String _search = '';
  int _pageIndex = 0;

  /// The lines whose code or name contains the search, ignoring case.
  List<InventoryCountLine> _filtered() {
    final term = _search.trim().toLowerCase();
    final lines = widget.count.lines;
    if (term.isEmpty) return lines;
    return [
      for (final line in lines)
        if (line.productCode.toLowerCase().contains(term) ||
            line.productName.toLowerCase().contains(term))
          line,
    ];
  }

  /// ✎ and 🗑 for [line], or none when the lines aren't editable.
  List<Widget> _lineActions(AppLocalizations l10n, InventoryCountLine line) {
    final onEdit = widget.onEditLine;
    final onRemove = widget.onRemoveLine;
    if (onEdit == null || onRemove == null) return const [];
    return buildCatalogRowActions(
      editTooltip: l10n.inventoryCountLineEditTooltip,
      editKey: Key('inventory_count_line_edit_${line.id}'),
      onEdit: () => onEdit(line),
      extraActions: [
        CatalogRowAction(
          key: Key('inventory_count_line_remove_${line.id}'),
          icon: Icons.delete_outline,
          tooltip: l10n.inventoryCountLineRemoveTooltip,
          onPressed: () => onRemove(line),
        ),
      ],
    );
  }

  /// A signed difference: "+" ahead of a positive one (R13).
  String _signed(AppFormatters fmt, Decimal value) {
    final text = fmt.display.quantity(value.toString());
    return value > Decimal.zero ? '+$text' : text;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final fmt = ref.watch(formattersProvider);
    final count = widget.count;

    if (count.lines.isEmpty && count.isDraft) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: spacing.lg),
          child: Text(
            l10n.inventoryCountDraftEmpty,
            key: const Key('inventory_count_lines_empty'),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final filtered = _filtered();
    // A write keeps the current page while it still exists; past the end,
    // the last page.
    final lastPage = math.max(0, (filtered.length - 1) ~/ _pageSize);
    final pageIndex = math.min(_pageIndex, lastPage);
    final page = filtered.skip(pageIndex * _pageSize).take(_pageSize).toList();

    return Column(
      key: const Key('inventory_count_lines'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: spacing.sm,
      children: [
        CatalogSearchBar(
          key: const Key('count_lines_search'),
          label: l10n.inventoryCountLinesSearchHint,
          initialValue: _search,
          onSubmitted: (value) => setState(() {
            _search = value;
            _pageIndex = 0;
          }),
        ),
        DataTableView<InventoryCountLine>(
          key: const Key('inventory_count_lines_table'),
          shrinkWrap: true,
          margin: EdgeInsets.zero,
          rows: page,
          pagination: CatalogPage<InventoryCountLine>(
            items: page,
            total: filtered.length,
            pageIndex: pageIndex,
            pageSize: _pageSize,
          ),
          onPageChanged: (index) => setState(() => _pageIndex = index),
          rowActionsBuilder: widget.onEditLine == null
              ? null
              : (context, line) => _lineActions(l10n, line),
          columns: [
            DataTableColumn.text(
              label: l10n.inventoryCountLineColCode,
              size: ColumnSize.S,
              text: (line) => line.productCode.isEmpty
                  ? emptyValuePlaceholder
                  : line.productCode,
            ),
            DataTableColumn.text(
              label: l10n.inventoryCountLineColProduct,
              size: ColumnSize.L,
              text: (line) => line.productName.isEmpty
                  ? emptyValuePlaceholder
                  : line.productName,
            ),
            DataTableColumn(
              label: l10n.inventoryCountLineColCounted,
              numeric: true,
              size: ColumnSize.S,
              cellBuilder: (context, line) => Text(
                fmt.display.quantity(line.quantity.toString()),
                key: Key('inventory_count_line_quantity_${line.id}'),
              ),
            ),
            // Blind drafts (SC-003): the on-hand figure and the difference
            // are read only once the count is completed.
            if (count.isCompleted) ...[
              DataTableColumn(
                label: l10n.inventoryCountLineColExpected,
                numeric: true,
                size: ColumnSize.S,
                cellBuilder: (context, line) => Text(
                  fmt.display.quantity(line.quantityOnHand?.toString()),
                  key: Key('inventory_count_line_expected_${line.id}'),
                ),
              ),
              DataTableColumn(
                label: l10n.inventoryCountLineColDifference,
                numeric: true,
                size: ColumnSize.S,
                cellBuilder: (context, line) {
                  final difference = line.difference;
                  return Text(
                    difference == null
                        ? emptyValuePlaceholder
                        : _signed(fmt, difference),
                    key: Key('inventory_count_line_difference_${line.id}'),
                  );
                },
              ),
            ],
          ],
        ),
      ],
    );
  }
}
