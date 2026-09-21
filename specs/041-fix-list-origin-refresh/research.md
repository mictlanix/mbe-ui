# Phase 0 Research: Fix List Origin Filtering and Cash Session List Refresh

**Feature**: `041-fix-list-origin-refresh` | **Date**: 2026-09-20

All findings below were verified against the checked-in sources on this branch,
not inferred from spec 039's own forward-looking notes. Line numbers are as of
2026-09-20.

---

## R1 — Exclusion, not inclusion: how the backfill question dissolves

**Decision**: Both lists filter with the server's `exclude_origin` parameter,
never with `origin`. The POS list sends `exclude_origin=backOffice`; the
"Pedidos" list sends `exclude_origin=pointOfSale`. Neither list ever sends
`origin`.

**Rationale**: Spec 039 deferred this facet (OS-2) because an inclusive filter
forces a bad choice: `origin=pointOfSale` on the register's list would drop
every sale raised before the field existed, and admitting them all would drag
every historical register sale into the back-office list. mbe-api resolved this
upstream when it shipped the field. The generated client's own doc comment for
the parameter states it outright
(`lib/generated/openapi/lib/src/api/sales_orders_api.dart:598`):

> Every order except this workflow's, including orders that recorded no origin —
> which is every order raised before #209. The register's own list is the caller
> this exists for: asking for its own workflow instead would drop its whole
> history.

Exclusion keeps unrecorded-origin orders in *both* result sets, which is exactly
FR-005 and SC-003, and it preserves spec 039's SC-012 promise that recording
origin changes nothing observable about orders that predate it. No backfill is
required, and none should be performed.

**Alternatives considered**:

- *Inclusive `origin=` filter* — rejected: hides all pre-#209 history from
  whichever list applies it. This is the exact failure spec 039 refused to pick.
- *Client-side filtering of a full page* — rejected outright: it would corrupt
  pagination and totals (the server returns `ListResponseSalesOrderSummary.total`
  for the unfiltered query), and it would scale with the dataset.
- *Backfilling origin server-side, then filtering inclusively* — rejected: it is
  an mbe-api data-migration decision, out of this repo's remit (constitution
  §III repo boundary), and unnecessary given `exclude_origin` exists.

---

## R2 — Origin reaches the rows with no backend change

**Decision**: Add `SaleOrigin? origin` to `OpenSale` and map it in
`OpenSale.fromResponse`. No codegen re-run against mbe-api is needed.

**Rationale**: The list call returns `ListResponseSalesOrderSummary`, whose
items are `SalesOrderSummary` — and that generated model already carries the
field (`lib/generated/openapi/lib/src/model/sales_order_summary.dart:72-73`),
with a doc comment that matches the domain enum's own reading of `null`:

> Which workflow raised the order: 0 the point of sale, 1 the back office. Null
> means it was never recorded — not "point of sale". Set at creation; it cannot
> be changed afterwards.

`OpenSale` (`lib/features/sales/domain/entities/open_sale.dart:11-49`) simply
never mapped it. The domain enum and both converters already exist
(`sale_origin.dart:15-38`, including `fromApi` returning `null` for an absent
value and `toApi()` for the outbound direction), so this is one nullable field,
one mapping line, one import, and a `freezed` regeneration. Every existing
construction site stays valid because the field is optional.

**Alternatives considered**:

- *A second fetch per row to get `Sale.origin`* — rejected as absurd; the
  projection already has it.
- *Deriving origin from an existing column (register, salesperson)* — rejected:
  spec 039 A15 establishes that every order carries a register including
  back-office ones, so it is not a discriminator. Guessing is exactly what the
  recorded field exists to stop.

---

## R3 — Filter control shape: a plain on/off chip, not tri-state

**Decision**: One `FilterChip` per screen in the existing filter drawer,
expressing a single on/off state ("hide the other workflow's orders"). Not a
tri-state cycling control, and not a `ChoiceChip` group.

**Rationale**: This project has a standing preference for tri-state controls
over on/off toggles — but it is scoped to *nullable boolean* fields, where
`null`/`true`/`false` are three states the backend genuinely supports and a
two-state chip would silently drop one (the correction that established the
preference was `ProductsListScreen`'s `stockable`/`salable`/`purchasable`
chips). That preference explicitly exempts fields where only two states are
meaningful, naming `ProductFilter.deactivated`'s "show inactive" chip as the
on/off case.

