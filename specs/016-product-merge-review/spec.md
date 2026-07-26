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

Before committing, the administrator wants to know how much history is riding on the product about to be deleted — how many order lines, inventory movements, price list entries, and similar records are attached to it — so a merge that looks trivial (two similarly named low-activity products) can be told apart from one carrying a large transactional history.

**Why this priority**: It adds valuable context but is not required to prevent the core mistake (wrong record kept/deleted) that Stories 1–2 already address, so it can ship after them. It is no longer blocked: the backing capability now exists (see Assumptions).

**Independent Test**: For a selected pair, confirm the review step shows a per-category breakdown of records attached to the product marked for deletion, plus a total, and that the wording distinguishes records that move to the kept product from records that are destroyed outright. With the breakdown unavailable (e.g., the lookup fails), confirm the review step still functions correctly (Stories 1–4 unaffected) and shows no fabricated or zero-by-default counts.

**Acceptance Scenarios**:

1. **Given** a valid, distinct pair is selected, **When** the review step renders, **Then** it shows each category of record attached to the product marked for deletion with its count, plus a total.
2. **Given** the breakdown is shown, **When** the operator reads it, **Then** it is clear that most categories move to the kept product but the deleted product's own price-list rows are destroyed rather than moved — the summary MUST NOT describe every counted record as "reassigned".
3. **Given** a category the interface has no friendly name for (the set of record types grows as the system adds new relationships), **When** the summary renders, **Then** that category is still shown with its count under a readable fallback label rather than being dropped from the list or breaking the total.
4. **Given** the breakdown lookup fails or is still loading, **When** the review step renders, **Then** the summary section is omitted (or shown as loading) rather than showing misleading placeholder or zero values, and the merge is **not** blocked — this summary is informational context, unlike the identity data in Stories 1–2.

---

### Edge Cases

