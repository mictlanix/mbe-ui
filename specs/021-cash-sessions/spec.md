# Feature Specification: Cash Session Open, Close and Count

**Feature Branch**: `021-cash-sessions`

**Created**: 2026-08-04

**Status**: Draft

**Input**: User description: "Give cashiers and supervisors a screen to manage a cash drawer shift: see the current session state, open a session on a drawer with an opening cash amount, close it by counting denominations, and review past sessions."

## Clarifications

### Session 2026-08-04

- Q: How much surface should this feature cover — a standalone screen, or should it also gate the Point of Sale screen? → A: **Standalone screen only.** This feature MUST NOT edit or depend on spec 020's Point of Sale screen. No session banner in the POS header, no forced-close routing out of POS. Spec 020 is `ready-to-implement` but not started, and lists "Cash session opening, closing, counting or reconciliation" in its own Out of Scope; the two features stay independent and shippable in either order. Wiring POS to the session state is a deliberate follow-up.
- Q: The backend stores denomination counts but computes no expected cash and no variance. What should the close flow show? → A: **Counted versus expected cash, with an over/short difference, computed by the client.** Expected cash = the session's opening amount plus its cash-method payment total. The figure MUST be labelled advisory, because the backend's per-method payment totals exclude expense vouchers and other non-payment drawer movements.
- Q: Should a session history list be in scope? → A: **Yes**, paginated, with a cash drawer filter and a close action reachable from open and stale rows. It is the only way to reach *orphaned* open sessions: production data contains cashiers with three and four sessions open simultaneously (left by the legacy monolith), and the current-session lookup returns only the most recent, so the others are otherwise unreachable and can never be closed.
- Q: Browsing the cash drawer catalog needs a different permission than opening a session, so a cashier may be able to open a shift yet unable to pick a drawer. What should happen when such a user also has no drawer assigned? → A: **Do not work around the missing permission.** Offer no way to open a session and show an error telling the user a cash drawer must be assigned to them, directing them to their administrator. The permission is a real requirement, not an obstacle for the screen to route around. Recorded as FR-007a; the same treatment covers an empty cash drawer catalog. Raised during planning (research.md §7).
- Q: Must a closing count be non-empty? The backend accepts an empty count list. → A: The client requires a deliberate count. Only denominations with a quantity above zero are submitted, and a genuinely empty drawer MUST be recorded through an explicit "counted and empty" confirmation rather than by silently submitting nothing.

### Session 2026-08-05

- Q: mbe-api#141 and #142 — filed against this feature's two backend gaps (research.md §14) — both shipped mid-implementation, expanding `cash_drawer`/`cashier`/`cash_supervisor` to full objects and adding `cashier`/`facility`/`status`/date-range filters to the list endpoint. Should the history list's scope grow to use the new facets, or stay exactly as originally specified? → A: **Grow within FR-028's existing intent, not beyond it.** Add cashier and status as real filters alongside cash drawer — the same story ("browse a paginated, drawer-filterable list") filled out with facets the backend now genuinely offers, using the identical picker/chip pattern already used elsewhere in the app. Do NOT add a date-range filter: no user story or requirement asks for one, and the backend supporting it is not by itself a reason to build UI for it. FR-028 updated accordingly; D-003 corrected to no longer describe a limitation that no longer exists. Full account in research.md §17.

## User Scenarios & Testing *(mandatory)*

<!--
  IMPORTANT: User stories are PRIORITIZED as user journeys ordered by importance.
  Each is INDEPENDENTLY TESTABLE — implementing just one still yields a viable MVP slice.
-->

### User Story 1 - Open a shift on a cash drawer (Priority: P1)

A cashier starting a shift needs to see, at a glance, whether they already have a cash session open. When they do not, they choose a cash drawer — defaulting to the one assigned to their user — declare the cash they are starting with, and open the session. From that moment the shift is theirs: the screen shows the drawer, the start time and the opening amount, so the cashier can confirm they are working against the right drawer before taking any money.

**Why this priority**: Nothing else in the feature exists without an open session. It is the smallest slice that delivers standalone value — a cashier can start a shift and see it recorded, which is impossible in the UI today — and every other story reads the state this one creates.

