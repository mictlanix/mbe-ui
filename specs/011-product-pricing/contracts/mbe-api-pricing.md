# Contract: mbe-api Pricing Endpoints

**Feature**: `011-product-pricing` | **API**: mbe-api v0.1.0 (verified live at
`http://127.0.0.1:8000/openapi.json`, 2026-07-14)

The generated Dart client for all three resources is **already committed** to
`lib/generated/openapi/` and is treated as current — no regeneration is planned
(research.md §2). This document records the contract mbe-ui consumes; it is
descriptive, not a spec mbe-ui may change (constitution §III repo boundary).

---

## Generated client surface

| Resource | Generated API class | File |
|---|---|---|
| Price lists | `PriceListsApi` | `lib/generated/openapi/lib/src/api/price_lists_api.dart` |
| Product prices | `ProductPricesApi` | `lib/generated/openapi/lib/src/api/product_prices_api.dart` |
| Exchange rates | `ExchangeRatesApi` | `lib/generated/openapi/lib/src/api/exchange_rates_api.dart` |

---

## 1. Price lists — `/api/v1/price-lists`

| Method | Path | Purpose |
|---|---|---|
| `GET` | `/api/v1/price-lists` | List (`search`, `skip`, `limit`) |
| `POST` | `/api/v1/price-lists` | Create |
| `GET` | `/api/v1/price-lists/{price_list_id}` | Read one |
| `PUT` | `/api/v1/price-lists/{price_list_id}` | Update |
| `DELETE` | `/api/v1/price-lists/{price_list_id}` | Delete |

**Query params (GET list)**: `search` (string), `skip` (int, default `0`),
`limit` (int, default `20`).

**`PriceListResponse`**: `price_list_id` (int), `name` (string),
`high_profit_margin` (string), `low_profit_margin` (string) — all required.

**`PriceListCreate`**: `name` (string, **required**), `high_profit_margin`
(number|string, optional), `low_profit_margin` (number|string, optional).

**`PriceListUpdate`**: all three nullable/optional.

**Envelope**: `ListResponse_PriceListResponse_ { items: [...], total: int }`.

---

## 2. Product prices — `/api/v1/product-prices`

| Method | Path | Purpose |
|---|---|---|
| `GET` | `/api/v1/product-prices` | List (`product`, `price_list`, `skip`, `limit`) |
| `POST` | `/api/v1/product-prices` | Create |
| `GET` | `/api/v1/product-prices/{product_price_id}` | Read one |
| `PUT` | `/api/v1/product-prices/{product_price_id}` | Update |
| `DELETE` | `/api/v1/product-prices/{product_price_id}` | Delete |

**Query params (GET list)**: `product` (int), `price_list` (int), `skip`,
`limit` (default `20`).

> ⚠️ **`limit` defaults to 20.** A product priced across more than 20 lists
> would silently truncate. The pricing screen MUST pass an explicit `limit`
> covering the price-list count (or paginate) rather than relying on the
> default — see quickstart §3.

**`ProductPriceResponse`**: `product_price_id` (int), `product` (int),
`price_list` (**nested `PriceListResponse`**), `price` (string), `low_profit`
(string), `high_profit` (string).

**`ProductPriceCreate`**: `product` (int), `price_list` (int), `price`
(number|string), `low_profit` (number|string), `high_profit` (number|string) —
**all required**.

**`ProductPriceUpdate`**: `price`, `low_profit`, `high_profit` (each
number|string, nullable). **No `product` / `price_list`** — a row cannot be
reassigned, only revalued.

**Asymmetry to note**: responses type money as plain `String`; create/update
type it as the generated `AnyOf` wrappers (`Price`, `LowProfit`,
`HighProfit`). See research.md §4 for the construction and why the String arm
is used.

---

## 3. Exchange rates — `/api/v1/exchange-rates`

| Method | Path | Purpose |
|---|---|---|
| `GET` | `/api/v1/exchange-rates` | List (`date_from`, `date_to`, `base`, `target`, `skip`, `limit`) |
| `POST` | `/api/v1/exchange-rates` | Create |
| `GET` | `/api/v1/exchange-rates/{exchange_rate_id}` | Read one |
| `PUT` | `/api/v1/exchange-rates/{exchange_rate_id}` | Update |
| `DELETE` | `/api/v1/exchange-rates/{exchange_rate_id}` | Delete |

**Query params (GET list)**: `date_from`, `date_to` (date), `base`, `target`
(int), `skip`, `limit` (default `20`).

**`ExchangeRateResponse`**: `exchange_rate_id` (int), `date` (string/date),
`rate` (string), `base` (int), `target` (int).

**`ExchangeRateCreate`**: `date` (date), `rate` (number|string), `base` (int),
`target` (int) — all required.

**`ExchangeRateUpdate`**: all nullable.

**No currency schema**: `base`/`target` are bare ints with no enum published.
mbe-ui maps them through its own `Currency` enum (research.md §6, data-model.md
§5).

---

## Contract gaps & assumptions

These are **observations about mbe-api**, not changes mbe-ui may make
(constitution §III forbids editing sibling repos; a needed change is filed as
an mbe-api issue).

| # | Gap | Impact | Handling |
|---|---|---|---|
| G1 | No currency enum published for `base`/`target` | FR-018 needs a selectable currency set | mbe-ui mirrors legacy `CurrencyCode` locally (research.md §6). Candidate mbe-api issue — not blocking. |
| G2 | No documented uniqueness rule on (`date`, `base`, `target`) | Duplicate-rate edge case | Submit and surface the server's response; no client pre-check (research.md §8). |
| G3 | No documented rule preventing price-list deletion while assigned to a customer | Spec US1 scenario 6 | Legacy `mbe/docs/specs/01-master-data.md` states the rule; whether mbe-api enforces it is unverified. UI surfaces any rejection; it does not pre-check. |
| G4 | Server-side RBAC enforcement on pricing endpoints unverified | Client gating may be the only gate | Same posture as feature 002 (its research.md §1 recorded the identical gap for products) — client-side gating ships; server enforcement is an mbe-api concern. |
| G5 | `product-prices` `limit` default of 20 | Silent truncation past 20 lists | Pass an explicit `limit`; see §2 warning. |

## Error mapping

All pricing calls go through the existing `dio` client and the shared
interceptor (bearer token, `401` ⇒ session-invalid redirect). Errors map to the
existing shared domain error types in `core/errors/app_error.dart`
(`ValidationError`, `NotFoundError`, `AuthError`, `ServerError`,
`NetworkError`) and surface via the shared `ErrorBanner` — no per-screen error
handling (constitution §III, spec FR-021).
