# Feature Specification: Price List Retirement UI

**Feature Branch**: `034-price-list-retirement-ui`

**Created**: 2026-08-30

**Status**: Draft

**Input**: User description: "Let's create a spec to introduce improvements for price list delete action, taking artifacts/price_list_delete/price-list-delete-review.html as base for ui changes. Also consider updated api."

## Overview

Deleting a price list is the one catalog deletion an operator currently cannot reason about. The
confirmation says only "Delete price list *Retail 2026*?" and offers a Delete button; behind it sits
an irreversible operation that may destroy thousands of product prices and move every customer on a
commercial tier to another one. Until now the operation was also impossible in practice — anything
pointing at a list refused the deletion — so the thin dialog was never really exercised.

mbe-api's price list retirement (mbe-api spec `015-price-list-retirement`, GitHub issue #181,
merged as PR #186) changes both halves. The list's own prices are now deleted with it rather than
reported as records to clear one at a time, and the deletion accepts a *replacement* list onto which
every assigned customer is moved atomically. It also publishes a read-only report of what rides on
the list, so the scale can be shown before the operator commits.

This feature spends that capability on the operator's side: the confirmation becomes a review. It
tells them what the deletion touches, distinguishes what is destroyed from what is moved, requires
them to name where the customers go, requires them to acknowledge the destruction explicitly, and
refuses in the dialog — before any request is sent — when something the deletion cannot handle
still points at the list.

The shape follows `016-product-merge-review`, the app's existing precedent for reviewing an
irreversible catalog operation: the same read-only breakdown of counts by category, the same
"this row is destroyed, not moved" distinction, the same explicit acknowledgment before the
destructive button becomes available, and the same treatment of a failed preview as an
informational note rather than a blocker.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Seeing what a deletion destroys before committing (Priority: P1)

An operator opens a price list for editing and presses Delete. Instead of a bare "are you sure",
they are shown each kind of record attached to the list with its count, largest first, with a total
— and, per row, whether that record is destroyed with the list or moved elsewhere. The destructive
button names the number it is about to destroy.

**Why this priority**: This is the feature's subject. The deletion is irreversible and can destroy
thousands of prices; today's dialog gives the operator nothing at all on which to base the decision.
Every other story in this spec is a refinement of what this review shows or demands. Shipped alone
it is already a complete improvement: an operator can delete an unassigned list knowing exactly what
goes with it.

**Independent Test**: Open a price list carrying prices for many products and assigned to no
customer, press Delete, and confirm the dialog names the price count, labels those prices as
destroyed, shows the total, and carries that same count on its confirm button — then confirm the
deletion succeeds and the prices are gone.

**Acceptance Scenarios**:

1. **Given** a price list carrying prices for products, **When** the operator presses Delete, **Then** the dialog lists each attached record category with its count, in the order the server reported them, together with a total.
2. **Given** that breakdown, **When** it renders, **Then** the product-prices row is marked as destroyed by the deletion, and the customers row is marked as moved to the replacement, so the two are never read as the same fate.
3. **Given** that breakdown, **When** it renders, **Then** the total is captioned as records the deletion *touches*, not as records it deletes.
4. **Given** the breakdown resolved, **When** the operator reads the confirm button, **Then** it names what the deletion destroys or moves rather than reading only "Delete".
5. **Given** a category the app has no label for (a relationship added to the data model after this feature ships), **When** the breakdown renders, **Then** it is shown with a readable fallback label and its count rather than being omitted.
6. **Given** the operator presses Cancel or dismisses the dialog, **When** it closes, **Then** nothing was requested of the server beyond the read-only report, and the list is untouched.

---

### User Story 2 - Naming where the list's customers go (Priority: P1)

An operator retiring a list that customers sit on names the price list those customers move to. The
deletion will not proceed until they have. Once named, the dialog says how many customers move and
where.

**Why this priority**: The other half of the same operation, and the same priority. Every customer
must be on some price list, so a list that customers sit on cannot be retired without saying where
they go — and the app cannot choose for them. Without this, exactly the lists that are in real use
remain undeletable, which is the condition this feature exists to end.

**Independent Test**: Assign customers to a list, press Delete, confirm the destructive button is
unavailable until a replacement is picked, pick one, confirm the dialog states how many customers
move and to which list, delete, and confirm every one of those customers now reads as being on the
named list.

