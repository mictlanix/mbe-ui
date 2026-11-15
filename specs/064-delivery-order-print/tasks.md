---
description: "Task list for 064-delivery-order-print"
---

# Tasks: Delivery Order Print

**Input**: Design documents from `specs/064-delivery-order-print/`

**Prerequisites**: plan.md, spec.md, research.md (R1–R12), data-model.md, contracts/consumed-endpoints.md, contracts/ui-actions.md (U1–U6), quickstart.md

**Tests**: The spec doesn't ask for a test suite as such, but the constitution's quality gates and research R11 require tests. Test tasks sit inside each story, after the code they cover.

**Organization**: Grouped by user story (US1–US4, spec.md). US1 (ticket from the detail screen, P1) is the MVP: it adds the document plumbing's consumers, the print flow and the detail button. US2 (ticket from the list row, P1) adds the order lookup and the row action. US3 (warehouse choice, P2) adds the chooser. US4 (Letter format, P3) adds the second document's button. Phase 2 holds the shared document plumbing, the error messages and the printability rule.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: parallelizable (different files, no dependency on an incomplete task)
- **[Story]**: US1 ticket from the detail screen · US2 ticket from the list row · US3 warehouse choice · US4 Letter format

## Cross-story notes

- **Shared files.** Do these sequentially, not in parallel:
  - `lib/features/sales/presentation/delivery_orders/delivery_order_print.dart`: T007 (Phase 2) creates it with `canPrintDeliveryOrder`. T010 (US1) adds `openDeliveryTicket`, T013 (US2) adds the order lookup and the in-flight set, T016 (US3) adds `distinctWarehouses`, T018 (US3) wires in the chooser, and T020 (US4) adds `openDeliveryLetter`.
  - `lib/features/sales/presentation/delivery_orders/delivery_order_detail_screen.dart`: T011 (US1) adds "Ver ticket", T016 (US3) swaps in the shared warehouse helper, T020 (US4) adds "Ver formato carta".
  - `test/widget/features/sales/delivery_order_detail_screen_test.dart`: T012 (US1) edits it, then T019 (US3) and T021 (US4) extend it.
  - `test/widget/features/sales/delivery_orders_list_screen_test.dart`: T015 (US2) edits it, then T019 (US3) and T021 (US4) extend it.
  - `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb`: every key is added once, in T002. If a later task needs another, add it there and run `flutter gen-l10n`. Never hand-edit `lib/l10n/app_localizations*.dart`.
- **Generated code.** No `build_runner` run is needed: this feature adds no `@riverpod` or `@freezed` declaration. No client regeneration is needed either: `DeliveryOrdersApi` already has `printDeliveryOrderTicketApiV1DeliveryOrdersDeliveryOrderIdTicketGet({deliveryOrderId, warehouse})` and `printDeliveryOrderDocumentApiV1DeliveryOrdersDeliveryOrderIdDocumentGet({deliveryOrderId})`, both returning `Response<Uint8List>`.
- **Adding enum values breaks exhaustive switches.** T003 adds two `DocumentKind` values. Until T005 and the `fallbackFilename` arms land, `flutter analyze` reports missing cases. Do T003–T005 together before running anything.
- **Formatting.** Format only the files you changed (`dart format <files>`). Never `dart format .`, and never format `lib/generated/`.
- **Spacing tokens, not literals** (`Theme.of(context).spacing`). No automated guard catches a literal, so check it in review.
- **Never match server prose** (§III). Show refusals through the shared message path; the preview already does.
- **Don't regress other documents.** Spec 044's tests (`test/unit/core/documents`, `test/widget/core/documents`) and every caller's widget test must keep passing unchanged. `DocumentRef` gains a field, so equality now includes it, and existing callers pass none.
- **Mirror, don't copy blindly.** Closest precedents:
  - Status-plus-right rule shared by a row and a detail screen: `canShowPaymentTicket` and `paymentTicketRef` in `sales/presentation/payments/payment_widgets.dart`, used at `payments/payments_list_screen.dart:283-299` (a row with no Edit and one extra icon).
  - Document caller: `_viewPedido` in `sales/presentation/orders/order_header_panel.dart`.
  - Radio choice inside a `ResponsiveDialog`: `sales/presentation/refunds/refund_confirm_dialog.dart`.
  - Warehouse name cell: `DeliveryOrderWarehouseName` in `delivery_orders/delivery_order_name_cells.dart`.
  - Document test fakes: `test/unit/core/documents/document_fakes.dart` (`FakeDocumentSource`, `FakeDocumentOutput`, `documentContainer`).
  - Live test: `integration_test/document_printing_quickstart_test.dart` and `integration_test/delivery_orders_quickstart_test.dart`.

