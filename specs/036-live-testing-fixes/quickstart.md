# Quickstart: validating Live Testing Session Fixes

**Feature**: 036-live-testing-fixes

How to prove each of the nine fixes works. Automated checks first; several of these (the
pricing-grid bug, the POS status timing) are exactly the kind of thing a passing test suite can
still miss if the new tests aren't the ones that would have caught the original bug.

---

## Prerequisites

- A live mbe-api reachable with the credentials in `.env` (`test/integration/TEST_ACCOUNTS.md`).
- mbe-api#198 (`code` optional) and #199 (remove shipping fields) — check whether they've landed
  and the client regenerated (`./tool/generate_api_client.sh`) before validating US4's full scope;
  the client-side half of US4 (form order, validation relaxed, switches removed) works either way.
- At least one customer with an associated salesperson on file, for US5.
- A product with known, differing stock levels across at least two warehouses, for US6.
- A price list with at least one product, for US3.

---

## Automated

```bash
flutter analyze
flutter test
```

Both must be clean. Pay particular attention to:

- `test/unit/features/sales/pos_step_controller_test.dart` — new `canReturnToCapture`/
  `returnToVenta` cases.
- `test/widget/features/pricing/price_cell_test.dart` — new commit-before-switch cases (click
  directly into another cell; keyboard move; unmount-while-active).
- `test/unit/features/catalog/customer_form_controller_test.dart` — code-not-required case,
  shipping fields removed from stub assertions.
- `test/widget/features/sales/fulfillment_mode_selector_test.dart` — gating now keyed on
  `posDefaultCustomerId`, not `customer.shipping`.

```bash
flutter test test/golden test/screenshots
```

The pricing-grid cell and POS capture screenshots may shift slightly (warehouse-picker stock
flag, step-pill tap affordance). Review each diff before `--update-goldens` — a golden accepted
without looking is how a styling bug becomes the reference.

---

## Manual — run the app

```bash
flutter run -d macos     # or: -d chrome
```

### US1 — Sales Order customer-first, no generic customer

1. Open **Pedidos** → New. The customer bar is the only thing shown; no product search field.
2. Search the customer picker for "General" — the generic customer does not appear.
3. Pick a real customer. The product search field appears; confirm is still disabled until at
   least one line exists.
4. Open an existing order that predates this feature and was billed to the generic customer — it
   still opens and displays correctly.

### US2 — Edit a sale before payment

1. Start a POS sale, add two lines, advance to Cobro. **Do not pay.**
2. Confirm a way back to the cart is offered (tap the Venta step pill, or the compact-mode
   affordance); use it, change a line, advance again — the payment step reflects the change.
3. Record a payment (any amount that brings balance to zero, or use credit terms). Confirm the
   way back to the cart is no longer offered.
4. While mid-flow (before paying), reload/resume the sale — confirm it resumes correctly (per R1,
   it resumes on Venta, since status never left `draft`).

### US3 — Pricing grid never loses an edit

1. Open the pricing grid, type a new price in row 1, then **click directly** into row 2's price
   field (not Tab, not Enter).
2. Reload the screen — row 1 shows the new value.
3. Repeat, but type an invalid value before clicking away — the rejection renders on row 1.

### US4 — Customer form

1. Open Customers → New. Confirm the field order is: … credit days, code, comment, status.
2. Save with `code` empty — succeeds.
3. Confirm no "shipping" or "shipping required document" toggle appears, in both the main form
   and the POS inline-create panel.

### US5 — Salesperson autofill

1. In Pedidos, pick a customer known to have an associated salesperson — the salesperson field
   fills in and shows that name (not blank).
2. Change to a customer with no salesperson on file — the field is left as it was (not cleared).
3. Manually override the salesperson, then change the customer again — confirm the new customer's
   salesperson overwrites your manual pick (the documented trade-off, FR-018).

### US6 — Warehouse stock visibility

1. Add a line for the product with known differing stock, open its warehouse picker.
2. Confirm the warehouse known to be short/out shows a visible flag; the one with enough stock
   does not; a warehouse never looked up this session shows as unknown, not falsely "in stock".
3. Select the flagged warehouse anyway — confirm the line still saves (informational only).

### US7 — First delivery destination auto-assigns

1. Start a delivery/mixed sale with several lines, reach the delivery step, add the first
   destination.
2. Confirm every line already shows its full quantity assigned to that destination, with no
   manual entry.
3. Add a second destination — confirm its quantities default to zero, as before.
4. Adjust a quantity on the first destination, then delete it — confirm the quantity returns to
   unassigned.

### US6/C4 combo — mid-sale customer switch (new gap closed)

1. Start a delivery-mode sale with a real customer.
2. Switch the customer to "Público en General" — confirm the sale auto-resets to pickup-only and
   a notice explains why.

### US8 — Currency decimals

1. In the pricing grid, open a cell for a price stored with more than 2 decimal digits (e.g. via
   a direct API call) — confirm it displays as `X.XX`, not the raw stored value.
2. Change `CURRENCY_DECIMAL_DIGITS` in `.env` to `3`, restart, confirm the same cell now shows
   three digits, and so does every other currency field checked in Phase 0 research (payment
   capture, sale totals).

### US9 — Debounce settings

1. Set `INPUT_DEBOUNCE_MS=1000` in `.env`, restart. Type in a product/customer search field —
   confirm the request fires ~1s after the last keystroke, and the quantity stepper's commit
   timing is unaffected.
2. Reset that, set `QUANTITY_COMMIT_DEBOUNCE_MS=1000` instead, restart. Adjust a quantity stepper
   — confirm its commit now waits ~1s, and search fields are unaffected.
