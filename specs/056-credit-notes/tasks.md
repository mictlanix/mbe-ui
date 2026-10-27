---
description: "Task list for 056-credit-notes"
---

# Tasks: Credit Notes

**Input**: Design documents from `specs/056-credit-notes/`

**Prerequisites**: plan.md, spec.md, research.md (R1–R11), data-model.md, contracts/ui-contracts.md (C1–C6), quickstart.md, wireframes.md (its Open Questions 1, 3, 4, 5 and 9 are folded into C2–C4, C6 and the tasks below)

**Tests**: The spec doesn't ask for a test suite as such, but the constitution's quality gates and research R11 require tests. Test tasks sit inside each story, after the code they cover.

**Organization**: Grouped by user story (US1–US3, spec.md). US1 and US2 both edit the payment step; US3 is independent of them.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: parallelizable (different files, no dependency on an incomplete task)
- **[Story]**: US1 spend a named customer's credit · US2 redeem a walk-in ticket · US3 the "Notas de crédito" list

## Cross-story notes

- **Shared files.** Do these sequentially, not in parallel:
  - `lib/features/sales/presentation/payment/payment_controller.dart`: US1 (T009) then US2 (T017).
  - `lib/features/sales/presentation/payment/payment_method_grid.dart`: US1 (T010) then US2 (T019).
  - `lib/features/sales/presentation/payment/payment_step.dart`: US1 only (T012). US2's ticket refusals live in the dialog, not the step.
  - `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb`: every key is added once, in T003. If a later task needs another, add it there and run `flutter gen-l10n`. Never hand-edit `lib/l10n/app_localizations*.dart`.
