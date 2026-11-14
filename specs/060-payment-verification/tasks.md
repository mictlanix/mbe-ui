---
description: "Task list for 060-payment-verification"
---

# Tasks: Payment Verification

**Input**: Design documents from `specs/060-payment-verification/`

**Prerequisites**: plan.md, spec.md, research.md (R1–R11), data-model.md, contracts/ui-contracts.md (C1–C8), quickstart.md, wireframes.md (its Open Questions are answered in spec.md Clarifications)

**Tests**: The spec doesn't ask for a test suite as such, but the constitution's quality gates and research R10 require tests. Test tasks sit inside each story, after the code they cover.

**Organization**: Grouped by user story (US1–US3, spec.md). US1 is the MVP: the queue with verify and the read-only row panel. US2 adds reject. US3 adds verify and reject on the Pagos payment view. Phase 2 holds what two or more stories share.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: parallelizable (different files, no dependency on an incomplete task)
- **[Story]**: US1 verify transfers against the bank statement · US2 reject a payment that isn't on the statement · US3 verify or reject from the payment view

## Cross-story notes

- **Shared files.** Do these sequentially, not in parallel:
  - `lib/features/sales/presentation/payment_verification/payment_verification_screen.dart`: T011 (US1) creates it, T016 (US2) edits it.
  - `lib/features/sales/presentation/payments/payment_detail_screen.dart`: T017 (US3) only.
  - `lib/features/sales/domain/repositories/customer_payment_repository.dart` and `lib/features/sales/data/customer_payment_repository_impl.dart`: T005 only.
  - `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb`: every key is added once, in T002. If a later task needs another, add it there and run `flutter gen-l10n`. Never hand-edit `lib/l10n/app_localizations*.dart`.
- **Generated code.** After editing a freezed or `@riverpod` file, run `dart run build_runner build --delete-conflicting-outputs` at the repo root. Never run two build_runner processes at once: tasks that both need it are not marked [P] against each other. No client regeneration is needed: `CustomerPaymentsApi` already has `listUnverifiedPaymentsApiV1CustomerPaymentsUnverifiedGet`, `verifyCustomerPaymentApiV1CustomerPaymentsCustomerPaymentIdVerifyPost`, `rejectCustomerPaymentApiV1CustomerPaymentsCustomerPaymentIdRejectPost` and `RejectionRequest`.
- **Formatting.** Format only the files you changed (`dart format <files>`). Never `dart format .`, and never format `lib/generated/`.
- **Amounts and dates** go through `formattersProvider` (constitution §V). No `NumberFormat`, no `toStringAsFixed`. Use `paymentAmountLabel` for amounts. Never use `double`.
- **Spacing tokens, not literals** (`Theme.of(context).spacing`). No automated guard catches a literal, so check it in review.
- **Never match server prose** (§III). Show refusals through `AppError.localizedMessage` / `FormErrorBanner`, which build the text from the error's `code`. Recognition keys on the code (`payment.already_verified`).
- **Folio is `customerPaymentId`**, as in Pagos (R2). Never show the DTO's `serial`.
- **Simplifications.** Any shortcut carries a comment `// simplified: <ceiling>, <what to do when it binds>`.
- **Mirror, don't copy blindly.** Closest precedents:
  - The whole list screen: `payments/payments_list_screen.dart` (filter bar, badged filter button, `_PaymentsFiltersPanel`, `DataTableView`, `CatalogListStateView`, `_FacilityNameCell`, `_isForbidden`).
  - URL filter: `payments/payments_filter.dart` (`fromQuery`, `encodePaymentsDateFacet`) and `payments/payments_list_controller.dart` (`fetchClampedPage`).
  - Write controller returning `AppError?`: `payments/payment_editor_controller.dart`.
  - Dialog with a busy flag, `FormErrorBanner` and non-dismissible submit: `payments/apply_payment_dialog.dart` and `payments/record_payment_dialog.dart`.
  - Read-only labelled grid: `_Labeled` and `ResponsiveFormGrid` in `payments/payment_detail_screen.dart`.
  - Facility picker facet: `CatalogEntityPicker<FacilityListItem>` in `orders/sales_orders_list_screen.dart` (~line 403).
  - Widget harness: `test/widget/features/sales/payments_list_screen_test.dart`, `payment_detail_screen_test.dart`, `apply_payment_dialog_test.dart`; unit harness: `test/unit/features/sales/payment_editor_controller_test.dart`, `payments_filter_test.dart`, `customer_payment_repository_impl_test.dart`.

