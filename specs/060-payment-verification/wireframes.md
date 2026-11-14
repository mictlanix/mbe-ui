# Wireframes: Payment Verification

**Spec**: [spec.md](./spec.md) | **Drawn**: 2026-11-14 | **Fidelity**: low

Drawn from the spec before planning. Layout is indicative, not prescriptive. Every dimension, colour and spacing comes from the design tokens (constitution §V).

## Screen: Verificación de pagos (`/sales/payment-verification`)

A new navigation destination in Ventas, right after Pagos. It is gated on `PrivilegeGate(SystemObject.paymentsVerification, AccessRight.read)` (FR-001).

### State: populated, user with Payments Verification read + update

```text
┌ Verificación de pagos ───────────────────────────────────────────────────────────────────┐
│ [⚙ Filtros ①]                                                    23 pagos sin verificar  │
├───────┬──────────┬──────────────────┬──────────────────┬─────────┬────────────┬─────────┬─────┤
│ Folio │ Sucursal │ Fecha            │ Cliente          │ Método  │ Referencia │   Monto │     │
├───────┼──────────┼──────────────────┼──────────────────┼─────────┼────────────┼─────────┼─────┤
│ 9131  │ Centro   │ 2026-11-13 17:20 │ Ferretería López │ Transf. │ SPEI 88213 │$4,250.00│ ✓ ✕ │
│ 9128  │ Norte    │ 2026-11-13 12:05 │ Constructora Gil │ Transf. │ 0045122    │$12,000.0│ ✓ ✕ │
│ 4410  │ Sur      │ 2026-11-12 09:41 │ Materiales Ríos  │ Transf. │ —          │  $780.00│ ✓ ✕ │
├───────┴──────────┴──────────────────┴──────────────────┴─────────┴────────────┴─────────┴─────┤
│                                                        1–20 de 23    ‹  1  2  ›           │
└──────────────────────────────────────────────────────────────────────────────────────────┘
```

- **Filter row:** `CatalogFilterBar` with no search control. `/unverified` has no free-text search, and §VI says to leave the search box out rather than draw an empty one. The badged filters button opens `showCatalogFilterSheet`. The badge shows ① on first load because the method starts at Transfer (FR-003).
- **Count:** the server's `total`, shown in the bar's trailing slot (FR-004).
- **Table:** `DataTableView<CustomerPayment>`. Text columns are left-aligned, Monto right-aligned, and the action column centred (§VI). Facility names come from the facilities provider already used by Pagos. Customer names come from `customer_display_name` (FR-002).
- **Row actions:** two direct icons. ✓ "Verificar" is the primary action and takes the slot Edit usually holds; ✕ "Rechazar" is the one secondary action. Each has a tooltip. This is the two-icon limit in §VI (v1.7.0): a primary action plus one direct secondary action or a ⋮ menu. Both icons appear only with `can(paymentsVerification, update)` (FR-006, FR-009). One tap on ✓ opens the confirmation, so a verification takes two taps.
- **Shared helper change:** today `buildCatalogRowActions` has only an Edit slot, and with Edit absent it puts two extra actions behind ⋮. The plan extends it so a different primary action can fill the first slot when there's no Edit. The two-icon limit stays enforced in the helper (§VI, built once in `core/widgets/`). See resolved Open Question 1.
- **Row tap:** opens the read-only payment panel below, from the row's own data, for every row (FR-005a, resolved Open Question 2).
- **Pagination:** `CatalogPagination`, page size 20, newest first.

### State: user with read only

The table looks the same, but the action column is left out entirely, not left empty (spec US1 scenario 6).

### State: filter sheet open

```text
                                         ┌ Filtros ─────────────────────────────┐
                                         │ Sucursal                              │
                                         │ [ Todas                            ▾] │
                                         │ Fecha                                 │
                                         │ [ 📅 Cualquier fecha               ]  │
                                         │ Método                                │
                                         │ [ Transferencia                    ▾] │
                                         │                                       │
                                         │ [Limpiar todo]            [Aplicar]   │
                                         └───────────────────────────────────────┘
```

- **Sucursal:** a dropdown of all facilities plus "Todas", which is the default (the queue is company-wide).
- **Fecha:** `DateRangeFilterChip`, with no date range by default. Legacy had none.
- **Método:** a dropdown of `PaymentMethod` values plus "Todos". It starts at Transferencia (FR-003).
- **No amount filter** (resolved Open Question 3).
- **"Limpiar todo":** empties Sucursal and Fecha and sets the method back to Transferencia, as the queue opened. The badge then reads ① (resolved Open Question 4).

### State: empty

```text
┌ Verificación de pagos ───────────────────────────────────────────────────────────┐
│ [⚙ Filtros ①]                                                0 pagos sin verificar│
├──────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│                  No hay pagos sin verificar con estos filtros.                   │
│                             [Quitar filtros]                                     │
│                                                                                  │
└──────────────────────────────────────────────────────────────────────────────────┘
```

