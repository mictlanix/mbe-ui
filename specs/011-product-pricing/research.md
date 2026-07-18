# Phase 0 Research: Product Pricing

**Feature**: `011-product-pricing` | **Date**: 2026-07-14 | **Plan**: [plan.md](./plan.md)

All Technical Context unknowns are resolved below. No `NEEDS CLARIFICATION`
markers remain.

---

## 1. Where do per-product prices live? (spec US2 vs. shipped feature 007)

**Decision**: A **standalone pricing screen** at `/pricing`, gated by
`SystemObject.pricing` (106). The product detail form is **not** touched.

**Rationale**:

- Feature `007-catalog-ui-improvements-2` deliberately removed the price
  section from the product form. Its **FR-012** ("The product form MUST NOT
  display any price-list section or price values") and **FR-013** (the labels
  control takes that layout position) are shipped requirements, and DESIGN.md
  §4.3 cites the resulting `switches|labels` band
  (`product_detail_screen.dart:331`, `_SwitchesLabelsBand`) as the reference
  implementation of the form-layout principle. Reintroducing prices there
  would reverse a shipped decision and evict labels from the slot 007 gave
  them.
- 007's stated reason for removal was that the price section *"isn't editable
  and duplicates information better served by labels"* — the "isn't editable"
  half is now obsolete, but the layout decision stands on its own.
- The RBAC model independently favors separation: pricing is its own
  `SystemObject` (`Pricing` = 106, "Price management / pricing tool") distinct
  from `Products` (0). A user may hold pricing rights without product-edit
  rights and vice versa; embedding prices in the product form would put two
  different privilege surfaces on one screen.

**Alternatives considered**:

- *Prices section back on the product form* (supersede 007 FR-012): matches
  the original feature request most literally and needs no product picker, but
  reverses a shipped requirement, competes with labels for the layout slot, and
  mixes two RBAC surfaces on one screen. **Rejected by decision 2026-07-14.**
- *Both surfaces* (read-only summary on the form + editable `/pricing`):
  best discoverability, but still violates 007 FR-012 and roughly doubles the
  surface to build and test for a marginal gain. **Rejected.**

---

## 2. OpenAPI codegen — regenerate or reuse?

**Decision**: **Reuse the committed generated client as-is.** No codegen task
is planned (decision 2026-07-14).

**Rationale**: `lib/generated/openapi/` already contains
`price_lists_api.dart`, `product_prices_api.dart`, `exchange_rates_api.dart`
and the full model set (`PriceListResponse`, `ProductPriceResponse`,
`ExchangeRateResponse`, their `*Create`/`*Update` variants, and the
`ListResponse_*` envelopes) — verified present against mbe-api v0.1.0's live
`/openapi.json` during planning. Constitution §III requires DTOs be generated
rather than hand-written; it does not require a redundant regeneration when the
committed client already matches.

**Alternatives considered**:

- *Regenerate unconditionally*: safest against silent drift, but rewrites many
  generated files and adds review noise. **Rejected.**
- *Verify-then-regen-if-stale*: middle ground. **Rejected** in favor of the
  explicit decision to treat the committed client as current.

**Risk accepted**: if mbe-api's pricing schemas change before implementation
lands, the client is stale. Mitigation: the quickstart's live-backend checks
exercise every pricing endpoint, so drift surfaces as a concrete failure rather
than silently.

---

## 3. Money & decimal representation

**Decision**: Model `price`, `lowProfit`, `highProfit`, margins, and `rate` as
**`String`** in domain entities. Format for display with `intl`
(`NumberFormat.currency` for money, percent formatting for margins). Never
parse money into `double`.

**Rationale**:

- mbe-api returns these as JSON strings and the generated **response** DTOs
  type them as `String` (`ProductPriceResponse.price`, `.lowProfit`,
  `.highProfit`; `PriceListResponse.highProfitMargin`, `.lowProfitMargin`;
  `ExchangeRateResponse.rate`). Keeping `String` end-to-end preserves the
  server's exact decimal scale.
- Established precedent: `Product.taxRate` is already a `String` through the
  same pipeline (`product.dart:32`), and no `decimal` package is in
  `pubspec.yaml`. Introducing one would be a new dependency for no gain.
- Round-tripping money through IEEE-754 `double` risks scale/rounding drift on
  values the business treats as exact.

**Alternatives considered**: adding `package:decimal` — rejected, new
dependency, and the API's string contract already carries exact values.

---

## 4. Writing prices: the `AnyOf` request wrapper

**Decision**: Send the **String** arm of the generated `AnyOf` wrappers using
`AnyOf2<String, num>` — String as the *first* type parameter — with key `0`:

```dart
HighProfitMarginBuilder builder;
builder.anyOf = AnyOf2<String, num>(values: {0: '0.40'});
```

This exactly mirrors the pre-existing `_setTaxRate` helper in
`product_repository_impl.dart`:

```dart
void _setTaxRate(TaxRateBuilder builder, String value) {
  builder.anyOf = AnyOf2<String, num>(values: {0: value});
}
```

