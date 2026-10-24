# Wireframes: Customer Discounts

**Spec**: [spec.md](./spec.md) | **Drawn**: 2026-10-24 | **Fidelity**: low

These wireframes were drawn from the spec. The layout is indicative, not prescriptive: every dimension, colour and spacing comes from the design tokens (constitution §V). Percentages use the app's percent format, which shows two decimals by default (spec 028, FR-003). The sample data is invented.

They were drawn after `/speckit-plan`, out of the usual order. The Open Questions at the end are meant to feed back into the spec and plan before `/speckit-tasks`.

The customer detail page (spec 046) is unchanged above the new section. The Discounts section follows the supplier Agreements section from spec 050: a section header with an add button, a `DataTableView` with an Edit-only row action, and one dialog for add and edit with Remove inside.

---

## Screen: Customer detail (`/customers/:id`, `?view=true`, `/customers/new`), changed

### State: edit, populated (regular)

```
┌──────────────────────────────────────────────────────────────────────────────────────┐
│ ←  Editar cliente                                                                    │  AppBar, no actions
├──────────────────────────────────────────────────────────────────────────────────────┤
│  … customer fields, status (unchanged, spec 046) …                                   │
│ ──────────────────────────────────────────────────────────────────────────────────── │
│  Direcciones (…)                           │  Contactos (…)                          │
│ ──────────────────────────────────────────────────────────────────────────────────── │
│  Receptores fiscales (…)                                                             │
│ ──────────────────────────────────────────────────────────────────────────────────── │
│  Descuentos                                                    [+ Agregar descuento] │
│ ┌──────────┬───────────────────────────────────────────────┬──────────────┬───────┐  │
│ │ Código   │ Producto                                      │    Descuento │       │  │
│ ├──────────┼───────────────────────────────────────────────┼──────────────┼───────┤  │
│ │ CLV-0125 │ Clavo estándar 2½" caja 25 kg                 │      10.00 % │   ✎   │  │
│ │ TOR-0310 │ Tornillo hexagonal ⅜" × 2" galvanizado        │      12.50 % │   ✎   │  │
│ │ VAR-1200 │ Varilla corrugada ½" × 12 m                   │       5.00 % │   ✎   │  │
│ └──────────┴───────────────────────────────────────────────┴──────────────┴───────┘  │
│ ──────────────────────────────────────────────────────────────────────────────────── │
│  [Eliminar cliente]                                                        [Guardar] │  RecordFormActions
└──────────────────────────────────────────────────────────────────────────────────────┘
```

- **Placement:** the section sits full width after Taxpayers, separated by a `Divider`, inside the same `ResponsiveFormGrid` (FR-001).
- **Header:** a `titleSmall` title. `+ Agregar descuento` is a `FilledButton.icon` with the `CatalogAction.create` icon (FR-004).
- **Table:** `DataTableView<CustomerDiscount>` with `shrinkWrap`, in server order, which is by code (FR-002). The Discount column is right-aligned and rendered with `fmt.display.percent` (FR-003).
- **`✎`:** `buildCatalogRowActions` with Edit only. It opens the edit dialog (FR-008). There is no row Delete (§VI, FR-009).
- **Independent saving:** the customer's `Guardar` doesn't save discounts. Each dialog saves on its own (FR-010).

### State: view (read-only), or a user without Customers Update

```
│  Descuentos                                                                          │
│ ┌──────────┬───────────────────────────────────────────────┬──────────────┐          │
│ │ Código   │ Producto                                      │    Descuento │          │
│ ├──────────┼───────────────────────────────────────────────┼──────────────┤          │
│ │ CLV-0125 │ Clavo estándar 2½" caja 25 kg                 │      10.00 % │          │
│ │ TOR-0310 │ Tornillo hexagonal ⅜" × 2" galvanizado        │      12.50 % │          │
│ └──────────┴───────────────────────────────────────────────┴──────────────┘          │
│  [Editar]                                                                            │  RecordFormActions
```

- There is no add button and no `✎` column (US1-4, FR-012). After the user presses `Editar` (with Update), the editable state above appears.
- A user with Update but no Products Read sees `✎` but no `+ Agregar descuento` (FR-012).

### State: empty

```
│  Descuentos                                                    [+ Agregar descuento] │
│  Sin descuentos por producto.                                                        │
```

- A plain `Text` empty state, like agreements (US1-2, FR-002).

### State: loading / error

```
│  Descuentos                                                    [+ Agregar descuento] │
│                                   ◌                                                  │  CircularProgressIndicator
```
```
│  Descuentos                                                    [+ Agregar descuento] │
│  ⚠ No se pudieron cargar los registros.                              [Reintentar]    │  ListFailedView
```

- The section loads independently of the customer's fields. A failure here doesn't block editing the customer. Retry re-reads only the discounts.

### State: create (`/customers/new`, not yet saved)

```
│  Descuentos                                                                          │
│  Los descuentos se pueden agregar después de guardar el cliente.                     │
```

- There is no add button and no table (US2-6, FR-007).
- **After the first save** the page replaces itself with `/customers/:id` in edit mode, and the same section appears with `+ Agregar descuento` (US2-7, FR-007a). There's no new state to draw: it's the empty state above.

### Compact tier

