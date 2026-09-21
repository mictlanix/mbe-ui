# Contract: Cash Session List Refresh

**Feature**: `041-fix-list-origin-refresh` | **Date**: 2026-09-20

Covers FR-008 – FR-011.

---

## 1. The rule

> A controller that successfully writes a cash session invalidates the cash
> sessions list family, in the same place it already invalidates the current
> session.

Two call sites, one line each:

| Controller | File | Existing line | Add beside it |
|---|---|---|---|
| `OpenSessionFormController.submit()` | `presentation/open_session_form_controller.dart:104-143` | `ref.invalidate(currentSessionControllerProvider);` | `ref.invalidate(cashSessionsListControllerProvider);` |
| `CloseSessionFormController.submit()` | `presentation/close_session_form_controller.dart:98-140` | same, at `:136` | same |

Placement matters: **after** the awaited repository call has succeeded and
**before** the `state = state.copyWith(saved: true)` / `closed: true` line, so
the re-fetch is already in flight when the form's own success flag flips and the
sheet pops.

---

## 2. Why the family is invalidated bare

`ref.invalidate(cashSessionsListControllerProvider)` is passed **no argument**.

- It is valid: `riverpod 2.6.1` declares
  `void invalidate(ProviderOrFamily provider)`, and the generated
  `cashSessionsListControllerProvider` is a
  `CashSessionsListControllerFamily extends Family<…>`
  (`cash_sessions_list_controller.g.dart:45,51`).
- It is necessary: the form controller cannot know which `CashSessionFilter` the
  history list is currently keyed on. That filter is derived from the screen's
  URL query (`CashSessionFilter.fromQuery`), which the controller never sees.
- It satisfies FR-011 by construction: invalidating the family re-runs each live
  instance's `build(filter)` with the argument it already holds. Filters are
  preserved, not reset.

This is the repo's established pattern, not a new one — eight precedents:
`supplier_form_controller.dart:179,241,279`, `facility_form_controller.dart:191`,
`label_form_controller.dart:94`, `vehicle_form_controller.dart:133`,
`expense_form_controller.dart:91`,
`taxpayer_recipient_form_controller.dart:174,234,272`,
`users_controller.dart:292`.

---

## 3. Why not the sheet

The obvious fix — await the shift sheet and refresh on dismiss — is wrong on
three independent counts (research R6):

1. `_ShiftToolbarAction.openSheet` (`cash_sessions_screen.dart:70-74`) is an
   arrow-bodied `void` closure that discards the returned `Future<void>`.
2. **The close path never goes through that sheet.** There is no `_CloseForm` on
   this screen: `_OpenShiftCard`'s button (`cash_sessions_screen.dart:385-393`)
   pops the sheet and `context.push`es to the session's detail screen, where the
   close is actually submitted (`cash_session_detail_screen.dart` `_submit`,
   ~:284-308). A sheet-dismiss fix would repair open and leave close broken.
3. `showAppSideSheet` documents itself against the pattern
   (`core/widgets/app_side_sheet.dart:20-25`): it returns nothing, and callers
   needing to react are told to read provider state. No caller in `lib/` awaits
   it.

Fixing at the controller covers both paths regardless of which screen, sheet or
route hosts the form.

---

## 4. Cancel behaviour (FR-010)

No guard is written for this. A cancelled or dismissed form never reaches
`submit()`, so neither invalidation fires and the list keeps its contents and
its filters untouched. The requirement is met by where the call sits, not by a
condition.

---

## 5. The stale comment

`cash_sessions_screen.dart:176-184` currently asserts:

> …so the history list and the toolbar action are already refreshing by the time
> this pops.

True of the toolbar action (which watches `currentSessionControllerProvider`),
false of the history list (which watches `cashSessionsListControllerProvider` and
was never invalidated). This is very likely why the bug shipped. **Correct it in
the same change** — left as-is, the next reader re-derives the same wrong
conclusion and may "simplify away" the new invalidation.

---

## 6. Verification

The only assertion that actually proves this fixed is a **re-fetch count**, not
a rendered row. The existing widget-test harness supports it directly: tests
hold the `ProviderContainer` (pumped via `UncontrolledProviderScope`) and stub
the repository with `mocktail`
(`test/widget/features/sales/cash_sessions_screen_test.dart:28-31, 95-190`).

```text
open:   load list (1) → submit open  → expect list fetched again (2)
close:  load list (1) → submit close → expect list fetched again (2)
cancel: load list (1) → dismiss form → expect list still fetched once (1)
```

Asserting on visible rows alone would pass against a fixture that never changes,
which is exactly the failure mode that let this ship. The harness already stubs
a `/sales/cash-sessions/:id` stand-in route, so the close path is reachable
without the real detail screen.