**Independent Test**: Sign in as a cashier with no open session, confirm the screen reports that, open a session on the assigned drawer with an opening amount, and confirm the screen now reports an open shift with that drawer, start time and amount. Requires no other story.

**Acceptance Scenarios**:

1. **Given** a cashier with no open session, **When** they open the cash session screen, **Then** it states that they have no open session and offers to open one.
2. **Given** a cashier whose user has an assigned cash drawer, **When** the open form is shown, **Then** that drawer is preselected and identified by name, and the cashier may change it to another drawer.
3. **Given** a cashier whose user has **no** assigned cash drawer but who may browse the cash drawer catalog, **When** the open form is shown, **Then** no drawer is preselected and choosing one is required before the session can be opened.
3a. **Given** a cashier with no assigned cash drawer who may **not** browse the cash drawer catalog, **When** they open the screen, **Then** no open affordance is shown and an error states that a cash drawer must be assigned to their user, directing them to their administrator.
4. **Given** the open form with a drawer chosen, **When** the cashier enters an opening cash amount and confirms, **Then** a session is opened for that drawer and the screen shows it as open with its start time and opening amount.
5. **Given** the open form, **When** the cashier leaves the opening amount blank or enters zero, **Then** the session may still be opened and its opening amount reads as zero.
6. **Given** the open form, **When** the cashier enters a negative opening amount, **Then** the form rejects it before submitting and explains that the amount cannot be negative.
7. **Given** a cashier who already has an open session, **When** they attempt to open another, **Then** they are told they already have one open and must close it first, and are offered the close action rather than a second open form.
8. **Given** a drawer that another cashier already has a session open on, **When** the cashier tries to open a session on that drawer, **Then** they are told that drawer already has an open session — a distinctly different message from the case above, because the remedy is to pick a different drawer, not to close their own.
9. **Given** a user without the privilege to open a session, **When** they open the screen, **Then** no open affordance is rendered at all.

---

### User Story 2 - Close a shift by counting the drawer (Priority: P1)

At the end of a shift the cashier counts the cash physically in the drawer, denomination by denomination, and enters each quantity. As they type, the screen keeps a running counted total and compares it to what the shift should hold — the opening amount plus the cash payments taken during the session — showing whether the drawer is over, short, or exact. The cashier reviews that, then closes the session. The shift ends, and it stops being their open session.

**Why this priority**: The count is the point of the whole exercise — an open session that can never be closed is worse than no session, because a stale session blocks the cashier from selling. Equal priority to User Story 1: together they are the minimum shippable shift lifecycle.

**Independent Test**: With an open session that has taken at least one cash payment, enter denomination quantities, confirm the counted total, the expected figure and the difference update as quantities change, close the session, and confirm the cashier no longer has an open session.

**Acceptance Scenarios**:

1. **Given** an open session, **When** the cashier begins closing it, **Then** they are shown one entry row per supported currency denomination, each starting at a quantity of zero.
2. **Given** the count entry, **When** the cashier enters a quantity for a denomination, **Then** that row shows its extended amount (denomination times quantity) and the counted total updates immediately.
3. **Given** the count entry, **When** any quantity changes, **Then** the counted total, the expected cash figure, and the difference between them all update immediately, and the difference is labelled as over or short.
4. **Given** the count entry, **Then** the expected cash figure is presented as advisory, with a plain-language note that it covers the opening amount and cash payments taken in the shift and does not account for other movements of cash out of the drawer.
5. **Given** a counted total equal to the expected figure, **When** the difference is displayed, **Then** it reads as zero and is not styled as a problem.
6. **Given** a counted total that differs from the expected figure, **When** the cashier closes the session, **Then** the close is **not** blocked and no justification is demanded — the difference is informational.
7. **Given** the count entry with at least one quantity above zero, **When** the cashier confirms the close, **Then** the session records an end time, the entered denomination quantities are submitted, and the session is reported as closed.
8. **Given** the count entry with every quantity still at zero, **When** the cashier attempts to close, **Then** they must explicitly confirm that the drawer was counted and found empty before the close proceeds.
9. **Given** a successful close, **When** the confirmation is shown, **Then** it reports the counted total and the difference, because those figures cannot be retrieved again afterwards.
10. **Given** an open session, **When** the user viewing it lacks the privilege to close a session, **Then** no close affordance is rendered and the screen explains that closing requires a supervisor.
11. **Given** a session that another user closed while this cashier had the close form open, **When** the cashier confirms the close, **Then** they are told the session is already closed and the screen refreshes to reflect that, without losing their entered counts to an unexplained error.