---

## Phase 1: Setup

**Purpose**: a known-good baseline, so later failures are attributable.

- [x] T001 Run `flutter analyze` and the existing tests this feature touches: `test/widget/core/widgets/catalog_action_icons_test.dart`, `test/widget/features/sales/payment_detail_screen_test.dart`, `payments_list_screen_test.dart`, `test/unit/features/sales/customer_payment_repository_impl_test.dart`, `payment_editor_controller_test.dart`, `payments_filter_test.dart`, `test/unit/core/errors/catalog_coverage_test.dart`, and any navigation or router test (find them with `grep -rl nav_destinations test`). Note any pre-existing failures so they aren't blamed on this feature. The failures in `test/golden/core_widgets_golden_test.dart` are already known (mbe-ui#209).

---

## Phase 2: Foundational (blocks all user stories)

**Purpose**: the pieces two or more stories use: strings, the error code, the row-actions helper, the repository gaps, the filter, the queue controller and the write controller.

- [x] T002 Add every new string to `lib/l10n/app_es.arb` and `lib/l10n/app_en.arb`, then run `flutter gen-l10n`. Each key gets an `@key` description starting "spec 060". Keys (C8):
  - `paymentVerificationMenuTitle` ("Verificación de pagos" / "Payment verification"), `paymentVerificationEmpty` ("No hay pagos sin verificar con estos filtros."), `paymentVerificationMethodAll` ("Todos"), `paymentVerificationFacilityAll` ("Todas").
  - `paymentVerifyAction` ("Verificar"), `paymentRejectAction` ("Rechazar"), `paymentVerifyTitle` ("Verificar pago"), `paymentRejectTitle` ("Rechazar pago").
  - `paymentVerifyIrreversible` ("Confirma que el dinero está en el banco. No se puede deshacer."), `paymentRejectReasonLabel` ("Motivo"), `paymentRejectNote` ("El pago seguirá sin verificar; el rechazo queda registrado con tu nombre y la fecha.").
  - `paymentVerifiedSnack` (placeholder `id`: "Pago {id} verificado."), `paymentRejectedSnack` (placeholder `id`: "Rechazo registrado. El pago {id} sigue sin verificar y seguirá en la lista de verificación.").
  - `paymentVerifyUnknown` ("No sabemos si se verificó: se perdió la conexión. La lista se actualizó."), `paymentRejectUnknown` (same shape for rejecting).
  - `apiErrorPaymentAlreadyVerified` ("Otra persona ya verificó este pago." / "Someone else already verified this payment.", description "mbe-api error code `payment.already_verified` (spec 060)").
  - Reuse, don't duplicate, the existing `paymentsColumn*` labels, `paymentHeaderTitle`, `filtersTooltip`, `filtersButton`, `clearAllFilters`, `applyFilters`, `clearFiltersButton`, `retryButton`, `cancelButton`, `paymentsListForbidden` (the 403 view) and `paymentsFilterMethod`/`paymentsFilterDate`. The dialogs' "Cerrar" is `MaterialLocalizations.of(context).closeButtonLabel`, not a new key. Check `app_es.arb` before adding anything else.

- [x] T003 [P] Localize `payment.already_verified` (R8, depends on T002):
  - In `lib/core/errors/localize_problem.dart`, add `api.ErrorCode.paymentPeriodAlreadyVerified` to `localizedErrorCodes` (alphabetically, before `paymentPeriodApplicationReversed`) and map it to `l10n.apiErrorPaymentAlreadyVerified` in the switch. The enum member is `paymentPeriodAlreadyVerified` (`lib/generated/openapi/lib/src/model/error_code.g.dart`); the `payment.already_verified` wire name is mapped by `ApiProblem`, as for the other `payment.*` codes.
  - In `test/unit/core/errors/problem_fixtures.dart`, add a fixture for it (no params).
  - In `specs/058-localized-api-errors/contracts/code-scope.tsv`, change the `payment.already_verified` row's verdict from `OUT` to `IN`, set `example_routes` to `POST /customer-payments/{}/verify` and the note to "reachable from the payment verification queue and the payment view (spec 060)".
  - In `test/unit/core/errors/catalog_coverage_test.dart`, change `expect(checked, 104)` to `105`.
  - Run `flutter test test/unit/core/errors/`.

