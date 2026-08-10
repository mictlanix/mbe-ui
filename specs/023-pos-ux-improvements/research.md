# Phase 0 — Research: POS Sales List, Full-Width Workspace, Capture Polish

Every decision below is anchored in code that already exists in this
repository, in spec 020's own recorded findings, or in the constitution. Where a
fact could only be established against a live backend, it is called out as such
and given a verification task rather than assumed.

---

## R1 — Route shape: the list keeps the branch, the workspace becomes a sibling

**Decision.** `/sales/pos` keeps its `StatefulShellBranch` (index 18) and now
builds `PosSalesListScreen(query: ListQuery.fromUri(state.uri))`. Two new
**top-level** routes are added next to the other record routes:
`/sales/pos/new` and `/sales/pos/:saleId`, both building `PosWorkspaceScreen`.
The `_routeGate` entry stays `location.startsWith('/sales/pos')` →
`(pos, read)`, so all three are covered by the one existing rule.

**Rationale.** `app_router.dart` already splits exactly this way: shell branches
for list screens, top-level siblings for record screens, with the comment
"Detail/form/merge and /auth/* routes are top-level siblings below — they render
full-screen (no rail)". The workspace needs precisely that treatment, and
`startsWith` gating means no new privilege wiring. Keeping the branch (rather
than renumbering) follows the standing "append, don't renumber" rule recorded in
that file and in `nav_destinations.dart`.

**Alternatives rejected.** (a) Nesting the workspace *inside* the branch — it
would keep the rail, which is the whole problem. (b) A new branch for the
workspace — branches are navigation destinations; the workspace is not one.

## R2 — Route-driven sale loading, and why `/new` rewrites its own URL

**Decision.** `PosWorkspaceScreen` takes a nullable `saleId`. On first mount it
dispatches exactly once: `saleId == null` → `PosSaleController.startNew()`;
otherwise → `load(saleId)`. The dispatch is guarded by a stored
"already-dispatched for this id" field, the same shape `_PosBodyState._syncedSaleId`
already uses, so a rebuild never re-issues it. As soon as a `/new` sale exists,
the screen calls `GoRouter.replace('/sales/pos/<id>')`.

**Rationale.** `POST /sales-orders` creates a real record — spec 020 measured 39
accumulated empty drafts on a live register before lazy creation was introduced,
and its `PosSaleController` docstring records that. A `/new` URL that survives a
browser reload would repeat that mistake once per reload. Rewriting to the real
id makes reload resume the same sale, makes Back land on the list rather than on
a second `/new`, and costs one `replace` call.

