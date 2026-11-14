# Wireframes: Delivery Orders

**Spec**: [spec.md](./spec.md) | **Drawn**: 2026-11-14 | **Fidelity**: low

These wireframes were drawn from the spec, before planning. Layout is indicative, not prescriptive. Every dimension, colour and spacing comes from the design tokens (constitution §V).

## Screen: Órdenes de entrega (`/sales/delivery-orders`)

This is a new navigation destination, first in the Logística group (decided after implementation; see Open Question 1). It is gated on `PrivilegeGate(SystemObject.deliveryOrders, AccessRight.read)` (FR-001). Where it sits in the navigation is Open Question 1.

### State: populated (opening filters)

```text
┌ Órdenes de entrega ──────────────────────────────────────────────────────────────────────────┐
│ [🔍 Folio                            ]  [⚙ Filtros]                                           │
├──────────┬──────────────────┬─────────┬────────────┬──────────────────┬─────────┬──────────────┤
│ Folio    │ Cliente          │ Tipo    │ Programada │ Destino          │ Pedidos │ Estado       │
├──────────┼──────────────────┼─────────┼────────────┼──────────────────┼─────────┼──────────────┤
│ Borrador │ Ferretería López │ Entrega │ 2026-11-15 │ Av. Juárez 120,… │ 8841    │ (Borrador)   │
│ 1532     │ Constructora Gil │ Entrega │ 2026-11-14 │ Calle 5 #33, Ce… │ 8790, 8 │ (En prepar.) │
│ 1529     │ Materiales Ríos  │ Recoge  │ 2026-11-14 │ Sucursal Centro  │ 8802    │ (Lista p. r.)│
│ 1517     │ Ana Martínez     │ Entrega │ 2026-11-13 │ Priv. Olmos 4, … │ 8755    │ (Fallida)    │
├──────────┴──────────────────┴─────────┴────────────┴──────────────────┴─────────┴──────────────┤
│                                                           1–20 de 37    ‹  1  2  ›           │
└──────────────────────────────────────────────────────────────────────────────────────────────┘
```

- **Filter row.** `CatalogFilterBar` with a `CatalogSearchBar`, which takes digits only (FR-005, spec edge case "Text search"). The badged filters button opens `showCatalogFilterSheet`. The badge reads nothing on first load, because the list opens on every status until mbe-api#312 ships (FR-003, plan R3). There is no Create action, because orders are created only in the POS (spec Assumptions).
- **Table.** `DataTableView<DeliveryOrderSummary>`, newest first (FR-002).
  - Folio shows "Borrador" when the order has none.
  - Destino and Cliente are truncated with a tooltip (§VI secondary text).
  - Pedidos lists the sales-order numbers, also truncated with a tooltip.
  - Estado is a new `DeliveryOrderStatusChip` built on the shared `StatusChip<T>`. It is never truncated.
- **Rows.** A row has no icons. Clicking it opens the detail screen (FR-006). See Open Question 2.
- **Pagination.** `CatalogPagination`, page size 20.
- **Names.** Customer and ship-to arrive as ids and are resolved through batch lookups. A name the user can't read falls back to its number (FR-025).

### State: filter sheet open

```text
                                            ┌ Filtros ──────────────────────────────┐
                                            │ Estado                                │
                                            │ [ Todas                            ▾] │
                                            │ Tipo                                  │
                                            │ [ Todos                            ▾] │
                                            │ Fecha programada                      │
                                            │ [ 📅 Cualquier fecha               ]  │
                                            │ Cliente                               │
                                            │ [ Buscar cliente…                  ]  │
                                            │ Pedido                                │
                                            │ [ Número de pedido                 ]  │
                                            │ Sucursal                              │
                                            │ [ Centro (mi sucursal)             ▾] │
                                            │                                       │
                                            │ [Limpiar todo]            [Aplicar]   │
                                            └───────────────────────────────────────┘
```

- **Estado.** A dropdown: "Todas" (the default), then each of the 11 statuses (FR-004). "Activas" is added, and becomes the default, when mbe-api#312 ships.
- **Tipo.** Todos, Entrega or Recoge en tienda.
- **Fecha programada.** `DateRangeFilterChip`.
- **Cliente.** `CatalogEntityPicker` over customers. It's offered only to users with Customers read; see Open Question 6.
- **Pedido.** A numeric field holding the sales-order id. The server filters by id, not by folio.
- **Sucursal.** Offered only to administrators, and defaults to the user's facility. Anyone else's `facility` URL key is ignored, because the server doesn't check it (mbe-api#314, plan R3).
- **"Limpiar todo".** Returns to every status, every type, any date, no customer, no sale, the user's facility.