**⚠️ Corrected 2026-07-17 — the original decision below was wrong.** An
earlier version of this section read the wrapper's generated `deserialize`
method (`targetType = FullType(AnyOf, [FullType(num), FullType(String)])`) and
inferred that construction should mirror that order —
`AnyOf2<num, String>(values: {1: value})`, String as the *second* parameter at
key `1`. **This does not work.** Implementing US1's price-list margins against
that guidance and running the mandatory round-trip test (this section's own
requirement) immediately failed both plausible-looking forms:

- `AnyOf2<num, String>(values: {1: value})` → `RangeError (length): Invalid
  value: Only valid value is 0: 1`
- `AnyOf2<num, String>(values: {0: value})` → `type 'String' is not a subtype
  of type 'num'` (from `NumSerializer`)

**Root cause**: `AnyOfSerializer.serialize` (`package:one_of_serializer`)
builds its `specifiedType.parameters` from `anyOf.valueTypes` — the *set of
types for keys actually present in `values`* — not from the wrapper's full
declared type-parameter list. `_$PriceSerializer.serialize` (and its five
siblings) construct that `specifiedType` from `anyOf.valueTypes` at
serialization time, so with exactly one value set, `parameters` always has
length 1, and the entry must live at key `0`, with `types[0]` matching the
value's actual runtime type. The deserializer's fixed `[num, String]` order
governs *reading* incoming JSON (try each type in turn) and has no bearing on
how a value must be *written* — reading that order into a serialization index
was the error. Verified directly against `standardSerializers.serialize(...)`
before landing.

**Alternatives considered**: `AnyOf2<num, String>` in either key configuration
— both throw, per the traces above. `AnyOf2<String, num>` with key `1` was not
tried (key `0` is required by the same `valueTypes`-length argument
regardless of parameter order).

