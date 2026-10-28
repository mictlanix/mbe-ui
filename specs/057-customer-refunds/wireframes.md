# Wireframes: Customer Refunds

**Spec**: [spec.md](./spec.md) | **Drawn**: 2026-10-28 | **Fidelity**: low

Drawn from the spec. Layout is indicative, not prescriptive. Every dimension, colour and spacing comes from the design tokens (constitution §V).

These were drawn **after** the plan, as spec 056's were. The answers are folded into [contracts/ui-contracts.md](./contracts/ui-contracts.md) rather than the spec.

## Screen: Devoluciones (`/sales/refunds`)

### State: populated

```text
┌ Devoluciones ─────────────────────────────────────────────────────────────────────────┐
│ [⚙ Filtros (1)]  Estado: Abiertas ×                              [+ Nueva devolución]  │
├────────┬────────────┬──────────────────────────┬──────────┬─────────────┬─────────────┤
│ Folio  │ Fecha      │ Cliente                  │ Pedido   │ Estado      │       Total │
├────────┼────────────┼──────────────────────────┼──────────┼─────────────┼─────────────┤
│ —      │ —          │ Ferretería López S.A. de…│ #18233   │ (Abierta)   │       $0.00 │
│ 412    │ 2026-10-27 │ Público en general       │ #18190   │ (Confirmada)│     $350.00 │
│ —      │ —          │ #5521 …                  │ #18102   │ (Cancelada) │     $120.00 │
├────────┴────────────┴──────────────────────────┴──────────┴─────────────┴─────────────┤
│                                                     1–20 de 57   ‹  1  2  3  ›         │
└───────────────────────────────────────────────────────────────────────────────────────┘
```

