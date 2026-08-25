import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/features/sales/domain/entities/fulfillment_mode.dart';
import 'package:mbe_ui/features/sales/domain/entities/open_sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/product_lookup_result.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';

/// Sale lifecycle: open, edit its header, capture lines, confirm, read one
/// back, list the register's open sales, and look products up
/// (data-model.md §1–§3, §8; contracts/mbe-api-pos.md §1). Every mutation
/// returns the **whole** [Sale] — the caller replaces its held copy
/// wholesale rather than patching it (research.md §1).
abstract class SalesOrderRepository {
  /// `POST /sales-orders` with an empty body — every field is optional, the
  /// server fills point of sale, facility, salesperson, default customer,
  /// currency and terms from the caller's own configuration (FR-002).
  Future<Sale> open();

  Future<Sale> getById({required int saleId});

  /// `PUT /sales-orders/{id}` — draft only. Passing [customer] different
  /// from the sale's current one triggers a server-side reprice of every
  /// existing line (FR-015, resolved) — nothing extra to do here, the
  /// returned [Sale] already carries it.
  ///
  /// [promiseDate], [salesperson], [priority] and [comment] are the
  /// back-office order screen's own additions (spec 029 FR-016, FR-017) —
  /// existing POS callers never pass them. [priority] is the one field the
  /// server still accepts once the order is completed or cancelled
  /// (mbe-api FR-011); every other parameter here is refused past that
  /// point. There is deliberately no `dueDate` parameter: it is derived
  /// server-side from terms and the customer's credit days and
  /// `SalesOrderUpdate` does not accept it (spec 029 contracts §3).
  Future<Sale> updateHeader({
    required int saleId,
    int? customer,
    PaymentTerms? paymentTerms,
    Currency? currency,
    int? shipTo,
    int? contact,
    String? customerName,
    // How the cashier said the goods reach the customer (mbe-api#170/#171) —
    // the fulfilment step's mode selection writes this alone (spec 020
    // FR-056, amended 2026-08-23 to drop the address it used to write
    // alongside it), so a mixed sale survives a resume without needing
    // [shipTo] at all.
    FulfillmentMode? fulfillmentIntent,
    DateTime? promiseDate,
    int? salesperson,
    Priority? priority,
    String? comment,
    String? recipient,
  });

  /// `POST /sales-orders/{id}/lines`. Omit [price] to take the customer's
  /// price-list price; omit [quantity] for the product's minimum order
  /// quantity; omit [taxRate] for the product's own rate (FR-023, resolved).
  Future<Sale> addLine({
    required int saleId,
    required int product,
    String? quantity,
    String? price,
    String? discountRate,
    String? taxRate,
    int? warehouse,
    String? comment,
  });

  /// `PUT /sales-orders/{id}/lines/{lineId}`.
  Future<Sale> updateLine({
    required int saleId,
    required int lineId,
    String? quantity,
    String? price,
    String? discountRate,
    String? taxRate,
    int? warehouse,
    String? comment,
  });

  /// `DELETE /sales-orders/{id}/lines/{lineId}`.
  Future<Sale> removeLine({required int saleId, required int lineId});

  /// `POST /sales-orders/{id}/confirm` — assigns the folio, commits stock,
  /// freezes the document (FR-038–FR-040).
  Future<Sale> confirm({required int saleId});

  /// `POST /sales-orders/{id}/cancel` — used only to abandon an empty open
  /// sale (US3 scenario 6), never a sale with lines.
  Future<void> cancel({required int saleId});

  /// `GET /sales-orders/product-lookup` — backs both the scan and the
  /// search path (FR-020, FR-021).
  Future<List<ProductLookupResult>> productLookup({
    required String pattern,
    required int customer,
    int? warehouse,
  });

  /// `GET /sales-orders?point_sale=<id>&status=<status>&date_from=<from>` —
  /// the open-sales selector's data source, scoped to the cashier's own
  /// register (resolved, research.md §5 — was `facility` + `mine=true`).
  ///
  /// [dateFrom] bounds it to the register's current trading day. Without it
  /// the confirmed and paid statuses answer with the register's entire
  /// history — 19k rows apiece on a real dataset — of which only the first
  /// [limit] are ever seen, so a genuinely unfinished sale could sit past the
  /// cut-off and never be offered.
  Future<OpenSalePage> listOpen({
    required int pointSale,
    required SaleStatus status,
    DateTime? dateFrom,
    int skip = 0,
    int limit = 100,
  });

  /// `GET /sales-orders?point_sale=<id>&status=&date_from=&date_to=&search=&skip=&limit=`
  /// — the sales list screen's data source (spec 023 FR-001–FR-005), scoped to
  /// the cashier's own register like [listOpen] but over an arbitrary,
  /// cashier-chosen date range and every status rather than the selector's
  /// fixed three.
  ///
  /// [status], when given, is **not** guaranteed exclusive by mbe-api — a
  /// live-verified quirk [listOpen] already documents (`completed` answers
  /// with `paid` rows too) — so a caller that cares about an exact status
  /// match must still narrow the returned page itself.
  Future<OpenSalePage> listSales({
    required int pointSale,
    SaleStatus? status,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? search,
    int skip = 0,
    int limit = 20,
  });

  /// `GET /sales-orders?mine=&facility=&salesperson=&status=&date_from=
  /// &date_to=&search=&skip=&limit=` — the back-office Sales Orders list's
  /// data source (spec 029 FR-006–FR-011), scoped by *who the order belongs
  /// to* and *which facility*, never by register.
  ///
  /// Three server behaviours this method's callers must respect
  /// (contracts/mbe-api-sales-orders.md §1):
  ///
  /// - [facility] defaults to the caller's own and the predicate is
  ///   unconditional — a call is always exactly one facility, never merged.
  /// - [mine], when true, matches an order whose creator, last updater **or**
  ///   salesperson is the caller — not creator alone.
  /// - [status], like [listSales]'s, is not guaranteed exclusive server-side.
  Future<OpenSalePage> listOrders({
    bool mine = false,
    int? facility,
    int? salesperson,
    SaleStatus? status,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? search,
    int skip = 0,
    int limit = 20,
  });
}

class OpenSalePage {
  const OpenSalePage({required this.items, required this.total});
  final List<OpenSale> items;
  final int total;
}
