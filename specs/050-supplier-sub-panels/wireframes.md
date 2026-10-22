# Wireframes: Supplier Sub-Panels

**Spec**: [spec.md](./spec.md) | **Drawn**: 2026-10-22 | **Fidelity**: low

These wireframes were drawn from the spec, before planning. The layout is indicative, not prescriptive: every dimension, colour and spacing comes from the design tokens (constitution §V). Dates use the configured format, which defaults to ISO (spec 028). The sample data is invented.

The screens reuse the customer detail from spec 046 wherever they can. Supplier detail means `CustomerDetailScreen` and `CustomerForm` with the supplier's fields. Addresses, contacts and bank accounts each use one `LinkedRecordsSection<T>`. Agreements follow the child-table precedent of `TaxpayerCertificatesSection`.

---

## Screen: Supplier list (`/suppliers`), changed

### State: populated (regular)

```
┌──────────────────────────────────────────────────────────────────────────────────────┐
│ Proveedores                                                                          │
├──────────────────────────────────────────────────────────────────────────────────────┤
│ [🔍 Buscar por código, nombre o zona…                       ]              [+ Nuevo] │
├──────────┬──────────────────────────────────┬──────────────┬─────────────────┬──────┤
│ Código   │ Nombre                           │ Zona         │ Límite crédito  │      │
├──────────┼──────────────────────────────────┼──────────────┼─────────────────┼──────┤
│ PRV-001  │ Aceros del Bajío                 │ Bajío        │      50,000.00  │  ✎   │
│ PRV-002  │ Ferretera Industrial Monterrey   │ Norte        │           0.00  │  ✎   │
└──────────┴──────────────────────────────────┴──────────────┴─────────────────┴──────┘
                                                               ‹  1  2  3 … ›  (pagination)
```

- The layout is unchanged: `CatalogFilterBar` / `CatalogSearchBar`, `DataTableView`, `CatalogPagination`.
- **What changes is where each action goes** (FR-004):
  - A row click pushes `/suppliers/:id?view=true` (read-only).
  - `✎` pushes `/suppliers/:id`.
  - `+ Nuevo` pushes `/suppliers/new`.
  - None of them opens `showRecordSheet` any more.
- `✎` is hidden without Suppliers *Update*, and `+ Nuevo` is hidden without *Create* (FR-018). This is unchanged.

---

## Screen: Supplier detail (`/suppliers/:id`, `/suppliers/:id?view=true`, `/suppliers/new`), new

### State: view, populated (regular)

```
┌──────────────────────────────────────────────────────────────────────────────────────┐
│ ←  Ver proveedor                                                                     │  AppBar, no actions
├──────────────────────────────────────────────────────────────────────────────────────┤
│  Código              [PRV-001                    ]  Nombre      [Aceros del Bajío  ] │
│  Zona                [Bajío                      ]  Límite créd.[50,000.00         ] │
│  Días de crédito     [30                         ]                                   │
│  Notas               [Entrega solo martes y jueves                                 ] │
│ ──────────────────────────────────────────────────────────────────────────────────── │
│  Direcciones (2)                           │  Contactos (1)                          │
│  Bodega central                            │  Laura Méndez                           │
│  Av. Industrias 1200, Parque Ind., León,   │  Compras · 477 555 0101 · laura@acer…   │
│  CP 37490                                  │  ─────────────────────────────────────  │
│  ────────────────────────────────────────  │                                         │
│  Fiscal                                    │                                         │
│  Calle 5 de Mayo 14, Centro, León, 37000   │                                         │
│  ────────────────────────────────────────  │                                         │
│ ──────────────────────────────────────────────────────────────────────────────────── │
│  Cuentas bancarias (1)                                                               │
│  BBVA · 0123456789 · Ref. ACB-01                                                     │
│  ──────────────────────────────────────────────────────────────────────────────────  │
│ ──────────────────────────────────────────────────────────────────────────────────── │
│  Convenios (3)                                                                       │
│  ┌──────────────┬──────────────┬───────────────────────────────────────────────────┐ │
│  │ Inicio       │ Fin          │ Notas                                             │ │
│  ├──────────────┼──────────────┼───────────────────────────────────────────────────┤ │
│  │ 2026-03-01   │ 2027-02-28   │ 3% por volumen anual                              │ │
│  │ 2025-03-01   │ 2026-02-28   │ 2% por volumen anual                              │ │
│  │ 2024-01-15   │ 2024-12-31   │ —                                                 │ │
│  └──────────────┴──────────────┴───────────────────────────────────────────────────┘ │
│                                                                         [✎ Editar]  │  RecordFormActions
└──────────────────────────────────────────────────────────────────────────────────────┘
```

