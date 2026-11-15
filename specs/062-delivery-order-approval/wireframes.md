# Wireframes: Delivery Order Approval

**Spec**: [spec.md](./spec.md) | **Drawn**: 2026-11-15 | **Fidelity**: low

Drawn from the spec before planning. Layout is indicative, not prescriptive. Every dimension, colour and spacing comes from the design tokens (constitution §V).

## Screen: Aprobación de entregas (`/sales/delivery-order-approval`)

This is a new navigation destination in the Logística group, right after Órdenes de entrega. It is gated on `PrivilegeGate(SystemObject.deliveryOrderApproval, AccessRight.read)` (FR-001). The route is Open Question 1.

### State: populated, user with Delivery Order Approval read + update and Delivery Orders read

```text
┌ Aprobación de entregas ──────────────────────────────────────────────────────────────────┐
├───────┬──────────────────┬─────────┬────────────┬──────────────────┬─────────┬──────┬─────┤
│ Folio │ Cliente          │ Tipo    │ Programada │ Destino          │ Pedidos │ Prio.│     │
├───────┼──────────────────┼─────────┼────────────┼──────────────────┼─────────┼──────┼─────┤
│ 1541  │ Constructora Gil │ Entrega │ 2026-11-16 │ Calle 5 #33, Ce… │ 8790, 8 │    2 │ ✓ ✕ │
│ 1538  │ Ferretería López │ Entrega │ 2026-11-15 │ Av. Juárez 120,… │ 8841    │    0 │ ✓ ✕ │
│ 1536  │ Materiales Ríos  │ Recoge  │ 2026-11-15 │ Sucursal Centro  │ 8802    │    0 │ ✓ ✕ │
├───────┴──────────────────┴─────────┴────────────┴──────────────────┴─────────┴──────┴─────┤
│                                                        1–20 de 23    ‹  1  2  ›           │
└──────────────────────────────────────────────────────────────────────────────────────────┘
```

- **No filter row.** The approval list takes only paging, so there's no search box and no filters button (FR-003). §VI says to leave out a search box that has nothing to search rather than draw an empty one, and with no filters either, the whole `CatalogFilterBar` row is left out. See Open Question 4.
- **Count.** The server's `total`, shown by the `CatalogPagination` footer ("1–20 de 23", FR-003).
- **Table.** `DataTableView<DeliveryOrderSummary>`, in the order the server returns (FR-002).
  - These columns are the same as in Órdenes de entrega, without Estado and with Prioridad added. Every row is Pendiente de aprobación, so a status column would say the same thing on every row.
  - Prioridad is right-aligned. Cliente, Destino and Pedidos are truncated with a tooltip (§VI).
  - Customer and ship-to names come from the batch lookups spec 061 already uses. A name the user can't read falls back to its number (FR-002).
- **Row actions.** Two direct icons from `buildCatalogRowActions`.
  - ✓ "Aprobar" is passed as `primaryAction` (the slot spec 060 added).
  - ✕ "Rechazar" is the one extra action.
  - Both show only with `can(deliveryOrderApproval, update)` (FR-005, FR-007, FR-010). This is the two-icon limit in §VI.
- **Row tap.** It opens the spec 061 detail screen, `/sales/delivery-orders/:id`, pushed so that back returns to the queue (FR-006). See Open Question 2.
- **Pagination.** `CatalogPagination`, page size 20.

### State: user without Delivery Orders read

The table looks the same, but rows don't respond to a tap: no hover highlight and no pointer cursor (FR-006, Clarification Q1). ✓ and ✕ still work.

### State: user with Delivery Order Approval read only

The table looks the same, but the action column is left out entirely, not left empty (US1 scenario 5, §VI).

### State: empty

```text
┌ Aprobación de entregas ──────────────────────────────────────────────────────────┐
├──────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│               No hay órdenes de entrega pendientes de aprobación.                │
│                                                                                  │
└──────────────────────────────────────────────────────────────────────────────────┘
```

- This is the `CatalogListStateView` empty variant, with no action button because there are no filters to clear. It covers both "nothing waiting" and "approval not required" (spec edge case). The app can't tell those apart, so the text doesn't try to.

### State: no facility

```text
┌ Aprobación de entregas ──────────────────────────────────────────────────────────┐
├──────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│       Tu usuario no tiene sucursal asignada. La aprobación de entregas           │
│       muestra las órdenes de tu sucursal.                                        │
│                                                                                  │
└──────────────────────────────────────────────────────────────────────────────────┘
```

