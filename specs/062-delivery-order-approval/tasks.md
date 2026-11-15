---
description: "Task list for 062-delivery-order-approval"
---

# Tasks: Delivery Order Approval

**Input**: Design documents from `specs/062-delivery-order-approval/`

**Prerequisites**: plan.md, spec.md, research.md (R1–R12), data-model.md, contracts/ui-contracts.md (C1–C9), quickstart.md, wireframes.md (its Open Questions are resolved in research.md)

**Tests**: The spec doesn't ask for a test suite as such, but the constitution's quality gates and research R11 require tests. Test tasks sit inside each story, after the code they cover.

**Organization**: Grouped by user story (US1–US3, spec.md). All three are P1. US1 (approve from the queue) is the MVP: it adds the screen, the navigation entry and the approve dialog. US2 adds reject to the same screen and dialogs file. US3 adds the two actions to the spec 061 detail screen and makes queue rows open it. Phase 2 holds what the stories share.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: parallelizable (different files, no dependency on an incomplete task)
- **[Story]**: US1 approve from the queue · US2 reject back to the author · US3 review and decide on the detail screen

## Cross-story notes

- **Shared files.** Do these sequentially, not in parallel:
  - `lib/features/sales/presentation/delivery_order_approval/approval_dialogs.dart`: T011 (US1) creates it with the approve dialog, T018 (US2) adds the reject dialog.
  - `lib/features/sales/presentation/delivery_order_approval/delivery_order_approval_screen.dart`: T012 (US1) creates it, then T019 (US2) adds the ✕ icon and T023 (US3) adds the row tap.
  - `lib/features/sales/presentation/delivery_orders/delivery_order_detail_screen.dart`: only T022 (US3) edits it.
  - `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb`: every key is added once, in T002. If a later task needs another, add it there and run `flutter gen-l10n`. Never hand-edit `lib/l10n/app_localizations*.dart`.
- **Generated code.** After editing a `@riverpod` file, run `dart run build_runner build --delete-conflicting-outputs` at the repo root. Never run two build_runner processes at once. No client regeneration is needed: `DeliveryOrdersApi` already has `listApprovalQueueApiV1DeliveryOrdersApprovalGet`, `approveDeliveryOrderApiV1DeliveryOrdersApprovalDeliveryOrderIdApprovePost` and `rejectDeliveryOrderApiV1DeliveryOrdersApprovalDeliveryOrderIdRejectPost` (the reject body is `ReasonRequest`).
- **Formatting.** Format only the files you changed (`dart format <files>`). Never `dart format .`, and never format `lib/generated/`.
- **Dates** go through `formattersProvider` (constitution §V). No `DateFormat`.
- **Spacing tokens, not literals** (`Theme.of(context).spacing`). No automated guard catches a literal, so check it in review.
- **Never match server prose** (§III). Show refusals through `DeliveryOrderRefusal` (spec 061, `delivery_order_dialogs.dart`), which builds the text from the error's `code`. Recognition keys on the code.
- **Status and type names come from l10n:** `deliveryOrderStatusLabel` and `deliveryOrderTypeLabel` in `delivery_order_status_chip.dart`, never `enum.name`.
- **Simplifications.** Any shortcut carries a comment `// simplified: <ceiling>, <what to do when it binds>`.
- **Don't regress spec 061.** `test/widget/features/sales/delivery_order_detail_screen_test.dart` has an action matrix (T039 there, around line 1442). It must keep passing unchanged. The new rights matrix is added beside it.
- **Mirror, don't copy blindly.** Closest precedents:
  - Queue screen, controller and 403 state: `sales/presentation/payment_verification/{payment_verification_screen, verification_queue_controller}.dart`, and `buildCatalogRowActions` with `primaryAction` in `lib/core/widgets/catalog_action_icons.dart`.
  - No-facility branch, name cells, table columns: `sales/presentation/delivery_orders/delivery_orders_list_screen.dart` and `delivery_order_name_cells.dart`.
  - Dialogs with a busy flag, reason field and in-dialog refusal: `payment_verification/{verify_payment_dialog, reject_payment_dialog}.dart` and `showCancelDeliveryOrderDialog` in `delivery_orders/delivery_order_dialogs.dart`.
  - Write notifier returning `AppError?`: `delivery_orders/delivery_order_actions.dart`.

