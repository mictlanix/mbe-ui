# Quickstart: Validating Spec 048

**Contracts**: [contracts/ui-contracts.md](./contracts/ui-contracts.md) | **Data model**: [data-model.md](./data-model.md)

## Prerequisites

- mbe-api running locally, with `.env` configured.
- Accounts: see the memory note on dev tenant accounts. The `MBE_POS_*` account is the admin account. You also need one non-admin cashier account without `customerPayments` read, to check FR-013.
- `flutter pub get`, then `dart run build_runner build --delete-conflicting-outputs`, then `flutter gen-l10n`.

## Automated checks

```bash
flutter analyze
flutter test test/unit/features/auth/password_policy_test.dart \
             test/widget/features/auth/new_password_fields_test.dart \
             test/widget/features/auth/change_password_screen_test.dart \
             test/widget/features/auth/forgot_password_screen_test.dart \
             test/unit/features/auth/users_controller_test.dart
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
| 2 | S1 | Same form: fix Confirm first, then edit New | Confirm re-validates immediately |
| 3 | S1 | Admin → Users → New. Type a mismatched password and confirmation | The user is not saved |
| 4 | S4 | Any password form before #241 ships | The checklist shows a single rule, "At least 6 characters". It turns green at 6 characters |
| 5 | S2 | POS sales list. Open a paid counter sale with a zero balance | The detail view: facts strip, read-only lines, totals and payments. No stepper, selector, or edit/pay actions |
| 6 | S2 | Same view → Ticket | The preview opens with Print |
| 7 | S2 | Open a completed sale that still has a balance | Opens on Cobro, as before |
| 8 | S2 | Open a paid delivery sale with pending distribution, then a fully distributed one | Entrega first, then the detail view |
| 9 | S2 | Log in as the cashier without `customerPayments` read and open a paid sale | Detail shows, and the payments area reads "No tienes permiso…" |
| 10 | S3 | New sale. Add a product stocked in another facility, then open the line's warehouse field | Selectable local warehouses, then a greyed "Otros almacenes" section with quantities (before #242) |
| 11 | S3 | Tap a greyed row | Nothing is selected and the dialog stays open |
| 12 | S3 | Use a product with no stock elsewhere, then a non-stockable product | First "No hay existencia en otras sucursales.", then no section |
| 13 | S3 | Resize to 390 px with a long list | The dialog scrolls, with no overflow |

## After each upstream issue ships

- **#242**: regenerate the client and re-run scenario 10. Groups are headed "Otras sucursales" and show facility names.
- **#241**: regenerate, change the deployment policy (e.g. require a symbol), and re-run scenario 4. The checklist follows the policy. A server rejection shows the localized rule.
- **#240**: regenerate, create a user as admin, then log in as that user.
  - The forced-change screen appears, and typed URLs redirect back to it.
  - Logout works.
  - After the change, the app opens at `/`, and the screen doesn't appear on the next login.
