# Feature Specification: Taxpayer Batches (Folio Series)

**Feature Branch**: `065-taxpayer-batches`

**Created**: 2026-11-15

**Status**: Draft

**Input**: User description: "Taxpayer batches (folio series) maintenance in the Taxpayer Issuer detail screen. Covers mictlanix/mbe-roadmap#45 (UI twin of the closed API issue mictlanix/mbe-roadmap#44; legacy scope 10 §1 "Batch/Series Sub-Panel", taxpayer_batch). Add a "Series" section to the existing taxpayer issuer detail screen, next to the existing Certificates section, letting a user list, create, edit and delete an issuer's batches, gated on Taxpayers (24) Read/Create/Update/Delete. Fields: Series (1–10 chars, unique per issuer), Document type (FiscalDocumentType 0, 1, 2, 3, 100, 101, 200, shown with localized labels), and the print template (name, logo, header height, footer height, bank accounts with bank, account, CLABE, currency). A series in use by a fiscal document has its series and type locked and cannot be deleted, but its template can still change; the UI must show this lock up front."

Roadmap: mictlanix/mbe-roadmap#45

## User Scenarios & Testing *(mandatory)*

### User Story 1 - See an issuer's series (Priority: P1)

An administrator opens a taxpayer issuer (an RFC the company invoices from) and sees, in a "Series" section next to its certificates, every folio series configured for that issuer. Each row shows the series prefix, the document type it numbers, the print template name, and whether the series is already in use by issued documents.

**Why this priority**: Invoicing fails for any document type the issuer has no series for. Being able to see which types are covered is what an administrator needs first, and it delivers value on its own (diagnosing "the issuer has no invoice series" errors) even before editing exists.

**Independent Test**: Open an issuer that has series in the dev tenant. Confirm every series the backend holds for it is listed with its document type in words and its in-use state. Then open an issuer with no series and confirm the empty state explains what that means.

**Acceptance Scenarios**:

1. **Given** an issuer with three series (Invoice "A", Credit note "NC", Payment receipt "P"), **When** a user with Taxpayers read right opens the issuer, **Then** the Series section lists all three, each with its series, its document type as a localized label (not a number), its template name, and an in-use marker where applicable.
2. **Given** an issuer with no series, **When** the user opens it, **Then** the section shows an empty state saying the issuer cannot issue fiscal documents until a series exists for that document type.
3. **Given** the series cannot be loaded (network or server error), **When** the user opens the issuer, **Then** the section shows the error with a retry action, and the rest of the issuer screen stays usable.
4. **Given** the user is creating a new issuer that has not been saved yet, **When** the form is shown, **Then** the Series section is not offered until the issuer exists (same rule as Certificates).

---

### User Story 2 - Add a series (Priority: P1)

An administrator adds a series to an issuer: types a prefix (e.g. "FAC"), picks the document type it numbers, and fills in the print template (template name, optional logo file name, header and footer heights, and any bank accounts to print on the document).

**Why this priority**: Without a series of the right type, the issuer cannot invoice at all. Adding one is the action that unblocks invoicing for a new RFC, so it is co-equal with viewing.

**Independent Test**: On an issuer with no Invoice series, add series "A" of type Invoice with template name "Factura" and one bank account. Confirm it appears in the list and survives a reload.

**Acceptance Scenarios**:

1. **Given** a user with Taxpayers create right, **When** they add series "A", type Invoice, template name "Factura", **Then** the series is saved and appears in the list without a full screen reload.
2. **Given** the issuer already has series "A", **When** the user tries to add another "A", **Then** the save is refused with a message that the series already exists for this issuer, and the form keeps what the user typed.
3. **Given** the user leaves the series blank (or only spaces), or types more than 10 characters, or leaves the template name blank, or types more than 50 characters in it, **When** they try to save, **Then** the form flags the field before sending anything.
4. **Given** the user enters a negative header or footer height, **When** they try to save, **Then** the form flags it.
5. **Given** the user adds two bank accounts and removes one before saving, **When** they save, **Then** only the remaining account is stored, in the order shown.
6. **Given** a user without Taxpayers create right, **When** they view an issuer, **Then** no "add series" action is offered.

---

### User Story 3 - Edit a series, respecting the in-use lock (Priority: P2)