- **Shell.** The screen mirrors `CustomerDetailScreen`: a `Scaffold` and `AppBar` whose title is "Ver proveedor", "Editar proveedor" or "Nuevo proveedor". The `AppBar` has no actions (§VI), and leaving with unsaved edits asks first (`PopScope`, `confirmDiscardChanges`).
- **Fields.** The six existing fields sit in a two-column `ResponsiveFormGrid`, as in `supplier_form.dart` today. Notes spans the full width.
- **Addresses and Contacts** are `LinkedRecordsSection<AddressListItem>` and `LinkedRecordsSection<Contact>`, paired side by side, as on the customer (FR-001, FR-002).
  - Address row: `labelOf` is the nickname, or the type when there is none. `subtitleOf` is street and number, neighbourhood, city or borough, and postal code.
  - Contact row: `labelOf` is the name. `subtitleOf` is the job title, phone or mobile, and email.
- **Bank accounts** is a `LinkedRecordsSection<BankAccount>` at full width (FR-002). It is new to this form. `labelOf` is "bank · account number" and `subtitleOf` is the reference.
- **Agreements** is a `DataTableView<SupplierAgreement>` child table, following the `TaxpayerCertificatesSection` precedent (FR-002, FR-016). It is sorted by start date, newest first. In view mode, rows have no action icon.
- **Actions.** `RecordFormActions` shows `Editar` when the user has Suppliers *Update*, and switches to edit in place (§VI). Delete is in the same action area (see Edit).
- **Covers** FR-001 to FR-003, FR-016 and FR-018.

### State: view, empty sections

```
│ ──────────────────────────────────────────────────────────────────────────────────── │
│  Direcciones                               │  Contactos                              │
│  Este proveedor no tiene direcciones.      │  Este proveedor no tiene contactos.     │
│ ──────────────────────────────────────────────────────────────────────────────────── │
│  Cuentas bancarias                                                                   │
│  Este proveedor no tiene cuentas bancarias.                                          │
│ ──────────────────────────────────────────────────────────────────────────────────── │
│  Convenios                                                                           │
│  Este proveedor no tiene convenios.                                                  │
```

- Each section shows its own `emptyText` (FR-002, US1 scenario 2). The count is dropped from the title when it is zero, which is how `LinkedRecordsSection` already behaves.

### State: edit, with pending link changes