---

## Phase 1: Setup

- [ ] T001 Confirm the starting point: on branch `062-delivery-order-approval`, run `flutter analyze` and `flutter test test/unit/features/sales test/widget/features/sales`, and note anything already failing so it isn't blamed on this feature. No file changes.

---

## Phase 2: Foundational (blocks every story)

**Purpose**: strings, the new error code, the repository methods, the queue controller, the write methods and the dialog value type. Nothing here is user-visible on its own.

- [ ] T002 Add every new string to `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb`, each with an `@key` description starting `spec 062:`, then run `flutter gen-l10n`. Use the `deliveryOrderApproval…` prefix (R10) for: the nav label ("Aprobación de entregas" / "Delivery approval"); the column header "Prio."; the empty text (C2); the no-facility title and message (new wording that mentions approval, C2); the ✓ and ✕ tooltips ("Aprobar", "Rechazar"); the approve dialog (title with `{serial}`, the "Tipo" and "Programada" fact labels if no spec 061 key fits, the delivery note, the pickup note, the "Aprobar" button); the reject dialog (title with `{serial}`, the summary with `{customer}` and `{date}`, the "Motivo" label, the note, the "Rechazar" button); the success SnackBars (approved with `{serial}` and `{status}` placeholders, rejected with `{serial}`); and `apiErrorDeliveryOrderNotPendingApproval` ("Esta orden ya no está pendiente de aprobación." / "This order is no longer pending approval."). Reuse spec 061's `deliveryOrderBackButton` ("Volver") and the shared close label rather than adding duplicates. Wording is in contracts C2–C4, C7, C8 and wireframes.md.
- [ ] T003 Localize the new error code (R9, C9). In `lib/core/errors/localize_problem.dart`, add `api.ErrorCode.deliveryOrderPeriodNotPendingApproval` to the catalog set and a case in the switch returning `l10n.apiErrorDeliveryOrderNotPendingApproval`. In `specs/058-localized-api-errors/contracts/code-scope.tsv`, flip the `delivery_order.not_pending_approval` row (line 55) from `OUT` to `IN` with endpoints `POST /delivery-orders/approval/{}/approve; POST /delivery-orders/approval/{}/reject` and the note `reachable from the delivery order approval queue and detail screen (spec 062)`, and add `POST /delivery-orders/approval/{}/reject` to the `delivery_order.reason_required` row's endpoints (line 59). Add `POST /delivery-orders/approval/{}/approve; POST /delivery-orders/approval/{}/reject` to the `state.transition_invalid` row's endpoints (line 229; reachable only on a race, research R9). The file is tab-separated: keep the tabs. In `test/unit/core/errors/problem_fixtures.dart`, add the fixture params for the new code beside `deliveryOrderPeriodNotFailed` (`{'status': 'APPROVED', 'action': 'approve'}`). Verify: `flutter test test/unit/core/errors` passes, including `catalog_coverage_test`.
- [ ] T004 [P] Add `approvalQueue({int skip = 0, int limit = 20}) → Future<DeliveryOrderPage>`, `approve(int id) → Future<DeliveryOrder>` and `reject({required int id, required String reason}) → Future<DeliveryOrder>` to `lib/features/sales/domain/repositories/delivery_order_admin_repository.dart` (doc comments naming the endpoints, C6), and implement them in `lib/features/sales/data/delivery_order_admin_repository_impl.dart` over the three generated methods. The queue maps with `DeliveryOrderSummary.fromResponse` and sends no facility. Reject sends `ReasonRequest` with the reason as given. Errors map through the same `toAppError` path the other methods use.
- [ ] T005 Create `lib/features/sales/presentation/delivery_order_approval/delivery_order_approval_queue_controller.dart`: `@riverpod` `DeliveryOrderApprovalQueueController`, an `AsyncNotifier` family keyed by `int pageIndex`, page size 20, built on `fetchClampedPage` (`lib/core/widgets/catalog_pagination.dart`) over `approvalQueue`, returning `CatalogPage<DeliveryOrderSummary>`. Doc comment: the server scopes the queue to the user's facility, so there is deliberately no client facility guard (R1, R12). Then run `dart run build_runner build --delete-conflicting-outputs`.
- [ ] T006 Edit `lib/features/sales/presentation/delivery_orders/delivery_order_actions.dart` (R6, C5). Add `approve(int id)` and `reject(int id, {required String reason})`, each returning `({AppError? error, DeliveryOrderStatus? status})`, with the status taken from the write's response. Give `_run` a result-carrying variant (keep the existing `_run` and its `AppError?` callers working by building it on the new one). Make the invalidation also cover `deliveryOrderApprovalQueueControllerProvider`, with the existing rule (the order always; both lists unless the server refused, and a `NetworkError` still counts as "may have changed"). This applies to every write, so a spec 061 cancel of a pending order also refreshes the queue. Update the class doc comment. Run build_runner if the generated part changes.
- [ ] T007 [P] Create `lib/features/sales/presentation/delivery_order_approval/approval_target.dart` (data-model §1): an immutable class with `id`, `serial`, `customerId`, `type`, `date` and the constructors `ApprovalTarget.fromSummary(DeliveryOrderSummary)` and `ApprovalTarget.fromOrder(DeliveryOrder)`. Plain Dart, no freezed. Add a `folio(l10n)` helper that returns `'${serial}'`, falling back to `'#$id'`.
- [ ] T008 [P] Extend `test/unit/features/sales/delivery_order_admin_repository_impl_test.dart`: `approvalQueue` sends `skip` and `limit` and no facility and maps the page and total; `approve` and `reject` hit the right paths; `reject` sends the reason body; a 409 maps to an `AppError` carrying `delivery_order.not_pending_approval`.
- [ ] T009 [P] Create `test/unit/features/sales/delivery_order_approval_queue_controller_test.dart` (templated on `verification_queue_controller_test.dart`): the page and offset sent, and the clamp back one page when a later page comes back empty with a non-zero total.
- [ ] T010 Extend `test/unit/features/sales/delivery_order_actions_test.dart`: `approve` and `reject` return the response's status on success and the `AppError` on refusal, send the trimmed reason as given, and invalidate the queue and list on success and on a `NetworkError` but not on a server refusal; an existing action (cancel) now invalidates the queue too.

