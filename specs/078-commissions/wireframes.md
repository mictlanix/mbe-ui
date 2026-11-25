# Wireframes: Commissions

**Spec**: [spec.md](./spec.md) | **Drawn**: 2026-11-25 | **Fidelity**: low

Drawn from the spec before planning. Layout is indicative, not prescriptive — every
dimension, colour and spacing resolves through the design tokens, per constitution §V.

Every screen here is gated by CommissionsBySalesPerson (112). Read opens it (FR-020, FR-021);
the actions drawn are absent, not disabled, for a user without the right that governs them.

Navigation: one entry, **Finanzas › Comisiones** (`/commissions`), after Gastos.
The settings live one level down at `/commissions/settings` (see Open Question 1).

---

## Screen: Months list (`/commissions`)

### State: populated

```
┌─ Comisiones ────────────────────────────────────────────────────────────────────────────┐
│                                        [Filtros (0)]  [Abrir mes…]  [⚙ Configuración]  │
│ ┌─────────────────────────────────────────────────────────────────────────────────────┐ │
│ │ Mes              Estado         Total        Cerrado el          Pagado el          │ │
│ ├─────────────────────────────────────────────────────────────────────────────────────┤ │
│ │ Octubre 2026     (● Cerrado)    $48,210.33   2026-11-03 10:12    —                  │ │
│ │ Septiembre 2026  (✓ Pagado)     $51,004.90   2026-10-02 09:40    2026-10-05 17:02   │ │
│ │ Agosto 2026      (✓ Pagado)     $46,877.15   2026-09-01 11:05    2026-09-04 12:30   │ │
│ │ Julio 2026       (○ Abierto)         $0.00   —                   —                  │ │
│ └─────────────────────────────────────────────────────────────────────────────────────┘ │
│                                                         ‹  1–4 de 4  ›                  │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

- Filter row: `CatalogFilterBar` with **no search** (the endpoint has none, §VI) and
  `actions`: `OutlinedButton` "Abrir mes…" (FR-002) and `OutlinedButton.icon`
  "Configuración" (visible with Read; settings are read-only without C/U/D).
  "Filtros" opens `showCatalogFilterSheet` with a single **Estado** facet (Abierto / Cerrado /
  Pagado), filtered client-side — see Open Question 6.
- Table: `DataTableView`; Mes left, Total right-aligned, Estado as `StatusChip`
  (Abierto → neutral, Cerrado → info, Pagado → success). Dates via `formattersProvider`.
  Row click opens the month (`/commissions/2026/10`). No Edit icon: a month is not edited,
  it changes state on its own screen (Open Question 3). FR-001.
- "Julio 2026, Abierto, $0.00" is a month reopened and not closed again (US3 sc. 4).
- `CatalogPagination` client-side; the list is one row per closed month, bounded by time.

### State: empty (no month ever closed)

```
┌─ Comisiones ────────────────────────────────────────────────────────────────────────────┐
│                                                     [Abrir mes…]  [⚙ Configuración]     │
│                                                                                         │
│                         Todavía no se ha cerrado ningún mes.                            │
│        Puede revisar cualquier mes; el primero que cierre inicia el historial.          │
│                                                                                         │
│                              [Ver octubre 2026]                                         │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

- `ListStateViews` empty state with a `FilledButton` to the previous calendar month
  (US3 sc. 3, FR-002 default). The "Filtros" button is hidden when the list is empty.

### State: loading / error

```
┌─ Comisiones ──────────────────────────────┐   ┌─ Comisiones ──────────────────────────────┐
│                [Abrir mes…] [⚙ Config.]   │   │                [Abrir mes…] [⚙ Config.]   │
│                                           │   │ ┌ ⚠ No se pudieron cargar los meses. ───┐ │
│                  ◌  cargando              │   │ │                       [Reintentar]    │ │
│                                           │   │ └───────────────────────────────────────┘ │
└───────────────────────────────────────────┘   └───────────────────────────────────────────┘
```

