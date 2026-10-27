# Wireframes: Credit Notes

**Spec**: [spec.md](./spec.md) | **Drawn**: 2026-10-27 | **Fidelity**: low

Drawn from the spec. Layout is indicative, not prescriptive: every dimension, colour and spacing comes from the design tokens (constitution §V).

**Drawn after the plan.** This run came after `/speckit-plan`, so the drawing was checked against [contracts/ui-contracts.md](./contracts/ui-contracts.md) as well as the spec. The open questions at the end name the contract each answer would change.

| Surface | Route / host | Gate | Stories |
|---|---|---|---|
| Cobro step, named customer | POS workspace, Cobro step | Credit Payments (83) read + Customer Payments (8) create | US1 |
| Cobro step, walk-in sale | POS workspace, Cobro step | the same + Customer Payments (8) read | US2 |
| Credit-note ticket dialog | over the Cobro step | as above | US2 |
| Notas de crédito | `/sales/credit-notes` | Credit Payments (83) read | US3 |
| Ver pago (existing) | `/sales/payments/:id` | Customer Payments (8) read | US3 (row target, unchanged) |

---

## Surface: Cobro step, named customer (US1)

The existing three-region step: capture pane (amount, quick amounts, method grid beside the keypad), applied-payments rail, and summary. Only the method grid and the applied rows change.

### State: credit available

```
┌ Cobro ── Venta 343990 · FERRETERÍA LÓPEZ ───────────────────────────────────────────────┐
│ ┌ capture pane ───────────────────────────────────────────┐ ┌ Pagos aplicados ─────────┐ │
│ │ Importe  [ 1,000.00                              ]       │ │ (none yet)               │ │
│ │ (Restante) ($500) ($1,000) (Mitad)                       │ │                          │ │
│ │ ┌ methods ─────────────────────────────┐ ┌ keypad ────┐  │ ├ Resumen ─────────────────┤ │
│ │ │ [▣ Efectivo     ] [▣ Tarjeta crédito ]│ │ 7  8  9    │  │ │ Total        $1,000.00   │ │
│ │ │ [▣ Sin referen. ] [▣ Req. referencia ]│ │ 4  5  6    │  │ │ Pagado           $0.00   │ │
│ │ │ [▣ Transferencia] [▤ Nota de crédito ]│ │ 1  2  3    │  │ │ Restante     $1,000.00   │ │
│ │ │ [  Req. referen.] [  Saldo $300.00   ]│ │ 0  .  ⌫    │  │ │ [ Continuar ] (disabled) │ │
│ │ └───────────────────────────────────────┘ └────────────┘  │ └──────────────────────────┘ │
│ └──────────────────────────────────────────────────────────┘                              │
└───────────────────────────────────────────────────────────────────────────────────────────┘
```

- **Credit tile** (`payment_credit_note_tile`): the existing `_MethodTile`, appended after the method tiles, with `Icons.receipt_long_outlined`. The second line is "Saldo $300.00" through the new subtitle override, replacing the reference hint (FR-001, C2).
- **Tap** spends `min(entered amount, balance, credit)`: here $300.00, the whole credit (FR-002). No keypad entry is needed: the amount field is already pre-filled with the balance, so spending all of it takes one tap (SC-001).
- The tile follows the grid's `enabled` rule: dimmed while a tender is in flight or the session is invalid, like every other tile.
- The money figures come from `fmt.display.currency`.

### State: after spending

```
┌ capture pane ─────────────────────────────────────────┐ ┌ Pagos aplicados ────────────────┐
│ Importe  [ 700.00                              ]       │ │ ▤ $300.00                    ↶  │
│ (Restante) ($500) ($700) (Mitad)                       │ │   Nota de crédito · Nº 300743   │
│ ┌ methods ─────────────────────────────┐               │ ├ Resumen ────────────────────────┤
│ │ [▣ Efectivo     ] [▣ Tarjeta crédito ]│   keypad      │ │ Total            $1,000.00      │
│ │ [▣ Transferencia]                     │               │ │ Pagado             $300.00      │
│ └───────────────────────────────────────┘               │ │ Restante           $700.00      │
└────────────────────────────────────────────────────────┘ └─────────────────────────────────┘
```

- The tile is gone, because the customer's only note is now on this sale and is left out of the credit (FR-001).
- **Applied row:** `AppliedPaymentsPanel`. The label leads with "Nota de crédito" instead of the method label "N/A" (FR-009, C4). It keeps the existing undo button, which works like any other application.
- **Several notes spent in one tap make one row each**, because each note is a separate application (R3).
- The amount field is re-filled with the new balance, as after any tender.

