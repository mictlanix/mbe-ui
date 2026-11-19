# Contract: Repository, Actions, Controllers

## `DeliveryItineraryRepository` (`domain/repositories/delivery_itinerary_repository.dart`, extended)

The 063 `pendingDeliveries` method stays as it is. New methods follow. Each write returns the full `Itinerary` the server sends back.

| Method | Endpoint | Notes |
|---|---|---|
| `list({status?, dateFrom?, dateTo?, vehicleId?, operatorId?, warehouseId?, skip, limit})` → `ItineraryPage` | `GET /delivery-itineraries` | Status is one value, or null for all. |
| `getById(id)` → `Itinerary` | `GET /delivery-itineraries/{id}` | |
| `create({date?, vehicleId?, operatorId?, warehouseId?, comment?})` | `POST /delivery-itineraries` | The response's `warnings` are ignored (R4). |
| `updateHeader(id, {date?, vehicleId?, operatorId?, comment?})` | `PUT /delivery-itineraries/{id}` | Null leaves a field unchanged. The server can't clear one. |
| `cancel(id)` | `POST …/{id}/cancel` | |
| `depart(id)` | `POST …/{id}/depart` | |
| `addStop(id, {deliveryOrderId})` | `POST …/{id}/stops` | No comment is sent. |
| `removeStop(id, stopId)` | `DELETE …/stops/{stopId}` | |
| `commitLine(id, stopId, {deliveryOrderLineId, quantity})` | `POST …/stops/{stopId}/lines` | The quantity is always sent. |
| `commitWholeOrder(id, stopId, {deliveryOrderId})` | `POST …/stops/{stopId}/lines/all` | |
| `adjustCommitment(id, stopId, lineId, {quantity})` | `PUT …/stops/{stopId}/lines/{lineId}` | |
| `releaseCommitment(id, stopId, lineId)` | `DELETE …/stops/{stopId}/lines/{lineId}` | |
| `closeStop(id, stopId, StopClosure)` | `POST …/stops/{stopId}/close` | Multipart. `lines` is a JSON string, and `image` is a `MultipartFile.fromBytes` (R12). |

Errors map `DioException` → `AppError` with the shared mapper (§III). Printing goes through `DocumentSource`, not this repository (R11).

## Lookups (presentation, research R2–R4)

Names come from the trip itself (mbe-api#343). Only two reads remain:
- `itineraryOrderProvider.family(deliveryOrderId)` → `DeliveryOrder`. This is one `DeliveryOrderAdminRepository.getById` per stop order, read only on an Abierto trip for open quantities. It's cached, and invalidated after loads, departure and close.
- `vehicleOperatorProvider.family(id)` → the operator's licence expiry (R4). It's read only for an Abierto trip with an operator.

## `DeliveryItineraryActions` (keepAlive notifier)

`create`, `updateHeader`, `addStop`, `removeStop`, `commitLine`, `commitWholeOrder`, `adjust`, `release`, `depart`, `cancel` and `closeStop`. Each returns `AppError?`; `create` returns the new id or an error. On success it:
- sets the detail controller's state to the returned trip;
- invalidates `deliveryItinerariesListControllerProvider` and the touched `itineraryOrderProvider` entries;
- after `depart`, `cancel` or `closeStop`, also invalidates the 061 delivery-order list and detail providers and the 063 pending queue.

## Controllers

- `DeliveryItinerariesListController` (`AsyncNotifier`): filter (freezed `DeliveryItinerariesFilter`, URL-encoded as in 061) and page.
- `DeliveryItineraryDetailController.family(id)` (`AsyncNotifier<Itinerary>`).
