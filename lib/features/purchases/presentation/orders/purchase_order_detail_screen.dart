import 'package:data_table_2/data_table_2.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/documents/domain/document_kind.dart';
import 'package:mbe_ui/core/documents/domain/document_ref.dart';
import 'package:mbe_ui/core/documents/presentation/document_actions.dart';
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
import 'package:mbe_ui/features/inventory/presentation/shared/inventory_document_status_chip.dart';
import 'package:mbe_ui/features/inventory/presentation/shared/inventory_name_cells.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_order.dart';
import 'package:mbe_ui/features/purchases/domain/zero_price.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/add_order_line_dialog.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/add_request_lines_dialog.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/order_dialogs.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/order_header_dialog.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/order_line_dialog.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/order_receipts_section.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/order_warnings_band.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/purchase_order_actions.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/purchase_order_availability.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/purchase_order_detail_controller.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/purchase_order_email_dialog.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/purchase_request_serial.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The purchase orders list's address. Declared here, with the detail, and
/// kept here: the list screen, the router and `PurchaseOrderLink` import it.
const purchaseOrdersPath = '/purchases/orders';

/// One purchase order (spec 080 contracts/ui-contract.md "Orden de compra
/// detail"): the header facts, the totals, the price-0 band on a draft and
/// the lines. Gated by PurchasesOrders (SystemObject 20) read, at the route.
///
/// A full screen with its own address, because an order owns lines and
/// receipts (§VI document reading). `AppBar.actions` stays empty; every
/// action is in the body's action area.
class PurchaseOrderDetailScreen extends ConsumerWidget {
  /// [orderId] is `null` for an address whose id isn't a number, which shows
  /// the not-found state instead of throwing.
  const PurchaseOrderDetailScreen({super.key, required this.orderId});

  final int? orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final id = orderId;
    if (id == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.navPurchaseOrders)),
        body: const _NotFound(),
      );
    }
    final detail = ref.watch(purchaseOrderDetailControllerProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          detail.hasValue
              ? l10n.purchaseOrderTitle('$id')
              : l10n.navPurchaseOrders,
        ),
      ),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => error is NotFoundError
            ? const _NotFound()
            : _LoadFailed(
                error: toAppError(error),
                onRetry: () =>
                    ref.invalidate(purchaseOrderDetailControllerProvider(id)),
              ),
        data: (order) => _OrderBody(order: order),
      ),
    );
  }
}

/// Back to the list: pops when something is underneath, otherwise goes to
/// the list.
void _backToList(BuildContext context) =>
    context.canPop() ? context.pop() : context.go(purchaseOrdersPath);

