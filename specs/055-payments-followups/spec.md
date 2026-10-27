# Feature Specification: Payments Follow-ups

**Feature Branch**: `055-payments-followups`

**Created**: 2026-10-27

**Status**: Draft

**Input**: User description: "Pagos follow-ups after mbe-api#270/#271/#272" — mictlanix/mbe-ui#223, #224, #225 and #227. No roadmap plan issue: these are follow-ups to spec 054 (mictlanix/mbe-roadmap#25, already closed), and the PR closes the four mbe-ui issues directly. mbe-api has now shipped the customer name on payment rows plus a customer-name search (#270, PR #274), facility checks on payment reads (#271, PR #273) and the payment ticket (#272, PR #275). Product decisions for the ticket are on mictlanix/mbe-roadmap#155.

## Clarifications

### Session 2026-10-27 (scoping, before specify)

- Q: Which roadmap plan issues does this spec cover? → A: None. It lists and closes only mbe-ui#223, #224, #225 and #227.
- Q: Is #225 (walkthrough gaps) part of this spec, given that it is data setup and a live run? → A: Yes, as verification work: seed the missing data, then extend and rerun the walkthrough.
- Q: Does the facility-scoped list get a search box now that the server can search by customer name? → A: Yes. It searches by customer name. The all-facilities mode keeps its reference search.
- Q: The ticket's balance subtracts change handed back, but the server's unapplied amount doesn't. What does this spec do? → A: Nothing on screen. It's filed as mictlanix/mbe-api#276, and Pagos keeps showing the server's unapplied amount.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Print a payment ticket (Priority: P1)

A customer pays off part of their credit, or leaves an advance, and asks for a receipt; or one was lost and they come back for a copy. The cashier or supervisor finds the payment in Pagos and opens its ticket, either from the list row or from the payment view. It opens in the app's shared document preview, where they print it on the thermal printer or download it.

Only credit payments ("Pago de crédito") and advances ("Pago anticipado") have a ticket. A counter sale's payment is already covered by the sale's own ticket.

**Why this priority**: It is the only new user-facing capability in this spec, and stores can't hand out a receipt for a credit payment or advance without it. Legacy printed these tickets.

**Independent Test**: Open a credit payment from Pagos, choose "Ver ticket", and confirm the preview shows that payment's 72 mm ticket, then print and download it. Repeat from the list row, and for an advance. Open a counter-sale payment and confirm the ticket action isn't offered.

**Acceptance Scenarios**:

1. **Given** a credit payment or an advance, **When** the user opens its payment view, **Then** a "Ver ticket" action is offered.
2. **Given** that action, **When** the user chooses it, **Then** the shared document preview opens with the payment's ticket, and from there they can print or download it as with every other document.
3. **Given** a credit payment or advance in the payments list, **When** the user looks at its row, **Then** a "Ver ticket" row action is offered and opens the same preview.
4. **Given** a payment of any other type (Contado, Nota de crédito, Gasto, N/A), **When** the user looks at its payment view or its row, **Then** no ticket action is offered.
5. **Given** a payment shown in the all-facilities mode, **When** the user can see the payment, **Then** they can open its ticket the same way.
6. **Given** the ticket can't be produced (the payment was deleted, or the server refuses the type), **When** the preview opens, **Then** it shows the server's message, as for any document that fails to load, and nothing else is printed in its place.

---

### User Story 2 - See customer names at once, and search the facility's payments by customer name (Priority: P2)

A cashier opens Pagos and sees each payment's customer name straight away, instead of a placeholder that fills in row by row. To find a customer's payments quickly, they type part of the customer's name into the search box.

**Why this priority**: The names already show today, just more slowly and with more requests. The search box is new, but the existing customer filter already gives a slower path to the same result.

**Independent Test**: Open Pagos and confirm every row shows its customer's name on the first render with no placeholder. Type part of a known customer's name and confirm only that customer's payments remain. Combine it with a date range and confirm both apply.

**Acceptance Scenarios**:

1. **Given** the payments list or the payment view, **When** it loads, **Then** each payment's customer name is shown as part of that load, with no placeholder and no separate lookup per customer.
2. **Given** a payment whose customer record no longer exists, so the server sends no name, **When** it is shown, **Then** the app falls back to its previous behavior: it looks the customer up, and shows the customer number if that also fails.
3. **Given** the facility-scoped mode, **When** the user types part of a customer's name (in any letter case) into the search box, **Then** only payments of the user's facility whose customer name contains that text are listed, newest first.
4. **Given** a customer-name search and drawer filters (customer, date range, method, verified state, cash session), **When** both are set, **Then** the list shows only payments that match all of them.
5. **Given** a search that matches nothing, **When** the list loads, **Then** the existing empty state says nothing matches and offers to clear the search and filters.
6. **Given** the all-facilities mode, **When** the user looks at its search box, **Then** it still searches by reference, as before. Its hint text tells the two boxes apart.