- `ListStateViews` loading / error (message via the shared localized-problem path, §III).

### Dialog: Abrir mes…

```
┌─ Abrir mes ───────────────────────────┐
│  Mes   [ Octubre        ▾ ]           │
│  Año   [ 2026           ▾ ]           │
│                                       │
│               [Cancelar]  [Abrir]     │
└───────────────────────────────────────┘
```

- `ResponsiveDialog` with two dropdowns. Defaults to the previous calendar month (FR-002).
  Months after the current one are not offered. No shared month picker exists — Open Question 2.

### Compact tier

```
┌─ Comisiones ─────────────────────┐
│ [Filtros] [Abrir mes…] [⚙]       │
│ ┌──────────────────────────────┐ │
│ │ Octubre 2026     (● Cerrado) │ │
│ │ $48,210.33                   │ │
│ │ Cerrado 2026-11-03           │ │
│ ├──────────────────────────────┤ │
│ │ Septiembre 2026  (✓ Pagado)  │ │
│ │ $51,004.90                   │ │
│ │ Pagado 2026-10-05            │ │
│ └──────────────────────────────┘ │
└──────────────────────────────────┘
```

- Rows become two-line cards; "Cerrado el" collapses to the latest of closed/paid.
  "Configuración" shrinks to its icon with a tooltip.

---

## Screen: Month (`/commissions/:year/:month`)

A full screen, not a panel: it needs its own URL (a month is linked to from the list and
from the "Abrir mes" dialog) and owns a child collection (its lines) — §VI record surface.

### State: open month, all agents (live calculation)

```
┌─ ← Comisiones · Octubre 2026 ───────────────────────────────────────────────────────────┐
│ ‹ Sep   Octubre 2026  Oct ›        (○ Abierto)                                          │
│ ┌ ⓘ Cálculo en vivo, no definitivo. Cambia con las ventas y la configuración hasta ──┐ │
│ │   que se cierre el mes.                                                              │ │
│ └──────────────────────────────────────────────────────────────────────────────────────┘ │
│ Total del mes  $48,210.33          Agente [Todos ▾]                    [Cerrar mes]     │
│                                                                                         │
│ Totales por agente                                                                      │
│ ┌─────────────────────────────────────────────────────────────────────────────────────┐ │
│ │ Agente                    Esquema           Líneas      Comisión                    │ │
│ ├─────────────────────────────────────────────────────────────────────────────────────┤ │
│ │ Juan Pérez                Pago total           412    $21,330.10                    │ │
│ │ María López               Pagos parciales      288    $15,002.55                    │ │
│ │ Agente #76                —                     14       $120.40                    │ │
│ │ Sin etiqueta (3 líneas sin comisión)                     $0.00                      │ │
│ └─────────────────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

- Header band: `FactStripRow` — period navigator (‹ previous / next ›, Open Question 2),
  `StatusChip`, and the grand total (FR-003). Next is hidden past the current month.
- Not-final notice: an info banner. The shared `ErrorBanner` is error-toned only — Open
  Question 4.
- Agent selector: the agent filter (FR-004). Drawn inline because it is the screen's
  main pivot, not a secondary facet — this conflicts with §VI's facet rule, Open Question 5.
- "Cerrar mes": `FilledButton` in the body action area (FR-007). It is not an Edit/Save/Delete,
  so `RecordFormActions` does not render it — Open Question 3.
- Totals table: `DataTableView`, one row per agent; a row click selects that agent
  (same as the selector). "Agente #76" is an agent no longer in the agents list (FR-006).
  The "Sin etiqueta" row is drawn as a prompt to fix labels; whether it belongs here is
  Open Question 7.
- With all agents selected, lines are not listed: thousands of rows with no pivot are
  unreadable, and the label breakdown needs one agent. Open Question 8.

### State: open month, one agent

```
┌─ ← Comisiones · Octubre 2026 ───────────────────────────────────────────────────────────┐
│ ‹ Sep   Octubre 2026  Oct ›        (○ Abierto)                                          │
│ ┌ ⓘ Cálculo en vivo, no definitivo. … ──────────────────────────────────────────────┐ │
│ Total de Juan Pérez  $21,330.10    Agente [Juan Pérez ▾]  Esquema: Pago total  [Cerrar mes] │
│                                                                                         │
│ Totales por etiqueta                                                                    │
│ ┌──────────────────────────────────────────────┐                                        │
│ │ Etiqueta          Líneas      Comisión       │                                        │
│ │ CONCRETOS            220   $14,210.00        │                                        │
│ │ TABIQUES             150    $6,980.10        │                                        │
│ │ Sin etiqueta           3        $0.00        │                                        │
│ └──────────────────────────────────────────────┘                                        │
│                                                                                         │
│ Líneas                                                           [Filtros (0)]          │
│ ┌─────────────────────────────────────────────────────────────────────────────────────┐ │
│ │ Pedido  Pagado      Cliente          Producto         Etiqueta     Particip.  Tasa  │ │
│ │                                                                   Importe  Comisión │ │
│ ├─────────────────────────────────────────────────────────────────────────────────────┤ │
│ │ 336924  2026-10-14  Constructora R…  Block 15x20x40   CONCRETOS    VITALICIO  2.50% │ │
│ │                                                       $15,001.70   $375.04          │ │
│ │ 336990  2026-10-20  Ferretería El…   Varilla 3/8"     [Asignar…]   CAMPO      0.00% │ │
│ │                                                       $2,400.00      $0.00          │ │
│ │ ↩ 337011 2026-10-22 Constructora R…  Block 15x20x40   CONCRETOS    VITALICIO  2.50% │ │
│ │   Devolución                                          −$1,200.00   −$30.00          │ │
│ └─────────────────────────────────────────────────────────────────────────────────────┘ │
│                                                     ‹  1–50 de 412  ›                   │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

