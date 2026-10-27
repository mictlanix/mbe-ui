# Feature Specification: Payments List and Search

**Feature Branch**: `054-payments-list-search`

**Created**: 2026-10-27

**Status**: Draft

**Input**: User description: "Payments list and search" — mictlanix/mbe-roadmap#25 (`[UI] Payments list and search`, scope 02 §2.5 Customer Payments, weight 5 legacy actions). mbe-api already lists, searches and reads customer payments (mbe-api spec 011). Today mbe-ui has only the POS payment step and no screen to browse payments; this spec is the mbe-ui side only.

## Clarifications

### Session 2026-10-27 (scoping, before specify)

- Q: What does #25 cover beyond a browsable list? → A: A list, a cross-facility search and a read-only payment detail. No new write flows. Verification (#27), reversing or moving applications (#26), credit notes (#28) and refunds (#29) stay in their own issues.
- Q: How is search by reference offered, given that only the cross-facility payments-editor search can filter by reference? → A: It's a separate search mode, shown only to users who can read the Payments Editor. Everyone else gets the facility-scoped list.
- Q: Payment rows carry only the customer's id. How is the customer shown? → A: mbe-api#270 asks the server to add the customer's name to payment rows. Until that ships, mbe-ui looks up the names for each page itself.

### Session 2026-10-27 (clarify)

- Q: How does the user pick a cash session in the filter drawer? → A: With a searchable picker listing the facility's sessions as "#id · cashier · date", searchable by session number.
- Q: What are the Spanish labels for payment types? → A: The legacy labels, in sentence case: N/A · Contado · Pago de crédito · Pago anticipado · Nota de crédito · Gasto.
- Q: Does the payment view show an "Aplicado" total? → A: Yes. The header shows Importe · Aplicado · Sin aplicar, where Aplicado is the sum of the non-reversed applications.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Browse and filter the facility's payments (Priority: P1)

A cashier, supervisor or accountant needs to answer questions like "did this customer pay yesterday?", "what came in by transfer this week?" or "which payments in this shift are still unverified?". From the back office, they open **Pagos** and see the payments received at their facility, newest first. They narrow the list by customer, date range, payment method, verified state and cash session.

**Why this priority**: This is the gap the roadmap issue names: payments are recorded at the counter but cannot be looked up afterwards. Search by reference and the detail view both build on this list.

**Independent Test**: Record a couple of payments through the POS, open Pagos, confirm they appear newest first with their amount, method and verified state, then apply each filter and confirm the list narrows accordingly.

**Acceptance Scenarios**:

1. **Given** a user who can read Customer Payments, **When** they open Pagos, **Then** they see the payments of their own facility, newest first, one page at a time. Each row shows the payment number, date, customer, amount with currency, method (plus the payment option when there is one), reference, payment type, unapplied amount and verified state.
2. **Given** the list is open, **When** the user filters by a customer, **Then** only that customer's payments are listed.
3. **Given** the list is open, **When** the user sets a date range, **Then** only payments dated within that range (both ends inclusive, in the facility's wall-clock time) are listed.
4. **Given** the list is open, **When** the user picks a payment method, **Then** only payments made with that method are listed.
5. **Given** the verified filter is set to "any", **When** the user switches it to "verified" or "unverified", **Then** only payments in that state are listed. Switching back to "any" lists both.
6. **Given** the list is open, **When** the user filters by a cash session, **Then** only payments taken during that session are listed.
7. **Given** a user with an open cash session, **When** they open Pagos with no filters, **Then** the list is not limited to their session or to themselves. It shows the whole facility.
8. **Given** filters are active, **When** the user clears them, **Then** the unfiltered facility list returns, and the filter button's badge shows how many filters are active.
9. **Given** no payment matches the filters, **When** the list loads, **Then** an empty state says that nothing matches and offers to clear the filters.
10. **Given** a user without read access to Customer Payments, **When** they look at the navigation or follow a link to Pagos, **Then** Pagos is not offered and the route is blocked.

---

### User Story 2 - Open a payment and see where it went (Priority: P2)

A supervisor or accountant sees a payment in the list and needs the full picture: every recorded field, how much is still unapplied, and which orders it was applied to, including applications that were later reversed. From there, they jump to the order or the cash session involved.

**Why this priority**: The list answers whether a payment exists; the detail answers what happened to it. It is read-only, so it carries no risk. It also gives the Payments Editor (#26) and Verification (#27) a screen to add their actions to later.

**Independent Test**: Apply a POS payment to an order, open that payment from Pagos, confirm all its fields and the application to that order are shown, then follow the order link and the cash-session link.

**Acceptance Scenarios**:

1. **Given** the payments list, **When** the user opens a payment, **Then** a payment view opens. Its header shows Importe, Aplicado and Sin aplicar, and below it the screen shows: customer, amount and currency, method and payment option, reference, date, facility, cash session, payment type, unapplied amount, and verified state with the verifier.
2. **Given** a payment with applications, **When** its screen is open, **Then** every application is listed with its order, applied amount, change returned, who applied it and when. Reversed applications are listed too, clearly marked as reversed, and don't count toward the applied total.
3. **Given** a payment with no applications, **When** its screen is open, **Then** the applications section says that the payment has not been applied to any order.
4. **Given** an application to an order the user can read, **When** they choose that order, **Then** the order opens on its own screen: the counter-sale screen for a POS sale, or the Pedidos order screen for a back-office order.
5. **Given** a payment taken during a cash session the user can read, **When** they choose the session, **Then** the cash-session screen opens.
6. **Given** the user can't read the linked order or cash session, **When** the payment view is open, **Then** the number is shown as plain text, not as a link.
7. **Given** a payment's own link is shared or reloaded, **When** an authorized user opens it, **Then** the same payment view loads directly. If the payment does not exist, a not-found state is shown.
8. **Given** the payment view, **When** the user looks for actions, **Then** there are no verify, reject, reverse or edit actions. Those are delivered by #26 and #27.
9. **Given** a user who can't search across facilities, **When** they open the link of a payment from another facility, **Then** they see the not-found state, the same as for a payment that doesn't exist.

---

### User Story 3 - Find a payment across facilities by reference (Priority: P3)

A user who can read the Payments Editor, typically head-office accounting, has a bank statement line with a transfer reference and doesn't know which facility took the payment. They switch Pagos to the cross-facility search, type part of the reference, and optionally narrow it by customer and date range.

**Why this priority**: It's valuable but used by few people, and it needs a separate privilege. Stories 1 and 2 are complete without it.

**Independent Test**: As a user with Payments Editor read access, record a payment with a known reference at another facility, search for a fragment of that reference across facilities, and confirm the payment is found with its facility shown. As a user without that access, confirm the cross-facility search is not offered.

**Acceptance Scenarios**:

1. **Given** a user who can read the Payments Editor, **When** they open Pagos, **Then** they can switch between "this facility" and "all facilities" modes.
2. **Given** the "all facilities" mode, **When** the user types part of a reference, **Then** payments from every facility whose reference contains that text (ignoring case) are listed, newest first, each showing its facility.
3. **Given** the "all facilities" mode, **When** the user also sets a customer or a date range, **Then** the results narrow accordingly.
4. **Given** the "all facilities" mode, **When** the user looks at the filters, **Then** only the filters that mode supports (reference, customer, date range) are offered. Method, verified state and cash session are not shown.
5. **Given** a user who cannot read the Payments Editor, **When** they open Pagos, **Then** there is no mode switch, no reference search and no way to see another facility's payments.
6. **Given** a result in "all facilities" mode, **When** the user opens it, **Then** the same payment view as in Story 2 opens.

---

### Edge Cases

- **Customer names arrive after the rows.** Until mbe-api#270 ships, names are looked up per page. Rows appear right away; each customer cell shows a placeholder until its name is known, and if the lookup fails it falls back to the customer number. One failed name never blanks the list.
- **Many rows for the same customer.** A page with 50 rows from one customer looks that customer up once, not 50 times.
- **Foreign-currency payments.** Amounts and the unapplied amount are shown in the payment's own currency, with its code. Amounts in different currencies are never added together on screen.
- **Payment type "N/A" and "Expense".** These legacy types exist in the data. They're shown as "N/A" and "Gasto" (FR-017), never blank or as a raw number.
- **Removed payment option.** If the payment option recorded on a payment no longer exists, the method is still shown and the option falls back to its number.
- **Unknown verifier or applier.** If the employee who verified a payment or made an application can't be resolved, their number is shown instead of a blank.
- **Facility scope.** The server accepts any facility in the facility-scoped list request, whoever asks (it does not check access). So the facility-scoped mode MUST always use the user's own facility and MUST NOT offer a facility picker. Seeing other facilities happens only through the Payments Editor–gated mode.
- **Invalid date range.** An end date before the start date can't be applied. The picker prevents it rather than showing an empty list.
- **A payment changes elsewhere while it's open.** For example, it gets verified or reversed through another session. The screen shows what it loaded, and reopening or refreshing shows the current state. It does not update live.
- **Server or network errors.** The list and the payment view show the app's standard error state with a retry. The filters the user set are kept.
- **User with no facility.** A user whose account has no facility gets the empty list in the facility-scoped mode, with no request made, because there's no facility to scope to.
- **Very old data.** Payments migrated from the legacy system have no cash session and possibly no reference. Those fields show as empty ("—"), not as errors.

## Requirements *(mandatory)*

### Functional Requirements

**Access**

- **FR-001**: Pagos MUST appear in the Sales section of the back-office navigation and be reachable only by users who can read Customer Payments (system object 8). The route MUST block everyone else.
- **FR-002**: The cross-facility search mode MUST be offered only to users who can read the Payments Editor (system object 100). Administrators get both, as with every other privilege.
- **FR-003**: Pagos MUST NOT offer any action that creates, changes, verifies, rejects, applies or reverses a payment.

**Facility-scoped list (Story 1)**

- **FR-004**: The default mode MUST list the payments of the user's own facility, newest first, with pagination. It MUST NOT be limited to the user's cash session or to the user.
- **FR-005**: Each row MUST show: payment number, date, customer, amount with currency, method (with payment option when present), reference, payment type, unapplied amount and verified state.
- **FR-006**: The user MUST be able to filter by customer, date range, payment method, verified state and cash session. Any combination of these can be active at once.
- **FR-006a**: The cash-session filter MUST be a searchable picker over the user's facility's cash sessions. Each option is labelled "#id · cashier · date", and typing a session number finds that session. The filter is offered only to users who can read cash sessions; for anyone else it is absent, not disabled.
- **FR-007**: The verified filter MUST be tri-state: any, verified or unverified. "Any" is the default.
- **FR-008**: Filters MUST use the app's shared filter drawer and badged filter button. This mode has no free-text search, so no search box is shown in it. Superseded by spec 055 FR-009: the facility mode now has a customer-name search box.
- **FR-009**: The facility-scoped mode MUST NOT offer a way to choose another facility.

**Cross-facility search (Story 3)**

- **FR-010**: In cross-facility mode, the user MUST be able to search by partial reference (ignoring case) and narrow by customer and date range, across all facilities, newest first, with pagination.
- **FR-011**: Cross-facility rows MUST also show each payment's facility.
- **FR-012**: Each mode MUST offer only the filters it supports. When the user switches modes, filters the new mode doesn't support MUST be cleared, not silently kept hidden.

**Payment view (Story 2)**

- **FR-013**: Every payment MUST have its own screen, reachable from both modes and by a direct link. It MUST show all of the payment's recorded fields, its unapplied amount and its verifier.
- **FR-013a**: The payment view's header MUST show three amounts in the payment's currency: Importe (the payment amount), Aplicado (the sum of its non-reversed applications) and Sin aplicar (the server's unapplied amount).
- **FR-013b**: A user who can't search across facilities MUST NOT be able to see a payment from another facility, even by opening its link directly. The payment view shows the same not-found state as for a payment that doesn't exist, and its applications are never requested.
- **FR-014**: The payment view MUST list every application of the payment, reversed ones included. Each shows the order, applied amount, change returned, applier and date, and reversed applications are visibly marked.
- **FR-015**: An order or cash-session number on the payment view MUST link to that record's screen only if the user can read it. Orders open in the screen that matches their origin: counter sale or Pedidos.

**Presentation**

- **FR-016**: Amounts MUST be formatted in the payment's own currency. Dates MUST follow the app's configured date format and the facility's wall-clock time.
- **FR-017**: Payment methods, payment types and verified state MUST be shown as labels in the app's language, never as raw codes. Payment types use the legacy system's words in sentence case: N/A (NA), Contado (Immediate), Pago de crédito (Credit payment), Pago anticipado (Payment in advance), Nota de crédito (Credit note), Gasto (Expense).
- **FR-018**: The customer MUST be shown by name. Until the server provides names on payment rows (mbe-api#270), the client MUST look up each distinct customer on a page once and fall back to the customer number if the lookup fails. When the server starts providing the name on payment rows (mbe-api#270), a follow-up change makes the client prefer it and drop the extra lookups. That follow-up is not part of this delivery.
- **FR-019**: Like every other list screen, the list and the payment view MUST have loading, empty and error-with-retry states, and they MUST work on both desktop and phone layouts.

### Key Entities

- **Customer payment**: money received from a customer. It has a number, customer, amount and currency, method and optional payment option (card fee scheme), optional reference, date, facility, an optional cash session (set for counter payments), a payment type (Contado, Pago de crédito, Pago anticipado, Nota de crédito, Gasto, N/A), an optional verifier, and a derived unapplied amount (the amount minus all non-reversed applications).
- **Payment application**: part of a payment applied to one sales order. It has the order, applied amount, change returned, the employee who applied it, a date, and whether it was reversed. Reversed applications stay on record as evidence.
- **Cash session**: the cashier shift a counter payment was taken in. It is used here as a filter and as a link target.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A user can find a specific payment from a known customer and day in under 30 seconds from opening Pagos.
- **SC-002**: A user with Payments Editor access can find a payment by a fragment of its transfer reference, without knowing its facility, in under 30 seconds.
- **SC-003**: For any payment, the payment view shows the same applied orders and unapplied amount as the server's records. Reversed applications appear but are excluded from the Aplicado total in 100% of cases checked. Where all applications share the payment's currency, Importe − Aplicado equals Sin aplicar.
- **SC-004**: Users without Payments Editor access can see no payment from another facility in 100% of attempts, including direct links and changed filters.
- **SC-005**: A page of results is shown with customer names (not numbers) for every customer that still exists.
- **SC-006**: No screen delivered by this feature can change a payment. The only effect of using it is reading.

## Assumptions

- The server's list, search, detail and applications endpoints (mbe-api spec 011) are final for this scope. The only server change requested is mbe-api#270 (customer name on rows), and the feature works without it.
- "Newest first" is the server's order (by payment number, descending). The client does not offer other sort orders.
- The date filter is by payment date, inclusive on both ends, using the same date-range picker and wall-clock handling as the other back-office lists (spec 043).
- The customer filter uses the app's existing customer picker. The cash-session filter is a searchable picker over the facility's cash sessions. Each option shows "#id · cashier · date", and the user finds a session by typing its number (FR-006a).
- In cross-facility mode, the verified state, method and unapplied amount are still shown on each row, even though they can't be filtered there.
- The payment view does not need printing. Whether payments get a ticket, and for which types, is an open question in mictlanix/mbe-roadmap#155; there is no endpoint for one yet (mbe-api#272).
- A facility-scoped list request without a facility uses the caller's facility on the server. The client still sends nothing other than the user's own facility (see Edge Cases: facility scope).
- Opening a payment from a cash-session screen, an order screen or the customer record is useful but out of scope here. Those screens can link to the payment view later.
- Out of scope: verify/reject (mictlanix/mbe-roadmap#27), reversing or moving applications (#26), credit notes (#28), refunds (#29), recording or applying a payment outside the POS, the received-payments report (#99), and export.
