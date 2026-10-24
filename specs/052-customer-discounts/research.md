# Research: Customer Discounts

**Feature**: [spec.md](./spec.md) · **Plan**: [plan.md](./plan.md)

## R1 — Surface: a section on the existing customer detail page

**Decision**: Add a `CustomerDiscountsSection` as the last section on the customer detail page (`customer_form.dart`), after the Taxpayers section and before `RecordFormActions`. This mirrors where `SupplierAgreementsSection` sits on the supplier form.

**Rationale**: Customers already use a full detail screen (spec 046, §VI record surface, which customers meet through their linked-record sections). Adding a child collection doesn't change the surface, so no constitution change is needed.

**Alternatives considered**: A separate `/customers/:id/discounts` screen. Rejected: the legacy system shows discounts on the customer, and §VI keeps child collections on the record's own surface.

## R2 — Data layer: extend `CustomerRepository`

**Decision**: Add `listDiscounts`, `createDiscount`, `updateDiscount` and `deleteDiscount` to `CustomerRepository` and `CustomerRepositoryImpl`, mapping to the generated `CustomersApi` methods. Add a new freezed `CustomerDiscount` entity with a `fromResponse` mapping. The wire `Discount` (`anyOf [string, num]`) is written through a file-local `_setDiscount` that sends the String arm. This is the same construction as `_setCreditLimit` in the same file.

**Rationale**: Supplier agreements put their CRUD on `SupplierRepository` (spec 050), and discounts are nested under `/customers/{id}` the same way. A separate repository would add a provider for four methods with a single caller.

**Alternatives considered**:
- A `CustomerDiscountRepository`. Rejected for the reason above.
- Reusing `sales/data/wire_value_setters.dart`. Rejected: its setters are typed to the sales wrapper types (`DiscountRate`, …), and the customer discount uses the distinct generated type `Discount`. Catalog repositories keep their setters local.

## R3 — Rate representation: string fraction, percentage only at the edge

**Decision**: The entity keeps `discount` as the wire's decimal string fraction, for example `"0.12500000"`.
- **List:** renders through `fmt.display.percent(discount)`.
- **Dialog field:** seeded with `fmt.field.rate(discount)`, which gives the full-precision percentage (`"12.5"`).
- **Sending:** `fmt.field.parseRate(input)` turns the field back into a fraction.
- **Untouched edit:** when the user saves without changing the field, the original string is sent back unchanged.

**Rationale**:
- Constitution §V says every displayed percentage goes through `formattersProvider`, and an automated guard enforces it.
- `display.percent` renders at the configured `percentDecimalDigits` (2 by default), so the list reads `12.50 %`. The spec was amended (FR-003, US1 scenario 3) to match this, instead of a bespoke trailing-zero format.
- `field.rate` / `parseRate` are the existing editable-rate pair the sales discount field uses. `parseRate` scales to 6 places when dividing by 100, which is exact for any percentage with up to 6 decimals.

**Alternatives considered**: A new `display.percentExact`. Rejected: it adds formatter surface for one screen, and the edit dialog already shows full precision.

## R4 — Percentage validation (FR-006)

**Decision**: The dialog controller validates the percentage text before it enables Save:
- It must be non-empty and parse with `Decimal.tryParse` after trimming.
- It must be `>= 0` and `<= 100`.
- It must have at most 6 decimal places, checked as `parsed.scale <= 6`.

Each failure has its own localized message under the field. The server's own 422 field errors still map to `fieldErrors['discount']` as a backstop.

**Rationale**: 6 decimals of a percentage is exactly the server's `Numeric(9, 8)` fraction. Anything finer would be refused or rounded by the server. The period-only separator matches `parseRate` and the sales discount field, and the spec edge case was amended to say so.

## R5 — Product picker (FR-005, FR-012)

**Decision**: In add mode the dialog shows a `CatalogEntityPicker<ProductListItem>`.
- **Search:** `productRepository.list(search: q, status: EntityStatus.active, limit: 20)`.
- **Exclusions:** results are filtered client-side against the product ids already in the section, taken from the loaded discounts list.
- **Option row:** code and name, with the merge-products thumbnail and subtitle style.
- **Edit mode:** the picker is replaced by a read-only `InputDecorator` that shows `code — name`.
- **Without Products Read:** the add button is hidden, because a discount can't be added without choosing a product.

**Rationale**: The server enforces Products Read on `GET /products` (`require_privilege(PRODUCTS, READ)`). Hiding the add control follows §IV, which hides actions rather than disabling them. The discount list is small and already loaded, so client-side exclusion is enough.

