# Feature Specification: Advanced Product Search

**Feature Branch**: `038-advanced-product-search`

**Created**: 2026-09-09

**Status**: Draft

**Input**: User description: "Let's create a spec to improve `lib/features/sales/presentation/capture/product_search_field.dart`. We want to introduce an 'Advanced search' button, that opens either a dialog or another screen, and shows the paged products table, searchbox, and filter button similar to `lib/features/catalog/presentation/products_list_screen.dart`, without the last columns (status and icon buttons), and it's first column has a checkbox that lets select one or many products (according to a new entry of the app settings). Only active products will be displayed on this table, so the status filter shouldn't be displayed."

## Why this feature exists

Inside a sale, the only way to find a product today is to know something about it and type it: the search field asks the sales-order product lookup for whatever pattern was entered and shows a short, unpaged list of matches. There is no paging, no facets, and no way to browse. An operator who knows only the brand, the supplier, or the label — or who simply wants to see what is available — has to leave the sale, look the product up in the catalog, memorise its code, come back and type it.

This feature gives the sales capture surface the same browsing power the catalog list already has, and lets the operator bring one or several products back into the sale in a single trip.

## Clarifications

### Session 2026-09-09

- Q: Should Advanced search open as a dialog over the current screen, or as its own route/screen? → A: **Its own route/screen**, addressable like the catalog list — search, filters and page live in the URL, so the existing filter-panel pattern is reused rather than re-created against local state. The cost accepted: the operator leaves the sale surface and comes back, so preserving in-progress sale state across the trip is a hard requirement (FR-006, FR-021).
- Q: Where should the new single-vs-multi select setting live? → A: **A deployment-level app setting**, resolved at build time from `.env` like every other option consolidated by spec 027 (FR-001–FR-007). Not a per-user preference and never changeable from the UI.
- Q: Which products may the table list, beyond "active only"? → A: **Active *and* salable only.** Both are fixed by the screen and neither is user-changeable, so the Status control **and** the Salable filter are both absent from the filter panel. Stockable, Purchasable, Supplier and Label facets remain. Rationale: these products are being added to a sale, and a non-salable product would either be refused or priced unexpectedly at the moment the line is created — a failure the operator can only discover after selecting it.
- Q: Which screens get the button? → A: **Both hosts** of the search field — the point-of-sale capture surface and the back-office sales order screen. It is one widget with one behaviour; splitting it would mean a flag whose only justification is habit.

## User Scenarios & Testing *(mandatory)*

---

### User Story 1 - Browse the catalog and add a product without leaving the sale (Priority: P1)

An operator taking an order knows the customer wants "that Truper hammer" but not its code. From the product search field they open Advanced search, land on a paged, searchable table of everything sellable, narrow it by typing "truper", tick the row they recognise from its photo, confirm, and are back on the sale with the product added as a line — priced for that customer, exactly as if they had scanned it.

**Why this priority**: This is the whole point of the feature. Everything else — multiple selection, deployment configuration — is a refinement of this journey, and none of it is worth anything if a single product cannot be found and added.

**Independent Test**: From a sale with a customer, open Advanced search, search a term, select one product, confirm, and verify a correctly priced line appears on the sale and nothing else about the sale changed.

**Acceptance Scenarios**:

1. **Given** a sale in progress, **When** the operator opens Advanced search, **Then** a paged table of active, salable products is shown with a photo, code, name, brand and unit for each, and a selection control on every row.
2. **Given** the table, **When** the operator types a term in the search box and submits, **Then** the table shows matching products from the first page.
3. **Given** a product is selected and confirmed, **When** the operator returns to the sale, **Then** the product is on the sale as a new line, priced for the sale's customer, with the same starting quantity a scan of that product would have produced.
4. **Given** a selection made by mistake, **When** the operator leaves without confirming, **Then** the sale is unchanged — no line was added.
5. **Given** the operator taps anywhere on a row, **When** the tap lands, **Then** the row's selection toggles — it never opens the product's catalog record.
6. **Given** the table shows no matching products, **When** the operator looks at it, **Then** an empty state explains that and offers a way back to the unfiltered list.

