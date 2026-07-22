# Tasks: Fiscal Catalogs (Payment Method Options, Taxpayer Issuers, Taxpayer Certificates)

**Input**: Design documents from `/specs/015-fiscal-catalogs/`
**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/](./contracts/)

**Tests**: Included — this project ships unit/widget/integration tests for every catalog (specs 012/013/014 precedent; plan Testing + quickstart). Test tasks are written **first** within each story and must fail before implementation.

**Organization**: Tasks are grouped by user story. Each story is an independently implementable, testable, and shippable increment inside `lib/features/catalog/`.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on an incomplete task).
- **[Story]**: US1 = Payment Method Options, US2 = Taxpayer Issuers, US3 = Taxpayer Certificates.
- Exact file paths are given in each task.

## Path & shared-file conventions

- Feature code: `lib/features/catalog/{domain,data,presentation}/`; shared-kernel: `lib/core/`.
- Generated APIs under `lib/generated/openapi/` are **consumed, never edited** (constitution §III).
- **Shared files touched by all three stories** — edits are additive; do **not** parallelize the *same* shared file across stories:
  - `lib/app/router/app_router.dart` (append branch + sub-routes + `_routeGate` entry)
  - `lib/core/navigation/nav_destinations.dart` (append `NavBranch` index + destination + label; order MUST match router — 18/19/20)
  - `lib/l10n/app_en.arb` + `lib/l10n/app_es.arb` (append keys)
- After any task that adds/edits a `freezed`/`riverpod`-annotated file, run codegen (the per-story `build_runner` task); regenerate localizations with `flutter gen-l10n` after `.arb` edits.

---

## Phase 1: Setup (Shared)

**Purpose**: Confirm the ground the feature builds on; no product code.

- [ ] T001 Confirm the three generated clients (`PaymentMethodOptionsApi`, `TaxpayerIssuersApi`, `TaxpayerCertificatesApi`) and their models are exported from `package:mbe_api_client/mbe_api_client.dart` and reachable, and that `file_picker: ^8.1.2` resolves — run `flutter pub get` and `dart analyze` on a scratch import (research §1, §8). No regeneration.
- [ ] T002 Confirm RBAC objects `paymentMethodOptions(84)` and `taxpayers(24)` already exist in `lib/core/access/system_object.dart` (research §2) — **no edit**; this task only verifies, so no `system_object.dart` change lands.

**Checkpoint**: Generated surface + dependencies verified.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Cross-story prerequisites. **This feature has none that block all three stories** — all shared infrastructure (`CatalogEntityPicker`, `CatalogFilterSheet`, `EntityStatusControls`, `DataTableView`, `CatalogPagination`, `catalog_action_icons`, `ResponsiveFormGrid`, `accessControlProvider`, and the spec-014 Facility/Warehouse + SAT-catalog repositories) already ships. Each user story is self-contained.

- [ ] T003 Establish the NavBranch↔router append order (18=paymentMethodOptions, 19=taxpayerIssuers, 20=taxpayerCertificates) as the contract each story follows when it appends its branch (contracts/routes.md). Documentation/agreement only — the actual constants are added within each story's nav task, in this order.

**Checkpoint**: No blocking foundation code — user stories may begin (in priority order, or in parallel by different developers with coordination on the three shared files).

---

## Phase 3: User Story 1 - Payment Method Options (Priority: P1) 🎯 MVP

**Goal**: A full-CRUD Payment Method Options catalog under Catálogos: paginated list with facility+status filter drawer + search box, and a create/view/edit detail form (facility + optional warehouse pickers, name, number-of-payments, show-on-ticket, SAT payment form, commission, status).

**Independent Test**: Open `/payment-method-options`, filter by facility, create an option (facility + name + payment form), edit its commission and show-on-ticket, view it read-only, delete it — no dependency on US2/US3.

### Tests for User Story 1 (write first; must fail) ⚠️

