# Delivery Itineraries Research & Design Foundation

**Status**: Future-release scope — for POS driver-facing mobile execution layer  
**Date**: 2026-08-15  
**Source**: mbe-api generated OpenAPI client + data models

---

## 1. Feature Overview

**Delivery itineraries** are driver-executed delivery routes. They bridge the warehouse (POS, creating delivery orders) and the driver (fulfilling those orders stop-by-stop).

**Lifecycle**: Warehouse creates → assigns vehicle/driver → driver departs → executes stops (commit lines, adjust, close) → returns → finalized with proof of delivery.

**Not an MBE feature yet** — planned for "delivery routing, itineraries, driver assignment and proof of delivery." This research prepares UI/spec design.

---

## 2. Core Data Model

### Itinerary (Route-level)
```dart
ItineraryResponse {
  int deliveriesItineraryId;        // PK
  Date date;                         // Delivery date (all stops occur this day)
  int? vehicle;                      // Vehicle ID (optional until assigned)
  int? vehicleOperator;              // Driver/operator ID (optional until assigned)
  int? warehouse;                    // Shipping warehouse (optional)
  ItineraryStatus status;            // 0-3: trip lifecycle (see § 2.2)
  DateTime? departureTime;           // When driver left
  DateTime? returnTime;              // When driver returned
  String? comment;                   // Notes (e.g., "high-traffic area expected")
  List<ItineraryStop> stops;         // Ordered list of deliveries
  List<String>? warnings;            // API warnings (e.g., "stop 5 partially delivered")
}
```

**Create payload** (warehouse → API):
```dart
ItineraryCreate {
  Date? date;                        // Optional (defaults to today?)
  int? vehicle;                      // Assign now or later
  int? vehicleOperator;              // Assign now or later  
  int? warehouse;                    // Where goods originate
  String? comment;
}
```

### Itinerary Status (FR-033a)
**4 states** — the trip lifecycle (wire values 0-3):
- `OPEN` (0) — itinerary created, stops/commitments can be added or removed
- `DEPARTED` (1) — driver left warehouse; stops/commitments frozen, goods in transit
- `CLOSED` (2) — **terminal** — all stops resolved
- `CANCELLED` (3) — **terminal** — cancelled before departure (commitments released)

**State machine**:
```
OPEN ──[depart]──► DEPARTED ──[all stops resolve]──► CLOSED (terminal)
  │
  └──[cancel]────► CANCELLED (terminal, only from OPEN)
```

**Key constraint (FR-034)**: At most one `OPEN` itinerary per vehicle at any time.

---

### Stop (Individual Delivery)
```dart
ItineraryStopResponse {
  int deliveriesItineraryStopId;    // PK
  int sequence;                      // Route order (1, 2, 3...)
  DateTime? arrivalTime;             // When driver arrived
  StopOutcome outcome;               // 0-3: how it resolved (see § 2.3)
  int? proofOfDelivery;              // Document/photo ID reference? (FKey?)
  String? comment;                   // Receiver notes, delivery notes
  List<ItineraryLine> lines;         // Lines assigned to this stop
}
```

**Create payload**:
```dart
StopCreate {
  int deliveryOrder;                 // FKey: the order being delivered
  String? comment;
}
```

### Stop Outcome
**4 outcomes** — how a stop resolved (wire values 0-3):
- `PENDING` (0) — stop not yet closed
- `DELIVERED` (1) — all lines fully accepted
- `PARTIALLY_DELIVERED` (2) — some lines short/refused, some accepted
- `FAILED` (3) — entire stop failed (nobody present, wrong address, etc.)

---

### Line (Order Line at a Stop)
```dart
ItineraryLineResponse {
  int deliveriesItineraryDetailId;   // PK
  int deliveryOrderDetail;           // FKey: the order line being delivered
  String committedQuantity;          // "10 units" — what driver committed to deliver
  String sentQuantity;               // What left the warehouse (may differ if short)
  String deliveredQuantity;          // What customer received
  String returnedQuantity;           // What came back (damage, refusal, partial)
  ShortfallReason? reasonCode;       // Why less was delivered (see § 2.4)
  String? comment;                   // "Customer refused," "damaged in transit"
}
```

