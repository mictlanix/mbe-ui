# Quickstart & Validation Guide: Fiscal Catalogs

**Feature**: `015-fiscal-catalogs` | **Date**: 2026-07-21

Runnable validation for the three catalogs. Assumes a local mbe-api with the
2026-07-21 client generation and a signed-in user holding
`paymentMethodOptions` and `taxpayers` privileges (create/read/update/delete),
plus `facilities`/`warehouses` read for the pickers.

## Prerequisites

```bash
flutter pub get
# Codegen (freezed/riverpod/json) for the new entities & controllers:
dart run build_runner build --delete-conflicting-outputs
# Regenerate localizations after editing the .arb files:
flutter gen-l10n
```

- A running mbe-api reachable at the app's configured base URL.
- At least one **Facility** and one **Warehouse** exist (create via the spec-014 catalogs) for the payment-method-option pickers.
- One real **CSD test pair** (`.cer` + `.key` + password) for the certificate upload check — e.g. the SAT test certificates.

## Static checks & tests

```bash
dart analyze
flutter test test/unit/features/catalog/           # mapping + validators
flutter test test/widget/features/catalog/          # screens, filters, RBAC hiding, upload form
flutter test integration_test/fiscal_catalogs_flow_test.dart
```

## Scenario 1 — Payment Method Options CRUD (User Story 1)

1. Sign in; open **Catálogos → Payment Method Options** (`/payment-method-options`).
   - ✅ Paginated list: facility, name, SAT payment form, number of payments, status.
   - ✅ A search box and a filter drawer (facility picker + status chips) are present.
     *(Search returns the full list until the upstream `search` param ships — research §15; it must not filter the current page client-side.)*
2. Open the filter drawer, pick a facility and a status → the list narrows on both, combined.
3. Toolbar **New** → pick a facility, enter a name, choose a SAT payment form, save.
   - ✅ New option appears showing the facility **name** (not id), payment-form **label** (not code); defaults: 1 payment, shown-on-ticket true.
4. Row-click a record → opens **read-only** ("View") with an Edit toggle (if update-privileged).
5. Edit → change commission and "show on ticket", save → reflected in list & detail.
6. In edit, use the delete button in the form body → confirm → record gone.
7. Sign in as a user **without** `paymentMethodOptions` read → destination absent; visiting `/payment-method-options` redirects to `/`.

**Expected**: single request per page; zero per-row lookups (facility/warehouse pre-expanded).

## Scenario 2 — Taxpayer Issuers CRUD (User Story 2)

1. Open **Ventas → Taxpayer Issuers** (`/taxpayer-issuers`).
   - ✅ Paginated list: RFC, C.P. (postal code), Nombre, Régimen Fiscal.
   - ✅ A **functional** server-side search box (no facet drawer — issuer has no backend facets).
2. Toolbar **New** → enter RFC, name, pick fiscal regime (SAT), pick postal code (SAT), choose provider (labeled), optional comment → save.
   - ✅ New issuer appears; regime/postal-code shown by their SAT descriptions.
3. Re-open **New**, enter an RFC that already exists → save → server rejection shown on the form; other input preserved.
4. Open an existing issuer for edit → ✅ **RFC field is present but disabled**; name/regime/provider/postal-code/comment editable.
5. Change the name → save → reflected in list & detail. Confirm no path lets you change the RFC.
6. Delete an issuer from its detail form body → confirm → gone. (If it still has certificates, a server rejection is shown instead.)
7. Sign in without `taxpayers` read → destination absent; `/taxpayer-issuers` redirects to `/`.

## Scenario 3 — Taxpayer Certificates upload + read-only (User Story 3)

1. Ensure at least one issuer exists (Scenario 2).
2. Open **Ventas → Taxpayer Certificates** (`/taxpayer-certificates`).
   - ✅ Paginated list: certificate id, taxpayer RFC, valid-from, valid-to, status.
   - ✅ Search box + filter drawer (taxpayer picker + status). ✅ **No** create-via-row, **no** Edit icon, **no** Delete icon on rows.
3. Toolbar **New** (upload form, `/taxpayer-certificates/new`):
   - Select taxpayer issuer (picker over registered issuers).
   - Pick `.cer` (certificate) and `.key` (key) files via the file picker; enter key password.
   - ✅ Submit is blocked until both files and a password are provided.
   - Submit a valid CSD pair → ✅ certificate registered; list shows a validity window you never typed.
   - **Encoding check**: if the server rejects a valid pair, verify the byte→string encoding (base64-of-DER assumed — research §8) matches what mbe-api expects; adjust the encode once and re-test.
4. Submit an invalid pair / wrong password / mismatched taxpayer → ✅ server rejection shown on the form; file selection preserved.
5. Open any certificate → ✅ detail is **read-only**; no edit toggle, no delete anywhere.
6. Sign in without `taxpayers` read → destination absent; `/taxpayer-certificates` redirects to `/`.

## Cross-cutting checks

- **Localization**: toggle language → every new label, column header, validation message, empty state, provider label, and payment-form label renders from the `.arb` resources in both languages (SC-008).
- **NavBranch invariant**: the highlighted nav item matches the open screen for all three new destinations (branch order 18/19/20 matches router).
- **Empty states**: each list shows a distinct empty message when no records match, separate from the loading spinner.

## Definition of done (validation)

- [ ] Scenarios 1–3 pass end-to-end against a local mbe-api.
- [ ] Certificate upload encoding confirmed against one real CSD pair.
- [ ] `dart analyze` clean; unit/widget/integration suites green.
- [ ] RBAC hiding verified for all three catalogs (nav + route redirect + action affordances).
- [ ] No per-row lookups on any list (network panel shows one request per page).
