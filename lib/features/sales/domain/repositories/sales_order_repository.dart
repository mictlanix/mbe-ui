import 'package:mbe_ui/core/domain/currency.dart';
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
  Future<Sale> updateHeader({
    required int saleId,
    int? customer,
    PaymentTerms? paymentTerms,
    Currency? currency,
    int? shipTo,
    int? contact,
    String? customerName,
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

  /// `GET /sales-orders?point_sale=<id>&status=<status>` — the open-sales
  /// selector's data source, scoped to the cashier's own register
  /// (resolved, research.md §5 — was `facility` + `mine=true`).
  Future<OpenSalePage> listOpen({
    required int pointSale,
    required SaleStatus status,
    int skip = 0,
    int limit = 100,
  });
}

class OpenSalePage {
  const OpenSalePage({required this.items, required this.total});
  final List<OpenSale> items;
  final int total;
}
