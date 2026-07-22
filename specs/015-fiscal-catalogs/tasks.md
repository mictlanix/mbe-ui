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
- **Shared files** — edits are additive; do **not** parallelize the *same* shared file across stories:
  - `lib/app/router/app_router.dart` — appended by **US1 & US2 only** (branch + sub-routes + `_routeGate`; order 18→19). US3 adds no route.
  - `lib/core/navigation/nav_destinations.dart` — appended by **US1 & US2 only** (`NavBranch` index + destination + label; order MUST match router — 18/19). US3 adds no destination.
  - `lib/l10n/app_en.arb` + `lib/l10n/app_es.arb` (append keys — all three stories)
  - `lib/features/catalog/presentation/taxpayer_issuer_detail_screen.dart` — created by US2, **augmented by US3** to embed the certificate section.
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

- [ ] T003 Establish the NavBranch↔router append order (18=paymentMethodOptions, 19=taxpayerIssuers) as the contract US1 and US2 follow when appending their branch (contracts/routes.md). Documentation/agreement only — the actual constants are added within each story's nav task, in this order. (US3 adds no branch — certificates are embedded in the issuer detail.)

**Checkpoint**: No blocking foundation code — user stories may begin (in priority order, or in parallel by different developers with coordination on the three shared files).

---

## Phase 3: User Story 1 - Payment Method Options (Priority: P1) 🎯 MVP

**Goal**: A full-CRUD Payment Method Options catalog under Catálogos: paginated list with facility+status filter drawer + search box, and a create/view/edit detail form (facility + optional warehouse pickers, name, number-of-payments, show-on-ticket, SAT payment method, commission, status).

**Independent Test**: Open `/payment-method-options`, filter by facility, create an option (facility + name + payment method), edit its commission and show-on-ticket, view it read-only, delete it — no dependency on US2/US3.

### Tests for User Story 1 (write first; must fail) ⚠️

- [ ] T004 [P] [US1] Entity mapping test (FacilitySummary/WarehouseSummary pre-expansion, Commission→string, status) in `test/unit/features/catalog/payment_method_option_test.dart`
- [ ] T005 [P] [US1] `PaymentMethod` lookup test — code→label round-trip for all confirmed members, non-contiguous gaps, unmapped-code fallback, and `1001 GovernmentFunding` present — in `test/unit/features/catalog/payment_method_test.dart`
- [ ] T006 [P] [US1] Form-controller validators + defaults test (facility required, name required, numberOfPayments ≥ 1, commission decimal; **and** creating with numberOfPayments and displayOnTicket untouched persists `numberOfPayments: 1` and `displayOnTicket: true` — FR-005, Acceptance Scenario 4) in `test/unit/features/catalog/payment_method_option_form_controller_test.dart`
- [ ] T007 [P] [US1] List-controller test (pagination, facility+status filter wiring, search wiring; **and** no-N+1: rendering a page of N items triggers exactly one repository `list` call and zero per-row `get` calls — FR-026, SC-006) in `test/unit/features/catalog/payment_method_options_list_controller_test.dart`
- [ ] T008 [P] [US1] Repository impl test (list/get/create/update/delete map correctly; partial update) in `test/unit/features/catalog/payment_method_option_repository_impl_test.dart`
- [ ] T009 [P] [US1] List screen widget test (columns, filter drawer, search box present, empty state, Create hidden without create right, Edit icon hidden without update right) in `test/widget/features/catalog/payment_method_options_list_screen_test.dart`
- [ ] T010 [P] [US1] Detail screen widget test (create vs read-only vs edit; optional warehouse; payment-method dropdown; delete-in-body gated) in `test/widget/features/catalog/payment_method_option_detail_screen_test.dart`
- [ ] T011 [P] [US1] Read-denied test (no `paymentMethodOptions` read → route redirects, nav hidden) in `test/widget/features/catalog/payment_method_option_read_denied_test.dart`

### Implementation for User Story 1