### State: partly applied (one of several notes failed)

```
┌ capture pane ─────────────────────────────────────────┐ ┌ Pagos aplicados ────────────────┐
│ ┌ ErrorBanner ──────────────────────────────────────┐  │ │ ▤ $300.00                    ↶  │
│ │ ⚠ Se aplicaron $300.00 de crédito; el resto no se │  │ │   Nota de crédito · Nº 300743   │
│ │   pudo aplicar.                                    │  │ │                                 │
│ │   El importe excede el saldo del pago.  (server)   │  │ │                                 │
│ └────────────────────────────────────────────────────┘ │ │                                 │
│ Importe  [ 700.00                              ]       │ ├ Resumen ── Restante $700.00 ────┤
│ ┌ methods ── … ── [▤ Nota de crédito · Saldo $150.00 ]│ └─────────────────────────────────┘
```

- This is the state where another register spent part of a note at the same time.
- The applied rows, the balance and the tile's credit are all re-read (FR-008). The tile shows what the server now says is left.
- **The message needs both lines.** Today `payment_step.dart` shows *either* the `ErrorBanner` (server error) *or* the issue line, and the server error wins. This state needs the applied amount and the server's reason together. See Open Question 1.

### State: no credit tile

Drawn once, because the grid is simply the existing one. The tile is absent, not disabled, when any of these hold:
- the customer holds no spendable credit
- every note is already on this sale
- the sale is cancelled or its balance is zero (FR-007)
- the user lacks Credit Payments read or Customer Payments create (FR-014)
- the credit is still loading (Open Question 2)

### Compact tier

```
┌ Cobro ───────────────────────────┐
│ Importe [ 1,000.00          ]     │
│ (Restante) ($500) ($1,000) (Mitad)│
│ [▣ Efectivo    ] [▣ Tarjeta crédi]│
│ [▣ Transferenc.] [▤ Nota de créd.]│
│                  [  Saldo $300.00]│
│ ┌ keypad ───────────────────────┐ │
│ │ …                             │ │
│ └───────────────────────────────┘ │
│ Pagos aplicados …                 │
│ Resumen … [ Continuar ]           │
└───────────────────────────────────┘
```

- Below 900 px the pane already stacks the grid above the keypad. The tile is one more grid cell, so it takes no new layout.
- The name ellipsizes; the "Saldo" line must not. It's an amount, which §VI never truncates. The extra-large-text test must cover it (T016).

---

## Surface: Cobro step, walk-in sale (US2)

### State: redeem tile

```
┌ methods ─────────────────────────────────────┐
│ [▣ Efectivo        ] [▣ Tarjeta crédito    ] │
│ [▣ Transferencia   ] [▤ Canjear nota de    ] │
│ [  Req. referencia ] [  crédito            ] │
└──────────────────────────────────────────────┘
```

- **Redeem tile** (`payment_credit_note_redeem_tile`): shown on every walk-in sale that passes the gates, because there's no customer balance to test (FR-005, C3). The second line is free for a hint such as "Escanea el ticket". See Open Question 4.
- On a walk-in sale this tile replaces the named-customer tile. The two never show together.

---

## Surface: credit-note ticket dialog (US2)

`showCreditNoteTicketDialog`, built on `ResponsiveDialog` (a regular dialog on wide screens, full screen on a phone). The precedent `payment_reference_dialog.dart` uses a plain `AlertDialog`; see Open Question 5.

### State: entry

```
┌ Canjear nota de crédito ──────────────────────────────┐
│ Número de ticket                                       │
│ [ ▌                                            ] [↵]   │
│ Escanea el código de barras del ticket o escríbelo.    │
│                                                        │
│                          [ Cancelar ]  [ Aplicar ]     │
│                                         (disabled)     │
└────────────────────────────────────────────────────────┘
```

- `credit_note_ticket_input`: autofocused, digits only. Enter submits, so a keyboard-wedge scanner works hands-free (SC-002).

### State: looking up

```
│ [ 300743                                       ] [⟳]   │
│ Buscando…                                              │
│                          [ Cancelar ]  [ Aplicar ]     │
│                                         (disabled)     │
```

- This lookup is the slow path while the `customer_payment` filter is missing: the walk-in customer's notes are scanned newest first (R4). A recent ticket is usually found on page 1. An old one can take several seconds, so the progress state is mandatory, not optional.

### State: found