- This is the `CatalogListStateView` empty variant. "Quitar filtros" appears only when the filters differ from the opening ones (Transferencia, every facility, any date), and resets to them (spec edge case "Empty queue").

### State: loading / load error

A `CatalogListStateView` spinner shows while loading. A load error shows its retry state, with text from `localizeProblem` (§III).

### State: after verify / reject

```text
│ ✓ Pago 9131 verificado.                                                          │   ← SnackBar
```
```text
│ Rechazo registrado. El pago 9128 sigue sin verificar y seguirá en esta lista.    │   ← SnackBar
```

- **After a verification**, the page reloads. If that removed the last row on the page, the queue moves back one page (spec edge case). The count drops by one (US1 scenario 5).
- **After a rejection**, the row stays and nothing about it changes (FR-011, FR-012). The SnackBar is the only feedback.

### Compact tier

```text
┌ Verificación de pagos ──────────────┐
│ [⚙ ①]                  23 sin verif.│
├─────────────────────────────────────┤
│ 9131 · Centro         $4,250.00 ✓ ✕ │
│ Ferretería López                    │
│ Transf. · SPEI 88213                │
│ 2026-11-13 17:20                    │
├─────────────────────────────────────┤
│ 9128 · Norte         $12,000.00 ✓ ✕ │
│ Constructora Gil                    │
│ Transf. · 0045122                   │
│ 2026-11-13 12:05                    │
├─────────────────────────────────────┤
│              ‹ 1 2 ›                │
└─────────────────────────────────────┘
```

- `DataTableView` falls back to stacked rows at this tier.
- No column is dropped. Every field in FR-002 is needed to match a transfer against the statement, so the stacked row is taller instead.
- ✓ and ✕ stay on the first line.

## Panel: Pago (read-only, `showRecordSheet`, opened by a queue row tap)

### State: open

```text
                                        ┌ Pago 9128 ─────────────────────────── ✕ ┐
                                        │ (Sin verificar)                          │
                                        │                                          │
                                        │ Sucursal      Norte                      │
                                        │ Fecha         2026-11-13 12:05           │
                                        │ Cliente       Constructora Gil           │
                                        │ Tipo          Abono a crédito            │
                                        │ Método        Transferencia              │
                                        │ Referencia    0045122                    │
                                        │ Monto         $12,000.00 MXN             │
                                        │ Sin aplicar   $12,000.00                 │
                                        │ Caja          #—                         │
                                        └──────────────────────────────────────────┘
```

- **Surface:** the shared `RecordSheet` side panel, in read-only mode, over the queue.
- **Data:** everything comes from the queue row already loaded, with no extra request, so it opens for another facility's payment too (FR-005a).
- **Cash session:** shown as `#id` plain text, not a link. Facility and customer names come from the same places as the row.
- **Actions:** none besides close (resolved Open Question 8).

### Compact tier

The `RecordSheet` goes full-screen and the facts stay in one column.

## Dialog: Verificar pago (`ResponsiveDialog`, shared by queue and payment view)

### State: confirm

```text
┌ Verificar pago ────────────────────────────────────┐
│ Folio      9131                                    │
│ Cliente    Ferretería López                        │
│ Monto      $4,250.00 MXN                           │
│ Referencia SPEI 88213                              │
│                                                    │
│ Confirma que el dinero está en el banco. No se     │
│ puede deshacer.                                    │
│                             [Cancelar] [Verificar] │
└────────────────────────────────────────────────────┘
```

- The facts are read from the row or view already loaded, with no extra fetch (FR-007).
- "Verificar" is a `FilledButton`.

### State: submitting

```text
│                         [Cancelar̶] [⟳ Verificando…] │
```

- Both buttons are disabled and the dialog can't be dismissed, so a double tap sends one request.

### State: refused / unknown result

```text
│ ┌────────────────────────────────────────────────┐ │
│ │ ⚠ Otra persona ya verificó este pago.          │ │
│ └────────────────────────────────────────────────┘ │
│                                         [Cerrar]   │
```
```text
│ ┌────────────────────────────────────────────────┐ │
│ │ ⚠ No sabemos si se verificó: se perdió la      │ │
│ │   conexión. La lista se actualizó.             │ │
│ └────────────────────────────────────────────────┘ │
│                                         [Cerrar]   │
```

- The message is shown in a `FormErrorBanner`, with text from `localizeProblem`. `payment.already_verified` gets its own string (FR-014).
- The confirm button is replaced by "Cerrar".
- The queue or payment view reloads behind the dialog, so an already-verified row disappears.

## Dialog: Rechazar pago (`ResponsiveDialog`, shared)

### State: empty reason

