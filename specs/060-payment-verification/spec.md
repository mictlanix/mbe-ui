# Feature Specification: Payment Verification

**Feature Branch**: `060-payment-verification`

**Created**: 2026-11-14

**Status**: Draft

**Input**: User description: mictlanix/mbe-roadmap#27. Scope 02 §2.9 (legacy Payments Verification, mbe-api `docs/specs/02-sales.md` §9, SystemObject PaymentsVerification 108). Server side done in mbe-api spec 011, made company-wide in spec 034. Weight: 3 legacy actions. Before specify, the user chose: a queue that starts on transfers but can show other methods; reject included, with an mbe-api issue filed so rejections become visible; a new "Verificación de pagos" screen plus verify and reject actions on the Pagos payment view.

Customers pay by bank transfer, and the cashier records the transfer as a payment. Someone has to confirm that the money actually reached the bank. In the current system, a supervisor opens "Validación de pagos", checks each transfer against the bank statement and marks it verified. The new app shows whether a payment is verified (spec 054) but has no way to verify one.

This feature adds a verification queue to the back office. It lists unverified payments from every facility, starting on transfers. For each payment, the supervisor sees what's needed to find it on the bank statement. They mark it verified, or reject it with a reason when it can't be found. The same two actions are on the Pagos payment view.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Verify transfers against the bank statement (Priority: P1)

Each morning a supervisor opens "Verificación de pagos" with the bank statement beside it. The queue lists unverified transfers from every store, newest first. Each row shows folio, store, date, customer, method, reference and amount. The supervisor narrows it to yesterday and finds the $4,250.00 transfer with reference "SPEI 88213" on the statement. They tap "Verificar" and confirm. The row leaves the queue. In Pagos, that payment now shows "Verificado" and the supervisor's name under "Verificado por".

**Why this priority**: This is the whole legacy screen and the reason for the feature. Without it, no payment recorded in the new app can ever be verified.

**Independent Test**: Seed an unverified transfer. Open the queue as a user with Payments Verification read and update, find the payment, verify it, and check that it leaves the queue and Pagos shows it verified by that user.

**Acceptance Scenarios**:

1. **Given** a user with Payments Verification read, **When** they open the back-office navigation, **Then** "Verificación de pagos" is offered. Without that right it isn't.
2. **Given** the queue opens, **When** it loads, **Then** it lists unverified payments from every facility, method filter set to Transfer, newest first. Each row shows folio, facility, date, customer, method, reference and amount.
3. **Given** the queue, **When** the user sets facility, date range, method or amount range, **Then** the list shows only matching unverified payments. Clearing the method filter shows every method.
4. **Given** a user with Payments Verification update, **When** they tap "Verificar" on a row, **Then** a confirmation names the folio, customer, amount and reference and says verification can't be undone.
5. **Given** the user confirms, **When** the server accepts, **Then** the row leaves the queue and the total count falls by one.
6. **Given** a user with only Payments Verification read, **When** they open the queue, **Then** they see the list but no "Verificar" or "Rechazar" actions.

---

### User Story 2 - Reject a payment that isn't on the statement (Priority: P2)

The supervisor can't find a $12,000.00 "transferencia" on the bank statement. They tap "Rechazar" on its row and type "No aparece en el estado de cuenta del 13/11". The server records the reason and who rejected it. A message confirms the rejection and explains that the payment stays unverified and stays in the queue until someone verifies it.

**Why this priority**: Legacy had no reject. The server offers it so a missing transfer leaves a record instead of being silently skipped. It is useful but not needed to clear the queue, so it comes second.

**Independent Test**: Reject an unverified payment from the queue with a reason. Check that the confirmation explains it remains in the queue, and that the payment is still listed and still unverified.

**Acceptance Scenarios**:

1. **Given** a user with Payments Verification update, **When** they tap "Rechazar" on a row, **Then** a dialog names the folio, customer, amount and reference and asks for a reason.
2. **Given** the reject dialog, **When** the reason is empty or only spaces, **Then** the confirm action is disabled. The reason can't exceed 500 characters.
3. **Given** a reason, **When** the user confirms and the server accepts, **Then** the app confirms the rejection was recorded and says the payment is still unverified and still in the queue.
4. **Given** a rejected payment, **When** the queue reloads, **Then** it is still listed and looks like any other unverified payment (see FR-012).

---

### User Story 3 - Verify or reject from the payment view (Priority: P3)

A supervisor looking up a customer's payment in Pagos sees it marked "Sin verificar". They're holding the bank statement, so they verify it right there instead of going to the queue. The payment view refreshes to "Verificado" with their name.

**Why this priority**: The queue covers the daily routine. This is a second way in for someone who is already looking at the payment.

**Independent Test**: Open an unverified payment in Pagos as a user with Payments Verification update, verify it, and check that the view shows it verified by that user. Open a verified payment and check that neither action is offered.

**Acceptance Scenarios**:

1. **Given** an unverified payment open in Pagos and a user with Payments Verification update, **When** the view loads, **Then** it offers "Verificar" and "Rechazar".
2. **Given** a verified payment, or a user without Payments Verification update, **When** the view loads, **Then** neither action is offered.
3. **Given** the user verifies or rejects, **Then** the same confirmation and reason dialogs as the queue are used.
4. **Given** a verification confirmed from the payment view, **When** it succeeds, **Then** the view shows "Verificado" and the verifier's name. If the Pagos list is open behind it, its row shows the new state too.

---

### Edge Cases

