# Feature Specification: Supplier Sub-Panels

**Feature Branch**: `050-supplier-sub-panels`

**Created**: 2026-10-22

**Status**: Draft

**Input**: User description: "Supplier sub-panels: addresses, contacts, bank accounts and agreements on the supplier detail (mictlanix/mbe-roadmap#14). mbe-api PR #251 (closes mictlanix/mbe-roadmap#13) made GET/POST/PUT /suppliers/{id} return SupplierDetailResponse with addresses, contacts, bank_accounts and agreements; create/update take address/contact/bank-account id lists with replace-all semantics (omit = unchanged, [] = clear, unknown id = 409); agreements are date-ranged child records via GET/POST /suppliers/{id}/agreements and PUT/DELETE /suppliers/{id}/agreements/{agreement_id} (end < start = 422); bank accounts are a standalone catalog at /bank-accounts (BANK_ACCOUNTS privilege, linked account cannot be deleted = 409); deleting a supplier with links or agreements returns 409. Scope: legacy spec 01 §1.6 (9 legacy actions). The UI today covers only the supplier parent CRUD (ui specs 005/012)."

Roadmap: mictlanix/mbe-roadmap#14

## Context & Findings

- **Today.** Suppliers are edited in a side panel with six flat fields: code, name, zone, credit limit, credit days and notes (specs 005 and 035). The panel has no linked records. The data layer already reads the supplier detail the server returns, but drops its four sub-panel lists.
- **Legacy.** The current system's supplier screen (scope 01 §6) has four sub-panels: Addresses, Contacts, Bank Accounts, and Agreements, which are date-ranged commercial agreements.
- **Server (mbe-api #251, #252).**
  - Addresses, contacts and bank accounts are shared records that a supplier *links* to. Saving a supplier sends the full set of linked ids for each kind, and the set replaces what was there.
  - Agreements belong to exactly one supplier. They are added, changed and removed on their own, one at a time, not as part of the supplier save.
  - A supplier with links or agreements cannot be deleted.
  - Linking and unlinking needs Suppliers *Update*, and so does adding, changing or removing agreements. Bank accounts have their own privilege (Bank Accounts, 13), the same way addresses (11) and contacts (12) do.
- **Precedent.** Customers already solved the same problem (spec 046). They moved to a full detail page. Below the customer's own fields, each linked kind gets a section. A section lists the linked records, unlinks with one click, links an existing record through a search picker, and creates a new record inline through a small dialog. This feature follows that pattern so the two screens behave the same.

## Clarifications

### Session 2026-10-22

- Q: Should suppliers open in a full detail page or stay in the side panel? → A: A full detail page at `/suppliers/:id`. Constitution v1.14.0, amended separately on branch `docs/record-surface-criteria`, gives the record-surface rule criteria instead of an entity list. Suppliers meets its first criterion, linked-record sections, so this spec needs no amendment of its own.
- Q: Where does the user remove an agreement? → A: Inside the agreement's edit dialog, through an `Eliminar` action and a confirmation. An agreement row carries only the Edit icon, so it has no Delete icon (§VI).
- Q: Where does the user land after saving a supplier? → A: After a create, they stay on the page, which reopens the saved supplier for editing so agreements can be added straight away. After an update, they go back to the list, as customers do.
- Q: What does a refused supplier save say, given that mbe-api sends one generic conflict for both a duplicate code and a vanished linked record? → A: One message that names both causes ("Ya existe un proveedor con ese código, o uno de los registros vinculados ya no existe."), and the form keeps the user's edits. A refused delete keeps its specific links-or-agreements message.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - See a supplier's addresses, contacts, bank accounts and agreements (Priority: P1)

A purchasing user opens a supplier and sees, on one screen, its own fields and four sections: Addresses, Contacts, Bank accounts and Agreements. Each section lists what is linked or recorded, or says that there is nothing yet.

**Why this priority**: Most use is lookup: how to reach the supplier, where to send goods, which account to pay. Seeing it is the minimum useful slice and needs no editing.

**Independent Test**: Open a supplier that, on the server, has linked addresses, contacts and bank accounts, plus agreements. Every one appears in its section, and a supplier with none shows four empty sections.

**Acceptance Scenarios**:

1. **Given** a supplier with 2 linked addresses, 1 contact, 1 bank account and 3 agreements, **When** the user opens it, **Then** each section lists exactly those records, with enough detail to recognise each one at a glance.
2. **Given** a supplier with no links or agreements, **When** the user opens it, **Then** each section shows an empty-state message instead of a blank area.
3. **Given** a user who can read suppliers but not change them, **When** they open a supplier, **Then** they see all four sections but no link, unlink, create, add, edit or remove controls.
4. **Given** a supplier with agreements, **When** the user views the Agreements section, **Then** the agreements are ordered by start date, newest first, and each shows its start date, end date and notes.

---

### User Story 2 - Link and unlink addresses, contacts and bank accounts (Priority: P1)

While editing a supplier, the user links an existing address, contact or bank account through a search picker, or creates a new one in a small dialog that links it straight away. The user unlinks a record with one click. Nothing is sent until the user saves the supplier, and cancelling discards the changes.

**Why this priority**: It is the core of the roadmap item. Without it the sections are read-only copies of whatever was migrated.

**Independent Test**: Edit a supplier, link one existing address, create and link a new contact, create and link a new bank account, unlink a previously linked address, and save. Reopen the supplier: the sections show exactly the new state.

**Acceptance Scenarios**:

1. **Given** a supplier being edited, **When** the user searches for and picks an existing address, **Then** the address appears in the section as pending, and it is linked when the supplier is saved.
2. **Given** a supplier being edited, **When** the user creates a new contact or bank account through the inline dialog, **Then** the new record is created, appears in the section, and is linked when the supplier is saved.
3. **Given** a supplier being edited with a linked address, **When** the user unlinks it and saves, **Then** the address is no longer linked to the supplier and still exists for anyone else who uses it.
4. **Given** a supplier being edited with link changes, **When** the user cancels, **Then** the supplier's links are unchanged.
5. **Given** the picker, **When** the user searches, **Then** records already linked to this supplier are not offered again.
6. **Given** a new supplier that has not been saved yet, **When** the user links addresses, contacts and bank accounts and saves, **Then** the supplier is created with those links in one save.
7. **Given** a user who can update suppliers but has no Read on Bank Accounts, **When** they edit a supplier, **Then** they cannot search for bank accounts to link. They still see the ones already linked and can unlink them. The same holds for addresses and contacts with their own privileges. Without Create on a kind, the "create new" action for that kind is hidden.

---

### User Story 3 - Record and maintain supplier agreements (Priority: P2)

The user adds an agreement to a saved supplier with a start date, an end date and optional notes. The user can correct its dates or notes, or remove it. Each change takes effect at once, like the other child records with their own dialogs (for example, taxpayer certificates).

**Why this priority**: Agreements carry commercial terms that purchasing needs, but they change rarely and none of the first purchasing flows depend on them.

**Independent Test**: On a saved supplier, add an agreement, change its end date, try to save one whose end date is before its start date (refused), then remove it. Reopen the supplier after each step: the section matches.

**Acceptance Scenarios**:

1. **Given** a saved supplier, **When** the user adds an agreement with a start date, an end date on or after it, and notes, **Then** it appears in the Agreements section and is still there after reopening.
2. **Given** an agreement, **When** the user changes its dates or notes and confirms, **Then** the section shows the new values.
3. **Given** the agreement dialog, **When** the end date is before the start date, **Then** the user cannot confirm, and the dialog says why.
4. **Given** an agreement, **When** the user opens its edit dialog, chooses to remove it, and confirms the prompt, **Then** it disappears from the section.
5. **Given** a supplier that has not been saved yet, **When** the user looks at the Agreements section, **Then** it explains that agreements can be added once the supplier is saved.
6. **Given** a new supplier, **When** the user saves it for the first time, **Then** the screen stays open on the saved supplier in edit mode, and the user can add an agreement without going back to the list.
7. **Given** a user without Update on suppliers, **When** they view the Agreements section, **Then** they see the agreements but no add, edit or remove controls.

---

### User Story 4 - Understand why a supplier cannot be deleted (Priority: P3)

When the user tries to delete a supplier that still has links or agreements, the screen says that the supplier cannot be deleted while it has addresses, contacts, bank accounts or agreements, and that these must be removed first. It does not show a generic failure.

**Why this priority**: The server already protects the data. This story only makes the refusal clear.

**Independent Test**: Try to delete a supplier with one linked contact: it is refused with the explanation. Unlink the contact, save, and delete again: it succeeds.

**Acceptance Scenarios**:

1. **Given** a supplier with at least one link or agreement, **When** the user deletes it and confirms, **Then** the supplier is kept and the message names the reason and what to do.
2. **Given** a supplier with no links or agreements, **When** the user deletes it, **Then** it is deleted as it is today.

---

### Edge Cases

- **A record disappears before save.** A picked address, contact or bank account is deleted by someone else before the supplier is saved. The save is refused. The user sees the conflict message from FR-011, which also covers a duplicate code. The form keeps their edits, and nothing is half-saved.
- **The same record on many suppliers.** A shared address or bank account linked to several suppliers shows on each of them. Unlinking it from one supplier leaves the others untouched.
- **Inline create fails.** The new record is not added to the section, the dialog stays open with the user's input, and it shows the error.
- **Agreement saved elsewhere while editing.** The supplier is reopened or refreshed after each agreement change, so the section shows what the server holds.
- **Equal start and end dates.** An agreement whose end date equals its start date is valid: a one-day agreement.
- **Expired agreements.** Agreements whose end date has passed are still listed, because they are history, not errors.
- **Many links.** A supplier with many links keeps every section readable, and the page scrolls rather than truncating.
- **Narrow screens.** The sections stack in one column, and every action stays reachable.

## Requirements *(mandatory)*

### Functional Requirements

**Supplier detail screen**

- **FR-001**: The supplier MUST open in a detail screen that shows its own fields and, below them, four sections: Addresses, Contacts, Bank accounts and Agreements. The screen MUST serve viewing, editing and creating, the same way the customer detail does.
- **FR-002**: Each section MUST list its records with an empty state when there are none.
  - An address MUST show its nickname or type, then street and number, neighbourhood, city or borough, and postal code.
  - A contact MUST show its name, then job title, phone or mobile, and email.
  - A bank account MUST show its bank name, account number and reference.
  - An agreement MUST show its start date, end date and notes.
- **FR-003**: Dates MUST use the application's configured date format (spec 028).
- **FR-004**: The supplier list, search and existing field validation MUST keep working as today. Opening a supplier from the list (view or edit) and "New" MUST lead to the detail screen.

**Linked records (addresses, contacts, bank accounts)**

- **FR-005**: While editing or creating a supplier, the user MUST be able to link an existing address, contact or bank account by searching for it, and to unlink a linked one.
- **FR-006**: The user MUST be able to create a new address, contact or bank account from its section in a dialog. The new record MUST be added to the section as linked, and MUST reuse the existing address and contact creation dialogs.
- **FR-007**: The bank account creation dialog MUST ask for bank name and account number (required), and reference, routing number and notes (optional). It MUST enforce the server's length limits: 250, 20, 20, 18 and 500 characters.
- **FR-008**: Link and unlink changes MUST stay pending until the supplier is saved, and MUST be discarded on cancel. Saving MUST send the complete set of linked records for every kind, so the saved links always match what the screen showed.
- **FR-009**: The search picker MUST NOT offer a record that is already linked to the supplier being edited.
- **FR-010**: Unlinking MUST NOT delete the shared record. Linked records MUST NOT be edited or deleted from the supplier screen.
- **FR-011**: If a save is refused as a conflict, the user MUST see one message that names both possible causes: the code is already used by another supplier, or a linked record no longer exists. The form MUST keep the user's edits. The server reports both causes the same way, so the screen MUST NOT claim to know which one happened.

**Agreements**

- **FR-012**: On a saved supplier, a user with Update on suppliers MUST be able to add, edit and remove agreements. Each change MUST take effect when its dialog is confirmed, independently of the supplier's Save.
- **FR-013**: The agreement dialog MUST require a start date and an end date, allow optional notes of up to 500 characters, and refuse an end date before the start date before anything is sent.
- **FR-014**: An agreement row MUST offer only an Edit action. Removing an agreement MUST be done from its edit dialog, and MUST ask for confirmation.
- **FR-015**: On a supplier that is not yet saved, the Agreements section MUST say that agreements can be added after saving, and MUST show no add control.
- **FR-015a**: After a supplier is created, the screen MUST stay open on the saved supplier in edit mode, with the Agreements add control available. After a supplier is updated, the screen MUST return to the supplier list.
- **FR-016**: Agreements MUST be listed by start date, newest first.

**Delete**

- **FR-017**: When deleting a supplier is refused because it still has links or agreements, the user MUST see a message that explains the reason and what to remove first.

**Access**

- **FR-018**: The following MUST follow the Suppliers privilege (3): viewing needs *Read*; linking, unlinking and agreement changes need *Update*; creating needs *Create*; deleting needs *Delete*. Without the right, the control MUST be hidden.
- **FR-019**: Searching existing records of a kind MUST need *Read* on that kind: Addresses (11), Contacts (12), Bank Accounts (13). Creating one inline MUST need *Create* on that kind. Without the right, that control MUST be hidden, and records already linked MUST still be shown and unlinkable.

**Language**

- **FR-020**: All new labels, empty states and messages MUST be available in Spanish and English.

### Key Entities

- **Supplier**: A vendor. It has code, name, zone, credit limit, credit days and notes, and now also its linked addresses, contacts and bank accounts and its agreements.
- **Address**: A shared postal address that can be linked to many suppliers (and customers).
- **Contact**: A shared person with name, job title, phones and email that can be linked to many suppliers (and customers).
- **Bank account**: A shared record with bank name, account number, reference, routing number and notes that can be linked to many suppliers.
- **Supplier agreement**: A commercial agreement that belongs to one supplier. It runs from a start date to an end date on or after it, and has optional notes.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: For every supplier on the test tenant, the four sections show exactly the server's links and agreements. A spot-check of at least 10 suppliers, including the one with the most links, finds no missing or extra record.
- **SC-002**: A user can link an existing contact to a supplier and save in under 30 seconds. Creating and linking a new bank account takes under 1 minute.
- **SC-003**: After any combination of link, unlink and cancel, reopening the supplier shows the expected links 100% of the time. No save leaves links half-applied.
- **SC-004**: An agreement with an end date before its start date is refused before it is sent, 100% of the time.
- **SC-005**: Every refused supplier delete caused by links or agreements shows the specific explanation, never a generic error.
- **SC-006**: A user without a given privilege never sees the controls that need it, verified for each of the rights named in FR-018 and FR-019.
- **SC-007**: Every legacy supplier sub-panel in scope 01 §6 can be used: view, link and unlink for addresses, contacts and bank accounts, plus view, add, edit and remove for agreements.

## Assumptions

- **Full detail page.** Suppliers move from the side panel to a full detail page, as customers did in spec 046. Four sections do not fit a side panel. Keeping the two catalogs alike is worth the change in how a supplier opens. Under constitution v1.14.0 §VI, an entity with linked-record sections MUST use a full detail screen, so the move is required rather than a choice. This depends on the v1.14.0 amendment (branch `docs/record-surface-criteria`) merging first.
- **Agreements save on their own.** Agreements have their own server operations and only exist under a saved supplier, so each dialog confirms on its own. This matches taxpayer certificates. Mixing staged links with immediate agreement changes on one screen is acceptable, because the agreements live in their own section with their own dialogs.
- **No standalone bank account catalog.** Bank accounts are created inline from the supplier, as customers create addresses and contacts. A standalone Bank accounts screen (list, edit, delete) is out of scope, as are standalone Address and Contact screens, which do not exist today either.
- **Linked records are not edited from the supplier.** This matches the customer screen. Fixing a typo in a shared address is out of scope until a standalone catalog exists.
- **No marker for unsaved links.** Linked and unlinked rows look the same before and after saving, as on the customer screen. Leaving with unsaved edits asks first.
- **Agreements render as a table**, following the taxpayer-certificates precedent. On narrow screens the table drops the notes column, and the notes stay visible in the agreement dialog.
- **No "in force" status.** Agreements show their dates only. The screen does not mark one as current, expired or upcoming, because nothing in scope asks for it.
- **Server is ready.** mbe-api #251 and #252 are on the test deployment, and the generated client already has the bank-account, agreement and supplier-detail operations.

## Out of Scope

- Standalone catalog screens for addresses, contacts or bank accounts.
- Editing or deleting a shared address, contact or bank account.
- Customer discounts (mictlanix/mbe-roadmap#16) and vehicle operator license photos (mictlanix/mbe-roadmap#21), which are separate specs.
- Using agreements anywhere else (purchasing, pricing).