---

## Phase 1: Setup

- [X] T001 Confirm the starting point: on branch `064-delivery-order-print`, run `flutter analyze` and `flutter test test/unit/core test/widget/core test/unit/features/sales test/widget/features/sales`, and note anything already failing so it isn't blamed on this feature. (Specs 062 and 063 list 7 failures already present on clean HEAD: 6 `core_widgets` goldens and the `pos_screens` screenshot "sales list desktop".) No file changes.

---

## Phase 2: Foundational (blocks every story)

**Purpose**: strings, the two document kinds, the warehouse field, the source arms, the three error messages, and the printability rule. Nothing here is user-visible on its own.

- [X] T002 Add every new string to `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb`, each with an `@key` description starting `spec 064:`, then run `flutter gen-l10n`. The ten keys and their es/en text are in contracts/ui-actions.md U6: `deliveryOrderViewTicket`, `deliveryOrderViewLetter`, `deliveryTicketScopeTitle`, `deliveryTicketScopeAll`, `documentDeliveryTicketTitle` (placeholder `folio`), `documentDeliveryTicketWarehouseTitle` (placeholders `folio`, `warehouse`), `documentDeliveryOrderLetterTitle` (placeholder `folio`), `apiErrorDeliveryOrderNotApproved`, `apiErrorDeliveryOrderUnknownWarehouse`, `apiErrorDeliveryOrderNoLinesFromWarehouse`. Reuse the existing generic "Cancelar" key for the chooser's secondary action rather than adding one.
- [X] T003 Edit `lib/core/documents/domain/document_kind.dart` (data-model, research R1): add `deliveryTicket` and `deliveryOrderDocument`, both with `SystemObject.deliveryOrders` as `gateObject`. Add their `fallbackFilename(recordId)` arms: `entrega-{id:08d}.pdf` and `orden-entrega-{id:08d}.pdf`, using the file's existing `_pad` helper. `gateRight` stays read.
- [X] T004 Edit `lib/core/documents/domain/document_ref.dart` (research R2): add `final int? warehouseId` (optional named constructor parameter, default null). Assert `warehouseId == null || warehouseId > 0` and `warehouseId == null || kind == DocumentKind.deliveryTicket`. Include it in `==` and `hashCode`. Update the class doc comment to say what the field is for.
- [X] T005 Edit `lib/core/documents/data/document_source_impl.dart` (research R1): build a `DeliveryOrdersApi` beside the other APIs, and add two `fetch` switch arms. `deliveryTicket` calls `printDeliveryOrderTicketApiV1DeliveryOrdersDeliveryOrderIdTicketGet(deliveryOrderId: ref.recordId, warehouse: ref.warehouseId)`. `deliveryOrderDocument` calls `printDeliveryOrderDocumentApiV1DeliveryOrdersDeliveryOrderIdDocumentGet(deliveryOrderId: ref.recordId)`. Everything after the call (the `%PDF-` check, the Content-Disposition filename with the kind's fallback, the error mapping) is shared and unchanged. Needs T003 and T004.
- [X] T006 [P] Add the three delivery-order codes to the error catalog (research R9, constitution §III):
  - In `lib/core/errors/localize_problem.dart`: add `deliveryOrderPeriodNotApproved`, `deliveryOrderPeriodUnknownWarehouse` and `deliveryOrderPeriodNoLinesFromWarehouse` to `localizedErrorCodes`, and a `switch` case for each returning its fixed message from T002 (the messages ignore params).
  - In `specs/058-localized-api-errors/contracts/code-scope.tsv`: change rows 50, 51 and 63 (`delivery_order.no_lines_from_warehouse`, `delivery_order.not_approved`, `delivery_order.unknown_warehouse`) from `OUT` to `IN`.
  - In `test/unit/core/errors/catalog_coverage_test.dart`: change the pinned `checked` count from 110 to 113.
  - In `test/unit/core/errors/problem_fixtures.dart`: add a fixture for each of the three codes, with the params the server sends (`status` for not approved, `warehouse_id` for the other two).
  
  Needs T002.
- [X] T007 [P] Create `lib/features/sales/presentation/delivery_orders/delivery_order_print.dart` with `canPrintDeliveryOrder(AccessControlService access, DeliveryOrderStatus status)` (data-model, research R3): true when `canOpenDocument(access, DocumentKind.deliveryTicket)` and the status is neither `draft` nor `pendingApproval`. Doc comment: it mirrors the server's 409 `delivery_order.not_approved` and is shared by the detail screen and the list row. Needs T003.
- [X] T008 [P] Extend the document unit tests (research R10, R11):
  - `test/unit/core/documents/document_source_impl_test.dart`: `deliveryTicket` calls the ticket route with no `warehouse` query when `warehouseId` is null and with `warehouse=<id>` when set; `deliveryOrderDocument` calls the document route; both return the server's filename, and fall back to `entrega-00000012.pdf` / `orden-entrega-00000012.pdf` when the header is missing; a non-PDF body is `AppError.server()`.
  - `test/unit/core/documents/generated_client_bytes_test.dart`: add the two generated method names to its list.
  - The `DocumentRef` equality test (add one in `test/unit/core/documents/` if none exists): two refs differing only in `warehouseId` are unequal and have different hash codes; the assert rejects a `warehouseId` on a kind other than `deliveryTicket` and a non-positive id.
  
  Needs T005.
- [X] T009 [P] Create `test/unit/features/sales/delivery_order_print_test.dart` with the `canPrintDeliveryOrder` cases: for each of the 11 `DeliveryOrderStatus` values, true exactly for the nine from `approved` on and false for `draft` and `pendingApproval`; false for every status when the user lacks Delivery Orders read; true for an administrator. Needs T007.

**Checkpoint**: `flutter analyze` clean; `flutter test test/unit/core test/unit/features/sales` passes.

---

## Phase 3: User Story 1 - Print a delivery order's ticket from its detail screen (Priority: P1) 🎯 MVP

**Goal**: A user opens an approved-or-later order, taps "Ver ticket" and sees the server's ticket in the preview.

**Independent Test**: Open an approved delivery and an approved pickup. "Ver ticket" shows the delivery ticket and the pickup ticket; "Imprimir" and "Descargar" work. A draft offers no print. (Spec US1, quickstart steps 1, 3, 4, 7.)

- [X] T010 [US1] Create the ticket flow in `lib/features/sales/presentation/delivery_orders/delivery_order_print.dart` (contracts U3, steps 3 only for now): `openDeliveryTicket(BuildContext context, WidgetRef ref, {required int orderId, required String folio, required int facilityId, List<int>? warehouseIds})` previews `DocumentRef(kind: deliveryTicket, recordId: orderId, title: l10n.documentDeliveryTicketTitle(folio))` through `ref.read(documentActionsProvider).preview(context, ...)`. Take `warehouseIds` and `facilityId` now so later stories don't change the signature, and add a comment `// simplified: no warehouse choice yet, preview is always unlimited; US3 adds the chooser`. Do not touch the order or any list state (spec FR-041). Needs T002–T005 and T007.
- [X] T011 [US1] Edit `lib/features/sales/presentation/delivery_orders/delivery_order_detail_screen.dart` (contracts U1, research R8): in `_actionButtons`, lead the list with an `OutlinedButton.icon` keyed `delivery_order_view_ticket` (`Icons.receipt_long_outlined`, label `deliveryOrderViewTicket`) shown when `canPrintDeliveryOrder(access, order.status)`. It calls `openDeliveryTicket` with the order's id, `_serialOf(order, l10n)` as the folio, its `facilityId` and the distinct warehouse ids of `order.lines` computed inline for now (replaced by T016's helper). Make sure the action `Wrap` renders when this is the only button, so a cancelled order shows it. `AppBar.actions` stays empty. Needs T010.
- [X] T012 [US1] Update `test/widget/features/sales/delivery_order_detail_screen_test.dart` and add the new cases, using the spec 044 fakes (`FakeDocumentSource`, `documentContainer`) overrides in the existing pump helper:
  - Change the cancelled-order assertion at about l.1114: `delivery_order_actions` now exists and holds `delivery_order_view_ticket` and none of the status actions (cancel, confirm, requeue, ready, pickup, approve, reject).
  - "Ver ticket" is present for each of the nine printable statuses and absent for draft and pending approval.
  - It is absent when the user lacks Delivery Orders read.
  - Tapping it on a one-warehouse order fetches exactly one ticket with no warehouse and opens the preview with the title "Ticket de entrega · {folio}".
  - A pickup order does the same (the app never chooses the ticket type).
  - A second tap while the preview is loading starts no second fetch.
  - Refusals shown in the preview (analysis C1): the fake source throws `AppError.server(statusCode: 409, problem: <delivery_order.not_approved>)`, then `AppError.validation(..., problem: <delivery_order.no_lines_from_warehouse>)` and `<delivery_order.unknown_warehouse>` (build the problems with `problem_fixtures.dart`). The preview shows the localized message from T002 in es and, with the English locale, in en, and offers the retry (`document_preview_retry`).
  - After closing the preview (analysis V1), the detail controller isn't read again (the repository's `getById` count is unchanged) and the action area shows the same buttons.
  
  Needs T011.