- This is the same no-facility notice Órdenes de entrega and Pedidos use, and no request is made (FR-004).

### State: loading / load error / no access

- **Loading** shows a `CatalogListStateView` spinner.
- **A load error** shows its retry state, with text from `localizeProblem` (§III).
- **Without Delivery Order Approval read**, the navigation entry is hidden and the route guard redirects (§IV).

### State: after approve / reject

```text
│ ✓ Orden 1541 aprobada: En preparación.                                           │   ← SnackBar
```
```text
│ ✓ Orden 1536 aprobada: Aprobada (recoge en tienda).                              │   ← SnackBar
```
```text
│ Orden 1538 rechazada. Regresó a borrador con el motivo.                          │   ← SnackBar
```

- The approval message names the status the server returned, not the one predicted (FR-009).
- After either action the page reloads and the row is gone. If that removed the last row on the page, the queue moves back one page (spec edge case). The footer's total drops by one.

### Compact tier

```text
┌ Aprobación de entregas ───────────────────────┐
├───────┬──────────────────┬────────────┬──────┬─────┤
│ Folio │ Cliente          │ Programada │ Prio.│     │
├───────┼──────────────────┼────────────┼──────┼─────┤
│ 1541  │ Constructora Gil │ 2026-11-16 │    2 │ ✓ ✕ │
│ 1536  │ Materiales Ríos  │ 2026-11-15 │    0 │ ✓ ✕ │
├───────┴──────────────────┴────────────┴──────┴─────┤
│                    1–2 de 2   ‹ 1 ›                │
└────────────────────────────────────────────────────┘
```

- `DataTableView` has no stacked-row compact layout yet (`data_table_view.dart`), so it stays a table. The table drops Tipo, Destino and Pedidos at this tier, as the spec 061 list does (`if (!compact)` columns).
- Folio, Cliente, Programada, Prio. and ✓ ✕ remain. The dropped fields are one tap away on the detail screen, and the approve dialog names the type.

## Screen: Orden de entrega (`/sales/delivery-orders/:id`), changed

This is the spec 061 detail screen. Only its action area changes, and only when the order is in Pendiente de aprobación.

### State: Pendiente de aprobación, user with Delivery Order Approval update and Delivery Orders update

```text
┌ ← Orden de entrega 1538 ─────────────────────────────────────────────────────────────────────┐
│ Folio  Estado                 Tipo     Cliente           Sucursal  Programada   Prioridad    │
│ 1538   (Pend. de aprobación)  Entrega  Ferretería López  Centro    2026-11-15   0            │
│ Destino  Av. Juárez 120, Col. Centro, 64000          Contacto  Luis López · 81 1234 5678     │
│ Pedidos  8841 ↗                                      Comentario  Entregar por la mañana      │
│                                                                                              │
│ ── Líneas ───────────────────────────────────────────────────────────────────────────────────│
│ CEM-50   Cemento gris 50 kg    Bodega 1  8841     10.00     0.00    0.00     0.00   10.00    │
│ VAR-38   Varilla 3/8"          Bodega 1  8841     25.00     0.00    0.00     0.00   25.00    │
│                                                                                              │
│ ── Historial ── …                                                                            │
│                                          [Cancelar orden]   [✕ Rechazar]   [✓ Aprobar]       │
└──────────────────────────────────────────────────────────────────────────────────────────────┘
```

- **Actions.** The `Wrap` is end-aligned, as in spec 061.
  - "Cancelar orden" (Delivery Orders update, spec 061 FR-018) and "Rechazar" are outlined.
  - "Aprobar" is filled, as the primary action.
  - "Rechazar" and "Aprobar" show only with `can(deliveryOrderApproval, update)` and status Pendiente de aprobación (FR-013). This holds whether the screen was opened from the queue or from Órdenes de entrega.
  - Putting Cancelar and Rechazar side by side is Open Question 3.
- **Earlier rejection.** When the order was rejected before and confirmed again, the rejection banner is gone, because confirming clears the stored reason (server `delivery_order_service.py`, in confirm). The earlier rejection and its reason are still in the history section (spec edge case "Rejected, then confirmed again"). Nothing new is drawn for this.

### State: Pendiente de aprobación, approver without Delivery Orders update

The screen is the same with only `[✕ Rechazar] [✓ Aprobar]`. "Cancelar orden" isn't shown (spec 061 FR-011).

### State: Pendiente de aprobación, no Delivery Order Approval update