- [ ] T004 [P] [US1] Entity mapping test (FacilitySummary/WarehouseSummary pre-expansion, Commission→string, status) in `test/unit/features/catalog/payment_method_option_test.dart`
- [ ] T005 [P] [US1] `PaymentForm` lookup test — code→label round-trip for all confirmed members, non-contiguous gaps, unmapped-code fallback, and `1001 FONACOT` present — in `test/unit/features/catalog/payment_form_test.dart`
- [ ] T006 [P] [US1] Form-controller validators test (facility required, name required, numberOfPayments ≥ 1, commission decimal) in `test/unit/features/catalog/payment_method_option_form_controller_test.dart`
- [ ] T007 [P] [US1] List-controller test (pagination, facility+status filter wiring, search wiring) in `test/unit/features/catalog/payment_method_options_list_controller_test.dart`
- [ ] T008 [P] [US1] Repository impl test (list/get/create/update/delete map correctly; partial update) in `test/unit/features/catalog/payment_method_option_repository_impl_test.dart`
- [ ] T009 [P] [US1] List screen widget test (columns, filter drawer, search box present, empty state, Create hidden without create right, Edit icon hidden without update right) in `test/widget/features/catalog/payment_method_options_list_screen_test.dart`
- [ ] T010 [P] [US1] Detail screen widget test (create vs read-only vs edit; optional warehouse; payment-form dropdown; delete-in-body gated) in `test/widget/features/catalog/payment_method_option_detail_screen_test.dart`
- [ ] T011 [P] [US1] Read-denied test (no `paymentMethodOptions` read → route redirects, nav hidden) in `test/widget/features/catalog/payment_method_option_read_denied_test.dart`

### Implementation for User Story 1

- [ ] T012 [P] [US1] Create the `PaymentForm` shared-kernel `{code:label}` lookup in `lib/core/domain/payment_form.dart` — confirmed members (research §5), non-contiguous explicit map, default `0` (N/A), unmapped→raw fallback, and a `// FIXME(payment-form):` comment isolating the `1001 FONACOT` line for easy removal (research §5 impl note)
- [ ] T013 [P] [US1] Create `PaymentMethodOption` detail entity (+ `facilityDisplayName`/`warehouseDisplayName`/`paymentFormLabel` helpers) in `lib/features/catalog/domain/entities/payment_method_option.dart` (data-model §1)
- [ ] T014 [P] [US1] Define `PaymentMethodOptionRepository` interface (`list{search?,facility?,status?}`, `get`, `create`, `update`, `delete`) + `Page` in `lib/features/catalog/domain/repositories/payment_method_option_repository.dart`
- [ ] T015 [US1] Implement `payment_method_option_repository_impl.dart` wrapping `PaymentMethodOptionsApi` (+ Riverpod provider) in `lib/features/catalog/data/payment_method_option_repository_impl.dart` — search wired to the expected (pending) param, facility/status live (research §15). Depends on T013, T014
- [ ] T016 [US1] Add l10n keys to `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb` — nav title, column headers, field labels, payment-form labels (15 members; add a comment beside the `1001 FONACOT` key), validation, empty state, search/filter labels (FR-029); then `flutter gen-l10n`
- [ ] T017 [US1] Implement list + filter controllers in `lib/features/catalog/presentation/payment_method_options_list_controller.dart` (facility+status filter Notifier + paginated list Notifier). Depends on T015
- [ ] T018 [US1] Implement `payment_method_options_list_screen.dart` (DataTableView, CatalogFilterBar + search box, CatalogFilterSheet with facility picker + status chips, row-click→view, Edit row action) in `lib/features/catalog/presentation/payment_method_options_list_screen.dart`. Depends on T016, T017
- [ ] T019 [US1] Implement `payment_method_option_form_controller.dart` (load/create/update/delete state, validators, error codes) in `lib/features/catalog/presentation/payment_method_option_form_controller.dart`. Depends on T015
- [ ] T020 [US1] Implement `payment_method_option_detail_screen.dart` (ResponsiveFormGrid; facility picker (req), warehouse picker (opt), name, numberOfPayments, displayOnTicket switch, PaymentForm dropdown, commission, EntityStatusControls; save + delete-in-body gated) in `lib/features/catalog/presentation/payment_method_option_detail_screen.dart`. Depends on T016, T019
- [ ] T021 [US1] Append route branch + sub-routes to `lib/app/router/app_router.dart` — shell branch `/payment-method-options` (index 18), `/payment-method-options/new`, `/payment-method-options/:paymentMethodOptionId` (`int.parse`, `?view=true`), and the `_routeGate` entry `(paymentMethodOptions, read)` (contracts/routes.md). Depends on T018, T020
- [ ] T022 [US1] Append nav to `lib/core/navigation/nav_destinations.dart` — `NavBranch.paymentMethodOptions = 18`, a `catalogs`-group `NavDestination` gated on `(paymentMethodOptions, read)`, and its label tear-off (order matches router). Depends on T016
- [ ] T023 [US1] Run `dart run build_runner build --delete-conflicting-outputs` for US1's freezed/riverpod files, then `dart analyze` clean and make T004–T011 pass. Depends on T012–T022

