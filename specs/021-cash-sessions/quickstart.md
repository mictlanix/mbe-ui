# Quickstart: validating Cash Session Open, Close and Count

**Feature**: `021-cash-sessions` | **Date**: 2026-08-04

How to prove the feature works. Details of *what* to build are in
[plan.md](./plan.md), [data-model.md](./data-model.md) and
[contracts/](./contracts/); this file is the run and validation guide.

---

## Prerequisites

- Flutter stable, Dart 3.10.3+
- mbe-api reachable — default `http://127.0.0.1:8000`, override with
  `--dart-define=API_BASE_URL=https://...`
- A user account with `POS (44)` READ + CREATE, for opening
- A user account with `CASH_SESSION_CLOSE (111)` UPDATE, for closing
- **A user with `POS` but *without* `CASH_DRAWERS (10)` READ** — needed to exercise the
  picker fallback (research §7), which is the easiest path to miss
- At least one cash drawer, and a user whose settings assign one

## Build and check

Run in this order — the codegen steps are not optional, since entities, controllers and
localizations are all generated.

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter analyze
flutter test
```

`flutter analyze` must be clean and `flutter test` green. The l10n parity test
(`test/unit/core/l10n_parity_test.dart`) reads relative paths, so **run from the repo root**
or it fails spuriously.

## Unit and widget tests

```bash
flutter test test/unit/features/sales/
flutter test test/widget/features/sales/
flutter test test/unit/app/router/app_router_test.dart
flutter test test/unit/core/l10n_parity_test.dart
flutter test test/unit/core/widgets/money_formatters_test.dart
```

The five that carry the most risk:

| Test | Proves |
|---|---|
| `money_test.dart` | A full-ladder count sums exactly — the same sum in `double` does not. This is the property SC-004's correctness rests on. |
| `cash_session_status_test.dart` | The three-way derivation, including a session started one second before midnight seen the next morning. `today` is injected so this is deterministic. |
| `open_session_form_controller_test.dart` | Both 409s reach the right message via the current-session re-read, **with no string matching** — the drawer-busy and cashier-busy cases differ only in what the re-read returns. |
| `close_session_form_controller_test.dart` | An all-zero count requires explicit confirmation; a 409 on close preserves entered counts (FR-024). |
| `app_router_test.dart` | Gate allows/denies, and `AppShell.navigationShell.currentIndex == NavBranch.cashSessions`. The branch-index assertion is the only thing standing between a renumbering slip and a silently wrong screen. |

**If unrelated tests suddenly fail at teardown**, the cause is almost certainly the missing
repository override in `app_router_test.dart`'s `pumpAt`: the new branch's screen fetches
eagerly, and an unmocked call leaves a pending timer that trips the leak detector.

## Integration test (live backend)

```bash
cp .env.template .env      # then fill in the MBE_CASH_SESSION_* values
flutter test test/integration/cash_session_flow_test.dart --dart-define-from-file=.env
```

Guarded by `_canRun`, so it **skips rather than fails** when credentials are absent, matching
every other integration test. Golden path:

> open a session on a drawer → observe a second session on the same drawer is refused →
> submit denomination counts → close → observe it is no longer the cashier's open session

Follow the established fixture pattern: discover the drawer at runtime from
`cashDrawerRepository.list()` rather than hardcoding an id, and use
`markTestSkipped(...)` when live data cannot satisfy a precondition.

**This test opens and closes real sessions and cannot undo them** — a closed session is
terminal, with no delete or reopen operation. Point it at a dev tenant, never production, and
expect it to leave closed sessions behind. That is unavoidable, not a defect in the test.

## Manual validation

Run the app and sign in:

```bash
flutter run -d chrome
```

Navigate to **Sales → Cash Sessions**.

### Opening (User Story 1)

1. With no open session, the panel says so and offers to open one.
2. Your assigned drawer is preselected **by name** — confirm no drawer request was needed.
3. Leave the amount blank → opens with zero. Enter `-1` → rejected before submitting.
4. Open a session. The panel now shows drawer, start time and opening amount.
5. Try to open a second → told you already have one, **with the close action offered**.
6. As a different cashier, try that same drawer → a *different* message about the drawer
   being busy. Both are 409s; confirm the two messages and remedies differ.
7. Sign in as a user with no assigned drawer and no `cashDrawers` read → **no open affordance
   at all**, and an error stating a cash drawer must be assigned, directing them to their
   administrator (FR-007a). Not a picker that fails, and not a disabled button.

### Counting and closing (User Story 2)

8. From the panel, choose Close → lands on the session detail screen.
9. Eleven denomination rows, descending, all starting at zero.
10. Enter quantities. After **every** change, the counted total, expected figure and
    difference all update, and the difference reads over, short, or zero.
11. Confirm the advisory note about the expected figure is present and legible.
12. Close with a difference → not blocked, no justification demanded.
13. Confirm the success message reports the counted total **and** the difference. Reload the
    session — the breakdown is gone and nothing implies it is retrievable.
14. As a user without `cashSessionClose` viewing an open session → no close affordance
    anywhere, and a message that a supervisor must close it.
15. Set every quantity to zero and close → explicit "counted and empty" confirmation first.

### History and recovery (User Stories 3 and 4)

16. The list shows drawer, cashier, start, end and status, newest first.
17. A session started yesterday and still open reads **stale**, visually distinct from open.
18. Filter by drawer, then by cashier, then by status (open/stale/closed) → each resets
    paging to page 1; page forward and back → every filter survives, and so does a browser
    reload (filters live in the URL). All three facets exist because mbe-api#142 shipped
    mid-implementation — confirm there is no fourth, date-range control, since nothing
    requires one.
19. Click a row → read-only detail. No edit, reopen or delete anywhere.
20. Detail shows payments grouped by method with a total each.
21. With a cashier who has several open sessions: the history lists **all** of them while
    their own panel shows only the newest and notes that others need attention.
22. As a holder of `cashSessionClose`, close another cashier's stale session → it closes, and
    the original cashier remains recorded as the session's cashier while you are recorded as
    having closed it.

### Cross-cutting

23. Switch locale to Spanish → every string translated, amounts and dates localized. No raw
    key, no manually formatted number.
24. Narrow the window below 600 px → the summary and the count collapse to one column and
    the count stays operable.
25. As a user without `POS` read → the Cash Sessions nav entry is absent, and navigating to
    `/sales/cash-sessions` directly redirects to `/`.

## Definition of done

- [x] `flutter analyze` clean, `flutter test` green (1287 passed, 43 skipped for missing live-backend credentials), l10n parity passing. 5 failures in `payment_method_option_repository_impl_test.dart`/`payment_method_option_test.dart` are pre-existing and unrelated to this feature (neither file touched by any cash-sessions commit)
- [x] All 41 functional requirements exercised by a test or a manual step above
- [x] Every privilege-gated action verified **absent** — not disabled — without its privilege
- [x] Both 409 paths verified to produce distinct messages, with no `detail` string parsed
- [x] The exact-sum property verified in `money_test.dart`
- [x] Branch-index assertion present in `app_router_test.dart`
- [x] Formatter promotion: all 9 source call sites and 2 test files updated, old file deleted
- [x] mbe-api issues filed and linked: [#141](https://github.com/mictlanix/mbe-api/issues/141) (expand FKs), [#142](https://github.com/mictlanix/mbe-api/issues/142) (list filters) — see [research.md](./research.md) §14. All three, including the blocking build defect [#144](https://github.com/mictlanix/mbe-api/issues/144), are closed
- [x] `.env.template` documents the new `MBE_CASH_SESSION_*` variables
- [ ] The quickstart.md 25-step manual walkthrough — not run by the implementing agent (no browser-automation tool available); left for a human to run before sign-off
