# Feature Specification: Merge Products — Explicit Kept/Deleted Review

**Feature Branch**: `016-product-merge-review`

**Created**: 2026-07-25

**Status**: Draft

**Input**: User description: "Enhance the existing Merge Products feature (specs/008-merge-products) so the merge decision is explicit and safe. Today, once both the canonical 'Product' and the 'Duplicate' are picked, the screen shows only a generic confirmation dialog with a boilerplate irreversibility warning — no side-by-side product data is shown, so the operator must trust their memory of two typeahead selections before permanently deleting one of them. Add a review/comparison step, based on a reference design ('Fusión de productos'), that makes unmistakably explicit which product survives and which is destroyed, and surfaces enough data on both to prevent a wrong decision: color/label-coded kept vs. deleted panels, a swap control, a field-by-field comparison table with differences flagged, a related-records-to-be-reassigned summary, an acknowledgment checkbox, and a restated final confirmation. All existing 008 guardrails remain in force; this is additive UX."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - See exactly which product survives and which is destroyed (Priority: P1)

An administrator has selected a canonical "Product" and a "Duplicate" in the merge pickers (spec 008). Before anything is submitted, they want an unmistakable, side-by-side view of both records — not just two names in two text fields — so they can visually confirm, using the product's photo and identifying details, that they have the right record marked to survive and the right record marked for deletion.

**Why this priority**: This is the reason the enhancement exists. Today's flow lets an operator confirm a merge based only on the text they typed into two search fields; the entire risk this feature addresses — merging the wrong product, or keeping the wrong one — is closed by this story alone.

**Independent Test**: With a canonical and a duplicate selected, open the review step and confirm it renders two clearly, redundantly labeled panels (label text, not color alone) — one marked as kept, one marked as deleted — each showing the corresponding product's photo, name, code, SKU, and model, before any confirmation dialog appears.

**Acceptance Scenarios**:

1. **Given** a valid canonical selection and a valid, distinct duplicate selection, **When** the operator proceeds past the pickers, **Then** a review step appears showing a "kept" panel and a "deleted" panel, each carrying its product's photo, name, code, SKU, and model, and each panel is distinguishable by both a text label and a visual treatment (not color alone).
2. **Given** the review step, **When** it renders the "deleted" panel, **Then** that product's name is visually marked as being removed (e.g., struck through) so it cannot be mistaken for the surviving record.
3. **Given** the review step is showing, **When** the operator changes either selection back on the picker step, **Then** the review step reflects the updated selections rather than showing stale data.

---

### User Story 2 - Compare both products' data field by field before committing (Priority: P1)

Two products that look similar by name may differ in ways that matter — status, unit of measure, tax rate, brand. The administrator wants a field-by-field comparison of the kept and deleted records, with differing fields called out, so a meaningful discrepancy (e.g., the "duplicate" is actually active and stocked while the "canonical" is not) is caught before the irreversible delete happens rather than discovered afterward.

**Why this priority**: Alongside Story 1, this directly prevents the costly mistake the feature is meant to guard against — merging records that are not, in fact, safe duplicates — so it ships in the same increment as the kept/deleted panels.

**Independent Test**: Select two products with at least one differing attribute (e.g., different status or unit of measure) and confirm the comparison table shows both values side by side with the differing row visually flagged, and shows matching rows without a flag.

**Acceptance Scenarios**:

1. **Given** the review step, **When** it renders the comparison table, **Then** it lists, at minimum, internal id, code, SKU, model, brand, unit of measure, tax rate, and status for both the kept and deleted product, sourced from each product's full record rather than the abbreviated picker suggestion data.
2. **Given** a field whose value differs between the two products, **When** the table renders that row, **Then** the row is visually flagged as differing.
3. **Given** a field whose value is identical between the two products, **When** the table renders that row, **Then** the row is not flagged as differing.
4. **Given** the comparison table, **When** the operator views it on a narrow (mobile-width) screen, **Then** the same information remains legible and correctly attributed to kept vs. deleted without requiring horizontal scrolling to identify which column is which.

---

### User Story 3 - Correct a backwards pick without starting over (Priority: P2)

Having selected two products, the administrator realizes they put the record they meant to keep into the "Duplicate" field and vice versa. They want to flip which selected product is treated as kept and which is deleted without re-searching and re-selecting both records from scratch.

**Why this priority**: It meaningfully reduces friction and the temptation to abandon a careful review just to fix a mislabeled pick, but the review/comparison itself (Stories 1–2) delivers the safety value even without this convenience.

**Independent Test**: From the review step, activate the swap control and confirm the kept and deleted panels, the comparison table, and the underlying picker selections all exchange roles consistently, with no data left mismatched between panel and table.

**Acceptance Scenarios**:

1. **Given** the review step with a kept and a deleted product shown, **When** the operator activates the swap control, **Then** the product previously shown as deleted is now shown as kept (and vice versa) across the panels and the comparison table.
2. **Given** a swap has occurred, **When** the operator proceeds to the final confirmation, **Then** the confirmation reflects the swapped roles, not the original ones.

