---
description: "Task list for 055-payments-followups"
---

# Tasks: Payments Follow-ups

**Input**: Design documents from `specs/055-payments-followups/`

**Prerequisites**: plan.md, spec.md, research.md (R1–R9), data-model.md, contracts/ui-contracts.md (C1–C6), quickstart.md

**Tests**: The spec doesn't ask for a test suite as such, but the constitution's quality gates and research R9 require tests. Test tasks sit inside each story, after the code they cover.

**Organization**: Grouped by user story (US1–US4, spec.md). The stories are small additions to spec 054's screens, so several of them edit the same files. See the cross-story notes.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: parallelizable (different files, no dependency on an incomplete task)
- **[Story]**: US1 payment ticket · US2 customer names and search · US3 facility checks · US4 walkthrough coverage

## Cross-story notes

- **Shared files.** Do these sequentially, not in parallel:
  - `lib/features/sales/presentation/payments/payments_list_screen.dart`: US1 (row action), US2 (search box, customer cell), US3 (refused state).
  - `lib/features/sales/presentation/payments/payment_detail_screen.dart`: US1 (button), US2 (customer cell).
  - `lib/features/sales/presentation/payments/payment_widgets.dart`: US1 (`paymentTicketRef`), US2 (`PaymentCustomerName`).
  - `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb`: all five keys are added once, in T003. If a later task needs another, add it there and run `flutter gen-l10n`. Never hand-edit `lib/l10n/app_localizations*.dart`.
  - `integration_test/payments_quickstart_test.dart`: US3 (T028) then US4 (T032–T035).
- **Generated code.** After editing a freezed or `@riverpod` file, run `dart run build_runner build --delete-conflicting-outputs` at the repo root. The client under `lib/generated/openapi` is rebuilt only inside its own directory (T002).
- **Formatting.** Format only the files you changed (`dart format <files>`). Never `dart format .`, and never format `lib/generated/`.
- **Amounts and dates** go through `formattersProvider` (constitution §V). No `NumberFormat`, no `toStringAsFixed`.
- **Spacing tokens, not literals** (`Theme.of(context).spacing`). No automated guard catches a literal, so check it in review.
- **Read-only.** No task adds a create, verify, reject, apply or reverse call from the app (FR-003 of spec 054 still holds). The seed script (T029) is a dev-tool script, not app code.
- **Facility guards are load-bearing.** Don't simplify `PaymentsFilter.fromQuery`, `PaymentsListController` or `paymentDetailProvider` to "trust the server" (FR-014). The server now enforces the same rule, but the client guards stay as defence in depth.
- **Mirror, don't copy blindly.** Closest precedents:
  - Row action: `pos_sales_list_screen.dart:283-310`.
  - Detail button: `cash_session_detail_screen.dart:129-148`.
  - 403 reading: `pos_sale_detail_view.dart:259-270`.
  - Document fakes: `test/unit/core/documents/document_fakes.dart`.
  - Seed script: `tool/seed_test_accounts.py`.

---

## Phase 1: Setup

**Purpose**: a known-good baseline, so later failures are attributable.

- [X] T001 Run `flutter analyze` and the existing tests this feature touches: `test/**/payments*_test.dart`, `test/**/payment_*_test.dart`, `test/**/customer_payment*_test.dart`, `test/unit/core/documents/`, `test/widget/core/documents/`, `test/unit/core/formatting_guard_test.dart`. Note any pre-existing failures so they aren't blamed on this feature.

---

## Phase 2: Foundational (blocks every story)

**Purpose**: the regenerated client, the new strings and the entity fields that all four stories use.

