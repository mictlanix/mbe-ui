# Phase 1 Data Model: App Settings, User Settings & Cross-Widget Consistency

**Feature**: 027-app-user-settings | **Date**: 2026-08-16

No mbe-api entities are added or changed (SC-011). Everything here is
client-side: two configuration values, one derived formatting value, and one
set of device-local preferences.

---

## 1. `AppSettings` — deployment configuration

Immutable, resolved once at startup from build-time values (research R7).
Never mutable from the UI (FR-007). Lives in `lib/core/config/`.

| Field | Type | Env key | Default | Notes |
|---|---|---|---|---|
| `apiBaseUrl` | `String` | `API_BASE_URL` | `http://127.0.0.1:8000` | moved from `dio_client.dart`, value unchanged |
| `photosBaseUrl` | `String` | `PHOTOS_BASE_URL` | *= `apiBaseUrl`* | **must stay a `const` cross-reference** (research R7) |
| `posDefaultCustomerId` | `int` | `POS_DEFAULT_CUSTOMER_ID` | `1` | moved from `pos_defaults.dart` |
| `brand` | `BrandConfig` | `BRAND_*` | *(see §1.1)* | **composed, not absorbed** |
| `formatting` | `FormattingSettings` | *(see §1.2)* | | new |
| `defaultLocale` | `Locale` | `DEFAULT_LOCALE` | `es_MX` | replaces the hard-coded literal in `app.dart:30` |

**Validation**: every field parses with fallback to its default. A malformed
value never prevents startup (FR-005) — the rule `BrandConfig._parseSeedColor`
already establishes for a bad hex colour.

**Exposure**: `appSettingsProvider`, overridable in tests (constitution §II).

### 1.1 `BrandConfig` — unchanged

Kept exactly as it is, including `usesDefaultPalette`'s "unset vs. explicitly
set to the same value" distinction (spec 019 FR-007). `AppSettings` holds it
as a field; `brandConfigProvider` is re-pointed at `appSettingsProvider.brand`
so there remains one instance, not two.

### 1.2 `FormattingSettings` — the formatting knobs

| Field | Type | Env key | Default | Renders today's output |
|---|---|---|---|---|
| `currencySymbol` | `String` | `CURRENCY_SYMBOL` | `$` | ✅ matches the hard-coded `r'$'` |
| `currencyCode` | `String` | `CURRENCY_CODE` | `MXN` | new; unused by the symbol path, carried for display/reporting |
| `currencyDecimalDigits` | `int` | `CURRENCY_DECIMAL_DIGITS` | `2` | ✅ |
| `datePattern` | `String` | `DATE_FORMAT` | `yMd` | ✅ `DateFormat.yMd` |
| `dateTimePattern` | `String` | `DATE_TIME_FORMAT` | `yMd Hm` | ✅ `DateFormat.yMd().add_Hm()` |
| `percentDecimalDigits` | `int` | `PERCENT_DECIMAL_DIGITS` | `2` | ✅ matches `"16.00 %"` |
| `quantityDecimalDigits` | `int` | `QUANTITY_DECIMAL_DIGITS` | `0` | trailing zeros dropped, as today |

Every default reproduces current rendering byte-for-byte, so no shipped
deployment changes appearance on upgrade (spec Assumptions).

---

## 2. `AppFormatters` — the single formatting surface

Derived, not configured: a value object built from `FormattingSettings` +
resolved locale (§4). Lives in `lib/core/formatting/`. Exposed as
`formattersProvider`; resolved once per build by call sites (research R3).

Two explicitly separate groups — this separation *is* FR-011:

### 2.1 `display.*` — read-only rendering

| Method | In | Out (es-MX defaults) |
|---|---|---|
| `currency(String?)` | `"120.5"` | `"$120.50"` |
| `percent(String?)` | `"0.16"` | `"16.00 %"` |
| `date(DateTime?)` | | `"16/8/2026"` |
| `dateTime(DateTime?)` | | `"16/8/2026 14:30"` |
| `quantity(String?)` | `"3.0000"` | `"3"` |

### 2.2 `field.*` — editable-field rendering, with inverses

