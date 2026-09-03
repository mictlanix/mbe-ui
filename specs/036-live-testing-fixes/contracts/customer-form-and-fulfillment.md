# Contract: Customer Form Fields & Fulfillment-Mode Gating

**Feature**: 036-live-testing-fixes

## C1 — Customer form

- `code` MUST be an optional field in the Customer form: a customer MUST be creatable and
  savable with an empty `code`.
- `code`'s position in the form's field order MUST be immediately after `credit days`.
- The form MUST NOT render a "shipping" or "shipping required document" toggle, in either the
  main Customer form or the POS inline-create mini-form.
- Until mbe-api#198 ships and the client regenerates, a create request MUST still send `code` as
  an empty string (the generated field is non-nullable); an update request MUST omit `code` when
  the field is blank rather than sending `""`.

## C2 — Generic-customer predicate

A single function, exposed from `AppSettings` or a shared helper beside it:

```dart
bool isGenericCustomer(int customerId); // customerId == posDefaultCustomerId
```

Every consumer that needs to know "is this the walk-in customer" (the Sales Order picker, C1 of
`sales-order-customer-flow.md`; the fulfillment-mode gate, C3 below) MUST call this one function.
No consumer may independently compare against `posDefaultCustomerId` or any other id source.

## C3 — Fulfillment-mode gating

- The POS delivery-method selector MUST allow delivery and mixed fulfillment for any customer for
  which `isGenericCustomer(customer.id)` is `false`.
- It MUST refuse delivery and mixed fulfillment when `isGenericCustomer(customer.id)` is `true`,
  rendering the same non-blocking refusal message shape used today (the selection does not move,
  a message appears below the mode track) — only the predicate and message text change, not the
  interaction shape.
- When no customer is attached yet (`sale == null`), the selector MUST NOT refuse delivery/mixed
  — a mode may be chosen before a customer, per existing behavior.

## C4 — Mid-sale customer switch (new)

- When a sale's customer is changed (via `CustomerBar._updateHeader` or equivalent) to a customer
  for which `isGenericCustomer` is `true`, **and** the sale's current fulfillment mode is not
  `counterPickup`:
  1. The sale's mode MUST be reset to `counterPickup` (both the local `PosStepController` mode
     and the persisted `Sale.fulfillmentIntent`).
  2. The user MUST be shown a one-time notice explaining that the new customer cannot receive
     deliveries and the sale has been switched to pickup.
- This reset MUST happen automatically — the customer change itself is not blocked or refused,
  only its downstream effect on fulfillment mode.
