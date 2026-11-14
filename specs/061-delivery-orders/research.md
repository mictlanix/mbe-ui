# Research: Delivery Orders

**Spec**: [spec.md](./spec.md) | **Wireframes**: [wireframes.md](./wireframes.md) | **Date**: 2026-11-14

These findings come from reading mbe-api (`app/api/v1/endpoints/delivery_orders.py`, `app/services/delivery_order_service.py`, `delivery_events.py`, `error_codes.py`), the generated client (`lib/generated/openapi/lib/src/api/delivery_orders_api.dart`) and the existing POS delivery layer. No `NEEDS CLARIFICATION` remains.

## R1. Rights and gating

- **Decision:**
  - The route and nav destination are gated on `PrivilegeGate(SystemObject.deliveryOrders, AccessRight.read)` (71).
  - Every write needs `deliveryOrders` update: header and line edits, confirm, cancel, requeue, ready-for-pickup and pickup.
  - Both SystemObjects already exist in `lib/core/access/system_object.dart`.
- **Rationale:** this mirrors the server, which gates all 13 operations used here on 71 Read or Update. Cancel needs Update, not Delete (constitution §IV).
- **Alternatives considered:** gating cancel on Delete. Rejected, because the server doesn't, and the UI would hide an action the server allows.

## R2. Domain types and repository

- **Decision:** add new back-office types, and leave the POS `Destination` alone.
  - **Entities** in `features/sales/domain/entities/delivery_order.dart` (freezed): `DeliveryOrderSummary`, `DeliveryOrder`, `DeliveryOrderLine`, `DeliveryOrderEvent`, `ProofOfDelivery` (data-model §1).
  - **Enums:** they reuse `DeliveryOrderStatus` and `FulfillmentType` from `destination.dart`, imported rather than moved, so the POS files keep their imports.
  - **Repository:** a new `DeliveryOrderAdminRepository` (domain interface plus `data/delivery_order_admin_repository_impl.dart`) over the same generated `DeliveryOrdersApi`. Its methods: `list`, `getById`, `events`, `proof`, `proofImage`, `updateHeader`, `addLine`, `updateLine`, `removeLine`, `confirm`, `cancel`, `requeue`, `markReadyForPickup`, `confirmPickup`.
  - **Shared helpers:** the `Quantity1` wire helper and `wireDate` are reused from the existing impl files. `_setQuantity1` becomes a top-level function in `delivery_order_repository_impl.dart`, so both impls share it. That is the only change to that file besides R9.
- **Rationale:**
  - `Destination` is POS-shaped. It's documented as "always draft", and it leaves out serial, facility, customer, priority, the four line quantities, rejection reason, proof and the parent link.
  - Widening it would make every POS card carry fields it never shows. Adding parallel methods to `DeliveryOrderRepository` that return a different type would muddle one interface.
- **Alternatives considered:**
  - Widening `Destination`. Rejected, because it touches every POS delivery test.
  - Moving the enums to their own file. A nice cleanup, but not needed (§3 of CLAUDE.md: surgical).

## R3. List filter and the interim opening state

