# Feature Specification: Invoice List, View, PDF and Editor

**Feature Branch**: `066-invoice-list-editor`

**Created**: 2026-11-16

**Status**: Draft

**Input**: Covers mictlanix/mbe-roadmap#48 ([UI] Invoice editor) and mictlanix/mbe-roadmap#49 ([UI] Invoice list, view and PDF). User description: "Invoice list, view, PDF and editor (back office). Source of truth: mbe-api docs/specs/10-fiscal-documents.md §2 (incl. 'New MBE: invoices up to a sealed CFDI (spec 027, #47)') and mbe-api specs/020-cfdi-invoice-pdf. List fiscal documents, open one read-only, download XML and PDF of an issued document; create and edit invoice drafts (lines from sales orders, manual lines, header, relations 04/07), confirm to a sealed invoice and reopen it. Until stamping ships, invoices made in the new MBE stop at sealed, so PDF/XML only work for documents issued by the legacy system."

## Context

This adds the back office's first fiscal-document screens. The server work is already done: the read side is mbe-api spec 020 (closed roadmap#47 covers the write side), and the generated client has every route this spec needs.

What the user can do here ends at a **sealed** invoice. Stamping by the PAC (roadmap#46), cancellation (#52), credit notes (#56), payment receipts and email are separate roadmap items. A document's state is one of:

| State | Meaning | Editable |
|---|---|---|
| Draft | Being prepared; no folio yet, or reopened with its folio kept | Yes |
| Sealed | Validated, folio assigned, signed XML stored, not yet stamped | No (can be reopened) |
| Issued | Stamped by SAT; has a UUID | No |
| Cancelled | Cancelled | No |

Because stamping is not available yet, the PDF and XML download work only for documents issued by the legacy system. Invoices made in the new MBE stay sealed until roadmap#46 ships.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Find a fiscal document (Priority: P1)

A billing clerk opens "Facturas" in the back office and finds a document by series and folio, UUID, or the recipient's RFC or name. They can narrow the list by issuer, document type, state and issue-date range. Each row shows the series and folio, type, issuer, recipient, issue date, state and total.

**Why this priority**: Every other story starts from this list. It also replaces the legacy lookup clerks use daily to answer customer questions about invoices.

**Independent Test**: With an account that can read fiscal documents, open the list, search for a known legacy invoice by folio and then by recipient RFC, and apply each filter. The expected rows appear, newest first.

**Acceptance Scenarios**:

1. **Given** a user with read access to fiscal documents, **When** they open Facturas, **Then** they see fiscal documents of every type, newest first, one page at a time.
2. **Given** the list, **When** the user types a series and folio, a UUID, or part of a recipient's RFC or name, **Then** only matching documents are shown.
3. **Given** the list, **When** the user filters by issuer, type, state or issue-date range, **Then** only matching documents are shown and the filter button shows how many filters are active.
4. **Given** a user without read access to fiscal documents, **When** they look at the navigation, **Then** Facturas is not offered, and opening its address directly shows the no-access screen.

---

### User Story 2 - View a document and get its PDF and XML (Priority: P1)

From the list, the clerk opens a document and sees its header (issuer, recipient, type, series and folio, dates, payment terms and form, CFDI usage, currency, UUID when stamped, cancellation date when cancelled), its state, its lines and its totals. For an issued document they can preview, print or download the PDF, and download the XML.

**Why this priority**: Customers ask for copies of their invoices every day, and the legacy invoices the new MBE inherits must be reachable from it.

**Independent Test**: Open an issued legacy invoice, check the header and lines, preview the PDF and download the XML. The XML file is named `{issuer RFC}-{series}{folio padded to 6 digits}.xml`.

**Acceptance Scenarios**:

1. **Given** an issued document, **When** the user opens it, **Then** they see its header, state, lines and totals, and the PDF and XML actions are available.
2. **Given** an issued document, **When** the user chooses the PDF, **Then** they can preview, print or save it.
3. **Given** an issued document, **When** the user downloads the XML, **Then** they receive the stored file unchanged under the legacy file name.
4. **Given** a draft or sealed document, **When** the user opens it, **Then** the PDF and XML actions are not offered, and a note explains that they become available once the document is stamped.
5. **Given** an issued document whose PDF the server refuses (not version 4.0, XML missing or unreadable), **When** the user requests it, **Then** they see the server's reason in Spanish, not a generic failure.
6. **Given** a credit note, a payment receipt or any non-invoice document, **When** the user opens it, **Then** it is shown read-only with no edit actions.

---

### User Story 3 - Invoice sales orders (Priority: P1)

The clerk starts a new invoice by choosing the customer and one of that customer's taxpayer records (RFC). The system fills in the store, issuer, series and default terms. The clerk then adds one or more completed sales orders. Each order contributes its invoiceable lines at the quantity not yet invoiced or refunded. Adding the same order twice adds nothing new.

**Why this priority**: Invoicing sales orders is the main way invoices are made (10,698 invoices in the last 24 months of legacy use).

**Independent Test**: Create an invoice for a customer with a completed order, add the order, and check that the lines and quantities match what remains to invoice. Add the same order again and check that nothing changes.

**Acceptance Scenarios**:

1. **Given** a user who can create fiscal documents, **When** they choose New invoice, a customer and one of the customer's RFCs, **Then** a draft invoice opens with the issuer, series, store and default terms filled in.
2. **Given** a customer with no taxpayer records, **When** the user picks the customer, **Then** no RFC can be chosen and the user is told the customer needs one first.
3. **Given** a store whose issuer has no invoice series, **When** the user creates an invoice, **Then** the server's refusal ("the issuer has no invoice series") is shown and no draft is created.
4. **Given** a draft, **When** the user adds a completed, non-cancelled sales order, **Then** its invoiceable lines are added at their remaining quantity, each showing which order it came from.
5. **Given** a draft that already holds an order's lines, **When** the user adds that order again, **Then** no line is duplicated.
6. **Given** a draft, **When** the user tries to add an order that is not completed, is cancelled, or has nothing left to invoice, **Then** they see the server's reason and the draft is unchanged.

---

### User Story 4 - Edit an invoice draft (Priority: P2)

On a draft, the clerk adjusts lines (quantity, price, discount, tax rate, description, comment), removes lines, and adds products by hand when they hold the standalone-invoice right. They also edit header fields: payment terms (PUE/PPD), payment form, CFDI usage, issue date, payment reference, notes and, with the extra right, the issuing store.

**Why this priority**: Most invoices need small adjustments before they go out. Standalone invoices (service charges, concepts with no sales order) depend on manual lines.

**Independent Test**: On a draft, change a line's quantity and discount, delete a line, add a manual product line, switch the terms to PPD, and set an issue date. Each change persists after reopening the draft.

**Acceptance Scenarios**:

1. **Given** a draft, **When** the user edits a line's quantity, price, discount or tax rate within the allowed values, **Then** the line and the invoice totals update.
2. **Given** a line that came from a sales order, **When** the user sets a quantity above what remains to invoice, **Then** the change is refused with the server's reason and the line keeps its previous quantity.
3. **Given** a line, **When** the user clears its description and saves, **Then** the description goes back to the product's name.
4. **Given** a user with the standalone-invoice right, **When** they add a product by hand, **Then** a line is added with quantity 1 at the customer's price-list price and the product's tax settings.
5. **Given** a user without the standalone-invoice right, **When** they edit a draft, **Then** the add-product action is not offered.
6. **Given** a draft, **When** the user switches the terms to PPD, **Then** the payment form becomes 99 (to be defined) and cannot be changed while PPD is selected.
7. **Given** a draft, **When** the user sets an issue date in the future or more than 72 hours ago, **Then** it is refused with a clear message.
8. **Given** a draft that already has a folio (it was reopened), **When** the user looks at the series, **Then** it is shown but cannot be changed.
9. **Given** a user without the issuing-store right, **When** they edit the header, **Then** the store cannot be changed.

---

### User Story 5 - Confirm (seal) an invoice and reopen it (Priority: P2)

When the draft is ready, the clerk confirms it. The server validates it, assigns the next folio, and signs and stores the XML. The invoice becomes sealed and read-only. If a mistake is found before stamping, the clerk reopens it: it returns to draft and keeps its folio, which the next confirm reuses.

**Why this priority**: This is the end of the flow available before stamping exists. It proves that an invoice built in the new MBE is complete and valid.

**Independent Test**: Confirm a valid draft and check that it shows a folio, the Sealed state and no edit actions. Reopen it and check that it is a draft again with the same folio. Confirm a draft that has no lines and check that the reason is shown.

**Acceptance Scenarios**:

1. **Given** a valid draft, **When** the user confirms it, **Then** it shows the Sealed state and its series and folio, and it can no longer be edited.
2. **Given** a draft that fails validation (no lines, a line without SAT keys, quantities above what remains, recipient without regime or postal code, issue date outside 72 hours, no valid certificate), **When** the user confirms, **Then** the server's reason is shown in Spanish and the draft stays a draft with no folio used.
3. **Given** a sealed invoice, **When** the user reopens it after confirming the action, **Then** it becomes a draft again and keeps its folio.
4. **Given** a sealed invoice, **When** the user views it, **Then** the screen tells them stamping is not yet available in the new system.

---

### User Story 6 - Relate an invoice to earlier CFDIs (Priority: P3)

Some invoices must cite earlier ones: an invoice that replaces a cancelled one (relation 04, substitution), or one that applies an advance payment (relation 07). On a draft, the clerk adds or removes related documents of one relation type.

**Why this priority**: SAT requires it for substitutions and advances, but these cases are uncommon compared with ordinary invoices.

**Independent Test**: On a draft, add a cancelled stamped invoice of the same issuer and recipient as a 04 relation, then try to add a 07 relation and check that it is refused because an invoice uses one relation type. Remove the relation.

**Acceptance Scenarios**:

1. **Given** a draft, **When** the user adds a 04 relation to a cancelled, stamped invoice of the same issuer and recipient, **Then** it is listed under the draft's related documents.
2. **Given** a draft, **When** the user adds a 07 relation to a stamped, non-cancelled document of the same issuer and recipient that is not a credit note or payment receipt, **Then** it is listed.
3. **Given** a draft with relations of one type, **When** the user adds a relation of the other type, **Then** it is refused with the server's reason.
4. **Given** a draft with a relation, **When** the user removes it, **Then** it disappears from the list.

---

### Edge Cases

- A document of a type other than invoice (credit note, payment receipt, legacy fee or rent receipt) appears in the list and opens read-only. This spec never offers to edit it.
- A legacy draft invoice (never completed, never sealed) opens as a draft and can be edited like a new one, since the server treats it the same.
- A document of a version older than 4.0 shows its data. The XML downloads, but the PDF is refused with the server's version error.
- An issued document whose stored XML is missing: both downloads fail with the server's "XML missing" error.
- A date-range filter hides drafts, because a draft has no issue date yet; the filter says so.
- Two clerks edit the same draft. The server applies each change as it arrives; after a refusal or a save, the screen shows the document as the server returned it.
- The customer's RFC is the general public RFC (XAXX010101000). The recipient's postal code comes from the store, as the server sets it.
- A sales order line whose quantity is fully invoiced or refunded is not added; if nothing remains on the whole order, the user is told.
- A user can read fiscal documents but not update them: every document opens read-only, with no New, edit, confirm or reopen actions.
- The user leaves a draft with unsaved edits in a line or header form: they are warned before losing them, as in other back-office forms.

## Requirements *(mandatory)*

### Functional Requirements

**List (roadmap#49)**

- **FR-001**: The back office MUST offer a Facturas list of all fiscal documents, newest first and paginated, to users with read access to fiscal documents (system object 23).
- **FR-002**: The list MUST search by series and folio, UUID, or recipient RFC or name.
- **FR-003**: The list MUST filter by issuer, document type, state (draft, sealed, issued, cancelled) and issue-date range, through the shared filter drawer.
- **FR-004**: Each row MUST show series and folio, type, issuer, recipient name and RFC, issue date, state and total.

**View, PDF and XML (roadmap#49)**

- **FR-005**: Users MUST be able to open any document and see its header, state, lines, totals and, when it has any, its related documents.
- **FR-006**: For an issued document, users MUST be able to preview, print and save the PDF the server renders. The UI MUST NOT build its own PDF.
- **FR-007**: For an issued document, users MUST be able to download the stored XML, named `{issuer RFC}-{series}{folio padded to 6 digits}.xml`.
- **FR-008**: The PDF and XML actions MUST NOT be offered for a draft or sealed document. A sealed invoice MUST say that stamping is not yet available.
- **FR-009**: Server refusals of a PDF or XML (never issued, version not 4.0, not stamped, XML missing or unreadable) MUST be shown as their specific localized messages.

**Editor (roadmap#48)**

- **FR-010**: Users with create access to fiscal documents MUST be able to start an invoice by choosing a customer and one of that customer's taxpayer records. The server picks the store, issuer, series and defaults.
- **FR-011**: Only invoices (type Ingreso) in the draft state MUST be editable. Every other type and state MUST open read-only.
- **FR-012**: On a draft, users MUST be able to add a completed, non-cancelled sales order, whose invoiceable lines are added at their remaining quantity.
- **FR-013**: On a draft, users with create access to standalone fiscal documents (system object 56) MUST be able to add a product line by hand. Without that right the action MUST NOT be offered.
- **FR-014**: On a draft, users MUST be able to edit a line's quantity (greater than 0), unit price (0 or more), discount (0–100 %), tax rate (16 %, 0 % or exempt), internal code, description and comment, and to delete a line.
- **FR-015**: On a draft, users MUST be able to edit the recipient (among the customer's RFCs), series, payment terms, payment form, CFDI usage, issue date, reference and notes. Choosing PPD MUST set the payment form to 99 and lock it.
- **FR-016**: The series MUST NOT be changeable once the invoice has a folio.
- **FR-017**: The issuing store MUST be changeable only by users who also hold update access on the issued-location right (system object 103).
- **FR-018**: On a draft, users MUST be able to add and remove related documents with relation type 04 (substitution) or 07 (application of an advance), one type per invoice.
- **FR-019**: Users with update access MUST be able to confirm a draft, which leaves it sealed with its folio shown, or show the server's reason when it is refused.
- **FR-020**: Users with update access MUST be able to reopen a sealed invoice after confirming the action. It returns to draft and keeps its folio.
- **FR-021**: Confirm and reopen MUST ask for confirmation before running, since confirm uses a folio and reopen discards the sealed XML.
- **FR-022**: After every change, the screen MUST show the document as the server returns it. A draft's subtotal, discount, tax and total MUST be computed with the same rules the server uses when sealing, and labelled as an estimate. A sealed or issued document MUST show the server's total.

**Across the feature**

- **FR-023**: Actions the user's rights do not allow MUST be hidden or disabled, mirroring the server's checks: read on 23 to see, create on 23 to start, update on 23 to edit, confirm and reopen, create on 56 for manual lines, update on 103 to change the store.
- **FR-024**: Every server refusal MUST be shown with the localized text for its error code, never a raw server message or a generic failure.
- **FR-025**: All user-facing text MUST be in Spanish, with amounts, dates and identifiers formatted by the app's shared formatting.

### Key Entities

- **Fiscal document**: A CFDI of any type (invoice, credit note, payment receipt and others). It has an issuer, a customer and recipient taxpayer, a series and folio, an issue date, a state, payment terms and form, CFDI usage, currency, totals, and, once stamped, a UUID.
- **Invoice line**: A product on an invoice with SAT product and unit keys, quantity, unit price, discount, tax rate, description and comment. It may point to the sales order line it came from, which limits its quantity to what remains to invoice.
- **Related document**: A link from an invoice to an earlier stamped CFDI, with relation type 04 or 07.
- **Taxpayer issuer and series**: The store's RFC that issues the invoice, and the invoice series whose folios it uses (maintained in spec 065).
- **Customer taxpayer (recipient)**: One of the customer's RFC records, with the name, tax regime and postal code the invoice copies.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A clerk can find a legacy invoice by folio, UUID or recipient RFC and have its PDF on screen in under 30 seconds.
- **SC-002**: A clerk can turn one completed sales order into a sealed invoice in under 2 minutes, without retyping any line.
- **SC-003**: Every server refusal a clerk can trigger in these screens shows a specific Spanish message. None shows a generic error or raw server text.
- **SC-004**: A user with read-only access cannot reach any action that changes a fiscal document.
- **SC-005**: For the same sales order, the lines and quantities on the new MBE's draft match what the server reports as remaining to invoice, every time.

## Assumptions

- Facturas is a new entry in the back office's navigation, next to the other sales-side screens. The editor is reached from it (New invoice, or opening a draft). Starting an invoice directly from a sales order screen is out of scope.
- The list shows every fiscal document type because the server's list does. Only invoices are editable here. Credit notes (#56), payment receipts, cancellation (#52), stamping (#46) and email are out of scope.
- Line discount is entered as a percentage (0–100 %) and sent as a fraction (0–1), as elsewhere in the back office.
- The PDF preview, print and save use the app's existing document-printing flow (spec 044). The XML is saved the same way a file download is saved elsewhere in the app.
- The server's rules (remaining quantities, the 72-hour window, PPD forcing form 99, relation checks, folio assignment) are enforced by the server. The UI mirrors only the rules a user can see while typing (field ranges, PPD lock, series lock, rights), and shows the server's reason for everything else.
- The existing customer, product and sales-order pickers are reused to choose a customer, a product and an order.
- Live verification uses legacy issued invoices already in the dev tenant for the PDF and XML. Sealing requires an issuer with an active certificate valid at the issue date, as seeded for spec 065.
