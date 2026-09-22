import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sales_quote_summary.dart';

/// Quote lifecycle: open, edit its header, capture lines, confirm, cancel,
/// duplicate, convert, read one back, list the facility's quotes (spec 040,
/// contracts/sales-quote-repository.md §1). Every mutation returns the
/// **whole** document — the caller replaces its held copy wholesale rather
/// than patching it, mirroring [SalesOrderRepository]'s own contract.
///
/// Deliberately narrower than [SalesOrderRepository] in places
/// (`updateHeader` has no `fulfillmentIntent`/`promiseDate`/`priority`/
/// `recipient`/`customerName`; the line methods have no `warehouse`/
/// `taxRate`) and wider in one (`priceAdjustment`, a quote's own absolute
/// per-line markup, read-only in v1 per spec A3) — none of these are an
/// oversight, each mirrors what `SalesQuoteCreate`/`Update`/`LineCreate`/
/// `LineUpdate` actually accept on the wire.
abstract class SalesQuoteRepository {
  /// `POST /sales-quotes` — every field is optional; the server fills
  /// customer, salesperson, currency and terms from the caller's own
  /// configuration for whichever is omitted — **including customer**, which
  /// defaults to the deployment's generic walk-in customer (spec 040 §2.1).
  /// The quote screen must never call this with an empty body — FR-008
  /// forbids attaching the generic customer by any route, including this
  /// server default.
  ///
  /// [customer]/[salesperson] let the very first customer pick on a
  /// brand-new quote be a single POST instead of an empty create followed by
  /// [updateHeader], mirroring `SalesOrderRepository.open`'s own fast path.
  Future<Sale> open({int? customer, int? salesperson});

  Future<Sale> getById({required int quoteId});

  /// `PUT /sales-quotes/{id}` — draft only (409 otherwise). There is
  /// deliberately no `date` parameter: it is set once at create and
  /// `SalesQuoteUpdate` does not accept it.
  Future<Sale> updateHeader({
    required int quoteId,
    int? customer,
    int? salesperson,
    PaymentTerms? paymentTerms,
    Currency? currency,
    DateTime? dueDate,
    int? contact,
    int? shipTo,
    String? comment,
  });

  /// `POST /sales-quotes/{id}/lines`. Omit [price] to take the customer's
  /// price-list price; omit [quantity] for the product's minimum order
  /// quantity. [priceAdjustment] round-trips the quote's absolute per-line
  /// markup but is **not written by any shared widget in v1** (spec A3).
  Future<Sale> addLine({
    required int quoteId,
    required int product,
    String? quantity,
    String? price,
    String? priceAdjustment,
    String? discountRate,
    String? comment,
  });

  /// `PUT /sales-quotes/{id}/lines/{lineId}`.
  Future<Sale> updateLine({
    required int quoteId,
    required int lineId,
    String? quantity,
    String? price,
    String? priceAdjustment,
    String? discountRate,
    String? comment,
  });

  /// `DELETE /sales-quotes/{id}/lines/{lineId}`.
  Future<Sale> removeLine({required int quoteId, required int lineId});

  /// `POST /sales-quotes/{id}/confirm` — assigns the folio, freezes the
  /// document (FR-021).
  Future<Sale> confirm({required int quoteId});

  /// `POST /sales-quotes/{id}/cancel` (409 if already cancelled). Returns
  /// the quote directly — unlike `SalesOrderRepository.cancel`, which
  /// returns `void` because the order endpoint's own response is discarded;
  /// the quote endpoint's response is not (contracts/sales-quote-repository.md
  /// §1).
  Future<Sale> cancel({required int quoteId});

  /// `POST /sales-quotes/{id}/duplicate` — a **different**, independent
  /// draft, re-priced from the customer's current price list (FR-033).
  Future<Sale> duplicate({required int quoteId});

  /// `POST /sales-quotes/{id}/convert` — a **sales order**, mapped through
  /// [Sale.fromResponse] rather than [Sale.fromQuoteResponse]. 409 when the
  /// quote is a draft, cancelled, or expired; 422 when the caller has no
  /// point of sale configured (FR-025, FR-028–FR-030).
  Future<Sale> convert({required int quoteId});

  /// `GET /sales-quotes?mine=&customer=&salesperson=&status=&search=&skip=
  /// &limit=` — the quotes list's data source (FR-034–FR-039). Scoped by the
  /// caller's own facility server-side, implicitly — there is no `facility`
  /// parameter on this endpoint, unlike [SalesOrderRepository.listOrders]
  /// (research.md R5; verified as a live release check in quickstart.md).
  ///
  /// [mine] is always passed `false` by the quotes list (FR-034: the
  /// facility's quotes, not filtered to the current user by default).
  Future<SalesQuotePage> listQuotes({
    bool mine = false,
    int? customer,
    int? salesperson,
    SaleStatus? status,
    String? search,
    int skip = 0,
    int limit = 20,
  });
}
