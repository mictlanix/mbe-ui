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
Cash Drawers and Points of Sale. Seed data should include, at minimum:

- one **store** facility with ≥2 warehouses, ≥1 point of sale and ≥1 cash drawer
- one **production site** with warehouses and no points of sale
- one facility with **no children at all**
- more than 20 facilities, so pagination is exercised

Optional but valuable: a facility whose type is `productionSite` but which has a
point of sale (research §2), and a point of sale whose warehouse belongs to
another facility (research §3). Neither can be created through the UI or the API —
they must be inserted directly if you want to see those paths.

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
flutter test test/integration/navigation_shell_flow_test.dart --dart-define-from-file=.env
```

Both need a reachable mbe-api; they skip rather than fail when `.env` values are
blank. `facility_catalogs_flow_test.dart` currently drives the three deleted list
screens and must be reworked to drive the tree instead.

---

## What "done" looks like

Every acceptance scenario in [spec.md](./spec.md) is reproducible against a live
backend, `flutter test` and `flutter analyze` are clean, and the two silent-failure
checks above (Gate 1's scroll behavior, Gate 3's `/warehouses/5` redirect) have
been performed by hand at least once.
