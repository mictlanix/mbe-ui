import 'package:data_table_2/data_table_2.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/config/app_settings_provider.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/core/widgets/compact_field.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/fact_strip_row.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart' show toAppError;
import 'package:mbe_ui/core/widgets/status_chip.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_refund.dart';
import 'package:mbe_ui/features/sales/presentation/capture/facility_warehouses_controller.dart';
import 'package:mbe_ui/features/sales/presentation/capture/warehouse_picker_dialog.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payment_link_providers.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payment_widgets.dart';
import 'package:mbe_ui/features/sales/presentation/refunds/refund_confirm_dialog.dart';
import 'package:mbe_ui/features/sales/presentation/refunds/refund_editor_controller.dart';
import 'package:mbe_ui/features/sales/presentation/refunds/refund_line_block.dart';
import 'package:mbe_ui/features/sales/presentation/refunds/refund_outcome_provider.dart';
import 'package:mbe_ui/features/sales/presentation/refunds/refunds_list_screen.dart';
import 'package:mbe_ui/features/sales/presentation/widgets/quantity_stepper.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// One customer refund: a draft being filled in, or a confirmed or cancelled
/// one read-only (spec 057 contracts C5).
///
/// A full screen with its own address rather than a side panel because a
/// refund owns child lines (constitution §VI record-surface criteria). The
/// AppBar carries only Back; the actions sit in the body.
class RefundDetailScreen extends ConsumerWidget {
  /// [refundId] is `null` for an address whose id isn't a number, which shows
  /// the not-found state instead of throwing.
  const RefundDetailScreen({super.key, required this.refundId});

  final int? refundId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final id = refundId;
    if (id == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.refundDetailTitle)),
        body: const _NotFound(refundId: null),
      );
    }
    final refund = ref.watch(refundEditorControllerProvider(id));
    final serial = refund.value?.serial;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          serial == null
              ? l10n.refundDetailTitle
              : l10n.refundDetailTitleWithNumber(serial),
        ),
      ),
      body: refund.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => error is NotFoundError
            ? _NotFound(refundId: id)
            : _LoadFailed(
                error: toAppError(error),
                onRetry: () =>
                    ref.invalidate(refundEditorControllerProvider(id)),
              ),
        data: (data) => _RefundBody(refund: data),
      ),
    );
  }
}

class _NotFound extends StatelessWidget {
  const _NotFound({required this.refundId});

  final int? refundId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    return Padding(
      padding: EdgeInsets.all(spacing.screenMargin),
      child: Column(
        key: const Key('refund_not_found'),
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.fieldGapVertical,
        children: [
          ErrorBanner(
            error: AppError.notFound(
              refundId == null ? null : l10n.refundNotFound(refundId!),
            ),
          ),
          OutlinedButton(
            onPressed: () =>
                context.canPop() ? context.pop() : context.go(refundsPath),
            child: Text(l10n.backButton),
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
        key: const Key('refund_load_failed'),
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.fieldGapVertical,
        children: [
          ErrorBanner(error: error),
          OutlinedButton(
            key: const Key('refund_retry_button'),
            onPressed: onRetry,
            child: Text(l10n.retryButton),
          ),
        ],
      ),
    );
  }
}

class _RefundBody extends ConsumerStatefulWidget {
  const _RefundBody({required this.refund});

  final CustomerRefund refund;

  @override
  ConsumerState<_RefundBody> createState() => _RefundBodyState();
}

class _RefundBodyState extends ConsumerState<_RefundBody> {
  final _quantityControllers = <int, QuantityStepperController>{};

  /// A refused write's server detail, per line.
  final _lineErrors = <int, String>{};

  /// Set from the confirm that just ran; nothing about it is stored (C8).
  bool _adjusted = false;
  bool _confirming = false;
  bool _cancelling = false;
  AppError? _confirmError;
  RefundSessionInvalid? _sessionInvalid;

  CustomerRefund get _refund => widget.refund;

  RefundEditorController get _editor =>
      ref.read(refundEditorControllerProvider(_refund.id).notifier);