An administrator changes a series. If no document has used it yet, they can change anything: prefix, type and template. If documents already carry the series, the prefix and document type are shown read-only with an explanation, and only the print template can change (e.g. a new bank account or a different logo).

**Why this priority**: Correcting a typo before first use, and keeping bank details current on a live series, are both routine. It ranks below create because an issuer can invoice without ever editing.

**Independent Test**: Edit an unused series and change its prefix; confirm it saves. Edit an in-use series; confirm prefix and type cannot be changed, a reason is shown, and a template change (adding a bank account) saves.

**Acceptance Scenarios**:

1. **Given** an unused series, **When** a user with Taxpayers update right opens it, **Then** the prefix, type and template are all editable, and saving stores the changes.
2. **Given** a series marked in use, **When** the user opens it, **Then** prefix and type are read-only with a visible note that documents already use this series, and the template fields remain editable.
3. **Given** a series marked in use, **When** the user changes only the template and saves, **Then** the change is stored and the series stays in use with the same prefix and type.
4. **Given** a series that became in use after the screen loaded (another user stamped a document meanwhile), **When** the user changes its prefix and saves, **Then** the save is refused with a message that the series is now in use, and the list refreshes so the lock shows.
5. **Given** a user without Taxpayers update right, **When** they open a series, **Then** they see its details read-only with no save action.

---

### User Story 4 - Delete an unused series (Priority: P3)

An administrator removes a series that was created by mistake and never used.

**Why this priority**: Cleanup only. Mistakes can be fixed by editing an unused series, so deletion is the least needed action.

**Independent Test**: Delete an unused series after confirming; confirm it disappears and stays gone after reload. Confirm an in-use series offers no delete.

**Acceptance Scenarios**:

1. **Given** an unused series and a user with Taxpayers delete right, **When** they choose delete and confirm, **Then** the series is removed from the list.
2. **Given** the user chooses delete, **When** the confirmation appears, **Then** it names the series and document type, and cancelling leaves the series untouched.
3. **Given** a series marked in use, **When** the user views it, **Then** no delete action is available, and the reason (documents already use it) is shown.
4. **Given** a series that became in use after the screen loaded, **When** the user deletes it, **Then** the deletion is refused with a message that the series is in use, and the list refreshes.
5. **Given** a user without Taxpayers delete right, **When** they view series, **Then** no delete action is offered.

---

### Edge Cases

- **Same prefix, different type**: Series must be unique per issuer regardless of type, so "A" for Invoice and "A" for Credit note on the same issuer is refused as a duplicate.
- **Same prefix, different issuer**: Allowed. Uniqueness is per issuer.
- **Surrounding spaces**: A prefix typed as " A " is stored as "A". The duplicate check applies to the trimmed value.
- **Several series of one type**: Allowed (e.g. "A" and "B" both Invoice). The screen does not choose a default among them.
- **Unknown document type from the backend**: If a series carries a type code outside the seven known ones, the row still shows, with a generic "Unknown type (code)" label, and editing it requires picking a known type.
- **Empty bank account row**: A bank account row with every field blank is dropped on save, not stored as an empty account.
- **Long lists of bank accounts**: The form handles any number of accounts without layout breaking at compact width.
- **Logo**: The logo is a file name the print service looks up (e.g. "logo.png"), not an upload. Blank means no logo.
- **Issuer deleted or RFC changed elsewhere**: Saving a series against an issuer that no longer exists shows the "not found" error and returns the user to the issuer list.

## Requirements *(mandatory)*

### Functional Requirements

**Viewing**

- **FR-001**: The taxpayer issuer detail screen MUST show a "Series" section for a saved issuer, alongside the existing Certificates section, listing every series the backend holds for that issuer.
- **FR-002**: Each listed series MUST show its prefix, its document type as a localized label, its template name, and whether it is in use.
- **FR-003**: Document types MUST be labeled in the user's language for all seven codes: Invoice (0), Expense/Egreso (1), Payment (2), Transfer/Traslado (3), Credit note (100), Payment receipt (101), Advance payments applied (200). An unrecognized code MUST still render with a generic label that includes the code.
- **FR-004**: The section MUST show a distinct empty state, loading state and error state with retry. A failure in this section MUST NOT block the rest of the issuer screen.
- **FR-005**: The section MUST NOT be shown while creating an issuer that has not been saved.