### State: empty

```text
┌ Órdenes de entrega ──────────────────────────────────────────────────────────────────┐
│ [🔍 Folio                            ]  [⚙ Filtros]                                   │
├──────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                      │
│               No hay órdenes de entrega con estos filtros.                           │
│                            [Quitar filtros]                                          │
│                                                                                      │
└──────────────────────────────────────────────────────────────────────────────────────┘
```

- This is the `CatalogListStateView` empty variant. "Quitar filtros" appears only when the filters differ from the opening ones.

### State: loading / load error / no access

- **Loading.** A `CatalogListStateView` spinner.
- **Load error.** The retry state, with text from `localizeProblem` (§III).
- **No Delivery Orders read.** The navigation entry is hidden, and the route guard redirects (§IV).

### Compact tier

```text
┌ Órdenes de entrega ─────────────────┐
│ [🔍 Folio…            ] [⚙]         │
├─────────────────────────────────────┤
│ 1532 · Entrega      (En prepar.)    │
│ Constructora Gil                    │
│ 2026-11-14 · Calle 5 #33, Centro    │
├─────────────────────────────────────┤
│ Borrador · Entrega  (Borrador)      │
│ Ferretería López                    │
│ 2026-11-15 · Av. Juárez 120         │
├─────────────────────────────────────┤
│              ‹ 1 2 ›                │
└─────────────────────────────────────┘
```

- `DataTableView` falls back to stacked rows.
- The Pedidos column is dropped at this tier. The detail screen shows it, and it's the least useful column for picking an order at a glance.

## Screen: Orden de entrega (`/sales/delivery-orders/:id`)

This is a full detail screen, not a panel (§VI). The order owns a child collection (its lines) and two linked sections (history and proof), and it needs its own URL, for links from parent and child orders. It follows the document-detail pattern of `refund_detail_screen.dart`: a facts strip, the lines, then the status actions bottom-right. `AppBar.actions` is empty (§VI).

### State: draft, user with Delivery Orders update

```text
┌ ← Orden de entrega · Borrador ───────────────────────────────────────────────────────────────┐
│ ┌──────────────────────────────────────────────────────────────────────────────────────────┐ │
│ │ ⚠ Rechazada: "Falta confirmar dirección con el cliente."                                  │ │
│ └──────────────────────────────────────────────────────────────────────────────────────────┘ │
│ Folio      Estado       Tipo     Cliente           Sucursal  Programada   Prioridad          │
│ Borrador   (Borrador)   Entrega  Ferretería López  Centro    2026-11-15   0                  │
│                                                                                              │
│ Destino   Av. Juárez 120, Col. Centro, 64000          Contacto  Luis López · 81 1234 5678    │
│ Pedidos   8841 ↗                                      Comentario  Entregar por la mañana     │
│                                                                  [✎ Editar encabezado]       │
│ ── Líneas ─────────────────────────────────────────────────────────────── [+ Agregar línea]  │
│ Código   Producto              Almacén   Pedido  Ordenada Comprom. Entreg. Devuelta Abierta  │
│ CEM-50   Cemento gris 50 kg    Bodega 1  8841     10.00     0.00    0.00     0.00   10.00 ✎ 🗑│
│ VAR-38   Varilla 3/8"          Bodega 1  8841     25.00     0.00    0.00     0.00   25.00 ✎ 🗑│
│                                                                                              │
│ ── Historial ────────────────────────────────────────────────────────────────────────────────│
│ 2026-11-14 09:12  —             → Borrador                  Carla Ruiz                       │
│ 2026-11-14 10:03  Borrador      → Pend. aprobación          Pedro Sosa                       │
│ 2026-11-14 11:40  Pend. aprob.  → Borrador                  Marta Díaz  "Falta confirmar…"   │
│                                                                                              │
│                                                              [Cancelar orden]  [Confirmar]   │
└──────────────────────────────────────────────────────────────────────────────────────────────┘
```

- **Rejection banner.** The shared info-banner style, shown while `rejection_reason` is set (FR-007, spec edge case "Rejected and back to draft").
- **Facts strip.** `FactStripRow` of `CompactField`s, with the status as `DeliveryOrderStatusChip`. The second band is a `ResponsiveFormGrid` of read-only `CompactField`s: Destino, Contacto, Pedidos and Comentario. Pedidos links to each sale in Pedidos (`/sales/orders/:id`). Parent and child orders appear here as links when they exist (FR-007).
- **"Editar encabezado".** An outlined button, shown on a draft with update. It opens the header dialog below (FR-012). See Open Question 3.
- **Lines.** A `DataTableView` of the lines. The five quantities are right-aligned and never truncated (FR-008).
  - On a draft with update, each row has ✎ (edit quantity) and 🗑 (remove), within the two-icon limit (§VI). The icons come from `catalog_action_icons.dart`.
  - "Agregar línea" sits in the section header (FR-013, FR-014).