---

### User Story 3 - Payments from another facility stay hidden, now enforced by the server too (Priority: P2)

A user without Payments Editor access opens a link to another facility's payment, or tries to read another facility's list some other way. The server now refuses these reads itself. The app keeps its own guards and shows the same answers as before.

**Why this priority**: It closes a data-exposure gap that the client was already covering, and it confirms the client's behavior against the server's real answers. Users see no change.

**Independent Test**: As the non-editor test account, open another facility's payment by link and confirm the not-found state. Confirm through the live test that the server itself refuses the payment, its applications and the other facility's list.

**Acceptance Scenarios**:

1. **Given** a user without Payments Editor access, **When** they open the link of another facility's payment, **Then** they see "El pago N no existe.", the same as for a payment that doesn't exist, and no retry button.
2. **Given** that user, **When** the server is asked directly for that payment, its applications or its ticket, **Then** it answers "not found". The live walkthrough checks this.
3. **Given** that user, **When** the server is asked directly for another facility's list, **Then** it refuses it. The live walkthrough checks this.
4. **Given** the server ever refuses a payments list (for example after the user's access changed mid-session), **When** the list screen shows it, **Then** it says the user isn't allowed to see those payments, with no retry button, instead of the generic error with retry.
5. **Given** a user with Payments Editor access, **When** they open another facility's payment, **Then** the payment view loads as before.

---

### User Story 4 - The walkthrough covers the back-office order link and the date picker (Priority: P3)

Two parts of the spec 054 walkthrough never ran end to end against the live tenant: following a payment's application to a back-office order, and choosing a date range through the picker dialog. Closing them gives the payments screens full live coverage.

**Why this priority**: Both behaviors are already covered by unit and widget tests. This is confidence, not new function.

**Independent Test**: Run the payments walkthrough against the dev tenant and confirm it reports both steps as passed, not skipped.

**Acceptance Scenarios**:

1. **Given** the dev tenant has a payment applied to a completed back-office order, **When** the walkthrough opens that payment and chooses the order, **Then** the back-office order screen opens for that order.
2. **Given** the payments list, **When** the walkthrough sets a date range by opening the date chip's picker and choosing dates, **Then** the list narrows to that range and the chip shows it. Choosing "Cualquier fecha" clears it.
3. **Given** a full walkthrough run, **When** it finishes, **Then** no step is recorded as skipped.

---

### Edge Cases

- **Ticket action and payment type.** The action is shown only for credit payments and advances, decided from the payment's type alone. The server refuses every other type, so the app never sends that request.
- **A payment's type is unknown to the app.** No ticket action is offered.
- **Pressing "Ver ticket" twice quickly.** One fetch and one preview, as for other documents (spec 044).
- **Ticket of a payment with reversed applications.** The server leaves reversed applications off the ticket. The app shows what the server renders and doesn't compare it with the payment view.
- **Ticket balance vs "Sin aplicar".** When change was handed back, the ticket's balance can be lower than the "Sin aplicar" amount on screen. That is a known server difference (mictlanix/mbe-api#276), not something this spec fixes.
- **Reprints.** A reprinted ticket carries no "copy" mark (server decision).
- **Customer-name search vs customer filter.** Both can be set at once. They combine, so a name that doesn't match the filtered customer gives an empty list.
- **Switching modes with search text.** The two search boxes mean different things (customer name vs reference), so switching between the facility-scoped and all-facilities modes clears the search text, as unsupported filters are cleared today (spec 054 FR-012).
- **Search text and links.** The search text is kept in the page's link, like the other filters, so reloading or sharing the link restores it.
- **Customer name projected but stale.** The name comes with the payment when it loads. If the customer is renamed while the screen is open, the new name shows on the next load.
- **No dev-tenant data for the back-office link.** If the seeded payment is missing (for example after a database reset), the walkthrough step fails with a clear reason. It isn't silently skipped.

## Requirements *(mandatory)*

### Functional Requirements

**Payment ticket (Story 1, mbe-ui#227)**

- **FR-001**: The payment view MUST offer "Ver ticket" for credit payments and advances, and MUST NOT offer it for any other payment type.
- **FR-002**: The payments list MUST offer the same "Ver ticket" row action under the same rule, in both modes. It MUST follow the app's row-action limit: one action beyond the row's primary action before collapsing into an overflow menu.
- **FR-003**: "Ver ticket" MUST open the app's shared document preview (spec 044) with the ticket the server renders, so the user can print or download it. It MUST NOT print directly without the preview.
- **FR-004**: The app MUST NOT print any other document in place of a payment ticket, such as the receipt of an order the payment was applied to.
- **FR-005**: The ticket action MUST be offered only to users who can read Customer Payments. Since Pagos itself requires that privilege, every user who can open Pagos sees it for eligible payments.
- **FR-006**: If the server can't produce a ticket, the preview MUST show the server's message, as for other documents.

**Customer name and search (Story 2, mbe-ui#223)**

- **FR-007**: The list and the payment view MUST show the customer name that comes with each payment, without a separate lookup per customer.
- **FR-008**: When a payment arrives with no customer name, the app MUST fall back to looking the customer up, and to the customer number if that fails. This is the spec 054 behavior.
- **FR-009**: The facility-scoped mode MUST offer a search box that finds the facility's payments whose customer name contains the typed text, ignoring case. It replaces spec 054 FR-008's "no search box in this mode".
- **FR-010**: The customer-name search MUST combine with every drawer filter of the facility-scoped mode.
- **FR-011**: The all-facilities mode MUST keep its reference search unchanged. Each mode's search box MUST have a hint that names what it searches (customer name or reference).
- **FR-012**: Switching between modes MUST clear the search text.
- **FR-013**: The search text MUST be part of the page's link, like the other filters.

**Facility checks (Story 3, mbe-ui#224)**

- **FR-014**: The client-side facility guards from spec 054 (FR-009, FR-013b) MUST stay in place even though the server now enforces the same rule.
- **FR-015**: Opening another facility's payment without Payments Editor access MUST keep showing the not-found state ("El pago N no existe."), with no retry.
- **FR-016**: If the server refuses a payments list request, the list MUST show a "not allowed" state without a retry, not the generic error.
- **FR-017**: The live walkthrough MUST check, as the non-editor test account, that the server refuses another facility's payment, its applications, its ticket and its list.

**Walkthrough coverage (Story 4, mbe-ui#225)**

- **FR-018**: The dev tenant MUST have at least one payment applied to a completed back-office order, created by a repeatable setup step that can be rerun after a database reset.
- **FR-019**: The live walkthrough MUST follow that payment's application to the back-office order screen, and MUST fail rather than skip if the data is missing.
- **FR-020**: The live walkthrough MUST set a date range through the date chip's picker dialog, and clear it with "Cualquier fecha".
- **FR-021**: The live walkthrough MUST also print-preview a credit payment's or advance's ticket, and confirm the ticket action is absent for a counter-sale payment.

### Key Entities

- **Customer payment**: as in spec 054. It now also carries the customer's name as the server knows it, which can be empty only when the customer record is missing.
- **Payment ticket**: a 72 mm receipt the server renders for one credit payment or advance. It has the store header, folio, date, customer, cashier and session, method, reference, the live applications with their orders, balance and total. It is read-only and isn't stored by the app.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: From Pagos, a user can get a credit payment's or advance's ticket into the print dialog in three actions or fewer: open the ticket, print, confirm.
- **SC-002**: The ticket action appears for 100% of credit payments and advances, and for 0% of other payment types.
- **SC-003**: A page of payments shows every customer name on its first render, with no extra request per customer, except for customers whose record is missing.
- **SC-004**: A user can find a facility payment from a fragment of the customer's name in under 15 seconds from opening Pagos.
- **SC-005**: Users without Payments Editor access see no payment from another facility in 100% of attempts, and the walkthrough confirms the server refuses each of the four reads.
- **SC-006**: The payments walkthrough passes every step against the dev tenant, with none skipped.

## Assumptions

- The server endpoints from mbe-api PRs #273, #274 and #275 are final. Regenerating the API client brings in the customer name, the search parameter and the ticket endpoint.
- The ticket is shown in the same shared preview as the order ticket and the cash cut (spec 044), including its behavior on phone browsers and its "Descargar" fallback.
- Printing right after a credit payment or advance is recorded is out of scope. The app has no flow to record those payments yet; whoever builds those flows adds the print.
- Credit-note tickets belong to the credit-note record (mictlanix/mbe-roadmap#28), not to the payment, and are out of scope.
- The server's "Sin aplicar" amount is shown as it comes. The change-handed-back difference is tracked in mictlanix/mbe-api#276.
- The seeded back-office payment is created against the dev tenant by a repeatable script, in the same way as the non-admin test accounts, because the app itself can't apply a payment to a back-office order yet (mictlanix/mbe-roadmap#26).
- The date-picker walkthrough step runs on the macOS desktop build, like the rest of the walkthrough. Phone devices aren't part of this run.
- The non-editor test account `MBE_QA054_*` (test/integration/TEST_ACCOUNTS.md) is the account for the facility checks.
- Out of scope: verify/reject (#27), applying or reversing payments (#26), credit notes (#28), the received-payments report (#99), export, and changing how "Sin aplicar" is computed.
