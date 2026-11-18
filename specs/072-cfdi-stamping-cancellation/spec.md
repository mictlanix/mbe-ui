# Feature Specification: CFDI Stamping, Refresh and Cancellation

**Feature Branch**: `072-cfdi-stamping-cancellation`

**Created**: 2026-11-17

**Status**: Draft

**Input**: Covers mictlanix/mbe-roadmap#52 ([UI] Invoice cancellation) and the handoff mictlanix/mbe-ui#274 (pick up mbe-api spec 039: stamping, SAT's two-step cancellation and refresh of CFDIs against the simulated PAC). User description: "Invoice cancellation plus CFDI stamping/refresh UI. Stamp and refresh actions on fiscal documents; show the six states (draft, sealed, stamping, issued, cancellation_pending, cancelled) in list, filter and detail, fixing the current mapping that degrades unknown statuses to draft; show the stamp (UUID, date, SAT certificate, provider RFC) and a 'simulated, no fiscal validity' badge when the stamp is simulated; cancel an issued CFDI with SAT reason 01–04 (01 requires the substitute document UUID), with the cancellation history on the detail; refresh for stamping and cancellation_pending; map the new error codes. Requires Update on 23. Payment receipts (#54) and CFDI credit notes (#56) are out of scope beyond showing has_live_documents. Builds on spec 066."

## Context

