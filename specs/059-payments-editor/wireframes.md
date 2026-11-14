# Wireframes: Payments Editor

**Spec**: [spec.md](./spec.md) | **Drawn**: 2026-11-13 | **Fidelity**: low

Drawn from the spec. Layout is indicative, not prescriptive. Every dimension, colour and spacing comes from the design tokens (constitution §V).

These were drawn **after** the plan, as specs 056 and 057's were. Answers go into [contracts/ui-contracts.md](./contracts/ui-contracts.md) and the spec, not into new decisions here.

## Screen: Pagos (`/sales/payments`)

### State: populated, user with Customer Payments create

```text
┌ Pagos ───────────────────────────────────────────────────────────────────────────────┐
│ [🔍 Buscar cliente o folio…]  [⚙ Filtros]      [+ Registrar pago] [Mi sucursal|Todas] │
├───────┬────────────┬────────────────────────┬──────────┬────────────┬──────────┬─────┤
│ Folio │ Fecha      │ Cliente                │ Método   │      Monto │ Sin apl. │  ✓  │
├───────┼────────────┼────────────────────────┼──────────┼────────────┼──────────┼─────┤
│ 9120  │ 2026-11-13 │ Ferretería López       │ Transf.  │  $3,000.00 │ $3,000.00│     │
│ 9119  │ 2026-11-12 │ Materiales del Norte   │ Efectivo │    $500.00 │     $0.00│  ✓  │
├───────┴────────────┴────────────────────────┴──────────┴────────────┴──────────┴─────┤
│                                                     1–20 de 295k   ‹  1  2  3  ›       │
└──────────────────────────────────────────────────────────────────────────────────────┘
```

- **The only change** is "Registrar pago", a `FilledButton.icon` in `CatalogFilterBar.actions` ahead of the scope switch, shown only with `can(customerPayments, create)` (FR-010, C1).
- Everything else is spec 054/055's list, unchanged.

### State: user without create

The same as today: no button. Nothing is disabled or greyed (SC-005).

### Compact tier

```text
┌ Pagos ──────────────────────────────┐
│ [🔍 Buscar…]  [⚙]          [+ Pago] │
│ …spec 055 compact rows…             │
└─────────────────────────────────────┘
```

- The button uses the short label "Pago", as refunds do with `refundsNewShort`.
- The scope switch already moves to the filter sheet at this tier (spec 054).

## Dialog: Registrar pago (`ResponsiveDialog`, C2)

### State: empty

```text
┌ Registrar pago ───────────────────────────────────────┐
│ Cliente                                               │
│ [ Buscar cliente…                                  ▾] │
│ Tipo                                                  │
│ [● Abono a crédito ][  Anticipo  ]                    │
│ Método                         Referencia             │
│ [ Selecciona…            ▾]   [                    ]  │
│ Monto                          Moneda                 │
│ [                     0.00]    MXN                    │
│                                                       │
│                               [Cancelar] [Registrar]  │
└───────────────────────────────────────────────────────┘
```

- **Cliente:** `CatalogEntityPicker<CustomerListItem>`, shown as "code — name" (FR-011).
- **Tipo:** `SegmentedButton<PaymentType>`, defaulting to "Abono a crédito".
- **Método:** a dropdown of the facility's payment options, or `PaymentMethod` tenders when the facility has none. It is an option, so it carries the method and its `payment_charge`.
- **Referencia:** max 50 characters. Its label becomes "Referencia *" when the option requires one.
- **Monto:** `PaymentAmountField`.
- **Moneda:** read-only text. It becomes a dropdown only with `multiCurrencyEnabledProvider`.
- **Layout:** `ResponsiveFormGrid`, two columns at regular width.
- **"Registrar":** enabled at all times. Validation runs on press, so the errors show where they apply.

### State: validation errors

```text
┌ Registrar pago ───────────────────────────────────────┐
│ Cliente                                               │
│ [ 1 — Público en general                           ▾] │
│ ⚠ Elige un cliente con nombre; el público en general  │
│   no puede tener anticipos ni abonos.                 │
│ Tipo                                                  │
│ [  Abono a crédito ][● Anticipo  ]                    │
│ Método                         Referencia             │
│ [ Efectivo               ▾]   [                    ]  │
│ ⚠ Para registrar efectivo necesitas una caja abierta  │
│   hoy. [Ir a cajas]                                   │
│ Monto                                                 │
│ [                     0.00]                           │
│ ⚠ Escribe un monto mayor que cero.                    │
│                               [Cancelar] [Registrar]  │
└───────────────────────────────────────────────────────┘
```