**Creating and editing**

- **FR-006**: Users MUST be able to create a series with: prefix (required, 1–10 characters after trimming), document type (required, one of the seven), template name (required, 1–50 characters), logo file name (optional), header height (whole number of millimetres ≥ 0, default 0), footer height (whole number of millimetres ≥ 0, default 15), and zero or more bank accounts.
- **FR-007**: Each bank account MUST have bank, account number, CLABE and currency fields, all optional text. Users MUST be able to add, remove and reorder accounts before saving. Accounts whose fields are all blank MUST be dropped on save.
- **FR-008**: The form MUST validate the limits in FR-006 before sending, and keep the user's input when the server refuses a save.
- **FR-009**: Users MUST be able to edit an existing series. For a series not in use, all fields MUST be editable.
- **FR-010**: For a series in use, prefix and document type MUST be read-only, with a visible explanation that issued documents already use the series; the template fields MUST stay editable.
- **FR-011**: When the server refuses a save because the prefix already exists for the issuer, the user MUST see a message saying so, attached to the prefix field where possible.
- **FR-012**: When the server refuses a change or deletion because the series became in use after the screen loaded, the user MUST see a message saying the series is now in use, and the list MUST refresh so the lock shows.

**Deleting**

- **FR-013**: Users MUST be able to delete a series that is not in use, after a confirmation naming the series and its document type.
- **FR-014**: A series in use MUST NOT offer a delete action.

**Access control**

- **FR-015**: Viewing the section MUST require Taxpayers read right; adding MUST require Taxpayers create; editing MUST require Taxpayers update; deleting MUST require Taxpayers delete. Actions the user lacks the right for MUST be hidden, not shown disabled. The add, edit and delete actions are also offered only on an editable render of the issuer, as the Certificates section's "Agregar" is: a View render of the issuer offers none of them, whatever the user's rights. A user with read but not update right MUST still be able to open a series and see its details.

**Errors and language**

- **FR-016**: All server refusals MUST be shown as localized messages derived from the server's error codes, never raw server text, consistent with the rest of the app.
- **FR-017**: All new labels, messages and document-type names MUST be available in English and Spanish.

### Key Entities

- **Taxpayer issuer**: An RFC the company issues fiscal documents from. Already managed on its own screen; owns certificates and, with this feature, series.
- **Series (taxpayer batch)**: A folio prefix belonging to one issuer, tied to one document type, with one print template. Unique per issuer by prefix. Carries an in-use flag once any of the issuer's fiscal documents uses it; that flag freezes its prefix and type and prevents deletion.
- **Print template**: How documents numbered by the series are printed: template name, optional logo file name, header and footer heights, and an ordered list of bank accounts.
- **Bank account (template entry)**: Bank name, account number, CLABE and currency printed on the document. Free text, not linked to the company's bank-account records.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: An administrator can add a working Invoice series to an issuer that has none in under 2 minutes, after which creating an invoice for that issuer no longer fails for lack of a series.
- **SC-002**: For every series in the dev tenant, the screen shows the same prefix, type, template and in-use state the backend holds.
- **SC-003**: An administrator can tell, without trying to edit, whether a series' prefix and type can still change. Every in-use series shows its lock before any save is attempted.
- **SC-004**: No save or delete refused by the server leaves the user with a raw error, a lost form, or a list that disagrees with the backend.
- **SC-005**: Users without the relevant right never see an add, edit-save or delete action they cannot use.

## Assumptions

- The backend's batch maintenance (mictlanix/mbe-roadmap#44) is live and already in the app's generated client; no backend work is needed.
- The Series section follows the same layout and interaction pattern as the existing Certificates section on the issuer detail screen (an inline list with add, edit and delete via dialogs).
- The logo is a free-text file name. Choosing or uploading the image file is out of scope; legacy used the same convention.
- Currency on a bank account is free text (e.g. "MXN"), as the backend stores it. A currency picker is out of scope.
- Bank accounts in the template are not linked to the company's bank-account records; they are printed text only.
- Previewing the printed document from the template is out of scope; the print layout itself belongs to the fiscal document printing work.
- Choosing a default series per store (used when creating invoices) is out of scope.
- The list is ordered by document type, then prefix.
