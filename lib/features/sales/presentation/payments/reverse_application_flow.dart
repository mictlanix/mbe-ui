import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/sales/data/customer_refund_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_refund.dart';
import 'package:mbe_ui/features/sales/presentation/payment/reversal_reason_dialog.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payment_editor_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Whether [saleId] has a completed refund, so the reverse dialog can warn that
/// reversing the payment doesn't undo it (spec 059 FR-004, R4).
///
/// The order's own response carries nothing about refunds, so this asks the
/// refunds list for one completed refund of the order. It answers `false`
/// when it can't tell: the user can't read refunds, or the lookup failed. The
/// warning is a caution, not a gate, and the server allows the reversal either
/// way, so a missing warning must never block one.
final orderHasRefundsProvider = FutureProvider.family<bool, int>((
  ref,
  saleId,
) async {
  final canRead = ref
      .watch(accessControlProvider)
      .can(SystemObject.customerRefunds, AccessRight.read);
  if (!canRead) return false;
  try {
    final page = await ref
        .watch(customerRefundRepositoryProvider)
        .list(
          salesOrderId: saleId,
          status: RefundStatus.completed,
          skip: 0,
          limit: 1,
        );
    return page.total > 0;
  } on AppError {
    return false;
  }
});

/// The back office's whole reversal of one application (spec 059 FR-002,
/// FR-004, FR-017): look for refunds, ask for the reason, send it, and say it
/// is done.
///
/// A refusal from the server shows inside the dialog, which stays open; the
/// screens behind it have already been reloaded by [PaymentEditor] (FR-009).
/// Returns whether the application was reversed.
///
/// [amount] is the application's amount already formatted for display. [ref]
/// must belong to a widget that outlives the write: the dialog calls it when
/// the user confirms, after this function's caller may have rebuilt.
Future<bool> reverseApplicationFlow(
  BuildContext context,
  WidgetRef ref, {
  required int paymentId,
  required int applicationId,
  required int saleId,
  required String amount,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final done = AppLocalizations.of(context)!.paymentReverseDone;
  final hasRefunds = await ref.read(orderHasRefundsProvider(saleId).future);
  if (!context.mounted) return false;
  final reason = await showReversalReasonDialog(
    context,
    amount: amount,
    orderId: saleId,
    orderHasRefunds: hasRefunds,
    submit: (reason) => ref
        .read(paymentEditorProvider.notifier)
        .reverse(
          paymentId: paymentId,
          applicationId: applicationId,
          saleId: saleId,
          reason: reason,
        ),
  );
  if (reason == null) return false;
  messenger.showSnackBar(SnackBar(content: Text(done)));
  return true;
}