- **Field errors:** each shows under its own field (FR-012, FR-015).
- **Cash session:** the error appears only when the method is cash. It is checked on press against a fresh read of the session. "Ir a cajas" links to the sessions list, as `PosSessionBlockedBanner` does.

### State: saving

```text
│                         [Cancelar̶] [⟳ Registrando…]   │
```

- Both buttons are disabled, and the dialog can't be dismissed (`dismissible: false`) (FR-013, SC-006).

### State: server refusal / unknown result

```text
┌ Registrar pago ───────────────────────────────────────┐
│ ┌───────────────────────────────────────────────────┐ │
│ │ ⚠ La caja se cerró. No se registró el pago.       │ │
│ └───────────────────────────────────────────────────┘ │
│ …fields, still filled…                                │
```
```text
│ ┌───────────────────────────────────────────────────┐ │
│ │ ⚠ No sabemos si el pago se registró: se perdió la │ │
│ │   conexión. Búscalo en Pagos antes de reintentar. │ │
│ └───────────────────────────────────────────────────┘ │
```

- **Banner:** `FormErrorBanner` at the top, with text from `localizeProblem` (§III).
- **Unknown result:** a network or timeout failure gets the "unknown" wording, and the form stays as it was.

### State: success

The dialog closes, the list refreshes, and the app pushes `/sales/payments/<new id>`. That view shows "Sin aplicar" equal to the amount, "Aplicar a pedido" and "Ver ticket".

### Compact tier

A full-screen `ResponsiveDialog` with fields in one column, in this order: Cliente, Tipo, Método, Referencia, Monto, Moneda. The actions are pinned at the bottom.

## Screen: Payment view (`/sales/payments/:paymentId`)

### State: populated, unapplied money, user with create + update

```text
┌ ← Pago 9120 ─────────────────────────────────────────────────────────────────────────┐
│  Monto            Aplicado          Sin aplicar                                       │
│  $3,000.00        $1,500.00         $1,500.00                  [⊕ Aplicar a pedido]   │
├──────────────────────────────────────────────────────────────────────────────────────┤
│ Cliente  Ferretería López       Tipo     Abono a crédito    Método  Transferencia     │
│ Fecha    2026-11-13 10:42       Ref.     SPEI 88213         Sucursal Centro           │
│ [🧾 Ver ticket]                                                                       │
├──────────────────────────────────────────────────────────────────────────────────────┤
│ Aplicaciones                                                                          │
├──────────┬────────────┬─────────┬──────────────┬──────────────────┬────────────┬─────┤
│ Pedido   │   Aplicado │  Cambio │ Aplicó       │ Fecha            │ Estado     │     │
├──────────┼────────────┼─────────┼──────────────┼──────────────────┼────────────┼─────┤
│ #1047    │  $1,500.00 │   $0.00 │ M. Pérez     │ 2026-11-13 10:45 │ —          │  ↶  │
│ #1041 ░░ │  $1,500.00 │   $0.00 │ J. Ruiz      │ 2026-11-12 18:02 │ (Revertida)│     │
└──────────┴────────────┴─────────┴──────────────┴──────────────────┴────────────┴─────┘
```

- **Summary:** the same as spec 054. "Aplicar a pedido" is an `OutlinedButton.icon`, shown when `unapplied > 0.01` and with `can(customerPayments, create)` (FR-005, C3).
- **Table:** `DataTableView<PaymentApplication>`, as today, with a trailing action column. "↶" is the reverse `IconButton`, shown on live rows with `can(customerPayments, update)` (FR-001). Reversed rows stay greyed with `PaymentReversedChip` (FR-003).
- **Ver ticket:** unchanged (spec 055). For a freshly recorded payment it is the print path (FR-014).

### State: fully applied

There is no "Aplicar a pedido" button, and the summary shows "Sin aplicar $0.00". Live rows still offer "↶".

### State: user with read only

The view looks exactly as in spec 055: no apply button and no action column. The column is dropped, not left empty.

### State: after a write

The applications reload in place, and a `SnackBar` says "Aplicación revertida" or "Pago aplicado a #1047". The summary figures are the server's.

### Compact tier

