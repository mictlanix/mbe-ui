# Feature Specification: CFDI Payment Receipts (REP)

**Feature Branch**: `074-cfdi-payment-receipts`

**Created**: 2026-11-18

**Status**: Draft

**Input**: Covers mictlanix/mbe-roadmap#54 ([UI] Payment complement (REP); scope 10 §2b of mbe-api docs/specs; weight 5 legacy actions). User description: "[UI] Payment complement (REP) — CFDI payment receipts (Pagos 2.0, type 200) for PPD invoices. Build on spec 072 (CFDI stamping/cancellation), spec 073 (CFDI credit notes), spec 066 (invoice list + editor) and spec 054/059 (customer payments)." Server side: mbe-api spec 028 (payment receipts, #53) and spec 039 (stamping and cancellation).

## Context

A **CFDI payment receipt** (type 200, *Recibo Electrónico de Pago* or *complemento de pago*, Pagos 2.0) is the fiscal document billing issues when a customer pays an invoice issued with method **PPD** (paid in installments or later). SAT requires one for each payment received against a PPD invoice. It carries no product lines. It records one payment (date, amount, payment form, operation number, ordering bank) and the PPD invoices that payment settles, with each invoice's installment number, previous balance, amount paid and remaining balance. It has the same life as any fiscal document: draft → sealed → stamped, and it can be cancelled.

Spec 066 built invoices up to sealed. Spec 072 added stamping, refresh and cancellation for every type, so a legacy receipt can already be stamped or cancelled from the app. Spec 073 made credit notes editable. The app cannot yet **create or edit** a payment receipt: today type 200 is read-only.

The server rules (mbe-api spec 028) that shape this spec:

- A receipt is created for a **customer and one of their recipient RFCs**, either by hand or **from a customer payment** (spec 054/059). From a payment, the server copies its date, amount, payment form and reference, keeps the link to that payment, and **proposes the PPD invoices** that hold lines of the orders the payment was applied to, filling amounts in invoice-date order.
- A customer payment backs **at most one live receipt**.
- **Which invoices can be paid:** stamped, live PPD invoices of the receipt's issuer and recipient. Invoices stamped by the legacy system count.
- **Installment** is 1 plus the invoice's earlier live receipts. **Previous balance** is the invoice's total less its live receipts' payments and its live credit notes. The **amount paid** defaults to the smaller of that balance and the payment amount not yet assigned, and cannot exceed the balance.
- The header takes payment date, payment amount, payment form (not 99), operation number (≤ 50 characters), ordering bank, issue date and notes. Terms, usage (CP01) and currency (MXN) are fixed.
- **Confirm** recomputes installments and balances and refuses unless the amounts paid add up exactly to the payment amount. It also refuses a payment date in the future or before an invoice's date.
- An invoice with live receipts cannot be cancelled (spec 072 already shows that refusal). An invoice with an open cancellation takes no new receipt.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Issue a payment receipt from a customer payment (Priority: P1)

A billing clerk opens a customer payment in Pagos (spec 054) that settled orders billed on PPD invoices. They choose "Emitir complemento de pago" and pick the customer's recipient RFC. The app creates a draft receipt with the payment's date, amount, form and reference and the invoices the server proposes, then opens it.

**Why this priority**: Most receipts follow a recorded payment, and starting from it fills almost everything. It is the shortest path to a receipt.

**Independent Test**: Record and apply a payment to an order billed on a stamped PPD invoice, issue a receipt from the payment, and check that the draft opens with the payment's data, links back to the payment, and lists that invoice with installment, previous balance, amount and remaining.

**Acceptance Scenarios**:

1. **Given** a customer payment and a user who can create fiscal documents, **When** they choose "Emitir complemento de pago", pick a recipient RFC of the payment's customer and confirm, **Then** a draft receipt opens with the payment's date, amount, payment form and reference, a link to that payment, and the proposed paid invoices.
2. **Given** a payment whose orders have no stamped PPD invoice of that issuer and recipient, **When** the receipt is created, **Then** the draft opens with no paid invoices and says none were found, and the clerk can add them by hand (User Story 3).
3. **Given** a payment that already has a live receipt, **When** the clerk tries to issue another, **Then** they are told the payment already has a receipt and can open it, and no draft is created.
4. **Given** the issuer has no payment receipt series, **When** the clerk issues a receipt, **Then** they are told so, and no draft is created.
5. **Given** a customer with no recipient RFC, **When** the clerk starts the action, **Then** they are told the customer has no tax data and cannot continue.
6. **Given** a user who cannot create fiscal documents, **When** they open a customer payment, **Then** the action is absent.

---

### User Story 2 - Issue a payment receipt by hand (Priority: P2)

A billing clerk has to issue a receipt for a payment that was not recorded in the new MBE (for example one received before go-live, or recorded in the legacy system). In Facturas they choose "Nuevo complemento de pago", pick the customer and recipient RFC, and get an empty draft receipt. They fill the payment's date, amount and form themselves.

**Why this priority**: During the transition, many PPD invoices were stamped in the legacy system and are paid without a matching payment in the new MBE. The clerk needs a way to cover them, but it is not the common path once payments are recorded here.

**Independent Test**: From Facturas, create a receipt by hand for a customer with a stamped PPD invoice, enter the payment data, add the invoice, confirm.

**Acceptance Scenarios**:

1. **Given** a user who can create fiscal documents, **When** they choose "Nuevo complemento de pago" in Facturas and pick a customer and recipient RFC, **Then** a draft receipt opens with no payment date or amount, payment form 01 (the server's default), no paid invoices and no link to a payment.
2. **Given** the existing "Nueva factura" action, **When** the clerk uses it, **Then** it still creates an invoice, unchanged.

---

### User Story 3 - Fill the payment and the invoices it pays (Priority: P1)

On a draft receipt, the clerk edits the payment data (date, amount, form, operation number, ordering bank, issue date, notes). They add PPD invoices of the same recipient, change the amount paid on each, and remove them. The draft always shows how much of the payment is still unassigned.

**Why this priority**: Proposals are a starting point. The clerk often has to split the payment differently, add an invoice the proposal missed, or correct the payment data. A receipt cannot be sealed until the amounts match the payment.

**Independent Test**: On a draft, set the payment amount, add two invoices, lower one's amount, remove one, and check after each step the installment, previous balance, amount paid, remaining balance and unassigned amount.

**Acceptance Scenarios**:

1. **Given** a draft receipt, **When** the clerk edits the header, **Then** they can change the payment date, payment amount, payment form, operation number, ordering bank, issue date and notes, and nothing else. Terms, usage and currency show read-only.
2. **Given** a draft receipt, **When** the clerk chooses to add an invoice, **Then** they can search stamped invoices of the receipt's issuer and recipient and pick one. It is added with its installment, previous balance, an amount that defaults to the smaller of the balance and the unassigned amount, and the remaining balance.
3. **Given** an invoice that is not PPD, is cancelled or has a cancellation in process, or is already on the receipt, **When** the clerk adds it, **Then** they are told it cannot be paid by this receipt, and it is not added.
4. **Given** a paid invoice on the draft, **When** the clerk changes its amount to more than its previous balance, **Then** they are told the balance, and the amount is not changed.
5. **Given** amounts that would add up to more than the payment amount, **When** the clerk adds or edits an invoice, **Then** they are told the amounts exceed the payment, and nothing changes.
6. **Given** a paid invoice on the draft, **When** the clerk removes it, **Then** it is gone and the unassigned amount goes up by its amount.
7. **Given** a draft receipt, **When** the clerk views it, **Then** no product line, sales order or generic relation action is offered.

---

### User Story 4 - Seal, stamp and finish a payment receipt (Priority: P1)

The clerk confirms the receipt to seal it and stamps it with spec 072's "Timbrar". A sealed receipt can be reopened, as an invoice can.

**Why this priority**: Only a stamped receipt reaches SAT. This completes roadmap#54's flow end to end.

**Independent Test**: Confirm a receipt whose amounts equal the payment; it shows Sellado with a folio from the payment receipt series. Reopen it, change an amount and the payment amount, confirm again (same folio). Stamp it against the simulator; it shows Timbrado with its UUID, and its PDF and XML are available.

**Acceptance Scenarios**:

1. **Given** a draft whose amounts paid do not add up to the payment amount, **When** the clerk confirms it, **Then** they are told the amounts must equal the payment amount, and it stays a draft. The draft already shows the difference before confirm.
2. **Given** a draft with payment form 99 or no payment form, **When** the clerk confirms it, **Then** they are told a receipt needs the actual payment form, and it stays a draft.
3. **Given** a payment date in the future or before one of the paid invoices' dates, **When** the clerk confirms, **Then** they are told the date must fall between the invoices' dates and today, and it stays a draft.
4. **Given** a draft with no paid invoices, or with no payment date or amount, **When** the clerk confirms it, **Then** they are told what is missing, and it stays a draft.
5. **Given** a valid draft, **When** the clerk confirms it, **Then** it shows Sellado with the next folio of the payment receipt series, and the stored installments and balances.
6. **Given** a sealed receipt, **When** the clerk reopens it, **Then** it is a draft again and keeps its folio.
7. **Given** a sealed receipt, **When** the clerk stamps it, **Then** it behaves as spec 072 describes for any document.

---

### User Story 5 - Navigate between a receipt, its payment and its invoices (Priority: P2)

From a receipt, the clerk opens each invoice it pays and the customer payment it came from. In Facturas, receipts are found by filtering by type.

**Why this priority**: Clerks check invoices and the payment while filling a receipt and when a customer asks about one later. The list's type filter (spec 066) already finds receipts. The links are the new part.

**Independent Test**: From a receipt, open a paid invoice and the source payment. In Facturas, filter by "Complemento de pago" and see the new receipt.

**Acceptance Scenarios**:

1. **Given** a receipt in any state, **When** the clerk opens it, **Then** each paid invoice shows its series, folio, UUID, installment, previous balance, amount paid and remaining balance, and opening a row shows that invoice.
2. **Given** a receipt made from a customer payment, **When** the clerk opens it, **Then** it shows that payment's number, and opening it shows the payment (for users who can read payments).
3. **Given** the Facturas list filtered by "Complemento de pago", **When** it loads, **Then** receipts made in the new MBE and in the legacy system are listed.

---

### Edge Cases

- **Two drafts for the same invoice.** Drafts reserve nothing. Each one's balance counts only live (sealed or stamped) receipts, so both can look valid; confirm recomputes, and the second confirm is refused if it overpays.
- **Balances shown on a draft are live.** They are recomputed every time the draft loads, so they can change while the draft is open if another receipt or credit note is sealed for the same invoice. Sealed receipts show the stored values.
- **A credit note sealed after the receipt was drafted** lowers the invoice's balance. If the amount now exceeds it, confirm is refused with the balance.
- **The payment amount is lowered below the amounts already assigned.** The header change is refused (the amounts would exceed the payment); the clerk lowers or removes paid invoices first. So the unassigned amount is never negative.
- **The customer payment is cancelled or edited after the receipt exists.** The receipt keeps its copied data; the app does not resync it (server behaviour). The clerk can edit a draft by hand.
- **Legacy-stamped PPD invoices** can be paid by receipts from the new MBE, and legacy receipts count toward installments and balances.
- **Invoice cancellation.** An invoice with a live receipt cannot be cancelled; spec 072's refusal names the receipts. Cancelling the receipt first (spec 072 flow) frees it.
- **A cancelled receipt** frees its customer payment for a new receipt, and its invoices' balances go back up.
- **Payments in other currencies.** Receipts are MXN at rate 1, as on the server; foreign-currency payments are out of scope (see Assumptions).
- **A user who can read but not update fiscal documents** sees receipts read-only, with no create, header, paid-invoice, confirm or reopen action.
- **A user who can create fiscal documents but cannot read customer payments** does not reach the payment screen, so the only entry left is the by-hand one in Facturas. The link from a receipt to its payment is shown as text, not a link.

## Requirements *(mandatory)*

### Functional Requirements

**Creating**

- **FR-001**: Users who can create fiscal documents (system object 23) MUST be able to issue a payment receipt from a customer payment's detail, choosing one of the payment customer's recipient RFCs and confirming. The action MUST be absent for users without that right.
- **FR-002**: Users who can create fiscal documents MUST be able to create a payment receipt by hand from the Facturas list, choosing a customer and one of their recipient RFCs. The existing new-invoice action MUST stay as it is.
- **FR-003**: After a receipt is created, the app MUST open the new draft. When a receipt created from a payment has no proposed invoices, the draft MUST say that none were found to users who can edit it.
- **FR-004**: When the customer payment already has a live receipt, the app MUST say so and offer to open that receipt.

**Payment data**

- **FR-005**: The header of a draft receipt MUST let the user change the payment date, payment amount, payment form, operation number (at most 50 characters), ordering bank, issue date and notes, and MUST NOT offer the invoice header fields. Terms, CFDI usage and currency MUST show read-only.
- **FR-006**: The payment form list for a receipt MUST NOT offer 99 ("por definir"). When the payment form is 99 (possible only on legacy drafts, since the server starts every receipt on 01), the draft MUST say a real payment form is needed before confirming.

**Paid invoices**

- **FR-007**: Users who can update fiscal documents MUST be able to add a paid invoice to a draft receipt by searching stamped invoices of the receipt's issuer and recipient, optionally with an amount. The amount MUST default to the smaller of the invoice's balance and the unassigned payment amount.
- **FR-008**: Users who can update fiscal documents MUST be able to change a paid invoice's amount and remove a paid invoice from a draft receipt.
- **FR-009**: Each paid invoice MUST show its series, folio, UUID, installment, previous balance, amount paid and remaining balance, and open the invoice when chosen.
- **FR-010**: The draft MUST show the payment amount, the sum of the amounts paid, and the unassigned difference, and MUST show clearly when they do not match.
- **FR-011**: A draft receipt MUST NOT offer product lines, sales orders, generic relations or a series change.

**Confirm, reopen, life after**

- **FR-012**: Confirm and reopen MUST work on receipts as they do on invoices (spec 066), including the 72-hour issue-date rule and the folio kept on reopen.
- **FR-013**: Stamping, refresh, cancellation, PDF and XML of a receipt MUST work as spec 072 and spec 066 describe, with no receipt-specific behaviour.
- **FR-014**: Only draft receipts MUST be editable. Receipts in any other state, including legacy ones, show their payment data and paid invoices read-only.

**Viewing**

- **FR-015**: A receipt MUST show as "Complemento de pago" wherever a document type appears. Its detail MUST show the payment data and the paid invoices in every state, and, when it came from a customer payment, that payment's number, opening the payment for users who can read payments.

**Errors and access**

- **FR-016**: Every refusal from these actions MUST be shown with localized text for its error code, per the constitution: invoice cannot be paid by this receipt; amount above the invoice's balance (with the balance); amounts above the payment amount; amounts not equal to the payment amount at confirm; payment date out of range; payment form required; payment already has a receipt (with a way to open it); payment of another customer; receipt pays no invoice; receipt missing payment date or amount; invoice already on the receipt; issuer without a payment receipt series; field not allowed for this type; action not available for this type; and the codes specs 066, 072 and 073 already map, reused.
- **FR-017**: Every action in this spec MUST be absent, never disabled, for users without the right the server checks, and absent in states where it does not apply.
- **FR-018**: While a request on the receipt is running, the user MUST NOT be able to start a second action on it from this screen.
- **FR-019**: All user-facing text MUST be in Spanish (with English where the app is localized), with amounts, dates and identifiers formatted by the app's shared formatting.

### Key Entities

- **CFDI payment receipt**: A fiscal document of type 200 (Pagos 2.0) with no product lines. It holds the payment data (date, amount, payment form, operation number, ordering bank), the paid invoices, an optional link to the customer payment it came from, and the same states, stamp and cancellation history as any fiscal document (spec 072).
- **Paid invoice**: One PPD invoice a receipt pays: its series, folio and UUID, installment number, previous balance, amount paid, and remaining balance.
- **Customer payment**: The payment recorded in Pagos (spec 054/059) a receipt can start from. It backs at most one live receipt.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A clerk can go from a recorded customer payment to a sealed payment receipt for one PPD invoice in under 1 minute.
- **SC-002**: A receipt made in the app, sealed and stamped against the simulator, shows Timbrado with a UUID and offers PDF and XML.
- **SC-003**: Every refusal a clerk can trigger while creating, filling, confirming or reopening a receipt shows a specific message. None shows a generic error or raw server text.
- **SC-004**: A user without create access to fiscal documents cannot start a receipt, and a user without update access cannot change one.
- **SC-005**: No receipt can be sealed with payment form 99, with amounts that do not add up to the payment amount, or with an amount above an invoice's balance. The app says why in each case, and the draft shows a mismatch before the clerk tries to confirm.

## Assumptions

- **Two entry points**: the customer payment's detail (the main path, User Story 1) and a by-hand receipt from Facturas (User Story 2, for payments not recorded in the new MBE). Neither the invoice detail nor the payments list gets an entry.
- **Recipient is picked by the clerk**: a customer payment does not carry a recipient RFC, so the clerk picks one of the customer's, as in spec 066's new-invoice flow. The issuer and series are the server's defaults (the store's issuer and its first payment receipt series).
- **Invoice search cannot filter to PPD**: the fiscal document list has no filter by payment terms or recipient. The invoice picker lists stamped invoices of the issuer, starts its search at the recipient's RFC, and drops other recipients, as spec 072's picker does. A non-PPD invoice picked is refused by the server with a specific message. The balance is known only once the invoice is added. A PPD filter on the list is an mbe-api follow-up, not part of this spec.
- **The payment does not show its receipt**: the customer payment record has no link to its receipt, so the payment detail does not show one. Issuing a second receipt is refused, and the message names the existing one.
- **Unverified payments**: the server does not require a payment to be verified (spec 060) before issuing a receipt, and neither does the app.
- **No delete of drafts**: as with invoices in spec 066, a draft receipt cannot be deleted; it stays as a draft.
- **Rights**: creating needs Create on 23; header, paid invoices, confirm and reopen need Update on 23. These are what the server checks. Fiscal documents have no facility scope. Opening the source payment needs read access to customer payments.
- **Currency**: receipts are MXN at rate 1. Paying foreign-currency invoices, or receipts for foreign-currency payments, is out of scope, as on the server.
- **Naming**: the type's Spanish label changes from the existing "Recibo de pago" to "Complemento de pago" everywhere it appears, including spec 065's series list. English keeps "Payment receipt".
- **Email** of a stamped receipt stays out of scope, as in specs 072 and 073.
- **No new navigation**: everything happens on the existing Facturas list, document detail and customer payment detail.
- **Live verification** runs against the dev tenant with the simulated PAC. It needs an issuer with a payment receipt series and a stamped PPD invoice. It consumes folios, so it is dev only, and the user is asked before it runs.