```text
┌ Rechazar pago ─────────────────────────────────────┐
│ Folio 9128 · Constructora Gil                      │
│ $12,000.00 MXN · Ref. 0045122                      │
│                                                    │
│ Motivo *                                           │
│ [                                                ] │
│ [                                                ] │
│                                             0/500  │
│ El pago seguirá sin verificar; el rechazo queda    │
│ registrado con tu nombre y la fecha.               │
│                           [Cancelar] [Rechazar̶]    │
└────────────────────────────────────────────────────┘
```

- **Motivo:** a multi-line `TextField` with `maxLength: 500` and the built-in counter (FR-010).
- **"Rechazar":** stays disabled while the trimmed reason is empty (US2 scenario 2).
- **Note under the field:** says before confirming what the rejection does and doesn't do (FR-011).

### State: submitting / refused / unknown result

These match the Verificar dialog. `incidence.reason_required` gets its own string, though the client already prevents it.

## Screen: Payment view (`/sales/payments/:paymentId`), changed

### State: unverified, user with Payments Verification update

```text
┌ ← Pago ──────────────────────────────────────────────────────────────────────────────┐
│  Pago 9131  (Sin verificar)                          [✓ Verificar] [✕ Rechazar]       │
│  Monto $4,250.00    Aplicado $4,250.00    Sin aplicar $0.00                           │
├──────────────────────────────────────────────────────────────────────────────────────┤
│ Cliente      Ferretería López            Fecha          2026-11-13 17:20              │
│ Método       Transferencia               Opción         —                             │
│ Referencia   SPEI 88213                  Tipo           Pago                          │
│ Sucursal     Centro                      Caja           #812                          │
│ Verificado por  —                                                                     │
├──────────────────────────────────────────────────────────────────────────────────────┤
│ Aplicaciones …unchanged (spec 059)…                                                   │
└──────────────────────────────────────────────────────────────────────────────────────┘
```

- **Actions:** two `OutlinedButton.icon`s in the header `Wrap`, after `PaymentVerifiedChip`. They appear only when `verifierId == null` and with `can(paymentsVerification, update)` (FR-013). They open the shared dialogs above.
- **Placement:** the header, next to the chip the actions change. "Aplicar a pedido" (spec 059) stays under the summary figures. See Open Question 5.

### State: verified (after the action, or already)

```text
│  Pago 9131  (Verificado)                                                             │
│ …                                                                                    │
│ Verificado por  M. Pérez                                                             │
```

- The buttons are gone.
- After verifying, the view reloads and the SnackBar "Pago 9131 verificado" shows (FR-008, US3 scenario 4).
- If the Pagos list is in the stack, it is invalidated so its ✓ column updates.

### State: user without update

The view is unchanged from today: no buttons, nothing disabled (SC-005).

### Compact tier

```text
┌ ← Pago ─────────────────────────────┐
│ Pago 9131  (Sin verificar)          │
│ [✓ Verificar] [✕ Rechazar]          │
│ Sin aplicar  $0.00                  │
│ …facts, one column…                 │
└─────────────────────────────────────┘
```

- The header `Wrap` moves the buttons onto their own line. They keep their full labels.

## Open Questions

1. **Row actions: ⋮ menu or direct icons?** *Resolved 2026-11-14:* show both as direct icons, ✓ Verificar as the primary and ✕ Rechazar as the secondary. That is within §VI's two-icon limit, because Verificar takes the slot Edit usually holds. The cost is a small change to `buildCatalogRowActions` so a primary action other than Edit can fill the first slot.
2. **What does a row tap open?** *Resolved 2026-11-14 (clarify, revised):* a read-only `RecordSheet` built from the row's data, for every row. It gives the payment a second surface. §VI isn't amended; the plan records it as a justified deviation.
3. **Amount range control.** *Resolved 2026-11-14 (clarify):* dropped. The queue filters by facility, date and method only.
4. **What does "Limpiar todo" reset the method to?** *Resolved 2026-11-14 (clarify):* back to Transferencia, the opening filter. "Todos" is chosen only on purpose.
5. **Where do Verificar and Rechazar sit on the payment view?** Options:
   - (a) The header, next to the verified chip.
   - (b) With "Aplicar a pedido" under the summary figures.
   - (c) In the AppBar. The spec 054 comment says the AppBar carries only Back.

   **Assumed (a).**
6. **Should the queue remember a rejection for the rest of the session?** A local "Rechazado" mark would stop a supervisor from rejecting the same payment twice in one sitting. But it disappears on reload, so it would claim knowledge the app doesn't have (FR-012). **Assumed no:** SnackBar only.
7. **Is the default date range empty or "today"?** Legacy had no date filter, and the queue is a backlog, not a day's work. **Assumed empty.**
8. **Should the read-only panel offer Verificar and Rechazar?** *Resolved 2026-11-14:* no, close only. The row icons already do both.
