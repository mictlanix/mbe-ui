# Contract: the payment surface (Cobro step)

Refines `specs/020-point-of-sale/contracts/pos-screen.md` §3's Cobro step, and
picks up what `specs/023-pos-ux-improvements` listed as out of scope. The visual
reference is `artifacts/point_of_sale/POS_Adaptativo.dc.html` frame `2c`
(expanded) and its phone frame labelled "Paso 3 · cobro"; the mock's palette,
font sizes and pixel dimensions are a presentation, not a requirement — every
colour, inset, radius and size resolves through `Theme.of(context)` and the
spec 022 tokens.

The mock draws this step as "Paso 3 de 3". It is the **second** step here, and
this contract changes nothing about that (FR-002).

---

## 1. Composition

### ≥ 1200 px — two panes

```
┌ PaymentStep ─────────────────────────────────┬──────────────────────┐
│ [ErrorBanner]                     (on error) │ Pagos aplicados  (n) │
│ IMPORTE                     RESTANTE         ├──────────────────────┤
│      1,234.56  │  $1,234.56 de $2,000.00     │ ┌──────────────────┐ │
│ [Restante][$500][$1,000][Mitad]              │ │ $500.00 Efectivo │ │  ← scrolls
│ ┌ MÉTODO DE PAGO ─────────┐ ┌ TECLADO ─────┐ │ │           [undo] │ │
│ │ [tile] [tile]           │ │  7  8  9     │ │ └──────────────────┘ │
│ │ [tile] [tile]           │ │  4  5  6     │ │ ┌──────────────────┐ │
│ │ [tile] [tile]           │ │  1  2  3     │ │ │ $250.00 T. Déb.  │ │
│ └─────────────────────────┘ │  .  0  ⌫     │ │ └──────────────────┘ │
│ [ Referencia ]  (when required) └───────────┘ ├──────────────────────┤
│                                              │ Total      $2,000.00 │
│                                              │ Pagado       $750.00 │
│                                              │ Restante   $1,250.00 │
│                                              │ ───────────────────  │
│ [        Aplicar pago        ]               │ Cambio         $0.00 │
│                                              │ [   Continuar    ]   │
│                                              │ ⓘ Se habilita …      │
└──────────────────────────────────────────────┴──────────────────────┘
   capture pane (flex)                            rail (360 px, fixed)
```

The capture pane does not scroll. Only the applied-payments list does. The rail's
header and its summary block stay put (FR-006).

### 600–1200 px — one column, pinned footer

Same order, one column: the amount, the quick amounts, the method grid, the
keypad beneath it, the reference, the apply action, then the applied payments.
`PaymentSummaryPanel` is pinned to the bottom edge as a footer band, exactly as
`SaleTotalsBar` is on the capture step.

### < 600 px — one scrolling column, pinned footer

Identical to the above; the difference is that everything above the footer is a
single `ListView` (spec 020 FR-053, unchanged).

---

## 2. `PaymentStep` — the composer

| Responsibility | Detail |
|---|---|
| Shape | `MediaQuery.sizeOf(context).width >= LayoutBreakpoints.large` → two panes; otherwise one column (research R1) |
| Error | `ErrorBanner(draft.error)` at the top of the capture pane, dismissible, cleared by the controller on the next edit — today's behaviour, new position (FR-007) |
| Insets | `spacing.screenMargin` horizontally, `spacing.paneGutter` between the panes |
| Enabled flag | `!draft.submitting`, passed to every child — and nothing else (research R12) |
| Not its job | any figure derivation beyond today's `paid`; any request; any gate logic other than asking `PosStepController.canLeavePayment` |

It keeps its constructor: `PaymentStep({required Sale sale, required VoidCallback onClose})`.

## 3. `PaymentCapturePane` *(new)*

Order, top to bottom: amount, quick amounts, methods + keypad, reference, apply.

| Element | Key | Notes |
|---|---|---|
| Section label | — | `posAmountLabel`, uppercased, `typeRoles.metricLabel` with the letter-spacing `SaleTotalsBar._group` uses |
| Amount field | `payment_amount_field` | `TextField`, `textAlign: TextAlign.end`, `prefixText` = the sale's currency, `filled: true`, style `typeRoles.heroHeading` + mono + tabular figures (research R4). Stays typable and focusable |
| Remaining figure | — | beside the amount at ≥ 900 px of pane; the mock's "Restante por cobrar" block. Below that width it is dropped here — the summary already carries it |
| Quick amounts | — | unchanged set: `posQuickAmountRemaining`, up to three round notes above the balance, `posQuickAmountHalf`. `ActionChip`, one row, wrapping |
| Methods | see §4 | |
| Keypad | `number_pad_*` | `NumberPad(controller:, enabled:)` — untouched (research R3). Beside the methods when the pane ≥ 900 px, beneath them otherwise (research R2) |
| Reference | `payment_reference_field` | rendered only when `draft.requiresReference`; label `posPaymentReferenceLabel` |
| Apply | `payment_submit_button` | `FilledButton`, full pane width, at the pane's foot. Spinner while `draft.submitting`, disabled unless `draft.isSubmittable` — unchanged |

