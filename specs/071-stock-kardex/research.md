# Research: Stock and Kardex (071)

Sources:
- mbe-api `docs/specs/04-inventory.md` §6.
- mbe-api `app/api/v1/endpoints/stock.py` and `kardex.py`.
- mbe-api `app/services/stock_query_service.py`, `kardex_service.py` and `warehouse_service.assert_sellable`, and `app/core/error_codes.py`.
- The generated client: `StockApi`, `KardexApi`, `StockRow`, `ProductStock`, `InTransitStock`, `Kardex`, `KardexRow` and `KardexDocument`.
- In mbe-ui: the shipped Inventario feature (specs 067–070), `CatalogEntityPicker`, `CatalogFilterBar`, `DateRangeFilterChip`, `RecordFormActions` and the product detail screen.

## R1. Where the code goes

- **Decision**: All in `lib/features/inventory/`. The domain gets the stock and kardex entities and two repository interfaces (`StockRepository`, `KardexRepository`), and `data/` implements them over `StockApi` and `KardexApi`. Presentation gets `stock/` (Existencias and the product view) and `kardex/`.
- **Rationale**: No repository wraps `StockApi` or `KardexApi` today. The POS reads stock through a different endpoint (`salesOrderRepository.productLookupByIds` → `WarehouseStock` in `features/sales`), with a different shape and purpose. Reusing it would tie inventory to a sales endpoint for no gain.
- **Alternatives considered**: putting the stock repository in a shared kernel (`core/` or `catalog/`) for the POS to adopt later. That was rejected because nothing else uses these routes yet; move it when a second feature needs it.

## R2. Required selections: filter sheet, plus a facts strip

- **Fact**: All 27 shipped lists put their pickers in the filter sheet (`showCatalogFilterSheet`). None puts a `CatalogEntityPicker` inline in `CatalogFilterBar.filters`. The picker has no width parameter and fills its width. Inside the bar's `Row` it would get unbounded width, and would need a fixed width with no token for it.
- **Decision**: Follow the shipped pattern, against wireframe question 1's assumption.
  - **Existencias**: the warehouse picker lives in the filter sheet, beside the "Mostrar sin existencia" switch. The search stays inline as the bar's `search`.
  - **Kardex**: the product picker, the warehouse picker and the range all live in the filter sheet.
  - On both screens a `FactStripRow` above the table always shows the current selection (Almacén; or Producto · Almacén · Rango), so the required choice is never hidden.
  - With no selection, the empty state reads "Elige un almacén…" or "Elige un producto y un almacén…" and has a button that opens the sheet.
- **Rationale**: This keeps the one filter-sheet pattern every list uses and needs no new widget or size token. The facts strip answers the wireframe's concern that a required choice in a drawer reads as optional.
- **Alternatives considered**: inline pickers in a sized box. That would mean a new size token or a literal width (against §V), and a pattern no other list follows.

## R3. The kardex range chip

- **Fact**: `DateRangeFilterChip` takes `from`, `to`, `isToday`, `onChanged`, `onClear` and an optional `firstDate` (default: one year back). When `isToday` is true it always labels itself "Hoy", whatever the range. Pedidos passes a month range with that label.
- **Decision**: In the Kardex sheet, pass the real range with `isToday: false`, so the chip always shows the dates. `onClear` restores the default, the last 30 days ending today. Pass `firstDate` as far back as the ledger can go, a fixed `DateTime(2000)`, because a kardex often reads history older than a year. The 366-day limit is checked by the screen, not the picker.
- **Rationale**: No shared-widget change is needed (wireframe question 2). Labelling a 30-day range "Hoy" would be wrong.
- **Alternatives considered**: a configurable default label on the shared chip, rejected for one caller.

## R4. The range check

- **Decision**: Before any request, the screen checks that `to` is not before `from` and that the range spans at most 366 days, both ends inclusive, as the server counts it. When it fails, the screen shows the matching localized text and does not load (FR-009). If the server still answers with `kardex.range_reversed` or `kardex.range_too_long`, that error shows through the shared path.

## R5. Source labels and document links

- **Facts**:
  - `KardexRow.source_` is the transaction type number. `sourceName` is a snake_case English token, `TransactionType.name.lower()`, except type 10, which is `delivery_itinerary`.
  - The server resolves a document for the folio types 1, 2, 3, 4, 5 and 12; for type 8, the legacy count adjustment, which resolves to the **receipt it raised**; and for type 13, a delivery pickup, which resolves to the delivery order. It resolves the id only for types 6 (purchase order) and 10 (itinerary).
