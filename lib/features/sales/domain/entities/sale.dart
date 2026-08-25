import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/features/sales/domain/entities/fulfillment_mode.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_line.dart';

part 'sale.freezed.dart';

/// The whole point of the screen (data-model.md §1). One per transaction,
/// created when the screen opens (FR-002) — after the cash-session gate
/// passes (FR-002a). Every mutation replaces this entity wholesale with
/// whatever the server returns (research.md §1) — never patched locally.
@freezed
class Sale with _$Sale {
  const Sale._();

  const factory Sale({
    required int id,
    int? serial,
    required int facility,
    required int pointSale,
    required int salesperson,
    required int customer,
    String? customerName,
    required PaymentTerms paymentTerms,
    required Currency currency,
    required String exchangeRate,
    int? shipTo,
    // `null` for a sale predating mbe-api#171 or raised by a client that
    // never asked — "not recorded", not "delivery" (FulfillmentMode.fromApi
    // keeps that distinction rather than guessing). The capture step writes
    // this via `updateHeader` once the cashier picks a mode.
    FulfillmentMode? fulfillmentIntent,
    required DateTime promiseDate,
    required SaleStatus status,
    @Default(<SaleLine>[]) List<SaleLine> lines,
    required String subtotal,
    required String taxTotal,
    required String total,
    required String balance,
    // Back-office order screen fields (spec 029) — all already on the wire in
    // `SalesOrderResponse`, simply never mapped until this feature needed them.
    // POS never reads any of these; adding them is additive.
    required DateTime date,
    // Display-only (FR-018): derived server-side from terms + customer credit
    // days (`derive_due_date`) and absent from `SalesOrderUpdate` — never sent.
    required DateTime dueDate,
    int? contact,
    String? recipient,
    String? recipientName,
    required Priority priority,
    String? comment,
  }) = _Sale;

  factory Sale.fromResponse(api.SalesOrderResponse r) => Sale(
    id: r.salesOrderId,
    serial: r.serial,
    facility: r.facility,
    pointSale: r.pointSale,
    salesperson: r.salesperson,
    customer: r.customer,
    customerName: r.customerName,
    paymentTerms: PaymentTerms.fromApi(r.paymentTerms),
    currency: currencyFromApi(r.currency),
    exchangeRate: r.exchangeRate,
    shipTo: r.shipTo,
    fulfillmentIntent: FulfillmentMode.fromApi(r.fulfillmentIntent),
    promiseDate: r.promiseDate,
    status: SaleStatus.fromApi(r.status),
    lines: (r.lines ?? const <api.SalesOrderLineResponse>[])
        .map(SaleLine.fromResponse)
        .toList(),
    subtotal: r.subtotal,
    taxTotal: r.taxTotal,
    total: r.total,
    balance: r.balance,
    date: r.date,
    dueDate: r.dueDate,
    contact: r.contact,
    recipient: r.recipient,
    recipientName: r.recipientName,
    priority: Priority.fromApi(r.priority),
    comment: r.comment,
  );

  /// The provisional reference before confirmation (FR-040) — callers
  /// display `serial` once non-null, and fall back to this otherwise.
  int get provisionalReference => id;

  /// FR-041: capture, customer, mode and terms are only editable while the
  /// sale is a draft. `data-model.md` §1.1.
  bool get isEditable => status == SaleStatus.draft;

  /// FR-050/§1.1: a paid sale's balance is exactly zero — the payment step's
  /// close gate reads this, not a locally-recomputed figure.
  bool get isPaid => status == SaleStatus.paid;

  /// FR-028's totals-bar line count.
  int get lineCount => lines.length;
}

/// `data-model.md` §1.1 — derived from `DocumentStatus`, which already has
/// real member names (unlike `PaymentTerms`/`CurrencyCode`/`Priority`
/// below, generated as bare `number0`/`number1`/... with no schema-level
/// names to preserve).
enum SaleStatus {
  draft,
  completed,
  paid,
  cancelled;

  /// The string mbe-api filters on (`?status=`) — the same four names the
  /// `DocumentStatus` schema enumerates.
  String get wireName => name;

  static SaleStatus fromApi(api.DocumentStatus value) => switch (value) {
    api.DocumentStatus.draft => SaleStatus.draft,
    api.DocumentStatus.completed => SaleStatus.completed,
    api.DocumentStatus.paid => SaleStatus.paid,
    api.DocumentStatus.cancelled => SaleStatus.cancelled,
    _ => SaleStatus.draft,
  };
}

/// `sales_order.payment_terms` (mbe-api `PaymentTerms(IntEnum)`:
/// `IMMEDIATE = 0, NET_D = 1`) — hand-mapped because the generator emits
/// `number0`/`number1` with no preserved member names, the same gap
/// `core/domain/currency.dart` and `core/domain/payment_method.dart`
/// already work around for their own enums.
enum PaymentTerms {
  immediate(0),
  netD(1);

  const PaymentTerms(this.value);

  final int value;

  static PaymentTerms fromApi(api.PaymentTerms value) =>
      switch (value.name) {
        'number1' => PaymentTerms.netD,
        _ => PaymentTerms.immediate,
      };

  api.PaymentTerms toApi() => switch (this) {
    PaymentTerms.immediate => api.PaymentTerms.number0,
    PaymentTerms.netD => api.PaymentTerms.number1,
  };
}

/// `sales_order.currency` (mbe-api `CurrencyCode(IntEnum)`: `MXN=0, USD=1,
/// EUR=2`) — same generator gap as [PaymentTerms] above; reuses the shared
/// [Currency] wrapper (`core/domain/currency.dart`) rather than a third
/// hand-written enum.
Currency currencyFromApi(api.CurrencyCode value) => switch (value.name) {
  'number1' => Currency.usd,
  'number2' => Currency.eur,
  _ => Currency.mxn,
};

api.CurrencyCode currencyToApi(Currency value) => switch (value) {
  Currency.mxn => api.CurrencyCode.number0,
  Currency.usd => api.CurrencyCode.number1,
  Currency.eur => api.CurrencyCode.number2,
};

/// `sales_order.priority` (mbe-api `Priority(IntEnum)`: `LOW=0, NORMAL=1,
/// HIGH=2, CRITICAL=3`) — same generator gap as [PaymentTerms]/[CurrencyCode]
/// above. Four members, not the three legacy's form offers (Baja/Media/Alta):
/// `critical` is an mbe-api addition with no legacy label, decoded here
/// because a value that exists on the wire must decode (data-model.md §1.1).
/// `normal` is the safe fallback for an unrecognized value, matching
/// `SalesOrderCreate.priority`'s own default.
enum Priority {
  low(0),
  normal(1),
  high(2),
  critical(3);

  const Priority(this.value);

  final int value;

  static Priority fromApi(api.Priority value) => switch (value.name) {
    'number0' => Priority.low,
    'number2' => Priority.high,
    'number3' => Priority.critical,
    _ => Priority.normal,
  };

  api.Priority toApi() => switch (this) {
    Priority.low => api.Priority.number0,
    Priority.normal => api.Priority.number1,
    Priority.high => api.Priority.number2,
    Priority.critical => api.Priority.number3,
  };
}