---

### User Story 3 - Review shift history (Priority: P2)

A supervisor reconciling the day, or a cashier checking their own earlier shifts, needs a list of cash sessions: which drawer, which cashier, when it started and ended, and whether it is still open. They can narrow the list to one drawer, page through it, and open any session to see its opening amount and the payments it took broken down by method.

**Why this priority**: It turns the feature from a personal shift button into something a supervisor can supervise, and it is the surface User Story 4 depends on. It is not P1 because the shift lifecycle works without it.

**Independent Test**: Open the history list, confirm sessions are listed newest first with drawer, cashier, start, end and status, filter to a single drawer, page forward and back, and open a closed session's detail to see its opening amount and per-method payment totals.

**Acceptance Scenarios**:

1. **Given** existing cash sessions, **When** the user opens the history list, **Then** sessions are listed newest first showing cash drawer, cashier, start, end and status.
2. **Given** the history list, **When** a session has no end time and started today, **Then** its status reads as open.
3. **Given** the history list, **When** a session has no end time and started on an earlier day, **Then** its status reads as stale and is visually distinguished from a session opened today.
4. **Given** the history list, **When** a session has an end time, **Then** its status reads as closed and the closing user is identified on its detail.
5. **Given** the history list, **When** the user filters by a cash drawer, **Then** only that drawer's sessions are listed and the paging resets to the first page.
6. **Given** more sessions than fit one page, **When** the user pages forward and back, **Then** the list pages without losing the drawer filter.
7. **Given** the history list, **When** the user clicks a row anywhere outside its actions, **Then** that session's detail opens read-only.
8. **Given** a session's detail, **Then** it shows the drawer, cashier, start, end, opening amount and the payments taken during the session grouped by payment method with a total per method.
9. **Given** a closed session's detail, **Then** it offers no way to edit, reopen or delete the session, because a closed shift is final.
10. **Given** a closed session's detail, **Then** the denomination breakdown entered at close is **not** shown, and the screen does not imply it is retrievable.
11. **Given** a user without read privilege on cash sessions, **When** they attempt to reach the history list, **Then** they are blocked at the route and the navigation entry is not shown to them.

---

### User Story 4 - Recover an abandoned session (Priority: P3)

A cashier left a session open overnight, or the legacy system left several sessions open on one cashier at once. A supervisor finds the offending sessions in the history, opens one, and closes it with whatever count is appropriate — including no count at all if the drawer's cash was long since accounted for elsewhere. The stale shift is cleared, and the cashier can start a fresh one.

**Why this priority**: It fixes a real condition already present in production data and one that hard-blocks a cashier, but it affects a minority of sessions and reuses the close flow from User Story 2 rather than introducing new behavior. It cannot ship before User Story 3, which is the only way to reach the sessions it acts on.

**Independent Test**: With a cashier who has more than one open session, confirm the history list shows all of them while the cashier's own screen shows only the most recent, close a non-current one from its detail as a user holding the close privilege, and confirm it becomes closed and the cashier's current session is unaffected.

**Acceptance Scenarios**:

1. **Given** a cashier with several sessions open at once, **When** the history list is filtered to their drawer, **Then** every one of those open sessions is listed, not just the newest.
2. **Given** a cashier with several sessions open at once, **When** that cashier views their own shift, **Then** the most recent open session is shown and the screen notes that they have other open sessions needing attention.
3. **Given** a stale session belonging to another cashier, **When** a user holding the close privilege opens its detail, **Then** the close action is offered.
4. **Given** a stale session belonging to another cashier, **When** that user closes it, **Then** it is recorded as closed and stamped with the closing user, leaving the original cashier recorded as the session's cashier.
5. **Given** a stale session, **When** any user views it, **Then** nothing in the UI suggests it will close itself — clearing it is always an explicit action.
6. **Given** a cashier blocked by their own stale session who lacks the close privilege, **When** they view it, **Then** they are told plainly that a user with closing rights must close it, rather than being shown an action that will fail.

