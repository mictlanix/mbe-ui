import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_order_approval/approval_target.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_order_actions.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_order_dialogs.dart'
    show DeliveryOrderRefusal;
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_order_name_cells.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_order_status_chip.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

// The two dialogs shared by the approval queue's row icons and the delivery
// order detail screen (spec 062 C3, C4, R5). Each runs its own write through
// `DeliveryOrderActions` and answers the status the server put the order in.

/// Asks before approving [target], naming its customer, type and scheduled
/// date and where it goes next, then approves it (FR-008).
///
/// Answers the order's new status once the server accepted, so the caller can
/// say so (FR-009). Answers `null` when the user backed out, or closed the
/// dialog after a refusal: a refusal stays inside the dialog (R5), so the
/// caller has nothing to show.
Future<DeliveryOrderStatus?> showApproveDeliveryOrderDialog(
  BuildContext context,
  ApprovalTarget target,
) => showResponsiveDialog<DeliveryOrderStatus>(
  context,
  builder: (context) => _DecisionDialog(
    keyPrefix: 'delivery_order_approve',
    target: target,
    title: (l10n) => l10n.deliveryOrderApproveTitle(target.folio),
    actionLabel: (l10n) => l10n.deliveryOrderApproveAction,
    run: (actions, _) => actions.approve(target.id),
    body: (context, l10n) => [
      _ApproveFacts(target: target),
      Text(
        target.type == FulfillmentType.counterPickup
            ? l10n.deliveryOrderApproveNextPickup
            : l10n.deliveryOrderApproveNextDelivery,
        key: const Key('delivery_order_approve_next'),
      ),
    ],
  ),
);

/// Asks for a reason, then rejects [target] back to its author as a draft
/// (FR-010, FR-011).
///
/// The confirm button stays disabled while the trimmed reason is empty, and
/// the field takes at most 500 characters. Answers the order's new status
/// (always Borrador) once the server accepted, and `null` when the user
/// backed out or closed the dialog after a refusal, as
/// [showApproveDeliveryOrderDialog] does.
Future<DeliveryOrderStatus?> showRejectDeliveryOrderDialog(
  BuildContext context,
  ApprovalTarget target,
) => showResponsiveDialog<DeliveryOrderStatus>(
  context,
  builder: (context) => _DecisionDialog(
    keyPrefix: 'delivery_order_reject',
    target: target,
    title: (l10n) => l10n.deliveryOrderRejectTitle(target.folio),
    actionLabel: (l10n) => l10n.deliveryOrderRejectAction,
    reasonLabel: (l10n) => l10n.deliveryOrderRejectReasonLabel,
    run: (actions, reason) => actions.reject(target.id, reason: reason),
    body: (context, l10n) => [_RejectSummary(target: target)],
    footer: (context, l10n) => [
      Text(
        l10n.deliveryOrderRejectNote,
        key: const Key('delivery_order_reject_note'),
      ),
    ],
  ),
);

/// One decision on an order: a body, an optional required reason, and a
/// single write.
///
/// A refusal stays in the dialog and turns the primary button into "Cerrar",
/// since the queue or the detail screen has already reloaded behind it and
/// there is nothing left to confirm. A lost connection says the result is
/// unknown rather than claiming a failure (spec Edge Cases).
class _DecisionDialog extends ConsumerStatefulWidget {
  const _DecisionDialog({
    required this.keyPrefix,
    required this.target,
    required this.title,
    required this.actionLabel,
    required this.run,
    required this.body,
    this.footer,
    this.reasonLabel,
  });

  final String keyPrefix;
  final ApprovalTarget target;
  final String Function(AppLocalizations l10n) title;
  final String Function(AppLocalizations l10n) actionLabel;

  /// Runs the write. The reason is trimmed, and empty when the dialog asks
  /// for none.
  final Future<ApprovalOutcome> Function(
    DeliveryOrderActions actions,
    String reason,
  )
  run;

  /// The content above the reason field.
  final List<Widget> Function(BuildContext context, AppLocalizations l10n) body;

  /// The content below the reason field, before any refusal.
  final List<Widget> Function(BuildContext context, AppLocalizations l10n)?
  footer;

  /// When set, the dialog asks for a reason and refuses to submit without one.
  final String Function(AppLocalizations l10n)? reasonLabel;