- [X] T002 Regenerate the API client (R1):
  1. Update `../mbe-api` to `main` at `b5fb935` or later and start it on `127.0.0.1:8000`.
  2. Run `tool/generate_api_client.sh`.
  3. Rebuild the package on its own: `(cd lib/generated/openapi && dart pub get && dart run build_runner build --delete-conflicting-outputs)`.
  4. Confirm the three new names exist: `CustomerPaymentResponse.customerDisplayName`, a `search` parameter on `listCustomerPaymentsApiV1CustomerPaymentsGet`, and `printCustomerPaymentTicketApiV1CustomerPaymentsCustomerPaymentIdTicketGet` returning `Future<Response<Uint8List>>`.
  5. Run `flutter analyze` at the root. Fix only breakage the regeneration caused, and list any unrelated endpoint changes in the commit message.
- [X] T003 [P] Add the five l10n keys to `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb` (contracts C5): `paymentsSearchCustomerHint`, `paymentsListForbidden`, `paymentViewTicketTooltip`, `paymentViewTicketAction`, and `documentPaymentTicketTitle` (takes an int `id`). Run `flutter gen-l10n`.
- [X] T004 Add `String? customerName` to `CustomerPayment` in `lib/features/sales/domain/entities/customer_payment.dart`, mapped from `customerDisplayName` in `fromResponse`. A blank or whitespace-only string becomes `null` (data-model §1). Depends on T002. Run build_runner.
- [X] T005 [P] Add `bool get hasTicket` to `PaymentType` in `lib/features/sales/domain/payment_type.dart`: true for `creditPayment` and `paymentInAdvance` only (R5, data-model §2).
- [X] T006 Unit tests: in `test/unit/features/sales/customer_payment_entity_test.dart`, `fromResponse` carries `customerName`, and null and blank both give `null`. In `test/unit/features/sales/payment_type_test.dart`, `hasTicket` is true for the two types and false for the other four.

**Checkpoint**: the client has the new fields and endpoint, and the entity carries the name. Nothing is visible yet.

---

## Phase 3: User Story 1 — Print a payment ticket (P1)

**Story goal**: "Ver ticket" opens the shared preview with a payment's ticket, from the payment view and from list rows, for credit payments and advances only.

**Independent test**: open a credit payment from Pagos, choose "Ver ticket", confirm the preview shows its 72 mm ticket, then print and download it. Repeat from the list row, and for an advance. Open a counter-sale payment and confirm there is no ticket action (quickstart steps 3–4).

- [X] T007 [US1] Add `customerPaymentTicket` to `DocumentKind` in `lib/core/documents/domain/document_kind.dart`: gate object `SystemObject.customerPayments` (read), and a fallback filename `pago-%08d.pdf` in `fallbackFilename` (R4, data-model §5). Mirror the existing values.
- [X] T008 [US1] Add the `customerPaymentTicket` case to `fetch` in `lib/core/documents/data/document_source_impl.dart`, calling the generated `printCustomerPaymentTicketApiV1CustomerPaymentsCustomerPaymentIdTicketGet(customerPaymentId: ref.recordId)`. Add an `api.CustomerPaymentsApi _customerPayments` field built in the constructor beside `_salesOrders`, `_cashSessions` and `_salesQuotes` (`document_source_impl.dart:25-28`), and update the class comment that lists the print methods. The call goes through the same magic-byte, filename and error handling as the other kinds. Depends on T002 and T007.
- [X] T009 [US1] Add the new operation's method name to the list in `test/unit/core/documents/generated_client_bytes_test.dart`, so a future regeneration that changes its return type fails the guard.
- [X] T010 [US1] Extend `test/unit/core/documents/document_source_impl_test.dart` for the new kind: it requests the payment id, returns the bytes, uses `Content-Disposition` or the `pago-%08d.pdf` fallback, and rejects non-PDF bytes. A 404 becomes `NotFoundError` and a 409 keeps the server's `detail`.
- [X] T011 [US1] Add `paymentTicketRef(AppLocalizations, CustomerPayment)` to `lib/features/sales/presentation/payments/payment_widgets.dart`, returning `DocumentRef(kind: DocumentKind.customerPaymentTicket, recordId: payment.customerPaymentId, title: l10n.documentPaymentTicketTitle(id))`. Model it on `saleTicketRef` in `pos_sales_list_screen.dart:439-449`. Also add a small helper `canShowPaymentTicket(AccessControlService, CustomerPayment)` that returns `payment.type.hasTicket && canOpenDocument(access, DocumentKind.customerPaymentTicket)`, so both call sites share one rule.
- [X] T012 [US1] Add the row action to `lib/features/sales/presentation/payments/payments_list_screen.dart` (contracts C3): set `rowActionsBuilder` on the `DataTableView` to `buildCatalogRowActions(editTooltip: ..., onEdit: null, extraActions: [if (canShowPaymentTicket(...)) CatalogRowAction(key: Key('payment_view_ticket_${id}'), icon: Icons.receipt_long_outlined, tooltip: l10n.paymentViewTicketTooltip, onPressed: () => ref.read(documentActionsProvider).preview(context, paymentTicketRef(l10n, p)))])`. Edit stays absent. Update the "No row action icons" comment on `onRowTap`, which this task makes untrue. The row tap must still open the payment view. Applies in both scopes.

  **Layout check.** A `rowActionsBuilder` makes `DataTableView` add a fixed 150 px actions column (`data_table_view.dart:185-186`). After this change, run `test/widget/features/sales/payments_layout_test.dart`, which requires no horizontal scroll at 1280 px in both scopes. If it fails, rebalance this screen's own column sizes (`size:` and `fixedWidth:` in `payments_list_screen.dart`) until it passes, keeping amounts and chips unellipsized. Don't change `DataTableView` (plan constraint), and don't loosen the layout test.