- [x] T004 [P] Extend `buildCatalogRowActions` with a primary action (C3, R5): in `lib/core/widgets/catalog_action_icons.dart`, add an optional `CatalogRowAction? primaryAction`.
  - Assert `onEdit == null || primaryAction == null`.
  - Render order: Edit or the primary action first as a direct `IconButton` (`visualDensity: VisualDensity.compact`, same as Edit), then one extra action direct, or two or more collapsed into ⋮.
  - A row must never show more than two icons. With a primary action plus two or more extras, that means primary plus ⋮ (still two). Say so in the doc comment, which must also state that §VI v1.7.0 is why, and that `primaryAction` is for rows with no Edit because the record isn't editable there (as in the Pagos list), never a way to replace Edit on an editable record.
  - Extend `test/widget/core/widgets/catalog_action_icons_test.dart`: the primary action renders in Edit's slot; primary plus one extra gives two direct icons; primary plus two extras gives the primary and ⋮; passing both `onEdit` and `primaryAction` trips the assert; every existing case still passes unchanged.

- [x] T005 Add the three repository methods (R2): in `lib/features/sales/domain/repositories/customer_payment_repository.dart` declare `listUnverified({int? facilityId, DateTime? dateFrom, DateTime? dateTo, int? methodCode, int skip = 0, int limit = 20}) → CustomerPaymentListResult`, `verify({required int customerPaymentId}) → CustomerPayment` and `reject({required int customerPaymentId, required String reason}) → CustomerPayment`, each with a doc comment naming its endpoint.
  - In `lib/features/sales/data/customer_payment_repository_impl.dart`, implement them over `listUnverifiedPaymentsApiV1CustomerPaymentsUnverifiedGet`, `verifyCustomerPaymentApiV1CustomerPaymentsCustomerPaymentIdVerifyPost` and `rejectCustomerPaymentApiV1CustomerPaymentsCustomerPaymentIdRejectPost`.
  - Copy `list`'s date handling exactly (`wireDate(dateFrom)`, `wireDateEnd(dateTo)`) and its `DioException → _toAppError` path. Never send `amountMin`/`amountMax`.
  - Build the `RejectionRequest` with `reason`. Check the generated builder's shape in `lib/generated/openapi/lib/src/model/rejection_request.dart`.
  - Map responses with `CustomerPayment.fromResponse`. A null body is `AppError.server()`.
  - Add cases to `test/unit/features/sales/customer_payment_repository_impl_test.dart`: `listUnverified` sends facility, method, date bounds, `skip` and `limit` and sends no amount filters; omits null filters; maps rows and total; `verify` and `reject` hit the right ids and map the response; `reject` sends the reason; a 409 surfaces as an `AppError` carrying the code (see how the other tests in that file assert this).
  - Implement the new methods on every fake of `CustomerPaymentRepository` in `test/`: find them with `grep -rln "implements CustomerPaymentRepository" test`.

