# Wireframes: Payments List and Search

**Spec**: [spec.md](./spec.md) | **Drawn**: 2026-10-27 | **Fidelity**: low

Drawn from the spec before planning. Layout is indicative, not prescriptive: every
dimension, colour and spacing comes from the design tokens (constitution §V).

Two screens:

| Screen | Route | Gate |
|---|---|---|
| Pagos (list, two modes) | `/sales/payments` | Customer Payments (8) read; the "Todas las sucursales" mode also needs Payments Editor (100) read |
| Payment view | `/sales/payments/:paymentId` | Customer Payments (8) read |

The payment view is a **full detail screen**, not the shared side panel. Under the
constitution's §VI record-surface rule it qualifies on two counts: it owns a child
collection (the applications) and it needs its own per-record URL (spec Story 2,
scenario 7).

---

## Screen: Pagos (`/sales/payments`)

### State: populated, "Esta sucursal" mode (user with Payments Editor read)

```
┌ Pagos ─────────────────────────────────────────────────────────────────────────────────┐
│ [ Esta sucursal | Todas las sucursales ]                                    (⚙ 2)       │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ Folio  Fecha             Cliente           Importe      Forma de pago     Referencia    │
│                                                         Tipo   Sin aplicar  Verificado  │
│ ────────────────────────────────────────────────────────────────────────────────────── │
│ 18342  27/10/2026 10:14  FERRETERÍA LÓPEZ  $1,250.00    Transferencia     SPEI 98123   │
│                                            MXN          Pago de crédito   $0.00        │
│                                                                           [Sin verif.]  │
│ 18341  27/10/2026 09:58  PÚBLICO EN GRAL.  $  480.00    Tarjeta · 3 MSI   —            │
│                                            MXN          Contado  $0.00 [Verificado]     │
│ 18339  26/10/2026 18:02  ⋯                 US$ 200.00   Efectivo          —            │
│                          (name loading)    USD          Pago anticipado $200 [Sin v.]  │
│ …                                                                                      │
├────────────────────────────────────────────────────────────────────────────────────────┤
│                                              Filas por página 20 ▾   1–20 de 3,412  ‹ › │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

Each row is drawn on two lines only to fit 100 columns. In the real table it is one
row with these columns, in order: Folio · Fecha · Cliente · Importe · Forma de pago ·
Referencia · Tipo · Sin aplicar · Verificado.

- **Filter row:** `CatalogFilterBar`.
  - `actions:` holds the mode `SegmentedButton`, only for Payments Editor readers (FR-002). Everyone else sees no switch at all, not a disabled one.
  - `filters:` holds the badged filter `IconButton` (`Badge.count` + `Icons.tune`), which opens `showCatalogFilterSheet` (FR-008).
  - This mode has **no** `search:` control. The endpoint has no free-text search, so the slot is omitted, not a placeholder (constitution §VI).
- **Body:** `CatalogListStateView<CustomerPayment>`, which renders `DataTableView` with `pagination:` (FR-004).
- **Pagination:** `CatalogPagination`, inside `DataTableView`. Page size is capped at 100 by the server.
- **Columns:**
  - *Folio:* `fixedWidth`.
  - *Fecha:* `fmt.display.dateTime` (FR-016).
  - *Cliente:* `DataTableColumn.text`, ellipsis + tooltip. Shows a placeholder while its name resolves (FR-018, Edge Cases).
  - *Importe:* right-aligned, never truncated, in the payment's own currency with its code (FR-016).
  - *Forma de pago:* "method · option" (FR-005). Falls back to the option number if the option is gone.
  - *Referencia:* `.text`, "—" when null.
  - *Tipo:* label (FR-017).
  - *Sin aplicar:* right-aligned currency.
  - *Verificado:* `StatusChip<VerifiedState>` (FR-017).
- **Row tap:** `context.push('/sales/payments/<id>')` opens the payment view (FR-013). There are **no row action icons**, because nothing on a payment can be changed here (FR-003).
- There is no Facility column in this mode: every row is the user's own facility.

### State: filter drawer, "Esta sucursal" mode

```
┌ Filtros ──────────────────────────────── ✕ ┐
│ Cliente                                    │
│ [ FERRETERÍA LÓPEZ                    ▾ ]  │
│                                            │
│ Fecha                                      │
│ [ 20/10/2026 – 27/10/2026            ✕ ]   │
│                                            │
│ Forma de pago                              │
│ [ Todas ▾ ]                                │
│                                            │
│ Verificado                                 │
│ ( Todos ) ( Verificados ) ( Sin verificar )│
│                                            │
│ Sesión de caja                             │
│ [ #812 · J. Pérez · 27/10/2026        ▾ ]  │
│                                            │
│ [ Limpiar todo ]               [ Aplicar ] │
└────────────────────────────────────────────┘
```

- **Container:** `showCatalogFilterSheet`, with the content in a `CurrentListQueryBuilder` (same pattern as `/sales/cash-sessions`). Every facet is written to the URL query (`ListQuery.withFacet`) and resets the list to page 0.
- **Cliente:** `CatalogEntityPicker<Customer>` (FR-006).
- **Fecha:** `DateRangeFilterChip`, using wall-clock dates per spec 043. It prevents an end date before the start (Edge Cases).
- **Forma de pago:** single-select menu over the payment-method enum (FR-006).
- **Verificado:** three `ChoiceChip`s; "Todos" is selected by default. This is the tri-state rule (FR-007).
- **Sesión de caja:** `CatalogEntityPicker<CashSession>` over the facility's sessions. See Open Question 4.
- There is **no facility facet**, by design (FR-009).

### State: populated, "Todas las sucursales" mode

```
┌ Pagos ─────────────────────────────────────────────────────────────────────────────────┐
│ [ Esta sucursal | Todas las sucursales ]  [🔍 Buscar referencia… SPEI 98   ✕]  (⚙ 1)   │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ Folio  Fecha             Sucursal    Cliente           Importe      Forma de pago       │
│                                      Referencia        Tipo   Sin aplicar  Verificado   │
│ ────────────────────────────────────────────────────────────────────────────────────── │
│ 18342  27/10/2026 10:14  Matriz      FERRETERÍA LÓPEZ  $1,250.00    Transferencia       │
│                                      SPEI 98123        Pago de crédito $0 [Sin verif.] │
│ 9921   25/10/2026 16:40  Sucursal 2  CONSTRUCTORA RÍO  $8,000.00    Transferencia       │
│                                      SPEI 98-44710     Pago anticipado $8,000 [Verif.] │
├────────────────────────────────────────────────────────────────────────────────────────┤
│                                              Filas por página 20 ▾      1–2 de 2    ‹ › │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

- **Search:** the `search:` slot holds a `CatalogSearchBar` over the reference, partial and ignoring case (FR-010). It exists in this mode only, because only this endpoint supports it.
- **Sucursal column:** added in this mode only (FR-011).
- **Filter drawer:** shrinks to **Cliente** and **Fecha** (FR-012). Switching modes clears any method, verified or cash-session facet. Switching back clears the reference search.
- **Row tap:** opens the same payment view (Story 3, scenario 6).
- The mode is part of the URL (e.g. `?scope=all`), so Back from a payment view returns to the same mode, page and filters.

### State: filter drawer, "Todas las sucursales" mode

```
┌ Filtros ──────────────────────────────── ✕ ┐
│ Cliente                                    │
│ [ Buscar cliente…                     ▾ ]  │
│ Fecha                                      │
│ [ Cualquier fecha                       ]  │
│ [ Limpiar todo ]               [ Aplicar ] │
└────────────────────────────────────────────┘
```

### State: loading

```
┌ Pagos ─────────────────────────────────────────────────────────────────────────────────┐
│ [ Esta sucursal | Todas las sucursales ]                                    (⚙)        │
├────────────────────────────────────────────────────────────────────────────────────────┤
│                                     ◌                                                  │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

- `CatalogListStateView` loading branch. The filter row stays interactive.

### State: empty

```
┌ Pagos ─────────────────────────────────────────────────────────────────────────────────┐
│ [ Esta sucursal | Todas las sucursales ]                                    (⚙ 3)       │
├────────────────────────────────────────────────────────────────────────────────────────┤
│                    Ningún pago coincide con los filtros.                               │
│                             [ Quitar filtros ]                                         │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

- `CatalogListStateView` with `isFiltered: true`, which offers `onClearFilters` (Story 1, scenario 9).
- With no filters at all (an empty facility), it shows only the message, with no button.

### State: error

```
┌ Pagos ─────────────────────────────────────────────────────────────────────────────────┐
│ [ Esta sucursal | Todas las sucursales ]                                    (⚙ 2)       │
├────────────────────────────────────────────────────────────────────────────────────────┤
│  ⚠ No se pudieron cargar los pagos.                                       [ Reintentar ]│
└────────────────────────────────────────────────────────────────────────────────────────┘
```

- `CatalogListStateView` error branch with `onRetry`. The filters in the URL are kept (FR-019).

### State: permission-denied

There is nothing to draw: the "Pagos" nav entry is absent from `AppNavigation`, and the
route guard redirects (FR-001, Story 1, scenario 10). This is the same behavior as every
other gated route.

### Compact tier

```
┌ Pagos ─────────────────────────┐
│ [Esta suc. | Todas]     (⚙ 2)  │
│ [🔍 Buscar referencia…      ]  │  ← "Todas" only; wraps to own line
├────────────────────────────────┤
│ Folio  Fecha       Cliente   ▸ │  ← whole table scrolls
│ 18342  27/10 10:14 FERRETE…  ▸ │    horizontally (minWidth)
│ 18341  27/10 09:58 PÚBLICO…  ▸ │
│ …                              │
├────────────────────────────────┤
│        1–20 de 3,412    ‹ ›    │
└────────────────────────────────┘
```

- `CatalogFilterBar` reflows to a `Wrap` below 840px, so in "Todas" mode the search box drops to its own line. The segment labels shorten.
- `DataTableView` has no compact card-list transformation yet (see its own comment), and it exposes no frozen-column parameter. The table keeps every column and scrolls horizontally inside its `minWidth`. **No columns are dropped.** See Open Question 3.

---

## Screen: Payment view (`/sales/payments/:paymentId`)

### State: populated

```
┌ ← Ver pago ────────────────────────────────────────────────────────────────────────────┐
│                                                                                        │
│  Pago 18342                                           [Sin verificar]                  │
│  Importe $1,250.00 MXN   ·   Aplicado $1,250.00   ·   Sin aplicar $0.00                │
│                                                                                        │
│  Cliente            FERRETERÍA LÓPEZ           Fecha            27/10/2026 10:14       │
│  Forma de pago      Transferencia              Opción de pago   —                      │
│  Referencia         SPEI 98123                 Tipo             Pago de crédito        │
│  Sucursal           Matriz                     Sesión de caja   #812 ↗                 │
│  Verificado por     —                                                                  │
│                                                                                        │
│  Aplicaciones                                                                          │
│ ┌────────────────────────────────────────────────────────────────────────────────────┐ │
│ │ Pedido      Aplicado    Cambio    Aplicó          Fecha             Estado         │ │
│ │ ────────────────────────────────────────────────────────────────────────────────── │ │
│ │ #5512 ↗     $1,250.00   $0.00     M. Ruiz         27/10/2026 10:15  —              │ │
│ │ #5498 ↗     $  300.00   $0.00     M. Ruiz         27/10/2026 10:14  [Revertida]    │ │
│ │ ~~(muted: struck from Aplicado total)~~                                            │ │
│ └────────────────────────────────────────────────────────────────────────────────────┘ │
│                                                                                        │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

- **AppBar:** title "Ver pago", Back only, with **no** action icons (FR-003; constitution §VI says a read-only surface is labelled "View").
- **Header:** the payment number, the verified `StatusChip`, and a summary line: Importe · Aplicado · Sin aplicar. *Aplicado* is the sum of the non-reversed applications (SC-003).
- **Fields:** `ResponsiveFormGrid` with `maxColumns: 2` and label/value pairs, the same pattern as `CashSessionDetailScreen` (FR-013).
  - Opción de pago, Referencia, Sesión de caja and Verificado por show "—" when empty (Edge Cases, very old data).
  - Verifier names that can't be resolved fall back to the employee number.
- **Sesión de caja #812 ↗:** a link to `/sales/cash-sessions/812`, shown only when the user can read Cash Sessions. Otherwise it's plain text (FR-015).
- **Aplicaciones:** an unpaginated `DataTableView`. A payment has few applications, a provably bounded set (constitution §VI exception).
  - *Pedido* is a link cell. It opens `/sales/pos/:id` or `/sales/orders/:id` according to the order's origin, and only if the user can read that origin. Otherwise it's plain text (FR-015).
  - *Estado* shows a `StatusChip` "Revertida" on reversed rows, which are rendered muted (FR-014).
  - The **rows themselves are not tappable.** An application has no record surface of its own; only the Pedido cell navigates.

### State: no applications

```
│  Aplicaciones                                                                          │
│ ┌────────────────────────────────────────────────────────────────────────────────────┐ │
│ │            Este pago no se ha aplicado a ningún pedido.                            │ │
│ └────────────────────────────────────────────────────────────────────────────────────┘ │
```

- This is the empty branch of `CatalogListStateView`, without a clear-filters action (Story 2, scenario 3).

### State: loading / error / not found

```
┌ ← Ver pago ──────────────────────┐   ┌ ← Ver pago ──────────────────────┐
│               ◌                  │   │ ⚠ No se pudo cargar el pago.     │
│                                  │   │                    [Reintentar ] │
└──────────────────────────────────┘   └──────────────────────────────────┘
┌ ← Ver pago ──────────────────────┐
│ ⚠ El pago 99999 no existe.       │
│              [ Volver a Pagos ]  │
└──────────────────────────────────┘
```

- Loading uses a centered `CircularProgressIndicator`; errors use `ErrorBanner` (the same as `CashSessionDetailScreen`).
- Not found (Story 2, scenario 7) is an `ErrorBanner` with a not-found `AppError`, with no retry.
- If the applications fail to load while the payment loads fine, only the Aplicaciones section shows the error with a retry. The fields above stay visible.

### Compact tier

```
┌ ← Ver pago ────────────────────┐
│ Pago 18342       [Sin verif.]  │
│ Importe $1,250.00 MXN          │
│ Aplicado $1,250.00             │
│ Sin aplicar $0.00              │
│                                │
│ Cliente                        │
│ FERRETERÍA LÓPEZ               │
│ Fecha                          │
│ 27/10/2026 10:14               │
│ …(one column)                  │
│                                │
│ Aplicaciones                   │
│ Pedido   Aplicado   Estado   ▸ │  ← scrolls horizontally
│ #5512↗   $1,250.00  —        ▸ │
└────────────────────────────────┘
```

- `ResponsiveFormGrid` collapses to one column, and the summary line wraps to three lines.
- The applications table scrolls horizontally. No columns are dropped.

---

## Open Questions

1. **Where does the mode switch live?**
   - Options: (a) a `SegmentedButton` in `CatalogFilterBar.actions`; (b) a "Sucursal: esta / todas" facet in the filter drawer; (c) two separate nav entries or routes.
   - (b) conflicts with FR-012: the mode changes which facets exist, so it can't be one of them. The `actions:` slot is meant for "entity actions", so (a) slightly stretches its documented purpose.
   - **Assumed (a)**, with the mode in the URL.

2. **Reference search: search box or facet?**
   - Options: (a) the `CatalogSearchBar` slot, shown only in "Todas"; (b) a "Referencia" text facet in the drawer.
   - Constitution §VI reserves the search slot for the endpoint's free-text search, and the cross-facility endpoint's `reference` is the closest thing to one. With (a), the search box appears and disappears with the mode.
   - **Assumed (a).**

3. **Column budget at compact width.** The list has 9 columns, or 10 in "Todas". `DataTableView` has no card-list transformation yet.
   - Options: (a) keep every column and scroll the whole table horizontally (`DataTableView` has no frozen-column parameter to keep Folio visible); (b) drop Tipo and Referencia on compact; (c) build the card list (a new shared-widget capability, outside this spec).
   - **Assumed (a)**, consistent with every other list today.

4. **How is a cash session picked as a filter?** **Resolved (clarify 2026-10-27): (a), FR-006a.** The spec says "the facility's cash sessions". There can be thousands, and a session has no name.
   - Options: (a) a `CatalogEntityPicker<CashSession>` labelled "#id · cajero · fecha", searchable by id; (b) a plain session-number text field; (c) drop this facet from the drawer and link in from the cash-session view instead, opening Pagos pre-filtered by `?cash-session=812`.
   - **Assumed (a).** (c) is attractive and cheap, but the spec explicitly lists "opening a payment from a cash-session screen" as out of scope.

5. **Spanish labels for payment types.** **Resolved (clarify 2026-10-27), FR-017.** The enum is NA, IMMEDIATE, CREDIT_PAYMENT, PAYMENT_IN_ADVANCE, CREDIT_NOTE, EXPENSE.
   - **Resolved (clarify 2026-10-27):** the legacy labels in sentence case: "N/A", "Contado", "Pago de crédito", "Pago anticipado", "Nota de crédito", "Gasto".
   - This needs confirmation against what users call them in the legacy system.

6. **Should the payment view show an "Aplicado" total?**
   - **Resolved (clarify 2026-10-27):** yes, as the header summary line Importe · Aplicado · Sin aplicar (FR-013a).

7. **The verified column in cross-facility mode.** The spec's Assumptions keep Verificado, Forma de pago and Sin aplicar visible there even though they can't be filtered.
   - With the added Sucursal column, that's 10 columns.
   - **Assumed:** keep all of them (see Q3).

8. **Where "Pagos" sits in the Sales nav section.**
   - Options: after "Cortes de caja" (cash-related), or after "Pedidos" (back-office documents).
   - **Assumed:** after "Cortes de caja".
