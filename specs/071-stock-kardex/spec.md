# Feature Specification: Stock and Kardex

**Feature Branch**: `071-stock-kardex`

**Created**: 2026-11-17

**Status**: Draft

**Input**: Covers mictlanix/mbe-roadmap#67 ([UI] Stock and kardex). Scope 04 §6 (mbe-api `docs/specs/04-inventory.md`: Stock and Kardex; SystemObjects WarehouseStockReport 67 and Kardex 32). Weight: 5 legacy actions. User description: "Stock by warehouse (on hand, reserved, available, in transit) and the kardex. Lots, serials and expiry alerts are out of scope (never used in mbe_dev; decided 25 Oct 2026)."

## Context

The Inventario group can record every stock movement: receipts, issues, transfers and counts (specs 067–070). What it can't do yet is show where stock stands, or why. This spec adds the two read-only views for that:

- **Existencias**: how much of each product a warehouse holds.
- **Kardex**: one product's movement history in one warehouse, entry by entry, with a running balance.

Both are read-only. The server work is done (mbe-api 04 §6), and the generated client has all three routes this spec needs: stock of a warehouse, stock of one product across every warehouse, and the kardex.

**Figures.** Each stock row carries four figures:

| Figure | Meaning |
|---|---|
| Existencia (on hand) | What the stock records hold: the sum of every movement |
| Apartado (reserved) | What open sales orders have reserved |
| Disponible (available) | On hand minus reserved: what can still be sold or moved |
| Por recibir (incoming) | What is still on its way to this warehouse on transfers in transit |

A product's view across warehouses also lists its stock **in transit**: the quantity sitting in each facility's in-transit warehouse between a dispatch and a receipt.

**What is dropped from the legacy reports.**
- The legacy stock report also filtered by label, brand and model, and showed unit cost and total value. The new stock routes carry no cost, and filter only by code or name. Stock valuation belongs to the analytics reports, which are separate roadmap items.
- The legacy kardex could span every warehouse at once. The new kardex is per warehouse.
- Lots, serials, expiry and the serial-number kardex are out of scope (decided 25 Oct 2026).

## Clarifications

### Session 2026-11-17

- Q: How are Existencias, the product view and the Kardex organised? → A: Two Inventario entries, "Existencias" and "Kardex". The product view opens from an Existencias row, and the product catalog's record surface also gets a "Ver existencias" action that opens it.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - See a warehouse's stock (Priority: P1)

A supervisor opens "Existencias", picks a warehouse and sees one row per product with its code, name, on-hand, reserved, available and incoming quantities, sorted by code. They type part of a code or name to narrow the list. By default, products with nothing on hand, reserved or incoming are hidden. A switch shows them too.

**Why this priority**: This is the question asked most often: "how much do we have here?". Every other view starts from it.

**Independent Test**: With an account that has read on WarehouseStockReport (67), open Existencias, pick a warehouse with known stock, and compare each figure for two products with the stock the records hold (for example, right after confirming a receipt). Search by part of a code. Turn on the zero-stock switch and check that products with no stock appear.

**Acceptance Scenarios**:

1. **Given** a user with read on stock (67), **When** they open Existencias, **Then** the warehouse starts as their point-of-sale warehouse when they have one, and the list shows that warehouse's products sorted by code, one page at a time.
2. **Given** the list, **When** the user picks another warehouse, **Then** the list shows that warehouse's stock, starting from the first page.
3. **Given** the list, **When** the user types part of a code or name, **Then** only products whose code or name contains it are shown.
4. **Given** the list, **When** the user turns on "Mostrar sin existencia", **Then** products with every figure at zero are listed too.
5. **Given** a product with stock reserved by an open order, **When** it is listed, **Then** its available quantity is its on-hand minus its reserved quantity, and a negative available quantity is shown as negative.
6. **Given** a user without read on stock (67), **When** they look at the navigation, **Then** Existencias is not offered, and opening its address directly is redirected to the home page.

---

### User Story 2 - See one product across every warehouse (Priority: P1)

From a row of Existencias, or from the product in the product catalog, the supervisor opens that product's stock everywhere: one row per warehouse where it has any figure, with the same four figures, plus its stock in transit in each facility. From there they can open the product's kardex for any of those warehouses.

**Why this priority**: When a warehouse runs short, the next question is "who has it?". It also answers where a transfer's goods currently are.

