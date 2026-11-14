import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/form_error_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_order.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_order_actions.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

// The dialogs the delivery order detail screen opens (spec 061 C5, C6, C8,
// C9). Each runs its own write through `DeliveryOrderActions`, so the order
// reloads whatever the outcome (FR-023).

/// What a status-action dialog reports back once it has closed: `error` is
/// `null` when the server accepted, otherwise the refusal the screen shows.
/// The dialog itself answers `null` when the user backed out.
typedef DeliveryOrderActionResult = ({AppError? error});

/// A write's failure, as a dialog or the screen shows it: a lost connection
/// leaves the outcome unknown, so it says that rather than claiming it failed
/// (spec Edge Cases); anything else is the server's refusal, localized from
/// its code (§III).
class DeliveryOrderRefusal extends StatelessWidget {
  const DeliveryOrderRefusal({super.key, required this.error});

  final AppError error;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return error is NetworkError
        ? FormErrorBanner(
            key: const Key('delivery_order_action_unknown'),
            headline: l10n.deliveryOrderActionUnknown,
          )
        : ErrorBanner(key: const Key('delivery_order_refusal'), error: error);
  }
}

/// The customer's name for a sentence, falling back to `#id` while it loads
/// or when it can't be read (research R4).
String _customerName(WidgetRef ref, int customerId) =>
    ref.watch(customerDisplayNameProvider(customerId)).value ?? '#$customerId';

// ---------------------------------------------------------------------------
// Confirmar (C5, FR-016, FR-017)
// ---------------------------------------------------------------------------

/// Asks before confirming [order], naming its customer, scheduled date and
/// line count, then confirms it.
///
/// A too-soon date (`delivery_order.insufficient_notice`) keeps the dialog
/// open with the earliest date allowed (FR-017). Any other refusal closes it
/// and is answered to the caller to show. `null` when the user backed out.
Future<DeliveryOrderActionResult?> showConfirmDeliveryOrderDialog(
  BuildContext context,
  DeliveryOrder order,
) => showResponsiveDialog<DeliveryOrderActionResult>(
  context,
  builder: (context) => _ConfirmDialog(order: order),
);

class _ConfirmDialog extends ConsumerStatefulWidget {
  const _ConfirmDialog({required this.order});

  final DeliveryOrder order;

  @override
  ConsumerState<_ConfirmDialog> createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends ConsumerState<_ConfirmDialog> {
  bool _busy = false;
  AppError? _refusal;

  Future<void> _confirm() async {
    if (_busy) return;
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
      _refusal = null;
    });
    final error = await ref
        .read(deliveryOrderActionsProvider.notifier)
        .confirm(widget.order.id);
    if (!mounted) return;
    if (error?.problem?.code ==
        api.ErrorCode.deliveryOrderPeriodInsufficientNotice) {
      setState(() {
        _busy = false;
        _refusal = error;
      });
      return;
    }
    navigator.pop((error: error));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final fmt = ref.watch(formattersProvider);
    final order = widget.order;

    return ResponsiveDialog(
      key: const Key('delivery_order_confirm_dialog'),
      title: l10n.deliveryOrderConfirmTitle,
      dismissible: !_busy,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          Text(
            l10n.deliveryOrderConfirmSummary(
              _customerName(ref, order.customerId),
              fmt.display.date(order.date),
              order.lines.length,
            ),
            key: const Key('delivery_order_confirm_summary'),
          ),
          Text(l10n.deliveryOrderConfirmIrreversible),
          if (_refusal != null) DeliveryOrderRefusal(error: _refusal!),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.deliveryOrderBackButton,
        onPressed: _busy ? null : () => Navigator.of(context).pop(),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('delivery_order_confirm_submit'),
        label: l10n.deliveryOrderConfirmAction,
        busy: _busy,
        onPressed: _confirm,
      ),
    );
  }
}

/// The folio for a sentence; a draft has none yet.
String _serial(AppLocalizations l10n, DeliveryOrder order) =>
    order.serial == null ? l10n.deliveryOrderDraftFolio : '${order.serial}';

// ---------------------------------------------------------------------------
// Cancelar orden (C6, FR-018)
// ---------------------------------------------------------------------------

