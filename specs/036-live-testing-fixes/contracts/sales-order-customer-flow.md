# Contract: Sales Order Customer-First Flow

**Feature**: 036-live-testing-fixes | **Screen**: `order_screen.dart` (back-office "Pedidos")

## C1 — Customer required before any line

- While `sale == null || sale.customer == AppSettings.posDefaultCustomerId` (the order either
  doesn't exist yet, or exists only against the generic default), the order screen MUST render
  `CustomerBar` and MUST NOT render `ProductSearchField` or any other line-entry control.
- The confirm/save action MUST be disabled under the same condition.
- Once a specific (non-generic) customer is attached, every existing order-screen behavior
  resumes unchanged — this contract adds a gate, not a new mode.
- An order already persisted against the generic customer before this feature shipped MUST still
  open and display normally; this gate applies only to selecting that customer going forward, not
  to reading existing data.

## C2 — Generic-customer exclusion in the picker

`CustomerBar` gains a constructor flag:

```dart
const CustomerBar({ ..., this.excludeGenericCustomer = false });
```

- When `true`, the picker's search results MUST exclude any customer whose id equals
  `AppSettings.posDefaultCustomerId` (via the shared `isGenericCustomer` predicate — see
  `data-model.md` §5).
- The order screen MUST pass `excludeGenericCustomer: true`. Every other `CustomerBar` consumer
  (POS capture) MUST keep the default `false` — POS still needs to default to and allow that
  customer.

## C3 — Salesperson autofill

- Selecting a customer in the order screen's `CustomerBar` MUST, in the same update call that
  attaches the customer, also set the order's `salesperson` to that customer's
  `CustomerListItem.salesperson?.id` when present.
- When the selected customer has no associated salesperson, the order's `salesperson` field MUST
  be left unchanged (not cleared).
- The user MUST still be able to override the autofilled salesperson afterward via the existing
  manual picker; that override is NOT protected from being overwritten if the customer is changed
  again later (changing the customer re-applies the new customer's salesperson, per spec.md
  FR-018's explicit trade-off).
- The order header's salesperson field MUST display the resolved salesperson's name on load,
  including when it was set by autofill rather than manual selection (fixes today's blank-field
  bug for any pre-filled value).

## C4 — What this contract does not change

- No new mbe-api endpoint or request field is used. `SalesOrderCreate`/`SalesOrderUpdate` already
  carry `customer` and `salesperson`.
- The optional single-round-trip refinement (passing `customer`/`salesperson` directly to
  `SalesOrderRepository.open()`) is an implementation optimization, not a contract requirement —
  the create-then-update sequence is an equally valid implementation of C1-C3.
