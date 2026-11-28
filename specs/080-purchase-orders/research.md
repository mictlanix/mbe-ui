# Research: Purchase Orders with Receipts, PDF and Email (080)

Sources: mbe-api `docs/specs/05-purchases.md` §3–4, `app/api/v1/endpoints/purchase_orders.py`, `app/services/purchase_order_service.py`, `app/schemas/purchases.py`, and the generated `PurchaseOrdersApi`. mbe-ui precedents: purchase requests (spec 079, `lib/features/purchases/`), warehouse receipts (spec 067), document printing (spec 044, `lib/core/documents/`), quote email (`lib/features/sales/presentation/quotes/quote_email_*`), and the cross-record links in `refund_detail_screen.dart` (`_OrderLink`) and `delivery_order_detail_screen.dart` (`_Links`).

## R1. Placement, routes and navigation

- **Decision**: `lib/features/purchases/`, next to the requests. New folders `presentation/orders/` and `presentation/to_purchase/`. Routes `/purchases/orders`, `/purchases/orders/:orderId` and `/purchases/to-purchase`.
- **Nav**: two destinations in the existing Compras group, after Aprobación de solicitudes, in workflow order: **Por comprar** (`NavBranch.toPurchase = 40`, `Icons.shopping_cart_outlined` / `Icons.shopping_cart`) then **Órdenes de compra** (`NavBranch.purchaseOrders = 41`, `Icons.receipt_long_outlined` / `Icons.receipt_long`). Both gated `PrivilegeGate(SystemObject.purchasesOrders, AccessRight.read)`. Branch indexes are positional, so both are appended after 39 in the shell and in `NavBranch`.
- **Detail**: a top-level `GoRoute` outside the shell, like requests and receipts. `_routeGate` gets one clause for each prefix (`/purchases/orders`, `/purchases/to-purchase`), neither a prefix of `/purchases/requests`.

## R2. Record surface

- **Decision**: A full detail screen (§VI: owns lines and linked receipts, needs a URL). The list row opens it; no row Edit icon, no View toggle. A draft is edited in place through a header dialog and line dialogs, with ✎ 🗑 on draft line rows. The AppBar has no actions.
- **Rationale**: The document reading recorded in specs 056–067 and 079 (Complexity Tracking). The wireframe's ✎ on draft list rows is dropped to match 079.

## R3. Names for ids

- Summary rows carry `supplier_name` (shown as is) and `creator` (id) → `InventoryEmployeeName`. Lines carry `warehouse` → `InventoryWarehouseName`. Groups and receipts carry `facility` → `InventoryFacilityName`; groups carry `supplier_name`. Same imports from `inventory/presentation/shared/` as 079 R5; no new coupling.

## R4. Status

- **Decision**: The wire value is `DocumentStatus` (`draft`/`completed`/`cancelled`), the same as receipts. Map it to the existing `InventoryDocumentStatus` and render with `InventoryDocumentStatusChip`: Borrador / Confirmada / Cancelada (wireframe Open Question 4). 079 already maps order status this way (`_orderStatus` in the request repository).
- **Rationale**: Same values, same labels, already feminine-agreeing with "orden". No new chip.

## R5. Por comprar (FR-007–FR-009, FR-031)

