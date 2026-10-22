# Feature Specification: Back-Office UI Polish

**Feature Branch**: `049-back-office-ui-polish`

**Created**: 2026-10-22

**Status**: Draft

**Input**: User description: "Back-office UI polish (covers mictlanix/mbe-ui#200; no roadmap plan issue — improvements to existing UI). (1) Exchange rates behind a deployment-level environment flag, off by default: hide the nav entry and the currency/exchange-rate fields. (2) Facility logo is an image, not a string. (3) Search box: stadium shape, one search icon. (4) Reorganize the quote header. (5) Taxpayer issuer certificates table: misaligned margins and a nested vertical scroll. (6) Pricing screen: table margin and chips not aligned. (7) Employee form: salesperson switch next to the enrollment number, status full width."

## Context & Findings

These findings come from an audit of the current screens on 2026-10-22. They explain each item and set the scope.

- **Exchange rates and currency.** Most deployments sell in one currency, but the back office always shows multi-currency controls:
  - the "Tipos de Cambio" entry in the navigation menu;
  - "Moneda" and "Tipo de cambio" in the sales order header;
  - "Moneda" in the sales quote header;
  - a currency picker on the product form;
  - a currency code (e.g. "MXN") before the payment amount.

  The app already has deployment-level settings fixed at build time. None of them hides a navigation entry today.
- **Facility logo.** The facility form shows the logo as a free-text field, so the user has to type an image address by hand. The backend already accepts a logo image upload for a facility. It has no way to delete a logo. Product photos already have a pick, preview and upload flow that this item can follow.
- **Search box.** One shared search box serves about 20 list screens. It shows two magnifier icons: a decorative one at the start and a search button at the end. Its corners are slightly rounded, while the sales product search box ("Buscar o escanear producto") is fully rounded (a stadium/pill shape). A search runs only when submitted (Enter or the button), and that stays.
- **Quote header.** The row of facts (Referencia, Estado, Fecha, Fecha de vencimiento, Moneda) gets only about half the card width, so "Moneda" drops to a second line. The "Más detalles" toggle starts near the middle of the card instead of at the trailing edge that spec 032 (FR-006) requires. The back-office order header is a copy of the same layout and has the same defect.
- **Taxpayer issuer certificates.** On the Razón Social edit screen, the "Certificados" table is indented further than the form fields and the section heading, and it ends short of the right edge. Its height is calculated wrong, so even one certificate makes the table scroll inside the page, and the user gets two vertical scrollbars.
- **Pricing screen.** The search box, the worklist chips and the table's left edges don't line up. On narrow layouts they start at 16, 16 and 32px. On wide layouts they start at 24, 16 and 40px.
- **Employee form.** "Número de empleado" sits alone in its row, leaving the cell next to it empty. The "Vendedor" switch and the "Estado" selector share a row further down, so Estado only gets half the width.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Single-currency deployments don't show exchange rates (Priority: P1)

A deployment that sells in one currency (most of them) shows no exchange-rate menu entry and no currency or exchange-rate fields. A deployment that does work in several currencies turns the option on and sees everything as it is today.

**Why this priority**: Controls that never apply clutter every sales document and the main menu for most customers. Users may also change a currency by mistake.

**Independent Test**: Build with the option at its default (off). Confirm that the menu entry is gone, the exchange-rates address doesn't open, and the currency fields are absent from orders, quotes, products and payments. Build again with the option on and confirm that everything appears as before.

**Acceptance Scenarios**:

1. **Given** the option is off, **When** a user with exchange-rate access opens the navigation menu, **Then** "Tipos de Cambio" is not listed.
2. **Given** the option is off, **When** a user goes to the exchange-rates screen's address directly, **Then** the screen doesn't open and the user is redirected as for any unavailable screen.
3. **Given** the option is off, **When** a user opens a sales order, **Then** the header shows neither "Moneda" nor "Tipo de cambio".
4. **Given** the option is off, **When** a user opens a sales quote, **Then** the header doesn't show "Moneda".
5. **Given** the option is off, **When** a user creates a product, **Then** no currency picker is shown and the product is saved in the default currency (MXN).
6. **Given** the option is off, **When** a cashier enters a payment amount, **Then** no currency code is shown before the amount.
7. **Given** the option is on, **When** a user with access visits each of the places above, **Then** they show the same controls as before this feature.

