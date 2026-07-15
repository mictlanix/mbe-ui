# Quickstart: Validating Product Pricing

**Feature**: `011-product-pricing` | **Date**: 2026-07-14

How to run and validate this feature end-to-end. Entity shapes are in
[data-model.md](./data-model.md); endpoint details in
[contracts/mbe-api-pricing.md](./contracts/mbe-api-pricing.md).

## Prerequisites

1. **mbe-api running locally** with the pricing endpoints (v0.1.0+):

   ```bash
   # in the sibling repo mictlanix/mbe-api
   uvicorn app.main:app --reload    # serves http://127.0.0.1:8000
   ```

   Confirm the pricing endpoints are live:

   ```bash
   curl -s http://127.0.0.1:8000/openapi.json \
     | python3 -c "import json,sys; print([p for p in json.load(sys.stdin)['paths'] if 'price' in p or 'exchange' in p])"
   ```

   Expect `/api/v1/price-lists`, `/api/v1/product-prices`,
   `/api/v1/exchange-rates` (with their `{id}` variants).

2. **A user with pricing privileges.** The three surfaces are gated
   independently (contracts/routes.md), so to exercise everything the test user
   needs `PriceLists` (5), `Pricing` (106), and `ExchangeRates` (43). An
   `administrator` user short-circuits all gates — use one for the happy path,
   and a *restricted* user for the gating checks below.

3. **At least one product** in the catalog to price.

## Run the app

```bash
flutter pub get
flutter run -d chrome            # Expanded/web tier — the target platform
```

Sign in, then confirm **Price Lists**, **Pricing**, and **Exchange Rates**
appear under the *Catalogs* group in the side nav.

## Validation scenarios

### 1. Price lists CRUD (US1)

1. Open **Price Lists** → the table lists name / high margin / low margin, with
   search and pagination present.
2. Create a list (toolbar action) named `Quickstart Retail`, high `0.40`, low
   `0.15` → it appears in the table; margins render as **40%** / **15%**, not
   `0.40`.
3. Search `Quickstart` → only that list shows.
4. Click the row (not the Edit icon) → opens a **read-only** View screen.
5. Edit → change low margin to `0.20` → save → value persists on reload.
6. Try a negative margin → blocked before submit with a field message (FR-006).
7. Delete an unused list from the detail form's warning-styled button → gone.
   Deleting a list that is assigned to a customer MUST surface the server's
   rejection and leave the list in place (US1 §6; note contracts/mbe-api-pricing.md
   **G3** — enforcement is unverified upstream).

### 2. Pricing a product (US2)

1. Open **Pricing** → empty state prompts you to find a product (US2 §8), not
   an error.
2. Pick a product → the table shows **one row per price list**, including lists
   with **no price set** — these must read as "not set", visibly distinct from
   a `0.00` price (FR-008). This is the client-side left join (research.md §5).
3. Set a price on a list that had none → saves via `POST /product-prices`
   (create path).
4. Change a price on a list that had one → saves via
   `PUT /product-prices/{id}` (update path).
5. Reselect the product → both values persisted.
6. Enter a negative price → blocked before submit (FR-011).
7. Prices render as MXN currency in `es-MX` (FR-013).

### 3. The `AnyOf` write path — highest-risk check ⚠️

Steps 2.3/2.4 are the **first runtime exercise of `one_of`/`AnyOf`
serialization in this codebase** (research.md §4 — no prior usage exists under
`lib/features/` or `lib/core/`). If prices silently fail to save, or save as
`null`/`0`, suspect the `AnyOf2<num, String>` construction before anything
else.

Verify the wire format directly:

```bash
# expect the decimal to arrive as a JSON string, e.g. "price": "120.00"
# (not 120.0, not null, not {})
```

Watch mbe-api's request log during step 2.3, or assert it in the repository
round-trip test. **Do not trust the UI alone here** — a broken serializer can
look like a successful save.

Also confirm a product priced across **more than 20 lists** returns all rows —
`GET /product-prices` defaults to `limit=20` and would silently truncate
(contracts/mbe-api-pricing.md **G5**).

### 4. Exchange rates (US3)

1. Open **Exchange Rates** → table shows date / base / target / rate, with date-range
   and currency filters plus pagination.
2. Create: date = today, base = **USD**, target = **MXN**, rate = `17.50` →
   appears in the list. Currencies are **pickers**, never raw ints (FR-018).
3. Filter by date range and by currency pair → only matching rows.
4. Edit the rate → persists. Delete → gone.
5. Rate of `0` or negative → blocked before submit (FR-016 — unlike prices,
   zero is invalid for a rate).
6. Add a second rate for the same date + pair → whatever mbe-api does (accept
   or reject) surfaces as a **clear** outcome, not an opaque failure
   (research.md §8, G2).

### 5. RBAC gating (FR-019)

Sign in as a **non-administrator** user and verify per-object gating:

| User holds | Expected |
|---|---|
| No pricing privileges | None of the three nav entries visible; direct URL nav to `/pricing`, `/price-lists`, `/exchange-rates` denied |
| `Pricing` (106) read only | Pricing screen visible, prices **read-only**, no edit controls |
| `Pricing` (106) but not `PriceLists` (5) | Can price products; **Price Lists** nav entry absent |
| `PriceLists` (5) read but not update | List visible; **no** Edit row icon (hidden, not disabled) |

The last row is the constitution §VI rule — a missing privilege **hides** the
control rather than rendering it disabled.

### 6. Regression — feature 007 must stay intact

Open any product's detail screen and confirm **no prices appear anywhere on the
form**, and that labels still occupy the `switches|labels` band. This feature
deliberately does **not** touch the product form (007 FR-012/FR-013,
research.md §1) — a price section reappearing there is a regression.

## Automated tests

```bash
flutter analyze
flutter test                                   # unit + widget
flutter test integration_test/                 # needs mbe-api running
```

Expected coverage (constitution "Development Workflow & Quality Gates"):

- **Unit**: DTO→entity mapping for all three entities (incl. the nested
  `price_list` object and `Currency.fromValue` fallback for an unknown code),
  the left-join row builder, validators, and the **`AnyOf` round-trip**.
- **Widget**: the three screens — read-only vs. editable, "not set" vs. zero,
  empty states, hidden-when-unprivileged controls.
- **Integration**: golden path — create price list → price a product on it →
  record an exchange rate — against a live mbe-api.