- **History.** A plain bounded list, oldest first, with no pagination, because an order has at most a few dozen events (FR-009). A long reason is truncated with a tooltip.
- **Actions.** `Wrap`, end-aligned:
  - "Cancelar orden" is outlined, so it stays lighter than the primary action;
  - "Confirmar" is filled.

  Each is shown only when the order's status, its type and the user's rights allow it (FR-011). "Confirmar" is disabled with a hint when the order has no lines (FR-016).

### State: draft, user without Delivery Orders update

The draft looks the same, but without "Editar encabezado", "Agregar línea", the line ✎ and 🗑 icons, and the action buttons (FR-015, SC-006). They're absent, not disabled (§VI).

### State: En preparación (delivery, confirmed)

```text
┌ ← Orden de entrega 1532 ─────────────────────────────────────────────────────────────────────┐
│ Folio  Estado            Tipo     Cliente           Sucursal  Programada   Prioridad         │
│ 1532   (En preparación)  Entrega  Constructora Gil  Centro    2026-11-14   2                 │
│ Destino  Calle 5 #33, Centro                          Contacto  Jorge Gil                    │
│ Pedidos  8790 ↗  8812 ↗                               De la orden  1498 ↗  (entrega parcial) │
│                                                                                              │
│ ── Líneas ───────────────────────────────────────────────────────────────────────────────────│
│ CEM-50   Cemento gris 50 kg    Bodega 1  8790     40.00    40.00    0.00     0.00    0.00    │
│ ARE-01   Arena m³              Patio     8812      3.00     0.00    0.00     0.00    3.00    │
│                                                                                              │
│ ── Historial ── …                                                                            │
│                                                                           [Cancelar orden]   │
└──────────────────────────────────────────────────────────────────────────────────────────────┘
```

- **Read-only.** The header and lines can't be edited.
- **Parent link.** "De la orden 1498" shows because this order is a partial delivery's child (spec edge case "Partial delivery's child order").
- **Actions.** The only one is "Cancelar orden" (FR-018). It stays offered even when the order is on an open trip, which is the known server gap mbe-api#311.

### State: Fallida

The status chip reads (Fallida), and the Devuelta column shows the returned quantities. The actions are `[Cancelar orden] [Reprogramar]`, with Reprogramar filled (FR-019). After a requeue the order reads (En preparación), Devuelta is back at 0.00, and Abierta is restored (US6).

### State: pickup, Aprobada / Lista para recoger

```text
│ Folio  Estado        Tipo               …                                                    │
│ 1529   (Aprobada)    Recoge en tienda   …                                                    │
│ …                                                                                            │
│                                               [Cancelar orden]  [Lista para recoger]         │
```

```text
│ 1529   (Lista para recoger)  Recoge en tienda   …                                            │
│ …                                                                                            │
│                                               [Cancelar orden]  [Entregar al cliente]        │
```

- **Pickup actions.** "Lista para recoger" is offered only on a pickup order in Aprobada (FR-020). "Entregar al cliente" is offered only in Lista para recoger, and opens the pickup dialog (FR-021).

### State: terminal with proof (Recogida / Entregada / Entregada parcialmente)

```text
│ ── Comprobante de entrega ──────────────────────────────────────────────────────────────────│
│ Recibió           Juan Pérez                         ┌──────────────┐                        │
│ Identificación    INE 0123456789                     │   [ photo ]  │                        │
│ Registrado        2026-11-14 16:22                   └──────────────┘                        │
```

- **Proof section.** A read-only section between Lines and History (FR-010). The photo is loaded with the authenticated image fetch, and tapping it opens it larger. The section is left out when there's no proof.
- **Actions.** None. The action area is left out entirely.
- **Cancelada.** Has no proof section and no actions. The history shows the cancellation reason.

### State: not found / load error

These follow `refund_detail_screen.dart`'s `_NotFound` and `_LoadFailed`: a message, plus an outlined "Volver a órdenes de entrega" button. A load error also offers retry.

### Compact tier