**Checkpoint**: US1 works on its own. Run the detail test file and `flutter analyze`.

---

## Phase 4: User Story 2 - Print a ticket straight from the list (Priority: P1)

**Goal**: A printable row offers "Ver ticket", which previews the same ticket without leaving the list.

**Independent Test**: Open the list with orders in several statuses. Approved and later rows show the icon and open the preview; draft and pending rows don't. The list keeps its state after closing. (Spec US2, quickstart steps 1, 2.)

- [X] T013 [US2] Extend `openDeliveryTicket` in `lib/features/sales/presentation/delivery_orders/delivery_order_print.dart` (contracts U3 steps 1–2, research R4, R5): keep a top-level `Set<int>` of in-flight order ids; a call for an id already in it returns at once, and the id is removed in a `finally`. When `warehouseIds` is null, call `ref.read(deliveryOrderAdminRepositoryProvider).getById(orderId)` and take the distinct warehouse ids of its lines; on `AppError`, show a SnackBar with `error.localizedMessage(l10n, fmt)` (the shared message path) and return without opening a preview. Check `context.mounted` after the await. Needs T010.
- [X] T014 [US2] Edit `lib/features/sales/presentation/delivery_orders/delivery_orders_list_screen.dart` (contracts U2, research R8): add a `rowActionsBuilder` to the `DataTableView` that returns `buildCatalogRowActions(editTooltip: ..., extraActions: [CatalogRowAction(key: Key('delivery_order_view_ticket_${o.id}'), icon: Icons.receipt_long_outlined, tooltip: l10n.deliveryOrderViewTicket, onPressed: ...)])` for a row where `canPrintDeliveryOrder(access, o.status)`, and no actions otherwise (follow `payments_list_screen.dart:283-299`). The press calls `openDeliveryTicket` with `warehouseIds: null`, the summary's id, `folio: '${o.serial ?? o.id}'` (printable orders always have a serial; the id is only a fallback) and `facilityId`. Update the class doc comment and the comment at about l.216 that say a delivery order has no row icons: the row tap still opens the detail, and the ticket icon is the one extra action. Needs T013.
- [X] T015 [US2] Update `test/widget/features/sales/delivery_orders_list_screen_test.dart` (mock repository `_MockDeliveryOrderAdminRepository`, spec 044 fakes):
  - The icon appears on rows in the nine printable statuses and not on draft or pending rows, and not for a user without Delivery Orders read.
  - A press on a one-warehouse order calls `getById` once, then opens the preview with one ticket fetch and no warehouse.
  - A `getById` failure shows a SnackBar with the localized message and opens no preview.
  - Two quick presses on one row call `getById` once.
  - Row tap still pushes the detail route, and a press on the icon does not.
  - Closing the preview leaves the list's filters, page and rows as they were, and the list repository is not called again.
  
  Needs T014.

