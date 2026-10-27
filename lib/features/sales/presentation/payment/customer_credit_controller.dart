import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/config/app_settings_provider.dart';
import 'package:mbe_ui/features/sales/data/credit_note_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/credit_note.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';
import 'package:mbe_ui/features/sales/presentation/payment/order_payments_controller.dart';
import 'package:mbe_ui/features/sales/presentation/pos_sale_controller.dart';

part 'customer_credit_controller.g.dart';

/// Whether the payment step may offer to spend credit notes on [sale] at all
/// (spec 056 FR-007, FR-014, research R7): the sale is still open to payment,
/// something is still owed, and the user can both read credit payments and
/// record customer payments.
///
/// One rule for both tiles — the named customer's balance and the walk-in
/// ticket — so it is written once. The walk-in ticket tile also needs
/// customer-payments read, because it looks the ticket's payment up.
bool creditTenderAllowed(Sale sale, AccessControlService access) =>
    sale.status != SaleStatus.cancelled &&
    compareAmounts(sale.balanceOrZero, '0') > 0 &&
    access.can(SystemObject.creditPayments, AccessRight.read) &&
    access.can(SystemObject.customerPayments, AccessRight.create);

/// A customer's spendable credit on one sale: the open notes, oldest first,
/// and what they add up to.
class CustomerCredit {
  const CustomerCredit({this.notes = const [], this.total = '0'});

  static const none = CustomerCredit();

  final List<CreditNote> notes;

  /// The sum of [notes]' server-reported `remaining`.
  final String total;
}

/// The credit a named customer can spend on a POS sale (spec 056 data-model
/// §6, research R2), keyed by sale id.
///
/// Empty — with no request — for the walk-in customer (their notes are
/// redeemed by ticket, never offered as a balance, FR-004) and whenever
/// [creditTenderAllowed] is false. Otherwise it reads every note the customer
/// holds, keeps the ones the server says have something left, and leaves out
/// any already applied to this sale (FR-001). The figures are the server's;
/// nothing here computes a remaining balance (FR-015).
///
/// `PaymentController` invalidates this after every redemption attempt, so a
/// failed or partial one never leaves a stale balance on screen (FR-008).
@riverpod
Future<CustomerCredit> customerCredit(Ref ref, int saleId) async {
  final sale = ref.watch(posSaleControllerProvider).value;
  if (sale == null || sale.id != saleId) return CustomerCredit.none;

  final access = ref.watch(accessControlProvider);
  final settings = ref.watch(appSettingsProvider);
  if (settings.isGenericCustomer(sale.customer) ||
      !creditTenderAllowed(sale, access)) {
    return CustomerCredit.none;
  }

  final applied = await ref.watch(
    orderPaymentsControllerProvider(saleId).future,
  );
  final onThisSale = {
    for (final p in applied)
      if (!p.cancelled) p.customerPayment,
  };

  final all = await ref
      .watch(creditNoteRepositoryProvider)
      .listForCustomer(sale.customer);
  final spendable = [
    for (final note in all)
      if (note.isOpen && !onThisSale.contains(note.customerPaymentId)) note,
  ];

  return CustomerCredit(
    notes: spendable,
    total: spendable.fold('0', (sum, n) => addAmounts(sum, n.remaining)),
  );
}
