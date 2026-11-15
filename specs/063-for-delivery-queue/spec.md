# Feature Specification: For Delivery Queue

**Feature Branch**: `063-for-delivery-queue`

**Created**: 2026-11-15

**Status**: Draft

**Input**: User description: mictlanix/mbe-roadmap#40 ([UI] For delivery queue). Scope 06 §6.3 (legacy "For Delivery (Pending Deliveries)", mbe-api `docs/specs/06-logistics.md` §3; SystemObject ForDeliver 91). Server side done in mbe-api spec 012, User Story 3. Weight: 2 legacy actions. Builds on spec 061 (Órdenes de entrega) and spec 062 (Aprobación de entregas).

Once a delivery order is confirmed (spec 061) and, where required, approved (spec 062), it sits in En preparación until its goods are loaded onto a truck. Warehouse staff need to see what is waiting to go out and when it's due, so they can plan the day's routes. Nothing in the new app shows that today.

In the current system, warehouse staff open "Por entregar". It shows every delivery line still waiting to be loaded, split by scheduled date around today, with the most urgent orders first. This feature brings that view to the back office. The legacy screen's date tabs become a period filter, using the app's shared filter panel.

## Clarifications

### Session 2026-11-15

- Q: The legacy screen had "Add to Itinerary" and "Mark Picked Up". Does this spec include committing lines to an itinerary? → A: No. The queue is read-only. Committing lines to an open itinerary ships with the itineraries feature (mictlanix/mbe-roadmap#41), which can add the action to this queue. "Mark Picked Up" is gone: the server never puts counter pickups in this queue.
- Q: The legacy screen splits the lines into date tabs. Tabs, or the app's filters? → A: Filters. The date period is a facet, so it goes in the shared filter panel (constitution §VI) as a single-select "Periodo", defaulting to Hoy. Each period's count shows in the panel. No refresh button: like Órdenes de entrega, the list reloads when the filter changes and when the user returns from an order. Every row shows its scheduled date, so the selected period is visible from the list itself.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - See today's pending deliveries (Priority: P1)

A warehouse coordinator opens "Por entregar" first thing in the morning. It lists every delivery line scheduled for today that hasn't been fully loaded yet, highest priority first. Each row shows the order folio, customer, ship-to, scheduled date, product, warehouse, priority and the quantity still to load.

**Why this priority**: This is the whole feature. Without it, warehouse staff can't see what's waiting to go out in the new app.

**Independent Test**: Confirm (and approve, if required) a delivery order scheduled for today with two lines. Open "Por entregar" as a user with ForDeliver read. Check that the period is Hoy, both lines appear with their full quantities as open, and the total includes them.

**Acceptance Scenarios**:

1. **Given** a user with ForDeliver read, **When** they open the back-office navigation, **Then** "Por entregar" is offered in the Logística group. Without that right it isn't, and its route is blocked.
2. **Given** the screen opens with no period chosen, **When** it loads, **Then** it lists today's pending lines, and the filters button shows no active-filter badge.
3. **Given** a period, **When** it's shown, **Then** the list holds the delivery lines in that date range that still have quantity to load, sorted by priority, highest first. Each row shows folio, customer, ship-to, scheduled date, priority, product code and name, warehouse, and open quantity.
4. **Given** a line partly committed to an itinerary, **When** the queue loads, **Then** its row shows only the quantity still open. A fully committed line doesn't appear.
5. **Given** a period with more lines than fit on a page, **When** it's shown, **Then** it's paginated with the period's total in the pagination footer.

---

### User Story 2 - Look ahead and behind (Priority: P2)

On Thursday afternoon the coordinator opens the filters and sees how many lines each period holds: Ayer 2, Hoy 12, Mañana 7, Pasado mañana 3. They pick Mañana to see how heavy Friday will be. Then they pick Anteriores to catch anything overdue that never went out. An overdue line shows its original scheduled date so they can tell how late it is.

**Why this priority**: Planning ahead and catching overdue deliveries is the second reason the legacy screen exists, but today's list alone already delivers value.

**Independent Test**: Have pending delivery lines scheduled three days ago, yesterday, tomorrow, the day after, and a week from now. Check that the filter panel shows each period's count, and that picking each period (Anteriores, Ayer, Mañana, Pasado mañana, Posteriores) lists its line with its scheduled date.

**Acceptance Scenarios**:

1. **Given** the user opens the filters, **When** the panel shows, **Then** it offers a single-select "Periodo" with six options in this order: Anteriores, Ayer, Hoy, Mañana, Pasado mañana, Posteriores. Each option shows its line count, and the four single-day options also show their date.
2. **Given** the user picks a period other than Hoy, **When** the list reloads, **Then** it shows that period's lines, and the filters button shows one active filter.
3. **Given** the user uses "Clear all", **When** the list reloads, **Then** it's back on Hoy with no badge.
4. **Given** a delivery line scheduled before yesterday, **When** the user picks Anteriores, **Then** it's listed with its scheduled date.
5. **Given** a delivery line scheduled more than two days ahead, or with no scheduled date, **When** the user picks Posteriores, **Then** it's listed. A line with no date says so instead of showing a date.
6. **Given** a period other than Hoy with no lines, **When** it's chosen, **Then** the list shows the app's standard "no matches" state with its clear-filters action, which goes back to Hoy.

---

### User Story 3 - Open the delivery order behind a line (Priority: P2)

The coordinator sees a line for 40 bags of cement with priority 5 and wants to check the delivery address notes. They tap the row and the delivery order's detail screen opens (spec 061). When they go back, the queue is on the same period and page, reloaded.

**Why this priority**: A row shows one line. Deciding how to load a truck often needs the whole order.

**Independent Test**: As a user with ForDeliver read and Delivery Orders read, tap a row. Check that the matching delivery order opens. Go back and check the period and page are kept.

**Acceptance Scenarios**:

1. **Given** a user with Delivery Orders read, **When** they tap a row, **Then** the delivery order's detail screen from spec 061 opens.
2. **Given** a user without Delivery Orders read, **When** they view the queue, **Then** rows aren't tappable. The queue still shows everything on the row.
3. **Given** the user returns from the detail screen, **When** the queue is shown again, **Then** it reloads and keeps the period and page. If the order was cancelled or sent back meanwhile, its lines are gone.

---

### Edge Cases

- **Approval required but not given.** Orders still in Pendiente de aprobación aren't in the queue. They appear once approved (spec 062).
- **Counter pickups.** Pickup orders never appear here, at any status. They're handed over at the counter, not loaded.
- **Cancelled or returned to draft.** An order cancelled or rejected back to draft leaves the queue on the next reload.
- **Disabled facility.** Lines of orders at a disabled facility don't appear.
- **Other facilities.** The server lists pending lines from every active facility, not just the user's. Each row shows its warehouse so staff can tell which lines are theirs.
- **Day boundary.** Periods are computed by the server from its current date. A screen left open past midnight shows yesterday's split until it reloads.
- **Page past the end.** If lines leave a period while the user is on its last page and that page becomes empty, the list moves back to its last non-empty page.
- **Unknown period in the URL.** A link with a period the app doesn't know falls back to Hoy.
- **Server unavailable.** The queue shows the standard load error with a retry, and keeps the period.
- **Very large backlog.** Anteriores may hold hundreds of overdue lines; it's paginated like any other period.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The app MUST offer "Por entregar" in the back-office Logística group, gated on ForDeliver (SystemObject 91) read. The route MUST be blocked without that right.
- **FR-002**: The screen MUST offer a single-select "Periodo" facet in the shared filter panel, with six options in the server's order: Anteriores (before yesterday), Ayer, Hoy, Mañana, Pasado mañana, Posteriores (later than the day after tomorrow, or no date). Hoy MUST be the default.
- **FR-003**: Each period option MUST show its total line count. The four single-day options MUST also show their date.
- **FR-004**: The list MUST show the pending delivery lines the server returns for the selected period, in the server's order (priority, highest first).
- **FR-005**: Each row MUST show the order folio, customer name, ship-to address, scheduled date, priority, product code and name, warehouse name, and open quantity. Open quantity MUST be formatted like other quantities in the app. A line with no scheduled date MUST say so.
- **FR-006**: The list MUST be paginated with the shared pagination component, showing the selected period's total.
- **FR-007**: The period and page MUST be kept in the screen's URL, so reloading or sharing the link reopens the same view. Changing the period MUST go back to the first page.
- **FR-008**: The list MUST reload when the period or page changes and when the user returns from a delivery order's detail screen, keeping the period and page.
- **FR-009**: With Delivery Orders (SystemObject 71) read, tapping a row MUST open that delivery order's detail screen (spec 061). Without it, rows MUST NOT be tappable.
- **FR-010**: The queue MUST be read-only. It MUST NOT offer actions that change a delivery order or commit lines to an itinerary.
- **FR-011**: The filter row MUST hold only the shared filters button, badged when a period other than Hoy is selected. It MUST NOT show a search box: the server offers no search for this queue. "Clear all" MUST return to Hoy.
- **FR-012**: An empty Hoy MUST say there are no deliveries pending for this period. An empty period other than Hoy MUST show the app's standard filtered-empty state with its clear-filters action, as every filtered list does. A load failure MUST show the standard error with a retry.
- **FR-013**: All user-visible text MUST be localized (Spanish and English), and API errors MUST be shown from their error codes as elsewhere in the app.

### Key Entities

- **Pending delivery line**: one line of a delivery order in En preparación that still has quantity to load. Carries the order (id, folio, customer, ship-to, scheduled date, priority), the product (id, code, name), the warehouse it ships from, and the open quantity: the line's quantity minus what's committed to non-cancelled itineraries.
- **Period**: one of six fixed date ranges relative to the server's today, with its date (for single-day periods), its total line count, and a page of its lines.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A warehouse user sees today's pending lines within 5 seconds of opening the screen, and every period's count with one more click.
- **SC-002**: Every line the server reports as pending appears in exactly one period, with the same open quantity the server reports, for a test set covering all six periods.
- **SC-003**: From any row, a user with Delivery Orders read reaches the full delivery order in one tap and returns to the same period and page.
- **SC-004**: Users without ForDeliver read can't reach the screen by navigation or by URL.
- **SC-005**: The legacy "For Delivery" view is covered: date periods, priority order, and remaining quantities match what the legacy screen shows for the same data, apart from counter pickups, which the new flow leaves out by design.

## Assumptions

- The server's pending-deliveries query defines what's in the queue (orders in En preparación, delivery type, active facility, open quantity above zero). The app doesn't filter further.
- The queue spans every active facility, as in the legacy screen. Scoping it to the user's facility would need a server filter; if wanted, it's a follow-up for mbe-api.
- Customer, ship-to, and warehouse names aren't in the server's response, only their ids. The app resolves them the way spec 061 does.
- Page size follows the app's default for list screens, within the server's maximum of 100 per period.
- Committing lines to an itinerary, and the itinerary screens themselves, are out of scope (mictlanix/mbe-roadmap#41).
- Printing the queue is out of scope; the legacy screen had no print.
- The Compact (phone) layout follows the shared table's existing behavior; no phone-specific design is added.