- Label totals: `DataTableView`, compact (FR-003 "each agent's totals by label").
- Lines: `DataTableView` + `CatalogPagination`, paged client-side over the one response
  (FR-005, edge case "large month"). Totals are over the whole agent, never the page.
- The row is drawn on two lines only to fit this page width. The full column set from
  FR-005 (order date, label rate, agent share, full commission, paid share, scheme) does
  not fit without horizontal scroll (§VI forbids it) — Open Question 9.
- Refund rows: leading ↩ icon and "Devolución", negative amounts (FR-005, edge case).
- "[Asignar…]" on an unlabelled line: shown on open months to users with Update (FR-016a).
  It opens the Assign label dialog below. It is the row's one extra action (§VI allows Edit
  plus one); the line has no Edit.
- "Filtros" on lines: facets Movimiento (venta/devolución), Etiqueta, Participación —
  client-side. Not required by the spec; drawn to show where they would go.
- Row click: no surface (a line has no record of its own). Open Question 10 covers linking
  to the order.

### State: closed month

```
┌─ ← Comisiones · Septiembre 2026 ────────────────────────────────────────────────────────┐
│ ‹ Ago   Septiembre 2026  Oct ›     (● Cerrado)                                          │
│ Cerrado el 2026-10-02 09:40 por admin                                               │
│ Total del mes  $51,004.90          Agente [Todos ▾]        [Reabrir]  [Marcar pagado]   │
│ Totales por agente …                                                                    │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

- No live-calculation banner: figures are final (FR-003).
- Audit line: who and when, name or user number (FR-003, Assumption "who closed/paid").
- "Reabrir" (`OutlinedButton`) only on the latest closed, unpaid month (FR-008);
  "Marcar pagado" (`FilledButton`) on any closed month (FR-009).
- Unlabelled lines show "Sin etiqueta" with no Asignar (FR-016a).

### State: paid month

```
┌─ ← Comisiones · Agosto 2026 ────────────────────────────────────────────────────────────┐
│ ‹ Jul   Agosto 2026  Sep ›         (✓ Pagado)                                           │
│ Cerrado el 2026-09-01 11:05 por admin · Pagado el 2026-09-04 12:30 por admin    │
│ Total del mes  $46,877.15          Agente [Todos ▾]                                     │
│ Totales por agente …                                                                    │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