- [x] T006 [P] Create the filter (data-model §2, R3): `lib/features/sales/presentation/payment_verification/payment_verification_filter.dart`, a freezed `PaymentVerificationFilter` plus the sealed `VerificationMethodFilter` (`all`, `code(int)`).
  - **Fields:** `facilityId`, `dateFrom`, `dateTo`, `method` (default `.code(PaymentMethod.eft.code)`), `pageIndex`.
  - **`fromQuery(ListQuery)`:** facets `facility`, `date-from`, `date-to`, `method`.
    - `method`: absent means Transfer, `all` means none, a number means that code, anything else means Transfer.
    - A half-open or reversed date range is dropped, as in `PaymentsFilter.fromQuery`.
    - An unparsable `facility` is dropped.
  - **`toQuery`** or an equivalent inverse, so the screen can write facets back. Omit `method` from the address when it is Transfer, write `all` for none, and write the code otherwise.
  - **Derived:** `methodCode` (`null` for `all`), `activeFilterCount` (facility, date range, and the method whenever it isn't `all`), `differsFromDefault`.
  - Reuse `encodePaymentsDateFacet` from `payments_filter.dart` for the date facets. Don't duplicate its parser: if `_parseDateFacet` is private, expose what you need from `payments_filter.dart` with the smallest change that keeps it a single parser.
  - Run build_runner.
  - Add `test/unit/features/sales/payment_verification_filter_test.dart`: the default is Transfer with no facility and no dates; `method=all`; `method=1`; `method=junk` reads as Transfer; round trip through `ListQuery`; half-open and reversed ranges drop; `activeFilterCount` is 1 on default, 0 on `all`, and counts facility and dates; `differsFromDefault` for each case.

- [x] T007 Create the queue controller (R2, R3, data-model §3): `lib/features/sales/presentation/payment_verification/verification_queue_controller.dart`, an `@riverpod` `AsyncNotifier` family keyed by `PaymentVerificationFilter`, returning `CatalogPage<CustomerPayment>` through `fetchClampedPage` with page size 20.
  - It calls `customerPaymentRepositoryProvider.listUnverified` with the filter's facility, dates and `methodCode`. It adds no facility scoping of its own: the queue is company-wide on purpose, and the server decides by Payments Verification read.
  - Add a doc comment saying so, so nobody "fixes" it by copying `PaymentsListController`'s facility guard.
  - Run build_runner.
  - Add `test/unit/features/sales/verification_queue_controller_test.dart`: it requests the filter's values and page; no `facilityId` is sent when none is chosen; Transfer is sent by default and nothing when `all`; `total` is the server's; stepping back a page when the last row of a page was removed (the clamping), following `payments_list_controller_test.dart`.
  - Depends on T005, T006.

- [x] T008 Create the write controller (R4): `lib/features/sales/presentation/payment_verification/payment_verification_controller.dart`, a keep-alive `@Riverpod(keepAlive: true)` notifier `PaymentVerification` shaped like `PaymentEditor`.
  - `Future<AppError?> verify({required int paymentId})` and `Future<AppError?> reject({required int paymentId, required String reason})`. Each runs the repository call, catches `AppError` as the return value, and always invalidates `verificationQueueControllerProvider`, `paymentDetailProvider(paymentId)` and `paymentsListControllerProvider`.
  - Run build_runner.
  - Add `test/unit/features/sales/payment_verification_controller_test.dart`, following `payment_editor_controller_test.dart`: success returns `null` and invalidates the three providers; a refusal is returned as a value (not thrown) and still invalidates; `reject` passes the reason untouched; `verify` carries the payment id.
  - Depends on T005, T007.

**Checkpoint**: `flutter analyze` is clean and `flutter test test/unit` passes.

---

## Phase 3: User Story 1 — Verify transfers against the bank statement (Priority: P1) 🎯 MVP

**Goal**: a supervisor opens "Verificación de pagos", sees unverified transfers from every facility, narrows them, taps a row to read it, and verifies one after a confirmation.

**Independent test**: with an unverified transfer seeded, open the queue as a user with Payments Verification read and update, tap its row to read it, verify it, and check that it leaves the queue and Pagos shows it verified by that user (quickstart steps 1, 3, 4, 5).

- [x] T009 [US1] Create `lib/features/sales/presentation/payment_verification/verify_payment_dialog.dart` (C5, FR-006 to FR-008, FR-014): `showVerifyPaymentDialog(BuildContext, CustomerPayment payment)`, returning `Future<bool>` (true after a verification).
  - A `ResponsiveDialog` titled `paymentVerifyTitle`, showing Folio, Cliente, Monto (`paymentAmountLabel`) and Referencia (`—` when null), then `paymentVerifyIrreversible`.
  - Buttons: Cancelar, and a `FilledButton` keyed `verify_payment_confirm`.
  - On confirm, set a busy flag and call `paymentVerificationProvider.notifier.verify`.
    - Busy: both buttons disabled, `dismissible: false`, a spinner on confirm.
    - `null`: close with `true`.
    - An `AppError`: show a `FormErrorBanner` (`localizedMessage`, or `paymentVerifyUnknown` for a network or timeout error), and replace the confirm button with "Cerrar" (`MaterialLocalizations.of(context).closeButtonLabel`; closing returns `false`).
  - Add `test/widget/features/sales/verify_payment_dialog_test.dart`: shows the four facts and the irreversibility text; confirm calls `verify` once with the payment id even on a double tap; both buttons are disabled and the dialog can't be dismissed while busy; `payment.already_verified` shows its localized text; a network error shows the unknown wording; after a refusal the only button is "Cerrar".

- [x] T010 [P] [US1] Create `lib/features/sales/presentation/payment_verification/verification_payment_panel.dart` (C4, FR-005a): `VerificationPaymentPanel(CustomerPayment payment)` and `showVerificationPaymentPanel(BuildContext, CustomerPayment)`, which calls `showRecordSheet(title: l10n.paymentHeaderTitle(payment.customerPaymentId), isDirty: () => false, form: …)`.
  - The body is a `PaymentVerifiedChip(verified: false)` header and a `ResponsiveFormGrid` (`maxColumns: 2`) of labelled values from the passed payment only: Sucursal (`facilityDisplayNameProvider`, falling back to `#id`), Fecha (`fmt.display.dateTime`), Cliente (`PaymentCustomerName`), Tipo (`paymentTypeLabel`), Método (`PaymentMethodText`), Referencia, Monto, Sin aplicar, Caja (`#id` as plain text, or `—`).
  - It makes no repository call and has no action besides the sheet's own close. Key it `verification_panel_<id>`.
  - Add a comment at the top of the file naming the §VI deviation and pointing at `specs/060-payment-verification/plan.md` Complexity Tracking, so the next reader knows it is deliberate.
  - Add `test/widget/features/sales/verification_payment_panel_test.dart`: every field renders from the given payment; a null reference and null cash session show `—`; another facility's payment renders with no repository override at all (assert nothing was called on a throwing fake); no buttons exist except close.

- [x] T011 [US1] Create `lib/features/sales/presentation/payment_verification/payment_verification_screen.dart` (C2, FR-001 to FR-005, FR-008): `PaymentVerificationScreen` and `const paymentVerificationPath = '/sales/payment-verification'`.
  - Follow `payments_list_screen.dart`: read the address into a `PaymentVerificationFilter`, watch `verificationQueueControllerProvider(filter)`, and render a `CatalogFilterBar` with **no** search control.
    - `filters`: the badged `IconButton.outlined` keyed `verification_filter_button` (badge from `activeFilterCount`, visible whenever it is above zero), opening `showCatalogFilterSheet` with `onClearAll` going to the bare path (R3).
    - `actions`: none. The total (FR-004) is the table's pagination footer; don't add a count to the filter row (§VI).
  - The filter sheet panel holds:
    - Facility: `CatalogEntityPicker<FacilityListItem>` keyed `verification_filter_facility`, unset text `paymentVerificationFacilityAll`, shown only with `can(SystemObject.facilities, AccessRight.read)` (R7). Copy the picker from `sales_orders_list_screen.dart`.
    - Date: `DateRangeFilterChip` with `isToday: false`, as Pagos does.
    - Method: a `DropdownButtonFormField` keyed `verification_filter_method` with `paymentVerificationMethodAll` plus each `PaymentMethod` (`paymentMethodLabel`). Choosing "Todos" writes `method=all`, choosing Transfer removes the facet.
    - Every change returns to page 0.
  - The table is a `DataTableView<CustomerPayment>` keyed `verification_table`. Columns in order: Folio (fixed width 90, `customerPaymentId`), Sucursal (`_FacilityNameCell`-style, `#id` fallback), Fecha, Cliente (`PaymentCustomerName`), Método (`PaymentMethodText`), Referencia, Monto (numeric). Reuse the existing `paymentsColumn*` labels.
  - `onRowTap: (p) => showVerificationPaymentPanel(context, p)`.
  - `rowActionsBuilder` is non-null only with `can(SystemObject.paymentsVerification, AccessRight.update)`, and returns `buildCatalogRowActions(editTooltip: l10n.editActionTooltip, primaryAction: CatalogRowAction(key: Key('verify_payment_${p.customerPaymentId}'), icon: Icons.check_circle_outline, tooltip: l10n.paymentVerifyAction, onPressed: …))`. Without update the argument is `null`, so the action column is left out.
  - The verify action calls `showVerifyPaymentDialog`, and on `true` shows a `SnackBar` with `paymentVerifiedSnack(id)`. The queue reloads by itself (T008).
  - States use `CatalogListStateView`: empty is `paymentVerificationEmpty` with `isFiltered: filter.differsFromDefault` and clear going to the bare path; error retries; a 403 shows a forbidden view with no retry (copy `_ListForbidden` and `_isForbidden`, reusing `l10n.paymentsListForbidden`).
  - Pagination through the table's `pagination`/`onPageChanged`, writing `pageIndex` to the address.
  - Doc comment: the queue is company-wide by design (no facility scoping) and each row's ✓/✕ act without opening the payment, because Pagos refuses another facility's payment (R1, SC-006).
  - Depends on T004, T006 to T010.

- [x] T012 [US1] Wire navigation and the route (C1, R1): in `lib/core/navigation/nav_destinations.dart`, add `NavBranch.paymentVerification = 25` (with a comment like the others: appended last, display order comes from the tree) and a `NavDestination` right after `payments`: id `payment-verification`, label `l10n.paymentVerificationMenuTitle`, icon `Icons.fact_check_outlined`, selected icon `Icons.fact_check`, route `/sales/payment-verification`, `gate: PrivilegeGate(SystemObject.paymentsVerification, AccessRight.read)`.
  - In `lib/app/router/app_router.dart`, append a `StatefulShellBranch` last (index 25) at that path building `PaymentVerificationScreen`, and add a gate clause for `location.startsWith('/sales/payment-verification')` returning `PrivilegeGate(SystemObject.paymentsVerification, AccessRight.read)` **before** the `/sales/payments` clause. Both get a comment naming `PaymentsVerification (108)` (§IV).
  - Check how the shell indexes branches against `NavBranch` and keep them aligned, as spec 057 did for index 24.
  - Add or extend a navigation test: the destination is shown with 108 read and hidden without it, and a user holding only Customer Payments read is redirected away from the path. Find the existing nav test pattern with `grep -rl "salesPayments\|payments'" test`.
  - Depends on T011.

- [x] T013 [P] [US1] Create `test/widget/features/sales/payment_verification_screen_test.dart` (follow `payments_list_screen_test.dart`):
  - rows show folio, facility, date, customer, method, reference and amount; facility falls back to `#id` when the name can't load;
  - the pagination footer shows the server total, and no count widget is in the filter row;
  - the filter badge reads 1 on the default view and 0 with `method=all`;
  - the default request is Transfer from every facility; choosing "Todos" sends no method; setting a facility and a date sends them; "Limpiar todo" returns to Transfer, no facility, no dates;
  - the facility picker is absent without Facilities read, and rows then show the facility as `#id`;
  - the ✓ icon shows with Payments Verification update and the action column is absent with read only;
  - tapping ✓ opens the confirmation, and confirming reloads and shows the SnackBar; a verified row leaves the list;
  - tapping a row opens the panel, and does so for a payment of another facility, with no extra repository call;
  - empty state: shows "Quitar filtros" only when the filters differ from the default;
  - loading, error with retry, and 403 without retry;
  - compact width: rows stack and ✓ stays on the first line, with no overflow.
  - Depends on T011.

**Checkpoint**: US1 works on its own. Run `flutter test test/widget/features/sales/payment_verification_screen_test.dart test/widget/features/sales/verify_payment_dialog_test.dart test/widget/features/sales/verification_payment_panel_test.dart`.

---

## Phase 4: User Story 2 — Reject a payment that isn't on the statement (Priority: P2)

**Goal**: from the queue, reject a payment with a reason, and be told clearly that it stays unverified and stays in the queue.

**Independent test**: reject an unverified payment from the queue with a reason, check the SnackBar wording, and check the payment is still listed and still unverified (quickstart step 7).

- [x] T014 [US2] Create `lib/features/sales/presentation/payment_verification/reject_payment_dialog.dart` (C6, FR-009 to FR-012, FR-014): `showRejectPaymentDialog(BuildContext, CustomerPayment payment)`, returning `Future<bool>`.
  - A `ResponsiveDialog` titled `paymentRejectTitle`, with the same four facts as the verify dialog (extract a small shared private widget in `verify_payment_dialog.dart` or a new file if that avoids duplication), a multi-line reason `TextField` keyed `reject_reason_field` with `maxLength: 500` and the built-in counter, and `paymentRejectNote` under it.
  - The confirm `FilledButton` keyed `reject_payment_confirm` is enabled only while `reason.trim().isNotEmpty` and not busy.
  - Submit calls `paymentVerificationProvider.notifier.reject(paymentId:, reason: reason.trim())`. Busy, success and refusal behave as in T009 (`paymentRejectUnknown` for the unknown-result wording).
  - Add `test/widget/features/sales/reject_payment_dialog_test.dart`: confirm disabled for empty and whitespace-only; enabled with text; the counter and the 500 limit; the typed reason is trimmed and sent once even on a double tap; the note is shown; busy blocks dismissal; a refusal and an unknown result show their banners.
  - Depends on T008, T009.

- [x] T015 [US2] Edit `payment_verification_screen.dart` (FR-005, FR-011): add the second row icon.
  - In the `buildCatalogRowActions` call from T011, add `extraActions: [CatalogRowAction(key: Key('reject_payment_${p.customerPaymentId}'), icon: Icons.block, tooltip: l10n.paymentRejectAction, onPressed: …)]`. Both icons show only with Payments Verification update, as already gated.
  - The action calls `showRejectPaymentDialog`, and on `true` shows a `SnackBar` with `paymentRejectedSnack(id)`. The row stays where it is, because a rejection changes nothing the queue can read (FR-012). Do not add any local "rejected" mark (wireframes Open Question 6).
  - Extend `test/widget/features/sales/payment_verification_screen_test.dart`: ✕ shows beside ✓ with update and neither with read only; a row has exactly two icon buttons; confirming a rejection sends the trimmed reason, shows the SnackBar with the "stays unverified" wording, and the row is still listed afterwards.
  - Depends on T011, T013, T014.

**Checkpoint**: US1 and US2 both work. Run the two dialog tests and the screen test.

---

## Phase 5: User Story 3 — Verify or reject from the payment view (Priority: P3)

**Goal**: on the Pagos payment view, offer Verificar and Rechazar for an unverified payment to a user allowed to verify.

**Independent test**: open an unverified payment in Pagos as a user with Payments Verification update, verify it, and check the view shows it verified by that user; open a verified payment and check neither action shows (quickstart step 8).

- [x] T016 [US3] Edit `lib/features/sales/presentation/payments/payment_detail_screen.dart` (C7, FR-013). Depends on T009, T014.
  - In the header `Wrap` that holds the title and `PaymentVerifiedChip`, add two `OutlinedButton.icon`s after the chip: `payment_verify_button` (✓ `Icons.check_circle_outline`, `paymentVerifyAction`) and `payment_reject_button` (✕ `Icons.block`, `paymentRejectAction`).
  - Show them only when `payment.verifierId == null` and `access.can(SystemObject.paymentsVerification, AccessRight.update)`. They open `showVerifyPaymentDialog` and `showRejectPaymentDialog`.
  - After a successful verification, show the `paymentVerifiedSnack(id)` SnackBar. After a rejection, show `paymentRejectedSnack(id)`. The view reloads through the invalidation in T008, so the chip and "Verificado por" update.
  - Don't change who can open the view (still Customer Payments read, spec 054), the ticket button, or the apply and reverse actions from spec 059.
  - Update the doc comment at the top of the file if it says the view has no verification actions.

- [x] T017 [P] [US3] Extend `test/widget/features/sales/payment_detail_screen_test.dart`:
  - both buttons show for an unverified payment with update;
  - neither shows for a verified payment, with read only, or with no Payments Verification right;
  - confirming a verification calls `verify` with the payment id and the view then shows "Verificado" and the verifier's name (override the detail provider to return the updated payment on reload);
  - confirming a rejection sends the trimmed reason and the payment stays unverified with the buttons still shown;
  - the existing apply, reverse and ticket tests still pass;
  - compact width: the buttons wrap onto their own line without overflow.
  - Depends on T016.

**Checkpoint**: all three stories work. Run `flutter test test/widget/features/sales/payment_detail_screen_test.dart`.

---

## Phase 6: Polish and cross-cutting

- [x] T018 [P] Create the live test `integration_test/payment_verification_quickstart_test.dart` (R10), following `integration_test/payments_editor_quickstart_test.dart` and the traps in `reference_macos_integration_test_traps` (frame-stall watchdog, hitTestable login). Run it as the admin account from `.env`.
  - **Read steps (always on):** the destination is in the menu; the queue loads, all rows are transfers and the count is shown; "Todos" brings other methods; a row tap opens the panel with the row's data.
  - **Write steps (only with `--dart-define=MBE_WRITE=true`):** each fresh transfer is recorded through `customerPaymentRepositoryProvider.createPayment(customer: <a named customer, not the walk-in>, amount: '1.00', method: PaymentMethod.eft.code, type: PaymentType.creditPayment)`, which needs no open cash session (spec 059 FR-015); take the customer the way `payments_editor_quickstart_test.dart` does. Record a fresh 1.00 transfer, find it in the queue, verify it from the row and check it left the queue; record a second fresh 1.00 transfer, reject it with a reason and check it is still listed and unverified; record a third and verify it from the payment view in Pagos; record a fourth, verify it through the API while its row is still on screen, then verify it from the stale row and check the refusal reads "Otra persona ya verificó este pago." and the row goes.
  - Each write run leaves three verified 1.00 transfers and one rejected, still-unverified one on the tenant. Never verify or reject a seeded fixture. Say so in a comment at the top of the file.
  - If a fresh transfer doesn't appear because it falls outside the default page, narrow the queue by date.

- [ ] T019 Run the manual checks in `quickstart.md` steps 2, 6, 9 and 10 that automation can't prove: a user without Payments Verification (`qa054payments`) neither sees nor reaches the queue; two windows verifying the same row (the second sees "already verified"); phone width; and the largest of the four text sizes at desktop width with real fonts, confirming no queue column clips its folio, date or amount (§V; widget tests can't answer this, because their placeholder font is much wider). Record any clipping as a fix in this task, not a follow-up. Also do one timed pass for SC-001 and SC-002: with a stopwatch, find a given day's transfer and verify it (target under 30 seconds), and clear 20 transfers without leaving the screen. Note the times in the PR description.

