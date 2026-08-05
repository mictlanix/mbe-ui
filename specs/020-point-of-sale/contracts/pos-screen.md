# Contract: the Point of Sale screen

**Feature**: `020-point-of-sale` | **Route**: `/sales/pos` | **Shell**: renders
inside `AppShell` as a nav branch (FR-001)

This is the screen's own contract — the step machine, what each step owns, and
what survives a reload. It is the reference the widget tests assert against.

---

## 1. Layout

```text
┌─ AppShell app bar (unchanged: brand, title, UserMenuButton) ────────────┐
├─ POS header band (screen body, research §13) ───────────────────────────┤
│  [ open-sales selector ▾  #00282127 · 4 open today ]      [1·Venta ▸ 2·Cobro ▸ 3·Entrega] │
├─ Step content ──────────────────────────────────────────────────────────┤
│                                                                          │
│   capture / payment / delivery                                           │
│                                                                          │
├─ Step footer (totals + primary action) ─────────────────────────────────┤
└──────────────────────────────────────────────────────────────────────────┘
```

**Compact (< 600 px)**: the band collapses — the selector becomes a compact chip
and the stepper becomes a "Paso N de M" label (FR-053). The footer stays pinned.

---

## 2. Step machine

```text
                    counterPickup
        ┌──────────────────────────────────────┐
        │                                      ▼
    ┌────────┐  confirm   ┌─────────┐  paid  ┌──────┐
    │ Venta  │───────────▶│  Cobro  │───────▶│ done │
    └────────┘            └─────────┘        └──────┘
                               │ paid, delivery|mixed
                               ▼
                          ┌──────────┐  all distributed
                          │ Entrega  │──────────────────▶ done
                          └──────────┘
```

| Transition | Guard | Side effect |
|---|---|---|
| Venta → Cobro | ≥ 1 line; RBAC `salesOrders:update` | `POST .../confirm` — folio assigned, stock committed, lines frozen |
| Cobro → done | `balance == 0`, or `paymentTerms == netD`; mode is counter pickup | none |
| Cobro → Entrega | same balance guard; mode is delivery or mixed | none — destinations are created inside the step |
| Entrega → done | every unit distributed (delivery), or the remainder is accepted at the counter (mixed) | `POST /delivery-orders` `COUNTER_PICKUP` for the remainder, when any |

**Backwards navigation**: Venta ← Cobro is **not** offered once the sale is
confirmed (FR-041) — the step indicator shows Venta as complete and read-only.
Cobro ← Entrega is offered read-only, so a cashier can check what was taken.

**Editability**: `Sale.isEditable` (`status == draft`, data-model.md §1.1) gates
every Venta-step control, not only backwards navigation. Once confirmed,
`SaleLineRow`'s in-place edits, `CustomerBar`'s customer and payment-terms
controls, and `FulfillmentModeSelector` all render read-only with an
explanatory banner rather than offering an action the server will reject with
409 (FR-041, analysis finding C3).

---

## 3. What each step owns

| Step | Owns | Writes | Never touches |
|---|---|---|---|
| **Venta** | customer, fulfilment mode, main delivery address, terms, currency, lines | `PUT /sales-orders/{id}`, line create/update/delete | payments, destinations |
| **Cobro** | tender amount, method, reference, applied payments | `POST /customer-payments` + `/applications` | lines, destinations |
| **Entrega** | destinations, per-line distribution | `POST/PUT/DELETE /delivery-orders...` | lines, payments |

Each step is a separate widget subtree with its own controller; all three read
the same `posSaleControllerProvider`, and only that provider holds the `Sale`.
Because Cobro's writes go through `paymentControllerProvider` — a different
provider, talking to a different repository — nothing updates `Sale.balance`
automatically when a payment is applied. `paymentControllerProvider` MUST call
`posSaleControllerProvider`'s refresh after every successful application, or
`Sale.balance` goes stale and Cobro's own close gate (§2) never unlocks
(analysis finding I1).

---

## 4. State ownership

| Provider | Type | Holds | Lifetime |
|---|---|---|---|
| `posSaleControllerProvider` | `AsyncNotifier<Sale>` | The whole sale, replaced on every write (research §1); exposes a `refresh()` that re-fetches via `getById()` for callers outside its own mutations | The screen; disposed when a new sale starts |
| `posStepControllerProvider` | `Notifier<PosStepState>` | Current step, fulfilment mode, whether a write is in flight | The screen |
| `productLookupControllerProvider(query)` | `AutoDisposeAsyncNotifier` | Scan/search results | Per query |
| `paymentControllerProvider` | `Notifier<PaymentDraft>` | Amount being typed, selected method, reference, **payments taken this session** (research §11); calls `posSaleControllerProvider.refresh()` after each successful application (I1) | The screen |
| `deliveryControllerProvider` | `AsyncNotifier<List<Destination>>` | The destinations and their lines | The delivery step |
| `openSalesProvider` | `AutoDisposeAsyncNotifier<List<OpenSale>>` | Selector contents — `draft`, `completed`, and `paid` filtered client-side to an incomplete distribution (research §5, analysis finding C1); invalidated after confirm, after a payment closes a delivery/mixed sale, and after a new sale starts | The screen |

**Nothing is persisted locally** (constitution §VII). Everything above is
reconstructible from the server except the session-scoped payment list, whose
absence is disclosed to the cashier rather than hidden.

---

## 5. Reload and resume behaviour

| Situation on entry | Screen does |
|---|---|
| No sale selected | `POST /sales-orders` — a fresh draft (FR-002) |
| Selected sale is `draft` | Opens **Venta** with its lines and customer |
| Selected sale is `completed`, balance > 0 | Opens **Cobro**, lines read-only, balance shown; earlier payments not itemised (research §11) |
| Selected sale is `paid`, `shipTo` is the facility address | Nothing owed — offers to start a new sale |
| Selected sale is `paid`, `shipTo` is another address, distribution incomplete | Opens **Entrega** with the destinations already recorded |
| Selected sale is `cancelled` | Not offered by the selector |

---

## 6. Failure handling

Every write follows the same rule (FR-009): **the screen shows the last accepted
state**, the reason is rendered where the cashier can act on it, and the action
is retryable without re-entering anything else.

| Failure | Rendered as |
|---|---|
| Line rejected (margin, minimum quantity) | Inline on the field; previous value restored |
| Confirm rejected (stock, zero price) | Banner + per-line markers on the offending lines; stays on **Venta** |
| Payment rejected (currency, unapplied) | Banner on the payment step; the draft tender is kept |
| Destination rejected | Inline on that destination card only; other destinations unaffected (FR-037) |
| Network failure | Shared error banner; the action retries; the sale is re-fetched rather than assumed |

Errors are mapped to the shared domain error types and rendered with the shared
error widget (constitution §III) — never a raw `DioException` message (SC-008).

---

## 7. Accessibility and input

- The product field keeps focus across adds so consecutive scans need no clicks
  (FR-020).
- Enter submits the product field; Escape closes the results list.
- The number pad is a shared widget and is keyboard-equivalent — every amount
  reachable by typing (FR-043).
- Every icon-only control carries a tooltip/semantic label.
- No horizontal scrolling at any supported width (FR-053, SC-007).
