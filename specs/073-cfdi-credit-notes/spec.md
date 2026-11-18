# Feature Specification: CFDI Credit Notes

**Feature Branch**: `073-cfdi-credit-notes`

**Created**: 2026-11-18

**Status**: Draft

**Input**: Covers mictlanix/mbe-roadmap#56 ([UI] CFDI credit notes; scope 10 §2b of mbe-api docs/specs; weight 5 legacy actions). User description: "[UI] CFDI credit notes. Build on spec 072 (CFDI stamping/cancellation) and spec 056 (credit notes)." Server side: mbe-api spec 028 (credit notes, #55) and spec 039 (stamping and cancellation).

## Context

A **CFDI credit note** (type 100, *egreso*) is the fiscal document billing issues to reduce a stamped invoice: goods returned, or a discount given after the sale. It relates the one invoice it reduces with SAT relation type 01, carries lines copied from that invoice or added by hand (for example a "Descuento" concept), and goes through the same life as an invoice: draft → sealed → stamped, and it can be cancelled.

Spec 066 built invoices up to sealed. Spec 072 added stamping, refresh and cancellation for every document type, so a credit note made by the legacy system can already be stamped or cancelled from the app. What the app cannot do yet is **create and edit** a credit note: today it shows type 100 as read-only.

The server rules (mbe-api spec 028) that shape this spec:

- A credit note is created **for one stamped, live invoice**. It takes that invoice's customer, recipient, issuer, store, payment form and CFDI usage; its terms are always PUE; its series is the issuer's credit-note series.
- Its lines come from two sources: **copied from the invoice** (same product, SAT keys, price, discount and tax, at a quantity no larger than the invoice line's), or **a product added by hand** (needs the standalone fiscal documents right, as in spec 066).
- **Confirm refuses** a payment form of 99 ("por definir"), and a total above what remains of the invoice after its other live credit notes.
- An invoice with an open cancellation takes no new credit note; an invoice with a live credit note cannot be cancelled (spec 072 already shows that refusal).
- A credit note is not the store credit of spec 056 ("Notas de crédito" in Ventas). Refunds never create fiscal credit notes, and a fiscal credit note moves no money.

On mbe_dev, every credit note relates one invoice (112) or none (11, legacy only); all 16 since 2023 are PUE with the invoice's payment form.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Start a credit note from an invoice (Priority: P1)

A billing clerk who must reduce a stamped invoice opens it in Facturas and chooses "Emitir nota de crédito". The app creates a draft credit note related to that invoice and opens it, ready for lines.

**Why this priority**: Every credit note starts here. Without it nothing else in this spec is reachable.

**Independent Test**: Open an issued invoice, issue a credit note, and check that a draft credit note opens with the invoice's customer, recipient, issuer, payment form and usage, PUE terms, and a read-only relation 01 to that invoice.

**Acceptance Scenarios**:

1. **Given** an issued (stamped, live) invoice and a user who can create fiscal documents, **When** they choose "Emitir nota de crédito" and confirm, **Then** a draft credit note opens, related to that invoice with type 01, with the invoice's customer, recipient, issuer, payment form and usage, and PUE terms.
2. **Given** an invoice that is draft, sealed, stamping, cancellation pending or cancelled, **When** the clerk opens it, **Then** "Emitir nota de crédito" is not offered.
3. **Given** a document that is not an invoice (a credit note, payment receipt or another type), **When** the clerk opens it, **Then** "Emitir nota de crédito" is not offered.
4. **Given** the invoice's issuer has no credit-note series, **When** the clerk issues a credit note, **Then** they are told the issuer has no credit-note series, and no draft is created.
5. **Given** a user who cannot create fiscal documents, **When** they open an issued invoice, **Then** the action is absent.

---

### User Story 2 - Fill a credit note with lines (Priority: P1)

On the draft credit note, the clerk picks lines of the related invoice to credit, each at its full quantity or less (a partial return), and can add a product by hand for a discount concept. They can change a line's quantity, price or discount and remove lines, and they see the credit note's totals as they go.

**Why this priority**: A credit note without lines cannot be sealed. Copying from the invoice is how returns are credited; the hand-added line is how discounts are credited.

**Independent Test**: On a draft credit note, copy two lines of the invoice, lower one's quantity, add a service product renamed "Descuento" at a set price, remove one line, and check the lines and totals after each step.

**Acceptance Scenarios**:

1. **Given** a draft credit note, **When** the clerk chooses to add lines from the invoice, **Then** they see the related invoice's lines (code, description, quantity, unit price, discount, tax) and can pick one or more, each with a quantity that defaults to the invoice line's.
2. **Given** a quantity above the invoice line's, **When** the clerk adds or edits that line, **Then** they are told the most it can be, and the line is not saved at that quantity.
3. **Given** a user with the standalone fiscal documents right, **When** they add a product by hand, **Then** it is added under spec 066's manual-line rules and can be renamed, priced and discounted.
4. **Given** a user without that right, **When** they view the draft, **Then** the hand-added product action is absent, and copying from the invoice is still offered.
5. **Given** a draft with lines, **When** the clerk edits a line's quantity, price or discount, or removes it, **Then** the line and the totals reflect the change.
6. **Given** a draft credit note, **When** the clerk views it, **Then** no "add sales order" or "add relation" action is offered, and its relation to the invoice cannot be changed or removed.

---

### User Story 3 - Seal, stamp and finish a credit note (Priority: P1)

The clerk reviews the header (payment form, CFDI usage, issue date, reference, notes), confirms the credit note to seal it, and stamps it with spec 072's "Timbrar" action. A sealed credit note can be reopened, as an invoice can.

**Why this priority**: Only a stamped credit note reduces the invoice fiscally. This completes roadmap#56's flow end to end.

**Independent Test**: Confirm a credit note with lines and a real payment form; it shows Sellado with a folio from the credit-note series. Reopen it, change a quantity, confirm again (same folio). Stamp it against the simulator; it shows Timbrado with its UUID, and its PDF and XML are available.

**Acceptance Scenarios**:

1. **Given** a draft credit note, **When** the clerk edits the header, **Then** they can change the payment form, CFDI usage, issue date, reference and notes, and nothing else.
2. **Given** a credit note whose payment form is 99, **When** the clerk confirms it, **Then** they are told a credit note needs the actual payment form, and it stays a draft.
3. **Given** an invoice whose payment form is 99 (a PPD invoice), **When** a credit note is created for it, **Then** the draft shows that a real payment form must be chosen before confirming.
4. **Given** a credit note whose total exceeds what remains of the invoice after its other live credit notes, **When** the clerk confirms it, **Then** they are told the invoice's series and folio and the amount that remains, and it stays a draft.
5. **Given** a valid draft credit note, **When** the clerk confirms it, **Then** it shows Sellado with the next folio of the credit-note series.
6. **Given** a sealed credit note, **When** the clerk reopens it, **Then** it is a draft again and keeps its folio.
7. **Given** a sealed credit note, **When** the clerk stamps it, **Then** it behaves as spec 072 describes for any document (issued, stamping, or refused with the PAC's message).

---

### User Story 4 - Navigate between an invoice and its credit notes (Priority: P2)

From a credit note, the clerk opens the invoice it reduces. In the Facturas list, the clerk can find credit notes by filtering by type.

**Why this priority**: Clerks check the invoice while filling a credit note, and later look for a credit note when the customer asks. The list's type filter (spec 066) already covers finding them; the link to the invoice is the new part.

**Independent Test**: From a credit note, open its invoice through the relation. In Facturas, filter by "Nota de crédito" and see the new credit note.

**Acceptance Scenarios**:

1. **Given** a credit note in any state, **When** the clerk opens it, **Then** it shows the related invoice's series, folio and UUID, and opening it shows that invoice.
2. **Given** the Facturas list filtered by type "Nota de crédito", **When** it loads, **Then** credit notes made in the new MBE and in the legacy system are listed.
3. **Given** a legacy credit note with no related invoice, **When** the clerk opens it, **Then** it shows no relation, and it is read-only unless it is a draft made in the new MBE.

---

### Edge Cases

- **Several credit notes for one invoice.** Each one's limit is what remains of the invoice after the others that are live (sealed or stamped, not cancelled). Drafts reserve nothing, so two drafts can each look valid and the second to confirm is refused.
- **Legacy-stamped invoices** can get credit notes from the new MBE, as the server allows.
- **Invoice cancellation pending.** The invoice takes no new credit note while its cancellation is open; the action is not offered and the server's refusal covers a race.
- **The invoice changes state while the credit note is a draft** (someone cancels it). Confirm is refused with the server's message, and the draft stays a draft (drafts cannot be deleted, as in spec 066).
- **Copied line quantity** is checked against the invoice line's quantity, not against what earlier credit notes already credited. The amount limit at confirm is what stops crediting more than was invoiced.
- **Cancelling a stamped credit note** goes through spec 072's cancel flow. Once it is cancelled, the invoice can be cancelled too, and the invoice's orders count as unpaid again (server rule).
- **Credit notes in other currencies.** Credit notes are MXN at rate 1, as on the server.
- **Naming.** Inside Facturas, "Nota de crédito" means the CFDI. The store credit of spec 056 keeps its own screen under Ventas and is not linked from here.
- **A user who can read but not update fiscal documents** sees credit notes read-only, with no create, line, header, confirm or reopen action.

## Requirements *(mandatory)*

### Functional Requirements

**Creating**

- **FR-001**: Users who can create fiscal documents (system object 23) MUST be able to issue a credit note from an issued invoice's detail, after confirming the action. The action MUST be absent for any other document type, any other state, and users without that right.
- **FR-002**: After it is created, the app MUST open the new draft credit note.
- **FR-003**: A draft credit note MUST show its related invoice (relation 01) as read-only, with series, folio and UUID, and a way to open that invoice.

**Lines**

- **FR-004**: Users who can update fiscal documents MUST be able to copy one or more lines of the related invoice into a draft credit note, each at a quantity greater than 0 and no greater than the invoice line's, defaulting to the invoice line's.
- **FR-005**: Users with the standalone fiscal documents right (system object 56, create) MUST be able to add a product by hand, under spec 066's manual-line rules. The action MUST be absent without that right.
- **FR-006**: Users who can update fiscal documents MUST be able to edit a draft credit note line's quantity, price, discount and description, and remove it, under spec 066's line rules. A copied line's quantity MUST NOT exceed its invoice line's.
- **FR-007**: A draft credit note MUST NOT offer adding sales orders, adding or removing relations, or changing the series.
- **FR-008**: The draft MUST show the credit note's subtotal, taxes and total, computed as spec 066 computes an invoice's.

**Header, confirm, reopen**

- **FR-009**: The credit note's header MUST let the user change the payment form, CFDI usage, issue date, reference and notes, and MUST NOT offer the other invoice header fields. Terms MUST show as PUE, read-only.
- **FR-010**: When the payment form is 99, the draft MUST say a real payment form is needed before confirming.
- **FR-011**: Confirm and reopen MUST work on credit notes as they do on invoices (spec 066), including the 72-hour issue-date rule and the folio kept on reopen.
- **FR-012**: When confirm is refused because the credit note exceeds what remains of the invoice, the message MUST name the invoice by series and folio and give the remaining amount.

**Viewing**

- **FR-013**: A credit note MUST show as "Nota de crédito" wherever a document type appears, and its detail MUST show the related invoice in every state.
- **FR-014**: Stamping, refresh, cancellation, PDF and XML of a credit note MUST work as spec 072 and spec 066 describe, with no credit-note-specific behaviour.
- **FR-015**: Only drafts of invoices and credit notes made in the new MBE MUST be editable. Other types stay read-only, as in spec 066.

**Errors and access**

- **FR-016**: Every refusal from these actions MUST be shown with localized text for its error code, per the constitution: invoice not creditable; credit note above the invoice's remaining total (with series, folio, remaining amount); copied quantity above the invoice line's (with the maximum); payment form required; issuer without a credit-note series; field not allowed for this type; action not available for this type; and the codes spec 066 and 072 already map, reused.
- **FR-017**: Every action in this spec MUST be absent, never disabled, for users without the right the server checks, and absent in states where it does not apply.
- **FR-018**: While a request on the credit note is running, the user MUST NOT be able to start a second action on it from this screen.
- **FR-019**: All user-facing text MUST be in Spanish (with English where the app is localized), with amounts, dates and identifiers formatted by the app's shared formatting.

### Key Entities

- **CFDI credit note**: A fiscal document of type 100 (egreso), with lines, a header (payment form, usage, issue date, reference, notes; terms always PUE) and one type-01 relation to the invoice it reduces. It has the same states, stamp and cancellation history as any fiscal document (spec 072).
- **Credited invoice**: The stamped, live invoice a credit note reduces. It supplies the parties, the lines that can be copied, and the limit: its total less its other live credit notes.
- **Credit note line**: Either a copy of an invoice line (same product, SAT keys, price, discount, tax; quantity up to the invoice line's) or a product added by hand.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A clerk can go from an issued invoice to a sealed credit note that credits part of one line in under 2 minutes.
- **SC-002**: A credit note made in the app, sealed and stamped against the simulator, shows Timbrado with a UUID and offers PDF and XML.
- **SC-003**: Every refusal a clerk can trigger while creating, filling, confirming or reopening a credit note shows a specific message. None shows a generic error or raw server text.
- **SC-004**: A user without create access to fiscal documents cannot start a credit note, and a user without update access cannot change one.
- **SC-005**: No credit note can be sealed with a payment form of 99 or a total above what remains of its invoice; the app says why in each case.

## Assumptions

- **Entry point**: A credit note is started only from an issued invoice's detail. The Facturas list's "Nueva" keeps creating invoices. This matches the server, which needs the invoice up front, and how a clerk reaches the invoice anyway (search by folio, UUID or RFC).
- **What remains of the invoice is not shown up front**: the server does not report the invoice's remaining creditable amount, or its credit notes, before confirm. The app relies on confirm's refusal, which gives the remaining amount. If clerks find that too late, the remaining amount on the invoice is an mbe-api follow-up, not part of this spec.
- **Copied lines are not traced back**: the server keeps a copied line's source order line but not its source invoice line, so the draft shows lines without a "copied from" mark, and the line picker may offer a line already copied. Copying it again adds a second line.
- **No delete of drafts**: as with invoices in spec 066, a draft credit note cannot be deleted; it stays as a draft.
- **Rights**: creating needs Create on 23; lines, header, confirm and reopen need Update on 23; a hand-added product needs Create on 56. These are what the server checks. Fiscal documents have no facility scope.
- **Naming**: "Nota de crédito" (CFDI) is the existing type label in Facturas. Store credit (spec 056) is unchanged and unrelated.
- **Email** of a stamped credit note stays out of scope, as in spec 072.
- **No new navigation**: everything happens on the existing Facturas list and document detail.
- **Live verification** runs against the dev tenant with the simulated PAC and needs an issuer with a credit-note series. It consumes credit-note folios, so it is dev only, and the user is asked before it runs.