**Operations**:
```dart
// Claim a line for this stop (driver says "I'll deliver this")
CommitLineRequest {
  int deliveryOrderDetail;           // Which line
  Quantity? quantity;                // Qty to commit (null = full open quantity, per FR-037)
  String? comment;
}

// Modify a claimed line (driver adjusts after commitment)
CommitLineUpdate {
  Quantity quantity;                 // New qty (required, must be > 0)
}

// Claim every open line of one delivery order in a single call (FR-038)
CommitOrderRequest {
  int deliveryOrder;                 // Which order (all open lines in this order)
}
```

### Shortfall Reason (Why Line Fell Short)
**5 reasons** — required when `deliveredQuantity < sentQuantity` on a line (wire values 0-4):
- `CUSTOMER_REFUSED` (0) — customer declined goods
- `NOBODY_PRESENT` (1) — no one at address to receive
- `WRONG_ADDRESS` (2) — delivery address incorrect/inaccessible
- `DAMAGED_GOODS` (3) — goods damaged/contaminated in transit
- `OTHER` (4) — reason not in above list

**Note**: Same set of reasons used for both per-line shortfalls and whole-stop failures.

---

## 3. API Operations (14 endpoints)

### Route Management

| Operation | HTTP | Input | Output | Purpose |
|-----------|------|-------|--------|---------|
| `createItinerary` | POST `/api/v1/delivery-itineraries` | `ItineraryCreate` | `ItineraryResponse` | Warehouse creates route |
| `updateItinerary` | PUT `/api/v1/delivery-itineraries/{id}` | `ItineraryUpdate` | `ItineraryResponse` | Edit route (vehicle/driver/comment) |
| `listItineraries` | GET `/api/v1/delivery-itineraries?dateFrom=…&dateTo=…&vehicle=…&vehicleOperator=…&warehouse=…&status=…&skip=…&limit=…` | Query params | `ListResponseItinerarySummary` | List routes by filters |
| `getItinerary` | GET `/api/v1/delivery-itineraries/{id}` | Route ID | `ItineraryResponse` | Fetch route + all stops/lines |
| `cancelItinerary` | POST `/api/v1/delivery-itineraries/{id}/cancel` | — | `ItineraryResponse` | Cancel entire route (e.g., vehicle breakdown) |

### Route State

| Operation | HTTP | Input | Output | Purpose |
|-----------|------|-------|--------|---------|
| `depart` | POST `/api/v1/delivery-itineraries/{id}/depart` | — | `ItineraryResponse` | Driver ready to leave (status transition?) |

### Stop Management

| Operation | HTTP | Input | Output | Purpose |
|-----------|------|-------|--------|---------|
| `addStop` | POST `/api/v1/delivery-itineraries/{id}/stops` | `StopCreate` | `ItineraryResponse` | Add a delivery to the route |
| `removeStop` | DELETE `/api/v1/delivery-itineraries/{id}/stops/{stopId}` | Stop ID | `ItineraryResponse` | Remove stop (before execution?) |
| `closeStop` | POST `/api/v1/delivery-itineraries/{id}/stops/{stopId}/close` | `receiverName`, `receiverIdShown`, `lines`, `image` (multipart) | `ItineraryResponse` | Mark stop delivered; **multipart form** to include signature photo atomically with outcomes |

### Line Operations (Execution)

| Operation | HTTP | Input | Output | Purpose | Note |
|-----------|------|-------|--------|---------|------|
| `commitLine` | POST `/api/v1/…/{stopId}/lines` | `CommitLineRequest` | `ItineraryResponse` | Driver claims a line for delivery | **Row lock** — concurrent callers race (SC-004) |
| `adjustCommitment` | PUT `/api/v1/…/{stopId}/lines/{lineId}` | `CommitLineUpdate` | `ItineraryResponse` | Driver changes qty after committing | E.g., discovered partial stock |
| `releaseCommitment` | DELETE `/api/v1/…/{stopId}/lines/{lineId}` | Line ID | `ItineraryResponse` | Driver unclaims line (decision change) | |
| `commitWholeOrder` | POST `/api/v1/…/{stopId}/lines/all` | `CommitOrderRequest` | `ItineraryResponse` | Claim all lines at once (fast path) | |