**Note on `startNew` vs lazy open.** Spec 020 deliberately does *not* create the
sale on entry — `ensureOpen()` is called by the first action that needs one. That
lazy behaviour is preserved: `/sales/pos/new` mounts the workspace with no sale
(exactly today's `sale == null` state, which `CaptureStep` already renders), and
the URL rewrite happens when the first action opens the sale. `startNew()` is
therefore *not* dispatched on mount; the explicit "Nueva venta" action on the
list navigates to `/sales/pos/new`, and nothing is written server-side until the
cashier acts. This keeps FR-008 and spec 020's anti-empty-draft rule compatible.

**Alternatives rejected.** Creating the sale eagerly on `/new` — simpler URL
handling, but reintroduces the empty-draft accumulation spec 020 fixed.

## R3 — What the list asks the backend for

**Decision.** The list calls `GET /sales-orders` through a new repository method
`listSales(...)` with: `pointSale` (the cashier's register), `status` (optional
facet), `dateFrom`/`dateTo` (the range, defaulting to today), `search`
(optional), `skip`/`limit` (page). The generated client already exposes every
one of these (`listSalesOrdersApiV1SalesOrdersGet`: `mine`, `customer`,
`salesperson`, `status`, `dateFrom`, `dateTo`, `facility`, `pointSale`,
`search`, `skip`, `limit`).

Two behaviours of that endpoint are already established by spec 020 and must be
carried over rather than rediscovered:

1. **`status` is not exclusive.** Spec 020's `openSalesSelectorController`
   documents, from live verification, that `status=completed` answers with paid
   sales too ("one page came back 80 `paid` to 20 `completed`"). The list must
   therefore narrow each page client-side to the status actually asked for, or
   the status facet will lie. This also means the reported total for a filtered
   status is the server's, which may exceed what the page shows — the list
   reports the server total and the narrowing is visible only as a shorter page.
   *Recorded as a known wart, not a defect to fix here.*
2. **`date_from` serialization is a landmine.** The same file documents that
   built_value's serializer throws on a local `DateTime`, while mbe-api reads the
   value as local wall-clock and ignores the offset — so the only correct value
   is `DateTime.utc(y, m, d)` of the *local* date. The list reuses that helper
   verbatim rather than writing a second one; it is extracted so both callers
   share it.

**Unverified against a live backend**: what `search` matches (folio? customer
name? both?) and whether `date_to` is inclusive of its day. Both get a
verification task in the live-backend integration test rather than an assumption
here; the UI degrades safely either way (a search that matches nothing shows the
empty state, and the range is chosen by a date picker whose upper bound the
cashier can extend).

**Alternatives rejected.** Reusing `listOpen` with extra parameters — it is
shaped for the selector's three fixed status queries and its `OpenSale` row type;
a separate method keeps the selector's contract untouched.

## R4 — Deciding whether a row can be edited (and what a row click does)

This is the one genuinely hard design question in the feature, and it collides
with the constitution.

**The cost problem.** "Still workable" is cheap for two of the three cases and
expensive for the third. `SalesOrderSummary` carries `status`, `total` and
`balance`, so *draft* (workable) and *cancelled* (not) and *completed with
balance > 0* (workable) are all decidable from the row itself. But **paid**
sales are workable only when they are delivery sales whose distribution is
unfinished — and spec 020 already established that answering that costs a
`getById` plus a delivery-orders call plus a facility-address lookup *per sale*.
Doing that per row would put dozens of round trips behind one page of history.

**Decision.** The list decides workability in two layers:

- **From the row alone**: `draft` → workable. `cancelled` → not.
  `completed`/`paid` with a non-zero balance → workable (it owes money).
- **For zero-balance paid sales**: workable only if the sale's id appears in the
  register's open-sales set, which `openSalesSelectorControllerProvider` already
  computes for the current trading day and which is the single source of truth
  spec 020 FR-058 defined. That provider is watched by the workspace anyway.
  Outside the current trading day, a zero-balance paid sale is treated as
  finished — a delivery left undistributed across a day boundary is a
  back-office matter, which is the same reasoning spec 020 used to bound the
  selector to today.

This adds **zero** per-row requests: the expensive set is computed once, for
today, by a provider that already exists.

**The constitutional collision.** Constitution §VI requires that clicking a row
anywhere outside the Edit icon opens that record's detail screen **read-only** —
"a stray click MUST NOT risk an unintended edit". The spec as approved put "no
read-only sale viewer" out of scope, which would leave the new list with no row
click at all.

**Decision.** No new screen is added *and* the rule is satisfied: a row click
opens `/sales/pos/:saleId`, and the workspace renders read-only when the sale is
not editable. That capability already ships — `Sale.isEditable` is false for
anything past draft, `CaptureStep` already passes `enabled: false` throughout and
shows `posSaleReadOnlyBanner`, and `SaleLineRow`/`SaleLineCard` already render
every control inert (spec 020 FR-041). So:

| Row state | Edit icon | Row click |
|---|---|---|
| draft | shown → workspace, editable | workspace, editable (it *is* the same screen) |
| completed / paid, still workable | shown → workspace at its step | same, read-only where the step is |
| finished (paid, distributed) | absent | workspace, read-only |
| cancelled | absent | blocked notice + way back |
| a user without `salesOrders` update | absent | workspace, read-only |

**Spec amendment this forces** (recorded here, applied to `spec.md`): FR-019's
"cannot be worked on → explain and offer a way back" narrows to *unknown,
cancelled, or another register's* sale. A **finished** sale opens read-only
instead of being refused, and the Out of Scope line "no read-only sale viewer is
added" is restated as "no *new* read-only screen is added — the workspace's
existing read-only rendering is what a finished sale opens into".

**Alternatives rejected.** (a) A separate read-only sale detail screen — a whole
screen duplicating what the workspace already renders read-only. (b) No row
click — a plain constitution violation. (c) Per-row distribution checks — the
round-trip cost above.

## R5 — Which step a resumed sale opens on: nothing new is needed

**Decision.** The list does not compute the step. It navigates to
`/sales/pos/:saleId`; the workspace loads the sale and its existing
`_syncStepTo` → `resumeTargetFor(sale, facilityAddressId: …)` puts the step
machine where the sale belongs, exactly as it does today when the selector
resumes a sale.

**Rationale.** `resumeTargetFor` needs a full `Sale` (status *and* `shipTo`) plus
the facility address; a list row has none of that. Computing it in the list would
mean fetching the sale twice. The sync logic also already handles the
failed-lookup degradation (documented at length in `_syncStepTo`), which a second
implementation would get wrong.

**Consequence for FR-007.** It is satisfied by navigation plus existing
behaviour; its acceptance test asserts the landing step, not a new function.

## R6 — The date-range filter, which this product does not yet have

**Decision.** Add one shared widget, `lib/core/widgets/date_range_filter_chip.dart`,
that renders a `FilterChip` showing the active range and opens Material's
`showDateRangePicker`. It encodes into `ListQuery` facets as `date-from` and
`date-to` (`yyyy-MM-dd`), parsed by `PosSalesFilter.fromQuery` the way every
other screen parses its facets.

**Rationale.** Constitution §VI requires filtering to use "the shared filter
pattern from `core/widgets/`", and shared visual components to live once in
`core/widgets/`. A grep confirms no `showDateRangePicker`/`DateTimeRange` usage
exists anywhere in `lib/` today, so this is the first one — which is exactly the
case the "lives once in core" rule is for. It is also the only new *core* widget
this feature adds.

**Consequence.** `test/golden/core_widgets_golden_test.dart` runs a
directory-scan test (spec 022 FR-023) that **fails** when a file appears in
`lib/core/widgets/` without either a golden or a justification entry. The new
chip therefore needs a golden scenario in that file — a hard, mechanical task,
not an optional nicety.

**Default and clearing.** The default range is today→today, and clearing the
chip returns to today rather than to "unbounded". Unbounded is what spec 020
measured at 19,277 rows for one register; a filter whose cleared state is a
19k-row scan is a trap.

## R7 — Search-as-you-type without breaking the scanner

**Decision.** `ProductSearchField` gains a debounced `onChanged` path alongside
its existing `onSubmitted` path, with three rules that keep them from fighting:

1. `onChanged` starts a 300 ms debounce (the same interval
   `CatalogEntityPicker` uses); when it fires, the lookup runs and results are
   *offered*, never auto-added.
2. `onSubmitted` cancels any pending debounce and runs the lookup immediately.
   **Only this path auto-adds a single exact match.**
3. Every lookup carries a monotonically increasing request number; a result whose
   number is not the latest is dropped.

**Rationale.** Rule 2's restriction is the crux. Today's field auto-adds when
`results.length == 1`, which is what makes scanning work. Move that to the
typing path and a cashier typing "CEM" pauses for 300 ms, one match comes back,
and a line is silently added mid-word. Rule 3 is what keeps a slow lookup for
"CEM" from replacing the results for "CEMENTO" — spec 020's own field has no such
guard because, searching only on submit, it could not have the race.

`productLookupControllerProvider` is an autodispose family keyed by
`(pattern, warehouse)` and can be reused as-is: each debounced pattern is its
own short-lived provider, which its docstring already describes as the intent.

**Alternatives rejected.** (a) Replacing the field with `CatalogEntityPicker` —
it has no scan/submit/auto-add path and no stock-carrying result type; the field
also owns focus behaviour that spec 020 keyed a widget test to. (b) Auto-adding
on a single typed match — the silent-add failure above.

## R8 — The customer band: why the name renders blank today, and the swap

**Root cause of the blank field.** `CustomerBar._picker` seeds
`CatalogEntityPicker.initialDisplayText` from `sale.customerName`, which is
nullable on `SalesOrderResponse` and is null for the register's walk-in customer
on the observed sale — while `_CustomerFacts` reads the *customer record*
(`saleCustomerControllerProvider`) and therefore does show `PÚBLICO EN GENERAL`.
The screenshot shows exactly that split: an empty "Cliente" field above a facts
row that knows the name.

**Decision.** The band's displayed name resolves as
`customer record name ?? sale.customerName ?? placeholder`, and the picker (when
opened) seeds from the same resolved value. Since the facts already fetch the
customer record, this costs nothing.

**Decision — the swap.** Default state is a facts row with two trailing actions
("Buscar", "Nuevo"). Pressing Buscar sets local state to `searching`; the band
renders the picker instead of the facts inside an `AnimatedSwitcher` (fade +
size), autofocusing the picker. Dismissing (Escape, or the picker's own cancel
affordance) returns to facts. Progress is shown in two distinct places: the
picker's own in-flight indicator while candidates load (`CatalogEntityPicker`
already debounces; the field shows a spinner), and a determinate-looking
disabled/spinner state on the band while `updateHeader` runs — which the existing
`_busy` flag already tracks.

