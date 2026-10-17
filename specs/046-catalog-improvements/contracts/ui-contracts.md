# UI Contracts: Catalog Improvements (046)

## C1 — `LinkedRecordsSection<T>`

**File:** `lib/features/catalog/presentation/widgets/linked_records_section.dart`

```text
LinkedRecordsSection<T extends Object>({
  required String title,                       // "Direcciones" / "Contactos" / "Receptores fiscales"
  required List<T> items,                      // currently linked
  required Object Function(T) idOf,            // used for dedupe and keys
  required String Function(T) labelOf,
  String? Function(T)? subtitleOf,
  bool Function(T)? isInactive,                // shows the shared status badge
  required bool editable,                      // false → no remove/link/new
  // link-existing (null hides the picker)
  Future<Iterable<T>> Function(String query)? searchExisting,
  ValueChanged<T>? onLinked,
  ValueChanged<T>? onUnlinked,
  // create-new (null hides the button)
  Future<T?> Function()? onCreateNew,
  String emptyText,                            // shown when items is empty
})
```

**Behavior:**

- **Header.** Shows `title`, and `(n)` when there are items. The section sits behind the shared M3 divider.
- **Rows.** One `ListTile`-density row per item:
  - the label;
  - the subtitle, if `subtitleOf` returns one;
  - an inactive badge, if `isInactive` returns true;
  - a trailing remove `IconButton` when `editable`, with tooltip "Desvincular" and key `ValueKey('unlink-<id>')`.
- **Link existing.** Shown when `editable` and `searchExisting != null`. Renders a `bare` `CatalogEntityPicker<T>`. Its `optionsBuilder` filters out ids already in `items`. Selecting an option calls `onLinked`, then clears the picker text.
- **Create new.** Shown when `editable` and `onCreateNew != null`. Renders a `TextButton.icon(Icons.add)` labelled "Nuevo". When the returned future completes with a non-null value, the section calls `onLinked(value)`.
- **Empty and read-only.** With no items, the section shows `emptyText`. When read-only, it shows only the header, the rows (with no remove icon) and the empty text.
- **Styling.** All padding comes from `Spacing` tokens. The section does no I/O itself.

**Instances inside `CustomerForm`.** These are full-width rows after `comment` and before `EntityStatusFormField`. The old `taxpayer_field` picker is removed from the grid.

| Section | Search | Create | Gate for search / create |
|---|---|---|---|
| Addresses | `addressRepository.list(search:, status: active).items` | `showAddressInlineCreateDialog` | `addresses` read / create |
| Contacts | `contactRepository.list(search:)` | `showContactInlineCreateDialog` | `contacts` read / create |
| Taxpayers | `taxpayerRecipientRepository.list(search:).items` | `showTaxpayerRecipientInlineCreateDialog` (C2) | `taxpayerRecipients` read / create |

`editable` is the form's existing `!readOnly` (see research R8). Labels and subtitles:

| Section | Label | Subtitle |
|---|---|---|
| Address | `label` | none |
| Contact | `name` | `displayLabel` number / email |
| Taxpayer | RFC | name |

## C2 — `showTaxpayerRecipientInlineCreateDialog`

**File:** `lib/features/catalog/presentation/taxpayer_recipient_inline_create.dart`

```text
Future<TaxpayerRecipientListItem?> showTaxpayerRecipientInlineCreateDialog(BuildContext context)
```

- Opens a `Dialog`, max width 640, scrollable, hosting `TaxpayerRecipientForm()` in create mode.
- When the form saves, it pops with `TaxpayerRecipient?`, which the dialog maps to a list item.
- Cancel or dismiss returns null.

## C3 — `ProductPhoto` (amended)

**File:** `lib/core/widgets/product_photo.dart`

```text
ProductPhoto({Key? key, String? photoUrl, double size = 84, VoidCallback? onTap})
```

- When `onTap != null` and the photo's first frame has decoded, the image is wrapped in an `InkWell` with `SystemMouseCursors.click`.
- The placeholders (null URL or load error) never respond to taps.
- Existing behavior is unchanged when `onTap` is null.

## C4 — `showProductPhotoPreview`

**File:** `lib/core/widgets/product_photo_preview.dart`

```text
Future<void> showProductPhotoPreview(BuildContext context, {required String photoUrl, required String title})
```

- A `Dialog` with a header row: the `title` (ellipsized, with a tooltip) and a close `IconButton`, keyed `Key('photo_preview_close')`.
- Body: `Image.network(photoUrl, fit: BoxFit.contain)` inside constraints of about 90% of the viewport's width and height. If loading fails, it shows the same placeholder as `ProductPhoto`.
- Closes on Escape, a barrier tap or the close button.

**Call sites:**
- `products_list_screen.dart` photo cell: `onTap: p.photo == null ? null : () => showProductPhotoPreview(context, photoUrl: p.photo!, title: p.name)`
- `product_detail_screen.dart` `_thumbnail()`: the saved-photo branch only.

## C5 — Product list photo cell

- **Size:** `size = (density.tableDataRowHeight ?? 44) - 2 * spacing.xxs`.
- **Padding:** `symmetric(vertical: spacing.xxs, horizontal: spacing.xs)`, centered.
- **Column width:** `fixedWidth = size + 2 * spacing.xs`.
- The row height stays the shared table value.

## C6 — Facilities

- **`FacilityCard`.** Every type renders the badges and the sections for Warehouses, Points of Sale and Cash Drawers. The `productionSiteChildrenNote` text and its arb key are removed. The type icon and label stay.
- **`facility_children_controller`.** Fetches all three child lists for every type, gated only by RBAC read. Keyed by `facilityId` only; the `facilityType` family parameter is removed.
- **es arb.** `facilityTypeProductionSite` changes to "Planta".

## C7 — Endpoints consumed

No new endpoints, and no codegen run is needed.

| Endpoint | Change in usage |
|---|---|
| `PUT /customers/{id}`, `POST /customers` | Now always send `addresses`, `contacts` and `taxpayers` as complete id lists. |
| `GET /addresses` | Now called with `status` from the address picker. |
| `GET /contacts`, `GET /taxpayer-recipients`, `POST /addresses`, `POST /contacts`, `POST /taxpayer-recipients` | Already used. Now also reached from the customer form. |
| `GET /point-sales?facility=`, `GET /cash-drawers?facility=` | Now called for production sites too. |
