import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/core/domain/payment_method.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';

part 'sale_payment.freezed.dart';

/// One payment applied to the sale (data-model.md §7), mapped from
/// `OrderApplicationResponse` — the sale's own payments listing
/// (`GET /sales-orders/{id}/payments`, mbe-api#134), **not** session state.
/// Cancelled applications stay in the list: a reversal remains visible
/// (research.md §11).
///
/// data-model.md §7 also lists `paymentChargeId` and `methodLabel` (the
/// facility's own wording for the chosen payment-method option). The
/// generated `OrderApplicationResponse` carries neither — it exposes the SAT
/// `method` code but not the `payment_charge` FK it was taken under — so
/// neither is mapped here. [method] renders through the shared
/// `paymentMethodLabel`, which is the SAT catalog wording rather than the
/// facility's own.
@freezed
class SalePayment with _$SalePayment {
  const SalePayment._();

  const factory SalePayment({
    required int id,
    required int customerPayment,
    required String amount,
    PaymentMethod? method,
    required int methodCode,
    required Currency currency,
    String? reference,
    int? verifier,
    required String changeAmount,
    required bool cancelled,
    required DateTime paymentDate,
    DateTime? date,
  }) = _SalePayment;

  factory SalePayment.fromResponse(api.OrderApplicationResponse r) {
    final code = _methodCodeFromApi(r.method);
    return SalePayment(
      id: r.salesOrderPaymentId,
      customerPayment: r.customerPayment,
      amount: r.amount,
      method: PaymentMethod.fromCode(code),
      methodCode: code,
      currency: currencyFromApi(r.currency),
      reference: r.reference,
      verifier: r.verifier,
      changeAmount: r.amountChange,
      cancelled: r.cancelled,
      paymentDate: r.paymentDate,
      date: r.date,
    );
  }

  /// data-model.md §7: a null verifier means "pending validation" — display
  /// only, it gates nothing.
  bool get isPendingValidation => verifier == null;
}

/// The generated `api.PaymentMethod` is an `EnumClass` whose members are
/// named `number0`/`number1`/`number28`/... after their wire numbers, with
/// no schema-level names to preserve — the same generator gap `PaymentTerms`
/// and `CurrencyCode` hit (see `sale.dart`). The suffix *is* the SAT code,
/// so it is parsed back out rather than switched over 15 members by hand.
int _methodCodeFromApi(api.PaymentMethod value) =>
    int.tryParse(value.name.replaceFirst('number', '')) ?? 0;
