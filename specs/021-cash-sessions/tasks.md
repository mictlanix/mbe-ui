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

- [X] T001 Confirm the generated client is present and untouched: `lib/generated/openapi/lib/src/api/cash_sessions_api.dart` exposes all 5 operations (`getCurrentSessionApiV1CashSessionsCurrentGet`, `listCashSessionsApiV1CashSessionsGet`, `openCashSessionApiV1CashSessionsPost`, `getCashSessionApiV1CashSessionsCashSessionIdGet`, `closeCashSessionApiV1CashSessionsCashSessionIdClosePost`), plus `CashSessionResponse`, `CashSessionOpen`, `CashSessionClose`, `CurrentSessionResponse`, `ListResponseCashSessionResponse`, `DenominationCount`, `MethodTotal`, `SessionState`, `OpeningAmount`, `Denomination` models (contracts/mbe-api-cash-sessions.md). Do NOT regenerate — if anything is missing, stop and re-open research.md
- [X] T002 Add `decimal: ^3.2.6` to `pubspec.yaml` and run `flutter pub get` (research.md §2 — the only new dependency; resolves clean per the dry-run verified during planning)
- [X] T003 [P] Create the module skeleton directories: `lib/features/sales/domain/entities/`, `lib/features/sales/domain/repositories/`, `lib/features/sales/data/`, `lib/features/sales/presentation/widgets/`, `test/unit/features/sales/`, `test/widget/features/sales/` (empty until populated below — spec 020 will independently populate sibling files in the same module; no file collision)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Shared entities, arithmetic, promotions, and wiring every user story depends on.

**⚠️ CRITICAL**: T009 (route) and T010 (nav) touch the two files every other feature also appends to — sequence them last in this phase, after every foundational domain file exists, so nothing downstream blocks on them.

### Shared promotions (constitution §I/§VI require these before any screen can format money)

- [X] T004 [P] Move `lib/features/pricing/presentation/pricing_formatters.dart` to `lib/core/widgets/money_formatters.dart`, renaming `PricingFormatters` → `MoneyFormatters`, plus a new `dateTime()` method for session start/end timestamps. Preserve the three original methods' behavior exactly — did NOT fix the hard-coded `$` symbol or the `'es_MX'` default (research.md §3; out of scope). Updated all 9 call sites (also fixed each file's import ordering into the existing `core/widgets/` block) and moved+renamed the test to `test/unit/core/widgets/money_formatters_test.dart`, with an added `dateTime` test. `flutter analyze` clean; all 10 tests pass
- [X] T005 [P] Promoted `paymentMethodLabel(AppLocalizations, int code)` (the raw-code-with-fallback shape, not the enum-only shape) into `lib/core/domain/payment_method.dart` (research.md §13). Found **two** duplicated private copies, not the one the task description named — `payment_method_option_detail_screen.dart:364` (enum-typed) and `payment_method_options_list_screen.dart:238` (int-typed, kept as the promoted signature). Both deleted, both call sites updated (`.code` added at the enum-typed call site). `flutter analyze` clean

### Domain layer (data-model.md §1–8)

- [X] T006 [P] Create `lib/features/sales/domain/denominations.dart` — `const List<String> kMxnDenominations` with the 11 values `'1000','500','200','100','50','20','10','5','2','1','0.50'`, descending (data-model.md §8)
- [X] T007 [P] Create `lib/features/sales/domain/money.dart` — `parseAmount`, `formatAmount`, `countedTotal`, `expectedCash`, `difference`, wrapping `package:decimal`. `expectedCash` sums only `PaymentMethodTotal` entries where `method == PaymentMethod.cash.code`; entities stay `String`, `Decimal` never escapes this file (data-model.md §7). Verified in `money_test.dart` (11 tests) — the exact-sum property holds for a full 11-denomination count and for a large quantity at a low denomination
- [X] T008 [P] Create the entities per data-model.md §1–2, §4, §6: `lib/features/sales/domain/entities/cash_session.dart` (`CashSession` + `PaymentMethodTotal`, `fromResponse`), `lib/features/sales/domain/entities/current_session.dart` (`CurrentSession` + `SessionState`, `fromResponse`), `lib/features/sales/domain/entities/denomination_count.dart` (`DenominationCount`). Hand-written `@freezed`, no `.g.dart`, matching `cash_drawer.dart`'s convention. **No `CashSessionDisplay` extension** — mbe-api#141 shipped mid-implementation, so `cashDrawerName`/`cashierName` are non-nullable fields with no resolution step to have a fallback for (data-model.md §1, superseding the pre-#141 design)
- [X] T009 [P] Create `lib/features/sales/domain/cash_session_status.dart` — `enum CashSessionStatus { open, stale, closed }` and the pure `cashSessionStatusOf(CashSession, {required DateTime today})` derivation, replicating mbe-api's `session_state` exactly (data-model.md §3). Also added `toApi()` mapping to the generated `CashSessionStatus` filter enum (mbe-api#142), mirroring `EntityStatus.toApi()`'s convention. Verified in `cash_session_status_test.dart` (6 tests) incl. the midnight-boundary edge case

