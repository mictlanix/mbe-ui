# Phase 1 — Data Model: POS Payment Step Look & Feel

**This feature introduces no entity, no field and no state.** It is a
presentation change over data that already exists. What follows is therefore an
inventory of what the new widgets *read*, so the implementation can be checked
against it — every row is existing, unchanged, and read-only from this
feature's point of view.

## Read by the step

### `Sale` (`features/sales/domain/entities/sale.dart`)

| Field | Used for | Changed? |
|---|---|---|
| `id` | keys the applied-payments listing and the reversal call | no |
| `facility` | the facility whose payment options are offered | no |
| `total` | the summary's Total row | no |
| `balance` | the summary's Remaining row, the paid derivation, the change derivation, the exit gate | no |
| `currency` | the amount display's currency indicator | no |
| `paymentTerms` | the exit gate (`netD` opens it with a balance outstanding) | no |

**Derived for display only** — neither is stored, and neither is new:

- **Paid** = `subtractAmounts(sale.total, sale.balance)` — the expression
  `payment_step.dart` already evaluates inline today.
- **Change** = `PaymentController.changeFor(sale.balance)` — the excess of the
  keyed amount over the balance, already implemented, already zero when the
  tender is at or under the balance.

### `PaymentDraft` (`payment/payment_controller.dart`)

| Field | Used for | Changed? |
|---|---|---|
| `amount` | the amount display; seeds the field's controller on mount (research R5) | no |
| `methodCode`, `paymentCharge` | which tile is marked selected | no |
| `requiresReference` | whether the reference field is shown | no |
| `reference` | the reference field's value | no |
| `submitting` | the `enabled` flag every control takes | no |
| `error` | the banner in the capture pane | no |
| `isSubmittable` | whether the apply action is enabled | no |

### `SalePayment` (`features/sales/domain/entities/sale_payment.dart`)

| Field | Used for | Changed? |
|---|---|---|
| `id` | the row key `applied_payment_<id>` | no |
| `customerPayment` | the reversal call | no |
| `methodCode` | the row's icon and method name | no |
| `amount` | the row's amount | no |
| `reference` | the row's supporting line | no |
| `isPendingValidation` | the row's pending marker | no |
| `cancelled` | the struck-through amount and the absent reversal action | no |

### `PaymentMethodOption` (`features/catalog/domain/…`)

| Field | Used for | Changed? |
|---|---|---|
| `paymentMethodOptionId` | the tile key `payment_option_<id>` | no |
| `name` | the tile's name | no |
| `paymentMethod` | the tile's icon, via the new `paymentMethodIcon(code)` mapping | no |
| `requiresReference` | the tile's secondary line, and whether selecting it shows the reference field | no |

When the facility has no options configured, the fallback set stays what it is
today — `PaymentMethod.cash`, `.creditCard`, `.debitCard`, `.eft`, keyed
`payment_method_<code>`, no `paymentCharge`, no reference required.

## Added to the shared kernel

One pure function, beside the label mapping it mirrors:

```dart
// lib/core/domain/payment_method.dart
IconData paymentMethodIcon(int code);
```

Total, per `PaymentMethod.fromCode`'s documented posture, with an unknown code
falling back rather than throwing. It holds no state and reads nothing.

## Not touched

`PaymentController`, `OrderPaymentsController`,
`FacilityPaymentOptionsController`, `PosStepController`, `PosSaleController`,
`CustomerPaymentRepository` and every generated client — no signature, no
provider, no request. SC-009 is the assertion of exactly this.