**Acceptance Scenarios**:

1. **Given** a list with customers assigned, **When** the dialog opens, **Then** a replacement price list picker is shown as required, and the destructive button is unavailable until a replacement is chosen.
2. **Given** the replacement picker, **When** the operator searches it, **Then** the list being deleted is never offered as its own replacement.
3. **Given** a replacement has been chosen, **When** the dialog re-renders, **Then** it states how many customers move and names the chosen list.
4. **Given** a replacement has been chosen, **When** the operator confirms, **Then** the deletion is sent with that replacement, and on success the list is gone and its customers are on the replacement.
5. **Given** a list with no customers assigned, **When** the dialog opens, **Then** no replacement picker is shown and the destructive button is available once the deletion is acknowledged.
6. **Given** the customers row in the breakdown, **When** the operator wants to know *which* customers move, **Then** the row offers a way to open the customers list filtered to this price list.

---

### User Story 3 - Acknowledging an irreversible destruction (Priority: P2)

Before the destructive button becomes available, the operator explicitly acknowledges that the
deletion cannot be undone and that the prices are destroyed with the list.

**Why this priority**: It prevents no failure the server would not also prevent, and it changes no
data — it slows the operator down at exactly the moment being slowed down is the point. It ranks
below the two stories that make the operation possible and legible, but the app already demands this
acknowledgment before merging two products, and a deletion that destroys thousands of prices with no
undo is not the place to demand less.

**Independent Test**: Open the dialog for a list with prices or customers attached, confirm the
destructive button is unavailable while the acknowledgment is unticked, tick it, and confirm the
button becomes available.

**Acceptance Scenarios**:

1. **Given** a list with anything attached to it, **When** the dialog opens, **Then** an unticked acknowledgment is shown and the destructive button is unavailable.
2. **Given** the acknowledgment is ticked, **When** every other requirement is satisfied, **Then** the destructive button becomes available.
3. **Given** the acknowledgment is ticked and then unticked, **When** it is unticked, **Then** the destructive button becomes unavailable again.
4. **Given** a list nothing at all is attached to, **When** the dialog opens, **Then** no acknowledgment is demanded — there is nothing to destroy beyond the empty list itself — and the dialog states plainly that nothing depends on it.

---

### User Story 4 - Being told, before submitting, that the list cannot be retired (Priority: P2)

A list that something *other* than its prices and its customers still points at cannot be retired at
all. The operator learns this from the review itself, not from a rejected submission.

**Why this priority**: The information is already in the report the operator was shown, so letting
them fill in a replacement, acknowledge the destruction and press Delete only to be refused is a
failure the app chose to stage. It ranks below the stories that make the common case work because it
is the uncommon case — but it is the case where a rejected submission is most confusing, since
nothing the operator did was wrong.

**Independent Test**: Point a record other than a price or a customer at a price list, open the
delete dialog, and confirm the dialog names the blockage, keeps the destructive action unavailable,
and offers only a way out — without any deletion having been attempted.

**Acceptance Scenarios**:

1. **Given** the report names a category other than the list's prices and its customers, **When** the dialog opens, **Then** it states that the list cannot be deleted until those records are cleared, and the destructive action is unavailable.
2. **Given** that blocked state, **When** the breakdown renders, **Then** the blocking category is marked as blocking, distinctly from the destroyed and moved rows.
3. **Given** that blocked state, **When** the operator reads the dialog, **Then** the only action offered is to close it.
4. **Given** a list that becomes referenced between the report and the submission, **When** the server refuses the deletion, **Then** the refusal and the server's explanation are shown in the dialog, the dialog stays open, and the list is left in place.

---

### User Story 5 - Deleting when the report cannot be loaded (Priority: P3)

The report is an aid, not a gate. If it cannot be loaded, the operator is told so and can still
attempt the deletion.

**Why this priority**: A degraded path for a request that can fail independently of the deletion
itself. It matters because the alternative — refusing to open the dialog, or showing an empty
breakdown as though nothing were attached — either blocks a legitimate operation or actively
misleads.

**Independent Test**: Make the report request fail, open the dialog, and confirm it says the
dependencies could not be loaded, still allows the deletion to be attempted, and surfaces the
server's refusal if the deletion is then rejected.

**Acceptance Scenarios**:

1. **Given** the report request fails, **When** the dialog opens, **Then** it says the dependencies could not be loaded and that the deletion may be refused as a result, rather than showing an empty or zeroed breakdown.
2. **Given** that state, **When** the operator reads the dialog, **Then** a replacement may be named optionally, described as being used only if customers turn out to be assigned.
3. **Given** that state, **When** the operator confirms and the server refuses, **Then** the server's explanation is shown in the dialog and the list is left in place.
4. **Given** that state, **When** the dialog renders, **Then** the acknowledgment is still demanded before the destructive action becomes available — the report's absence is not evidence that there is nothing to acknowledge.

### Edge Cases

- A list with neither prices nor customers nor anything else attached shows a plain confirmation stating that nothing depends on it, with no breakdown, no replacement picker and no acknowledgment.
- A list with customers but no prices requires a replacement and an acknowledgment, and its confirm button names the customers moved rather than prices destroyed.
- While the report is loading, the dialog is open and the destructive action is unavailable — a delete cannot be confirmed against a review that has not arrived.
- While the deletion is in flight, both the confirm and cancel actions are unavailable, so a second submission cannot be started and the dialog cannot be dismissed mid-request.
- A replacement is named and the deletion then fails: the dialog stays open with the replacement still selected, so the operator can retry without re-entering it.
- The operator lacks delete permission on price lists: the Delete action is absent entirely, exactly as today — this feature changes what the action does, never who may see it.
- Counts can reach the tens of thousands; they are rendered so that magnitude is readable at a glance rather than as an undifferentiated run of digits.
- A category the app has no label for is shown with a readable fallback derived from its identifier, and — because it is neither the prices nor the customers — it blocks the deletion.

## Requirements *(mandatory)*

### Functional Requirements

#### The review

- **FR-001**: Pressing Delete on a price list MUST open a review dialog rather than a bare confirmation, and MUST request the deletion report for that list when it opens.
- **FR-002**: The dialog MUST show each category of record attached to the list with its count, in the order the server reported them, together with the server's own total — never a client-side re-sum.
- **FR-003**: The dialog MUST distinguish, per category, whether the deletion destroys those records, moves them to the replacement, or is blocked by them.
- **FR-004**: The total MUST be captioned as the records the deletion touches, not as records it deletes.
- **FR-005**: A category the app has no label for MUST be shown with a readable fallback label derived from its identifier and MUST NOT be omitted from the breakdown or the total.
- **FR-006**: The customers category row MUST offer navigation to the customers list filtered to the price list being deleted.
- **FR-007**: While the report is in flight, the dialog MUST be open, MUST indicate that it is loading, and MUST keep the destructive action unavailable.
- **FR-008**: A list with nothing attached to it MUST show a plain confirmation stating that no prices and no customers depend on it, with no breakdown, no replacement picker and no acknowledgment.

#### The replacement

- **FR-009**: When the report shows customers assigned to the list, the dialog MUST require a replacement price list before the deletion may be confirmed.
- **FR-010**: The replacement picker MUST search the price list catalog and MUST NOT offer the list being deleted.
- **FR-011**: Once a replacement is chosen, the dialog MUST state how many customers will move and to which list.
- **FR-012**: The deletion MUST be submitted with the chosen replacement, so the move and the deletion succeed or fail as one operation.
- **FR-013**: When no customers are assigned, no replacement picker MUST be shown and no replacement MUST be sent.

#### The acknowledgment and the commit

- **FR-014**: When anything at all is attached to the list, the dialog MUST require an explicit, initially-unticked acknowledgment that the deletion is irreversible and destroys the list's prices, before the destructive action becomes available. When the report could not be loaded, the acknowledgment MUST still be required: whether anything is attached is then unknown, and the safe reading of an unknown is that something is.
- **FR-015**: The destructive action's label MUST name what the deletion does — the number of prices destroyed, or the number of customers moved when there are no prices — rather than reading only "Delete".
- **FR-016**: While the deletion is in flight, the dialog MUST indicate progress and MUST make both confirming and cancelling unavailable.
- **FR-017**: On success, the dialog MUST close, the operator MUST be returned to the price lists list, that list MUST reflect the deletion, and a confirmation message MUST be shown naming the replacement and the number of customers moved when a replacement was used.

#### Refusals