- [X] T013 [US1] Add the button to `lib/features/sales/presentation/payments/payment_detail_screen.dart` (contracts C3): an `OutlinedButton.icon` keyed `payment_view_ticket_button`, label `paymentViewTicketAction`, icon `Icons.receipt_long_outlined`, in the body's action area and aligned to the end, placed like "Ver corte" (`cash_session_detail_screen.dart:129-148`). Shown only when `canShowPaymentTicket` is true. Not in the `AppBar` (§VI).
- [X] T014 [US1] Widget tests in `test/widget/features/sales/payments_list_screen_test.dart` (use `FakeDocumentSource` and `FakeDocumentOutput`, as in `pos_sales_list_screen_test.dart:673-674`): the icon appears on credit-payment and advance rows and not on immediate, credit-note, expense or N/A rows; it's absent for a user without Customer Payments read; pressing it records a fetch of the right `DocumentRef` and does not navigate to the payment view; the row tap still navigates; the icon appears in the all-facilities scope too.
- [X] T015 [US1] Widget tests in `test/widget/features/sales/payment_detail_screen_test.dart`: the button is shown for a credit payment and an advance, absent for the other types and absent without the privilege; pressing it opens the preview for that payment (fake source records the `DocumentRef`); a fake source that throws a 409 shows the server's message in the preview, and nothing else is fetched (spec FR-006).

**Checkpoint**: a ticket can be previewed, printed and downloaded for eligible payments. This is the MVP.

---

## Phase 4: User Story 2 — Customer names at once, and search by customer name (P2)

**Story goal**: names arrive with the payments, with the old lookup only as the fallback, and the facility list has a customer-name search box.

**Independent test**: open Pagos and confirm every customer cell shows a name on first render with no "…". Type part of a customer's name and confirm only that customer's payments remain. Combine it with a date range (quickstart steps 1–2).