**Checkpoint**: Payment Method Options fully functional and independently testable (MVP).

---

## Phase 4: User Story 2 - Taxpayer Issuers (Priority: P1)

**Goal**: A full-CRUD Taxpayer Issuers catalog ("Razones Sociales") under Ventas: paginated, server-side-searchable list (RFC, C.P., Nombre, Régimen) and a create/view/edit form keyed by an immutable RFC, with SAT regime/postal-code pickers, a labeled certification-provider dropdown, and a comment.

**Independent Test**: Open `/taxpayer-issuers`, register an issuer (RFC + name + regime + postal code), confirm the RFC is not editable on re-open, edit the name, delete it — independent of US1/US3.

**Note**: Extends the **existing** list-only `TaxpayerIssuerRepository` (spec-014 facility autocomplete) additively — the existing `list`/lightweight `get` and their consumer must keep working (research §13).

### Tests for User Story 2 (write first; must fail) ⚠️

- [ ] T024 [P] [US2] `TaxpayerIssuer` detail entity mapping test (RFC id, regime/postalCode pre-expansion, provider, name fallback) in `test/unit/features/catalog/taxpayer_issuer_test.dart`
- [ ] T025 [P] [US2] Provider label-map test (each `FiscalCertificationProvider` ordinal → label, unmapped→ordinal fallback) in `test/unit/features/catalog/fiscal_certification_provider_label_test.dart`
- [ ] T026 [P] [US2] Form-controller test (RFC required + create-only/immutable, regime required, name required) in `test/unit/features/catalog/taxpayer_issuer_form_controller_test.dart`
- [ ] T027 [P] [US2] List-controller test (pagination + server-side search wiring) in `test/unit/features/catalog/taxpayer_issuers_list_controller_test.dart`
- [ ] T028 [P] [US2] Repository impl test — **new** CRUD methods map correctly AND the pre-existing `list`/lightweight `get` still behave (regression) — in `test/unit/features/catalog/taxpayer_issuer_repository_impl_test.dart`
- [ ] T029 [P] [US2] List screen widget test (columns RFC/CP/name/regime, functional search box, no facet drawer, RBAC hiding) in `test/widget/features/catalog/taxpayer_issuers_list_screen_test.dart`
- [ ] T030 [P] [US2] Detail screen widget test (RFC editable on create, disabled on edit; provider dropdown; delete gated) in `test/widget/features/catalog/taxpayer_issuer_detail_screen_test.dart`
- [ ] T031 [P] [US2] Read-denied test (no `taxpayers` read → redirect + nav hidden) in `test/widget/features/catalog/taxpayer_issuer_read_denied_test.dart`

### Implementation for User Story 2

