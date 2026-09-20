# Feature Specification: Fix List Origin Filtering and Cash Session List Refresh

**Feature Branch**: `041-fix-list-origin-refresh`

**Created**: 2026-09-20

**Status**: Draft

**Input**: User description: "Let's create a spec to fix those lists, and also fix cash sessions list, which is not being updated after a session is opened or closed." — following on from spec 039 (Back-Office Order Workspace), whose OS-2 explicitly deferred giving the point-of-sale sales list and the back-office "Pedidos" list any awareness of the order-origin field it introduced.

## Context

Spec 039 recorded, for the first time, which workflow raised an order — point of sale or back office — as a durable `origin` field on the order (FR-051/FR-052). It deliberately left both list screens untouched (OS-2): filtering by origin would either hide every order that predates the field or admit every historical register sale, and choosing between those was a backfill-policy question the spec declined to answer on the spot.

That question already has an answer available: the API these lists call supports excluding one origin from a list while always keeping orders that never recorded one (`excludeOrigin`, delivered alongside the `origin` field itself). Asking to exclude a workflow, rather than asking to include only one, is exactly the shape that leaves undated legacy orders visible everywhere — the same guarantee spec 039 promised for the order workspace itself now extends to these lists.

Separately, and unrelated to origin: the cash sessions list (spec 021) does not reflect a session that was just opened or closed. Opening or closing a session already refreshes the *current session* indicator elsewhere on the same screen; it never refreshes the *history list* sitting next to it, which was assumed — incorrectly — to update on its own.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Hide back-office orders from the point-of-sale sales list (Priority: P1)

A cashier reviewing the register's sales list wants to see only what was actually sold at that register, without back-office phone orders mixed in.

**Why this priority**: This is the concrete complaint driving the spec — the list mixes both workflows today with no way to separate them.

**Independent Test**: From the point-of-sale sales list, turn on the filter that hides back-office orders, and confirm every remaining row is either a point-of-sale sale or an order with no recorded origin, and that all back-office orders disappear.

**Acceptance Scenarios**:

1. **Given** the point-of-sale sales list with no origin filter applied, **When** the screen loads, **Then** sales of every origin — point of sale, back office, and unrecorded — appear, exactly as today.
2. **Given** the point-of-sale sales list, **When** the user turns on "hide back-office orders", **Then** the list re-fetches and shows only point-of-sale sales and sales with no recorded origin.
3. **Given** the filter from Scenario 2 is active, **When** the user turns it back off, **Then** the full, unfiltered list returns.
4. **Given** the origin filter is active together with the list's existing filters (date range, status), **When** the user changes a different filter, **Then** the origin filter stays applied.

---

### User Story 2 - Hide point-of-sale orders from the back-office "Pedidos" list (Priority: P1)

A back-office user reviewing "Pedidos" wants to see only orders their team took, without register sales mixed in.

**Why this priority**: The mirror image of User Story 1, and equally named in the request; back-office staff need this as much as cashiers do.

**Independent Test**: From the "Pedidos" list, turn on the filter that hides point-of-sale sales, and confirm every remaining row is either a back-office order or an order with no recorded origin, and that all point-of-sale sales disappear.

**Acceptance Scenarios**:

1. **Given** the "Pedidos" list with no origin filter applied, **When** the screen loads, **Then** orders of every origin appear, exactly as today.
2. **Given** the "Pedidos" list, **When** the user turns on "hide point-of-sale sales", **Then** the list re-fetches and shows only back-office orders and orders with no recorded origin.
3. **Given** the filter from Scenario 2 is active, **When** the user turns it back off, **Then** the full, unfiltered list returns.

---

### User Story 3 - See a session's status change reflected in the cash sessions list (Priority: P1)

A user opens a new cash session, or closes their current one, from the cash sessions screen, and expects the session history right there on the same screen to show it — without pulling to refresh, retrying, or leaving and reopening the screen.

**Why this priority**: This is a visible correctness bug reported directly against the shipped feature — the screen shows stale data about its own subject immediately after the user's own action on that same screen.

**Independent Test**: Open a new cash session from the cash sessions screen, and confirm the session history list shows it as soon as the open form closes, with no other action taken. Repeat for closing the current session.

**Acceptance Scenarios**:

1. **Given** the cash sessions screen with no open session, **When** the user opens a new session and the open form closes, **Then** the session history list shows the new session without the user doing anything else.
2. **Given** the cash sessions screen with an open session, **When** the user closes it and the close form closes, **Then** the session history list shows it as closed without the user doing anything else.
3. **Given** the user cancels the open or close form instead of submitting it, **When** the form closes, **Then** the session history list is unchanged (no unnecessary re-fetch is required, but one is harmless).
4. **Given** the session history list has a date-range filter applied, **When** a session is opened or closed, **Then** the list refreshes under that same filter rather than resetting it.

