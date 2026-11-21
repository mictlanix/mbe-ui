import 'package:data_table_2/data_table_2.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/app_formatters.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/compact_field.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/fact_strip_row.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart' show toAppError;
import 'package:mbe_ui/core/widgets/record_id_text.dart';
import 'package:mbe_ui/core/widgets/responsive_form_grid.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_transfer.dart';
import 'package:mbe_ui/features/inventory/presentation/transfers/add_from_sales_order_dialog.dart';
import 'package:mbe_ui/features/inventory/presentation/transfers/add_transfer_line_dialog.dart';
import 'package:mbe_ui/features/inventory/presentation/transfers/inventory_transfer_detail_controller.dart';
import 'package:mbe_ui/features/inventory/presentation/transfers/inventory_transfer_status_chip.dart';
import 'package:mbe_ui/features/inventory/presentation/transfers/inventory_transfers_list_screen.dart';
import 'package:mbe_ui/features/inventory/presentation/transfers/receive_transfer_dialog.dart';
import 'package:mbe_ui/features/inventory/presentation/transfers/transfer_dialogs.dart';
import 'package:mbe_ui/features/inventory/presentation/transfers/transfer_header_dialog.dart';
import 'package:mbe_ui/features/inventory/presentation/shared/inventory_name_cells.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// One warehouse transfer (spec 068 contracts/ui-contract.md "Detail screen"):
/// the header facts, the lines and the action area.
///
/// A full screen with its own address, because an transfer owns lines (§VI
/// document reading). `AppBar.actions` stays empty; every action is in the
/// body. A draft is edited in place; any other transfer is read-only.
class InventoryTransferDetailScreen extends ConsumerWidget {
  /// [transferId] is `null` for an address whose id isn't a number, which shows
  /// the not-found state instead of throwing.
  const InventoryTransferDetailScreen({super.key, required this.transferId});

  final int? transferId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final id = transferId;
    if (id == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.navInventoryTransfers)),
        body: const _NotFound(),
      );
    }
    final detail = ref.watch(inventoryTransferDetailControllerProvider(id));
    final transfer = detail.value;

    return Scaffold(
      appBar: AppBar(
        // A draft has no folio yet.
        title: Text(
          transfer == null
              ? l10n.navInventoryTransfers
              : transfer.serial == null
              ? l10n.inventoryTransferTitleDraft('${transfer.id}')
              : l10n.inventoryTransferTitle('${transfer.serial}'),
        ),
      ),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => error is NotFoundError
            ? const _NotFound()
            : _LoadFailed(
                error: toAppError(error),
                onRetry: () => ref.invalidate(
                  inventoryTransferDetailControllerProvider(id),
                ),
              ),
        data: (transfer) => _TransferBody(transfer: transfer),
      ),
    );
  }
}

/// Back to the list: pops when the list is underneath, otherwise goes there.
void _backToList(BuildContext context) =>
    context.canPop() ? context.pop() : context.go(inventoryTransfersPath);