```
│ [ 300743                                       ]       │
│ ┌──────────────────────────────────────────────────┐   │
│ │ Nota de crédito Nº 300743 · 29/09/2026            │   │
│ │ Saldo disponible                       $200.00    │   │
│ │ Se aplicará                            $200.00    │   │
│ └──────────────────────────────────────────────────┘   │
│                          [ Cancelar ]  [ Aplicar ]     │
```

- "Se aplicará" is `min(remaining, balance, entered amount)`. That's the C3 rule, made visible so the cashier sees the cap before confirming. See Open Question 3.
- `credit_note_ticket_confirm` applies it, closes the dialog, and the Cobro step re-reads (FR-008).

### State: refused (one block, four messages)

```
│ [ 300743                                       ]       │
│ ⚠ <message>                                            │
│                          [ Cancelar ]  [ Aplicar ]     │
│                                         (disabled)     │
```

| Case | Message | FR |
|---|---|---|
| No payment with that number, a payment that isn't a credit note, or one from another facility (404) | No hay una nota de crédito con ese número en esta sucursal. | FR-006 |
| Nothing remaining | Esta nota de crédito ya se usó por completo. | FR-006 |
| Already applied to this sale | Esta nota de crédito ya está aplicada a esta venta. | FR-006 |
| Issued to a named customer | Esta nota de crédito es de MARTHA VARELA ORTIZ. Haz la venta a su nombre para usarla. | FR-006a |

- The field keeps its text and stays focused, so the cashier can correct a digit and press Enter again.

### Compact tier

`ResponsiveDialog` goes full screen: a top bar with close, the title and "Aplicar"; the field and the found card fill the body. Nothing is dropped.

---

## Screen: Notas de crédito (`/sales/credit-notes`)

### State: populated

```
┌ Notas de crédito ──────────────────────────────────────────────────────────────────────────┐
│                                                                              (⚙ )          │
├────────────────────────────────────────────────────────────────────────────────────────────┤
│ Fecha             Cliente               Origen                          Emitido      Saldo  │
│ ──────────────────────────────────────────────────────────────────────────────────────────  │
│ 29/09/2026 16:56  PÚBLICO EN GENERAL    Devolución #9609 · Pedido #343972  $0.00     $0.00 │
│ 29/09/2026 12:55  MARTHA VARELA ORTIZ   Devolución #9605 · Pedido #343533  $0.00     $0.00 │
│ 22/09/2025 15:12  ⋯ (name loading)      Devolución #7781 · Pedido #305734  $1,025.00 $1,0… │
│ …                                                                                          │
├────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                 Filas por página 20 ▾   1–20 de 984   ‹ ›  │
└────────────────────────────────────────────────────────────────────────────────────────────┘
```

(The last amount is clipped only in this drawing. In the table, amounts are never truncated.)

- **Filter row:** `CatalogFilterBar` with **no** `search:` (the endpoint has none; §VI says omit it, not reserve it) and **no** `actions:`. `filters:` holds the badged `Icons.tune` button opening `showCatalogFilterSheet` (FR-011).
- **Body:** `CatalogListStateView<CreditNote>` → `DataTableView` with `CatalogPagination`, 20 per page, the page in the URL (FR-010).
- **Columns:**
  - *Fecha:* `fmt.display.dateTime`.
  - *Cliente:* `DataTableColumn.text`, ellipsis + tooltip. "⋯" while `customerDisplayNameProvider` resolves, `#id` on failure.
  - *Origen:* plain refund number, then the order number, which is a link when the user can read orders.
  - *Emitido* and *Saldo:* right-aligned, never truncated.
- **The figures are the server's** (FR-015). The first two rows show the mbe-api#277 defect as it really looks: $0.00 issued on legacy notes. See Open Question 6.
- **Row tap:** pushes Ver pago for the backing payment when the user can read customer payments (FR-012). No row icons: a credit note is never edited (plan §VI note).

### State: filter drawer

```
┌ Filtros ────────────────────────────────┐
│ Cliente                                  │
│ [ Buscar cliente…                    ▾ ] │   CatalogEntityPicker
│                                          │
│ Solo con saldo                     [●──] │   SwitchListTile
│                                          │
│                 [ Limpiar ]  [ Cerrar ]  │
└──────────────────────────────────────────┘
```

- The badge counts the active facets: customer chosen, switch on (FR-011).

### State: "Solo con saldo" on, no customer chosen

```
├────────────────────────────────────────────────────────────────────────────────────────────┤
│                         ⟳  Cargando notas de crédito…                                      │
│                    (reads every page once, about 10 requests today)                        │
├────────────────────────────────────────────────────────────────────────────────────────────┤
│ … then the open notes only, paged locally:                       1–1 de 1   ‹ ›           │
```