- [ ] T032 [P] [US2] Create `TaxpayerIssuer` detail entity in `lib/features/catalog/domain/entities/taxpayer_issuer.dart` (distinct from the retained `taxpayer_issuer_list_item.dart` picker projection; data-model §2)
- [ ] T033 [P] [US2] Add a `FiscalCertificationProvider` display-label map (over the generated enum, no new type; research §7) — e.g. `lib/core/domain/fiscal_certification_provider_label.dart` or a presentation helper
- [ ] T034 [US2] Extend `TaxpayerIssuerRepository` interface — keep `list` + lightweight `get(rfc)→TaxpayerIssuerListItem`; add `getDetail(rfc)→TaxpayerIssuer`, `create`, `update(rfc,…)`, `delete(rfc)` (RFC never in update body) in `lib/features/catalog/domain/repositories/taxpayer_issuer_repository.dart`. Depends on T032
- [ ] T035 [US2] Extend `taxpayer_issuer_repository_impl.dart` to implement the new CRUD methods against `TaxpayerIssuersApi`, preserving existing methods, in `lib/features/catalog/data/taxpayer_issuer_repository_impl.dart`. Depends on T034
- [ ] T036 [US2] Add l10n keys to `lib/l10n/app_en.arb` + `lib/l10n/app_es.arb` — nav title, columns (RFC/C.P./Nombre/Régimen), field labels, provider labels, validation (RFC/regime/name required, duplicate-RFC), empty state, search label (FR-029); then `flutter gen-l10n`
- [ ] T037 [US2] Implement `taxpayer_issuers_list_controller.dart` (paginated list + server-side search Notifier; **no** filter controller — search-only) in `lib/features/catalog/presentation/taxpayer_issuers_list_controller.dart`. Depends on T035
- [ ] T038 [US2] Implement `taxpayer_issuers_list_screen.dart` (DataTableView with RFC/CP/name/regime, CatalogFilterBar + functional search box, no filter drawer, row-click→view, Edit action) in `lib/features/catalog/presentation/taxpayer_issuers_list_screen.dart`. Depends on T036, T037
- [ ] T039 [US2] Implement `taxpayer_issuer_form_controller.dart` (load-for-edit via `getDetail`, create/update/delete, RFC-immutable logic, validators) in `lib/features/catalog/presentation/taxpayer_issuer_form_controller.dart`. Depends on T035
- [ ] T040 [US2] Implement `taxpayer_issuer_detail_screen.dart` (ResponsiveFormGrid; RFC field `enabled && !_isEdit`; name; SAT regime & postal-code `CatalogEntityPicker`s; provider dropdown; comment; save + delete-in-body gated) in `lib/features/catalog/presentation/taxpayer_issuer_detail_screen.dart`. Depends on T033, T036, T039
- [ ] T041 [US2] Append route branch + sub-routes to `lib/app/router/app_router.dart` — shell branch `/taxpayer-issuers` (index 19), `/taxpayer-issuers/new`, `/taxpayer-issuers/:rfc` (**String, no `int.parse`**, `?view=true`), and `_routeGate` entry `(taxpayers, read)` (contracts/routes.md). Depends on T038, T040
- [ ] T042 [US2] Append nav to `lib/core/navigation/nav_destinations.dart` — `NavBranch.taxpayerIssuers = 19`, a `sales`-group `NavDestination` gated on `(taxpayers, read)`, and its label tear-off. Depends on T036
- [ ] T043 [US2] Run `build_runner`, `dart analyze` clean, and make T024–T031 pass; verify the spec-014 facility-form taxpayer autocomplete still works (regression). Depends on T032–T042

**Checkpoint**: Taxpayer Issuers fully functional; US1 still green.

---

## Phase 5: User Story 3 - Taxpayer Certificates (Priority: P2)

**Goal**: A Taxpayer Certificates catalog under Ventas: paginated list (id, taxpayer RFC, valid-from, valid-to, status) with taxpayer+status filter drawer + search box, a **read-only** detail view, and an **upload** (create) form (issuer picker + `.cer`/`.key` file pickers + key password). **No edit, no delete anywhere.**

**Independent Test**: With ≥1 issuer present, open `/taxpayer-certificates`, filter by taxpayer, upload a CSD pair (issuer + two files + password), see the server-derived validity window, open the record read-only — confirming no edit/delete affordance exists.

**Note**: The issuer picker uses the existing `TaxpayerIssuerRepository.list` (shipped by spec 014), so US3 is testable even without US2's catalog.

### Tests for User Story 3 (write first; must fail) ⚠️

- [ ] T044 [P] [US3] `TaxpayerCertificate` entity mapping test (id, taxpayer RFC, validFrom/validTo, status) in `test/unit/features/catalog/taxpayer_certificate_test.dart`
- [ ] T045 [P] [US3] Upload controller/value test (all four fields required before submit; byte→string encode; server-error preserves selection) in `test/unit/features/catalog/taxpayer_certificate_upload_controller_test.dart`
- [ ] T046 [P] [US3] List-controller test (pagination + taxpayer+status filter wiring + search wiring) in `test/unit/features/catalog/taxpayer_certificates_list_controller_test.dart`
- [ ] T047 [P] [US3] Repository impl test (list/get/upload map correctly; **no update/delete methods exist**) in `test/unit/features/catalog/taxpayer_certificate_repository_impl_test.dart`
- [ ] T048 [P] [US3] List screen widget test (columns, filter drawer + search, empty state, **no Edit icon, no Delete icon on rows**, upload button gated on create) in `test/widget/features/catalog/taxpayer_certificates_list_screen_test.dart`
- [ ] T049 [P] [US3] Upload screen widget test (issuer picker, two file pickers, password, submit disabled until complete, RBAC create gating) in `test/widget/features/catalog/taxpayer_certificate_upload_screen_test.dart`
- [ ] T050 [P] [US3] Detail screen widget test (read-only; **no edit toggle in AppBar, no delete button**) in `test/widget/features/catalog/taxpayer_certificate_detail_screen_test.dart`
- [ ] T051 [P] [US3] Read-denied test (no `taxpayers` read → redirect + nav hidden) in `test/widget/features/catalog/taxpayer_certificate_read_denied_test.dart`

