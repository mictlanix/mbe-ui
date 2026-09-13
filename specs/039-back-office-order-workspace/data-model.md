# Phase 1 Data Model: Back-Office Order Workspace

**Feature**: `039-back-office-order-workspace` | **Date**: 2026-09-11

This feature introduces **no new domain entity**. It adds one piece of UI-only
state and one optional field to an existing entity. Everything else is reused.

---

## 1. Reused entities (unchanged)

| Entity | Where | Used for |
|---|---|---|
| `Sale` | `domain/entities/sale.dart` | The order itself: status, lines, totals, customer, terms, priority, promise date, `fulfillmentIntent` |
| `SaleLine` | same | One product on the order |
| `Destination` | `domain/entities/destination.dart` | One planned shipment: ship-to, contact, date, comment, line quantities |
| `LineDistribution` | `domain/entities/line_distribution.dart` | Computed, not stored — ordered vs assigned vs remaining per line |
| `FulfillmentMode` | `domain/entities/fulfillment_mode.dart` | Pinned to `delivery` for every order this workspace raises (FR-021) |
| `Customer`, `CustomerListItem` | `features/catalog/domain` | Picker, price list, credit line, addresses and contacts |

No field is added to, or removed from, any of these by this feature — with the
single exception in §3.

---

## 2. New: `OrderStep` and `OrderStepState` (UI-only)

The workspace's own step machine. Mirrors `PosStepState` in shape and lifetime
deliberately, so the two hosts read alike, but shares no code with it: the
vocabularies differ and a union of both would serve neither (research R1).

```
OrderStep = cliente | venta | entrega
```

| Field | Type | Notes |
|---|---|---|
| `current` | `OrderStep` | Defaults to `cliente` — a new order has no customer yet |

**Never persisted.** Reconstructed from the order's own `status` when it is
reopened (§4), exactly as `PosStepState` is reconstructed rather than stored.

### Transitions

| From | To | Guard |
|---|---|---|
| `cliente` | `venta` | A non-generic customer is attached and the draft is open (FR-009, FR-014) |
| `venta` | `entrega` | At least one line; no write outstanding; unconfirmed edits resolved (FR-007, FR-008, FR-022) |
| `entrega` | `venta` | **Only while the order is still a draft** (FR-006) — once a destination exists the order is committed and its lines are fixed (spec A2) |
| `venta` | `cliente` | While the order is a draft; changing the customer reprices every line (spec edge cases) |
| any | — | No transition once `status != draft`; the workspace is read-only (FR-034) |

There is deliberately **no** transition that commits the order. Commitment is a
side effect of creating the first destination, because the server permits no
other ordering (research R2).

---

## 3. Extended: `Sale.origin`

Blocked on [mbe-api#209](https://github.com/mictlanix/mbe-api/issues/209).

| Field | Type | Notes |
|---|---|---|
| `origin` | `SaleOrigin?` | `null` = never recorded. Not a default value — an order that predates the field genuinely has no knowable origin (spec A9) |

```
SaleOrigin = pointOfSale | backOffice
```

Mapped from the generated DTO in `Sale.fromResponse` once codegen has run
(constitution III). Written once, at create, by this workspace; never edited.

**Ownership of the question, before and after #209.** Until the field exists,
the register-shaped check in research R5 answers "did this workspace raise it?"
for every order. Once the field exists it answers that question for every order
that *carries* one, and the R5 check remains as the fallback for the `null`
rows — orders predating FR-051, which include every order the previous
back-office editor raised and which SC-008 requires to keep reopening. The
decision table:

| `origin` | Decision |
|---|---|
| `backOffice` | resume (§4) |
| `pointOfSale` | decline (FR-053) |
| `null` | fall back to R5's three register-shaped signals |

FR-052's "no proxy" rule binds the first two rows, which are the whole of the
population from FR-051 onward. A `null` row has no field to read; the fallback
is the only answer available, and A9 states it as the deliberate one.

---

## 4. Derived: which step a reopened order resumes on

Not stored anywhere. A pure function of the order (research R2):

| `Sale.status` | Resume on | Why |
|---|---|---|
| `draft` | `venta` | Nothing is committed, so no destination can exist |
| `completed` | `entrega` | Only the first destination create could have committed it |
| `paid` | `entrega` | Collected elsewhere; the distribution may still be owed |
| `cancelled` | none — read-only | |

An order that is not this workspace's own is declined **before** this table is
consulted (§3's decision table, FR-053), so no row here has to cope with a
register sale. A legacy order that passes that check — no recorded origin and
none of the register-shaped signals — reaches this table and resumes on exactly
the same rules as any other, which is what SC-008 asks for.

---

## 5. Validation rules, and where each is already enforced

| Rule | Source | Enforced by |
|---|---|---|
| Customer is required, and must not be the generic walk-in customer | FR-009, FR-011, FR-012 | `AppSettings.isGenericCustomer`; `CustomerBar.excludeGenericCustomer` filters the picker |
| Order opens carrying its customer | FR-014 | `updateHeader`'s first-write fast path → `POST /sales-orders` with `customer` |
| Fulfilment intent is `delivery` | FR-015, FR-021 | Written at attach; `FulfillmentModeSelector` is not rendered |
| At least one line before leaving Venta | FR-022 | `SaleTotalsBar.onContinue == null` when `lineCount == 0` |
| No write outstanding before a transition | FR-007 | `pendingWritesProvider(saleWritesScopeProvider)` |
| Unconfirmed edits resolved before a transition | FR-008 | `resolveUnconfirmedEdits(context, ref, scope)` |
| Every unit assigned before closing delivery | FR-030 | `isDistributionComplete(..., isMixed: false)` — existing behaviour |
| Delivery requires a committed order | spec A2 | **Server**: 409 from `POST /delivery-orders` |
| No zero-priced line, sufficient stock | FR-033 | **Server**: refusal on confirm, names the offending products |
| Priority stays editable after commitment | FR-035 | `canEditPriority = canUpdate` alone |

The two rows marked **Server** are the ones the client must not attempt to
duplicate — it surfaces the refusal rather than pre-empting it (constitution VII:
mbe-api owns the canonical document).
