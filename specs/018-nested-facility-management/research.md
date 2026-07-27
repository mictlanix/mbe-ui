# Phase 0 Research: Nested Facility Management

**Feature**: `018-nested-facility-management` | **Date**: 2026-07-26
**Spec**: [spec.md](./spec.md)

Every finding below was verified against the current source of `mbe-ui` or the
sibling `mbe-api` checkout, not inferred. Three of them (§2, §3, §4) change what
the implementation must do relative to a naive reading of the spec.

---

## 1. Where the hierarchy state lives

**Decision**: No composed page-level provider. Keep the existing
`facilitiesListControllerProvider(filter)` exactly as it is, add one new family
`facilityChildrenControllerProvider(facilityId)`, and have each facility card
watch its own instance. The card list is rendered **non-lazily**.

**Rationale**:

- FR-027 requires that a mutation refresh *one* facility in place. With a family
  keyed by facility id, `ref.invalidate(facilityChildrenControllerProvider(id))`
  refetches exactly that card's children — the other 19 cards on the page keep
  their cached data and do not even rebuild their futures. A page-level composed
  provider would refetch all 20 facilities × up to 3 child types on every save.
- The facilities list keeps spec 017's URL-as-source-of-truth behavior for
  search, status and page **for free**, because that provider is untouched.
- Per-facility error isolation (FR-020) is structural rather than engineered: each
  card holds its own `AsyncValue` and renders its own error/retry.

**The non-lazy detail is load-bearing, not incidental.** FR-017 requires counts to
be correct on first paint without the user expanding anything. A
`ListView.builder` only builds visible children, so off-screen cards would never
watch their provider, their children would never be requested, and counts would
pop in during scroll. The card list must therefore be a `ListView(children: [...])`
or `SingleChildScrollView` + `Column` — non-lazy by construction. This is safe
because the list is hard-bounded at the facilities page size (20).

**Alternatives considered**:

- *A composed `facilityHierarchyProvider(filter)` returning fully-resolved nodes.*
  Rejected: it makes per-facility invalidation impossible without refetching the
  page, and `Future.wait` over the children would make one facility's failure fail
  the whole page, contradicting FR-020.
- *Lazy loading on expand.* Rejected upstream by the requester; it also cannot
  satisfy FR-006's collapsed-card counts without a backend change.

---

## 2. FR-011 and FR-018 are in tension — FR-018 loses, narrowly

**The conflict**: FR-018 says child types that cannot exist for a facility's type
MUST NOT be requested. FR-011 says a production site that nonetheless *has* points
of sale or cash drawers MUST show them. You cannot know a record exists without
asking for it.

**Finding**: `mbe-api` does **not** enforce the type rule. `app/models/core.py:78`
stores `type` as a plain integer column, and neither
`app/services/point_sale_service.py` nor `app/services/cash_drawer_service.py`
validates the parent facility's type on create or update. "Production sites have
no points of sale or cash drawers" is a **UI convention over legacy semantics**,
not a database or API invariant — and this catalog is populated by a migration
from the legacy C# monolith, which is exactly where a violating row would come
from.

**Decision**: Request all three child types for **every** facility, uniformly,
regardless of type. For a production site, render the Points of Sale and Cash
Drawers sections only when they come back non-empty; when both are empty, render
the explanatory note from FR-011 instead.

**Rationale**: The cost is two extra requests per production site — a minority of
facilities — and those requests return `total: 0` immediately. The benefit is that
FR-011 becomes implementable at all, and the code has one uniform fetch path
instead of a type-conditional one. Uniformity here is both simpler and more
correct.

**Consequence for the spec**: FR-018's first clause ("child types that cannot
exist for a facility's type") is superseded by this finding. Its second clause
(types the user may not read are not requested) stands unchanged and is
implemented. Recorded here rather than silently ignored; `/speckit-tasks` should
treat FR-011 as the governing requirement.

---

## 3. The cross-facility point-of-sale badge can only ever show legacy data

**Finding**: `app/services/point_sale_service.py:71-79` defines
`_validate_warehouse_facility`, documented as *"Reject a warehouse that belongs to
a facility other than the point of sale's"*, and it is called on both create
(`:85`) and update (`:111-112`). Any point of sale written through mbe-api today
is guaranteed to draw stock from a warehouse in its own facility.