- [ ] T012 [P] [US1] Create the `PaymentMethod` shared-kernel `{code:(name, label)}` lookup in `lib/core/domain/payment_method.dart` — authoritative members mirroring mbe-api's `PaymentMethod` constant (research §5), non-contiguous explicit map, default `0` (NA), unmapped→raw fallback, and a `// FIXME(payment-method):` comment isolating the `1001 GovernmentFunding` line for easy removal (research §5 impl note)
- [ ] T013 [P] [US1] Create `PaymentMethodOption` detail entity (+ `facilityDisplayName`/`warehouseDisplayName`/`paymentMethodLabel` helpers) in `lib/features/catalog/domain/entities/payment_method_option.dart` (data-model §1)
- [ ] T014 [P] [US1] Define `PaymentMethodOptionRepository` interface (`list{search?,facility?,status?}`, `get`, `create`, `update`, `delete`) + `Page` in `lib/features/catalog/domain/repositories/payment_method_option_repository.dart`
- [ ] T015 [US1] Implement `payment_method_option_repository_impl.dart` wrapping `PaymentMethodOptionsApi` (+ Riverpod provider) in `lib/features/catalog/data/payment_method_option_repository_impl.dart` — search wired to the expected (pending) param, facility/status live (research §15). Depends on T013, T014
- [ ] T016 [US1] Add l10n keys to `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb` — nav title, column headers, field labels, payment-method labels (15 members; add a comment beside the `1001 GovernmentFunding` key), validation, empty state, search/filter labels (FR-029); then `flutter gen-l10n`
- [ ] T017 [US1] Implement list + filter controllers in `lib/features/catalog/presentation/payment_method_options_list_controller.dart` (facility+status filter Notifier + paginated list Notifier). Depends on T015
- [ ] T018 [US1] Implement `payment_method_options_list_screen.dart` (DataTableView, CatalogFilterBar + search box, CatalogFilterSheet with facility picker + status chips, row-click→view, Edit row action) in `lib/features/catalog/presentation/payment_method_options_list_screen.dart`. Depends on T016, T017
- [ ] T019 [US1] Implement `payment_method_option_form_controller.dart` (load/create/update/delete state, validators, error codes) in `lib/features/catalog/presentation/payment_method_option_form_controller.dart`. Depends on T015
- [ ] T020 [US1] Implement `payment_method_option_detail_screen.dart` (ResponsiveFormGrid; facility picker (req), warehouse picker (opt), name, numberOfPayments, displayOnTicket switch, PaymentMethod dropdown, commission, EntityStatusControls; save + delete-in-body gated) in `lib/features/catalog/presentation/payment_method_option_detail_screen.dart`. Depends on T016, T019
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
- [ ] T026 [P] [US2] Form-controller test (RFC required + create-only/immutable, regime required, name required; **and** a duplicate-RFC create rejection surfaces a clear error via the standard error surface while preserving the rest of the form's input — FR-017, SC-002) in `test/unit/features/catalog/taxpayer_issuer_form_controller_test.dart`
- [ ] T027 [P] [US2] List-controller test (pagination + server-side search wiring; **and** no-N+1: rendering a page of N items triggers exactly one repository `list` call and zero per-row `get`/`getDetail` calls — FR-026, SC-006) in `test/unit/features/catalog/taxpayer_issuers_list_controller_test.dart`
- [ ] T028 [P] [US2] Repository impl test — **new** CRUD methods map correctly AND the pre-existing `list`/lightweight `get` still behave (regression) — in `test/unit/features/catalog/taxpayer_issuer_repository_impl_test.dart`
- [ ] T029 [P] [US2] List screen widget test (columns RFC/CP/name/regime, functional search box, no facet drawer, RBAC hiding) in `test/widget/features/catalog/taxpayer_issuers_list_screen_test.dart`
- [ ] T030 [P] [US2] Detail screen widget test (RFC editable on create, disabled on edit; provider dropdown; delete gated) in `test/widget/features/catalog/taxpayer_issuer_detail_screen_test.dart`
- [ ] T031 [P] [US2] Read-denied test (no `taxpayers` read → redirect + nav hidden) in `test/widget/features/catalog/taxpayer_issuer_read_denied_test.dart`

### Implementation for User Story 2

- [ ] T032 [P] [US2] Create `TaxpayerIssuer` detail entity in `lib/features/catalog/domain/entities/taxpayer_issuer.dart` (distinct from the retained `taxpayer_issuer_list_item.dart` picker projection; data-model §2)
- [ ] T033 [P] [US2] Add a `FiscalCertificationProvider` display-label map (over the generated enum, no new type; research §7) in `lib/core/domain/fiscal_certification_provider_label.dart` (consistent with `payment_method.dart` in T012)
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

## Phase 5: User Story 3 - A Taxpayer Issuer's Certificates section (Priority: P2)

**Goal**: Inside the Taxpayer Issuer detail (US2), for an **existing** issuer, a read-only **Certificates section** (certificate number, valid-from, valid-to, active status) scoped to that issuer's RFC, plus an **Agregar** action opening a CSD upload dialog (`.cer`/`.key` file pickers + key password). **No standalone screen/route/nav. No edit, no delete. Section absent on the issuer create form.**

**Independent Test**: With ≥1 issuer present, open that issuer's detail, view its Certificates section, use Agregar to upload a CSD pair (two files + password; the RFC comes from the open issuer), see the new row with a server-derived validity window — confirming no per-certificate edit/delete affordance and that the section is absent on the issuer create form.

**Note**: US3 **augments** US2's `taxpayer_issuer_detail_screen.dart` and reuses the spec-014 inline-dialog pattern. It depends on US2's issuer detail existing (its host).

### Tests for User Story 3 (write first; must fail) ⚠️

- [ ] T044 [P] [US3] `TaxpayerCertificate` entity mapping test (number/id, taxpayer RFC, validFrom/validTo, status) in `test/unit/features/catalog/taxpayer_certificate_test.dart`
- [ ] T045 [P] [US3] Upload controller/value test (both files + password required before submit; taxpayer taken from the open issuer, not re-selected; byte→string encode; server-error preserves selection) in `test/unit/features/catalog/taxpayer_certificate_upload_controller_test.dart`
- [ ] T046 [P] [US3] Certificates-section controller test (`listForIssuer(rfc)` returns that issuer's certificates; **no-N+1**: rendering N certs triggers exactly one repository `list(taxpayer:rfc)` call and zero per-row `get` calls; a successful upload refreshes the section — FR-026, SC-006) in `test/unit/features/catalog/taxpayer_certificates_controller_test.dart`
- [ ] T047 [P] [US3] Repository impl test (`listForIssuer` maps `list(taxpayer:rfc)`; `upload` maps correctly; **no update/delete methods exist**) in `test/unit/features/catalog/taxpayer_certificate_repository_impl_test.dart`
- [ ] T048 [P] [US3] Certificate section widget test (renders the issuer's certs read-only; **no per-row Edit/Delete**; **no** taxpayer-picker and **no** search box in the section — FR-020; Agregar hidden without `taxpayers` create; **Agregar also hidden when the issuer detail is read-only/View even with create privilege** — FR-025, Acceptance Scenario 8; **section ABSENT on the issuer create form** — FR-025, Acceptance Scenario 2) in `test/widget/features/catalog/taxpayer_certificates_section_test.dart`
- [ ] T049 [P] [US3] Upload dialog widget test (two file pickers, password, submit disabled until both files + password present, taxpayer not re-selected, server-rejection preserves selection; **and** the dialog renders **no** certificate-number and **no** validity-date input field — those are server-derived — FR-022) in `test/widget/features/catalog/taxpayer_certificate_upload_dialog_test.dart`

### Implementation for User Story 3

- [ ] T050 [P] [US3] Create `TaxpayerCertificate` entity + `CertificateUpload` input value in `lib/features/catalog/domain/entities/taxpayer_certificate.dart` (data-model §3)
- [ ] T051 [P] [US3] Define `TaxpayerCertificateRepository` interface (`listForIssuer(rfc)→List<TaxpayerCertificate>`, `upload({taxpayer, certificate, key, keyPassword})` — **no `update`, no `delete`, no standalone list/detail**) in `lib/features/catalog/domain/repositories/taxpayer_certificate_repository.dart`
- [ ] T052 [US3] Implement `taxpayer_certificate_repository_impl.dart` wrapping `TaxpayerCertificatesApi` (`list(taxpayer:rfc)` + `upload`, + provider), including the file byte→string encode (base64-of-DER default; research §8), in `lib/features/catalog/data/taxpayer_certificate_repository_impl.dart`. Depends on T050, T051
- [ ] T053 [US3] Add l10n keys to `lib/l10n/app_en.arb` + `lib/l10n/app_es.arb` — Certificates section title, columns (número/Desde/Hasta/Activo), Agregar label, upload-dialog labels (certificate file, key file, password), validation (missing file/password, server rejection), empty-section state (FR-029); then `flutter gen-l10n`. **No** nav-title key (no destination).
- [ ] T054 [US3] Implement `taxpayer_certificates_controller.dart` (Notifier: load the open issuer's certificates via `listForIssuer(rfc)`; refresh after a successful upload) in `lib/features/catalog/presentation/taxpayer_certificates_controller.dart`. Depends on T052
- [ ] T055 [US3] Implement the certificate **upload dialog controller** `taxpayer_certificate_upload_controller.dart` (two `file_picker` byte reads with extension filters, password, submit/validation/error state; taxpayer fixed to the open issuer) in `lib/features/catalog/presentation/taxpayer_certificate_upload_controller.dart`. Depends on T052
- [ ] T056 [US3] Implement `taxpayer_certificate_upload_dialog.dart` (Material 3 `Dialog` with `ResponsiveFormGrid` body: `.cer` + `.key` file pickers, password field, submit disabled until complete) in `lib/features/catalog/presentation/taxpayer_certificate_upload_dialog.dart`. Depends on T053, T055
- [ ] T057 [US3] Implement `taxpayer_certificates_section.dart` — a read-only child table (número/Desde/Hasta/Activo via `DataTableView`, **no per-row actions**) taking a `readOnly` flag, with an Agregar `FilledButton` shown only when `can(taxpayers, create) && !readOnly` (hidden in the issuer's read-only/View mode even for create-privileged users — FR-025) that opens the upload dialog and refreshes on success, in `lib/features/catalog/presentation/taxpayer_certificates_section.dart`. Depends on T053, T054, T056
- [ ] T058 [US3] Embed the section into `taxpayer_issuer_detail_screen.dart` (US2's file): render `TaxpayerCertificatesSection(rfc: …, readOnly: <the screen's existing readOnly flag>)` below the issuer fields, delimited by a Material 3 divider, **only when the issuer is persisted** (`_isEdit`, never on create — FR-025). Pass the same `readOnly` the screen already computes for its save/delete gating (`forceReadOnly || !canUpdate`), so the section's Agregar follows the screen's mode. Depends on T057 (and US2 T040)
- [ ] T059 [US3] Run `build_runner`, `dart analyze` clean, and make T044–T049 pass. Depends on T050–T058

**Checkpoint**: Payment Method Options, Taxpayer Issuers, and the issuer's Certificates section all functional.

---

## Phase 6: Polish & Cross-Cutting

**Purpose**: End-to-end validation and cleanup across stories.

- [ ] T060 Integration flow test (create issuer → add its certificate from the issuer detail's Certificates section → create a payment method option) in `test/integration/fiscal_catalogs_flow_test.dart`
- [ ] T061 Confirm the CSD `.cer`/`.key` byte→string encoding against one real SAT test pair per quickstart Scenario 3; adjust the encode in `taxpayer_certificate_repository_impl.dart` if the server rejects a valid pair (research §8)
- [ ] T062 [P] Verify the NavBranch↔router branch-order invariant (18/19) — highlighted nav item matches the open screen for both new destinations (contracts/routes.md)
- [ ] T063 [P] Full-suite green + lints: `dart analyze` clean, `flutter test`, and `flutter test test/integration/fiscal_catalogs_flow_test.dart`
- [ ] T064 Run the [quickstart.md](./quickstart.md) Scenarios 1–3 against a local mbe-api; confirm localization renders in both languages, empty states, and RBAC hiding (nav + route redirect + action affordances)

---

## Dependencies & Execution Order

### Phase dependencies

- **Setup (Phase 1)** → no dependencies.
- **Foundational (Phase 2)** → after Setup; no blocking code (see T003 note).
- **User Stories (Phases 3–5)** → after Foundational. US1 and US2 are each independently implementable/testable. **US3 depends on US2** — it embeds a section into US2's issuer detail screen (its host) — so build US2 before US3.
- **Polish (Phase 6)** → after the stories you intend to ship (T060 exercises all three).

### Shared-file coordination (not a logic dependency)

`app_router.dart` and `nav_destinations.dart` are appended by **US1 and US2 only** (order 18→19); US3 adds no route or destination. The two `.arb` files are appended by all three stories. `taxpayer_issuer_detail_screen.dart` is created by US2 and augmented by US3. Serialize edits to each shared file; within one story, separate files may proceed in parallel where marked `[P]`.

### Within each story

Tests (written first, failing) → entity/lookup + repository interface (`[P]`) → repository impl → l10n → controllers → screens (US1/US2: + router + nav; US3: + embed section) → `build_runner`/analyze/green.

## Parallel opportunities

- **Setup**: T001, T002 sequential-light (both quick verifications).
- **US1 tests**: T004–T011 all `[P]`. **US1 first code**: T012, T013, T014 `[P]`.
- **US2 tests**: T024–T031 all `[P]`. **US2 first code**: T032, T033 `[P]`.
- **US3 tests**: T044–T049 all `[P]`. **US3 first code**: T050, T051 `[P]`.
- **Cross-story**: US1 and US2 can be built in parallel (coordinating on the shared router/nav/`.arb` files). US3 follows US2.

## Parallel example — User Story 1 tests

```bash
Task: "Entity mapping test in test/unit/features/catalog/payment_method_option_test.dart"
Task: "PaymentMethod lookup test in test/unit/features/catalog/payment_method_test.dart"
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

Add US2 (Taxpayer Issuers) → validate Scenario 2 → ship. Then add US3 (the issuer's Certificates section) → validate Scenario 3 → ship. Each increment leaves the previous work green. Finish with Phase 6 (integration flow + encoding confirmation + full quickstart).

## Notes

- `[P]` = different files, no dependency on an incomplete task.
- **US1/US2 standalone catalogs**: row-click → read-only view; Create as a toolbar `FilledButton`; delete-in-form-body; Edit as the single row action. **US3 certificate section**: a read-only child table (no per-row actions) with an Agregar upload button; it is a divider-delimited sub-section of the issuer detail, not a catalog list. Affordances **hidden** (not disabled) without the RBAC right (constitution §IV, §VI).
- Do **not** edit generated files under `lib/generated/openapi/` or `system_object.dart`.
- The `1001 GovernmentFunding` `PaymentMethod` entry (a non-SAT mbe extension) and its `.arb` key carry a `// FIXME(payment-method):` note for one-line removal (research §5).
- The Payment Method Options list search box is wired to an expected upstream `search` param (tracked dependency, research §15) — never client-side page filtering. (Certificates is a bounded per-issuer section — no search box.)
- Commit after each task or logical group; stop at any checkpoint to validate a story independently.