```text
┌ ← Orden 1532 ───────────────────────┐
│ (En preparación) · Entrega          │
│ Constructora Gil                    │
│ Programada 2026-11-14 · Prioridad 2 │
│ Destino  Calle 5 #33, Centro        │
│ Pedidos  8790 ↗ 8812 ↗              │
│ ── Líneas ────────────────────────  │
│ CEM-50 Cemento gris 50 kg           │
│ Bodega 1 · Pedido 8790              │
│ Ord 40 · Comp 40 · Ent 0 · Dev 0    │
│ Abierta 0                           │
│ ──────────────────────────────────  │
│ ── Historial ── …                   │
│ [Cancelar orden]                    │
└─────────────────────────────────────┘
```

- **Facts strip.** Wraps to one column.
- **Lines.** Stack as cards, with every quantity kept. A draft's ✎ and 🗑 icons stay on the card's first line.
- **Actions.** Wrap to full-width buttons, primary last.

## Dialogs (all `ResponsiveDialog`)

### Confirmar

```text
┌ ¿Confirmar orden de entrega? ─────────────────────────────┐
│ Ferretería López · Programada 2026-11-15 · 2 líneas       │
│ Una vez confirmada, ya no podrá editarse.                 │
│                                [Volver]   [Confirmar]     │
└───────────────────────────────────────────────────────────┘
```

- **Content.** Names the customer, the scheduled date and the line count (FR-016).
- **On success.** The screen reloads, showing the folio and status the server assigned.
- **Too-soon date.** `delivery_order.insufficient_notice` keeps the dialog open with an `ErrorBanner`: "Se requieren al menos 24 h de anticipación. Fecha más próxima: 2026-11-16 08:00." (FR-017).

### Cancelar orden

```text
┌ Cancelar orden 1532 ──────────────────────────────────────┐
│ Constructora Gil · Programada 2026-11-14                  │
│ Motivo                                                    │
│ [                                                      ]  │
│                                [Volver]  [Cancelar orden] │
└───────────────────────────────────────────────────────────┘
```

- **Reason.** Required. The confirm button stays disabled while it's blank (FR-018).
- **Refused.** `state.transition_invalid` closes the dialog, shows the generic localized transition message, and reloads the order, so the new status explains why (US4 scenario 4, plan R10).

### Reprogramar / Lista para recoger

Both are simple confirmations naming the folio and customer. Neither has a body field (FR-019, FR-020).

### Entregar al cliente (pickup proof)

```text
┌ Entregar al cliente · Orden 1529 ─────────────────────────┐
│ Nombre de quien recibe                                    │
│ [                                                      ]  │
│ Identificación mostrada                                   │
│ [ INE 0123456789                                       ]  │
│ Foto                                                      │
│ [📎 Elegir archivo]   recibo.jpg  ✕                       │
│                                [Volver]   [Entregar]      │
└───────────────────────────────────────────────────────────┘
```

- **Required.** The receiver's name, the identification shown and a photo. "Entregar" stays disabled until all three are filled, with neither text field blank (FR-021, SC-004).
- **Identificación mostrada.** Free text. The server stores what was shown (`receiver_id_shown`, a string), not a yes or no (resolved Open Question 5).
- **Photo.** Chosen as a file through the existing `file_picker` dependency (resolved Open Question 4).

### Editar encabezado

```text
┌ Editar encabezado ────────────────────────────────────────────────────────┐
│ Fecha programada            Prioridad                                     │
│ [ 📅 2026-11-15 09:00   ]   [ 0        ]                                  │
│ Destino                                                                   │
│ [ Av. Juárez 120, Col. Centro                                          ▾] │
│ Contacto                                                                  │
│ [ Luis López · 81 1234 5678                                            ▾] │
│ Comentario                                                                │
│ [ Entregar por la mañana                                               ]  │
│                                                  [Cancelar]  [Guardar]    │
└───────────────────────────────────────────────────────────────────────────┘
```

- **Layout.** `ResponsiveFormGrid`, two columns.
- **Destino.** Reuses the POS `CustomerAddressPicker`, over the customer's addresses (FR-012). On a pickup order it's read-only and shows the store (plan R7).
- **Contacto.** Reuses `CustomerContactPicker`.
- **Prioridad.** A whole number, 0 or more.
- **No clear option.** No field offers a "clear" choice, because the server ignores empty values (spec edge case "Fields that can't be cleared"). Only changed fields are sent.

### Cantidad de línea / Quitar línea

- **✎ Cantidad.** Opens a small dialog with a numeric field. It shows "Pendiente por entregar en el pedido: 12.00" and validates more than 0 and at most that amount (FR-013).
- **🗑 Quitar.** Asks for confirmation: "¿Quitar Cemento gris 50 kg de la orden? La cantidad volverá a estar disponible para entregar."

