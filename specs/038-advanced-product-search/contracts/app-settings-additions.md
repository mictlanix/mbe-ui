# Contract: App settings additions

**Feature**: 038-advanced-product-search | **Date**: 2026-09-09

One new deployment-level option (FR-024, FR-025). Build-time only, never
mutable from the UI, documented default — constitution §V's app-settings rule.

---

## C1. `PRODUCT_SEARCH_MULTI_SELECT`

| | |
|---|---|
| Env key | `PRODUCT_SEARCH_MULTI_SELECT` |
| Type | `bool` |
| Default | `true` (multiple selection) |
| Field | `AppSettings.productSearchMultiSelect` |
| Provider | `productSearchMultiSelectProvider` (`lib/core/config/app_settings_provider.dart`) |
| Consumed by | the advanced search screen only |

**Parsing rule** — read as a string, parsed in Dart, fallback rather than throw:

```
'true'  (any case) → true
'false' (any case) → false
anything else      → the default (true)
```

Read via `String.fromEnvironment('PRODUCT_SEARCH_MULTI_SELECT', defaultValue: 'true')`
rather than `bool.fromEnvironment`, so that a malformed value falls back to the
documented default instead of silently resolving to `false` — the same reason
`INPUT_DEBOUNCE_MS` is a string (`app_settings.dart:96`).

**`.env.template` entry** (app-settings block, near `POS_DEFAULT_CUSTOMER_ID`):

```
# Whether the sales product search's "Advanced search" screen lets the
# operator pick several products at once (true) or exactly one (false).
# Anything other than true/false falls back to the default.
PRODUCT_SEARCH_MULTI_SELECT=true
```

**Debug audit line**: added to `AppSettings.fromEnvironment`'s `kDebugMode`
`debugPrint`, alongside the other keys.

**Tests** (`test/unit/core/config/app_settings_test.dart`):

1. `AppSettings.fromEnvironment()` with no `--dart-define` yields
   `productSearchMultiSelect == true` (add to the existing all-defaults test).
2. The parser's documented rule, mirrored inline the way the debounce group
   does it: `'true'`→true, `'TRUE'`→true, `'false'`→false, `''`→default,
   `'yes'`→default, `'1'`→default.

---

## C2. Not added

For the record, so a later reader does not re-litigate it:

- **No per-user override.** Selection mode is deployment configuration, not
  display taste; constitution §V forbids conflating the two levels, and adding
  it to `UserDisplayPreferences` would give a personal setting a deployment
  meaning.
- **No selection cap setting.** Spec Assumption 6 — a limit can be added later
  if real use finds one; a knob nobody has asked for is not shipped.
- **No page-size setting.** The picker uses the catalog's fixed page size of 20
  (`products_list_controller.dart:15`), like every other list in the app.
