import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/access/access_control.dart';
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
import 'package:mbe_ui/features/inventory/presentation/shared/inventory_document_status_chip.dart';
import 'package:mbe_ui/features/inventory/presentation/shared/inventory_name_cells.dart';
import 'package:mbe_ui/features/purchases/domain/below_minimum.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_request.dart';
import 'package:mbe_ui/features/purchases/presentation/requests/add_request_line_dialog.dart';
import 'package:mbe_ui/features/purchases/presentation/requests/purchase_request_actions.dart';
import 'package:mbe_ui/features/purchases/presentation/requests/purchase_request_availability.dart';
import 'package:mbe_ui/features/purchases/presentation/requests/purchase_request_detail_controller.dart';
import 'package:mbe_ui/features/purchases/presentation/requests/purchase_request_status_chip.dart';
import 'package:mbe_ui/features/purchases/presentation/requests/purchase_requests_list_screen.dart';
import 'package:mbe_ui/features/purchases/presentation/requests/request_dialogs.dart';
import 'package:mbe_ui/features/purchases/presentation/requests/request_header_dialog.dart';
import 'package:mbe_ui/features/purchases/presentation/requests/request_line_dialog.dart';
import 'package:mbe_ui/features/purchases/presentation/requests/request_minimum_band.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// One purchase request (spec 079 contracts/ui-contract.md "Solicitud
/// detail"): the header facts, the minimum-quantity band, the lines and the
/// action area.
///
/// A full screen with its own address, because a request owns lines (§VI
/// document reading). `AppBar.actions` stays empty; every action is in the
/// body, each present only per `PurchaseRequestAvailability`.
class PurchaseRequestDetailScreen extends ConsumerWidget {
  /// [requestId] is `null` for an address whose id isn't a number, which
  /// shows the not-found state instead of throwing.
  const PurchaseRequestDetailScreen({super.key, required this.requestId});

  final int? requestId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final id = requestId;
    if (id == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.navPurchaseRequests)),
        body: const _NotFound(),
      );
    }
    final detail = ref.watch(purchaseRequestDetailControllerProvider(id));
    final request = detail.value;

    return Scaffold(
      appBar: AppBar(
        // FR-005: a request never submitted has no folio yet.
        title: Text(
          request == null
              ? l10n.navPurchaseRequests
              : request.serial == null
              ? l10n.purchaseRequestTitleDraft('${request.id}')
              : l10n.purchaseRequestTitle('${request.serial}'),
        ),
      ),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => error is NotFoundError
            ? const _NotFound()
            : _LoadFailed(
                error: toAppError(error),
                onRetry: () =>
                    ref.invalidate(purchaseRequestDetailControllerProvider(id)),
              ),
        data: (request) => _RequestBody(request: request),
      ),
    );
  }
}

/// Back to the list: pops when the list is underneath, otherwise goes there.
void _backToList(BuildContext context) =>
    context.canPop() ? context.pop() : context.go(purchaseRequestsPath);