---

### User Story 4 - Be required to explicitly acknowledge what will be destroyed (Priority: P2)

Beyond seeing the comparison, the administrator must take a deliberate, explicit action confirming they understand a specific, named record will be permanently deleted, before the destructive control can even be activated — and the final confirmation dialog must restate exactly which two records are involved so there is no ambiguity in the last moment before submission.

**Why this priority**: This raises the bar from "the information was on screen" to "the operator affirmatively confirmed it," closing the gap where a rushed operator might scroll past the comparison without registering it. It builds on Stories 1–3 rather than standing alone.

**Independent Test**: Reach the review step and confirm the destructive submit control is disabled until an acknowledgment referencing the specific product to be deleted is checked; then confirm the final confirmation dialog names both the kept and deleted product by name and code before submission fires.

**Acceptance Scenarios**:

1. **Given** the review step, **When** it first renders, **Then** the destructive "merge" control is disabled until the operator checks an acknowledgment that names the specific product to be deleted.
2. **Given** the acknowledgment is checked, **When** the operator activates the merge control, **Then** a final confirmation dialog appears restating both the kept and deleted product by name and code.
3. **Given** the operator swaps kept/deleted (Story 3) after having checked the acknowledgment, **When** the roles change, **Then** the acknowledgment is reset and must be re-confirmed against the new deleted product, so a stale acknowledgment can never apply to a different record than the one actually named.
4. **Given** the final confirmation dialog, **When** the operator cancels it, **Then** no merge is submitted and the review step remains as it was, selections intact.

---

### User Story 5 - Understand the blast radius before merging (Priority: P3)

Before committing, the administrator wants to know, in broad terms, how much history is riding on the product about to be deleted — how many inventory movements, order lines, price list entries, and similar records will be reassigned to the surviving product — so a merge that looks trivial (two similarly named low-activity products) can be told apart from one carrying a large transactional history.

**Why this priority**: It adds valuable context but is not required to prevent the core mistake (wrong record kept/deleted) that Stories 1–2 already address, and it depends on data the system may not yet be able to compute for every category (see Assumptions). It ships when that data is available and degrades gracefully otherwise.

**Independent Test**: With related-record counts available for a selected pair, confirm the review step shows a per-category breakdown (e.g., inventory movements, purchase lines, sales lines, price lists, labels/barcodes) plus a total, all attributed to reassignment onto the kept product. With counts unavailable, confirm the review step still functions correctly (Stories 1–4 unaffected) and does not display fabricated or zero-by-default counts.

**Acceptance Scenarios**:

1. **Given** related-record counts can be determined for the deleted product, **When** the review step renders, **Then** it shows each category with its count and a total, clearly framed as records that will be reassigned to the kept product.
2. **Given** related-record counts cannot be determined, **When** the review step renders, **Then** the summary section is omitted entirely rather than showing misleading placeholder or zero values, and the rest of the review step (panels, comparison, acknowledgment, confirmation) is unaffected.

---

### Edge Cases