- **Layout**: `CatalogFilterBar` with no search (the endpoint has none, §VI says omit it). Its actions slot holds the badged filters button, "Actualizar" and the filled "Crear orden". Below it, one card per group: a leading `Radio` (only on a group with a supplier), the supplier name (or "Sin proveedor"), facility, line count and estimated total (money). The card expands to a `DataTableView<ToPurchaseLine>` with Solicitud (serial), Código, Producto, Cantidad, Almacén, Costo ("sin costo" when 0). Then `CatalogPagination`.
- **Filter**: the drawer has one facet, Sucursal (`CatalogEntityPicker` over facilities, needs read on facilities), sent as `facility`. Without that right the filters button is left out. The facet and the page live in the URL (`ListQuery`).
- **Pagination** (changed after `/speckit-analyze`, finding C2): §VI requires the shared pagination on a list that can grow without limit, and pending lines can. The endpoint returns every group at once, so the controller keeps the full response and the screen shows 20 groups per page with `CatalogPagination`, page clamped like the other lists. When mictlanix/mbe-api#354 ships, the paging moves to the server. Search and a supplier facet are not built client-side (FR-031).
- **Crear orden** (changed after `/speckit-analyze`, finding C1; wireframe Open Question 3): §VI makes create a toolbar-only action, so there is one "Crear orden" in the filter row, create on 20. It acts on the selected group: a screen-scoped selection (supplier id, facility id) set by the group's radio or a tap on its header row. A "Sin proveedor" group has no radio. The button is present with the right and disabled while nothing is selected (state, not rights: the "Aprobar seleccionadas" precedent from 079). The selection clears on page change, filter change and after any create.
- **After Crear orden**: `POST /to-purchase {supplier, facility}`, then `context.push` the new order, a SnackBar "Orden {id} creada con {n} partidas." plus " {k} partidas ya estaban en otra orden." when `skipped` is not empty (FR-018), and Por comprar is invalidated (FR-009). Back returns to a fresh Por comprar.
- **Expanded state**: each group starts collapsed; with one group on the page, it starts expanded and selected.
- **Alternatives**: a "Crear orden" button in each group header (the first design). Rejected by §VI: create is never a row action.

## R6. Creating an order by hand

- "Nueva orden" `FilledButton.icon` in the list's filter row, create on 20 plus read on suppliers. A `ResponsiveDialog` with supplier (required), estimated receipt date (optional, `showDatePicker` with `firstDate` today) and notes (`maxLength` 500). `POST /purchase-orders`, then push the detail.
- **Supplier picker**: `CatalogEntityPicker<SupplierListItem>` over `supplierRepositoryProvider.list(search:)`, display `'{code} — {name}'`, as products and pricing do.
- **Supplier is always set**: create requires it and an update cannot clear it (wireframe Open Question 7), so FR-021's supplier check is a server guard only; the `purchase_order.no_supplier` message is still localized.

## R7. Header edits and clearing

- `PUT /purchase-orders/{id}` applies `model_dump(exclude_unset=True)`, so an explicit `null` clears. Send `supplier` only when changed. Clearing notes sends `comment: ""` (079 R8); clearing the date needs an explicit `estimated_receipt_date: null`. If the generated serializer drops nulls, fall back to a raw `dio.put` with the JSON body (the 049 remove-logo precedent). The live test checks both (quickstart step 5).

## R8. Lines