**Rationale.** `AnimatedSwitcher` + `AnimatedSize` is stock Material 3 motion and
needs no package. Keeping the picker mounted only while searching also removes
the `ValueKey('rw-…')` remount churn that `CatalogEntityPicker` documents as its
re-seeding workaround.

## R9 — Payment terms as a dropdown that never moves on its own

**Decision.** Replace `_paymentTermsControl`'s `SegmentedButton<PaymentTerms>`
with a `DropdownButtonFormField<PaymentTerms>` (or `DropdownMenu`, decided at
build time by which reads better under the tokens) rendered *in the facts row*,
in the slot the credit figure occupies today. Its label states the credit line
(the figure that used to be there is not lost — it becomes the control's
supporting text), its value is `sale.paymentTerms`, `PaymentTerms.netD` is
selectable only when the customer's `creditLimit` is non-zero, and choosing a
value calls the existing `updateHeader(paymentTerms: …)`.

**No auto-switch.** Nothing in the screen writes `paymentTerms` except that
`onChanged`. Whatever terms mbe-api sets when a customer is attached is what the
control displays. This is the clarified answer (2026-08-10) and it also keeps the
re-price round trip count unchanged.

**Open, resolved by construction**: whether mbe-api itself flips terms to credit
when a credit customer is attached is now irrelevant to the UI — the control
mirrors the response either way. No verification needed.

