# Quickstart & Validation: Nested Facility Management

**Feature**: `018-nested-facility-management` | **Plan**: [plan.md](./plan.md)

How to run this feature and prove it works. Two things need deliberate
verification because nothing fails loudly when they break: the **route guards on
the surviving record screens** (contracts/routes.md §5) and the **eager child
load** (research §1).

## Prerequisites

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # freezed + riverpod_generator
flutter gen-l10n                                            # after touching either .arb
```

A running mbe-api and a user holding full privileges on Facilities, Warehouses,
Cash Drawers and Points of Sale.

**What the reference tenant actually contains** (verified 2026-07-26): 14
facilities, **all stores** — no production sites — which fits on one page. So two
scenarios cannot be reached by clicking through live data and must be covered by
widget tests with fabricated data instead:

| Scenario | Why it is unreachable live | Covered by |
|---|---|---|
| Production site: Warehouses-only card + FR-011 note | Zero rows of `type = 1` | Widget test |
| Page preserved after a mutation (FR-027) | 14 facilities = a single page | Widget test |

Reachable live, and expected in the seed data:

- a store with ≥2 warehouses, ≥1 point of sale and ≥1 cash drawer
- a facility with **no children at all**

To exercise the two unreachable paths by hand instead, create a production-site
facility from the facility form, or temporarily lower the facilities page size.

Optional: a point of sale whose warehouse belongs to another facility, to see the
cross-facility badge (research §3). mbe-api rejects that combination on write, so
it must be inserted directly.

**One-off data check before shipping** (research §2). The UI treats "production
sites have warehouses only" as an invariant, but mbe-api does not enforce it, so a
migrated row could contradict it and would then be unreachable:

```sql
-- STORE = 0, PRODUCTION_SITE = 1 — `= 1` is the violating side
SELECT p.point_sale_id, p.code, f.name
  FROM point_sale p JOIN facility f ON f.facility_id = p.facility
 WHERE f.type = 1;
SELECT c.cash_drawer_id, c.code, f.name
  FROM cash_drawer c JOIN facility f ON f.facility_id = c.facility
 WHERE f.type = 1;
```

Both empty → risk closed. Non-empty → data cleanup in mbe-api, not a UI change.

## Run

```bash
flutter run -d chrome     # web — the only target where URL/deep-link checks are observable
flutter run -d macos      # desktop — Expanded-tier layout
```

For the compact tier, narrow the Chrome window below 600 px rather than using a
device emulator; `LayoutBreakpoints` keys off width alone.

---

## Phase gates

### Gate 1 — children load and render (US1)

```bash
flutter test test/widget/features/catalog/facilities_list_screen_test.dart
flutter analyze
```

Then in the running app, open `/facilities` and confirm:

- Counts appear on **every** card on the page — including ones you must scroll to
  reach — without expanding anything. If counts pop in as you scroll, the card
  list was built lazily; see research §1.
- Expanding any card is instantaneous, with no spinner.
- The production site shows only Warehouses plus the explanatory note.
- The childless facility shows all applicable sections with empty placeholders.
- Search, status filter and page survive a browser reload and a copied link;
  expansion state does not.

### Gate 2 — in-context CRUD (US2)

With the app running:

1. Expand a store facility → **+ Almacén** → confirm the facility picker is
   already filled in. Save.
2. On return: same page, same card still expanded, warehouse count +1, new row
   present.
3. Repeat for **+ Punto de venta** and **+ Caja**.
4. Open a warehouse via its edit icon, change its facility to a different one,
   save. **Both** cards must update — the record leaves the old card and appears
   under the new one. This is the `originalFacilityId` path (research §6); if the
   old card still shows it, that field is missing or is being overwritten by
   `facilitySelected`.
5. Click a child row anywhere but the edit icon → it must open **read-only**.
6. Delete a record from its own detail screen → it disappears from its section and
   the count drops, card still expanded.

Cold-load check — paste directly into the address bar:

```
/warehouses/new?facility=<some facility id>
```

The picker must be pre-filled, proving FR-023 rather than only the in-app path.

### Gate 3 — navigation and guards (US3)

```bash
flutter test test/widget/core/widgets/app_navigation_test.dart
flutter test test/unit/app/router/app_router_test.dart
```

The router test must cover both halves of contracts/routes.md:

- every `NavDestination`'s `branchIndex` activates the branch it names
  (renumbering, §2)
- a user without `warehouses:read` is redirected away from **`/warehouses/5`**,
  not just `/warehouses` (§5)

The second assertion is the one that matters. If the three prefix guards were
deleted along with the list screens, every other test in the suite still passes
and the only symptom is unauthorized records reachable by URL.

Manually: the Catálogos menu shows Facilities and no longer shows Warehouses, Cash
Drawers or Points of Sale; `/warehouses` no longer resolves; `/warehouses/<id>`
still does.

### Gate 4 — compact tier (US4)

Narrow the window below 600 px and confirm: no horizontal scrolling at any point,
chevrons trailing, status as dots, create actions as a chip row inside the expanded
card, and the FAB present. Every action available on the wide tier must be
reachable.

### Full suite

```bash
flutter test
flutter analyze
```

Expected deletions (their subjects no longer exist): the three
`*_list_screen_test.dart` files for warehouses, cash drawers and points of sale.
`test/unit/features/repository_list_params_audit_test.dart` must still pass
untouched — the repositories did not change.

---

## Integration tests

```bash
flutter test test/integration/facility_catalogs_flow_test.dart --dart-define-from-file=.env
flutter test test/integration/facility_children_controller_live_test.dart --dart-define-from-file=.env
flutter test test/integration/navigation_shell_flow_test.dart --dart-define-from-file=.env
```

All three skip rather than fail when `.env` values are blank.

- `facility_catalogs_flow_test.dart` operates entirely at the repository/API
  level — create a facility, a warehouse under it, a point of sale drawing from
  that warehouse, and a cash drawer, then verify and clean up. It never touched
  the deleted list screens (an earlier note here claimed otherwise; corrected
  during implementation once the file was actually read), so it needed no rework
  for this feature.
- `facility_children_controller_live_test.dart` is new, added during this
  feature's implementation: `FacilityChildrenController` is new code that no
  other test exercises against real wire data. It fetches the real first page of
  facilities and runs the actual fetch-by-type logic (research §2) against each
  one, concurrently — matching how the real screen watches every card's provider
  at once (research §1) — asserting a production site never returns points of
  sale or cash drawers and that the cross-facility check never throws.
- `navigation_shell_flow_test.dart` needs no live backend (its data sources are
  mocked) and needed no changes for this feature.

---

## What "done" looks like

Every acceptance scenario in [spec.md](./spec.md) is reproducible against a live
backend, `flutter test` and `flutter analyze` are clean, and the two silent-failure
checks above (Gate 1's scroll behavior, Gate 3's `/warehouses/5` redirect) have
been performed by hand at least once.
