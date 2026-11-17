# Research: Physical Inventory Counts (070)

Sources:
- mbe-api `docs/specs/04-inventory.md` §4–5 and Common Patterns.
- mbe-api `app/services/inventory_count_service.py`, `app/services/inventory_documents.py` (`COUNT` kind), `app/api/v1/endpoints/inventory_counts.py`, `app/schemas/inventory.py` (`Count*`), `app/core/errors.py`.
- The generated client: `InventoryCountsApi`, `InventoryCountResponse`, `InventoryCountSummary`, `InventoryCountLineResponse`, `InventoryCountConfirmResponse`, `NegativeAvailable`, `CorrectedByOtherCount`.
- The mbe-ui precedent: the shipped Inventario feature in `lib/features/inventory/`. Issues (spec 068) is the closest document; receipts (067) is the precedent for post-confirm warnings.

## R1. What is reused from 067–069

- **Decision**: Reuse the shared inventory parts as they are, with no rename and no behaviour change:
  - `InventoryDocumentStatus` (`domain/entities/inventory_document_status.dart`). The server's count states are the same three.
  - `inventoryDocumentStatusColors` (`presentation/shared/inventory_document_status_chip.dart`).
  - `InventoryWarehouseName`, `InventoryFacilityName`, `InventoryEmployeeName` (`presentation/shared/inventory_name_cells.dart`).
  - `inventoryWarehouseScope`, `inventoryWarehouseOptions`, `inventoryFilterWarehouseOptions`, `inventoryStartingWarehouse` (`presentation/shared/inventory_warehouse_options.dart`).
  - `InventoryDocumentsFilter` (`presentation/shared/inventory_documents_filter.dart`).

  Counts get their own entity, repository, actions, controllers, screens and dialogs under `counts/`, copied from issues and changed where counts differ.
- **Rationale**: FR-019 asks counts to look like the other Inventario screens. The shared parts were extracted in 068 for exactly this ("Transfers and counts will add to them").
- **Alternatives considered**: A generic document detail screen shared with issues. Rejected: counts differ in lines (replace, blind, Esperado/Diferencia), entry (quick entry, paste), warnings and cancel rules, so a generic screen would need more switches than it saves.

## R2. Status labels are masculine

- **Decision**: Add a `InventoryCountStatusChip` in `counts/` that uses `inventoryDocumentStatusColors` with new labels: `inventoryCountStatusDraft` "Borrador", `inventoryCountStatusCompleted` "Confirmado" and `inventoryCountStatusCancelled` "Cancelado". The count list's filter drawer uses the same labels. Each list screen builds its own state chips, so no shared code changes.
- **Rationale**: The shared labels "Confirmada" and "Cancelada" agree with "entrada" and "salida". "Conteo" is masculine. Transfers solved the same problem with their own masculine labels (`inventoryTransferStatusCancelled` "Cancelado").
- **Alternatives considered**: A label parameter on `InventoryDocumentStatusChip`. Rejected as a change to shipped shared code that only one caller needs; the chip is ten lines.
- **Wireframe note**: the wireframes show "(Confirmada)" and "(Cancelada)" chips. They read "Confirmado" and "Cancelado" when built.

## R3. Writing lines

The server has no single-line create. Its line routes are:
- `PUT /{id}/lines`: a batch of 1–2,000 items, each with exactly one of `product` (id) or `product_code`, and a `quantity` of at least 0 with up to 4 decimals. It is applied whole or not at all, and each product's quantity is replaced.
- `PUT /{id}/lines/{line_id}` with `{quantity}`.
- `DELETE /{id}/lines/{line_id}`.

Every line route returns the whole count with all its lines.

- **Decision**: The repository has `setLines(id, List<CountLineInput>)`, `updateLine` and `removeLine`. `CountLineInput` is a product id or a code, plus a quantity.
  - Agregar producto sends one item with the product id.
  - Quick entry sends one item with the typed code.
  - Pegar lista sends batches of up to 2,000 items with codes.
  - The ✎ dialog uses `updateLine`, and 🗑 uses `removeLine`.

  Each response replaces the detail state, as in 068 (FR-017).
- **Rationale**: The batch route is the only way to add, and it already replaces and validates (FR-009, FR-011).

## R4. Large counts and full responses