- **Selection changes while the review step is open**: the review step MUST recompute from the current selections (Story 1 #3); it must never show a comparison for a product no longer selected.
- **Swap immediately followed by confirm**: the acknowledgment gate MUST be tied to the current deleted product, not the one deleted at the time the checkbox was first checked (Story 4 #3).
- **Full product record fails to load for the review step** (e.g., transient network error after the picker's lightweight suggestion succeeded): the review step MUST surface a clear error and MUST NOT proceed to a comparison built on incomplete or stale data; the operator can retry.
- **Related-record counts fail to load**: degrade gracefully per Story 5 #4 — omit the summary, do not block the merge or misrepresent the rest of the review. This is informational context, not identity data.
- **An unrecognized record category comes back in the breakdown**: shown with a readable fallback label per Story 5 #3, never dropped silently — the set of categories is derived from the system's own relationships and grows over time without the interface being updated.
- **Very long product names/codes**: panel and table layouts MUST remain legible (wrapping or truncation with full text available) rather than overflowing or clipping the kept/deleted labels themselves.
- **No differences at all between the two products**: the comparison table MUST still render all rows (unflagged), so the operator can confirm the products are indeed near-identical duplicates rather than seeing an empty or confusing table.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Once both the "Product" (canonical) and "Duplicate" pickers hold a valid, distinct selection, the system MUST present a review step before the final destructive confirmation, replacing the current flow where a generic confirmation dialog is the only checkpoint.
- **FR-002**: The review step MUST display the canonical product in a panel unambiguously labeled as kept and the duplicate in a panel unambiguously labeled as deleted, using both a text label and a distinct visual treatment for each (not color alone), with the deleted product's name shown as struck through.
- **FR-003**: Each panel MUST show its product's photo, internal id, name, code, SKU, model, status, unit of measure, and tax rate, sourced from the full product record rather than the abbreviated list/suggestion projection used by the pickers.
- **FR-004**: The review step MUST provide a control that swaps which of the two selected products is treated as kept and which is deleted, updating the panels, the comparison table, and any acknowledgment state consistently (Edge Cases).
- **FR-005**: The review step MUST present a field-by-field comparison of the kept and deleted product covering, at minimum, internal id, code, SKU, model, brand, unit of measure, tax rate, and status, with rows whose values differ between the two visually flagged as differing.
- **FR-006**: The review step MUST display, by category with a total, the count of records attached to the product marked for deletion, obtained from the system's merge-preview capability rather than estimated client-side. The summary MUST distinguish records that move to the kept product from the deleted product's own price-list rows, which are destroyed rather than moved (Story 5 #2). Categories the interface has no friendly name for MUST still appear with a readable fallback label (Story 5 #3). If the lookup fails or is pending, the summary MUST be omitted or shown as loading rather than rendered with fabricated or zero-by-default values, and MUST NOT block the merge (Story 5 #4).
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
- **Related-record category**: A class of data that references the product marked for deletion (order lines, inventory movement lines, lot/serial tracking, price list entries, labels, fiscal document lines, and any other relationship the system knows about), shown with a count. Most categories move to the kept product during the merge; the deleted product's own price-list rows are destroyed instead. The set of categories is not fixed — it is derived from the system's own relationships and grows as new ones are added, so the interface must tolerate categories it has no friendly name for.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of review steps clearly and redundantly (label plus visual treatment) identify which of the two shown products is kept and which is deleted, verified by usability review with no reliance on color alone.
- **SC-002**: 100% of destructive merge submissions are preceded by an explicit acknowledgment naming the specific product being deleted at the time of submission (never a stale acknowledgment from a since-swapped role).
- **SC-003**: 100% of comparison tables correctly flag every field whose value differs between the two products, and flag no field whose value matches.
- **SC-004**: An authorized user can move from two valid picker selections through the review step to a submitted merge in under 90 seconds for products they can visually identify from the panel data alone (no need to consult the original catalog list to verify identity).
- **SC-005**: 0% of merges submit when the full product data needed for the review step failed to load.
- **SC-006**: 100% of related-record categories returned by the merge-preview lookup are shown to the operator with their count — none silently dropped for lacking a friendly name — and the displayed total always equals the sum of the categories shown.

## Assumptions

- **Builds on spec 008, does not replace it**: this feature adds a review/comparison step between the existing pickers and the existing final confirmation described in `specs/008-merge-products`; all of 008's functional requirements, guardrails, and RBAC gating remain in force (FR-014).
- **Full product data is fetchable for the review step now**: the system already exposes a way to retrieve the complete product record (photo, code, SKU, model, brand, unit of measure detail, tax rate, status, and more) for a given product id — richer than the abbreviated data used by the picker's search suggestions — and the review step is expected to use that fuller record for both the kept and deleted product rather than reusing picker suggestion data.
- **Related-record counts are available now (FR-006, Story 5) — dependency resolved**: this requirement originally had no backing capability and was written to degrade gracefully until one existed. That capability has since shipped: the system can now report, for a given pair, every category of record attached to the product marked for deletion together with its count and a total, without modifying anything. Story 5 is therefore in scope for this feature rather than deferred. Two properties of that capability shape the requirements above: the category list is derived from the system's own relationships (so it grows on its own, and unfamiliar categories must still render — Story 5 #3), and it counts every attached record including the price-list rows a merge destroys rather than moves (so the summary must not describe all of them as "reassigned" — Story 5 #2).
- **Merge moves every reference**: a related correction shipped alongside the counting capability — the merge previously left some record types pointing at the deleted product, and now moves every relationship the system knows about. The summary and the merge therefore describe the same set of records, so a count shown in the review step is not an underestimate of what the merge will touch.
- **Reference design as guidance, not pixel spec**: the "Fusión de productos" reference design (color-coded kept/deleted panels, swap control, comparison table, related-records summary, acknowledgment checkbox, restated confirmation) informs the shape of this feature's requirements; exact visual styling follows this project's existing design system rather than reproducing the reference mockup's specific colors/typography verbatim.
- **No new entry point**: this feature changes what happens between the existing pickers and the existing final confirmation on the existing Merge Products screen; it does not add a new navigation entry point or change who can reach the screen (still gated exactly as in spec 008).
- **Desktop and compact layouts both in scope**: consistent with the reference design and this project's existing responsive conventions, the review step must work at both narrow (mobile-width) and wide (desktop-width) breakpoints, not desktop-only.