```
┌──────────────────────────────────────────────────────────────────────────────────────┐
│ ←  Editar proveedor                                                                  │
├──────────────────────────────────────────────────────────────────────────────────────┤
│  (fields editable)                                                                   │
│ ──────────────────────────────────────────────────────────────────────────────────── │
│  Direcciones (2)                 [+ Nueva] │  Contactos (2)                 [+ Nuevo] │
│  Bodega central                     [⛓̸]   │  Laura Méndez                     [⛓̸]   │
│  Av. Industrias 1200, … 37490              │  Compras · 477 555 0101                 │
│  ────────────────────────────────────────  │  ─────────────────────────────────────  │
│  Sucursal Silao             ← just linked  │  Pedro Ruiz         ← just created [⛓̸] │
│  Blvd. Aeropuerto 300, … 36100      [⛓̸]   │  Ventas · pedro@acer…                   │
│  ────────────────────────────────────────  │  ─────────────────────────────────────  │
│  [🔍 Vincular dirección existente…      ]  │  [🔍 Vincular contacto existente…    ]  │
│ ──────────────────────────────────────────────────────────────────────────────────── │
│  Cuentas bancarias (1)                                                     [+ Nueva] │
│  BBVA · 0123456789                                                           [⛓̸]   │
│  Ref. ACB-01                                                                         │
│  ──────────────────────────────────────────────────────────────────────────────────  │
│  [🔍 Vincular cuenta bancaria existente…                                          ]  │
│ ──────────────────────────────────────────────────────────────────────────────────── │
│  Convenios (3)                                                    [+ Agregar convenio] │
│  ┌──────────────┬──────────────┬─────────────────────────────────────────────┬─────┐ │
│  │ 2026-03-01   │ 2027-02-28   │ 3% por volumen anual                        │  ✎  │ │
│  │ 2025-03-01   │ 2026-02-28   │ 2% por volumen anual                        │  ✎  │ │
│  │ 2024-01-15   │ 2024-12-31   │ —                                           │  ✎  │ │
│  └──────────────┴──────────────┴─────────────────────────────────────────────┴─────┘ │
│                                                     [Eliminar proveedor]  [Guardar]  │  RecordFormActions
└──────────────────────────────────────────────────────────────────────────────────────┘
```

- **Linking.** Each `CatalogEntityPicker` searches records of its kind and leaves out the ones already linked (FR-005, FR-009).
  - The address picker searches active addresses only, as on the customer.
  - Picking a record adds it to the list, but only in the form's state (FR-008).
- **New record.** `[+ Nueva]` / `[+ Nuevo]` opens the matching inline-create dialog (FR-006, FR-007). When it confirms, the new record is linked.
  - Addresses use the existing `showAddressInlineCreateDialog`, contacts use `showContactInlineCreateDialog`, and bank accounts use the new bank-account dialog below.
- **Unlink.** `[⛓̸]` unlinks the record in the form's state only. It never deletes the record (FR-010).
- **No marker for unsaved links.** Pending links are not marked "pending" visually. The customer screen has no such marker, and the drawing does not add one (Open Question 3).
- **Agreements.** `[+ Agregar convenio]` and each row's `✎` open the agreement dialog. They act at once, not on Guardar (FR-012).
  - A row has exactly one icon (§VI). Delete lives inside the dialog, not on the row (FR-014; see Open Question 2).
- **Saving.** `Guardar` sends the fields and all three id lists in full (FR-008). `Eliminar proveedor` asks for confirmation through `RecordDeleteConfirmation`.
- **Covers** FR-005 to FR-010, FR-012 and FR-018.

### State: create (`/suppliers/new`)

```
│ ←  Nuevo proveedor                                                                   │
│  (empty fields)                                                                      │
│ ──────────────────────────────────────────────────────────────────────────────────── │
│  Direcciones                     [+ Nueva] │  Contactos                     [+ Nuevo] │
│  Este proveedor no tiene direcciones.      │  Este proveedor no tiene contactos.     │
│  [🔍 Vincular dirección existente…      ]  │  [🔍 Vincular contacto existente…    ]  │
│ ──────────────────────────────────────────────────────────────────────────────────── │
│  Cuentas bancarias                                                         [+ Nueva] │
│  Este proveedor no tiene cuentas bancarias.                                          │
│  [🔍 Vincular cuenta bancaria existente…                                          ]  │
│ ──────────────────────────────────────────────────────────────────────────────────── │
│  Convenios                                                                           │
│  ⓘ Podrás agregar convenios después de guardar el proveedor.                         │
│                                                                          [Guardar]   │
```

