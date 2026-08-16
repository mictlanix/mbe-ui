# Quickstart: Proving the Entrega Surface Works

**Feature**: `026-pos-delivery-ux` | **Date**: 2026-08-15

How to check this feature is right, in the order that finds problems fastest.
Every scenario runs: [#163](https://github.com/mictlanix/mbe-api/issues/163),
[#165](https://github.com/mictlanix/mbe-api/issues/165) and
[#171](https://github.com/mictlanix/mbe-api/pull/171) all landed and the client
is regenerated.

**Drive this against a live server before believing it.** Four defects in this
feature were invisible to the whole test suite and turned up in the first ten
minutes of real use: a date that killed the request before it was sent, a
stepper whose figure never moved, a UI that froze on every tap, and a mixed
sale that could not be finished. Each is now covered by §4 and by a
regression test — but the pattern is the point.

---

## 1. Automated

```bash
flutter analyze
flutter test test/widget/features/sales/ test/unit/features/sales/
flutter test                                   # full suite before pushing
```

Green means: the two shapes render, the cards expand independently, the rail's
chips agree with the cards, no region overflows at 320–1920 px, and the two
locales are complete. It does **not** prove the layout looks right — §3 does
that.

Must stay green untouched, by [research R12](./research.md):
`test/unit/features/sales/line_distribution_test.dart`,
`test/unit/features/sales/delivery_order_repository_impl_test.dart`.

---

## 2. Getting to the step

The Entrega step is the **last** step, and it renders only for a delivery or
mixed sale. To reach it:

1. Open the POS with a register session (`/sales/pos`).
2. Capture a sale for a customer whose `shipping` is true — otherwise the
   fulfilment selector will not offer Domicilio or Mixta.
3. Give it at least **six lines**, one of them a fractional unit (kg or m), so
   §3's stepper and ellipsis rows have something to bite on.
4. Choose **Mixta** to exercise the counter row; **Domicilio** to exercise the
   outstanding gate. Both are worth one pass.
5. Confirm, then take the payment. Entrega opens after Cobro.

A sale that is already part-distributed can be reopened from the sales list,
which is the faster loop once the first one exists.

---

## 3. The width table

Resize the window through each row and check the named thing. The first two
rows are where the layout is most likely to be wrong.

| Width | Expect |
|---|---|
| 1440 | Two regions. Counter row, cards, add action left; rail right. Nothing scrolls with 2 destinations × 6 lines (SC-001) |
| 1200 | The two-region shape still holds — the card header keeps badge, address, recipient, counts and both icons on one line, nothing wrapped ([research R1](./research.md)) |
| 1199 | One column, summary and finish pinned to the bottom edge. Cross this boundary back and forth twice |
| 840 | Same one-column shape, wider cards |
| 390 | Phone. Each card's rows fit; no horizontal scroll anywhere (SC-007) |
| 320 | Nothing clipped, figures intact |
| 1920 | The rail stays 360 px; the destinations region takes the rest |

At 1440 and 390, repeat with the OS text scale raised — SC-007 covers both
scales the product supports.

---

## 4. Scenarios

### 4.1 Read the distribution (US1, US3)

On a mixed sale with two destinations:

- The counter row is **first**, before both cards.
- Each card's badge matches the chips in the rail — `D2 242` in the rail means
  the card badged `D2` holds 242 of that line.
- The rail's foot reads assigned against total, and the finish action sits
  directly beneath it.
- Expand one card; the other's expansion state does not change and the list does
  not jump (FR-014).

### 4.2 The gate (US3)

On a **pure-delivery** sale with something unassigned:

- The finish action is disabled and the outstanding notice names the short lines
  and their quantities.
- Assign the remainder; the notice disappears and the action enables in the same
  block, with no scroll.
- Now on a **mixed** sale with a remainder: the action is enabled, the counter
  row states the remainder, and nothing is red.

### 4.3 Assignment (US2)

In one card:

- Raise a line past what the sale still owes → the control refuses; watch the
  network panel and confirm **no request was sent** (SC-006).
- Lower a line to zero → it leaves the destination and the units return to the
  pool; the rail's chips and the assigned total both move.
- Use assign-all on a short line → it takes everything remaining.
- Type `2.5` into a kg line → the fraction survives; stepping from there moves
  by whole units.
- Expand **two** cards showing the same line and raise it in one → the other's
  ceiling drops to match.
- With devtools, refuse an adjustment server-side → the message lands on that
  row and the figure returns to the server's value (FR-024).
- Raise a line from zero, then raise it again → the first call is a `POST
  .../lines`, the second a `PUT .../lines/{id}`. A second `POST` would come back
  409 ([research R13](./research.md)), so seeing one in the network panel means
  the dispatch is wrong.
- **Watch the field, not just the rail.** Tap `+` once: the stepper's own
  figure, the card's counts, the row's "Tienda" chip and the rail's chips must
  all move together. The field is the one thing that does not re-read the
  authoritative value on rebuild, so it is the one that goes stale
  ([research R6](./research.md)).
- **Hold `+` down.** The figure must track every press with no freeze, and the
  network panel must show **one** request after you stop, not one per press
  (~400 ms debounce, FR-025). Then tap `+` and immediately collapse the card —
  the pending change must still land.
- Check a `POST .../lines` body carries the fulfilment type you expect: pickup
  is `0` and delivery `1` since #171, the reverse of before
  ([research R15](./research.md)). Inverted values here corrupt data silently.

### 4.4 Adding a destination (US4)

- At 1440 the sheet is right-anchored over the rail and the cards stay visible
  behind it; at 390 it is a bottom sheet.
- It asks for address, contact, date and instructions and **no quantity**.
- Save → the sheet closes, the new card is last, badged, **expanded**, every
  line reading zero.
- Force a refusal → the sheet stays open with the entered values and no recorded
  destination changes.
- Resize across 1200 with the sheet open → the entered values survive.
- **Pick a delivery date, then save.** This must create the destination. A
  local `DateTime` dies in serialization before the request leaves, and
  surfaces as "no se pudo conectar con el servidor" — a connectivity message
  for a request that never touched the network ([research R16](./research.md)).
- Watch the create in the network panel: the body must carry `"lines": []`. An
  **absent** `lines` claims the whole sale — the one mistake here that silently
  produces a wrong sale rather than an error ([research R14](./research.md)).
- Assign every unit of the sale, then look at the add action → it is disabled
  with a reason, because an empty create on a fully-assigned sale is a 409.
  Lower one line and it becomes available again.

### 4.5 A mixed sale survives a restart (mbe-api#171)

- Capture a **Mixta** sale, assign part of it, then fully restart the app and
  reopen the sale from the sales list.
- It must come back **as mixed**: the counter row present, the remainder read
  as the counter's share, and "Finalizar venta" enabled. Before #171 it
  returned as plain delivery and could not be finished at all.
- Check `GET /sales-orders/{id}` carries `fulfillment_intent: 2`.
- Then the fallback path: on a sale captured *before* #171 (or with the field
  null), the same restart reads as plain delivery and the remainder blocks the
  close — "Entregar el resto en tienda" is what finishes it (FR-037a).

### 4.6 Removal and resume

- Remove a destination → its quantities return to the pool and the badges of the
  destinations after it renumber.
- The counter row offers no removal (FR-011).
- Reopen the sale from the sales list → the destinations, their lines and the
  distribution come back as they were.

---

## 5. What to check in the diff

- Zero literal colour, spacing, radius or font-size values in the changed files
  (SC-008) — every one through `spacing` / `shapes` / `typeRoles` / `elevations`.
- No new request. The step issues create, list, per-line add/update/remove and
  cancel, and nothing else — no polling, no refetch of the whole list after an
  assignment (SC-010).
- `deliveryControllerProvider`'s state shape unchanged; `distributionFor`,
  `isDistributionComplete` and the sweep untouched (FR-001).
