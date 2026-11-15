import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/formatting/app_formatters.dart'
    show emptyValuePlaceholder;
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/record_sheet.dart';
import 'package:mbe_ui/core/widgets/responsive_form_grid.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_payment.dart';
import 'package:mbe_ui/features/sales/domain/payment_type.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payment_widgets.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Opens [payment] read-only in the shared side panel, over the queue
/// (spec 060 C4, FR-005a).
///
/// **A deliberate §VI deviation, recorded in `plan.md` Complexity Tracking.**
/// A customer payment's own surface is the Pagos full screen. This is a
/// second one, because the queue spans every facility and that screen refuses
/// another facility's payment to a verifier without Payments Editor read. The
/// panel is built from the row the queue already loaded, with no request for
/// the payment, so it opens for every row. It has no action besides close:
/// the row's own icons verify and reject.
Future<void> showVerificationPaymentPanel(
  BuildContext context,
  CustomerPayment payment,
) => showRecordSheet(
  context,
  title: AppLocalizations.of(
    context,
  )!.paymentHeaderTitle(payment.customerPaymentId),
  isDirty: () => false,
  form: (_) => VerificationPaymentPanel(payment: payment),
);

/// The read-only body of [showVerificationPaymentPanel]: every field comes
/// from [payment]. Only names are looked up (facility), and they fall back to
/// the number.
class VerificationPaymentPanel extends ConsumerWidget {
  const VerificationPaymentPanel({super.key, required this.payment});

  final CustomerPayment payment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final fmt = ref.watch(formattersProvider);

    Widget labeled(String label, Widget child) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        child,
      ],
    );

    return Padding(
      key: Key('verification_panel_${payment.customerPaymentId}'),
      padding: EdgeInsets.all(spacing.screenMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.sectionGap,
        children: [
          PaymentVerifiedChip(verified: payment.isVerified),
          ResponsiveFormGrid(
            maxColumns: 2,
            spacing: spacing.fieldGapHorizontal,
            alignment: AlignmentDirectional.centerStart,
            children: [
              FormGridChild(
                labeled(
                  l10n.paymentFieldFacility,
                  _FacilityName(facilityId: payment.facilityId),
                ),
              ),
              FormGridChild(
                labeled(
                  l10n.paymentsColumnDate,
                  Text(fmt.display.dateTime(payment.date)),
                ),
              ),
              FormGridChild(
                labeled(
                  l10n.paymentsColumnCustomer,
                  PaymentCustomerName(
                    customerId: payment.customerId,
                    name: payment.customerName,
                  ),
                ),
              ),
              FormGridChild(
                labeled(
                  l10n.paymentsColumnType,
                  Text(paymentTypeLabel(l10n, payment.type)),
                ),
              ),
              FormGridChild(
                labeled(
                  l10n.paymentsColumnMethod,
                  PaymentMethodText(payment: payment),
                ),
              ),
              FormGridChild(
                labeled(
                  l10n.paymentsColumnReference,
                  Text(payment.reference ?? emptyValuePlaceholder),
                ),
              ),
              FormGridChild(
                labeled(
                  l10n.paymentsColumnAmount,
                  Text(
                    paymentAmountLabel(fmt, payment.amount, payment.currency),
                  ),
                ),
              ),
              FormGridChild(
                labeled(
                  l10n.paymentSummaryUnapplied,
                  Text(
                    paymentAmountLabel(
                      fmt,
                      payment.unapplied,
                      payment.currency,
                    ),
                  ),
                ),
              ),
              // Plain text, not a link: the session's own screen has its own
              // gate, and this panel opens nothing.
              if (payment.lastRejection case final rejection?)
                FormGridChild(
                  labeled(
                    l10n.paymentFieldLastRejection,
                    PaymentRejectionDetails(rejection: rejection),
                  ),
                ),
              FormGridChild(
                labeled(
                  l10n.paymentFieldCashSession,
                  Text(
                    payment.cashSessionId == null
                        ? emptyValuePlaceholder
                        : '#${payment.cashSessionId}',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A facility's name, or its number while loading and when it can't be read:
/// the name needs Facilities read, which a verifier may not hold (spec 060
/// R7), so the number is the expected fallback and never an error.
class _FacilityName extends ConsumerWidget {
  const _FacilityName({required this.facilityId});

  final int facilityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Text(
    ref.watch(facilityDisplayNameProvider(facilityId)).value ?? '#$facilityId',
  );
}
