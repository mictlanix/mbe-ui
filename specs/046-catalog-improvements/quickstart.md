# Quickstart: Catalog Improvements (046)

## Prerequisites

- A Flutter toolchain matching the repo.
- `.env` pointing at a dev mbe-api. The admin account is enough for every check; see the memory note on dev tenant accounts.
- After the arb edits, run `flutter gen-l10n`. Commit the regenerated `lib/l10n/app_localizations*.dart` files.
- `dart run build_runner build --delete-conflicting-outputs` after freezed state changes.

## Automated checks

```bash
flutter analyze
flutter test test/unit/features/catalog/customer_form_controller_test.dart \
             test/widget/features/catalog/customer_form_test.dart \
             test/widget/features/catalog/linked_records_section_test.dart \
             test/widget/features/catalog/taxpayer_recipient_inline_create_test.dart \
             test/widget/features/sales/customer_inline_create_test.dart \
             test/widget/features/sales/quote_customer_inline_create_test.dart \
             test/unit/features/catalog/facility_children_controller_test.dart \
             test/widget/features/catalog/facilities_list_screen_test.dart \
             test/widget/core/widgets/product_photo_test.dart \
             test/widget/core/widgets/product_photo_preview_test.dart \
             test/widget/features/catalog/products_list_screen_test.dart
flutter test   # full suite, including formatting_guard_test
```

Live check, against dev mbe-api:

```bash
flutter test test/integration/facility_children_controller_live_test.dart --dart-define-from-file=.env
```

## Manual validation

| # | Story | Steps | Expected |
|---|---|---|---|
| 1 | US1 | Open the Customers list. Edit a customer that has 2 or more RFCs. Change Zone and save. Reopen it. | All RFCs are still linked (SC-002). |
| 2 | US1 | On the same customer, link an existing address, create a new contact with "Nuevo", and unlink one RFC. Save and reopen. | The address and contact are linked. Only the removed RFC is gone. The RFC itself still exists in Contribuyentes. |
| 3 | US1 | Make link changes, then close the sheet. | The discard confirmation appears. If you confirm, nothing changes on the server. |
| 4 | US1 | Create a new customer with 1 address, 1 contact and 1 RFC before the first save. | The customer is created with all three links. |
| 5 | US1 | Sign in as a user with customer read-only access, then click a customer row. | The sections list the links, with no Nuevo, unlink or picker controls. |
| 6 | US1 | In the POS, quick-create a customer with one RFC. | Works as before, with one RFC linked. |
| 7 | US2 | Open Facilities and expand a production site. | You see Warehouses, Points of Sale and Cash Drawers with counts and "+" actions, and no warehouses-only note. Create one POS and one drawer, and both appear. |
| 8 | US3 | Set the app language to Spanish. Open the facility type dropdown and the plant card. | Both read "Planta". "Sitio de producción" appears nowhere. |
| 9 | US4 | In the product list, click a product photo. | A dialog shows the enlarged photo and the product name. The product detail does not open. Esc, the backdrop and × all close it. Clicking a placeholder does nothing. |
| 10 | US4 | In the product detail, click the saved photo. | The same preview opens. |
| 11 | US5 | Look at the product list at pointer and touch densities. | Each thumbnail has an equal gap above and below and a gap from the next column, and is not clipped. |
