# Research: Taxpayer Batches (Folio Series)

Phase 0 for [plan.md](plan.md). The spec has no open clarifications, so the decisions below cover the design choices and the facts checked against mbe-api and this codebase.

## R1. Surface: a dialog launched from a section in the issuer detail

- **Decision.** Add a `TaxpayerBatchesSection` below the Certificates section on `TaxpayerIssuerDetailScreen`. A series opens in a `ResponsiveDialog`, the same way customer discounts (spec 052) and supplier agreements (spec 050) open from their parent's detail screen.
- **Rationale.**
  - A series only exists under its issuer. The API nests it at `/taxpayer-issuers/{rfc}/batches`, and it has no list of its own.
  - §VI requires a full detail screen for an entity that owns child collections or has more than 15 own fields. A series has six own fields: series, type, template name, logo, header height and footer height.
  - The bank accounts are a repeating group inside the template value. They have no id or endpoint of their own and are saved atomically with the series, so they are not a child collection in §VI's sense. The issuer stays a full screen, as it already is.
- **Alternatives considered.**
  - A full screen per series with its own URL: nothing links to a series, and it would take the user away from the issuer they are configuring.
  - `showRecordSheet`: it opens over a list screen, and there is no series list screen.

## R2. View mode, Edit toggle and Delete inside the dialog

- **Decision.**
  - Tapping a row opens the dialog read-only, titled "Ver serie".
  - The row's Edit icon opens it editable, titled "Editar serie".
  - The dialog's action area is the shared `RecordFormActions`:
    - `view` mode shows Edit, which switches the dialog to editable in place.
    - `edit` mode shows Delete (behind the shared confirmation), then Save.
    - `create` mode shows Save only.
- **Rationale.**
  - §VI says a row click opens the record read-only, the read-only surface is labeled "View" with an in-place switch to edit, and delete lives on the record's own surface, never on the row.
  - The spec needs this too: FR-015 lets a reader without update see a series' full template, which the row doesn't show (logo, heights, accounts).
  - `RecordFormActions` already enforces "absent, not disabled" and the delete confirmation.
- **Alternatives considered.**
  - Discount-style (no row tap, a hand-rolled delete button in the dialog): readers couldn't see the template, and §VI's row-click rule would be broken for a row with hidden detail.
  - A delete icon on the row: banned by §VI.

## R3. Rights

All four rights are on Taxpayers (24). The parent screen's `readOnly` flag (`forceReadOnly || !canUpdate`) is passed through, as Certificates does:

| Control | Shown when |
|---|---|
| Section and rows | Always. The route is already gated by `PrivilegeGate(taxpayers, read)` |
| Row tap (view) | Always |
| "Nuevo" button | `!readOnly && can(create)` |
| Row Edit icon, and the Edit toggle in view mode | `!readOnly && can(update)` |
| Delete in edit mode | `can(delete) && !batch.inUse` |

`readOnly` already folds in `!canUpdate`. That means a user with create but not update sees no "Nuevo" button, the same as the Certificates section. This is the existing screen-wide rule, so we keep it rather than special-casing series.

## R4. Document type: a domain enum keyed by code

- **Decision.** Add a domain enum `FiscalDocumentKind`: `invoice(0)`, `expense(1)`, `payment(2)`, `transfer(3)`, `creditNote(100)`, `paymentReceipt(101)`, `advancePaymentsApplied(200)`. It has `code` and `static FiscalDocumentKind? fromCode(int)`.
  - The entity keeps the raw `typeCode` (int) and a nullable `kind`. A null `kind` renders "Tipo desconocido (code)".
  - Mapping to the generated `FiscalDocumentType` (`number0`…`number200`) happens only in the repository.
- **Rationale.**
  - The response's `type` is a plain `int`, while create and update take the generated `FiscalDocumentType` enum with opaque names.
  - §III keeps generated types out of `presentation`.
  - The spec's edge case requires an unknown code to still render.
- **Name.** `FiscalDocumentKind` avoids clashing with the generated `FiscalDocumentType` export and with `core/documents`' `DocumentKind`, which covers printable documents.
- **Alternatives considered.** Using the generated enum in the UI: it breaks §III and can't represent an unknown code.

## R5. Ordering

- **Decision.** Sort client-side by the type's position in the enum (Invoice first), then by series. Unknown types go last.
- **Rationale.** The spec assumes type-then-series order so an administrator can see coverage per document type at a glance. The server orders by series only (`list_batches`), and the list is small and unpaged.

## R6. In-use lock and the race

