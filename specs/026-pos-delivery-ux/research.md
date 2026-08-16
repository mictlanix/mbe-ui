# Phase 0 Research: POS Delivery Step Look & Feel

**Feature**: `026-pos-delivery-ux` | **Date**: 2026-08-15

Findings that shape the design, each one resolved against the real code rather
than assumed. R2 and R3 are the two that change how the work is sequenced;
read those first.

---

## R1 — The two-region threshold and the rail's width

**Decision**: split at `LayoutBreakpoints.large` (1200 px); the rail is a fixed
**360 px**, the same figure `PaymentStep._railWidth` uses.

**Rationale**: arithmetic on the real tokens, not taste. At exactly 1200 px with
`Spacing.forTier(large)` — `screenMargin: 24`, `paneGutter: 24` — the
destinations region gets `1200 − (24 × 2) − 24 − 360 = 768 px`. A destination
card header at its widest is the badge (40) + gap (12) + identity (flexible) +
divider (1) + counts (~120) + expand/remove actions (2 × 44): about 270 px of
fixed furniture, leaving ~500 px for an address and a recipient line. That is
comfortable. Below 1200 the same header would have ~410 px and the counts would
wrap off the header line, which is exactly the failure FR-013 forbids.

The mock draws a 380 px rail at 1440. Taking 360 instead costs 20 px of chip
room and buys visual identity with the payment step's rail, which sits one step
earlier in the same workspace.

**Alternatives considered**: `LayoutBreakpoints.expanded` (840) — rejected by the
same arithmetic (a 440 px destinations region cannot hold the header). A
fractional rail (`Expanded(flex:)`) — rejected because the rail's chips are
fixed-size content; a proportional rail is wider than it needs at 1920 and
narrower than it needs at 1200.

---

## R2 — What mbe-api can and cannot do

