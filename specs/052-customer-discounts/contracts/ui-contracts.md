# UI Contracts: Customer Discounts

**Feature**: [spec.md](../spec.md) | **Data model**: [data-model.md](../data-model.md) | **Research**: [research.md](../research.md)

These are the interfaces the new and changed widgets expose to one another, and to tests. The widget keys listed here are a contract: tests rely on them.

## C1. `CustomerDetailScreen` (changed)

- **Unchanged:** routes, title logic and the dirty-leave guard.
- **New:** it passes `onCreated: (id) => context.replace('/customers/$id')` to `CustomerForm` (FR-007a). An update and a delete still pop to the list.

## C2. `CustomerForm` (changed)

```dart
CustomerForm({Key? key, int? customerId, bool forceReadOnly = false,
              VoidCallback? onEditRequested, ValueChanged<int>? onCreated})
```

- **Provider:** reads `customerFormControllerProvider(widget.customerId)`, which is now a family (R8).
- **After a save:** a successful create calls `onCreated(customerId)` when it is set, and pops otherwise. The `_snapshot != null` guard is copied from `SupplierForm`.
- **Layout:** after the Taxpayers section, and the generic-taxpayer note when present, it adds `Divider` → `CustomerDiscountsSection(customerId: widget.customerId, readOnly: readOnly)`, full width, before `RecordFormActions`.

## C3. `CustomerDiscountsSection` (new)

```dart
CustomerDiscountsSection({Key? key, required int? customerId, required bool readOnly})
```

| State | Renders |
|---|---|
| `customerId == null` | Title plus the note `customerDiscountsAfterSaveNote`, with no controls (FR-007) |
| Loading or error | A spinner, or `ListFailedView` with retry that invalidates the family |
| Empty | `customerDiscountsEmpty` |
| Rows | `DataTableView<CustomerDiscount>` with columns Code (S), Product (L) and Discount (S). Discount renders as `fmt.display.percent(d.discount)` and is right-aligned |

- **Header:** the same as the linked-record sections above it: a row with the title, counted as `Descuentos (n)` once the list has rows, and a `TextButton.icon` with the shared `linkedRecordNewAction` label ("Nuevo") at the end. The empty and after-save lines use the same muted small text. (Changed 2026-10-24 after review: the first build used a filled "Agregar descuento" button beside the title, which stood out from the other sections.)
- **Add button** `add_customer_discount_button`: shown only when the customer is saved, the discounts list has loaded, `!readOnly`, and the user has Customers Update **and** Products Read (R5, R9). While the list is loading or failed it's hidden, so the product exclusion is always complete.
- **Spacing:** every gap comes from `Theme.of(context).spacing`, not literals (constitution §V). The same applies to the dialog in C4.
- **Row actions:** `buildCatalogRowActions` with Edit only, key `edit_customer_discount_${id}`. Shown only when `!readOnly` and the user has Customers Update.
- **Compact tier:** drops the Code column and shows the code as a prefix in the Product cell (`code · name`), so the product stays identifiable.
- **Section keys:** `customer_discounts_section`, `customer_discounts_table`, `customer_discounts_after_save_note`.

## C4. `showCustomerDiscountDialog` (new)

```dart
Future<void> showCustomerDiscountDialog(BuildContext context, {
  required int customerId,
  required Set<int> takenProductIds,   // product ids already in the section
  CustomerDiscount? existing,          // null = add
})
```

- **Title:** `newCustomerDiscountDialogTitle` or `editCustomerDiscountDialogTitle`.
- **Product:**
  - Add mode: `CatalogEntityPicker<ProductListItem>` with key `customer_discount_product_field`. It searches active products and drops `takenProductIds` (R5). The option row shows `name` with a `code` subtitle and a thumbnail.
  - Edit mode: a read-only `InputDecorator` with the same key that shows `code — name` (FR-008).