class _NotFound extends StatelessWidget {
  const _NotFound();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    return Padding(
      padding: EdgeInsets.all(spacing.screenMargin),
      child: Column(
        key: const Key('purchase_request_not_found'),
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.fieldGapVertical,
        children: [
          const ErrorBanner(error: AppError.notFound()),
          OutlinedButton(
            key: const Key('purchase_request_back_to_list'),
            onPressed: () => _backToList(context),
            child: Text(l10n.purchaseRequestBackToList),
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
        key: const Key('purchase_request_load_failed'),
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.fieldGapVertical,
        children: [
          ErrorBanner(error: error),
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            children: [
              OutlinedButton(
                key: const Key('purchase_request_back_to_list'),
                onPressed: () => _backToList(context),
                child: Text(l10n.purchaseRequestBackToList),
              ),
              FilledButton(
                key: const Key('purchase_request_retry_button'),
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

/// The loaded request, as a column of sections: facts, minimum band, lines,
/// refusal, action area.
///
/// Every write goes through `PurchaseRequestActions`, which puts the
/// returned request into the detail provider, so this body is rebuilt with
/// it (FR-028). Stateful so a refusal survives that rebuild.
class _RequestBody extends ConsumerStatefulWidget {
  const _RequestBody({required this.request});

  final PurchaseRequest request;

  @override
  ConsumerState<_RequestBody> createState() => _RequestBodyState();
}

class _RequestBodyState extends ConsumerState<_RequestBody> {
  /// The last action's refusal, shown above the action area. The dialogs
  /// show their own refusals; an action without one (the Comprar mark)
  /// reports its refusal here.
  AppError? _actionError;

  /// The lines whose Comprar mark is being saved: one call at a time per
  /// line (FR-017).
  final Set<int> _marking = {};

  PurchaseRequest get _request => widget.request;

  Future<void> _editHeader() async {
    setState(() => _actionError = null);
    await showRequestHeaderDialog(context, _request);
  }

  Future<void> _cancel() async {
    setState(() => _actionError = null);
    await showCancelRequestDialog(context, _request);
  }

  /// Flips [line]'s Comprar mark, with no prompt since it is easy to reverse
  /// (research R11). The returned request replaces the one on screen.
  Future<void> _markLine(PurchaseRequestLine line) async {
    if (_marking.contains(line.id)) return;
    setState(() {
      _actionError = null;
      _marking.add(line.id);
    });
    final error = await ref
        .read(purchaseRequestActionsProvider.notifier)
        .markLine(_request.id, line.id, toPurchase: !line.toPurchase);
    if (!mounted) return;
    setState(() {
      _marking.remove(line.id);
      _actionError = error;
    });
  }

  /// The order a `purchase_request.line_on_live_order` refusal is about,
  /// found by its `line_id` among the request's lines. The shared message
  /// stays generic; this enrichment is the screen's (error-messages.md).
  int? _refusalOrder(AppError error) {
    final problem = error.problem;
    if (problem?.code != api.ErrorCode.purchaseRequestPeriodLineOnLiveOrder) {
      return null;
    }
    final lineId = problem!.intParam('line_id');
    for (final line in _request.lines) {
      if (line.id == lineId) return line.purchaseOrderId;
    }
    return null;
  }

  Future<void> _addProduct() async {
    setState(() => _actionError = null);
    await showAddRequestLineDialog(context, requestId: _request.id);
  }

  Future<void> _submit() async {
    setState(() => _actionError = null);
    await showSubmitRequestDialog(context, _request);
  }

  /// The parts the approve and reject prompts name.
  RequestDecisionTarget get _decisionTarget => (
    id: _request.id,
    serial: _request.serial,
    facilityId: _request.facilityId,
    warehouseId: _request.warehouseId,
    lineCount: _request.lineCount,
  );

  Future<void> _approve() async {
    setState(() => _actionError = null);
    await showApproveRequestDialog(context, _decisionTarget);
  }

  Future<void> _reject() async {
    setState(() => _actionError = null);
    await showRejectRequestDialog(context, _decisionTarget);
  }

  Future<void> _editLine(PurchaseRequestLine line) async {
    setState(() => _actionError = null);
    await showRequestLineDialog(context, requestId: _request.id, line: line);
  }

  Future<void> _removeLine(PurchaseRequestLine line) async {
    setState(() => _actionError = null);
    await showRemoveRequestLineDialog(
      context,
      requestId: _request.id,
      line: line,
    );
  }

  /// The action area, left to right (ui-contract "Solicitud detail"):
  /// Cancelar · Editar encabezado · Agregar producto · Enviar on a draft;
  /// Cancelar · Rechazar · Aprobar on a submitted request. Each follows
  /// [PurchaseRequestAvailability] and is absent, never disabled, without
  /// its right.
  List<Widget> _actionButtons(PurchaseRequestAvailability can) {
    final l10n = AppLocalizations.of(context)!;
    return [
      // PurchaseRequest (86) delete on an own draft, submitted or approved
      // request (FR-018).
      if (can.canCancel)
        OutlinedButton(
          key: const Key('purchase_request_cancel'),
          onPressed: _cancel,
          child: Text(l10n.purchaseRequestCancel),
        ),
      // PurchaseRequest (86) update on an own draft, plus Warehouses (4) read
      // for the picker (FR-007).
      if (can.canEditHeader)
        OutlinedButton(
          key: const Key('purchase_request_edit_header'),
          onPressed: _editHeader,
          child: Text(l10n.purchaseRequestEditHeader),
        ),
      // PurchaseRequest (86) update on an own draft, plus Products read for
      // the picker.
      if (can.canAddLine)
        OutlinedButton.icon(
          key: const Key('purchase_request_add_product'),
          onPressed: _addProduct,
          icon: Icon(CatalogAction.create.icon),
          label: Text(l10n.purchaseRequestAddProduct),
        ),
      // PurchaseRequest (86) update on an own draft.
      if (can.canSubmit)
        FilledButton(
          key: const Key('purchase_request_submit'),
          onPressed: _submit,
          child: Text(l10n.purchaseRequestSubmit),
        ),
      // PurchaseRequestApproval (96) update on a submitted request, in any
      // facility (FR-022).
      if (can.canReject)
        OutlinedButton(
          key: const Key('purchase_request_reject'),
          onPressed: _reject,
          child: Text(l10n.purchaseRequestReject),
        ),
      // PurchaseRequestApproval (96) update on a submitted request, in any
      // facility (FR-021).
      if (can.canApprove)
        FilledButton(
          key: const Key('purchase_request_approve'),
          onPressed: _approve,
          child: Text(l10n.purchaseRequestApprove),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).spacing;
    final request = _request;
    // The signed-in user's facility, read here rather than through the
    // sales feature's provider, so purchases doesn't depend on sales.
    final auth = ref.watch(authProvider).value;
    final can = PurchaseRequestAvailability(
      status: request.status,
      facilityId: request.facilityId,
      access: ref.watch(accessControlProvider),
      userFacilityId: auth is AuthAuthenticated
          ? auth.user.settings?.facilityId
          : null,
    );
    final buttons = _actionButtons(can);
    // FR-013: never on a cancelled request.
    final below = request.status == PurchaseRequestStatus.cancelled
        ? const <BelowMinimum>[]
        : belowMinimum(request.lines);
    final actionError = _actionError;
    final refusalOrder = actionError == null
        ? null
        : _refusalOrder(actionError);

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.screenMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.sectionGap,
        children: [
          _HeaderFacts(request: request),
          if (below.isNotEmpty) RequestMinimumBand(belowMinimum: below),
          _LinesSection(
            request: request,
            onEditLine: can.canEditLines ? _editLine : null,
            onRemoveLine: can.canEditLines ? _removeLine : null,
            // PurchasesOrders (20) update on a submitted or approved request,
            // in any facility (FR-017).
            onMarkLine: can.canMarkLines ? _markLine : null,
            marking: _marking,
          ),
          if (actionError != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: spacing.xs,
              children: [
                ErrorBanner(
                  key: const Key('purchase_request_refusal'),
                  error: actionError,
                ),
                if (refusalOrder != null)
                  Text(
                    AppLocalizations.of(
                      context,
                    )!.purchaseRequestRefusalOrder('$refusalOrder'),
                    key: const Key('purchase_request_refusal_order'),
                  ),
              ],
            ),
          if (buttons.isNotEmpty)
            Align(
              key: const Key('purchase_request_actions'),
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

/// The header (FR-005, FR-009): Estado, Folio, Almacén and Sucursal on one
/// strip, then the notes and who asked for it, when.
class _HeaderFacts extends ConsumerWidget {
  const _HeaderFacts({required this.request});

  final PurchaseRequest request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final fmt = ref.watch(formattersProvider);
    final comment = request.comment;
    final facilityId = request.facilityId;
    final approverId = request.approverId;
    final approvalTime = request.approvalTime;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: spacing.fieldGapVertical,
      children: [
        FactStripRow(
          key: const Key('purchase_request_facts'),
          facts: [
            CompactField(
              label: l10n.purchaseRequestFactStatus,
              child: PurchaseRequestStatusChip(status: request.status),
            ),
            CompactField(
              label: l10n.purchaseRequestFactFolio,
              child: RecordIdText(
                request.serial == null
                    ? emptyValuePlaceholder
                    : '${request.serial}',
                key: const Key('purchase_request_serial'),
              ),
            ),
            CompactField(
              label: l10n.purchaseRequestFactWarehouse,
              child: InventoryWarehouseName(warehouseId: request.warehouseId),
            ),
            CompactField(
              label: l10n.purchaseRequestFactFacility,
              child: facilityId == null
                  ? const Text(emptyValuePlaceholder)
                  : InventoryFacilityName(facilityId: facilityId),
            ),
          ],
          trailing: const SizedBox.shrink(),
        ),
        ResponsiveFormGrid(
          key: const Key('purchase_request_detail_band'),
          spacing: spacing.fieldGapHorizontal,
          alignment: AlignmentDirectional.centerStart.resolve(
            Directionality.of(context),
          ),
          children: [
            FormGridChild(
              CompactField(
                label: l10n.purchaseRequestFactComment,
                child: Text(
                  comment == null || comment.isEmpty
                      ? emptyValuePlaceholder
                      : comment,
                  key: const Key('purchase_request_comment'),
                ),
              ),
            ),
            FormGridChild(
              CompactField(
                label: l10n.purchaseRequestFactCreator,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: InventoryEmployeeName(
                        employeeId: request.creatorId,
                      ),
                    ),
                    Text(' · ${fmt.display.dateTime(request.date)}'),
                  ],
                ),
              ),
            ),
            // FR-009: who approved it, when; cleared again by a rejection.
            if (approverId != null)
              FormGridChild(
                CompactField(
                  key: const Key('purchase_request_approver'),
                  label: l10n.purchaseRequestFactApprover,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: InventoryEmployeeName(employeeId: approverId),
                      ),
                      if (approvalTime != null)
                        Text(' · ${fmt.display.dateTime(approvalTime)}'),
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

/// The lines (FR-010, FR-015, FR-017): Código, Producto, Cantidad, Destino,
/// the Comprar mark and, once any line is on one, the purchase order. When
/// the lines are editable each row has ✎ (name, quantity, destination) and
/// 🗑 (remove).
class _LinesSection extends ConsumerWidget {
  const _LinesSection({
    required this.request,
    this.onEditLine,
    this.onRemoveLine,
    this.onMarkLine,
    this.marking = const {},
  });

  final PurchaseRequest request;

  /// Each `null` hides its row icon (FR-025, FR-026).
  final void Function(PurchaseRequestLine line)? onEditLine;
  final void Function(PurchaseRequestLine line)? onRemoveLine;

  /// `null` leaves the Comprar mark read-only.
  final void Function(PurchaseRequestLine line)? onMarkLine;

  /// The lines whose mark is being saved: their checkbox is disabled.
  final Set<int> marking;

  /// ✎ and 🗑 for [line], or none when the lines aren't editable.
  List<Widget> _lineActions(AppLocalizations l10n, PurchaseRequestLine line) {
    final onEdit = onEditLine;
    final onRemove = onRemoveLine;
    if (onEdit == null || onRemove == null) return const [];
    return buildCatalogRowActions(
      editTooltip: l10n.purchaseRequestLineEditTooltip,
      editKey: Key('purchase_request_line_edit_${line.id}'),
      onEdit: () => onEdit(line),
      extraActions: [
        CatalogRowAction(
          key: Key('purchase_request_line_remove_${line.id}'),
          icon: Icons.delete_outline,
          tooltip: l10n.purchaseRequestLineRemoveTooltip,
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
    final lines = request.lines;
    final onMark = onMarkLine;
    // FR-015: the column only once some line is on a purchase order.
    final onOrder = lines.any((line) => line.purchaseOrderId != null);

    return Column(
      key: const Key('purchase_request_lines'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: spacing.sm,
      children: [
        Text(l10n.purchaseRequestColLines, style: theme.textTheme.titleMedium),
        if (lines.isEmpty && request.status == PurchaseRequestStatus.draft)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: spacing.lg),
              child: Text(
                l10n.purchaseRequestLinesEmpty,
                key: const Key('purchase_request_lines_empty'),
              ),
            ),
          )
        else
          DataTableView<PurchaseRequestLine>(
            key: const Key('purchase_request_lines_table'),
            shrinkWrap: true,
            margin: EdgeInsets.zero,
            rows: lines,
            rowActionsBuilder: onEditLine == null
                ? null
                : (context, line) => _lineActions(l10n, line),
            columns: [
              DataTableColumn.text(
                label: l10n.purchaseRequestLineColCode,
                size: ColumnSize.S,
                text: (line) => line.productCode.isEmpty
                    ? emptyValuePlaceholder
                    : line.productCode,
              ),
              DataTableColumn.text(
                label: l10n.purchaseRequestLineColProduct,
                size: ColumnSize.L,
                text: (line) => line.productName,
              ),
              DataTableColumn(
                label: l10n.purchaseRequestLineColQuantity,
                numeric: true,
                size: ColumnSize.S,
                cellBuilder: (context, line) => Text(
                  fmt.display.quantity(line.quantity.toString()),
                  key: Key('purchase_request_line_quantity_${line.id}'),
                ),
              ),
              DataTableColumn(
                label: l10n.purchaseRequestLineColDestination,
                size: ColumnSize.M,
                cellBuilder: (context, line) {
                  final warehouseId = line.warehouseId;
                  return warehouseId == null
                      ? const Text(emptyValuePlaceholder)
                      : InventoryWarehouseName(warehouseId: warehouseId);
                },
              ),
              DataTableColumn(
                label: l10n.purchaseRequestLineColToPurchase,
                size: ColumnSize.S,
                cellBuilder: (context, line) {
                  final key = Key(
                    'purchase_request_line_to_purchase_${line.id}_'
                    '${line.toPurchase}',
                  );
                  if (onMark == null) {
                    return Icon(
                      line.toPurchase
                          ? Icons.check_box_outlined
                          : Icons.check_box_outline_blank,
                      key: key,
                    );
                  }
                  return Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Checkbox(
                      key: key,
                      value: line.toPurchase,
                      onChanged: marking.contains(line.id)
                          ? null
                          : (_) => onMark(line),
                    ),
                  );
                },
              ),
              // Text, not a link: there is no purchase-order screen yet.
              if (onOrder)
                DataTableColumn(
                  label: l10n.purchaseRequestLineColPurchaseOrder,
                  size: ColumnSize.M,
                  cellBuilder: (context, line) {
                    final orderId = line.purchaseOrderId;
                    final status = line.purchaseOrderStatus;
                    if (orderId == null) {
                      return const Text(emptyValuePlaceholder);
                    }
                    return Row(
                      key: Key('purchase_request_line_order_${line.id}'),
                      mainAxisSize: MainAxisSize.min,
                      spacing: spacing.sm,
                      children: [
                        RecordIdText('$orderId'),
                        if (status != null)
                          Flexible(
                            child: InventoryDocumentStatusChip(status: status),
                          ),
                      ],
                    );
                  },
                ),
            ],
          ),
      ],
    );
  }
}
