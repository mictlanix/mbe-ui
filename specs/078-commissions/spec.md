# Feature Specification: Commissions

**Feature Branch**: `078-commissions`

**Created**: 2026-11-25

**Status**: Draft

**Input**: Covers mictlanix/mbe-roadmap#34 ([UI] Commissions, epic mictlanix/mbe-roadmap#3), the UI twin of mictlanix/mbe-roadmap#33 ([API] Commissions, closed) over the scope in mictlanix/mbe-roadmap#32. Scope 02 §10 Commissions (mbe-api `docs/specs/02-sales.md`); server work in mbe-api spec 025 "Commissions with Stable History". SystemObject CommissionsBySalesPerson (112). Weight: 2 legacy actions. User description: "Commissions back-office UI: commission settings (labels, participation types, agents and their scheme, agent rates, product labels) and monthly commission periods (review, close, reopen, pay)."

## Context

Sales agents earn a share of the sales they bring in, by product category, and are paid by month. In the current system the settings have no screen at all (they are edited in the database), and commissions are a live report over any date range that is never closed or marked paid. Because it reads the customer's salesperson and the rates at report time, reassigning a customer or changing a rate rewrites every past month.

mbe-api spec 025 replaced that with **monthly periods with stable history**, and the generated client already has every route this spec needs. This feature gives a manager the screens to use it:

- **Settings**: the commission catalog a computation reads.
- **Periods**: review a month's commissions, close it (which freezes it), reopen it if a mistake is found, and mark it paid.

How a sale line earns, in short (decided by the server; the UI only shows it):

