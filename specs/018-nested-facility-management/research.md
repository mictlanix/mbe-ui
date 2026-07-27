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
pop in during scroll.

**Status: corrected during implementation (2026-07-26).** The card list is
`SingleChildScrollView` wrapping a plain `Column` — **not** `ListView(children:
[...])`, despite an earlier version of this document naming both as equally safe.
They are not. `ListView` — even given a literal `List<Widget>` rather than a
builder callback — still renders through Flutter's sliver viewport protocol
(`SliverList`/`RenderSliverList`), which only materializes `Element`s for children
within the visible area plus a small cache extent. A `ref.watch()` inside an
off-screen card's `build()` simply never runs, for exactly the same underlying
reason `ListView.builder` was ruled out.

This was caught by a widget test, not by inspection: with two facilities on
screen, expanding the first grew it tall enough to push the second past the
default cache extent, and the second card's `FacilityCard` silently unmounted —
`find.byKey` for its content returned zero matches with no error, no exception, no
warning. `Column` has no viewport concept at all; every child becomes a real
`Element` on first build regardless of size or position, which is what FR-017
actually requires. Safe here because the list is hard-bounded at the facilities
page size (20) — a large `Column` is not scored on scroll performance the way an
unbounded one would be.

**Alternatives considered**:

- *A composed `facilityHierarchyProvider(filter)` returning fully-resolved nodes.*
  Rejected: it makes per-facility invalidation impossible without refetching the
  page, and `Future.wait` over the children would make one facility's failure fail
  the whole page, contradicting FR-020.
- *Lazy loading on expand.* Rejected upstream by the requester; it also cannot
  satisfy FR-006's collapsed-card counts without a backend change.

---

## 2. The facility type rule is authoritative — fetch by type

**Decision**: A facility's type determines which child types are requested at all.
A **store** fetches warehouses, points of sale and cash drawers. A **production
site** fetches warehouses only — the other two requests are never issued, and their
sections are never rendered.

**Rationale**: This is a domain invariant supplied by the product owner: stores
have warehouses, points of sale and cash drawers; production sites have warehouses
only. FR-011 and FR-018 both follow from it directly, and the type-conditional
fetch is the natural expression of it. It also saves two requests per production
site on every page load.

**Prior position, and why it changed**: an earlier revision of this document
proposed fetching all three types uniformly and rendering a production site's extra
sections only if they came back non-empty. That was a defensive response to the
finding below, and it was overridden by the clarification above. The invariant is
the specification; the UI implements it rather than second-guessing it.

**Status: verified clean (2026-07-26).** The queries below were run by the product
owner against production data and returned no rows — no point of sale and no cash
drawer is attached to a production site. `SELECT type, COUNT(*) FROM facility
GROUP BY type` returned a single row, `type 0 → 14`: the tenant has **no
production sites at all**, so the invariant cannot currently be violated. The
production-site path is still implemented — the type is selectable in the facility
form — but it has no live data and must be verified by widget test (plan.md,
Reference-tenant reality). The invariant holds in the real dataset,
so the strict design carries no live data behind it. What follows is retained as
the reason the check was needed and as the procedure to repeat if the migration is
ever re-run.

**mbe-api does not enforce the type rule.** `app/models/core.py:78` stores `type` as a plain integer column, and
neither `app/services/point_sale_service.py` nor
`app/services/cash_drawer_service.py` validates the parent facility's type on
create or update. Because this catalog is populated by a migration from the legacy
C# monolith, a violating row is representable.

**Consequence had it been violated**: such a record would be invisible in this UI
and, once the standalone list screens are deleted, unreachable. The check below
established that no such record exists, so this is now a documented procedure
rather than an open risk:

```sql
-- FacilityType: STORE = 0, PRODUCTION_SITE = 1 (app/enums.py:18)
SELECT p.point_sale_id, p.code, f.name
  FROM point_sale p JOIN facility f ON f.facility_id = p.facility
 WHERE f.type = 1;

SELECT c.cash_drawer_id, c.code, f.name
  FROM cash_drawer c JOIN facility f ON f.facility_id = c.facility
 WHERE f.type = 1;
```

Note the predicate: `type = 1` selects production sites. `type <> 1` selects
stores and is the healthy population — an inverted first attempt at this check
returned every point of sale in the database and looked alarming for the wrong
reason.

An empty result set closes the risk permanently. A non-empty one is a data-cleanup
task for mbe-api, not a reason to reopen this design.

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

**Status: a second bug corrected during implementation (2026-07-26).**
`_invalidateCaches()` resolves each facility's type via
`facilityRepositoryProvider.get()` before it can invalidate the precise
`(facilityId, facilityType)` family member — an unavoidable extra request per
save (see "the family key needs a type" note below). The first version of this
method was called fire-and-forget (`_invalidateCaches();`, not awaited) on the
theory that the save had already succeeded and the affected card could catch up
asynchronously. That was wrong in a way a unit test caught directly: `submitUpdate`
returned — and with it the `saved: true` transition that pops the screen — before
the *second* `_invalidateFacilityChildren` call (the original facility, reached
only after awaiting the first) had even started. Only the new facility's card
ever refreshed; the original facility's card kept showing the moved record until
an unrelated reload. All nine call sites (`submitCreate`/`submitUpdate`/`delete`
× three controllers) now `await _invalidateCaches();`. The added latency is one
small GET, paid once per save, not per page render — a fair trade for FR-027
actually holding.

**The family key needs a type, which forced a design change no one had
anticipated**: `facilityChildrenControllerProvider` is keyed by `(facilityId,
FacilityType)`, not `facilityId` alone (data-model.md §3 was corrected to match).
A child form only ever holds a `facilityId` — never a type — so invalidating the
*exact* family member costs the one extra request above. The alternative,
invalidating the whole family with `ref.invalidate(facilityChildrenControllerProvider)`
(no arguments), was rejected: it refetches every currently-watched card on the
page, reintroducing precisely the up-to-60-request cost per save this family
design exists to avoid.

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