- **Agregar producto**: product (`CatalogEntityPicker<ProductListItem>`, `purchasable: true`, as 079) **and quantity**, because `OrderLineAdd.quantity` is required. Warehouse, price and tax rate are left to the server's defaults (FR-014). Quantity prefilled 1.
- **Editar partida**: warehouse (`CatalogEntityPicker<Warehouse>`, unscoped, as 079's line destination), quantity (> 0, ≤ 4 decimals), unit price (≥ 0, ≤ 7 decimals, "antes de IVA"), tax rate. `PUT …/lines/{lineId}` sends only changed fields (the server drops `None`).
- **Tax rate** (wireframe Open Question 10): a dropdown of `{0, 0.08, 0.16} ∪ {line's current rate}`, ascending, labelled as percentages. These are the Mexican IVA rates; the line's own rate is always present so rendering never rewrites it. The sale-line picker (`SaleLineEditing.taxRateOptions`) uses a similar always-include-current rule.
- **Wire values**: quantity, price and tax rate are sent with the shared `AnyOf2<String, num>` setter pattern; responses are strings parsed to `Decimal`.
- **Display**: quantity through the quantity formatter, unit price through the app's single price formatter at the configured currency precision (implementation found no wider-precision formatter, and §V allows one formatting surface), amounts and totals as money (wireframe Open Question 6). The edit field shows full precision, and an untouched price is sent back unrounded.
- **Columns by state** (wireframe Open Question 9): draft shows Precio, IVA, Importe; confirmed shows Recibido and Pendiente instead of Precio and IVA ("—" when null, i.e. non-stockable). Cancelled shows the draft columns, read-only.
- **Request folio** (FR-016): a line carries its request's **id** (`purchase_request`), not its folio, and users know requests by folio. Decision: a cached `purchaseRequestSerialProvider` (`FutureProvider.family<int?, int>` over `purchaseRequestRepository.get(id)`) resolves the folio, shown as "Sol. {serial}" after the product name, on its line (a table row has one fixed height; T035); `…` while loading, `#id` on failure (no read on 86). Lines from one request share the lookup, so an order costs one GET per distinct request.
- **Alternatives**: ask mbe-api to add the serial to the line. Not worth a server change while orders hold few distinct requests; fold it into mbe-api#353 if that issue is reopened for other reasons.

## R9. Adding a request's lines (FR-017, FR-018)

- "Agregar solicitud" opens a dialog with `CatalogEntityPicker<PurchaseRequestSummary>` over `purchaseRequestRepository.list(status: approved, all: true, serial: int.tryParse(search), skip: 0, limit: 10)`. Options read "{serial} · {facility} · {warehouse}" because folios repeat across facilities (079 Open Question 10). `POST /{id}/request-lines {purchase_request}`.
- Feedback: SnackBar "Se agregaron {n} partidas." with " {k} ya estaban en otra orden." when `skipped` is not empty. `n` = line count after minus before.

## R10. Warnings (FR-019)

- **Price 0**: a pure function `zeroPriceLines(lines)` returns the lines with `price == 0`. Shown in a warning band on a draft (one line per product: "{code} {name}: precio 0; no actualizará el costo.") and listed in the confirm prompt. Never blocks.
- **Band**: feature-local `OrderWarningsBand`, copying `RequestMinimumBand`'s look (`tertiaryContainer`, `warning_amber`). Wireframe Open Question 5: a fourth feature with a band is due for promotion, but promotion touches three shipped features; record it and leave it (Complexity Tracking).
- **Supplier mismatch and server warnings**: not shown. `warnings` (uncoded `List<String>`) are dropped. When mictlanix/mbe-api#353 ships: regenerate, map the codes, show the mismatch, and drop `zeroPriceLines` if the server's coded zero-price warning covers it.

## R11. Confirm and receipts (FR-021–FR-023)

- **Confirm prompt** (always, it is irreversible): supplier, line count, total, the destination warehouses ("Se crearán entradas en {warehouses}."), and the zero-priced lines if any. `POST /{id}/confirm`.
- **Receipts**: the confirm response's `receipts` are kept in the detail controller's state alongside the order and shown in an "Entradas" section: number (`RecordIdText`), `InventoryWarehouseName`, `InventoryFacilityName`, line count, and "Abrir" pushing `'$inventoryReceiptsPath/$id'` when the user has read on inventory receipts (15). A reload (`GET`) returns no receipts (FR-022), so the section is then absent and the UI does not look them up another way. When mictlanix/mbe-api#355 ships: the section shows on every load with an `InventoryDocumentStatusChip`.
- **After confirm**: SnackBar "Orden confirmada; se crearon {n} entradas." The list and Por comprar are invalidated.

## R12. Cancel

- "Cancelar orden" on a draft, delete on 20. Prompt: "La orden queda cancelada. Sus partidas de solicitud vuelven a Por comprar." `POST /{id}/cancel`. Invalidates the list and Por comprar.

## R13. Print (FR-026)

- Add `DocumentKind.purchaseOrder` (gate `SystemObject.purchasesOrders`, fallback filename `orden-compra-{id}.pdf`) and its arm in `document_source_impl.dart` calling `printPurchaseOrderDocumentApiV1PurchaseOrdersOrderIdDocumentGet`. "Imprimir" on a confirmed order calls `documentActionsProvider.preview(context, DocumentRef(kind: DocumentKind.purchaseOrder, recordId: id, title: 'Orden de compra {id}'))`.

## R14. Email (FR-027, FR-028; wireframe Open Question 11)

- **Decision**: A purchases-owned `PurchaseOrderEmailDialog` + `PurchaseOrderEmailController`, reusing the pure parts of `sales/domain/quote_email.dart` by import (`isPlausibleEmail`, `RecipientChip`, the 10-recipient limit) and copying the dialog's layout (chips, typed address, counter). It adds the message field (`maxLength` 1000).
- **Suggestions**: `supplierRepositoryProvider.get(supplierId:)` → `Supplier.contacts` with an email. Without read on suppliers, or when loading fails, no suggestions and a hint; typing still works.
- **Errors**: 502 `email.send_failed` and 503 `email.not_configured` are already localized; 409 `purchase_order.not_confirmed` is new. All go through `localizeProblem` into the dialog's `FormErrorBanner`, which keeps the input. Success: SnackBar "Orden enviada a {n} destinatarios."
- **Alternatives**: Generalize the quote dialog into `core/`. Rejected for now: it rewrites shipped sales code (its controller is a family on quote id, seeded from customer contacts and taxpayers, with a 409 stale-quote path). Promote when a third document needs email (Complexity Tracking).

## R15. List

- Filter row: `CatalogSearchBar` over the `id` query param (numeric), the badged filters button, "Nueva orden".
- Drawer facets: Mostrar ("Mis órdenes" default, "Todas" → `all=true`, counted in the badge, as 079 R9), Estado (Borrador, Confirmada, Cancelada → `draft`, `completed`, `cancelled`), Proveedor (supplier picker, read on suppliers), Creó (employee picker, read on employees), Fecha (`from`/`to`, the payments-filter date helpers as 079). All in `ListQuery`.
- Columns: Número, Proveedor (truncated), Estado (chip), Entrega, Creó, Fecha, Partidas, Total (money, never truncated). Page size 20, server order.

## R16. Links from existing screens (FR-030)

- A `PurchaseOrderLink(orderId)` widget in `purchases/presentation/orders/` renders a compact `TextButton` pushing `'$purchaseOrdersPath/$orderId'` when `can(purchasesOrders, read)`, else `RecordIdText`/`Text`. It copies the `_OrderLink` look (padding zero, shrink-wrapped).
- Used in the request detail line table (replacing the text at `purchase_request_detail_screen.dart` ~:667, next to its chip) and in the receipt detail fact (`inventory_receipt_detail_screen.dart` ~:464). The receipt screen then imports `purchases/presentation/` (Complexity Tracking).

## R17. Errors and stale state

- 9 new codes (all `purchase_order.*`), see [contracts/error-messages.md](contracts/error-messages.md). The rest are already localized.
- `purchase_order.already_cancelled`, `.confirmed_cannot_cancel`, `.not_confirmed`, `document.not_editable` and `lock.busy` make the detail re-fetch, covering concurrent confirm/cancel (spec edge case).

## R18. Tests

- **Unit** (`test/unit/features/purchases/`): order repository impl (mapping, wire values, `skipped`, `receipts`), `zeroPriceLines`, orders filter ↔ `ListQuery`, Por comprar filter, list/detail/Por comprar controllers, actions (invalidations, stale refresh, receipts kept after confirm), availability, email controller, tax-rate options. Fixtures in `purchase_order_fixtures.dart`.
- **Widget** (`test/widget/features/purchases/`): list, Por comprar (groups, no-supplier group, empty), detail per state (draft, confirmed with and without receipts, cancelled, read-only), every dialog, band, link widget (with and without right), large text. Reuse `purchases_harness.dart`.
- **Live** (`test/integration/purchase_orders_live_test.dart`): with `MBE_WRITE=true`, create by hand, add lines, edit, clear notes and date, add a request's lines, confirm (receipts returned), print bytes, email (when mail is configured, else expect 503), cancel a second draft and see its lines back in Por comprar, create from a Por comprar group. Discovers its fixtures at run time (an approved request with marked lines is made by the test through the 079 repository).
- **Device** (`integration_test/purchase_orders_quickstart_test.dart`): the quickstart walkthrough on macOS.
- **Shared**: `nav_destinations_test.dart` and `app_router_test.dart` gain branches 40/41; `catalog_coverage_test.dart` covers the 9 codes; the documents tests cover `DocumentKind.purchaseOrder`.