  @override
  ConsumerState<_DecisionDialog> createState() => _DecisionDialogState();
}

class _DecisionDialogState extends ConsumerState<_DecisionDialog> {
  final _reason = TextEditingController();
  bool _busy = false;
  AppError? _refusal;

  bool get _needsReason => widget.reasonLabel != null;

  bool get _canSubmit =>
      !_busy && (!_needsReason || _reason.text.trim().isNotEmpty);

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;
    final navigator = Navigator.of(context);
    setState(() => _busy = true);
    final outcome = await widget.run(
      ref.read(deliveryOrderActionsProvider.notifier),
      _reason.text.trim(),
    );
    if (!mounted) return;
    final status = outcome.status;
    if (outcome.error == null && status != null) {
      navigator.pop(status);
      return;
    }
    setState(() {
      _busy = false;
      _refusal = outcome.error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final refusal = _refusal;
    final prefix = widget.keyPrefix;
    final reasonLabel = widget.reasonLabel;

    return ResponsiveDialog(
      key: Key('${prefix}_dialog'),
      title: widget.title(l10n),
      dismissible: !_busy,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          ...widget.body(context, l10n),
          if (reasonLabel != null)
            TextField(
              key: Key('${prefix}_reason'),
              controller: _reason,
              enabled: !_busy && refusal == null,
              autofocus: true,
              minLines: 2,
              maxLines: 4,
              maxLength: _maxReasonLength,
              decoration: InputDecoration(labelText: reasonLabel(l10n)),
              onChanged: (_) => setState(() {}),
            ),
          ...?widget.footer?.call(context, l10n),
          if (refusal != null) DeliveryOrderRefusal(error: refusal),
        ],
      ),
      secondaryAction: refusal != null
          ? null
          : ResponsiveDialogAction(
              label: l10n.deliveryOrderBackButton,
              onPressed: _busy ? null : () => Navigator.of(context).pop(),
            ),
      primaryAction: refusal != null
          ? ResponsiveDialogAction(
              key: Key('${prefix}_close'),
              label: MaterialLocalizations.of(context).closeButtonLabel,
              onPressed: () => Navigator.of(context).pop(),
            )
          : ResponsiveDialogAction(
              key: Key('${prefix}_submit'),
              label: widget.actionLabel(l10n),
              busy: _busy,
              onPressed: _canSubmit ? _submit : null,
            ),
    );
  }
}

/// The server's `rejection_reason` column holds 500 characters (spec 062
/// data-model §5).
const _maxReasonLength = 500;

/// Customer, type and scheduled date: what a supervisor checks before
/// approving (FR-008).
class _ApproveFacts extends ConsumerWidget {
  const _ApproveFacts({required this.target});

  final ApprovalTarget target;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final fmt = ref.watch(formattersProvider);

    Widget fact(String label, Widget value) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: [
        SizedBox(
          width: 96,
          child: Text(label, style: Theme.of(context).textTheme.labelMedium),
        ),
        Expanded(child: value),
      ],
    );

    return Column(
      key: const Key('delivery_order_approve_facts'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: spacing.sm,
      children: [
        fact(
          l10n.deliveryOrderColumnCustomer,
          DeliveryOrderCustomerName(
            customerId: target.customerId,
            name: target.customerName,
          ),
        ),
        fact(
          l10n.deliveryOrderColumnType,
          Text(deliveryOrderTypeLabel(l10n, target.type)),
        ),
        fact(
          l10n.deliveryOrderColumnScheduled,
          Text(fmt.display.date(target.date)),
        ),
      ],
    );
  }
}

/// The customer and scheduled date of the order being rejected (C4).
class _RejectSummary extends ConsumerWidget {
  const _RejectSummary({required this.target});

  final ApprovalTarget target;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final fmt = ref.watch(formattersProvider);
    // The name needs Customers read: without it, or while it loads, the
    // number stands in (spec 061 R4).
    final customer =
        ref.watch(customerDisplayNameProvider(target.customerId)).value ??
        '#${target.customerId}';
    return Text(
      l10n.deliveryOrderRejectSummary(customer, fmt.display.date(target.date)),
      key: const Key('delivery_order_reject_summary'),
    );
  }
}