---

## Edge Cases

- The signed-in user has no assigned cash drawer and does not choose one — the open attempt must be prevented client-side with a clear explanation rather than surfacing a raw backend rejection.
- The signed-in user has no assigned cash drawer and is not permitted to browse the cash drawer catalog — there is nothing they can select, so the remedy is administrative, not something the screen can offer (FR-007a).
- The cash drawer catalog is empty, so even a permitted user has nothing to select — same administrative remedy.
- The chosen cash drawer was deleted between loading the picker and opening the session.
- Two cashiers race to open a session on the same drawer; the loser must get the drawer-busy explanation, not a generic failure.
- The same session is closed twice — from two tabs, or from the shift panel and the history detail at once.
- A session's payments total is empty because no payment has been taken yet; the expected figure must still render (as the opening amount alone) rather than blanking out.
- The session took only non-cash payments; expected cash equals the opening amount and the per-method breakdown must still be visible.
- Cash refunds paid out of the drawer make the cash-method total *lower* than the payments actually received; the expected figure must not be described as "cash received".
- A denomination quantity is entered as a non-integer, a negative number, or a value large enough to be an obvious typo.
- The count is entered and the app is reloaded before the close is submitted — the count is not persisted anywhere and is lost; the UI must not imply otherwise.
- A session is open on a drawer belonging to a facility other than the user's; the backend does not scope the history list by facility, so cross-facility sessions can appear.
- The history list's last page becomes shorter (or vanishes) because sessions were added or closed while the user was paging.
- The system clock crosses midnight while a session is open and the screen is left sitting there — an open session silently becomes stale.
- Amounts arriving from the backend cannot be parsed as numbers.

## Requirements *(mandatory)*

### Functional Requirements

**Shift state**

- **FR-001**: The system MUST show the signed-in user their current cash session state, distinguishing three cases: no open session, an open session started today, and an open session started on an earlier day (stale).
- **FR-002**: The system MUST treat a session with no end time as open, and an open session whose start date precedes today as stale, applying the same rule wherever a session's status is displayed — including list rows and session detail, which do not receive a status from the backend.
- **FR-003**: The system MUST NOT automatically close, extend, or alter a stale session; clearing it MUST always be an explicit user action.
- **FR-004**: When the signed-in user has more than one open session, the system MUST display the most recent as their current session and MUST indicate that further open sessions exist and need attention.

**Opening a session**

- **FR-005**: A user holding the create privilege for cash sessions MUST be able to open a session by selecting a cash drawer and declaring an opening cash amount.
- **FR-006**: The open form MUST preselect the cash drawer assigned to the signed-in user and identify it by name.
- **FR-007**: When the signed-in user has no assigned cash drawer but is permitted to browse the cash drawer catalog, the open form MUST require an explicit drawer selection and MUST prevent submission until one is chosen, rather than allowing a submission that the backend would reject.
- **FR-007a**: When no cash drawer can be determined for the signed-in user — because they have none assigned and are not permitted to browse the cash drawer catalog, or because no cash drawer exists — the system MUST NOT offer to open a session, and MUST show an error stating that a cash drawer must be assigned to their user and directing them to their administrator. The system MUST NOT attempt to work around the missing permission.
- **FR-008**: The open form MUST accept an opening amount of zero, MUST default to zero when left blank, and MUST reject a negative amount before submitting.
- **FR-009**: The system MUST distinguish, with different messages and different suggested remedies, a refusal because the selected drawer already has an open session from a refusal because the signed-in user already has one open elsewhere.
- **FR-010**: When the refusal is that the user already has an open session, the system MUST surface the close action for that session instead of leaving the open form as the only path forward.
- **FR-011**: When the selected cash drawer no longer exists, the system MUST report that specifically and allow another drawer to be chosen.
- **FR-012**: On a successful open, the system MUST show the new session as the user's current one without requiring a manual refresh.