- **Already verified by someone else.** Two supervisors work the same queue. The second to verify is refused. The app says the payment was already verified and removes the row (or refreshes the payment view).
- **Another facility's payment.** The queue lists and acts on payments from every facility. A verifier without Payments Editor read can't open those payments in Pagos (spec 055). So the queue row itself must show everything needed to decide, and must not depend on opening the payment.
- **Rejected payments come back.** The server records only the rejection, so a rejected payment stays unverified, and nothing in the app can show that it was rejected. Each time the queue loads, rejected payments look the same as payments nobody has checked. The rejection still leaves a record with who, when and why. An mbe-api issue asks the server to expose that rejection so the queue can mark or hide those payments later.
- **Rejecting twice.** The server accepts it and records a second rejection. The app doesn't prevent it, because it can't tell.
- **Verifying a payment after its rejection.** Allowed. Rejection doesn't block verification.
- **Empty queue.** The queue says there are no unverified payments for the current filters, and offers to clear them when any are set.
- **Cash and card payments.** They appear only when the user changes the method filter. The queue doesn't hide or block verifying them.
- **Network failure on verify or reject.** The app says the result is unknown and reloads the row, rather than claiming it failed.
- **Last row on a page.** After the last row on a page is verified, the queue loads the previous page instead of showing an empty one.

## Requirements *(mandatory)*

### Functional Requirements

**Queue**

- **FR-001**: The back office MUST offer a "Verificación de pagos" screen only to users with Payments Verification read.
- **FR-002**: The queue MUST list unverified payments from every facility, newest first, paginated. Each row shows folio, facility name, date, customer name, method, reference and amount with currency.
- **FR-003**: The queue MUST filter by facility, date range, method and amount range. The method filter starts at Transfer and can be changed or cleared to show every method.
- **FR-004**: The queue MUST show the total count of unverified payments that match the filters.
- **FR-005**: The queue MUST let the user act on a payment from its row, without opening the payment, whatever its facility.

**Verify**

- **FR-006**: "Verificar" MUST be offered only to users with Payments Verification update, and only on unverified payments.
- **FR-007**: Verifying MUST ask for confirmation. The confirmation names the payment's folio, customer, amount and reference, and says verification can't be undone.
- **FR-008**: After a verification, the payment MUST leave the queue, and the payment view and Pagos list MUST show it verified, with the verifier's name.

**Reject**

- **FR-009**: "Rechazar" MUST be offered only to users with Payments Verification update, and only on unverified payments.
- **FR-010**: Rejecting MUST require a reason that isn't empty or only whitespace, up to 500 characters. The dialog names the payment's folio, customer, amount and reference.
- **FR-011**: After a rejection, the app MUST confirm it was recorded and say the payment stays unverified and stays in the queue.
- **FR-012**: Until the server exposes rejections, the queue MUST NOT claim to know whether a payment was rejected. Rejected and unchecked payments look the same.

**Payment view**

- **FR-013**: The Pagos payment view MUST offer "Verificar" and "Rechazar" on an unverified payment to users with Payments Verification update, using the same dialogs as the queue.

**General**

- **FR-014**: When the server refuses a verification or rejection, the app MUST show the reason in the user's language, from the error code, and reload the affected payment. An already-verified payment is reported as such.
- **FR-015**: Every new label, message and error MUST be available in Spanish and English.
- **FR-016**: An mbe-api issue MUST be filed asking the server to expose a payment's rejections (or a rejected flag on the unverified list), and linked from this spec, before the feature ships.

### Key Entities

- **Customer payment**: money received from a customer. Has a folio, facility, date, customer, method, reference, amount, currency and a verifier (empty until someone verifies it).
- **Verification**: a payment's verifier set to the employee who confirmed it. It can't be undone.
- **Rejection**: a reason recorded against a payment, with who rejected it and when. It doesn't change the payment, and the app can't read it back today.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A supervisor can find a transfer from a given day in the queue and verify it in under 30 seconds.
- **SC-002**: A supervisor can clear a queue of 20 transfers without leaving the screen.
- **SC-003**: In every walkthrough case, a verified payment leaves the queue and shows as verified, with the verifier's name, in Pagos.
- **SC-004**: No rejection can be confirmed without a reason.
- **SC-005**: Users without Payments Verification read don't see the queue. Users without Payments Verification update don't see verify or reject anywhere.
- **SC-006**: A verifier can verify or reject a payment from any facility without needing access to open that payment in Pagos.

## Assumptions

- The rights follow the server: listing needs Payments Verification (108) read, and verify and reject need Payments Verification update. Both act on any facility's payment. Customer Payments rights aren't needed.
- The method filter's default is the legacy setting `PaymentMethodsVerificationRequired = EFT`, which is Transfer in the new app. It is fixed in the app, not configurable per tenant.
- Legacy listed both verified and unverified transfers. The queue lists only unverified ones; verified payments stay visible in Pagos through its verified filter (spec 054).
- Legacy had a free-text search by folio, order number, customer or cashier. The server's unverified list doesn't take one, so the queue has filters only. Folio, customer and reference are on each row for scanning.
- The queue doesn't print or export. Verified payments are read and printed from Pagos.
- Facility names come from the facilities the app already knows.
- Out of scope: undoing a verification (the server has no way to), showing a payment's rejection history, verifying several payments in one action, verifying supplier payments, and per-tenant configuration of which methods need verification.

## Verbatim Constraints

- Server rules relied on: `GET /customer-payments/unverified` (filters `facility`, `date_from`, `date_to`, `method`, `amount_min`, `amount_max`, `skip`, `limit`), `POST /customer-payments/{id}/verify`, `POST /customer-payments/{id}/reject` (body carries `reason`, 1 to 500 characters).
- Error codes: `payment.already_verified`, `incidence.reason_required`.