### Reporting

| Operation | HTTP | Input | Output | Purpose |
|-----------|------|-------|--------|---------|
| `pendingDeliveries` | GET `/api/v1/delivery-itineraries/deliveries?skip=…&limit=…` | Skip/limit (applied per bucket) | `PendingDeliveriesResponse` | Dashboard: lines grouped into 6 date buckets; **each bucket independently paginated** (FR-030–FR-032) |

**Six buckets** (by scheduled delivery date, FR-031):
1. **earlier than yesterday** — older outstanding lines
2. **yesterday** 
3. **today**
4. **tomorrow**
5. **day after tomorrow**
6. **later** — future deliveries

Each bucket contains:
```dart
PendingDeliveryBucket {
  String key;                        // Bucket identifier (e.g., "today")
  Date? date;                        // Reference date (null for "earlier" or "later")
  List<PendingDeliveryLine> items;   // Lines in this bucket
  int total;                         // Total count in bucket (for pagination)
}

PendingDeliveryLine {
  int deliveryOrder;
  int deliveryOrderDetail;
  int? serial;
  int customer;
  int? shipTo;
  DateTime? date;
  int priority;
  int product;
  String productCode;
  String productName;
  int warehouse;
  Quantity openQuantity;             // Amount still to be delivered
}
```

**Sorting**: Lines within each bucket sorted by sales order priority (highest first, FR-031).

---

## 4. Known Constraints & Behaviors

### Concurrency
- **commitLine has row locks** — exactly one driver wins when two commit the same line simultaneously (SC-004). Loser gets a conflict error.
- **Workflow implication**: UI must handle optimistic-lock conflicts; driver sees "someone else claimed this" → shows updated itinerary state.

### Stop Closure (closeStop - Multipart Form)
Proof + per-line outcome bundled atomically — signature/photo cannot separate from delivery decisions (FR-043).

**Request payload**:
```dart
StopClosureRequest {
  String receiverName;               // Non-blank (FR-043)
  String receiverIdShown;            // ID type shown (e.g., "DNI", "Passport")
  List<StopClosureLine> lines;       // Per-line outcomes
}

StopClosureLine {
  int line;                          // deliveries_itinerary_detail ID
  Quantity deliveredQuantity;        // >= 0; the amount accepted
  ShortfallReason? reasonCode;       // Required if deliveredQuantity < sentQuantity (FR-045)
}
```

**Multipart HTTP form**:
- `receiverName` — form field
- `receiverIdShown` — form field
- `lines` — JSON form field (serialized list of StopClosureLine)
- `image` — file upload (signature photo; UUID filename, never content-addressed, FR-044b)

**Implementation note**: Flutter `MultipartFile` + `Dio` required; standard JSON/content-type won't work.

### Quantity Tracking Invariant (SC-003)
Every delivery-order line maintains at all times:
```
quantity = delivered_quantity + returned_quantity + committed_quantity + open_quantity
```

**Four quantities per line**:
- **sent_quantity**: Fixed at itinerary departure (how much left warehouse)
- **committed_quantity**: Reserved when driver commits; frozen through `IN_TRANSIT`, released at closure
- **delivered_quantity**: What customer accepted (backed by POD)
- **returned_quantity**: What was refused/damaged (back in warehouse or new child order)

**Key rule**: `delivered + returned + committed + open` must always equal `quantity`. Used to guard against double-commitment (SC-004).

### Commitments & Inventory
- **Committed quantity protects against double-sell** while goods are in transit (prevents warehouse from re-selling goods on truck).
- **Released only at closure**, not at departure — goods still belong to delivery order during transit.
- **If itinerary cancelled** (only possible from `OPEN`), all commitments released back to `open_quantity`.

