# Quickstart: Advanced Product Search

**Feature**: 038-advanced-product-search | **Branch**: `038-advanced-product-search`

How to build, run and prove this feature works. Artifacts:
[spec.md](./spec.md) · [plan.md](./plan.md) · [research.md](./research.md) ·
[data-model.md](./data-model.md) ·
[contracts/advanced-search-screen.md](./contracts/advanced-search-screen.md) ·
[contracts/app-settings-additions.md](./contracts/app-settings-additions.md)

---

## Build & codegen

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # riverpod/freezed for the new providers
flutter gen-l10n                                            # REQUIRED after touching either .arb
flutter analyze
```

`flutter gen-l10n` is not optional and not implied by `build_runner`: a new
`.arb` key without it yields a stale `AppLocalizations` — a missing getter at
build time, not an analyzer error.

---

## Run

```bash
# Multiple selection (the default)
flutter run -d chrome --dart-define-from-file=.env.settings

# Single selection
flutter run -d chrome --dart-define-from-file=.env.settings \
  --dart-define=PRODUCT_SEARCH_MULTI_SELECT=false
```

`.env.settings` is the local app-settings file `.vscode/launch.json` already
points at; add `PRODUCT_SEARCH_MULTI_SELECT` there to exercise it from the IDE
run configuration.

---

## Validation scenarios

Each maps to a spec story. Sign in as an account with `products` read plus a
register or sales-order privilege (`MBE_ADMIN_*` satisfies both).

### V1 — Add one product (US1, FR-004→FR-007, FR-019, FR-020)

1. Open `/sales/pos/new`, choose a customer, type `mart` into the product field
   **without submitting**, press **Búsqueda avanzada**.
2. Expect: the screen opens with `mart` already in its search box; the table
   shows photo/code/name/brand/unit and a leading checkbox — **no status column,
   no row icons**.
3. Tap a row (anywhere), press **Agregar (1)**.
4. Expect: back on the sale, one new line for that product, priced, quantity 1
   (or the product's `minOrderQty` when it is greater), and every pre-existing
   line untouched.

### V2 — Filters (US2, FR-008→FR-011)

1. From the screen, open the filters button.
2. Expect: **Stockable** and **Purchasable** chips, supplier picker, label
   picker. **No status control and no salable chip.**
3. Pick a supplier and a label. Expect the badge to read the number of selected
   facets (a label counts one each), the table to narrow, and the URL to carry
   `?supplier=…&label=…`.
4. Append `&status=all&salable=false` to the address by hand and reload.
   Expect: **identical results** — the forced facets win (FR-008).
5. Clear all. Expect the table to return to every active, salable product.

### V3 — Multiple selection across pages (US3, FR-017, FR-019)

1. Build with the default (multiple). Tick two products on page 1, page to
   page 2, tick a third, change a filter, page back.
2. Expect: the count reads 3 throughout; every earlier tick still set.
3. Press **Agregar (3)**. Expect three lines on the sale, in the order ticked.

### V4 — Partial failure (US3 scenario 6, FR-021, SC-006)

Hard to force against a live backend; assert it in the widget test
(`skips a product whose lookup returns no matching row`). Manually, the nearest
approximation is to select a product and have the customer's price list not
cover it — the line is skipped, the others are added, and the field lists the
skipped product as `code — name`.

### V5 — Single selection (US4, FR-015, FR-016)

1. Run with `--dart-define=PRODUCT_SEARCH_MULTI_SELECT=false`.
2. Tick a row, then tick another. Expect the first to release; the count never
   exceeds 1 and the button reads **Agregar (1)**.
3. Run with no `--dart-define` at all and confirm multiple selection is back —
   the documented default (FR-025).

### V6 — Access (US5, FR-002, SC-007)

1. As a user without `products` read, open a sale. Expect **no** Búsqueda
   avanzada affordance.
2. Navigate to `/sales/product-search` by address. Expect a redirect to `/`,
   the same treatment `/products` gives.
3. On a sale where the field is disabled (write-gated), expect the affordance to
   be disabled too (FR-003).

### V7 — The sale survives the trip (FR-006, SC-003)

1. With three lines on a POS sale, open advanced search, change a filter twice,
   press **Cancelar**.
2. Expect: back on the same sale, same customer, same three lines, same
   quantities, same step — and **no** new draft sale created.
3. Repeat using the browser's Back button instead of Cancelar. Same expectation.

### V8 — Compact (FR-014)

Narrow the window below 840dp and repeat V1. Expect the filter row to wrap, the
table to scroll horizontally inside itself, the page not to scroll horizontally,
and the Add/Cancel bar to stay reachable.

### V9 — Scan path unchanged (SC-009)

Scan (or type + Enter) a barcode matching exactly one product. Expect the line
to be added directly, with no screen opening and no behavioural change.

### V10 — Ten products, priced and added (SC-005)

The one scenario the widget suite cannot judge: real per-product round trips against a live backend.

1. With multiple selection enabled, tick **10** products and press **Agregar (10)**.
2. Expect: a progress indicator that visibly advances ("Agregando 3 de 10…"), never a frozen field.
3. Expect: all 10 lines on the sale — in tick order — within roughly **5 seconds** of confirming,
   less any product reported as skipped.
4. Expect: exactly 10 lines, never 11 — a slow batch must not let a second confirm through
   (FR-022).

T037 asserts the same counts and ordering against a mock repository; this scenario is only about the
wall-clock budget and the progress being genuinely visible.

---

## Tests

```bash
flutter test test/unit/core/config/app_settings_test.dart
flutter test test/widget/features/sales/advanced_search_screen_test.dart
flutter test test/widget/features/sales/product_search_field_test.dart
flutter test                      # full suite, including the formatting guard
```

Live integration tests need credentials:

```bash
flutter test test/integration --dart-define-from-file=.env
```

Note `test/integration/TEST_ACCOUNTS.md`: `MBE_POS_*` is an administrator, so a
live run **cannot** prove the cashier-privilege case (research R7). V6 is
covered by a widget test with an overridden `accessControlProvider`, not by a
live account.