- **FR-018**: When the report names any category other than the list's prices and its customers, the dialog MUST state that the list cannot be deleted until those records are cleared, MUST keep the destructive action unavailable, and MUST offer only to close — without attempting a deletion.
- **FR-019**: When the server refuses a submitted deletion, the dialog MUST stay open, MUST show the server's own explanation alongside a localized message, MUST preserve the chosen replacement, and MUST leave the price list in place.
- **FR-020**: When the report cannot be loaded, the dialog MUST say so, MUST still allow the deletion to be attempted, and MUST offer the replacement picker as optional, described as used only if customers turn out to be assigned.

#### Scope and access

- **FR-021**: The Delete action MUST remain gated by the operator's delete permission on price lists exactly as today, and MUST remain absent — never disabled — when that permission is missing.
- **FR-022**: The delete entry point MUST remain the price list edit screen only; no deletion action is added to the price lists list screen.
- **FR-023**: Every string introduced by this feature MUST be available in both application languages.

### Key Entities *(include if feature involves data)*

- **Price list**: The commercial tier being retired. Holds a price per product and is what customers are assigned to.
- **Deletion report**: A read-only breakdown, requested when the dialog opens, of every category of record attached to the list, each with a count, plus a server-computed total. Changes nothing by being asked for.
- **Report category**: One relationship to the price list, identified by a stable `table.column` key and a count. Three fates exist: destroyed with the list (its prices), moved to the replacement (its customers), or blocking (anything else, including relationships added after this feature ships).
- **Replacement price list**: The tier the retired list's customers are moved to. Named by the operator per deletion, never inferred, and never the list being deleted.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: An operator retires a price list holding prices for any number of products in a single confirmed action, with no preparatory work of any kind — where today the operation is refused outright.
- **SC-002**: An operator retires a list that customers sit on in a single confirmed action regardless of how many customers are assigned, replacing the per-customer reassignment they would otherwise perform by hand.
- **SC-003**: Before confirming, the operator can state from the dialog alone how many records the deletion destroys, how many it moves, and where the moved ones land.
- **SC-004**: No deletion can be submitted from a review that reports a blocking relationship, so an operator is never refused for a reason the app already knew.
- **SC-005**: The counts the operator is shown match, category for category, what the deletion then acts on.
- **SC-006**: A relationship to price lists added to the data model later appears in the breakdown, with a readable label and its count, and blocks the deletion — with no change to this feature.
- **SC-007**: Every refusal — blocked, rejected, or unreachable — leaves the price list in place and the operator on the dialog with the explanation and their input intact.

## Assumptions

- The deletion report and the replacement-carrying deletion are already available from mbe-api and already reachable from the app's generated API client; no backend change and no client regeneration is required by this feature. The report's `table.column` category keys, its largest-first ordering and its server-computed total are consumed as published.
- The list's prices are the only thing a retirement destroys. Every other relationship blocks it — now and for any relationship added later — so the app treats "not the prices, not the customers" as blocking rather than maintaining its own list of blockers.
- A replacement is named on the deletion itself rather than through a separate reassignment step, so the move and the deletion cannot come apart.
- **Deviation from the design canvas**: the artboards in `artifacts/price_list_delete/` deliberately omit an acknowledgment checkbox, arguing that the counted destructive button label is itself the acknowledgment. This spec adds the checkbox back (FR-014), matching `016-product-merge-review`, on the grounds that consistency in how the app gates its irreversible operations outweighs the one saved click. Everything else follows the artboards.
- The customers row links to the existing customers list filtered by price list; no new listing of the affected customers is built, since the report carries counts only and no endpoint enumerates them.
- Delete stays on the price list edit screen. Adding a row action on the list screen was considered and dropped: it would open the same dialog from a second place for no new capability, and no other catalog screen in the app deletes from its list.
- The breakdown panel is built for this feature rather than generalized out of the product merge screen's equivalent. The two look alike, but merge has no blocking fate and no replacement, and refactoring a shipped destructive flow to share layout code is risk this feature does not need to take. If a third such panel appears, that is the moment to unify all three.
- Counts are formatted with the operator's locale grouping and aligned so magnitudes compare at a glance, consistent with how the app renders quantities elsewhere.
- The deletion remains irreversible, and this spec introduces no undo, no soft-delete and no audit record of the previous customer assignments — none of which mbe-api offers.
