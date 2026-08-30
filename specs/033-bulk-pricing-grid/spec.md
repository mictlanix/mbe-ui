# Feature Specification: Bulk Pricing Grid

**Feature Branch**: `033-bulk-pricing-grid`

**Created**: 2026-08-29

**Status**: Draft — API dependencies satisfied 2026-08-29 (mbe-api#182–#185)

**Input**: User description: "Bulk pricing grid, replacing the
one-product-at-a-time pricing screen, plus two small products-list filter
drawer corrections. Design source: `artifacts/pricing_redesign/` (Claude
Design canvas `Pricing Grid.dc.html` + `github.md` screen map)."

## Context

Spec 011 shipped `/pricing` as a **one-product-at-a-time tool**: pick a
product with a picker, then see and edit that product's price on every price
list (its FR-007, FR-007b). That shape answers "what does this product cost
on each list?" It cannot answer the question a pricing clerk actually starts
from — *"what do I still have to price, and can I move a whole list at
once?"* — because reaching a second product means clearing the picker and
starting over.

This feature replaces that screen with a **grid**: one row per product, one
column per price list, prices edited in place. The visual contract is the
`Pricing Grid` artboard in `artifacts/pricing_redesign/`, which was built
from the real app shell, the shared catalog chrome, and the current pricing
screen's own price cells.

Two of the grid's three headline capabilities — bulk column actions and the
"what is unpriced" worklist — had **no query or write behind them in mbe-api**
when this spec was written. Four issues were filed, and **all four have since
landed** (see *External Dependencies*): nothing in this spec is blocked on the
backend any more. The staging that follows from them survives as delivery
order, not as a constraint.

The feature also retires the **low/high profit fields** from every screen
that shows them, and carries two unrelated one-line corrections to the
products list filter drawer, which the same canvas exposed by drawing that
drawer correctly.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - See and edit many products' prices at once (Priority: P1)

A pricing clerk opens `/pricing` and immediately sees a page of products,
each with its price on every price list side by side. They click a price,
type a new one, press Enter, and land on the same column of the next row —
never touching a picker, never leaving the page.

**Why this priority**: it is the whole reason the screen is being replaced.
Everything else here is an accelerator on top of this; without it there is
no feature.

**Independent Test**: open `/pricing` with no product selected — a populated
grid renders, and a price can be changed and re-read after a reload.

**Acceptance Scenarios**:

1. **Given** an authorized user with update rights, **When** they open
   `/pricing`, **Then** a grid renders with one row per product (photo,
   code with copy action, name, and an "Inactive" marker on inactive
   products) and one column per shown price list — with no product
   selection required first.
2. **Given** a cell holding a price, **When** the user clicks it, **Then**
   it becomes an editable field with the current value selected.
3. **Given** a cell being edited, **When** the user presses Enter, **Then**
   the value is submitted and the same column of the next row opens for
   editing.
4. **Given** a cell being edited, **When** the user presses Tab or
   Shift+Tab, **Then** the value is submitted and the next/previous column
   opens, wrapping to the next/previous row at the ends.
5. **Given** a cell being edited, **When** the user presses Escape,
   **Then** the edit is abandoned and the stored price is left unchanged.
6. **Given** a product with no price on a list, **When** the grid renders,
   **Then** that cell is visibly distinct from a cell whose price is zero
   (carrying forward spec 011 FR-008).
7. **Given** a submitted value, **When** it is not a non-negative number,
   **Then** the stored price is left unchanged, the cell keeps the typed
   text visibly flagged as rejected, and the user can correct it without
   retyping from memory.

---

### User Story 2 - Find what still needs pricing (Priority: P1)

Before a season or a supplier update, the clerk needs the products that have
**no** price on a given list. A row of worklist chips above the grid names
each list with a count — "Missing Mostrador (14)" — and clicking one narrows
the grid to exactly those products.

**Why this priority**: it is the question the current screen cannot answer at
all, and it is what makes the grid a work surface rather than a viewer. It is
independently valuable even with no bulk actions: the clerk can work the list
down cell by cell.

**Independent Test**: with at least one product unpriced on a list, the chip
for that list shows a non-zero count and selecting it shows only unpriced
rows.

**Acceptance Scenarios**:

1. **Given** the grid, **When** it renders, **Then** an "All products" chip
   and one "Missing «list» (count)" chip per shown price list appear above
   it, with the active chip visibly selected.
2. **Given** a "Missing «list»" chip, **When** the user selects it,
   **Then** only products with no price on that list are listed, and the
   pagination count reflects that narrowed set.
3. **Given** a narrowed worklist, **When** the user prices one of its rows,
   **Then** the count on that chip decreases.
4. **Given** the worklist query is unavailable in the backend, **When** the
   grid renders, **Then** the chips are absent entirely rather than shown
   with wrong or zero counts (see *External Dependencies*).

---

### User Story 3 - Move a whole price list in one action (Priority: P2)

A supplier raises prices 5%. The clerk filters to that supplier, opens the
column menu on the affected list, enters 5, and applies — every shown row
moves at once. The same menu fills a column down from its first row, or
copies the cost list across into it as a starting point.

**Why this priority**: the largest time saving on the screen, but it rests on
US1 being in place and on a backend write that does not exist yet, so it
cannot be first.

**Independent Test**: with a filtered set of rows on screen, apply a
percentage adjustment to one column and confirm every shown row in that
column moved, and no row outside the shown set did.

**Acceptance Scenarios**:

1. **Given** a user with update rights, **When** they open a price-list
   column's menu, **Then** it offers "fill down from the first row", "copy
   from the cost list", and "adjust every shown row by N%" with a percentage
   input.
2. **Given** a column action, **When** it is applied, **Then** it affects
   **only the rows currently shown** (the current page under the current
   filters and worklist), and the user is told how many rows changed.
3. **Given** a column action affecting N rows, **When** it completes,
   **Then** it counts as **one** undoable change, not N.
4. **Given** a column action, **When** any part of it fails, **Then** no
   row is left changed — the whole action either applies or does not.
5. **Given** a user without update rights, **When** the grid renders,
   **Then** no column menu is offered at all.

---

### User Story 4 - Trust what just happened, and take it back (Priority: P2)

Bulk editing is only usable if the user can see what changed and undo a
mistake. Each cell shows whether its value is saving, saved, or rejected; a
summary bar counts the session's changes and offers "undo last" and "revert
all".

**Why this priority**: it is what makes US1 and US3 safe to use, but the grid
is demonstrable without it.

**Independent Test**: change three cells and one column, then undo — the
column returns as a unit and the change count falls accordingly.

**Acceptance Scenarios**:

1. **Given** a cell whose value was submitted, **When** the write is in
   flight, **Then** the cell shows a saving indicator; on success it shows
   a saved indicator; on rejection it shows a rejected indicator with the
   reason available on hover/focus.
2. **Given** any change in the session, **When** the grid renders, **Then**
   a summary bar states how many prices changed and how many were rejected,
   with "undo last" and "revert all" actions.
3. **Given** a change history, **When** the user invokes "undo last" (or
   the platform undo shortcut), **Then** the most recent change — single
   cell or whole column action — is reversed.
4. **Given** a change history, **When** the user invokes "revert all",
   **Then** every price returns to the value it held when the current view
   was loaded, and the summary bar disappears.
5. **Given** changed prices, **When** the user changes page, filter, or
   worklist, **Then** they are told the undo history does not survive the
   navigation before it is discarded.

---

### User Story 5 - Look without touching (Priority: P3)

A user with read but not update rights on pricing opens the grid to check
prices. Everything is legible; nothing is editable.

**Why this priority**: carries forward an existing guarantee (spec 011
FR-012, FR-019) rather than adding value, but the grid must not regress it.

**Independent Test**: sign in as a profile with pricing read and no update,
open `/pricing`, and confirm no cell opens for editing and no column menu
exists.

**Acceptance Scenarios**:

1. **Given** a user without pricing update rights, **When** they open the
   grid, **Then** every price is displayed, no cell enters edit mode on
   click, no column menus are offered, and no summary bar can appear.
2. **Given** that user, **When** the grid renders, **Then** a short line
   states the view is read-only because their profile lacks the update
   right.
3. **Given** a user without pricing read rights, **When** they attempt
   `/pricing`, **Then** access is refused exactly as it is today.

---

### User Story 6 - Read the products filter drawer without guessing (Priority: P3)

Unrelated to pricing: on the products list, the drawer's three tri-state
chips are the only group with no heading, and the supplier picker sits after
labels instead of with the other single-value filters.

**Why this priority**: two small corrections, independently shippable, with
no dependency on anything else in this feature.

**Independent Test**: open the products filter drawer and read it top to
bottom — every group has a heading, and supplier precedes labels.

**Acceptance Scenarios**:

1. **Given** the products filter drawer, **When** it renders, **Then** the
   Stockable/Salable/Purchasable chip group carries a section heading
   styled like the drawer's other headings.
2. **Given** the products filter drawer, **When** it renders, **Then** the
   sections appear in the order: status, product attributes, supplier,
   labels.
3. **Given** either supported language, **When** the drawer renders,
   **Then** the new heading is localized like every other drawer heading.
4. **Given** the drawer, **When** filters are applied, **Then** the
   behaviour of every filter, including the result counts on labels, is
   unchanged from today.

---

### User Story 7 - Stop maintaining numbers nobody edits (Priority: P3)

The low-profit and high-profit fields — per price row on the pricing screen,
and per list as "high/low profit margin" on the price-list form — are being
deprecated. Every screen that shows or edits them drops them.

**Why this priority**: independently shippable, and it shrinks the surface
the rest of this feature has to carry. It is not a prerequisite for any
other story here.

**Independent Test**: open the price-list form, the price-lists list, and
both pricing surfaces — no profit field appears on any of them, and saving
each record still works.

**Acceptance Scenarios**:

1. **Given** the price-list create/edit form, **When** it renders, **Then**
   it shows the name and nothing else of the two profit-margin fields, and
   saving a list still succeeds.
2. **Given** the price-lists list, **When** it renders, **Then** no
   profit-margin column appears.
3. **Given** either pricing surface (the grid, and the per-product screen
   kept by CL-002), **When** it renders, **Then** no low-profit or
   high-profit value is shown or editable.
4. **Given** a price created or updated from any surviving surface,
   **When** it is saved, **Then** the user is never asked for a profit
   threshold, and any value the backend still requires is supplied without
   being surfaced.

---

### Edge Cases

- **Many price lists**: a deployment with more price lists than fit the
  viewport must not force horizontal scrolling of the whole grid (Principle
  VI). The shown-columns chooser is the answer; the spec requires a
  default-visible set and a way to change it, not an ever-widening table.
- **No price lists exist**: the grid has no columns to draw and must say so
  rather than render an empty frame.
- **Product priced by someone else while the page is open**: a submitted
  price for a product/list that already gained a row must not fail as a
  duplicate; the user's intent is "this list now costs this".
- **Price list deleted while the page is open**: the column disappears on
  the next load; in-flight writes to it must surface as a normal error, not
  a crash (see mbe-api#181, which currently blocks such a delete anyway).
- **Product deleted while the page is open**: carried forward from spec 011
  — its price rows go with it and the grid must not show stale prices.
- **A rejected cell left on screen**: navigating away with rejected cells
  outstanding must not silently discard them without telling the user.
- **Zero and blank are different**: clearing a cell (removing the price)
  and typing 0 are distinct outcomes and must remain distinguishable after
  a reload.
- **Percentage adjustment on an unpriced cell**: a row with no price on the
  adjusted list has nothing to adjust and must be skipped, not created at
  0.
- **Very long product names**: truncate with a tooltip; never widen the row
  (Principle VI).
- **Sales-order price validation after the profit fields go**: the backend
  still refuses sales-order lines whose margin falls outside the band
  stored on a product price. Removing the fields from this UI does not
  remove that check — it removes the only way to adjust it (see
  *External Dependencies*, mbe-api#185).

## Requirements *(mandatory)*

### Functional Requirements

#### The grid (US1)

- **FR-001**: `/pricing` MUST present a paginated grid of products with one
  column per shown price list, requiring no product selection to render.
- **FR-002**: Each row MUST show the product's photo, code with a copy
  action, name, and an inactive marker when the product is not active,
  consistent with the products list.
- **FR-003**: The grid MUST support the shared catalog search (code, name,
  brand, model), the shared filter side sheet, and mandatory pagination
  (Principle VI).
- **FR-004**: Prices MUST be right-aligned, formatted with the application
  locale and currency, and rendered with figures that align across rows
  (carrying forward spec 011 FR-013).
- **FR-005**: A price list on which a product has no price MUST be visually
  distinct from a price of zero.
- **FR-006**: The grid MUST NOT force horizontal scrolling of the page; when
  the shown columns exceed the available width, the grid's own region MAY
  scroll horizontally while row identity (photo, code, name) stays legible.

#### Editing a cell (US1)

- **FR-007**: A user with pricing update rights MUST be able to edit any
  price cell in place by clicking it.
- **FR-008**: Keyboard traversal MUST be supported while editing: Enter
  submits and moves down; Tab/Shift+Tab submit and move right/left,
  wrapping at row ends; Up/Down move between rows; Escape abandons the
  edit.
- **FR-009**: A submitted value MUST be validated as a non-negative
  monetary amount. A rejected value MUST leave the stored price unchanged,
  keep the typed text visible and flagged, and state why.
- **FR-010**: Submitting a value equal to the stored price MUST NOT issue a
  write.
- **FR-010a**: An **empty** submit on a cell that has no price is the same
  no-op — it is what "unchanged" looks like on an unpriced cell, not an
  invalid amount. Traversing a "Missing «list»" worklist means arrowing
  through cells that are unpriced by definition, so treating this as a
  rejection flagged every cell the user passed over with an edit they never
  made. An empty submit on a cell that *does* have a price stays refused
  until FR-011's clearing is actually built.
- **FR-011**: Clearing a cell MUST be a distinct, deliberate outcome from
  entering 0, and the spec's chosen meaning of "cleared" MUST survive a
  reload.
- **FR-012**: Creating a price where none existed MUST NOT ask the user for
  any profit threshold, and MUST NOT invent one either: the client sends the
  price alone and the backend fills the row's band from the price list's own
  margins (mbe-api#185). Updating a price MUST leave the stored band
  untouched.
- **FR-012a**: The grid MUST NOT expose a price row's own low-profit and
  high-profit thresholds — neither as columns nor behind a per-cell
  affordance. A price cell holds one number: the price (see CL-003).

#### Column actions (US3)

- **FR-013**: A user with update rights MUST be offered, per price-list
  column: fill down from the first shown row, copy from the cost list, and
  adjust every shown row by a percentage. The cost list is identified by
  the deployment's configured cost price list; when that setting names no
  existing list, the copy-from-cost action MUST be absent rather than
  broken.
- **FR-014**: A column action MUST apply to exactly the rows currently
  shown, and MUST state how many rows it changed.
- **FR-015**: A column action MUST be all-or-nothing: a partial application
  MUST NOT be left behind on failure.
- **FR-016**: A column action MUST be a single undoable unit.

#### Worklist (US2)

- **FR-017**: The grid MUST offer an "all products" chip plus one chip per
  shown price list naming the number of products with no price on it, and
  selecting a chip MUST narrow the grid to those products.
- **FR-018**: Worklist counts MUST reflect the filters currently applied,
  not the whole catalog.
- **FR-018a**: They MUST also reflect the work done since the view loaded: a
  cell going from unpriced to priced MUST re-read them. Revaluing a price
  that already existed MUST NOT — a missing-count cannot move, and this is a
  bulk-editing screen where a refresh per keystroke-ended edit would be its
  own defect.
- **FR-019**: When the backend cannot answer the worklist query, the chips
  MUST be omitted rather than displayed with unreliable counts. *(The query
  exists as of mbe-api#184, so this now governs only the interval before the
  US2 UI is built, and any later failure of that call.)*
- **FR-019a**: A price list id of `0` is real (`Costo` in the deployment).
  Every worklist filter and count MUST test for absence, never for
  falsiness, or the cost list's own chip silently disappears.

#### Columns and filters

- **FR-020**: The filter side sheet MUST let the user choose which price
  lists appear as columns, and MUST retain that choice for the session.
- **FR-020a**: No price list is privileged in the grid's layout. The cost
  list is an ordinary column — hideable and orderable like any other, and
  editable under the same rules (see CL-001); its only distinction is that
  it is what "copy from cost" reads (FR-013).
- **FR-021**: The side sheet MUST otherwise offer the same product filters
  as the products list (status, attributes, supplier, labels), in the same
  order and with the same headings as FR-030/FR-031 establish there.

#### Change tracking (US4)

- **FR-022**: Each cell MUST indicate whether its value is in flight,
  written, or rejected, with the reason for a rejection available without
  navigating away.
- **FR-022a**: "Written" includes a cell that had **no** price before. The
  summary bar counts it, so the cell must show it — otherwise the user is
  told six prices changed with no way to see which six, which is precisely
  the case a "Missing «list»" worklist produces. The tooltip says what it
  can: the previous value when there was one, "newly priced" when there was
  not.
- **FR-023**: A summary bar MUST appear whenever the session holds changes,
  counting changed and rejected prices, and offering undo-last and
  revert-all.
- **FR-023a**: Rejected edits MUST be dismissible on their own, without
  discarding the accepted changes beside them. A rejection never reached the
  server, so clearing one is local and instant — unlike revert-all, which
  issues writes. Two routes: a summary-bar action clearing all of them, and
  Escape on a cell clearing that cell's, since Escape already means "cancel
  this edit" and a rejection is an edit that was never accepted.
- **FR-024**: Undo MUST operate on whole changes — a column action reverses
  as one — and revert-all MUST restore every price to its value when the
  current view loaded.
- **FR-025**: The user MUST be warned before an action that discards the
  undo history or outstanding rejected cells.

#### Permissions (US5)

- **FR-026**: Without pricing update rights the grid MUST render read-only:
  no cell editing, no column menus, no summary bar, and a stated reason.
- **FR-027**: Access to `/pricing` MUST remain gated by the existing
  deny-by-default privilege model, with controls hidden rather than
  disabled (spec 011 FR-019).

#### Replacing the current screen

- **FR-028**: The grid MUST replace the product-picker pricing screen at
  `/pricing`; the picker-first flow MUST NOT remain as a second way to do
  the same thing.
- **FR-028a**: The per-product pricing route reached from a product's
  detail screen (`/products/:productId/pricing`) MUST survive unchanged
  (see CL-002). It keeps its current single-product layout and is not
  replaced by a one-row grid.
- **FR-029**: Prices MUST remain absent from the product create/edit form
  (spec 011 FR-007a, spec 007 FR-012/FR-013 remain in force).

#### Products filter drawer (US6)

- **FR-030**: The products filter drawer's tri-state attribute chips MUST
  carry a localized section heading styled like the drawer's other section
  headings.
- **FR-030a**: **Every** section of that drawer MUST carry such a heading —
  status, attributes, supplier and labels alike. Supplier had none either
  (found 2026-08-29 during review); its picker now sits under a "Supplier"
  heading and its own field label says what to do rather than repeating the
  noun, matching the canvas.
- **FR-030b**: The pricing grid's filter drawer MUST stay identical to the
  products drawer in headings and order, since FR-021 makes it a mirror —
  the two disagreeing is itself the defect.
- **FR-031**: The drawer's sections MUST appear in the order: status,
  attributes, supplier, labels.
- **FR-032**: FR-030 and FR-031 MUST NOT change any filter's behaviour,
  query parameters, or label facet counts.

#### Retiring the profit fields (US7)

- **FR-034**: The application MUST NOT show or edit a low-profit or
  high-profit value on any screen — the pricing grid, the per-product
  pricing screen kept by FR-028a, the price-list create/edit form, and the
  price-lists list included.
- **FR-035**: Removing those fields MUST NOT prevent creating or updating a
  price list or a product price from any surviving surface.
- **FR-036**: The strings and localizations for the removed fields MUST be
  removed with them, in every supported language, rather than left orphaned.
- **FR-037**: This removal is UI-only. It MUST NOT be accompanied by a
  change to mbe-api from this repository (Principle III); the field
  deprecation itself is tracked as mbe-api#185.

#### Errors

- **FR-038**: Backend failures MUST surface through the shared error
  mechanism rather than per-cell ad-hoc handling, and a failed write MUST
  never leave the grid showing a value the backend did not accept.

### Key Entities

- **Product row**: one catalog product as it appears in the grid — photo,
  code, name, status — plus its price on each shown list.
- **Price list column**: a price list shown as a column; carries its name
  and whether it is the deployment's cost list.
- **Price cell**: the intersection — a product's price on a list, which may
  not exist yet; carries its own local state (unchanged, editing, in
  flight, written, rejected) and the value it held when the view loaded.
- **Change**: one undoable unit — a single cell edit or a whole column
  action — holding the previous values needed to reverse it.
- **Worklist**: a named subset of products (all, or unpriced on a given
  list) with a count.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A clerk can set prices for 20 products on one price list
  without ever selecting a product from a picker, and without leaving the
  page.
- **SC-002**: Repricing a filtered set of products on one list by a
  percentage takes one action, and the user is told exactly how many rows
  it changed.
- **SC-003**: A user can tell, without reloading, which of their changes
  were stored and which were rejected — every cell they touched shows one
  or the other.
- **SC-004**: Any single change, including a bulk column action, can be
  reversed in one action.
- **SC-005**: "Which products have no price on list X?" is answerable from
  the screen in one click, with a count visible before clicking.
- **SC-006**: Loading a page of the grid costs a constant, small number of
  backend round trips regardless of how many rows the page shows.
- **SC-007**: A read-only user sees every price and can reach no editing
  affordance.
- **SC-008**: Every section of the products filter drawer is labelled, and
  the drawer's filter results are byte-for-byte what they were before this
  feature.
- **SC-009**: A user can search the whole application and find no
  low-profit or high-profit field, while every price list and product price
  remains creatable and editable.

## External Dependencies

Per Principle III, the needed backend changes were filed as mbe-api issues
and **not** made from this repo. **All four landed on 2026-08-29** (`98d3254`),
so no story here is blocked on the backend.

- **mictlanix/mbe-api#182 — landed.** `product` repeats on the
  product-prices list, so a grid page is one price request rather than one
  per row (SC-006 met). The cap moved with it: `BULK_LIMIT` is 500 and is
  shared by this read and the bulk write, so a page that can be read can
  always be written back.
- **mictlanix/mbe-api#183 — landed.** `PUT /product-prices` upserts a page
  in one transaction, keyed on `(product, price_list)`. FR-015's
  all-or-nothing guarantee is now reachable, which is what **US3** was
  waiting for. Two client obligations come with it: a repeated
  `(product, price_list)` in one body is a 400, and the body is capped at
  500 items.
- **mictlanix/mbe-api#184 — landed.** `GET /products?missing_price_list=`
  plus `GET /products/prices/missing-facets` for the whole chip row in one
  call. **US2** is unblocked; the filter is already wired through
  `ProductRepository.list`.
- **mictlanix/mbe-api#185 — landed, and it went further than asked.** The
  sales-order margin validation is **retired outright** rather than
  relocated, and all four low/high profit fields are deprecated (still
  accepted and returned). A created row takes its band from the price
  list's margins server-side; an update leaves the stored band alone. This
  resolves the CL-002/CL-003 overlap in favour of removal (see
  *Clarifications*) and defuses FR-012's landmine entirely.

- **mictlanix/mbe-api#188 — filed, not built.** Three of the six product
  boolean flags (`perishable`, `seriable`, `invoiceable`) are editable on the
  product form but not filterable on `GET /products`, so the attribute
  section of both drawers can only ever offer half of them. **Blocks nothing
  here** — the three that do filter are shipped; the other three arrive as
  three more chips in both drawers when the query exists.

**Adjacent, not consumed here**: the investigation behind this spec also
filed **#181**, which landed as
`DELETE /price-lists/{id}?replacement={other_id}` plus a delete-preview
endpoint. Spec 033 does not touch the price-lists delete flow; the
capability exists and wants its own spec.

## Assumptions

- **The canvas is the visual contract, not the data contract.** Its
  products, price lists and counts are sample data; its layout, states and
  interaction model are the specification.
- **Scope is the pricing screens, one drawer, and the profit fields.** The
  price-lists catalog screen is in scope only for removing its two
  profit-margin fields (US7); the exchange-rates screen and the product
  form are untouched.
- **Session-scoped undo.** Undo/revert live in the open view; they are not
  a stored audit trail, and they do not survive a page load. Reverting
  issues new writes rather than rolling back the backend.
- **Writes settle per change, not per screen.** There is no "save" button
  for the grid; a submitted cell or applied column action is written
  immediately. This matches the current pricing screen's inline-edit
  behaviour (spec 011 FR-020a) rather than introducing a dirty-form model.
- **Default shown columns.** Absent a stored preference, the grid shows the
  cost list plus every other price list up to what fits, and the user
  narrows from there via FR-020.
- **The grid is a tool screen, not a record catalog.** Spec 011's FR-020a
  exemption from row-click/row-edit conventions carries over: rows are
  editable prices, not navigable records.
- **Formatting comes from the shared surface.** Money and percentage
  rendering follow the application's existing formatting rules; this
  feature introduces no new formatting path.
- **Products filter drawer wording.** "Product attributes" is the heading
  the canvas uses and is adopted here; it names what the three chips are —
  boolean capabilities of the product — rather than what they filter.

## Clarifications

### Session 2026-08-29

- **CL-001 — The cost list is just another column.** It gets no pinned
  position and no special read-only treatment: it is hideable and orderable
  through the column chooser (FR-020a) and editable like any other column.
  The deployment's configured cost price list matters only as the source
  for the "copy from cost" action (FR-013). This departs from the canvas
  only in that the canvas draws the cost column with its own quieter
  styling; the grid may keep that styling as a visual cue without making
  the column behave differently.
- **CL-002 — The standalone per-product pricing screen stays.**
  `/products/:productId/pricing`, reached from the product detail screen,
  survives as it is (FR-028a). Only the picker-first `/pricing` is
  replaced. Two pricing surfaces therefore coexist and must be kept in step
  for anything that changes both.
- **CL-003 — Per-price low/high profit thresholds leave the grid.** The
  grid edits the price and nothing else (FR-012a); a newly created price
  takes its thresholds from the price list's configured margins (FR-012).

  **Resolved (same session, follow-up)**: the overlap with CL-002 is
  settled in favour of retiring the fields everywhere — including the
  standalone screen CL-002 keeps, the price-list form and the price-lists
  list. The low/high profit fields are being deprecated outright, so they
  leave the UI as a set rather than surviving on one screen (US7,
  FR-034..FR-037). Spec 011's FR-010/FR-011 (per-price threshold editing)
  and FR-006 (price-list margins displayed as percentages) are superseded
  for those fields.

  **Confirmed by mbe-api#185 (2026-08-29)**: the decision this rested on
  went the way US7 assumed. The margin validation is retired rather than
  relocated, and all four fields — the price list's two included — are
  deprecated. The task list's T049 gate, which would have stopped the
  price-list form work had the band been relocated onto those margins,
  resolves to outcome (a): proceed.