**Alternatives considered**: Leaving out the exclusion and relying on the 409. Rejected: FR-005 requires the exclusion, and a 409 should only happen in a race.

## R6 — Errors (FR-011)

**Decision**: Map the server's refusals to dialog error codes. In every case the dialog stays open with the user's input.

| Server | `AppError` | Dialog code | Then |
|---|---|---|---|
| 409 `already has a discount` | `ServerError(statusCode: 409)` | `duplicateProduct` | invalidate the section |
| 422 `Product not found` (plain detail) | `ValidationError(errors: [], message)` | `productMissing` | — |
| 422 field errors | `ValidationError(errors)` | `fieldErrors` | — |
| 404 on PUT/DELETE | `NotFoundError` | `discountMissing` | invalidate the section |
| anything else | — | `saveFailed` / `deleteFailed` | show the server message if any |

**Rationale**:
- These are the four cases the spec names.
- A refused save refreshes the section so it shows the server's current state (FR-011).
- A 422 with no field errors and a message is the documented `ValidationError` plain-detail form (#172).

## R7 — Section state and refresh (FR-010)

**Decision**: A `@riverpod` family `CustomerDiscountsController(int customerId)` loads `listDiscounts`. The server already orders it by product code, and the controller doesn't re-sort. The dialog controller invalidates it after each successful create, update or delete, and after a 409 or 404.

**Rationale**: This is the same pattern as `SupplierAgreementsController`. The section is independent of `CustomerFormController`, so the customer's unsaved edits are never touched.

## R8 — Stay on the saved customer after create (FR-007a), and the form-state key

**Decision**:
- `CustomerForm` gains `onCreated: ValueChanged<int>?`. `CustomerDetailScreen` passes `(id) => context.replace('/customers/$id')`, as suppliers do.
- `CustomerFormController` becomes a family keyed by `int? customerId`, with `null` for a create.
- The `_snapshot` guard from `supplier_form.dart` is copied, so a leftover `saved` flag never fires on the replacing screen.
- `customer_inline_create.dart` (POS) reads the `null` key, so its behaviour doesn't change.

**Rationale**:
- `context.replace` mounts a new `CustomerForm` for the new id while the create form is disposing. With the current unkeyed provider, the new screen would read the old create's `saved: true` state and pop at once. A New opened during a back transition would also inherit the previous customer's data.
- This is mbe-ui#207, and keying is the fix #207 proposes, proven on suppliers in commit 424c940. The PR therefore also `Closes #207`.

**Alternatives considered**: Resetting the provider in `initState`. Rejected in #207, because Flutter refuses to mark the closing screen dirty during build.

## R9 — Rights matrix (FR-012)

| Control | Needs |
|---|---|
| See the Discounts section | Customers Read (the route gate already requires it) |
| Add button, row Edit icon, Delete in the dialog | Customers Update, **and** the page is not in read-only view |
| Add button (additionally) | Products Read |

The section takes the page's `readOnly` flag, as `SupplierAgreementsSection` does. In create mode (`customerId == null`) it shows the after-save note and no controls (FR-007).

## R10 — Sales lines start at the discount (FR-013)

**Decision**: There is no code change. A regression test asserts that the capture step's `addLine` call passes no `discountRate`, so the server default from mbe-api ac68749 keeps applying. The live quickstart walks it end to end: add a discount, start an order for the customer, add the product, and expect the line at that rate.

**Rationale**: The only way this could break silently is if a later change starts sending `discount_rate: 0` from capture.

## R11 — Tests

- **Unit:**
  - `customer_repository_impl_test` (extended): the four discount methods, the request bodies including the String arm of `Discount`, and the error mapping.
  - `customer_discounts_controller_test` and `customer_discount_dialog_controller_test` (new): validation, create/update/delete, the R6 table, and invalidation.
  - `customer_form_controller_test` (extended): the family key.
- **Widget:**
  - `customer_discounts_section_test`: rows, empty state, the after-save note, and the rights matrix.
  - `customer_discount_dialog_test`: picker exclusion, the read-only product in edit mode, delete confirmation, and errors.
  - `customer_detail_screen_test` (extended): stay after create, and a create during a closing screen starts empty (#207).
  - Capture regression (R10).
- **Live:** `test/integration/customer_discounts_live_test.dart` discovers a customer and a product at runtime, then creates, updates and deletes a discount, checks a repeat gets 409, and cleans up.
- **Quickstart:** the walkthrough in [quickstart.md](./quickstart.md), including the sales-line check.