- [X] T016 [US2] Add `String? search` to `CustomerPaymentRepository.list` in `lib/features/sales/domain/repositories/customer_payment_repository.dart` and pass it to the generated `search` parameter in `lib/features/sales/data/customer_payment_repository_impl.dart`. A null or blank search sends nothing. Depends on T002.
- [X] T017 [US2] Extend `test/unit/features/sales/customer_payment_repository_impl_test.dart`: `list` forwards a non-blank `search`, and sends none for null or blank.
- [X] T018 [US2] Add `String? customerSearch` to `PaymentsFilter` in `lib/features/sales/presentation/payments/payments_filter.dart` (data-model §3): `fromQuery` fills it from the trimmed `ListQuery.search` in the facility scope only, and `reference` keeps the all-facilities scope; `isNarrowed` counts it; `activeFilterCount` does not. Update the class comments that say the facility scope has no search. Run build_runner.
- [X] T019 [US2] Extend `test/unit/features/sales/payments_filter_test.dart`: `search` becomes `customerSearch` in the facility scope and `reference` in the all-facilities scope, never both; it's trimmed and empty becomes null; `isNarrowed` is true with only a search; `activeFilterCount` is unchanged by it; `paymentsQueryForScope` drops `search` in both directions (FR-012).
- [X] T020 [US2] In `lib/features/sales/presentation/payments/payments_list_controller.dart`, pass `filter.customerSearch` as `search` in `_fetch`. Update the class comment. The all-facilities branch is unchanged.
- [X] T021 [US2] Extend `test/unit/features/sales/payments_list_controller_test.dart`: the facility fetch forwards `customerSearch` together with the other facets and still sends the user's own facility; the all-facilities search doesn't send it.
- [X] T022 [US2] Change `PaymentCustomerName` in `lib/features/sales/presentation/payments/payment_widgets.dart` to take `required int customerId, String? name` (contracts C4): a non-null `name` is shown without watching `customerDisplayNameProvider`; null keeps today's behavior. Pass `payment.customerName` from the customer column in `payments_list_screen.dart` and from `payment_detail_screen.dart`. Update the class comment.
- [X] T023 [US2] In `lib/features/sales/presentation/payments/payments_list_screen.dart`, show `CatalogSearchBar` in both scopes (contracts C1): hint `paymentsSearchCustomerHint` with `filter.customerSearch` in the facility scope, and the existing reference hint with `filter.reference` in the all-facilities scope. Reuse the same `submitCatalogSearch` call, with the matching `current` value. Update the two comments this makes untrue: the class comment that says the facility scope has no search box, and the comment on `isFiltered:` that says a stray `search` is ignored in the facility scope.
- [X] T024 [US2] Widget tests in `test/widget/features/sales/payments_list_screen_test.dart`: a row with a projected name shows it with no placeholder, and `customerDisplayNameProvider` is never read for it (override it with a provider that fails the test if called); a row with no name falls back to "…", then the looked-up name, then `#id` on failure; the facility scope shows the search box with the customer hint and the all-facilities scope with the reference hint; submitting text writes `?search=`; a search with no result shows the filtered-empty view and "Limpiar filtros" removes it; switching scope clears the text. In `payment_detail_screen_test.dart`, the header shows the projected name.

  **Update the two existing tests that encode spec 054's "no search box in the facility scope"**:
  - `payments_list_screen_test.dart:583`: a non-editor loading `?scope=all&search=REF` now lands in the facility scope with REF as a customer search. Assert the search box is present with the customer hint, the scope switch and the Sucursal column are still absent, and the repository's `list` (not `searchAcrossFacilities`) is called with `search: 'REF'` and the user's own facility.
  - `payments_list_screen_test.dart:615`: rename it and assert the facility scope shows the search box with the customer hint for an editor too, still with no Sucursal column.

**Checkpoint**: the list is fast to read and to search by customer.

---

## Phase 5: User Story 3 — Facility checks enforced by the server too (P2)

**Story goal**: the client's guards stay, a refused list reads as "not allowed" with no retry, the detail keeps its not-found state, and the live walkthrough proves the server refuses the reads.

**Independent test**: as QA054, open another facility's payment by link and confirm "El pago N no existe." with no Retry. The walkthrough confirms the server's 404s and 403 (quickstart step 7).

