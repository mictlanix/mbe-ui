# Contract: POS Sale Lifecycle (amends spec 020's `pos-screen.md`)

**Feature**: 036-live-testing-fixes | **Amends**: `specs/020-point-of-sale/contracts/pos-screen.md`

## C1 — `confirm()` timing

**Before this feature**: `confirm()` is called once, on the Venta → Cobro transition, before any
payment exists.

**After this feature**: `confirm()` is called once, immediately before the **first** of these
three operations, whichever occurs first for a given sale:

1. `PaymentController.submit` — before its `createPayment` call.
2. The first delivery-order `create` in the Entrega step (delivery/mixed fulfillment).
3. Leaving Cobro on credit terms with no cash payment posted.

**Guarantees**

- A sale's `status` remains `draft` for the entire time it is on the Venta, Cobro, or Entrega
  step, until one of the three triggers above fires.
- `confirm()` is idempotent from the caller's perspective within one sale: callers MUST NOT call
  it a second time once it has already succeeded for that sale in the current session.
- A `confirm()` failure (empty order / zero-priced line / stock shortfall — the same 409 body
  shape `_toConfirmError` already parses) MUST be presented via the Venta step's existing
  per-line error rendering, with the user returned to Venta, regardless of which of the three
  triggers invoked it.

**Callers MUST NOT assume** stock is reserved or a folio (`serial`) is assigned before one of the
three triggers has run — `Sale.provisionalReference` remains the correct display fallback until
then, unchanged from today.

## C2 — Back-navigation

**New methods** on `PosStepController`:

```dart
bool canReturnToCapture({required bool isEditable, required bool hasNonCancelledPayments});
void returnToVenta();
```

**Contract**

- `canReturnToCapture` returns `true` iff `isEditable` (i.e. `sale.status == draft`, always true
  pre-confirm per C1) **and** `!hasNonCancelledPayments`.
- `hasNonCancelledPayments` MUST be computed by the caller from
  `orderPaymentsControllerProvider(sale.id)`, filtering out entries where `SalePayment.cancelled`
  is true. A loading or error state for that provider MUST be treated as `hasNonCancelledPayments
  == true` (deny the transition) — never as `false`.
- `returnToVenta()` MUST NOT make any server call. It is purely a client-side step change; the
  underlying sale is already `draft`.
- Once returned to Venta, every existing capture-step affordance (add line, remove line, change
  quantity, change warehouse) is available exactly as it is for a sale that never left Venta —
  no new gating is introduced by having visited Cobro/Entrega.

## C3 — Resume-selector bucketing (pending sign-off — see plan.md Risks)

If the "Borrador"/"Sin pagar" merge (research.md R3) is approved: `open_sales_selector` MUST
bucket every `draft` sale with `lineCount > 0` under one heading (label TBD with the requester),
and keep the existing `paid` bucket ("Sin entregar") unchanged. Until approved, this contract item
is **not yet in force** — implement C1/C2 first, and treat the bucket question as a follow-up
decision, not a blocker for the rest of this feature.
