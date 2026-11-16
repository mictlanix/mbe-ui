import 'package:data_table_2/data_table_2.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/app_formatters.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/compact_field.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/fact_strip_row.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart' show toAppError;
import 'package:mbe_ui/core/widgets/responsive_form_grid.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_receipt.dart';
import 'package:mbe_ui/features/inventory/domain/over_receipt.dart';
import 'package:mbe_ui/features/inventory/presentation/receipts/add_receipt_line_dialog.dart';
import 'package:mbe_ui/features/inventory/presentation/receipts/inventory_receipt_actions.dart';
import 'package:mbe_ui/features/inventory/presentation/receipts/inventory_receipt_detail_controller.dart';
import 'package:mbe_ui/features/inventory/presentation/shared/inventory_document_status_chip.dart';
import 'package:mbe_ui/features/inventory/presentation/receipts/inventory_receipts_list_screen.dart';
import 'package:mbe_ui/features/inventory/presentation/receipts/receipt_dialogs.dart';
import 'package:mbe_ui/features/inventory/presentation/receipts/receipt_header_dialog.dart';
import 'package:mbe_ui/features/inventory/presentation/shared/inventory_name_cells.dart';
import 'package:mbe_ui/features/inventory/presentation/receipts/receipt_warnings.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// One warehouse receipt (spec 067 contracts/ui-contract.md "Detail
/// screen"): the header facts, the lines and the action area.
///
/// A full screen with its own address, because a receipt owns lines (§VI
/// document reading). `AppBar.actions` stays empty; every action is in the
/// body. A draft is edited in place; any other receipt is read-only.
class InventoryReceiptDetailScreen extends ConsumerWidget {
  /// [receiptId] is `null` for an address whose id isn't a number, which
  /// shows the not-found state instead of throwing.
  const InventoryReceiptDetailScreen({super.key, required this.receiptId});

  final int? receiptId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final id = receiptId;
    if (id == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.navInventoryReceipts)),
        body: const _NotFound(),
      );
    }
    final detail = ref.watch(inventoryReceiptDetailControllerProvider(id));
    final receipt = detail.value;

    return Scaffold(
      appBar: AppBar(
        // FR-004a: a draft has no folio yet.
        title: Text(
          receipt == null
              ? l10n.navInventoryReceipts
              : receipt.serial == null
              ? l10n.inventoryReceiptTitleDraft('${receipt.id}')
              : l10n.inventoryReceiptTitle('${receipt.serial}'),
        ),
      ),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => error is NotFoundError
            ? const _NotFound()
            : _LoadFailed(
                error: toAppError(error),
                onRetry: () => ref.invalidate(
                  inventoryReceiptDetailControllerProvider(id),
                ),
              ),
        data: (receipt) => _ReceiptBody(receipt: receipt),
      ),
    );
  }
}

/// Back to the list: pops when the list is underneath, otherwise goes there.
void _backToList(BuildContext context) =>
    context.canPop() ? context.pop() : context.go(inventoryReceiptsPath);