## 4. `PaymentMethodGrid` — tiles

`LayoutBuilder` + `Wrap`; two columns when the available width admits two tiles
of ≥ 260 px, one otherwise; tile height follows its content (research R6).

```
┌──────────────────────────────────┐  ┌──────────────────────────────────┐
│ [icon]  Efectivo                 │  │ [icon]  T. de Crédito         ✓  │
│         Sin referencia           │  │         Requiere referencia      │
└──────────────────────────────────┘  └══════════════════════════════════┘
        unselected: 1 px outlineVariant        selected: 2 px primary + fill
```

| Aspect | Rule |
|---|---|
| Key | `payment_option_<paymentMethodOptionId>` for configured options; `payment_method_<code>` for the fallback set — both verbatim as today |
| Icon | `paymentMethodIcon(option.paymentMethod)` (research R7) |
| Name | `option.name`; for the fallback, `paymentMethodLabel(l10n, code)`. Wraps or ellipsizes inside the tile |
| Secondary line | `posPaymentMethodRequiresReference` / `posPaymentMethodNoReference` |
| Selected | 2 px `colorScheme.primary` border, `elevations.engaged.surfaceColor` fill, trailing `Icons.check_circle` — never fill alone (FR-014) |
| Semantics | `Semantics(button: true, selected: …, label: name)`; focusable and activatable from the keyboard via `InkWell` (FR-017) |
| Loading / error | unchanged: `LinearProgressIndicator` while the options load, nothing rendered on failure (the rest of the step stays usable) |
| Fallback | unchanged set and unchanged posture — no `paymentCharge`, no reference required |

## 5. `AppliedPaymentsPanel` — the rail's list

| Aspect | Rule |
|---|---|
| Row | a card: leading circular icon (`paymentMethodIcon`), amount as the row's headline (`typeRoles.money`), method — and `posPaymentReferenceValue` when present — as the supporting line |
| Row key | `applied_payment_<id>` — verbatim as today |
| Pending validation | `posPaymentPendingValidation` on the supporting line, in the theme's warning-carrying colour role |
| Reversed | amount struck through, `posPaymentCancelled` on the supporting line, no reversal action |
| Reversal | trailing `IconButton` (`Icons.undo`, tooltip `posReverseAction`) → the existing mandatory-reason dialog, keys `reversal_reason_field` / `reversal_confirm_button`, unchanged |
| Count | the rail header shows `posAppliedPaymentsTitle` and the number of payments |
| Empty | `posNoAppliedPayments`, centred in the list region |
| Loading / error | unchanged |

## 6. `PaymentSummaryPanel` *(new)* — one widget, two homes

Used at the rail's foot at ≥ 1200 px and as the pinned footer band below it.
Same content, same order, in both.

| Row | Value | Style |
|---|---|---|
| `posPaymentTotal` | `sale.total` | label `typeRoles.metricLabel`, figure `typeRoles.money` |
| `posPaymentPaid` | `subtractAmounts(sale.total, sale.balance)` | same |
| `posPaymentBalance` ("Restante") | `sale.balance` | same, emphasized while non-zero |
| — | a hairline `outlineVariant` divider | |
| `posPaymentChangeLabel` | `changeFor(sale.balance)` | figure `typeRoles.metricValue` — permanent, reads `$0.00` when there is no change (FR-022) |
| Action | `posContinue` | key `payment_close_button`, `FilledButton.tonal` — **must stay in the `FilledButton` family** (research R11) |
| Hint | `posPaymentGateHint` | shown only while the action is disabled and the balance is outstanding (FR-024) |

| Aspect | Rule |
|---|---|
| Gate | `PosStepController.canLeavePayment(balance:, isCreditTerms:)` — asked, never reimplemented |
| Surface | `elevations.raised.surfaceColor` with a top `outlineVariant` hairline, square corners — the `SaleTotalsBar` treatment (research R8) |
| Provider | watches `paymentControllerProvider` so the change row tracks the keyed amount (research R9) |

## 7. What this contract does not change

- Any request, in count, order or payload (SC-009).
- The create-then-apply sequence, the change split on an over-tender, the
  reversal reason rule, the step gate, or the step order.
- `NumberPad` (research R3), its tests, or its four goldens.
- The controls' `enabled` conditions (research R12).
- The keys listed above, each of which an existing test addresses.