## R10 — The line row's single-row budget, and where it breaks

**Decision.** `SaleLineRow` lays out from a `LayoutBuilder`, not `MediaQuery`,
and switches on its own available width:

| Available width | Layout |
|---|---|
| ≥ 950 px | one row |
| 600–950 px | two rows |
| < 600 px | `SaleLineCard` (unchanged, chosen by the caller as today) |

**Why 950.** The mock's frame `2a` grid is
`minmax(300px,1fr) 176 128 96 100 88 84 124 44` with 10 px gaps — 940 px of
fixed columns plus a 300 px minimum for the product, i.e. ~1240 px, which is
above a tablet's 1024 and would fail FR-037a. Tightening each column to what its
value actually needs gives a budget that fits:

```
thumbnail  36   warehouse 140   quantity 104   unit 36   price 84
discount   68   tax        68   total     96   delete 40
gaps       9 × 8 = 72
                                    fixed subtotal = 744
product name/code, minimum          +           200
                                    ------------------
                                              944 px
```

So the single row holds at 950 px of *available* width. A 1024-px tablet in
landscape, in a workspace that no longer spends ~80 px on the rail and takes its
screen margin from the token scale (16 px a side at that tier), has ~992 px
available — inside the budget with ~48 px of slack. That slack is why the
threshold is 950 and not 990.

