# Phase 1 Data Model: Nested Facility Management

**Feature**: `018-nested-facility-management` | **Date**: 2026-07-26

No API entity changes. No generated-client regeneration. This feature adds one
presentation-scoped aggregate and three form-state fields; everything else is
existing domain entities recomposed.

---

## 1. Existing entities — unchanged

| Entity | File | Used for |
|---|---|---|
| `FacilityListItem` | `domain/entities/facility_list_item.dart` | The card header: `facilityId`, `code`, `name`, `type`, `status` |
| `Warehouse` | `domain/entities/warehouse.dart` | Warehouse child rows |
| `PointSale` | `domain/entities/point_sale.dart` | POS child rows; carries `warehouseId`/`warehouseName` |
| `CashDrawer` | `domain/entities/cash_drawer.dart` | Cash-drawer child rows |
| `FacilityType` | `core/domain/facility_type.dart` | `store` / `productionSite` — icon and section rules |
| `EntityStatus` | `core/domain/entity_status.dart` | Status badge / dot |

`FacilityListItem` already carries everything a collapsed card header needs
except the counts, which come from §2.

---

## 2. `FacilityChildren` — new, presentation-scoped

**File**: `lib/features/catalog/domain/entities/facility_children.dart` (freezed)

The complete child set of one facility, as displayed under its card.

| Field | Type | Notes |
|---|---|---|
| `facilityId` | `int` | The family key this was loaded for |
| `warehouses` | `List<Warehouse>` | Complete — see loading rule below |
| `pointsOfSale` | `List<PointSale>` | Complete; empty when not fetched |
| `cashDrawers` | `List<CashDrawer>` | Complete; empty when not fetched |
| `warehousesReadable` | `bool` | From `can(warehouses, read)` at load time |
| `pointsOfSaleReadable` | `bool` | From `can(pointsOfSale, read)`; always `false` for a production site, which has none by definition |
| `cashDrawersReadable` | `bool` | From `can(cashDrawers, read)`; always `false` for a production site |

**Why the `*Readable` flags exist**: an empty list is ambiguous — it means both
"this facility has none" and "you may not see them". FR-010 requires an empty-state
placeholder for the first case and FR-029 requires the section to be *absent* in
the second. The flag disambiguates without the widget re-reading access control.

### Derived values (extension, not stored)

| Getter | Rule |
|---|---|
| `warehouseCount` / `pointSaleCount` / `cashDrawerCount` | `list.length` — the list is complete, so length is the true total |
| `isCrossFacility(PointSale p)` | `!warehouses.any((w) => w.warehouseId == p.warehouseId)` — FR-009; see research §3 |

### Loading rule

Per research §7, each list is fetched with `limit: 100` and, while
`total > loaded.length`, subsequent pages are appended by `skip`. Consequently
**`list.length` is the count** — there is no partial-load state to represent, which
is why no `total` field appears above.

Which types are fetched is decided **before** any request, by facility type
(research §2) and then by privilege:

| Facility type | Fetched |
|---|---|
| `store` | warehouses, points of sale, cash drawers — each only if readable |
| `productionSite` | warehouses only, and only if readable |

A type that is not fetched has an empty list and a `false` `*Readable` flag. The
card consults `FacilityType` first, so a production site never reaches the
point-of-sale or cash-drawer branch at all; the flags disambiguate "none exist"
from "not readable" only within the sections a facility's type actually permits.

---

## 3. `FacilityChildrenController` — new provider family

**File**: `lib/features/catalog/presentation/facility_children_controller.dart`

```
facilityChildrenControllerProvider(int facilityId, FacilityType facilityType) -> AsyncValue<FacilityChildren>
```

- **Keyed by** `facilityId` and `facilityType` together — not by filter or page: the
  child set of a facility does not depend on how its parent was found, so a
  facility appearing under a different search keeps its cached children. The type
  is part of the key (rather than looked up inside the provider) because it
  decides which child types are fetched at all (research §2); passing it in lets
  the caller supply it from the `FacilityListItem` it already holds, at zero extra
  requests, instead of the provider issuing its own "get this facility" call.
- **Watched by** each facility card. Because the card list is non-lazy
  (research §1), every facility on the page starts loading on first paint —
  this is what implements FR-017.
- **Invalidated by** the three child form controllers after create/update/delete,
  for the affected facility id (research §6).
- **Errors** stay inside the `AsyncValue` and render per-card with a retry
  (FR-020); they never propagate to the page.

The existing `facilitiesListControllerProvider(FacilityFilter)` and `FacilityFilter`
are **unchanged** — search, status facet, page index and `fetchClampedPage`
clamping all carry over from spec 017 untouched.

---

## 4. Expansion state — view-local

**File**: `facilities_list_screen.dart` (screen `State`, not a provider)

`Set<int> expandedFacilityIds`, plus a derived `allExpanded` for the toolbar
toggle's label (FR-012).

Deliberately **not** a Riverpod provider and **not** in the URL (FR-013): it must
survive push/pop to a record screen — which it does, because the list screen stays
mounted beneath the pushed route (established by spec 017 research §3) — but must
not appear in a shared link. A `StatefulWidget`'s `State` gives exactly that
lifetime with no extra machinery.

---

## 5. Form-state additions

One new field on each of three existing freezed states (research §6):

| State | New field | Set by | Read by |
|---|---|---|---|
| `WarehouseFormState` | `int? originalFacilityId` | `loadForEdit` | `_invalidateCaches` |
| `CashDrawerFormState` | `int? originalFacilityId` | `loadForEdit` | `_invalidateCaches` |
| `PointSaleFormState` | `int? originalFacilityId` | `loadForEdit` | `_invalidateCaches` |

`facilitySelected` must **not** touch it — that is the whole point. On update,
`_invalidateCaches` invalidates the current facility and, when
`originalFacilityId != facilityId`, the original one too, so a moved record
disappears from its old card.

---

## 6. Relationship notes

```
Facility 1 ──< Warehouse
         1 ──< CashDrawer
         1 ──< PointSale >── 1 Warehouse
```

The point-of-sale → warehouse edge is the only non-tree edge. mbe-api constrains
that warehouse to the same facility on write (research §3), so in current data the
graph *is* a tree; the cross-facility case is legacy-only and is surfaced with a
badge rather than modeled structurally.

A point of sale is nested under the facility named by its **own** `facilityId`,
never under its warehouse's facility. It therefore appears exactly once in the
tree.