- **Generated code.** After editing a freezed or `@riverpod` file, run `dart run build_runner build --delete-conflicting-outputs` at the repo root. Never run two build_runner processes at once: tasks that both need it are not marked [P] against each other. No client regeneration is needed: `CreditNotesApi` and `OrderApplicationResponse.paymentType` already exist in `lib/generated/openapi`.
- **Formatting.** Format only the files you changed (`dart format <files>`). Never `dart format .`, and never format `lib/generated/`.
- **Amounts and dates** go through `formattersProvider` (constitution §V). No `NumberFormat`, no `toStringAsFixed`. Amount arithmetic goes only through `features/sales/domain/money.dart`.
- **Spacing tokens, not literals** (`Theme.of(context).spacing`). No automated guard catches a literal, so check it in review.
- **The app never computes a remaining balance (FR-015) and never sends `open_only`** (mbe-api#278). Don't "simplify" the list or the credit read into a server-side filter, even though it looks cheaper.
- **Interim code carries a marker.** Two places are deliberately inefficient until mbe-api ships a change. Each gets a comment `// simplified: <ceiling>, <what to do when it binds>`: the walk-in ticket scan (T004, needs the unfiled `customer_payment` filter) and the open-only full read (T023, needs mbe-api#278).
- **Mirror, don't copy blindly.** Closest precedents:
  - Controller side effects: `PaymentController.tender` (`payment_controller.dart:143-236`).
  - Dialog: `payment_reference_dialog.dart`.
  - List screen, filter and paging: `payments_list_screen.dart`, `payments_list_controller.dart`, `payments_filter.dart`.
  - Repository and its test: `customer_payment_repository_impl.dart` and its `_test.dart` (`_FakeHttpClientAdapter`).
  - Controller tests: `payment_controller_test.dart`. Widget harness: `pos_test_harness.dart`.

---

## Phase 1: Setup

**Purpose**: a known-good baseline, so later failures are attributable.

- [ ] T001 Run `flutter analyze` and the existing tests this feature touches: `test/**/payment_*_test.dart`, `test/**/payments*_test.dart`, `test/widget/features/sales/payment_method_grid_test.dart`, `test/widget/features/sales/pos_047_extra_large_text_test.dart`, `test/unit/app/router/app_router_test.dart`, `test/unit/core/formatting_guard_test.dart`. Note any pre-existing failures so they aren't blamed on this feature. The six failures in `test/golden/core_widgets_golden_test.dart` are already known.

---

## Phase 2: Foundational (blocks every story)

**Purpose**: the entity, repository, strings and the applied-row type that all three stories use.

- [ ] T002 [P] Create the `CreditNote` freezed entity in `lib/features/sales/domain/entities/credit_note.dart` (data-model §1). `fromResponse(api.CreditNoteResponse)` maps `creditNoteId`, `customer`, `salesOrder`, `customerRefund`, `customerPayment`, `refunded` (as `issued`), `remaining` and `date`. Do not map `cashSession`. Add `bool get isOpen` using `compareAmounts` from `money.dart`. Run build_runner.
- [ ] T003 [P] Add every l10n key from contracts C6 to `lib/l10n/app_en.arb` (the template, with `@key` descriptions) and `lib/l10n/app_es.arb`, using the Spanish wording given in C3 and C2. Run `flutter gen-l10n`.
- [ ] T004 Create `CreditNoteRepository` and `CreditNoteListResult` in `lib/features/sales/domain/repositories/credit_note_repository.dart`, and the implementation in `lib/features/sales/data/credit_note_repository_impl.dart` with `creditNoteRepositoryProvider` (data-model §3). Wrap `api.CreditNotesApi(dio, appSerializers)` and map errors with the `_toAppError` pattern from `customer_payment_repository_impl.dart:254-257`. A null `response.data` throws `const AppError.server()`.
  - `list({customerId, skip, limit})`: never sends `open_only`.
  - `listForCustomer(customerId)`: pages at limit 100 until `total` rows are read; returns oldest first (`date`, then `id`).
  - `findByPayment({customerPaymentId, customerId})`: pages newest first and stops at the first match. Mark it `// simplified: worst case reads every walk-in page (512 on the dev tenant); switch to a customer_payment filter when mbe-api ships one`.
  Depends on T002.
- [ ] T005 Add `required PaymentType type` to `SalePayment` in `lib/features/sales/domain/entities/sale_payment.dart`, mapped with `PaymentType.fromApi(r.paymentType)` (R6). Update every test helper that builds a `SalePayment` (grep `SalePayment(` under `test/`) to pass `type: PaymentType.immediate`. Run build_runner.
- [ ] T006 [P] Update the doc comment on `applyPayment` in `lib/features/sales/domain/repositories/customer_payment_repository.dart`: it is no longer always called straight after `createPayment`, since a credit-note redemption applies an existing payment (R1). Comment only, no signature change.
- [ ] T007 Repository tests in `test/unit/features/sales/credit_note_repository_impl_test.dart`, using the `_FakeHttpClientAdapter` pattern. Cover:
  - `list` sends `customer`, `skip` and `limit`, and never sends `open_only`.
  - `listForCustomer` reads a second page when `total` exceeds one page, and orders oldest first.
  - `findByPayment` returns the match from page 1 without reading page 2, and reads page 2 when page 1 has no match.
  - A null body gives `AppError.server`; a 404 gives `NotFoundError`.
  Depends on T004.
- [ ] T008 [P] Entity test in `test/unit/features/sales/credit_note_entity_test.dart`: `fromResponse` carries `issued` and `remaining` as the server sent them (FR-015), and `isOpen` is false for `"0"` and `"0.000000"`.

**Checkpoint**: the app can read credit notes and tell a credit-note application apart. Nothing is visible yet.

---

## Phase 3: User Story 1 — Pay a sale with the customer's credit notes (P1)

**Story goal**: the Cobro step shows a named customer's spendable credit as a tile. One tap applies their notes oldest first, up to the sale's balance, and the applied rows read "Nota de crédito".

**Independent test**: with a named customer holding an open credit note, start a POS sale, open Cobro, tap the credit tile, and confirm the sale's balance and the note's remaining both fell by the same amount (quickstart steps 5–6).

- [ ] T009 [US1] In `lib/features/sales/presentation/payment/payment_controller.dart`, add `creditPartlyApplied` to `PaymentIssue`, add `creditApplied` to `PaymentDraft` with `copyWith` support (data-model §5), and add `tenderCreditNotes(Sale sale, List<CreditNote> notes, {String? enteredAmount})` returning `TenderResult` (R1, R3):
  - Copy `tender`'s sequence: the `submitting` guard, the session check, `confirmBeforePayableAction`, the `_tracked` lock, then `posSaleControllerProvider` refresh and `orderPaymentsControllerProvider(sale.id)` invalidation.
  - Total to spend = the smallest of the entered amount (when given), `sale.balanceOrZero` and the sum of the notes' `remaining`. Walk the notes in the order given and apply `min(note.remaining, left)` to each with `applyPayment(customerPaymentId: note.customerPaymentId, salesOrder: sale.id, amount: …)`. Never pass `amountChange`.
  - On the first `AppError`, stop, set `error`, and set `issue = creditPartlyApplied` with `creditApplied` only when at least one application succeeded. Refresh the sale and invalidate `customerCreditProvider(sale.id)` on every outcome, success or failure (FR-008).
  - Reset the draft amount to the new remaining balance on success, as `tender` does.
  Depends on T004 and T005. Run build_runner.
- [ ] T010 [US1] Create `lib/features/sales/presentation/payment/customer_credit_controller.dart` with `CustomerCredit(notes, total)` and `customerCreditProvider(saleId)` (data-model §6, R2):
  - Put the shared gate in one function in this file, `bool creditTenderAllowed(Sale sale, AccessControlService access)`: true when the sale isn't cancelled, `balanceOrZero > 0`, and the user passes `can(creditPayments, read)` and `can(customerPayments, create)` (R7, FR-007, FR-014). T019 reuses it, so the rule is written once.
  - Return an empty value, with no request, for the walk-in customer (`appSettingsProvider.isGenericCustomer`) or when `creditTenderAllowed` is false.
  - Otherwise call `listForCustomer(sale.customer)`, keep notes where `isOpen`, drop any whose `customerPaymentId` appears among the sale's non-cancelled applications from `orderPaymentsControllerProvider(saleId)`, and sum `remaining` with `addAmounts`.
  Run build_runner. Depends on T004.
- [ ] T011 [US1] In `lib/features/sales/presentation/payment/payment_method_grid.dart`, add the credit tile (contracts C2): key `payment_credit_note_tile`, appended after the method tiles, shown only when `customerCreditProvider(sale.id).total > 0`. Give `_TileData` an optional subtitle override, because the second line is hard-wired to the reference text (`payment_method_grid.dart:233-237`); the tile's subtitle is `paymentCreditNoteBalance(amount)` through `fmt.display.currency`. The tap calls `tenderCreditNotes(sale, credit.notes, enteredAmount: …)` with the draft's amount when the cashier typed one, and is disabled under the same `enabled && !submitting` rule as the other tiles. Depends on T009 and T010.
- [ ] T012 [US1] In `lib/features/sales/presentation/payment/payment_step.dart`, add the `creditPartlyApplied` case to the issue `switch` (around line 52): the message `paymentCreditPartlyApplied(amount)` using `draft.creditApplied`. Change the step's `error` widget, which today renders the `ErrorBanner` *or* the issue line, so that when both `draft.error` and `draft.issue` are set it renders the issue line above the banner (contracts C2, wireframes Open Question 1). Every existing case, which sets only one of the two, must look exactly as before. Depends on T009 and T003.
- [ ] T013 [P] [US1] In `lib/features/sales/presentation/payment/applied_payments_panel.dart`, lead a row with `paymentTypeLabel(l10n, row.type)` instead of the method label when `row.type == PaymentType.creditNote`, followed by `appliedPaymentCreditNoteNumber(row.customerPayment)` ("Nº 300743") in the same " · "-joined line, with `Icons.receipt_long_outlined` as its icon (FR-009, contracts C4, R6). Amount, undo and cancelled styling are unchanged. Depends on T005.
- [ ] T014 [US1] Controller tests in `test/unit/features/sales/payment_controller_test.dart`, in a new group "tenderCreditNotes (spec 056)" using the existing `MockCustomerPaymentRepository` and `_FixedPosSale`:
  - Notes of 300 and 700 against a 1,000 balance apply 300 then 700, in that order.
  - Notes totalling 1,500 against a 1,000 balance apply exactly 1,000 and leave the last note part-spent.
  - An entered amount of 400 caps the total at 400.
  - `createPayment` is never called and `amountChange` is never sent.
  - The second application fails: the first stays applied, `issue` is `creditPartlyApplied` with `creditApplied` equal to the first amount, and the sale is still refreshed.
  - A second tap while one is in flight returns `ignored`.
  Depends on T009.
- [ ] T015 [P] [US1] Provider tests in `test/unit/features/sales/customer_credit_controller_test.dart`: oldest first, notes with `remaining` 0 left out, a note already among the sale's applications left out, an empty value with no repository call for the walk-in customer, a cancelled sale, a zero balance, and a user lacking `creditPayments` read or `customerPayments` create. Depends on T010.
- [ ] T016 [US1] Widget tests: extend `test/widget/features/sales/payment_method_grid_test.dart` for the tile (shown with the balance subtitle; hidden when the credit is zero, the user lacks a privilege, the customer is the walk-in one, the sale is cancelled, or the sale's balance is zero (FR-007); tapping applies and the applied row reads "Nota de crédito · Nº {ticket}"; the partial-failure state shows the issue line *and* the server's `ErrorBanner` together). Extend `test/widget/features/sales/payment_step_gate_test.dart` with a check that an issue-only state and an error-only state render as before. Add a case to `test/widget/features/sales/pos_047_extra_large_text_test.dart` with the tile present at the largest text size, which must not clip or overflow. Depends on T011–T013.

**Checkpoint**: US1 works end to end against mocks, and against a live note issued through mbe-api (quickstart steps 5–6).

---

## Phase 4: User Story 2 — Redeem a walk-in customer's credit-note ticket (P2)

**Story goal**: on a walk-in sale, "Canjear nota de crédito" takes the ticket number, shows the note's remaining amount, and applies it.

**Independent test**: with an open note issued to the walk-in customer, start a walk-in sale, redeem it by its backing payment id, and confirm the sale's balance and the note's remaining both fell by the same amount. Then try an unknown number, a used-up note, the same note twice, and a named customer's note (quickstart steps 7–9).

- [ ] T017 [US2] In `payment_controller.dart`, add the `CreditNoteRefusal` enum (`notFound`, `usedUp`, `alreadyOnSale`, `otherCustomer`) and the `CreditNoteLookup` record (data-model §5), and add `lookupCreditNoteTicket(Sale sale, int ticketNumber)` returning `CreditNoteLookup` (R4). Do **not** add these to `PaymentIssue`: only the ticket dialog shows them (T018 maps each to `creditNoteNotFound`, `creditNoteUsedUp`, `creditNoteAlreadyOnSale` or `creditNoteOtherCustomer(name)`), and `payment_step.dart` stays untouched by this task. The lookup runs these steps in order:
  1. `CustomerPaymentRepository.get(ticketNumber)`. `NotFoundError`, or a type other than `creditNote`, gives `CreditNoteRefusal.notFound`.
  2. A payment whose customer differs from the sale's gives `CreditNoteRefusal.otherCustomer`, with the owner's name from `customerDisplayName`, falling back to `customerDisplayNameProvider`.
  3. A payment already among the sale's non-cancelled applications gives `CreditNoteRefusal.alreadyOnSale`.
  4. `CreditNoteRepository.findByPayment(...)` for the server's `remaining`. No match gives `CreditNoteRefusal.notFound`; a match with nothing remaining gives `CreditNoteRefusal.usedUp`.
  Applying the found note reuses `tenderCreditNotes` with a single note (R1). Depends on T009 and T004.
- [ ] T018 [P] [US2] Create `lib/features/sales/presentation/payment/credit_note_ticket_dialog.dart` with `showCreditNoteTicketDialog` (contracts C3). Build it on the shared `ResponsiveDialog` (`lib/core/widgets/responsive_dialog.dart`), not `AlertDialog`, so it goes full screen on a phone (wireframes Open Question 5). Take the field's submit-on-Enter behaviour from `payment_reference_dialog.dart`.
  - An autofocused number field `credit_note_ticket_input` (`creditNoteTicketInput`, help line `creditNoteTicketHelp`) that accepts digits only and submits on Enter, so a keyboard-wedge scanner works.
  - Submitting runs `lookupCreditNoteTicket`. While it runs, show `creditNoteTicketSearching` with confirm disabled; the walk-in scan can take seconds (R4).
  - A refusal (`CreditNoteRefusal`) shows its message inside the dialog and applies nothing. The field keeps its text and focus.
  - A found note shows a card: `creditNoteTicketHeading(number, date)`, `creditNoteTicketAvailable(remaining)` and `creditNoteTicketWillApply(amount)`, where `amount` is `min(remaining, balance, Cobro's entered amount when set)`, computed with `money.dart`. Confirm `credit_note_ticket_confirm` is then enabled. The dialog has no amount field of its own (wireframes Open Question 3).
  - Confirming returns the note and that amount to the caller.
  Depends on T003.
- [ ] T019 [US2] In `payment_method_grid.dart`, add the walk-in tile `payment_credit_note_redeem_tile` labelled `paymentCreditNoteRedeemTile`, with `paymentCreditNoteRedeemHint` ("Escanea el ticket") as its second line through T011's subtitle override (contracts C3). Show it only on a walk-in sale when `creditTenderAllowed(sale, access)` (T010) holds and the user also passes `can(customerPayments, read)` (FR-014), with no credit-total condition. Tapping opens the dialog, passing it the sale and the Cobro step's entered amount. On confirm it calls `tenderCreditNotes(sale, [note], enteredAmount: <the amount the dialog returned>)`, so what is applied is exactly the "Se aplicará" figure the cashier saw. The named-customer tile from T011 and this one are mutually exclusive. Depends on T011, T017 and T018.
- [ ] T020 [US2] Controller tests for `lookupCreditNoteTicket` in `payment_controller_test.dart`: an unknown payment gives `CreditNoteRefusal.notFound`; a payment of another type gives `CreditNoteRefusal.notFound`; a note for another customer gives `CreditNoteRefusal.otherCustomer` carrying the owner's name; a note already on the sale gives `CreditNoteRefusal.alreadyOnSale`; a note with remaining 0 gives `CreditNoteRefusal.usedUp`; a spendable note returns it. Depends on T017.
- [ ] T021 [US2] Widget tests in `test/widget/features/sales/credit_note_ticket_dialog_test.dart`: Enter submits; the searching state disables confirm; each refusal message shows, nothing is applied, and the field keeps its text; a found note shows its heading, remaining and "Se aplicará" capped at the balance and at the entered amount, and enables confirm; on a phone-width surface the dialog is full screen. Extend `payment_method_grid_test.dart`: the redeem tile shows on a walk-in sale only; it is hidden on a cancelled sale, on a sale whose balance is zero (FR-007), and for a user lacking any of credit-payments read, customer-payments create or customer-payments read (FR-014); confirming applies the note. Depends on T018 and T019.

**Checkpoint**: US2 works against mocks, and against a live walk-in note issued through mbe-api (quickstart steps 7–9).

---

## Phase 5: User Story 3 — See which credit notes exist and what is left (P3)

**Story goal**: "Notas de crédito" lists notes with customer, date, issued, remaining and origin. Filters are customer and "Solo con saldo". A row opens the backing payment.

**Independent test**: open the screen, filter to a customer holding notes, check the figures against their backing payments, turn "Solo con saldo" on and confirm the rows and count agree, then open a row (quickstart steps 1–4, 10).

- [ ] T022 [P] [US3] Create `lib/features/sales/presentation/credit_notes/credit_notes_filter.dart` (data-model §7): a freezed `CreditNotesFilter` built by `fromQuery(ListQuery)` with `customerId` (facet `customer`), `openOnly` (facet `open` = `1`) and `pageIndex`, plus `activeFilterCount` and `isNarrowed`. Follow `payments_filter.dart`, and keep date and facet encoding out of `intl` (spec 028's formatting guard). Run build_runner.
- [ ] T023 [US3] Create `lib/features/sales/presentation/credit_notes/credit_notes_list_controller.dart`, keyed by `CreditNotesFilter` and returning `CatalogPage<CreditNote>` (R8):
  - `openOnly` off: `fetchClampedPage` with page size 20 against `list(customerId:, skip:, limit:)`.
  - `openOnly` on: read every page (`listForCustomer` when a customer is chosen, otherwise every page of `list`), keep notes where `isOpen`, newest first, and page the result locally at 20. Mark this branch `// simplified: reads every page while mbe-api#278 is open (984 notes, about 10 requests on the dev tenant); pass open_only and page on the server once it ships`.
  - A user without `creditPayments` read gets an empty page.
  Run build_runner. Depends on T004 and T022.
- [ ] T024 [US3] Create `lib/features/sales/presentation/credit_notes/credit_notes_list_screen.dart` (contracts C5), modelled on `payments_list_screen.dart`:
  - `CatalogFilterBar` with no `search` and no `actions`; the `filters` slot holds the badged tune button opening `showCatalogFilterSheet`.
  - The drawer holds a customer `CatalogEntityPicker` (key `credit_notes_customer_filter`, with `initialDisplayText` from `customerDisplayNameProvider`) and a "Solo con saldo" `SwitchListTile` (key `credit_notes_open_only_filter`).
  - `CatalogListStateView` and `DataTableView` with the five columns from C5. Only the customer cell may be ellipsized, and it needs a tooltip. The customer cell calls `customerDisplayNameProvider(id)`, showing "…" while loading and `#id` on failure.
  - The origin cell reads `creditNotesOrigin(refund, order)`; the order number links through `orderLinkTargetProvider` when the user can read orders (see `payment_link_providers.dart:80-101`).
  - No row icons. A row tap pushes `/sales/payments/{customerPaymentId}` only when `can(customerPayments, read)`; otherwise the row isn't tappable.
  - A 403 shows the same forbidden view as Pagos.
  Use spacing tokens. Depends on T003, T022 and T023.
- [ ] T025 [US3] Wire the route and navigation (contracts C1):
  - `lib/core/navigation/nav_destinations.dart`: add `NavBranch.creditNotes = 23`, and a `NavDestination` in the `sales` group right after Pagos with id `credit-notes`, the label tear-off for `creditNotesMenuTitle`, `Icons.receipt_long_outlined`, route `/sales/credit-notes`, branch index `NavBranch.creditNotes`, and `PrivilegeGate(SystemObject.creditPayments, AccessRight.read)`.
  - `lib/app/router/app_router.dart`: append a `StatefulShellBranch` at index 23 (it must match `NavBranch`) for `/sales/credit-notes`, building `CreditNotesListScreen(query: ListQuery.fromUri(state.uri))`, and add a `_routeGate` clause for the `/sales/credit-notes` prefix returning the same `PrivilegeGate`, next to the `/sales/payments` clause.
  Depends on T024.
- [ ] T026 [P] [US3] Tests:
  - `test/unit/features/sales/credit_notes_filter_test.dart`: round-trips the URL facets and counts active filters.
  - `test/unit/features/sales/credit_notes_list_controller_test.dart`: the off-toggle path uses server paging and never sends `open_only`; the on-toggle path reads every page and filters locally; a first page with no open notes still finds an open one on page 3 (the #278 case); a user without read gets an empty page.
  - `test/widget/features/sales/credit_notes_list_screen_test.dart`: columns and figures show as the server sent them, there is no search box, the drawer has both facets, the empty and filtered-empty states render, a row tap navigates only with `customerPayments` read, and the origin links only when orders are readable. Assert that amount and origin cells are never ellipsized at the Expanded width.
  - `test/unit/app/router/app_router_test.dart`: `/sales/credit-notes` redirects to `/` without `creditPayments` read, and the nav entry is absent for that user.
  Depends on T022–T025.

**Checkpoint**: US3 works against mocks and against the live list (quickstart steps 1–4, 10).

---

## Phase 6: Polish & cross-cutting

- [ ] T027 [P] Live test `test/integration/credit_notes_live_test.dart`, following `payments_list_live_test.dart` (admin credentials from `MBE_POS_*`, skipped when absent):
  - `list` pages and the total matches the number of notes reached by paging.
  - `listForCustomer(10653)` returns note 990 and, with no spendable fixture, reports its remaining as the server sent it.
  - `findByPayment` finds note 990's backing payment 300743.
  - The redemption case runs only when a note with `remaining > 0` exists whose payment has no cash session, otherwise `markTestSkipped` (R11). Don't use note 158: it was paid out in cash.
  - SC-005, scoped as the spec now states: for notes issued through mbe-api only (found at runtime as notes whose `issued` is above 0 and whose backing payment's `amount` equals it), `issued` equals the payment's `amount` and `remaining` equals its `unapplied`. Skip with `markTestSkipped` when none exists. Legacy notes are not checked until mbe-api#277 ships.
  Depends on T004.
- [ ] T028 Run `flutter analyze` (must be clean), `dart format` on the changed files only, `flutter test` on every test added or touched above plus `test/unit/core/formatting_guard_test.dart`, and `dart run build_runner build --delete-conflicting-outputs` once more to confirm the generated files are current. Run the live test with `-j 1 --dart-define-from-file=.env`.
- [ ] T029 Walk through quickstart.md in the real app. Steps 5–9 need a spendable fixture: create one through mbe-api's refund endpoints as described in the quickstart's prerequisites. Record anything that can't be checked live in the spec's `.spec-context.json` verifications, the way spec 054 did for its step 5b. Also record two measurements there:
  - SC-001: the number of actions from opening Cobro to the credit being applied, which must be at most two.
  - SC-002: the time to redeem a walk-in ticket by scan or typed number, which must be under 30 seconds.
  SC-004 (no over-spend when two registers spend the same note) can't be staged by hand. It is verified by T014's failure-path test, plus the server's bound on every application. Record that in the verifications rather than claiming a live check.
- [ ] T030 Confirm the two `// simplified:` markers (T004, T023) are present and name the upstream issue they wait on. Re-check whether mbe-api#277 and #278 have shipped, and the unfiled `customer_payment` filter: if one has, remove the matching workaround and its marker in the same change.

---

## Dependencies and order

```text
T001
 └─ Foundational: T002, T003, T006 [P] · T005 (build_runner after T002) ─→ T004 ─→ T007 (T008 [P])
        │
        ├─ US1: T009, T010 ─→ T011, T012 ; T013 [P] ─→ T014, T015 [P] ─→ T016
        │             │
        │             └─ US2: T017 ─→ T019 (needs T011, T018 [P]) ─→ T020, T021
        │
        └─ US3: T022 [P] ─→ T023 ─→ T024 ─→ T025 ─→ T026 [P]
                                   (US3 needs only the Foundational phase)

Polish: T027 [P] after T004 · T028 after everything · T029, T030 last
```

**Parallel opportunities:**
- Foundational: T002, T003 and T006 together, then T005 (it runs build_runner, as T002 does); then T007 and T008 together.
- Across stories: US3 (T022–T026) can run alongside US1 and US2 once Phase 2 is done, because it shares no file with them.
- Within US1: T013, T015 beside the controller work; within US2: T018 beside T017.

## Implementation strategy

1. **MVP = Phase 2 + US1.** Cashiers can spend a named customer's credit, which is the highest-value path. Stop and verify there (quickstart steps 5–6).
2. **Add US2**, which reuses US1's controller method and grid, so it's a small increment.
3. **Add US3** last, or in parallel by a second person. It's read-only and independent.

**Risk to watch:** until mbe-api#277 ships, every legacy note reports 0 remaining, so US1 and US2 show no credit for them. Verify with notes issued through mbe-api (quickstart prerequisites), and don't treat the empty state on legacy data as a bug in this feature.
