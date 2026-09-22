import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';

part 'sales_quote_summary.freezed.dart';

/// One row in the quotes list (spec 040 data-model.md §3), from
/// `GET /sales-quotes`. `OpenSale` cannot be reused: it requires `balance`,
/// which a quote does not have, and has no `hasExpired`.
@freezed
class SalesQuoteSummary with _$SalesQuoteSummary {
  const factory SalesQuoteSummary({
    required int id,
    int? serial,
    required int customer,

    /// The customer's own name, joined server-side (mbe-api#213) — the same
    /// join `OpenSale.customerDisplayName` reads for orders. Null only if
    /// the customer row is gone.
    String? customerDisplayName,
    required int salesperson,
    required DateTime date,

    /// The quote's expiry (spec 040 FR-024, FR-037).
    required DateTime dueDate,
    required Currency currency,
    required SaleStatus status,

    /// Orthogonal to [status] — a quote can be both `completed` and
    /// expired. Rendered as a **separate marker**, never folded into the
    /// status chip (FR-024, FR-037).
    required bool hasExpired,
    required String total,
  }) = _SalesQuoteSummary;

  factory SalesQuoteSummary.fromResponse(api.SalesQuoteSummary r) =>
      SalesQuoteSummary(
        id: r.salesQuoteId,
        serial: r.serial,
        customer: r.customer,
        customerDisplayName: r.customerDisplayName,
        salesperson: r.salesperson,
        date: r.date,
        dueDate: r.dueDate,
        currency: currencyFromApi(r.currency),
        status: SaleStatus.fromApi(r.status),
        hasExpired: r.hasExpired,
        total: r.total,
      );
}

/// One page of the quotes list (spec 040 data-model.md §3), mirroring
/// `OpenSalePage`'s own shape.
class SalesQuotePage {
  const SalesQuotePage({required this.items, required this.total});
  final List<SalesQuoteSummary> items;
  final int total;
}