### Proof of Delivery (POD)
- **Signature/photo required** to close a stop (FR-043) — structured fields + image bundled atomically.
- **One POD per stop** can cover multiple delivery orders (if several dropped at same address).
- **Authenticated retrieval only** — image stored with UUID filename outside public static mount.
- **Personal data consideration** — signature is user-specific; never content-addressed.

---

## 5. Resolved: All Enums & Key Data Structures

**✅ RESOLVED from mbe-api source** (`specs/012-delivery-logistics-endpoints/`):

### ItineraryStatus Enum (FR-033a)
- **OPEN** (0) — created, can add/remove stops & commitments
- **DEPARTED** (1) — driver left warehouse, stops frozen, goods in transit
- **CLOSED** (2) — terminal, all stops resolved
- **CANCELLED** (3) — terminal, cancelled from OPEN only (commitments released)

### StopOutcome Enum
- **PENDING** (0) — stop not closed
- **DELIVERED** (1) — all lines fully accepted
- **PARTIALLY_DELIVERED** (2) — some lines short/failed, some accepted
- **FAILED** (3) — entire stop failed (nobody home, wrong address, etc.)

### ShortfallReason Enum (Required when delivered < sent, per FR-045)
- **CUSTOMER_REFUSED** (0) — customer declined
- **NOBODY_PRESENT** (1) — no one at address
- **WRONG_ADDRESS** (2) — address incorrect/inaccessible
- **DAMAGED_GOODS** (3) — damaged in transit
- **OTHER** (4) — none of above

### ItineraryUpdate (Mutable Fields)
```dart
ItineraryUpdate {
  Date? date;
  int? vehicle;
  int? vehicleOperator;
  String? comment;
}
```
**Cannot change**: warehouse (snapshotted at creation).

### Data Precision
- **Quantities**: `Decimal(18,4)` on delivery order lines, `Decimal(20,6)` on itinerary lines.
- **Supports**: Fractional units (e.g., "2.5 boxes" or "1500.5000 grams").

### Immutable-After-Creation Constraints
- **fulfillment_type** — set at creation, cannot change (DELIVERY vs COUNTER_PICKUP).
- **warehouse** — snapshotted at delivery-order creation.

---

## 6. UI Considerations & Questions

### For Warehouse (Creating/Assigning Routes)
- **Route creation form**: 
  - Optional fields (vehicle, operator, warehouse, comment) — how early assign?
  - Date picker (today by default?).
  - Dynamic stop-adding form or create empty → add stops next?

- **Route list + filtering**:
  - Date range, vehicle, operator, status, warehouse.
  - Paginate or load-more for large result sets?
  - Summary view or full stops expanded?

- **Assignment workflow**:
  - Drag vehicle/operator into route? Or modal form?
  - Can change mid-execution? Business rule?

### For Driver (Mobile Execution)
- **Route detail screen**:
  - Map view of stops (if lat/lng available on delivery orders)?
  - List of stops by sequence; each shows delivery address, items, status.
  
- **Stop-by-stop workflow**:
  1. Arrive at address → tap "Arrive" → confirm address, take photo of location.
  2. List lines at stop; for each: **commit**, **adjust qty** (if stock mismatch), or **release**.
  3. Once committed, drive order → show total committed vs. order total (progress bar?).
  4. When done: **close stop** → multipart form: receiver name, ID shown, per-line outcome + reason, signature photo.
  5. Move to next stop.

- **Pending dashboard**:
  - Six buckets (statuses) horizontally scrollable? Tabs?
  - Each bucket paginated independently.
  - Tap to open route detail or assign.

- **Error handling**:
  - Concurrent lock failure → "Another driver claimed this line. Refresh?" → fetch updated itinerary.
  - Network offline → queue operations? Or fail and require refresh?
  - Partial failures (stop closes but one line fails) → retry UI.

- **Proof of delivery**:
  - How is photo captured? (Camera app, built-in camera widget?)
  - Where stored? (Cloud? Local cache until sync?)
  - Signature widget vs. photo? (Both? Either?)