---

### User Story 2 - Facility logo is uploaded as an image (Priority: P2)

On the facility form, an administrator picks a logo image from their device, sees a preview, and saves. They no longer type an image address.

**Why this priority**: A typed address is error-prone and can't upload anything. This is the only item that adds a capability rather than fixing presentation.

**Independent Test**: Edit a facility, pick a PNG or JPEG, save, then reopen the facility and see the uploaded logo.

**Acceptance Scenarios**:

1. **Given** a facility with no logo, **When** the administrator opens its form, **Then** they see an empty logo placeholder with a control to choose an image, not a text field.
2. **Given** the administrator has chosen a valid image, **When** the form shows it, **Then** a preview appears before saving.
3. **Given** a chosen image, **When** the administrator saves, **Then** the image is uploaded and reopening the facility shows it.
4. **Given** a new facility, **When** the administrator picks a logo and saves, **Then** the facility is created first and the logo is uploaded to it.
5. **Given** a facility with a logo, **When** the administrator chooses a different image and saves, **Then** the new image replaces the old one.
6. **Given** a file that isn't a JPEG or PNG, or one larger than the allowed size, **When** the administrator picks it, **Then** it is rejected with a message and nothing is uploaded.
7. **Given** the facility saved but the logo upload failed, **When** the error appears, **Then** the facility data is kept, the form stays open with a message that the logo wasn't saved, and saving again retries the upload.

---

### User Story 3 - A cleaner, consistent search box (Priority: P2)

Every list screen's search box is fully rounded, like the sales product search box, and shows one search icon.

**Why this priority**: The search box is on about 20 screens, so this is the most visible polish item. It is low-risk because the change is visual only.

**Independent Test**: Open any two list screens (e.g. Empleados and Precios). Confirm a stadium-shaped search box with exactly one magnifier, and that Enter and the icon both run the search.

**Acceptance Scenarios**:

1. **Given** any list screen, **When** it loads, **Then** its search box has fully rounded ends and exactly one search icon.
2. **Given** text typed in the search box, **When** the user presses Enter or activates the search icon, **Then** the search runs as before.
3. **Given** text typed but not submitted, **When** the user keeps typing, **Then** no search runs. Submit-only behavior is unchanged.

---

### User Story 4 - Quote and order headers read as one line (Priority: P2)

On the quote screen, Referencia, Estado, Fecha, Fecha de vencimiento and Moneda sit on one line, and "Más detalles" sits at the trailing edge of the card. The back-office order header gets the same treatment.

**Why this priority**: The header is the first thing read on every quote and order. The current wrap and the floating toggle look broken and go against spec 032.

**Independent Test**: Open a confirmed quote at desktop width. Confirm that all facts are on one line and the toggle is right-aligned. Repeat for a back-office order. Repeat at the compact width and at the largest text size, and confirm that nothing overflows.

**Acceptance Scenarios**:

1. **Given** a quote at desktop width, **When** the header renders, **Then** all fact-strip fields share one line and the disclosure toggle is at the card's trailing edge.
2. **Given** a back-office order at desktop width, **When** the header renders, **Then** the same layout holds: the facts use the available width and the trailing actions sit at the trailing edge.
3. **Given** a narrow width or the largest text size, **When** the facts no longer fit on one line, **Then** they wrap onto more lines using the full available width, the toggle stays at the trailing edge, and nothing overflows or clips, including when the label reads "Menos detalles".

---

### User Story 5 - Certificates table aligns and scrolls with the page (Priority: P3)

On the Razón Social edit screen, the "Certificados" table lines up with the form fields and the section heading. The table shows all its rows at full height, so only the page scrolls.

**Why this priority**: The double scroll is annoying, but it only affects one administrative screen.

**Independent Test**: Edit a taxpayer issuer with one certificate and then one with several. Confirm that the table's left and right edges match the form, all rows are visible without an inner scrollbar, and the page is the only thing that scrolls.

**Acceptance Scenarios**:

1. **Given** an issuer with one certificate, **When** the edit screen renders, **Then** the row is fully visible and the table has no scrollbar of its own.
2. **Given** an issuer with many certificates, **When** the user scrolls, **Then** the page scrolls through all of them and the table doesn't scroll on its own.
3. **Given** any width, **When** the screen renders, **Then** the table's left and right edges align with the form fields above it.