The origin facet is the exempt kind. Per screen, the filter field holds either
`null` or one fixed value: the POS list has no meaningful use for
"exclude pointOfSale", and the back-office list none for
"exclude backOffice". A third state would have to be "show only unrecorded",
which nobody asked for and which FR-005 forbids either list from making
reachable. The spec's own Edge Cases section already fixes this shape:

> A list's origin filter is a single on/off toggle per screen … there is no
> control to hide unrecorded-origin orders, and no control to hide both origins
> at once.

**Alternatives considered**:

- *Tri-state cycling chip* — rejected per the above; it would offer a state the
  spec forbids.
- *A `ChoiceChip` group with an explicit "All" chip*, mirroring the status facet
  — rejected as heavier than the data: status has six values, origin has one
  meaningful alternative, and a two-chip "All / Only mine" group says the same
  thing as one chip while taking twice the drawer space.
- *Reusing `_TriStateFilterChip`* — moot given the above, but worth recording
  that it exists in **three** duplicated private copies
  (`employees_list_screen.dart:241-276`, `products_list_screen.dart:288`,
  `advanced_search_screen.dart:415`). Promoting it to `core/widgets/` is a real
  cleanup, but it is **out of scope here** — this feature does not use it, and
  hoisting it would be unrelated churn (CLAUDE.md §3).

---

## R4 — The facet is URL state, and it must be registered in four places

**Decision**: The origin facet is a URL query facet on both screens, decoded in
each filter's `fromQuery`, exactly as `status` is.

**Rationale**: Both lists are URL-driven: the family key is the whole filter
value, built by `PosSalesFilter.fromQuery(query, today:)`
(`pos_sales_list_controller.dart:26-64`) and
`SalesOrdersFilter.fromQuery(query, today:, isAdministrator:)`
(`orders/sales_orders_list_controller.dart:34-75`), and every drawer control
navigates with `context.go(updated.toUri(path).toString())`. A facet that did
not round-trip through the URL would be lost on any other filter change.

**The four registration points** (missing one is the likely defect, so tasks
must name each):

1. `fromQuery` — decode the facet into the filter field.
2. `activeFilterCount` in the `…FilterBadge` extension — the drawer icon's badge
   (`pos_sales_list_controller.dart:118-121`,
   `sales_orders_list_controller.dart:116-122`).
3. The screen's `onClearAll` — which lists facets explicitly
   (`pos_sales_list_screen.dart:147-153`,
   `sales_orders_list_screen.dart:172-180`).
4. The screen's `isFiltered`/empty-state expression — POS spells it out longhand
   (`pos_sales_list_screen.dart:172-175`); Orders delegates to
   `hasActiveFilters` (`sales_orders_list_screen.dart:197-198`).

Two invariants to copy from the status facet: clear with
`query.withFacet(key, null)`, and carry `.copyWith(pageIndex: 0)` on **every**
facet change, so narrowing the result set cannot strand the user on a page that
no longer exists.

**Alternatives considered**:

- *Holding the facet in a separate provider outside the URL* — rejected: breaks
  deep-linking and back-button behaviour the rest of the filter row relies on,
  and would desynchronize the family key from the visible drawer state.

---

## R5 — Per-row indicator: a chip column, sized and then proven

**Decision**: A new `SaleOriginChip` — a thin wrapper over the shared
`StatusChip<T>` (`lib/core/widgets/status_chip.dart:14-42`), mirroring
`PosSaleStatusChip` (`presentation/widgets/pos_sale_status_chip.dart:24-49`) —
rendered in its own narrow column immediately after Status, on both lists, for
all three states.

**Rationale**: FR-006 asks for all three states to be legible per row, which
rules out any scheme that renders nothing for one of them. Both tables today are
6 columns (S, M, L, S, S, S) plus a `fixedWidth: 150` action column, and neither
passes `minWidth` — so `DataTableView` shrinks to fit rather than scrolling
(`data_table_view.dart:111-119`). Adding a 7th narrow column is therefore a real
width risk rather than a free change, and `DataTableColumn` offers `fixedWidth`
for exactly this kind of short, bounded content (`data_table_view.dart:60-73`).

