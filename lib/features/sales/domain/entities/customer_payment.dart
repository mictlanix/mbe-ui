import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/core/domain/payment_method.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/payment_type.dart';

part 'customer_payment.freezed.dart';

/// A payment received from a customer, mapped from `CustomerPaymentResponse`
/// (spec 054 data-model.md §1). Read-only: the Pagos screens never write one.
///
/// Not [SalePayment]: that models an application *seen from the order*
/// (`OrderApplicationResponse`), a different resource with different fields.
@freezed
abstract class CustomerPayment with _$CustomerPayment {
  const CustomerPayment._();

  const factory CustomerPayment({
    required int customerPaymentId,
    required int customerId,

    /// The customer's name as the server joins it onto the payment, so no
    /// per-customer lookup is needed (spec 055 R2). `null` only when the
    /// customer row is missing; a blank name is treated the same way.
    String? customerName,
    required String amount,
    required Currency currency,
    required int methodCode,
    int? paymentOptionId,
    String? reference,
    required DateTime date,
    required int facilityId,
    int? cashSessionId,
    required PaymentType type,
    int? verifierId,

    /// The server's derived figure: the amount less its non-reversed
    /// applications. Never recomputed client-side.
    required String unapplied,
  }) = _CustomerPayment;

  factory CustomerPayment.fromResponse(api.CustomerPaymentResponse r) =>
      CustomerPayment(
        customerPaymentId: r.customerPaymentId,
        customerId: r.customer,
        customerName: _nonBlank(r.customerDisplayName),
        amount: r.amount,
        currency: currencyFromApi(r.currency),
        methodCode: paymentMethodCodeFromApi(r.method),
        paymentOptionId: r.paymentCharge,
        reference: r.reference,
        date: r.date,
        facilityId: r.facility,
        cashSessionId: r.cashSession,
        type: PaymentType.fromApi(r.paymentType),
        verifierId: r.verifier,
        unapplied: r.unapplied,
      );

  /// A payment is verified once someone has signed off on it.
  bool get isVerified => verifierId != null;
}

String? _nonBlank(String? value) =>
    value == null || value.trim().isEmpty ? null : value;

/// One application of a payment to a sales order, mapped from
/// `ApplicationResponse` (spec 054 data-model.md §2). A reversed application
/// stays on record as evidence, so [reversed] rows are listed but never
/// counted in the applied total.
@freezed
abstract class PaymentApplication with _$PaymentApplication {
  const factory PaymentApplication({
    required int id,
    required int saleId,
    required String amount,
    required String change,
    int? applierId,
    DateTime? date,
    required bool reversed,
  }) = _PaymentApplication;

  factory PaymentApplication.fromResponse(api.ApplicationResponse r) =>
      PaymentApplication(
        id: r.salesOrderPaymentId,
        saleId: r.salesOrder,
        amount: r.amount,
        change: r.amountChange,
        applierId: r.applier,
        date: r.date,
        reversed: r.cancelled,
      );
}
