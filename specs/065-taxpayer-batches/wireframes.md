# Wireframes: Taxpayer Batches (Folio Series)

**Spec**: [spec.md](./spec.md) | **Drawn**: 2026-11-15 | **Fidelity**: low

Drawn from the spec. Layout is indicative, not prescriptive: every dimension, colour and spacing resolves through the design tokens, per constitution §V.

> **Order note.** This ran after `/speckit-plan`, not before it. The drawings use the component choices plan.md already made (research R1–R3). Open questions that would change the spec are marked **→ spec**. Questions that only confirm a plan choice are marked **→ plan**.

## Screen: Taxpayer issuer detail, Series section (`/taxpayer-issuers/:rfc`)

The existing issuer form and Certificados section are unchanged. The new section sits below Certificados, inside the same width-capped column.

### State: populated (edit mode, admin)

```text
┌──────────────────────────────────────────────────────────────────────────────────┐
│ ← Editar emisor                                                                  │
├──────────────────────────────────────────────────────────────────────────────────┤
│  [ RFC ............ ]  [ Razón social ............................. ]            │
│  [ Régimen ▾ ...... ]  [ Proveedor ▾ ] [ C.P. ..... ]   (existing form)          │
│                                        [ Eliminar ]  [ Guardar ]                 │
│ ──────────────────────────────────────────────────────────────────────────────── │
│  Certificados                                          [ + Agregar ]  (existing) │
│  │ Número ...........│ Desde ....│ Hasta ....│ Estado │                           │
│ ──────────────────────────────────────────────────────────────────────────────── │
│  Series (4)                                                        [ + Nuevo ]   │
│  ┌─────────┬────────────────────┬──────────────────────┬────────┬─────┐          │
│  │ Serie   │ Tipo               │ Plantilla            │ En uso │     │          │
│  ├─────────┼────────────────────┼──────────────────────┼────────┼─────┤          │
│  │ A       │ Factura            │ Factura estándar     │   🔒   │  ✎  │          │
│  │ B       │ Factura            │ Factura sucursal…    │        │  ✎  │          │
│  │ NC      │ Nota de crédito    │ Nota de crédito      │   🔒   │  ✎  │          │
│  │ P       │ Recibo de pago     │ Recibo               │        │  ✎  │          │
│  └─────────┴────────────────────┴──────────────────────┴────────┴─────┘          │
└──────────────────────────────────────────────────────────────────────────────────┘
```

- **Section header.** Title with count, like the linked-record sections. "+ Nuevo" is a `TextButton.icon` using `CatalogAction.create.icon`, and appears only with create right on an editable render (FR-015).
- **Table.** `DataTableView` (`shrinkWrap`, `margin: zero`), with no pagination (FR-001, FR-002).
  - Tipo is a localized label (FR-003).
  - Plantilla truncates, with a tooltip (§VI, a secondary column).
  - En uso is a lock icon with a tooltip, not a `StatusChip`, because it is a flag and not a lifecycle status (FR-002).
- **Row actions.**
  - ✎ comes from `buildCatalogRowActions` and appears only with update right on an editable render.
  - A row tap opens the dialog in view mode (§VI).
  - There is no row delete (FR-014, §VI).
- **Order.** Type, then series (spec Assumptions).

### State: issuer screen in View mode, or a reader without update

```text
│  Series (4)                                                                      │
│  ┌─────────┬────────────────────┬──────────────────────┬────────┐                │
│  │ Serie   │ Tipo               │ Plantilla            │ En uso │                │
│  ├─────────┼────────────────────┼──────────────────────┼────────┤                │
│  │ A       │ Factura            │ Factura estándar     │   🔒   │  ← row tap =   │
│  │ ...                                                         │    "Ver serie" │
```

- Shows no "+ Nuevo" and no ✎ column. Rows stay tappable and open read-only (FR-015, US1).

### State: empty

```text
│  Series                                                            [ + Nuevo ]   │
│  Este emisor no tiene series. Sin una serie del tipo correspondiente no puede    │
│  emitir ese documento.                                                           │
```