- **Selection changes while the review step is open**: the review step MUST recompute from the current selections (Story 1 #3); it must never show a comparison for a product no longer selected.
- **Swap immediately followed by confirm**: the acknowledgment gate MUST be tied to the current deleted product, not the one deleted at the time the checkbox was first checked (Story 4 #3).
- **Full product record fails to load for the review step** (e.g., transient network error after the picker's lightweight suggestion succeeded): the review step MUST surface a clear error and MUST NOT proceed to a comparison built on incomplete or stale data; the operator can retry.
- **Related-record counts unavailable or fail to load**: degrade gracefully per Story 5 #2 — omit the summary, do not block or misrepresent the rest of the review.
- **Very long product names/codes**: panel and table layouts MUST remain legible (wrapping or truncation with full text available) rather than overflowing or clipping the kept/deleted labels themselves.
- **No differences at all between the two products**: the comparison table MUST still render all rows (unflagged), so the operator can confirm the products are indeed near-identical duplicates rather than seeing an empty or confusing table.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Once both the "Product" (canonical) and "Duplicate" pickers hold a valid, distinct selection, the system MUST present a review step before the final destructive confirmation, replacing the current flow where a generic confirmation dialog is the only checkpoint.
- **FR-002**: The review step MUST display the canonical product in a panel unambiguously labeled as kept and the duplicate in a panel unambiguously labeled as deleted, using both a text label and a distinct visual treatment for each (not color alone), with the deleted product's name shown as struck through.
- **FR-003**: Each panel MUST show its product's photo, internal id, name, code, SKU, model, status, unit of measure, and tax rate, sourced from the full product record rather than the abbreviated list/suggestion projection used by the pickers.
- **FR-004**: The review step MUST provide a control that swaps which of the two selected products is treated as kept and which is deleted, updating the panels, the comparison table, and any acknowledgment state consistently (Edge Cases).
- **FR-005**: The review step MUST present a field-by-field comparison of the kept and deleted product covering, at minimum, internal id, code, SKU, model, brand, unit of measure, tax rate, and status, with rows whose values differ between the two visually flagged as differing.
- **FR-006**: When the system can determine counts of records that will be reassigned from the deleted product to the kept product (e.g., inventory movements, purchase order lines, sales order lines, price lists, labels/barcodes), the review step MUST display those counts by category plus a total; when such counts cannot be determined, the system MUST omit this summary rather than display misleading or zero-by-default values.
- **FR-007**: The review step's destructive submit control MUST remain disabled until the operator checks an explicit acknowledgment that names the specific product currently marked for deletion.
- **FR-008**: Swapping kept/deleted (FR-004) after the acknowledgment has been checked MUST reset the acknowledgment, requiring it to be re-confirmed against the product now marked for deletion.
- **FR-009**: On activating the (now-enabled) merge control, the system MUST show a final confirmation dialog restating both the kept and deleted product by name and code, and, when available, the total related-record count, before the merge is submitted.
- **FR-010**: If either underlying selection is changed or cleared while the review step is open, the review step MUST update to reflect the current selections and MUST NOT submit a merge based on stale data.
- **FR-011**: If the full product record needed for the review step fails to load, the system MUST show a clear error and MUST NOT allow the operator to proceed to the final confirmation until it loads successfully.
- **FR-012**: The review step MUST be usable in both narrow/compact and wide/desktop layouts, with kept-vs-deleted attribution remaining unambiguous at all supported widths (Story 2 #4).
- **FR-013**: All new user-facing text introduced by the review step MUST be localized (es-MX default and en) with no hardcoded strings, matching the existing catalog screens.
- **FR-014**: All guardrails established by the existing merge feature (both selections required, self-merge rejected, in-flight submit disabled to prevent double submission, RBAC gate via the merge privilege with create-level access, errors preserving both selections) MUST continue to hold unchanged; this feature adds a review step ahead of the existing confirmation and does not alter or bypass those guardrails.

### Key Entities *(include if feature involves data)*

- **Merge review**: The transient, on-screen comparison of a canonical and a duplicate product formed once both are validly selected; tracks which of the two is currently in the kept vs. deleted role (swappable) and whether the deletion has been acknowledged for the current role assignment.
- **Product comparison field**: One attribute (id, code, SKU, model, brand, unit of measure, tax rate, status, etc.) shown side by side for the kept and deleted product, flagged when the two values differ.
- **Related-record category**: A class of data (e.g., inventory movement, purchase order line, sales order line, price list entry, label/barcode) that references the deleted product and will be reassigned to the kept product as part of the merge; shown with a count when the system can determine it.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of review steps clearly and redundantly (label plus visual treatment) identify which of the two shown products is kept and which is deleted, verified by usability review with no reliance on color alone.
- **SC-002**: 100% of destructive merge submissions are preceded by an explicit acknowledgment naming the specific product being deleted at the time of submission (never a stale acknowledgment from a since-swapped role).
- **SC-003**: 100% of comparison tables correctly flag every field whose value differs between the two products, and flag no field whose value matches.
- **SC-004**: An authorized user can move from two valid picker selections through the review step to a submitted merge in under 90 seconds for products they can visually identify from the panel data alone (no need to consult the original catalog list to verify identity).
- **SC-005**: 0% of merges submit when the full product data needed for the review step failed to load.

## Assumptions

- **Builds on spec 008, does not replace it**: this feature adds a review/comparison step between the existing pickers and the existing final confirmation described in `specs/008-merge-products`; all of 008's functional requirements, guardrails, and RBAC gating remain in force (FR-014).
- **Full product data is fetchable for the review step now**: the system already exposes a way to retrieve the complete product record (photo, code, SKU, model, brand, unit of measure detail, tax rate, status, and more) for a given product id — richer than the abbreviated data used by the picker's search suggestions — and the review step is expected to use that fuller record for both the kept and deleted product rather than reusing picker suggestion data.
- **Related-record counts are an open dependency (FR-006, Story 5)**: nothing in the system today can report, for a given product, how many inventory movements, purchase/sales order lines, price list entries, or labels reference it. Story 5 and FR-006 are written to degrade gracefully (omit the summary) until such a capability exists; delivering it is expected to require a new capability from the system's backend, to be requested and tracked as a dependency the way a prior data gap in the base merge feature was (an external, trackable request rather than something worked around in this feature's scope).
- **Reference design as guidance, not pixel spec**: the "Fusión de productos" reference design (color-coded kept/deleted panels, swap control, comparison table, related-records summary, acknowledgment checkbox, restated confirmation) informs the shape of this feature's requirements; exact visual styling follows this project's existing design system rather than reproducing the reference mockup's specific colors/typography verbatim.
- **No new entry point**: this feature changes what happens between the existing pickers and the existing final confirmation on the existing Merge Products screen; it does not add a new navigation entry point or change who can reach the screen (still gated exactly as in spec 008).
- **Desktop and compact layouts both in scope**: consistent with the reference design and this project's existing responsive conventions, the review step must work at both narrow (mobile-width) and wide (desktop-width) breakpoints, not desktop-only.