**Counting and closing**

- **FR-013**: A user holding the close privilege MUST be able to close an open session by entering a quantity for each supported currency denomination.
- **FR-014**: The count entry MUST present one row per denomination in the supported currency ladder, descending by value, each defaulting to a quantity of zero.
- **FR-015**: The count entry MUST show each row's extended amount and MUST maintain a running counted total that updates as quantities change.
- **FR-016**: The system MUST display an expected cash figure for the session, calculated as its opening amount plus the total of its cash-method payments.
- **FR-017**: The system MUST display the difference between the counted total and the expected figure, labelled as over or short, and MUST show a zero difference as such rather than hiding it.
- **FR-018**: The system MUST present the expected figure and the difference as advisory, with a note stating that they cover the opening amount and cash payments taken during the shift and do not account for other cash movements out of the drawer.
- **FR-019**: The system MUST NOT block a close, demand a justification, or require an approval because the counted total differs from the expected figure.
- **FR-020**: The system MUST submit only denominations whose quantity is above zero.
- **FR-021**: When every quantity is zero, the system MUST require an explicit confirmation that the drawer was counted and found empty before closing.
- **FR-022**: Denomination quantities MUST be validated as non-negative whole numbers before submission.
- **FR-023**: On a successful close, the system MUST report the counted total and the difference in the confirmation, because neither figure can be retrieved from the backend afterwards.
- **FR-024**: When a close is refused because the session is already closed, the system MUST say so plainly and refresh the session's state, without discarding the user's entered counts to an unexplained error.
- **FR-025**: A user lacking the close privilege MUST NOT be shown a close affordance anywhere, and when such a user is blocked by their own stale session the system MUST tell them that a user with closing rights must close it.
- **FR-026**: A user holding the close privilege MUST be able to close a session belonging to another cashier, and the closed session MUST continue to identify its original cashier while also identifying the closing user.

**History**

- **FR-027**: Users holding the read privilege MUST be able to browse a paginated list of cash sessions showing cash drawer, cashier, start, end and status, ordered newest first.
- **FR-028**: The history list MUST offer cash drawer, cashier and status filters, and applying or changing any of them MUST reset paging to the first page.
- **FR-029**: The history list MUST page through sessions using the application's established shared pagination pattern, and MUST NOT attempt to retrieve the whole set at once.
- **FR-030**: Clicking a history row outside its actions MUST open that session's detail read-only.
- **FR-031**: A session's detail MUST show its cash drawer, cashier, start, end, opening amount, closing user where present, and the payments taken during the session grouped by payment method with a per-method total.
- **FR-032**: A session's detail MUST offer no edit, reopen, or delete action, because a closed session is final and an open one is only ever advanced by closing it.
- **FR-033**: A session's detail MUST NOT display or promise the denomination breakdown recorded at close, which the backend does not return.
- **FR-034**: The history list MUST show every open session for a cashier who has several, so a session hidden from the current-session view remains reachable and closable.

**Access control**

- **FR-035**: Reading and opening sessions MUST be gated on the point-of-sale privilege (read and create respectively), and closing MUST be gated on the dedicated cash-session-close privilege — never on the point-of-sale privilege — so a cashier is not shown a close action that will be refused.
- **FR-036**: The route MUST be guarded on the read privilege, and the navigation entry MUST be hidden from users lacking it.
- **FR-037**: Every privilege-gated action MUST be absent for a user lacking the privilege, never rendered disabled.

**Presentation**

- **FR-038**: All monetary amounts MUST be formatted as localized currency, and all timestamps as localized dates and times, in both supported locales.
- **FR-039**: All user-facing text introduced by this feature MUST be localized in both English and Spanish.
- **FR-040**: The screen MUST render usably on the compact layout tier as well as the expanded tier, and the count entry in particular MUST remain operable on a narrow viewport.

## Key Entities