---

### User Story 6 - Pricing screen rows line up (Priority: P3)

On the Precios screen, the search box, the worklist chips, the pending-changes bar, the table and the keyboard hint all start at the same left edge.

**Why this priority**: The misalignment is cosmetic and limited to one screen.

**Independent Test**: Open Precios at a narrow and at a wide layout. Confirm that the left edges of the search box, chips and table coincide.

**Acceptance Scenarios**:

1. **Given** any layout width, **When** the Precios screen renders, **Then** the search box, chips, pending-changes bar (when shown), table and hint share one left edge.
2. **Given** any layout width, **When** the screen renders, **Then** the table's right edge aligns with the search row's right edge.

---

### User Story 7 - Employee form uses its space (Priority: P3)

On the employee form, the "Vendedor" switch sits in the empty cell next to "Número de empleado", and "Estado" spans the full width.

**Why this priority**: This small layout fix makes the form shorter and closes the gap.

**Independent Test**: Open the new-employee form at a two-column width. Confirm that the switch is beside the employee number, Estado is full width, and toggling the switch still saves.

**Acceptance Scenarios**:

1. **Given** a two-column layout, **When** the employee form renders, **Then** "Vendedor" occupies the cell next to "Número de empleado".
2. **Given** a two-column layout, **When** the form renders, **Then** "Estado" spans the full form width.
3. **Given** a one-column layout, **When** the form renders, **Then** the fields stack in the same order without overlap.
4. **Given** the switch is toggled, **When** the employee is saved, **Then** the salesperson value persists as before.

---

### Edge Cases

- **Option off, document in another currency.** A sales order or quote recorded in a non-default currency (from legacy data or a period when the option was on) has its currency hidden like any other. The amounts still display as they do today.
- **Option value malformed or missing.** The option falls back to off and the app starts normally.
- **Option off and exchange-rates permission.** Users with exchange-rate permission still don't see the entry. Permission alone doesn't reveal it.
- **Logo address unreachable.** If the logo can't be loaded, the form shows the empty placeholder and doesn't break.
- **Creating a facility with a logo, upload fails.** The facility still exists. The user sees that only the logo failed and can retry from the edit form.
- **Removing a logo.** The form doesn't offer a "remove logo" action, because the backend can't delete one (see Assumptions).
- **Search box at compact width.** The stadium shape and single icon hold, and the filter button beside it stays aligned.
- **Taxpayer issuer with no certificates.** The section shows its empty state without leaving a blank, fixed-height area.

## Requirements *(mandatory)*

### Functional Requirements

**Exchange rates option**

- **FR-001**: The app MUST provide a deployment-level option that turns multi-currency (exchange rates) on or off. It defaults to **off**.
- **FR-002**: The option MUST be listed with its default alongside the other deployment settings. A missing or malformed value MUST fall back to off without failing startup. It MUST NOT be reachable or changeable from the UI.
- **FR-003**: When the option is off, the "Tipos de Cambio" navigation entry MUST be hidden for every user, whatever their permissions.
- **FR-004**: When the option is off, the exchange-rates screen MUST NOT be reachable by direct address. Navigating there MUST behave like navigating to any screen the user can't access.
- **FR-005**: When the option is off, the app MUST hide:
  - the currency selector and the exchange-rate field in the sales order header;
  - the currency field in the sales quote header;
  - the currency selector on the product form;
  - the currency code shown with the payment amount.
- **FR-006**: When the option is off, a newly created product MUST be saved in the default currency (MXN). Existing documents MUST keep the currency they already have; hiding a field MUST NOT change stored data.
- **FR-007**: When the option is on, every control listed in FR-003–FR-005 MUST appear and behave exactly as before this feature, still subject to the existing permissions.

**Facility logo**

- **FR-008**: The facility form MUST replace the free-text logo field with an image control: a preview (or an empty placeholder) and an action to choose an image file from the device.
- **FR-009**: The image control MUST accept only JPEG and PNG files within the same size limit as product photos. It MUST reject anything else with a message, before saving.
- **FR-010**: A chosen image MUST be previewed before saving. It MUST be uploaded when the form is saved: after creation for a new facility, alongside the update for an existing one.
- **FR-011**: If the facility saves but the logo upload fails, the facility data MUST be kept, the form MUST stay open showing that the logo wasn't saved, and saving again MUST retry the upload against the saved facility.
- **FR-012**: A facility's existing logo MUST be displayed when its form opens. Choosing a new image MUST replace it on save.

