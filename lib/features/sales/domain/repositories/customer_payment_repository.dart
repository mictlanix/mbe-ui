import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_payment.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_payment.dart';

/// Taking money and applying it to a sale (contracts/mbe-api-pos.md §1, §3).
///
/// [createPayment] and [applyPayment] are always called as a pair — the
/// tender is recorded, then applied to the order; one logical action
/// (FR-046). They stay two methods here because they are two endpoints and
/// the second can fail on its own (wrong currency, order not confirmed),
/// which the caller has to surface distinctly.
abstract class CustomerPaymentRepository {
  /// `POST /customer-payments` — records the tender. The cashier's open cash
  /// session is attached server-side; by this feature's own precondition
  /// (contracts/pos-screen.md §0) one always exists by now. Returns the new
  /// payment's id, which [applyPayment] needs.
  Future<int> createPayment({
    required int customer,
    required String amount,
    required int method,
    Currency? currency,
    int? paymentCharge,
    String? reference,
  });

  /// `POST /customer-payments/{id}/applications` — applies the tender to the
  /// sale. [amountChange] is the excess handed back on a cash tender
  /// (FR-047); it does **not** consume the payment's unapplied amount.
  Future<void> applyPayment({
    required int customerPaymentId,
    required int salesOrder,
    required String amount,
    String? amountChange,
  });

  /// `POST /customer-payments/{id}/applications/{applicationId}/reverse` —
  /// [reason] is mandatory, 1–500 chars (FR-048).
  Future<void> reverseApplication({
    required int customerPaymentId,
    required int applicationId,
    required String reason,
  });

  /// `GET /sales-orders/{id}/payments` — every application against the sale,
  /// cancelled ones included (research.md §11). Not session-scoped.
  Future<List<SalePayment>> listForOrder({required int saleId});

  /// What the customer still owes across all their open orders — FR-011's
  /// "outstanding balance" in the customer area.
  ///
  /// Summed client-side from `GET /customer-payments/outstanding-orders`,
  /// which is per-order: mbe-api exposes no aggregate on the customer itself
  /// (`CustomerResponse` carries only `creditLimit`/`creditDays`). Pages
  /// until every outstanding order is counted, so the figure is the whole
  /// balance rather than the first page of it.
  Future<String> outstandingBalanceFor({required int customerId});

  /// `GET /customer-payments` — the **facility-scoped** list (spec 054 FR-004,
  /// R4), newest first. [facilityId] is required so no caller can lean on the
  /// server's implicit default or forget the scope: mbe-api honours any
  /// `facility` it is sent (mbe-api#271), so the client is the only thing
  /// keeping a user inside their own facility. [verified] is tri-state — `null`
  /// lists both, `true` only verified, `false` only unverified.
  /// [dateFrom]/[dateTo] are inclusive wall-clock days. [search] matches part
  /// of the customer's name, ignoring case, and combines with every other
  /// filter (mbe-api#270); blank is no search.
  Future<CustomerPaymentListResult> list({
    required int facilityId,
    int? customerId,
    int? cashSessionId,
    DateTime? dateFrom,
    DateTime? dateTo,
    int? methodCode,
    bool? verified,
    String? search,
    int skip = 0,
    int limit = 20,
  });

  /// `GET /customer-payments/search` — crosses facilities, so mbe-api gates it
  /// behind Payments Editor read. [reference] matches as a case-insensitive
  /// substring.
  Future<CustomerPaymentListResult> searchAcrossFacilities({
    int? customerId,
    String? reference,
    DateTime? dateFrom,
    DateTime? dateTo,
    int skip = 0,
    int limit = 20,
  });

  /// `GET /customer-payments/{id}`. A missing payment is
  /// [AppError.notFound]. mbe-api does not check the caller's facility here
  /// (mbe-api#271), so the screen applies its own guard (spec 054 R4).
  Future<CustomerPayment> get({required int customerPaymentId});

  /// `GET /customer-payments/{id}/applications` — every application,
  /// reversed ones included, in the server's order.
  Future<List<PaymentApplication>> listApplications({
    required int customerPaymentId,
  });
}

/// One page of [CustomerPayment]s and the total across all pages — the same
/// shape as `CashSessionListResult`.
class CustomerPaymentListResult {
  const CustomerPaymentListResult({required this.items, required this.total});
  final List<CustomerPayment> items;
  final int total;
}
