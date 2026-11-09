import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/sales/data/customer_refund_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_refund.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// What [openOrResume] decided (spec 057 contracts C3).
sealed class RefundStart {
  const RefundStart();
}

/// A draft refund exists for the order: [resumed] when it was already there,
/// `false` when it was just opened.
class RefundOpened extends RefundStart {
  const RefundOpened(this.refundId, {required this.resumed});
  final int refundId;
  final bool resumed;
}

/// The order cannot be refunded. [serverDetail] is only ever shown, never
/// parsed (R3); it is set for [RefundRefusal.nothingToReturn].
class RefundRefused extends RefundStart {
  const RefundRefused(this.reason, [this.serverDetail]);
  final RefundRefusal reason;
  final String? serverDetail;
}

/// Resumes the order's draft refund, or opens a new one (spec 057 R2, R3).
/// Refusals are classified from the order's own status, never from the
/// server's prose; any error other than a `409` on the open is rethrown.
Future<RefundStart> openOrResume(WidgetRef ref, int salesOrderId) async {
  final refunds = ref.read(customerRefundRepositoryProvider);

  final drafts = await refunds.list(
    salesOrderId: salesOrderId,
    status: RefundStatus.draft,
    skip: 0,
    limit: 1,
  );
  if (drafts.items.isNotEmpty) {
    return RefundOpened(drafts.items.first.id, resumed: true);
  }

  final Sale order;
  try {
    order = await ref
        .read(salesOrderRepositoryProvider)
        .getById(saleId: salesOrderId);
  } on NotFoundError {
    return const RefundRefused(RefundRefusal.orderNotFound);
  }
  switch (order.status) {
    case SaleStatus.draft:
    case SaleStatus.cancelled:
      return const RefundRefused(RefundRefusal.notCompleted);
    case SaleStatus.completed:
      return const RefundRefused(RefundRefusal.notPaid);
    case SaleStatus.paid:
      break;
  }

  try {
    final refund = await refunds.open(salesOrderId);
    return RefundOpened(refund.id, resumed: false);
  } on ServerError catch (e) {
    if (e.statusCode == 409) {
      return RefundRefused(RefundRefusal.nothingToReturn, e.message);
    }
    rethrow;
  }
}

/// The shared "tap Devolver" handler (spec 057 T017/T018): resumes or opens
/// the order's refund and navigates to it, or shows why it cannot be refunded.
Future<void> startRefundFromOrder(
  BuildContext context,
  WidgetRef ref,
  int orderId,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final router = GoRouter.of(context);
  final l10n = AppLocalizations.of(context)!;
  String message;
  try {
    switch (await openOrResume(ref, orderId)) {
      case RefundOpened(:final refundId):
        router.push('/sales/refunds/$refundId');
        return;
      case RefundRefused(:final reason, :final serverDetail):
        message = switch (reason) {
          RefundRefusal.orderNotFound => l10n.refundRefusalOrderNotFound(
            orderId,
          ),
          RefundRefusal.notCompleted => l10n.refundRefusalNotCompleted(orderId),
          RefundRefusal.notPaid => l10n.refundRefusalNotPaid(orderId),
          RefundRefusal.nothingToReturn => l10n.refundRefusalNothingToReturn(
            orderId,
          ),
        };
        if (reason == RefundRefusal.nothingToReturn && serverDetail != null) {
          message = '$message $serverDetail';
        }
    }
  } on AppError catch (e) {
    message = e.serverMessage ?? l10n.refundsLoadError;
  }
  messenger.showSnackBar(SnackBar(content: Text(message)));
}

/// Whether the "Devolver" button is offered for [sale] (spec 057 R9): the
/// order is paid and the user can both open a refund and read it afterwards.
/// Otherwise the button is not built at all.
bool canStartRefund(AccessControlService access, Sale sale) =>
    sale.isPaid &&
    access.can(SystemObject.customerRefunds, AccessRight.create) &&
    access.can(SystemObject.customerRefunds, AccessRight.read);

/// The "Devolver" button on a paid order (spec 057 T017, T018). A tap shows a
/// spinner while [startRefundFromOrder] runs. Callers build it only when
/// [canStartRefund] holds.
class RefundOrderButton extends ConsumerStatefulWidget {
  const RefundOrderButton({super.key, required this.orderId});

  final int orderId;

  @override
  ConsumerState<RefundOrderButton> createState() => _RefundOrderButtonState();
}

class _RefundOrderButtonState extends ConsumerState<RefundOrderButton> {
  bool _busy = false;

  Future<void> _start() async {
    setState(() => _busy = true);
    try {
      await startRefundFromOrder(context, ref, widget.orderId);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return OutlinedButton.icon(
      key: const Key('order_refund_button'),
      onPressed: _busy ? null : _start,
      icon: _busy
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.assignment_return_outlined),
      label: Text(l10n.refundAction),
    );
  }
}