| Method | In | Out | Inverse |
|---|---|---|---|
| `price(String)` | `"50.0000000"` | `"50.00"` | `parsePrice` |
| `rate(String)` | `"0.1600"` | `"16"` | `parseRate` |
| `quantity(String)` | `"3.0000"` | `"3"` | `parseQuantity` |

**Invariant (FR-012)**: `parseX(field.x(v)) == v` for every value the domain
can hold — asserted as a property test, not per-example.

### 2.3 Absent / unparseable input (FR-014)

One rule, applied by every method, replacing today's three disagreeing
behaviours (`MoneyFormatters` returns a formatted `0`; `money.dart` returns
the raw input unchanged; `cash_sessions_screen.dart` hand-writes `'—'`):

- `null` → the em-dash placeholder `—`
- unparseable non-null → the em-dash placeholder `—`

Callers that need a different empty rendering pass it explicitly; they do not
re-implement formatting.

### 2.4 Migration map

| Replaced | Sites | By |
|---|---|---|
| `MoneyFormatters.currency/percent/date/dateTime` | 53 | `display.*` |
| `money.dart`: `formatQuantity`, `formatPrice`, `formatRateAsPercent`, `formatRateAsPercentWithSymbol`, `parsePercentAsRate` | 24 | `field.*` / `display.percent` |
| inline `DateFormat.yMd()` (`taxpayer_certificates_section.dart:51`) | 1 | `display.date` |
| `_dateFacetFormat` (`pos_sales_list_controller.dart`) | 1 | **not migrated** — query encoder, exempt (research R4) |

---

## 3. `UserDisplayPreferences` — device-local

Persisted via `shared_preferences`, loaded before `runApp` (research R5).
Distinct from the server-side `UserSettings` in `core/access/user_settings.dart`
(cash drawer, point of sale) — constitution §V requires the naming keep them
distinguishable, which is why this is `UserDisplayPreferences`, not
`UserSettings`.

| Field | Type | Pref key | Default | Applies to |
|---|---|---|---|---|
| `themeMode` | `ThemeMode` | `theme_mode` *(existing key — must not change)* | `system` | `MaterialApp.themeMode` |
| `textSizeLevel` | `TextSizeLevel` | `text_size_level` | `normal` | `MediaQuery.textScaler` (research R1) |
| `localeOverride` | `Locale?` | `locale_override` | `null` (= follow deployment/system) | `MaterialApp.locale` + `formattersProvider` |

**Existing key preserved**: `theme_mode` already holds users' choices; reusing
it satisfies FR-017's "without losing an already-persisted choice".

**Corrupt value (FR-022)**: treated as absent → default. Never an error.

### 3.1 `TextSizeLevel`

| Level | Factor | Notes |
|---|---|---|
| `small` | 0.9 | |
| `normal` | 1.0 | **default — identity, so goldens/screenshots are unaffected** |
| `large` | 1.15 | |
| `extraLarge` | 1.3 | the level FR-024 must be verified against |

Exactly four (FR-019, constitution §V). The factor composes with the platform
scaler rather than replacing it (research R1).

---

## 4. Resolved locale — derived

One provider, feeding both `MaterialApp.locale` and `formattersProvider`, so
the interface language and formatted values cannot disagree:

```
localeOverride ?? appSettings.defaultLocale   // then validated against
                                              // AppLocalizations.supportedLocales,
                                              // falling back to the deployment
                                              // default, then to supportedLocales.first
```

---

## 5. Sale-line layout metrics — changed shape, not new data

`features/sales/presentation/capture/sale_line_layout.dart`'s vertical
constants become functions of the effective text scaler (research R2). Not
entities, but recorded here because the change is a contract other widgets
depend on:

| Today | Becomes |
|---|---|
| `const saleLineFieldHeight = 52.0` | `saleLineFieldHeight(TextScaler)` |
| `const saleLineTextFieldPadding` | derived from the above |
| `const saleLineDropdownPadding` | derived from the above |
| `const saleLineSingleRowMinWidth = 950.0` | `saleLineSingleRowMinWidth(TextScaler)` |
| column widths (168/132/88/76/88/100/48) | **unchanged** — secondary text ellipsizes |

The file's existing invariant is preserved and is exactly what US6 needs: text
fields and dropdowns pay their height difference *in padding*, so both boxes
match in height **and** both centre their text on the line total's baseline.