- Links can be made before the first save. They go out with the create (US2 scenario 6).
- Agreements show a note in place of the add control (FR-015).
- After the first save, the screen replaces its route with `/suppliers/:id` in edit mode, so the user can add agreements right away (Open Question 4).

### State: read-only user, or partial privileges on linked kinds

```
 Suppliers Update, but no Read on Bank accounts and no Create on Contacts:

│  Direcciones (1)                 [+ Nueva] │  Contactos (1)                          │  ← no [+ Nuevo]
│  Bodega central                     [⛓̸]   │  Laura Méndez                     [⛓̸]   │
│  [🔍 Vincular dirección existente…      ]  │  [🔍 Vincular contacto existente…    ]  │
│  Cuentas bancarias (1)                                                     [+ Nueva] │  ← create without read
│  BBVA · 0123456789                                                           [⛓̸]   │  ← still unlinkable
│                                                    (no "vincular" picker)            │
```

- **No Suppliers *Update*.** The screen is always the read-only view above: no `Editar`, no `[+ …]`, no `[⛓̸]`, no `✎` (FR-018, US1 scenario 3, US3 scenario 6).
- **Per-kind rights.**
  - The picker needs *Read* on its kind: Addresses 11, Contacts 12, Bank Accounts 13.
  - `[+ …]` needs *Create* on its kind.
  - Records already linked are always shown, and can be unlinked if the user has Suppliers *Update* (FR-019).
  - This is the same wiring as on the customer: `searchExisting` or `onCreateNew` is `null`.
- `Eliminar proveedor` needs Suppliers *Delete*.

### State: loading / load failed

```
│ ←  Ver proveedor                                                                     │
│                                                                                      │
│                                   ( spinner )                                        │
│                                                                                      │
├──────────────────────────────────────────────────────────────────────────────────────┤
│ ←  Ver proveedor                                                                     │
│  ┌ ErrorBanner ───────────────────────────────────────────────────────────────────┐  │
│  │ ⚠ No se pudo cargar el proveedor.                                [Reintentar]  │  │
│  └────────────────────────────────────────────────────────────────────────────────┘  │
```

- These are the existing loading and `ErrorBanner` / `ListFailedView` states of the form, now on a full page. The whole supplier, with its four sections, comes back in one read, so the sections have no loading state of their own.

### State: save refused, a linked record no longer exists

```
│  ┌ ErrorBanner ───────────────────────────────────────────────────────────────────┐  │
│  │ ⚠ Ya existe un proveedor con ese código, o uno de los registros vinculados     │  │
│  │   ya no existe. Revisa el código y los vínculos y vuelve a guardar.            │  │
│  └────────────────────────────────────────────────────────────────────────────────┘  │
│  (form stays in edit mode with every edit intact)                                    │
```

- FR-011. The banner sits above the action area, where the form's errors already go. The form does not reload: the user's edits are kept, and nothing is half-saved.
- The server's 409 cannot tell this case apart from a duplicate code, so one message covers both (Open Question 5).

### State: delete refused, the supplier has links or agreements

```
│  ┌ ErrorBanner ───────────────────────────────────────────────────────────────────┐  │
│  │ ⚠ No se puede eliminar el proveedor mientras tenga direcciones, contactos,     │  │
│  │   cuentas bancarias o convenios. Desvincúlalos y elimina los convenios         │  │
│  │   primero.                                                                     │  │
│  └────────────────────────────────────────────────────────────────────────────────┘  │
```

- FR-017 and US4. The message appears after the delete confirmation, and the supplier is kept.

### Compact tier