**Search box**

- **FR-013**: The shared list-screen search box MUST have a fully rounded (stadium) shape that matches the sales product search box.
- **FR-014**: The shared search box MUST show exactly one search icon, and activating that icon MUST run the search.
- **FR-015**: Search behavior MUST be unchanged: it runs on Enter or on the icon, never while typing.

**Quote and order headers**

- **FR-016**: The quote header's fact strip MUST use the card's full available width, so that at desktop widths all its facts (including Moneda when shown) sit on one line.
- **FR-017**: The quote header's disclosure toggle ("Más detalles" / "Menos detalles") MUST sit at the trailing edge of the strip.
- **FR-018**: The back-office order header MUST follow the same layout: the facts use the full width and the trailing actions sit at the trailing edge.
- **FR-019**: At compact width and at the largest text size, both headers MUST wrap rather than overflow or clip. The facts wrap onto more lines first. The toggle's own label wraps only when even its reserved share of the row is too narrow. The toggle MUST stay fully visible in both its labels.

**Certificates table**

- **FR-020**: On the taxpayer issuer edit screen, the certificates table's left and right edges MUST align with the form fields above it.
- **FR-021**: The certificates table MUST show all its rows at their full height, with no scroll area of its own. The page MUST be the only vertical scroll.

**Pricing screen**

- **FR-022**: On the pricing screen, the search row, worklist chips, pending-changes bar, table and keyboard hint MUST share the same left and right edges, at every layout width.

**Employee form**

- **FR-023**: On the employee form, the salesperson ("Vendedor") switch MUST occupy the cell next to the employee number ("Número de empleado") when the form shows two columns.
- **FR-024**: The status ("Estado") field on the employee form MUST span the full form width.

**General**

- **FR-025**: No screen touched by this feature MAY clip, overflow or hide content at supported widths or at the largest text size.

### Key Entities

- **Deployment setting – multi-currency**: an on/off value fixed per deployment that decides whether exchange-rate and currency controls appear. Default off.
- **Facility logo**: the image associated with a facility. It is shown on the facility form and replaced by uploading a new image. It is stored by the backend and referenced by address.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: With the option at its default, a user finds zero exchange-rate or currency controls across the menu, sales orders, quotes, products and payments.
- **SC-002**: With the option on, 100% of the controls listed in FR-003–FR-005 appear as before.
- **SC-003**: An administrator can set a facility's logo by picking a file, with no address typed, in under 30 seconds. The logo is visible on reopening the facility.
- **SC-004**: Every list screen that uses the shared search box shows exactly one search icon and a fully rounded box.
- **SC-005**: At desktop width, a quote's and an order's header facts occupy one line, and the disclosure toggle sits at the trailing edge.
- **SC-006**: On the Razón Social edit screen, at most one vertical scrollbar is visible, whatever the certificate count, and the table's edges are within 1 logical pixel of the form's.
- **SC-007**: On the pricing screen, the left edges of the search box, chips and table are within 1 logical pixel of one another at every layout width.
- **SC-008**: The employee form at two-column width is one row shorter than before, with no empty cell beside "Número de empleado".

## Assumptions

- The multi-currency option is a build-time deployment setting, consistent with the existing split between deployment settings and per-user preferences. Changing it requires a new build.
- "Hide the fields" covers display only. The app doesn't convert, clear or rewrite any stored currency or exchange-rate value.
- Facility logos can't be removed through the app, because the backend has no clean way to clear one. A remove action is out of scope until mictlanix/mbe-api#250 ships.
- The logo size limit and accepted formats match the existing product photo upload.
- The order header follows the quote header fix because the two share the same layout and defect. Its other content (fields, actions) is unchanged.
- The alignment fixes for the certificates table and the pricing screen stay local to those screens. Changing the default spacing of every table in the app is out of scope.
- No backend changes are required. Everything this feature needs is already available.
- Tracked by mictlanix/mbe-ui#200. No roadmap plan issue applies, because these are improvements to existing UI.
