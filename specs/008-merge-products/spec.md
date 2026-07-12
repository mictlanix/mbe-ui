# Feature Specification: Merge Products

**Feature Branch**: `008-merge-products`

**Created**: 2026-07-12

**Status**: Draft

**Input**: User description: "Add a Merge Products feature to the catalog UI that lets an authorized user fuse two records found to be duplicates into one, surfacing mbe-api's already-implemented `POST /api/v1/products/merge` endpoint. Behavior mirrors the legacy `/Products/Merge` screen: two search-as-you-type product pickers (a canonical 'Product' that is kept and a 'Duplicate' that is remapped and deleted), a 'Merge' action, and a back-to-list affordance. The action is destructive and irreversible, gated by the `productsMerge` RBAC privilege."

## Clarifications

### Session 2026-07-12

- Q: After a successful merge, where should the user land and what should the pickers show? → A: **Confirm success, then return to the products list.** A merge is a rare, deliberate cleanup action; on success the user is shown a confirmation and returned to the products list (the canonical product remains, the duplicate is gone). The merge screen does not stay open pre-filled — starting another merge is a fresh, deliberate navigation. This matches the legacy flow's intent (one merge per visit) while removing the risk of an accidental second merge from stale selections.
- Q: Should the canonical ("Product") picker exclude already-deactivated/soft-deleted products, or show all products? → A: **Show all products, matching the legacy merge search.** The legacy merge suggestion search intentionally queries *all* products (unlike the general product search, which hides disabled ones), because a duplicate cleanup may legitimately involve a product in any state. Both pickers search the full catalog.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Fuse a confirmed duplicate into the canonical product (Priority: P1)

A catalog administrator discovers the same physical product was entered twice (e.g., two "BROCA CONCRETO MULTICONSTRUCCION 1/4" X 4" BOSCH 7150" records with different codes). Order lines, inventory movements, and labels are scattered across both. The administrator wants to keep one record (the canonical "Product") and fold the other (the "Duplicate") into it, so that all history now points at a single product and the duplicate disappears from the catalog.

**Why this priority**: This is the entire reason the feature exists — without the merge itself nothing else has value. It is the MVP: selecting a canonical and a duplicate and completing the fusion delivers the full user benefit (a de-duplicated catalog with preserved transactional history).

**Independent Test**: On the Merge Products screen, select a canonical product and a different duplicate product, confirm the destructive action, and verify the merge completes: the confirmation is shown, the duplicate no longer appears in the catalog, and the canonical product remains with the duplicate's references now attached to it.

**Acceptance Scenarios**:

1. **Given** a canonical product is selected in "Product" and a different product is selected in "Duplicate", **When** the user activates "Merge" and confirms the destructive action, **Then** the merge is submitted, a success confirmation is shown, and the user is returned to the products list.
2. **Given** a completed merge, **When** the user browses the products list, **Then** the duplicate product is no longer present and the canonical product still exists.
3. **Given** a completed merge, **When** the user inspects records that previously referenced the duplicate (orders, inventory movements, labels), **Then** those references now resolve to the canonical product with no loss of history.
4. **Given** the merge is in progress after confirmation, **When** the request has not yet returned, **Then** the "Merge" action is disabled/shows progress so the operation cannot be submitted twice.

---

### User Story 2 - Find the two products by searching as you type (Priority: P2)

Before merging, the administrator has to locate both records. They rarely know the internal id; they recognize a product by its name, code, model, SKU, or brand, and confirm it visually by its photo. The administrator wants each picker to search the whole catalog as they type and present enough detail (photo plus name/code/model/SKU) to pick the exact record with confidence.

**Why this priority**: The merge is only safe if the operator can reliably identify the correct records; a weak picker turns a cleanup tool into a way to destroy the wrong product. It is P2 because the merge action (US1) is the core, but this journey is what makes it usable and trustworthy in practice.

**Independent Test**: Type a partial product term into either picker and confirm the suggestion list filters the full catalog by name/code/model/SKU/brand, shows a photo thumbnail plus identifying text per suggestion, and lets exactly one product be chosen into that field.

**Acceptance Scenarios**:

1. **Given** either picker is focused, **When** the user types a partial term, **Then** matching products are suggested by name, code, model, SKU, or brand.
2. **Given** the suggestion list, **When** it renders, **Then** each row shows the product's photo thumbnail alongside identifying text (name, code, model, SKU).
3. **Given** the suggestion list, **When** the user selects a product, **Then** that single product fills the field and the field cannot hold more than one product at a time.
4. **Given** a selected product in a field, **When** the user clears it, **Then** the field returns to empty and can be searched again.
5. **Given** a search term that matches nothing, **When** results return, **Then** the picker communicates that no products were found rather than appearing broken.