- **Fact**: Each line write returns every line. On a 15,000-line opening count, each quick entry and each paste batch brings back about 15,000 lines.
- **Decision**: Accept it for now.
  - Quick entry on a count that size is not the expected use: opening counts are pasted.
  - During a paste, each batch's response replaces the state. Only the last one is rendered, because the dialog covers the screen until it finishes.
  - quickstart step 9 measures one write on a pasted 15,000-line count. If it takes more than about 2 s, the follow-up is an mbe-api request for a lighter line-write response. Per §III, that would be filed, not patched.
- **Alternatives considered**: Re-fetching only the changed line. Not possible: there is no single-line GET.

## R5. Showing thousands of lines

- **Decision**: Page the lines in memory, 100 per page, with `CatalogPagination` through `CatalogPage`, following `lib/features/auth/presentation/admin/privileges_grid.dart` (the one existing in-memory pager). A `CatalogSearchBar` above the table filters the loaded lines by code or name, case-insensitively, before paging. Changing the search returns to page 1. A write keeps the current page when it still exists (FR-011a, wireframe question 3).
- **Rationale**: `DataTableView` with `shrinkWrap` (as 068 uses it) builds every row. 15,000 rows would freeze the screen. Paging keeps 068's table look.
- **Alternatives considered**: One lazily built scrolling table. Rejected: it would change the table pattern the other Inventario screens share, and would need a scroll-aware `DataTableView`.

## R6. Quick entry

