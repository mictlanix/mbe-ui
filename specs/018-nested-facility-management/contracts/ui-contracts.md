# Contract: Facility Hierarchy UI

**Feature**: `018-nested-facility-management`

Widget structure, keys, RBAC gating and l10n for the new Facilities screen.
Structure and density come from
`artifacts/facilities_improvements/{desktop,mobile}_layout.html`; **all** color,
elevation and typography come from `Theme.of(context)` (FR-030) — no hex literal
from the mock may appear in Dart.

---

## 1. Widget tree

```
FacilitiesListScreen                       (rewritten, same file)
├── CatalogFilterBar                       (reused)
│   ├── CatalogSearchBar                   key: facilities_search_field
│   ├── actions: [ExpandAllButton, NewFacilityButton]
│   └── filters: [FilterSheetButton]       key: facilities_filter_button
├── CatalogListStateView<FacilityListItem> (reused — loading/empty/error/retry)
│   └── non-lazy card list                 (research §1 — NOT ListView.builder)
│       └── FacilityCard × page size
└── pagination footer                      (reused)

FacilityCard                               presentation/widgets/facility_card.dart
├── header (whole-row tap → view)          key: facility_card_<facilityId>
│   ├── chevron · type icon · name · code chip · type label
│   ├── counts: warehouses / POS / cash drawers
│   ├── EntityStatusCell                   (reused)
│   └── edit action                        (CatalogAction.edit icon)
└── body (when expanded)
    ├── FacilityChildSection × 1–3         widgets/facility_child_section.dart
    │   ├── header: label · count · divider · create action
    │   └── FacilityChildRow × n           widgets/facility_child_row.dart
    │       or empty placeholder
    ├── production-site note               (FR-011, when applicable)
    └── compact tier only: create-action chip row
```

Three new files under `lib/features/catalog/presentation/widgets/`, matching the
existing convention there (`merge_*.dart`).

---

## 2. Widget keys

Required for widget tests; `<id>` is the entity's integer id.

| Key | Element |
|---|---|
| `facility_card_<id>` | Card root |
| `facility_card_toggle_<id>` | Expand/collapse hit area |
| `facility_edit_<id>` | Facility edit action |
| `facility_section_warehouses_<id>` | Warehouses section |
| `facility_section_points_of_sale_<id>` | POS section |
| `facility_section_cash_drawers_<id>` | Cash Drawers section |
| `facility_create_warehouse_<id>` | "+ Almacén" |
| `facility_create_point_sale_<id>` | "+ Punto de venta" |
| `facility_create_cash_drawer_<id>` | "+ Caja" |
| `warehouse_row_<id>` / `point_sale_row_<id>` / `cash_drawer_row_<id>` | Child rows |
| `facility_children_retry_<id>` | Per-card retry (FR-020) |
| `facilities_expand_all` | Toolbar toggle |
| `new_facility_button` | Wide-tier create (existing key, kept) |
| `new_facility_fab` | Compact-tier FAB |

---

## 3. Navigation from the tree

| Trigger | Destination |
|---|---|
| Facility header tap | `/facilities/<id>?view=true` |
| Facility edit | `/facilities/<id>` |
| Warehouse row tap | `/warehouses/<id>?view=true` |
| Warehouse edit | `/warehouses/<id>` |
| "+ Almacén" | `/warehouses/new?facility=<facilityId>` |
| POS row tap / edit / create | `/points-of-sale/<id>?view=true` · `/points-of-sale/<id>` · `/points-of-sale/new?facility=<facilityId>` |
| Cash drawer row tap / edit / create | `/cash-drawers/<id>?view=true` · `/cash-drawers/<id>` · `/cash-drawers/new?facility=<facilityId>` |

All use `context.push` so the list screen stays mounted beneath — which is what
preserves expansion state and page position on return (data-model §4).

**Delete appears nowhere in this tree** (FR-026). It stays on each record's
detail screen via `RecordFormActions`.

---

## 4. RBAC gating

Hidden, never disabled (constitution §VI, FR-028).

| Element | Requires |
|---|---|
| New facility button / FAB | `facilities:create` |
| Facility edit action | `facilities:update` |
| Warehouses section rendered at all | `warehouses:read` |
| "+ Almacén" | `warehouses:create` |
| Warehouse row edit action | `warehouses:update` |
| …same pattern for `pointsOfSale` and `cashDrawers` | |

A section the user cannot read is **absent**, and its count is absent from the
collapsed header (FR-029) — not shown as zero, which would assert a falsehood.

Row tap → read-only view is available to anyone who can read that object, i.e.
anyone who can see the row at all.

---

## 5. Per-card states

| Condition | Rendering |
|---|---|
| Children loading | Card header renders; counts show a placeholder, not `0` |
| Children loaded, section empty, readable | Dashed-border empty placeholder naming the type (FR-010) |
| Section not readable | Section omitted entirely |
| Children failed | Inline message + retry (`facility_children_retry_<id>`); other cards unaffected (FR-020) |
| Production site, no POS and no cash drawers | Warehouses section + FR-011 note |
| Production site **with** POS or cash drawers | Those sections rendered; note suppressed (research §2) |
| POS whose warehouse is not in this facility | Cross-facility badge on the row (FR-009, legacy data only — research §3) |

Counts must never render as `0` while loading; a wrong count is worse than no
count on a screen whose purpose is spotting misconfiguration.

---

## 6. Compact tier

Branch on `LayoutBreakpoints.isCompact(context)` within the same widgets
(research §9):

| | Wide | Compact |
|---|---|---|
| Chevron | Leading | Trailing |
| Status | Badge with label | Colored dot |
| Icon tile | 42 px | 40 px |
| Child metadata | One row | Wrapped chips |
| Create actions | In each section header | Chip row at end of expanded body |
| Create facility | Toolbar `FilledButton` | FAB (`new_facility_fab`) |
| Touch targets | Default | ≥ 44 px |

No horizontal scrolling at any width; long names wrap or ellipsize **with a
tooltip**, and code, status and name are never truncated (FR-033).

---

## 7. Localization

**Reused as section headers** (research §8): `warehousesMenuTitle`,
`cashDrawersMenuTitle`, `pointsOfSaleMenuTitle`.

**New keys**, both `app_en.arb` and `app_es.arb`:

| Key | es-MX |
|---|---|
| `facilitiesExpandAll` | Expandir todo |
| `facilitiesCollapseAll` | Contraer todo |
| `noWarehousesInFacility` | Sin almacenes registrados. |
| `noPointsOfSaleInFacility` | Sin puntos de venta. |
| `noCashDrawersInFacility` | Sin cajas registradas. |
| `productionSiteChildrenNote` | Los sitios de producción solo administran almacenes: no tienen puntos de venta ni cajas. |
| `pointSaleForeignFacilityBadge` | Otra instalación |
| `newWarehouseInFacility` | Almacén |
| `newPointSaleInFacility` | Punto de venta |
| `newCashDrawerInFacility` | Caja |
| `facilityChildrenLoadFailed` | No se pudieron cargar los elementos de esta instalación. |

The search placeholder keeps the existing `facilitiesSearchLabel` and MUST NOT be
reworded to promise child search (FR-014).