---

### User Story 3 - Be protected from an irreversible mistake (Priority: P2)

Merging permanently deletes the duplicate; there is no undo. The administrator wants the tool to stop obvious mistakes before any data is touched (no product chosen, or the same product picked on both sides), to require an explicit confirmation that makes the permanence clear, and — if the server rejects the merge — to show why without throwing away the selections they carefully made.

**Why this priority**: The operation is destructive and irreversible, so guardrails are as important as the merge itself for trust and safety. It is P2 rather than P1 only because it protects the P1 action rather than delivering it.

**Independent Test**: Attempt to merge with a missing selection and with the same product on both sides (blocked with a clear message, nothing submitted); then force a server-side rejection and confirm the error is shown and both selections remain intact.

**Acceptance Scenarios**:

1. **Given** either "Product" or "Duplicate" is empty, **When** the user attempts to merge, **Then** the merge is not submitted and the user is told both products are required.
2. **Given** the same product is selected in both fields, **When** the user attempts to merge, **Then** the merge is not submitted and the user is told a product cannot be merged with itself.
3. **Given** valid, distinct selections, **When** the user activates "Merge", **Then** a confirmation step appears that clearly states the duplicate will be permanently and irreversibly deleted before anything is submitted.
4. **Given** the confirmation step, **When** the user cancels it, **Then** no merge is performed and both selections remain unchanged.
5. **Given** a confirmed merge, **When** the server rejects it (e.g., the product or duplicate no longer exists, or a referential/other failure occurs), **Then** an error message is shown, no partial change is reflected in the UI, and both selected products remain in their fields so the user can retry or adjust.

---

### User Story 4 - Only authorized users can reach the tool (Priority: P3)

Merging is a powerful, destructive administrative capability. The organization wants it hidden and inaccessible to users who lack the merge privilege, and available to those who have it, consistent with how every other mutating catalog action is gated.

**Why this priority**: Access control is essential but inherits the platform's existing deny-by-default RBAC pattern, so it is lower-risk to deliver than the novel merge flow. It is P3 because the feature is not shippable-to-everyone without it, but it is a well-trodden pattern rather than new behavior.

**Independent Test**: As a user with the merge privilege, confirm the entry point is visible and the screen is reachable; as a user without it, confirm the entry point is hidden and direct navigation to the screen is refused.

**Acceptance Scenarios**:

1. **Given** a user who holds the merge privilege, **When** they are in the products area, **Then** an entry point to the Merge Products screen is available and the screen loads.
2. **Given** a user who lacks the merge privilege, **When** they are in the products area, **Then** the entry point is not shown.
3. **Given** a user who lacks the merge privilege, **When** they navigate directly to the merge screen's location, **Then** access is refused (deny-by-default) rather than the screen rendering.

---

### Edge Cases