- No actions (US2 sc. 4).

### State: open month that cannot be closed yet

```
│ ‹ Oct   Noviembre 2026             (○ Abierto)                                          │
│ ┌ ⓘ Cálculo en vivo, no definitivo. … ──────────────────────────────────────────────┐ │
│ Total del mes  $12,040.00          Agente [Todos ▾]                                     │
│ No se puede cerrar: el mes aún no termina.                                              │

│ ‹ Ago   Septiembre 2025            (○ Abierto)                                          │
│ No se puede cerrar: primero hay que cerrar agosto 2025.                                 │

│ ‹ Jun   Julio 2025                 (○ Abierto)                                          │
│ No se puede cerrar: ya hay un mes posterior cerrado.                                    │
```

- Close is absent and a plain explanatory line takes its place (FR-007, US1 sc. 4, edge
  cases "current month", "before the first close"). Which month blocks it is derived from
  the months list. The server still decides (FR-011).

### State: loading / error / refused action

```
┌ ⚠ No se pudo cerrar el mes: ya está cerrado. ─────────────────────────── [×] ┐
└──────────────────────────────────────────────────────────────────────────────┘
```

- Loading and load-error: `ListStateViews` in the content area, header kept.
- A refused Close/Reopen/Pay shows `ErrorBanner` above the totals with the localized
  reason (FR-011, US1 sc. 7), and the month reloads to its current state (FR-010).

### Dialogs: confirmations

```
┌─ Cerrar octubre 2026 ───────────────────────────────────┐
│ Se guardarán 714 líneas por $48,210.33. A partir de     │
│ ahora el mes no cambiará aunque cambien clientes,       │
│ tasas o etiquetas.                                      │
│                              [Cancelar]  [Cerrar mes]   │
└─────────────────────────────────────────────────────────┘

┌─ Reabrir septiembre 2026 ───────────────────────────────┐
│ Se descartarán las líneas guardadas. El mes volverá a   │
│ calcularse con los datos actuales y habrá que cerrarlo  │
│ de nuevo.                                               │
│                                [Cancelar]  [Reabrir]    │
└─────────────────────────────────────────────────────────┘

┌─ Marcar septiembre 2026 como pagado ────────────────────┐
│ Total $51,004.90. Un mes pagado es definitivo: no podrá │
│ reabrirse ni modificarse.                               │
│                         [Cancelar]  [Marcar pagado]     │
└─────────────────────────────────────────────────────────┘
```

- `ResponsiveDialog`; primary action shows its spinner and the dialog is not dismissible
  while the call is in flight. Cancel changes nothing (US1 sc. 6, FR-007–FR-009).

### Dialog: Assign label (from an unlabelled line)

```
┌─ Etiqueta de comisión ──────────────────────────────┐
│ Producto  Varilla 3/8"  (VAR-038)                   │
│ Etiqueta  [ Buscar etiqueta…            ▾ ]         │
│ El cambio aplica a meses abiertos y cálculos        │
│ futuros, nunca a meses cerrados.                    │
│                          [Cancelar]  [Asignar]      │
└─────────────────────────────────────────────────────┘
```

- `ResponsiveDialog` + `CatalogEntityPicker` over labels. On success the month recomputes
  (FR-016a); the settings note is FR-018.

### Compact tier

