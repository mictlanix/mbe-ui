# Phase 1 Data Model: POS Delivery Step Look & Feel

**Feature**: `026-pos-delivery-ux` | **Date**: 2026-08-15

**No new entity.** This feature renders records spec 020 already defines and
adds one controller surface over them. Two things did change under it, both
from mbe-api#171: `Sale` gained `fulfillmentIntent`, and `FulfillmentType`'s
wire values were renumbered. What follows is the inventory the presentation
layer reads, plus the two derived values the new layout computes.

---

## 1. Entities read

`Sale` gains one field (§1.0) and `FulfillmentType`'s wire values were
renumbered by mbe-api#171 ([research R15](./research.md)); everything else here
is read exactly as spec 020 defines it.

### 1.0 `Sale.fulfillmentIntent` — `domain/entities/sale.dart` (**new**)

`FulfillmentMode?`, mapped from `SalesOrderResponse.fulfillment_intent`
(mbe-api#171). Three values plus `null`:

| Value | Means |
|---|---|
| `counterPickup` / `delivery` / `mixed` | what the cashier chose, recorded before the sale was confirmed |
| `null` | **not recorded** — every sale predating #171, and any raised by a client that does not set it |

`null` is deliberately not collapsed into a mode: `FulfillmentMode.fromApi`
returns `null` for it, and `resumeTargetFor` falls back to the `ship_to`
heuristic only in that case. Reading `null` as `delivery` would reintroduce the
exact wrong-answer risk the field was added to remove — mbe-api's own migration
017 declined to backfill it for the same reason.

Written by the capture step's mode selector, on the same `updateHeader` call
that already sets `shipTo` — one request, not two.

### `Destination` — `domain/entities/destination.dart`

| Field | Used by |
|---|---|
| `id` | card key, badge map, per-line endpoints |
| `fulfillmentType` / `isCounterPickup` | counter row vs addressed card (FR-010). Wire values **renumbered** by mbe-api#171 — pickup is now `0` and delivery `1`, the reverse of before ([research R15](./research.md)) |
| `addressSummary` | card header identity (FR-013) |
| `contactName`, `contactPhone` | card header identity |
| `date` | card header identity |
| `comment` | not rendered on the card; captured by the sheet |
| `status` | gates editability server-side (`draft` only) |
| `lines` | the expanded card's rows (FR-018) |
| `lineCount`, `unitCount` | the header's counts block (FR-013), the counter row's (FR-011) |

`addressSummary` / `contactName` / `contactPhone` are joined by
`DeliveryController._labelled` from the customer's own records — not persisted
on the delivery order. Unchanged.

### `DestinationLine` — `domain/entities/destination_line.dart`

`id` is what `PUT`/`DELETE .../lines/{line_id}` address, so it is what the
stepper needs to persist a change. `salesOrderDetail` is the join back to the
sale line; `quantity` is the assigned figure. `productName` is rendered when the
destination carries the line, but the card lists **every** sale line (FR-018),
so a row for a line at zero takes its name from the sale, not from here.

### `LineDistribution` — `domain/entities/line_distribution.dart`

Computed per build by `distributionFor(sale:, destinations:, draft:)`. Pure, no
round trip. Read by the rail (FR-031), by the counter row's preview (R4), and by
the clamp (R7).

`draftQuantity` and the `draft:` parameter survive with no caller — see
[research R9](./research.md). `isOverClaimed` keeps its caller:
`isDistributionComplete`, the gate FR-001 pins.

---

## 2. Derived values the new layout computes

### 2.1 Badge map

```
badges : Map<int destinationId, String label>
```

Built once per build in the step, over the **addressed** destinations in list
order (`D1`, `D2`, …); the counter row is not in it. Consumed by the cards
(FR-012) and by the rail's chips (FR-032), so the two cannot disagree
([research R8](./research.md)).

### 2.2 Assignment ceiling

```
ceiling(destination, line) = line.claimable + (line.perDestination[destination.id] ?? '0')
```

The clamp FR-021 applies, and the same figure `update_line` validates
server-side ([research R7](./research.md)).

### 2.3 Counter row figures

From a `Destination` where one exists — whatever the mode says — otherwise, on
a **mixed** sale, from the distribution: lines with a non-zero `atCounter` are
its lines, their sum is its units ([research R4](./research.md), FR-010).

---

## 3. The one new controller surface

`DeliveryController` (`presentation/delivery/delivery_controller.dart`) gains
three methods over the repository methods that already exist. No new provider,
no new state shape — `state` stays `AsyncValue<List<Destination>>`, and each
method replaces the one destination that changed.

| Method | Repository call | Availability |
|---|---|---|
| `assignLine(destinationId, saleLineId, quantity)` | `addLine` — **new**, to be added to the interface and the impl | ✅ endpoint shipped ([#163](https://github.com/mictlanix/mbe-api/issues/163)), client regenerated |
| `adjustLine(destinationId, lineId, quantity)` | `updateLine` | exists, unused today |
| `dropLine(destinationId, lineId)` | `removeLine` | exists, unused today |

Which of the three a stepper change calls is decided locally from
`Destination.lines` — the server refuses a duplicate `POST` with 409 rather than
folding it, and neither `POST` nor `PUT` accepts zero
([research R13](./research.md)).

Each returns the full updated destination, so the controller replaces that one
element of `state` — no refetch (SC-010).

`addDestination` has lost its `quantities` parameter (#165 landed) and now
sends an explicit `lines: const []` (FR-027, [research R14](./research.md));
`sweepRemainderToCounter`, `removeDestination` and `distribution` are untouched.

### 3.1 `SalesOrderRepository.updateHeader` — one new parameter

`fulfillmentIntent: FulfillmentMode?`, forwarded to
`SalesOrderUpdate.fulfillment_intent` (mbe-api#171). The capture step's mode
selector passes it in the call it already makes for `shipTo`, so recording the
intent costs no extra request. `pos_sale_controller.dart`'s wrapper threads it
through unchanged.

Counter pickup deliberately does **not** make this call: a `null` `shipTo`
already means counter pickup unambiguously, so there would be nothing at stake
if the request failed.

A refusal propagates as it does today — thrown for the caller to render, with
`state` left exactly as it was, which is what makes FR-024's "the displayed
quantity returns to the value the server still holds" a re-read rather than a
rollback.

---

## 4. State transitions

None added. A destination is `draft` for the whole of this step's life; every
line endpoint is guarded server-side by `assert_editable`, and the POS only ever
reaches destinations it created moments earlier. The sweep, the completion gate
and the cancel path are unchanged (FR-001).
