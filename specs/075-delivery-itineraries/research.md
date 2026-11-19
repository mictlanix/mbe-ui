# Research: Delivery Itineraries (spec 075)

Phase 0 decisions. Each entry is a decision, why it was chosen, and the alternatives considered.

## R1. Where the code lives

**Decision**: `lib/features/sales/`, beside delivery orders (061), approval (062) and the "Por entregar" queue (063). The existing `DeliveryItineraryRepository` (063, pending deliveries only) gains the itinerary methods. Screens go in a new `presentation/delivery_itineraries/`. The routes are `/sales/delivery-itineraries` and `/sales/delivery-itineraries/:itineraryId`. Nav is the fourth entry of the Logística group, after "Por entregar", gated on SystemObject 87 read, with `NavBranch.deliveryItineraries = 36`.

**Rationale**: The 063 repository's doc comment already says the itinerary screens extend it. Delivery orders are in `sales/`, and this feature reads their repository and entities, so staying in the same feature avoids a cross-feature import. The routes stay under `/sales/`, as the other three Logística screens do. Only the nav group is "Logística".

**Alternatives**: A new `features/logistics/`. That would move 061–063 or import them across features, which is a refactor nobody asked for.

## R2. A stop's delivery order and its names (mbe-api#343)

**Decision**: Build against #343. The domain `ItineraryStop` carries `deliveryOrderId`, `customerName` and `shipToLabel`, and `ItineraryLine` carries `deliveryOrderId`, `productCode`, `productName` and `unitSymbol`, all nullable. The data layer fills them from the server once #343 ships and the client is regenerated. Until then, two sources fill what they can:

1. **Session memory.** `addStop` records `stopId → deliveryOrderId` in a keep-alive provider. The new stop is the one id the response has that the previous state lacked. Every screen in the same app session can then resolve that stop.
2. **The order itself.** For a stop whose order is known, one cached `DeliveryOrderAdminRepository.getById` gives customer name, ship-to label and the order's lines (detail id → product code and name). Those resolve the stop's loaded lines. Unit symbol isn't on a delivery-order line, so it stays empty until #343.

A stop whose order isn't known (a reload in a new session) shows "Parada N", and its lines show their delivery-order line number. The stop UI is implemented last (plan order step 6), so #343 has time to land. "Agregar línea" on an unknown stop asks for the order again (spec Edge Cases).

**Rationale**: The user chose this on 2026-11-18. No endpoint maps a delivery-order line to its order, and the stop row doesn't store one (mbe-api `add_stop` validates and then drops it). Every workaround that works across sessions either writes markers into server data or costs many requests.

**Alternatives** (rejected by the user):
- Encoding `DO:<id>` in the stop's `comment`. It leaves residue in data that outlives #343.
- Listing every order in En preparación or En tránsito and matching line ids. That costs many requests per trip and misses closed trips.
- Device-local storage of the mapping. It's barred by §VII.

## R3. Vehicle, operator and warehouse names