**Independent Test**: Open a product that has stock in two warehouses and is on a dispatched transfer, once from Existencias and once from the product catalog's "Ver existencias". Both open the same view. It lists both warehouses with their figures, and the in-transit section shows the dispatched quantity under the origin's facility.

**Acceptance Scenarios**:

1. **Given** Existencias, **When** the user opens a product, **Then** they see one row per warehouse where it has any figure, with on hand, reserved, available and incoming, and a total for each figure.
2. **Given** a product on a transfer in transit, **When** its view is open, **Then** an "En tránsito" section lists the quantity per facility.
3. **Given** a product with no figure anywhere, **When** its view is open, **Then** it says the product has no stock in any warehouse.
4. **Given** the product view and a user with read on the kardex (32), **When** they choose a warehouse row's kardex action, **Then** the kardex opens for that product and warehouse.
5. **Given** a product open in the product catalog and a user with read on stock (67), **When** they choose "Ver existencias", **Then** that product's view opens. Without read on 67 the action is absent.

---

### User Story 3 - Read a product's kardex (Priority: P1)

The supervisor wants to know why a warehouse shows the stock it does. In the Kardex they pick a product, a warehouse and a date range, and see the opening balance, every movement in the range in date order (date and time, the source document, quantity in or out, running balance), the totals in and out, and the closing balance. Each movement names its source (receipt, issue, transfer, count, sale, refund, delivery…) and, when the app has a screen for that document and the user can read it, opens it.

**Why this priority**: This is how stock discrepancies get explained and corrected: a count that doesn't match leads straight here.

**Independent Test**: Pick a product and warehouse, and a range that includes a receipt and an issue recorded during testing. The opening balance plus the ins minus the outs equals the closing balance, the closing balance equals Existencias' on-hand figure when the range ends today, and the receipt's row opens that receipt.

**Acceptance Scenarios**:

1. **Given** a user with read on the kardex (32), **When** they open Kardex, **Then** they choose a product, a warehouse and a date range, and the range starts as the last 30 days ending today.
2. **Given** a product, warehouse and range, **When** the kardex loads, **Then** it shows the opening balance, one row per movement in date and time order with its source, quantity in or out and running balance, then the totals in and out and the closing balance.
3. **Given** a movement whose source document has a screen in the app (receipt, issue, transfer, count, sales order, refund or delivery order) and the user can read that document type, **When** they choose the row, **Then** that document opens.
4. **Given** a movement whose source has no screen in the app (a legacy purchase order, a delivery itinerary) or could not be found, **When** it is shown, **Then** it names the source and shows the reference number as plain text, with nothing to open. A legacy adjustment opens the receipt it raised, which the server resolves.
5. **Given** a range longer than 366 days, or an end date before the start date, **When** the user tries to load it, **Then** the screen says so and does not load.
6. **Given** a range with no movements, **When** the kardex loads, **Then** it shows the opening and closing balances, which are equal, and says there were no movements in the range.
7. **Given** a user without read on the kardex (32), **When** they look at the navigation or the product view, **Then** Kardex is not offered, and opening its address directly is redirected to the home page.

---

### Edge Cases

- **In-transit warehouses.** Existencias refuses an in-transit warehouse (the server answers with an error). The warehouse picker can't tell which warehouses are in transit, so the server's refusal is shown in Spanish and the list stays empty. In-transit stock is seen through the product view instead.
- **Negative stock.** On-hand and available figures can be negative (for example, sales posted before a receipt). They are shown as negative numbers, never hidden or clamped to zero.
- **Large ranges.** The kardex is not paged by the server. A year of movements for a busy product can be thousands of rows, and the screen stays usable with that many.
- **Same-day ordering.** Movements are shown one row per entry in the server's order, not netted by day as the legacy kardex did.
- **Stale figures.** The views show the stock at the moment they load. Movements recorded afterwards appear when the user reloads.
- **No warehouse.** A user without a point-of-sale warehouse sees Existencias with no warehouse chosen and a prompt to pick one.
- **Document the user can't open.** A movement whose document type the user has no read right on shows the source and number as plain text.
- **Kardex for a product with no movements ever.** Opening balance, closing balance and totals are all zero, with the no-movements text.

## Requirements *(mandatory)*

### Functional Requirements

**Existencias**