- A muted note (`bodySmall`, `onSurfaceVariant`), the same as the discounts/agreements empty line (US1 #2, FR-004).

### State: loading

```text
│  Series                                                                          │
│                                     ◌                                            │
```

- A centered `CircularProgressIndicator`. "+ Nuevo" is hidden until the list loads (FR-004).

### State: error

```text
│  Series                                                                          │
│  ⚠ No se pudieron cargar las series. <localized cause>          [ Reintentar ]   │
```

- `ListFailedView`. The issuer form above stays usable (US1 #3, FR-004).

### State: unknown type code from the backend

```text
│  │ X       │ Tipo desconocido (7)│ Plantilla X         │        │  ✎  │          │
```

- Edge case. Sorts last.

### State: issuer being created (not saved)

```text
│  [ RFC ............ ]  [ Razón social ............................. ]            │
│                                                       [ Guardar ]                │
└──────────────────────────────────────────────────────────────────────────────────┘
   (no Certificados, no Series)
```

- FR-005. Matches the Certificados rule.

### Compact tier

```text
┌────────────────────────────────────┐
│ ← Editar emisor                    │
│ ...form, one column...             │
│ ────────────────────────────────── │
│ Certificados          [+ Agregar]  │
│ ...                                │
│ ────────────────────────────────── │
│ Series (4)              [+ Nuevo]  │
│ ┌──────┬────────────────┬────┬───┐ │
│ │Serie │ Tipo           │ 🔒 │   │ │
│ ├──────┼────────────────┼────┼───┤ │
│ │A     │ Factura        │ 🔒 │ ✎ │ │
│ │B     │ Factura        │    │ ✎ │ │
│ │NC    │ Nota de crédito│ 🔒 │ ✎ │ │
│ └──────┴────────────────┴────┴───┘ │
└────────────────────────────────────┘
```

- **Plantilla is dropped.** It is secondary text, and the template name is one tap away in the dialog. Serie, Tipo and the lock stay because they answer "which types are covered, and what is locked".
- The En uso header shrinks to the icon.

## Screen: Series dialog (`ResponsiveDialog`, launched from the section)

### State: create

```text
┌──────────────────────────────────────────────────────────────┐
│ Nueva serie                                              ✕   │
├──────────────────────────────────────────────────────────────┤
│  [ Serie ......... ]           [ Tipo de documento ▾ ...... ]│
│  [ Nombre de plantilla ................................... ] │
│  [ Logo (archivo) ......... ]                                │
│  [ Alto de encabezado  0 ]     [ Alto de pie  15 ]           │
│ ──────────────────────────────────────────────────────────── │
│  Cuentas bancarias                                           │
│   (none yet)                                                 │
│  [ + Agregar cuenta ]                                        │
│ ──────────────────────────────────────────────────────────── │
│                                    [ Cancelar ]  [ Guardar ] │
└──────────────────────────────────────────────────────────────┘
```

- **Form.** `ResponsiveFormGrid` with at most 2 columns (§VI).
- **Tipo.** A dropdown of the 7 localized kinds, with nothing preselected (FR-006).
- **Defaults.** Header height 0, footer height 15 (FR-006).
- **Actions.** The dialog's own primary and secondary actions (Guardar, Cancelar).

### State: create with bank accounts (and a validation error)

```text
│  [ Serie  FACTURAS-2026 ]      [ Tipo de documento ▾ Factura ]│
│    ⚠ Máximo 10 caracteres                                     │
│  [ Nombre de plantilla  Factura ......................... ]  │
│ ──────────────────────────────────────────────────────────── │
│  Cuentas bancarias                                           │
│  ┌────────────────────────────────────────────────────────┐  │
│  │ [Banco BBVA ] [Cuenta 0123456789] [CLABE 0121800…] [MXN]│  │
│  │                                            ↓    🗑     │  │
│  ├────────────────────────────────────────────────────────┤  │
│  │ [Banco Banorte] [Cuenta ......] [CLABE .......] [MXN]  │  │
│  │                                       ↑         🗑     │  │
│  └────────────────────────────────────────────────────────┘  │
│  [ + Agregar cuenta ]                                        │
```

- **Accounts.** Each one is a row of four text fields, plus move up/down and remove `IconButton`s (FR-007). Up is absent on the first account and down on the last. All-blank accounts are dropped on save.
- **Field errors.** Shown under their field (FR-008).

### State: duplicate series refused by the server

```text
│  ┌──────────────────────────────────────────────────────────┐│
│  │ ⚠ Ya existe una serie con ese valor.                      ││
│  └──────────────────────────────────────────────────────────┘│
│  [ Serie  A ]                  [ Tipo de documento ▾ Nota… ] │
│    ⚠ Ya existe una serie con ese valor.                       │
```

- `FormErrorBanner` plus the field error. The typed values are kept (US2 #2, FR-011).

### State: view (row tap)

```text
┌──────────────────────────────────────────────────────────────┐
│ Ver serie                                                ✕   │
├──────────────────────────────────────────────────────────────┤
│  Serie   A                     Tipo de documento   Factura   │
│  Nombre de plantilla   Factura estándar                      │
│  Logo   logo-cm.png                                          │
│  Alto de encabezado   0        Alto de pie   15              │
│ ──────────────────────────────────────────────────────────── │
│  Cuentas bancarias                                           │
│   BBVA · 0123456789 · CLABE 012180001234567891 · MXN         │
│ ──────────────────────────────────────────────────────────── │
│                                     [ Cerrar ]  [ Editar ]   │
└──────────────────────────────────────────────────────────────┘
```

- The dialog's own actions in view mode. Editar is the primary action and appears only with update right on an editable parent, and switches to edit in place (§VI, FR-015).
- With no accounts, the group shows "Sin cuentas bancarias".

### State: edit, series in use (locked)

```text
┌──────────────────────────────────────────────────────────────┐
│ Editar serie                                             ✕   │
├──────────────────────────────────────────────────────────────┤
│  🔒 Ya hay documentos emitidos con esta serie; solo puede    │
│     cambiar la plantilla.                                    │
│  Serie   A  (read-only)        Tipo   Factura  (read-only)   │
│  [ Nombre de plantilla  Factura estándar ................ ]  │
│  [ Logo  logo-cm.png ]                                       │
│  [ Alto de encabezado  0 ]     [ Alto de pie  15 ]           │
│ ──────────────────────────────────────────────────────────── │
│  Cuentas bancarias  ...editable...                           │
│ ──────────────────────────────────────────────────────────── │
│                                    [ Cancelar ]  [ Guardar ] │
└──────────────────────────────────────────────────────────────┘
```

- The lock note sits above the fields. Series and type render read-only. There is no Eliminar (FR-010, FR-014, SC-003).

### State: edit, unused series (admin)

```text
│  [ Serie  B ]                  [ Tipo de documento ▾ Factura ]│
│  ...template fields...                                        │
│ ──────────────────────────────────────────────────────────── │
│                       [ Cancelar ]  [ Eliminar ]  [ Guardar ] │
```

- Eliminar is a warning-styled button at the bottom of the body, behind the shared confirmation. It appears only with delete right (FR-013, FR-015).

### State: delete confirmation

```text
            ┌────────────────────────────────────────────┐
            │ ¿Eliminar la serie?                        │
            │ Se eliminará la serie B (Factura).         │
            │                     [ Cancelar ] [Eliminar]│
            └────────────────────────────────────────────┘
```

- The `RecordDeleteConfirmation` wording names the series and type (US4 #2).

### State: became in use while open (race)

```text
│  ┌──────────────────────────────────────────────────────────┐│
│  │ ⚠ La serie ya se usa en documentos emitidos; solo puede  ││
│  │   cambiar su plantilla.                                   ││
│  └──────────────────────────────────────────────────────────┘│
│  🔒 Ya hay documentos emitidos con esta serie; ...            │
│  Serie   B  (read-only, reset)   Tipo   Factura (read-only)  │
│  ...template edits kept...                                    │
│                                    [ Cancelar ]  [ Guardar ] │
```

- Banner plus the switch to the locked layout. The list behind is refreshed (US3 #4, US4 #4, FR-012).

### State: saving

```text
│                                    [ Cancelar ]  [ ◌ Guardar ]│
```

- The busy primary action (`ResponsiveDialogAction.busy`). Fields are not editable while saving.

### Compact tier

```text
┌────────────────────────────────────┐
│ ✕  Editar serie          [Guardar] │
├────────────────────────────────────┤
│ [ Serie ....................... ]  │
│ [ Tipo de documento ▾ ......... ]  │
│ [ Nombre de plantilla ......... ]  │
│ [ Logo ........................ ]  │
│ [ Alto de encabezado .......... ]  │
│ [ Alto de pie ................. ]  │
│ ────────────────────────────────── │
│ Cuentas bancarias                  │
│ ┌────────────────────────────────┐ │
│ │ [ Banco ..................... ]│ │
│ │ [ Cuenta .................... ]│ │
│ │ [ CLABE ..................... ]│ │
│ │ [ Moneda .. ]      ↑  ↓  🗑    │ │
│ └────────────────────────────────┘ │
│ [ + Agregar cuenta ]               │
│ ────────────────────────────────── │
│ [ Eliminar ]                       │
└────────────────────────────────────┘
```

- `ResponsiveDialog` goes fullscreen, and the grid collapses to one column.
- Each account stacks its four fields vertically, with the icons beside the currency field.
- Nothing is dropped.

## Open Questions

> **Resolved at implementation (tasks T041).** Questions 1 and 3 stood as assumed. Question 2 was left out, as assumed. Question 4: "+ Nuevo", the edit icon and Editar follow the issuer screen's editable render, and spec FR-015 now says so. Question 5: both height fields carry an "mm" suffix, and spec FR-006 now says so. The header-height hint (option c) was not added.

1. **Logo: free text or a picker of known image files?** The spec says it is a file name, not an upload. With free text, a typo silently prints no logo. Options: (a) free text, (b) a dropdown of images the server knows (needs an API endpoint that doesn't exist). The wireframe assumes **(a)**. **→ spec**, already stated in Assumptions. If the risk matters, an mbe-api issue for (b) is the follow-up.
2. **Should the empty state suggest which types are missing even when some series exist?** For example: "Sin serie para: Nota de crédito, Recibo de pago". It helps diagnose "issuer has no series" errors for a specific type. Options: (a) no, the plain list only, (b) a muted line under the table listing uncovered types. The wireframe assumes **(a)**, because the spec doesn't ask for it. **→ spec** if wanted. It would be a small FR addition to US1.
3. **The En uso column: a lock icon or a text chip?** A `StatusChip` reads as a lifecycle status, and this is a flag. The wireframe assumes **a lock icon with a tooltip**. **→ plan**, already in ui-contract.md.
4. **Can a user with create but not update add a series?** The parent screen's read-only flag folds in `!canUpdate`, so "+ Nuevo" is hidden for them, the same as Certificados' "Agregar". Options: (a) keep the screen-wide rule, (b) let create-only users add series. The wireframe assumes **(a)**. **→ spec**, because FR-015 implies create alone suffices. Either amend FR-015 to say "on an editable render of the issuer", or the plan has to special-case the section.
5. **Header/footer height units.** Checked in mbe-api:
   - Footer height is millimetres: `cfdi.batch_settings` reads it as `footer_height_mm`, and the invoice PDF uses it as `height_mm`.
   - Header height is stored and round-tripped, but the new PDF renderer never reads it. It only matters for legacy.

   Options: (a) both fields with no unit, (b) "mm" on both, with header kept for legacy, (c) "mm" on footer, and header shown with a hint that the current print doesn't use it. The wireframe assumes **(b)**. **→ spec**: add the "mm" unit to FR-006, and decide whether header height needs the hint.