- **Cash Session** — a cashier's shift on one cash drawer. Identified by its own id; carries the cash drawer, the cashier who opened it, a start time, an end time that is absent while the shift is open, the user who closed it, the opening cash amount, and the totals of payments taken during the shift grouped by payment method. Its status (open, stale, closed) is derived from the end time and the start date, not stored. A closed session is immutable.
- **Session State** — the three-way answer to "does the signed-in user have a shift open right now": none, open, or stale. Distinct from a session's own status because it is scoped to the signed-in user and resolves the ambiguity of several sessions being open at once.
- **Denomination Count** — one line of a closing count: a currency denomination and how many of it were counted. Submitted at close and not readable afterwards. The set of denominations offered is a client-side property of the currency, not something the backend defines or validates.
- **Payment Method Total** — the sum of the payments of one method taken during a session. Net of refunds paid out of the drawer, so a method's total can be lower than the gross received and, in principle, negative.
- **Cash Drawer** — the physical drawer a session runs on, already managed as a catalog record. A session's drawer cannot change once opened, and one drawer holds at most one open session.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A cashier can determine whether they have a shift open, and if so on which drawer, within 5 seconds of reaching the screen and without any further interaction.
- **SC-002**: A cashier with an assigned drawer can open a shift in at most two interactions after reaching the screen (enter the amount, confirm) — the drawer requires no selection step.
- **SC-003**: 100% of the ways a session open can be refused produce a distinct, actionable message naming a remedy the user can act on; none surface a raw backend error string or a generic failure.
- **SC-004**: Counting a full drawer of 11 denominations requires no interaction other than entering the 11 quantities, and the counted total, expected figure and difference are correct after every single quantity change.
- **SC-005**: A supervisor can locate and close any open session, including one not shown as the cashier's current session, in under 60 seconds starting from the navigation entry.
- **SC-006**: 100% of sessions displayed anywhere in the feature show a status consistent with the three-way rule, including sessions that started on a previous day.
- **SC-007**: No user is ever shown an action they lack the privilege for: a cashier without closing rights sees zero close affordances across the shift panel, the history list and every session detail.
- **SC-008**: A closing count of any size is submitted in one request and confirmed with its counted total and difference, so the figures are readable at least once even though they cannot be retrieved later.
- **SC-009**: The history list never fetches more than one page of sessions at a time, and paging and filtering remain correct against a dataset larger than one page.
- **SC-010**: All feature text, currency amounts and timestamps render correctly in both English and Spanish with no untranslated string and no manually formatted amount or date.

## Assumptions

- **A-001**: The supported denomination ladder is a client-side constant for Mexican pesos, using distinct values descending: 1000, 500, 200, 100, 50, 20, 10, 5, 2, 1, 0.50. The 20-peso value appears once even though it circulates as both a note and a coin, because the backend cannot distinguish notes from coins and a duplicated row would only confuse the count. Multi-currency drawers are not supported by this feature.
- **A-002**: "Cash-method payments" means payments recorded under the cash payment method specifically, not the sum of all methods. The existing shared payment-method definitions supply that identification; this feature does not introduce its own.
- **A-003**: The expected cash figure omits expense vouchers, cash-on-delivery movements and any other drawer movement the backend's per-method payment totals do not include. This is why FR-018 requires it to be labelled advisory. Making it exact would require new backend capability and is out of scope.
- **A-004**: The feature occupies one navigation entry, in the same navigation area as Point of Sale, leading to a screen that carries both the signed-in user's shift panel and the session history list; session detail is a separate screen reached by clicking a row. Exact route paths are a planning decision.
- **A-005**: A session's cashier and the drawer's facility are displayed using whatever identifying information the backend returns with the session; resolving them to richer records is not assumed to be free and is a planning decision.
- **A-006**: The closing user is stamped by the backend as whoever performed the close, with no verification that they are a different person from the cashier. This feature does not add dual control, and does not present the closing user as an independently verified supervisor.
- **A-007**: Cross-facility sessions may appear in the history list because the backend does not scope it by facility. This feature displays them rather than filtering them out client-side, which would silently hide sessions and defeat User Story 4.
- **A-008**: The history list is not scoped to the signed-in user: any user holding the read privilege sees every cashier's sessions, not only their own. This is imposed by the backend, which offers no cashier filter and no per-user scoping, and it is also what User Story 4 requires — a supervisor cannot close an abandoned session they cannot see. Restricting the list to the signed-in cashier is therefore explicitly rejected rather than overlooked. If shift visibility later needs to be restricted, that is a backend scoping change.
- **A-009**: An entered but unsubmitted count is not persisted across a reload. This matches the online-only constraint and is treated as acceptable because a count is entered and submitted in one sitting.

