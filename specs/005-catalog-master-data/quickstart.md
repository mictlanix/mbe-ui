# Quickstart Validation Guide: Product Catalog Master-Data Integration

**Feature**: `005-catalog-master-data` | **Spec**: [spec.md](./spec.md)

---

## Prerequisites

- mbe-api running locally (`uv run uvicorn app.main:app --reload`).
- mbe-ui running locally (`flutter run -d <device>`).
- At least one `Supplier`, one `Label`, and at least two `PriceList` rows exist in the database.
- SAT catalog tables populated (via migration; `sat_unit_of_measurement` and `sat_product_service` must be non-empty).
- An account with `Products` create + update privilege.
- An account with `Products` read-only privilege (for RBAC checks).

---

## Scenario 1 — Supplier picker (US1, FR-001, FR-002, SC-001)

**Goal**: confirm that the form shows a searchable supplier picker, the name is stored correctly, and displays throughout the UI.

1. Sign in with the create-privilege account.
2. Open **Products → New product**.
3. Locate the **Supplier** field — it must be a searchable input, not a numeric text box.
4. Type the first two letters of a known supplier's name.
5. **Expected**: a dropdown appears showing matching suppliers as `"CODE — Name"` strings within 1 second.
6. Select a supplier from the dropdown.
7. **Expected**: the field shows the selected supplier's name (not its id).
8. Fill required fields (Code, Name, Unit of Measurement) and save.
9. Open the saved product's detail screen.
10. **Expected**: the Supplier field shows the supplier's name, not a numeric id.
11. Return to the products list.
12. **Expected**: the supplier name (or a "no supplier" indicator) is visible where the supplier column appears.

**Fallback/edge case check**: open a product that has no supplier assigned — detail screen must show a clear "no supplier" indicator, not blank or "0".

---

## Scenario 2 — SAT unit-of-measurement picker (US2, FR-003, FR-005, FR-006, SC-002)

**Goal**: confirm that unit-of-measurement is a SAT-backed picker, validated before submit, and shows description on detail.

1. Open **Products → New product**.
2. Locate the **Unit of Measurement** field — must be a searchable picker, not a free-text input.
3. Type `"kilo"` into the picker.
4. **Expected**: matching SAT units appear with code, name, and description (e.g. `"KGM — kilogram — A unit of mass…"`).
5. Clear the field and click **Save** without selecting a unit.
6. **Expected**: form blocks submission with a "unit required" validation error on the field.
7. Search for and select a valid unit (e.g. `KGM`).
8. Save the product.
9. Open the detail screen.
10. **Expected**: Unit of Measurement shows the code, name, and description (e.g. `"KGM — kilogram"`), not just the raw code.

---

## Scenario 3 — SAT product/service key picker (US2, FR-004, FR-006)

**Goal**: confirm that the SAT product/service key field is a SAT-backed picker with description.

1. Open an existing product's edit form.
2. Locate the **SAT Key** field — must be a searchable picker.
3. Type `"laptop"` into the picker.
4. **Expected**: matching SAT product/service entries appear with code and description.
5. Select one and save.
6. Open the detail screen.
7. **Expected**: the SAT Key field shows both the code and the description.
8. Verify that the SAT key field can be left empty (it is optional) by clearing it and saving successfully.

---

## Scenario 4 — Price list names on detail screen (US3, FR-007, SC-003)

**Goal**: confirm that product prices show price list names instead of raw ids.

1. Open any product that has at least two price list entries.
2. **Expected**: each price row in the Prices sub-panel shows the price list's human-readable name (e.g. "Retail", "Wholesale"), not a numeric id.
3. Verify a price row does not crash if the referenced price list id is unknown — it must show a fallback label.

---

## Scenario 5 — Label filter on products list (US4, FR-008, FR-009, SC-004)

**Goal**: confirm the label filter narrows the product list correctly.

1. Ensure at least one product is tagged with a known label (do this in Scenario 6 first if needed).
2. Open the **Products** list.
3. **Expected**: a label filter control is visible in the filter bar (or hidden if no labels exist — skip to Scenario 6 and return).
4. Select the label used in step 1.
5. **Expected**: only products carrying that label are shown; untagged products are hidden.
6. Clear the label filter (select "All labels" or the clear affordance).
7. **Expected**: all products reappear.

---

## Scenario 6 — Label assignment on product form (US5, FR-010, FR-011, SC-004)

**Goal**: confirm that labels can be assigned and removed on a product, and are visible read-only on the detail screen.

1. Sign in with the edit-privilege account.
2. Open an existing product's edit form.
3. Locate the **Labels** multi-picker — must show available labels as selectable chips.
4. Select two labels. **Expected**: both chips become "selected" (visually distinct).
5. Save. Open the product's detail screen.
6. **Expected**: both selected labels are shown on the detail screen.
7. Re-open the edit form.
8. **Expected**: the two previously selected labels are pre-selected in the picker.
9. Deselect one label and save.
10. Open the detail screen. **Expected**: only the remaining label is shown.

**Read-only check**: sign in with the read-only account and open the same product.
**Expected**: the label(s) are displayed on the detail screen, but no chip is interactive/tappable.

---

## Scenario 7 — Regression: existing workflows unaffected (SC-005)

**Goal**: confirm that search, create (non-master-data fields), edit flags, deactivate, and photo upload all work exactly as before.

1. Use the products list search to find a product by partial name. **Expected**: results unchanged.
2. Create a product filling only required fields (Code, Name, Unit of Measurement via picker). **Expected**: product is created, supplier/key/labels default to none/empty.
3. Toggle `stockable`/`salable`/`purchasable` checkboxes on an existing product and save. **Expected**: flags updated.
4. Upload a new photo on a product. **Expected**: photo upload works, list/detail refresh.
5. Deactivate a product. **Expected**: product becomes deactivated; appears only when the "include deactivated" filter is active.