  @override
  void dispose() {
    for (final controller in _quantityControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  QuantityStepperController _controllerFor(RefundLine line) {
    final existing = _quantityControllers[line.id];
    if (existing != null) {
      existing.sync(value: line.quantity, max: line.refundableQuantity);
      return existing;
    }
    return _quantityControllers[line.id] = QuantityStepperController(
      value: line.quantity,
      min: '0',
      max: line.refundableQuantity,
      onCommit: (value) => _commitQuantity(line.id, value),
      debounce: ref.read(quantityCommitDebounceProvider),
    );
  }

  Future<bool> _commitQuantity(int lineId, String value) async {
    try {
      await _editor.setQuantity(lineId, value);
      if (mounted) setState(() => _lineErrors.remove(lineId));
      return true;
    } on AppError catch (e) {
      if (!mounted) return false;
      final l10n = AppLocalizations.of(context)!;
      setState(
        () => _lineErrors[lineId] = e.serverMessage ?? l10n.errorServerGeneric,
      );
      return false;
    }
  }

  Future<void> _pickWarehouse(
    RefundLine line,
    List<Warehouse> warehouses,
  ) async {
    final picked = await showWarehousePicker(
      context,
      facilityId: _refund.facilityId,
      warehouses: warehouses,
      selected: line.warehouseId,
      stock: null,
      quantity: Decimal.tryParse(line.quantity) ?? Decimal.zero,
      productName: line.productName,
    );
    if (picked == null || picked == line.warehouseId || !mounted) return;
    try {
      await _editor.setWarehouse(line.id, picked);
      if (mounted) setState(() => _lineErrors.remove(line.id));
    } on AppError catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(
        () => _lineErrors[line.id] = e.serverMessage ?? l10n.errorServerGeneric,
      );
    }
  }

  Future<void> _cancel() async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        key: const Key('refund_cancel_dialog'),
        title: Text(l10n.refundCancelAction),
        content: Text(l10n.refundCancelPrompt),
        actions: [
          TextButton(
            key: const Key('refund_cancel_dialog_back'),
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.refundConfirmBack),
          ),
          FilledButton(
            key: const Key('refund_cancel_dialog_confirm'),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.refundCancelAction),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() {
      _cancelling = true;
      _confirmError = null;
      _sessionInvalid = null;
    });
    try {
      await _editor.cancel();
    } on AppError catch (e) {
      if (mounted) setState(() => _confirmError = e);
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  Future<void> _confirm() async {
    final fmt = ref.read(formattersProvider);
    final blocked = await _editor.sessionBlock();
    if (!mounted) return;
    if (blocked != null) {
      setState(() {
        _sessionInvalid = blocked;
        _confirmError = null;
      });
      return;
    }
    final payout = await showRefundConfirmDialog(
      context,
      total: fmt.display.currency(_refund.total),
    );
    if (payout == null || !mounted) return;
    setState(() {
      _confirming = true;
      _confirmError = null;
      _sessionInvalid = null;
    });
    try {
      final result = await _editor.confirm(payout);
      if (!mounted) return;
      setState(() {
        switch (result) {
          case RefundConfirmed(:final adjusted):
            _adjusted = adjusted;
          case RefundSessionInvalid():
            _sessionInvalid = result;
        }
      });
    } on AppError catch (e) {
      if (mounted) setState(() => _confirmError = e);
    } finally {
      if (mounted) setState(() => _confirming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final fmt = ref.watch(formattersProvider);
    final access = ref.watch(accessControlProvider);
    final refund = _refund;

    final canEdit =
        refund.isDraft &&
        access.can(SystemObject.customerRefunds, AccessRight.update);
    final canConfirm =
        refund.isDraft &&
        access.can(SystemObject.customerRefundConfirm, AccessRight.update);

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.screenMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.sectionGap,
        children: [
          if (_adjusted)
            _InfoBanner(
              key: const Key('refund_adjusted_banner'),
              message: l10n.refundAdjustedBanner,
            ),
          FactStripRow(
            facts: [
              CompactField(
                label: l10n.refundFieldNumber,
                child: Text(
                  refund.serial == null
                      ? l10n.refundDraftNumber
                      : '${refund.serial}',
                ),
              ),
              CompactField(
                label: l10n.refundFieldDate,
                child: Text(
                  refund.date == null
                      ? l10n.refundNoValue
                      : fmt.display.dateTime(refund.date),
                ),
              ),
              CompactField(
                label: l10n.refundFieldCustomer,
                child: refund.customerId == null
                    ? Text(l10n.refundNoValue)
                    : PaymentCustomerName(
                        customerId: refund.customerId!,
                        name: null,
                      ),
              ),
              CompactField(
                label: l10n.refundFieldOrder,
                child: _OrderLink(orderId: refund.salesOrderId),
              ),
              CompactField(
                label: l10n.refundFieldStatus,
                child: RefundStatusChip(status: refund.status),
              ),
            ],
            trailing: const SizedBox.shrink(),
          ),
          _buildLines(context, canEdit),
          _Totals(refund: refund),
          if (refund.status == RefundStatus.completed)
            _PayoutLine(refund: refund),
          if (_confirmError != null) ErrorBanner(error: _confirmError!),
          if (_sessionInvalid != null)
            _SessionBanner(staleSessionId: _sessionInvalid!.staleSessionId),
          if (canEdit || (canConfirm && refund.hasReturn))
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Wrap(
                spacing: spacing.sm,
                runSpacing: spacing.sm,
                children: [
                  if (canEdit)
                    OutlinedButton(
                      key: const Key('refund_cancel_button'),
                      onPressed: _cancelling || _confirming ? null : _cancel,
                      child: _cancelling
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.refundCancelAction),
                    ),
                  if (canConfirm && refund.hasReturn)
                    FilledButton(
                      key: const Key('refund_confirm_button'),
                      onPressed: _confirming || _cancelling ? null : _confirm,
                      child: _confirming
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.refundConfirmAction),
                    ),
                ],
              ),
            ),
          if (canEdit &&
              !access.can(
                SystemObject.customerRefundConfirm,
                AccessRight.update,
              ))
            Text(
              l10n.refundNeedsConfirmerHint,
              key: const Key('refund_needs_confirmer_hint'),
              style: theme.textTheme.bodySmall,
            ),
        ],
      ),
    );
  }

  Widget _buildLines(BuildContext context, bool canEdit) {
    final l10n = AppLocalizations.of(context)!;
    final fmt = ref.watch(formattersProvider);
    final refund = _refund;
    final completed = refund.status == RefundStatus.completed;

    Widget quantityCell(RefundLine line) => canEdit
        ? Align(
            alignment: AlignmentDirectional.centerStart,
            child: QuantityStepper(
              fieldKey: Key('refund_line_qty_${line.id}'),
              controller: _controllerFor(line),
            ),
          )
        : Text(fmt.field.quantity(line.quantity));

    Widget warehouseCell(RefundLine line) => _WarehouseCell(
      facilityId: refund.facilityId,
      warehouseId: line.warehouseId,
      fieldKey: Key('refund_line_warehouse_${line.id}'),
      onTap: canEdit ? (warehouses) => _pickWarehouse(line, warehouses) : null,
    );

    if (LayoutBreakpoints.isCompact(context)) {
      return Column(
        children: [
          for (final line in refund.lines)
            RefundLineBlock(
              key: Key('refund_line_block_${line.id}'),
              line: line,
              quantity: quantityCell(line),
              warehouse: warehouseCell(line),
              quantityLabel: completed ? l10n.refundColumnReturned : null,
              error: _lineErrors[line.id],
            ),
        ],
      );
    }

    return DataTableView<RefundLine>(
      key: const Key('refund_lines_table'),
      shrinkWrap: true,
      margin: EdgeInsets.zero,
      rows: refund.lines,
      columns: [
        DataTableColumn(
          label: l10n.refundColumnProduct,
          size: ColumnSize.L,
          cellBuilder: (context, line) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${line.productCode} · ${line.productName}',
                overflow: TextOverflow.ellipsis,
              ),
              if (_lineErrors[line.id] != null)
                Text(
                  _lineErrors[line.id]!,
                  key: Key('refund_line_error_${line.id}'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
            ],
          ),
        ),
        DataTableColumn(
          label: l10n.refundColumnPrice,
          numeric: true,
          size: ColumnSize.S,
          cellBuilder: (context, line) =>
              Text(fmt.display.currency(line.price)),
        ),
        DataTableColumn(
          label: l10n.refundColumnDiscount,
          numeric: true,
          size: ColumnSize.S,
          cellBuilder: (context, line) =>
              Text(fmt.display.percent(line.discount)),
        ),
        DataTableColumn(
          label: l10n.refundColumnTax,
          numeric: true,
          size: ColumnSize.S,
          cellBuilder: (context, line) =>
              Text(fmt.display.percent(line.taxRate)),
        ),
        if (!completed)
          DataTableColumn(
            label: l10n.refundColumnRefundable,
            numeric: true,
            size: ColumnSize.S,
            cellBuilder: (context, line) =>
                Text(fmt.field.quantity(line.refundableQuantity)),
          ),
        DataTableColumn(
          label: completed
              ? l10n.refundColumnReturned
              : l10n.refundColumnReturn,
          size: ColumnSize.M,
          cellBuilder: (context, line) => quantityCell(line),
        ),
        DataTableColumn(
          label: l10n.refundColumnWarehouse,
          size: ColumnSize.M,
          cellBuilder: (context, line) => warehouseCell(line),
        ),
        DataTableColumn(
          label: l10n.refundColumnTotal,
          numeric: true,
          size: ColumnSize.S,
          cellBuilder: (context, line) =>
              Text(fmt.display.currency(line.total)),
        ),
      ],
    );
  }
}

