# Research: Purchase Requests with Approval (079)

Sources: mbe-api `docs/specs/05-purchases.md` §1–2, `specs/031-purchase-requests-orders/` (spec, contracts/purchasing.md), `app/services/purchase_request_service.py`, and the generated client under `lib/generated/openapi/` (`PurchaseRequestsApi`). mbe-ui precedents: warehouse receipts (spec 067, `lib/features/inventory/presentation/receipts/`), the shared inventory parts from spec 068 (`lib/features/inventory/presentation/shared/`), delivery order approval (spec 062) and advanced product search (spec 038) for the checkbox column.

## R1. Where the feature lives

- **Decision**: `lib/features/purchases/`. Routes `/purchases/requests`, `/purchases/requests/:requestId` and `/purchases/request-approval`.
- **Rationale**: Purchasing is its own business area (roadmap epic #7). Purchase orders, supplier payments and accounts payable (#71, #75, #80) will join it. Routes mirror folders (Technology Stack). `/purchases/request-approval` does not start with `/purchases/requests`, so the two `_routeGate` prefixes cannot shadow each other.
- **Alternatives**: `lib/features/inventory/`. Rejected: requests are not stock documents, and the server keeps them out of the inventory document mechanics.

## R2. Navigation

- **Decision**: A new `NavGroup(id: 'purchases', label: 'Compras')` placed in `kNavigationTree` between Inventario and Finanzas, with two destinations:
  - Solicitudes de compra: `NavBranch.purchaseRequests = 38`, gate `PrivilegeGate(SystemObject.purchaseRequest, AccessRight.read)`, icon `Icons.assignment_outlined` / `Icons.assignment`.
  - Aprobación de solicitudes: `NavBranch.purchaseRequestApproval = 39`, gate `PrivilegeGate(SystemObject.purchaseRequestApproval, AccessRight.read)`, icon `Icons.fact_check_outlined` / `Icons.fact_check`.
- Branch indexes are appended after commissions (37), because they are positional in the `StatefulShellRoute`. The detail is a top-level `GoRoute` outside the shell, as receipts do, gated by the `/purchases/requests` prefix (read on 86).
- **Rationale**: Spec assumption. Proveedores stays in Inventario, where it already is.

## R3. Record surface

- **Decision**: A full detail screen, as in 067. The list row tap opens it. No row Edit icon and no View toggle. A draft is edited in place: a header dialog, line dialogs, and ✎/🗑 on draft line rows. The AppBar has no actions; every action is in the body's action area.
- **Rationale**: A request owns lines (§VI criterion 1) and has a status lifecycle where only a draft is editable. This is the document reading recorded in specs 056, 057, 060, 061, 066 and 067.

## R4. Names for ids

- **Decision**: The summaries and responses carry ids only (`warehouse`, `facility`, `creator`, `approver`). Names come from the cached per-id `warehouseDisplayNameProvider`, `facilityDisplayNameProvider` and `employeeDisplayNameProvider`, through the name cells of `inventory/presentation/shared/inventory_name_cells.dart` (`InventoryWarehouseName`, `InventoryFacilityName`, `InventoryEmployeeName`). They show `…` while loading and `#id` when the lookup fails, for example without read on employees.
- **Rationale**: Wireframe Open Question 1. The lookups exist and are cached, so a page of 20 rows costs at most a few dozen cached GETs, most of them repeats. No mbe-api change is needed.
- **Alternatives**: Ask mbe-api for joined names, as #324–#330 did for inventory documents. Not blocking; worth asking if the list feels slow in the walkthrough.

## R5. Reusing inventory's shared parts

- **Decision**: Import `inventory_name_cells.dart` and `inventory_warehouse_options.dart` (`inventoryWarehouseScopeProvider`, `inventoryStartingWarehouseProvider`, `inventoryWarehouseOptions`) from `lib/features/inventory/presentation/shared/` directly.
- **Rationale**: Both do exactly what this feature needs (names for ids; the own-facility warehouse scope and the starting point-of-sale warehouse). Copying them duplicates ~200 lines. Moving them to `catalog` touches 23 files of shipped code for no behaviour change (CLAUDE.md: surgical changes).
- **Cost**: This is the first import of one feature's presentation from another. §I does not forbid it (it constrains presentation → data and shared entities), but it couples the two features. When a third feature needs these parts, move them to `lib/features/catalog/presentation/` in their own change.

## R6. Creating a request and the pickers

- **Create**: A "Nueva solicitud" `FilledButton.icon` in the list's `CatalogFilterBar.actions`, gated on create on 86 and read on warehouses (4). It opens `new_request_dialog` (warehouse plus notes), sends `POST /purchase-requests`, and `context.push`es the new request's detail (the 067 pattern).
- **Header warehouse (Nueva solicitud, Editar encabezado)**: `CatalogEntityPicker<Warehouse>` over `inventoryWarehouseOptions`, scoped by `inventoryWarehouseScopeProvider`: every warehouse for an administrator, the user's facility for anyone else, none (with the "no sucursal" note) for a non-administrator without a facility. The starting value is `inventoryStartingWarehouseProvider` (FR-006, FR-008).
- **Line destination (Editar partida)**: the same picker with no facility scope, for everyone (FR-014).
- **List filter warehouse**: the same unscoped picker.
- **Product (Agregar producto)**: `CatalogEntityPicker<ProductListItem>` over `productRepositoryProvider.list(search:, status: EntityStatus.active, purchasable: true, limit: 10)`. `ProductRepository.list` already takes `purchasable`. Needs read on products.
- **Agregar producto asks for the product only** (wireframe Open Question 9): the server sets the line's name, its quantity (the minimum order quantity, or 1) and its destination (FR-011). `ProductListItem` has no minimum order quantity, so the dialog could not prefill it without another GET. The user edits the new line with ✎ when the default is wrong.
- **Quantity**: entered through `fmt.field.quantity` / `parseQuantity`, validated as greater than 0 with at most 2 decimals (FR-012), sent as `Quantity6` with the setter pattern every feature uses (`AnyOf2<String, num>(values: {0: value.toString()})`). The live test confirms the wire value (quickstart step 3).

## R7. Minimum-quantity warning (FR-013)

- **Decision**: A pure domain function `belowMinimum(lines)` returns one `BelowMinimum{productCode, quantity, minimum}` per line with `minOrderQty > 1 && quantity < minOrderQty`. This is exactly the server's `below_minimum_warning` rule: a minimum of 0 or 1 never warns.
- It shows in a warning band on the detail for draft, submitted and approved requests (not cancelled), after load and after every line save, and it is repeated in the submit prompt. It never blocks. The band copies the look of `ReceiptOverReceiptBand` (`tertiaryContainer`, `warning_amber`) as a feature-local widget, since there is still no shared warning banner (wireframe Open Question 6).
- **Rationale**: The server's `warnings` are English strings with no code (`BuiltList<String>` here). §III forbids showing them. The figures are on the lines.
- **Exit**: If mbe-api codes these warnings (as #322 did for receipts), map the code and drop the function.

## R8. Clearing the notes

- **Decision**: Same risk and decision as 067 R8: `PurchaseRequestUpdate.comment` is optional and the server applies `exclude_unset`. Send the generated PUT; when the user clears the notes, send `""`. The quickstart checks it (step 4). If the generated client drops `""`, fall back to a raw `dio.put` with `{"comment": null}`.
- **Header warehouse**: sent only when it changed.

## R9. List

- **Facets**: state (Borrador, Enviada, Aprobada, Cancelada → `draft`, `submitted`, `approved`, `cancelled`), facility, warehouse, requester (employee picker, needs read on employees), date range (`from`/`to`). Folio search uses the `serial` query param through the `CatalogFilterBar` search slot, numeric only.
- **Scope switch** (wireframe Open Question 3): a `SegmentedButton` "Mis solicitudes | Todas" in the filter bar, sent as `all=true` for Todas. It is not counted in the filter badge. All of it lives in the URL query (`ListQuery`).
- **Columns**: Folio (`serial`, or "Borrador #{id}" when null), Sucursal, Almacén, Estado (chip), Solicitó, Fecha, Partidas (`lineCount`, right-aligned). Newest first is the server's order. Page size 20.
- **Folios repeat across facilities** (wireframe Open Question 10): Sucursal sits next to Folio. The folio search may return several rows, one per facility.
- **Default excludes cancelled**: the server does this. Choosing Cancelada in the state facet shows them (quickstart step 9 checks the server honours it in the default scope).

## R10. Approval queue and bulk approve

- **Table**: `DataTableView<PurchaseRequestSummary>` in the server's order (oldest first), columns Folio, Sucursal, Almacén, Solicitó, Fecha, Partidas, Notas (truncated, tooltip). No Estado column; every row is Enviada.
- **Filter row**: `CatalogFilterBar` with no search, an inline facility picker (needs read on facilities), and the "Aprobar seleccionadas (n)" button (update on 96; disabled while nothing is selected).
- **Selection** (wireframe Open Question 2): a leading checkbox column built by this screen with the existing `DataTableColumn` API: `fixedWidth: 48`, `header` a tristate `Checkbox` that selects or clears the page, and each cell a `Checkbox`. This is the advanced-search pattern (spec 038, `advanced_search_screen.dart`), so `DataTableView` does not change. The selection is a `Set<int>` in a screen-scoped notifier, **per page**: it clears on page change, filter change and after any approval. With pages of 20, the server's 100-id limit is never reached; the action still guards it.
- **Row ✓ "Aprobar"**: `buildCatalogRowActions(primaryAction: …)`, update on 96. It opens the same approve prompt as the detail. No row ✕: rejecting needs the detail (Clarification 1).
- **Row tap**: pushes the detail only when `can(purchaseRequest, read)`; otherwise rows don't respond (Clarification 1).
- **Bulk result**: `POST /purchase-requests/approve` returns one result per id. Refused results carry `code` and `params`, built into an `ApiProblem` and localized with `localizeProblem`. All approved: a SnackBar "Se aprobaron {n} solicitudes." Any refused: a `ResponsiveDialog` with "Se aprobaron {a} de {n} solicitudes." and each refused folio with its facility and reason. The folio and facility come from the page's summaries, kept by id before the call. Then the queue reloads.

## R11. Detail actions

- **Submit**: prompt (FilledButton "Enviar"); the text says the request gets its folio, or "Volverá a aprobación con el folio {serial}" when it already has one; it repeats the minimum warnings.
- **Approve**: prompt naming folio, facility, warehouse and line count.
- **Reject**: `ResponsiveDialog` with a multi-line reason, `maxLength` 500, "Rechazar" disabled while the trimmed reason is empty. The note says the request returns to draft keeping its folio. It does not promise the requester sees the reason (mbe-api#352).
- **Cancel**: prompt "Cancelar la solicitud {folio}" or "Cancelar el borrador".
- **Mark line**: a `Checkbox` cell, interactive with update on 20 and the request submitted or approved. A tap sends `PUT …/to-purchase` and disables that checkbox until the response, then shows the server's request. No prompt; it is reversible (wireframe Open Question 4).
- **After any decision on the detail**: the detail shows the server's response, and the list and queue providers are invalidated. Back returns to where the user came from.

## R12. Requests of another facility (wireframe Open Question 5)

- **Decision**: For a non-administrator, Editar encabezado, Agregar producto, line ✎/🗑, Enviar and Cancelar are **absent** when the request's facility is known and differs from the user's `UserSettings.facilityId`. Approve, reject and line marking stay, because the server does not limit them by facility. The server's `facility.other_facility` refusal is still localized and shown for any case the UI can't see coming (for example a null facility).
- **Rationale**: §IV and FR-025 say actions the user cannot perform are absent, never shown to fail. The UI has both facilities in hand, so this costs one comparison. Spec FR-026 is updated to say so.
- **Alternatives**: Show them and let the server refuse (the spec's first wording). Rejected: every tap is a guaranteed refusal.

## R13. Error handling and coverage

- **Decision**: The repository maps `DioException` to `AppError` (`mapDioException`). Actions return `AppError?` and the dialogs and detail show it through `ErrorBanner`/`FormErrorBanner`. 11 codes are new; see [contracts/error-messages.md](contracts/error-messages.md).
- **Stale refusals**: `purchase_request.not_draft`, `.not_submitted`, `.already_cancelled`, `.lines_not_markable`, `.warehouse_facility_changed` and `lock.busy` make the detail re-fetch, and the queue reload, which covers the concurrent-decision edge cases.

## R14. Tests and live verification

- **Unit** (`test/unit/features/purchases/`): repository impl (DTO mapping, quantity wire value, status mapping, bulk results), `belowMinimum`, list filter ↔ `ListQuery`, list/detail/queue controllers, actions (invalidations, stale refresh), action availability (rights × state × facility), the queue selection notifier. Fixture builders in `purchase_request_fixtures.dart`. mocktail mocks, as in 067.
- **Widget** (`test/widget/features/purchases/`): list, detail per state, queue (selection, rights variants, bulk result), every dialog, the warning band, the status chip, large text. A `purchases_harness.dart` modelled on `inventory_harness.dart`.
- **Live** (`test/integration/purchase_requests_live_test.dart`): finds at run time a purchasable product with `min_order_qty > 1` and a non-transit warehouse of the POS user's facility. With `MBE_WRITE=true`: create, add lines, submit, approve, reject+resubmit (same serial), bulk approve with one stale id, mark/unmark, cancel. The admin account (`MBE_POS_*`) holds 86, 96 and 20.
- **Device** (`integration_test/purchase_requests_quickstart_test.dart`): the quickstart walkthrough on macOS.
- **Codegen and nav**: `nav_destinations_test.dart` and `app_router_test.dart` gain the two branches; `catalog_coverage_test.dart` covers the 11 new codes.
