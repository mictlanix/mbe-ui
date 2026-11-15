# Data Model: Delivery Orders

**Spec**: [spec.md](./spec.md) | **Research**: [research.md](./research.md)

These are client-side types only; nothing is persisted (§VII). Money doesn't appear. Quantities are `Decimal`, parsed from the server's decimal strings.

## 1. Entities (`features/sales/domain/entities/delivery_order.dart`, freezed)

### DeliveryOrderSummary (list row)

| Field | Type | From | Notes |
|---|---|---|---|
| `id` | `int` | `delivery_order_id` | |
| `facilityId` | `int` | `facility` | Name through `facilityDisplayNameProvider` (R4) |
| `serial` | `int?` | `serial` | Null on a draft. Shown as "Borrador" |
| `customerId` | `int` | `customer` | Name through `customerDisplayNameProvider` |
| `salesOrderIds` | `List<int>` | `sales_orders` | Derived by the server from the lines |
| `shipToId` | `int?` | `ship_to` | Address id, resolved through the customer (R4) |
| `date` | `DateTime?` | `date` | Scheduled, local |
| `priority` | `int` | `priority` | ≥ 0 |
| `status` | `DeliveryOrderStatus` | `status` | Existing enum (`destination.dart`), `fromApi` |
| `type` | `FulfillmentType` | `fulfillment_type` | Existing enum: `counterPickup(0)`, `delivery(1)` |
| `parentId` | `int?` | `parent_delivery_order` | |

### DeliveryOrder (detail): `DeliveryOrderSummary`'s fields, plus:

| Field | Type | From |
|---|---|---|
| `contactId` | `int?` | `contact` |
| `comment` | `String?` | `comment` |
| `rejectionReason` | `String?` | `rejection_reason` |
| `proofId` | `int?` | `proof_of_delivery` |
| `createdAt`, `modifiedAt` | `DateTime` | `creation_time`, `modification_time` |
| `lines` | `List<DeliveryOrderLine>` | `lines` |

Derived getters:
- `isDraft`
- `isPickup`
- `isTerminal`: `pickedUp`, `delivered`, `partiallyDelivered` or `cancelled`
- `hasProof`

### DeliveryOrderLine

| Field | Type | From |
|---|---|---|
| `id` | `int` | `delivery_order_detail_id` |
| `salesOrderDetailId` | `int?` | `sales_order_detail` |
| `productId`, `productCode`, `productName` | `int`, `String`, `String` | snapshots |
| `warehouseId` | `int` | `warehouse` (dispatch) |
| `quantity`, `committed`, `delivered`, `returned`, `open` | `Decimal` | `quantity`, `committed_quantity`, `delivered_quantity`, `returned_quantity`, `open_quantity` |

The source sales order isn't on the line.
- When the order covers one sale (`salesOrderIds.length == 1`), every line's Pedido column shows that sale.
- When it covers more than one, the detail controller loads each sale (`SalesOrderRepository.getById`, which needs Sales Orders read) and maps `salesOrderDetailId` to its sale. These are usually two or three calls.
- Without that right, the column reads "—" (C4).

### DeliveryOrderEvent

| Field | Type | From |
|---|---|---|
| `id` | `int` | `delivery_order_event_id` |
| `from` | `DeliveryOrderStatus?` | `from_status`, null on creation |
| `to` | `DeliveryOrderStatus` | `to_status` |
| `employeeId` | `int` | `employee` |
| `at` | `DateTime` | `event_time` |
| `reason` | `String?` | `reason` |

### ProofOfDelivery

| Field | Type | From |
|---|---|---|
| `receiverName` | `String` | `receiver_name` |
| `receiverIdShown` | `String` | `receiver_id_shown` (free text) |
| `capturedAt` | `DateTime` | `captured_time` |
| `capturedBy` | `int` | `captured_by` (employee) |

The image is fetched separately as bytes (R5).

### DeliverableLine (add-line step 2, `deliverable_lines.dart`)

