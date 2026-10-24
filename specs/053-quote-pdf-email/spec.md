# Feature Specification: Quotation PDF and Email

**Feature Branch**: `053-quote-pdf-email`

**Created**: 2026-10-24

**Status**: Draft

**Input**: User description: "Quotation PDF and email" — mictlanix/mbe-roadmap#31 (`[UI] Quotation PDF and email`, scope 02 §2.2, weight 3 legacy actions). mbe-api already renders the quote as a letter-size PDF and emails it with the PDF attached (mbe-api spec 024, PR #254); this spec is the mbe-ui side only.

## Clarifications

### Session 2026-10-24

- Q: What does the recipient list start with when the email dialog opens? → A: Nothing is selected. The customer's known addresses are shown as wrapping selectable chips — the same style as the "Falta …" filter chips on the Precios screen: tapping a chip selects it (check mark, filled) and tapping again deselects it. The selected chips are the recipients; there is no separate recipient list. A typed address becomes another chip, already selected.
- Q: Where are "Ver cotización" and "Enviar por correo" offered? → A: On the quote screen only; the quotes list gets no row actions.

### Session 2026-10-24 (wireframe review)

- Q: Where on the quote screen does "Enviar por correo" live? → A: In the header strip beside "Ver cotización", grouping the two document actions (as "Ver pedido" sits on the order screen) — not in the totals bar with the state-changing actions.
- Q: On a phone, the header would stack "Ver cotización", "Enviar por correo" and "Más detalles" on three rows. How is that avoided? → A: On phone-sized screens the two document actions move into an overflow menu in the header strip; "Más detalles" stays a visible button. Wider screens show both actions as buttons.
- Q: What presents the email dialog? → A: A shared responsive dialog — a regular dialog on wide screens, full-screen on phones — added to the shared component set rather than built inside this feature, so later form dialogs reuse it.
- Q: What happens to a typed address when it is deselected? → A: It stays as an unselected chip, like every other chip.
- Q: How are chips labelled and ordered? → A: "owner · address"; the customer's contacts first, then fiscal recipients, then typed addresses. An address shared by a contact and a fiscal recipient shows the contact's name.
- Q: Can the dialog be closed while a send is in progress? → A: No — it cannot be dismissed until the server answers.
- Q: How is success reported for many recipients? → A: The confirmation lists every confirmed address, wrapping as needed.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - View, print or download a quote (Priority: P1)

A salesperson has a quote open and needs a printable copy: to hand to a customer at the counter, to attach to a message from their own mail client, or to keep on file. From the quote, they open the quote document, see it in the same preview used for the pedido, and print or download it.

**Why this priority**: It is the most frequent of the three legacy actions, works for a quote in any state, and has no external dependency (no mail server). On its own it already replaces the legacy "Print / PDF" action.

**Independent Test**: Open any quote (draft, confirmed or cancelled), choose "Ver cotización", and confirm the preview shows the server-rendered quote and that print and download both work.

**Acceptance Scenarios**:

1. **Given** a user who can read quotes has a quote open, **When** they choose "Ver cotización", **Then** a preview of the quote document opens over the quote screen, offering print and download.
2. **Given** the preview is open, **When** the user downloads, **Then** the file is saved with the server's file name (`cotizacion-00000123.pdf` style).
3. **Given** a draft quote with an edit still being saved, **When** the user chooses "Ver cotización", **Then** the pending edit is resolved first (waited on, or kept/discarded through the screen's existing prompt), so the document matches what is on screen.
4. **Given** the document cannot be fetched (offline, server error, not a PDF), **When** the user chooses "Ver cotización", **Then** the preview shows the same error state and retry used for other documents, and the quote screen is unchanged.

---

### User Story 2 - Email a confirmed quote to the customer (Priority: P2)

A salesperson has confirmed a quote and wants the customer to receive it. From the quote, they choose "Enviar por correo", pick or type one or more addresses, and send. The system emails the quote PDF from the company's address and tells the salesperson who it was sent to.

**Why this priority**: It covers the second and third legacy actions (send email, sent confirmation) and removes the manual "download then attach" step, but it depends on mail being configured on the server and only applies to confirmed quotes.

**Independent Test**: Confirm a quote, choose "Enviar por correo", enter a reachable address, send, and confirm the success message lists that address and the message arrives with the PDF attached.

**Acceptance Scenarios**:

1. **Given** a confirmed quote, **When** the user chooses "Enviar por correo", **Then** a dialog opens showing the customer's known addresses as selectable chips, none selected; tapping a chip selects it (check mark) and tapping it again deselects it.
2. **Given** the dialog is open, **When** the user types an address that is not among the chips and confirms it, **Then** it appears as a new chip, already selected.
3. **Given** one to ten valid recipients, **When** the user sends, **Then** the send button shows progress and is disabled until the server answers, and on success the dialog closes and a confirmation names every recipient the message was sent to.
4. **Given** a draft or cancelled quote, **When** the user views it, **Then** "Enviar por correo" is not offered.
5. **Given** the server refuses the send (mail server rejected it, or mail is not configured), **When** the user sends, **Then** the dialog stays open with the recipients intact and shows a message that says which of the two happened, so the user can retry or fall back to downloading the PDF.

---

### Edge Cases

- **Address limit**: the user tries to select or type an eleventh recipient — the chip is not selected and the dialog says the limit is ten.
- **Duplicate address**: the same address belongs to both a contact and a fiscal recipient, or is typed again (any letter case) — it appears as one chip.
- **Malformed address**: the user types something that is not an email address — it is flagged before sending; if the server still rejects an address, the dialog shows the server's reason and keeps the recipients.
- **Quote changed state meanwhile**: the quote was cancelled by someone else after the dialog opened — the server refuses the send; the dialog explains the quote can no longer be sent and the quote screen refreshes to its current state.
- **Customer with no known addresses**: no chips are shown at first; typing an address still works.
- **Confirmed but expired quote**: it can still be emailed (the server checks only that the quote is confirmed); the email action is offered as for any confirmed quote.
- **Mail not configured on the server**: every send fails the same way; the message says sending email is not available and suggests downloading the PDF instead.
- **Slow mail server**: the send is synchronous; the dialog cannot be submitted twice or closed while waiting, so it never reports a false success.
- **No permission to read quotes**: the user cannot reach the quote screen, so neither action is offered (deny-by-default).

## Requirements *(mandatory)*

### Functional Requirements

**Quote document (P1)**

- **FR-001**: The quote screen MUST offer a "Ver cotización" action for a quote in any state (draft, confirmed, cancelled) to any user who can read quotes.
- **FR-002**: "Ver cotización" MUST open the shared document preview already used for the pedido and the cash cut, with the same print, download, zoom and error/retry behaviour.
- **FR-003**: The document MUST be the server-rendered quote; mbe-ui MUST NOT build, alter or cache it.
- **FR-004**: A downloaded quote MUST use the file name the server provides, falling back to `cotizacion-` plus the quote number padded to 8 digits `.pdf` when none is provided.
- **FR-005**: Before opening the document for a draft quote, the screen MUST resolve pending edits (in-flight saves and unconfirmed typed text) the same way it does before its other critical actions.

**Email (P2)**

- **FR-006**: The quote screen MUST offer an "Enviar por correo" action only for a confirmed, not-cancelled quote, to any user who can read quotes.
- **FR-007**: The email dialog MUST let the user add between 1 and 10 recipients, each either picked from suggestions or typed freely.
- **FR-008**: The dialog MUST show the email addresses of the quote customer's contacts and fiscal recipients (as the legacy system offered) as wrapping selectable chips, each labelled "owner · address" (a typed address has no owner and shows the address alone), in the same style as the filter chips on the Precios screen. Contacts come first, then fiscal recipients, then typed addresses; an address shared by a contact and a fiscal recipient appears once, under the contact's name. Tapping a chip toggles it between selected (check mark) and not selected; a deselected typed address stays as an unselected chip.
- **FR-009**: No chip is selected when the dialog opens. The recipients are exactly the selected chips; nothing is sent to an address the user did not select or type.
- **FR-009a**: A typed address MUST be added as a new chip, already selected; typing an address that matches an existing chip (any letter case) selects that chip instead of adding another. Send is disabled while no chip is selected.
- **FR-010**: The dialog MUST reject malformed addresses and duplicates (case-insensitive) before sending, and MUST NOT allow more than 10 recipients.
- **FR-011**: While a send is in progress, the dialog MUST prevent a second submission, show progress, and MUST NOT be dismissible until the server answers.
- **FR-012**: On success, the dialog MUST close and a confirmation MUST list every address the server reports as sent to, wrapping as needed.
- **FR-013**: On failure, the dialog MUST stay open with the recipients kept, and MUST show a distinct message for each case: quote no longer sendable, invalid recipients (with the server's reason), mail server refused, mail not configured, and connection/other errors.
- **FR-014**: When the server reports the quote is no longer sendable, the quote screen MUST refresh to the quote's current state after the dialog is closed.

**Placement and access**

- **FR-015**: Both actions MUST be offered on the quote screen only, in its header strip beside "Más detalles"; the quotes list gets no new row actions.
- **FR-015a**: On phone-sized screens, the two actions MUST be offered from an overflow menu in the header strip instead of as buttons; "Más detalles" stays a visible button. Wider screens show them as buttons.
- **FR-015b**: The email dialog MUST be presented as a regular dialog on wide screens and full-screen on phone-sized screens, through a shared responsive dialog component that other form dialogs can reuse.
- **FR-016**: Both actions MUST be gated by read access to sales quotes, matching what the server enforces; no new privilege is introduced.
- **FR-017**: All new text MUST be localized in Spanish and English.

### Key Entities

- **Quote document**: the server-rendered PDF of one quote — facility header and logo, customer and contact, date, validity, payment terms, lines, totals with amount in words, and the salesperson. Read-only to mbe-ui.
- **Email send**: one request to email a confirmed quote — its recipients (1–10 addresses) and, on success, the recipients the server confirms and the time sent. The server records each successful send; mbe-ui does not display that record in this spec.
- **Recipient suggestion**: an email address known for the quote's customer, from a contact or a fiscal recipient, with the owner's name.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: From an open quote, a user can have the quote document on screen in at most one action, and printed or downloaded in at most two more.
- **SC-002**: From an open confirmed quote, a user can email it to a customer contact in under 30 seconds, without leaving the app or attaching files by hand.
- **SC-003**: Every failed send leaves the user with a message naming the cause and with the recipients still entered; no failed send is ever reported as successful.
- **SC-004**: The three legacy quotation actions in scope (print/PDF, send email, sent confirmation) are all available, closing mictlanix/mbe-roadmap#31.

## Assumptions

- mbe-api's quote document and quote email endpoints (mbe-api spec 024) are live on the target deployment, and the generated client already includes them; no backend work is needed.
- Mail sending is configured on the deployment where email is tested (otherwise every send fails as "not configured"); confirming this is a precondition for verifying User Story 2, not something mbe-ui controls.
- The subject, body text, sender and reply-to address are decided by the server; the dialog does not let the user edit them.
- The history of past sends (recorded server-side) is out of scope; showing it would need a new mbe-api read endpoint.
- The quote's customer, with its contacts and fiscal recipients, is readable by any user who can read quotes (the server allows it). If loading it fails for any reason, the dialog shows no chips and typing still works.
- "Confirmed" means the quote's completed state; a cancelled quote is not sendable even if it was confirmed before. Expiry does not affect sending.