**Updated 2026-08-15, after both [#163](https://github.com/mictlanix/mbe-api/issues/163)
and [#165](https://github.com/mictlanix/mbe-api/issues/165) landed** (merged in
#164 and #166) and the client was regenerated. Nothing in this feature is
blocked on mbe-api any more.

**Verified at the source** (`~/development/repos/mictlanix/mbe-api`), not
inferred from the client:

| Operation | Endpoint | Available |
|---|---|---|
| Create destination with lines | `POST /api/v1/delivery-orders` | ✅ |
| Create destination with **no** lines | same | ✅ **new** — `min_length=1` is gone and the service tests `lines is not None`, so `[]` and omitted stay distinct; see [R14](#r14--the-empty-create) for the one precondition |
| **Add a line to an existing destination** | `POST /api/v1/delivery-orders/{id}/lines` | ✅ **new** — `delivery_order_service.add_line`; see [R13](#r13--add_lines-semantics) |
| Adjust an existing line | `PUT /api/v1/delivery-orders/{id}/lines/{line_id}` | ✅ — `update_line`, validated against `_covered_quantities` |
| Remove an existing line | `DELETE /api/v1/delivery-orders/{id}/lines/{line_id}` | ✅ — `delete_line` |

**Rationale**: decisions 2 and 3 — header-only creation and in-card assignment —
are both buildable as specified.

The repository interface already declares `updateLine` / `removeLine` and
`DeliveryOrderRepositoryImpl` implements them — they have simply never had a
caller. `addLine` is **not** declared and must be added to both; only the
generated client has it (`82c496e`).

---

## R3 — Assignment ships as one piece

**Decision**: build the stepper, the clamp and the drop together. The trap this
finding originally described is gone.

**Rationale**: before #163 this section argued that no part of in-card
assignment could ship, because FR-022 makes zero a `DELETE` and a dropped line
could never be restored — the cashier would be one tap from destroying a line,
on a destination they would then have to cancel entirely. `add_line` removes
exactly that: a dropped line can be put back. The stepper can therefore have
its full `0 … ceiling` range (FR-021) from the first commit, rather than a
floor of 1 that would need rewriting later.

Nothing remains blocked. #165 followed, so the header-only sheet builds too;
the phases below are ordered by dependency alone.

**Alternatives considered**: cancel-and-recreate the destination to add a line —
forbidden by FR-003, and it loses the destination's id and its badge position.
Create every destination carrying one placeholder line so `updateLine` always
has something to work on — same prohibition, and it corrupts the distribution
the moment the cashier abandons the destination. Defer creation until the first
assignment, so the card is local until it has a line — legitimate, and rejected
for a different reason: a card with no server record behind it is a state
badges, the distribution, removal, the close gate and the resume path would all
have to reason about, which is a large amount of new conditional logic to carry
until #165 lands anyway.

---

## R4 — The counter row without a counter-pickup record

**Decision**: one widget, two sources. When the sale has a `Destination` with
`isCounterPickup`, render from it. Otherwise, for a **mixed** sale only, render
from the distribution the step already computes: the lines with a non-zero
`atCounter` are its lines, and their sum is its units.

**Rationale**: `distributionFor` is pure and already called on every build; the
remainder is `LineDistribution.atCounter` per line. Nothing is fetched and
nothing is created early, which is what keeps FR-001's fence intact. The two
sources agree by construction — after the sweep, the created destination holds
exactly the quantities the preview was showing.

**Alternatives considered**: creating the counter-pickup destination up front so
there is always a record — rejected: it changes when the sweep happens, which
FR-001 forbids, and a cashier who then assigns everything to addresses would be
left with a zero-line destination on the server.

---

## R5 — Card expansion: hand-rolled, not `ExpansionTile`

**Decision**: `DestinationCard` becomes a `StatefulWidget` holding its own
`_expanded` flag, with a custom header row and an `AnimatedSize` body.

**Rationale**: FR-013's header is a badge, an identity block, a vertical
divider, a counts block and two action icons on one line. `ExpansionTile` gives
`leading`/`title`/`subtitle`/`trailing` and puts its own chevron in `trailing` —
producing that header means fighting it for the trailing slot and losing the
divider. A `Column` with an `InkWell` header is less code than the workarounds.

Per-card state in the widget (not lifted) is what makes FR-014's independence
free, and it survives the list rebuilding around it because
`destination_card_${destination.id}` keys each card to its record.

---

## R6 — The stepper: reuse the pattern, not the code

**Decision**: mirror `SaleLineEditing` (`capture/sale_line_editing.dart`) in a
delivery-side equivalent. Do not extract a shared mixin.

**Rationale**: the capture step already solved this exact problem — a
display-formatted `TextEditingController`, a server round trip per edit, a
`_busy` flag that inerts the controls while one is in flight, and a
`syncFields()` that restores the last accepted value when the server refuses
(`sale_line_editing.dart:99-105`). FR-024 and FR-025 are that behaviour,
verbatim. But the mixin is bound to `SaleLine`, `posSaleControllerProvider` and
a warehouse/tax picker; nothing generic survives extraction except the shape.

Two differences to encode deliberately:

- `SaleLineEditing.step()` refuses to reach zero (`if (next.sign <= 0) return;`)
  because a sale line at zero is meaningless. A **destination** line at zero is
  meaningful — FR-022 makes it the removal gesture — so the delivery `step()`
  clamps at zero and calls remove there.
- The capture stepper's ceiling is stock; the delivery stepper's is R7's.

**Reused for free**: `posLineDecreaseQuantity` / `posLineIncreaseQuantity`
already exist in both locales (`app_es.arb:956-957`, `app_en.arb:2113-2116`) and
say exactly what the delivery steppers do. No new key for either.

---

## R7 — The clamp ceiling

**Decision**: for destination `d` and sale line `l`, the maximum assignable is

```
ceiling(d, l) = LineDistribution.claimable(l) + perDestination(l)[d.id]
```

**Rationale**: `claimable` is `ordered − Σ(all destinations)`, so it has already
subtracted what `d` itself holds. Adding `d`'s own share back gives "everything
the sale still owes, from `d`'s point of view" — which is what lets a cashier
raise `d` from 4 to 6 when the line has 2 left, and lower it freely. Using
`claimable` alone would pin every existing quantity as its own ceiling.

This is the same figure `update_line` validates server-side (`elsewhere +
quantity > sales_line.quantity`, `delivery_order_service.py:518`), so a client
clamp at this value means SC-006's "zero over-claims reach the server" is
achievable rather than aspirational.

---

## R8 — Badges, and the id→badge map

**Decision**: badges are positional over the **addressed** destinations only, in
list order: the first is `D1`. The counter row is badged by its store icon, not
a letter. One `Map<int, String>` from destination id to badge label is built
once per build in the step and passed to both regions.

**Rationale**: FR-012 requires the card's badge and the rail's chip to agree.
`LineDistribution.perDestination` is keyed by destination id, so the rail needs
the same map the cards were numbered from — computing it twice invites them to
disagree after a removal. Counting only addressed destinations keeps `D1` on the
first address whether or not a counter row is present.

**Localization**: the letter is a label, not a literal — `posDestinationBadge`
takes the ordinal, so `D1`/`E1` can differ per locale (FR-040).

---

## R9 — `draftQuantity` after header-only creation

**Decision**: keep `LineDistribution.draftQuantity`, `isOverClaimed` and
`distributionFor`'s `draft:` parameter. Remove only the call sites that pass a
draft.

**Rationale**: with no quantities in the create sheet there is no draft to
overlay, so `distribution(draft: …)` loses its only caller. But `isOverClaimed`
is still read by `isDistributionComplete` — the completion gate FR-001 pins —
and `line_distribution_test.dart` covers the draft arithmetic directly. Deleting
the parameter would mean editing a passing unit test to match an implementation
change, which is the wrong direction. It costs one unused named parameter.

---

## R10 — The side sheet

**Decision**: follow `showCatalogFilterSheet` (`core/widgets/catalog_filter_sheet.dart`):
a right-anchored `showGeneralDialog` above the threshold, a
`showModalBottomSheet` below it. A delivery-specific opener, not a reuse of the
catalog one.

**Rationale**: the catalog sheet is the product's established side-sheet
mechanics, including the one non-obvious part — `useRootNavigator: true`,
because the POS lives inside a `StatefulShellBranch` whose nested Navigator
would tear the sheet down. That reasoning applies here unchanged. What does not
transfer is its footer: the filter sheet applies live and offers
Clear-all/Apply, while the destination sheet is a form with Cancel/Save and a
refusal banner.

**Threshold**: the sheet switches at `LayoutBreakpoints.large`, the same figure
as the step's own split (FR-026), not at the catalog sheet's `expanded`. Below
1200 there is no rail for a side sheet to sit over.

---

## R11 — Localization inventory

**Decision**: nine new keys; one existing key reused for the counter row. The
ninth (`posAddDestinationNothingLeft`) was added once [R14](#r14--the-empty-create)
established that the add action needs a disabled-state reason.

| Key | Purpose |
|---|---|
| `posDestinationBadge` | `D{ordinal}` on the card and the chips |
| `posDeliveryDestinationsTitle` | the destinations region's heading |
| `posDistributionRailSubtitle` | "{lines} líneas · {destinations} destinos" |
| `posDeliveryAssignedUnits` | "{assigned} / {total} unidades asignadas" |
| `posDestinationLinesTitle` | "Cantidad a entregar en este destino" |
| `posAddDestinationSheetTitle` | the sheet's title |
| `posDestinationCounterChip` | the rail chip for the counter's share |
| `posDeliveryAssignmentRefused` | the per-line refusal line |
| `posAddDestinationNothingLeft` | the add action's disabled-state reason, FR-016/R14 |

`posCounterPickupRemainder` already reads "Se recoge en tienda" / "Counter
pickup remainder" and needs no change. `posDistributionClaimAll` already labels
the assign-all action. `posDistributionTitle`, `posDistributionOrdered`,
`posDistributionAtCounter` survive in the rail. `posDestinationQuantitiesTitle`
is superseded by `posDestinationLinesTitle` and is removed with the composer's
quantity block.

---

## R12 — Test impact

**Decision**: two existing widget tests change; the unit tests do not.

- `destination_editor_error_test.dart` — pumps `DeliveryStep` and asserts the
  composer's refusal banner. It survives phase G if the sheet keeps
  `destination_editor` and `destination_editor_error`; the pump changes because
  the editor is behind a sheet rather than inline.
- `pos_compact_delivery_test.dart` — asserts cards, the joined address/contact,
  the quantity fields and no horizontal scroll at 390 px. The card and
  no-overflow assertions hold; the quantity-field assertions move to the card in
  phase G.
- `line_distribution_test.dart`, `delivery_order_repository_impl_test.dart` —
  untouched, by R9 and by FR-001.

New: a layout test for the two shapes and the reflow, a destination-card test
for expansion and the header, and a rail test for the chips and the total. The
assignment tests come with the stepper.

---

## R13 — `add_line`'s semantics

**Decision**: the stepper dispatches on whether the destination already carries
the sale line — `addLine` for the first unit, `updateLine` afterwards, `dropLine`
at zero.

**Rationale**: read off the shipped service
(`delivery_order_service.py:504-600`), not assumed. Four behaviours the client
must respect:

| Behaviour | Consequence for the client |
|---|---|
| A sale line **already on** this delivery order is refused with **409**, naming the existing line id — deliberately not folded, "so that the caller's quantity always means what it says" | The client cannot post blindly. `Destination.lines` already says which lines it carries, so the dispatch is local and needs no probe request |
| `quantity` is `Field(gt=0)` | Zero cannot be posted. Removal stays `DELETE`, which is what FR-022 already specifies |
| Returns the full updated `DeliveryOrderResponse`, like `PUT`/`DELETE` on a line | The controller replaces that one destination in `state` wholesale — no refetch of the list, which is what SC-010 asks for |
| Over-claim → 422 reusing `update_line`'s wording; an unknown line or **another customer's** line → 422 with one shared message | The per-line refusal treatment (FR-024) is identical for every path; no branch on which one it was |

**Amended by [#167](https://github.com/mictlanix/mbe-api/issues/167)** (`2884710`,
landed the same day): `add_line`'s guard was originally "the same sales order as
the lines already here", which forbade one shipment consolidating several sales —
261 of 27,921 sale-linked delivery orders in production do exactly that. The
guard is now **the customer alone**. Nothing in the POS flow changes: every
destination it builds belongs to one sale and one customer. It does mean a
line of *another sale* is no longer refused, so the client must not rely on that
as a safety net — the POS only ever offers the current sale's lines, which is
what makes it moot here.

`assert_editable` guards it, so `draft` only — the same precondition the other
two line endpoints carry, and always true for a destination the POS just made.

The generated method is
`DeliveryOrdersApi.addDeliveryOrderLineApiV1DeliveryOrdersDeliveryOrderIdLinesPost({deliveryOrderId, deliveryOrderLineRequest})`.
`DeliveryOrderRepository` needs a matching `addLine`; the impl mirrors
`updateLine`'s shape.

---

## R14 — The empty create

**Decision**: the header-only sheet creates with `lines: []` — an explicit empty
list, never an omitted one. The add action is disabled when the sale has
nothing left unassigned.

**Rationale**: [#165](https://github.com/mictlanix/mbe-api/issues/165) dropped
`min_length=1` and the service branches on `lines is not None`, so the three
cases stay distinct: omitted claims everything the sale still owes, `[]` creates
a destination carrying nothing, a populated list claims that subset.

The client already honours the distinction by accident of good luck:
`DeliveryOrderRepositoryImpl.create` guards with `if (lines != null)`, and the
generated serializer emits the field with `if (object.lines != null)` — so a
non-null empty `ListBuilder` serialises as `lines: []` and a null one is
omitted. **Passing `const []` is therefore enough; no repository change is
needed for the empty create.** What must not happen is `lines` being normalised
to null when empty anywhere along the way — that would silently claim the whole
sale.

**The one precondition**, and it is a UI consequence: `create_from_sales_order`
raises `409 "This sales order is already fully delivered"` when nothing is
uncovered, and that guard runs **before** the narrowing step
(`delivery_order_service.py:263` vs `:269`). So an empty create is refused on a
sale whose every unit is already assigned. The client's equivalent test is
"every line fully distributed" — precisely the condition that opens the finish
gate — so **the add action is disabled exactly when the finish action is
enabled** on a pure-delivery sale. Adding a destination to a fully-assigned sale
means first freeing units from an existing one, which the steppers now allow.

**Alternatives considered**: sending one line at some nominal quantity and
correcting it — the placeholder FR-003 forbids. Letting the sheet post and
rendering the 409 — rejected: a refusal the client can predict is a disabled
control with a reason, not a round trip.