---

### User Story 2 - Narrow the list down by supplier, label or attribute (Priority: P2)

The operator does not know the product's name but knows it comes from one supplier, or carries one of the catalog's labels. They open the filters panel from the badged filters button — the same control every list screen in the app has — pick a supplier and a label, and the table narrows. The number of active filters is visible on the button, and one action clears them all.

**Why this priority**: It is what turns "a long table" into "the shortlist", and it is the half of the ask that makes browsing genuinely faster than typing. It is independently testable on top of US1 and delivers nothing without it.

**Independent Test**: Open Advanced search, apply a supplier and a label filter, confirm the table narrows, the badge counts two, clearing resets the table, and the filters survive a page change.

**Acceptance Scenarios**:

1. **Given** the screen, **When** the operator opens the filters panel, **Then** it offers Stockable, Purchasable, Supplier and Label — and shows **no** status control and **no** salable control.
2. **Given** filters are applied, **When** the operator looks at the filters button, **Then** it carries a badge with the number of active filters, counting each selected label individually — the same rule the catalog list uses.
3. **Given** filters are applied, **When** the operator clears them all, **Then** the table returns to every active, salable product and the badge disappears.
4. **Given** any filter or the search term changes, **When** the table reloads, **Then** it shows the first page of results rather than staying on a page that may no longer exist.
5. **Given** any combination of filters, **When** results are shown, **Then** every product listed is active and salable — no filter combination can reveal one that is not.

---

### User Story 3 - Add several products in one trip (Priority: P2)

Where the deployment allows it, the operator ticks several products across the list — including across pages and after changing filters — sees a running count of what they have picked, and confirms once. Every picked product is added to the sale as its own line.

**Why this priority**: It is the efficiency win for order-taking, where a customer routinely asks for six things at once. It rides entirely on US1's machinery, and a deployment configured for single selection never sees it.

**Independent Test**: With multiple selection enabled, tick three products across two pages, confirm, and verify three lines appear on the sale and the count shown before confirming matched.

**Acceptance Scenarios**:

1. **Given** multiple selection is enabled, **When** the operator ticks several rows, **Then** each stays ticked and a running count of the selection is visible.
2. **Given** products are ticked on one page, **When** the operator moves to another page or changes a filter and comes back, **Then** the earlier ticks are still there within the same visit to the screen.
3. **Given** several products are ticked, **When** the operator confirms, **Then** one line per ticked product is added to the sale and the operator is returned to it.
4. **Given** a selection, **When** the operator clears it, **Then** every tick is removed and the count returns to zero without leaving the screen.
5. **Given** single selection is configured instead, **When** the operator ticks a second row, **Then** the first row's tick is released — at most one product is ever selected.
6. **Given** one of the selected products cannot be priced for this sale, **When** the operator confirms, **Then** every other selected product is still added and the operator is told, by code and name, which one was not.

---

### User Story 4 - A deployment chooses how many products may be picked at once (Priority: P3)

Someone deploying MBE decides whether the register's operators pick one product at a time or several, sets it in that deployment's configuration file, and builds. They can see the option and its default documented alongside every other deployment option.

**Why this priority**: It is a small, self-contained configuration story, but it is the gate on US3's behaviour, so it must exist before multiple selection can be trusted to be off where it should be off.

**Independent Test**: Build with the option set to single selection and confirm only one product can ever be ticked; build with no configuration file at all and confirm the documented default applies.

**Acceptance Scenarios**:

1. **Given** the deployment configures single selection, **When** an operator uses Advanced search, **Then** the table permits at most one selected product.
2. **Given** the deployment configures multiple selection, **When** an operator uses Advanced search, **Then** the table permits any number of selected products.
3. **Given** no configuration is supplied, **When** the app runs, **Then** the documented default applies and nothing fails to start.
4. **Given** a malformed value for the option, **When** the app starts, **Then** it falls back to the documented default rather than failing to start — the rule every other deployment option already follows.
5. **Given** the configuration template, **When** a deployer reads it, **Then** the option is listed with its default and a one-line description.

---

### User Story 5 - An operator without catalog access is never offered a dead end (Priority: P3)

A register operator whose role does not grant catalog read access simply does not see the Advanced search button, and cannot reach the screen by typing its address. Their product search field works exactly as it does today.

**Why this priority**: It costs little and prevents the worst failure mode of this feature — an inviting button that leads to a permission wall or a server rejection in the middle of serving a customer.

**Independent Test**: Sign in as a role without catalog read access, open a sale, confirm no Advanced search affordance is present, and confirm navigating directly to the screen's address is refused the same way the catalog list is.

**Acceptance Scenarios**:

1. **Given** a user without catalog read access, **When** they open the product search field, **Then** no Advanced search affordance is shown.
2. **Given** the same user, **When** they navigate directly to the screen's address, **Then** access is refused exactly as it is for the catalog list — not with a server error mid-flow.
3. **Given** a user with catalog read access, **When** they open the product search field, **Then** the affordance is present and works.
4. **Given** the sale is in a state where the search field itself is not editable, **When** the operator looks at the field, **Then** the Advanced search affordance is unavailable too — it cannot be a way around the field's own gating.

---

## Edge Cases

