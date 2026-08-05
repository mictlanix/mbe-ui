---
description: "Task list for Cash Session Open, Close and Count"
---

# Tasks: Cash Session Open, Close and Count

**Input**: Design documents from `/specs/021-cash-sessions/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/mbe-api-cash-sessions.md, contracts/routes.md, contracts/cash-session-screens.md, quickstart.md

**Tests**: Included — the constitution's "Development Workflow & Quality Gates" mandates unit tests for repositories, widget tests for critical screens, and an integration test for the golden path; every prior spec (011–019) sets this precedent.

**Organization**: Tasks are grouped by user story. Story order follows the spec's priorities: US1 Open (P1), US2 Close/Count (P1), US3 History (P2), US4 Recover an abandoned session (P3). US3 depends on US2's detail screen existing (its Independent Test opens a session's detail); US4 depends on US3's history list. Everything else across stories is independent.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: US1–US4, mapping to the spec's user stories
- Every task includes an exact file path

## Path Conventions

Single Flutter project, feature-first. New module `lib/features/sales/` (plan.md Structure Decision) — the first-ever files there, shared with spec 020 which also creates this module but touches none of the same files. Two shared promotions land in `lib/core/`: `money_formatters.dart` (from `features/pricing`) and a `paymentMethodLabel` addition to `lib/core/domain/payment_method.dart`. Shared edits: `lib/app/router/app_router.dart`, `lib/core/navigation/nav_destinations.dart`, both `.arb` files. Tests live under `test/unit/features/sales/`, `test/widget/features/sales/`, `test/unit/core/widgets/`, and `test/integration/`.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Confirm preconditions and stand up the module skeleton. No backend change, no codegen.

- [ ] T001 Confirm the generated client is present and untouched: `lib/generated/openapi/lib/src/api/cash_sessions_api.dart` exposes all 5 operations (`getCurrentSessionApiV1CashSessionsCurrentGet`, `listCashSessionsApiV1CashSessionsGet`, `openCashSessionApiV1CashSessionsPost`, `getCashSessionApiV1CashSessionsCashSessionIdGet`, `closeCashSessionApiV1CashSessionsCashSessionIdClosePost`), plus `CashSessionResponse`, `CashSessionOpen`, `CashSessionClose`, `CurrentSessionResponse`, `ListResponseCashSessionResponse`, `DenominationCount`, `MethodTotal`, `SessionState`, `OpeningAmount`, `Denomination` models (contracts/mbe-api-cash-sessions.md). Do NOT regenerate — if anything is missing, stop and re-open research.md
- [ ] T002 Add `decimal: ^3.2.6` to `pubspec.yaml` and run `flutter pub get` (research.md §2 — the only new dependency; resolves clean per the dry-run verified during planning)
- [ ] T003 [P] Create the module skeleton directories: `lib/features/sales/domain/entities/`, `lib/features/sales/domain/repositories/`, `lib/features/sales/data/`, `lib/features/sales/presentation/widgets/`, `test/unit/features/sales/`, `test/widget/features/sales/` (empty until populated below — spec 020 will independently populate sibling files in the same module; no file collision)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Shared entities, arithmetic, promotions, and wiring every user story depends on.

**⚠️ CRITICAL**: T009 (route) and T010 (nav) touch the two files every other feature also appends to — sequence them last in this phase, after every foundational domain file exists, so nothing downstream blocks on them.

### Shared promotions (constitution §I/§VI require these before any screen can format money)

- [ ] T004 [P] Move `lib/features/pricing/presentation/pricing_formatters.dart` to `lib/core/widgets/money_formatters.dart`, renaming `PricingFormatters` → `MoneyFormatters`. Preserve behavior exactly — do NOT fix the hard-coded `$` symbol or the `'es_MX'` default (research.md §3; out of scope). Update all 9 call sites: `lib/features/pricing/presentation/{price_lists_list_screen,pricing_screen,exchange_rate_detail_screen,exchange_rates_list_screen}.dart`, `lib/features/catalog/presentation/{employee_detail_screen,vehicle_operator_detail_screen,suppliers_list_screen}.dart`, and the comment in `lib/main.dart`. Move `test/unit/features/pricing/pricing_formatters_test.dart` to `test/unit/core/widgets/money_formatters_test.dart` (rename class references) and update `test/widget/features/pricing/exchange_rate_detail_screen_test.dart`'s import
- [ ] T005 [P] Promote `_paymentMethodLabel` out of `lib/features/catalog/presentation/payment_method_option_detail_screen.dart:364` into a shared `paymentMethodLabel(AppLocalizations, PaymentMethod)` function in `lib/core/domain/payment_method.dart` (research.md §13). Preserve the existing `PaymentMethod.fromCode` null-fallback posture — an unrecognized code renders its raw int, never crashes. Update the one existing caller to use the shared function

### Domain layer (data-model.md §1–8)

- [ ] T006 [P] Create `lib/features/sales/domain/denominations.dart` — `const List<String> kMxnDenominations` with the 11 values `'1000','500','200','100','50','20','10','5','2','1','0.50'`, descending (data-model.md §8)
- [ ] T007 [P] Create `lib/features/sales/domain/money.dart` — `parseAmount`, `formatAmount`, `countedTotal`, `expectedCash`, `difference`, wrapping `package:decimal`. `expectedCash` sums only `PaymentMethodTotal` entries where `method == PaymentMethod.cash.code`; entities stay `String`, `Decimal` never escapes this file (data-model.md §7)
- [ ] T008 [P] Create the entities per data-model.md §1–2, §4, §6: `lib/features/sales/domain/entities/cash_session.dart` (`CashSession` + `PaymentMethodTotal`, `fromResponse`, `CashSessionDisplay` extension), `lib/features/sales/domain/entities/current_session.dart` (`CurrentSession` + `SessionState`, `fromResponse`), `lib/features/sales/domain/entities/denomination_count.dart` (`DenominationCount`). Hand-written `@freezed`, no `.g.dart`, matching `cash_drawer.dart`'s convention
- [ ] T009 [P] Create `lib/features/sales/domain/cash_session_status.dart` — `enum CashSessionStatus { open, stale, closed }` and the pure `cashSessionStatusOf(CashSession, {required DateTime today})` derivation, replicating mbe-api's `session_state` exactly (data-model.md §3)

### Repository (data-model.md §5–6, §10; contracts/mbe-api-cash-sessions.md)

- [ ] T010 Define `CashSessionRepository` in `lib/features/sales/domain/repositories/cash_session_repository.dart` — `getCurrent()`, `list({int? cashDrawerId, int skip = 0, int limit = 20})`, `open({int? cashDrawerId, required String openingAmount})`, `get({required int cashSessionId})`, `close({required int cashSessionId, required List<DenominationCount> counts})`, plus `CashSessionListResult { items, total }`. Depends on T008
- [ ] T011 Implement `lib/features/sales/data/cash_session_repository_impl.dart` wrapping `CashSessionsApi` — the `_toAppError` catch-and-rethrow on every method matching the repo-wide convention; `_setOpeningAmount`/`_setDenomination` shims building `AnyOf2<String, num>(values: {0: value})` with the **String arm at key 0** (reversed order throws at runtime — contracts/mbe-api-cash-sessions.md warns explicitly); expose `cashSessionRepositoryProvider`. Depends on T010
- [ ] T012 [P] Add a `FutureProvider<Map<int, CashDrawer>>` (`cashDrawerNameMapProvider`) in `lib/features/sales/data/cash_session_repository_impl.dart` or a sibling file — one `cashDrawerRepository.list(limit: 100)` call cached and keyed by id, asserted against `total` (research.md §5). Depends on T011

### Shared UI pieces

- [ ] T013 [P] Create `lib/features/sales/presentation/widgets/cash_session_status_chip.dart` — `CashSessionStatusChip({required CashSessionStatus status})`, mirroring `EntityStatusCell`'s colour-pair `switch` + `Chip` shape (contracts/cash-session-screens.md). Depends on T009
- [ ] T014 [P] Create `lib/features/sales/presentation/current_session_controller.dart` — `@riverpod` `AsyncNotifier<CurrentSession>` wrapping `cashSessionRepository.getCurrent()`. Depends on T011

### l10n seed (shared keys every story appends to)

- [ ] T015 Seed shared l10n keys in `lib/l10n/app_en.arb` (with `@` blocks) and `lib/l10n/app_es.arb`: `cashSessionsMenuTitle`, `cashSessionStatusOpen`/`Stale`/`Closed`, `cashSessionDrawerFieldLabel`, `cashSessionCashierFieldLabel`, `cashSessionStartFieldLabel`, `cashSessionEndFieldLabel`. Per-story keys are added inside each story's screen task. Run `flutter gen-l10n` after editing

### Routing and navigation (sequenced last — shared files, one clean edit each)

- [ ] T016 Add the `/sales/cash-sessions` `StatefulShellBranch` (appended last, index 17) and the `/sales/cash-sessions/:cashSessionId` top-level sibling to `lib/app/router/app_router.dart`, plus the `_routeGate` clause `startsWith('/sales/cash-sessions')` → `(object: SystemObject.pos, right: AccessRight.read)` (contracts/routes.md §1–2). No `forceReadOnly` param on the detail route — a session has no editable form
- [ ] T017 Add `static const int cashSessions = 17;` to `NavBranch` and a `NavDestination` (`id: 'cash-sessions'`, gate `pos`/`read`) inside the existing `NavGroup(id: 'sales')` in `lib/core/navigation/nav_destinations.dart`, plus the `_cashSessionsLabel` top-level tear-off (contracts/routes.md §3). Sequential with T016 (same branch-index invariant)

**Checkpoint**: Entities, arithmetic, repository, both promotions, routing and nav all exist. No screen yet. Every user story can now start.

---

## Phase 3: User Story 1 - Open a shift on a cash drawer (Priority: P1) 🎯 MVP

**Goal**: A cashier can see they have no open session, open one on a drawer with a declared opening amount, and see it become their current shift.

**Independent Test**: Sign in with no open session, confirm the screen reports that, open a session on the assigned drawer with an opening amount, confirm the screen now reports an open shift with that drawer, start time and amount.

### Tests for User Story 1 ⚠️

- [ ] T018 [P] [US1] Unit test `test/unit/features/sales/current_session_controller_test.dart` — `none`/`open`/`stale` states surfaced from a mocked `CashSessionRepository.getCurrent()`
- [ ] T019 [P] [US1] Unit test `test/unit/features/sales/open_session_form_controller_test.dart` — drawer preselected from `userSettings.cashDrawerId`/`cashDrawerName`; the three-way drawer fork (has `cashDrawers:read` → picker; lacks it but has assigned drawer → static label, no request; lacks both → blocked with FR-007a's administrator message); negative/blank amount validation; the two 409s disambiguated by re-reading `getCurrent()` (cashier-busy vs drawer-busy), asserting the raw `detail` string is never pattern-matched; 404/422 mapping; permission re-check before submit
- [ ] T020 [P] [US1] Widget test `test/widget/features/sales/cash_sessions_screen_test.dart` (US1 scope) — `none` state shows the open form; `open`/`stale` states show drawer/start/amount; open button absent (not disabled) without `pos:create`; the FR-007a blocked state renders no open affordance at all

### Implementation for User Story 1

- [ ] T021 [US1] Create `OpenSessionFormState` (freezed) and `OpenSessionFormController` (`Notifier`) in `lib/features/sales/presentation/open_session_form_controller.dart` per data-model.md §11 — error codes as `static const String` (`drawerRequired`, `amountNegative`, `amountInvalid`, `drawerBusy`, `cashierBusy`, `noDrawerConfigured`, `drawerNotFound`, `openFailed`, `openPermissionDenied`), the drawer-fork logic from T019, the 409 re-read-and-branch logic, `_invalidateCaches()` calling `ref.invalidate(currentSessionControllerProvider)` on success. Depends on T011, T014
- [ ] T022 [US1] Create `lib/features/sales/presentation/cash_sessions_screen.dart` — the shift panel region only (US3 appends the history list below it in Phase 5, same file). Renders the three `SessionState` cases via `CurrentSessionController`; the open form wired to `OpenSessionFormController`; the `CatalogEntityPicker<CashDrawer>` / static label / blocked-message fork (contracts/cash-session-screens.md §1a); the FR-004 "other open sessions" note is a stub `SizedBox.shrink()` here — filled in by T034. Add `cashSessionOpenButtonLabel`, `cashSessionOpeningAmountFieldLabel`, `cashSessionNoOpenSessionMessage`, `cashSessionDrawerBlockedMessage`, `cashSessionDrawerBusyError`, `cashSessionCashierBusyError` l10n keys to both `.arb` files; run `flutter gen-l10n`. Depends on T013, T021

**Checkpoint**: A cashier can open a shift and see it. MVP.

---

## Phase 4: User Story 2 - Close a shift by counting the drawer (Priority: P1)

**Goal**: A cashier counts denominations against an advisory expected-cash figure and closes the session; the counted total and difference are shown once, in the confirmation, because neither can be read back afterward.

**Independent Test**: With an open session that has taken at least one cash payment, navigate directly to its detail route, enter denomination quantities, confirm the counted total/expected/difference update live, close it, confirm it is no longer the cashier's open session.

### Tests for User Story 2 ⚠️

- [ ] T023 [P] [US2] Unit test `test/unit/features/sales/money_test.dart` — the exact-sum property: a full 11-denomination count sums correctly as `Decimal` where the same sum in `double` accumulates error; `expectedCash` includes only `PaymentMethod.cash` totals; `difference` sign matches over/short
- [ ] T024 [P] [US2] Unit test `test/unit/features/sales/cash_session_status_test.dart` — `open`/`stale`/`closed` derivation including a session started one second before midnight, with `today` injected for determinism
- [ ] T025 [P] [US2] Unit test `test/unit/features/sales/close_session_form_controller_test.dart` — running total/expected/difference update per quantity change; only `quantity > 0` rows submitted; all-zero requires explicit empty-count confirmation before submit; 409 already-closed preserves entered quantities and refreshes state (FR-024); 404; permission re-check; non-negative-whole-number validation
- [ ] T026 [P] [US2] Widget test `test/widget/features/sales/cash_session_detail_screen_test.dart` (US2 scope) — 11 denomination rows descending from zero; extended amount per row; the advisory note text is present; a non-zero difference does not block Close; Close absent (not disabled) without `cashSessionClose:update`, replaced by the "ask your supervisor" message; empty-count confirmation dialog gates an all-zero close; success confirmation shows counted total and difference

### Implementation for User Story 2

- [ ] T027 [US2] Create `CloseSessionFormState` (freezed) and `CloseSessionFormController` (`Notifier`) in `lib/features/sales/presentation/close_session_form_controller.dart` per data-model.md §11 — `quantities: Map<String, int>` keyed by denomination string, recomputed `countedTotal`/`expectedCash`/`difference` via `money.dart` on every change, error codes (`quantityInvalid`, `alreadyClosed`, `sessionNotFound`, `closeFailed`, `closePermissionDenied`), `_invalidateCaches()` on success. Depends on T007, T011
- [ ] T028 [P] [US2] Create `lib/features/sales/presentation/widgets/denomination_count_table.dart` — one row per `kMxnDenominations` entry, a quantity `TextFormField` (`keyboardType: numberWithOptions`) per row, extended-amount display; no `TextInputFormatter` (matches the codebase-wide convention of validating in the controller). Depends on T006
- [ ] T029 [US2] Create `lib/features/sales/presentation/cash_session_detail_screen.dart` — summary region (drawer/cashier/start/end/closedBy/openingAmount/paymentsByMethod, all `ResponsiveFormGrid` `maxColumns: 2`, amounts via `MoneyFormatters`, method labels via T005's `paymentMethodLabel`) always rendered; the count/close region from T028 rendered only when status is open/stale AND the viewer holds `cashSessionClose:update`, else the supervisor-required message; the empty-count confirmation `showDialog<bool>` (research.md §11 — no shared helper exists, hand-rolled here); Close as a body `FilledButton`, never an app-bar icon; success confirmation dialog reporting counted total + difference (FR-023). Deliberately does NOT use `RecordFormActions` (research.md §6 — none of Delete/Edit/Save apply). Add `cashSessionCloseButtonLabel`, `cashSessionCountedTotalLabel`, `cashSessionExpectedCashLabel`, `cashSessionDifferenceLabel`, `cashSessionDifferenceOver`/`Short`/`Zero`, `cashSessionAdvisoryNote`, `cashSessionEmptyCountConfirmTitle`/`Message`, `cashSessionAlreadyClosedError`, `cashSessionSupervisorRequiredMessage`, `cashSessionClosedByFieldLabel`, `cashSessionPaymentsByMethodLabel` l10n keys to both `.arb` files; run `flutter gen-l10n`. Depends on T009, T012, T027, T028

**Checkpoint**: A shift can be opened and closed end to end, independent of the history list.

---

## Phase 5: User Story 3 - Review shift history (Priority: P2)

**Goal**: Browse a paginated, drawer-filterable list of sessions newest-first, and open any session's detail read-only.

**Independent Test**: Open the history list, confirm newest-first ordering with drawer/cashier/start/end/status, filter by drawer, page forward and back, open a closed session's detail to see its opening amount and per-method payments.

### Tests for User Story 3 ⚠️

- [ ] T030 [P] [US3] Unit test `test/unit/features/sales/cash_sessions_list_controller_test.dart` — `CashSessionFilter.fromQuery` round-trip (drawer facet, no `search` field); `fetchClampedPage` integration; drawer-name and cashier-name resolution via T012's map and the existing `employeeDisplayNameProvider` family; filter change resets `pageIndex` to 0
- [ ] T031 [P] [US3] Widget test `test/widget/features/sales/cash_sessions_screen_test.dart` (US3 scope, extends T020's file) — columns present with correct alignment; no row action icons; row click opens read-only detail; the filter bar's `search` slot renders nothing (documented deviation, not a bug — assert its absence explicitly so a future "fix" doesn't quietly add a dead search box); drawer facet filter with `Badge.count`; pagination present and uses the shared component

### Implementation for User Story 3

- [ ] T032 [US3] Create `CashSessionFilter` (freezed, `fromQuery`/`activeFilterCount`) and `CashSessionsListController` (`@riverpod` family) in `lib/features/sales/presentation/cash_sessions_list_controller.dart` per data-model.md §9 — `fetchClampedPage` wrapping `cashSessionRepository.list`, page size 20. Depends on T010
- [ ] T033 [US3] Extend `lib/features/sales/presentation/cash_sessions_screen.dart` (from T022) to add the history list region below the shift panel: `DataTableView<CashSession>` with `pagination:`/`onPageChanged:`, wrapped in `CatalogListStateView`; drawer/cashier columns resolved via T012's map and `employeeDisplayNameProvider`, falling back to `#<id>`; status column via T013's chip; `CatalogFilterBar` with the drawer facet in `filters:`, nothing in `search:`, nothing in `actions:`; `onRowTap` → `context.push('/sales/cash-sessions/$id')`. Add `cashSessionsListEmptyMessage`, `cashSessionsFilterDrawerLabel`, `cashSessionColumnDrawer`/`Cashier`/`Start`/`End`/`Status` l10n keys; run `flutter gen-l10n`. Depends on T029 (detail screen must exist for row-tap navigation), T032

