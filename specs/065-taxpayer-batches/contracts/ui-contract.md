# UI Contract: Taxpayer Batches

## Series section (`TaxpayerBatchesSection`)

- **Placement.** On `TaxpayerIssuerDetailScreen`, only when `_isEdit` (a saved issuer). It goes inside the same width-capped column as the Certificates section, after it, separated by a `Divider`.
- **Inputs.** `rfc` (`String`) and `readOnly` (`bool`, the parent's own flag).

| Element | Key | Shown when |
|---|---|---|
| Title "Series" / "Series (n)" | none | Always. The count shows once the list has loaded and isn't empty |
| "Nuevo" `TextButton.icon` | `add_taxpayer_batch_button` | `!readOnly && can(taxpayers, create)` |
| Loading spinner | none | Loading |
| `ListFailedView` with retry | none | Error. Retry invalidates `taxpayerBatchesControllerProvider(rfc)` |
| Empty note | `taxpayer_batches_empty` | Loaded and empty: "Este emisor no tiene series. Sin una serie del tipo correspondiente no puede emitir ese documento." |
| Table | `taxpayer_batches_table` | Loaded and not empty |

### Table columns

| Column | Content | Compact tier |
|---|---|---|
| Serie | `series` | kept |
| Tipo | localized `kind` label, or "Tipo desconocido (n)" | kept |
| Plantilla | `template.name` (may be truncated, with a tooltip) | dropped |
| En uso | a lock icon with the tooltip "En uso", empty otherwise | kept |

- **Row tap.** Opens the dialog in `view` mode.
- **Row Edit icon.** Uses `buildCatalogRowActions`, key `edit_taxpayer_batch_{id}`. Shown when `!readOnly && can(taxpayers, update)`. Opens the dialog in `edit` mode.
- **No row delete icon** (§VI).
- **Order.** By kind, then series (research R5).
- **Paging.** None. The list is small, the same as Certificates.

## Series dialog (`showTaxpayerBatchDialog(context, rfc:, existing:, startInEdit:, parentReadOnly:)`)

`ResponsiveDialog` (fullscreen on compact). Title by mode:

| Mode | es title |
|---|---|
| create | Nueva serie |
| view | Ver serie |
| edit | Editar serie |

### Fields (`ResponsiveFormGrid`, max 2 columns)

| Field | Key | Editable when |
|---|---|---|
| Serie | `taxpayer_batch_series_field` | mode ≠ view and not locked |
| Tipo de documento (dropdown of the 7 kinds) | `taxpayer_batch_type_field` | mode ≠ view and not locked |
| Nombre de plantilla | `taxpayer_batch_template_name_field` | mode ≠ view |
| Logo (file name) | `taxpayer_batch_logo_field` | mode ≠ view |
| Alto de encabezado | `taxpayer_batch_header_height_field` | mode ≠ view |
| Alto de pie | `taxpayer_batch_footer_height_field` | mode ≠ view |

- **Lock note.** Key `taxpayer_batch_in_use_note`. Shown when locked: "Ya hay documentos emitidos con esta serie; solo puede cambiar la plantilla."

### Bank accounts group

Titled "Cuentas bancarias", delimited by a divider.

- **Each account.** Bank, Cuenta, CLABE and Moneda fields, plus icon buttons `move_account_up_{i}`, `move_account_down_{i}` and `remove_account_{i}`. The buttons appear only in editable modes. Up is absent on the first account and down on the last.
- **"Agregar cuenta".** Key `add_taxpayer_batch_account_button`. Editable modes only.
- **View mode with no accounts.** Shows "Sin cuentas bancarias".

### Actions

The shared `RecordFormActions`, keyed `taxpayer_batch_form_actions`. Close or Cancel is the dialog's own secondary action.

| Mode | Actions |
|---|---|
| create | Guardar |
| view | Editar (only when `!parentReadOnly && can(update)`; switches mode in place) |
| edit | Eliminar (only when `can(delete) && !locked`; confirmation names series and type, confirm key `confirm_delete_taxpayer_batch_button`), then Guardar |

### Outcomes

| Event | Result |
|---|---|
| Save or delete succeeds | Dialog pops; `taxpayerBatchesControllerProvider(rfc)` invalidated |
| Refusal | Shown in the dialog's `FormErrorBanner` via the shared localized path; field errors under their fields |
| In-use race | Stays open, locked, list invalidated (research R6) |
| Issuer gone | Pops, then `go('/taxpayer-issuers')` (research R8) |
