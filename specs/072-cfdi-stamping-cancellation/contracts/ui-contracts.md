# UI Contracts: CFDI Stamping, Refresh and Cancellation

Contracts continue spec 066's numbering (C1–C14) ([066 ui-contracts](../../066-invoice-list-editor/contracts/ui-contracts.md)).
Keys are the widget `Key`s tests find.

## C15. Status chip and filter (FR-001, FR-002)

- `FiscalDocumentStatusChip` renders all six states (data-model table).
- The list filter's state picker lists them in lifecycle order: draft, sealed, stamping,
  issued, cancellationPending, cancelled.
- URL: `status=<wire value>`. An unknown value in the URL is dropped, as spec 066 does
  for facets.

## C16. Detail banner (FR-005, FR-009, FR-013)

`_StatusBanner` shows at most one banner, keyed `fiscal_document_banner_<key>`:

| key | When | Text (es) | Colours |
|---|---|---|---|
| `cancelled` | cancelled | existing | error |
| `cancellation_pending` | cancellationPending | "Cancelación solicitada el {requestedAt}. El SAT espera que el receptor la acepte; mientras tanto el documento sigue vigente." (no date if `openCancellation` is null) | tertiary |
| `stamping` | stamping | "Timbrando desde {stampingSince}. El PAC aún no confirma el resultado; el sistema lo consulta cada 10 minutos, o puedes consultarlo ahora." The last clause is dropped without 23 update | tertiary |
| `sealed` | sealed | "Sellado, sin validez fiscal todavía." With 23 update, invoices add "Timbralo para emitirlo, o reábrelo si necesitas corregirlo (conserva el folio)."; other types add "Timbralo para emitirlo." | primary |
| `read_only_kind` | non-invoice draft (existing) | existing | primary |

The old "stamping is not yet available" text (`fiscalDocumentBannerSealed`) is replaced.

## C17. Stamp facts and badge (FR-007, FR-008)

- Shown in `_HeaderFacts` when `stamp != null`. The existing UUID fact is kept.
- New facts:
  - `fiscal_document_stamped`: Fecha de timbrado ("Stamped on"), the date and time.
  - `fiscal_document_sat_certificate`: Certificado SAT.
  - `fiscal_document_provider_rfc`: PAC.
- A null field shows `emptyValuePlaceholder`.
- `fiscal_document_substitution`: "Sustituida por", shown when `cancellationSubstitution`
  is set.
- `fiscal_document_simulated_badge`: a `StatusChip`, error colours, beside the state chip,
  shown only when `stamp.simulated`.

## C18. Action row (FR-005, FR-006, FR-010, FR-015, FR-020, FR-021)

The order is fixed, with the primary action last. Each button is present only when its
condition holds, and otherwise absent:

| Key | Label | Style | Condition |
|---|---|---|---|
| `fiscal_document_view_pdf` | Ver PDF | Outlined | `canRead && hasDocuments` |
| `fiscal_document_download_xml` | Descargar XML | Outlined | same |
| `fiscal_document_cancel_cfdi` | Cancelar ante el SAT | Outlined, error foreground | `canCancel && can(23, update)` |
| `fiscal_document_reopen` | Reabrir | Outlined | `canReopen && can(23, update)` |
| `fiscal_document_stamp` | Timbrar | Filled | `canStamp && can(23, update)` |
| `fiscal_document_refresh` | Consultar estado | Filled | `canRefresh && can(23, update)` |
| `fiscal_document_confirm` | Confirmar | Filled | existing (draft) |

At most one filled button applies at a time, since the states are mutually exclusive.

While refresh runs, every button is disabled and `fiscal_document_refresh` shows a
spinner. Stamp and cancel run inside their dialogs (C20, C21).

## C19. Cancellation history (FR-017, FR-019)

- `fiscal_document_cancellations`: a section titled "Cancelaciones", shown when
  `cancellations` is non-empty, placed after related documents and before totals.