/// Asks for a reason, then cancels [order].
///
/// The confirm button stays disabled while the trimmed reason is empty. Any
/// refusal closes the dialog and is answered to the caller to show: for
/// `state.transition_invalid` that is the generic transition message, and the
/// reload shows the status the order moved to (research R10). `null` when the
/// user backed out.
Future<DeliveryOrderActionResult?> showCancelDeliveryOrderDialog(
  BuildContext context,
  DeliveryOrder order,
) => showResponsiveDialog<DeliveryOrderActionResult>(
  context,
  builder: (context) => _CancelDialog(order: order),
);

class _CancelDialog extends ConsumerStatefulWidget {
  const _CancelDialog({required this.order});

  final DeliveryOrder order;

  @override
  ConsumerState<_CancelDialog> createState() => _CancelDialogState();
}

class _CancelDialogState extends ConsumerState<_CancelDialog> {
  final _reason = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  bool get _canCancel => !_busy && _reason.text.trim().isNotEmpty;

  Future<void> _cancel() async {
    if (!_canCancel) return;
    final navigator = Navigator.of(context);
    setState(() => _busy = true);
    final error = await ref
        .read(deliveryOrderActionsProvider.notifier)
        .cancel(widget.order.id, reason: _reason.text.trim());
    if (!mounted) return;
    navigator.pop((error: error));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final fmt = ref.watch(formattersProvider);
    final order = widget.order;

    return ResponsiveDialog(
      key: const Key('delivery_order_cancel_dialog'),
      title: l10n.deliveryOrderCancelTitle(_serial(l10n, order)),
      dismissible: !_busy,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          Text(
            l10n.deliveryOrderCancelSummary(
              _customerName(ref, order.customerId),
              fmt.display.date(order.date),
            ),
            key: const Key('delivery_order_cancel_summary'),
          ),
          TextField(
            key: const Key('delivery_order_cancel_reason'),
            controller: _reason,
            enabled: !_busy,
            autofocus: true,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: l10n.deliveryOrderCancelReasonLabel,
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.deliveryOrderBackButton,
        onPressed: _busy ? null : () => Navigator.of(context).pop(),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('delivery_order_cancel_submit'),
        label: l10n.deliveryOrderCancelAction,
        busy: _busy,
        onPressed: _canCancel ? _cancel : null,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reprogramar and Lista para recoger (C5, FR-019, FR-020)
// ---------------------------------------------------------------------------

/// Asks before requeuing failed [order], naming its folio and customer, then
/// requeues it. A refusal (such as `delivery_order.not_failed`) closes the
/// dialog and is answered to the caller to show. `null` when the user backed
/// out.
Future<DeliveryOrderActionResult?> showRequeueDeliveryOrderDialog(
  BuildContext context,
  DeliveryOrder order,
) => showResponsiveDialog<DeliveryOrderActionResult>(
  context,
  builder: (context) => _StatusActionDialog(
    keyPrefix: 'delivery_order_requeue',
    order: order,
    title: (l10n) => l10n.deliveryOrderRequeueTitle(_serial(l10n, order)),
    body: (l10n, customer) => l10n.deliveryOrderRequeueBody(customer),
    action: (l10n) => l10n.deliveryOrderRequeueAction,
    run: (actions) => actions.requeue(order.id),
  ),
);

/// Asks before marking pickup [order] ready, naming its folio and customer,
/// then marks it. A refusal closes the dialog and is answered to the caller
/// to show. `null` when the user backed out.
Future<DeliveryOrderActionResult?> showReadyDeliveryOrderDialog(
  BuildContext context,
  DeliveryOrder order,
) => showResponsiveDialog<DeliveryOrderActionResult>(
  context,
  builder: (context) => _StatusActionDialog(
    keyPrefix: 'delivery_order_ready',
    order: order,
    title: (l10n) => l10n.deliveryOrderReadyTitle(_serial(l10n, order)),
    body: (l10n, customer) => l10n.deliveryOrderReadyBody(customer),
    action: (l10n) => l10n.deliveryOrderReadyAction,
    run: (actions) => actions.markReady(order.id),
  ),
);

/// A confirmation with no field that runs one status action and closes on
/// any outcome.
class _StatusActionDialog extends ConsumerStatefulWidget {
  const _StatusActionDialog({
    required this.keyPrefix,
    required this.order,
    required this.title,
    required this.body,
    required this.action,
    required this.run,
  });

  /// `<prefix>_dialog` and `<prefix>_submit` are the dialog's keys.
  final String keyPrefix;
  final DeliveryOrder order;
  final String Function(AppLocalizations l10n) title;
  final String Function(AppLocalizations l10n, String customer) body;
  final String Function(AppLocalizations l10n) action;
  final Future<AppError?> Function(DeliveryOrderActions actions) run;

  @override
  ConsumerState<_StatusActionDialog> createState() =>
      _StatusActionDialogState();
}

class _StatusActionDialogState extends ConsumerState<_StatusActionDialog> {
  bool _busy = false;

  Future<void> _submit() async {
    if (_busy) return;
    final navigator = Navigator.of(context);
    setState(() => _busy = true);
    final error = await widget.run(
      ref.read(deliveryOrderActionsProvider.notifier),
    );
    if (!mounted) return;
    navigator.pop((error: error));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ResponsiveDialog(
      key: Key('${widget.keyPrefix}_dialog'),
      title: widget.title(l10n),
      dismissible: !_busy,
      body: Text(
        widget.body(l10n, _customerName(ref, widget.order.customerId)),
        key: Key('${widget.keyPrefix}_body'),
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.deliveryOrderBackButton,
        onPressed: _busy ? null : () => Navigator.of(context).pop(),
      ),
      primaryAction: ResponsiveDialogAction(
        key: Key('${widget.keyPrefix}_submit'),
        label: widget.action(l10n),
        busy: _busy,
        onPressed: _submit,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Line quantity and remove (C8, FR-013)
// ---------------------------------------------------------------------------

/// Changes [line]'s quantity on draft [orderId]. `true` once saved.
///
/// The client checks only that the quantity is above 0. The upper bound is
/// the server's: `delivery_order.quantity_exceeds_remaining` already
/// excludes this line's own quantity from `remaining`, so its message states
/// the line's true maximum (research R10). Every refusal shows inline and
/// keeps the dialog open.
///
/// [saleId] is the line's sale, when the screen knows it (the user has Sales
/// Orders read): the sale's ordered quantity is then shown above the field.
Future<bool> showDeliveryOrderLineQuantityDialog(
  BuildContext context, {
  required int orderId,
  required DeliveryOrderLine line,
  int? saleId,
}) async =>
    await showResponsiveDialog<bool>(
      context,
      builder: (context) =>
          _LineQuantityDialog(orderId: orderId, line: line, saleId: saleId),
    ) ??
    false;

class _LineQuantityDialog extends ConsumerStatefulWidget {
  const _LineQuantityDialog({
    required this.orderId,
    required this.line,
    required this.saleId,
  });

  final int orderId;
  final DeliveryOrderLine line;
  final int? saleId;

  @override
  ConsumerState<_LineQuantityDialog> createState() =>
      _LineQuantityDialogState();
}

class _LineQuantityDialogState extends ConsumerState<_LineQuantityDialog> {
  late final _quantity = TextEditingController(
    text: ref
        .read(formattersProvider)
        .field
        .quantity(widget.line.quantity.toString()),
  );
  String? _ordered;
  bool _busy = false;
  AppError? _refusal;

  @override
  void initState() {
    super.initState();
    unawaited(_loadOrdered());
  }

  @override
  void dispose() {
    _quantity.dispose();
    super.dispose();
  }

  /// The sale line's quantity, for the hint. Best effort: without it the
  /// hint is simply left out.
  Future<void> _loadOrdered() async {
    final saleId = widget.saleId;
    final detailId = widget.line.salesOrderDetailId;
    if (saleId == null || detailId == null) return;
    try {
      final sale = await ref
          .read(salesOrderRepositoryProvider)
          .getById(saleId: saleId);
      final ordered = sale.lines
          .where((l) => l.id == detailId)
          .firstOrNull
          ?.quantity;
      if (mounted && ordered != null) setState(() => _ordered = ordered);
    } on Object {
      // The hint is optional; the dialog works without it.
    }
  }

  Decimal? get _value {
    final parsed = ref
        .read(formattersProvider)
        .field
        .parseQuantity(_quantity.text);
    return parsed == null ? null : Decimal.parse(parsed);
  }

  bool get _valid => (_value ?? Decimal.zero) > Decimal.zero;

  bool get _canSave => !_busy && _valid && _value != widget.line.quantity;

  Future<void> _save() async {
    final value = _value;
    if (!_canSave || value == null) return;
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
      _refusal = null;
    });
    final error = await ref
        .read(deliveryOrderActionsProvider.notifier)
        .updateLine(widget.orderId, lineId: widget.line.id, quantity: value);
    if (!mounted) return;
    if (error == null) {
      navigator.pop(true);
      return;
    }
    setState(() {
      _busy = false;
      _refusal = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final fmt = ref.watch(formattersProvider);
    final line = widget.line;

    return ResponsiveDialog(
      key: const Key('delivery_order_line_quantity_dialog'),
      title: l10n.deliveryOrderLineQuantityTitle,
      dismissible: !_busy,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          Text('${line.productCode} ${line.productName}'),
          if (_ordered != null)
            Text(
              l10n.deliveryOrderLineQuantityOrdered(
                fmt.display.quantity(_ordered),
              ),
              key: const Key('delivery_order_line_quantity_ordered'),
            ),
          TextField(
            key: const Key('delivery_order_line_quantity_field'),
            controller: _quantity,
            enabled: !_busy,
            autofocus: true,
            textAlign: TextAlign.end,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.deliveryOrderLineQuantityLabel,
              errorText: _valid ? null : l10n.deliveryOrderLineQuantityInvalid,
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _save(),
          ),
          if (_refusal != null) DeliveryOrderRefusal(error: _refusal!),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.cancelButton,
        onPressed: _busy ? null : () => Navigator.of(context).pop(false),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('delivery_order_line_quantity_submit'),
        label: l10n.saveButton,
        busy: _busy,
        onPressed: _canSave ? _save : null,
      ),
    );
  }
}

/// Asks before removing [line] from draft [orderId], naming the product and
/// saying its quantity becomes available again, then removes it. `true` once
/// removed; a refusal shows inline and keeps the dialog open.
Future<bool> showRemoveDeliveryOrderLineDialog(
  BuildContext context, {
  required int orderId,
  required DeliveryOrderLine line,
}) async =>
    await showResponsiveDialog<bool>(
      context,
      builder: (context) => _RemoveLineDialog(orderId: orderId, line: line),
    ) ??
    false;

class _RemoveLineDialog extends ConsumerStatefulWidget {
  const _RemoveLineDialog({required this.orderId, required this.line});

  final int orderId;
  final DeliveryOrderLine line;

  @override
  ConsumerState<_RemoveLineDialog> createState() => _RemoveLineDialogState();
}

class _RemoveLineDialogState extends ConsumerState<_RemoveLineDialog> {
  bool _busy = false;
  AppError? _refusal;

  Future<void> _remove() async {
    if (_busy) return;
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
      _refusal = null;
    });
    final error = await ref
        .read(deliveryOrderActionsProvider.notifier)
        .removeLine(widget.orderId, lineId: widget.line.id);
    if (!mounted) return;
    if (error == null) {
      navigator.pop(true);
      return;
    }
    setState(() {
      _busy = false;
      _refusal = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;

    return ResponsiveDialog(
      key: const Key('delivery_order_line_remove_dialog'),
      title: l10n.deliveryOrderLineRemoveTitle(widget.line.productName),
      dismissible: !_busy,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          Text(l10n.deliveryOrderLineRemoveBody),
          if (_refusal != null) DeliveryOrderRefusal(error: _refusal!),
        ],
      ),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.cancelButton,
        onPressed: _busy ? null : () => Navigator.of(context).pop(false),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('delivery_order_line_remove_submit'),
        label: l10n.deliveryOrderLineRemoveAction,
        busy: _busy,
        onPressed: _remove,
      ),
    );
  }
}
