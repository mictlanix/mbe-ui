# Feature Specification: Delivery Itineraries

**Feature Branch**: `075-delivery-itineraries`

**Created**: 2026-11-18

**Status**: Draft

**Input**: User description: mictlanix/mbe-roadmap#41 ([UI] Delivery itineraries: stops, depart, close stop, proof of delivery). Scope 06 §6.4 and 06a §4–5 (mbe-api `docs/specs/06-logistics.md`, `06a-delivery-flow-v2.md`; SystemObject DeliveryItineraries 87). Server side done in mbe-api spec 012 US3–5, plus printing in spec 026. Weight: 12 legacy actions. Before specify, the user chose:

- the back office only. The driver's phone app (offline queue, sync, map) is mictlanix/mbe-roadmap#119, and the design in `artifacts/delivery_itineraries/` belongs to it, not to this feature;
- for names the server doesn't send (a stop's order, customer and ship-to; the vehicle, operator and warehouse on rows), both: file the server change (mictlanix/mbe-api#343) and resolve the names in the app until it ships;
- for proof of delivery, both: upload a photo or scan, or draw a signature on screen;
- printing the trip ticket and the delivery notes is part of this feature;
- trip setup follows the server: a trip may start empty, and vehicle and operator are optional until departure.

Delivery orders reach "En preparación" and show up in the "Por entregar" queue (spec 063), but nothing in the new app puts them on a truck. The orders never leave the warehouse on paper, the goods never move to "in transit", and no delivery is ever recorded as made, partly made or failed. In the current system the dispatcher uses "Itinerarios" to plan a trip, load delivery lines onto it, confirm it and print its papers.

This feature brings that screen to the back office, following the new delivery flow:

- a list of trips;
- a trip screen where the dispatcher adds stops (one per delivery order) and loads their lines;
- departure, which fixes what's on the truck;
- closing each stop when the paperwork comes back, with what the customer accepted and the proof;
- printing the trip ticket and the delivery notes.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Plan a trip and load it (Priority: P1)

At 7:00 the dispatcher opens "Itinerarios" and taps "Nuevo itinerario". The trip opens right away with today's date and the dispatch warehouse taken from their point of sale. They pick the van MBE-114 and the driver Juan Rivas. They tap "Agregar parada" and choose delivery order 1532 from the orders waiting in preparation. Then they tap "Cargar todo" to load every open line of that order. They add order 1540 as a second stop, but load only 6 of its 10 bags of cement, because the van is full.

**Why this priority**: This is the planning step that turns approved paperwork into a trip. Departure, closing stops and printing all start from a loaded trip.

**Independent Test**: Seed two delivery orders in En preparación. As a user with Delivery Itineraries create and update, create a trip, set vehicle and operator, add both orders as stops, load one in full and part of the other. Reload and check that the trip shows both stops in order, each line's loaded quantity, and that the orders' open quantities went down by what was loaded.

**Acceptance Scenarios**:

1. **Given** a user with Delivery Itineraries create, **When** they tap "Nuevo itinerario", **Then** a trip is created at once (status Abierto, today's date, the dispatch warehouse from their point of sale unless they chose another) and its screen opens. No stop, vehicle or operator is required to create it.
2. **Given** an Abierto trip and a user with Delivery Itineraries update, **When** they edit the header, **Then** they can change date, vehicle, operator and comment. The dispatch warehouse is shown, but only set at creation.
3. **Given** an operator whose licence has expired, **When** they're assigned, **Then** the assignment is kept and the screen warns that the licence expired, with its date.
4. **Given** a vehicle that already has another Abierto trip, **When** a new trip is created for it, **Then** the app says which trip holds the vehicle, and the new trip isn't created with that vehicle.
5. **Given** "Agregar parada", **When** the user picks a delivery order, **Then** they choose from delivery (not pickup) orders in En preparación, and the order becomes the next stop in sequence.
6. **Given** a stop, **When** the user taps "Cargar todo", **Then** every line of the stop's order with open quantity is loaded with all of it.
7. **Given** a stop, **When** the user loads one line, **Then** the quantity defaults to the line's open quantity and can be lowered. More than is open is refused, and the app shows how much is available.
8. **Given** a loaded line, **When** the user changes its quantity, **Then** it can go up to what's open plus what it already holds. When they remove it, its quantity is open again.
9. **Given** a stop, **When** the user removes it, **Then** it's removed after confirmation, together with everything loaded on it, and those quantities are open again.

---

### User Story 2 - Send the truck out (Priority: P1)

The van is loaded. The dispatcher checks the trip and taps "Dar salida". The trip becomes "En ruta" with its departure time. Each line's sent quantity is now fixed at what was loaded, and both delivery orders show En tránsito. The trip can no longer be edited.

**Why this priority**: Departure is where paper and stock agree. Until a trip leaves, the goods still count as on the shelf and no stop can be closed.

**Independent Test**: Depart a loaded trip as a user with Delivery Itineraries update. Check that it shows En ruta with a departure time, that every line's sent quantity equals what was loaded, that its orders are En tránsito, and that no edit, stop or load action is offered any more.

**Acceptance Scenarios**:

1. **Given** an Abierto trip with something loaded, **When** the user taps "Dar salida", **Then** a confirmation shows the vehicle, the operator (or that none is set), the number of stops and lines, and says the load can't be changed afterwards.
2. **Given** the server accepts, **Then** the trip shows En ruta, its departure time, and each line's sent quantity.
3. **Given** a trip with nothing loaded, **Then** "Dar salida" is disabled and the screen says why.
4. **Given** a stop with no lines loaded, **Then** "Dar salida" is disabled until the stop is loaded or removed, and the screen names the stop.
5. **Given** a line now loaded beyond what's open (someone changed its order meanwhile), **When** the server refuses departure, **Then** the app names the lines and reloads the trip.
6. **Given** an Abierto trip, **When** the user taps "Cancelar itinerario" and confirms, **Then** the trip becomes Cancelado, every loaded quantity is open again, and the orders stay in En preparación. A trip that has departed offers no cancel.

---

### User Story 3 - Close each stop with what the customer accepted (Priority: P1)

The driver returns at 15:00 with the signed delivery notes. The dispatcher opens the trip and closes stop 1. The receiver was Ana Domínguez, who showed "INE 0123456789", and she took everything. The dispatcher uploads the scan of the signed note. At stop 2 the customer refused 2 of the 6 bags because they were torn. The dispatcher enters 4 delivered, picks "Mercancía dañada", and draws the receiver's signature from the paper copy because that page wasn't scanned. Both stops are now resolved, so the trip closes with its return time.

**Why this priority**: This is what the whole flow exists to produce. Until a stop closes, the goods stay in transit and no delivery counts as made.

**Independent Test**: Depart a trip with two stops. As a user with Delivery Itineraries update, close one stop with everything delivered and an uploaded image, and the other with a shortfall, a reason and a drawn signature. Check that each stop shows its outcome, that the trip closes with a return time, and that the second order shows partially delivered with a child order for the remainder.

**Acceptance Scenarios**:

1. **Given** a pending stop on an En ruta trip and a user with Delivery Itineraries update, **When** they tap "Cerrar parada", **Then** a form asks for the receiver's name, the identification shown, each line's delivered quantity, and one proof.
2. **Given** the form, **Then** each line's delivered quantity starts at what was sent and can't go above it or below 0. Quick choices set every line to all sent, or to none.
3. **Given** a line delivered below what was sent, **Then** a reason is required for it: Cliente rechazó, No había nadie, Dirección incorrecta, Mercancía dañada, or Otro.
4. **Given** the proof, **Then** the user either uploads an image (jpg or png, up to 2 MB) or draws a signature on screen. A stop keeps one proof, so choosing one replaces the other.
5. **Given** any of receiver name, identification, proof or a needed reason is missing, **Then** "Cerrar parada" can't be confirmed, and the form says what's missing.
6. **Given** the server accepts, **Then** the stop shows its outcome (Entregada, Entregada parcialmente or Fallida), each line's delivered and returned quantities and reason, and when it was closed. The app shows the outcome the server returns and doesn't work it out ahead of time.
7. **Given** the last pending stop closes, **Then** the trip shows Cerrado with its return time, without the user reloading.
8. **Given** a closed stop, **Then** it links to its delivery order, whose screen shows the proof (spec 061) and, after a partial delivery, the child order carrying the remainder.

---

### User Story 4 - Find trips (Priority: P2)

A supervisor wants to know which trips went out yesterday and which are still on the road. They open "Itinerarios" and see every trip, newest first. Each row shows number, date, vehicle, operator, dispatch warehouse, status, departure and return times. They filter to "En ruta" and to vehicle MBE-114.

**Why this priority**: Planning, departure and closing all start from finding the trip. Legacy had this list, but on day one a dispatcher works on a trip they just created, so the list comes after the three P1 stories.

**Independent Test**: Seed trips in every status for two vehicles and two warehouses. Open the list as a user with Delivery Itineraries read. Check that it shows them newest first, paginated, that each filter narrows it, and that a row opens the trip's screen.

**Acceptance Scenarios**:

1. **Given** a user with Delivery Itineraries read, **When** they open the back-office navigation, **Then** "Itinerarios" is offered. Without that right it isn't.
2. **Given** the list opens, **Then** it shows trips in every status, newest first, paginated.
3. **Given** the filters, **When** the user filters by status (one status or all), date range, vehicle, operator or dispatch warehouse, **Then** only matching trips are shown. Clearing the filters returns to the opening state.
4. **Given** a row, **When** the user clicks it, **Then** the trip's screen opens, read-only unless the trip is Abierto and the user has Delivery Itineraries update.

---

### User Story 5 - Print the trip's papers (Priority: P2)

Before the van leaves, the dispatcher prints the trip ticket for the driver and the delivery notes for the customers to sign. Later, a supervisor reprints the notes of a closed trip to settle a dispute.

**Why this priority**: In 2026 the current system printed 3,846 trip tickets and 3,553 delivery notes. Drivers rely on them, but a trip can be planned, sent and closed without them.

**Independent Test**: Depart a trip, print both documents as a user with Delivery Itineraries read, and check that each previews and prints. Check that neither is offered on an Abierto or Cancelado trip.

**Acceptance Scenarios**:

1. **Given** an En ruta or Cerrado trip and a user with Delivery Itineraries read, **Then** "Imprimir ticket" and "Imprimir notas de entrega" are offered.
2. **Given** either is chosen, **Then** the server's document is previewed and can be printed, downloaded or shared, as with other documents (spec 044).
3. **Given** an Abierto or Cancelado trip, **Then** neither is offered.

---

### Edge Cases

- **A stop's order after a reload.** The server takes a stop's delivery order when the stop is added, but doesn't keep it (mbe-api#343). Until that ships, the app knows a stop's order in the session that added it, and otherwise works it out from the stop's loaded lines. A stop with no lines, loaded fresh, shows as "Parada N" with no customer. Loading lines onto it asks the user to pick the order again, from the same list as "Agregar parada".
- **Names arriving as numbers.** Vehicle, operator, warehouse, customer, ship-to and product arrive as numbers on trips, stops and lines until mbe-api#343 ships. The app looks each one up. When the user can't read that catalog, the app shows the number.
- **Licence warning text.** The server reports an expired licence as an English sentence with no error code. The app builds its own warning from the operator's licence expiry date, in the user's language, and doesn't show the server's text.
- **A vehicle moved onto a second open trip.** The server checks that a vehicle has only one Abierto trip when a trip is created, not when its vehicle is changed later. The app relies on the server and adds no check of its own, so changing a trip's vehicle can leave that vehicle on two open trips.
- **An empty stop on a departed trip.** The server would let a trip depart with a stop that has no lines, and that stop would then need proof to close. The app blocks departure until every stop has a line (US2 scenario 4).
- **Loading lines from another order onto a stop.** The server would accept any order's line on any stop. The app offers only the lines of the stop's own order. Two orders for the same address are two stops.
- **Two dispatchers loading the same line.** Exactly one wins. The other gets a refusal stating how much is still available, and the trip reloads.
- **The order changed since it was added.** If a stop's order was cancelled or moved out of En preparación after it was added, loading or departure is refused with the order's status, and the trip reloads.
- **Closing a stop twice.** A second close of the same stop is refused as already resolved, and the trip reloads to show the first result.
- **A facility with no in-transit location.** Departure is refused for the whole trip, and the app names the problem so an administrator can configure it.
- **Proof image too large or unsupported.** The form refuses anything other than jpg or png, or anything over 2 MB, before sending, and also shows the server's refusal if it gets one. A drawn signature is sent as an image within those limits.
- **The server is busy closing another stop.** Concurrent closes on one trip are serialised. A busy refusal says to try again, and nothing is recorded.
- **Network failure on an action.** The app says the result is unknown and reloads the trip, rather than claiming the action failed.
- **Edits after departure.** Header, stops and loads are read-only from En ruta on. Only closing stops and printing remain.

## Requirements *(mandatory)*

### Functional Requirements

**List**

- **FR-001**: The back office MUST offer an "Itinerarios" screen only to users with Delivery Itineraries read.
- **FR-002**: The list MUST show trips newest first, paginated. Each row shows number, date, vehicle, operator, dispatch warehouse, status as a badge, departure time and return time.
- **FR-003**: The list MUST filter by status (a single status or all), date range, vehicle, operator and dispatch warehouse. It has no free-text search, because the server offers none.
- **FR-004**: Clicking a row MUST open that trip's own screen.

**Create and header**

- **FR-005**: "Nuevo itinerario" MUST be offered only to users with Delivery Itineraries create. It creates the trip at once, with today's date and the dispatch warehouse from the user's point of sale unless they choose another, and opens its screen.
- **FR-006**: On an Abierto trip, a user with Delivery Itineraries update MUST be able to change date, vehicle, operator and comment. The dispatch warehouse MUST be shown read-only after creation.
- **FR-007**: When the assigned operator's licence has expired, the trip screen MUST show a warning with the expiry date. The warning doesn't block anything.

**Stops and loading**

- **FR-008**: "Agregar parada" MUST offer delivery-type orders in En preparación and add the chosen one as the trip's next stop.
- **FR-009**: Each stop MUST show its sequence, delivery order, customer, ship-to and loaded lines. Each line shows product code, product name, unit, the order's open quantity and the quantity loaded.
- **FR-010**: On a stop, the user MUST be able to load all open lines of its order at once ("Cargar todo"), or load one line with a quantity that defaults to its open quantity and is greater than 0 and at most that.
- **FR-011**: The user MUST be able to change a loaded line's quantity (greater than 0, at most open plus already loaded), and remove a loaded line or a whole stop after confirming. Removed quantities become open again.

**Departure and cancellation**

- **FR-012**: "Dar salida" MUST be offered on an Abierto trip, MUST ask for confirmation (vehicle, operator, stops, lines), and MUST stay disabled, with the reason shown, while nothing is loaded or any stop has no lines.
- **FR-013**: After departure, the trip MUST show En ruta, its departure time and each line's sent quantity, and MUST NOT offer header edits, stops or loading.
- **FR-014**: "Cancelar itinerario" MUST be offered only on an Abierto trip and MUST ask for confirmation. Afterwards the trip shows Cancelado.

**Closing stops**

- **FR-015**: "Cerrar parada" MUST be offered on each pending stop of an En ruta trip.
- **FR-016**: The close form MUST require receiver name and identification shown (free text, not blank), a delivered quantity per line from 0 up to what was sent (starting at what was sent), a reason for each line delivered below what was sent, and one proof.
- **FR-017**: The proof MUST be either an uploaded image (jpg or png, up to 2 MB) or a signature drawn on screen. The user can switch between the two before confirming, and only one is sent.
- **FR-018**: After a stop closes, it MUST show the server's outcome, each line's delivered and returned quantities and reason, and a link to its delivery order.
- **FR-019**: When the last pending stop closes, the trip MUST show Cerrado and its return time without a manual reload.

**Printing**

- **FR-020**: An En ruta or Cerrado trip MUST offer "Imprimir ticket" and "Imprimir notas de entrega" to users with Delivery Itineraries read, through the app's shared document preview. Abierto and Cancelado trips MUST NOT offer them.

**General**

- **FR-021**: Every action MUST be shown only to a user with the right it needs (see Assumptions), and only in the trip and stop statuses that allow it.
- **FR-022**: When the server refuses an action, the app MUST show the reason in the user's language, from the error code, and reload the trip.
- **FR-023**: Every new label, message, status name, outcome and reason MUST be available in Spanish and English.
- **FR-024**: Until mbe-api#343 ships, the app MUST resolve the names the server sends as numbers (vehicle, operator, warehouse, a stop's order, customer and ship-to, a line's product), falling back to the number when the user can't read that catalog. Once it ships, the app MUST use the server's names and keep the lookups only as a fallback.

### Key Entities

- **Itinerary (trip)**: one trip of one vehicle with one driver, leaving from one dispatch warehouse. It has a number, a date, an optional vehicle, an optional operator, a comment, its departure and return times, and a status:
  - Abierto: being planned; stops and loads can change;
  - En ruta: departed; the load is fixed; stops are being closed;
  - Cerrado: every stop resolved (terminal);
  - Cancelado: cancelled before departure (terminal).
- **Stop**: one delivery order's visit within a trip, with a sequence number and an outcome: Pendiente, Entregada, Entregada parcialmente or Fallida.
- **Loaded line**: a quantity of one delivery-order line on one stop. It tracks loaded (committed), sent (fixed at departure), delivered and returned quantities, plus a shortfall reason when delivered is below sent.
- **Shortfall reason**: Cliente rechazó, No había nadie, Dirección incorrecta, Mercancía dañada, Otro.
- **Proof of delivery**: receiver name, identification shown, one image (an uploaded picture or a drawn signature), who recorded it and when. It's kept on each delivery order at the stop.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A dispatcher can create a trip, assign vehicle and operator, add two orders as stops and load them in full in under 2 minutes.
- **SC-002**: A dispatcher can close a stop from returned paperwork, with an uploaded scan or a drawn signature, in under 1 minute.
- **SC-003**: Every delivery order in En preparación can be put on a trip, sent out and settled from the back office. None is left stuck in preparation or in transit for lack of a screen.
- **SC-004**: No stop can be closed without receiver name, identification, proof, and a reason for every shortfall.
- **SC-005**: In every walkthrough case, the trip screen offers exactly the actions the trip's status, each stop's outcome and the user's rights allow, and no others.
- **SC-006**: Users without Delivery Itineraries read don't see the screen. Users without update see no edit, load, departure, cancel or close action.

## Assumptions

- Rights follow the server. List, trip screen and printing need Delivery Itineraries (87) read. "Nuevo itinerario" needs create. Header edits, stops, loading, departure, cancellation and closing stops all need update. Nothing needs delete. Picking an order for a stop also needs Delivery Orders read, and following a closed stop's link to its proof is governed by spec 061's rights.
- The trip has nested stops, so it gets its own screen with its own route, not the shared side panel (constitution §VI).
- The dispatch warehouse is set only when a trip is created. The user input listed it among the header edits, but the server offers no way to change it later.
- The list has no free-text search, because the server's list takes only status, date range, vehicle, operator and warehouse. Legacy searched by number or customer, and that's dropped. Legacy's default of non-cancelled trips can't be expressed either (the server filters one status at a time), so the list opens on every status.
- Picking an order for a stop uses the delivery-order list filtered to En preparación and the delivery type, not the "Por entregar" queue (spec 063), which lists lines rather than orders.
- A stop is closed by back-office staff from the returned paperwork. Closing from the road, offline work and a driver's own view belong to mictlanix/mbe-roadmap#119.
- The server stores one proof image per stop, so a stop's proof is an uploaded image or a drawn signature, not both. A drawn signature is turned into an image before it's sent.
- Closing a stop has no comment field, because the server takes none.
- Approval, the "Por entregar" queue, delivery orders and their proof screen are specs 062, 063 and 061, and stay as they are. This feature's effects show up there as statuses, quantities and proof.
- Out of scope: the driver's mobile app, a map or route optimisation, reordering stops (the server numbers them in the order they're added), reopening a closed stop, changing a trip after departure, and bulk actions on several trips.

## Verbatim Constraints

- Server rules relied on:
  - `GET /delivery-itineraries` (filters `date_from`, `date_to`, `vehicle`, `vehicle_operator`, `warehouse`, `status`, `skip`, `limit`);
  - `POST /delivery-itineraries` (`date`, `vehicle`, `vehicle_operator`, `warehouse`, `comment`, all optional), `GET` and `PUT /delivery-itineraries/{id}` (`date`, `vehicle`, `vehicle_operator`, `comment`);
  - `POST /delivery-itineraries/{id}/cancel`, `/depart`;
  - `POST /delivery-itineraries/{id}/stops` (`delivery_order`, `comment`), `DELETE /delivery-itineraries/{id}/stops/{stop_id}`;
  - `POST .../stops/{stop_id}/lines` (`delivery_order_detail`, `quantity` optional, defaults to all open), `POST .../stops/{stop_id}/lines/all` (`delivery_order`), `PUT` and `DELETE .../stops/{stop_id}/lines/{line_id}`;
  - `POST .../stops/{stop_id}/close` (multipart: `receiver_name`, `receiver_id_shown`, `lines` as a JSON array of `{line, delivered_quantity, reason_code}`, `image`);
  - `GET /delivery-itineraries/{id}/ticket`, `/delivery-notes` (PDF; DEPARTED or CLOSED only).
- Status numbers: itinerary 0 OPEN, 1 DEPARTED, 2 CLOSED, 3 CANCELLED. Stop outcome 0 PENDING, 1 DELIVERED, 2 PARTIALLY_DELIVERED, 3 FAILED. Shortfall reason 0 CUSTOMER_REFUSED, 1 NOBODY_PRESENT, 2 WRONG_ADDRESS, 3 DAMAGED_GOODS, 4 OTHER.
- The trip closes itself, and records its return time, when its last pending stop is closed. There is no close-trip request.
- The licence warning arrives in `warnings` as uncoded English text.
- Proof image: at most 2 MB. The server stores it scaled to at most 1024 px wide.
- Error codes:
  - `itinerary.not_open`, `itinerary.not_departed`, `itinerary.cancelled`, `itinerary.nothing_committed`, `itinerary.lines_overcommitted` (detail lists the lines);
  - `itinerary.stop_already_resolved`, `itinerary.stop_lines_incomplete`, `itinerary.stop_lines_malformed`, `itinerary.stop_delivered_exceeds_sent` (`line_id`, `sent`, `delivered`), `itinerary.stop_shortfall_needs_reason` (`line_id`);
  - `vehicle.open_itinerary_exists` (`vehicle_id`, `itinerary_id`);
  - `delivery_order.not_in_preparation` (`status`), `delivery_order.pickup_not_loadable`, `delivery_order_line.nothing_to_load`, `delivery_order_line.quantity_unavailable` (`available`, `requested`);
  - `facility.no_in_transit_location`, `image.too_large`, `image.unsupported_format`, `lock.busy`, `resource.not_found`.
- Pending server change: mictlanix/mbe-api#343 (keep a stop's delivery order; names on stops, lines and trip rows).
- Known server gaps, relied on as they are: the one-open-trip-per-vehicle check runs only at creation; departure doesn't refuse a stop with no lines.