- One row per entry, keyed `fiscal_document_cancellation_<id>`, newest first.
- Each row shows:
  - the reason code and its label;
  - the outcome chip (R10 colours);
  - the substitute UUID, if any;
  - "Solicitó {employee name | #id} · {requestedAt}";
  - "Respuesta {answeredAt | —}" and "Resuelta {resolvedAt | —}";
  - when present, "PAC {pacCode} · «{pacMessage}»", verbatim.
- On compact, each row's facts stack vertically.

## C20. Stamp confirmation (FR-006)

- `showStampFiscalDocumentDialog(context, document:)` in `invoice_action_dialogs.dart`,
  built like `showConfirmInvoiceDialog`.
- Title: "¿Timbrar {kind} {folio}?"
- Body: "Se enviará al PAC para timbrarlo ante el SAT. Una vez timbrado ya no podrá
  reabrirse ni editarse; solo podrá cancelarse."
- Buttons: Volver / Timbrar.
- While running: progress, buttons disabled.
- A refusal closes the dialog and returns the error to the detail's refusal slot.
- On success: snackbar "{folio} timbrado", plus " (simulado)" when `stamp.simulated`.

## C21. Cancel dialog (FR-010–FR-013, FR-018)

`showCancelFiscalDocumentDialog(context, document:)` in the new
`cancel_fiscal_document_dialog.dart`. It is a `ResponsiveDialog`, with
`hasUnsavedChanges` once a reason is picked.

**Keys**:
- `cancel_cfdi_dialog`
- `cancel_cfdi_reason_<code>`: radio buttons, none preselected
- `cancel_cfdi_substitute`: the C22 picker, shown only for 01
- `cancel_cfdi_substitute_selected`, with a `Cambiar` control
- `cancel_cfdi_candidate_row_<id>`, `cancel_cfdi_candidate_search`, `cancel_cfdi_candidate_empty` (the no-candidates explanation): the C22 picker with key prefix `cancel_cfdi_candidate`
- `cancel_cfdi_substitute_change`: the Cambiar control
- `cancel_cfdi_submit`: "Enviar cancelación", enabled only when valid (data-model
  validation)
- `cancel_cfdi_back`: "Volver"

**Text**: "La solicitud se envía al SAT y no se puede deshacer desde aquí. Si el SAT
requiere la aceptación del receptor, quedará pendiente." The dialog is its own
confirmation; there is no second prompt.

**Refusals**:
- **Inline** (dialog stays open): `fiscal_document.substitution_invalid`,
  `.substitution_required`, `.unknown_cancellation_reason`.
- **Closing** (shown in the detail's refusal slot): everything else.

**Success**: the dialog closes, and a snackbar reads "Cancelación enviada: {state label}".

## C22. Candidate picker (FR-011)

- `FiscalDocumentCandidatePicker` in `fiscal_document_candidate_picker.dart`, extracted
  from `_AddRelationDialog`.
- Inputs: `issuerRfc`, `status`, `excludeId`, `recipientRfc` (initial search and row
  filter), `onPicked`.
- Rows are keyed `<prefix>_row_<id>` and show folio, issue date, UUID and total (the
  relation dialog's columns).
- Also keyed: `<prefix>_search`, `<prefix>_load_more` and `<prefix>_empty`.
- The add-relation dialog re-hosts it with no behaviour change. The relation dialog's
  existing keys are kept by passing a key prefix.

## C23. Refresh outcomes (FR-016)

| Outcome | Shown in | Key | Text (es) |
|---|---|---|---|
| Same status as before | refusal slot, info style, dismissible | `fiscal_document_still_in_process` | "Sigue en proceso. Vuelve a consultar en unos minutos." |
| New status | snackbar | — | "{folio}: {new state label}" |
| Error | refusal slot | — | the `FiscalDocumentRefusal` text |

## C24. Error messages (FR-018, FR-019)

Covers the 12 new codes, the 3 reworded ones, and the stamp-context hint for
`issue_date_out_of_range` (key `fiscal_document_refusal_hint`). Details are in research R9.
English and Spanish keys are added together.