- **Same product on both sides**: prevented in the UI (US3 #2) and also rejected by the server with "Cannot merge a product with itself"; both guards must agree.
- **Duplicate or canonical deleted between selection and submit**: the server returns not-found; surface the error and keep the user on the screen with selections intact (US3 #5).
- **Merge fails midway / referential failure on the server**: no partial state is shown as success; the operation is reported as failed and the catalog is left as the server left it.
- **Very large reference sets**: a product with many transactional references may take longer to merge; the UI must remain responsive and show progress rather than appear frozen or allow a double-submit (US1 #4).
- **Deactivated/soft-deleted products**: both pickers can still surface them (per Clarifications) so a duplicate in any state can be cleaned up.
- **Search term shorter than the minimum**: below the minimum length the picker does not fire a search (see Assumptions), avoiding overly broad result sets.
- **Network interruption during merge**: treated as a failure per US3 #5 — error shown, selections preserved, no false success.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST provide a dedicated Merge Products screen that lets an authorized user select two products — a canonical "Product" (kept) and a "Duplicate" (folded in and removed) — and initiate a merge.
- **FR-002**: Each of the two product fields MUST be a single-select search-as-you-type picker that queries the full product catalog by name, code, model, SKU, or brand.
- **FR-003**: Each picker suggestion MUST display the product's photo thumbnail together with identifying text (name, code, model, SKU) so the operator can visually confirm the record.
- **FR-004**: Each picker MUST allow at most one product to be selected at a time and MUST allow that selection to be cleared and re-searched.
- **FR-005**: The system MUST prevent submitting a merge unless both "Product" and "Duplicate" are selected, informing the user that both are required.
- **FR-006**: The system MUST prevent submitting a merge when the same product is selected in both fields, informing the user that a product cannot be merged with itself.
- **FR-007**: Before performing the merge, the system MUST require an explicit confirmation that clearly communicates the action is permanent and irreversible (the duplicate will be deleted).
- **FR-008**: On confirmation, the system MUST submit the merge of the selected duplicate into the selected canonical product to the backend merge operation, which remaps the duplicate's transactional references (sales/purchase order details, inventory receipt/issue/transfer details, lot-serial tracking, and related tables) and labels onto the canonical product and then permanently deletes the duplicate.
- **FR-009**: While a merge is in flight, the system MUST prevent duplicate submission (e.g., disable the action / show progress) until the operation completes or fails.
- **FR-010**: On a successful merge, the system MUST confirm success to the user and return them to the products list; the merge screen MUST NOT remain open with the just-merged selections still populated.
- **FR-011**: On a failed merge (including self-merge rejection, product-or-duplicate-not-found, and referential/other server errors), the system MUST surface a clear error message, MUST NOT present any partial change as success, and MUST preserve both selected products so the user can retry or adjust.
- **FR-012**: The Merge Products screen and its entry point MUST be gated by the merge privilege (`productsMerge`) requiring create-level access, denied by default; the entry point MUST be hidden and direct access refused for users without it.
- **FR-013**: The screen MUST provide a way to leave/return to the products list without merging (a back affordance), consistent with other catalog screens.
- **FR-014**: All user-facing text MUST be localized (es-MX default and en) with no hardcoded strings, matching the existing catalog screens.

### Key Entities *(include if feature involves data)*

- **Product (canonical / "Product")**: The record that is kept. After a merge it owns all of its own prior references plus those transferred from the duplicate. Identified to the operator by photo, name, code, model, SKU, and brand.
- **Duplicate ("Duplicated")**: The redundant record selected to be folded into the canonical product. Its transactional references and labels are remapped to the canonical product; its price rows and label rows are removed; the record itself is permanently deleted. Must be a different product than the canonical.
- **Merge request**: The pairing of a canonical product and a duplicate product submitted as a single destructive operation; valid only when both are present and distinct.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: An authorized user can complete a full merge — locate both products, confirm, and finish — in under 60 seconds for products they can name.
- **SC-002**: 100% of successful merges leave the canonical product present and the duplicate absent from the catalog, with zero loss of the duplicate's prior transactional history (all references resolve to the canonical product).
- **SC-003**: 0% of merges proceed without an explicit permanence confirmation, and 0% proceed with a missing selection or with the same product on both sides.
- **SC-004**: 100% of server-rejected merges show the user a clear reason and preserve both selections, with no false "success" and no partial change presented as complete.
- **SC-005**: Users without the merge privilege have no visible entry point to the feature and cannot reach the screen by direct navigation (0% unauthorized access).
- **SC-006**: When identifying a product by a partial term, the correct record appears in the picker suggestions in the large majority of attempts, letting the operator pick it without resorting to the internal id.

## Assumptions

- **Backend and client already exist**: mbe-api's merge operation (`POST /api/v1/products/merge`, gated by the merge privilege with create-level access, returning no content on success) is implemented, and the generated API client already exposes it and its request shape. No API contract change or client regeneration is required — this feature is the missing UI surface only.
- **Reuse of existing building blocks**: the search-as-you-type picker reuses the shared catalog entity picker and the existing product search/list data path; the screen follows the feature-first layered architecture, Material 3 design system, deny-by-default RBAC, and online-only conventions already established for catalog features.
- **Minimum search length**: the picker requires a minimum typed length before searching and caps the number of suggestions (the legacy screen used a 3-character minimum and ~15 results); these thresholds are adopted as reasonable defaults unless product feedback dictates otherwise.
- **Full-catalog search for both pickers**: both pickers search all products regardless of active/deactivated state, matching the legacy merge suggestion behavior (per Clarifications), which differs intentionally from the general product search that hides disabled products.
- **Merge direction is explicit**: the operator chooses which record is canonical and which is the duplicate; the system does not auto-decide which to keep.
- **Irreversibility is accepted**: there is no in-product undo for a merge; the confirmation step is the safeguard, consistent with the destructive nature of the backend operation.
- **Entry point placement**: an entry point reachable from the products area is sufficient; the exact placement (products list action vs. navigation menu) is a design/planning detail and does not change the feature's scope.
