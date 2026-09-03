# Contract: App Settings Additions

**Feature**: 036-live-testing-fixes | **Extends**: `lib/core/config/app_settings.dart`

## C1 — Two new deployment-level settings

| Setting | Env var | Type | Default | Parse-failure fallback |
|---|---|---|---|---|
| Search-field debounce | `INPUT_DEBOUNCE_MS` | int (ms) | `300` | `300` |
| Quantity-commit debounce | `QUANTITY_COMMIT_DEBOUNCE_MS` | int (ms) | `400` | `400` |

- Both resolve once at startup via `--dart-define-from-file=.env`, exactly like every other app
  setting — never UI-mutable, never a per-user preference.
- A malformed or absent value MUST fall back to the documented default rather than failing
  startup or throwing, mirroring `FormattingSettings._parseDigits`.
- Both MUST be documented in `.env.template` with their default and a one-line description.

## C2 — Consumers

| Field/widget | Setting used |
|---|---|
| `catalog_entity_picker.dart` search debounce | search-field debounce |
| `product_search_field.dart` search debounce | search-field debounce |
| `quantity_stepper.dart` (`kQuantityCommitDebounce`) and its two reusers (`destination_card.dart`, `sale_line_editing.dart`) | quantity-commit debounce |

No consumer MUST keep its own hardcoded `Duration` literal for these delays after this feature
ships (spec.md FR-029).

## C3 — Currency decimal digits (no new setting — closing existing gaps)

`AppSettings.formatting.currencyDecimalDigits` already exists and already defaults to 2. This
feature adds **no new field** for it. What changes is which call sites route through it:

- The pricing grid's editable cell (seed and commit) and the single-product pricing dialog must
  route through `AppFormatters.field.price()`/`parsePrice()` instead of a raw wire-string
  pass-through (see `research.md` R10 and `contracts/pricing-grid-commit.md`).
- The percent-adjust helper's internal rounding must use `currencyDecimalDigits` instead of a
  hardcoded `2`.

No other currency-displaying field was found bypassing this setting during Phase 0 research;
if implementation discovers another one, it is in scope for FR-026/FR-027 to fix.
