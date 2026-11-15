# Wireframes: For Delivery Queue

**Spec**: [spec.md](./spec.md) | **Drawn**: 2026-11-15 | **Fidelity**: low

Drawn from the spec before planning. Layout is indicative, not prescriptive. Every dimension, colour and spacing comes from the design tokens (constitution §V).

## Screen: Por entregar (`/sales/for-delivery`)

This is a new navigation destination in the Logística group, after Aprobación de entregas. It is gated on `PrivilegeGate(SystemObject.forDeliver, AccessRight.read)` (FR-001). The route is Open Question 1.

### State: populated, default period (Hoy), user with ForDeliver read and Delivery Orders read

```text
┌ Por entregar ────────────────────────────────────────────────────────────────────────────┐
│                                                                                   [ ⚙ ]  │
├──────┬──────────────┬───────────────┬────────────┬─────┬─────────────────────┬────────┬────────┤
│Folio │ Cliente      │ Destino       │ Programada │Prio.│ Producto            │Almacén │Pendien.│
├──────┼──────────────┼───────────────┼────────────┼─────┼─────────────────────┼────────┼────────┤
│ 1541 │ Constructor… │ Calle 5 #33,… │ 2026-11-15 │   5 │ CEM-50 Cemento gri… │ Centro │  40.00 │
│ 1541 │ Constructor… │ Calle 5 #33,… │ 2026-11-15 │   5 │ VAR-38 Varilla 3/8" │ Centro │ 120.00 │
│ 1538 │ Ferretería … │ Av. Juárez 1… │ 2026-11-15 │   2 │ BLK-15 Block 15x20… │ Norte  │ 500.00 │
│ 1536 │ Materiales … │ Periférico 2… │ 2026-11-15 │   0 │ CEM-50 Cemento gri… │ Centro │  10.00 │
├──────┴──────────────┴───────────────┴────────────┴─────┴─────────────────────┴────────┴────────┤
│                                                           1–12 de 12    ‹  1  ›                 │
└────────────────────────────────────────────────────────────────────────────────────────────────┘
```

- **Filter row.** `CatalogFilterBar` with no `search` and one entry in `filters`: the badged `Icons.tune` button that opens `showCatalogFilterSheet`, as in Órdenes de entrega (FR-011). The server has no search, so §VI says to leave the search box out. No badge on Hoy, the default.
- **Table.** `DataTableView<PendingDeliveryLine>`, in the server's order (FR-004, FR-005).
  - Programada is on every period. It's what tells the user which period they're looking at, since there are no tabs.
  - Prio. and Pendiente are right-aligned. Cliente, Destino and Producto are truncated with a tooltip (§VI).
  - Pendiente uses the app's quantity format.
  - Customer, ship-to and warehouse names come from lookups, as in spec 061. A name the user can't read falls back to its number.
  - Lines of one order sit next to each other and repeat the order columns. See Open Question 2.
- **No row actions.** The queue is read-only (FR-010), so there's no action column. The §VI rule that each row must have Edit as its primary action doesn't apply to a read-only queue, the same reading specs 060 and 062 used for theirs.
- **Row tap.** It pushes the spec 061 detail screen, `/sales/delivery-orders/:id`, so back returns here. The queue reloads and keeps its period and page (FR-008, FR-009).
- **Pagination.** `CatalogPagination`, page size 20, showing the period's total (FR-006). Period and page live in the URL, e.g. `?period=tomorrow&page=2` (FR-007).

### State: filter panel open

```text
                                              ┌ Filtros ──────────────────────── ✕ ┐
                                              │                                    │
                                              │ Periodo                            │
                                              │  ○ Anteriores                  (4) │
                                              │  ○ Ayer · 14 nov               (2) │
                                              │  ● Hoy · 15 nov               (12) │
                                              │  ○ Mañana · 16 nov             (7) │
                                              │  ○ Pasado mañana · 17 nov      (3) │
                                              │  ○ Posteriores                 (9) │
                                              │                                    │
                                              ├────────────────────────────────────┤
                                              │ [ Borrar todo ]        [ Aplicar ] │
                                              └────────────────────────────────────┘
```