/// A refund status's label.
String refundStatusLabel(AppLocalizations l10n, RefundStatus status) =>
    switch (status) {
      RefundStatus.draft => l10n.refundStatusDraft,
      RefundStatus.completed => l10n.refundStatusCompleted,
      RefundStatus.cancelled => l10n.refundStatusCancelled,
    };

/// A refund status's `(background, foreground)` pair.
(Color, Color) refundStatusColors(
  ColorScheme scheme,
  RefundStatus status,
) => switch (status) {
  RefundStatus.draft => (scheme.primaryContainer, scheme.onPrimaryContainer),
  RefundStatus.completed => (
    scheme.surfaceContainerHighest,
    scheme.onSurfaceVariant,
  ),
  RefundStatus.cancelled => (scheme.errorContainer, scheme.onErrorContainer),
};

/// The refund's status chip, shared by the detail screen and the list.
class RefundStatusChip extends StatelessWidget {
  const RefundStatusChip({super.key, required this.status});

  final RefundStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return StatusChip<RefundStatus>(
      key: Key('refund_status_chip_${status.name}'),
      value: status,
      label: refundStatusLabel(l10n, status),
      colors: (scheme) => refundStatusColors(scheme, status),
    );
  }
}

/// The order as a link when [orderLinkTargetProvider] finds a destination the
/// user can open, plain text otherwise.
class _OrderLink extends ConsumerWidget {
  const _OrderLink({required this.orderId});