class _NotFound extends StatelessWidget {
  const _NotFound();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    return Padding(
      padding: EdgeInsets.all(spacing.screenMargin),
      child: Column(
        key: const Key('inventory_transfer_not_found'),
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.fieldGapVertical,
        children: [
          const ErrorBanner(error: AppError.notFound()),
          OutlinedButton(
            key: const Key('inventory_transfer_back_to_list'),
            onPressed: () => _backToList(context),
            child: Text(l10n.inventoryTransferBackToList),
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
        key: const Key('inventory_transfer_load_failed'),
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.fieldGapVertical,
        children: [
          ErrorBanner(error: error),
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            children: [
              OutlinedButton(
                key: const Key('inventory_transfer_back_to_list'),
                onPressed: () => _backToList(context),
                child: Text(l10n.inventoryTransferBackToList),
              ),
              FilledButton(
                key: const Key('inventory_transfer_retry_button'),
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

/// The loaded transfer, as a column of sections: facts, lines, refusal,
/// action area.
///
/// Stateful so a refusal survives the reload a write triggers: every write
/// goes through `InventoryTransferActions`, which puts the returned transfer
/// into the detail provider, so this body is rebuilt with it.
class _TransferBody extends ConsumerStatefulWidget {
  const _TransferBody({required this.transfer});

  final InventoryTransfer transfer;

  @override
  ConsumerState<_TransferBody> createState() => _TransferBodyState();
}

class _TransferBodyState extends ConsumerState<_TransferBody> {
  /// The last action's refusal, shown above the action area.
  AppError? _actionError;

  InventoryTransfer get _transfer => widget.transfer;

  Future<void> _dispatch() async {
    setState(() => _actionError = null);
    final result = await showDispatchTransferDialog(context, _transfer);
    if (!mounted || result == null) return;
    setState(() => _actionError = result.error);
  }

  /// The product code for an `inventory_document.insufficient_stock`
  /// refusal, whose params name the product only by id (research R6). The
  /// shared message stays generic; this enrichment is the screen's.
  // simplified: the lookup covers only this transfer's lines, which is every
  // product a dispatch or cancel refusal can name; should another action
  // raise it for a product not on the transfer, the code falls back to
  // "#{id}".
  String? _refusalProductCode(AppError error) {
    final problem = error.problem;
    if (problem?.code !=
        api.ErrorCode.inventoryDocumentPeriodInsufficientStock) {
      return null;
    }
    final productId = problem!.intParam('product_id');
    if (productId == null) return null;
    for (final line in _transfer.lines) {
      if (line.productId == productId) {
        return line.productCode ?? '#$productId';
      }
    }
    return '#$productId';
  }

  Future<void> _addProduct() async {
    setState(() => _actionError = null);
    await showAddTransferLineDialog(context, transferId: _transfer.id);
  }

  Future<void> _receive() async {
    setState(() => _actionError = null);
    final result = await showReceiveTransferDialog(context, _transfer);
    if (!mounted || result == null) return;
    setState(() => _actionError = result.error);
  }

  Future<void> _close() async {
    setState(() => _actionError = null);
    final result = await showCloseTransferDialog(context, _transfer);
    if (!mounted || result == null) return;
    setState(() => _actionError = result.error);
  }

  Future<void> _cancel() async {
    setState(() => _actionError = null);
    final result = await showCancelTransferDialog(context, _transfer);
    if (!mounted || result == null) return;
    setState(() => _actionError = result.error);
  }

  Future<void> _editHeader() async {
    setState(() => _actionError = null);
    await showTransferHeaderDialog(context, _transfer);
  }

  Future<void> _addFromOrder() async {
    setState(() => _actionError = null);
    final added = await showAddFromSalesOrderDialog(
      context,
      transferId: _transfer.id,
    );
    if (!mounted || added == null) return;
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          added == 0
              ? l10n.inventoryTransferFromOrderNone
              : l10n.inventoryTransferFromOrderAdded(added),
        ),
      ),
    );
  }

  Future<void> _editLine(InventoryTransferLine line) async {
    setState(() => _actionError = null);
    await showTransferLineQuantityDialog(
      context,
      transferId: _transfer.id,
      line: line,
    );
  }

  Future<void> _removeLine(InventoryTransferLine line) async {
    setState(() => _actionError = null);
    await showRemoveTransferLineDialog(
      context,
      transferId: _transfer.id,
      line: line,
    );
  }

  /// The action area, left to right (ui-contract "Action area"). Each
  /// control follows data-model "Action availability" and is absent, never
  /// disabled, without its right: a `null` callback builds nothing. Later
  /// stories add their buttons at their place in this order: Cancelar and
  /// Cerrar pendiente first, Editar encabezado and Agregar desde pedido
  /// before Agregar producto, Recibir last.
  List<Widget> _actionButtons({
    VoidCallback? onCancel,
    VoidCallback? onClose,
    VoidCallback? onEditHeader,
    VoidCallback? onAddFromOrder,
    VoidCallback? onAddProduct,
    VoidCallback? onDispatch,
    VoidCallback? onReceive,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final error = Theme.of(context).colorScheme.error;
    return [
      // InventoryTransfers (17) delete on a transfer that isn't cancelled.
      if (onCancel != null)
        OutlinedButton(
          key: const Key('inventory_transfer_cancel'),
          style: OutlinedButton.styleFrom(
            foregroundColor: error,
            side: BorderSide(color: error),
          ),
          onPressed: onCancel,
          child: Text(l10n.inventoryTransferCancel),
        ),
      // InventoryTransfers (17) delete on an in-transit transfer.
      if (onClose != null)
        OutlinedButton(
          key: const Key('inventory_transfer_close'),
          onPressed: onClose,
          child: Text(l10n.inventoryTransferClose),
        ),
      // InventoryTransfers (17) update on a draft.
      if (onEditHeader != null)
        OutlinedButton(
          key: const Key('inventory_transfer_edit_header'),
          onPressed: onEditHeader,
          child: Text(l10n.inventoryTransferEditHeader),
        ),
      // InventoryTransfers (17) update on a draft, plus SalesOrders (7) read.
      if (onAddFromOrder != null)
        OutlinedButton(
          key: const Key('inventory_transfer_add_from_order'),
          onPressed: onAddFromOrder,
          child: Text(l10n.inventoryTransferAddFromOrder),
        ),
      // InventoryTransfers (17) update on a draft, plus Products read for
      // the picker.
      if (onAddProduct != null)
        OutlinedButton.icon(
          key: const Key('inventory_transfer_add_product'),
          onPressed: onAddProduct,
          icon: Icon(CatalogAction.create.icon),
          label: Text(l10n.inventoryTransferAddProduct),
        ),
      // InventoryTransfers (17) update on a draft.
      if (onDispatch != null)
        FilledButton(
          key: const Key('inventory_transfer_dispatch'),
          onPressed: onDispatch,
          child: Text(l10n.inventoryTransferDispatch),
        ),
      // InventoryTransfers (17) update on an in-transit transfer.
      if (onReceive != null)
        FilledButton(
          key: const Key('inventory_transfer_receive'),
          onPressed: onReceive,
          child: Text(l10n.inventoryTransferReceive),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final access = ref.watch(accessControlProvider);
    final transfer = _transfer;
    // InventoryTransfers (17) update: lines and header are editable only on
    // a draft.
    final canEdit =
        transfer.isDraft &&
        access.can(SystemObject.inventoryTransfers, AccessRight.update);
    final canUpdate = access.can(
      SystemObject.inventoryTransfers,
      AccessRight.update,
    );
    final canDelete = access.can(
      SystemObject.inventoryTransfers,
      AccessRight.delete,
    );
    final buttons = _actionButtons(
      onCancel:
          canDelete && transfer.status != InventoryTransferStatus.cancelled
          ? _cancel
          : null,
      onClose: canDelete && transfer.isInTransit ? _close : null,
      onEditHeader: canEdit ? _editHeader : null,
      onAddFromOrder:
          canEdit && access.can(SystemObject.salesOrders, AccessRight.read)
          ? _addFromOrder
          : null,
      onAddProduct:
          canEdit && access.can(SystemObject.products, AccessRight.read)
          ? _addProduct
          : null,
      onDispatch: canEdit ? _dispatch : null,
      onReceive: canUpdate && transfer.isInTransit ? _receive : null,
    );
    final actionError = _actionError;
    final refusalProduct = actionError == null
        ? null
        : _refusalProductCode(actionError);
    // The warehouse the refusal names, from its own `warehouse_id` param: on
    // a cancel it can be the destination, so the transfer's own origin would
    // be wrong (research R6).
    final refusalWarehouseId = refusalProduct == null
        ? null
        : actionError!.problem?.intParam('warehouse_id');
    final refusalWarehouse = refusalWarehouseId == null
        ? null
        : ref.watch(warehouseDisplayNameProvider(refusalWarehouseId)).value ??
              '#$refusalWarehouseId';

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.screenMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.sectionGap,
        children: [
          _HeaderFacts(transfer: transfer),
          _LinesSection(
            transfer: transfer,
            onEditLine: canEdit ? _editLine : null,
            onRemoveLine: canEdit ? _removeLine : null,
          ),
          if (actionError != null)
            Column(
              key: const Key('inventory_transfer_refusal'),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: spacing.xs,
              children: [
                ErrorBanner(error: actionError),
                if (refusalProduct != null && refusalWarehouse != null)
                  Text(
                    l10n.inventoryTransferRefusalProductWarehouse(
                      refusalProduct,
                      refusalWarehouse,
                    ),
                    key: const Key('inventory_transfer_refusal_product'),
                  ),
              ],
            ),
          if (buttons.isNotEmpty)
            Align(
              key: const Key('inventory_transfer_actions'),
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

/// The header: Estado, Folio, Origen, Destino and Sucursal on one strip,
/// then the notes and who created and last changed it.
class _HeaderFacts extends ConsumerWidget {
  const _HeaderFacts({required this.transfer});

  final InventoryTransfer transfer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final fmt = ref.watch(formattersProvider);
    final comment = transfer.comment;

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
          key: const Key('inventory_transfer_facts'),
          facts: [
            CompactField(
              label: l10n.inventoryTransferFactStatus,
              child: InventoryTransferStatusChip(status: transfer.status),
            ),
            CompactField(
              label: l10n.inventoryTransferFactFolio,
              child: RecordIdText(
                transfer.serial == null
                    ? emptyValuePlaceholder
                    : '${transfer.serial}',
                key: const Key('inventory_transfer_serial'),
              ),
            ),
            CompactField(
              label: l10n.inventoryTransferFactSource,
              child: InventoryWarehouseName(warehouseId: transfer.warehouseId),
            ),
            CompactField(
              label: l10n.inventoryTransferFactDestination,
              child: InventoryWarehouseName(
                warehouseId: transfer.warehouseToId,
              ),
            ),
            CompactField(
              label: l10n.inventoryTransferFactFacility,
              child: InventoryFacilityName(facilityId: transfer.facilityId),
            ),
          ],
          trailing: const SizedBox.shrink(),
        ),
        ResponsiveFormGrid(
          key: const Key('inventory_transfer_detail_band'),
          spacing: spacing.fieldGapHorizontal,
          alignment: AlignmentDirectional.centerStart.resolve(
            Directionality.of(context),
          ),
          children: [
            FormGridChild(
              CompactField(
                label: l10n.inventoryTransferFactNotes,
                child: Text(
                  comment == null || comment.isEmpty
                      ? emptyValuePlaceholder
                      : comment,
                  key: const Key('inventory_transfer_comment'),
                ),
              ),
            ),
            FormGridChild(
              CompactField(
                label: l10n.inventoryTransferFactCreatedBy,
                child: byAt(transfer.creatorId, transfer.createdAt),
              ),
            ),
            FormGridChild(
              CompactField(
                label: l10n.inventoryTransferFactModifiedBy,
                child: byAt(transfer.updaterId, transfer.modifiedAt),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// The lines. A transfer with no folio (a draft, or a cancelled draft) shows
/// Código, Producto, Cantidad, with ✎ (quantity) and 🗑 (remove) on each row
/// of an editable draft. A dispatched one shows Código, Producto, Enviado,
/// Recibido, Pendiente and no row actions (research R10).
class _LinesSection extends ConsumerWidget {
  const _LinesSection({
    required this.transfer,
    this.onEditLine,
    this.onRemoveLine,
  });

  final InventoryTransfer transfer;

  /// Each `null` hides its row icon.
  final void Function(InventoryTransferLine line)? onEditLine;
  final void Function(InventoryTransferLine line)? onRemoveLine;

  /// ✎ and 🗑 for [line], or none when the lines aren't editable.
  List<Widget> _lineActions(AppLocalizations l10n, InventoryTransferLine line) {
    final onEdit = onEditLine;
    final onRemove = onRemoveLine;
    if (onEdit == null || onRemove == null) return const [];
    return buildCatalogRowActions(
      editTooltip: l10n.inventoryTransferLineEditTooltip,
      editKey: Key('inventory_transfer_line_edit_${line.id}'),
      onEdit: () => onEdit(line),
      extraActions: [
        CatalogRowAction(
          key: Key('inventory_transfer_line_remove_${line.id}'),
          icon: Icons.delete_outline,
          tooltip: l10n.inventoryTransferLineRemoveTooltip,
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
    final lines = transfer.lines;

    DataTableColumn<InventoryTransferLine> quantityColumn(
      String label,
      String keyPrefix,
      Decimal Function(InventoryTransferLine line) value,
    ) => DataTableColumn(
      label: label,
      numeric: true,
      size: ColumnSize.S,
      cellBuilder: (context, line) => Text(
        fmt.display.quantity(value(line).toString()),
        key: Key('${keyPrefix}_${line.id}'),
      ),
    );

    return Column(
      key: const Key('inventory_transfer_lines'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: spacing.sm,
      children: [
        Text(
          l10n.inventoryTransferLinesTitle,
          style: theme.textTheme.titleMedium,
        ),
        if (lines.isEmpty && transfer.isDraft)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: spacing.lg),
              child: Text(
                l10n.inventoryTransferLinesEmpty,
                key: const Key('inventory_transfer_lines_empty'),
              ),
            ),
          )
        else
          DataTableView<InventoryTransferLine>(
            key: const Key('inventory_transfer_lines_table'),
            shrinkWrap: true,
            margin: EdgeInsets.zero,
            rows: lines,
            rowActionsBuilder: onEditLine == null
                ? null
                : (context, line) => _lineActions(l10n, line),
            columns: [
              DataTableColumn.text(
                label: l10n.inventoryTransferLineColCode,
                size: ColumnSize.S,
                text: (line) => line.productCode ?? emptyValuePlaceholder,
              ),
              DataTableColumn.text(
                label: l10n.inventoryTransferLineColProduct,
                size: ColumnSize.L,
                text: (line) => line.productName ?? emptyValuePlaceholder,
              ),
              if (transfer.isDispatched) ...[
                quantityColumn(
                  l10n.inventoryTransferLineColSent,
                  'inventory_transfer_line_sent',
                  (line) => line.quantity,
                ),
                quantityColumn(
                  l10n.inventoryTransferLineColReceived,
                  'inventory_transfer_line_received',
                  (line) => line.quantityReceived,
                ),
                quantityColumn(
                  l10n.inventoryTransferLineColOutstanding,
                  'inventory_transfer_line_outstanding',
                  (line) => line.quantityOutstanding,
                ),
              ] else
                quantityColumn(
                  l10n.inventoryTransferLineColQuantity,
                  'inventory_transfer_line_quantity',
                  (line) => line.quantity,
                ),
            ],
          ),
      ],
    );
  }
}
