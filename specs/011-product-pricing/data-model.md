# Phase 1 Data Model: Product Pricing

**Feature**: `011-product-pricing` | **Date**: 2026-07-14 | **Plan**: [plan.md](./plan.md)

Domain entities are immutable `freezed` classes under
`lib/features/pricing/domain/entities/`, mapped from the **already-generated**
DTOs in `lib/generated/openapi/` (research.md §2). Money and margin fields are
`String` end-to-end (research.md §3).

---

## 1. `PriceList`

Maps from `PriceListResponse`. A named selling tier.

| Field | Type | Source | Notes |
|---|---|---|---|
| `priceListId` | `int` | `price_list_id` | Identity |
| `name` | `String` | `name` | Required, non-empty |
| `highProfitMargin` | `String` | `high_profit_margin` | Decimal markup ceiling, e.g. `"0.40"` = 40% |
| `lowProfitMargin` | `String` | `low_profit_margin` | Decimal markup floor |

**Validation** (client-side, before submit):

- `name`: required, non-empty after trim.
- `highProfitMargin` / `lowProfitMargin`: optional on create
  (`PriceListCreate` marks them non-required); when present MUST parse as a
  non-negative decimal (FR-006).

**Write mapping**:

- Create → `PriceListCreate { name, highProfitMargin: HighProfitMargin?, lowProfitMargin: LowProfitMargin? }`
- Update → `PriceListUpdate` (all fields nullable; send only changed fields).
  Margins use the **distinct `HighProfitMargin1`/`LowProfitMargin1`** wrapper
  classes, not the create-side `HighProfitMargin`/`LowProfitMargin` (research.md §4)

**Display**: margins render as percentages (`0.40` → `40%`) per FR-006; the
stored decimal is never shown raw.

---

## 2. `ProductPrice`

Maps from `ProductPriceResponse`. One product's price on one price list.

| Field | Type | Source | Notes |
|---|---|---|---|
| `productPriceId` | `int` | `product_price_id` | Identity |
| `productId` | `int` | `product` | FK → product |
| `priceList` | `PriceList` | `price_list` | **Nested object**, not an id (research.md §5) |
| `price` | `String` | `price` | Selling price |
| `lowProfit` | `String` | `low_profit` | |
| `highProfit` | `String` | `high_profit` | |

**Validation**: `price`, `lowProfit`, `highProfit` MUST each parse as a
non-negative decimal (FR-011). Empty is rejected on create (all three are
required by `ProductPriceCreate`).

**Write mapping** (research.md §4 — the `AnyOf` String arm):

- Create → `ProductPriceCreate { product: int, priceList: int, price: Price, lowProfit: LowProfit, highProfit: HighProfit }`
- Update → `ProductPriceUpdate { price?, lowProfit?, highProfit? }` — note the
  update DTO carries **no** `product`/`priceList`: a price row cannot be moved
  between products or lists, only revalued. Its `AnyOf` fields use the
  **distinct `Price1`/`LowProfit1`/`HighProfit1`** wrapper classes, not the
  create-side `Price`/`LowProfit`/`HighProfit` (research.md §4)

---

## 3. `ProductPriceRow` (view model, not an API entity)

The pricing screen's unit of display — the client-side left join from
research.md §5. Lives in `presentation/`, not `domain/entities/`, because it
exists only to drive the table.

| Field | Type | Notes |
|---|---|---|
| `priceList` | `PriceList` | Always present — every list gets a row |
| `price` | `ProductPrice?` | `null` ⇒ **no price set** for this list |

**Derived state**:

- `price == null` → render "not set"; save performs **create**.
- `price != null` → render values; save performs **update** on
  `price.productPriceId`.

This is what makes FR-008's "not set" ≠ `0.00` distinction representable —
without it, a missing row and a zero price are indistinguishable.

---

## 4. `ExchangeRate`

Maps from `ExchangeRateResponse`. A dated currency conversion.

| Field | Type | Source | Notes |
|---|---|---|---|
| `exchangeRateId` | `int` | `exchange_rate_id` | Identity |
| `date` | `DateTime` | `date` (`string/date`) | Date-only; render via `intl` |
| `rate` | `String` | `rate` | Conversion rate |
| `base` | `Currency` | `base` (`int`) | Mapped through `Currency.fromValue` |
| `target` | `Currency` | `target` (`int`) | Mapped through `Currency.fromValue` |

**Validation**:

- `date`: required.
- `rate`: required, MUST parse as a **positive** decimal (FR-016 — zero is
  invalid for a rate, unlike a price).
- `base` / `target`: required, selected from `Currency` (FR-018).

**Mapping note**: an unrecognized `int` from the API (`fromValue` returns
`null`) MUST NOT crash the list. Fall back to displaying the raw code — the
API's currency set is not schema-constrained (research.md §6).

**Write mapping**:

- Create → `ExchangeRateCreate { date, rate: Rate, base: int, target: int }`
- Update → `ExchangeRateUpdate` (all nullable). `rate` uses the **distinct
  `Rate1`** wrapper class, not the create-side `Rate` (research.md §4)

---

## 5. `Currency` (new shared enum)

`lib/core/domain/currency.dart` — hand-written, mirroring legacy `CurrencyCode`
(`mbe/docs/constants.md` §CurrencyCode). Justification and the §III
non-violation argument are in research.md §6.

| Constant | Value | Display |
|---|---|---|
| `mxn` | `0` | MXN — Mexican Peso (base currency) |
| `usd` | `1` | USD — US Dollar |
| `eur` | `2` | EUR — Euro |

Shape mirrors `SystemObject`: `const Currency(this.value)`, `final int value`,
`static Currency? fromValue(int value)` returning `null` when unmatched.

---

## Relationships

```text
PriceList 1 ──────< ProductPrice >────── 1 Product (by id; the product
    │                    │                          entity is not fetched here)
    │                    └── unique (product, priceList) — at most one price
    │                        per product per list
    │
    └──< assigned to Customer (out of scope — customers feature)

ExchangeRate ──> Currency (base), Currency (target)
```

## Entity ownership

`PriceList`, `ProductPrice`, and `ExchangeRate` live in the **new**
`lib/features/pricing/` module, not `features/catalog/`. Rationale in plan.md's
Structure Decision: they are the pricing tool's own entities behind distinct
RBAC objects, and nothing in `catalog/` consumes them (feature 007 removed the
catalog's last price reference). `Currency` is the sole shared addition and
goes to `core/domain/` because it is cross-feature (research.md §6).
