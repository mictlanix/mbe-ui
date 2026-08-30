# Phase 1 Data Model: CRUD UI Refinements

**Feature**: 035-crud-ui-refinements

This feature introduces **no new persisted entities and no API schema changes**. What it does
change is the shape of three pieces of client-side view state, and one design-token surface.
Those are modelled here because they are what the tasks will actually edit.

---

## 1. Status facet value (changed)

The URL-level representation of a list's status filter.

| State | URL | Meaning | Today | After |
|---|---|---|---|---|
| Default | `status` absent | every record | every record | **Active only** |
| Explicit all | `status=all` | every record | *(not representable)* | every record |
| Explicit one | `status=active` \| `inactive` \| `archived` | that state | that state | that state |

**Rules**

- Absent MUST decode to `EntityStatus.active` (FR-001, FR-002).
- `all` MUST decode to "no status filter" and MUST survive paging, sorting and reload (FR-004).
- An unrecognised value MUST fall back to the default rather than erroring, matching the existing
  `byNameOrNull` tolerance.
- `ListQuery.isFiltered` MUST report `true` when the default is in force, so the filters badge
  counts it (FR-006).

**Owners**: `EntityStatusFilterChips` (`core/widgets/entity_status_controls.dart`) writes it; a
shared decode helper reads it; the ten list controllers consume the decoded value.

**Not applicable to**: the POS sales, sales orders and cash sessions facets, which keep `null` =
every state exactly as today (FR-007).

---

## 2. Record surface mode (relocated, not redefined)

The existing create / view / edit triple, moving from a route to a panel.

| Mode | Opened by | Fields | Actions |
|---|---|---|---|
| `create` | the list's New action | editable | Save |
| `view` | a row click | disabled | Edit (if update privilege) |
| `edit` | the view surface's Edit control, or the row's Edit icon | editable | Save, Delete (if delete privilege) |

**Rules**

- Transitions are unchanged: `view → edit` via the Edit control; `create|edit → closed` on save;
  `edit → closed` on delete.
- `RecordFormMode` and `RecordFormActions` already model all three and already gate Delete to
  `edit` and the Edit control to `view`; this feature reuses them unmodified.
- What was `?view=true` on a route becomes a constructor argument on the panel's content
  (FR-027).

---

## 3. Panel dirty state (new)

Derived, not stored.

| Field | Type | Source |
|---|---|---|
| `snapshot` | the entity's freezed form state | captured once, after load completes |
| `isDirty` | `bool` | `currentState != snapshot` |

**Rules**

- The snapshot MUST be taken after loading finishes, never before, or every edit-mode panel opens
  already dirty.
- All three dismissal paths — barrier tap, Escape, close button — MUST consult `isDirty` (FR-032).
- Save and delete close the panel without consulting it.

---

## 4. Design tokens (extended)

| Token | Status | Value | Consumers |
|---|---|---|---|
| `cardTheme.clipBehavior` | new | `Clip.antiAlias` | every `Card`, incl. both table branches |
| `cardTheme.shape.side` | new | `outlineVariant`, 1px | every `Card`, incl. `FacilityCard` |
| hairline side helper | new | same colour/width, as a `BorderSide` | the three `Container`-based facility child rows |
| `spacing.cardPadding` | existing | 16 / 16 / 24 / 24 | now also the filter bar's horizontal inset |
| `shapes.sm` / `shapes.md` | existing | 8 / 12 | replace `circular(6)` and `circular(12)` literals |

**Rule**: no consumer may pass its own value for any of these (FR-021).