### Data Dependencies
- **Vehicle/operator dropdowns**: Pull from existing master data (populated via spec 013?).
- **Delivery order details**: Existing system (spec 026 — POS delivery step creates these).
- **Warehouse list**: Existing master data.
- **Address/contact for stops**: Embedded in delivery order destination (from spec 026).

---

## 7. Related Specs & Features

### Predecessors (Must Be Complete First)
- **Spec 013 — Catalog Logistics Entities**: Vehicles, vehicle operators, warehouses.
- **Spec 026 — POS Delivery Step UX**: Creates delivery orders & destinations (what itineraries execute).

### Related Future Work
- **Driver assignment**: Likely a warehouse feature (assign operator to itinerary before depart).
- **Route optimization**: Sequencing stops for efficiency (AI/solver?).
- **Real-time tracking**: Driver location broadcast (WebSocket? Periodic polling?).
- **Integration with order status**: Closing stop updates order status to "delivered" or "failed."

---

## 8. Spec Writing Checklist

### Research Tasks
- [ ] Get mbe-api source code (or run `/openapi.json`) to extract:
  - [ ] Enum friendly names for ItineraryStatus, StopOutcome, ShortfallReason.
  - [ ] Full structure of CommitOrderRequest.
  - [ ] Structure of PendingDeliveriesResponse (what are the 6 buckets?).
  - [ ] ItineraryUpdate fields (what's mutable?).
  - [ ] Field constraints (qty precision, max string lengths, required vs optional).
  - [ ] Error codes & semantics (409 conflict for lock? 422 validation? 400 qty precision?).

- [ ] Legacy system (mbe C# docs) context:
  - [ ] How were itineraries managed in the old system?
  - [ ] Proof of delivery — signature vs. photo? Both?
  - [ ] Typical route size (5, 10, 50 stops per driver per day?).
  - [ ] Multipart photo storage — where? Size limits?

- [ ] Business requirements (from stakeholders/PMO):
  - [ ] Is this driver-mobile-only, or web also?
  - [ ] Offline-first? Queue operations while offline?
  - [ ] Can driver view live itinerary state (another driver just closed a stop)?
  - [ ] Reporting/analytics — how many delivered/failed/partial per day?
  - [ ] Handoff to accounting/invoicing — when does "delivered" trigger invoice flow?

### Spec Structure (Proposal)
```
spec.md
├─ 1. Overview (feature purpose, driver workflow, warehouse workflow)
├─ 2. User Stories (create route, assign driver, execute stops, track, dashboard)
├─ 3. Data Model (with resolved enum names)
├─ 4. API Contract (endpoint semantics, error cases, concurrency)
├─ 5. UI Flows (wireframes/screens by story)
├─ 6. Localization Inventory
├─ 7. Accessibility & Mobile Considerations

research.md (this file + findings)
├─ Field constraints & validation rules
├─ Enum mappings (0→"Pending", etc.)
├─ Proof of delivery capture (signature vs. photo vs. both?)
├─ Offline behavior & sync strategy
├─ Concurrency conflict recovery (UX for lock failures)

plan.md + tasks.md
├─ Phase 1: Repository layer (wrapper around itinerary API)
├─ Phase 2: Warehouse route-mgmt screens (create, list, assign, update)
├─ Phase 3: Driver mobile screens (route detail, stop workflow, close, dashboard)
├─ Phase 4: Polish (tests, analytics hooks, offline sync)
```

---

## 9. Remaining Design Questions

### Proof of Delivery Capture
1. **Signature pad or photo** — both work per API, which for MVP?
   - Signature: Legal proof, handwritten ID
   - Photo: Easier on mobile, proof of location/packaging
   - **Decision needed**: One or both? Or configurable per tenant?

2. **Receiver ID capture**
   - What formats (DNI, Passport, License Plate, other)?
   - Autocomplete from customer DB or freeform?

3. **Receiver name**
   - Required non-blank — should pre-populate from customer contact info?

### Driver Mobile UX
4. **Offline operation**
   - Should driver queue commitments if network drops?
   - Or fail gracefully and retry when back online?

5. **Map integration**
   - Is there an address/lat-lng on delivery orders for mapping stops?
   - Route optimization (sequencing stops) in scope for MVP?

6. **Progress tracking**
   - Show % complete (committed vs. total) per stop/itinerary?
   - Visual feedback for locked lines (another driver claimed)?

### Warehouse / Dispatcher UX
7. **Route creation workflow**
   - Can create empty itinerary → add stops later?
   - Or must add at least one stop at creation?

8. **Assignment timing**
   - Assign vehicle/driver now or later (before departure)?
   - Can reassign after creation but before departure?

9. **Split delivery handling**
   - When a line is only partially delivered, does POS create a child order automatically?
   - Or is that backend-only, invisible to UI?

10. **Integration with POS delivery orders**
    - Does closing a stop/itinerary update the POS order status?
    - Or is itinerary a separate tracking system?

### Scale & Performance
11. **Expected route sizes**
    - Typical stops per itinerary? (5-20? 50-100?)
    - Affects pagination/scroll vs. virtual list strategy.

12. **Pending deliveries dashboard**
    - Each bucket independently paginated — what default page size per bucket?
    - Need filters (vehicle, operator, facility) in addition to date buckets?

---

## 10. Resources

### In This Repo (mbe-ui)
- **Generated OpenAPI client**: `lib/generated/openapi/lib/src/api/delivery_itineraries_api.dart` (14 endpoints)
- **Data models**: `lib/generated/openapi/lib/src/model/itinerary_*.dart`, `stop_*.dart`, `commit_*.dart`
- **Enums**: Now resolved; see §5 above.
- **Related feature**: `specs/026-pos-delivery-ux/` (creates delivery orders that itineraries execute)

### In mbe-api Repo (Source of Truth)
- **Specification**: `specs/012-delivery-logistics-endpoints/spec.md` (complete feature spec)
- **Data model**: `specs/012-delivery-logistics-endpoints/data-model.md` (schema, enums, invariants)
- **Python schemas**: `app/schemas/delivery_itinerary.py` (Pydantic models, actual API contracts)
- **Python enums**: `app/enums.py` (DeliveryOrderStatus, ItineraryStatus, StopOutcome, ShortfallReason)
- **Service layer**: `app/services/delivery_itinerary_service.py` (business logic, concurrency, validation)
- **Integration tests**: `tests/integration/test_itinerary_flow.py` (real workflow scenarios)

### Research & Context
- **Legacy system docs**: `../mbe/docs/specs/06-logistics.md` and `06a-delivery-flow-v2.md` (reference only; v2 takes precedence)
- **Known issues**: See mbe-api `specs/012-delivery-logistics-endpoints/research.md` for detailed decisions (especially on concurrency, quantity tracking, POD storage)

---

## Next Steps

✅ **Research phase complete.** All enums resolved, data structures confirmed, API contracts documented.

**Ready for design phase**:

1. **Answer the 12 remaining design questions** (§9) — scope decisions for MVP (POD capture, offline, split delivery, integration points).
2. **Interview stakeholders** on workflows — warehouse dispatch process, driver handoff, integration with POS order status.
3. **Map user stories** to the two main personas:
   - **Warehouse dispatcher**: Create routes, assign vehicles/drivers, monitor progress
   - **Field driver**: Execute stops, commit lines, capture POD, handle conflicts
4. **Create wireframes** for key flows:
   - Route creation & assignment (warehouse)
   - Stop-by-stop execution (driver)
   - Pending deliveries dashboard (both personas)
   - Stop closure with multipart POD form (driver)
5. **Draft spec.md** with:
   - User stories (building on the 5 major user stories already in mbe-api spec)
   - Data model (now fully documented in §2 & §5)
   - API contract (14 endpoints documented in §3, all in mbe-api)
   - UI flows & wireframes
   - Localization inventory (new labels for itinerary/stop/POD concepts)
6. **Reference mbe-api data-model.md** — database schema is already complete; just document what the UI needs to know.
