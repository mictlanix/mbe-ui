# Quickstart: Validating Spec 048

**Contracts**: [contracts/ui-contracts.md](./contracts/ui-contracts.md) | **Data model**: [data-model.md](./data-model.md)

## Prerequisites

- mbe-api running locally, at a version that includes PRs #244–#246, with **migration `021` applied**. Without it, every `user` read fails.
- Accounts: see the memory note on dev tenant accounts. The `MBE_POS_*` account is the admin account. You also need one non-admin cashier account without `customerPayments` read, for scenario 9.
- `flutter pub get`, then `dart run build_runner build --delete-conflicting-outputs`, then `flutter gen-l10n`.

## Automated checks

```bash
flutter analyze
flutter test test/unit/features/auth test/widget/features/auth \
             test/unit/core/network/auth_interceptor_test.dart \
             test/unit/app/router/app_router_test.dart
flutter test test/unit/features/sales/open_sale_resolution_test.dart \
             test/widget/features/sales/pos_workspace_route_test.dart \
             test/widget/features/sales/pos_sale_detail_view_test.dart
flutter test test/unit/features/sales/other_facility_stock_test.dart \
             test/widget/features/sales/warehouse_picker_dialog_test.dart \
             test/widget/features/sales/sale_line_row_test.dart
flutter test   # full suite, including goldens
```

## Manual scenarios (`flutter run -d chrome`)

| # | Story | Steps | Expected |
|---|---|---|---|
| 1 | S1 | Account menu → Change password. Type different values in New and Confirm | "Passwords don't match" on Confirm, and no submit |
| 2 | S1 | Same form: fill Confirm first, then edit New | Confirm re-validates immediately |
| 3 | S1 | Admin → Users → New. Type a mismatched password and confirmation | The user is not saved |
| 4 | S4 | Any password form, with the default policy. Type `abc12345`, then `Abc12345` | The uppercase rule is unmet at first, then all four rules are met |
| 5 | S4 | Set `PASSWORD_REQUIRE_SYMBOL=true` on mbe-api, restart it, and reopen the form | The checklist gains the symbol rule, with no app change |
| 6 | S2 | POS sales list. Open a paid counter sale with a zero balance | The detail view: facts strip, read-only lines, totals and payments. No stepper, selector, or edit/pay actions |
| 7 | S2 | Same view → Ticket | The preview opens, with Print |
| 8 | S2 | Open a completed sale with a balance, then a paid delivery sale with pending distribution, then a fully distributed one | Cobro, then Entrega, then the detail view |
| 9 | S2 | Log in as the cashier without `customerPayments` read and open a paid sale | The detail shows, and the payments area reads "No tienes permiso…" |
| 10 | S3 | New sale. Add a product stocked in another facility, then open the line's warehouse field | Local warehouses, then "Otras sucursales" with facility subheaders and stock flags |
| 11 | S3 | Pick an other-facility row | The dialog closes, and the line shows "<warehouse> · <facility>". The stock gate uses that warehouse |
| 12 | S3 | Use a product with no stock elsewhere, then a non-stockable product | First "No hay existencia en otras sucursales.", then local warehouses only |
| 13 | S3 | Resize to 390 px with a long list | The dialog scrolls, with no overflow |
| 14 | S3 (#182) | Open a draft whose line is booked to another facility's warehouse. To set one up, use scenario 11 and reopen the sale | The line shows the warehouse name (or `#id`), never empty. The pop-up lists it as selected |
| 15 | S5 | As admin, create a user. Log in as that user | The forced-change screen appears, and typed URLs (e.g. `/sales/pos`) bring the user back |
| 16 | S5 | On that screen, Logout | Back on login |
| 17 | S5 | Log in again and change the password (confirm, policy) | The app opens at `/`. On the next login there's no forced screen |