```
┌──────────────────────────────┐
│ ←  Editar proveedor          │
├──────────────────────────────┤
│ Código   [PRV-001          ] │
│ Nombre   [Aceros del Bajío ] │
│ Zona     [Bajío            ] │
│ Límite   [50,000.00        ] │
│ Días     [30               ] │
│ Notas    [Entrega solo …   ] │
│ ──────────────────────────── │
│ Direcciones (2)    [+ Nueva] │
│ Bodega central        [⛓̸]  │
│ Av. Industrias 1200 …        │
│ [🔍 Vincular dirección…    ] │
│ ──────────────────────────── │
│ Contactos (1)      [+ Nuevo] │
│ …                            │
│ ──────────────────────────── │
│ Cuentas bancarias  [+ Nueva] │
│ …                            │
│ ──────────────────────────── │
│ Convenios      [+ Agregar]   │
│ ┌──────────┬──────────┬───┐  │
│ │ Inicio   │ Fin      │   │  │
│ │2026-03-01│2027-02-28│ ✎ │  │
│ │2025-03-01│2026-02-28│ ✎ │  │
│ └──────────┴──────────┴───┘  │
│ [Eliminar]        [Guardar]  │
└──────────────────────────────┘
```

- `ResponsiveFormGrid` collapses to one column, and Addresses and Contacts stack instead of pairing.
- The agreements table **drops the Notes column** on the compact tier, so that both dates and the `✎` icon fit. The notes stay readable and editable in the agreement dialog.
- The add button's label shortens to `Agregar`.

---

## Dialog: New bank account (from the Bank accounts section), new

### State: entering

```
┌──────────────── Nueva cuenta bancaria ────────────────┐
│  Banco *            [BBVA                           ] │   ≤ 250
│  Número de cuenta * [0123456789                     ] │   ≤ 20
│  Referencia         [ACB-01                         ] │   ≤ 20
│  CLABE / ruteo      [                               ] │   ≤ 18
│  Notas              [                               ] │   ≤ 500
│                                                       │
│                              [Cancelar]   [Crear]     │
└───────────────────────────────────────────────────────┘
```

- The dialog mirrors `address_inline_create.dart` and `contact_inline_create.dart`, each with its own controller. It returns the created record, which the section then links (FR-006, FR-007).
- `Crear` stays disabled until both required fields have text. The length limits come from the server schema.

### State: validation / submit error

```
┌──────────────── Nueva cuenta bancaria ────────────────┐
│  Banco *            [                               ] │
│                     ⚠ El banco es obligatorio.        │
│  Número de cuenta * [01234567890123456789012        ] │
│                     ⚠ Máximo 20 caracteres.           │
│  ┌ ErrorBanner ────────────────────────────────────┐  │
│  │ ⚠ No se pudo crear la cuenta bancaria.          │  │
│  └─────────────────────────────────────────────────┘  │
│                              [Cancelar]   [Crear]     │
└───────────────────────────────────────────────────────┘
```

- If the create fails, the dialog stays open with the user's input, and nothing is linked (edge case "Inline create fails").

---

## Dialog: Agreement (add / edit), new

### State: add

```
┌──────────────────── Nuevo convenio ───────────────────┐
│  Inicio *  [2026-03-01      📅]   Fin *  [2027-02-28 📅] │
│  Notas     [3% por volumen anual                      ] │   ≤ 500
│                                                         │
│                                [Cancelar]   [Guardar]   │
└─────────────────────────────────────────────────────────┘
```

### State: edit (with delete)

```
┌─────────────────── Editar convenio ───────────────────┐
│  Inicio *  [2026-03-01      📅]   Fin *  [2027-02-28 📅] │
│  Notas     [3% por volumen anual                      ] │
│                                                         │
│  [Eliminar]                    [Cancelar]   [Guardar]   │
└─────────────────────────────────────────────────────────┘
          │ Eliminar
          ▼
┌──────────────── ¿Eliminar convenio? ──────────────────┐
│  Se eliminará el convenio del 2026-03-01 al            │
│  2027-02-28. Esta acción no se puede deshacer.         │
│                              [Cancelar]   [Eliminar]   │
└────────────────────────────────────────────────────────┘
```

### State: invalid range