**Verification, not assertion.** The numbers above are a budget, not a
measurement. The widget test for FR-037a pumps a line at a 1024-px surface and
fails if the layout is not the single row or if anything overflows — so if the
real type scale makes a column wider than budgeted, the test says so instead of
the layout silently degrading on the cashier's tablet.

**Rationale for `LayoutBuilder`.** The row must react to the space it is given,
not the window: the same row renders inside a full-width workspace today and
could sit inside a narrower container tomorrow. `MediaQuery` would answer for
the window and be wrong in both directions.

## R11 — The product thumbnail, and the mbe-api dependency

**Decision.** `SaleLineRow`/`SaleLineCard` render
`ProductPhoto(photoUrl: null, size: 36)` — the existing shared widget's
placeholder — in a fixed 36 px slot. No photo is fetched.

**Rationale.** `ProductLookupResponse` and `SalesOrderLineResponse` carry no
photo field (confirmed by reading both generated models and the `SaleLine` /
`ProductLookupResult` mappings). Only `Product`/`ProductListItem` carry a
resolved `photo`, reachable through `products` endpoints — a privilege a cashier
need not hold, and a per-line round trip on the one screen whose premise is
speed. Constitution §III forbids editing mbe-api from here and requires the
needed backend change to be recorded as an external dependency and filed as an
mbe-api issue.

**External dependency to file** (mbe-api issue, blocking only the image):
expose the product's resolved `photo` on `ProductLookupResponse` and on
`SalesOrderLineResponse`, so the POS can render a thumbnail without a second
call. Until it ships, the reserved slot keeps row heights stable so lighting it
up later is a one-line change at each call site.

## R12 — Reclaiming the vertical space: what actually causes the dead band

**Diagnosis.** Three separate things, all visible in the screenshot:

1. `CaptureStep` gives the non-compact branch `Expanded(child: ListView(...))`
   for the lines — correct — but then stacks `SaleTotalsBar` **and** a separate
   `Padding(EdgeInsets.all(12)) → FilledButton` band beneath it, so the footer
   costs two bands instead of one.
2. Every header piece carries its own `EdgeInsets.all(12)`, and `CustomerBar`
   adds a second `EdgeInsets.all(12)` *inside* its `Card` — the doubled padding
   the request calls "strange".
3. `PosHeaderBand` spends a full band (`fromLTRB(16,12,16,8)`) on the selector
   and the step indicator, above the app bar's own 64 px.

**Decision.** (1) The totals bar absorbs the primary action, becoming one footer
band (FR-045). (2) Header insets come from `Theme.of(context).spacing`
(`screenMargin`/`cardPadding`), applied once — the card keeps its internal
`cardPadding`, and the step no longer wraps it in a second inset. (3) The
selector, the sale identity and the step indicator move into the workspace app
bar's `title` slot, deleting the band entirely. The lines `Expanded` stays and
now genuinely reaches the footer.

**Explicit opt-out.** The workspace does **not** apply
`spacing.contentMaxWidth` (which is finite only at the `large` tier) and does not
centre. That is a deliberate divergence from the form-grid conventions, recorded
in the plan's Complexity Tracking, on the grounds that constitution §VI's
multi-column form rule addresses *forms* — the POS capture surface is a working
table, and its whole complaint is bounded width.

## R13 — Keeping the app bar legal

**Decision.** The workspace's `AppBar` uses `leading` (Back, via
`Navigator.maybePop` / `context.pop()`), a composed `title` widget carrying the
step name, the sale identity chip, the open-sales selector and the step
indicator, and **`actions: const []`**.