Because constitution VI bans horizontal scroll and constitution V requires the
largest text-size level to be *verified rather than assumed*, this decision ships
with a test obligation, not a hope: a widget test asserting no overflow at a
representative desktop width and at the largest of the four text-size levels. If
that test cannot be made to pass at a sane column width, the documented fallback
is an icon-only chip (glyph + tooltip, no text label) in the same column — which
preserves all three states and the column header while spending roughly a third
of the width.

**Alternatives considered**:

- *An icon riding inside the Reference cell* — rejected: it conflates two facts
  in one column, leaves the table with no header naming the concept, and hides a
  filterable dimension behind a tooltip.
- *Marking only the "foreign" rows and leaving same-workflow rows blank* —
  genuinely tempting, since a filtered POS list would otherwise repeat
  "Punto de venta" down the whole column. Rejected because a blank cell becomes
  ambiguous between "same workflow as this list" and "origin unrecorded", which
  is precisely the distinction FR-006 exists to make legible. Recorded here
  because it is the obvious refinement if the column later proves noisy in use.
- *A new column only on the unfiltered view* — rejected: a table whose column
  set changes under a filter is worse than either fixed choice.

---

## R6 — The cash-session refresh seam is the form controllers, not the sheet

**Decision**: Add `ref.invalidate(cashSessionsListControllerProvider)` — the
bare family, no argument — immediately beside the existing
`ref.invalidate(currentSessionControllerProvider)` in **both**
`OpenSessionFormController.submit()`
(`open_session_form_controller.dart:104-143`) and
`CloseSessionFormController.submit()`
(`close_session_form_controller.dart:98-140`, invalidate at :136).

**Rationale**: Three findings overturned the initial hypothesis that this was a
sheet-dismiss problem, and each one matters:

1. **The sheet is not awaited.** `_ShiftToolbarAction.openSheet`
   (`cash_sessions_screen.dart:70-74`) is an arrow-bodied `void` closure that
   discards `showAppSideSheet`'s `Future<void>`. There is no post-dismiss seam
   there today.
2. **The close path does not go through that sheet at all.** There is no
   `_CloseForm` on this screen. `_OpenShiftCard`'s close button
   (`cash_sessions_screen.dart:385-393`) pops the sheet and
   `context.push`es to the session's own detail screen, where
   `cash_session_detail_screen.dart` `_submit` (~:284-308) performs the close. A
   sheet-dismiss fix would have fixed open and silently left close broken — the
   more visible half of the reported bug.
3. **`showAppSideSheet` documents itself against this use**
   (`lib/core/widgets/app_side_sheet.dart:20-25`): it returns nothing, and
   callers needing to react are told to read provider state instead. No caller
   in `lib/` awaits it.

Meanwhile "the form controller invalidates the whole list family after a
successful write" is already this repo's majority pattern, with eight
precedents: `supplier_form_controller.dart:179,241,279`,
`facility_form_controller.dart:191`, `label_form_controller.dart:94`,
`vehicle_form_controller.dart:133`, `expense_form_controller.dart:91`,
`taxpayer_recipient_form_controller.dart:174,234,272`, and
`users_controller.dart:292`. The two cash-session controllers are the outliers.
Fixing them at the source repairs both paths regardless of which screen or sheet
hosts the form, and makes FR-010 true for free — a cancelled form never reaches
`submit()`, so it never invalidates.

**Validity of the bare-family invalidation**: confirmed against the pinned
versions, not assumed. `riverpod 2.6.1` declares
`void invalidate(ProviderOrFamily provider)`, and the generated
`cashSessionsListControllerProvider` is a `CashSessionsListControllerFamily
extends Family<…>` (`cash_sessions_list_controller.g.dart:45,51`). Invalidating
the family invalidates every instance — which is what this fix needs, since the
form controller has no idea what date/status filter the history list is
currently keyed on. This also satisfies FR-011: each instance re-runs under its
own existing filter argument rather than being reset.

**A stale comment to delete, not preserve**: `cash_sessions_screen.dart:176-184`
asserts that "the history list and the toolbar action are already refreshing by
the time this pops". It is true of the toolbar action and false of the history
list, and it is very likely why the bug shipped. It must be corrected in the
same change, or the next reader re-derives the same wrong conclusion.