- The operator has typed a term into the search field before pressing Advanced search — the term carries over as the screen's initial search rather than being silently discarded, and can return no results, in which case the empty state offers a way to clear it.
- A product is deactivated, made non-salable, or deleted between the moment it was listed and the moment the selection is confirmed — it cannot be priced, so it is reported and skipped while the rest are added.
- The lookup that prices a selection returns nothing for a product (no price for this customer, or no match on the product's own code) — the same reported-and-skipped path.
- The network fails part-way through confirming a multi-product selection — lines already added stay added, the operator is told what did not make it, and confirming again is possible without duplicating what already succeeded.
- The operator confirms twice quickly, or presses back while the selection is being added — the sale must not receive duplicate lines.
- At the point of sale no sale exists yet when the operator opens Advanced search — confirming a selection must open the sale exactly as scanning a product does today, not fail.
- On the back-office order screen the search field is not shown at all until a customer is chosen, so Advanced search cannot be reached before there is a customer to price against.
- The screen's address is opened directly, with no sale in progress behind it — the operator must not end up adding lines to an unrelated or newly-invented sale.
- A selected product is already on the sale — the result is whatever scanning that same product a second time already does today; this feature introduces no new merge or duplicate rule.
- The window is narrow (a register on a small screen) — the table must remain usable, and the confirm action reachable, without the sale's own layout being disturbed when the operator returns.
- The product catalog is empty, or every product is inactive or non-salable — an empty state, not an error.

## Requirements *(mandatory)*

### Functional Requirements

**Entry point**

- **FR-001**: The product search field MUST offer an "Advanced search" affordance alongside its input, in both surfaces that host it — the point-of-sale capture surface and the back-office sales order screen.
- **FR-002**: The affordance MUST be hidden for a user who lacks catalog read access, and the screen it opens MUST be gated by that same access at the route level.
- **FR-003**: The affordance MUST be unavailable whenever the search field itself is disabled, so it cannot bypass the field's own write-gating.
- **FR-004**: Opening Advanced search MUST carry whatever the operator had typed in the field across as the screen's initial search term.
- **FR-005**: Opening Advanced search MUST NOT alter the sale in any way — no line, no lookup, no state change happens until a selection is confirmed.

**The screen**

- **FR-006**: Advanced search MUST be its own addressable screen whose search term, filters and page are carried in its address, so it behaves like every other list surface in the app; returning from it MUST land the operator back on the sale they left, with that sale unchanged apart from the lines they confirmed.
- **FR-007**: The table MUST show, per product: photo, code, name, brand and unit — and a selection control as its first column. It MUST NOT show the status column or any per-row action icons.
- **FR-008**: The table MUST list only products that are both active and salable, and this restriction MUST NOT be relaxable by the operator: neither a status control nor a salable control appears in its filter panel.
- **FR-009**: The screen MUST offer the same search box and the same badged filters button used by the catalog list, with the filter panel offering Stockable, Purchasable, Supplier and Label, plus a clear-all action.
- **FR-010**: The filters badge MUST count active filters by the same rule the catalog list uses, counting each selected label individually.
- **FR-011**: The table MUST be paged, using the same page size as the catalog list, and MUST return to the first page whenever the search term or any filter changes.
- **FR-012**: Tapping a row MUST toggle that row's selection and MUST NOT navigate to the product's catalog record.
- **FR-013**: The screen MUST present loading, empty and error states consistent with the catalog list, including a retry action on failure and a clear-filters action on an empty filtered result.
- **FR-014**: At a narrow window the screen MUST remain usable — the table scrollable and the confirm and cancel actions reachable without obscuring the selection count.

**Selection**

- **FR-015**: The selection control MUST permit at most one product, or any number of products, according to the deployment's configured selection mode (FR-022).
- **FR-016**: In single-selection mode, selecting a product MUST release any previously selected one.
- **FR-017**: In multiple-selection mode, the selection MUST survive paging, searching and filter changes for the duration of one visit to the screen, MUST show a running count of selected products, and MUST offer a way to clear it without leaving the screen.
- **FR-018**: The screen MUST require an explicit confirm action to add anything to the sale, and MUST offer a cancel path that returns to the sale having added nothing.
- **FR-019**: Confirming MUST add exactly one line per selected product, in the order the operator selected them, each with the same starting quantity that scanning that product would produce today.
- **FR-020**: Each selected product MUST be priced for the sale's own customer and warehouse before its line is created — the table's own listing carries no price and MUST NOT be treated as one.
- **FR-021**: A product that cannot be priced MUST NOT prevent the rest of the selection from being added; the operator MUST be told which products were skipped, identified by code and name, and MUST arrive back at a sale carrying every product that did succeed.
- **FR-022**: Confirming MUST be protected against repeat submission, and MUST NOT leave the sale holding duplicate lines if the operator confirms twice or navigates away while lines are being added.
- **FR-023**: Where the sale has not been opened yet, confirming a selection MUST open it exactly as the existing scan path does, rather than failing.

**Configuration**

- **FR-024**: The selection mode MUST be a deployment-level option resolved at build time, alongside the app's other deployment options; it MUST NOT be changeable from the UI and MUST NOT be a per-user preference.
- **FR-025**: The option MUST have a documented default, MUST be listed in the deployment configuration template with a one-line description, and MUST fall back to its default on a malformed or absent value rather than preventing startup.

**Presentation**

- **FR-026**: Every new user-facing string MUST be localized in both Spanish and English, and every value shown MUST use the app's established formatting.

### Key Entities

- **Product candidate** — a product as the table lists it: photo, code, name, brand, unit of measurement, and the identity needed to price it later. Carries no price, no tax, no stock and no minimum order quantity. Always active and salable.
- **Selection** — the set of product candidates the operator has ticked during one visit to the screen, in the order they ticked them. Ordered, bounded by the selection mode, and discarded when the screen is left without confirming.
- **Selection mode** — the deployment's choice of single or multiple selection. Fixed for the life of the build.
- **Priced product** — what the sale's own pricing path returns for a product, for this sale's customer and warehouse: price, tax rate, tax-included flag, minimum order quantity and stock. The only thing a sale line can be created from; obtained per selected product at confirm time.
- **Sale line** — an existing entity, unchanged by this feature. One is created per successfully priced selected product.

## Success Criteria *(mandatory)*

- **SC-001**: An operator who knows only a product's brand, supplier or label can find it and add it to a sale without ever leaving the sale flow, in under 30 seconds.
- **SC-002**: Confirming a selection of N products yields exactly N new sale lines, less any product reported as skipped — never more, never silently fewer.
- **SC-003**: Returning from Advanced search preserves the sale exactly as it was left — customer, existing lines, quantities and step — in 100% of trips, including trips ended by cancelling or by the browser's back control.
- **SC-004**: No inactive or non-salable product appears in the table under any combination of search term, filters and paging.
- **SC-005**: A selection of 10 products is added, or reported as partially added, within 5 seconds of confirming, with visible progress throughout.
- **SC-006**: When one product of a selection cannot be priced, 100% of the remaining products are still added and the skipped product is named to the operator.
- **SC-007**: No user lacking catalog read access can see the affordance or reach the screen, whether by clicking or by address.
- **SC-008**: Switching a deployment between single and multiple selection requires a configuration change and a rebuild only — no source change.
- **SC-009**: The existing scan and type-ahead behaviour of the product search field is unchanged: every scenario that passes today still passes.

## Assumptions

1. **Pricing is resolved at confirm time, one product at a time, through the existing sales-order product lookup.** The catalog listing that backs the table carries no per-customer price, and no backend change is in scope, so a selected product must be resolved through the customer- and warehouse-scoped lookup before its line can be created. The resulting per-product failure mode is why FR-021 exists rather than an all-or-nothing confirm.
2. **The lookup is matched back to the selected product by identity, not by trusting the first result.** The lookup takes a pattern and can return several products; only the row whose product matches the selected one may be used.
3. **The default selection mode is multiple.** The feature was asked for to make adding several products faster; a deployment that wants the old one-at-a-time discipline sets it explicitly.
4. **Both modes require an explicit confirm.** Single selection could return the moment a row is ticked, but a mis-tap would then be unrecoverable, and two different interaction models for one screen are harder to explain than one.
5. **There is no select-all control.** Selecting a whole page of products is not a use case anyone described, and it interacts badly with per-product pricing failures.
6. **There is no cap on how many products may be selected.** SC-005 sets the expectation at the scale that matters; a hard limit can be added later if real use finds one.
7. **A product already on the sale behaves exactly as it does when scanned twice today.** This feature deliberately introduces no new merge-or-duplicate rule; whatever the existing add-line path does, this does.
8. **Whether a point-of-sale operator's role actually holds catalog read access is unverified** and must be checked against the dev tenant during planning. If cashiers do not hold it, FR-002 means the feature effectively ships to the back-office surface only — which changes nothing about the requirements, but is worth knowing before it is called done.
9. **Reaching the screen's address directly, with no sale behind it, is treated as an edge case to be closed during planning** — the acceptable outcomes are that the operator is returned to a sensible surface, or that confirming is unavailable. What is not acceptable is adding lines to an unrelated or newly-invented sale.
10. **The screen reuses the catalog list's existing filter, search, table and pagination behaviour** rather than defining its own; where this spec says "the same rule the catalog list uses", that is a requirement to match observable behaviour, not a licence to diverge.

## Verbatim Constraints

These values were pinned by the request and MUST be used exactly:

- The affordance is labelled **"Advanced search"** (Spanish translation to be provided; the English string is this one).
- The widget improved is `lib/features/sales/presentation/capture/product_search_field.dart`.
- The screen is modelled on `lib/features/catalog/presentation/products_list_screen.dart`, **without** its last columns — the status column and the row action icon buttons.
- The table's **first column is a checkbox** that selects one or many products.
- Only **active** products are displayed, and the **status filter is not displayed**.
