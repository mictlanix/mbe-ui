# Contract: UI (routes, navigation, screens, dialogs)

Every route and action below is governed by SystemObject 112, CommissionsBySalesPerson (§IV).
The wireframes in [../wireframes.md](../wireframes.md) are the drawings. This contract is
what they turned into after clarification and research.

## Navigation and routes

| Item | Value |
|---|---|
| Nav entry | Finanzas › **Comisiones**, after Gastos; `NavBranch.commissions = 37`; `PrivilegeGate(commissionsBySalesPerson, read)` |
| `commissionsPath` | `/commissions`: months list |
| `commissionSettingsPath` | `/commissions/settings?section=labels\|participations\|agents\|rates\|products[&agent=ID]`, declared **before** the month route |
| `commissionMonthPath(y, m)` | `/commissions/:year/:month[?agent=ID]`. An invalid year or month (not an int, month outside 1–12, after the current month) redirects to `/commissions` |
| `_routeGate` | the `/commissions` prefix requires Read |

The `AppBar` has no actions on any of these screens (§VI).

## Months list (`/commissions`)

- **Filter row** (`CatalogFilterBar`):
  - no search;
  - `actions`: "Abrir mes…" (`OutlinedButton`) and "Configuración" (`OutlinedButton.icon`; icon only below 600 px);
  - `filters`: the badged filters button → drawer with an **Estado** facet (client-side).
- **Table** (`DataTableView`, client-paged 25, R9): Mes · Estado (`StatusChip`) · Total (numeric) · Cerrado el · Pagado el. Row tap → the month. No row icons: a month has no Edit.
- **Empty**: `ListStateViews` empty message with a `FilledButton` "Ver {previous month}". The filters button is hidden.
- **Abrir mes dialog**: `ResponsiveDialog` with Mes and Año dropdowns, defaulting to the previous month. Months after the current one are not offered.

## Month (`/commissions/:year/:month`)

From top to bottom:

1. **`FactStripRow`**: ‹ previous · month name · next › (› hidden past the current month) · `StatusChip` · the chosen agent with a clear (×), when one is chosen · the badged filters button (drawer: **Agente** picker).
2. **Audit line** (closed or paid): "Cerrado el {dateTime} por {employee}", "· Pagado el … por …", and "Reabierto el … por …" while open after a reopen. Names come from `CommissionEmployeeName` (R2).
3. **`InfoBanner`** (open only): "Cálculo en vivo, no definitivo…".
4. **Totals**:
   - **No agent chosen**:
     - "Total del mes {grand total}";
     - an agents table (`DataTableView`): Agente · Esquema · Líneas · Comisión. Row tap selects the agent (R7).
   - **Agent chosen**:
     - "Total de {agent} {total}" and the agent's scheme;
     - a by-label table (Etiqueta · Líneas · Comisión, "Sin etiqueta" for null);
     - a **lines table** (client-paged 50, R8): Pedido · Pagado · Cliente · Producto · Etiqueta · Participación · Tasa · Importe · Comisión.
     - Refund rows have a leading ↩ icon and "Devolución" under the order number.
     - An unlabelled line on an open month, for a user with Update, shows "Asignar…" in the Etiqueta cell. That is the row's one action (§VI).
     - Row tap opens the **line panel**.
5. **`ErrorBanner`**, when the last action was refused.
6. **Action row** (`Align(centerEnd, Wrap)`, R6), with each button present only when offered (data-model "Action availability") and the user has Update:
   - [Reabrir] (`OutlinedButton`), then [Marcar pagado] or [Cerrar mes] (`FilledButton`);
   - in place of Cerrar mes on a blocked open month, the blocked reason as text.

States: loading and load error through `ListStateViews`, with the header kept.

**Line panel**: `showRecordSheet`, read-only, `isDirty: () => false`, titled "Línea del pedido {n}". It shows every FR-005a value:
- the order and paid dates;
- customer and product;
- label and label rate;
- participation and agent share;
- effective rate;
- price × quantity = amount;
- full commission, share (scheme 2) and this month's commission;
- the scheme;
- the order's and customer's salespeople;
- the movement.