```
┌─ ← Octubre 2026 ─────────────────┐
│ ‹  Octubre 2026  ›  (○ Abierto)  │
│ ⓘ Cálculo en vivo, no definitivo │
│ Total  $48,210.33                │
│ Agente [Juan Pérez ▾]            │
│ [Cerrar mes]                     │
│ ── Por etiqueta ──────────────── │
│ CONCRETOS   220     $14,210.00   │
│ TABIQUES    150      $6,980.10   │
│ ── Líneas ─────────── [Filtros]  │
│ 336924 · 2026-10-14              │
│ Block 15x20x40 · CONCRETOS       │
│ Constructora R… · VITALICIO      │
│ $15,001.70 × 2.50%     $375.04   │
│ ──────────────────────────────── │
│ ↩ 337011 · Devolución            │
│ …                       −$30.00  │
└──────────────────────────────────┘
```

- Lines become stacked cards showing order, product, label, customer, participation,
  amount × rate and commission. Order date, label rate, agent share, full commission, paid
  share and scheme are dropped on compact. The agents table becomes a list of
  name + total.

---

## Screen: Commission settings (`/commissions/settings`)

One screen, five sections switched by a `SegmentedButton` (the payments-scope precedent),
see Open Question 1. Every section shows the note "Los cambios aplican a meses abiertos y
cálculos futuros, nunca a meses cerrados." (FR-018).

### Section: Etiquetas (populated)

```
┌─ ← Comisiones · Configuración ──────────────────────────────────────────────────────────┐
│ [Etiquetas | Participaciones | Agentes | Tasas por agente | Productos]                  │
│ ⓘ Los cambios aplican a meses abiertos y cálculos futuros, nunca a meses cerrados.      │
│ [🔍 Buscar etiqueta…                                    ]              [+ Nueva etiqueta] │
│ ┌─────────────────────────────────────────────────────────────────────────────────────┐ │
│ │ Nombre            Tasa      Comentario                                         [✎]  │ │
│ ├─────────────────────────────────────────────────────────────────────────────────────┤ │
│ │ ARMEX             0.20 %                                                       [✎]  │ │
│ │ CONCRETOS         2.50 %    Block y concreto premezclado                       [✎]  │ │
│ │ FERRETERÍA        4.00 %                                                       [✎]  │ │
│ └─────────────────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

- `CatalogFilterBar` with search (client-side; ~13 rows, bounded) and Create action (FR-012).
- `DataTableView`; Tasa right-aligned via `formattersProvider` percent; Edit icon from
  `catalog_action_icons`. No pagination: bounded list (§VI exception).
- Row click → `showRecordSheet` read-only; Edit → editable.

### Panel: label (edit)

```
                                           ┌─ Editar etiqueta ─────────────────────── × ┐
                                           │ Nombre      [CONCRETOS                ]    │
                                           │ Tasa (%)    [2.5                      ]    │
                                           │ Comentario  [Block y concreto premez… ]    │
                                           │                                            │
                                           │ ┌ ⚠ No se puede eliminar: la etiqueta   ┐ │
                                           │ │   está asignada a productos.          │ │
                                           │ └───────────────────────────────────────┘ │
                                           │              [Eliminar]  [Guardar]         │
                                           └────────────────────────────────────────────┘