- [X] T025 [US3] In `lib/features/sales/presentation/payments/payments_list_screen.dart`, add a local `_ListForbidden` view (contracts C2, R7): an `ErrorBanner` with `paymentsListForbidden`, keyed `payments_list_forbidden`, and no retry button. When `pageAsync.error` converts to `ServerError(statusCode: 403)`, render it instead of `CatalogListStateView`; every other state still goes through `CatalogListStateView`. Match the 403 the way `_isForbidden` does in `pos_sale_detail_view.dart:259-270`. Spacing from tokens.
- [X] T026 [US3] Widget tests in `test/widget/features/sales/payments_list_screen_test.dart`: a controller error of `ServerError(statusCode: 403)` shows `payments_list_forbidden` and no `list_state_retry_button`; a 500 still shows `list_state_failed` with retry.
- [X] T027 [P] [US3] Widget and unit tests for the detail (FR-015, FR-014): in `test/widget/features/sales/payment_detail_screen_test.dart`, `NotFoundError` shows `payment_not_found` with "El pago N no existe." and no retry; in `test/unit/features/sales/payment_detail_controller_test.dart`, for a non-editor another facility's payment still throws `AppError.notFound()` and the applications are never requested, and for a Payments Editor it loads. These guard the existing behavior, so they should pass without a code change. If one fails, fix the code and say so.
- [X] T028 [US3] Extend step 9 in `integration_test/payments_quickstart_test.dart` (FR-017, contracts C6): after signing in as QA054, through its authenticated Dio, assert `GET /customer-payments/{other}`, `/{other}/applications` and `/{other}/ticket` all answer 404, and `GET /customer-payments?facility=<other>` answers 403. Keep the existing "El pago N no existe." UI assertion. Missing QA054 credentials stay one soft finding, as today.

  Also update step 8 in the same file (`:780-793`). It asserts `payments_search_field` is absent for the non-editor, which is no longer true: every user now has the customer-name search in the facility scope. Rename the step to "8 non-editor: no mode switch; customer search only; ?scope=all ignored", and assert that the search box is present with the "Buscar cliente…" hint, at `/sales/payments` and at `/sales/payments?scope=all`, while `payments_scope_switch` and "Sucursal" stay absent.

**Checkpoint**: the client's answers are pinned by tests, and the live run confirms the server's.

---

## Phase 6: User Story 4 — Walkthrough covers the back-office link and the date picker (P3)

**Story goal**: a repeatable seed creates the missing data, and the walkthrough passes with no step skipped.

**Independent test**: run `python3 tool/seed_payment_fixtures.py`, then the walkthrough, and confirm `==== RESULTS ====` has no `SOFT` line (quickstart "Automated").