- **Decision:**
  - **URL-backed filter.** A freezed `DeliveryOrdersFilter.fromQuery(ListQuery)`, modelled on `refunds_filter.dart` and `payments_filter.dart`. Its facets are `status` (wire number), `type`, `from` and `to` (scheduled date), `customer`, `order` (sales-order id) and `facility`.
  - **Absent values.** An absent `status` means every status, the interim opening state the user chose. An absent `facility` means the server default, the caller's facility.
  - **Search** takes digits only and is labelled "Folio". The server also matches the internal id, but no screen shows that id, so the app doesn't offer it as a search key (analysis B1).
  - **Facility scoping (analysis S1, mbe-api#314).** The server honors any `facility` from any 71 reader. Following Pedidos (spec 029, `sales_orders_scoping_test.dart`), the facet is decoded only when `isAdministrator`, twice: in `DeliveryOrdersFilter.fromQuery` and again in the list controller's fetch. Treat the double drop as load-bearing; never merge it into one site.
  - **No facility configured.** When `userFacilityIdProvider` is null, the screen shows a notice and sends no request, administrators included, as `sales_orders_list_screen.dart` does.
  - **Clearing** empties every facet.
- **The `Activas` gap:**
  - `GET /delivery-orders` takes one `status` value, so the seven non-terminal statuses can't be one paginated request. Filtering on the client would break `total` and page boundaries.
  - The user chose to file mbe-api#312 and open on every status in the meantime. The spec's FR-003 says so.
  - The filter keeps `status` a nullable single value, so an `active` choice can be added as one more value when #312 ships. Nothing else in the screen changes then.
- **Alternatives considered:**
  - Opening on Borrador.
  - Blocking the list until #312.
  - Client-side multi-status filtering, which breaks pagination.

  The user chose the interim "every status".

## R4. Names behind ids

- **Decision:** reuse the existing per-id providers, each falling back to `#id` (FR-025).

  | Shown | Provider | Right needed |
  |---|---|---|
  | Customer | `customerDisplayNameProvider` | Customers read |
  | Facility | `facilityDisplayNameProvider` | Facilities read |
  | Employee (history, proof "registered by") | `employeeDisplayNameProvider` | Employees read, or one of the related rights mbe-api's `_LOOKUP` accepts |
  | Warehouse | `facilityWarehousesControllerProvider(facility)`, the `_WarehouseCell` pattern in `refund_detail_screen.dart` | Warehouses read |
  | Ship-to and contact | `saleCustomerControllerProvider(customer)`: the customer's embedded addresses and contacts | Customers read |

- **Ship-to in the list:** the cell resolves the address through the row's customer, which is cached per customer. A 20-row page costs at most 20 customer reads, and usually far fewer, because one customer repeats. Without Customers read the cell shows `#id`.
- **Facility ship-to (pickup):** a pickup's ship-to is a facility's address, which isn't in the customer's list. The cell then falls back to the facility name, because `fulfillment_type == PICKUP` already says "at the store".
- **Customer filter:** the facet is offered only with Customers read, because the picker searches `/customers` (wireframes Open Question 6).
- **Rationale:** no batch lookups exist anywhere in the app. Every screen uses these cached families, and `DeliveryOrderSummary` carries no joined names.
- **Alternatives considered:** asking mbe-api for `customer_display_name` on the summary, as on other summaries. Worth having, but not needed for this feature, so no issue was filed.

## R5. Detail composition

- **Decision:** the detail controller loads the order and its events together, in two parallel requests.
  - The proof section loads only when `proofOfDelivery != null`: `proof` first, then `proofImage`.
  - `proofImage` is bytes, so it copies spec 051's `licensePhotoProvider`: a PNG signature check, then `Image.memory`. The server always answers `image/png`.
  - Parent and child links: the parent comes from `parentDeliveryOrder`. Children are found with `GET /delivery-orders?sales_order=<a sale of the order>&facility=<the order's facility>`. The facility is passed because the server otherwise filters on the caller's (analysis F1). Their `parentDeliveryOrder == id` is checked on the client, since the list can't filter by parent. That costs one list call, made only when the order is PARTIALLY_DELIVERED.
- **Rationale:** the history is bounded (a handful of events), so it isn't paginated. A failed proof never blocks the rest of the screen.
- **Alternatives considered:** a child-order link from the server. Not available, and a partial delivery's child is rare enough that one list call is fine.

## R6. Writes and refresh

- **Decision:**
  - **Controller.** A keep-alive `DeliveryOrderActions` notifier, one method per action. Each returns `AppError?`, following spec 059's `PaymentEditor` and spec 060's `PaymentVerification`.
  - **Refresh.** Every success invalidates the order, its events and the list family. Every failure invalidates the order too, because FR-023 asks for a reload.
  - **Network failure.** A connection error, or a timeout with no response, is reported as "unknown result" and the order reloads (spec edge case).
  - **Pickup upload.** The photo is read with `FilePicker.platform.pickFiles(type: custom, allowedExtensions: [jpg, jpeg, png], withData: true)` and sent as `MultipartFile.fromBytes(bytes, filename:)`. This is spec 051's path.
- **Rationale:** these patterns already exist in the app and are tested.

## R7. Header edit

- **Decision:**
  - **Dialog.** A `ResponsiveDialog` with a two-column `ResponsiveFormGrid`. Its fields are scheduled date (date and time), priority (integer ≥ 0), ship-to, contact and comment.
  - **Pickers.** Ship-to and contact reuse `CustomerAddressPicker` and `CustomerContactPicker` (`presentation/widgets/`). For a pickup, the ship-to stays as it is: the address picker isn't offered, and the field reads the facility.
  - **Saving.** Only changed fields are sent, and none can be cleared. The server ignores nulls, which is spec edge case "Fields that can't be cleared".
- **Rationale:**
  - Changing a pickup's ship-to to a customer address would flip what the order is.
  - The server sets `fulfillment_type` once at creation, and `PUT` can't change it.
  - Offering a facility list would invent a "move pickup store" flow that the spec doesn't ask for.
- **Spec impact:** FR-012's "or a facility's address" is narrowed. A pickup keeps its facility address, and a delivery picks from the customer's addresses. Recorded here, and the spec is aligned in the same change.

## R8. "Agregar línea": deliverable lines

- **Decision:** a two-step dialog (contract C7).
  - **Step 1, pick a sale.** It lists the customer's completed, uncancelled sales at the order's facility, newest first. The source is `SalesOrderRepository.listOrders(customer:, status: completed, facility:)`. The repository gains a `customer` parameter, which the server already supports.
  - **Step 2, enter quantities.** It shows that sale's lines (`getById`) with what's left on each line, and the user types quantities. Lines already on this order are left out.
  - **What's left** = `line.quantity − Σ quantity` over that sale's non-cancelled delivery orders. The orders come from `GET /delivery-orders?sales_order=&facility=<sale's facility>&limit=100`, each fetched for its lines. This matches the server's `_covered_quantities`.
  - **Saving.** One `addLine` per filled row, run in sequence. The first failure stops the run and reports it, and the lines already added stay.
- **Rights:** step 1 needs Sales Orders read. Without it, "Agregar línea" isn't offered, and the edit-quantity and remove actions still are.
- **Facility:** the server's list always applies a facility filter, defaulting to the caller's. So the coverage call passes the sale's own facility, or another facility's orders for that sale would be missed.
  - One rare case is still missed: a consolidated order at a different facility claiming this sale's line.
  - Then the computed amount overstates what's left, and the server refuses the add with `delivery_order.quantity_exceeds_remaining {requested, remaining}`, which is already localized.
- **Upstream:** the user chose to file mbe-api#313 for a server query, `deliverable-lines?customer=`. When it ships, step 2 switches to it and the coverage computation is deleted.
- **Rationale:** working one sale at a time keeps it to a few calls per sale, rather than N+1 across every sale the customer has. The server stays the authority on what's left.
- **Alternatives considered:**
  - Reusing the POS open-sales source. Rejected, because it's scoped to one register and today, and has no customer filter.
  - A flat list across every sale, as the wireframe first drew it. Rejected, because of the N+1.
  - Leaving add-line out until #313. The user chose to ship it now.

## R9. POS distribution counts cancelled destinations (fixed here)

- **Finding:**
  - `DeliveryOrderRepositoryImpl.listForSale` returns every delivery order of a sale, cancelled ones included.
  - `distributionFor` (`line_distribution.dart`) then counts their quantities as claimed. The server's `_covered_quantities` excludes CANCELLED.
  - Today a destination is cancelled only by the POS's own undo, which also drops it from local state. A reload brings it back, though.
  - Once this feature cancels orders from the back office, a cashier resuming that sale in the POS would see it as already distributed. That contradicts US4 ("the sale's quantities can go on a new delivery").
- **Decision:** `listForSale` drops cancelled orders, with one new unit test. This is a two-line change, and it traces directly to US4.
- **Alternatives considered:**
  - Filtering in `distributionFor`. The repository is the narrower place, because no POS caller wants cancelled destinations.
  - A separate bug issue. The fix is too small to split off, so it's recorded here and in the PR instead.

## R10. Localized errors

- **Decision:** add four codes to `localizedErrorCodes`, with arms in `localize_problem.dart` and keys in both ARB files, and flip each from `OUT` to `IN` in `specs/058-localized-api-errors/contracts/code-scope.tsv`: `delivery_order.insufficient_notice` (carries `earliest`, formatted by a new `_dateTime` helper on `fmt.display.dateTime`, and `min_hours`), `delivery_order.no_lines`, `delivery_order.not_failed` and `delivery_order.proof_incomplete`.
- **Every code the newly called endpoints can return** (constitution workflow gate; analysis D1). "New" means this feature adds the message. "Have" means it's already localized and reused. Every endpoint can also return the framework codes (authentication, permission, validation, `resource.conflict`), which are already localized.

  | Endpoint | Codes | Message |
  |---|---|---|
  | `GET /delivery-orders`, `/{id}`, `/{id}/events`, `/{id}/proof`, `/{id}/proof/image` | `resource.not_found` | have |
  | `PUT /{id}` | `delivery_order.not_editable`, `resource.not_found` | have |
  | `POST /{id}/lines` | `delivery_order.not_editable`, `.line_not_deliverable`, `.line_already_present`, `.quantity_exceeds_remaining`, `facility.no_dispatch_warehouse` | have |
  | `PUT`, `DELETE /{id}/lines/{line}` | `delivery_order.not_editable`, `.quantity_exceeds_remaining` (PUT only), `resource.not_found` | have |
  | `POST /{id}/confirm` | `delivery_order.not_editable`, `lock.busy` | have |
  | | `delivery_order.no_lines`, `delivery_order.insufficient_notice` | **new** |
  | `POST /{id}/cancel` | `delivery_order.reason_required`, `state.transition_invalid` | have |
  | `POST /{id}/requeue` | `delivery_order.not_failed` | **new** |
  | `POST /{id}/ready-for-pickup` | `state.transition_invalid` | have |
  | `POST /{id}/pickup` | `state.transition_invalid`, `image.too_large` (2 MB), `image.unsupported_format` | have |
  | | `delivery_order.proof_incomplete` | **new** |

  The `example_routes` of the reused rows (`lock.busy`, `image.*`, `state.transition_invalid`, `delivery_order.not_editable`) gain the delivery-order routes in code-scope.tsv, so the table records where each code is reachable.
- **`state.transition_invalid`'s message is generic:** "Este registro no puede pasar de su estado actual al solicitado." The wireframe's contextual cancel message ("ya no puede cancelarse desde En tránsito") isn't built. The generic message plus the reload, which shows the new status, meets FR-023. A contextual variant would need per-screen copies of the code's text, which §III steers away from.
- **Line edits:** `update_line` reports `remaining` with the line's own quantity already excluded (`sales_line.quantity − elsewhere`), so the refusal states the true maximum for that line (analysis U4). No client computation is needed for C8.
- **Rationale:** constitution §III (v1.15.0) says error text comes from codes, in both locales, and `catalog_coverage_test.dart` enforces it.

## R11. Navigation and routes

- **Decision:**
  - **List.** A new `StatefulShellBranch` appended last in `app_router.dart`, with `GoRoute('/sales/delivery-orders')`, and a `NavBranch.deliveryOrders = 26` const. The `NavDestination` goes in Ventas right after Pedidos (`sales-orders`) in `kNavigationTree`.
  - **Detail.** A top-level `GoRoute('/sales/delivery-orders/:deliveryOrderId')`, like the refunds detail.
  - **Gate.** A `_routeGate` prefix clause on `/sales/delivery-orders` for 71 read.
- **Rationale:** this is the same as every recent sales screen. A Logística group is deferred until itineraries (wireframes Open Question 1).

## R12. Tests

- **Unit** (`test/unit/features/sales/`):
  - `delivery_orders_filter_test`;
  - `delivery_orders_scoping_test`, which pins the double facility drop for non-administrators (S1), following `sales_orders_scoping_test.dart`;
  - `delivery_order_admin_repository_impl_test`, covering the status mapping, the four quantities, multipart pickup and the PNG check;
  - `delivery_order_actions_test`, covering invalidations and error passthrough;
  - `deliverable_lines_test`, covering the remaining computation and cancelled exclusion;
  - the R9 case added to `delivery_order_repository_impl_test`.
- **Widget** (`test/widget/features/sales/`):
  - `delivery_orders_list_screen_test`, covering opening, filters, empty state and the no-right redirect;
  - `delivery_order_detail_screen_test`: the rejection banner, parent link and proof, plus one table-driven action matrix over all 11 statuses × both types × update or not, asserting exactly the actions in data-model §3 and no others (SC-003, analysis E1);
  - dialog tests for confirm, cancel, pickup, header and add line.
- **Core:** `catalog_coverage_test` gains four codes, and `problem_fixtures` gets the new ones.
- **Live:** `integration_test/delivery_orders_quickstart_test.dart`.
  - Read-only by default.
  - With `MBE_WRITE=true` it does more. It creates a draft through the POS repository from a completed 1-unit sale, then edits the header, confirms, cancels, and checks the history. It also confirms and hands over a pickup order with a generated PNG.
  - Requeue needs a FAILED order, which only an itinerary produces. It is checked manually (quickstart step 9).