```

- `RecordSheet` + `ResponsiveFormGrid` + `RecordFormActions` (Delete, then Save).
- Rate typed as a percentage, validated 0–100 before sending (FR-017); stored as a
  fraction. The in-use refusal shows in `FormErrorBanner` (FR-019, US4 sc. 2).

### Section: Participaciones

```
│ [🔍 Buscar…                                         ]               [+ Nueva participación] │
│ │ Nombre                                                                         [✎]  │ │
│ │ CLIENTE VITALICIO                                                              [✎]  │ │
│ │ CANALIZACIÓN                                                                   [✎]  │ │
│ │ ATENCIÓN EN CAMPO                                                              [✎]  │ │
```

- Same pattern; panel has one field (Nombre) (FR-013).

### Section: Agentes

```
│ [🔍 Buscar agente…                                  ]                    [+ Nuevo agente] │
│ │ Agente                    Esquema                                              [✎]  │ │
│ │ Juan Pérez                Pago total                                           [✎]  │ │
│ │ María López               Pagos parciales                                      [✎]  │ │
```

```
                                           ┌─ Nuevo agente ────────────────────────── × ┐
                                           │ Empleado  [ Buscar vendedor…        ▾ ]    │
                                           │ Esquema   (•) Pago total                   │
                                           │           ( ) Pagos parciales              │
                                           │ El esquema aplica desde el siguiente       │
                                           │ cálculo; nunca cambia meses cerrados.      │
                                           │                         [Guardar]          │
                                           └────────────────────────────────────────────┘