- The count comes from the filtered set, never from the server's `total` (mbe-api#278; spec edge case). The progress state is the shared loading view; the slow full read is a known interim cost (R8). See Open Question 7.

### State: loading · empty · filtered-empty · error · forbidden

```
┌──────────────────────────────┐  ┌──────────────────────────────┐  ┌──────────────────────────┐
│      ⟳ (shared loading)       │  │  No hay notas de crédito.     │  │ Ninguna nota coincide con │
└──────────────────────────────┘  └──────────────────────────────┘  │ los filtros. [Limpiar]    │
                                                                     └──────────────────────────┘
┌──────────────────────────────┐  ┌──────────────────────────────┐
│ No se pudo cargar. [Reintentar]│ │ No tienes acceso a las notas  │
└──────────────────────────────┘  │ de crédito. (no retry)        │
                                   └──────────────────────────────┘
```

- These are all `CatalogListStateView`'s own views (`ListEmptyView`, the filtered-empty view, `ListFailedView`), plus the forbidden view as on Pagos.
- A user without Credit Payments read never reaches this screen: no nav entry, and the route redirects to `/` (FR-013).

### Compact tier

`DataTableView` has no card mode, so the table scrolls sideways on a phone, the same limitation Pagos accepted. No column is dropped: amounts and origin are critical information under §VI.

---

## Surface: Ver pago (existing, unchanged)

The row lands on spec 054's payment view. Two known effects:
- A note from another facility opens as **not found** for non-editors (mbe-api#273, R10).
- The not-found view's button goes to Pagos, not back to this list (Open Question 8).

---

## Open Questions

**Status (2026-10-27):** the user accepted every assumed answer. Questions 1, 3, 4, 5 and 9 changed the design and are folded into contracts C2, C3, C4 and C6 and tasks T012, T013, T016, T018, T019 and T021. Questions 2, 6, 7 and 8 needed no change.

1. **How does the partial-failure state show both lines?** `payment_step.dart` renders the server `ErrorBanner` *or* the issue message, never both. Options: (a) render the issue line above the banner when both are set; (b) fold the applied amount into a custom banner. **Wireframe assumed (a).** It's a two-line change to the step's `error` widget and keeps the shared banner untouched. *Changes C2 and T012.*
2. **What does the tile show while the customer's credit loads?** Options: hidden until loaded; a placeholder tile. **Assumed hidden.** It's one quick request, and a tile that appears a moment later beats a placeholder that may turn into nothing. *Fits C2 as written.*
3. **Can the cashier change the amount inside the ticket dialog?** Options: no, it uses the Cobro amount field's value as the cap; or yes, an amount field in the dialog. **Assumed no**, with "Se aplicará" shown so the cap is visible. *Adds the "Se aplicará" line to C3.*
4. **What is the walk-in tile's second line?** Options: blank; a hint like "Escanea el ticket". **Assumed the hint.** The tile otherwise reads like a payment method with nothing to say. *Adds one l10n key to C6.*
5. **Which dialog component?** `payment_reference_dialog.dart` uses `AlertDialog`; spec 053 added `ResponsiveDialog` so a form dialog goes full screen on a phone. **Assumed `ResponsiveDialog`**, because this dialog holds a result card and should not be cramped on a phone. *Changes T018's "modelled on" note.*
6. **Should the list explain the $0.00 figures on legacy notes?** Until mbe-api#277 ships, almost every row reads Emitido $0.00, Saldo $0.00. Options: show as-is (FR-015); add a one-line notice above the table. **Assumed as-is.** The defect is upstream and temporary, and a notice would outlive the fix. Flagged so the walkthrough doesn't file it as a bug.
7. **Is a multi-second full read acceptable when "Solo con saldo" is turned on with no customer?** Options: accept it while #278 is open; require a customer before the switch can be used. **Assumed accept it** (R8), because FR-011 offers the toggle unconditionally.
8. **Should the not-found payment view return to the credit-notes list?** It always goes to Pagos (`payment_detail_screen.dart:100`). Options: leave it (the system back button returns correctly, because the row uses `push`); make the button pop when there's a route to pop. **Assumed leave it.** It's out of this spec's scope, and back works.
9. **Should an applied credit-note row show its ticket number?** C4 shows only "Nota de crédito". **Assumed it also shows "Nº {payment id}"**, so a cashier can match a row to the paper ticket they just scanned, and tell several spent notes apart. *Changes C4 and T013.*
