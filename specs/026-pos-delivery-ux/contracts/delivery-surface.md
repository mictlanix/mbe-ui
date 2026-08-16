# UI Contract: The Entrega Surface

**Feature**: `026-pos-delivery-ux` | **Date**: 2026-08-15

What each region owns, what it renders, and which token every value resolves
through. Written so a widget test can be read off it. Every section is
buildable: [#163](https://github.com/mictlanix/mbe-api/issues/163),
[#165](https://github.com/mictlanix/mbe-api/issues/165) and
[#171](https://github.com/mictlanix/mbe-api/pull/171) all landed and the client
is regenerated ([research R2](./research.md)).

Token access is always `Theme.of(context).spacing` / `.shapes` / `.typeRoles` /
`.elevations` — no literal colour, spacing, radius or size anywhere (FR-039).

---

## 1. Step host — `delivery_step.dart`

Two shapes, chosen on `MediaQuery.sizeOf(context).width >= LayoutBreakpoints.large`.

**Wide (≥ 1200 px)** — `Row`, `crossAxisAlignment: stretch`, outer padding
`spacing.screenMargin`:

| Slot | Width | Contents |
|---|---|---|
| destinations | `Expanded` | §2 |
| gutter | `spacing.paneGutter` | — |
| rail | `360` (const `_railWidth`) | §5 |

**Compact (< 1200 px)** — `Column`: an `Expanded` `ListView` holding §2 then §5's
list, and §5's foot pinned beneath it as a footer band, the treatment
`SaleTotalsBar` already gives the capture step.

Invariants:

- Only the destination list and the distribution list scroll (FR-007). The
  rail's header and foot do not.
- No `Center`, no `contentMaxWidth` clamp: the step spends what it is given
  (FR-006).
- A load failure renders `ErrorBanner` above the destinations region, dismissed
  by invalidating `deliveryControllerProvider` — as today (FR-008).
- The step builds the badge map (`data-model.md §2.1`) once and passes it to
  both regions.

---

## 2. Destinations region

Vertical list, `spacing.sm` between children, in this order (FR-009):

1. §3 counter row — always first; shown for a mixed sale **or** for any sale that already has a counter-pickup destination (FR-010)
2. §4 destination card, one per addressed destination, in recorded order
3. the add action
4. the empty state, when there are no destinations at all (FR-017)

**Add action** — key `delivery_add_destination_button`. Full-width,
`OutlinedButton.icon` with a dashed-appearance border from `shapes`, icon
`Icons.add_location_alt_outlined`, label `posAddDestination`. Disabled while the
sheet is open, while a close is in flight, and **when no line has anything left
unassigned** — the server refuses an empty create on a fully-assigned sale, so
the control states `posAddDestinationNothingLeft` rather than making the round
trip (FR-016, [research R14](./research.md)).

---

## 3. Counter row

Key `destination_counter_row`. A `Card` at the same radius as §4 but without an
expand affordance and **without a remove action** (FR-011).

| Element | Content | Style |
|---|---|---|
| leading | `Icons.store_outlined` in a `shapes`-rounded box | `colorScheme.surfaceContainerHighest` |
| title | `posCounterPickupRemainder` | `typeRoles.cardTitle` |
| counts | `posDestinationCounts(lines, units)` | `typeRoles.metricLabel` |

Figures come from the counter-pickup `Destination` when one exists — whatever
the sale's mode says — otherwise from the distribution, for a mixed sale only
([research R4](./research.md)). So a sale that resumed with a `null`
`fulfillment_intent` and reads as plain delivery still shows its swept counter
units rather than counting them invisibly.

---

## 4. Destination card — `destination_card.dart`

Key `destination_card_${destination.id}`. `StatefulWidget`, own `_expanded`
([research R5](./research.md)).

### 4.1 Header (always visible, FR-013)

One `InkWell` row, `spacing.sm` gaps, that toggles expansion:

| Element | Content |
|---|---|
| badge | `posDestinationBadge(ordinal)` in a `shapes.sm` box, `typeRoles.recordId`, `colorScheme.secondaryContainer` |
| identity | `addressSummary ?? posDeliveryAddressPending` (`typeRoles.cardTitle`, one line, ellipsized) over `contactName · contactPhone · date` (`typeRoles.metricLabel`) |
| divider | `VerticalDivider`, `spacing.lg` tall |
| counts | `posDestinationCounts(lineCount, unitCount)` (`typeRoles.metricLabel`) |
| spacer | `Expanded` |
| remove | `IconButton`, key `destination_remove_${id}`, `Icons.delete_outline`, `colorScheme.error`, tooltip `posRemoveDestination` (FR-015) |
| chevron | `Icons.expand_more` / `expand_less` |

A long address ellipsizes; the counts never do (constitution §VI — counts are
task-critical).

### 4.2 Body (expanded)

Header `posDestinationLinesTitle` with `posDistributionClaimAll` as a trailing
text action (FR-023). Then one §4.3 row per **sale line** — every line, not only
the ones this destination carries (FR-018).

### 4.3 Line row

| Element | Content |
|---|---|
| identity | product name (ellipsized) over `productCode · posDistributionOrdered(ordered)` |
| elsewhere chip | `posDestinationCounterChip(units)` when another destination or the counter holds some |
| stepper | §4.4 |

### 4.4 Stepper pill

`IconButton(Icons.remove)` — `TextField` — `IconButton(Icons.add)`, wrapped in a
`shapes.xl`-radius container, mirroring `SaleLineRow._quantityStepper`
([research R6](./research.md)).

- Keys: `destination_quantity_${saleLineId}`, `destination_claim_all_${saleLineId}`.
- Tooltips: `posLineDecreaseQuantity` / `posLineIncreaseQuantity` — existing keys.
- The field is real, focusable, typable, `TextInputType.numberWithOptions(decimal: true)` (FR-020).
- Clamp `0 … ceiling` (`data-model.md §2.2`); the control refuses out-of-range
  rather than sending (FR-021, SC-006).
- Step is `1`; a typed fraction is preserved (spec Assumptions).
- At `0` the line is dropped and its units return to the pool (FR-022).
- A burst of steps is **debounced** into one write of the final value
  (~400 ms) and the row stays live throughout (FR-025) — the controls are
  never inerted for a round trip. Only one write per line is in flight at a
  time; a step landing mid-flight is sent once that one settles, and anything
  still pending is flushed on dispose.
- On refusal: message on the row, quantity re-read from `state` (FR-024) —
  the `syncFields()` shape from `SaleLineEditing`. All three refusal paths
  (over-claim, foreign line, already-present) render identically
  ([research R13](./research.md)).
- **Dispatch** ([research R13](./research.md)): the destination already carries
  this sale line → `adjustLine` (`PUT`); it does not → `assignLine` (`POST`,
  which refuses a duplicate with 409); the new value is zero → `dropLine`
  (`DELETE`, since `POST`/`PUT` both require `quantity > 0`). Read from
  `Destination.lines`, so no probe request.

---

## 5. Distribution rail — `line_distribution_panel.dart`

### 5.1 Header

`posDistributionTitle` (`typeRoles.sectionHeading`) over
`posDistributionRailSubtitle(lines, destinations)` (FR-035).

### 5.2 List — key `line_distribution_panel`

One row per sale line, key `distribution_row_${saleLineId}` (FR-031):

| Element | Content |
|---|---|
| name | product name, ellipsized, `typeRoles.tableCell` |
| chips | one per destination holding any of the line — `posDestinationBadge(n)` + quantity — plus `posDistributionAtCounter(units)` when any remains at the counter (FR-032) |
| ordered | `formatQuantity(ordered)`, `typeRoles.recordId`, right-aligned |

A line still outstanding is marked by an icon plus its chip treatment, never by
colour alone (FR-034). The rail rebuilds from `deliveryControllerProvider`, so
an assignment moves it without any explicit refresh (FR-033).

### 5.3 Foot (pinned)

In order (FR-036 → FR-038):

1. `posDeliveryAssignedUnits(assigned, total)`
2. the outstanding notice — key `delivery_outstanding_notice`,
   `posDeliveryOutstanding(lines)`, `colorScheme.error`; **only** when the
   finish action is disabled on a pure-delivery sale
2a. the sweep action — key `delivery_sweep_to_counter_button`,
   `OutlinedButton.icon`, `Icons.store_outlined`, `posDeliverRestAtCounter`;
   shown **only** while the notice above it is (FR-037a), disabled while a
   close is in flight. Sweeps the remainder to the counter and finishes.
   Secondary by construction — the primary action stays the one below it.
3. the finish action — key `delivery_close_button`, `FilledButton`,
   `posFinishSale`, enabled by `isDistributionComplete(distribution, isMixed:)`
   exactly as today, spinner while closing

---

## 6. Add sheet — `destination_editor.dart`

Key `destination_editor`. Opened by §2's add action through a delivery-specific
opener modelled on `showCatalogFilterSheet` ([research R10](./research.md)):
right-anchored `showGeneralDialog` at ≥ 1200 px, `showModalBottomSheet` below,
`useRootNavigator: true` in both.

Captures the header only — **no quantity control** (FR-027):

| Control | Key | Source |
|---|---|---|
| address | `destination_address_button` | `showCustomerAddressPicker` — a linked record, never free text (FR-028) |
| contact | `destination_contact_button` | `showCustomerContactPicker` |
| date | `destination_date_button` | `showDatePicker` |
| instructions | `destination_comment_field` | free text |
| save | `destination_save_button` | `FilledButton`, enabled when an address is chosen |
| refusal | `destination_editor_error` | `ErrorBanner`, keeps entered values (FR-030) |

On save the sheet closes and the new destination is appended, **expanded**
(FR-029, spec Assumptions).

The create call passes `lines: const []` — an explicit empty list, never
omitted. Omitted means "claim everything the sale still owes", so a `lines`
normalised to null when empty would hand the whole sale to one destination
([research R14](./research.md)). `DeliveryOrderRepositoryImpl.create` already
distinguishes the two correctly and needs no change.

---

## 7. Parity

- Every key above that exists today keeps its name (FR-042).
  `destination_quantity_*` and `destination_claim_all_*` keep their names but
  move from §6 to §4.4.
- `posDestinationQuantitiesTitle` is removed with the composer's quantity block;
  the other eight new keys are listed in [research R11](./research.md).
- Every control disabled today while closing stays disabled (FR-041).
- Expansion, stepping, assign-all, sheet open/save, remove and finish are all
  keyboard-reachable and screen-reader-labelled (FR-043).
