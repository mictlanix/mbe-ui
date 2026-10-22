# Quickstart: Supplier Sub-Panels

**Feature**: [spec.md](./spec.md) | **Contracts**: [contracts/ui-contracts.md](./contracts/ui-contracts.md)

These steps show that the feature works end to end. Implementation details are in `tasks.md`.

## Prerequisites

- Constitution **v1.14.0** has merged (branch `docs/record-surface-criteria`, research R1).
- mbe-api has #251 and #252 on the target deployment (the test tenant has both).
- The live tests need an administrator account, passed with `--dart-define` as `MBE_CATALOG_TEST_USERNAME` and `MBE_CATALOG_TEST_PASSWORD` (see TEST_ACCOUNTS.md). This is the same convention `crud_panel_flow_test.dart` uses.
- A second account with Suppliers Read only, for the access checks.

## 1. Automated checks

```bash
dart run build_runner build --delete-conflicting-outputs   # freezed / riverpod
flutter gen-l10n
flutter analyze
flutter test test/unit test/widget
flutter test test/integration/supplier_sub_panels_live_test.dart \
  --dart-define=MBE_CATALOG_TEST_USERNAME=… --dart-define=MBE_CATALOG_TEST_PASSWORD=…
```

**Expected:**
- Analyze is clean, and the unit and widget tests are green.
- The live test runs the following round trip and leaves no records behind:
  1. Create a bank account.
  2. Create a supplier with links.
  3. Read the detail back.
  4. Add, change and remove an agreement.
  5. Delete the supplier while it still has links: refused with 409.
  6. Unlink everything, then delete.

## 2. Manual walkthrough (administrator, web build)

| # | Step | Expected | Spec |
|---|---|---|---|
| 1 | `/suppliers`, click a row | A full page opens, titled "Ver proveedor", with four sections and no side panel | FR-001, FR-004 |
| 2 | Open a supplier with migrated links | The sections match the server. Spot-check 10 suppliers, including the one with the most links | SC-001 |
| 3 | Editar → link an existing contact → Guardar | Back on the list. Reopening shows the contact | US2-1, SC-002 |
| 4 | Edit → "+ Nueva" bank account → fill it in → Crear → Guardar | The account is created and linked | US2-2, FR-007 |
| 5 | Edit → unlink an address → Cancelar (confirm discard) | The link is still there on reopening | US2-4, FR-008 |
| 6 | The picker after linking | The linked record is not offered again | FR-009 |
| 7 | "+ Nuevo" supplier → link an address → Guardar | The page stays open in edit mode, and "Agregar convenio" is available | FR-015a |
| 8 | Agregar convenio with end before start | Guardar is disabled, with an error under Fin | FR-013, SC-004 |
| 9 | Add an agreement with equal start and end | Accepted | Edge cases |
| 10 | ✎ on an agreement → change Fin → Guardar | The row updates, and unsaved supplier edits elsewhere on the page are kept | FR-012 |
| 11 | ✎ → Eliminar → confirm | The row disappears. Rows show no trash icon | FR-014 |
| 12 | Delete a supplier with a link | The specific "remove the links and agreements first" message appears, and the supplier is kept | FR-017, SC-005 |
| 13 | Change the code to another supplier's code → Guardar | The combined conflict message appears, and the form keeps its edits | FR-011 |
| 14 | Narrow the window to the compact width | One column. The agreements table shows Start, End and ✎ only | Wireframes, R12 |
| 15 | Switch the language to English | All new text is translated | FR-020 |

## 3. Access walkthrough (read-only account)

| # | Step | Expected | Spec |
|---|---|---|---|
| 1 | Open a supplier | All four sections are visible, with no Editar, link, unlink, "+ …", ✎ or Agregar | FR-018, SC-006 |
| 2 | Administrator removes Read on Bank Accounts only from a profile that has Suppliers Update | No bank-account picker. "+ Nueva" shows only with Create. Linked accounts can still be unlinked | FR-019 |