### Agregar línea (two steps, plan R8)

```text
┌ Agregar línea · 1 de 2 ───────────────────────────────────────────────────────┐
│ Ventas completadas de Ferretería López en Centro                              │
│ [🔍 Folio de venta        ]                                                   │
│ ┌──────┬────────────┬──────────────┐                                          │
│ │ Folio│ Fecha      │        Total │                                          │
│ ├──────┼────────────┼──────────────┤                                          │
│ │ 8860 │ 2026-11-14 │    $3,240.00 │  ›                                       │
│ │ 8841 │ 2026-11-14 │   $18,900.00 │  ›                                       │
│ └──────┴────────────┴──────────────┘                                          │
│ [Cargar más]                                              [Cancelar]          │
└───────────────────────────────────────────────────────────────────────────────┘
```

```text
┌ Agregar línea · 2 de 2 ─ Venta 8860 ──────────────────────────────────────────┐
│ ┌────────┬────────────────────────┬──────────┬────────────────────┐           │
│ │ Código │ Producto               │ Pendiente│ Cantidad           │           │
│ ├────────┼────────────────────────┼──────────┼────────────────────┤           │
│ │ CEM-50 │ Cemento gris 50 kg     │    15.00 │ [        ]         │           │
│ │ BLK-15 │ Block 15×20×40         │   200.00 │ [        ]         │           │
│ └────────┴────────────────────────┴──────────┴────────────────────┘           │
│ [‹ Otra venta]                                    [Cancelar]  [Agregar]       │
└───────────────────────────────────────────────────────────────────────────────┘
```

- **Step 1.** The customer's completed sales at the order's facility, newest first, 20 at a time. Tapping a sale goes to step 2.
- **Step 2.** That sale's lines that still have quantity left, computed on the client until mbe-api#313 ships. Lines already on the order are left out (FR-014).
- **Multiple lines.** Several lines can get a quantity in one pass. "Agregar" sends one add per filled row, in sequence, and stops at the first error.
- **Gate.** Offered only with Delivery Orders update and Sales Orders read (contract C7).

## Open Questions

1. **Where does "Órdenes de entrega" go in the navigation?**
   - Options: under Ventas after Pedidos; or a new "Logística" group, which would later hold itineraries and might move Vehículos and Operadores out of Catálogos.
   - Assumed at drafting: Ventas, after Pedidos. *Resolved after implementation:* a Logística group after Ventas holding Órdenes de entrega, Vehículos and Operadores. The route stays under `/sales/`.
2. **Does a list row need the §VI Edit icon?**
   - Options: no icons, and the row opens the detail (as Pedidos, Reembolsos and Notas de crédito do); or an Edit icon on drafts.
   - Assumed: no icons. Delivery orders are documents with a status lifecycle, not catalog records, so editing happens on the draft's detail screen. The Edit rule in §VI is written for catalog rows.
3. **How do you edit the header and lines: in place, or with a view/edit toggle?**
   - Options: the document pattern, where a draft's lines are editable directly and the header is edited in a dialog; or the §VI read-only-then-"Editar" toggle with `RecordFormActions`.
   - Assumed: the document pattern, as in Reembolsos. A non-draft is read-only anyway, and a toggle would add a step for the one status that can be edited.
4. **Pickup photo: camera or file?** *Resolved while drafting:* file only. The app has `file_picker` but no camera plugin, and the spec's assumption is narrowed to match. Camera capture can come with itinerary proof of delivery (#41), which is phone-first.
5. **Is "showed ID" a yes/no?** *Resolved while drafting:* no. mbe-api's `build_proof` takes `receiver_id_shown` as a string and refuses it blank (`delivery_order.proof_incomplete`). It records which ID was shown. The spec (US7, FR-010, FR-021, Key Entities, SC-004) now says "identification shown (free text)".
6. **Customer filter and names without Customers read.**
   - The customer picker and batch name lookup need Customers read. Delivery Orders read doesn't grant it.
   - Options: hide the customer filter and show customer numbers; or require Customers read for the screen.
   - Assumed: hide the filter and fall back to numbers (FR-025), the same as the facility fallback in spec 060.
7. **Where does "Agregar línea" get deliverable lines from?** *Resolved in planning (research R8):* not from the POS source, which is scoped to one register and today. The user picks one of the customer's completed sales, and the app computes what's left on that sale's lines. The user also chose to file mbe-api#313 for a server query that replaces the computation.
