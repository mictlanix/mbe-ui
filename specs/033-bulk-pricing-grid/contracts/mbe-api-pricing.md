# Contract: mbe-api Usage

**Feature**: `033-bulk-pricing-grid` | **Verified**: 2026-08-29
**Revised**: 2026-08-29, after mbe-api#182–#185 landed (`98d3254`, `bb85005`)

Every endpoint below now exists and is in the generated client. When this
contract was first written, four of them did not; the *filed, not built*
sections are gone and what replaced them is marked **landed**.

---

## 1. `GET /api/v1/products` — the rows

Generated: `listProductsApiV1ProductsGet({search, label, status, stockable,
salable, purchasable, supplier, missingPriceList, skip, limit})`, wrapped by
`ProductRepository.list(...)`.

`limit` is `Query(20, ge=1, le=100)`; the grid asks for 20.

**`missingPriceList` — landed (#184).** Products with no price on that list,
a correlated `NOT EXISTS` composing with every filter beside it, so
"unpriced *and* salable" is one query and `ListResponse.total` is the chip
count. Wired through `ProductRepository.list` and pinned by
`repository_list_params_audit_test.dart`.

⚠️ **`0` is a real price list id** in the deployment (`Costo`), so every test
of this parameter is `!= null`, never truthiness. The same trap applies
client-side.

## 2. `GET /api/v1/products/prices/missing-facets` — the chip row *(landed, #184)*

Generated: `getProductMissingPriceFacetsApiV1ProductsPricesMissingFacetsGet({search,
label, status, stockable, salable, purchasable, supplier})` →
`BuiltList<ProductMissingPriceFacet>`, each `{price_list, missing_count}`.

One call for the whole worklist row, counted as *matching minus priced*, so a
list nobody has priced at all still gets a row rather than being dropped by a
join. It takes **no** `missing_price_list` of its own — clicking one chip does
not change the numbers on the chips beside it.

Gated on `PRODUCTS` read, not `PRICING`: it counts products.

## 3. `GET /api/v1/price-lists` — the columns

Generated: `listPriceListsApiV1PriceListsGet({search, skip, limit})`, wrapped
by `PriceListRepository.list(limit: 100)`.

## 4. `GET /api/v1/product-prices` — the cells

Generated: `listProductPricesApiV1ProductPricesGet({product, priceList, skip,
limit})`.

**`product` repeats — landed (#182).** It is `BuiltList<int>?` in the
generated client and goes over the wire as dio's `ListParam` in
`ListFormat.multi` (`?product=1&product=2`), the shape `label` already used.

The repository seam is unchanged from the day it was written:

```dart
Future<List<ProductPrice>> listForProducts({
  required List<int> productIds,
  required List<int> priceListIds,
});
```

| | Implementation | Requests for a 20-row page |
|---|---|---|
| Before #182 | `Future.wait` over `listByProduct` | 20 |
| **Now** | one call with a repeated `product` | **1** |

The signature never changed — only the body, exactly as research.md §R5
predicted. `listByProduct` survives for the standalone per-product screen and
now sends a one-element list.

**The cap moved with the shape.** `BULK_LIMIT = 500` is one constant read by
this endpoint's `limit` *and* by the bulk write's body cap, deliberately: a
read cap the write could not match would make a full page unwritable. Mirrored
client-side as `kProductPriceBulkLimit`. A page returns products × lists rows,
so `productIds.length * priceListIds.length` must stay under it — over it, the
page is silently truncated, which reads as "these products have no price".

## 5. Writing a price

| Case | Call | Notes |
|---|---|---|
| single cell, row exists | `PUT /product-prices/{id}` — `ProductPriceRepository.update` | send `price` alone |
| single cell, row absent | `POST /product-prices` — `ProductPriceRepository.create` | send `price` alone |
| a page of cells | `PUT /product-prices` — bulk upsert, §6 | US3 |

### The profit band: no longer the client's problem *(#185)*

The original contract carried a rule for inventing `low_profit`/`high_profit`
on create, because they were `NOT NULL`, the grid does not collect them, and
`assert_margin_in_range` enforced them on every sales-order line — so a wrong
default made a product unsellable. **That is all gone:**

- The validation is **retired** — `assert_margin_in_range`, both call sites,
  the `EXCLUDE_PRICE_RANGE_VALIDATION` bypass and the
  `price_validation_in_range_required` setting. Nothing reads the band now.
- All four profit fields are **deprecated** but still accepted and returned,
  so a generated client keeps fields it compiles against. Both are optional on
  `ProductPriceCreate`/`ProductPriceUpdate`/`ProductPriceBulkItem`.
- **Create**: omitted, the row takes the price list's own
  `low_profit_margin`/`high_profit_margin` — server-side, from the values the
  data already treats as that list's default.
- **Update**: omitted, the stored band is **left alone** (there is no default
  to fall back to, and overwriting what the client never mentioned would
  change rows it never named).

So the grid sends `price` and nothing else, on both paths. The client-side
`_bandFor` helper and its `('0','1')` fallback are deleted.

⚠️ The generated Dart fields carry `@Deprecated`. Our entities still map them
(the standalone screen displays them until US7), with an explicit
`// ignore: deprecated_member_use` and a reason — reading a field deprecated
*for callers* is what a mapping layer is for.

**Wrapper-class note**: `price` still has separate create/update wrappers
(`Price`, `Price1`), but `LowProfit1`/`HighProfit1` **no longer exist** — both
schemas became nullable and the pair collapsed onto `LowProfit`/`HighProfit`.

## 6. `PUT /api/v1/product-prices` — bulk upsert *(landed, #183)*

Generated: `bulkUpsertProductPricesApiV1ProductPricesPut({productPriceBulkItem})`
taking a `BuiltList<ProductPriceBulkItem>` and returning
`BuiltList<ProductPriceResponse>`.

One transaction, keyed on the existing `UNIQUE (product, list)` rather than a
row id — which is what makes FR-015 (a column action is all-or-nothing)
reachable, and what US3 was waiting for. Gated on `UPDATE`, not `CREATE`, even
though a body may create rows: editing a blank cell is not a different act of
authority from editing a full one.

Behaviour the client must respect:

| Behaviour | Consequence here |
|---|---|
| Either every cell lands or none does | a column action needs no client-side rollback |
| Every product and price list id is checked up front | one bad id refuses the whole body, rather than applying the good rows first |
| A repeated `(product, price_list)` in one body → **400** | the client must not send two cells for one cell; that is a client bug, and last-one-wins would hide it |
| Body capped at `BULK_LIMIT` (500) | the same number as the read cap, so a page that can be read can always be written back |
| No POST-vs-PUT branch | the stale-read race, and its 409 on what the user saw as a plain edit, is gone |

Planned repository shape for US3:

```dart
Future<List<ProductPrice>> applyPriceChanges(List<PriceWrite> writes);
```

## 7. Price lists — what the profit removal does not break

`PriceListCreate` defaults both margins to `0` server-side and
`PriceListUpdate` has both optional; the repository sends them only when
non-null. Dropping the two form fields (FR-034) leaves create and update
working (FR-035).

## 8. Out of scope here, but adjacent: price list retirement *(#181)*

The issue this feature's investigation filed also landed:
`DELETE /price-lists/{id}?replacement={other_id}` retires a list, sweeping its
`product_price` rows and handing its customers to a named replacement in one
transaction, plus `GET /price-lists/{id}/delete/preview` for a confirmation
step. The generated client has both, and `PriceListDeletePreviewResponse` /
`PriceListDeletePreviewItem` exist.

**Spec 033 does not consume either.** The price-lists screen's delete flow is
untouched by this feature — noted here so the next reader knows the capability
exists rather than rediscovering it. It wants its own spec.