- **Up front.** The dialog renders series and type read-only when `batch.inUse`, with a note: "Ya hay documentos emitidos con esta serie; solo puede cambiar la plantilla."
- **Race.** The series became in use after the list loaded, and the save or delete returns 409 `taxpayer_batch.in_use`:
  - The dialog stays open and shows the localized message in its error banner.
  - The controller resets series and type to their saved values and marks the draft locked. The user's template edits survive, so they can save those right away.
  - The section's list provider is invalidated so the row shows the lock.
- **Rationale.** FR-010 and FR-012. Recognition is keyed on the code (§III).

## R7. Duplicate series

- **Fact.** `_assert_series_free` raises `resource.already_exists` with `{resource: taxpayer_batch, field: batch}` (409).
- **Decision.** Map it to `fieldErrors['batch']`, shown under the series field with the localized text, the same way the discount dialog maps `resource.already_exists` with a `field`.
- **Client checks.** The client also trims, and rejects a series that is blank or longer than 10 characters, before sending anything. It doesn't pre-check uniqueness against the loaded list: the server is the authority, and the list can be stale.

## R8. Not found

| Refusal | Behavior |
|---|---|
| `resource.not_found`, `resource: taxpayer_issuer` (create, or the list) | The issuer was deleted elsewhere. Close the dialog and `go('/taxpayer-issuers')`, as the spec's edge case asks. The issuer detail already handles a missing issuer on load |
| `resource.not_found`, `resource: taxpayer_batch` (update or delete) | The series was deleted elsewhere. Show the message, invalidate the list, and keep the dialog open so the user can cancel |

## R9. Error-text coverage (§III)

Codes and validation types the four endpoints can return, from `specs/058-localized-api-errors/contracts/code-scope.tsv` and mbe-api's `taxpayer_batch_service.py` / `schemas/fiscal.py`:

| Kind | Name | Today | Action |
|---|---|---|---|
| code | `taxpayer_batch.in_use` (`action`: `update` \| `delete`) | OUT | Add a message per action in es and en. Flip the row to IN |
| code | `resource.already_exists` | IN | Add a resource row for `taxpayer_batch` |
| code | `resource.not_found` | IN | Add a resource row for `taxpayer_batch`. `taxpayer_issuer` is already IN |
| validation_type | `taxpayer_batch_series_blank` | OUT | Add to `localizedValidationTypes` and `localizeValidationType`. Flip to IN |
| resource noun | `taxpayer_batch` | missing in `resourceNoun` / `resourceGender` | Add "serie" (feminine) / "series" |
| generic | `string_too_short`, `string_too_long`, `greater_than_equal`, `enum` | already handled generically | none |

`catalog_coverage_test` expects 113 codes marked IN. It becomes 114.

## R10. Bank account editing

- **Layout.** Each account is a row of four text fields (bank, account, CLABE, currency) with "move up", "move down" and "remove" icon buttons, plus an "Agregar cuenta" text button below. On the compact tier each account stacks into one column.
- **Saving.** Accounts whose fields are all blank are dropped. The others are sent in order, with fields trimmed.
- **Rationale.** FR-007. Up/down buttons work by keyboard and inside a scrolling dialog, where `ReorderableListView` nested in a scroll view is fragile.
- **No field validation.** The API accepts any text in these four fields, and the spec makes them optional free text.

## R11. Template round-trip

- **What is sent.** PUT replaces the whole record. The dialog always sends the full template: name, logo (null when blank), both heights and the accounts.
- **New series defaults.** Header height 0 and footer height 15, matching the API's defaults.
- **Fields the UI doesn't show.** The API's `BatchTemplate` only exchanges these five fields. Any other legacy keys stored in the JSON are dropped by the API, not by the UI.

## R12. Backend dependency

None. mictlanix/mbe-roadmap#44 shipped the four endpoints, and the generated client already has `createTaxpayerBatch…`, `listTaxpayerBatches…` (returns `BuiltList<TaxpayerBatchResponse>`, not a `ListResponse`), `updateTaxpayerBatch…` and `deleteTaxpayerBatch…` on `TaxpayerIssuersApi`. No codegen re-run and no mbe-api issue.

## R13. Testing approach

- **Unit.**
  - The repository against a mocked `TaxpayerIssuersApi`: mapping, type code conversion and error passthrough.
  - `FiscalDocumentKind.fromCode`.
  - Validators.
  - The dialog controller: create, update, delete, the in-use race, duplicate mapping, blank-account dropping and reorder.
  - The localize_problem additions and the coverage count.
- **Widget.**
  - The section: loading, empty, error/retry, sorted rows, type labels, in-use marker, and the rights matrix.
  - The dialog in view, edit and create modes: lock rendering, the Edit toggle, and Delete hidden when in use.
- **Live.** `integration_test/taxpayer_batches_quickstart_test.dart` on macOS. It discovers an issuer at runtime and cleans up the series it creates (the memory pattern from spec 009).