**Implication**: The "Otra instalación" badge in the design mock — which the mock
shows on real-looking data (`PVVI01` under `CASA MAESTRA` drawing from
`ZUMPANGO 1`) — describes a state the API now forbids. It can only appear on rows
migrated from the legacy monolith before that constraint existed.

**Decision**: Keep FR-009's badge. Implement it as a set-membership test against
the parent facility's own warehouses (which §7 guarantees are fully loaded), which
costs one lookup and no extra request.

**Rationale**: The data in the requester's own mock came from their real database,
so violating rows evidently exist. Silently nesting such a point of sale with no
indication that its stock comes from elsewhere would hide precisely the kind of
misconfiguration this screen exists to reveal. But it must be understood as a
**legacy-data affordance**: it will never appear for records created from this UI,
and no layout decision should be optimized around it.

**Alternative considered**: *Drop the badge as unreachable.* Rejected — the mock's
own sample data disproves "unreachable", and the check is nearly free.

---

## 4. Router renumbering — and one guard that must NOT be touched

**Decision**: Delete the three `StatefulShellBranch` entries at
`app_router.dart:216-243` and renumber the tail of `NavBranch`:

| Destination | Before | After |
|---|---|---|
| `vehicleOperators` | 13 | 13 (unchanged) |
| `warehouses` | 14 | *removed* |
| `cashDrawers` | 15 | *removed* |
| `pointsOfSale` | 16 | *removed* |
| `facilities` | 17 | **14** |
| `paymentMethodOptions` | 18 | **15** |
| `taxpayerIssuers` | 19 | **16** |

Branches 0–13 are untouched, so only three constants move.

**The guard finding**: the access guards at `app_router.dart:617-625` match on
`location.startsWith('/warehouses')`, `'/cash-drawers'` and `'/points-of-sale'`.
Because they are prefix matches, they gate the **detail** routes
(`/warehouses/:warehouseId`, `/warehouses/new`) as well as the list route. These
three clauses MUST be **kept verbatim**. Removing them alongside the list screens —
the intuitive move, and what a naive reading of "the removed list paths' guards go
away" implies — would silently strip route-level RBAC from every surviving
warehouse, cash-drawer and point-of-sale record screen, violating constitution §IV
and FR-003.

This is the single highest-risk edit in the feature and is called out in
[contracts/routes.md](./contracts/routes.md) as an explicit non-deletion.

---

## 5. Pre-selecting the parent facility on a create form

**Decision**: Add an optional `facilityId` constructor parameter to
`WarehouseDetailScreen`, `CashDrawerDetailScreen` and `PointSaleDetailScreen`,
populated by the router from a `?facility=<id>` query parameter on the `/new`
routes. In create mode the screen resolves the id to a display name via the
existing `facilityDisplayNameProvider`
(`facility_repository_impl.dart:25`) and calls the form controller's existing
`facilitySelected(id, name)`.

**Rationale**: This reuses three things that already exist — the `?view=true`
query-parameter precedent on every detail route, `facilitySelected` (already the
picker's callback), and `facilityDisplayNameProvider` (built by spec 017 for
exactly this cold-load id→label problem). No form controller signature changes.
FR-023 is satisfied because the resolution happens from the URL, so a direct link
behaves identically to an in-app navigation.

**Note**: `facilityDisplayNameProvider` returns `null` on failure rather than
throwing. The create form must still open with the id applied and the picker
showing a fallback, not block on the lookup.

---

## 6. Post-mutation invalidation needs an original-facility field

**Finding**: All three child form controllers currently call
`ref.invalidate(<entity>ListControllerProvider)` in `_invalidateCaches()`
(`warehouse_form_controller.dart:125`, `cash_drawer_form_controller.dart:125`,
`point_sale_form_controller.dart:162`). Those providers are being deleted, so all
three must be repointed.