**Checkpoint**: US1 and US2 work. Run both widget test files and `flutter analyze`.

---

## Phase 5: User Story 3 - Print only one warehouse's lines (Priority: P2)

**Goal**: When an order's lines come from two or more warehouses, "Ver ticket" first asks which lines to print.

**Independent Test**: Open an approved order with lines from two warehouses. "Ver ticket" asks; choosing one warehouse prints only its lines, "Todos los almacenes" prints all, dismissing opens nothing. (Spec US3, quickstart step 6.)

- [X] T016 [US3] Add `List<int> distinctWarehouses(List<DeliveryOrderLine> lines)` to `lib/features/sales/presentation/delivery_orders/delivery_order_print.dart` (data-model): the distinct `warehouseId`s in first-appearance order. Replace the inline computation T011 put in the detail screen, and the one T013 put in the flow, with it, in `delivery_order_detail_screen.dart` and `delivery_order_print.dart`.
- [ ] T017 [US3] Create `lib/features/sales/presentation/delivery_orders/delivery_ticket_scope_dialog.dart` (contracts U5, research R6): `DeliveryTicketScope` (`all()` and `warehouse(int id, String name)`) and `showDeliveryTicketScopeDialog(BuildContext, {required int facilityId, required List<int> warehouseIds})` built on `showResponsiveDialog` / `ResponsiveDialog` (title `deliveryTicketScopeTitle`). A `RadioGroup` holds `delivery_ticket_scope_all` first and selected, then a `RadioListTile` keyed `delivery_ticket_scope_<id>` per warehouse, labelled with `DeliveryOrderWarehouseName(facilityId:, warehouseId:)`. Primary action keyed `delivery_ticket_scope_confirm` ("Ver ticket") pops the scope; for a warehouse the name is the resolved one from `facilityWarehousesControllerProvider(facilityId)`, or `#id` when unresolved. The secondary action ("Cancelar") and a barrier dismiss pop `null`. Follow `refund_confirm_dialog.dart`.
- [ ] T018 [US3] Wire the chooser into `openDeliveryTicket` in `delivery_order_print.dart` (contracts U3 step 4, research R6, R7): with fewer than 2 warehouses, preview unlimited as before (remove the `// simplified` comment from T010). With 2 or more, `await showDeliveryTicketScopeDialog(...)`; check `context.mounted`; `null` returns with nothing fetched; `all` previews as before; `warehouse(id, name)` previews with `warehouseId: id` and `title: l10n.documentDeliveryTicketWarehouseTitle(folio, name)`. Keep the in-flight id in the set until the chooser closes, so a second tap can't open a second chooser. Needs T016 and T017.
- [ ] T019 [US3] Add the tests:
  - `test/widget/features/sales/delivery_ticket_scope_dialog_test.dart`: the options are "Todos los almacenes" (selected) then one per id; a warehouse whose name can't be read shows `#id`; confirm pops the chosen scope with its name; "Cancelar" and a barrier tap pop null; it fits a phone-sized surface (400×900) with no overflow.
  - In `delivery_order_print_test.dart`: `distinctWarehouses` returns first-appearance order, de-duplicates, and returns an empty list for no lines.
  - In the detail and list widget tests: with two warehouses, "Ver ticket" shows the chooser and fetches nothing yet; choosing a warehouse fetches one ticket with `warehouse=<id>` and a title ending in the name; "Todos" fetches with no warehouse; dismissing fetches nothing; a one-warehouse order never shows the chooser; on the list the lookup happens before the chooser.
  
  Needs T018.

