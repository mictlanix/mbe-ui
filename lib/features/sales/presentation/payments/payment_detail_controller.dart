import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/sales/data/customer_payment_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_payment.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';
import 'package:mbe_ui/features/sales/presentation/register_controller.dart';

/// One payment, for its own screen (spec 054 US2).
///
/// **The facility guard lives here** (FR-013b, research R4). mbe-api does not
/// check the caller's facility on `GET /customer-payments/{id}`
/// (mbe-api#271), so any Customer Payments reader could open any facility's
/// payment by typing its id. A payment outside the user's own facility is
/// therefore refused as [AppError.notFound] — the same answer as for an id
/// that doesn't exist, so the screen doesn't confirm that it exists
/// elsewhere — unless the user can search across facilities (Payments Editor
/// read). A user with no facility of their own matches nothing, so only an
/// editor gets through.
///
/// Don't relax this to "the server will check": until #271 ships this is the
/// only protection, and afterwards it stays as defence in depth.
final paymentDetailProvider = FutureProvider.family<CustomerPayment, int>((
  ref,
  customerPaymentId,
) async {
  final payment = await ref
      .watch(customerPaymentRepositoryProvider)
      .get(customerPaymentId: customerPaymentId);
  final ownFacility = ref.watch(userFacilityIdProvider);
  final canSeeAnyFacility = ref
      .watch(accessControlProvider)
      .can(SystemObject.paymentsEditor, AccessRight.read);
  if (payment.facilityId != ownFacility && !canSeeAnyFacility) {
    throw const AppError.notFound();
  }
  return payment;
});

/// The payment's applications, reversed ones included.
///
/// Waits on [paymentDetailProvider], so a payment the guard refuses never has
/// its applications requested — the guard is enforced by the data, not left
/// to the screen remembering to check first. It is also a separate provider
/// so that a failure here leaves the payment's own fields on screen, with only
/// the applications section in its error state.
final paymentApplicationsProvider =
    FutureProvider.family<List<PaymentApplication>, int>((
      ref,
      customerPaymentId,
    ) async {
      await ref.watch(paymentDetailProvider(customerPaymentId).future);
      return ref
          .watch(customerPaymentRepositoryProvider)
          .listApplications(customerPaymentId: customerPaymentId);
    });

/// The sum of the applications that still stand — a reversed application stays
/// listed as evidence but no longer counts (FR-013a, FR-014). Summed in
/// decimal, never in `double`.
String appliedTotal(List<PaymentApplication> applications) => applications
    .where((a) => !a.reversed)
    .fold('0', (total, a) => addAmounts(total, a.amount));
