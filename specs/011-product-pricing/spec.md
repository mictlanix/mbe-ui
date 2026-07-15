# Feature Specification: Product Pricing (Price Lists, Product Prices & Exchange Rates)

**Feature Branch**: `011-product-pricing`

**Created**: 2026-07-14

**Status**: Draft

**Input**: User description: "Product Pricing: manage price lists, per-product prices, and exchange rates in mbe-ui, backed by the newly added mbe-api v0.1.0 endpoints (/api/v1/price-lists, /api/v1/product-prices, /api/v1/exchange-rates). Users can view and edit the set of price lists (name, high/low profit margin), see and edit a product's prices across all price lists from the product detail/edit screen, and manage daily currency exchange rates. Reuse existing catalog feature patterns."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Manage price lists (Priority: P1)

A pricing administrator maintains the set of named price lists (e.g. "Retail", "Wholesale", "Distributor") that the business sells at. Each list carries a high and a low profit-margin threshold used to warn staff when a sale would fall below the acceptable markup. The administrator can browse the lists, create a new one, edit an existing one's name or margins, and remove a list that is no longer used.

**Why this priority**: Price lists are the backbone every product price hangs off of. Without at least one list, per-product pricing has nothing to attach to, so this is the foundational slice and delivers standalone value as the catalog of pricing tiers.

**Independent Test**: Sign in as a user with the price-list privilege, open the price-lists screen, create a list with a name and two margins, confirm it appears, edit its margins, and delete an unused list — all without touching any product.

**Acceptance Scenarios**:

1. **Given** a user with read access to price lists, **When** they open the price-lists screen, **Then** every existing price list is shown with its name, high profit margin, and low profit margin.
2. **Given** a user with create privilege, **When** they submit a new list with a non-empty name and valid margins, **Then** the list is created and appears in the list view.
3. **Given** a user editing a list, **When** they change its name or a margin and save, **Then** the updated values are persisted and reflected wherever the list is shown.
4. **Given** a user searches by name, **When** the list refreshes, **Then** only lists whose name matches are shown.
5. **Given** a user without the price-list read privilege, **When** they attempt to open the price-lists screen, **Then** access is denied (deny-by-default).
6. **Given** a user attempts to delete a price list, **When** the backend rejects the deletion because the list is still assigned (e.g. to a customer) or otherwise in use, **Then** the user sees a clear message and the list is not removed.

---

### User Story 2 - Price a product across price lists (Priority: P1)

A pricing user opens the dedicated pricing screen, finds a product, and sees its selling price for every price list in one place, alongside the low- and high-profit figures for each. They can set or update the product's price for any list from that screen, so a single product can carry a different price per tier.

**Why this priority**: This is the headline capability the feature exists to deliver — pricing a product per tier. It is where day-to-day pricing work happens and is the reason the mbe-api pricing endpoints were added.

**Independent Test**: Open the pricing screen, select a known product, confirm the panel lists every price list with the product's current price (or a "not set" indication when none exists yet), change one list's price, save, reselect the product, and confirm the new price persisted.

**Acceptance Scenarios**:

1. **Given** one or more price lists exist, **When** a user selects a product on the pricing screen, **Then** the panel shows one row per price list with that product's price, low-profit, and high-profit values for the list.
2. **Given** a price list for which the selected product has no price yet, **When** the user views it, **Then** that list still appears indicating no price is set, and a user with edit privilege can set one.
3. **Given** a user with edit privilege, **When** they set or change the product's price for a list and save, **Then** the value is persisted and shown when the product is reselected.
4. **Given** a user enters a price, low-profit, or high-profit value that is not a valid non-negative amount, **When** they try to save, **Then** the invalid field is rejected with a clear message and nothing is saved.
5. **Given** a user with read but not update access to the pricing tool, **When** they select a product, **Then** prices are visible but read-only with no editing controls.
6. **Given** a product's prices are being viewed, **When** monetary and margin values are displayed, **Then** they are formatted per the application locale (MXN currency, `es-MX`).
7. **Given** a user without read access to the pricing tool, **When** they attempt to open the pricing screen, **Then** access is denied (deny-by-default).
8. **Given** the pricing screen is open with no product selected yet, **When** it renders, **Then** it shows an empty state prompting the user to find a product, not an error.

---

### User Story 3 - Manage daily exchange rates (Priority: P2)

A pricing/finance administrator records the daily exchange rate between two currencies (e.g. USD → MXN) so foreign-currency amounts elsewhere in the system can be converted. They can browse historical rates filtered by date range and currency pair, add a new day's rate, correct a wrong entry, and remove an erroneous one.

**Why this priority**: Exchange rates support currency conversion but are a distinct, lower-frequency administrative task than routine product pricing; the pricing MVP is viable without it, so it follows the two P1 slices.

**Independent Test**: Open the exchange-rates screen, filter to a date range and a currency pair, add a rate for a given date, confirm it appears, edit its value, and delete it — independently of price lists or products.

**Acceptance Scenarios**:

1. **Given** a user with read access, **When** they open the exchange-rates screen, **Then** recorded rates are shown with date, base currency, target currency, and rate.
2. **Given** a user applies a date-range and/or currency-pair filter, **When** the list refreshes, **Then** only rates matching the filter are shown.
3. **Given** a user with create privilege, **When** they submit a rate with a date, a base and target currency, and a positive rate value, **Then** the rate is recorded and appears in the list.
4. **Given** a user edits a rate, **When** they change its value and save, **Then** the updated rate is persisted.
5. **Given** a user without the exchange-rates read privilege, **When** they attempt to open the screen, **Then** access is denied.

---

### Edge Cases

- **New product, no prices yet**: A product may have no price rows for some or all lists. The pricing screen MUST show every current price list, distinguishing "no price set" from "price set to zero".
- **List deleted while a product is priced on it**: If a price list is removed, product prices tied to it become orphaned. The UI relies on the backend's deletion rules (US1 scenario 6) and MUST surface a backend rejection rather than silently losing data.
- **Product deleted from the catalog**: Deleting a product hard-deletes its price rows (per feature 007's FR-016a). The pricing screen MUST handle a selected product disappearing without leaving stale prices on screen.
- **Duplicate exchange rate**: Attempting to add a second rate for the same date and currency pair — the UI MUST surface whatever the backend returns (accept, reject, or overwrite) as a clear outcome rather than failing opaquely.
- **Zero / negative values**: Negative price, margin, or rate values MUST be rejected client-side before submission.
- **Very small or large decimals**: Margins are decimals (e.g. `0.40` = 40%); rates and prices may carry several decimal places. Display MUST NOT truncate in a way that misrepresents the stored value.
- **No price lists exist yet**: If there are zero price lists, the pricing screen MUST render an empty state directing the user to create a price list first, not an error.

## Requirements *(mandatory)*

### Functional Requirements

#### Price Lists

- **FR-001**: The system MUST let an authorized user view all price lists, each showing name, high profit margin, and low profit margin.
- **FR-002**: The system MUST let an authorized user create a price list with a required non-empty name and optional high and low profit margins.
- **FR-003**: The system MUST let an authorized user edit a price list's name, high profit margin, and low profit margin.
- **FR-004**: The system MUST let an authorized user delete a price list, and MUST surface a clear message when the backend refuses the deletion because the list is in use.
- **FR-005**: The price-lists screen MUST support searching by name and MUST paginate when the number of lists can grow unbounded.
- **FR-006**: Profit-margin values MUST be validated as non-negative decimals before submission and displayed as percentages consistently across the feature.

#### Product Prices

- **FR-007**: The system MUST provide a dedicated pricing screen where a user selects a product and sees every current price list with that product's price, low-profit, and high-profit values for the list.
- **FR-007a**: The product form MUST NOT display prices. Feature `007-catalog-ui-improvements-2`'s FR-012 (no price section on the product form) and FR-013 (labels occupy that layout position) remain in force and are NOT superseded by this feature.
- **FR-007b**: The pricing screen MUST let the user find a product using the shared product-search/picker pattern already used elsewhere in the catalog.
- **FR-008**: The pricing screen MUST visually distinguish a list for which no product price exists yet from one whose price is zero.
- **FR-009**: An authorized user MUST be able to set a product's price (and low/high profit) for a price list that has no existing price row, creating it.
- **FR-010**: An authorized user MUST be able to update a product's existing price, low-profit, and high-profit for a price list.
- **FR-011**: Price, low-profit, and high-profit inputs MUST be validated as non-negative monetary amounts before submission.
- **FR-012**: When the current user lacks update privilege on the pricing tool, the pricing screen MUST render read-only with no create/edit controls, while still displaying values.
- **FR-013**: Monetary values MUST be formatted using the application locale and currency (MXN, `es-MX`), not manual string formatting.

#### Exchange Rates

- **FR-014**: The system MUST let an authorized user view recorded exchange rates showing date, base currency, target currency, and rate.
- **FR-015**: The exchange-rates screen MUST support filtering by date range and by base/target currency, and MUST paginate.
- **FR-016**: The system MUST let an authorized user create an exchange rate with a required date, base currency, target currency, and a positive rate value.
- **FR-017**: The system MUST let an authorized user edit and delete an existing exchange rate.
- **FR-018**: Currency selection MUST present the currencies the system recognizes rather than free-form numeric entry, and dates MUST use the shared locale-aware date input.

#### Cross-cutting

- **FR-019**: Every pricing screen and every mutating action (create/edit/delete) MUST be gated by the deny-by-default RBAC privilege model; controls the user lacks privilege for MUST be hidden, not merely disabled.
- **FR-020**: All pricing list/table screens MUST follow the shared catalog conventions: consistent row hover/borders, right-aligned numeric/currency columns, a single row-level Edit affordance, whole-row click opening a read-only view, and Create as a toolbar-only action.
- **FR-021**: Backend errors (validation, not-found, conflict, server, network) MUST be surfaced through the shared error-display mechanism, not handled ad hoc per screen.

### Key Entities *(include if feature involves data)*

- **Price List**: A named selling tier. Attributes: name (unique, required), high profit margin (decimal markup ceiling), low profit margin (decimal markup floor). Assigned to customers elsewhere in the system; referenced by every product price.
- **Product Price**: A product's price on one price list. Attributes: the product it belongs to, the price list it applies to, price, low-profit figure, high-profit figure. A product has at most one price per list.
- **Exchange Rate**: A currency conversion for a specific date. Attributes: date, base currency, target currency, rate value. Used to convert foreign-currency amounts.
- **Currency**: The set of currencies the system recognizes, referenced by exchange rates as base and target.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: An authorized user can create a new price list and see it in the list in under 30 seconds without leaving the price-lists screen.
- **SC-002**: From the pricing screen, a user can select a product and see its price for every price list at a glance, with 100% of existing price lists represented (including those with no price set).
- **SC-003**: A user can change a product's price for one price list and confirm the persisted change on reload with no more than one save action.
- **SC-004**: 100% of pricing create/edit/delete actions are hidden from users lacking the corresponding privilege (no orphaned, non-functional controls).
- **SC-005**: All monetary and margin values render in MXN/`es-MX` formatting across every pricing surface, with none showing raw unformatted numbers.
- **SC-006**: A user can locate a specific day's exchange rate for a currency pair using the filters in under 15 seconds on a dataset of a year's daily rates.
- **SC-007**: Invalid inputs (negative or non-numeric price, margin, or rate) are blocked before submission 100% of the time, with a field-level message.

## Assumptions

- **Reuse of catalog patterns**: This feature reuses the existing shared list/table, filter, pagination, form-grid, currency/date field, and error-display widgets and the established feature-layer structure; it introduces no new cross-cutting UI infrastructure.
- **Backend is authoritative for cross-entity rules**: Rules such as "a price list cannot be deleted while assigned to a customer" and any auto-seeding of a product-price row per list on product creation are enforced by mbe-api. The UI surfaces the backend's outcome and does not re-implement these rules client-side.
- **Product-price screen placement** (decided 2026-07-14): Product prices are managed on a **standalone pricing screen**, not as a sub-panel on the product detail/edit form. Feature `007-catalog-ui-improvements-2` deliberately removed the price section from the product form (its FR-012/FR-013, with labels taking that layout slot — the `switches|labels` band DESIGN.md §4.3 cites as the reference implementation); this feature honors that decision rather than reversing it. The pricing tool is also a distinct RBAC surface (`Pricing`, 106) from the product catalog (`Products`, 0), so a separate screen matches the privilege model: a user may price products without holding product-edit rights, and vice versa.
- **RBAC mapping** (from `mbe/docs/constants.md`): the price-lists catalog screen (US1) maps to the `PriceLists` system object (code 5); editing a product's prices (US2) maps to the distinct `Pricing` system object (code 106, "Price management / pricing tool"), **not** the product privilege nor the price-list-catalog privilege; exchange rates (US3) map to the `ExchangeRates` system object (code 43). These map to the standard `AccessRight` bitmask (Read to view, Update/Create/Delete for the corresponding mutations). Presence of each `SystemObject` code in mbe-api's `UserResponse.privileges` is confirmed during planning.
- **Currency source**: The set of selectable currencies for exchange rates comes from a defined currency reference (enum/constant) shared with the backend; free-form numeric currency codes are not exposed to users.
- **Margins as decimals**: Profit margins are stored as decimals (e.g. `0.40`) and presented to users as percentages (40%).
- **Customer↔price-list assignment out of scope**: Assigning a price list to a customer belongs to the customers feature and is not delivered here; this feature only maintains the lists themselves.
- **Below-margin sales warnings out of scope**: The legacy behavior of warning when a POS/sales-order line sells below a list's low profit margin belongs to the sales feature, not this pricing-administration feature.

## Dependencies

- **mbe-api pricing endpoints** (v0.1.0): `/api/v1/price-lists`, `/api/v1/product-prices`, `/api/v1/exchange-rates` (full CRUD each). **Already generated** — `price_lists_api.dart`, `product_prices_api.dart`, `exchange_rates_api.dart` and their models are present in `lib/generated/openapi/`; the committed client is treated as current and no codegen re-run is planned (decided 2026-07-14). These DTOs MUST still be mapped to immutable `freezed` domain entities per the Contract-Driven API Integration principle.
- **Existing product search/picker**: reused by the pricing screen to select a product.
- **Existing RBAC session provider**: supplies `can(SystemObject, AccessRight)` for gating. `SystemObject.pricing` (106), `priceLists` (5), and `exchangeRates` (43) are **already defined** in `lib/core/access/system_object.dart` — no RBAC plumbing is added by this feature.
- **Currency reference/enum**: needed for exchange-rate base/target selection; confirm mbe-api exposes it (or a shared constant) during planning — if absent, file an mbe-api dependency.