- [X] T029 [US4] Create `tool/seed_payment_fixtures.py` (R8), stdlib-only and modeled on `tool/seed_test_accounts.py` (same `.env`, same `MBE_ADMIN_*` login and `Api.call` helper). It:
  1. Looks for a payment already applied to a back-office order (`GET /sales-orders?origin=1&status=completed&facility=<admin facility>`, then that order's payments). If it finds one, it prints it and exits without writing.
  2. Otherwise takes the first completed back-office order with a balance above 0 and creates a `CREDIT_PAYMENT` for its customer, for the smaller of the balance and 1.00, with reference `QA055-SEED`.
  3. Applies it with `POST /customer-payments/{id}/applications`.
  4. Prints the payment and order ids.

  It writes only to the dev tenant named in `.env`. If no eligible order exists, or the API refuses the payment or the application, it exits non-zero, printing the HTTP status and the server's `detail`. It must not retry with other payment types or amounts. Nobody has run these calls against a back-office order yet, so T031 is the first real check of this assumption.
- [X] T030 [P] [US4] Add the script to `test/integration/TEST_ACCOUNTS.md`, next to the `seed_test_accounts.py` instructions: what it creates, that it's idempotent, and that it should be rerun after a database reset.
- [X] T031 [US4] Run the script against the dev tenant twice. The first run creates the payment and prints both ids. The second creates nothing and prints the same ids. Report both outputs. If the first run fails, stop US4 and report the server's answer before working around it.
- [X] T032 [US4] Replace step 2b's URL navigation in `integration_test/payments_quickstart_test.dart` (R9): tap `date_range_filter_chip`, choose two days in the `DateRangePickerDialog` and press the Save label from `MaterialLocalizations` (the finder sequence is in `test/widget/features/sales/payments_filters_test.dart:118-140`), then assert the `date-from`/`date-to` facets, the narrowed rows against `payments.list(dateFrom/dateTo)` and the badge. Clear it through the chip's delete ("Cualquier fecha") and assert the list is unfiltered again. Mind the macOS traps in memory (frame watchdog, `hitTestable`, back-button tooltip).
- [X] T033 [US4] Step 5b in the same file: when no back-office application is found, record a `fail` with the reason "run tool/seed_payment_fixtures.py" instead of `softFinding` (FR-019). With data present it keeps opening the payment, tapping `payment_order_link_<saleId>` and waiting for `/sales/orders/<id>`.
- [X] T034 [US4] Add step 14 to the same file (R9, FR-021): open a credit payment or advance (the seeded one, or any discovered), tap `payment_view_ticket_button`, wait for the preview to render a page, and close it. Repeat from the list row's `payment_view_ticket_<id>`. Open an `IMMEDIATE` payment and assert neither control is present. The native print dialog isn't driven.
- [X] T035 [US4] Add step 15 to the same file: type part of a discovered customer's name (in a different letter case) into `payments_search_field` and assert every shown row's customer contains it, ignoring case.
- [X] T036 [US4] Run the walkthrough on macOS with the command in quickstart.md. Success is `==== RESULTS ====` with every step `PASS` and no `SOFT`, as the admin and as QA054 (SC-006). Paste the results block. If a step fails, report the step and the `QS-DBG` dump rather than loosening the assertion.

**Checkpoint**: the whole payments flow has live coverage with nothing skipped.

---

## Phase 7: Polish & cross-cutting

- [X] T037 Run `flutter analyze` at the root, then `dart format` on only the files changed by this feature (never `lib/generated/`, never `.`). Analyze must be clean.
- [X] T038 [P] Run the full affected test set: `flutter test test/unit/features/sales test/unit/core/documents test/widget/features/sales test/widget/core/documents test/unit/core/formatting_guard_test.dart`, and then the whole `flutter test` to catch fallout from the client regeneration.
- [X] T039 [P] Check the layouts by hand at Expanded and phone widths: the list row's ticket icon, the search box with its two hints, the detail's "Ver ticket" button, and the "not allowed" state (quickstart steps 1–4 and 7). Constitution §VI: no horizontal scroll at Expanded width, and the new icon must not push the Verificado chip off. Also time the two success criteria that have no automated check:
  - **SC-001:** from the list, the ticket reaches the print dialog in three actions or fewer (Ver ticket, Imprimir, confirm).
  - **SC-004:** from opening Pagos, a facility payment is found by part of its customer's name in under 15 seconds.

  Record both results in the PR description.
- [X] T040 [P] Update `specs/054-payments-list-search/plan.md` "Follow-ups": mark the mbe-api#270 and #271 items as done by spec 055, with the PR numbers. In `specs/054-payments-list-search/spec.md`, append one sentence to FR-008: "Superseded by spec 055 FR-009: the facility mode now has a customer-name search box." Change nothing else in spec 054.
- [X] T041 Prepare the PR description: under "Roadmap", state that no roadmap plan issue is covered; list `Closes #223`, `Closes #224`, `Closes #225` and `Closes #227`; mention mbe-api#276 as the known `unapplied` difference; list the unrelated endpoint changes the regeneration brought in (T002).

---

## Dependencies & execution order

- **Phase 1** → **Phase 2** → the stories → **Phase 7**.
- **Phase 2:** T002 first. T003 and T005 are independent of it. T004 needs T002. T006 follows T004 and T005.
- **US1** needs Phase 2. Inside it: T007 → T008; T009 and T010 follow T008; T011 needs T005 and T007; T012 and T013 need T011; T014 and T015 follow them.
- **US2** needs Phase 2. T016 needs T002; T018 → T020; T022 needs T004; T023 needs T018 and T020. US2 doesn't depend on US1 except for the shared files below.
- **US3** needs only Phase 2, but T025 edits the list screen after US1 and US2 have.
- **US4** needs US1 (T034) and US2 (T035) for its two new steps, and T031 before T033 and T036. T032 needs nothing from the other stories.
- **Shared files** (see the cross-story notes) force this order: US1 → US2 → US3 for the list screen, and US3 (T028) → US4 for the walkthrough file.

## Parallel opportunities

- **Phase 2:** T003 and T005 alongside T002.
- **US1:** T009 and T010 together once T008 is done; T012 and T013 together once T011 exists.
- **US2:** T017 after T016, T019 after T018 and T021 after T020. Each pair is independent of the others.
- **US3:** T027 at any time (it pins existing behavior); T026 after T025.
- **US4:** T030 alongside T029.
- **Phase 7:** T038, T039 and T040 together.

## Implementation strategy

- **MVP:** Phases 1–3. It delivers the ticket, which is the one new capability and the only P1.
- **Release:** Phases 1–7 in one PR that closes #223, #224, #225 and #227.
- **Order inside Phase 2:** do T002 first and look at the generated diff before building on it. A regeneration pulls in every API change since the last one, so surprises show up there, not in the middle of a story.
- **Risk to watch:** T002 can change generated models that other features use. Run the whole test suite after it (T001 gives the baseline to compare against).

## Requirement coverage

| Requirement | Tasks |
|---|---|
| FR-001 ticket on the payment view, eligible types only | T005, T011, T013, T015 |
| FR-002 ticket row action in both modes, row-action limit | T011, T012 (with its layout check), T014 |
| FR-003 opens the shared preview, no direct print | T008, T012, T013, T015 |
| FR-004 no order receipt in its place | T008, T010 (no other kind is used) |
| FR-005 gated by Customer Payments read | T007, T011, T014, T015 |
| FR-006 server message when the ticket fails | T010, T015 |
| FR-007 name arrives with the payment | T002, T004, T022, T024 |
| FR-008 lookup fallback when the name is missing | T022, T024 |
| FR-009 facility search box | T016, T018, T020, T023, T024 |
| FR-010 search combines with the drawer filters | T016, T017, T020, T021 |
| FR-011 reference search kept, two hints | T023, T024 |
| FR-012 mode switch clears the search | T019, T024 |
| FR-013 search text in the link | T018, T019, T024 |
| FR-014 client guards stay | T027 |
| FR-015 detail not-found with no retry | T027 |
| FR-016 refused list: "not allowed", no retry | T025, T026 |
| FR-017 live server refusals | T028 |
| FR-018 seeded back-office application, rerunnable | T029, T031 |
| FR-019 back-office link verified, fails when missing | T033, T036 |
| FR-020 date picker driven and cleared | T032 |
| FR-021 ticket and absent action in the walkthrough | T034 |
| SC-001 ticket in three actions or fewer | T034, T039 (timed) |
| SC-002 ticket action exactly on eligible types | T005, T014, T034 |
| SC-003 no per-customer request | T022, T024 |
| SC-004 customer search under 15 s | T035, T039 (timed) |
| SC-005 other facilities stay hidden | T027, T028 |
| SC-006 walkthrough has no skipped step | T033, T036 |