**Checkpoint**: US1–US3 work. Run the new and edited test files and `flutter analyze`.

---

## Phase 6: User Story 4 - Print the Letter format (Priority: P3)

**Goal**: The detail screen offers "Ver formato carta", a secondary action that previews the Letter document.

**Independent Test**: Open an approved order. "Ver formato carta" shows a Letter-size document and downloads as `orden-entrega-…pdf`; the list row has no such action. (Spec US4, quickstart step 5.)

- [ ] T020 [US4] Add `openDeliveryLetter(BuildContext context, WidgetRef ref, {required int orderId, required String folio})` to `lib/features/sales/presentation/delivery_orders/delivery_order_print.dart` (contracts U4): preview `DocumentRef(kind: deliveryOrderDocument, recordId: orderId, title: l10n.documentDeliveryOrderLetterTitle(folio))` with no chooser. In `delivery_order_detail_screen.dart`, add a `TextButton.icon` keyed `delivery_order_view_letter` (`Icons.description_outlined`, label `deliveryOrderViewLetter`) right after "Ver ticket", under the same `canPrintDeliveryOrder` condition. Needs T011 and T018.
- [ ] T021 [US4] Extend `test/widget/features/sales/delivery_order_detail_screen_test.dart` and the list test: the letter button appears exactly when "Ver ticket" does, is a `TextButton` (not outlined) so it reads as secondary; tapping it on a two-warehouse order opens the preview with no chooser and fetches one document with the title "Orden de entrega · {folio} (carta)"; the list row never offers it. Needs T020.