**Alternatives considered**:

- *`await showAppSideSheet(...)` then invalidate* — rejected on all three counts
  above; fixes at most half the bug and contradicts the helper's own contract.
- *Converting the list controller to a stream/polling* — rejected: constitution
  VII (online-only, no local sync machinery) and far beyond the reported
  problem, which is a missing invalidation, not a missing live feed.
- *Invalidating a specific family instance* — rejected: the form controller
  cannot know the list's current filter, and guessing it would refresh the wrong
  instance.

---

## R7 — Vocabulary and iconography for origin

**Decision**: Reuse spec 039's established wording for the point-of-sale side;
coin the back-office and unrecorded labels here, in both locales.

**Rationale**: Exactly one place in the app makes origin visible today —
`_ForeignOrderNotice` in `orders/order_workspace_screen.dart:328-365`, which
uses `Icons.point_of_sale_outlined` and the string
`salesOrderForeignOrderMessage` ("Se originó en el punto de venta.",
`app_es.arb:881-882`). So "punto de venta" is settled vocabulary and
`Icons.point_of_sale_outlined` is the settled glyph. There is no existing
back-office label or icon to inherit, and no existing wording for the unrecorded
state — those are new strings, and the spec's own framing ("origin was never
recorded", deliberately *not* a synonym for point of sale) should govern the
copy so the third state is never mistaken for a default.

Key naming follows the area convention: `posSales*` for the POS list,
`salesOrders*` for the back-office list, `<prefix>Column<Name>` for headers and
`<prefix>…FilterLabel` for facets. New strings go to `app_en.arb` (with `"@key"`
metadata stubs) and `app_es.arb` (values only), then regeneration.

---

## R8 — Test strategy against existing coverage

**Decision**: Extend the suites that already cover these three screens rather
than adding parallel ones; add one genuinely new kind of assertion (a re-fetch
count) for fix 3.

**Rationale and existing coverage**:

- **Unit**: `pos_sales_filter_test.dart` and `sales_orders_filter_test.dart`
  already cover `fromQuery` decoding and badge counts — the natural home for the
  facet's four registration points (R4). Repository parameter forwarding belongs
  with the existing repository impl tests.
- **Widget**: `pos_sales_list_screen_test.dart` (485 lines) already covers the
  filter drawer badge and empty states; `sales_orders_filters_test.dart` covers
  the orders drawer; `cash_sessions_screen_test.dart` (526 lines) already covers
  the shift sheet's states. All share the `mocktail` +
  `ProviderContainer(overrides:)` + `UncontrolledProviderScope` pattern
  (`cash_sessions_screen_test.dart:28-31, 95-190`).
- **The re-fetch assertion**: because the tests hold the `ProviderContainer` and
  stub the repository with `mocktail`, a regression test for fix 3 can assert
  `verify(() => cashSessionRepository.list(...)).called(2)` — once for the
  initial load, once after the write. This is the only assertion that actually
  proves the bug is fixed; asserting on rendered rows alone would pass against a
  fixture that never changes. The existing harness already stubs a
  `/sales/cash-sessions/:id` stand-in route, so the close path (which navigates
  there, per R6) is testable without the real detail screen.
- **Integration**: `pos_sales_list_flow_test.dart` and `sales_orders_flow_test.dart`
  (`MBE_POS_*`) can assert the live `exclude_origin` round trip;
  `cash_session_flow_test.dart` (`MBE_CASH_SESSION_*`) already walks
  open → refuse-second → close. Credentials are compile-time
  `String.fromEnvironment` with a `_canRun` guard that skips rather than fails;
  invocation is `flutter test --dart-define-from-file=.env`, and the
  account/privilege contract is `test/integration/TEST_ACCOUNTS.md`. Note the
  `MBE_POS_*` account requires an already-open cash session for some suites,
  while `sales_orders_flow_test.dart` explicitly does not.

**Alternatives considered**:

- *Golden tests for the new chip* — rejected: the existing golden suite covers
  leaf POS widgets, and a chip that wraps the already-goldened `StatusChip` adds
  maintenance without new signal. The overflow risk (R5) is better caught by an
  explicit layout assertion than by a golden diff.
