import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/features/sales/domain/entities/credit_note.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';

part 'customer_refund.freezed.dart';

/// Lifecycle of a customer refund, mapped from `api.DocumentStatus`
/// (spec 057 data-model.md). `paid` never occurs on a refund; if it does it is
/// treated as [completed].
enum RefundStatus {
  draft,
  completed,
  cancelled;

  static RefundStatus fromApi(api.DocumentStatus value) => switch (value.name) {
    'draft' => RefundStatus.draft,
    'cancelled' => RefundStatus.cancelled,
    _ => RefundStatus.completed,
  };

  /// The string mbe-api filters on (`?status=`).
  String get wireName => switch (this) {
    RefundStatus.draft => 'draft',
    RefundStatus.completed => 'completed',
    RefundStatus.cancelled => 'cancelled',
  };
}

/// How the customer gets their money back. Has no default (spec 057 FR-008).
enum RefundPayout {
  cash,
  creditNote;

  api.RefundPayout toApi() => switch (this) {
    RefundPayout.cash => api.RefundPayout.cash,
    RefundPayout.creditNote => api.RefundPayout.creditNote,
  };
}

/// Why a refund cannot be opened, derived on the client (spec 057 R3).
enum RefundRefusal { orderNotFound, notCompleted, notPaid, nothingToReturn }

/// What a completed refund shows about its payout (spec 057 R6). Interim
/// until mbe-api#286.
@freezed
sealed class RefundOutcome with _$RefundOutcome {
  const factory RefundOutcome.cash() = RefundOutcomeCash;
  const factory RefundOutcome.creditNote(CreditNote note) =
      RefundOutcomeCreditNote;
  const factory RefundOutcome.unknown() = RefundOutcomeUnknown;
}

/// One line of a [CustomerRefund], mapped from `CustomerRefundLineResponse`.
/// Amounts and quantities stay as the server's strings.
@freezed
abstract class RefundLine with _$RefundLine {
  const factory RefundLine({
    required int id,
    required int salesOrderLineId,
    required int productId,
    required String productCode,
    required String productName,

    /// The return quantity.
    required String quantity,

    /// The stepper's maximum (FR-007).
    required String refundableQuantity,
    required String price,
    required String discount,
    required String taxRate,
    required bool taxIncluded,

    /// The return-to warehouse.
    int? warehouseId,
    required String subtotal,
    required String taxTotal,
    required String total,
  }) = _RefundLine;

  factory RefundLine.fromResponse(api.CustomerRefundLineResponse r) =>
      RefundLine(
        id: r.customerRefundDetailId,
        salesOrderLineId: r.salesOrderDetail,
        productId: r.product,
        productCode: r.productCode,
        productName: r.productName,
        quantity: r.quantity,
        refundableQuantity: r.refundableQuantity,
        price: r.price,
        discount: r.discount,
        taxRate: r.taxRate,
        taxIncluded: r.taxIncluded,
        warehouseId: r.warehouse,
        subtotal: r.subtotal,
        taxTotal: r.taxTotal,
        total: r.total,
      );
}

/// A customer refund, mapped from `CustomerRefundResponse`. The client never
/// computes a total or a refundable quantity (FR-006).
@freezed
abstract class CustomerRefund with _$CustomerRefund {
  const CustomerRefund._();

  const factory CustomerRefund({
    required int id,
    required int salesOrderId,

    /// Null means no customer; the payout lookup is not possible then (R6).
    int? customerId,
    required int salesPersonId,
    required int facilityId,

    /// The folio. Null until confirmed.
    int? serial,

    /// Set on confirm.
    DateTime? date,
    required Currency currency,
    required RefundStatus status,
    @Default(<RefundLine>[]) List<RefundLine> lines,
    required String subtotal,
    required String taxTotal,
    required String total,
  }) = _CustomerRefund;

  factory CustomerRefund.fromResponse(api.CustomerRefundResponse r) =>
      CustomerRefund(
        id: r.customerRefundId,
        salesOrderId: r.salesOrder,
        customerId: r.customer,
        salesPersonId: r.salesPerson,
        facilityId: r.facility,
        serial: r.serial,
        date: r.date,
        currency: currencyFromApi(r.currency),
        status: RefundStatus.fromApi(r.status),
        lines: (r.lines ?? const <api.CustomerRefundLineResponse>[])
            .map(RefundLine.fromResponse)
            .toList(),
        subtotal: r.subtotal,
        taxTotal: r.taxTotal,
        total: r.total,
      );

  bool get isDraft => status == RefundStatus.draft;

  /// Whether any line's return quantity is above zero. Gates confirm (FR-008).
  bool get hasReturn => lines.any((l) => !isZeroAmount(l.quantity));
}

/// One row of the refunds list, mapped from `CustomerRefundSummary`.
@freezed
abstract class CustomerRefundSummary with _$CustomerRefundSummary {
  const factory CustomerRefundSummary({
    required int id,
    required int salesOrderId,
    int? customerId,
    int? serial,
    DateTime? date,
    required Currency currency,
    required RefundStatus status,
    required String total,
  }) = _CustomerRefundSummary;

  factory CustomerRefundSummary.fromResponse(api.CustomerRefundSummary r) =>
      CustomerRefundSummary(
        id: r.customerRefundId,
        salesOrderId: r.salesOrder,
        customerId: r.customer,
        serial: r.serial,
        date: r.date,
        currency: currencyFromApi(r.currency),
        status: RefundStatus.fromApi(r.status),
        total: r.total,
      );
}
