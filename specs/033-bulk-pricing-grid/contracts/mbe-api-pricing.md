# Contract: mbe-api Usage

**Feature**: `033-bulk-pricing-grid` | **Verified**: 2026-08-29

Two of the four endpoints below exist and are already in the generated client. The
other two are **filed, not built** — nothing in this repo may add them (§III).

---

## 1. `GET /api/v1/products` — the rows *(exists)*

Generated: `listProductsApiV1ProductsGet({search, label, status, stockable,
salable, purchasable, supplier, skip, limit})`, already wrapped by
`ProductRepository.list(...)` and already used by the products list.

The grid reuses it verbatim. `limit` is `Query(20, ge=1, le=100)`; the grid asks
for 20.

**Missing for US2**: `missing_price_list=N` — filed as **mbe-api#184**. Until it
exists, `PricingGridFilter.missingPriceList` is always null and the worklist chips
are not rendered at all (FR-019).

## 2. `GET /api/v1/price-lists` — the columns *(exists)*

Generated: `listPriceListsApiV1PriceListsGet({search, skip, limit})`, wrapped by
`PriceListRepository.list(limit: 100)` — the same call `PricingController._load`
already makes.

## 3. `GET /api/v1/product-prices` — the cells *(exists, one product at a time)*

Generated: `listProductPricesApiV1ProductPricesGet({product, priceList, skip,
limit})`. `product` is a **single** int (`app/api/v1/endpoints/product_prices.py:16`).

New repository method, the seam the whole read path goes through:

```dart
/// Every price on [priceListIds] for [productIds], as a flat list.
Future<List<ProductPrice>> listForProducts({
  required List<int> productIds,
  required List<int> priceListIds,
});
```

| | Implementation | Requests for a 20-row page |
|---|---|---|
| **Today** | `Future.wait` over `listByProduct` | 20 |
| **With mbe-api#182** | one call with a repeated `product` param | 1 |

The signature does not change when #182 lands — only the body. Nothing above the
repository knows which world it is in.

**Cap**: the batched response is products × lists rows against `limit ≤ 100`. The
client therefore requests **only the shown columns'** prices and pages the fetch if
`productIds.length * priceListIds.length > 100`. Recorded on #182.

## 4. Writing a price *(exists per row; bulk is filed)*

| Case | Call | Notes |
|---|---|---|
| cell had a price | `PUT /product-prices/{id}` — `ProductPriceRepository.update` | send `price`; **echo `lowProfit`/`highProfit` back unchanged** |
| cell was empty | `POST /product-prices` — `ProductPriceRepository.create` | `low_profit`/`high_profit` are **required** (`app/schemas/product_price.py:8`) |

### The band a created row carries (research R6)

`assert_margin_in_range` (`app/services/sales_order_service.py:56`) enforces
`low_profit ≤ (price − cost) / price ≤ high_profit` on every sales-order line for
the customer's price list. So the value the grid invents here decides whether the
product can be sold at all.

```text
create(productId, priceListId, price):
  band = (list.lowProfitMargin, list.highProfitMargin)   # already on PriceList
  if band == (0, 0):        # the shipped default for a list created without margins
      band = (0, 1)         # widest the schema allows: at or above cost, no ceiling
```

Never `(0, 0)` — that band refuses every sale at any profit. This is the client
choosing a rule the server should own; **mbe-api#185** carries that argument, and
**mbe-api#183** (optional profit fields, defaulted server-side) deletes this block
when it lands.

## 5. `PUT /api/v1/product-prices` (bulk upsert) — **filed, not built**

**mbe-api#183**. One transaction, keyed on the unique `(product, list)`, with the
profit fields optional. It is what makes FR-015 (a column action is all-or-nothing)
reachable, and therefore what US3 waits for (research R7). Planned repository shape,
for when it exists:

```dart
Future<List<ProductPrice>> applyPriceChanges(List<PriceWrite> writes);
```

## 6. Price lists — what the profit removal does *not* break

`PriceListCreate` defaults `high_profit_margin` / `low_profit_margin` to `0`
server-side (`app/schemas/product.py:29`) and `PriceListUpdate` has both optional.
The repository already sends them only when non-null, so dropping the two form
fields (FR-034) leaves create and update working untouched (FR-035).