- Each line of a completed, non-cancelled, paid order compares the order's salesperson with the customer's salesperson. If they are the same agent, that agent earns as **CLIENTE VITALICIO**. Otherwise the order's salesperson earns as **CANALIZACIÓN** and the customer's as **ATENCIÓN EN CAMPO**.
- Rate = the product's label rate × the agent's share for that label and participation. Commission = the line amount × rate, rounded to cents.
- A refund is a negative line.
- Each agent follows a **scheme**: **1, fully paid** (the default: a line earns in full in the month its order becomes fully paid), or **2, partial payments** (a line earns in proportion to what has been paid by each month's end, without ever earning more than its full commission).

A month's period moves through these states:

| State | Meaning | What can happen |
|---|---|---|
| Open (Abierto) | Computed live from current sales and settings every time it is read; not final | Close, once the month has ended and the previous month is closed (the very first close has no previous) |
| Closed (Cerrado) | Its lines are stored as they were at close; later reassignments, rate or label changes, and order edits do not change it | Pay; or reopen, if it is the latest closed month |
| Paid (Pagado) | Final | Nothing |

A month that has never been closed has no record yet and is treated as open.

## Clarifications

### Session 2026-11-25

- Q: How are agent rates presented and edited? → A: As a per-agent grid: labels as rows, participation types as columns, a share or empty in each cell, edited in place (US5, FR-015).
- Q: Where can a product's commission label be set? → A: On a dedicated product labels list, and from an unlabelled line in an open month, as the current system's report allowed. Not on the product's own screen (US6, FR-016, FR-016a).
- Q: When no agent is chosen on a month's screen, are lines listed? → A: No. The all-agents view shows the grand total and each agent's total; lines and the per-label breakdown appear once one agent is chosen (US1, FR-003–FR-005).
- Q: Which values does a line show in the table, given they cannot all fit? → A: A core set in the table (order, paid date, customer, product, label, participation, effective rate, amount, commission, sale/refund). Every value is in a read-only side panel opened by choosing the line (FR-005, FR-005a).
- Q: How does a manager label a product that has no label yet from the product labels list? → A: The list has an "Asignar etiqueta" action that opens a product picker over all products, since the list itself holds only labelled products; no backend change (FR-016).
- Q: Where do the five settings sections live? → A: One "Comisiones" entry in Finanzas opens the months. A "Configuración" button there opens one settings screen with the five sections (labels, participation types, agents, agent rates, product labels) behind a segmented control, so the menu gains one entry, not six (Assumptions, FR-020, FR-021).

**Out of scope**: the "Comisiones por vendedor" report with the agent's printed ticket and CSV export (mictlanix/mbe-roadmap#101, Reports epic), which will read the same period data; the card-processing commission on payment methods, which is unrelated; and the legacy `commissions_history` table, which nothing uses.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Review and close a month's commissions (Priority: P1)

At the start of a month, a manager opens the previous month's commissions. They see what each agent earned, broken down by label, and can look at one agent's lines to check them. If everything is right, they close the month. From then on the month shows exactly what it showed when it was closed, whatever happens to customers, rates or orders later.

**Why this priority**: Closing is what turns a live calculation into a stable record that agents can be paid from. It is the reason the new system exists (mictlanix/mbe-roadmap#32), and it works with the settings already in the shared database, so it delivers value before any settings screen exists.

**Independent Test**: Open last month (never closed). Its totals per agent appear, marked as not final. Choose one agent and check that the label totals equal the sum of that agent's lines. Close it and confirm. The month now shows Closed, with when it was closed, and the same totals. Reassign one of its customers to another agent and reopen the month view: nothing has changed.

**Acceptance Scenarios**:

1. **Given** a month that has ended and has never been closed, **When** the manager opens it, **Then** they see, clearly marked as a live, not-final calculation, each agent's total and the month's grand total, with no lines listed.
2. **Given** a month on screen, **When** the manager chooses one agent, **Then** the screen shows that agent's totals by label and their lines. The lines table shows each line's order, paid date, customer, product, label, participation, effective rate, amount, commission and whether it is a sale or a refund. Choosing a line shows every other value too: order date, label rate, agent share, full commission, paid share (scheme 2 sales only), scheme and the salespeople (FR-005, FR-005a).
3. **Given** an open month that has ended and whose previous month is closed (or no month has ever been closed), **When** the manager chooses Close and confirms, **Then** the month becomes Closed, shows when it was closed and by whom, and its totals are the ones they reviewed.
4. **Given** the current month, or an open month whose previous month is not closed, **When** the manager looks at it, **Then** the Close action is not offered, and the screen says why (the month has not ended yet / the previous month must be closed first).
5. **Given** a closed month, **When** a customer is reassigned, a rate or label changes, or an order is edited, **Then** the month still shows exactly what it showed when it was closed.
6. **Given** the close confirmation, **When** the manager cancels it, **Then** nothing changes.
7. **Given** a refusal from the server (for example, another user closed the month first), **When** the action fails, **Then** the manager sees a message in their own language that explains the reason, and the month is shown in its current state.

---

### User Story 2 - Mark a month paid, or reopen it to correct it (Priority: P1)

After agents are paid, the manager marks the closed month as paid, which makes it final. If, before paying, they find a mistake (a product with the wrong label, a missing rate), they reopen the latest closed month, fix the setting, and close it again.

**Why this priority**: Paying is the last step of the monthly cycle and the only way to record that a month is settled. Reopening is the only correction path for a closed month. Without both, a manager who closes a month with a mistake is stuck.

**Independent Test**: With a closed, unpaid latest month: reopen it and confirm; it is Open again and computed live. Close it again. Mark it paid and confirm; it shows Paid with when and by whom, and neither Reopen nor Pay is offered any longer.

**Acceptance Scenarios**:

1. **Given** a closed month, **When** the manager chooses Mark as paid and confirms, **Then** the month becomes Paid and shows when it was paid and by whom. The confirmation warns that a paid month can never be reopened or changed.
2. **Given** the latest closed month that is not paid, **When** the manager chooses Reopen and confirms, **Then** the month becomes Open, its stored lines are discarded, it is computed live again, and it shows when it was reopened and by whom. The confirmation says that the stored lines will be recalculated with current data when it is closed again.
3. **Given** a closed month that is not the latest closed month, **Then** Reopen is not offered.
4. **Given** a paid month, **Then** neither Reopen nor Mark as paid is offered.

---

### User Story 3 - See the history of months (Priority: P1)

The manager opens Commissions and sees the months that have been closed, newest first, each with its state, its total, and when it was closed and paid. From there they open any month, including one that has never been closed.

**Why this priority**: It is the entry point to Stories 1 and 2, and it answers at a glance the question a manager asks most: which months are still unpaid.

**Independent Test**: With some closed and paid months, open the list: each appears with its state, total and dates, newest first. Open one. Pick a month that is not in the list (never closed) and open it.

**Acceptance Scenarios**:

1. **Given** months that have been closed at least once, **When** the manager opens Commissions, **Then** they see each of those months, newest first, with its state, total, closing date and payment date.
2. **Given** the list, **When** the manager picks any month and year, including one never closed, **Then** that month opens.
3. **Given** no month has ever been closed, **When** the manager opens Commissions, **Then** the screen explains that no month has been closed yet and still lets them open any month (by default, the previous month).
4. **Given** a month that was reopened and not closed again, **Then** it appears as Open, with a total of zero, and opening it shows its live calculation.

---

### User Story 4 - Maintain labels, participation types and agents (Priority: P2)

A manager keeps the commission catalog current: the labels and their rates (e.g. CONCRETOS 2.5%), the participation types, and which employees are agents and under which scheme.

**Why this priority**: These settings change rarely and the current values are already in the shared database, so the monthly cycle works without these screens. Still, today a rate change needs a developer, and the scheme (new in this system) has no other way to be set.

**Independent Test**: Create a label with a rate of 3%, edit its rate to 3.5%, then delete it. Make an employee an agent under scheme 2, switch them to scheme 1, then remove them. Rename a participation type. Each change shows immediately in its list.

**Acceptance Scenarios**:

1. **Given** the labels list, **When** the manager creates or edits a label with a name, a rate and an optional comment, **Then** it is saved. The rate is entered and shown as a percentage, and a rate below 0% or above 100% is refused before it is sent.
2. **Given** a label still assigned to products or used by an agent rate, **When** the manager tries to delete it, **Then** the deletion is refused with a message that says it is in use.
3. **Given** the agents list, **When** the manager adds an agent, **Then** they pick an employee who is not already an agent and choose a scheme, which defaults to "fully paid".
4. **Given** an agent, **When** the manager changes their scheme, **Then** it is saved, and the screen states that the change applies from the next calculation and never alters closed months.
5. **Given** an agent who still has rates, **When** the manager tries to remove them, **Then** the removal is refused with a message that says the agent's rates must be removed first.
6. **Given** a participation type used by agent rates, **When** the manager tries to delete it, **Then** the deletion is refused with a message that says it is in use.

---

### User Story 5 - Maintain agent rates (Priority: P2)

A manager sets each agent's share of each label under each participation type, for example 100% of CONCRETOS as CLIENTE VITALICIO and 50% as ATENCIÓN EN CAMPO.

**Why this priority**: The shares decide every commission, and there are about 130 of them today. Without this screen a new agent or label earns nothing until a developer edits the database.

**Independent Test**: Give an agent a 100% share of a label as CLIENTE VITALICIO, change it to 80%, then remove it. Try to add the same agent, label and participation twice: the second is refused.

**Acceptance Scenarios**:

1. **Given** an agent, **When** the manager sets their share for a label and participation type, **Then** it is saved. The share is entered and shown as a percentage between 0% and 100%.
2. **Given** an existing share for an agent, label and participation, **When** the manager tries to add another for the same three, **Then** it is refused with a message that the share already exists (and the existing one can be edited instead).
3. **Given** a share, **When** the manager changes or removes it, **Then** the change applies from the next calculation and never alters a closed month.
4. **Given** the rates, **Then** each one shows the agent's, label's and participation's names, never bare numbers.
5. **Given** an agent is chosen, **Then** their rates are shown as a grid: one row per label, one column per participation type, each cell holding the share or empty when there is none, so a missing rate is visible at a glance.
6. **Given** the grid, **When** the manager types a share into an empty cell, changes a cell, or clears it, **Then** the rate is created, updated or removed for that agent, label and participation type, and the cell shows the saved value or the reason it was refused.

---

### User Story 6 - Assign products to labels (Priority: P2)

A manager sets which label a product belongs to, changes it, or removes it. A product has one label or none.

**Why this priority**: An unlabelled product earns nothing, so a new product sold before it is labelled pays no commission. The current system can add a missing label but never change one.

**Independent Test**: Set a label on an unlabelled product. Change it to another label. Remove it. Find all the products of one label.

**Acceptance Scenarios**:

1. **Given** the product labels, **When** the manager filters by a label or picks a product, **Then** they see the matching products with their code, name and label, page by page.
2. **Given** a product, **When** the manager sets or changes its label, **Then** it has exactly that label, and the change applies from the next calculation only.
3. **Given** a labelled product, **When** the manager removes its label, **Then** it has none.
4. **Given** an open month with a line marked "Sin etiqueta", **When** a user with the right to change settings assigns a label from that line, **Then** the product gets that label and the month is recalculated, so the line now earns at that label's rate. This is offered on open months only; a closed month's lines are frozen.

---

### Edge Cases

- **A line with no label**: it still lists, earning 0, so that someone labels the product. It shows "Sin etiqueta" rather than a blank.
- **A line with a missing rate**: it lists earning 0 at a 0% rate.
- **An agent who is no longer an agent**: a closed month can hold lines and totals for an employee who has since been removed as an agent. Their figures still show, with their name when it can be found and their number otherwise; they are never dropped.
- **A large month**: a month can hold thousands of lines. The lines are shown page by page and can be narrowed to one agent; totals are always over the whole month (or the whole agent), never just the visible page.
- **Negative totals**: a month in which an agent's refunds outweigh their sales shows a negative total, formatted as a negative amount, not hidden or shown as zero.
- **The current month**: it can be opened and reviewed live, but not closed.
- **A month far in the past before the first close**: it opens as a live calculation like any open month. It cannot be closed once a later month has been closed, and the screen says so.
- **Concurrent changes**: another user closes, reopens or pays the month while it is on screen. The action is refused by the server, the reason is shown, and the month is refreshed to its current state.
- **Reopened then closed again**: the month shows the latest close (date and user); the earlier close is not shown.
- **Scheme 2 lines across months**: the same sale line can appear in several months, each time with the share paid so far and only that month's increment as the commission. The full commission and the share make this readable.
- **No privilege**: a user without Read on commissions does not see the Commissions entry and cannot reach its screens by address.
- **Read-only user**: a user with Read but not Update sees months and settings but no Close, Reopen, Pay, Edit, Create or Delete actions.

## Requirements *(mandatory)*

### Functional Requirements

**Periods**

- **FR-001**: The system MUST list every month that has a period record, newest first, with its state (Open, Closed, Paid), its total, when it was closed, and when it was paid.
- **FR-002**: The system MUST let the user open any month by choosing its month and year, whether or not it has a record, defaulting to the previous calendar month. Months after the current one MUST NOT be offered, and an address for one opens the months list instead: nothing has happened in them yet.
- **FR-003**: For a month, the system MUST show its state, whether its figures are final (closed or paid) or a live calculation (open), who closed, reopened and paid it and when (where it has been), its grand total, and each agent's total. With no agent chosen it MUST NOT list lines. Once an agent is chosen it MUST also show that agent's totals by label.
- **FR-004**: The user MUST be able to choose one agent for a month. Until one is chosen the month shows totals only; once chosen, the totals by label and the lines are for that agent alone.
- **FR-005**: For a month and a chosen agent, the system MUST show the agent's lines, page by page, each with: order number, paid date, customer, product, label (or "Sin etiqueta"), participation type, effective rate, line amount, the commission for this month, and whether the line is a sale or a refund. Refund lines MUST be visually distinguishable from sales.
- **FR-005a**: Choosing a line MUST open a read-only side panel with every value of the line: the above plus order date, label rate, agent share, full commission, paid share (scheme 2 sales only), the scheme, and the order and customer's salespeople. The lines table MUST NOT need horizontal scrolling.
- **FR-006**: Agent names MUST be shown wherever an agent appears (totals and lines). An agent whose name cannot be found MUST still be shown, by number.
- **FR-007**: The user MUST be able to close an open month, after confirming. Close MUST be offered only when the month has ended and either its previous month is closed or no month has ever been closed. When Close is not offered for an open month, the screen MUST say why.
- **FR-008**: The user MUST be able to reopen the latest closed month that is not paid, after a confirmation that explains its stored lines will be discarded and recalculated with current data on the next close. Reopen MUST NOT be offered for any other month.
- **FR-009**: The user MUST be able to mark a closed month as paid, after a confirmation that warns a paid month is final. Mark as paid MUST NOT be offered for an open or paid month.
- **FR-010**: After any close, reopen or pay, successful or refused, the month and the list of months MUST show the period's current state without the user reloading.
- **FR-011**: The UI's availability rules for Close, Reopen and Pay are guidance; the server decides. Every server refusal for these actions MUST be shown as a message in the user's language that names the reason (month not ended, previous month not closed, a later month already closed, already closed, not closed, already paid, a paid month cannot be reopened).

**Settings**

- **FR-012**: The user MUST be able to list, create, edit and delete commission labels (name, rate, optional comment).
- **FR-013**: The user MUST be able to list, create, rename and delete participation types.
- **FR-014**: The user MUST be able to list agents (name and scheme), add an employee as an agent with a scheme (default: fully paid), change an agent's scheme, and remove an agent. The employee choice MUST exclude employees who are already agents.
- **FR-015**: The user MUST be able to see and edit one agent's rates as a grid of labels (rows) × participation types (columns), with names, where each cell is the share or empty. Entering a share in an empty cell creates the rate, changing it updates it, and clearing it removes it. Every label and participation type MUST appear, including those the agent has no rate for.
- **FR-016**: The user MUST be able to list product labels page by page, filtered by label and by a chosen product (the server offers no text search over this list, research R10), and to set, change or remove a product's label. Because the list holds only labelled products, it MUST also offer a way to choose any product, labelled or not, and give it a label.
- **FR-016a**: On an open month, a line without a label MUST offer a user with Update on commissions a way to assign a label to its product in place. After assigning, the month MUST be recalculated and shown with the new label. Closed and paid months MUST NOT offer it.
- **FR-017**: Every rate and share MUST be entered and displayed as a percentage, and MUST be validated as between 0% and 100% before it is sent. What is stored is the same value as a fraction (2.5% is 0.025), with no loss of the precision the server keeps.
- **FR-018**: Every settings screen MUST state, where a change is made, that settings changes apply to open months and future calculations only, never to closed months.
- **FR-019**: Settings refusals MUST be shown as messages in the user's language: a label or participation type in use, an agent who still has rates, an employee already an agent, a duplicate agent rate, a share for someone who is not an agent, and an out-of-range rate.

**Access**

- **FR-020**: Every commissions screen and action MUST be governed by the CommissionsBySalesPerson privilege (112): Read to see months and settings; Create, Update or Delete to change the matching settings; Update to close, reopen or pay a month. Administrators have every right. An action the user lacks the right for MUST NOT be shown.
- **FR-021**: The Commissions entry in the navigation MUST be hidden from a user without Read, and its screens MUST NOT be reachable by address for that user.

### Key Entities

- **Commission period**: a calendar month (year and month) with a state (Open, Closed, Paid), its total, and who closed, reopened and paid it and when.
- **Commission line**: one line of a month's calculation: an order line or refund line, credited to one agent under one participation type, with its rates, amounts, scheme, paid share and the month's commission. Stored, and therefore frozen, once the month is closed.
- **Commission total**: a month's sum of commissions for one agent and one label, with its line count.
- **Commission label**: a product category with a commission rate.
- **Product label**: a product's single commission label, or none.
- **Agent**: an employee who earns commissions, with a scheme (fully paid or partial payments).
- **Participation type**: why an agent earns on a line (CLIENTE VITALICIO, CANALIZACIÓN, ATENCIÓN EN CAMPO).
- **Agent rate**: an agent's share of a label under a participation type.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A manager can review last month's commissions and close it in under 2 minutes from opening Commissions.
- **SC-002**: For any month and agent, the totals shown equal the sum of the lines shown for that agent, to the cent, in 100% of checked months.
- **SC-003**: After a month is closed, reassigning a customer, changing a rate and relabelling a product change 0 figures in that month's view.
- **SC-004**: A manager can change a label's rate, an agent's share or a product's label without developer help, in under 1 minute each.
- **SC-005**: Every server refusal of a commissions action or settings change is shown with a reason in the user's language; none shows untranslated server text or a generic error alone.
- **SC-006**: A user lacking a right never sees the action it governs: 0 visible actions that the server would refuse for lack of privilege.

## Assumptions

- **Scope against the report (mictlanix/mbe-roadmap#101)**: this feature shows a month's totals and lines on screen because a manager must review a month before closing it. The printed per-agent ticket and the CSV export belong to the report and are not built here.
- **Navigation**: Commissions ("Comisiones") is one back-office entry in the Finanzas group. It opens the months; a "Configuración" button opens one settings screen with the five settings sections behind a segmented control. The whole feature sits behind one privilege and one menu entry.
- **Who can be an agent**: commissions follow the order's and the customer's salesperson, so an employee who is not a salesperson can never earn. The agent picker offers salespeople only.
- **Who closed/paid**: the server records the employee who closed, reopened or paid a month. The screen shows that employee's name, or their number when the name cannot be found (research R2).
- **Names for ids**: agent rates and month totals carry ids only. Labels, participation types and agents are small, bounded catalogs read with the same privilege, so the screens resolve names from them.
- **Bounded lists**: labels (about 13), participation types (3), agents (about 6) and agent rates (about 130) are small and bounded, so they are read whole, with no server paging. Labels, participation types and agents get a search box; agent rates are a per-agent grid instead (Clarifications). Product labels (about 1,100) and a month's lines (thousands) are shown page by page.
- **Settings surfaces**: labels, participation types and agents are small records edited in the shared side panel over their list, like other small catalogs. Agent rates use the per-agent grid (Clarifications) instead of a list and panel.
- **Product labels are not on the product screen**: they are set from the product labels list and from unlabelled lines in an open month, not from the product's own screen, which stays under the Products privilege.
- **Language**: the screens are in Spanish (es-MX) first, with English as the second locale, like the rest of the app. Participation type and label names are data and are shown as stored.
- **No backend change** is expected: mbe-api spec 025 and the generated client cover every route. If one turns out to be missing, it is filed against mbe-api, not patched here.