**Checkpoint**: all four stories work.

---

## Phase 7: Polish & cross-cutting

- [ ] T022 [P] Create `integration_test/delivery_order_print_quickstart_test.dart` (research R11, quickstart), read-only, modelled on `document_printing_quickstart_test.dart` and `delivery_orders_quickstart_test.dart` (macOS, `--dart-define-from-file=.env.settings`, `_Result`/`_Outcome` reporting, SKIP rather than PASS for a step that couldn't run): a draft or pending row and detail have no print action; an approved-or-later row's icon opens a preview with a PDF; the same from the detail screen; the letter format opens; a multi-warehouse order shows the chooser and a limited ticket (SKIP when the tenant has none); a phone-sized window (400×900) still offers the row icon and a fullscreen preview. Check the frame-stall and hit-test traps in the macOS integration-test notes first.
- [ ] T023 Format only the changed Dart files (`git diff --name-only main... | grep '\.dart$'`, excluding `lib/generated/` and `lib/l10n/app_localizations*.dart`), then run `flutter analyze` and the full `flutter test`. Compare any failure against T001's list; only failures not in it block. Needs T006–T021.
- [ ] T024 Run the manual walkthrough in quickstart.md against the dev tenant, including the phone-width and English checks. Record any step you couldn't run, and file a tracking issue for it (as #242, #244 and #247 did for specs 061–063), assigned to the user. Needs T022 and T023.
- [ ] T025 Update `specs/064-delivery-order-print/spec.md`: set **Status** to `Implemented` once T001–T023 are done, and note T024's issue number under Assumptions if manual checks remain open. Needs T024.

---

## Dependencies & execution order

```text
T001
 └─ T002 ──┬─ T006 [P]
           └─ T003 ─ T004 ─ T005 ─ T008 [P]
              T003 ─ T007 [P] ─ T009 [P]
Phase 2 done ─ T010 ─ T011 ─ T012                 (US1, MVP)
             T010 ─ T013 ─ T014 ─ T015            (US2, needs US1's flow)
             T013 ─ T016 ─ T017 ─ T018 ─ T019     (US3, needs US2's lookup)
             T018 ─ T020 ─ T021                   (US4)
all stories ─ T022 [P], T023 ─ T024 ─ T025
```

- **US1 → US2 → US3 → US4** share `delivery_order_print.dart`, so they are sequential in that file. Each story's test task is independent of the next story's code.
- **US4 doesn't depend on the chooser's behaviour**, but its button sits beside US1's, so it waits for T011, and for T018 only to avoid conflicting edits in the shared file.

## Parallel opportunities

- After T002: T006 (error catalog) runs beside T003–T005 (document plumbing).
- After T003: T007 runs beside T004–T005.
- After T005 and T007: T008 and T009 run together (different test files).
- T022 (live test) runs beside T023 once the code is in.

## Implementation strategy

- **MVP (US1).** Phase 1, Phase 2, T010–T012. A user can print an approved order's ticket from its detail screen, which already replaces the trip to the current system for the common case. Stop and check it.
- **Next increment (US2).** The list row, where most tickets are printed. Together US1 and US2 deliver spec SC-001 and SC-006.
- **Then US3, US4,** then polish. US3 and US4 can ship separately from US1–US2 if the warehouse asks for it later.
- **No dependency on mbe-api.** Nothing waits on the server side.

## Notes

- Total: 25 tasks. Setup 1, Foundational 8 (T002–T009), US1 3 (T010–T012), US2 3 (T013–T015), US3 4 (T016–T019), US4 2 (T020–T021), Polish 4 (T022–T025).
- Every task names its file.
