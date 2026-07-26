# Quickstart & Validation: Cross-Screen UX Consistency & Filtering Backfill

**Feature**: `017-ui-consistency-filters` | **Plan**: [plan.md](./plan.md)

How to run and prove this feature. Because it changes 36 existing screens rather
than adding new ones, validation is mostly **regression** validation: the same
screens must keep doing everything they did, plus the new behavior.

## Prerequisites

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # freezed + riverpod_generator
flutter gen-l10n                                            # after touching either .arb
```

A running mbe-api with a user holding full privileges on at least Vehicles,
Products, Users, and Warehouses. Some checks below need a catalog with **more than
one page** (>20 records) — seed one if necessary; the page-preservation behavior is
invisible on a single-page catalog.

## Run

```bash
flutter run -d chrome        # web — the only target where the URL checks are observable
flutter run -d macos         # desktop — for the Expanded-tier layout checks
```

## Phase gates

### Gate 1 — shared foundations (no user-visible change)

```bash
flutter test test/unit/core/navigation/list_query_test.dart
flutter test test/widget/core/widgets/record_form_actions_test.dart
flutter test test/widget/core/widgets/list_state_views_test.dart
flutter analyze
```

**Expected**: green, and the app looks and behaves exactly as before — nothing is
wired up yet.

### Gate 2 — the routing risk (hard gate, plan Phase 2)

The one assumption that could invalidate the approach: does `context.go` to the same
shell-branch path with different query parameters update the list in place, or
rebuild/reset the branch?

```bash
flutter test test/widget/features/catalog/vehicles_list_screen_test.dart
```

Then manually, on web:

1. Open `/vehicles`.
2. Apply the status filter → address becomes `/vehicles?status=active`.
3. Page forward → `/vehicles?status=active&page=2`.
4. Confirm the nav rail still shows Vehicles selected and the branch did not reset.

**If the branch rebuilds or the rail selection is lost, stop** and revisit
research §4 before converting the other 17 screens.

### Gate 3 — governance (plan Phase 3)

```bash
grep -n "AppBar.actions" .specify/memory/constitution.md
grep -n "Version" .specify/memory/constitution.md | tail -1     # expect 1.10.0
```

**Expected**: §VI's rule reads the new way, the Sync Impact Report records the
1.9.0 → 1.10.0 bump, DESIGN.md §4.2/§4.3 agrees, and the first converted detail
screen is in the same commit. No commit exists in which a converted screen and the
old rule coexist.

## Acceptance walkthroughs

### US1 — record actions in one place

1. Open any catalog, click a **row** (not the Edit icon) → read-only view.
2. **Confirm the app bar has no icons at all.**
3. Scroll to the end of the form → an outlined **Edit** button, right-aligned, sized
   to its content — not stretched across the form.
4. Click Edit → the form becomes editable and the same area now shows
   `[ Delete ] [ Save ]`.
5. Click Delete → confirmation dialog; cancel → nothing is deleted.
6. Repeat on a record in a different module (e.g. a price list) and confirm
   identical placement, order, and styling.
7. Sign in as a user **without** update privilege, open a record → **no** Edit
   control anywhere (absent, not greyed out).
8. Open `/vehicles/new` → only Save; no Edit, no Delete.

### US2 — backfilled filters

1. `/vehicles` → open Filters → status chips are present → select Inactive → only
   inactive vehicles remain, and the **result count and page count** reflect the
   filtered total.
2. `/vehicle-operators` → status combines with the existing operator filter.
3. `/users` → status filter present and applied.
4. `/products` → open Filters → supplier picker present; pick one; combine it with a
   label and a status and confirm all three apply together.
5. Clear each filter → the unfiltered list returns without a page reload.

### US3 — shareable, bookmarkable, refresh-safe

1. `/products` → search a term, apply supplier + status, page to 3.
2. The address now reads e.g.
   `/products?search=tornillo&page=3&status=active&supplier=7`.
3. **Copy it, open in a private window, sign in** → same search, same filters, same
   page — and the filter controls **show** those values, including the supplier's
   **name**, not its id (this is the cold-load resolution; watch for a blank picker).
4. Refresh in place → nothing lost.
5. Clear everything and return to page 1 → address is bare `/products`, no leftover
   parameters.
6. Change filters three times, then press browser **Back** three times → you step
   back through the filter states rather than leaving the list.
7. Hand-edit the address to `?status=bogus&page=999&nonsense=1` → the list loads,
   the bad values are ignored, page clamps to the last valid page, and **no error is
   shown**.

### US4 — keeping your place (the corrected story)

1. Filter a catalog with more than 3 pages, page to 3.
2. Open a record, change nothing, go back → still page 3.
   *(This already worked before the feature — it is a regression check.)*
3. Open a record on page 3, **edit and save** → back on **page 3**, with the change
   visible. **This is the bug being fixed**: before, this landed on page 1 with the
   filters still applied, so the list looked right but showed different records.
4. Delete the only record on the last page → land on a valid page, never an empty one.

### US5 — consistent feedback

1. Throttle the network → every list shows the same loading treatment.
2. Open a catalog with no records → "no records yet" + a **Create the first record**
   action (absent without the create privilege).
3. Search a nonsense term → a **different** message saying nothing matched, with a
   **Clear filters** action.
4. Stop mbe-api, reload a list → a comprehensible message with a **Retry** action,
   and **no raw exception text** anywhere on screen.
5. Restart mbe-api, click Retry → the list reloads with the same search, filters, and
   page.
6. Switch the app to English and repeat step 4 → the error text is localized, not
   hard-coded English leaking through `ErrorBanner`.

## Full suite

```bash
flutter analyze
flutter test
flutter test integration_test/   # or: test/integration, per this repo's layout
```

**Expected**: green. In particular the 23 previously-failing assertions across 16
detail-screen test files now find `edit_<entity>_button` in the form body rather
than the app bar — the key is unchanged, only its location moved.

## Definition of done

- [x] Zero record screens have a non-empty `AppBar.actions` (SC-001).
- [x] `grep -rn "LoadError(e)" lib/features` returns nothing (SC-008).
- [x] Every list route round-trips its filters through the URL (SC-004).
- [x] The repository-parameter audit test passes and covers every list repository
      (SC-003).
- [x] Constitution is at v1.10.0 and DESIGN.md agrees (SC-009).
- [x] `app_en.arb` and `app_es.arb` have identical key sets.