- **Decision**: One l10n label per source type, keyed on the number and never on `sourceName` (§III). Each row's link follows this table:

| Type | Label (es) | Opens | Gate |
|---|---|---|---|
| 1 | Pedido | `/sales/orders/{id}` (back-office order workspace) | SalesOrders read |
| 2 | Devolución | `/sales/refunds/{id}` | CustomerRefunds read |
| 3 | Salida de almacén | `/inventory/issues/{id}` | InventoryIssues (16) read |
| 4 | Entrada de almacén | `/inventory/receipts/{id}` | InventoryReceipts (15) read |
| 5 | Traspaso | `/inventory/transfers/{id}` | InventoryTransfers (17) read |
| 6 | Orden de compra | — (plain "#{id}") | — |
| 8 | Ajuste (sistema anterior) | `/inventory/receipts/{id}` (the receipt it raised) | InventoryReceipts (15) read |
| 10 | Itinerario de reparto | — (plain "#{id}") | — |
| 12 | Conteo físico | `/inventory/counts/{id}` | PhysicalCountAdjustment (74) read |
| 13 | Entrega en mostrador | `/sales/delivery-orders/{id}` | DeliveryOrders (71) read |
| other | Movimiento | — | — |

  - The Documento column shows the document's `serial` when present, otherwise "#{id}". A row with no `document` shows "#{reference}" when the reference is not 0, and "—" otherwise.
  - A linked row opens with `context.push` (back returns to the same kardex, whose state is in the URL).
- **Rationale**: Every linked route already exists and is gated by its own read right. Linking only when that right is held means a link never leads to a redirect (FR-011).
- **Note**: The back-office order workspace opens any order id. The own-orders limit applies only to the Pedidos list. The server decides whether the user may read it, and a refusal shows on that screen.

## R6. The product view

- **Decision**: A full screen at `/inventory/stock/products/:id`, under the read-67 gate (FR-006, FR-013).
  - The title is "Existencias · {code} {name}", using the product name from the catalog's product lookup by id, since `ProductStock` carries no name.
  - Warehouses: a `DataTableView` with Almacén, Sucursal, Existencia, Apartado, Disponible and Por recibir. `StockRow` carries only the warehouse id, so the view's controller resolves each distinct warehouse's facility once through the catalog `warehouseRepositoryProvider.get(id)`, whose `Warehouse` entity has the facility's id and name.
  - The one row action is "Ver kardex", via `buildCatalogRowActions(onEdit: null, extraActions: [...])`, shown only with read on 32. It pushes the Kardex page `/inventory/kardex/view?product=&warehouse=` with the default range (R14).
  - **Totals**: `DataTableView` has no footer row, so a `FactStripRow` above the table shows the four totals (wireframe question 3, option b). The totals are sums of the server's rows; the UI recomputes no per-row figure.
  - **En tránsito**: a short list of facility name (through `InventoryFacilityName`) and quantity, shown only when non-empty, as plain text (wireframe question 4).
  - Empty (no rows and no in-transit): "Este producto no tiene existencias en ningún almacén."

## R7. Existencias paging and URL state

- **Decision**: 50 per page (server maximum 500, wireframe question 6), in the server's order, which is by code. The warehouse, `q`, `include_zero` and page live in the URL through `ListQuery`, as the other lists do (FR-005). A search or switch change returns to page 1.
- **Starting warehouse**: when the URL has none, use the user's point-of-sale warehouse, with no facility restriction (stock has no facility scope), and write it into the URL. When the user has no point of sale, show the prompt (R2).

## R8. Kardex paging

- **Decision**: The kardex is not paged by the server, so rows are paged in memory, 100 per page, with `CatalogPagination` and `CatalogPage`. This follows the spec 070 count lines (`inventory_count_detail_screen.dart`) and `privileges_grid.dart`. Changing the selection returns to page 1.

## R9. "Ver existencias" on the product detail screen

