# Quickstart: Customer Discounts

**Feature**: [spec.md](./spec.md) | **Contracts**: [contracts/ui-contracts.md](./contracts/ui-contracts.md)

These steps show that the feature works end to end. Implementation details are in `tasks.md`.

## Prerequisites

- mbe-api has #251 (discount endpoints) and #253 (new sales lines start at the customer's discount) on the target deployment. Both merged 2026-10-22.
- An administrator account for the live tests, passed with `--dart-define` as `MBE_CATALOG_TEST_USERNAME` and `MBE_CATALOG_TEST_PASSWORD`. This is the same convention `supplier_sub_panels_live_test.dart` uses.
- `MBE_READONLY_USERNAME` / `_PASSWORD`, a non-admin account with Customers Read, for the access checks (see `test/integration/TEST_ACCOUNTS.md`).

## 1. Automated checks

```bash
dart run build_runner build --delete-conflicting-outputs   # freezed / riverpod
flutter gen-l10n
flutter analyze
flutter test test/unit test/widget
flutter test test/integration/customer_discounts_live_test.dart \
  --dart-define=MBE_CATALOG_TEST_USERNAME=… --dart-define=MBE_CATALOG_TEST_PASSWORD=…
```

Format only the files you changed. Don't run `dart format .`.

**Expected:**
- Analyze is clean, and the unit and widget tests are green, including `formatting_guard_test`.
- The live test runs the following round trip and restores the customer as it found it:
  1. Find a customer and an active product with no discount for it.
  2. Create a 10 % discount.
  3. A repeat create is refused with 409.
  4. Update it to 12.5 %.
  5. Read it back as the fraction `0.125`.
  6. Delete it.
  7. Delete it again: refused with 404.

## 2. Manual walkthrough (administrator, web build)

| # | Step | Expected | Spec |
|---|---|---|---|
| 1 | Open a customer that has migrated discounts | The Discounts section lists them in product-code order, with code, name and `NN.NN %` | US1-1, FR-002, FR-003 |
| 2 | Spot-check 10 customers, including the one with the most discounts, against `GET /customers/{id}/discounts` | Nothing is missing or extra, and the rates match | SC-001 |
| 3 | Open a customer with no discounts | Empty-state text | US1-2 |
| 4 | **Agregar descuento**, then search a product that already has a discount | That product isn't offered | US2-2, FR-005 |
| 5 | Pick another product and type `-1`, `101`, `abc`, `1.1234567` | Save is disabled, with a specific message under the field for each | US2-3, FR-006, SC-003 |
| 6 | Type `10` and save | The row appears at `10.00 %`, and it's still there after reload | US2-1, SC-002 |
| 7 | Edit the field (name or zone) without saving, then add a discount | The discount saves, and the field edit is still pending and dirty | FR-010 |
| 8 | Edit the new discount | The product is read-only and the field shows `10`. Change it to `12.5` and save: the row shows `12.50 %` | US3-1, US3-2 |
| 9 | Edit it, then **Eliminar** and confirm | The row disappears | US3-3, FR-009 |
| 10 | Open the same customer in two tabs. Add product P in tab A, then try to add P in tab B | Tab B's dialog stays open with the duplicate message, and the section refreshes to show P | US2-4, FR-011 |
| 11 | In tab A, delete a discount. In tab B, edit and save it | The "no longer exists" message, and the row disappears | US3-4 |
| 12 | **Nuevo cliente**, fill in the fields and save | The page stays on the new customer in edit mode, with **Agregar descuento** available | US2-7, FR-007a |
| 13 | Before saving a new customer, look at Discounts | The after-save note, and no add button | US2-6, FR-007 |
| 14 | Edit an existing customer and save | Returns to the list, as before | FR-007a |
| 15 | Go back from a customer and click **Nuevo cliente** immediately | The new form is empty (mbe-ui#207) | R8 |

## 3. Sales picks up the discount (end to end)

| # | Step | Expected | Spec |
|---|---|---|---|
| 1 | Give customer C a 10 % discount on product P | — | — |
| 2 | Back-office **Pedidos**: start an order for C and add P | The line's discount reads 10 % without being typed | US2-8, FR-013, SC-004 |
| 3 | Change C's discount on P to 15 %, and look at the same order | The existing line still reads 10 % | US3-5 |
| 4 | Repeat step 2 on the POS register for C | The line starts at the discount | FR-013 |

## 4. Access (read-only account)

| # | Step | Expected | Spec |
|---|---|---|---|
| 1 | Sign in with `MBE_READONLY` and open a customer with discounts | Rows are visible, with no add button and no row Edit icons | US1-4, FR-012, SC-005 |
| 2 | As admin, open a customer in View mode (row click) | No add or Edit controls until **Editar** is pressed | R9 |
| 3 | An account with Customers Update but no Products Read | Rows and Edit are visible, the add button is hidden | FR-012 |