**Decision**: These are feature-local `FutureProvider.family` lookups by id: `vehicleDisplayNameProvider` (name, then plate) and `vehicleOperatorDisplayNameProvider` (the employee's name, as the operators catalog shows it). Warehouses use the existing `warehouseDisplayNameProvider` (catalog). Each is cached per id for the session. A failed or forbidden lookup falls back to the number (FR-024). Once #343 adds `vehicle_name`, `vehicle_operator_name` and `warehouse_name`, the mapper prefers them.

**Rationale**: This is the pattern 061 used until api#324–330 shipped. Rows render first, and names fill in.

**Alternatives**: Loading the whole vehicle and operator catalogs once. That's fine for vehicles, but the same per-id lookup already exists for warehouses, so one pattern serves all three.

## R4. Licence warning

**Decision**: Ignore the response's `warnings`. The trip screen reads the assigned operator (catalog `VehicleOperatorRepository.getById`, which carries `expirationDate`) and shows "La licencia de {operador} venció el {fecha}" when the expiry is before today. It's shown on the header for an Abierto trip only.

**Rationale**: The server's warning is uncoded English (§III, API error text). The same operator read already serves the name (R3), so the warning costs no extra request. Specs 067 and 068 took the same approach for over-receipt warnings.

**Alternatives**: Asking for a coded warning upstream (as api#322 did). That's possible later. It doesn't block this feature.

## R5. Picking an order for a stop

**Decision**: "Agregar parada" opens a dialog over `DeliveryOrderAdminRepository.list(statuses: [inPreparation], type: delivery)`, paged, with folio search. Rows show folio, customer, ship-to and date. Orders already stops on this trip are hidden. Choosing one calls `addStop`.

**Rationale**: The 063 queue lists lines, not orders, and has no search. The 061 list already filters on exactly these two facets.

**Alternatives**: Reusing the "Por entregar" screen as a picker. It's grouped by date and line-level, which is the wrong shape for choosing an order.

## R6. Loading lines

**Decision**: Each stop's card shows its loaded lines and, when the trip is Abierto, two actions:
- "Cargar todo" calls `commitWholeOrder(deliveryOrderId)`.
- "Cargar línea" opens a dialog listing the order's lines with open quantity above 0, from the cached `getById`. The quantity defaults to open and is capped at it.

A loaded line's ✎ opens the quantity dialog, capped at open plus already loaded (server headroom), and 🗑 releases it after confirmation. Lines come only from the stop's own order (spec Edge Cases). After every write, the cached order is invalidated, so open quantities are current.

**Rationale**: These are the four server operations, one control each. The cap mirrors the server's checks, so a refusal only happens on a race (handled by R10).

## R7. Departure guard

**Decision**: "Dar salida" is enabled only when the trip has at least one loaded line and every stop has at least one line. Otherwise it's disabled, with a caption naming the empty stops or saying nothing is loaded. The confirmation dialog shows vehicle, operator (or "Sin operador"), stop count and line count.

**Rationale**: Spec FR-012. The server accepts empty stops (gap posted on mbe-api#343), and such a stop would block the trip from closing.

## R8. Close-stop dialog and proof

**Decision**: A `ResponsiveDialog` with three sections:
- **Receptor**: name and ID shown.
- **Líneas**: one row per loaded line with product, sent quantity, a delivered field starting at sent, and a reason dropdown that appears when delivered is below sent. "Todo entregado" and "Nada entregado" set every row.
- **Prueba**: a segmented control, Imagen / Firma.
  - **Imagen** uses the `FilePicker` flow from 061's `pickup_dialog.dart`: jpg, jpeg or png, at most 2 MB, checked before sending.
  - **Firma** is a feature-local `SignaturePad`.

Confirm stays disabled until every requirement in FR-016 holds. Switching between Imagen and Firma keeps each one's input until confirm, but only the selected one is sent.

**Rationale**: This is one screen for desk work from paper. The 1d layout from the #119 design survives as a single form. Its wizard and verdict variants (1e and 1f) suit a phone, not the back office.

**Alternatives**: A full-screen route for closing. A stop has few lines, so a dialog is enough, and the trip stays visible behind it.

## R9. Signature pad

**Decision**: A feature-local `SignaturePad` widget. It captures strokes with a `GestureDetector` (pan) into a list of paths, draws them with a `CustomPainter` on a white canvas, and offers "Borrar". On confirm it renders through `PictureRecorder` → `Picture.toImage` → `toByteData(format: png)`, at a fixed 1024 × 384 px, black ink on white. That's under 100 KB, well inside 2 MB, and already at the server's 1024 px POD width. An empty pad doesn't count as proof.

**Rationale**: About 120 lines with no new dependency. The output is what the server stores anyway: a PNG at most 1024 px wide. It stays out of `core/widgets/` until a second caller needs it (the 061 pickup could, later).

**Alternatives**: The `signature` pub package. It works, but it adds a dependency and its export API for one small widget. `hand_signature` was also rejected: it's heavier and its SVG-first output isn't needed.

## R10. Actions, refresh and races

**Decision**: A `keepAlive` `DeliveryItineraryActions` notifier wraps every write and returns `AppError?`, as 061's `DeliveryOrderActions` does. Every write returns the full trip. The notifier pushes it into the detail controller, with no extra GET. It also invalidates the list controller and the cached orders touched by the write, and, for depart and close, the 061 delivery-order detail and list providers, because order statuses change. On a server refusal, the dialog shows the localized message and the trip reloads (FR-022). On a network failure, it shows "result unknown" and reloads.

**Rationale**: 061's pattern, already tested.

## R11. Printing

**Decision**: Two new `DocumentKind` values, `itineraryTicket` (`GET /delivery-itineraries/{id}/ticket`) and `itineraryDeliveryNotes` (`/delivery-notes`). Both are gated on SystemObject 87 read and routed in `DocumentSourceImpl`, with fallback names `itinerario-<id>.pdf` and `notas-entrega-<id>.pdf`. The trip screen shows both buttons only for En ruta and Cerrado (`canPrintItinerary`). The server's 409s (`itinerary.not_departed`, `itinerary.cancelled`) show in the preview, as other documents' do.

**Rationale**: The spec 044 surface, as 064 did for delivery orders.

## R12. Close-stop upload

**Decision**: Use the generated `closeStop`, which takes `MultipartFile image` and `String lines`. `lines` is `jsonEncode([{line, delivered_quantity, reason_code}])`, with the quantity as a decimal string and `reason_code` as the wire int or null. A live test closes a stop with an uploaded PNG and with a drawn signature before the wrapper is trusted (§III multipart rule).

**Rationale**: The generator emitted a real `MultipartFile` here, as it did for 061's pickup, which works live. The constitution still requires the live check.

## R13. Error messages

**Decision**: Fifteen codes flip from `OUT` to `IN` in `code-scope.tsv`, and two resources get their own names; see [contracts/error-messages.md](contracts/error-messages.md). Param enrichment:
- quantities go through `formattersProvider`;
- `status` goes through the existing `DeliveryOrderStatus` and new `ItineraryStatus` labels;
- `line_id` and the `lines` in `lines_overcommitted` resolve to product names from the loaded trip, falling back to the number.

**Rationale**: §III coverage, measured from the catalog rows above.

## R14. List

**Decision**: There's a filter row with no search box, because the endpoint has none (§VI allows omitting it), and "Nuevo itinerario" as the toolbar action. The shared drawer holds status (all, Abierto, En ruta, Cerrado, Cancelado), a date range, vehicle, operator and dispatch warehouse. The table is paginated at 20, newest first. Rows have no Edit icon, the same document reading as 067–069 (Complexity Tracking).

**Rationale**: The server's filters (spec FR-003), the shared list contract, and the precedent for document lists.

## R15. New trip

**Decision**: "Nuevo itinerario" opens a short dialog with date (default today), vehicle, operator and an optional dispatch warehouse. The warehouse picker says that leaving it blank uses the point of sale's. On confirm, `create` is called and the trip's screen opens. `vehicle.open_itinerary_exists` keeps the dialog open with the message, which names the trip holding the vehicle.

**Rationale**: The spec says creation is immediate and the warehouse is optional. The app can't read the point of sale's warehouse cheaply, and the server already defaults it. The warehouse can only be chosen here (R1, spec Assumptions).

**Alternatives**: Creating with no dialog and editing afterwards (legacy "New"). That would leave no place to choose a non-default warehouse, because the header can't change it later.