---

### Edge Cases

- An order with no recorded origin (it predates spec 039) MUST remain visible in both lists under every filter combination — neither list's filter is allowed to hide it, since its true origin is unknowable.
- Turning on a list's origin filter where every remaining order was, in fact, excluded (e.g., a facility whose only orders are back-office) MUST show the list's existing empty-results state, not an error.
- A list's origin filter is a single on/off toggle per screen (hide the *other* workflow's orders) — there is no control to hide unrecorded-origin orders, and no control to hide both origins at once.
- Opening or closing a session on a different device or by a different user is not covered by this refresh — this feature only guarantees the list reflects the acting user's own action on the same screen.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The point-of-sale sales list MUST offer a control to hide back-office-originated orders, off by default, matching the list's current unfiltered behavior when not engaged.
- **FR-002**: When the control in FR-001 is engaged, the point-of-sale sales list MUST show only orders whose recorded origin is point-of-sale or whose origin was never recorded, and MUST exclude every order whose recorded origin is back-office.
- **FR-003**: The back-office "Pedidos" list MUST offer a control to hide point-of-sale-originated orders, off by default, matching the list's current unfiltered behavior when not engaged.
- **FR-004**: When the control in FR-003 is engaged, the "Pedidos" list MUST show only orders whose recorded origin is back-office or whose origin was never recorded, and MUST exclude every order whose recorded origin is point-of-sale.
- **FR-005**: Neither list's origin control MAY hide orders with no recorded origin, regardless of the control's state.
- **FR-006**: Each row in both lists MUST show which workflow originated it (point of sale, back office, or unrecorded), so the effect of the filter controls in FR-001/FR-003 is visible even before they are used.
- **FR-007**: Engaging or disengaging either list's origin control MUST NOT reset the list's other active filters (date range, status, and, where applicable, salesperson/facility).
- **FR-008**: The cash sessions screen's session history list MUST reflect a newly opened session as soon as the open action completes, without requiring a manual refresh or leaving the screen.
- **FR-009**: The cash sessions screen's session history list MUST reflect a session's closed status as soon as the close action completes, without requiring a manual refresh or leaving the screen.
- **FR-010**: Cancelling the open or close action MUST NOT be required to trigger a history list refresh, and MUST NOT itself corrupt or clear the list's current contents or filters.
- **FR-011**: The automatic refresh in FR-008/FR-009 MUST honor whatever filters (e.g., date range) are currently applied to the history list rather than resetting them.
- **FR-012**: None of the above changes any observable behavior for a list when its origin control is left at the default (off) state, and none of them change how opening or closing a cash session itself works.

### Key Entities

- **Order / Sale**: A point-of-sale sale or back-office order, unified for listing purposes; carries a recorded origin (point of sale, back office, or unrecorded, per spec 039) that both list screens can now read and filter by.
- **Cash Session**: A register's open/closed cash-drawer period; its status (open, closed) and its presence in session history are what the cash sessions list must keep current.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A register user can go from the default point-of-sale sales list to a list containing zero back-office orders in a single action.
- **SC-002**: A back-office user can go from the default "Pedidos" list to a list containing zero point-of-sale sales in a single action.
- **SC-003**: In 100% of cases, an order with no recorded origin remains visible in both lists, in every filter state.
- **SC-004**: After opening or closing a cash session, the session history list shows the change with zero additional user actions, 100% of the time.
- **SC-005**: With every origin control left off, both lists' contents, columns, and other filter behavior are unchanged from their current shipped behavior.

## Assumptions

- The API's existing support for excluding one workflow's orders from a list (while always keeping orders with no recorded origin) is available and is the mechanism both list filters rely on; no historical backfill of missing origin values is undertaken by this feature.
- "Hide the other workflow" (rather than "show only mine") is the right shape for both filters specifically because it is the one that keeps pre-existing, unrecorded-origin orders visible by default — consistent with spec 039's promise that recording origin changes nothing observable for orders that predate it.
- Per-row origin display (FR-006) reuses whatever labeling/badge convention each list already uses for similar per-row facts (e.g., status), rather than introducing a new visual language.
- The cash session history list's refresh is triggered by the acting user's own open/close action completing on the same screen; keeping the list live against sessions opened or closed elsewhere (another device, another user) is not part of this feature.

## Out of Scope

- Backfilling the `origin` field on orders that predate spec 039 — they remain permanently unrecorded, by spec 039's own design.
- Any other column, sort, export, or pagination behavior on either sales list beyond the origin control and its per-row indicator.
- Real-time or cross-session/cross-device updates to the cash sessions list — this feature only fixes the list's staleness after the current user's own action on the same screen.
- Any change to the business rules governing when a cash session may be opened or closed.
