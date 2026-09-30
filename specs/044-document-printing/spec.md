# Feature Specification: Document Printing

**Feature Branch**: `044-document-printing`

**Created**: 2026-09-29

**Status**: Draft

**Input**: User description: "Consider a preview component for generated documents too" — building on `docs/document-printing-research.md` (§0.1 records what mbe-api#231 shipped): print the sale ticket, the sales order document (pedido) and the cash session cut (corte de caja) that mbe-api now renders, with a shared in-app preview.

## Clarifications

### Session 2026-09-29

- Q: How does the in-app preview relate to printing? → A: The POS "sale completed" moment prints the ticket straight to the print dialog, for speed at the register. Every other entry point (ticket reprint, pedido, cash cut) opens the shared preview first, where the user prints or downloads.
- Q: mbe-api lets a closed session's cut be fetched at any time, but the close dialog says the figures "no se mostrarán de nuevo". What does mbe-ui do? → A: Allow reprinting the cut from any closed session, and reword the close message so it no longer claims the figures cannot be seen again.

### Session 2026-09-30 (wireframe review)

- Q: What surface presents the preview? → A: A modal dialog over the calling screen, full-screen on phone-sized screens — not a side panel and not a separate page. Closing it returns to the caller unchanged.
- Q: How is a document read when it is too small at fit-to-width (a letter page on a phone)? → A: Both pinch zoom and explicit zoom controls (zoom out, zoom in, fit to width, with the current level shown).
- Q: How is the "saved version" note on a pedido presented? → A: ~~A plain informational strip~~ Superseded below: the order workspace saves every edit immediately, so there is no lasting unsaved state to note.
- Q: A user can have the privilege to close a session without the privilege to view its cut. → A: Recorded as an edge case: the cut action is simply absent for them.
- Q: In the "Venta completada" dialog, which action is primary? → A: "Nueva venta" stays primary; "Imprimir ticket" is secondary, so the default key still starts the next sale.
- Q: The order workspace saves every edit as it happens; its only transient local states are typed-but-unconfirmed text and writes still in flight. How does "Ver pedido" treat them? → A: It resolves them first — waits for in-flight writes and runs the workspace's existing keep/discard prompt for unconfirmed text, as other critical actions already do. The document then always matches the screen, and the "saved version" strip is dropped.
- Q: When "Ver corte" is pressed in the "Sesión cerrada" dialog, what happens to that dialog? → A: It closes, then the preview opens over the refreshed detail screen. Only one dialog is ever open.
- Q: Does the preview show a page indicator? → A: Always — "Página n / N" for every document, including one-page tickets and cuts.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A cashier prints the ticket when a sale is completed (Priority: P1)

A cashier finishes a sale at the point of sale. The "Venta completada" dialog now offers "Imprimir ticket" beside "Nueva venta". Pressing it opens the device's print dialog with the final receipt already loaded, so the cashier prints on the thermal printer and hands the customer a receipt. Today mbe-ui has no way to produce a receipt, which blocks stores from moving off legacy.

**Why this priority**: The sale ticket is printed on every sale. It is the most frequent document and the one whose absence stops a store from operating on mbe-ui.

**Independent Test**: Complete a POS sale, press "Imprimir ticket" in the completion dialog, and confirm the print dialog opens showing the final receipt ("Ticket de Venta") for that sale's folio, 72 mm wide.

**Acceptance Scenarios**:

1. **Given** a sale has just been completed and the "Venta completada" dialog is showing, **When** the cashier presses "Imprimir ticket", **Then** the device's print dialog opens with that sale's final receipt, with no intermediate preview.
2. **Given** the print dialog was opened from the completion dialog, **When** the cashier prints or cancels it, **Then** the completion dialog is still showing, so they can print again or press "Nueva venta".
3. **Given** the ticket is being fetched, **When** the cashier waits, **Then** the "Imprimir ticket" action shows it is working and cannot be pressed a second time until the fetch finishes.
4. **Given** the ticket cannot be fetched (network failure, server error), **When** the fetch fails, **Then** the cashier sees an error message in the dialog, can retry, and can still start a new sale.
5. **Given** the user lacks the privilege to read sales orders, **When** the completion dialog shows, **Then** "Imprimir ticket" is not offered.

---

### User Story 2 - A user previews a document and prints or downloads it (Priority: P1)

Any document opened for review — a ticket reprint, a pedido, or a cash cut — appears in one shared preview surface. The user sees the rendered pages exactly as they will print, then chooses "Imprimir" (the device's print dialog) or "Descargar" (saves the PDF), or closes it. The preview is the same for every document type, so users learn it once.

**Why this priority**: Every entry point except the POS completion moment depends on it. Without it, users print blind: a wrong order or the pre-payment ticket instead of the receipt goes to paper before anyone notices.

**Independent Test**: Open any document in the preview, confirm its pages render legibly, then print it and download it, and confirm the downloaded file opens as the same document.

**Acceptance Scenarios**:

1. **Given** a user opens a document for preview, **When** the document loads, **Then** its pages are shown in reading order, legibly and at their true proportions (a narrow ticket looks like a ticket, a letter page like a letter page), with the document's title.
2. **Given** a document is shown in the preview, **When** the user presses "Imprimir", **Then** the device's print dialog opens with that same document.
3. **Given** a document is shown in the preview, **When** the user presses "Descargar", **Then** the PDF is saved or offered for saving under the file name the server supplies (for example `pedido-00001234.pdf`).
4. **Given** the document is still loading, **When** the preview opens, **Then** it shows a loading state, and "Imprimir" and "Descargar" are unavailable until the document arrives.
5. **Given** the document fails to load, **When** the preview shows the failure, **Then** it states the server's reason when there is one (for example "Cash session is not closed") and offers a retry.
6. **Given** a multi-page document (a long pedido), **When** it is previewed, **Then** every page can be reached by scrolling, and the preview shows which page is in view out of the total ("Página 1 / 2").
7. **Given** the preview is open, **When** the user closes it, **Then** they return to the screen they came from, unchanged.
8. **Given** a document is shown in the preview, **When** the user zooms in or out — with the zoom controls, or by pinching on a touch screen — **Then** the pages scale accordingly, the current zoom level is visible, the user can pan across a zoomed page, and "fit to width" restores the opening view.

---

### User Story 3 - A supervisor prints the cash cut at close and reprints it later (Priority: P1)

A supervisor closes a cash session. The "Sesión cerrada" dialog now offers "Ver corte", which opens the cut in the preview for printing. Later — for a jammed printer, a lost ticket, or an audit — anyone allowed to see cash sessions opens a closed session's detail screen and opens the same cut again.

**Why this priority**: The cut is printed every shift and is how cash discrepancies are caught and filed. mbe-ui can close a session but has nothing to print.

**Independent Test**: Close a session, open the cut from the close dialog and print it. Then leave, return to that session's detail screen, and confirm the same cut can be opened again.

**Acceptance Scenarios**:

1. **Given** a session has just been closed and the "Sesión cerrada" dialog is showing, **When** the supervisor presses "Ver corte", **Then** the cut opens in the preview.
2. **Given** the close dialog is showing, **When** the supervisor reads its message, **Then** it no longer says the figures will not be shown again.
3. **Given** a closed session's detail screen, **When** a user with the privilege to read cash sessions opens it, **Then** a "Ver corte" action is offered and opens the cut in the preview.
4. **Given** a session has just been closed from its detail screen, **When** the supervisor dismisses the close dialog, **Then** the detail screen shows the session as closed, including the "Ver corte" action, without having to leave and re-enter.
5. **Given** an open session's detail screen, **When** it is shown, **Then** no "Ver corte" action is offered.

---

### User Story 4 - A cashier reprints a ticket from the POS sales list (Priority: P2)

A customer comes back asking for a copy of their receipt, or the printer jammed. The cashier finds the sale in the POS sales list and opens its ticket from the row, in the preview, then prints it.

**Why this priority**: Reprints are common but less frequent than the first print, and the first print already covers the main flow.

**Independent Test**: From the POS sales list, open a completed sale's ticket from its row, confirm the preview shows the final receipt, and print it.

**Acceptance Scenarios**:

1. **Given** the POS sales list, **When** a user with the privilege to read sales orders looks at a saved sale's row, **Then** a "Ver ticket" row action is offered.
2. **Given** a completed sale, **When** its ticket is opened from the row, **Then** the preview shows the final receipt.
3. **Given** a sale that is not yet completed, **When** its ticket is opened from the row, **Then** the preview shows the pre-payment ticket, as the server supplies for that state.
4. **Given** a row already offers Edit, **When** "Ver ticket" is added, **Then** the row still respects the limit of one action beyond Edit before collapsing into an overflow menu.

---

### User Story 5 - A salesperson prints the sales order document (Priority: P2)

A salesperson working on an order in the back-office order workspace opens its letter-size document (pedido) in the preview to print it for the customer or the warehouse, or to download it and send it.

**Why this priority**: It is printed less often than the ticket and the cut and is not tied to a shift's cash flow. It reverses the "no printing" assumption of specs 029 and 039, which existed only because no server document was available.

**Independent Test**: Open a saved order in the order workspace, open its document, and confirm the preview shows a letter-size pedido for that order.

**Acceptance Scenarios**:

1. **Given** a saved order in any state (draft, completed, paid or cancelled) open in the order workspace, **When** a user with the privilege to read sales orders looks at it, **Then** a "Ver pedido" action is offered.
2. **Given** the user opens it, **When** the document loads, **Then** the preview shows the letter-size pedido for that order.
3. **Given** the user has typed into a field without confirming it, or an edit is still being saved, **When** they press "Ver pedido", **Then** in-flight edits finish first and the workspace's existing keep/discard prompt resolves the unconfirmed text before the document is fetched, so the pedido shows exactly what is on screen.

---

### Edge Cases

- **The record was deleted or does not exist** (a stale list row): the preview shows the server's "not found" message; nothing crashes.
- **The cut is requested for a session the server still considers open** (a race with another user): the preview shows "Cash session is not closed" as the reason.
- **A user can close a session but lacks the privilege to view cuts** (closing and viewing the cut are gated by different privileges): the close dialog shows no "Ver corte" action and the detail screen offers none; the close dialog's counted/expected/difference figures are all they see. Nothing is shown disabled.
- **The privilege was revoked after the screen loaded**: the request is refused and the preview shows a permission error; the action disappears on next load.
- **The session expires while a document loads**: the usual sign-in handling applies; no partial document is shown.
- **The network drops mid-download**: the preview shows the load failure with retry, never a half-drawn or corrupted document.
- **The user presses the print action twice quickly**: only one fetch and one print dialog result.
- **A browser on a phone or tablet**: where the browser cannot print from within the page, printing opens the PDF in a new tab or the device's viewer instead. The user can still print or share from there. The preview itself still works.
- **The browser blocks the new tab** (pop-up blocker) on such devices: the platform gives the app no signal that this happened, so no message is promised; "Descargar" stays available in the preview as the fallback (research R5).
- **A very long ticket** (many lines): the preview shows it as one long page, as the server renders it.
- **Printing cancelled in the print dialog**: no error is shown; the user returns to where they were. (Browsers do not report a cancel at all; native platforms do, and it is treated as nothing to report.)

## Requirements *(mandatory)*

### Functional Requirements

**Documents and where they are offered**

- **FR-001**: The system MUST offer three server-generated documents: the sale ticket (pre-payment ticket or final receipt, as the server decides from the order's state), the sales order document (pedido), and the cash session cut (corte de caja).
- **FR-002**: The "Venta completada" dialog MUST offer "Imprimir ticket" alongside "Nueva venta". It MUST send the final receipt directly to the device's print dialog, without the preview, and MUST leave the completion dialog open afterwards. "Nueva venta" MUST remain the dialog's primary (default) action, with "Imprimir ticket" visually secondary.
- **FR-003**: The POS sales list MUST offer a "Ver ticket" row action for every saved sale, opening that sale's ticket in the preview. It MUST respect the existing rule of at most one row action beyond Edit before collapsing into an overflow menu.
- **FR-004**: The back-office order workspace MUST offer a "Ver pedido" action for a saved order in any state, opening its document in the preview. It MUST be a body action, never an app-bar action.
- **FR-005**: The "Sesión cerrada" dialog MUST offer "Ver corte". Pressing it MUST close that dialog and then open the just-closed session's cut in the preview, so no two dialogs are stacked.
- **FR-006**: A closed session's detail screen MUST offer "Ver corte", opening its cut in the preview. An open session MUST NOT offer it.
- **FR-007**: After a session is closed from its detail screen, that screen MUST reflect the closed state (status, and the "Ver corte" action) once the close dialog is dismissed, without the user leaving and returning.
- **FR-008**: The close dialog's message MUST no longer state that the figures will not be shown again. It keeps reporting counted, expected and difference.
- **FR-009**: Before fetching the pedido, the order workspace MUST let in-flight edits finish and MUST resolve any unconfirmed typed text through its existing keep/discard prompt — the same one its other critical actions use — so the document reflects exactly what the user sees. Choosing to keep editing MUST cancel opening the preview.

**Shared preview**

- **FR-010**: The system MUST provide one shared preview surface used by every document entry point except the POS completion print (FR-002). It MUST be a modal dialog over the calling screen, filling the screen on phone-sized displays; it MUST NOT be a side panel or a separate navigable page.
- **FR-011**: The preview MUST show the document's pages as the server rendered them, in order, at their true proportions, all reachable by scrolling, with the document's title. Each document MUST open fitted to the available width; a page narrower than the preview, such as a ticket, is shown at its natural size and centred rather than stretched to the dialog's width. The user MUST be able to zoom both with explicit controls (zoom out, zoom in, fit to width, with the current level displayed) and with pinch gestures on touch screens, and MUST be able to pan across a zoomed page. The preview MUST always show a page indicator ("Página n / N") for the page in view, including for single-page documents.
- **FR-012**: The preview MUST offer "Imprimir" (opens the device's print dialog with the same document) and "Descargar" (saves the PDF under the server-supplied file name), and a way to close it.
- **FR-013**: While loading, the preview MUST show a loading state and keep "Imprimir" and "Descargar" unavailable. On failure, it MUST show the reason the server gave when there is one, a generic message otherwise, and offer a retry.
- **FR-014**: The preview MUST NOT contact any third-party service at runtime (no public content-delivery network for its viewer code). It MUST work in a deployment that allows only the application's own origin and mbe-api.
- **FR-015**: The preview and print paths MUST be built so that a future "send to printer" option (server-side printing, where the client gets only success or failure) can be added without changing each entry point.

**Content integrity and rendering ownership**

- **FR-020**: The document the user previews, prints or downloads MUST be byte-for-byte the document mbe-api produced. A corrupted or partial document MUST never be shown or printed; a transfer failure MUST surface as an error.
- **FR-021**: mbe-ui MUST NOT generate, alter or re-lay-out document content. Paper size, fonts, fields and wording come entirely from mbe-api.
- **FR-022**: Documents MUST NOT be stored or cached by mbe-ui. Each open fetches the current document from mbe-api. A download is a file the user explicitly saves, not an app cache.

**Errors**

- **FR-030**: When mbe-api refuses a document request, the user MUST see the explanation the server returned (for example "Sales order not found", "Cash session is not closed", "Insufficient privileges") rather than only a generic message. This MUST hold for every document request, not just one screen.
- **FR-031**: Cancelling the print dialog MUST NOT be reported as an error.
- **FR-032**: Repeated presses of a print or preview action while a document is loading MUST NOT start additional fetches or dialogs.

**Access**

- **FR-040**: The sale ticket and the pedido actions MUST be offered only to users with the read privilege on sales orders. The cash cut actions MUST be offered only to users with the read privilege on the point of sale. These match what mbe-api enforces.
- **FR-041**: Each action MUST re-check the privilege immediately before fetching, and a server refusal MUST be handled as in FR-030.

**Language**

- **FR-050**: All new labels and messages MUST be available in Spanish (es-MX, the default) and English.

### Key Entities

- **Document reference**: which document to fetch — its kind (sale ticket, pedido, cash cut), the record it belongs to (sales order or cash session), the title shown in the preview, and the privilege that gates it.
- **Rendered document**: the PDF produced by mbe-api for a document reference, with the file name the server supplies. Held only while it is on screen or being printed.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: From the "Venta completada" dialog, a cashier reaches the print dialog with the sale's receipt in one press, and the print dialog appears within 3 seconds on a normal store connection.
- **SC-002**: Any previewed document is fully visible within 3 seconds of opening on a normal store connection.
- **SC-003**: 100% of printed and downloaded documents are identical to what mbe-api produced for the same record at that moment (no corrupted or truncated files), verified by comparing the downloaded file with a direct server fetch.
- **SC-004**: Opening, printing and downloading a document makes zero requests to any host other than the application's own origin and mbe-api.
- **SC-005**: For every refusal mbe-api makes on a document request (not found, not closed, insufficient privileges), the user sees the server's own reason in 100% of cases.
- **SC-006**: A ticket printed from a desktop browser to a real 80 mm thermal printer through the print dialog fits the paper width, with nothing clipped and legible text.
- **SC-007**: A lost cash cut can be reprinted from its closed session in under 30 seconds by a user who has the point-of-sale read privilege.
- **SC-008**: A user who lacks the relevant privilege sees no print or preview action for that document on any screen.

## Assumptions

- **mbe-api is ready.** The three documents already exist server-side (mbe-api#231, issue #230): the sale ticket and pedido are available for an order in any state, and the cut only for a closed session. This feature consumes them and changes nothing in mbe-api.
- **Which ticket prints is the server's decision.** The same ticket request returns the pre-payment ticket before an order is completed and the final receipt after. The POS completion dialog is shown only after the order is committed on the server, so it always prints the final receipt.
- **Order edits are already saved.** The order workspace writes every change to the server as it happens, with no Save button; the only local-only states are typed-but-unconfirmed text and writes in flight, both of which it already resolves before critical actions. So the pedido — always rendered from server data — matches the screen once those are resolved (FR-009).
- **Printing goes through the device's print dialog**, exactly as legacy did. Silent printing, the cash-drawer kick and direct thermal output are a later phase (server-side printing); FR-015 keeps room for it.
- **Web on desktop is the primary target.** Native desktop and Android builds are expected to work through the same flows. On phone and tablet browsers, in-page printing degrades to opening the PDF in a new tab (see Edge Cases). This is a known platform limit, stated rather than solved here.
- **Per-store access is not narrowed.** Like the existing read screens, printing is gated by privilege only; mbe-api does not restrict single-record reads by store, and this feature does not add a client-side restriction.
- **Out of scope**: CFDI invoice PDFs (no server endpoint yet, and no invoicing feature in mbe-ui), emailing documents, the ~40 other legacy documents, server-side/thermal direct printing, and a print action on the POS workspace's own read-only view of a finished sale (the sales-list row covers reprints).
- **Web security policy.** If the web deployment ever adds a Content Security Policy, it must still allow what the document viewer and print path need on web, which includes evaluating same-origin script and one inline script (research R4). FR-014 is about *which hosts* are contacted, and it holds either way. Today the app sets no such policy.
- **Server reasons are shown as returned.** mbe-api's refusal messages are shown as the server words them, the same as existing error banners; translating them is not part of this feature.
- **No new privilege.** Printing uses each document's existing read privilege; no print-specific privilege is introduced (research §7).