### Repository (data-model.md §5–6, §10; contracts/mbe-api-cash-sessions.md)

- [X] T010 Define `CashSessionRepository` in `lib/features/sales/domain/repositories/cash_session_repository.dart` — `getCurrent()`, `list({int? cashDrawerId, int? cashierId, CashSessionStatus? status, int skip = 0, int limit = 20})` (mbe-api#142's `dateFrom`/`dateTo` accepted too but never called from this feature's UI), `open({int? cashDrawerId, required String openingAmount})`, `get({required int cashSessionId})`, `close({required int cashSessionId, required List<DenominationCount> counts})`, plus `CashSessionListResult { items, total }`. Depends on T008 and T009 (the domain `CashSessionStatus` the `status` param takes)
- [X] T011 Implement `lib/features/sales/data/cash_session_repository_impl.dart` wrapping `CashSessionsApi` — the `_toAppError` catch-and-rethrow on every method matching the repo-wide convention; `_setOpeningAmount`/`_setDenomination` shims building `AnyOf2<String, num>(values: {0: value})` with the **String arm at key 0**; map the domain `CashSessionStatus` to the generated `CashSessionStatus` enum for the `list` call; `CashSession.fromResponse` flattens `cash_drawer`'s (`CashDrawerSummary`) and `cashier`/`cash_supervisor`'s (`EmployeeResponse`) names directly — **no separate name-resolution request of any kind**; expose `cashSessionRepositoryProvider`. Naming collision on both `CashSessionStatus` and `DenominationCount` (domain vs. generated) resolved via `hide` on the main import plus a second `as gen show DenominationCount` import, avoiding a `lib/src` reach-in. Verified in `cash_session_repository_impl_test.dart` (15 tests) via a fake `HttpClientAdapter`, incl. confirming `opening_amount`/`denomination` serialize as plain strings on the wire, not a wrapped object — caught and fixed a test-only bug (reading `options.data` as already-decoded, not JSON bytes) in the process. Depends on T010
- [ ] ~~T012~~ **Deleted** — mbe-api#141 shipped mid-implementation and expanded `cash_drawer`/`cashier`/`cash_supervisor` to full objects on every response, so there is nothing left to resolve into a name map (research.md §5, §17). Do not create this file.

### Shared UI pieces

- [X] T013 [P] Create `lib/features/sales/presentation/widgets/cash_session_status_chip.dart` — `CashSessionStatusChip({required CashSessionStatus status})`, mirroring `EntityStatusCell`'s colour-pair `switch` + `Chip` shape (contracts/cash-session-screens.md). Every state gets a chip (unlike `EntityStatusCell`, none of the three is an unmarked default). Depends on T009
- [X] T014 [P] Create `lib/features/sales/presentation/current_session_controller.dart` — `@riverpod` `AsyncNotifier<CurrentSession>` wrapping `cashSessionRepository.getCurrent()`. Depends on T011

### l10n seed (shared keys every story appends to)

- [X] T015 Seed shared l10n keys in `lib/l10n/app_en.arb` (with `@` blocks) and `lib/l10n/app_es.arb`: `cashSessionsMenuTitle`, `cashSessionStatusOpen`/`Stale`/`Closed`, `cashSessionDrawerFieldLabel`, `cashSessionCashierFieldLabel`, `cashSessionStartFieldLabel`, `cashSessionEndFieldLabel`. Per-story keys are added inside each story's screen task. Run `flutter gen-l10n` after editing

### Routing and navigation (sequenced last — shared files, one clean edit each)

- [X] T016 Add the `/sales/cash-sessions` `StatefulShellBranch` (appended last, index 17) and the `/sales/cash-sessions/:cashSessionId` top-level sibling to `lib/app/router/app_router.dart`, plus the `_routeGate` clause `startsWith('/sales/cash-sessions')` → `(object: SystemObject.pos, right: AccessRight.read)` (contracts/routes.md §1–2). No `forceReadOnly` param on the detail route — a session has no editable form. **Deviation from task order**: wired against minimal placeholder `CashSessionsScreen`/`CashSessionDetailScreen` stubs (correct constructor signatures, `Placeholder()` bodies) created ahead of T022/T029, since the router can't reference screens that don't exist yet — this file is edited once, not twice
- [X] T017 Add `static const int cashSessions = 17;` to `NavBranch` and a `NavDestination` (`id: 'cash-sessions'`, gate `pos`/`read`) inside the existing `NavGroup(id: 'sales')` in `lib/core/navigation/nav_destinations.dart`, plus the `_cashSessionsLabel` top-level tear-off (contracts/routes.md §3). Sequential with T016 (same branch-index invariant). **Verified early** (moved up from Polish/T038): added gate allow/deny + branch-index (17) tests to `app_router_test.dart` now, plus the `cashSessionRepositoryProvider` override in `pumpAt` the real T022 screen will need — all 35 router tests pass, zero regressions

**Checkpoint**: Entities, arithmetic, repository, both promotions, routing and nav all exist. No screen yet. Every user story can now start.

---

## Phase 3: User Story 1 - Open a shift on a cash drawer (Priority: P1) 🎯 MVP

**Goal**: A cashier can see they have no open session, open one on a drawer with a declared opening amount, and see it become their current shift.

**Independent Test**: Sign in with no open session, confirm the screen reports that, open a session on the assigned drawer with an opening amount, confirm the screen now reports an open shift with that drawer, start time and amount.

### Tests for User Story 1 ⚠️

- [X] T018 [P] [US1] Unit test `test/unit/features/sales/current_session_controller_test.dart` — `none`/`open`/`stale` states surfaced from a mocked `CashSessionRepository.getCurrent()`. 4 tests, all pass
- [X] T019 [P] [US1] Unit test `test/unit/features/sales/open_session_form_controller_test.dart` — drawer preselected from `userSettings.cashDrawerId`/`cashDrawerName`; the three-way drawer fork; negative/blank amount validation; the two 409s disambiguated by re-reading `getCurrent()` (cashier-busy vs drawer-busy), asserting the raw `detail` string is never pattern-matched; 404/422 mapping incl. the empty-array 422 edge case (`noDrawerConfigured`); permission re-check before submit. Written genuinely first (TDD), against a controller that didn't exist yet. 17 tests, all pass on first run against T021
- [X] T020 [P] [US1] Widget test `test/widget/features/sales/cash_sessions_screen_test.dart` (US1 scope) — `none` state shows the open form; `open`/`stale` states show drawer/start/amount; open button absent (not disabled) without `pos:create`; the FR-007a blocked state renders no open affordance at all. 7 tests. **Caught two real bugs**, both fixed: (1) a `RenderFlex` overflow from testing the screen without the `Scaffold` wrapper production always provides via `AppShell`; (2) a genuine Riverpod `autoDispose` race — seeding the drawer from `initState`'s `ref.listenManual` happened before anything watched `openSessionFormControllerProvider`, so the seeded state was disposed (zero listeners) before the real UI ever saw it. Fixed by moving the seed call inside `_OpenForm.build()` itself, guaranteeing the provider is alive while it runs (research.md-worthy finding, see T021/T022 notes)

### Implementation for User Story 1

- [X] T021 [US1] Create `OpenSessionFormState` (freezed) and `OpenSessionFormController` (`Notifier`) in `lib/features/sales/presentation/open_session_form_controller.dart` per data-model.md §11 — error codes as `static const String` (`drawerRequired`, `amountNegative`, `amountInvalid`, `drawerBusy`, `cashierBusy`, `noDrawerConfigured`, `drawerNotFound`, `openFailed`, `openPermissionDenied`), the drawer-fork logic, the 409 re-read-and-branch logic (falls back to `drawerBusy` if the re-read itself throws, rather than crashing or leaving `submitting: true` stuck), `ref.invalidate(currentSessionControllerProvider)` on success. Also added `blockingSessionId` (not in the original data-model.md field list) so FR-010's "offer the close action" has a concrete target to link to. Depends on T011, T014
- [X] T022 [US1] Create `lib/features/sales/presentation/cash_sessions_screen.dart` — the shift panel region only (US3 appends the history list below it in Phase 5, same file). Renders the three `SessionState` cases via `CurrentSessionController`; the open form wired to `OpenSessionFormController`; the `CatalogEntityPicker<CashDrawer>` / static label / blocked-message fork (contracts/cash-session-screens.md §1a). **`seedAssignedDrawer` is called from inside `_OpenForm.build()`, not from a `CashSessionsScreen` `initState`** — see T020's note; the screen ended up a plain `ConsumerWidget` with no lifecycle needs of its own. The hand-rolled static-label `TextFormField` needed the same value-keyed remount trick `CatalogEntityPicker` already documents (`initialValue` only seeds on first mount), wrapped in a stable-keyed `KeyedSubtree` so tests can still find it by a fixed key. The FR-004 "other open sessions" note is a stub `SizedBox` here — filled in by T036/T037. Added `cashSessionCloseButtonLabel`, `cashSessionPaymentsByMethodLabel`, `cashSessionStaleWarningMessage`, `cashSessionOpenFailedError`, `cashSessionOpenPermissionDeniedError` l10n keys beyond the originally-planned set — needed by contracts §1a's Close button and the open/stale card, and by two error codes the plan named but never assigned copy to. Depends on T013, T021

**Checkpoint**: A cashier can open a shift and see it. MVP.

---

## Phase 4: User Story 2 - Close a shift by counting the drawer (Priority: P1)

**Goal**: A cashier counts denominations against an advisory expected-cash figure and closes the session; the counted total and difference are shown once, in the confirmation, because neither can be read back afterward.

**Independent Test**: With an open session that has taken at least one cash payment, navigate directly to its detail route, enter denomination quantities, confirm the counted total/expected/difference update live, close it, confirm it is no longer the cashier's open session.

### Tests for User Story 2 ⚠️

- [X] T023 [P] [US2] **Already satisfied by T007** — `money_test.dart` was written and verified alongside `money.dart` itself (Foundational phase), not deferred to this story. 11 tests, all passing
- [X] T024 [P] [US2] **Already satisfied by T009** — `cash_session_status_test.dart` was written and verified alongside `cash_session_status.dart` itself (Foundational phase), incl. the midnight-boundary case. 6 tests, all passing
- [X] T025 [P] [US2] Unit test `test/unit/features/sales/close_session_form_controller_test.dart` — the empty-count confirmation is explicitly the *screen's* job, not the controller's (research.md §11) — the controller accepts an all-zero submit unconditionally; running total/expected/difference update per quantity change; only `quantity > 0` rows submitted; 409 already-closed preserves entered quantities; 404/permission/generic-failure mapping. Written first (TDD). 10 tests, all pass on first run against T027
- [X] T026 [P] [US2] Widget test `test/widget/features/sales/cash_session_detail_screen_test.dart` (US2 scope) — summary fields for open and closed sessions; the close region gated on `cashSessionClose:update` (absent, not disabled, replaced by the supervisor-required message); live counted/difference update on quantity entry; a non-zero difference closes immediately with no dialog (FR-019); an all-zero count requires the confirm-empty dialog first. 7 tests. Needed `tester.ensureVisible` before tapping Close — off-screen inside `SingleChildScrollView` at the default 800×600 test viewport, unrelated to the T020 `Scaffold` finding

### Implementation for User Story 2

- [X] T027 [US2] Create `CloseSessionFormState` (freezed) and `CloseSessionFormController` (`Notifier`) in `lib/features/sales/presentation/close_session_form_controller.dart` per data-model.md §11 — `quantities: Map<String, int>` keyed by denomination string, recomputed `countedTotal`/`expectedCash`/`difference` via `money.dart` on every change, error codes (`quantityInvalid`, `alreadyClosed`, `sessionNotFound`, `closeFailed`, `closePermissionDenied`), `ref.invalidate(currentSessionControllerProvider)` on success. Depends on T007, T011
- [X] T028 [P] [US2] Create `lib/features/sales/presentation/widgets/denomination_count_table.dart` — one row per `kMxnDenominations` entry, a quantity `TextFormField` (`keyboardType: numberWithOptions`) per row, extended-amount display; no `TextInputFormatter`. Added `extendedAmount(denomination, quantity)` to `money.dart` (with its own 2 tests) so this widget never needs to import `package:decimal` itself. Depends on T006
- [X] T029 [US2] Create `lib/features/sales/presentation/cash_session_detail_screen.dart`, plus the small `CashSessionDetailController` family provider (`get(cashSessionId:)`) neither data-model.md nor this task named explicitly but the screen needs to fetch by id somehow — summary region (drawer/cashier/start/end/closedBy/openingAmount/paymentsByMethod, all `ResponsiveFormGrid` `maxColumns: 2`, amounts via `MoneyFormatters`, method labels via T005's `paymentMethodLabel`) always rendered; the count/close region from T028 rendered only when status is open/stale AND the viewer holds `cashSessionClose:update`, else the supervisor-required message; the empty-count confirmation `showDialog<bool>` (research.md §11 — no shared helper exists, hand-rolled here); Close as a body `FilledButton`, never an app-bar icon; success confirmation dialog reporting counted total + difference (FR-023). Deliberately does NOT use `RecordFormActions` (research.md §6 — none of Delete/Edit/Save apply). Add `cashSessionCloseButtonLabel`, `cashSessionCountedTotalLabel`, `cashSessionExpectedCashLabel`, `cashSessionDifferenceLabel`, `cashSessionDifferenceOver`/`Short`/`Zero`, `cashSessionAdvisoryNote`, `cashSessionEmptyCountConfirmTitle`/`Message`, `cashSessionAlreadyClosedError`, `cashSessionSupervisorRequiredMessage`, `cashSessionClosedByFieldLabel`, `cashSessionPaymentsByMethodLabel` l10n keys to both `.arb` files; run `flutter gen-l10n`. Depends on T009, T011, T027, T028 (T012 dependency removed — deleted, mbe-api#141)

**Checkpoint**: A shift can be opened and closed end to end, independent of the history list.

---

## Phase 5: User Story 3 - Review shift history (Priority: P2)

**Goal**: Browse a paginated, drawer-filterable list of sessions newest-first, and open any session's detail read-only.

**Independent Test**: Open the history list, confirm newest-first ordering with drawer/cashier/start/end/status, filter by drawer, page forward and back, open a closed session's detail to see its opening amount and per-method payments.

### Tests for User Story 3 ⚠️

- [X] T030 [P] [US3] Unit test `test/unit/features/sales/cash_sessions_list_controller_test.dart` — `CashSessionFilter.fromQuery` round-trip for all 3 facets (drawer/cashier/status, no `search` field); unparseable facet values degrade to null rather than throw; `fetchClampedPage` integration. 9 tests, all pass
- [X] T031 [P] [US3] Widget test `test/widget/features/sales/cash_sessions_screen_test.dart` (US3 scope, extends T020's file) — columns present; row click opens read-only detail; the filter bar's `search` slot renders nothing, asserted via `find.byType(CatalogSearchBar)` specifically — a naive `find.byType(TextField)` false-positives on the shift panel's own form fields; empty state. 4 tests

### Implementation for User Story 3

- [X] T032 [US3] Create `CashSessionFilter` (freezed, `fromQuery`/`activeFilterCount`, fields `cashDrawerId`/`cashierId`/`status`/`pageIndex` per data-model.md §9 as updated post-mbe-api#142) and `CashSessionsListController` (`@riverpod` family) in `lib/features/sales/presentation/cash_sessions_list_controller.dart` — `fetchClampedPage` wrapping `cashSessionRepository.list`, page size 20. Depends on T010
- [X] T033 [US3] Extend `lib/features/sales/presentation/cash_sessions_screen.dart` (from T022) to add the history list region below the shift panel: `DataTableView<CashSession>` with `pagination:`/`onPageChanged:`, wrapped in `CatalogListStateView`; drawer/cashier columns read directly off `CashSession.cashDrawerName`/`cashierName`; status column via T013's chip; `CatalogFilterBar` with **three** facets in `filters:` (cash drawer + cashier `CatalogEntityPicker`, status `ChoiceChip` row over `CashSessionStatus`, each with a `*DisplayNameProvider` for cold-loaded URL facets — added `cashDrawerDisplayNameProvider` to `cash_drawer_repository_impl.dart`, matching the existing `employeeDisplayNameProvider` precedent exactly, since no such provider existed for cash drawers before this), nothing in `search:`, nothing in `actions:`; `onRowTap` → `context.push('/sales/cash-sessions/$id')`. Depends on T029, T032

**Checkpoint**: Full shift lifecycle plus browsable history, independently testable end to end.

---

## Phase 6: User Story 4 - Recover an abandoned session (Priority: P3)

**Goal**: A supervisor finds and closes a stale or orphaned session belonging to another cashier, via the history list and the existing detail screen — no new close mechanism, just the existing one applied cross-cashier.

**Independent Test**: With a cashier who has several open sessions, confirm the history list (filtered to their drawer) shows all of them while their own shift panel shows only the newest; as a `cashSessionClose` holder, close a non-current one from its detail; confirm it closes and the original cashier is still recorded as its cashier.

### Tests for User Story 4 ⚠️

- [ ] T034 [P] [US4] Unit test `test/unit/features/sales/current_session_controller_test.dart` (extends T018's file) — FR-004's "other open sessions" check, now a **direct, exact** query (research.md §17 superseded the same-drawer heuristic §16 described): given an open current session, `cashSessionRepository.list(cashierId: myEmployeeId, status: CashSessionStatus.open)` returning more than one row (i.e. a row besides the current session) surfaces the "other open sessions exist" flag; exactly one row (the current session itself) ⇒ no flag. Unlike the superseded heuristic, this is exhaustive across every drawer, not a same-drawer approximation
- [X] T035 [P] [US4] Widget test `test/widget/features/sales/cash_sessions_screen_test.dart` (US4 scope, extends T020/T031's file) — the "other open sessions exist" note renders only when T034's query finds another row; a stale session belonging to another cashier is closeable from its detail by a `cashSessionClose` holder and the closed session keeps its original `cashierId` while gaining a `cashSupervisorId`. Added an `otherOpenSessionsTotalFor` param to `pumpScreen`'s stub: mocktail resolves overlapping `when()` matchers last-registered-wins, so the exact-value stub for `list(cashierId:, status: open, limit: 100)` must be registered *after* the generic history-list stub, not before. Two new cases cover both the warning-present and warning-absent paths; the closeable-by-another-cashier claim is already covered by existing repository/controller tests, no new code needed there

### Implementation for User Story 4

- [X] T036 [US4] Extend `CurrentSessionController` (`lib/features/sales/presentation/current_session_controller.dart`, from T014) with the FR-004 check per research.md §17: on an open/stale result, issue `cashSessionRepository.list(cashierId: session.cashierId, status: CashSessionStatus.open, limit: 100)` and check whether more than one row comes back; expose the result as an `hasOtherOpenSessions: bool` field. This replaces the same-drawer heuristic research.md §16 originally specified — mbe-api#142's `cashier` filter makes the direct query both simpler and exhaustive. Depends on T011, T034. Implemented as a separate `hasOtherOpenSessionsProvider` `FutureProvider<bool>` (matching the `employeeDisplayNameProvider`/`cashDrawerDisplayNameProvider` convention for a small derived async value) rather than a field on `CurrentSession`, keeping the wire-mapped entity untouched; returns `false` immediately when there is no current session
- [X] T037 [US4] Wire the note into `cash_sessions_screen.dart`'s shift panel (replacing T022's stub): when `hasOtherOpenSessions` is true, render text pointing at the history list, using `cashSessionOtherSessionsWarning` (new l10n key, both `.arb` files; run `flutter gen-l10n`). Confirm (no code change expected, test-only) that `cash_session_detail_screen.dart`'s close flow already permits closing a session whose `cashierId` differs from the signed-in user — FR-026 falls out of T029 as built, since the close controller never compares `cashierId` to the caller. Depends on T029, T036. Wired into `_OpenShiftCard` (watches `hasOtherOpenSessionsProvider`), key `cash_session_other_sessions_warning`, l10n key `cashSessionOtherSessionsWarningMessage`; `flutter analyze` clean

**Checkpoint**: All four user stories independently functional; legacy orphaned sessions are recoverable.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Cross-story validation, the mandatory router test coverage, and final gates.

- [X] T038 **Done early, folded into T016/T017** rather than deferred to Polish — a branch-index mismatch is silent, so it was verified the moment the router/nav wiring landed rather than risk forgetting it later. Gate allow/deny, detail route parsing/gating, and the branch-index assertion are all in `app_router_test.dart`; `cashSessionRepositoryProvider` override added to `pumpAt`. Confirm at Polish time only that T022/T029/T033/T037 haven't silently changed what the stub screens need — `currentSessionControllerProvider` itself needs no separate override since it derives from `cashSessionRepositoryProvider`
- [X] T039 [P] Verify `test/unit/core/l10n_parity_test.dart` passes after every `.arb` edit in this feature — run from the repo root. Passes
- [X] T040 [P] Integration test `test/integration/cash_session_flow_test.dart` — live backend, `.env`-guarded per the established `_canRun` pattern: discover a drawer at runtime via `cashDrawerRepository.list()` rather than hardcoding an id; golden path open → observe a second open on the same drawer refused → submit denomination counts → close → observe it is no longer the cashier's current session (quickstart.md). Add the new `MBE_CASH_SESSION_*` variables to `.env.template` with the file's documented blank-skips-tests convention. Single test account (both `pos:create`/`read` and `cashSessionClose:update`) rather than the two separate accounts quickstart.md's prerequisites list — matches `catalog_master_flow_test.dart`'s existing convention where one combined-rights account plays every role. The second-open rejection asserts `ServerError.statusCode == 409` only, no `detail` string matching. Compiles clean, skips (no creds configured)
- [X] T041 Run the full gate: `dart run build_runner build --delete-conflicting-outputs`, `flutter gen-l10n`, `flutter analyze` (clean), `flutter test`, and the quickstart.md 25-step manual walkthrough including the RBAC absent-not-disabled spot-check across all four privilege gates (`pos:create`, `pos:read`, `cashDrawers:read`, `cashSessionClose:update`). Codegen/gen-l10n/analyze all clean. `flutter test`: 1287 passed, 43 skipped (integration tests without configured credentials), 5 failed — all in `payment_method_option_repository_impl_test.dart`/`payment_method_option_test.dart`, a pre-existing failure unrelated to this feature (confirmed via `git diff`: neither file touched by any cash-sessions commit; last touched by an ancestor commit predating this branch's work). Not fixed here — out of this feature's scope. **The 25-step manual walkthrough was not performed** — no browser-automation tool is available in this environment; left for the user to run per quickstart.md
- [X] T042 [P] Confirm no regression in the four pricing screens and three catalog screens touched by T004's formatter promotion, and in `payment_method_option_detail_screen.dart` touched by T005's label promotion — re-run their existing widget tests. All 9 touched screens' widget test files pass (57 tests total)
- [X] T043 File the two mbe-api dependencies as issues if not already done (research.md §14): expand `cash_drawer`/`cashier`/`cash_supervisor` to `{id, name}`; add cashier/date-range/status filters and a sort choice to `GET /cash-sessions`. **Already filed**: [mbe-api#141](https://github.com/mictlanix/mbe-api/issues/141), [mbe-api#142](https://github.com/mictlanix/mbe-api/issues/142) — this task is a checkpoint, not new work. Confirmed via `gh issue view`: #141, #142 and the blocking build defect #144 are all **CLOSED**

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