**Risk (materialized)**: this was the codebase's **first** `one_of`/`AnyOf`
construction site (`grep` found no existing usage under `lib/features/` or
`lib/core/` — the `_setTaxRate` precedent above existed but its exact index
convention (`String` first, key `0`) wasn't cross-checked against this
wrapper's index semantics before writing the original guidance). The mandatory
round-trip test caught the defect before any UI code depended on it — see
`price_list_repository_impl_test.dart`'s two `AnyOf write path` tests, and the
same pattern must be verified again for US2 (`ProductPriceCreate`/`Update`)
and US3 (`ExchangeRateCreate`/`Update`) since each uses its own generated
wrapper classes, even though the fix generalizes.

**Update DTOs use a *different, separately-generated* wrapper class for the
same field** (flagged by `/speckit-analyze`, 2026-07-14, finding U2). The
openapi-generator could not dedupe the inline `anyOf: [number, string]` schema
across Create and Update request bodies, so it emitted a second class per
field, suffixed `1`. Verified against the generated client — each pair has the
**identical shape** (`AnyOf get anyOf`), so the same `AnyOf2<String, num>`
construction with key `0` applies; only the class name changes:

| Field | Create-side class | Update-side class |
|---|---|---|
| `ProductPriceCreate.price` / `ProductPriceUpdate.price` | `Price` | `Price1` |
| `.lowProfit` | `LowProfit` | `LowProfit1` |
| `.highProfit` | `HighProfit` | `HighProfit1` |
| `ExchangeRateCreate.rate` / `ExchangeRateUpdate.rate` | `Rate` | `Rate1` |
| `PriceListCreate.highProfitMargin` / `PriceListUpdate.highProfitMargin` | `HighProfitMargin` | `HighProfitMargin1` |
| `PriceListCreate.lowProfitMargin` / `PriceListUpdate.lowProfitMargin` | `LowProfitMargin` | `LowProfitMargin1` |

An update, e.g., therefore reads
`builder.anyOf = AnyOf2<String, num>(values: {0: '120.00'})` on a `Price1Builder`
— same pattern, different type. Using the Create-side class name in an update
path (or vice versa) is a compile error, not a silent bug.

---

## 5. "No price set" vs. "price is zero"

**Decision**: The pricing screen **left-joins** the full price-list set against
the product's existing price rows, client-side.

**Rationale**: `GET /api/v1/product-prices?product={id}` returns only rows that
exist; a list with no row for the product is simply absent from the response.
Spec FR-008 requires distinguishing "not set" from "0.00". So the controller
fetches all price lists (`GET /price-lists`) and the product's prices
(`GET /product-prices?product={id}`), then emits one row per price list with a
nullable `ProductPrice`:

- `productPriceId == null` → "not set", the save action **creates**
  (`POST /product-prices`).
- `productPriceId != null` → editable, the save action **updates**
  (`PUT /product-prices/{id}`).

Note `ProductPriceResponse.priceList` is a **nested `PriceListResponse`**, not
an id, so the join key is `priceList.priceListId`.

**Alternatives considered**: relying on the backend to pre-seed a row per list
(legacy `mbe` did this on product create per `docs/specs/01-master-data.md`) —
rejected: the UI must not assume seeding it cannot verify, and
`01-master-data.md` itself notes new price lists do *not* backfill rows onto
existing products.

---

## 6. Currency reference for exchange rates

**Decision**: Add a hand-written `Currency` enum at
`lib/core/domain/currency.dart`, mirroring legacy `CurrencyCode`
(`mbe/docs/constants.md` §CurrencyCode): `mxn(0)`, `usd(1)`, `eur(2)`, with a
`fromValue(int)` lookup.

**Rationale**:

- Spec FR-018 requires currency **selection**, not free-form numeric entry, but
  mbe-api exposes `base`/`target` as bare `int` with **no currency schema** —
  `lib/generated/openapi/lib/src/model/` has no currency model, so there is
  nothing to generate from.
- This does **not** violate constitution §III, which forbids hand-written DTOs
  *for a resource that already has a published schema*. `Currency` is a
  constant enum, not a DTO, and there is direct precedent:
  `lib/core/access/system_object.dart` is a hand-written enum mirroring
  `constants.md` §SystemObjects in exactly this shape.
- `core/domain/` (not `features/catalog/`) because currency is cross-feature —
  `Product.currency` is already a raw `int` (`product.dart:35`) that later
  features (sales, invoicing) will want to render.

**Alternatives considered**:

- *Free-form int field*: violates FR-018. **Rejected.**
- *File an mbe-api issue for a currency enum*: worth doing eventually, but a
  blocking upstream dependency for a 3-value legacy constant is
  disproportionate; §III's repo-boundary rule means we cannot add it ourselves.
  **Deferred** — noted as a follow-up in plan.md, not a blocker.

**Out of scope**: retrofitting `Product.currency` to the new enum — that's a
catalog change, not a pricing one.

---

## 7. Navigation & routing placement

**Decision**: Three new top-level routes, each its own
`StatefulShellRoute` branch, added to the existing `catalogs` nav group:

| Route | Screen | Nav gate |
|---|---|---|
| `/price-lists` | price-lists catalog | `priceLists` (5) + `read` |
| `/pricing` | pricing tool | `pricing` (106) + `read` |
| `/exchange-rates` | exchange-rates catalog | `exchangeRates` (43) + `read` |

**Rationale**: `lib/core/navigation/nav_destinations.dart` (spec 010) already
models the tree declaratively — new destinations are added to `kNavigationTree`
with a `gate`, and `navDestinationsProvider` filters by access automatically
(the widget never calls `can(...)`). `NavBranch` indices must stay in sync with
the branch order in `app_router.dart`. All three legacy objects sit in the
"Master Data" category per `constants.md`, matching the existing `catalogs`
group; no new group is warranted for three destinations.

**Alternatives considered**: a dedicated "Pricing" nav group — rejected as
premature for three entries; revisit if the group grows.

---

## 8. Duplicate exchange rate for a date + currency pair

**Decision**: No client-side pre-check. Submit and surface whatever mbe-api
returns through the shared error mapping.

**Rationale**: mbe-api's OpenAPI spec declares no uniqueness constraint on
(`date`, `base`, `target`), and the UI cannot know the server's rule. Spec's
edge case requires only that the outcome be *clear*, not that the client
predict it. A client-side "does it exist?" probe would be a TOCTOU race and
would encode a rule we cannot verify.

**Alternatives considered**: pre-flight GET on the pair/date — rejected
(racy, extra round-trip, guesses at a server rule).

---

## 9. Testing approach

**Decision**: Mirror the catalog feature's existing three-tier split —
`flutter_test` unit tests with `mocktail` repository fakes, widget tests per
screen, and one `integration_test` golden path (create price list → price a
product on it → record an exchange rate) run against a live mbe-api per
quickstart.md.

**Rationale**: constitution "Development Workflow & Quality Gates" mandates all
three tiers; `test/unit|widget|integration/features/catalog/` already
establishes the layout and `mocktail` is already a dev dependency.

**Additional required coverage** (beyond the standard tiers): a repository
round-trip test proving the §4 `AnyOf` write path actually serializes — the
feature's highest-risk unknown.

---

## 10. Date input for exchange rates

**Decision**: Use Flutter's built-in `showDatePicker` (single date, the
exchange-rate form) and `showDateRangePicker` (date-range filter, the
exchange-rates list) directly. **No new shared `core/widgets/` date component
is introduced.**

**Rationale**: `grep` confirms no date-picker/date-field widget exists
anywhere in `lib/core/widgets/` or `lib/features/catalog/` today — FR-018 and
the original tasks.md wording incorrectly assumed a "shared locale-aware date
input" already existed for reuse (flagged by `/speckit-analyze`, 2026-07-14,
finding U1). `showDatePicker`/`showDateRangePicker` are already locale-aware
through the app's configured `MaterialLocalizations` (es-MX,
`flutter_localizations`, constitution §V) with zero extra setup, and this
feature has exactly two call sites — one single-date field, one range filter —
not enough repetition to justify a new shared abstraction under constitution
§VI's "implemented once" guidance.

**Alternatives considered**: build a new `core/widgets/date_field.dart` (+ a
range variant) — rejected as premature for two call sites; revisit if a third
pricing-adjacent date input appears in a future feature.
