# Feature Specification: Catalog UI Improvements Round 2

**Feature Branch**: `007-catalog-ui-improvements-2`

**Created**: 2026-07-05

**Status**: Draft

**Input**: User description: "Follow-up refinements to the catalog CRUD screens (products list and product detail, and the shared row-action/data-table widgets other catalog CRUDs also use) based on usage feedback after the previous improvements round: drop frozen table columns, reduce row actions to Edit-only with row-click opening a read-only view, multi-select label filtering, complete the product form (SKU, supplier, drop price list in favor of labels), relocate the deactivate action into the form body with a warning style, enlarge and correctly fit the product photo, reorder the product list's photo column, let users copy a product's code, and rename the LEGACY_PHOTOS_BASE_URL setting to PHOTOS_BASE_URL."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Browse and open a product without accidentally editing it (Priority: P1)

A catalog user scans the products table to find something — most of the time they just want to look something up, not change it. Today, clicking anywhere on a row (or the row's dedicated action icons) opens the full editable form, so a stray click risks an unintended edit. The user wants row clicks and the table's row actions to default to a safe, read-only view, with an explicit, deliberate step required to switch to editing.

**Why this priority**: This is the interaction users hit dozens of times a day on every catalog table (products today; the same shared components back the users list and will back future catalog CRUDs). Getting the default to "safe" removes the biggest everyday friction/risk point from the previous round.

**Independent Test**: Open the products list, click a row (not an action icon) — the detail screen opens in read-only mode with a "View" title and no editable fields. From there, press the provided button to switch to the editable form for the same record.

**Acceptance Scenarios**:

1. **Given** the products list is showing rows, **When** a user clicks anywhere on a row (not a dedicated action icon), **Then** the product detail screen opens in read-only mode (fields disabled, no Save button).
2. **Given** the products list row actions, **When** a user with edit rights looks at a row, **Then** they see only one action icon (Edit) — the previous View and Delete row icons are gone.
3. **Given** the product detail screen opened in read-only mode, **When** the screen renders, **Then** the app bar title reads "View <Product/Entity>" rather than "Edit <Product/Entity>".
4. **Given** the product detail screen opened in read-only mode and the current user has update rights on the record, **When** the screen renders, **Then** a button is visible that navigates to the same record's editable form.
5. **Given** the product detail screen opened in read-only mode and the current user does NOT have update rights, **When** the screen renders, **Then** the button to switch to the editable form is not shown.
6. **Given** the Edit row-action icon on the products list, **When** a user with edit rights clicks it, **Then** the product detail screen opens directly in editable mode (unchanged from today).
7. **Given** a user without update rights on products, **When** they view the products list, **Then** no Edit row-action icon is shown for any row (existing permission behavior is preserved).

---

### User Story 2 - Filter products by more than one label at a time (Priority: P2)

A user managing labeled products (e.g., "clearance", "seasonal") wants to see everything tagged with any one of several labels in a single filtered view, instead of re-running the filter once per label.

**Why this priority**: Meaningfully improves a filtering workflow already in daily use, but it is additive — the single-label filter already works, so this is a quality-of-life upgrade rather than a fix to broken/risky behavior.

**Independent Test**: Open the products list filter panel, select two or more labels, apply, and confirm the result set includes products carrying any of the selected labels; the active-filter badge count reflects the number of labels selected.

**Acceptance Scenarios**:

1. **Given** the products filter panel, **When** a user opens the label filter, **Then** they see a list of selectable labels (not a single-choice dropdown) and can select more than one.
2. **Given** two or more labels selected in the filter, **When** the user applies the filter, **Then** the products list shows products matching at least one of the selected labels.
3. **Given** one or more labels selected, **When** the user views the filter badge/count, **Then** it reflects the number of labels currently selected (not just whether any is selected).
4. **Given** labels selected in the filter, **When** the user clears all filters, **Then** the label selection is cleared along with the other filters.

---

### User Story 3 - See and manage all of a product's real attributes (Priority: P2)

A user editing a product notices the form doesn't show every attribute the catalog actually tracks (e.g., SKU is missing entirely), while it does show a price-list section that isn't editable and duplicates information better served by labels. The user wants the form to reflect what the product actually is: complete on real, editable attributes and free of the dead-weight price section.

**Why this priority**: Data users need (SKU, supplier) is currently invisible or unverified in the UI, which is a functional gap; equally, the form carries a read-only section that no longer earns its space. Same priority tier as label filtering — both are form-completeness/quality improvements on an already-working screen.

**Independent Test**: Open an existing product with a SKU, a supplier, and at least one label. Confirm the SKU value is visible on the form, the supplier picker reflects the assigned supplier and can be changed or cleared and saved, the price-list section is gone, and labels are now presented where prices used to sit.

**Acceptance Scenarios**:

1. **Given** a product that has a SKU value, **When** the product form is opened (create or edit, read-only or editable), **Then** the SKU value is visible, and in editable mode it can be changed and saved.
2. **Given** the product form, **When** a user assigns, changes, or clears the supplier, **Then** the change is saved and reflected the next time the product is loaded (clearing must persist as "no supplier", not silently keep the previous one).
3. **Given** the product detail screen, **When** it renders, **Then** no price-list section or price values are shown anywhere on the form.
4. **Given** the product detail screen, **When** it renders, **Then** the labels control occupies the layout position the price-list section previously used, alongside the boolean attribute switches.

---

### User Story 4 - Deactivate a product from a safer, more visible control (Priority: P3)

A user deactivating a product currently taps a small icon in the app bar — a spot with no room to signal "this is a consequential, hard-to-miss action." The user wants deactivation moved into the form body as a clearly-styled warning action, directly below Save, so it reads as deliberate and distinct from routine navigation-bar icons.

**Why this priority**: Deactivation is already confirmed via a dialog today, so this is a discoverability/affordance improvement, not a data-safety fix — lower urgency than the items above.

**Independent Test**: Open an editable, active product with delete rights. Confirm there is no deactivate icon in the app bar, and a warning-styled "Deactivate" button appears just below the Save button; pressing it still asks for confirmation before deactivating.

**Acceptance Scenarios**:

1. **Given** an editable product detail screen for an active product, **When** the app bar renders, **Then** it no longer shows a deactivate icon.
2. **Given** an editable product detail screen for an active product with delete rights, **When** the form renders, **Then** a button styled to signal a warning/destructive action ("Deactivate") appears directly below the Save button.
3. **Given** the new Deactivate button, **When** a user presses it, **Then** the existing confirmation dialog still appears before the product is deactivated.
4. **Given** a product that is already deactivated, or a user without delete rights, or read-only/create mode, **When** the form renders, **Then** the Deactivate button is not shown (matching today's visibility rule for the app-bar icon it replaces).

---

### User Story 5 - See product photos at a usable size and uncropped (Priority: P3)

A user checking a product's photo — on the list or the detail screen — finds today's thumbnail too small and, for some images, cropped so the subject is cut off. The user wants a bigger thumbnail with a fit that always shows the whole image.

**Why this priority**: A visual-clarity refinement to an existing, working feature (photo upload/display already ships) — valuable but not blocking any workflow.

**Independent Test**: Open a product with a non-square photo where the current display crops it. Confirm the enlarged thumbnail shows the entire image without cropping, on both the detail screen and anywhere else the same thumbnail is reused.

**Acceptance Scenarios**:

1. **Given** a product with a photo, **When** its thumbnail is displayed, **Then** it renders at 75% larger dimensions than before, wherever that thumbnail component is used.
2. **Given** a product photo whose aspect ratio differs from the thumbnail's shape, **When** it is displayed, **Then** the entire image is visible (no cropped/cut-off edges), rather than being cropped to fill the frame.

---

### User Story 6 - Scan and reuse product codes faster from the list (Priority: P3)

A user building a downstream form (e.g., an order) needs a product's code and currently must open the product to read and manually retype it. The user wants the photo — the thing that helps them visually confirm they've found the right product — to be the very first thing they see in each row, and wants a one-action way to copy a product's code straight from the list.

**Why this priority**: A convenience/speed improvement layered on an already-functional list; independent of, and lower urgency than, the safety and completeness fixes above.

**Independent Test**: Open the products list; confirm the photo is the first column with no header text, then use the provided control to copy a visible product's code and paste it elsewhere to confirm the value matches.

**Acceptance Scenarios**:

1. **Given** the products list table, **When** it renders, **Then** the photo column is the first (leftmost) column, and its header shows no text/label.
2. **Given** the products list table, **When** it renders, **Then** no column is frozen/pinned during horizontal layout or scroll.
3. **Given** a row's code cell, **When** a user invokes the copy affordance on that cell, **Then** the exact product code is placed on the system clipboard.
4. **Given** a successful copy action, **When** it completes, **Then** the user gets a brief, unobtrusive confirmation that the code was copied.

---

### Edge Cases

- A product has no photo at all: the enlarged thumbnail area still renders its existing placeholder, just at the larger size.
- A user has view-but-not-edit rights on a product reached via row click (read-only): the "switch to edit" button must not appear, consistent with them never being able to reach the editable form for that record.
- All labels are deselected in the multi-select filter: the list behaves exactly as "no label filter applied" (matches today's `null`/no-filter semantics).
- A product carries labels that get deleted/deactivated elsewhere while its detail screen is open in read-only mode: the read-only labels display simply omits them, consistent with existing label-rendering behavior.
- A user is mid-edit on the form (unsaved changes) and taps Deactivate: the existing confirmation dialog still gates the destructive action before anything is submitted, and canceling leaves the in-progress edits untouched.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The products list, the users list, and any other screen built on the shared catalog table/row-action components MUST NOT render any column as frozen/pinned; all columns MUST participate in normal (non-scrolling) layout.
- **FR-002**: The shared catalog row-actions component MUST offer only an Edit action per row; the View and Delete row-level icons MUST be removed from that shared vocabulary.
- **FR-003**: Clicking anywhere on a catalog table row (outside the row's action icon) MUST open that record's detail screen in read-only mode, replacing today's behavior of opening the editable form.
- **FR-004**: The Edit row-action icon MUST continue to open the record's detail screen in editable mode, and MUST only be shown to users holding update rights on that record (existing permission gating preserved).
- **FR-005**: When a catalog detail screen is opened in read-only mode, its title MUST read as a "View" title for that entity, not an "Edit" title.
- **FR-006**: When a catalog detail screen is opened in read-only mode and the current user holds update rights on that record, the screen MUST show a control that navigates to the same record's editable form; this control MUST be hidden when the user lacks update rights.
- **FR-007**: The products list filter MUST let a user select zero, one, or multiple labels at once, presented as a multi-select control (e.g., a checkable list) rather than a single-choice dropdown.
- **FR-008**: When one or more labels are selected in the products filter, the list MUST return products matching at least one of the selected labels (OR semantics).
- **FR-009**: The products filter's active-filter indicator MUST reflect the number of labels currently selected, and clearing all filters MUST also clear the label selection.
- **FR-010**: The product form MUST display the product's SKU value, and MUST allow it to be edited and saved wherever other similar text attributes (code, name, brand, etc.) are editable.
- **FR-011**: The product form's supplier control MUST support assigning, changing, and clearing the supplier, and clearing MUST persist as "no supplier" on save (not silently retain the prior value).
- **FR-012**: The product form MUST NOT display any price-list section or price values.
- **FR-013**: The product form MUST present the labels control in the layout area previously occupied by the price-list section, alongside the boolean attribute switches.
- **FR-014**: The product detail screen's app bar MUST NOT contain a deactivate/delete icon.
- **FR-015**: The product form MUST present a Deactivate button styled to signal a warning/destructive action, positioned directly below the Save button, visible under the same conditions (permissions, product state, mode) that today gate the app-bar deactivate icon.
- **FR-016**: Pressing the Deactivate button MUST show the existing confirmation dialog before the product is deactivated.
- **FR-017**: The product photo thumbnail MUST render at 75% larger dimensions than its current size, consistently everywhere that thumbnail is reused (list and detail screen).
- **FR-018**: The product photo MUST be displayed with a fit that shows the entire image without cropping, replacing any current fit behavior that cuts off part of the image.
- **FR-019**: The products list table MUST show the photo as its first (leftmost) column, with no header text for that column.
- **FR-020**: The products list MUST provide a control on each row's code cell that copies that row's exact product code to the system clipboard, with a brief confirmation shown on success.
- **FR-021**: The configuration setting currently named for resolving legacy photo paths (`LEGACY_PHOTOS_BASE_URL`) MUST be renamed to `PHOTOS_BASE_URL` everywhere it is referenced (code, environment templates, and related documentation), with no change to its resolution behavior.

### Key Entities

- **Product**: The catalog item being viewed/edited. Gains visible SKU; supplier is assigned/cleared as a settable reference to a **Supplier**; loses its association with price-list display in the form; retains its many-to-many association with **Label**.
- **Label**: A tag attachable to products, already used for editing a product's own labels; reused here as the basis for multi-select list filtering (a product matches the filter if it carries any selected label).
- **Supplier**: An existing reference entity selectable on a product; scope here is completing/confirming its assign-clear-persist behavior, not introducing it.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Zero accidental edits reported from row clicks on catalog tables after release — read-only view is the default outcome of a row click in 100% of cases.
- **SC-002**: Users can filter the products list by 2+ labels in a single pass, eliminating the need to re-run the filter once per label.
- **SC-003**: 100% of a product's user-relevant attributes present in the underlying data (including SKU and supplier) are visible on the product form; 0% show a price-list section.
- **SC-004**: Users can copy a product code from the list in a single action, without opening the product detail screen.
- **SC-005**: No catalog table exhibits horizontal scrolling or a frozen column after release.
- **SC-006**: Product photos display with no visibly cropped/cut-off content across a representative sample of existing product images.

## Assumptions

- The shared row-actions and data-table components are used today by the products list and the (non-catalog) users list; this change updates the shared components, so both consuming screens change consistently. Any future catalog CRUD screens built on these components inherit the same behavior automatically.
- "Read-only mode" for the detail screen already exists as a rendering mode (reached today via a dedicated View action); this feature changes what triggers it (row click instead of a dedicated icon) and how its title reads, not its underlying read-only rendering.
- Removing the price-list section is a client-side UI change to mbe-ui. Any corresponding removal of price-list support from the mbe-api service itself is out of scope for this repository and tracked separately.
- "Copy code" uses the system clipboard already available to the platform (web/desktop) this app runs on; no new permission or backend support is required.
- The label multi-select filter uses OR semantics (match any selected label) as the default, matching how label filtering commonly behaves elsewhere in the app (e.g., existing per-product label assignment being a set, not an exclusive choice).
- Renaming `LEGACY_PHOTOS_BASE_URL` to `PHOTOS_BASE_URL` is a naming-only change: the setting continues to resolve the same legacy photo paths it does today, under its new name.
- The "75% bigger" photo sizing is measured against the current thumbnail's rendered dimensions on each screen where it appears (list and detail), so both grow proportionally from their own current baseline.