Neither "Rechazar" nor "Aprobar" is shown. This is spec 061's screen unchanged (FR-013).

### State: after approve / reject on the detail screen

The screen reloads in place. After an approval it shows (En preparación) or (Aprobada), with a new history line. After a rejection it shows (Borrador), the rejection banner with the reason just typed, and a history line Pend. aprob. → Borrador with the reason. On a draft, spec 061's edit and confirm controls appear for users with Delivery Orders update (FR-014). Going back to the queue shows the order gone.

### Compact tier

The action `Wrap` breaks onto two lines: "Aprobar" first, then "Rechazar" and "Cancelar orden". Everything else follows spec 061's compact tier.

## Dialog: Aprobar orden (`ResponsiveDialog`, shared by queue and detail)

### State: confirm

```text
┌ ¿Aprobar orden de entrega 1541? ─────────────────────────┐
│ Cliente     Constructora Gil                              │
│ Tipo        Entrega                                       │
│ Programada  2026-11-16                                    │
│                                                           │
│ Pasará a En preparación y aparecerá para el almacén.      │
│                                    [Volver]   [Aprobar]   │
└───────────────────────────────────────────────────────────┘
```

- The facts come from the row or the loaded order, with no extra fetch (FR-008).
- The last line depends on the type. A pickup reads "Pasará a Aprobada; después se marca lista para recoger."
- "Aprobar" is a `FilledButton`.

### State: submitting / refused / unknown result

- **Submitting.** Both buttons are disabled and the dialog can't be dismissed, so a double tap sends one request.
- **Refused.** The message shows in a `FormErrorBanner`, with text from `localizeProblem`. `delivery_order.not_pending_approval` gets its own string: "Esta orden ya no está pendiente de aprobación." (FR-015). The confirm button becomes "Cerrar", and the queue or detail reloads behind the dialog.
- **Unknown result** (network): "No sabemos si se aprobó: se perdió la conexión. La lista se actualizó." Then the same reload follows.

## Dialog: Rechazar orden (`ResponsiveDialog`, shared)

### State: empty reason

```text
┌ Rechazar orden de entrega 1538 ──────────────────────────┐
│ Ferretería López · Programada 2026-11-15                  │
│                                                           │
│ Motivo *                                                  │
│ [                                                       ] │
│ [                                                       ] │
│                                                    0/500  │
│ La orden regresa a borrador para que su autor la corrija  │
│ y la vuelva a confirmar. El motivo queda en la orden.     │
│                                   [Volver]   [Rechazar̶]   │
└───────────────────────────────────────────────────────────┘
```

- **Motivo.** A multi-line `TextField` with `maxLength: 500` and the built-in counter (FR-011).
- **"Rechazar".** It stays disabled while the trimmed reason is empty (US2 scenario 2).
- **Note.** It says what the rejection does before the user confirms (FR-011).

### State: submitting / refused / unknown result

These match the Aprobar dialog. `delivery_order.reason_required` gets its own string, though the client already prevents it.

## Open Questions

1. **Route path.** The options are `/sales/delivery-order-approval` or `/sales/delivery-orders/approval`. The second sits beside `/sales/delivery-orders/:id`, so "approval" would have to be matched before the id segment, and a reader could mistake it for an order. *Assumed:* `/sales/delivery-order-approval`, under `/sales/` like the other Logística routes (spec 061 Open Question 1).
2. **Back from the detail screen.** A row tap could push the detail screen, so back returns to the queue, or go to it, so back returns to Órdenes de entrega. *Assumed:* push. The approver came from the queue and should return to it (FR-014).
3. **Cancelar and Rechazar side by side.** On a pending order, a user with both rights sees "Cancelar orden" and "Rechazar". Both take a reason, and they're easy to confuse: cancel ends the order, reject sends it back. The options are to show both (each dialog's note says what it does) or to hide "Cancelar orden" while pending, which drops a spec 061 action. *Assumed:* show both, ordered Cancelar · Rechazar · Aprobar, and rely on the dialog notes.
4. **No filter row at all.** The queue has neither search nor filters, so the `CatalogFilterBar` row is left out entirely. The alternative is an empty bar kept so the screen lines up with the other lists. *Assumed:* leave it out. §VI says not to draw controls with nothing behind them.
5. **No status column.** Every row is Pendiente de aprobación. *Assumed:* the column is dropped and Prioridad is shown in its place. Legacy showed neither column; priority helps an approver decide what to review first.
