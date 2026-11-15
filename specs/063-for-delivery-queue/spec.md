# Feature Specification: For Delivery Queue

**Feature Branch**: `063-for-delivery-queue`

**Created**: 2026-11-15

**Status**: Draft

**Input**: User description: mictlanix/mbe-roadmap#40 ([UI] For delivery queue). Scope 06 §6.3 (legacy "For Delivery (Pending Deliveries)", mbe-api `docs/specs/06-logistics.md` §3; SystemObject ForDeliver 91). Server side done in mbe-api spec 012, User Story 3. Weight: 2 legacy actions. Builds on spec 061 (Órdenes de entrega) and spec 062 (Aprobación de entregas).

Once a delivery order is confirmed (spec 061) and, where required, approved (spec 062), it sits in En preparación until its goods are loaded onto a truck. Warehouse staff need to see what is waiting to go out and when it's due, so they can plan the day's routes. Nothing in the new app shows that today.

In the current system, warehouse staff open "Por entregar". It shows every delivery line still waiting to be loaded, split into tabs by scheduled date around today, with the most urgent orders first. This feature brings that view to the back office.

## Clarifications

### Session 2026-11-15

- Q: The legacy screen had "Add to Itinerary" and "Mark Picked Up". Does this spec include committing lines to an itinerary? → A: No. The queue is read-only. Committing lines to an open itinerary ships with the itineraries feature (mictlanix/mbe-roadmap#41), which can add the action to this queue. "Mark Picked Up" is gone: the server never puts counter pickups in this queue.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - See today's pending deliveries (Priority: P1)

A warehouse coordinator opens "Por entregar" first thing in the morning. The screen opens on the "Hoy" tab and lists every delivery line scheduled for today that hasn't been fully loaded yet, highest priority first. Each row shows the order folio, customer, ship-to, product, warehouse, priority and the quantity still to load. The tab labels show how many lines each one holds, so the coordinator sees at a glance that yesterday's tab still has 4 lines left behind.

**Why this priority**: This is the whole feature. Without it, warehouse staff can't see what's waiting to go out in the new app.

**Independent Test**: Confirm (and approve, if required) a delivery order scheduled for today with two lines. Open "Por entregar" as a user with ForDeliver read. Check that the "Hoy" tab is selected, both lines appear with their full quantities as open, and the tab count includes them.

**Acceptance Scenarios**:

1. **Given** a user with ForDeliver read, **When** they open the back-office navigation, **Then** "Por entregar" is offered in the Logística group. Without that right it isn't, and its route is blocked.
2. **Given** the screen opens, **When** it loads, **Then** it shows six tabs in this order: Anteriores, Ayer, Hoy, Mañana, Pasado mañana, Posteriores. "Hoy" is selected. Each tab label shows its line count, and the four single-day tabs also show their date.
3. **Given** a tab, **When** it's shown, **Then** it lists the delivery lines in that date range that still have quantity to load, sorted by priority, highest first. Each row shows folio, customer, ship-to, scheduled date, priority, product code and name, warehouse, and open quantity.
4. **Given** a line partly committed to an itinerary, **When** the queue loads, **Then** its row shows only the quantity still open. A fully committed line doesn't appear.
5. **Given** a tab with more lines than fit on a page, **When** it's shown, **Then** it's paginated with the tab's total in the pagination footer.

---

### User Story 2 - Look ahead and behind (Priority: P2)

On Thursday afternoon the coordinator switches to "Mañana" and "Pasado mañana" to see how heavy Friday and Saturday will be, then checks "Anteriores" for anything overdue that never went out. An overdue line shows its original scheduled date so they can tell how late it is.

**Why this priority**: Planning ahead and catching overdue deliveries is the second reason the legacy screen exists, but today's tab alone already delivers value.

**Independent Test**: Have pending delivery lines scheduled three days ago, yesterday, tomorrow, the day after, and a week from now. Check each one lands in its tab (Anteriores, Ayer, Mañana, Pasado mañana, Posteriores) and shows its scheduled date.

**Acceptance Scenarios**:

1. **Given** a delivery line scheduled before yesterday, **When** the user opens "Anteriores", **Then** it's listed with its scheduled date.
2. **Given** a delivery line scheduled more than two days ahead, or with no scheduled date, **When** the user opens "Posteriores", **Then** it's listed. A line with no date says so instead of showing a date.
3. **Given** an empty tab, **When** the user opens it, **Then** it says there are no deliveries pending for that period.
4. **Given** the user switches tabs, **When** they come back to a tab, **Then** it's on the page they left it at.

---

### User Story 3 - Open the delivery order behind a line (Priority: P2)

The coordinator sees a line for 40 bags of cement with priority 5 and wants to check the delivery address notes. They tap the row and the delivery order's detail screen opens (spec 061). When they go back, the queue is on the same tab and page, refreshed.

**Why this priority**: A row shows one line. Deciding how to load a truck often needs the whole order.

**Independent Test**: As a user with ForDeliver read and Delivery Orders read, tap a row. Check that the matching delivery order opens. Go back and check the tab and page are kept.

**Acceptance Scenarios**:

1. **Given** a user with Delivery Orders read, **When** they tap a row, **Then** the delivery order's detail screen from spec 061 opens.
2. **Given** a user without Delivery Orders read, **When** they view the queue, **Then** rows aren't tappable. The queue still shows everything on the row.
3. **Given** the user returns from the detail screen, **When** the queue is shown again, **Then** it reloads and keeps the selected tab and page. If the order was cancelled or sent back meanwhile, its lines are gone.
4. **Given** the queue is open, **When** the user uses the refresh action, **Then** it reloads every tab and keeps the selected tab and page.

---

### Edge Cases

- **Approval required but not given.** Orders still in Pendiente de aprobación aren't in the queue. They appear once approved (spec 062).
- **Counter pickups.** Pickup orders never appear here, at any status. They're handed over at the counter, not loaded.
- **Cancelled or returned to draft.** An order cancelled or rejected back to draft leaves the queue on the next reload.
- **Disabled facility.** Lines of orders at a disabled facility don't appear.
- **Other facilities.** The server lists pending lines from every active facility, not just the user's. Each row shows its warehouse so staff can tell which lines are theirs.
- **Day boundary.** Tabs are computed by the server from its current date. A screen left open past midnight shows yesterday's split until it reloads.
- **Page past the end.** If lines leave a tab while the user is on its last page and that page becomes empty, the tab moves back to its last non-empty page.
- **Server unavailable.** The queue shows the standard load error with a retry, and keeps the selected tab.
- **Very large backlog.** "Anteriores" may hold hundreds of overdue lines; it's paginated like any other tab.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The app MUST offer "Por entregar" in the back-office Logística group, gated on ForDeliver (SystemObject 91) read. The route MUST be blocked without that right.
- **FR-002**: The screen MUST show six date tabs in the server's order: Anteriores (before yesterday), Ayer, Hoy, Mañana, Pasado mañana, Posteriores (later than the day after tomorrow, or no date). "Hoy" MUST be selected when the screen opens.
- **FR-003**: Each tab label MUST show the tab's total line count. The four single-day tabs MUST also show their date.
- **FR-004**: Each tab MUST list the pending delivery lines the server returns for it, in the server's order (priority, highest first).
- **FR-005**: Each row MUST show the order folio, customer name, ship-to address, scheduled date, priority, product code and name, warehouse name, and open quantity. Open quantity MUST be formatted like other quantities in the app.
- **FR-006**: Each tab MUST be paginated with the shared pagination component, showing the tab's total. Each tab MUST keep its own page while the user switches tabs.
- **FR-007**: The selected tab and its page MUST be kept in the screen's URL, so reloading or sharing the link reopens the same view.
- **FR-008**: The screen MUST offer a refresh action that reloads every tab and keeps the selected tab and page. Returning from a delivery order's detail screen MUST reload the queue the same way.
- **FR-009**: With Delivery Orders (SystemObject 71) read, tapping a row MUST open that delivery order's detail screen (spec 061). Without it, rows MUST NOT be tappable.
- **FR-010**: The queue MUST be read-only. It MUST NOT offer actions that change a delivery order or commit lines to an itinerary.
- **FR-011**: The screen MUST NOT show a search box or facet filters: the server offers none for this queue. The filter row MUST hold only the screen's actions (refresh).
- **FR-012**: An empty tab MUST say there are no deliveries pending for that period. A load failure MUST show the standard error with a retry.
- **FR-013**: All user-visible text MUST be localized (Spanish and English), and API errors MUST be shown from their error codes as elsewhere in the app.

### Key Entities

- **Pending delivery line**: one line of a delivery order in En preparación that still has quantity to load. Carries the order (id, folio, customer, ship-to, scheduled date, priority), the product (id, code, name), the warehouse it ships from, and the open quantity: the line's quantity minus what's committed to non-cancelled itineraries.
- **Date bucket (tab)**: one of six fixed date ranges relative to the server's today, with its date (for single-day buckets), its total line count, and a page of its lines.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A warehouse user can see how many lines are pending for today, yesterday and the next two days within 5 seconds of opening the screen, without changing tabs.
- **SC-002**: Every line the server reports as pending appears in exactly one tab, with the same open quantity the server reports, for a test set covering all six tabs.
- **SC-003**: From any row, a user with Delivery Orders read reaches the full delivery order in one tap and returns to the same tab and page.
- **SC-004**: Users without ForDeliver read can't reach the screen by navigation or by URL.
- **SC-005**: The legacy "For Delivery" view is covered: date tabs, priority order, and remaining quantities match what the legacy screen shows for the same data, apart from counter pickups, which the new flow leaves out by design.

## Assumptions

- The server's pending-deliveries query defines what's in the queue (orders in En preparación, delivery type, active facility, open quantity above zero). The app doesn't filter further.
- The queue spans every active facility, as in the legacy screen. Scoping it to the user's facility would need a server filter; if wanted, it's a follow-up for mbe-api.
- Customer, ship-to, and warehouse names aren't in the server's response, only their ids. The app resolves them the way spec 061 does.
- Page size follows the app's default for list screens, within the server's maximum of 100 per tab.
- Committing lines to an itinerary, and the itinerary screens themselves, are out of scope (mictlanix/mbe-roadmap#41).
- Printing the queue is out of scope; the legacy screen had no print.
- The Compact (phone) layout follows the shared table's existing behavior; no phone-specific design is added.