- **FR-001**: The back office MUST offer an Existencias screen to users with read on WarehouseStockReport (67), in the Inventario navigation group.
- **FR-002**: Existencias MUST show one warehouse at a time, chosen from a warehouse picker that offers every warehouse. It MUST start on the user's point-of-sale warehouse when they have one, and with no warehouse and a prompt otherwise.
- **FR-003**: The list MUST show, per product, its code, name, on-hand, reserved, available and incoming quantities, sorted by code, paginated.
- **FR-004**: The list MUST filter by text contained in the code or name, and offer a "Mostrar sin existencia" switch, off by default, that includes products whose figures are all zero.
- **FR-005**: The chosen warehouse, search text, switch and page MUST be kept in the address, so a reload or a shared link shows the same view.

**Product view**

- **FR-006**: From a row of Existencias, the user MUST be able to open the product's stock in every warehouse where it has any figure, with the four figures per warehouse, a total per figure, and its in-transit stock per facility.
- **FR-007**: Each warehouse row of the product view MUST offer the kardex for that product and warehouse to users with read on Kardex (32).

**Kardex**

- **FR-008**: The back office MUST offer a Kardex screen to users with read on Kardex (32), in the Inventario navigation group.
- **FR-009**: The Kardex MUST require a product, a warehouse and a date range. The range MUST start as the last 30 days ending today, MUST NOT exceed 366 days, and its end MUST NOT be before its start. The screen MUST explain an invalid range instead of loading.
- **FR-010**: The Kardex MUST show the opening balance, each movement in the range (date and time, source name, reference, quantity in, quantity out, running balance), the totals in and out, and the closing balance.
- **FR-011**: A movement MUST open its source document when the app has a screen for that document type and the user has read on it. Otherwise the source and reference MUST be shown as plain text.
- **FR-012**: The product, warehouse and range MUST be kept in the address, so a reload or a link from the product view shows the same kardex.

**Navigation between views**

- **FR-013**: Existencias and Kardex MUST be two entries of the Inventario group. The product view MUST open from an Existencias row, and MUST have its own address, so it can also be opened directly.
- **FR-013a**: The product catalog's record surface MUST offer a "Ver existencias" action to users with read on stock (67), which opens that product's view (FR-006). It MUST be absent without that right.

**Across the feature**

- **FR-014**: Both views are read-only. Nothing on them changes stock.
- **FR-015**: Every server refusal MUST be shown with the localized text for its error code, never a raw server message or a generic failure. This includes an in-transit warehouse on Existencias and an invalid range on the kardex.
- **FR-016**: All user-facing text MUST be in Spanish. Quantities, dates and times MUST use the app's shared formatting. Negative quantities MUST be shown as negative.
- **FR-017**: Lots, serials, expiry, unit cost and stock value MUST NOT appear on these screens.

### Key Entities

- **Stock row**: a product in a warehouse, with on-hand, reserved, available and incoming quantities, and the product's code and name.
- **Product stock**: one product's stock rows across every warehouse where it has a figure, plus its in-transit stock per facility.
- **Kardex**: one product in one warehouse over a date range: opening balance, movements, totals in and out, and closing balance.
- **Movement**: one ledger entry: date and time, source type and name, reference, quantity in or out, running balance, and the source document (type, id, facility, folio) when it was found.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A supervisor can find a product's available stock in their own warehouse in under 15 seconds from opening Existencias.
- **SC-002**: For any product, warehouse and range, the kardex's opening balance plus total in minus total out equals its closing balance, and for a range ending today the closing balance equals the product's on-hand figure in Existencias.
- **SC-003**: From a stock row, a supervisor reaches the kardex for that product and warehouse in two actions or fewer, and from a product in the catalog, its stock in every warehouse in one action.
- **SC-004**: Every movement whose document has a screen in the app opens that document in one action.
- **SC-005**: Every server refusal a user can trigger on these screens shows a specific Spanish message.

## Assumptions

- The figures come from the server as computed there. The UI does not recompute available stock, balances or totals.
- There is no facility scope: anyone with read on 67 sees every warehouse's stock, and anyone with read on 32 can read any warehouse's kardex, as on the server.
- The warehouse picker uses the existing warehouse list, which doesn't say which warehouses are in transit. The server refuses an in-transit warehouse on Existencias, and that refusal is shown.
- The product picker on the Kardex searches active and inactive stockable products, so the history of a discontinued product can still be read.
- The kardex's 30-day default range and 366-day limit follow the server's limit.
- Export and printing are out of scope. Stock valuation and the analytics kardex export are separate roadmap items.
- Live verification uses the dev tenant's warehouses and the QA documents left by specs 067–070 (receipts, issues, transfers and counts), which give known movements to check balances against.