| Field | Type | Notes |
|---|---|---|
| `salesOrderId` | `int` | |
| `salesOrderDetailId` | `int` | |
| `productCode`, `productName` | `String` | from the sale line |
| `ordered` | `Decimal` | sale line quantity |
| `remaining` | `Decimal` | `ordered − Σ quantity` over the sale's non-cancelled delivery orders (R8) |

A pure function, `deliverableLines(Sale sale, List<DeliveryOrder> ordersOfSale, {required Set<int> excludeDetailIds})`, computes it. Lines with `remaining <= 0` and lines already on the order being edited are dropped.

## 2. List filter (`DeliveryOrdersFilter`, URL state)

| URL key | Field | Type | Absent means | Sent as |
|---|---|---|---|---|
| `q` | `search` | `String?` (digits) | no search | `search` |
| `status` | `status` | `DeliveryOrderStatus?` (wire number) | active statuses (mbe-api#312 shipped; `status=all` is every status) | `status` |
| `type` | `type` | `FulfillmentType?` | every type | `fulfillment_type` |
| `from`, `to` | `dateFrom`, `dateTo` | `DateTime?` (day) | any date | `date_from` (start of day), `date_to` (end of day) |
| `customer` | `customerId` | `int?` | any | `customer` |
| `order` | `salesOrderId` | `int?` | any | `sales_order` |
| `facility` | `facilityId` | `int?` | the caller's facility (server default) | `facility`, administrators only: dropped for everyone else in `fromQuery` and again in the fetch (research R3) |
| `page` | via `ListQuery` | | page 1 | `skip`, `limit` = 20 |

- `activeFilterCount` counts the non-null facets, not search or page.
- `isNarrowed` is `activeFilterCount > 0 || search != null`.
- Clearing nulls every facet.
- When #312 ships, `status=active` becomes one more value, and the absent value moves to active (FR-003). **Shipped 2026-11-14** (mbe-api PR #315): the list opens on "Activas"; "Todas" is `status=all` (fix/consume-mbe-api-308-314).

## 3. Status rules (what the detail screen offers)

`U` = the user has `deliveryOrders` update. Without `U`, nothing in this table is shown (FR-011, FR-015).

| Status | Type | Offered with U |
|---|---|---|
| draft | any | Editar encabezado, line ✎ and 🗑, Agregar línea (also needs Sales Orders read), **Confirmar** (disabled with no lines), Cancelar |
| pendingApproval | any | Cancelar |
| approved | pickup | **Lista para recoger**, Cancelar |
| approved | delivery | Cancelar (not reachable: a confirmed delivery skips approved) |
| readyForPickup | pickup | **Entregar al cliente**, Cancelar |
| inPreparation | any | Cancelar (refused while on an open itinerary: mbe-api#311 fixed) |
| inTransit | any | — |
| failed | any | **Reprogramar**, Cancelar |
| pickedUp, delivered, partiallyDelivered, cancelled | any | — |

Filled (primary) actions are in bold. "Cancelar orden" is always outlined.

Transitions the server applies:
- confirm: draft → pendingApproval, approved (pickup) or inPreparation (delivery). Assigns the serial.
- cancel: → cancelled. Zeroes committed.
- requeue: failed → inPreparation. Zeroes returned.
- ready: approved → readyForPickup.
- pickup: readyForPickup → pickedUp. Attaches the proof.

The app never predicts the status that results. It shows the one returned.

## 4. Validation (client side, mirrored by the server)

| Input | Rule | Server code if bypassed |
|---|---|---|
| Cancel reason | not blank after trim | `delivery_order.reason_required` |
| Line quantity (edit or add) | > 0 and ≤ remaining | `delivery_order.quantity_exceeds_remaining` |
| Priority | integer ≥ 0 | 422 validation |
| Pickup receiver name, identification shown | not blank after trim | `delivery_order.proof_incomplete` |
| Pickup photo | jpg, jpeg or png file chosen, up to 2 MB | `delivery_order.proof_incomplete`, `image.too_large`, `image.unsupported_format` |
| Confirm | at least one line | `delivery_order.no_lines` |