Spec 066 took invoices made in the new MBE as far as **sealed** and said stamping was not available yet. mbe-api spec 039 now stamps, cancels and refreshes fiscal documents through a PAC contract. On dev and test that PAC is a **simulator**; the real PAC comes later (roadmap#46, #51) behind the same contract, with no change to these screens.

A fiscal document now has six states:

| State | Meaning | What the user can do |
|---|---|---|
| Borrador (draft) | Editable | Edit, confirm (seal) |
| Sellado (sealed) | Signed, not stamped; no fiscal validity | Stamp, reopen |
| Timbrando (stamping) | A stamp was sent and its outcome is not known yet | Refresh |
| Emitido (issued) | Stamped by the PAC; has a UUID | Cancel, PDF, XML |
| Cancelación pendiente (cancellation pending) | SAT waits for the receiver to accept the cancellation | Refresh, PDF, XML |
| Cancelado (cancelled) | Cancelled at SAT | PDF, XML |

```text
draft ──confirm──▶ sealed ──stamp──▶ (stamping) ──▶ issued
                     ▲                    │
                     └── PAC rejected it / never stamped it
issued ──cancel──▶ cancelled                       (SAT accepts at once)
               └─▶ cancellation pending ──refresh──▶ cancelled (accepted / expired)
                                                └──▶ issued    (receiver rejected)
```

Today the app knows only four of these states and shows any other one as a draft. A document that is stamping or waiting on a cancellation would open as an editable draft. This spec fixes that.

The server also refreshes every waiting document by itself every 10 minutes, so on-demand refresh is only a shortcut.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - See every fiscal state correctly (Priority: P1)

A billing clerk browsing Facturas sees each document in its real state, including Timbrando and Cancelación pendiente. They can filter the list by any of the six states, which is how they find documents that need attention. A stamping or cancellation-pending document never opens as an editable draft.

**Why this priority**: The server already returns the two new states on dev and test. Until the app shows them, a clerk could try to edit a stamped document and get refusals they can't explain. Every other story depends on states being shown correctly.

**Independent Test**: Using the simulator, leave one document stamping (stamp timeout) and one cancellation pending. Open the list filtered by each new state and check that the document appears with the right label. Open each one and check that no edit action is offered.

**Acceptance Scenarios**:

1. **Given** documents in each of the six states, **When** the clerk opens Facturas, **Then** each row shows its state with a distinct label, and the state filter offers all six.
2. **Given** the list filtered by Timbrando or Cancelación pendiente, **When** it loads, **Then** only documents in that state are shown.
3. **Given** a document in the stamping or cancellation-pending state, **When** the clerk opens it, **Then** it is read-only: no edit, confirm or reopen action is offered.
4. **Given** each of the six states the server can return, **When** a document in that state is shown, **Then** it shows that state. None falls back to draft.

---

### User Story 2 - Stamp a sealed document (Priority: P1)

After confirming an invoice, the clerk stamps it. The document comes back issued, with its UUID, stamp date, the SAT certificate number and the PAC's RFC. From then on its PDF and XML are available and it can no longer be reopened. When the stamp was made by the simulator, the document carries a clear "simulated, no fiscal validity" badge.

**Why this priority**: This is the step spec 066 could not offer. Without it no document made in the new MBE has fiscal validity, and there is nothing to cancel.

**Independent Test**: Seal an invoice and stamp it against the simulator. It shows Emitido, its UUID and stamp details, the simulated badge, and the PDF and XML actions. Reopen is no longer offered.

**Acceptance Scenarios**:

1. **Given** a sealed document and a user with update access to fiscal documents, **When** they stamp it and confirm the action, **Then** it shows Emitido with its UUID, stamp date, SAT certificate number and PAC RFC.
2. **Given** a document stamped by the simulator, **When** anyone views it, **Then** a "Timbrado simulado, sin validez fiscal" badge is shown next to its state.
3. **Given** a newly issued document, **When** the clerk views it, **Then** PDF and XML are offered and reopen is not.
4. **Given** the PAC rejects the stamp, **When** the clerk stamps, **Then** they see the PAC's own message as the PAC wrote it, and the document stays sealed.
5. **Given** the PAC is unavailable, **When** the clerk stamps, **Then** they are told nothing changed and they can retry, and the document stays sealed.
6. **Given** the PAC does not answer in time, **When** the clerk stamps, **Then** they are told the outcome is not known yet, the document shows Timbrando, and Refresh is offered.
7. **Given** a sealed document whose issue date is more than 72 hours old, **When** the clerk stamps, **Then** the message explains that they must reopen it, set a new issue date (or leave it empty for "now") and confirm again.

---

### User Story 3 - Cancel an issued document (Priority: P1)

A clerk cancels an issued CFDI by choosing one of SAT's four reasons. For reason 01 (errors with relation) they also choose the stamped document that replaces it. Depending on SAT's answer, the document is cancelled at once or stays Cancelación pendiente until the receiver answers.

**Why this priority**: This is roadmap#52 itself. Clerks cancel invoices whenever one was issued with a mistake, and it is the only way to undo a stamped document.

**Independent Test**: With the simulator, cancel one issued invoice with reason 02 and an immediate acceptance, and check that it shows Cancelado. Cancel another with reason 01, choosing a stamped invoice of the same issuer and recipient as the substitute, set to need the receiver, and check that it shows Cancelación pendiente.

**Acceptance Scenarios**:

1. **Given** an issued document of any type and a user with update access, **When** they choose Cancel, **Then** they are asked for a reason among 01 Comprobante emitido con errores con relación, 02 Comprobante emitido con errores sin relación, 03 No se llevó a cabo la operación and 04 Operación nominativa relacionada en una factura global.
2. **Given** reason 01, **When** the clerk cancels, **Then** they must choose the substitute document among stamped, live documents of the same issuer and recipient before the cancellation can be sent.
3. **Given** reason 02, 03 or 04, **When** the clerk cancels, **Then** no substitute is asked for.
4. **Given** SAT accepts at once, **When** the cancellation is sent, **Then** the document shows Cancelado with its cancellation date, and Cancel is no longer offered.
5. **Given** SAT needs the receiver's acceptance, **When** the cancellation is sent, **Then** the document shows Cancelación pendiente, Refresh is offered, and the screen explains it waits for the receiver.
6. **Given** an invoice that still has live payment receipts or credit notes, **When** the clerk cancels it, **Then** they are told which documents (by series and folio) must be cancelled first, and the invoice stays issued.
7. **Given** SAT says the document cannot be cancelled, or the PAC rejects the request, **When** the clerk cancels, **Then** they see the reason (the PAC's own text when the PAC gave one) and the document stays issued.
8. **Given** the cancel dialog is open, **When** the clerk closes it without sending, **Then** nothing is sent.

---

### User Story 4 - Refresh a document in process (Priority: P2)

A clerk who sees Timbrando or Cancelación pendiente can ask the PAC for the outcome now instead of waiting for the server's periodic check.

**Why this priority**: The server's own check resolves these documents within about 10 minutes, so refresh is a convenience. It does matter when a customer is waiting at the counter.

**Independent Test**: With the simulator, leave a document stamping after a "timeout but stamped" outcome and refresh it: it becomes Emitido. Leave a cancellation pending, have the receiver accept it in the simulator, and refresh: it becomes Cancelado. Do the same with a rejection: it goes back to Emitido.

**Acceptance Scenarios**:

1. **Given** a stamping document the PAC did stamp, **When** the clerk refreshes, **Then** it shows Emitido with its stamp.
2. **Given** a stamping document the PAC never stamped, **When** the clerk refreshes after the PAC's waiting period, **Then** it is back to Sellado and can be stamped again or reopened.
3. **Given** a document still in process, **When** the clerk refreshes, **Then** they are told it is still in process and the document is unchanged.
4. **Given** a cancellation the receiver accepted or that expired, **When** the clerk refreshes, **Then** the document shows Cancelado.
5. **Given** a cancellation the receiver rejected, **When** the clerk refreshes, **Then** the document is Emitido again, the rejection shows in its history, and Cancel is offered again.
6. **Given** a document someone else already resolved, **When** the clerk refreshes, **Then** they are told there is nothing in process and the screen shows the current state.

---

### User Story 5 - Review a document's stamp and cancellation history (Priority: P2)

On an issued, cancellation-pending or cancelled document, the clerk sees its stamp details and every cancellation request made for it, newest first: reason, substitute UUID, who asked and when, SAT's answer and when it came, the outcome, and the PAC's code and message when there was a rejection.

**Why this priority**: When a customer disputes a cancellation, the clerk needs to say what was asked, when and what SAT answered. A document can have several requests (for example one rejected by the receiver, then one accepted).

**Independent Test**: With the simulator, cancel a document, have the receiver reject it, refresh, cancel again and have it accepted. The detail shows two requests, newest first, the first rejected and the second accepted, with their times.

**Acceptance Scenarios**:

1. **Given** an issued document, **When** the clerk opens it, **Then** they see the UUID, stamp date, SAT certificate number and PAC RFC.
2. **Given** a document with cancellation requests, **When** the clerk opens it, **Then** each request shows its reason, substitute UUID (if any), requester, request time, answer time, resolution time and outcome (requested, pending, accepted, expired, rejected, not cancellable, failed).
3. **Given** a rejected request with a PAC code and message, **When** the clerk views it, **Then** the code and the PAC's message are shown as the PAC wrote them.
4. **Given** a cancelled document with a reason-01 cancellation, **When** the clerk views it, **Then** the substitute UUID is shown.
5. **Given** a document stamped by the current (legacy) system, **When** the clerk opens it, **Then** its stamp details are shown as far as the server has them, without the simulated badge.

---

### Edge Cases

- **Documents stamped by the legacy system** are already issued and can be cancelled through the same flow. Cancelling one in the new MBE does not tell the legacy system.
- **Non-invoice types** (payment receipts, credit notes, legacy fee or rent receipts, type 101) stay read-only for editing, as in spec 066, but they can be stamped, cancelled and refreshed like invoices. Otherwise an invoice blocked by a live payment receipt could not be cancelled from the app at all.
- **Two clerks act on the same document.** If the other request is still running, the clerk is told the document is busy and can retry. If it already finished (stamped, cancelled), the screen shows the document as the server returns it. Stamping an already-stamped document is harmless.
- **An invoice with an open cancellation** cannot get new payment receipts or credit notes. The server enforces this; it is not reachable from this spec's screens.
- **Instance without a PAC.** The clerk is told this system has no PAC configured, and nothing changes.
- **Issuer without a certificate valid today.** Cancelling is refused with the existing certificate message.
- **The substitute for reason 01** must already be stamped and live. If none exists, the clerk is told, and can instead cancel with 02 and issue a replacement invoice afterwards (relation 04, spec 066), which is how businesses do it today.
- **A cancellation-pending document** still counts as live: it keeps lowering balances and still has a valid PDF and XML.
- **A user who can read but not update fiscal documents** sees states, stamps and history, but no Stamp, Cancel or Refresh action.

## Requirements *(mandatory)*

### Functional Requirements

**States (mbe-ui#274)**

- **FR-001**: The app MUST recognise all six fiscal states (draft, sealed, stamping, issued, cancellation pending, cancelled) and show each with a distinct Spanish label wherever a state appears: list rows, state filter, detail.
- **FR-002**: The list's state filter MUST offer all six states.
- **FR-003**: The mapping from server states MUST be exhaustive: each of the server's states maps to its own state, and none falls back to draft. (A value outside the server's contract fails the load, as every closed server enum does in the app. It is never shown as a draft.)
- **FR-004**: Only drafts MUST be editable, as in spec 066. Stamping and cancellation-pending documents MUST open read-only.
- **FR-005**: PDF and XML MUST be offered for issued, cancellation-pending and cancelled documents, and not for draft, sealed or stamping ones. Spec 066's note that "stamping is not yet available" MUST be removed. Sealed and stamping documents get a note that explains what comes next: stamp, or wait and refresh.

**Stamping (mbe-ui#274)**

- **FR-006**: Users with update access to fiscal documents MUST be able to stamp a sealed document of any type, after confirming the action. Stamping is its own "Timbrar" action on a sealed document. Confirm keeps sealing only, as in spec 066, so a sealed document offers both Timbrar and Reabrir.
- **FR-007**: An issued, cancellation-pending or cancelled document MUST show its stamp: UUID, stamp date, SAT certificate number and PAC RFC, as far as the server has them.
- **FR-008**: A document whose stamp the server marks as simulated MUST show a "Timbrado simulado, sin validez fiscal" badge on its detail.
- **FR-009**: When stamping times out, the app MUST say the outcome is not known yet, show the document as stamping, and offer Refresh.

**Cancellation (roadmap#52)**

- **FR-010**: Users with update access MUST be able to cancel an issued document of any type by choosing a SAT reason, 01–04, each shown with its code and SAT description.
- **FR-011**: For reason 01, the user MUST choose a substitute among issued documents with the same issuer and recipient, other than the one being cancelled. The request MUST NOT be sendable without one. For 02–04 no substitute is asked for. The server also accepts a document whose own cancellation is pending, but the picker doesn't offer it: such a document is on its way to being cancelled, so it makes a poor replacement.
- **FR-012**: Cancel MUST ask the user to confirm before sending, saying it is sent to SAT and cannot be undone from the app.
- **FR-013**: After a cancellation is sent, the document MUST show the state the server returns: cancelled, or cancellation pending with a note that SAT waits for the receiver.
- **FR-014**: When an invoice still has live payment receipts or credit notes, the refusal MUST list those documents by series and folio.

**Refresh (mbe-ui#274)**

- **FR-015**: Users with update access MUST be able to refresh a stamping or cancellation-pending document. The screen MUST then show the document as the server returns it.
- **FR-016**: When a refresh succeeds but the document is still in process (same state as before), the user MUST get an informational "still in process" notice, not an error. When the server says there is nothing in process (someone or the periodic job already resolved it), the user MUST see that refusal, and the screen MUST show the document's current state.

**History**

- **FR-017**: The detail MUST list every cancellation request, newest first, with reason, substitute UUID, requester, request time, answer time, resolution time, outcome, and PAC code and message when present.

**Errors**

- **FR-018**: Every refusal from these actions MUST be shown with localized text for its error code, per the constitution. That covers: cancellation already open; live dependent documents (with their list); not cancellable; nothing to refresh; stamp in process; invalid substitute; substitute required; unknown reason; no PAC configured; PAC rejected; PAC timeout (offering refresh); PAC unavailable (nothing changed, retry); document busy (retry). It also covers the reused codes for not sealed, not issued, no valid certificate and issue date out of range (explaining reopen, new date, confirm).
- **FR-019**: The PAC's rejection message MUST be shown exactly as the PAC wrote it, alongside a localized lead-in. It is the one place raw server text is shown, because it is SAT's or the PAC's own answer and the clerk needs it verbatim.

**Across the feature**

- **FR-020**: Stamp, Cancel and Refresh MUST be absent, never disabled, for users without update access to fiscal documents (system object 23), and absent in states where they do not apply. Choosing a reason-01 substitute also needs read access to fiscal documents, which every user of these screens has.
- **FR-021**: While a stamp, cancel or refresh request is running, the user MUST NOT be able to start a second action on the same document from this screen.
- **FR-022**: All user-facing text MUST be in Spanish (with English where the app is localized), with dates, UUIDs and identifiers formatted by the app's shared formatting.

### Key Entities

- **Fiscal document** (existing, spec 066): gains the stamping and cancellation-pending states, the stamp, the time a pending stamp was sent, the accepted substitute UUID and the cancellation history.
- **Stamp**: The PAC's fiscal stamp on a document. It has the UUID, stamp date, SAT certificate number, PAC RFC, and whether the simulator produced it.
- **Cancellation request**: One request to cancel a document. It has the reason (01–04), the substitute UUID, the requester and request time, SAT's answer time, resolution time and last check, the outcome (requested, pending, accepted, expired, rejected, not cancellable, failed), and the PAC's code and message.
- **SAT cancellation reason**: SAT catalogue entries 01–04 with their official descriptions.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A clerk can take a sealed invoice to issued in under 30 seconds, and cancel an issued invoice in under 1 minute, including choosing a substitute for reason 01.
- **SC-002**: Every row of the simulator's scenario table in mbe-ui#274 (13 stamp and cancel outcomes) can be driven from the app's screens, plus the simulator controls, and ends in the state and message the handoff lists.
- **SC-003**: No document in the stamping or cancellation-pending state ever offers an edit action.
- **SC-004**: Every refusal a clerk can trigger from stamp, cancel or refresh shows a specific message. None shows a generic error. Raw server text appears only as the PAC's own rejection message.
- **SC-005**: A user with read-only access to fiscal documents cannot reach Stamp, Cancel or Refresh.

## Clarifications

### Session 2026-11-17

- Q: Should stamping be its own action after Confirm, or should Confirm seal and stamp in one step as in the legacy system? → A: Its own "Timbrar" action on a sealed document. Confirm keeps sealing only (spec 066). That leaves a review point where a mistake can still be reopened with the same folio, and it keeps the 72-hour fix path (reopen, new date, confirm) clear.

## Assumptions

- **Rights**: Stamp, cancel and refresh need update on fiscal documents (system object 23), which is what the server checks. Fiscal documents have no facility scope.
- **All document types** can be stamped, cancelled and refreshed here, not only invoices, because the server allows it and because a live payment receipt or credit note blocks its invoice's cancellation. Creating and editing payment receipts (#54) and CFDI credit notes (#56) stays out of scope.
- **Choosing the substitute** reuses the related-document search from spec 066 (relations 04/07), limited to issued documents of the same issuer and recipient. Its search already accepts a UUID, so a clerk with a UUID in hand can paste it.
- **The requester** in the history is shown by user name where the app can resolve it, otherwise by user id.
- **The simulator's controls** (choosing the next stamp or cancel outcome, answering as the receiver) are a testing aid on dev and test. The app does not show them; testers drive them through the API, as the handoff describes.
- **Email** of a stamped document (spec 028 on the server) has no UI yet and stays out of scope.
- **No new navigation**: everything happens on the existing Facturas list and document detail.
- **The real PAC** (roadmap#46, #51) changes nothing in these screens, except that the simulated badge stops appearing.
- **Live verification** runs against the dev tenant's simulated PAC. It consumes folios and stamps documents, so it is dev only, and the user is asked before it runs.