```text
┌ ← Pago 9120 ────────────────────────┐
│ Sin aplicar  $1,500.00              │
│ Monto $3,000.00 · Aplicado $1,500.00│
│ [⊕ Aplicar a pedido]                │
│ …facts, one column…                 │
│ Aplicaciones                        │
│ #1047        $1,500.00          ↶   │
│ M. Pérez · 2026-11-13 10:45         │
│ #1041 ░░     $1,500.00 (Revertida)  │
│ J. Ruiz · 2026-11-12 18:02          │
└─────────────────────────────────────┘
```

- At this tier `DataTableView` falls back to its stacked rows.
- "Cambio" moves into the second line only when it isn't zero.
- "↶" stays on the first line.

## Dialog: Revertir aplicación (shared, C4)

### State: empty reason

```text
┌ Revertir aplicación ──────────────────────────────┐
│ $1,500.00 aplicados al pedido #1041.              │
│ Motivo *                                          │
│ [                                               ] │
│                                            0/500  │
│                         [Cancelar] [Revertir̶]     │
└───────────────────────────────────────────────────┘
```

- Confirm stays disabled while the trimmed text is empty (FR-002).
- The header line names the amount and the order, so the user reverses the right row.
- This one dialog serves the POS, Pagos and Pedidos.

### State: order has refunds

```text
┌ Revertir aplicación ──────────────────────────────┐
│ $1,500.00 aplicados al pedido #1041.              │
│ ┌───────────────────────────────────────────────┐ │
│ │ ⚠ Este pedido tiene devoluciones. Revertir el │ │
│ │   pago no deshace la devolución.              │ │
│ └───────────────────────────────────────────────┘ │
│ Motivo *                                          │
│ [ Aplicado al pedido equivocado                 ] │
│                          [Cancelar] [Revertir]    │
└───────────────────────────────────────────────────┘
```

- The warning is shown when the order has a completed refund (FR-004). It is a caution, so it doesn't block.

### State: refused (already reversed, busy)

`FormErrorBanner` shows the localized text, the dialog stays open (the user closes it with "Cancelar"), and the view reloads behind it (spec edge case).

## Dialog: Aplicar a pedido (C5)

### State: populated

```text
┌ Aplicar pago #9120 ─────────────────────────────────────────────┐
│ Sin aplicar: $1,500.00 MXN                                      │
│ [🔍 Pedido o folio…                                           ] │
├────┬────────┬───────┬────────────┬─────────────┬────────────────┤
│    │ Pedido │ Folio │ Fecha      │       Total │          Saldo │
├────┼────────┼───────┼────────────┼─────────────┼────────────────┤
│ ○  │ #1047  │ 812   │ 2026-11-10 │   $2,400.00 │      $1,800.00 │
│ ●  │ #1052  │ —     │ 2026-11-11 │     $900.00 │        $900.00 │
├────┴────────┴───────┴────────────┴─────────────┴────────────────┤
│ Monto a aplicar                                                 │
│ [                                                       900.00] │
│ Máximo $900.00                                                  │
│                                       [Cancelar] [Aplicar]      │
└─────────────────────────────────────────────────────────────────┘
```

- **Order list:** single choice, `RadioListTile` rows in a bounded `ListView`. The rows are the customer's outstanding orders in MXN only (FR-006).
- **Order label:** `#id`, the label the payment view, the reverse dialog and the snackbar use. Folio (`serial`) is secondary and "—" when absent.
- **Search:** by order number or folio, on the server (it matches either).
- **Monto:** prefilled with `min(saldo, sin aplicar)`, with "Máximo" stating that bound (FR-007). There is no change field (FR-008).

### State: amount out of bounds

```text
│ [                                                      1200.00] │
│ ⚠ No puede ser más de $900.00.                                  │
│                                       [Cancelar] [Aplicar̶]      │
```

### State: empty

```text
┌ Aplicar pago 9120 ─────────────────────────────┐
│ Sin aplicar: $1,500.00 MXN                     │
│                                                │
│   Este cliente no tiene pedidos por pagar      │
│   en MXN.                                      │
│                                     [Cerrar]   │
└────────────────────────────────────────────────┘
```

- `CatalogListStateView`, empty variant.

### State: loading / load error

A `CatalogListStateView` spinner while loading. On a load error it shows its retry state, and the amount and confirm controls are hidden.

### State: server refusal

