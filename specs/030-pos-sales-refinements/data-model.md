# Phase 1 Data Model: POS Sale & Delivery Refinements

**Feature**: 030-pos-sales-refinements | **Date**: 2026-08-20

No entity is added, no entity is fetched differently, and nothing new is
persisted. What this feature introduces is **one piece of view state**
(§1), **one derived figure** (§3) and **one new write** against a payload
that already exists (§2).

---

## 1. `QuantityStepperController` — view state

A `ChangeNotifier`, created and disposed by the host `State`, one per line
being edited. Never a provider: it is per-widget input state with no consumer
outside the widget that owns it, which constitution §II names as local UI
state (the same call spec 018 made for card expansion).

| Field | Type | Meaning |
|---|---|---|
| `accepted` | `String` | The last value the server is known to hold. Pushed in by the host on every rebuild (`sync(value)`); the only value a reset can restore to. |
| `pending` | `String?` | A value the cashier committed (stepped, or Enter-confirmed) that has not been accepted yet. `null` when nothing is in flight or waiting. |
| `typed` | `String?` | Unconfirmed text currently in the field. Never sent. Cleared by confirmation, by abandonment, and by teardown. |
| `min` | `String` | Inclusive floor. `'1'` on the capture surface, `'0'` on the delivery surface. |
| `max` | `String?` | Inclusive ceiling, or `null` for none. `claimable + already held` on the delivery surface; `null` on capture. |
| `debounce` | `Timer?` | The window that will flush `pending`. |
| `inFlight` | `bool` | A commit is awaiting its `onCommit` future. Does **not** gate input. |
| `resetTick` | `int` | Incremented on every discard. The widget animates when it changes; the value itself carries no meaning. |

**Displayed value** = `typed ?? pending ?? accepted`. The widget renders it
through `formattersProvider.field.quantity` (constitution §V's single
formatting surface); the controller stores wire-format decimal strings only.

### Transitions

| Trigger | Guard | Effect |
|---|---|---|
| `step(+1 / −1)` | result within `[min, max]` | `typed = null`; `pending = result`; restart `debounce` |
| `step(…)` | result outside bounds | nothing (the action is unavailable in the first place, so this is a defensive no-op) |
| `edit(text)` (keystroke) | — | `typed = text` |
| `submit(text)` | parses, within bounds | `typed = null`; `pending = parsed`; restart `debounce` |
| `submit(text)` | unparseable or out of bounds | `typed = null`; `resetTick++` |
| `abandon()` (focus lost) | `typed != null` | `typed = null`; `resetTick++` |
| `set(value)` (host-driven: claim-all, adjust-to-available) | within bounds | as `submit`, without touching focus |
| debounce fires | `pending != null`, `!inFlight` | `inFlight = true`; `await onCommit(pending)` |
| `onCommit → true` | `pending` unchanged meanwhile | `pending = null` |
| `onCommit → false` | — | `pending = null`; `resetTick++` |
| `onCommit` completes | `pending` changed meanwhile | flush again immediately (a tap landed mid-flight) |
| `sync(v)` from host | see precedence, below | |
| `dispose()` | `pending != null` | cancel `debounce`, fire the commit, swallow any throw (research R8) |

### `sync(v)` precedence (research R7)

| Controller state | Outcome |
|---|---|
| `pending != null` | `accepted = v`; displayed value unchanged — `pending` is newer |
| `typed != null`, `v != accepted` | `accepted = v`; `typed = null`; `resetTick++` |
| neither, `v != accepted` | `accepted = v`; no animation |
| `v == accepted` | nothing |

**Invariants**

- `pending` and `typed` are never both non-null.
- At most one `onCommit` future is outstanding per controller.
- `accepted` always satisfies `[min, max]` as the *server* sees it; the
  controller never invents a value outside the bounds it was given.
- Every value crossing the boundary is a wire-format decimal string —
  `Decimal` never escapes `money.dart`, per that file's own contract.

---

## 2. Destination header edit — the write

No new payload, no new field. The existing `DeliveryOrderUpdate` shape,
reached through `DeliveryOrderRepository.updateHeader` (already implemented,
never called until now).

| Field | Source in the sheet | Null means |
|---|---|---|
| `shipTo` | address picker (customer's own addresses) | unchanged |
| `contact` | contact picker (customer's own contacts) | unchanged |
| `date` | date picker | unchanged |
| `comment` | instructions field | unchanged |

**"Null means unchanged" is the server's rule, not a client choice** — 
`update_order` assigns only non-`None` fields and the generated serializer
omits nulls (research R9). Consequences the UI must respect:

- A field left as the destination had it is simply re-sent with the same
  value; there is no diffing requirement.
- **Clearing** a previously-set contact, date or comment is not expressible.
  The sheet therefore offers no clear affordance (spec Out of Scope).
- An empty instructions field is sent as `null`, i.e. *unchanged* — not as an
  erasure. This matches the create path, which already maps blank to `null`.

**State transition, client side**: `DeliveryController.updateDestination`
replaces exactly one entry of its `AsyncData<List<Destination>>` with the
server's response passed through the existing `_labelled` join, via the same
`_replace` helper `assignLine`/`adjustLine`/`dropLine` use. The list is never
refetched (FR-021), and no other destination's identity or lines change.

**Refusals** worth naming: `409` when the destination is no longer a draft
(`assert_editable`), `422` on a malformed payload. Both surface through
`AppError` into the sheet's existing `ErrorBanner` (FR-022).

---

## 3. The store's share per line — derived figure

Computed inside `DestinationCounterRow` from the two inputs it already
receives; nothing new is passed to it (research R11).

```text
storeShare(line) = (counterDestination == null
                      ? '0'
                      : line.perDestination[counterDestination.id] ?? '0')
                 + line.atCounter
```

| Consumer | Value |
|---|---|
| Expanded body row for a line | `storeShare(line)`, formatted, for **every** sale line, zeros included (FR-026) |
| Header line count | number of lines where `storeShare(line)` is non-zero |
| Header unit count | `Σ storeShare(line)` over all lines |

Both header figures now read from the same list the body renders (FR-028), so
they cannot disagree. Reduces to today's behaviour whenever only one of the
two terms is non-zero; differs only on a resumed mixed sale carrying both a
recorded counter destination and an unassigned remainder, where today's header
under-reports (research R11).

**Ordering**: the sale's own line order, i.e. the order of
`distribution`, which is built from `sale.lines`.

**Expansion state**: one `bool` in the widget's `State`, collapsed initially,
independent of every `DestinationCard`'s own flag (FR-025). Not persisted, not
a provider — same reasoning as §1.

---

## 4. What does *not* change

- `SaleLine`, `Sale`, `Destination`, `DestinationLine`, `LineDistribution`:
  untouched, including `Destination.lineCount`/`unitCount` (still used by the
  addressed cards' headers).
- `distributionFor`, `isDistributionComplete`: untouched. The store-share
  figure above is computed at the widget, not folded into
  `LineDistribution` — it is presentation arithmetic for one row, and adding a
  field to the entity would put a counter-pickup concept into a type the
  addressed cards and the rail also read.
- Every repository signature, including `updateHeader`'s. This feature adds a
  caller, not a contract.