- **Filter row:** `CatalogFilterBar` shows the badge and the active facet chips. "Nueva devolución" is a `FilledButton.icon` in the bar's trailing slot, shown only with `can(customerRefunds, create)` (FR-002). There is no search slot until mbe-api#285.
- **Table:** `DataTableView<CustomerRefundSummary>` with `CatalogPagination` (FR-013).
  - **Folio and Fecha:** "—" for a draft.
  - **Cliente:** `PaymentCustomerName`. It shows "…" while the name loads and `#id` if the lookup fails (R7, interim #284).
  - **Pedido:** a link through `orderLinkTargetProvider` (FR-015).
  - **Estado:** a `StatusChip<RefundStatus>`.
  - **Total:** right-aligned and never truncated.
- **Interaction:** a row tap opens `/sales/refunds/{id}`. There is no row Edit icon.
- **Order:** newest first, the server's order, until #285.

### State: filter sheet

```text
┌ Filtros ──────────────────────────────┐
│ Estado                                │
│ [Todas][Abiertas][Confirmadas][Canc.] │
│ Cliente                               │
│ [ Buscar cliente…                  ▾] │
│ Pedido                                │
│ [ 18233                             ] │
│                    [Limpiar] [Listo]  │
└───────────────────────────────────────┘
```

- `showCatalogFilterSheet` holds:
  - a `SegmentedButton` for Estado;
  - `CatalogEntityPicker<CustomerListItem>` for Cliente;
  - a numeric `TextField` for Pedido.
- Each change writes its facet and resets the page to 0 (FR-014).

### State: new-refund dialog

```text
┌ Nueva devolución ─────────────────────────────┐
│ Número de pedido                              │
│ [ 18190                                     ] │
│ ⚠ El pedido 18190 no está pagado. Cancélalo   │
│   en lugar de hacer una devolución.           │
│                        [Cancelar] [Continuar] │
└───────────────────────────────────────────────┘
```

- This is a `ResponsiveDialog`. Enter submits it, and `openOrResume` runs (C3).
- On success the dialog closes and the refund opens: a new one, or the order's existing draft (FR-003).
- On a refusal the reason shows inline and the dialog stays open (FR-004). "Nada por devolver" adds the server's detail on a second line, which names the invoice when invoiced units are the cause.
- "Continuar" shows a spinner while the request runs.

### State: empty / filtered-empty / forbidden / error

```text
│                     No hay devoluciones.                                  │   (no facets)
│      Ninguna devolución coincide con los filtros.  [Limpiar filtros]      │   (facets set)
│         No tienes permiso para ver devoluciones.                          │   (403, no retry)
│  ⚠ No se pudieron cargar las devoluciones.            [Reintentar]        │   (other error)
```

- All four states come from `CatalogListStateView`, exactly as Notas de crédito uses it.

### Compact tier

```text
┌ Devoluciones ─────────────────┐
│ [⚙ (1)]               [+ Nueva]│
├───────┬──────────┬────────────┤
│ Folio │ Pedido   │      Total │
├───────┼──────────┼────────────┤
│ —     │ #18233 ● │      $0.00 │
│ 412   │ #18190 ● │    $350.00 │
└───────┴──────────┴────────────┘
```

- The compact tier drops Fecha and Cliente, and Estado becomes a coloured dot next to Pedido. `DataTableView` has no card transformation yet (FR-025 of the table spec), so columns are what we can cut.
- The "Nueva devolución" label shortens to "Nueva".

## Screen: Refund detail (`/sales/refunds/:refundId`)

### State: draft, editable (user has update and confirm)

```text
┌ ← Devolución ─────────────────────────────────────────────────────────────────────────┐
│ Folio: Borrador · Pedido: #18233 · Cliente: Ferretería López · Estado: (Abierta)       │
├───────────────────────────────┬────────┬──────┬─────┬─────────┬───────────┬──────┬────┤
│ Producto                      │ Precio │ Desc │ IVA │ Por dev.│ Devolver  │ Alm. │ Tot│
├───────────────────────────────┼────────┼──────┼─────┼─────────┼───────────┼──────┼────┤
│ TOR-08 · Tornillo 1/4"        │  $2.50 │  0 % │ 16% │      50 │ [-] 10 [+]│ [Mat▾]│$29│
│ PIN-01 · Pintura blanca 4 L   │$480.00 │  5 % │ 16% │       2 │ [-]  0 [+]│ [Mat▾]│ $0│
│ CEM-50 · Cemento 50 kg        │$210.00 │  0 % │ 16% │       1 │ [-]  0 [+]│ [Sur▾]│ $0│
│   ⚠ El almacén Sur no admite ventas.                                                  │
├───────────────────────────────┴────────┴──────┴─────┴─────────┴───────────┴──────┴────┤
│                                          Subtotal $25.00 · IVA $4.00 · Total $29.00    │
│                                   [Cancelar devolución]   [Confirmar devolución]       │
└───────────────────────────────────────────────────────────────────────────────────────┘
```

- **Header:** a `FactStripRow` of `CompactField`s, with the order as a link (FR-015). Actions sit in the body, not the app bar (§VI).
- **Lines:** `DataTableView<RefundLine>` without pagination (FR-005).
  - **Devolver:** a `QuantityStepper` with `min 0` and `max` = Por devolver (FR-006, FR-007).
  - **Alm.:** a tap-field that opens `showWarehousePicker`.
  - **Refusals:** a refused write shows its server detail as a sub-row under its line. The example is the unsellable warehouse.
- **Totals:** the server's figures, laid out the way `SaleTotalsBar` reads them.
- **Confirmar:** shown only with confirm access and at least one line above 0 (FR-008).
- **Cancelar:** shown with update access (FR-012).

### State: draft, user can edit but not confirm

```text
│ … same lines, steppers live …                                                          │
│                                          Subtotal $25.00 · IVA $4.00 · Total $29.00    │
│                                                         [Cancelar devolución]          │
│  ⓘ Otra persona con permiso de confirmar debe terminar esta devolución.                │
```

- Confirm is hidden, not disabled (§IV). A one-line hint explains who finishes the refund (Edge Cases).

### State: draft, read-only (no update right)

- This looks like the editable draft, but Devolver and Alm. are plain text and there are no action buttons.

### State: no open cash session

```text
│  ⚠ Abre una sesión de caja para confirmar la devolución.      [Ir a sesiones de caja]  │
│                                   [Cancelar devolución]   [Confirmar devolución]       │
```

- An `ErrorBanner`-styled inline banner appears above the actions after confirm is tapped and the session check fails (FR-009).
- For a stale session the button reads "Cerrar sesión anterior" and opens that session.

### State: confirm dialog

```text
┌ Confirmar devolución ─────────────────────────┐
│ Se devolverán $29.00 al cliente.              │
│                                               │
│ ○ Efectivo de la caja                         │
│ ○ Nota de crédito                             │
│                                               │
│                     [Volver] [Confirmar]      │   ← Confirmar disabled until a choice
└───────────────────────────────────────────────┘
```

- This is a `ResponsiveDialog` with two `RadioListTile`s and nothing pre-selected. Both choices are always offered (FR-008, Clarifications).

### State: completed

```text
┌ ← Devolución 412 ─────────────────────────────────────────────────────────────────────┐
│ Folio: 412 · Fecha: 2026-10-28 · Pedido: #18233 · Cliente: Ferretería López · (Conf.)  │
│  ⓘ Algunas cantidades se ajustaron porque otra devolución se confirmó antes.           │
├───────────────────────────────┬────────┬──────┬─────┬──────────┬──────┬───────────────┤
│ Producto                      │ Precio │ Desc │ IVA │ Devuelto │ Alm. │         Total │
│ TOR-08 · Tornillo 1/4"        │  $2.50 │  0 % │ 16% │        8 │ Mat. │        $23.20 │
├───────────────────────────────┴────────┴──────┴─────┴──────────┴──────┴───────────────┤
│                                          Subtotal $20.00 · IVA $3.20 · Total $23.20    │
│ Forma de devolución: Nota de crédito Nº 30517 ↗                                        │
└───────────────────────────────────────────────────────────────────────────────────────┘
```

- **Read-only:** "Por dev." is dropped because it no longer means anything on a completed refund, and the quantity column is renamed "Devuelto" (FR-010).
- **Adjustment banner:** shown only right after a confirm that changed quantities (FR-011).
- **Payout line** (FR-017, R6 interim #286):
  - "Pagada en efectivo";
  - "Nota de crédito Nº {n}", which links to the payment detail;
  - "Forma de pago no disponible" when the refund has no customer.
  - It shows "…" while the lookup runs.
- **Print:** there is no print action until mbe-api#287. Once it ships, an `OutlinedButton.icon` "Imprimir" sits right-aligned on the payout row (FR-018).

### State: cancelled

- This is the completed layout with Folio "—", the chip "(Cancelada)", no payout line and no actions.

### State: cancel prompt

```text
┌ Cancelar devolución ──────────────────────────┐
│ La devolución se cancelará y no podrá         │
│ editarse.                                     │
│                   [Volver] [Cancelar devol.]  │
└───────────────────────────────────────────────┘
```

### State: loading / not found / error

- Loading is a centred progress indicator.
- A 404 shows "No existe la devolución {id}." with a Back button.
- Any other error shows an `ErrorBanner` with Reintentar.

### Compact tier

```text
┌ ← Devolución ─────────────────┐
│ Borrador · #18233 · (Abierta) │
│ Ferretería López              │
├───────────────────────────────┤
│ TOR-08 · Tornillo 1/4"        │
│ $2.50 · Por devolver 50       │
│ [-] 10 [+]   [Mat ▾]   $29.00 │
├───────────────────────────────┤
│ PIN-01 · Pintura blanca 4 L   │
│ $480.00 · Por devolver 2      │
│ [-]  0 [+]   [Mat ▾]    $0.00 │
├───────────────────────────────┤
│ Total $29.00                  │
│ [Cancelar]        [Confirmar] │
└───────────────────────────────┘
```

- On compact, each line becomes a stacked block of three rows instead of a table row. An 8-column table with a stepper can't fit at phone width. See Open Question 1.

## Changed: Pedidos order header (`/sales/orders/:orderId`, paid order)

```text
│ Pedido 18233 · Ferretería López · Total $1,240.00 · (Pagado)    [Ver pedido] [Devolver] │
```

- "Devolver" (key `order_refund_button`) is an `OutlinedButton` in `OrderHeaderPanel`'s trailing `Wrap`. It is shown only on a paid order with refund create and read access (FR-001).
- Tapping it shows a spinner, then the refund opens. A refusal shows as a SnackBar with the reason (FR-004).

## Changed: POS sale detail (`/sales/pos/:saleId`, paid sale)

```text
│ Venta 18190 · Público en general · $350.00 · (Pagada)          [🧾 Ticket] [Devolver] │
```

- "Devolver" goes next to the ticket button in `PosSaleDetailView._Facts`, with the same rules as Pedidos.

## Changed: Notas de crédito origin cell

```text
│ Devolución #412 · Pedido #18233 │      ← both underlined links
```

- The refund segment becomes a link with key `credit_note_refund_link_<id>`, gated by refund read (FR-016).

## Open Questions

1. **How do refund lines lay out on a phone?** The options were a horizontally scrolling `DataTableView`, or stacked per-line blocks. The vocabulary has no table-to-card transformation yet. The wireframe assumed **stacked blocks built from `CompactField`s** inside the detail screen, local to this screen, not a new shared widget. If that counts as a bespoke widget under §V, the fallback is the scrolling table.
2. **What do Folio and Fecha show on a draft?** A draft has no folio and no date, and the response has no creation time. The wireframe assumed **"Borrador" / "—"**.
3. **Which lines does a completed refund show?** The server drops lines left at zero on confirm, so a completed refund only has the returned lines. The wireframe assumed **only what the server returns, with no "Por devolver" column**.
4. **Should edit-but-can't-confirm users see a hint?** The spec says Confirm is hidden. The wireframe assumed **a one-line hint** so the clerk knows the refund isn't stuck.
5. **Where does the adjustment notice live after a reload?** It is derived from the confirm call, so it is lost when the page reloads. The wireframe assumed that is **acceptable**: it is a notice at the moment of confirming, not a stored fact.
6. **How does a compact list row show status?** The wireframe assumed **a coloured dot by the order number**, with the full chip on the detail screen.