class _NotFound extends StatelessWidget {
  const _NotFound();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    return Padding(
      padding: EdgeInsets.all(spacing.screenMargin),
      child: Column(
        key: const Key('inventory_receipt_not_found'),
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.fieldGapVertical,
        children: [
          const ErrorBanner(error: AppError.notFound()),
          OutlinedButton(
            key: const Key('inventory_receipt_back_to_list'),
            onPressed: () => _backToList(context),
            child: Text(l10n.inventoryReceiptBackToList),
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
        key: const Key('inventory_receipt_load_failed'),
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.fieldGapVertical,
        children: [
          ErrorBanner(error: error),
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            children: [
              OutlinedButton(
                key: const Key('inventory_receipt_back_to_list'),
                onPressed: () => _backToList(context),
                child: Text(l10n.inventoryReceiptBackToList),
              ),
              FilledButton(
                key: const Key('inventory_receipt_retry_button'),
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

/// The loaded receipt, as a column of sections: facts, lines, refusal,
/// action area.
///
/// Stateful so a refusal survives the reload a write triggers: every write
/// goes through `InventoryReceiptActions`, which puts the returned receipt
/// into the detail provider, so this body is rebuilt with it.
class _ReceiptBody extends ConsumerStatefulWidget {
  const _ReceiptBody({required this.receipt});

  final InventoryReceipt receipt;

  @override
  ConsumerState<_ReceiptBody> createState() => _ReceiptBodyState();
}

class _ReceiptBodyState extends ConsumerState<_ReceiptBody> {
  /// The last action's refusal, shown above the action area.
  AppError? _actionError;

  InventoryReceipt get _receipt => widget.receipt;

  Future<void> _confirm() async {
    setState(() => _actionError = null);
    _settled(await showConfirmReceiptDialog(context, _receipt));
  }

  Future<void> _cancel() async {
    setState(() => _actionError = null);
    _settled(await showCancelReceiptDialog(context, _receipt));
  }

  /// A confirm's or cancel's outcome: its refusal, or the cost notice when
  /// the server raised warnings beyond the over-receipts (FR-015a).
  void _settled(ReceiptSettled? result) {
    if (!mounted || result == null) return;
    setState(() => _actionError = result.error);
    if (result.hasUnmappedWarnings) {
      ref.read(receiptCostNoticeProvider(_receipt.id).notifier).show();
    }
  }

  Future<void> _editHeader() async {
    setState(() => _actionError = null);
    await showReceiptHeaderDialog(context, _receipt);
  }

  /// Opens the purchase order's complementary draft: the existing one (200)
  /// or a new one (201) alike (research R10).
  Future<void> _complementary() async {
    setState(() => _actionError = null);
    final result = await ref
        .read(inventoryReceiptActionsProvider.notifier)
        .complementary(_receipt.id);
    if (!mounted) return;
    final id = result.id;
    if (result.error != null || id == null) {
      setState(() => _actionError = result.error);
      return;
    }
    context.push('$inventoryReceiptsPath/$id');
  }

  /// "Producto: {code}" for an `inventory_document.insufficient_stock`
  /// refusal, whose params name the product only by id (research R7). The
  /// shared message stays generic; this enrichment is the screen's.
  // simplified: the lookup covers only this receipt's lines, which is every
  // product a cancel refusal can name; should another action raise it for a
  // product not on the receipt, the line is just left out.
  String? _refusalProductCode(AppError error) {
    final problem = error.problem;
    if (problem?.code !=
        api.ErrorCode.inventoryDocumentPeriodInsufficientStock) {
      return null;
    }
    final productId = problem!.intParam('product_id');
    for (final line in _receipt.lines) {
      if (line.productId == productId) {
        return line.productCode ?? '#${line.productId}';
      }
    }
    return null;
  }

  Future<void> _addProduct() async {
    setState(() => _actionError = null);
    await showAddReceiptLineDialog(context, receiptId: _receipt.id);
  }

  Future<void> _editLine(InventoryReceiptLine line) async {
    setState(() => _actionError = null);
    await showReceiptLineQuantityDialog(
      context,
      receiptId: _receipt.id,
      line: line,
    );
  }

  Future<void> _removeLine(InventoryReceiptLine line) async {
    setState(() => _actionError = null);
    await showRemoveReceiptLineDialog(
      context,
      receiptId: _receipt.id,
      line: line,
    );
  }

  /// The action area, left to right (ui-contract "Action area"): Cancelar,
  /// Entrada complementaria, Editar encabezado, Agregar producto, Confirmar.
  /// Each follows data-model "Action availability" and is absent, never
  /// disabled, without its right.
  List<Widget> _actionButtons({
    required bool canEdit,
    required bool canReadProducts,
    required bool canCancel,
    required bool canComplement,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final error = Theme.of(context).colorScheme.error;
    return [
      // InventoryReceipts (15) delete, on any receipt not yet cancelled.
      if (canCancel)
        OutlinedButton(
          key: const Key('inventory_receipt_cancel'),
          style: OutlinedButton.styleFrom(
            foregroundColor: error,
            side: BorderSide(color: error),
          ),
          onPressed: _cancel,
          child: Text(l10n.inventoryReceiptCancel),
        ),
      // InventoryReceipts (15) create, on a linked receipt not cancelled.
      if (canComplement)
        OutlinedButton(
          key: const Key('inventory_receipt_complementary'),
          onPressed: _complementary,
          child: Text(l10n.inventoryReceiptComplementary),
        ),
      // InventoryReceipts (15) update on a draft.
      if (canEdit)
        OutlinedButton(
          key: const Key('inventory_receipt_edit_header'),
          onPressed: _editHeader,
          child: Text(l10n.inventoryReceiptEditHeader),
        ),
      // InventoryReceipts (15) update on a draft, plus Products read for the
      // picker.
      if (canEdit && canReadProducts)
        OutlinedButton.icon(
          key: const Key('inventory_receipt_add_product'),
          onPressed: _addProduct,
          icon: Icon(CatalogAction.create.icon),
          label: Text(l10n.inventoryReceiptAddProduct),
        ),
      // InventoryReceipts (15) update on a draft.
      if (canEdit)
        FilledButton(
          key: const Key('inventory_receipt_confirm'),
          onPressed: _confirm,
          child: Text(l10n.inventoryReceiptConfirm),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).spacing;
    final access = ref.watch(accessControlProvider);
    final receipt = _receipt;
    // InventoryReceipts (15) update: lines and header are editable only on a
    // draft (FR-016).
    final canEdit =
        receipt.isDraft &&
        access.can(SystemObject.inventoryReceipts, AccessRight.update);
    final notCancelled = receipt.status != InventoryDocumentStatus.cancelled;
    final buttons = _actionButtons(
      canEdit: canEdit,
      canReadProducts: access.can(SystemObject.products, AccessRight.read),
      // InventoryReceipts (15) delete (FR-013).
      canCancel:
          notCancelled &&
          access.can(SystemObject.inventoryReceipts, AccessRight.delete),
      // InventoryReceipts (15) create (FR-014, FR-021).
      canComplement:
          notCancelled &&
          receipt.isLinked &&
          access.can(SystemObject.inventoryReceipts, AccessRight.create),
    );
    final showCostNotice = ref.watch(receiptCostNoticeProvider(receipt.id));
    // FR-015: never on a cancelled receipt.
    final overReceipts = notCancelled
        ? receipt.overReceipts
        : const <OverReceipt>[];
    final actionError = _actionError;
    final refusalProduct = actionError == null
        ? null
        : _refusalProductCode(actionError);

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.screenMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.sectionGap,
        children: [
          _HeaderFacts(receipt: receipt),
          if (showCostNotice)
            ReceiptCostNoticeBand(
              onClose: () => ref
                  .read(receiptCostNoticeProvider(receipt.id).notifier)
                  .dismiss(),
            ),
          if (overReceipts.isNotEmpty)
            ReceiptOverReceiptBand(overReceipts: overReceipts),
          _LinesSection(
            receipt: receipt,
            onEditLine: canEdit ? _editLine : null,
            onRemoveLine: canEdit ? _removeLine : null,
          ),
          if (actionError != null)
            Column(
              key: const Key('inventory_receipt_refusal'),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: spacing.xs,
              children: [
                ErrorBanner(error: actionError),
                if (refusalProduct != null)
                  Text(
                    AppLocalizations.of(
                      context,
                    )!.inventoryReceiptRefusalProduct(refusalProduct),
                    key: const Key('inventory_receipt_refusal_product'),
                  ),
              ],
            ),
          if (buttons.isNotEmpty)
            Align(
              key: const Key('inventory_receipt_actions'),
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

/// The header (FR-007): Estado, Folio, Almacén, Sucursal and the purchase
/// order on one strip, then the notes and who created and last changed it.
class _HeaderFacts extends ConsumerWidget {
  const _HeaderFacts({required this.receipt});

  final InventoryReceipt receipt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final fmt = ref.watch(formattersProvider);
    final comment = receipt.comment;

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
          key: const Key('inventory_receipt_facts'),
          facts: [
            CompactField(
              label: l10n.inventoryReceiptFactStatus,
              child: InventoryDocumentStatusChip(status: receipt.status),
            ),
            CompactField(
              label: l10n.inventoryReceiptFactFolio,
              child: Text(
                receipt.serial == null
                    ? emptyValuePlaceholder
                    : '${receipt.serial}',
                key: const Key('inventory_receipt_serial'),
              ),
            ),
            CompactField(
              label: l10n.inventoryReceiptFactWarehouse,
              child: InventoryWarehouseName(warehouseId: receipt.warehouseId),
            ),
            CompactField(
              label: l10n.inventoryReceiptFactFacility,
              child: InventoryFacilityName(facilityId: receipt.facilityId),
            ),
            if (receipt.purchaseOrderId != null)
              CompactField(
                label: l10n.inventoryReceiptFactPurchaseOrder,
                child: Text(
                  '${receipt.purchaseOrderId}',
                  key: const Key('inventory_receipt_purchase_order'),
                ),
              ),
          ],
          trailing: const SizedBox.shrink(),
        ),
        ResponsiveFormGrid(
          key: const Key('inventory_receipt_detail_band'),
          spacing: spacing.fieldGapHorizontal,
          alignment: AlignmentDirectional.centerStart.resolve(
            Directionality.of(context),
          ),
          children: [
            FormGridChild(
              CompactField(
                label: l10n.inventoryReceiptFactComment,
                child: Text(
                  comment == null || comment.isEmpty
                      ? emptyValuePlaceholder
                      : comment,
                  key: const Key('inventory_receipt_comment'),
                ),
              ),
            ),
            FormGridChild(
              CompactField(
                label: l10n.inventoryReceiptFactCreatedBy,
                child: byAt(receipt.creatorId, receipt.createdAt),
              ),
            ),
            FormGridChild(
              CompactField(
                label: l10n.inventoryReceiptFactModifiedBy,
                child: byAt(receipt.updaterId, receipt.modifiedAt),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// The lines (FR-008, FR-010): Código, Producto, Cantidad recibida, plus
/// Ordenado and Recibido en otras entradas on a linked receipt. On an
/// editable draft each row has ✎ (quantity) and 🗑 (remove).
class _LinesSection extends ConsumerWidget {
  const _LinesSection({
    required this.receipt,
    this.onEditLine,
    this.onRemoveLine,
  });

  final InventoryReceipt receipt;

  /// Each `null` hides its row icon (FR-016).
  final void Function(InventoryReceiptLine line)? onEditLine;
  final void Function(InventoryReceiptLine line)? onRemoveLine;

  /// ✎ and 🗑 for [line], or none when the lines aren't editable.
  List<Widget> _lineActions(AppLocalizations l10n, InventoryReceiptLine line) {
    final onEdit = onEditLine;
    final onRemove = onRemoveLine;
    if (onEdit == null || onRemove == null) return const [];
    return buildCatalogRowActions(
      editTooltip: l10n.inventoryReceiptLineEditTooltip,
      editKey: Key('inventory_receipt_line_edit_${line.id}'),
      onEdit: () => onEdit(line),
      extraActions: [
        CatalogRowAction(
          key: Key('inventory_receipt_line_remove_${line.id}'),
          icon: Icons.delete_outline,
          tooltip: l10n.inventoryReceiptLineRemoveTooltip,
          onPressed: () => onRemove(line),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final fmt = ref.watch(formattersProvider);
    final lines = receipt.lines;

    return Column(
      key: const Key('inventory_receipt_lines'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: spacing.sm,
      children: [
        Text(
          l10n.inventoryReceiptLinesTitle,
          style: theme.textTheme.titleMedium,
        ),
        if (lines.isEmpty && receipt.isDraft)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: spacing.lg),
              child: Text(
                l10n.inventoryReceiptLinesEmpty,
                key: const Key('inventory_receipt_lines_empty'),
              ),
            ),
          )
        else
          DataTableView<InventoryReceiptLine>(
            key: const Key('inventory_receipt_lines_table'),
            shrinkWrap: true,
            margin: EdgeInsets.zero,
            rows: lines,
            rowActionsBuilder: onEditLine == null
                ? null
                : (context, line) => _lineActions(l10n, line),
            columns: [
              DataTableColumn.text(
                label: l10n.inventoryReceiptLineColCode,
                size: ColumnSize.S,
                text: (line) => line.productCode ?? emptyValuePlaceholder,
              ),
              DataTableColumn.text(
                label: l10n.inventoryReceiptLineColProduct,
                size: ColumnSize.L,
                text: (line) => line.productName ?? emptyValuePlaceholder,
              ),
              DataTableColumn(
                label: l10n.inventoryReceiptLineColQuantity,
                numeric: true,
                size: ColumnSize.S,
                cellBuilder: (context, line) => Text(
                  fmt.display.quantity(line.quantity.toString()),
                  key: Key('inventory_receipt_line_quantity_${line.id}'),
                ),
              ),
              // FR-010: the purchase order's figures, only on a linked
              // receipt; a hand-added line has none.
              if (receipt.isLinked) ...[
                DataTableColumn(
                  label: l10n.inventoryReceiptLineColOrdered,
                  numeric: true,
                  size: ColumnSize.S,
                  cellBuilder: (context, line) => Text(
                    line.purchaseOrderLineId == null
                        ? emptyValuePlaceholder
                        : fmt.display.quantity(line.quantityOrdered.toString()),
                    key: Key('inventory_receipt_line_ordered_${line.id}'),
                  ),
                ),
                DataTableColumn(
                  label: l10n.inventoryReceiptLineColElsewhere,
                  numeric: true,
                  size: ColumnSize.S,
                  cellBuilder: (context, line) {
                    final elsewhere = line.quantityReceivedElsewhere;
                    return Text(
                      line.purchaseOrderLineId == null
                          ? emptyValuePlaceholder
                          : fmt.display.quantity(
                              (elsewhere ?? Decimal.zero).toString(),
                            ),
                      key: Key('inventory_receipt_line_elsewhere_${line.id}'),
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