- `showCatalogFilterSheet`: a side sheet at regular width, a bottom sheet on compact. Picking a period applies live, like the other facet panels (FR-002, FR-003).
- **Options.** Six, in the server's order. The counts are each period's total from the last load. Each option's look (radio list or single-select chips) follows whatever single-select facet the existing panels use; see Open Question 3.
- **Borrar todo** returns to Hoy (FR-011). Aplicar closes the panel.

### State: populated, another period (e.g. Anteriores)

```text
│                                                                                 [ ⚙¹ ]  │
├──────┬──────────────┬───────────────┬────────────┬─────┬─────────────────────┬────────┬────────┤
│ 1502 │ Constructor… │ Calle 5 #33,… │ 2026-11-10 │   3 │ CEM-50 Cemento gri… │ Centro │  20.00 │
│ 1499 │ Obras del V… │ Km 4 carr. T… │ 2026-11-08 │   0 │ VAR-12 Varilla 1/2" │ Norte  │  60.00 │
```

- **Badge.** The filters button shows one active filter (US2 scenario 2).
- **Posteriores** looks the same; a line with no scheduled date says "Sin fecha" in Programada (FR-005).

### State: user without Delivery Orders read

The table looks the same, but rows don't respond to a tap: no hover highlight and no pointer cursor (FR-009, US3 scenario 2).

### State: empty period

```text
│                                                                                 [ ⚙¹ ]  │
├──────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                          │
│                  No hay entregas pendientes para este periodo.                           │
│                            [ Borrar filtros ]                                            │
│                                                                                          │
└──────────────────────────────────────────────────────────────────────────────────────────┘
```

- `CatalogListStateView` empty variant with `isFiltered` set when the period isn't Hoy, so it offers "Borrar filtros" back to Hoy (FR-012, US2 scenario 6). On Hoy itself there's no button.

### State: loading / error

- **Loading:** `CatalogListStateView` loading variant under the filter row.
- **Error:** `CatalogListStateView` error variant with "Reintentar", message mapped from the API error code (FR-012, FR-013). The period stays in the URL.

### State: permission denied

No drawing. Without ForDeliver read the destination isn't in the navigation, and the route redirects the way every gated route does (FR-001, SC-004).

### Compact tier

```text
┌ Por entregar ──────────────── [ ⚙ ] ┐
├──────────────────────────────────────┤
│ 1541 · Constructora Gil         P5  │
│ CEM-50 Cemento gris 50 kg            │
│ Centro · 2026-11-15         40.00    │
├──────────────────────────────────────┤
│ 1541 · Constructora Gil         P5  │
│ VAR-38 Varilla 3/8"                  │
│ Centro · 2026-11-15        120.00    │
├──────────────────────────────────────┤
│        1–12 de 12   ‹ 1 ›            │
└──────────────────────────────────────┘
```

- **Rows** become cards (`DataTableView` compact layout): folio, customer and priority on the first line, product on the second, warehouse, scheduled date and open quantity on the third.
- **Dropped:** Destino. It's long, and the screen is mostly used on desktop. Tapping the card shows it on the order's detail screen.
- **Filter panel** opens as a bottom sheet.

## Open Questions

All three were resolved in planning: 1 → research R9 (`/sales/for-delivery`), 2 → R10 (flat rows), 3 → R5 (the existing dropdown facet, no "all" item).

1. **Route.** Siblings live under `/sales/…` (`/sales/delivery-orders`, `/sales/delivery-order-approval`) even though the menu group is Logística. Options: `/sales/for-delivery`, `/sales/pending-deliveries`, or a new `/logistics/…` prefix. Wireframe assumed `/sales/for-delivery`.
2. **One row per line or per order.** The server returns lines, so an order with five lines repeats its folio, customer and ship-to five times. Options: flat rows (as drawn, the legacy layout), or group lines under an order header row. Grouping breaks the period counts and pagination, which count lines. Wireframe assumed flat rows.
3. **Single-select facet control.** The period is the first facet that must always have one value (no "any"). Options: the single-select control an existing panel already uses, without an "all" choice; or a radio list. Wireframe assumed whatever existing panels use, to be confirmed in planning.
