# Feature Specification: Catalog Improvements

**Feature Branch**: `046-catalog-improvements`

**Created**: 2026-10-16

**Status**: Draft

**Input**: User description: "Product catalog: display a dialog with a bigger image preview when an image is clicked; add some margins to image thumbnails. Facilities catalog: change `Sitio de Producción` to `Planta`; remove restrictions over production sites so they can also have points of sale and cash drawers. Customer catalog: form is incomplete — missing addresses, contacts and taxpayers; check if other relationships are missing too."

## Context & Findings

These findings come from an audit of mbe-ui, mbe-api and the legacy `mbe` docs, done on 2026-10-16. They set the scope boundaries below.

- **Product photos.** The backend stores one photo per product; there is no separate thumbnail. The catalog list draws an 84 px photo inside a 44 px table row and has no spacing around it. No image preview exists in the app today.
- **Production sites.** The rule "production sites have warehouses only" was added by spec 018 at the product owner's request. Only the UI enforces it: the Facilities screen hides the Points of Sale and Cash Drawers sections for production sites and shows a note explaining why. The backend accepts points of sale and cash drawers under any facility type, and the point-of-sale and cash-drawer forms already let users pick a production site. Lifting the rule needs no backend change.
- **Customer relationships.** The backend links a customer to any number of **addresses**, **contacts** and **taxpayers (RFCs)**. Addresses, contacts and taxpayers are shared records that exist on their own. The customer form today:
  - has no address or contact section;
  - offers a **single** taxpayer picker. A customer with two or more RFCs is silently cut down to one when saved, which is a data-loss bug.
- **Relationships that are not available.** The legacy system also had per-product **customer discounts** and **shipping flags**. The backend has a table for discounts, but neither discounts nor shipping flags are reachable through the API. They are out of scope here (see Assumptions).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Manage a customer's addresses, contacts and taxpayers (Priority: P1)

A back-office user opens a customer in the Customers catalog. They see every address, contact and taxpayer linked to that customer, and they can:

- link existing records;
- create new records and link them;
- unlink records;

all without leaving the customer form.

**Why this priority**: The legacy system had these sub-panels, and without them the form is incomplete. Customer addresses and contacts are used later on sales orders and deliveries. Today they can only be added one at a time from the POS. The current single-taxpayer picker also loses data.

**Independent Test**: Open a customer that has no links. Add two addresses, one contact and two taxpayers, mixing existing records and new ones. Save, reopen, and confirm all five links are still there. Remove one taxpayer, save, and confirm only that link is gone.

**Acceptance Scenarios**:

1. **Given** a customer with 2 linked addresses, 1 contact and 2 taxpayers, **When** the user opens the customer form, **Then** all 5 linked records are listed under their own sections, each showing enough detail to recognize it (e.g., nickname and street for an address; name and phone/email for a contact; RFC and name for a taxpayer).
2. **Given** the customer form is open, **When** the user picks an existing address from a searchable list and saves, **Then** that address is linked to the customer and the existing links are kept.
3. **Given** the customer form is open, **When** the user creates a new contact from the form and saves, **Then** the contact is created and linked to the customer.
4. **Given** a customer with 2 taxpayers, **When** the user edits an unrelated field (e.g., zone) and saves, **Then** both taxpayers stay linked (fixes today's cut-down-to-one bug).
5. **Given** a customer with a linked address, **When** the user unlinks it and saves, **Then** the address is no longer linked to this customer but still exists for any other customer or document that uses it.
6. **Given** the user is creating a new customer, **When** they add addresses, contacts and taxpayers before the first save, **Then** the customer is created with all of those links.
7. **Given** the user has linked or unlinked records but not saved, **When** they cancel or leave the form, **Then** no link changes are kept, and the usual unsaved-changes warning applies.
8. **Given** a linked address or contact, **When** the user views it in the customer form, **Then** no in-place edit action is offered. To correct a record, the user unlinks it and creates (or links) the right one, so past orders and other customers that reference the original are not changed.

---

### User Story 2 - Production sites can have points of sale and cash drawers (Priority: P2)

A facility of type production site (shown as "Planta") is managed the same way as a store. On the Facilities screen it shows the Warehouses, Points of Sale and Cash Drawers sections, and the user can create items in each of them.

**Why this priority**: This removes a business restriction that is blocking real operations: plants that sell on site need points of sale and cash drawers. The change is small and needs no backend work.

**Independent Test**: On the Facilities screen, expand a production-site facility. Confirm the Points of Sale and Cash Drawers sections appear with their counts and create actions. Create one of each and confirm both show up under the plant.

**Acceptance Scenarios**:

1. **Given** a production-site facility, **When** the user views it on the Facilities screen, **Then** it shows Warehouses, Points of Sale and Cash Drawers sections with the same counts and create actions as a store.
2. **Given** a production-site facility, **When** the user views it, **Then** the "production sites only manage warehouses" note no longer appears.
3. **Given** a store that already has points of sale and cash drawers, **When** its type is changed to production site and saved, **Then** those points of sale and cash drawers stay visible under it.
4. **Given** a production site with points of sale, **When** a cashier uses one of those points of sale, **Then** sales and cash-session work behave exactly as they do for a store's points of sale.

---

### User Story 3 - "Planta" label for production sites (Priority: P2)

Spanish-language users see the facility type as "Planta" wherever the type name appears: the type dropdown in the facility form and the type label on facility cards.

**Why this priority**: "Planta" is the term users actually use. It is a one-string change that ships with Story 2.

**Independent Test**: With the app in Spanish, open the facility form type dropdown and a production-site facility card, and confirm both read "Planta".

**Acceptance Scenarios**:

1. **Given** the app language is Spanish, **When** the user opens the facility type dropdown, **Then** the options read "Tienda" (unchanged) and "Planta".
2. **Given** the app language is Spanish, **When** the user views a production-site facility card, **Then** its type label reads "Planta".
3. **Given** the app language is Spanish, **When** the user browses all facility screens, **Then** "Sitio de producción" appears nowhere.

---

### User Story 4 - Larger product photo preview (Priority: P3)

A user browsing the product catalog clicks a product's photo and sees it enlarged in a dialog, so they can confirm it is the right product without opening the product's detail page.

**Why this priority**: A convenience that improves identification. It does not block any workflow.

**Independent Test**: In the product list, click a product's photo. A dialog shows the same photo at a much larger size. Close it and confirm the list is unchanged. Repeat on the product detail screen.

**Acceptance Scenarios**:

1. **Given** a product with a photo in the product list, **When** the user clicks the photo, **Then** a dialog opens that shows the photo as large as the screen allows (keeping its aspect ratio), and the product's name is shown with it.
2. **Given** a product with a photo, **When** the user clicks the photo itself, **Then** only the preview opens. The click does not also trigger the row's normal action, such as opening the product.
3. **Given** the preview is open, **When** the user presses Escape, clicks outside it or uses the close control, **Then** the dialog closes and the list keeps its scroll position, filters and selection.
4. **Given** a product with no photo, or a photo that fails to load, **When** the user clicks the placeholder, **Then** no preview opens.
5. **Given** the product detail screen, **When** the user clicks the saved photo, **Then** the same preview opens.
6. **Given** the preview is open and the photo fails to load, **When** the dialog is shown, **Then** it shows the standard placeholder instead of a broken image.

---

### User Story 5 - Spacing around product thumbnails (Priority: P3)

Product thumbnails in the catalog have visible space around them. They no longer touch the cell edges, the row borders or the text next to them.

**Why this priority**: A visual polish item.

**Independent Test**: Look at the product list at every density setting. Each thumbnail has visible space on all sides, and none is clipped by the row height.

**Acceptance Scenarios**:

1. **Given** the product list, **When** it is shown at any density setting, **Then** every thumbnail has visible space between it and the row borders and the column next to it, and the thumbnail is not clipped.
2. **Given** the product detail screen, **When** the photo section is shown, **Then** the thumbnail keeps the same visible space from the upload, replace and remove buttons.

---

### Edge Cases

- **Customer with many links.** A customer may have, say, 20 addresses. Each section must stay usable: it scrolls or grows, and the form does not overflow on compact layouts.
- **Duplicate link.** If the user picks a record that is already linked, it is not linked twice.
- **Inactive linked address.** Addresses have a status. An inactive address that is already linked is still listed and marked as inactive. It can be unlinked, but it is not offered when linking new addresses.
- **Unlinking the last record.** Unlinking the last address, contact or taxpayer is allowed. None of them is required.
- **Shared records.** Unlinking never deletes the underlying address, contact or taxpayer. Other customers and past orders may use it.
- **Failure while creating a linked record.** If the user creates a new address or contact and the customer save then fails, the new record may already exist without being linked. On retry the user can link it from the existing-records search. The app does not create a duplicate silently.
- **Permissions.** A user who can read customers but not edit them sees the linked sections read-only. Creating a new address, contact or taxpayer from the form requires the matching permission. When the user lacks it, the "create new" action is hidden.
- **Changing a plant back to a store.** No restriction applies; its children stay visible.
- **Very large or portrait photos.** These fit inside the preview without distortion and without scrolling the page.

## Requirements *(mandatory)*

### Functional Requirements

**Customer catalog**

- **FR-001**: The customer form MUST show separate sections for Addresses, Contacts and Taxpayers, each listing every record currently linked to the customer.
- **FR-002**: Users MUST be able to link an existing address, contact or taxpayer by searching for it from that section.
- **FR-003**: Users MUST be able to create a new address, contact or taxpayer from that section. The new record is linked to the customer.
- **FR-004**: Users MUST be able to unlink any linked record. Unlinking MUST NOT delete the record itself.
- **FR-005**: Link changes MUST be kept only when the customer is saved, and thrown away when the user cancels, the same as any other field on the form.
- **FR-006**: Saving a customer MUST keep every linked taxpayer, address and contact the user did not explicitly remove. This includes customers with more than one taxpayer.
- **FR-007**: The sections MUST work both when creating and when editing a customer.
- **FR-008**: The sections MUST follow the existing permission rules: read-only without edit permission, and "create new" only with create permission on that record type.
- **FR-009**: The customer form MUST NOT edit linked addresses or contacts in place. They are shared records, so corrections are made by unlinking and then linking or creating the correct record.
- **FR-021** *(added 2026-10-17)*: The walk-in customer (the deployment's POS default customer) MUST NOT accept new addresses, contacts or taxpayers from the customer form. Its only taxpayer is XAXX010101000 (general public): the form shows it fixed with an explanatory note, and saving always sends exactly that RFC. Unlinking a stray address or contact stays allowed. This rule lives in mbe-ui only; mbe-api does not enforce it.
- **FR-020** *(added 2026-10-17)*: The customer form MUST open on its own screen (create, view and edit), not in the side panel over the list. Row click opens it read-only, Edit opens it editable, and leaving with unsaved edits asks first.

**Facilities catalog**

- **FR-010**: Production-site facilities MUST show the Points of Sale and Cash Drawers sections, with counts and create actions, exactly as stores do.
- **FR-011**: The note saying production sites only manage warehouses MUST be removed.
- **FR-012**: The Spanish name of the production-site facility type MUST be "Planta" everywhere it is shown.
- **FR-013**: Facility type MUST still be shown, with its label and icon, so users can tell plants and stores apart.

**Product catalog**

- **FR-014**: Clicking a product photo in the product list or on the product detail screen MUST open a dialog that shows the photo enlarged. The dialog fits the photo to the available screen space, keeps its aspect ratio, and shows the product's name.
- **FR-015**: The dialog MUST close with Escape, a click outside it, or an explicit close control.
- **FR-016**: A click on the photo MUST open only the preview, not the row's own action.
- **FR-017**: The preview MUST NOT open for products without a photo, or when the photo failed to load.
- **FR-018**: Product thumbnails in the product list MUST have visible space on every side and MUST NOT be clipped by the row height at any density setting.
- **FR-019**: The photo section on the product detail screen MUST also keep visible space between the thumbnail and its neighbors.

### Key Entities

- **Customer**: a buyer record. Linked to zero or more Addresses, Contacts and Taxpayers.
- **Address**: a shared postal address (nickname, street, numbers, neighborhood, city, state, postal code, country, status). Can be linked to several customers and referenced by orders and deliveries.
- **Contact**: a shared person record (name, job title, phone, mobile, email, etc.). Can be linked to several customers.
- **Taxpayer (RFC)**: a fiscal recipient (RFC, legal name, tax regime, postal code, email). Can be linked to several customers.
- **Facility**: a store or a production site ("Planta"). Either type can now hold warehouses, points of sale and cash drawers.
- **Product photo**: the single image stored for a product. It is used both as the thumbnail and as the enlarged preview.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A user can link two existing addresses and create one new contact for a customer in under 2 minutes, without leaving the customer form.
- **SC-002**: Saving any customer keeps 100% of their taxpayer, address and contact links unless the user removed them. Multi-RFC customers lose zero links on save.
- **SC-003**: A plant can be given a point of sale and a cash drawer from the Facilities screen in the same number of steps as a store.
- **SC-004**: With the app in Spanish, "Sitio de producción" appears on zero screens.
- **SC-005**: A product's photo can be seen enlarged with one click from the list, and closed with one action.
- **SC-006**: No product thumbnail touches or is clipped by its row borders at any supported density.

## Assumptions

- **Out of scope.** Customer per-product discounts and legacy shipping flags are out of scope because the backend does not expose them. Adding them would need new mbe-api work first, so they belong in a follow-up.
- **Not covered by this spec.** These are not relationships, so this spec does not add them:
  - zone, credit limit and credit-days columns in the customer list;
  - customer balance / credit status.
- **Changed 2026-10-17.** At the product owner's request, the customer form moved from the side panel to its own screen (FR-020); with the linked-record sections it was too much for a panel.
- **Clarified 2026-10-16.** No in-place editing of shared addresses and contacts from the customer form; the form only links, unlinks and creates them.
- **Unlinking only.** The customer form never deletes addresses, contacts or taxpayers. It only unlinks them.
- **Single photo.** The preview uses the one photo the backend already serves. No new image size is needed. Zoom and pan inside the preview are out of scope.
- **English label.** The English label stays "Production Site". The request only covered the Spanish label.
- **No other production-site rules.** Points of sale and cash drawers were the only restriction on production sites. Warehouses and every other screen already treat both facility types the same.
- **Supplier screens.** Supplier addresses and contacts are out of scope. The backend has the link tables but does not expose them yet.
- **No backend changes.** All customer work uses capabilities the backend already provides: the replace-all link lists on customer save, and the standalone address, contact and taxpayer endpoints.