class _NotFound extends StatelessWidget {
  const _NotFound();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    return Padding(
      padding: EdgeInsets.all(spacing.screenMargin),
      child: Column(
        key: const Key('purchase_order_not_found'),
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.fieldGapVertical,
        children: [
          const ErrorBanner(error: AppError.notFound()),
          OutlinedButton(
            key: const Key('purchase_order_back_to_list'),
            onPressed: () => _backToList(context),
            child: Text(l10n.purchaseOrderBackToList),
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
        key: const Key('purchase_order_load_failed'),
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.fieldGapVertical,
        children: [
          ErrorBanner(error: error),
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            children: [
              OutlinedButton(
                key: const Key('purchase_order_back_to_list'),
                onPressed: () => _backToList(context),
                child: Text(l10n.purchaseOrderBackToList),
              ),
              FilledButton(
                key: const Key('purchase_order_retry_button'),
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

/// The loaded order, as a column of sections: facts, receipts, price-0
/// band, lines, totals, then the refusal and the action area.
class _OrderBody extends ConsumerStatefulWidget {
  const _OrderBody({required this.order});

  final PurchaseOrder order;

  @override
  ConsumerState<_OrderBody> createState() => _OrderBodyState();
}

class _OrderBodyState extends ConsumerState<_OrderBody> {
  /// The last action's refusal, shown above the action area. The dialogs
  /// show their own refusals; Confirmar, Quitar and Cancelar orden, whose
  /// prompts only ask, report theirs here.
  AppError? _actionError;

  /// A confirm is in flight: Confirmar is disabled meanwhile.
  bool _confirming = false;

  /// A cancel is in flight: Cancelar orden is disabled meanwhile.
  bool _cancelling = false;

  PurchaseOrder get _order => widget.order;

  Future<void> _addRequest() async {
    setState(() => _actionError = null);
    await showAddRequestLinesDialog(context, orderId: _order.id);
  }

  Future<void> _addProduct() async {
    setState(() => _actionError = null);
    await showAddOrderLineDialog(context, orderId: _order.id);
  }

  Future<void> _editHeader() async {
    setState(() => _actionError = null);
    await showOrderHeaderDialog(context, _order);
  }

  Future<void> _editLine(PurchaseOrderLine line) async {
    setState(() => _actionError = null);
    await showOrderLineDialog(context, orderId: _order.id, line: line);
  }

  /// Asks, then removes [line] (FR-013). The returned order, with its new
  /// totals, replaces the one on screen.
  Future<void> _removeLine(PurchaseOrderLine line) async {
    setState(() => _actionError = null);
    if (!await showRemoveOrderLineDialog(context, line) || !mounted) return;
    final error = await ref
        .read(purchaseOrderActionsProvider.notifier)
        .removeLine(_order.id, line.id);
    if (!mounted) return;
    setState(() => _actionError = error);
  }

  /// Asks, then cancels the draft (FR-024): it stays on screen cancelled,
  /// read-only, with its lines. A `purchase_order.confirmed_cannot_cancel`
  /// refusal re-fetches it (`PurchaseOrderActions`).
  Future<void> _cancel() async {
    setState(() => _actionError = null);
    final order = _order;
    if (!await showCancelOrderDialog(context, order) || !mounted) return;
    setState(() => _cancelling = true);
    final error = await ref
        .read(purchaseOrderActionsProvider.notifier)
        .cancel(order.id);
    if (!mounted) return;
    setState(() {
      _cancelling = false;
      _actionError = error;
    });
  }

  /// Asks, then confirms (FR-021). On success the order on screen becomes
  /// the confirmed one with the receipts the server created (research R11);
  /// a stale refusal re-fetches it (`PurchaseOrderActions`).
  Future<void> _confirm() async {
    setState(() => _actionError = null);
    final order = _order;
    if (!await showConfirmOrderDialog(context, order) || !mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _confirming = true);
    final error = await ref
        .read(purchaseOrderActionsProvider.notifier)
        .confirm(order.id);
    if (!mounted) return;
    setState(() {
      _confirming = false;
      _actionError = error;
    });
    if (error != null) return;
    final receipts =
        ref
            .read(purchaseOrderDetailControllerProvider(order.id))
            .value
            ?.receipts
            .length ??
        0;
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.purchaseOrderConfirmedSnack(receipts))),
    );
  }

  /// Opens the order's PDF in the shared preview (FR-026, research R13).
  Future<void> _print() {
    final l10n = AppLocalizations.of(context)!;
    return ref
        .read(documentActionsProvider)
        .preview(
          context,
          DocumentRef(
            kind: DocumentKind.purchaseOrder,
            recordId: _order.id,
            title: l10n.purchaseOrderTitle('${_order.id}'),
          ),
        );
  }

  Future<void> _email() async {
    setState(() => _actionError = null);
    await showPurchaseOrderEmailDialog(context, _order);
  }

  /// The action area, left to right (ui-contract "Orden de compra detail"):
  /// Cancelar orden · Editar encabezado · Agregar solicitud · Agregar
  /// producto · Confirmar on a draft; Enviar por correo · Imprimir on a
  /// confirmed order. Each
  /// follows [PurchaseOrderAvailability] and is absent, never disabled,
  /// without its right; Confirmar alone is disabled, with the reason as a
  /// tooltip, while the draft has no lines.
  List<Widget> _actionButtons(PurchaseOrderAvailability can) {
    final l10n = AppLocalizations.of(context)!;
    return [
      // PurchasesOrders (20) delete, on a draft only (FR-024).
      if (can.canCancel)
        OutlinedButton(
          key: const Key('purchase_order_cancel'),
          onPressed: _cancelling ? null : _cancel,
          child: Text(l10n.purchaseOrderCancelAction),
        ),
      // PurchasesOrders (20) update on a draft, plus Suppliers (3) read for
      // the picker (FR-011).
      if (can.canEditHeader)
        OutlinedButton(
          key: const Key('purchase_order_edit_header'),
          onPressed: _editHeader,
          child: Text(l10n.purchaseOrderEditHeader),
        ),
      // PurchasesOrders (20) update on a draft, plus PurchaseRequest (86)
      // read for the picker (FR-017).
      if (can.canAddRequestLines)
        OutlinedButton(
          key: const Key('purchase_order_add_request'),
          onPressed: _addRequest,
          child: Text(l10n.purchaseOrderAddRequest),
        ),
      // PurchasesOrders (20) update on a draft, plus Products read for the
      // picker (FR-013).
      if (can.canAddLine)
        OutlinedButton.icon(
          key: const Key('purchase_order_add_product'),
          onPressed: _addProduct,
          icon: Icon(CatalogAction.create.icon),
          label: Text(l10n.purchaseOrderAddProduct),
        ),
      // PurchasesOrders (20) update on a draft (FR-021).
      if (can.canConfirm)
        _withReason(
          can.confirmNeedsLines
              ? l10n.purchaseOrderConfirmNoLinesTooltip
              : null,
          FilledButton(
            key: const Key('purchase_order_confirm'),
            onPressed: can.confirmNeedsLines || _confirming ? null : _confirm,
            child: Text(l10n.purchaseOrderConfirm),
          ),
        ),
      // PurchasesOrders (20) update, on a confirmed order (FR-027).
      if (can.canEmail)
        OutlinedButton.icon(
          key: const Key('purchase_order_email'),
          onPressed: _email,
          icon: const Icon(Icons.email_outlined),
          label: Text(l10n.purchaseOrderEmailAction),
        ),
      // PurchasesOrders (20) read, on a confirmed order: the server refuses
      // a draft or cancelled one (FR-026).
      if (can.canPrint)
        OutlinedButton.icon(
          key: const Key('purchase_order_print'),
          onPressed: _print,
          icon: const Icon(Icons.print_outlined),
          label: Text(l10n.purchaseOrderPrint),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).spacing;
    final order = _order;
    final can = PurchaseOrderAvailability(
      status: order.status,
      access: ref.watch(accessControlProvider),
      lineCount: order.lines.length,
    );
    final buttons = _actionButtons(can);
    final actionError = _actionError;
    // FR-019: the price-0 warning only while the order can still change.
    final zeroPrice = order.status == InventoryDocumentStatus.draft
        ? zeroPriceLines(order.lines)
        : const <PurchaseOrderLine>[];

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.screenMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.sectionGap,
        children: [
          _HeaderFacts(order: order),
          if (order.receipts.isNotEmpty)
            OrderReceiptsSection(receipts: order.receipts),
          if (zeroPrice.isNotEmpty)
            OrderWarningsBand(zeroPriceLines: zeroPrice),
          _LinesSection(
            order: order,
            // ✎: PurchasesOrders (20) update plus Warehouses (4) read for its
            // picker; 🗑: PurchasesOrders (20) update. Drafts only.
            onEditLine: can.canEditLines ? _editLine : null,
            onRemoveLine: can.canRemoveLines ? _removeLine : null,
          ),
          _TotalsBand(order: order),
          if (actionError != null)
            ErrorBanner(
              key: const Key('purchase_order_refusal'),
              error: actionError,
            ),
          if (buttons.isNotEmpty)
            Align(
              key: const Key('purchase_order_actions'),
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

/// [child] with [reason] as its tooltip, when there is one: why a control is
/// disabled.
Widget _withReason(String? reason, Widget child) =>
    reason == null ? child : Tooltip(message: reason, child: child);

/// The header (FR-011, FR-012): Estado, Proveedor and Entrega on one strip,
/// then the notes and who created it, when.
class _HeaderFacts extends ConsumerWidget {
  const _HeaderFacts({required this.order});

  final PurchaseOrder order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final fmt = ref.watch(formattersProvider);
    final comment = order.comment;
    final supplier = order.supplierName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: spacing.fieldGapVertical,
      children: [
        FactStripRow(
          key: const Key('purchase_order_facts'),
          facts: [
            CompactField(
              label: l10n.purchaseOrderFactStatus,
              child: InventoryDocumentStatusChip(status: order.status),
            ),
            CompactField(
              label: l10n.purchaseOrderFactSupplier,
              child: Text(
                supplier == null || supplier.isEmpty
                    ? emptyValuePlaceholder
                    : supplier,
                key: const Key('purchase_order_supplier'),
              ),
            ),
            CompactField(
              label: l10n.purchaseOrderFactDelivery,
              child: Text(
                fmt.display.date(order.estimatedReceiptDate),
                key: const Key('purchase_order_delivery'),
              ),
            ),
          ],
          trailing: const SizedBox.shrink(),
        ),
        ResponsiveFormGrid(
          key: const Key('purchase_order_detail_band'),
          spacing: spacing.fieldGapHorizontal,
          alignment: AlignmentDirectional.centerStart.resolve(
            Directionality.of(context),
          ),
          children: [
            FormGridChild(
              CompactField(
                label: l10n.purchaseOrderFactNotes,
                child: Text(
                  comment == null || comment.isEmpty
                      ? emptyValuePlaceholder
                      : comment,
                  key: const Key('purchase_order_comment'),
                ),
              ),
            ),
            FormGridChild(
              CompactField(
                label: l10n.purchaseOrderFactCreator,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: InventoryEmployeeName(employeeId: order.creatorId),
                    ),
                    Text(' · ${fmt.display.dateTime(order.createdAt)}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Subtotal, IVA and Total, in every state (FR-012).
class _TotalsBand extends ConsumerWidget {
  const _TotalsBand({required this.order});

  final PurchaseOrder order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final fmt = ref.watch(formattersProvider);
    return Align(
      key: const Key('purchase_order_totals'),
      alignment: AlignmentDirectional.centerEnd,
      child: Wrap(
        alignment: WrapAlignment.end,
        spacing: spacing.lg,
        runSpacing: spacing.sm,
        children: [
          CompactField(
            label: l10n.purchaseOrderTotalSubtotal,
            child: Text(
              fmt.display.currency(order.subtotal.toString()),
              key: const Key('purchase_order_subtotal'),
            ),
          ),
          CompactField(
            label: l10n.purchaseOrderTotalTax,
            child: Text(
              fmt.display.currency(order.tax.toString()),
              key: const Key('purchase_order_tax'),
            ),
          ),
          CompactField(
            label: l10n.purchaseOrderTotalTotal,
            child: Text(
              fmt.display.currency(order.total.toString()),
              key: const Key('purchase_order_total'),
            ),
          ),
        ],
      ),
    );
  }
}

/// The lines (FR-016). A draft or cancelled order shows Código, Producto
/// (with "Sol. {serial}" under a line from a request), Almacén, Cantidad,
/// Precio, IVA, Importe; a confirmed one shows Recibido and Pendiente in
/// place of Precio and IVA (FR-023). On an editable draft each row has ✎
/// (warehouse, quantity, price, IVA) and 🗑 (remove).
class _LinesSection extends ConsumerWidget {
  const _LinesSection({
    required this.order,
    this.onEditLine,
    this.onRemoveLine,
  });

  final PurchaseOrder order;

  /// Each `null` hides its row icon.
  final void Function(PurchaseOrderLine line)? onEditLine;
  final void Function(PurchaseOrderLine line)? onRemoveLine;

  /// ✎ and 🗑 for [line], each only with its callback.
  List<Widget> _lineActions(AppLocalizations l10n, PurchaseOrderLine line) {
    final onEdit = onEditLine;
    final onRemove = onRemoveLine;
    return buildCatalogRowActions(
      editTooltip: l10n.purchaseOrderLineEditTooltip,
      editKey: Key('purchase_order_line_edit_${line.id}'),
      onEdit: onEdit == null ? null : () => onEdit(line),
      extraActions: [
        if (onRemove != null)
          CatalogRowAction(
            key: Key('purchase_order_line_remove_${line.id}'),
            icon: Icons.delete_outline,
            tooltip: l10n.purchaseOrderLineRemoveTooltip,
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
    final lines = order.lines;
    final confirmed = order.status == InventoryDocumentStatus.completed;

    return Column(
      key: const Key('purchase_order_lines'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: spacing.sm,
      children: [
        Text(l10n.purchaseOrderColLines, style: theme.textTheme.titleMedium),
        if (lines.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: spacing.lg),
              child: Text(
                l10n.purchaseOrderLinesEmpty,
                key: const Key('purchase_order_lines_empty'),
              ),
            ),
          )
        else
          DataTableView<PurchaseOrderLine>(
            key: const Key('purchase_order_lines_table'),
            shrinkWrap: true,
            margin: EdgeInsets.zero,
            rows: lines,
            rowActionsBuilder: onEditLine == null && onRemoveLine == null
                ? null
                : (context, line) => _lineActions(l10n, line),
            columns: [
              DataTableColumn.text(
                label: l10n.purchaseOrderLineColCode,
                size: ColumnSize.S,
                text: (line) => line.productCode.isEmpty
                    ? emptyValuePlaceholder
                    : line.productCode,
              ),
              DataTableColumn(
                label: l10n.purchaseOrderLineColProduct,
                size: ColumnSize.L,
                cellBuilder: (context, line) => _ProductCell(line: line),
              ),
              DataTableColumn(
                label: l10n.purchaseOrderLineColWarehouse,
                size: ColumnSize.M,
                cellBuilder: (context, line) {
                  final warehouseId = line.warehouseId;
                  return warehouseId == null
                      ? const Text(emptyValuePlaceholder)
                      : InventoryWarehouseName(warehouseId: warehouseId);
                },
              ),
              DataTableColumn(
                label: l10n.purchaseOrderLineColQuantity,
                numeric: true,
                size: ColumnSize.S,
                cellBuilder: (context, line) => Text(
                  fmt.display.quantity(line.quantity.toString()),
                  key: Key('purchase_order_line_quantity_${line.id}'),
                ),
              ),
              // A confirmed order swaps Precio and IVA for what has been
              // received and what is still pending (research R8, FR-023).
              if (confirmed) ...[
                DataTableColumn(
                  label: l10n.purchaseOrderLineColReceived,
                  numeric: true,
                  size: ColumnSize.S,
                  cellBuilder: (context, line) => Text(
                    _quantityOrDash(fmt, line.quantityReceived),
                    key: Key('purchase_order_line_received_${line.id}'),
                  ),
                ),
                DataTableColumn(
                  label: l10n.purchaseOrderLineColPending,
                  numeric: true,
                  size: ColumnSize.S,
                  cellBuilder: (context, line) => Text(
                    _quantityOrDash(fmt, line.quantityPending),
                    key: Key('purchase_order_line_pending_${line.id}'),
                  ),
                ),
              ] else ...[
                DataTableColumn(
                  label: l10n.purchaseOrderLineColPrice,
                  numeric: true,
                  size: ColumnSize.S,
                  cellBuilder: (context, line) => Text(
                    fmt.display.currency(line.price.toString()),
                    key: Key('purchase_order_line_price_${line.id}'),
                  ),
                ),
                DataTableColumn(
                  label: l10n.purchaseOrderLineColTax,
                  numeric: true,
                  size: ColumnSize.S,
                  cellBuilder: (context, line) => Text(
                    fmt.display.percent(line.taxRate.toString()),
                    key: Key('purchase_order_line_tax_${line.id}'),
                  ),
                ),
              ],
              DataTableColumn(
                label: l10n.purchaseOrderLineColAmount,
                numeric: true,
                size: ColumnSize.S,
                cellBuilder: (context, line) => Text(
                  fmt.display.currency(line.amount.toString()),
                  key: Key('purchase_order_line_amount_${line.id}'),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

/// A received or pending quantity, or "—" where the server sends none (a
/// non-stockable line, research R8).
String _quantityOrDash(AppFormatters fmt, Decimal? value) =>
    value == null ? emptyValuePlaceholder : fmt.display.quantity('$value');

/// The product name and, for a line from a request, "Sol. {serial}" after
/// it: `…` while the folio loads, `#id` when it can't be read (research R8).
class _ProductCell extends ConsumerWidget {
  const _ProductCell({required this.line});

  final PurchaseOrderLine line;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestId = line.requestId;
    final name = Text(
      line.productName,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    if (requestId == null) return name;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final serial = ref.watch(purchaseRequestSerialProvider(requestId));
    final folio = serial.when(
      data: (s) => s == null ? '#$requestId' : '$s',
      loading: () => '…',
      error: (_, _) => '#$requestId',
    );
    // On the name's line, not under it: a table row has one fixed height
    // and two lines overflow it at the largest text level (T035). The name
    // gives way (ellipsis, full text in the tooltip); the folio never does.
    return Row(
      spacing: theme.spacing.sm,
      children: [
        Flexible(
          child: Tooltip(message: line.productName, child: name),
        ),
        Text(
          l10n.purchaseOrderLineRequest(folio),
          key: Key('purchase_order_line_request_${line.id}'),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