## Dependencies and Constraints

- **D-001**: No backend change and no client regeneration are required. Every capability this feature needs is already exposed by the backend and present in the checked-in generated client.
- **D-002**: This feature MUST NOT modify the Point of Sale screen specified by `specs/020-point-of-sale`, which is `ready-to-implement` but not started and which declares cash session handling out of its own scope. The two features MUST remain independently shippable in either order. Making the Point of Sale screen require or display an open session is deliberately deferred to a later feature.
- **D-003**: The history list can be filtered by cash drawer, cashier, and status (open/stale/closed) — mbe-api#142, filed during planning, shipped these mid-implementation. A date-range filter also exists server-side but is not exposed in the UI, since no user story or requirement asks for one. The backend still offers no free-text search, and a session has no text field that would make one meaningful. Client-side filtering across a returned page remains explicitly rejected regardless of which facets are server-side: it would produce results that are wrong across page boundaries.
- **D-004**: The denomination breakdown submitted at close is write-only — no backend capability returns it. Any future requirement to audit a past count is a backend change.
- **D-005**: Page size is 20 by default and cannot exceed 100 records per request.
- **D-006**: Monetary values cross the wire as strings and must be parsed before arithmetic; the counted total, expected figure and difference must be computed with exact decimal arithmetic, not floating-point, so a count of many denominations does not accumulate rounding error.
- **D-007**: Payments taken while no session was open are permanently unattributed to any shift. This feature cannot retroactively attach them and must not imply that opening a session captures earlier payments.

## Verbatim Constraints

Exact identifiers and strings pinned by the request. Downstream steps and the implementation MUST use these exactly as written.

**Backend operations** (already present in the checked-in generated client at `lib/generated/openapi/lib/src/api/cash_sessions_api.dart`):

- `GET /api/v1/cash-sessions/current` — `getCurrentSessionApiV1CashSessionsCurrentGet`
- `GET /api/v1/cash-sessions` — `listCashSessionsApiV1CashSessionsGet`, query `cash_drawer`, `skip`, `limit`
- `POST /api/v1/cash-sessions` — `openCashSessionApiV1CashSessionsPost`
- `GET /api/v1/cash-sessions/{cash_session_id}` — `getCashSessionApiV1CashSessionsCashSessionIdGet`
- `POST /api/v1/cash-sessions/{cash_session_id}/close` — `closeCashSessionApiV1CashSessionsCashSessionIdClosePost`

**Wire field names**:

- Open request: `cash_drawer`, `opening_amount`
- Close request: `counts`, each entry `denomination`, `quantity`
- Session response: `cash_session_id`, `cash_drawer`, `cashier`, `start`, `end`, `cash_supervisor`, `opening_amount`, `payments_by_method`; each per-method entry `method`, `total`
- Current-session response: `state`, `session`

**State values**: `'none'`, `'open'`, `'stale'`

**Backend refusal messages**, which are the only discriminator between the two same-status open conflicts:

- `That cash drawer already has an open session`
- `You already have an open session; close it before opening another`
- `No cash drawer is configured for your user; set one or supply it explicitly`
- `Session is already closed`
- `Cash drawer not found`
- `Cash session not found`

**Privileges** (both already defined in `lib/core/access/system_object.dart`):

- `SystemObject.pos` (44) — read for viewing, create for opening
- `SystemObject.cashSessionClose` (111) — update for closing

**Signed-in user's drawer**, from `lib/core/access/user_settings.dart`: `cashDrawerId`, `cashDrawerCode`, `cashDrawerName`, reached through a doubly-nullable path (`settings` may be absent, and `cashDrawerId` within it may be null).

**Upstream requirement source**: `specs/011-sales-cycle-endpoints/spec.md` in mbe-api, FR-050 through FR-054 and its User Story 3.