- **Percentage:** `TextFormField`, key `customer_discount_percent_field`, with a `%` suffix and `TextInputType.numberWithOptions(decimal: true)`. The error text is the localized `percentError` (R4), or the server's `fieldErrors['discount']`.
- **Error banner:** above the fields when `error != null`. It names the R6 case: `customerDiscountDuplicateError`, `customerDiscountProductMissingError`, `customerDiscountMissingError`, or the generic save or delete message with the server detail.
- **Actions:**
  - Delete, key `customer_discount_delete_button`, in edit mode only and leftmost. It goes through `showRecordDeleteConfirmation` with `deleteCustomerDiscountConfirmMessage(code, name)` and confirm key `confirm_delete_customer_discount_button` (FR-009).
  - Cancel, key `customer_discount_cancel_button`.
  - Save, key `customer_discount_save_button`, enabled only when `canSubmit`.
- **On success:** the controller invalidates `customerDiscountsControllerProvider(customerId)` and sets `done`, and the dialog pops.

## C5. `CustomerRepository` (changed)

There are four new methods, listed in [data-model.md](../data-model.md#repository-additions-customerrepository). Their request bodies are:
- **POST:** `CustomerDiscountCreate(product, discount)`.
- **PUT:** `CustomerDiscountUpdate(discount)`.
- In both, `discount` is set through `_setDiscount(b.discount, fraction)`, which sends the String arm of the `anyOf`.

## C6. Localization (both `.arb` files)

The new keys are listed below, with Spanish first and English second.

| Key | es | en |
|---|---|---|
| `customerDiscountsSection` | Descuentos | Discounts |
| `customerDiscountsEmpty` | Sin descuentos por producto. | No product discounts. |
| `customerDiscountsAfterSaveNote` | Los descuentos se pueden agregar después de guardar el cliente. | Discounts can be added once the customer is saved. |
| `customerDiscountColumnCode` | Código | Code |
| `customerDiscountColumnProduct` | Producto | Product |
| `customerDiscountColumnDiscount` | Descuento | Discount |
| `newCustomerDiscountDialogTitle` | Nuevo descuento | New discount |
| `editCustomerDiscountDialogTitle` | Editar descuento | Edit discount |
| `customerDiscountProductLabel` | Producto | Product |
| `customerDiscountPercentLabel` | Descuento (%) | Discount (%) |
| `customerDiscountPercentRequiredError` | Ingresa un porcentaje. | Enter a percentage. |
| `customerDiscountPercentInvalidError` | Ingresa un número, p. ej. 12.5. | Enter a number, e.g. 12.5. |
| `customerDiscountPercentOutOfRangeError` | Debe estar entre 0 y 100. | Must be between 0 and 100. |
| `customerDiscountPercentTooPreciseError` | Máximo 6 decimales. | At most 6 decimal places. |
| `customerDiscountDuplicateError` | Este cliente ya tiene un descuento para ese producto. | This customer already has a discount on that product. |
| `customerDiscountProductMissingError` | El producto ya no existe. | The product no longer exists. |
| `customerDiscountMissingError` | Este descuento ya no existe. | This discount no longer exists. |
| `customerDiscountSaveFailedError` | No se pudo guardar el descuento. | The discount could not be saved. |
| `customerDiscountDeleteFailedError` | No se pudo eliminar el descuento. | The discount could not be removed. |
| `deleteCustomerDiscountButton` | Eliminar | Remove |
| `deleteCustomerDiscountConfirmTitle` | Eliminar descuento | Remove discount |
| `deleteCustomerDiscountConfirmMessage(code, name)` | ¿Eliminar el descuento sobre {code} — {name}? Las partidas ya capturadas conservan su descuento. | Remove the discount on {code} — {name}? Lines already entered keep their discount. |

## C7. Generated client (unchanged)

The client already has `CustomersApi` list, create, update and delete for discounts, plus `CustomerDiscountCreate`, `CustomerDiscountUpdate`, `CustomerDiscountResponse`, `Discount` and `ProductSummary` (mbe-api #251 and #253, both merged 2026-10-22). Task T001 regenerates once as a drift check and expects no diff.