### Implementation for User Story 3

- [ ] T052 [P] [US3] Create `TaxpayerCertificate` detail entity + `CertificateUpload` input value in `lib/features/catalog/domain/entities/taxpayer_certificate.dart` (data-model §3)
- [ ] T053 [P] [US3] Define `TaxpayerCertificateRepository` interface (`list{search?,taxpayer?,status?}`, `get`, `upload` — **no `update`, no `delete`**) + `Page` in `lib/features/catalog/domain/repositories/taxpayer_certificate_repository.dart`
- [ ] T054 [US3] Implement `taxpayer_certificate_repository_impl.dart` wrapping `TaxpayerCertificatesApi` (+ provider), including the file byte→string encode (base64-of-DER default; research §8) for the multipart upload, in `lib/features/catalog/data/taxpayer_certificate_repository_impl.dart`. Depends on T052, T053
- [ ] T055 [US3] Add l10n keys to `lib/l10n/app_en.arb` + `lib/l10n/app_es.arb` — nav title, columns, upload-field labels (issuer, certificate file, key file, password), validation (missing file/password, server rejection), empty state, search/filter labels (FR-029); then `flutter gen-l10n`
- [ ] T056 [US3] Implement list + filter controllers in `lib/features/catalog/presentation/taxpayer_certificates_list_controller.dart` (taxpayer+status filter Notifier + paginated list Notifier). Depends on T054
- [ ] T057 [US3] Implement `taxpayer_certificates_list_screen.dart` (DataTableView with id/taxpayer/validFrom/validTo/status, CatalogFilterBar + search box, CatalogFilterSheet with taxpayer picker + status chips, toolbar Upload button gated on create, row-click→read-only view, **no Edit/Delete row icons**) in `lib/features/catalog/presentation/taxpayer_certificates_list_screen.dart`. Depends on T055, T056
- [ ] T058 [US3] Implement `taxpayer_certificate_upload_controller.dart` (issuer selection, two `file_picker` byte reads with extension filters, password, submit/validation/error state) in `lib/features/catalog/presentation/taxpayer_certificate_upload_controller.dart`. Depends on T054
- [ ] T059 [US3] Implement `taxpayer_certificate_upload_screen.dart` (ResponsiveFormGrid; issuer `CatalogEntityPicker<TaxpayerIssuerListItem>`, `.cer` + `.key` file pickers, password field, submit disabled until complete) in `lib/features/catalog/presentation/taxpayer_certificate_upload_screen.dart`. Depends on T055, T058
- [ ] T060 [US3] Implement `taxpayer_certificate_detail_screen.dart` — **read-only** view (id, taxpayer, validFrom, validTo, status); no AppBar edit toggle, no delete button, no editable form in `lib/features/catalog/presentation/taxpayer_certificate_detail_screen.dart`. Depends on T055
- [ ] T061 [US3] Append route branch + sub-routes to `lib/app/router/app_router.dart` — shell branch `/taxpayer-certificates` (index 20), `/taxpayer-certificates/new` → upload screen, `/taxpayer-certificates/:taxpayerCertificateId` (**String**) → detail with `forceReadOnly: true` (no edit route target), and `_routeGate` entry `(taxpayers, read)` (contracts/routes.md). Depends on T057, T059, T060
- [ ] T062 [US3] Append nav to `lib/core/navigation/nav_destinations.dart` — `NavBranch.taxpayerCertificates = 20`, a `sales`-group `NavDestination` gated on `(taxpayers, read)`, and its label tear-off. Depends on T055
- [ ] T063 [US3] Run `build_runner`, `dart analyze` clean, and make T044–T051 pass. Depends on T052–T062

**Checkpoint**: All three catalogs independently functional.

---

## Phase 6: Polish & Cross-Cutting

**Purpose**: End-to-end validation and cleanup across stories.

