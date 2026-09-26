# Contract: `SalesQuoteRepository`

**Feature**: `040-sales-quotes` | **Date**: 2026-09-20

The domain interface over `/api/v1/sales-quotes`, mirroring `SalesOrderRepository`. The
generated client exists and is committed (`lib/generated/openapi/lib/src/api/sales_quotes_api.dart`)
— **no codegen is required**.

Interface at `lib/features/sales/domain/repositories/sales_quote_repository.dart`;
implementation and its `salesQuoteRepositoryProvider` at
`lib/features/sales/data/sales_quote_repository_impl.dart`.

---

## 1. Methods

Every mutation returns the **whole quote**; the caller replaces its held copy wholesale rather
than patching. This is the same contract `SalesOrderRepository` states and the reason
`SaleEditing`'s publish-before-return discipline works.

| Method | Endpoint | Returns |
|---|---|---|
| `open({int? customer, int? salesperson, PaymentTerms?, Currency?, DateTime? date, DateTime? dueDate, int? contact, int? shipTo, String? comment})` | `POST /sales-quotes` | `Sale` |
| `getById({required int quoteId})` | `GET /sales-quotes/{id}` | `Sale` |
| `updateHeader({required int quoteId, int? customer, int? salesperson, PaymentTerms?, Currency?, DateTime? dueDate, int? contact, int? shipTo, String? comment})` | `PUT /sales-quotes/{id}` | `Sale` |
| `addLine({required int quoteId, required int product, String? quantity, String? price, String? priceAdjustment, String? discountRate, String? comment})` | `POST …/lines` | `Sale` |
| `updateLine({required int quoteId, required int lineId, String? quantity, String? price, String? priceAdjustment, String? discountRate, String? comment})` | `PUT …/lines/{lineId}` | `Sale` |
| `removeLine({required int quoteId, required int lineId})` | `DELETE …/lines/{lineId}` | `Sale` |
| `confirm({required int quoteId})` | `POST …/confirm` | `Sale` |
| `cancel({required int quoteId})` | `POST …/cancel` | `Sale` |
| `duplicate({required int quoteId})` | `POST …/duplicate` | `Sale` — a **different** quote |
| `convert({required int quoteId})` | `POST …/convert` | `Sale` — a **sales order**, via `Sale.fromResponse` |
| `listQuotes({bool mine, int? customer, int? salesperson, SaleStatus? status, String? search, int skip, int limit})` | `GET /sales-quotes` | `SalesQuotePage` |

### Divergences from `SalesOrderRepository`, each deliberate

- **No `origin`, `fulfillmentIntent`, `promiseDate`, `priority`, `recipient`, `customerName`**
  on create or update — none exist on the quote schemas. `date` is on **create only**.
- **No `warehouse` and no `taxRate`** on either line body. `priceAdjustment` is the quote's
  writable line lever instead — accepted by this interface so the value round-trips, but
  **not written by the UI in v1** (spec A3).
- **`cancel` returns the quote**, unlike the order repository's `void`. Do **not** copy
  `OrderEditorController.cancel`'s second `getById` — that read-back exists because the order
  interface discards a response the server does actually send, and repeating it here would add
  a needless round trip.
- **`listQuotes` has no `facility`, no date range and no origin.** The server scopes by the
  caller's facility implicitly; see the live check in `quickstart.md`.

### Return-type note

`duplicate` and `convert` both return a document **other than** the one addressed. Neither may
be written into a controller keyed on the original id. Both are navigation results: the caller
routes to `/sales/quotes/<new>` and `/sales/orders/<new>` respectively.

---

## 2. Error mapping — the part that is easy to get wrong

The implementation must carry its own mapper, in the shape of
`sales_order_repository_impl.dart:365-419`. Three layers:

```
_toAppError(e)          // the universal unwrap, repeated in every repository impl
  ↑
_toQuoteError(e)        // 422 with a plain-string `detail` → AppError.creditHold(detail)
  ↑
(applied to: open, updateHeader, convert)
```

**Why the middle layer is mandatory.** `mapDioException`'s 422 arm
(`auth_interceptor.dart:86-100`) reads `detail` only as a *list* of field errors. A **422 whose
`detail` is a plain string** yields `AppError.validation(const [])` — **the server's message is
destroyed** and the user sees a bare "validation failed". `convert` creates a sales order, and
mbe-api credit-checks on order creation, so this path is reachable. `convert`'s
"no point of sale is configured for your user" (FR-030) arrives the same way.

This is the single highest-risk omission in the feature: it fails silently, only against a live
server, and only for the users least likely to have a point of sale configured.

**409s need no new code.** `mapDioException`'s `default` arm already produces
`ServerError(statusCode: 409, message: detail)`, and `_detailFrom` reads `detail` as a string
*or* as a map with a `message` key. `ErrorBanner` prints the server's own text beneath a
localized headline.

**Do not distinguish convert's refusals by their prose.** All four arrive as
`ServerError(409, …)`. FR-029's Duplicate offer is driven by the quote's own `hasExpired`, not
by matching the message. If a future requirement needs to *branch* on refusal kind rather than
display it, add a typed variant — the precedent and its rationale are at
`app_error.dart:29-32`.

---

## 3. Wire-value helpers

The quote line bodies use the same generated `anyOf: [string, num]` wrappers as the order
bodies for `quantity`, `price` and `discountRate`, plus two new ones for `priceAdjustment`
(create and update). The five existing one-line setters are private to
`sales_order_repository_impl.dart:429-447`; promote them to a shared file rather than
duplicating.

Each setter is called **guarded by `if (x != null)`**, so an omitted value means "server
default", not zero. Preserve that — a quote line added without an explicit price must be priced
by the customer's price list, not at zero.