- [x] T020 File the mbe-api issue for rejection visibility (FR-016, R11) **with the user's go-ahead**: ask first, then `gh issue create -R mictlanix/mbe-api`. The body must name the exact change wanted: expose a payment's rejections (reason, who, when), or a `rejected` flag or `last_rejection` summary and filter on `/customer-payments/unverified`, with the current behaviour (`reject_payment` writes only an incidence) and why the queue needs it. Link the issue in the spec's Assumptions and in the PR description. Do not patch mbe-api (§III). *Filed as mbe-api#310, 2026-11-14.*

- [x] T021 Final checks: `flutter analyze` clean; `dart format` on only the files changed in this feature (`git diff --name-only main... | grep '\.dart$'`, excluding `lib/generated/` and `*.g.dart`/`*.freezed.dart`); `flutter test test/unit test/widget` all green apart from the pre-existing goldens (mbe-ui#209); confirm no hand-edit under `lib/generated/` or `lib/l10n/app_localizations*.dart`; and re-read the Constitution Check in `plan.md` against the final code (the §VI deviation is still the only one).

- [x] T022 Write `specs/060-payment-verification/pr-description.md` with a Roadmap section ("Closes mictlanix/mbe-roadmap#27"), a summary, the §VI deviation and why, the Facilities-read fallback, the live-test residue on the dev tenant, the mbe-api issue link from T020, and the attribution line the project requires. Do not open the PR until the user asks.

---

## Dependencies and execution order

```text
T001 ─▶ T002 ─▶ T003
T004 (needs T001)
T005 ─┬─▶ T007 ─▶ T008
T006 ─┘

T008 + T004 + T006 ─▶ T009 ─┬─▶ T011 ─▶ T012            (US1)
                     T010 ──┘      └─▶ T013
T008 + T009 ─▶ T014 ─▶ T015 (also needs T011, T013)       (US2)
T009 + T014 ─▶ T016 ─▶ T017                               (US3)
all stories ─▶ T018 ─▶ T019 ─▶ T020 ─▶ T021 ─▶ T022
```

- **US1** needs T002 to T008. **US2** needs the queue screen from US1 for its icon, but its dialog (T014) can start as soon as T008 and T009 are done. **US3** needs both dialogs.
- **Parallel:**
  - In Phase 2: T003, T004 and T006 can run beside each other once T002 is done (T003 needs T002's strings; T004 and T006 touch separate files). T005 can run beside them.
  - In US1: T010 runs beside T009, and T013 runs beside T012.
  - T017 can start as soon as T016 compiles.
  - T018 can start once US1 is done, but needs US2 and US3 for its reject and payment-view steps.

## Implementation strategy

- **MVP**: Phases 1–3 (T001–T013). That delivers the whole legacy screen: the queue with filters, the row panel and verify.
- **Then**: US2 (reject), then US3 (payment view). Each is demoable alone, and neither changes US1.
- **Order of risk:** T004 changes a shared core helper that every list screen uses, so run the full widget suite right after it, not just its own test. T012 changes the router, so run the navigation tests right after it.

## Task count

22 tasks:

| Phase | Tasks |
|---|---|
| Setup | 1 |
| Foundational | 7 (T002–T008) |
| US1 | 5 (T009–T013) |
| US2 | 2 (T014–T015) |
| US3 | 2 (T016–T017) |
| Polish | 5 (T018–T022) |
