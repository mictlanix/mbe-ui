import 'package:mbe_ui/core/domain/currency.dart';
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
}