**Checkpoint**: Full shift lifecycle plus browsable history, independently testable end to end.

---

## Phase 6: User Story 4 - Recover an abandoned session (Priority: P3)

**Goal**: A supervisor finds and closes a stale or orphaned session belonging to another cashier, via the history list and the existing detail screen — no new close mechanism, just the existing one applied cross-cashier.

**Independent Test**: With a cashier who has several open sessions, confirm the history list (filtered to their drawer) shows all of them while their own shift panel shows only the newest; as a `cashSessionClose` holder, close a non-current one from its detail; confirm it closes and the original cashier is still recorded as its cashier.

### Tests for User Story 4 ⚠️

- [ ] T034 [P] [US4] Unit test `test/unit/features/sales/current_session_controller_test.dart` (extends T018's file) — the FR-004 same-drawer heuristic (research.md §16): given an open current session, a second `list(cashDrawer:)` call finding another row with the same `cashierId` and `end == null` surfaces the "other open sessions exist" flag; no match ⇒ no flag; the heuristic never claims certainty when it finds nothing
- [ ] T035 [P] [US4] Widget test `test/widget/features/sales/cash_sessions_screen_test.dart` (US4 scope, extends T020/T031's file) — the "other open sessions exist" note renders only when T034's heuristic matches; a stale session belonging to another cashier is closeable from its detail by a `cashSessionClose` holder and the closed session keeps its original `cashierId` while gaining a `cashSupervisorId`

### Implementation for User Story 4

- [ ] T036 [US4] Extend `CurrentSessionController` (`lib/features/sales/presentation/current_session_controller.dart`, from T014) with the research.md §16 heuristic: on an open/stale result, issue `cashSessionRepository.list(cashDrawerId: session.cashDrawerId, limit: 100)` and check for another row matching `cashierId` with `end == null`; expose the result as an `hasOtherOpenSessions: bool` field. Depends on T011, T034
- [ ] T037 [US4] Wire the note into `cash_sessions_screen.dart`'s shift panel (replacing T022's stub): when `hasOtherOpenSessions` is true, render text pointing at the history list, using `cashSessionOtherSessionsWarning` (new l10n key, both `.arb` files; run `flutter gen-l10n`). Confirm (no code change expected, test-only) that `cash_session_detail_screen.dart`'s close flow already permits closing a session whose `cashierId` differs from the signed-in user — FR-026 falls out of T029 as built, since the close controller never compares `cashierId` to the caller. Depends on T029, T036

**Checkpoint**: All four user stories independently functional; legacy orphaned sessions are recoverable.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Cross-story validation, the mandatory router test coverage, and final gates.

- [ ] T038 Extend `test/unit/app/router/app_router_test.dart` per contracts/routes.md §4 — gate allow (user with `pos:read` reaches `/sales/cash-sessions`) and deny (redirects to `/`); the branch-index assertion `AppShell.navigationShell.currentIndex == NavBranch.cashSessions` (the spec-018 pattern); detail route param parsing and gating. **Add `cashSessionRepositoryProvider` and `currentSessionControllerProvider` overrides to `pumpAt`** — the new branch's screen fetches eagerly and an unmocked call trips the leak detector at teardown, failing unrelated tests
- [ ] T039 [P] Verify `test/unit/core/l10n_parity_test.dart` passes after every `.arb` edit in this feature — run from the repo root
- [ ] T040 [P] Integration test `test/integration/cash_session_flow_test.dart` — live backend, `.env`-guarded per the established `_canRun` pattern: discover a drawer at runtime via `cashDrawerRepository.list()` rather than hardcoding an id; golden path open → observe a second open on the same drawer refused → submit denomination counts → close → observe it is no longer the cashier's current session (quickstart.md). Add the new `MBE_CASH_SESSION_*` variables to `.env.template` with the file's documented blank-skips-tests convention
- [ ] T041 Run the full gate: `dart run build_runner build --delete-conflicting-outputs`, `flutter gen-l10n`, `flutter analyze` (clean), `flutter test`, and the quickstart.md 25-step manual walkthrough including the RBAC absent-not-disabled spot-check across all four privilege gates (`pos:create`, `pos:read`, `cashDrawers:read`, `cashSessionClose:update`)
- [ ] T042 [P] Confirm no regression in the four pricing screens and three catalog screens touched by T004's formatter promotion, and in `payment_method_option_detail_screen.dart` touched by T005's label promotion — re-run their existing widget tests
- [ ] T043 File the two mbe-api dependencies as issues if not already done (research.md §14): expand `cash_drawer`/`cashier`/`cash_supervisor` to `{id, name}`; add cashier/date-range/status filters and a sort choice to `GET /cash-sessions`. **Already filed**: [mbe-api#141](https://github.com/mictlanix/mbe-api/issues/141), [mbe-api#142](https://github.com/mictlanix/mbe-api/issues/142) — this task is a checkpoint, not new work

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately.
- **Foundational (Phase 2)**: Depends on Setup — BLOCKS all user stories. T004/T005 (promotions) and T006–T009 (domain) are parallel; T010–T012 (repository) are sequential on each other; T013–T014 (shared UI/controller) depend on T009/T011; T016–T017 (router/nav) come last and are sequential with each other.
- **User Stories (Phase 3–6)**: All depend on Foundational.
  - US1 (Open) and US2 (Close) touch disjoint files except both extend the same domain layer — fully parallel-buildable.
  - US3 (History) depends on US2's `cash_session_detail_screen.dart` existing (row-tap target) and edits the **same file** US1 created (`cash_sessions_screen.dart`) — sequential: T022 (US1) → T033 (US3).
  - US4 (Recover) depends on US3's list existing and edits `current_session_controller.dart` (from US1/Foundational) and `cash_sessions_screen.dart` (from US1/US3) — sequential after both.
  - Concretely: **T022 → T033 → T037**, all on `cash_sessions_screen.dart`; **T014 → T036**, both on `current_session_controller.dart`. Everything else across stories is parallelizable.
- **Polish (Phase 7)**: Depends on all four stories being complete.

### Within Each User Story

- Tests (marked [P]) are written first and MUST fail before implementation.
- Entity/domain (Foundational) → form controller → screen/widget → l10n.
- The two same-file sequences above are the only cross-story serialization; everything else within a story is on its own files.

### Parallel Opportunities

- All Phase 1 tasks, and T004–T009 in Phase 2, can run in parallel.
- Once Foundational completes, **US1 and US2 can be built fully in parallel** by different developers — disjoint files.
- US3 can start as soon as US1's `cash_sessions_screen.dart` shell (T022) and US2's detail screen (T029) both exist; its own list-controller work (T032) has no dependency on either and can start immediately after Foundational.
- US4's test (T034) can be written as soon as Foundational's `current_session_controller.dart` (T014) exists — before US2/US3 are done — but its implementation (T036) needs T011, and its screen wiring (T037) needs both T029 and T033.
- All test tasks within a story marked [P] can run in parallel.

---

## Parallel Example: User Story 1

```bash
# Launch all US1 tests together (they fail first):
Task: "Unit test current_session_controller_test.dart"
Task: "Unit test open_session_form_controller_test.dart"
Task: "Widget test cash_sessions_screen_test.dart (US1 scope)"
```

---

## Implementation Strategy

### MVP First (User Story 1 only)

1. Complete Phase 1: Setup.
2. Complete Phase 2: Foundational (entities, arithmetic, repository, both promotions, routing/nav).
3. Complete Phase 3: US1 (Open).
4. **STOP and VALIDATE**: open a session, confirm it renders as the current shift, confirm the two 409s produce distinct messages via re-read (not string matching).
5. Deploy/demo if ready — opening is a complete, observable slice even before closing exists.

### Incremental Delivery

1. Setup + Foundational → foundation ready.
2. Add US1 Open → test independently → demo (MVP).
3. Add US2 Close/Count → test independently (direct route navigation to a session id) → demo — full shift lifecycle now works end to end.
4. Add US3 History → test independently → demo — sessions become browsable and supervised.
5. Add US4 Recover → test independently → demo — legacy orphans become reachable and closeable.
6. Polish (router coverage, l10n parity, integration test, regression check, issue-filing checkpoint).

### Parallel Team Strategy

With Foundational done: Developer A takes US1, Developer B takes US2 — both independent. Once both land, Developer C takes US3 (needs US2's detail screen and edits US1's screen file). US4 follows US3, needing both `current_session_controller.dart` (Foundational/US1) and the now-extended `cash_sessions_screen.dart` (US1+US3).

---

## Notes

- No mbe-api change and no client regeneration anywhere in this feature (T001) — issues #141/#142 are filed and tracked, not blocking.
- `decimal` (T002) is confined to `money.dart` (T007); every entity still carries `String` amounts, matching the repo-wide convention.
- FR-007a (the no-drawer-and-no-privilege block) and the FR-004 same-drawer heuristic (research.md §16) are both deliberate scope decisions reached during planning — not gaps to "fix" later without re-reading their rationale.
- [P] tasks = different files, no dependencies. [Story] label maps each task to its user story.
- Verify tests fail before implementing; commit after each task or logical group.
- Stop at any checkpoint to validate a story independently.
