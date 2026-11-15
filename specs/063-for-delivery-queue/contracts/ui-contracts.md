# UI Contracts: For Delivery Queue

**Spec**: [spec.md](../spec.md) | **Data model**: [data-model.md](../data-model.md) | **Wireframes**: [wireframes.md](../wireframes.md)

## C1. Navigation and route

- `NavBranch.forDelivery = 28`, appended last.
- `NavDestination(id: 'for-delivery', route: '/sales/for-delivery', gate: PrivilegeGate(SystemObject.forDeliver, AccessRight.read))` in the Logística group, right after `delivery-order-approval`. Label "Por entregar" / "For delivery".
- `app_router.dart`: a `StatefulShellBranch` with `GoRoute(path: forDeliveryPath, builder: … PendingDeliveriesScreen(query: ListQuery.fromUri(state.uri)))`, and a `_routeGate` clause `startsWith(forDeliveryPath)` → the same gate.
- Without 91 read: no nav entry, and the route redirects as every gated route does (FR-001, SC-004).

## C2. Screen layout

`PendingDeliveriesScreen` is a filter row, a list and pagination (§VI).

- **Filter row**: `CatalogFilterBar(search: null, filters: [badged filters button])`. The button is `Badge.count(count: filter.activeFilterCount)` over `IconButton.outlined(Icons.tune)`, key `for_delivery_filter_button`, opening C3 (FR-011).
- **List**: `CatalogListStateView<PendingDeliveryLine>` → `DataTableView<PendingDeliveryLine>`, key `for_delivery_table` (C4).
- **Pagination**: `CatalogPagination` over `view.page`, page changes through `context.go` with the filter's query.

## C3. Filter panel

`showCatalogFilterSheet(title: Filtros, onClearAll: go to the default filter's path)`, builder `CurrentListQueryBuilder` → `_PendingDeliveriesFiltersPanel`.

- One `DropdownButtonFormField<PendingDeliveryPeriod>`, key `for_delivery_period_filter`, label "Periodo", wrapped in `KeyedSubtree(ValueKey(period))`.
- Six items, display order, no "all" item. Item text:
  - single-day period: `{label} · {date} ({total})`
  - `earlier` / `later`: `{label} ({total})`
  - counts and dates come from `LastPendingDeliverySummaries` (C7), the six summaries of the last successful load, so they stay visible while a newly picked period loads; labels only until the first load succeeds.
- Selecting goes to page 0 with the new period (FR-007). Selecting `today` drops the facet.
- "Borrar todo" goes to the default filter (FR-011).

## C4. Table columns

| # | Header (es) | Content | Align | Compact |
|---|---|---|---|---|
| 1 | Folio | `serial`, or placeholder | left | card line 1 |
| 2 | Cliente | `DeliveryOrderCustomerName` | left, truncated | card line 1 |
| 3 | Destino | `DeliveryOrderCustomerAddress` | left, truncated | dropped |
| 4 | Programada | `display.date(scheduledDate)` or "Sin fecha" | left | card line 3 |
| 5 | Prio. | `priority` | right | card line 1 |
| 6 | Producto | `"{code} {name}"` | left, truncated | card line 2 |
| 7 | Almacén | warehouse name cell (R7) | left | card line 3 |
| 8 | Pendiente | `display.quantity(openQuantity)` | right | card line 3 |

- Rows in the server's order (FR-004). No action column (FR-010).
- `onRowTap`: only with `can(deliveryOrders, read)`; pushes `'$deliveryOrdersPath/$deliveryOrderId'` and on return invalidates the controller for the current key (FR-008, FR-009, R6).

## C5. States

| State | Rendering |
|---|---|
| Loading | `CatalogListStateView` loading |
| Error | `CatalogListStateView` error, message from the problem code, "Reintentar" invalidates (FR-012, FR-013) |
| Empty, period = Hoy | empty message "No hay entregas pendientes para este periodo.", no button |
| Empty, other period | the shared filtered-empty state (`isFiltered: true`: "No se encontraron coincidencias", "Intenta ajustar o borrar tus filtros") with its clear-filters button to the default filter |
| Populated | C4 |

## C6. Repository

```text
abstract class DeliveryItineraryRepository {
  Future<PendingDeliveriesResult> pendingDeliveries({required int skip, required int limit});
}
```

Provider `deliveryItineraryRepositoryProvider`. Maps R1's response to data-model §1–3; propagates `DioException` like the other repositories.

## C7. Controller

`@riverpod class PendingDeliveriesController` — `build(PendingDeliveryPeriod period, int pageIndex)` → `Future<PendingDeliveriesView>`, page size 20, via `fetchClampedPage` (R4). Doc comment states there is no facility guard and why. After a successful load it writes the view's six summaries to `LastPendingDeliverySummaries`.

`@Riverpod(keepAlive: true) class LastPendingDeliverySummaries` — state `List<PendingDeliveryPeriodSummary>?`, `null` until the first successful load; a `set(summaries)` method. Feeds the panel counts (C3, R5).

## C8. Name-cell extraction

`delivery_order_name_cells.dart`: new public `DeliveryOrderCustomerAddress({customerId, shipToId, truncate = true})` holding what is now `DeliveryOrderShipTo`'s delivery branch. `DeliveryOrderShipTo` calls it. No visible change on spec 061/062 screens; their existing tests are the guard.

## C9. Localization

New keys in both `.arb` files: nav label, screen title, period label, the six period names, "Sin fecha", empty message, column headers not already shared with spec 061 (Programada, Prio., Producto, Almacén, Pendiente where missing).