```
┌──────────────────────────────────────┐
│ ←  Editar cliente                    │
├──────────────────────────────────────┤
│  … fields, sections, one column …    │
│ ──────────────────────────────────── │
│  Descuentos        [+ Agregar]       │
│ ┌──────────────────────┬────────┬──┐ │
│ │ Producto             │  Desc. │  │ │
│ ├──────────────────────┼────────┼──┤ │
│ │ CLV-0125 · Clavo es… │ 10.00 %│✎ │ │
│ │ TOR-0310 · Tornillo… │ 12.50 %│✎ │ │
│ └──────────────────────┴────────┴──┘ │
└──────────────────────────────────────┘
```

- **Columns:** the Code column is dropped and its value is prefixed into the Product cell (`code · name`), so the product stays identifiable without horizontal scroll (§VI).
- **Truncation:** the name truncates with an ellipsis, and the full name is in the edit dialog.
- **Add button:** keeps its icon. The label may shorten to `Agregar` if the header row overflows (see OQ-2).

---

## Dialog: Add discount (`showCustomerDiscountDialog`, `existing == null`)

### State: blank → filled

```
┌────────────────────────────────────────────────────────┐
│ Nuevo descuento                                        │
│                                                        │
│  Producto                                              │
│  [🔍 Buscar por código o nombre…                    ]  │  CatalogEntityPicker<ProductListItem>
│   ┌──────────────────────────────────────────────────┐ │
│   │ ▣  Clavo estándar 2½" caja 25 kg                 │ │  options: thumbnail, name,
│   │    CLV-0125                                      │ │  code subtitle; active only;
│   │ ▣  Clavo para concreto 2" caja 10 kg             │ │  products already discounted
│   │    CLV-0140                                      │ │  for this customer omitted
│   └──────────────────────────────────────────────────┘ │
│                                                        │
│  Descuento (%)                                         │
│  [ 10                                            % ]   │  TextFormField, decimal keyboard
│                                                        │
│                               [Cancelar]  [Guardar]    │
└────────────────────────────────────────────────────────┘
```

- `Dialog` with a maximum width of 560, the same as the agreement dialog, and a `ResponsiveFormGrid` with one field per row.
- `Guardar` is enabled only when a product is picked and the percentage passes validation (FR-004, FR-005, FR-006).

### State: invalid percentage

```
│  Descuento (%)                                         │
│  [ 101                                           % ]   │
│  Debe estar entre 0 y 100.                             │  error text, Guardar disabled
```

- The other messages are `Ingresa un porcentaje.`, `Ingresa un número, p. ej. 12.5.` and `Máximo 6 decimales.` (US2-3, FR-006).

### State: refused by the server

```
┌────────────────────────────────────────────────────────┐
│ Nuevo descuento                                        │
│ ┌────────────────────────────────────────────────────┐ │
│ │ ⚠ Este cliente ya tiene un descuento para ese      │ │  ErrorBanner, above the grid
│ │   producto.                                        │ │
│ └────────────────────────────────────────────────────┘ │
│  Producto      [Clavo estándar 2½" caja 25 kg       ]  │  input kept
│  Descuento (%) [ 10                              % ]   │
│                               [Cancelar]  [Guardar]    │
└────────────────────────────────────────────────────────┘
```

- The dialog stays open, and the section behind it refreshes (US2-4, FR-011).
- The other banners are `El producto ya no existe.` (US2-5) and the generic save failure.

---

## Dialog: Edit discount (`existing != null`)

```
┌────────────────────────────────────────────────────────┐
│ Editar descuento                                       │
│                                                        │
│  Producto                                              │
│  TOR-0310 — Tornillo hexagonal ⅜" × 2" galvanizado     │  InputDecorator, read-only (FR-008)
│                                                        │
│  Descuento (%)                                         │
│  [ 12.5                                          % ]   │  full stored precision (FR-003)
│                                                        │
│  [Eliminar]                   [Cancelar]  [Guardar]    │  Eliminar: outlined, error colour,
└────────────────────────────────────────────────────────┘  furthest from the primary action
```

- `Eliminar` opens the confirmation below (FR-009).
- If the discount was removed elsewhere, the banner reads `Este descuento ya no existe.`, and the row disappears behind the dialog (US3-4).

### Remove confirmation (`showRecordDeleteConfirmation`)

```
┌────────────────────────────────────────────────────────┐
│ Eliminar descuento                                     │
│                                                        │
│ ¿Eliminar el descuento sobre TOR-0310 — Tornillo       │
│ hexagonal ⅜" × 2" galvanizado? Las partidas ya         │
│ capturadas conservan su descuento.                     │
│                                                        │
│                              [Cancelar]  [Eliminar]    │
└────────────────────────────────────────────────────────┘
```

- The message tells the user that existing sales lines aren't changed (US3-5).

---

## Open Questions

1. **Should the section show a count in its title, like `Descuentos (3)`?** The supplier wireframes show counts on linked sections, but the agreements section has none. Options: no count, or a count. *Assumed: no count, matching agreements.*
2. **Compact header overflow.** `+ Agregar descuento` beside the title may not fit at 360 px. Options: shorten the label to `Agregar`; icon only, with a tooltip; or wrap the button below the title. *Assumed: shorten to `Agregar` on compact. This needs a new l10n key, not yet in contracts C6.*
3. **Picker results for a product with many variants.** The option shows name and code. The legacy table also showed model and SKU, which `ProductListItem` may carry, unlike the discount row. Options: code subtitle only, or add model/SKU to the option subtitle. *Assumed: code only. The spec's "no extra product details" assumption covers the row, not the picker.*
4. **0 % row emphasis.** A 0 % discount is valid (edge case) and reads `0.00 %`, the same as any other row. Options: no emphasis, or a muted style. *Assumed: no emphasis. Nothing in scope asks for it.*