**Checkpoint**: `flutter analyze` is clean and `flutter test test/unit/features/sales test/unit/core/errors` passes.

---

## Phase 3: User Story 1 — Approve delivery orders waiting for review (P1) 🎯 MVP

**Goal**: A supervisor opens "Aprobación de entregas", sees the orders waiting at their facility, and approves one with a confirmation. It leaves the queue and moves to En preparación (delivery) or Aprobada (pickup).

**Independent Test** (spec US1): with approval required on the server, confirm a delivery and a pickup order, open the queue as a user with 94 read and update, approve both, and check the new statuses and that both left the queue.

- [ ] T011 [US1] Create `lib/features/sales/presentation/delivery_order_approval/approval_dialogs.dart` with `showApproveDeliveryOrderDialog(BuildContext, ApprovalTarget) → Future<DeliveryOrderStatus?>` (C3, FR-008). Key `delivery_order_approve_dialog`; body with Cliente (the `DeliveryOrderCustomerName` fallback behaviour, as a sentence like spec 061's private `_customerName`), Tipo, Programada (`formattersProvider`) and the type-dependent next-status note; "Volver" and a filled "Aprobar" (key `delivery_order_approve_submit`). Runs `deliveryOrderActionsProvider.notifier.approve`. Busy disables both buttons and blocks dismissal. A refusal stays in the dialog through `DeliveryOrderRefusal`, and the primary becomes "Cerrar" popping `null`. Success pops the returned status.
- [ ] T012 [US1] Create `lib/features/sales/presentation/delivery_order_approval/delivery_order_approval_screen.dart` (C2): `DeliveryOrderApprovalScreen(query)` and `const deliveryOrderApprovalPath = '/sales/delivery-order-approval'`. No-facility notice when `userFacilityIdProvider` is null, without watching the controller (key `delivery_order_approval_no_facility`); `CatalogListStateView` for loading, error with retry and the empty text with no action button; a 403 shows a no-retry not-allowed state (copy the pattern of `_isForbidden` in `payment_verification_screen.dart`); a `DataTableView<DeliveryOrderSummary>` with the Folio, Cliente, Tipo, Programada, Destino (`DeliveryOrderShipTo`), Pedidos and Prio. columns (compact tier drops the Tipo, Destino and Pedidos columns as the spec 061 list does, wireframe compact block), no filter bar, and `CatalogPagination` via `pagination:`, with `onPageChanged` doing `context.go('$deliveryOrderApprovalPath?page=N')`. Add the ✓ row action only with `can(deliveryOrderApproval, update)`, as `primaryAction` in `buildCatalogRowActions` (key `approve_delivery_order_<id>`, tooltip from T002). The helper requires `editTooltip` even with no Edit, so pass `l10n.editActionTooltip`, as `payment_verification_screen.dart` does. Its handler opens the approve dialog from `ApprovalTarget.fromSummary` and, on a returned status, shows the approved SnackBar with `deliveryOrderStatusLabel`. The queue reloads by invalidation (T006). No ✕ icon and no row tap yet.
- [ ] T013 [US1] Edit `lib/core/navigation/nav_destinations.dart` (C1): add `NavBranch.deliveryOrderApproval = 27` with a doc comment in the style of the neighbours, and a `NavDestination(id: 'delivery-order-approval', …)` in the `logistics` group right after `delivery-orders`, icons `Icons.fact_check_outlined` / `Icons.fact_check`, route `deliveryOrderApprovalPath`, gate `PrivilegeGate(SystemObject.deliveryOrderApproval, AccessRight.read)`, with a comment documenting the right (§IV). Add the label resolver tear-off.
- [ ] T014 [US1] Edit `lib/app/router/app_router.dart` (C1): append a `StatefulShellBranch` (index 27) with a `GoRoute` at `deliveryOrderApprovalPath` building `DeliveryOrderApprovalScreen(query: ListQuery.fromUri(state.uri))`, commented like the neighbours; and add a `_routeGate` clause for `deliveryOrderApprovalPath` returning `PrivilegeGate(SystemObject.deliveryOrderApproval, AccessRight.read)`, placed before the `deliveryOrdersPath` clause with a comment saying why (R8).
- [ ] T015 [P] [US1] Create `test/widget/features/sales/delivery_order_approval_screen_test.dart` (templated on `payment_verification_screen_test.dart`): populated rows show folio, customer, type, date, ship-to, sales orders and priority; without Customers read the customer and ship-to cells fall back to `#id` (spec edge case "Names the user can't read"); the footer shows the server total; a user with 94 read only gets no action column; a user with update sees ✓; no-facility shows the notice and makes no request; empty shows the text and no button; a 403 shows the not-allowed state with no retry; tapping ✓ then confirming calls approve, shows the approved SnackBar with the new status, and the row is gone after the reload.
- [ ] T016 [P] [US1] Create `test/widget/features/sales/approval_dialogs_test.dart` for the approve dialog: names the customer, type and date; the note differs for a delivery and a pickup; "Aprobar" calls approve once (double tap sends one request); a `not_pending_approval` refusal stays in the dialog with its message and turns the primary into "Cerrar"; a `NetworkError` shows the unknown-result banner; "Volver" pops `null` without a write.
- [ ] T017 [P] [US1] Extend `test/unit/core/navigation/nav_destinations_test.dart` (the `NavBranch` pin near line 452 gets `deliveryOrderApproval == 27`; the entry appears after Órdenes de entrega only with 94 read) and `test/unit/app/router/app_router_test.dart` (the 94-read route gate, templated on the `deliveryOrders (71) read` group near line 1352: a user with 94 read reaches the queue, a user without it is redirected home, and 71 read alone does not open it).

**Checkpoint**: US1 works alone. A supervisor can open the queue and approve orders. Run `flutter test test/unit test/widget` for the touched files.

---

## Phase 4: User Story 2 — Reject an order back to its author (P1)

**Goal**: The supervisor rejects an order with a mandatory reason. It returns to Borrador and leaves the queue, and its reason and history are visible on the spec 061 detail screen.

**Independent Test** (spec US2): reject an order from the queue with a reason, check it left the queue, is Borrador in Órdenes de entrega, shows the rejection banner and a history line Pend. aprob. → Borrador with the reason; confirm it again and see it return to the queue.

- [ ] T018 [US2] Add `showRejectDeliveryOrderDialog(BuildContext, ApprovalTarget) → Future<DeliveryOrderStatus?>` to `approval_dialogs.dart` (C4, FR-010, FR-011): key `delivery_order_reject_dialog`; summary line (customer · Programada date); a multi-line reason `TextField` (key `delivery_order_reject_reason`, `maxLength: 500`, counter, autofocus); the note; "Volver" and a filled "Rechazar" (key `delivery_order_reject_submit`) disabled while the trimmed reason is empty or busy. It runs `reject` with the trimmed reason. Busy, refusal and "Cerrar" behave as in the approve dialog.
- [ ] T019 [US2] Edit `delivery_order_approval_screen.dart`: add the ✕ row action as the single `extraActions` entry (key `reject_delivery_order_<id>`, tooltip "Rechazar"), shown only with `can(deliveryOrderApproval, update)`. Its handler opens the reject dialog from `ApprovalTarget.fromSummary` and, on success, shows the rejected SnackBar.
- [ ] T020 [P] [US2] Extend `test/widget/features/sales/approval_dialogs_test.dart` for the reject dialog: "Rechazar" is disabled for an empty or whitespace reason; the counter caps at 500; a valid reason calls reject with the trimmed text; a `not_pending_approval` refusal and a `NetworkError` behave as in the approve dialog; "Volver" writes nothing.
- [ ] T021 [P] [US2] Extend `test/widget/features/sales/delivery_order_approval_screen_test.dart`: with update, each row has ✓ and ✕ and nothing else; ✕ then a reason then confirm calls reject, shows the rejected SnackBar and the row is gone; with read only, neither icon is present; a page left empty by an action steps back one page.

**Checkpoint**: US1 and US2 both work. The queue approves and rejects.

---

## Phase 5: User Story 3 — Review the order before deciding (P1)

**Goal**: A supervisor opens an order from the queue to see its lines, and decides there. The spec 061 detail screen offers Rechazar and Aprobar on a pending order, whichever way it was reached.

**Independent Test** (spec US3): open an order from the queue as a user with 94 update and 71 read, approve from the detail screen, check the new status and history, and go back to a queue without that order.

- [ ] T022 [US3] Edit `lib/features/sales/presentation/delivery_orders/delivery_order_detail_screen.dart` (R7, C7, data-model §4). In `_DeliveryOrderBodyState._actionButtons`, replace the early `if (!canUpdate) return const []` with a per-button check: spec 061's buttons each still require 71 update (so every existing rights case renders exactly as before), and for an order in `pendingApproval` add an outlined "Rechazar" (key `delivery_order_reject`) then a filled "Aprobar" (key `delivery_order_approve`), each requiring `can(deliveryOrderApproval, update)` and nothing else. The final order is Cancelar orden, Rechazar, Aprobar. The access check in `build` supplies the new right beside `canUpdate`. Add `_approve` and `_reject` handlers that open the dialogs from `ApprovalTarget.fromOrder(_order)` and show the SnackBars (approved with the status label, rejected). Check that the existing `_confirming` busy flag doesn't need to guard them. Don't change what the screen shows for any other status.
- [ ] T023 [US3] Edit `delivery_order_approval_screen.dart`: set `onRowTap` to `context.push('$deliveryOrdersPath/${o.id}')` only when `can(deliveryOrders, read)`, and leave it null otherwise so rows show no tap affordance (FR-006, R4). Import `deliveryOrdersPath` from `delivery_orders_list_screen.dart`.
- [ ] T024 [P] [US3] Extend `test/widget/features/sales/delivery_order_detail_screen_test.dart`: add the rights matrix from data-model §4 for an order in `pendingApproval` (71 update × 94 update gives exactly the button sets listed, in order), confirm Rechazar and Aprobar are absent in every other status, and cover approving and rejecting from the screen (new status shown after the reload, SnackBar, refusal inside the dialog). The existing T039 action matrix must still pass untouched.
- [ ] T025 [P] [US3] Extend `test/widget/features/sales/delivery_order_approval_screen_test.dart`: with 71 read, tapping a row pushes `/sales/delivery-orders/<id>` and back returns to the queue; without 71 read, rows are not tappable while ✓ and ✕ still work.

**Checkpoint**: all three stories work. The whole spec is built.

---

## Phase 6: Polish and cross-cutting

- [ ] T026 [P] Create `integration_test/delivery_order_approval_quickstart_test.dart` (templated on `integration_test/delivery_orders_quickstart_test.dart` and `payment_verification_quickstart_test.dart`, plus `reference_macos_integration_test_traps` conventions): the read-only part logs in and checks the queue loads at the user's facility; the `MBE_WRITE` part confirms a delivery and a pickup draft, and if confirm doesn't land in Pendiente de aprobación it prints why and skips (the server's `DELIVERY_ORDER_APPROVAL_REQUIRED` is off, quickstart prerequisites), otherwise approves one and rejects the other and checks the statuses through the repository.
- [ ] T027 Format only the files this feature changed (`dart format <files>`, never the repo, never `lib/generated/`) and run `flutter analyze`. It must be clean.
- [ ] T028 Run the full suite, `flutter test`, and confirm it passes with spec 061's tests untouched. Fix any regression from T006 or T022 at its cause.
- [ ] T029 Run the live quickstart: `flutter test integration_test/delivery_order_approval_quickstart_test.dart -d macos`, and again with `MBE_WRITE=1` against a server that has approval required turned on. Record which of the two ran.
- [ ] T030 Walk the manual quickstart steps (quickstart.md 1–11) that the automated tests don't cover: the real navigation entry, the compact tier, and the largest text size. Time SC-001 (open, review and approve one order in under 30 seconds) and SC-002 (clear a 20-order queue without leaving the screen), which only the walkthrough can check. Record unrun steps in the PR description. If any can't be run now, open a tracking issue as spec 061 did (#242), after asking the user.
- [ ] T031 Write `specs/062-delivery-order-approval/pr-description.md`: a summary, the Roadmap section (`Closes mictlanix/mbe-roadmap#39`), the test evidence from T028 and T029, the manual checks left, and the open deployment question (does production set `DELIVERY_ORDER_APPROVAL_REQUIRED`? Until it does, the queue is empty by design). End with the attribution line the session's reminder gives.

---

## Dependencies and execution order

**Phases.** Setup (T001) → Foundational (T002–T010) → US1 → US2 → US3 → Polish. The stories share two files (the dialogs file and the screen file), so they run in order, not in parallel.

**Inside Foundational.**
- T002 before T003 (the error text key).
- T004 before T005, T006, T008. T005 before T006, T009.
- T006 before T010. T007 is independent, but T011 needs it.

**Inside the stories.**
- US1: T011 and T012 need T004–T007. T013 needs T012 (the path constant). T014 needs T012 and T013. Tests T015–T017 need their code.
- US2: T018 needs T011. T019 needs T012 and T018.
- US3: T022 needs T011 and T018. T023 needs T012.
- T026 needs US1–US3 done.

```text
T001 → T002 → T003
T004 ─┬─ T005 ─┬─ T006 → T010
      │        └─ T009
      └─ T008
T007
Foundational ─→ T011 → T012 → T013 → T014 ─→ T015 T016 T017 (parallel)
             ─→ T018 → T019 ─→ T020 T021 (parallel)
             ─→ T022, T023 ─→ T024 T025 (parallel)
All stories ─→ T026 → T027 → T028 → T029 → T030 → T031
```

## Parallel opportunities

- **Foundational:** T004 and T007 can start together. After T004, T008 runs beside T005. After T005, T009 runs beside T006.
- **US1 tests:** T015, T016 and T017 touch different files.
- **US2 tests:** T020 and T021 touch different files.
- **US3 tests:** T024 and T025 touch different files.
- **Polish:** T026 can be written while T027–T028 run on the rest.

## Implementation strategy

**MVP.** Phases 1, 2 and US1 (T001–T017). A supervisor can open the queue and approve orders. That alone clears the "everything stops at Pendiente de aprobación" problem, though a wrong order can only be cancelled, not sent back.

**Increments.**
1. Add US2 (T018–T021): rejection with a reason, which completes the queue's two actions.
2. Add US3 (T022–T025): review on the detail screen, and the same actions there.
3. Finish with Polish (T026–T031): the live test, formatting, the full run, and the PR description.

**Risks to watch while implementing.**
- T006 touches the write path of every spec 061 action. Keep the old `_run` behaviour byte-for-byte for existing callers and let the 061 tests prove it.
- T022 loosens an early return. The 061 matrix test is the guard, so run it right after the edit.
- The live write part only means something against a server with approval required. Don't treat a skipped write part as a pass for FR-009 or FR-012.