- **Decision**: Two `TextField`s (code and quantity) and a button, in a `_QuickEntryRow` in the detail screen. The code is sent exactly as typed or scanned (trimmed) as `product_code`, with no client lookup. The server matches codes case-insensitively.
  - Enter in Código moves focus to Cantidad.
  - Enter in Cantidad submits. On success both fields clear and focus returns to Código. On a refusal the values stay, and the localized error shows under the row (US3 #2).
  - Before the write, the row looks up the code in the loaded lines, case-insensitively. After the write, the feedback line reads "{code} {name}: {old} → {new} (reemplazada)" when the product was already counted, and "{code} {name}: {new}" otherwise (FR-009, wireframe questions 1–2).
- **Rationale**: Scanners are keyboard-wedge devices that type an exact code and Enter (the same finding as the POS `ProductSearchField`, spec 038 research §7). The product picker already covers search by name. Reusing `ProductSearchField` would pull a POS widget out of `features/sales/` for a behaviour (search) the row does not need.
- **Alternatives considered**: Asking before replacing. Rejected: it stops a scanner run. The Agregar producto dialog does warn beforehand, because it is not a scanning flow.

## R7. Paste parsing

- **Decision**: A pure function `parseCountPaste(String text) → CountPaste`, in `domain/count_paste.dart`, unit-tested on its own.
  - Rows are split on line breaks. Blank rows are skipped but still counted for row numbers. Row numbers are 1-based.
  - The separator for each row is the first of tab, then `;`, then `,` that it contains. The row must have exactly two fields after trimming.
  - Quantity: with a tab or `;` separator, a single `,` is read as the decimal point. With a `,` separator, only `.` is a decimal point. Thousands separators are not accepted.
  - A row is a problem when its code is empty, its quantity is not a number, is negative or has more than 4 decimals, or it has the wrong number of fields. Each problem keeps its row number and a reason enum.
  - A code repeated in the paste, compared case-insensitively as the server compares, is a problem on every repeat after the first.
  - `CountPaste` holds the good rows (row number, code, quantity as a decimal string) and the problems. Enviar is enabled only when there are good rows and no problems (FR-011c).
- **Rationale**: Spanish-locale spreadsheets copy cells with a tab and decimals with a comma ("4,5"). A comma-separated row with a decimal comma (`A-100,4,5`) has three fields, so it is reported, not guessed (wireframe question 4). Checking everything before sending means a paste never fails halfway because of formatting.

## R8. Sending a paste in batches

- **Decision**: The `CountPasteSender` notifier is scoped to the dialog (auto-dispose). It sends the good rows in order, in chunks of 2,000, one at a time, and publishes the batch number and rows sent so far (FR-011d).
  - On success it pushes each response into the detail controller.
  - On a refusal it stops. For `inventory_count.batch_invalid`, each `ApiProblemPart` is mapped back to its row: `extra['index']` plus the batch offset gives the row. The part's code (`inventory_count_line.product_unknown`, `.not_stockable` or `.repeated`) gives the reason. The dialog lists "{code} {reason}" with the row number and says how many rows were applied (whole batches before the refused one).
  - Any other refusal (`lock.busy`, `document.not_editable`, …) stops with that error in the dialog's `FormErrorBanner` and the same applied count.
  - The dialog can't be dismissed while a batch is in flight (wireframe question 8). Closing it re-fetches the count.
- **Rationale**: `ApiProblemPart.extra` already keeps the batch's `index`, `product_code` and `reason` keys (`lib/core/errors/api_problem.dart`, written for this route). Because a line's quantity replaces the previous one, sending the corrected list again is safe, and the dialog says so.

## R9. Confirm and its warnings

- **Decision**: `confirm(id, includeUncounted)` returns the count plus `CountWarnings(negativeAvailable, correctedByOtherCounts)`, mapped from `InventoryCountConfirmResponse`.
  - The confirm dialog's checkbox is off by default (FR-012).
  - The warnings go into `CountConfirmNotice`, an auto-dispose provider family keyed by count id, the same pattern as 067's `ReceiptCostNotice` (`presentation/receipts/receipt_warnings.dart`). The detail screen shows them as a dismissible warning band above the lines. A re-fetch inside the screen keeps them. Leaving the count drops them, as the spec's assumption says (FR-013, wireframe question 5).
  - `negative_available` rows show the product code with counted, reserved and available quantities. `corrected_by_other_counts` rows show the product code and "conteo {serial}" as plain text (wireframe question 6). `serial` is nullable. When it is null the row shows "Borrador #{id}"; this should not happen, since the other count is confirmed.
- **Rationale**: The server returns the warnings only in the confirm response and stores nothing.

## R10. Error codes (§III coverage)

The count routes can return these codes (from the service and `inventory_documents.py`):

| Code | Localized today? |
|---|---|
| `inventory_count.batch_invalid` | No: **new** |
| `inventory_count.confirmed_cannot_cancel` | No: **new** |
| `inventory_count_line.product_unknown` | No: **new** |
| `inventory_count_line.not_stockable` | No: **new** |
| `inventory_count_line.repeated` | No: **new** |
| `inventory_count_line.product_reference` | No: **new** (the UI always sends exactly one reference, so it can't trigger this) |
| `inventory_document.no_lines`, `inventory_document.already_cancelled` | Yes (067) |
| `document.not_editable`, `facility.other_facility` | Yes |
| `warehouse.in_transit_location`, `lock.busy` | Yes |
| `resource.not_found` (resource `inventory_count`) | Code yes; the resource noun `inventory_count` **new** |

- **Decision**: Add the six codes to `localizedErrorCodes`, the `localizeProblem` switch and both ARBs. Add `apiResourceInventoryCount` ("conteo", plural "conteos") and its masculine gender entry to the resource switches in `lib/core/errors/localize_problem.dart`. `catalog_coverage_test.dart` then covers them. The exact text is in [contracts/error-messages.md](contracts/error-messages.md).

## R11. Navigation, route and rights

- **Decision**:
  - `NavBranch.inventoryCounts = 33`, the fourth child of the `inventory` group, after transfers.
  - Label `navInventoryCounts` "Conteos físicos".
  - List route `/inventory/counts` (shell branch) and detail route `/inventory/counts/:id`, with a `_routeGate` clause on `SystemObject.physicalCountAdjustment` (74, already defined and unused).
  - Actions are gated with `access.can(physicalCountAdjustment, …)`: create for Nuevo conteo; update for header, lines, quick entry, paste and confirm; delete for cancel, on a draft only.
  - System object 93 (`InventoryAdjustments`) is not used (FR-020).

## R12. Names on list rows and the header

- **Fact**: `InventoryCountSummary` and `InventoryCountResponse` carry only ids for the warehouse, facility, creator and updater. Issue summaries carry server-joined names.
- **Decision**: Pass `name: null` to the shared name cells, which already fall back to the cached display-name providers by id. No mbe-api change is needed. The names are right after one lookup per distinct id; asking mbe-api to add them would only save those lookups.

## R13. Small decisions from the wireframes

- **"Partidas" fact**: the header shows the line count (`lines.length`). Kept (wireframe question 7).
- **Cancelled title**: a count can only be cancelled as a draft, so it never has a folio, and the title stays "Conteo · Borrador #{id}" (FR-004a).
- **Esperado and Diferencia**: shown only when the count is completed. On a draft the server returns nulls anyway (SC-003). Diferencia is a signed quantity through `fmt.display.quantity`, with "+" for positive values, as plain text with no colour.
- **Compact tier**: no compact-specific work, as in 067–069 (§VI defers it).