`FormErrorBanner` above the list shows, for example, "El pedido ya está pagado." The list and the payment's remainder reload, the selection clears, and the dialog stays open (FR-009).

### Compact tier

A full-screen dialog. Each row stacks "#Pedido · Fecha" over "Saldo"; Folio and Total are dropped, since the order number and balance are what the choice depends on. The amount field and actions are pinned at the bottom.

## Screen: Pedidos order (`/sales/orders/:orderId`), completed order

### State: header with the new action

```text
┌ ← Pedido 1041 · Entrega ●─○ ─────────────────────────────────────────────────────────┐
│ Cliente Ferretería López   Estado (Pagado)   Prioridad [Normal▾]                      │
│                                            [Ver pedido] [Pagos] [Devolver]            │
├──────────────────────────────────────────────────────────────────────────────────────┤
│ …DeliveryStep, unchanged…                                                            │
```

- **"Pagos":** a `TextButton` in the `OrderHeaderPanel` trailing group. It is shown when the status is completed or paid and the user has `can(customerPayments, read)` (FR-016, C6).
- It isn't shown on a draft or a cancelled order.
- It isn't shown on an order the foreign-order guard declines, because the whole workspace is replaced there.

### Dialog: Pagos del pedido

```text
┌ Pagos del pedido 1041 ────────────────────────────────────────┐
│ Transferencia · SPEI 88213        $1,500.00              ↶  ↗ │
│ Cambio $0.00 · 2026-11-12 18:02                               │
│ Efectivo ░░                         $200.00   (Revertido)   ↗ │
│ Cambio $50.00 · 2026-11-10 09:15                              │
│                                                     [Cerrar]  │
└───────────────────────────────────────────────────────────────┘
```

- **Body:** `AppliedPaymentsPanel(showChangeAndDate: true)`, with the same rows as the POS sale detail (FR-016).
- **"↶":** shown on live rows with `can(customerPayments, update)`. It opens the shared reverse dialog. Afterwards the panel and the header's "Estado" refresh (FR-017).
- **"↗":** opens `/sales/payments/<payment id>` and closes the dialog (FR-018).

### State: empty / forbidden

```text
│        No se han aplicado pagos a este pedido.               │
```
```text
│        No tienes permiso para ver los pagos.                 │
```

- The forbidden text reuses `posSaleDetailPaymentsForbidden`, shown on a 403, as in `_PaymentsSection`.

### Compact tier

The header's trailing group already wraps. The dialog goes full screen, and each row keeps the "↶ ↗" icons on its first line.

## Open Questions

**Resolved 2026-11-13.** The user accepted the recommendation for Q1, and Q2–Q5 as drawn. The answers are in spec.md (Clarifications, FR-002, FR-005) and contracts C2–C6. For Q1, mbe-api#308 was filed and "Aplicar a pedido" is hidden on another facility's payment until it ships.

1. **Applying a payment from another facility.** The server lists outstanding orders from the **caller's** facility only (mbe-api `search_outstanding`, `SalesOrder.facility == current.facility_id`). Take a Payments Editor in Centro opening a Norte payment: the dialog offers Centro's orders, not the Norte orders the customer most likely owes.
   - Options:
     - (a) Accept it and say so in the dialog. Editors switch facility to apply.
     - (b) Hide "Aplicar a pedido" on another facility's payment.
     - (c) File an mbe-api issue for a `facility` param on outstanding-orders.
   - Wireframe assumed: (a) with a note. Recommended: (b) now, and (c) filed.
2. **"Registrar" when the walk-in customer is picked.** The wireframe flags it under the field when the user presses save. The alternative is to leave the walk-in customer out of the picker's results.
   - Wireframe assumed: flag on save. The walk-in customer is still a valid search hit elsewhere, and silently missing results confuse people.
3. **After recording, apply right away?** One option is to add "Registrar y aplicar" in the dialog.
   - Wireframe assumed: no. The payment view opens with "Aplicar a pedido" visible, one tap away (SC-002 still fits in 2 minutes).
4. **Should Pedidos' "Pagos" show a count, e.g. "Pagos (2)"?** That would cost a request on every order open.
   - Wireframe assumed: no count. The dialog loads on open.
5. **Reverse dialog header (amount + order).** The spec doesn't ask for it, but it prevents reversing the wrong row. The POS dialog today shows only "Motivo".
   - Wireframe assumed: add it everywhere, including the POS. It's an addition, not a behaviour change.