  final int orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final target = ref.watch(orderLinkTargetProvider(orderId)).value;
    final label = '#$orderId';
    if (target == null) return Text(label);
    return TextButton(
      key: const Key('refund_order_link'),
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        alignment: AlignmentDirectional.centerStart,
      ),
      onPressed: () => context.push(target),
      child: Text(label),
    );
  }
}

/// A line's warehouse: a tap-field when [onTap] is set, plain text otherwise.
class _WarehouseCell extends ConsumerWidget {
  const _WarehouseCell({
    required this.facilityId,
    required this.warehouseId,
    required this.fieldKey,
    required this.onTap,
  });

  final int facilityId;
  final int? warehouseId;
  final Key fieldKey;
  final void Function(List<Warehouse> warehouses)? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final warehouses = ref.watch(
      facilityWarehousesControllerProvider(facilityId),
    );
    return warehouses.when(
      loading: () => const LinearProgressIndicator(),
      error: (_, _) =>
          Text(warehouseId == null ? l10n.refundNoValue : '#$warehouseId'),
      data: (list) {
        String name = l10n.refundNoValue;
        if (warehouseId != null) {
          name = '#$warehouseId';
          for (final w in list) {
            if (w.warehouseId == warehouseId) name = w.name;
          }
        }
        final text = Text(name, overflow: TextOverflow.ellipsis);
        if (onTap == null) return text;
        return InkWell(
          key: fieldKey,
          borderRadius: theme.shapes.xsRadius,
          onTap: () => onTap!(list),
          child: Row(
            children: [
              Expanded(child: text),
              Icon(
                Icons.unfold_more,
                size: 24,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Totals extends ConsumerWidget {
  const _Totals({required this.refund});

  final CustomerRefund refund;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final fmt = ref.watch(formattersProvider);
    final theme = Theme.of(context);
    final spacing = theme.spacing;

    Widget row(String label, String value, {Key? key, bool strong = false}) {
      final style = strong ? theme.textTheme.titleMedium : null;
      return Row(
        key: key,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: style),
          SizedBox(width: spacing.lg),
          Text(value, style: style),
        ],
      );
    }

    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: spacing.xs,
        children: [
          row(
            l10n.refundSubtotal,
            fmt.display.currency(refund.subtotal),
            key: const Key('refund_subtotal'),
          ),
          row(
            l10n.refundTax,
            fmt.display.currency(refund.taxTotal),
            key: const Key('refund_tax'),
          ),
          row(
            l10n.refundTotal,
            fmt.display.currency(refund.total),
            key: const Key('refund_total'),
            strong: true,
          ),
        ],
      ),
    );
  }
}

/// How a completed refund was paid out (spec 057 R6).
class _PayoutLine extends ConsumerWidget {
  const _PayoutLine({required this.refund});

  final CustomerRefund refund;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final access = ref.watch(accessControlProvider);
    final outcome = ref.watch(refundOutcomeProvider(refund));

    final Widget value = outcome.when(
      loading: () => const Text('…'),
      error: (_, _) => Text(l10n.refundPayoutLineUnknown),
      data: (o) => switch (o) {
        RefundOutcomeCash() => Text(l10n.refundPayoutLineCash),
        RefundOutcomeUnknown() || null => Text(l10n.refundPayoutLineUnknown),
        RefundOutcomeCreditNote(:final note) =>
          access.can(SystemObject.customerPayments, AccessRight.read)
              ? TextButton(
                  key: const Key('refund_payout_link'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () =>
                      context.push('/sales/payments/${note.customerPaymentId}'),
                  child: Text(
                    l10n.refundPayoutLineCreditNote(note.customerPaymentId),
                  ),
                )
              : Text(l10n.refundPayoutLineCreditNote(note.customerPaymentId)),
      },
    );

    return Row(
      key: const Key('refund_payout_line'),
      children: [
        Text(
          '${l10n.refundPayoutLineLabel}: ',
          style: theme.textTheme.bodyMedium,
        ),
        Flexible(child: value),
      ],
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final color = theme.colorScheme.onSecondaryContainer;
    return Material(
      color: theme.colorScheme.secondaryContainer,
      borderRadius: theme.shapes.mdRadius,
      child: Padding(
        padding: EdgeInsets.all(spacing.md),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: color),
            SizedBox(width: spacing.sm),
            Expanded(
              child: Text(message, style: TextStyle(color: color)),
            ),
          ],
        ),
      ),
    );
  }
}

/// No valid cash session: nothing was sent, and the one action that unblocks
/// the confirm is offered (spec 057 R5).
class _SessionBanner extends StatelessWidget {
  const _SessionBanner({required this.staleSessionId});

  final int? staleSessionId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final stale = staleSessionId != null;
    return Container(
      key: const Key('refund_session_banner'),
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: theme.shapes.mdRadius,
      ),
      padding: EdgeInsets.all(spacing.md),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: spacing.sm,
        runSpacing: spacing.sm,
        children: [
          Text(
            l10n.refundSessionBanner,
            style: TextStyle(color: theme.colorScheme.onErrorContainer),
          ),
          FilledButton(
            key: const Key('refund_session_button'),
            onPressed: () => context.push(
              stale
                  ? '/sales/cash-sessions/$staleSessionId'
                  : '/sales/cash-sessions',
            ),
            child: Text(
              stale
                  ? l10n.refundSessionStaleAction
                  : l10n.refundSessionOpenAction,
            ),
          ),
        ],
      ),
    );
  }
}
