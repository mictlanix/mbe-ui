import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/sales/presentation/payment/applied_payments_panel.dart';
import 'package:mbe_ui/features/sales/presentation/payment/order_payments_controller.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payment_widgets.dart';
import 'package:mbe_ui/features/sales/presentation/payments/reverse_application_flow.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The payments applied to a back-office order, with the power to reverse one
/// and to open its payment (spec 059 C6, US3).
///
/// A dialog launched from the order header rather than a panel of the
/// workspace: the workspace has no rail of its own, and this is a short list
/// the user looks at and leaves. The list is the one the register's sale
/// detail shows; what is new is that a reversal here refreshes the order, so
/// its status follows (FR-017).
Future<void> showOrderPaymentsDialog(
  BuildContext context, {
  required int orderId,
}) => showDialog<void>(
  context: context,
  builder: (context) => _OrderPaymentsDialog(orderId: orderId),
);

class _OrderPaymentsDialog extends ConsumerWidget {
  const _OrderPaymentsDialog({required this.orderId});

  final int orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final access = ref.watch(accessControlProvider);
    final fmt = ref.watch(formattersProvider);
    final canRead = access.can(SystemObject.customerPayments, AccessRight.read);
    final canReverse = access.can(
      SystemObject.customerPayments,
      AccessRight.update,
    );

    return ResponsiveDialog(
      key: const Key('sales_order_payments_dialog'),
      title: l10n.salesOrderPaymentsTitle('$orderId'),
      maxWidth: 560,
      body:
          !canRead ||
              _isForbidden(ref.watch(orderPaymentsControllerProvider(orderId)))
          ? Padding(
              padding: EdgeInsets.all(spacing.sm),
              child: Text(l10n.posSaleDetailPaymentsForbidden),
            )
          : AppliedPaymentsPanel(
              saleId: orderId,
              enabled: canReverse,
              showChangeAndDate: true,
              onReverse: (payment) => reverseApplicationFlow(
                context,
                ref,
                paymentId: payment.customerPayment,
                applicationId: payment.id,
                saleId: orderId,
                amount: paymentAmountLabel(
                  fmt,
                  payment.amount,
                  payment.currency,
                ),
              ),
              onOpenPayment: (paymentId) {
                Navigator.of(context).pop();
                context.push('/sales/payments/$paymentId');
              },
            ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('sales_order_payments_close'),
        label: MaterialLocalizations.of(context).closeButtonLabel,
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  /// A user the server refuses the list (403) sees the same words the
  /// register's sale detail shows, rather than a failed panel.
  bool _isForbidden(AsyncValue<Object?> payments) {
    final error = payments.error;
    return error != null &&
        switch (toAppError(error)) {
          ServerError(statusCode: 403) => true,
          _ => false,
        };
  }
}