```
│  Inicio *  [2026-03-01      📅]   Fin *  [2026-02-01 📅] │
│                                   ⚠ La fecha de fin no   │
│                                     puede ser anterior   │
│                                     a la de inicio.      │
│                                [Cancelar]   [Guardar]   │  ← Guardar disabled
```

- **Dates.** The date fields use the same date-field pattern as `employee_form.dart` and `vehicle_operator_form.dart`: a read-only text field plus a `showDatePicker`.
- **Saving.** `Guardar` creates or updates the agreement at once, then refreshes the supplier (FR-012).
  - It is disabled while a required date is missing or end < start (FR-013, SC-004).
  - An equal start and end is allowed.
- **Deleting.** `Eliminar` appears only when editing. It asks first, with a second dialog (FR-014). The button order follows `RecordFormActions`: the destructive action on the left, Cancel, then the primary action.
- **Errors.** A server error keeps the dialog open and shows an `ErrorBanner`.

---

## Open Questions

1. **The record surface needs a constitution PATCH.**
   - §VI lists Suppliers as a shared side-panel entity. Moving it to a full detail screen is the same per-entity reassignment as Customers in v1.13.3.
   - Options:
     - (a) Amend to v1.13.4: move Suppliers to the full-detail list, giving nested child collections as the reason.
     - (b) Keep the side panel, and fit four sections into it at 640 px.
   - Wireframe assumed **(a)**. The plan's Constitution Check has to carry it.
2. **Where do you delete an agreement?**
   - §VI bans a per-row Delete icon on list rows, and the facility child rows put delete inside the edit surface. The spec only says "remove".
   - Options:
     - (a) `Eliminar` inside the edit dialog, with a confirmation.
     - (b) A row overflow menu with Edit and Delete.
     - (c) A direct trash icon on the row.
   - Wireframe assumed **(a)**. (c) breaks §VI, and (b) adds a menu for a single extra action.
3. **Do unsaved link changes get a visual marker?**
   - Today, the customer screen shows linked and unlinked rows the same way, saved or not.
   - Options:
     - (a) No marker, consistent with customers; leaving with unsaved edits asks first.
     - (b) A "pending" tag or tint, which `LinkedRecordsSection` would need to support for both customers and suppliers.
   - Wireframe assumed **(a)**.
4. **What happens after the first save of a new supplier?**
   - *Checked:* the customer form pops back to the list after every save, create or update (`customer_form.dart:136`).
   - Options:
     - (a) After **create** only, stay on the page as `/suppliers/:id` in edit mode, so agreements can be added straight away. After an update, pop as customers do.
     - (b) Pop after every save, as customers do. Adding agreements to a new supplier then means reopening it.
   - Wireframe assumed **(a)**, because FR-015 tells the user that agreements come after the save. This makes suppliers behave differently from customers on create.
5. **Can a refused save be told apart from other conflicts?**
   - *Checked:* no. Every supplier 409 comes from mbe-api's generic `IntegrityError` handler (`app/main.py`), with the same body: `{"detail": "The request conflicts with existing data"}`. A vanished linked id and a duplicate supplier code look identical.
   - **On save,** FR-011's message has to cover both causes. For example: "Ya existe un proveedor con ese código, o uno de los registros vinculados ya no existe." The alternative is an mbe-api change (#147's error codes would solve it).
   - **On delete,** the case is clear: a foreign-key 409 can only come from links or agreements, so FR-017's specific message stands.
   - Wireframe assumed **the combined save message and the specific delete message**. The spec's FR-011 wording needs to be updated to match.
6. **Is the agreements table the right component, or should it be rows?**
   - The certificates precedent uses `DataTableView`. The other three sections use `LinkedRecordsSection`'s list rows.
   - Options:
     - (a) `DataTableView`, which is column-aligned dates and good for scanning history.
     - (b) `ListTile` rows that visually match the other sections. This needs either an edit-row variant of `LinkedRecordsSection` or a new section widget.
   - Wireframe assumed **(a)**. It reuses an existing component as is. (b) is a component gap.