**Decision**: `_invalidateCaches()` invalidates
`facilityChildrenControllerProvider(facilityId)` for the affected facility — and,
on an update that **moved** the record to a different facility, for the original
facility as well. This requires adding an `originalFacilityId` field to each of the
three form states, captured in `loadForEdit` and never mutated by
`facilitySelected`.

**Rationale**: Without it, moving a warehouse from facility A to facility B
refreshes B's card but leaves the warehouse still rendered under A until a full
reload — a visibly wrong tree. Invalidating the whole family instead would refetch
up to 60 requests on every save, discarding the main benefit of §1.

**Facility deletion**: `facility_form_controller.dart:189` invalidates
`facilitiesListControllerProvider` and needs no change — the facility list
provider survives. It should additionally invalidate that facility's children
instance so a deleted-then-recreated id cannot serve stale children.

---

## 7. Loading a section completely (FR-019)

**Finding**: every mbe-api list endpoint declares `limit: int = Query(20, ge=1,
le=100)` — verified on `warehouses.py:21`, `cash_drawers.py:21`,
`points_of_sale.py:22` and `facilities.py:21`. A single request therefore returns
at most 100 records, and the response carries the true `total`.

**Decision**: Request each child type with `limit: 100`. If the returned `total`
exceeds what came back, loop on `skip` until the collection is complete. No
control appears on screen and no "load more" string is added.

**Rationale**: The loop is three lines and guarantees FR-019's "no child may be
unreachable" invariant now that the standalone lists are gone. It will not execute
in practice — a facility with more than 100 warehouses is not a real
configuration — so it costs nothing at runtime. Counts are read from `total`, so a
collapsed card is correct even during the first frame of a multi-page section.

**Rejected**: asking mbe-api to raise the 100 cap. It is uniform across all ~20
list endpoints and exists to prevent unbounded responses; this catalog is not
special enough to justify an exception.

---

## 8. The three removed menu labels are reused, not orphaned

**Finding**: `warehousesMenuTitle`, `cashDrawersMenuTitle` and
`pointsOfSaleMenuTitle` are referenced only by the tear-offs at
`nav_destinations.dart:268-270`. Removing the destinations would orphan them.

**Decision**: Reuse the same three keys as the child **section headers** inside the
expanded card ("Almacenes", "Cajas", "Puntos de Venta" — already exactly the
labels the mock uses). No keys are deleted and no synonyms are introduced.

**New keys required**: expand-all / collapse-all labels, the three empty-state
messages, the production-site note, the cross-facility badge, the three
"+ <child>" create labels, the child-load error/retry, and the compact-tier FAB
label. All added to both `app_en.arb` and `app_es.arb`.

---

## 9. Compact tier

**Decision**: One widget tree, branching on `LayoutBreakpoints.isCompact(context)`
(`core/layout/breakpoints.dart`) for density only — not two parallel screens. The
mock's two layouts differ in spacing, chevron placement, status rendering (badge
vs. dot), and where the create actions sit; the hierarchy and behavior are
identical.

**Rationale**: constitution §VI centralizes breakpoints in `core/` precisely so
features branch rather than fork. Two screens would double the RBAC and
invalidation surface for a purely presentational difference.

The compact FAB for "new facility" is the one genuinely new structural element and
is gated on the same `facilities.create` privilege as the wide-tier button.

---

## 10. Test fallout

**Deleted** (their subject ceases to exist):
`test/widget/features/catalog/warehouses_list_screen_test.dart`,
`cash_drawers_list_screen_test.dart`, `points_of_sale_list_screen_test.dart`.

**Rewritten**: `test/widget/features/catalog/facilities_list_screen_test.dart` —
the screen it covers is replaced wholesale.

**Updated**: `test/widget/core/widgets/app_navigation_test.dart` (three fewer
destinations), `test/unit/app/router/app_router_test.dart` (renumbered branches,
plus a new assertion that the three prefix guards survive — see §4),
`test/integration/facility_catalogs_flow_test.dart` and
`navigation_shell_flow_test.dart`.

**Unaffected**: `test/unit/features/repository_list_params_audit_test.dart` — the
repositories themselves are unchanged, which is what that audit reflects over. The
four `*_detail_screen_test.dart` files need additions only for the new
`facilityId` prefill parameter.