- [ ] T064 Integration flow test (create issuer → upload its certificate → create a payment method option) in `test/integration/fiscal_catalogs_flow_test.dart`
- [ ] T065 Confirm the CSD `.cer`/`.key` byte→string encoding against one real SAT test pair per quickstart Scenario 3; adjust the encode in `taxpayer_certificate_repository_impl.dart` if the server rejects a valid pair (research §8)
- [ ] T066 [P] Verify the NavBranch↔router branch-order invariant (18/19/20) — highlighted nav item matches the open screen for all three destinations (contracts/routes.md)
- [ ] T067 [P] Full-suite green + lints: `dart analyze` clean, `flutter test`, and `flutter test test/integration/fiscal_catalogs_flow_test.dart`
- [ ] T068 Run the [quickstart.md](./quickstart.md) Scenarios 1–3 against a local mbe-api; confirm localization renders in both languages, empty states, and RBAC hiding (nav + route redirect + action affordances)

---

## Dependencies & Execution Order

### Phase dependencies

- **Setup (Phase 1)** → no dependencies.
- **Foundational (Phase 2)** → after Setup; no blocking code (see T003 note).
- **User Stories (Phases 3–5)** → after Foundational. US1, US2, US3 are each independently implementable and testable. US3's issuer picker relies only on the pre-existing (spec-014) issuer `list`, so US3 does **not** depend on US2 shipping.
- **Polish (Phase 6)** → after the stories you intend to ship (T064 exercises all three).

### Shared-file coordination (not a logic dependency)

`app_router.dart`, `nav_destinations.dart`, and the two `.arb` files are appended by all three stories. When stories run in parallel across developers, serialize edits to each of these four files (append order for nav/router branches must be 18→19→20). Within one story these are separate files and may proceed in parallel where marked `[P]`.

### Within each story

Tests (written first, failing) → entity/lookup + repository interface (`[P]`) → repository impl → l10n → controllers → screens → router + nav → `build_runner`/analyze/green.

## Parallel opportunities

- **Setup**: T001, T002 sequential-light (both quick verifications).
- **US1 tests**: T004–T011 all `[P]`. **US1 first code**: T012, T013, T014 `[P]`.
- **US2 tests**: T024–T031 all `[P]`. **US2 first code**: T032, T033 `[P]`.
- **US3 tests**: T044–T051 all `[P]`. **US3 first code**: T052, T053 `[P]`.
- **Cross-story**: with coordination on the four shared files, US1/US2/US3 can be built in parallel by three developers.

## Parallel example — User Story 1 tests

```bash
Task: "Entity mapping test in test/unit/features/catalog/payment_method_option_test.dart"
Task: "PaymentForm lookup test in test/unit/features/catalog/payment_form_test.dart"
Task: "Form-controller validators test in test/unit/features/catalog/payment_method_option_form_controller_test.dart"
Task: "List-controller test in test/unit/features/catalog/payment_method_options_list_controller_test.dart"
Task: "Repository impl test in test/unit/features/catalog/payment_method_option_repository_impl_test.dart"
Task: "List screen widget test in test/widget/features/catalog/payment_method_options_list_screen_test.dart"
Task: "Detail screen widget test in test/widget/features/catalog/payment_method_option_detail_screen_test.dart"
Task: "Read-denied test in test/widget/features/catalog/payment_method_option_read_denied_test.dart"
```

## Implementation strategy

### MVP first (User Story 1 only)

1. Phase 1 Setup → Phase 2 Foundational → Phase 3 (US1).
2. **STOP and validate**: run US1 tests + quickstart Scenario 1.
3. Ship Payment Method Options as the MVP.

### Incremental delivery

Add US2 (Taxpayer Issuers) → validate Scenario 2 → ship. Add US3 (Taxpayer Certificates) → validate Scenario 3 → ship. Each increment leaves the previous catalogs green. Finish with Phase 6 (integration flow + encoding confirmation + full quickstart).

## Notes

- `[P]` = different files, no dependency on an incomplete task.
- Every screen: row-click → read-only view; Create as a toolbar `FilledButton`; delete-in-form-body (US1/US2 only); Edit as the single row action (US3 has none). Affordances **hidden** (not disabled) without the RBAC right (constitution §IV, §VI).
- Do **not** edit generated files under `lib/generated/openapi/` or `system_object.dart`.
- The `1001 FONACOT` `PaymentForm` entry and its `.arb` key carry a `// FIXME(payment-form):` note for one-line removal (research §5).
- Search on US1/US3 lists is wired to an expected upstream `search` param (tracked dependency, research §15) — never client-side page filtering.
- Commit after each task or logical group; stop at any checkpoint to validate a story independently.