```

- `RecordSheet`; employee via `CatalogEntityPicker<EmployeeListItem>` over salespeople,
  excluding current agents (FR-014, Assumption "who can be an agent"). On edit, Empleado is
  read-only and only Esquema changes (US4 sc. 4). Delete refused while the agent has
  rates (US4 sc. 5).
- "Tasas por agente" could be the row's one extra action (jump to that agent's grid).

### Section: Tasas por agente (grid)

```
│ Agente [Juan Pérez ▾]                                                                   │
│ ┌─────────────────────────────────────────────────────────────────────────────────────┐ │
│ │ Etiqueta (tasa)        CLIENTE VITALICIO    CANALIZACIÓN    ATENCIÓN EN CAMPO       │ │
│ ├─────────────────────────────────────────────────────────────────────────────────────┤ │
│ │ ARMEX (0.20 %)         [ 100      ] %       [          ] %  [ 50       ] %          │ │
│ │ CONCRETOS (2.50 %)     [ 100      ] %       [          ] %  [ 50       ] %          │ │
│ │ FERRETERÍA (4.00 %)    [ 100      ] %       [ 50       ] %  [ 50       ] %          │ │
│ │ TABIQUES (4.00 %)      [ ⚠ 120    ] %       [          ] %  [ 50       ] %          │ │
│ │                        Máximo 100 %                                                 │ │
│ └─────────────────────────────────────────────────────────────────────────────────────┘ │
```

- Every label is a row and every participation type a column, including empty cells
  (FR-015). Each cell is a `ConfirmableTextField`: Enter saves; typing into an empty cell
  creates the rate, changing it updates, clearing it deletes. Leaving focus without Enter
  discards, with acknowledgement (its existing contract). A refusal shows under the cell
  with `InlineErrorText` (US5 sc. 6).
- Agent selector: `CatalogEntityPicker` over agents; defaults to the first agent.
- Read-only users see the same grid as text, not fields.
- No shared editable-grid component exists; this composes `DataTableView`-styled rows with
  fields in cells — Open Question 11.

### Section: Productos

```
│ [🔍 Buscar producto…                    ]  [Filtros (1)]            [+ Asignar etiqueta] │
│ │ Código     Producto                         Etiqueta                           [✎]  │ │
│ │ BLK-1520   Block 15x20x40                   CONCRETOS                          [✎]  │ │
│ │ VAR-038    Varilla 3/8"                     FERRETERÍA                         [✎]  │ │
│                                                         ‹  1–50 de 1,123  ›             │
```

- `CatalogFilterBar` search (by product) + facet **Etiqueta** in the filter sheet
  (FR-016); `CatalogPagination` server-side.
- Edit opens the same Assign label dialog with a **Quitar etiqueta** option (US6 sc. 3).
  "+ Asignar etiqueta" adds a picker for any product, including unlabelled ones, since this
  list holds only labelled products — Open Question 12.

### State: read-only user (Read, no C/U/D)

- No Create buttons, no Edit icons, no Delete. Rate grid as plain text. Months show no
  Close/Reopen/Pay and no "Asignar…" on lines (FR-020, edge case "read-only user").

### Compact tier (settings)

```
┌─ ← Configuración ────────────────┐
│ [Sección: Tasas por agente ▾]    │
│ Agente [Juan Pérez ▾]            │
│ ── CONCRETOS (2.50 %) ────────── │
│ Vitalicio      [ 100   ] %       │
│ Canalización   [       ] %       │
│ En campo       [ 50    ] %       │
│ ── TABIQUES (4.00 %) ─────────── │
│ …                                │
└──────────────────────────────────┘
```

- Five segments do not fit a phone: the `SegmentedButton` becomes a dropdown.
- The rate grid turns into one block per label with the three participation types stacked.

---

## Open Questions

**Resolved in `/speckit-clarify` (2026-11-25):** Q1 (one settings screen, five sections), Q8 (totals only until an agent is chosen), Q9 (core columns in the table, every value in a read-only side panel, so the "row expansion" idea is replaced by `RecordSheet`), Q12 (any product can be picked to label). The rest stay open for planning.

1. **Where do the settings live?** Options: (a) a sub-route `/commissions/settings` reached by a
   "Configuración" button, five sections under a `SegmentedButton`; (b) separate Finanzas menu
   entries (Finanzas already has 10); (c) a real `TabBar`, which no screen uses yet.
   *Assumed (a).* The spec says "one entry … (for example, as tabs)" and should name this.
2. **Choosing a month.** There is no shared month/year picker (`DateRangeFilterChip` picks a
   range). *Assumed* a two-dropdown dialog plus ‹ › stepping on the month screen. Is a new
   shared month picker warranted?
3. **Close / Reopen / Pay buttons.** `RecordFormActions` renders only Delete and Edit/Save.
   *Assumed* plain `FilledButton`/`OutlinedButton` in the body action area, like cash-session
   close. Extend `RecordFormActions` with state-transition slots instead?
4. **The "live, not final" notice.** `ErrorBanner` is error-toned. *Assumed* an info-toned
   banner. Does one exist (e.g. a `StatusTone.info` banner), or is a new shared widget needed?
5. **Agent selector placement.** §VI says facet controls live in the filter drawer, not inline.
   *Assumed* inline, because the agent decides what the screen shows (totals by agent vs. by
   label + lines) rather than narrowing a list. Accept as a documented exception, or move it
   into the drawer?
6. **Months-list filter.** §VI requires filtering on every list screen; the endpoint has no
   search or status filter. *Assumed* a client-side Estado facet and no search. Enough?
7. **Unlabelled lines in the all-agents view.** *Assumed* a "Sin etiqueta" summary row so gaps
   are visible before closing. Keep it, or show it only per agent?
8. **Lines with no agent chosen.** *Assumed* lines only appear once an agent is chosen; the
   all-agents view is totals only. The spec's FR-005 does not say. Should a whole-month line
   list (thousands of rows) be offered?
9. **Line columns.** FR-005 lists ~16 values per line; they do not fit without horizontal
   scroll. *Assumed* the table shows order, paid date, customer, product, label, participation,
   effective rate, amount, commission; the rest (order date, label rate, agent share, full
   commission, share, scheme) are reached by ... a row expansion? a tooltip? Needs a decision,
   and FR-005 may need to split "always shown" from "on demand".
10. **Link to the order.** Should a line's order number open the order (Pedidos)? Not in the
    spec. *Assumed* no link.
11. **Editable grid.** No shared component exists for a matrix of editable cells. *Assumed*
    the grid is composed from existing pieces (`ConfirmableTextField` per cell). Confirm it
    stays feature-local, or plan a shared widget.
12. **Labelling an unlabelled product from the Productos list.** The product-labels list only
    holds labelled products. *Assumed* "+ Asignar etiqueta" with a product picker. Should the
    list instead offer an "unlabelled" facet (needs an mbe-api change, since the endpoint
    cannot list products without a label)?