Rates display through `formatters.percent` (read-only, 2 decimals, "1.25 %"). `formatters.field.rate` is the editable-field formatter and is used only to fill grid cells (research R12).

**Dialogs** (`period_dialogs.dart`, `showResponsiveDialog`, not dismissible while in flight):

| Dialog | Body | Confirm |
|---|---|---|
| Cerrar {month} | "Se guardarán {n} líneas por {total}. A partir de ahora el mes no cambiará aunque cambien clientes, tasas o etiquetas." | Cerrar mes |
| Reabrir {month} | "Se descartarán las líneas guardadas. El mes volverá a calcularse con los datos actuales y habrá que cerrarlo de nuevo." | Reabrir |
| Marcar {month} como pagado | "Total {total}. Un mes pagado es definitivo: no podrá reabrirse ni modificarse." | Marcar pagado |
| Etiqueta de comisión (from a line) | product (read-only) + label picker + the FR-018 note | Asignar |

## Settings (`/commissions/settings`)

- **Section switch**: `SegmentedButton` in `CatalogFilterBar.actions` (≥ 600 px), or a `DropdownButton` below that. It writes `?section=`.
- **`InfoBanner`** on every section: "Los cambios aplican a meses abiertos y cálculos futuros, nunca a meses cerrados." (FR-018)

| Section | Filter row | Table | Surface |
|---|---|---|---|
| Etiquetas | client search · "+ Nueva etiqueta" (Create) | Nombre · Tasa · Comentario · ✎ | `showRecordSheet`: Nombre, Tasa (%), Comentario; `RecordFormActions` (Delete, Edit/Save) |
| Participaciones | client search · "+ Nueva participación" | Nombre · ✎ | panel: Nombre |
| Agentes | client search · "+ Nuevo agente" | Agente · Esquema · ✎ · "Ver tasas" (one extra action → `section=rates&agent=`) | panel: Empleado (`CatalogEntityPicker<EmployeeListItem>`, `salesPerson: true`, current agents excluded; read-only on edit) · Esquema (radio) · scheme note |
| Tasas por agente | filters button (drawer: Agente picker) | `FactStripRow` with the agent, then `AgentRatesGrid` (R11) | in-cell |
| Productos | filters button (drawer: Etiqueta, Producto) · "+ Asignar etiqueta" | Código · Producto · Etiqueta · ✎; `CatalogPagination` server-side, 20 | dialog: Producto (picker; fixed on edit) · Etiqueta · [Quitar etiqueta] on edit |

Rights follow the HTTP call each control makes (spec 025 contract: POST of a settings row = Create, PUT = Update, DELETE = Delete), so no control is shown that the server would refuse for lack of privilege (SC-006):

| Control | Call | Right |
|---|---|---|
| "+ Nueva etiqueta", "+ Nueva participación", "+ Nuevo agente" | POST | Create |
| ✎ and the panel's edit toggle on labels, participations, agents | PUT | Update |
| Eliminar in a label, participation or agent panel | DELETE | Delete |
| Rate grid: typing into an **empty** cell | POST `/agent-rates` | Create |
| Rate grid: changing a **filled** cell | PUT `/agent-rates/{id}` | Update |
| Rate grid: clearing a filled cell | DELETE `/agent-rates/{id}` | Delete |
| "+ Asignar etiqueta", ✎ on a product label, "Asignar…" on a month line | PUT `/product-labels/{product}` | Update |
| "Quitar etiqueta" | DELETE `/product-labels/{product}` | Delete |
| Cerrar mes, Reabrir, Marcar pagado | POST `/periods/…/close`, `/reopen`, `/pay` | Update |

- A grid cell is a field only when the user may write it: an empty cell needs Create, a filled cell needs Update. Otherwise it renders as text. A filled cell the user may update but not delete rejects an empty value with `commissionRateClearNotAllowed`, and keeps its value.
- With **Read only**, everything renders as text.

## Compact tier

- **Months list**: two-line cards.
- **Month**: agents become name + total rows. Lines become stacked cards: order · date / product · label / customer · participation / amount × rate = commission.
- **Settings**: the section switch becomes a dropdown. The rate grid becomes one block per label with the participation types stacked.