- **Facts**: `RecordFormActions` renders only Delete, Edit and Save, in an end-aligned `Wrap`, and has no slot for another button. No screen puts a button beside it. The product detail screen has a read-only View mode (`?view=true`) and **no unsaved-changes guard**.
- **Decision**:
  - Add an optional `leading` list of widgets to `RecordFormActions`, rendered first in its `Wrap`. With null or empty, the widget behaves exactly as today.
  - The product detail screen passes an `OutlinedButton.icon` "Ver existencias" there. It shows whenever the screen's resulting mode is `RecordFormMode.view`, for an existing product, with read on 67 (FR-013a; wireframe question 8, answered "view only" because the screen has no guard that would protect unsaved edits). That mode covers both ways a product is read-only: `?view=true`, and a user without the products update right (`readOnly = (isEdit && !canUpdate) || forceReadOnly`, `product_detail_screen.dart`). Keying it on `forceReadOnly` alone would hide it from exactly the stock-only supervisors it is for.
  - It pushes `/inventory/stock/products/{id}`.
- **Rationale**: §VI places a shortcut to a related screen in the record's shared action area. Extending the shared component keeps that area built in one place. Building a local `Row` next to it would let the alignment drift from every other record screen.
- **Alternatives considered**:
  - A local `Wrap` around the button and `RecordFormActions`. Rejected because the alignment would drift.
  - A products-list row action. Rejected: the row already has Edit and pricing, the two-icon maximum (wireframe question 7).
- **Tests**: a `RecordFormActions` widget test for `leading` (rendered first; nothing rendered when null), and the existing record-form tests must pass unchanged.

## R10. Error codes (§III coverage)

| Code | Route | Localized today? |
|---|---|---|
| `kardex.range_reversed` | `GET /kardex` | No: **new** |
| `kardex.range_too_long` (`max_days`) | `GET /kardex` | No: **new** |
| `warehouse.in_transit_location` | `GET /stock` | Yes |
| `resource.not_found` (product, warehouse) | all three | Yes (the nouns exist) |
| `auth.forbidden` | all three | Yes |
| `request.*` | all three | Yes |

- **Decision**: Add the two kardex codes to `localizedErrorCodes`, the `localizeProblem` switch and both ARBs. Mark their rows in `specs/058-localized-api-errors/contracts/code-scope.tsv` as `IN`, which takes the coverage count from 163 to 165.

## R11. Navigation, routes and rights

- **Decision**:
  - `NavBranch.inventoryStock = 34` ("Existencias", gate 67 read) and `NavBranch.inventoryKardex = 35` ("Kardex", gate 32 read). They are the fifth and sixth children of the `inventory` group.
  - Routes: `/inventory/stock` (shell branch), `/inventory/stock/products/:id` (top-level) and `/inventory/kardex` (shell branch, with query `product`, `warehouse`, `from`, `to`), each with a `_routeGate` clause.
  - Nothing in these screens needs create, update or delete. Warehouse pickers need read on Warehouses (4), and the kardex product picker needs read on Products.

## R12. Products offered by the kardex picker

- **Decision**: `productRepository.list(search:, stockable: true, status: null, limit: 10)`, so the history of a discontinued product can still be read (spec assumption). The live test confirms that omitting `status` returns inactive products too. If it doesn't, the picker sends two queries (active and inactive) and merges them, with a `// simplified:` comment.

## R13. Timestamps

- **Decision**: `KardexApi` is constructed with `appSerializers`, as every repository is, so each row's `date` is read as wall-clock time (spec 043). Dates and times show through `formattersProvider`.

## R14. Opening the Kardex from the product view

- **Fact** (found by the macOS device test, 2026-11-17): the product view is a top-level route pushed over the Existencias tab. Pushing `/inventory/kardex`, a shell branch, on top of it puts a second `StatefulShellRoute` page on the root navigator. That trips `navigator.dart` `!keyReservation.contains(key)`, later `A GlobalKey was used multiple times` on the root navigator key, and every later navigation renders blank. The widget harness's simplified router can't show it, so the regression test lives in `test/unit/app/router/app_router_test.dart` with the real router.
- **Decision** (the user's choice): "Ver kardex" pushes a separate, top-level Kardex **page** at `/inventory/kardex/view`, with the same query as the tab. It is the same `KardexScreen` in a pushed mode: its own `AppBar` with a back arrow to the product view, and selection changes that `replace` the URL in place. The existing `/inventory/kardex` gate clause (32 read) covers it.
- **Alternatives considered**:
  - `go` to the Kardex tab. A one-line fix, but the product view closes and back no longer returns to it.
  - Moving the product view inside the Existencias tab. A larger routing change.
- **Cost**: one screen at two addresses, and the side nav doesn't highlight Kardex while the pushed page covers the shell.