**Rationale.** Constitution §VI (v1.10.0) requires a record detail screen's
`AppBar.actions` to be empty and every screen-level action to be a body button.
The POS workspace is not a record form — it has no Save/Delete/read-only toggle —
but the safest reading is to keep `actions` empty and treat the identity chip,
selector and step indicator as title-area content, which is what the mock draws
anyway (frame `2a`: they sit immediately right of the title). The Back
affordance is `leading`, which the rule does not restrict and which every other
full-screen route already uses.

**Recorded in Complexity Tracking** rather than waved through: the open-sales
selector is an interactive menu in the title area. It is retained because the
counter needs a switch between open sales without leaving the sale (spec 020
FR-004, and the mock shows it there), and because deleting it would be a
regression in the flow the list does not replace.

## R14 — Cash session gating across two screens

**Decision.** The **workspace** keeps the gate exactly as it is: `PosScreen`'s
`currentSession.state == none → PosGateScreen` moves to `PosWorkspaceScreen`, so
every entry path — list action, deep link, reload — hits it (FR-020). The **list**
does *not* gate: reading the register's sales needs no open shift. Instead the
list's "Nueva venta" action is disabled when there is no session, with the reason
stated and a link to `/sales/cash-sessions`, reusing `PosGateScreen`'s existing
copy and navigation.

**Rationale.** Spec 021's gate exists so no *sale record* is created without a
shift (spec 020 decision 4, D-006). Reading history breaks none of that, and a
cashier whose shift is closed still has a legitimate reason to look at the day.
Blocking the list would also make the gate the landing screen for the whole
navigation destination, which is worse than today.

## R15 — Test surface

**Decision.** The existing POS test assets are reused, not replaced:
`test/widget/features/sales/pos_test_harness.dart` (`pumpPos`, `testSale`,
`testLine`, `phoneSurface`, `expectNoHorizontalScroll`, the repository mocks)
gains a `pumpPosRouted` helper for the two new routes, and the mocks gain the new
`listSales` stub. New/changed coverage:

| Area | Test |
|---|---|
| list rows, facets, paging, workability | `test/widget/features/sales/pos_sales_list_screen_test.dart` (new) |
| workability rule in isolation | `test/unit/features/sales/pos_sale_workability_test.dart` (new) |
| routing: list → workspace → back, `/new` URL rewrite, blocked sale | `test/widget/features/sales/pos_workspace_route_test.dart` (new) |
| no rail, no centring, no dead band | same file, layout assertions |
| customer band swap, name resolution, terms dropdown | `customer_bar_test.dart` (extended) |
| search-as-you-type vs scanner | `test/widget/features/sales/product_search_field_test.dart` (new) |
| one row at 1024, two rows below, card at 390 | `sale_line_row_test.dart` (extended) |
| footer figures and action | `test/widget/features/sales/sale_totals_bar_test.dart` (new) |
| the new core widget's appearance | `core_widgets_golden_test.dart` (+ scan entry) |
| the restyled POS surfaces | `test/golden/pos_capture_golden_test.dart` (new) |
| endpoint semantics (`search`, `date_to`) | `test/integration/pos_sales_list_flow_test.dart` (new, live-backend) |

**Rationale.** Constitution's quality gates ask for unit tests on domain logic,
widget tests on critical screens, and integration tests on golden-path flows;
spec 022 added the golden net and its directory-scan enforcement. The live
integration test is where the two unverified endpoint behaviours from R3 get
settled — and per this project's own convention (recorded in memory from spec
009) it discovers its fixtures at runtime rather than hard-coding ids.

**Known constraint.** `MBE_POS_*` keys are absent from `.env`, so the live POS
integration tests need those credentials to run; the new one is written to skip
cleanly when they are missing, like its siblings.

---

## Unresolved (tracked, none blocking)

| # | Question | How it is handled |
|---|---|---|
| U1 | What `search` matches on `GET /sales-orders` | Live integration test; UI degrades to an empty state either way |
| U2 | Whether `date_to` includes its own day | Same test; the picker lets the cashier extend the range |
| U3 | Whether mbe-api will expose `photo` on lookup/line payloads | mbe-api issue to file (R11); placeholder ships regardless |
