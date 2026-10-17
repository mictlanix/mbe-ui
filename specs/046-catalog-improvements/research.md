# Research: Catalog Improvements (046)

Every decision below rests on an audit of mbe-ui, mbe-api and the legacy `mbe` docs carried out on 2026-10-16; file references are mbe-ui paths unless noted otherwise. No backend change is needed: every decision uses endpoints and fields that already exist in the generated client.

## R1 — Customer surface stays the shared side panel

- **Decision**: The three link sections go inside the existing `CustomerForm`, which `showRecordSheet` opens as a 640 px side sheet. Customers do not get a full detail screen.
- **Rationale**: §VI names Customers explicitly as a panel entity, and the full detail screen is reserved for entities with nested child collections. Addresses, contacts and taxpayers are shared records that a customer only links to (many-to-many), not children the customer owns. They also have no per-record CRUD on this surface (see R6), so the sections behave like multi-value fields, which a panel form can hold. The sheet already scrolls, gives a full-width bottom sheet on Compact, and handles the dirty check.
- **Alternatives considered**: Promoting Customers to a full detail screen. Rejected because it needs a §VI amendment, a new route, and moving `customers_list_screen.dart` back off the sheet that spec 035 introduced, all for three lists.

## R2 — One generic `LinkedRecordsSection<T>` widget, used three times

- **Decision**: A new catalog-presentation widget, `lib/features/catalog/presentation/widgets/linked_records_section.dart`, made up of:
  - a section header with the label and count;
  - one row per linked record (label, optional subtitle, optional "inactive" badge, and a remove icon when editable);
  - a "link existing" `CatalogEntityPicker` (in `bare` mode) whose options leave out records that are already linked;
  - a "New" `TextButton.icon` that calls the caller's async create callback.
  It performs no I/O of its own. Everything reaches it through callbacks.
- **Rationale**: The three sections have the same shape. A single generic widget keeps them identical, and its tests cover all three. It lives in `features/catalog/` rather than `core/widgets/` because customers are its only consumer. It can be promoted to `core/widgets/` later if suppliers adopt it (R10).
- **Alternatives considered**:
  - Reusing the POS `showCustomerAddressPicker` and `showCustomerContactPicker`. Rejected: they belong to the sales feature, read `saleCustomerControllerProvider`, persist the link immediately, and cannot unlink, so they would break FR-005, where link changes wait for Save.
  - Three hand-written sections. Rejected as triplicated code.

## R3 — Link changes are form state and are sent on Save as replace-all lists

- **Decision**:
  - `CustomerFormState` replaces `taxpayerId`/`taxpayerDisplayText` with `List<TaxpayerRecipientListItem> taxpayers`, and gains `List<AddressListItem> addresses` and `List<Contact> contacts`.
  - `loadForEdit` seeds all three lists from `GET /customers/{id}`.
  - Both `submitCreate` and `submitUpdate` always send all three id lists. The API treats each list as replace-all: `[]` unlinks everything and `null` leaves the links unchanged.
- **Rationale**:
  - **Fixes the multi-RFC data loss.** Today `_taxpayersOf` sends only the first RFC; sending the full list keeps every link (FR-006).
  - **Dirty check for free.** The freezed equality used by `isDirty()` covers the new lists automatically, so cancelling throws link changes away (FR-005).
  - **Safe to always send.** The edit path always loads the record first, so the lists are complete before Save.
- **Alternatives considered**: Sending only the lists that changed (`null` otherwise). Rejected: more state for no benefit, because a full list that did not change has the same effect as `null`.

## R4 — The POS quick-create keeps its single taxpayer picker

- **Decision**:
  - `customer_inline_create.dart` (POS and quotes) keeps its one-RFC picker. Its controller method `taxpayerSelected(id, name)` now replaces the list with exactly `[item]`.
  - The picker's `initialDisplayText` is derived from `taxpayers.firstOrNull`.
  - The full form uses the new `taxpayerAdded(item)` and `taxpayerRemoved(id)` methods.
- **Rationale**: The POS form is a create-only quick form, and one RFC is enough there. Changing it is outside this spec. The shared controller (`ref.invalidate(customerFormControllerProvider)` in the POS) keeps working.
- **Alternatives considered**: Putting `LinkedRecordsSection` in the POS dialog too. Rejected as scope creep.

## R5 — Creating a record from a section persists it immediately, but the link waits for Save

- **Decision**:
  - "New address" calls the existing `showAddressInlineCreateDialog`, which returns an `AddressListItem?`.
  - "New contact" calls `showContactInlineCreateDialog`, which returns a `Contact?`.
  - "New taxpayer" calls a new `showTaxpayerRecipientInlineCreateDialog`, described in R7.
  - Each of these creates the record on the server. The section then adds the returned item to the form's list, and the link is written when the customer is saved.
- **Rationale**: This reuses the dialogs already in the app. The edge case where the user creates a record and then cancels the customer is spelled out in the spec: the record remains unlinked and can be found again with "link existing", so no duplicate is created silently.
- **Alternatives considered**: Deferring record creation until the customer Save. Rejected because it would need a multi-step transaction on the client and new draft-entity plumbing.

## R6 — No in-place editing; unlinking never deletes

- **Decision**: Neither the rows nor the sections offer edit or delete. The address and contact repositories stay `list` + `create` only.
- **Rationale**: The user decided this on 2026-10-16 (spec, Clarifications and FR-009). Shared records also feed past orders and their reprints.

## R7 — Taxpayer inline create reuses `TaxpayerRecipientForm` inside a dialog

- **Decision**:
  - `TaxpayerRecipientFormState` gains `TaxpayerRecipient? created`, which `submitCreate` fills from the repository's return value.
  - When `TaxpayerRecipientForm` saves, it calls `Navigator.pop(state.created)`.
  - A new `showTaxpayerRecipientInlineCreateDialog(context) → Future<TaxpayerRecipientListItem?>` hosts the form inside a `Dialog` (max width 640). This is the same frame as `showAddressInlineCreateDialog`, and it maps the result to the list item.
- **Rationale**: The form has SAT postal-code and tax-regime pickers that should not be duplicated. Passing a value to `pop` changes nothing for the existing caller, `showRecordSheet` (`Future<void>`), which ignores it. A dialog avoids stacking a second side sheet on top of the customer sheet.
- **Alternatives considered**:
  - A new, slimmer taxpayer dialog. Rejected because it would duplicate the SAT pickers.
  - A nested `showRecordSheet`. Rejected because two right-anchored sheets on top of each other read badly.

## R8 — Permissions (§IV)

- **Decision**:
  - **Sections editable**: the form is not read-only (the existing `readOnly` flag, driven by `customers` update on edit and create on create).
  - **"Link existing" shown**: the sections are editable and the user has `can(<obj>, read)`.
  - **"New" shown**: the sections are editable and the user has `can(<obj>, create)`.
  - `<obj>` is one of `SystemObject.addresses (11)`, `contacts (12)` or `taxpayerRecipients (54)`.
  - Actions the user lacks permission for are hidden, not disabled.
- **Rationale**: This mirrors the server, where creating a record in `/addresses` requires address create, while linking it is part of the customer update. No new `SystemObject` is needed.

## R9 — Inactive addresses

- **Decision**:
  - `AddressListItem` gains `EntityStatus status`, mapped from `AddressResponse.status`, which the API already returns.
  - `AddressRepository.list` gains an optional `EntityStatus? status` parameter, which the API already supports as `status`.
  - The "link existing" options are requested with `status: active`.
  - Linked rows whose status is inactive show the shared `EntityStatus` badge.
- **Rationale**: Covers the inactive-address edge case in the spec with fields the API already provides. Contacts and taxpayer recipients have no status.

## R10 — Out of scope (confirmed during the audit)

The following are excluded:

- **Customer discounts**: the `customer_discount` model exists, but no schema or endpoint does.
- **Legacy `shipping` and `shipping_required_document` flags**: not in the API at all.
- **Supplier address, contact and bank-account links**: the tables exist but have no API.
- **Zone and credit columns in the customer list.**
- **Customer balance.**

Adding discounts or shipping would first need an mbe-api issue (§III). No issue is filed by this spec, because the user has not asked for those features.

## R11 — Production-site restriction removal

- **Decision**: Drop every `isStore` gate on children:
  - `facility_children_controller.dart:40-49`: fetch points of sale and cash drawers for every type, still gated by `can(..., read)`.
  - `facility_card.dart:326-348` (badges), `:457-513` (sections) and `:521-545` (note).
  
  Also delete the arb key `productionSiteChildrenNote` from both arb files and regenerate the committed `app_localizations*.dart` with `flutter gen-l10n`.
  
  Keep the type icon and label (`:172-177`, FR-013). The `isStore` local disappears wherever it is no longer used.
- **Rationale**: mbe-api never enforced the rule (spec 018 research §2). The forms for points of sale and cash drawers already accept any facility.
- **Tests to invert**:
  - `facilities_list_screen_test.dart:342`: now expect all three sections and no note.
  - `facility_children_controller_test.dart:149-178`: now expect all three fetches.
  - `facility_children_controller_live_test.dart:88-93`: drop the assertion that the production site's lists are empty.

## R12 — "Planta"

- **Decision**: Change `app_es.arb:604` `facilityTypeProductionSite` from "Sitio de producción" to "Planta". Leave English unchanged (spec, Assumptions). The `@` metadata stays only in the English template.
- **Rationale**: This is the only Spanish occurrence once the note key is gone (R11), which satisfies SC-004.

## R13 — Photo preview: `ProductPhoto.onTap` plus `showProductPhotoPreview`

- **Decision**:
  - `ProductPhoto` gains `VoidCallback? onTap`. When it is set and a URL is present, the image is wrapped in `Image.network(frameBuilder:)`. Once the first frame has decoded (`frame != null`), the child is wrapped in an `InkWell` with a click cursor.
  - The `errorBuilder` placeholder and the null-URL placeholder are never wrapped, so failed or missing photos cannot be tapped (FR-017). The widget stays stateless.
  - A new `lib/core/widgets/product_photo_preview.dart` provides `showProductPhotoPreview(context, {required String photoUrl, required String title})`. It shows a `Dialog` containing:
    - a title row with the product name and a close `IconButton`;
    - an `Image.network(fit: BoxFit.contain)` constrained to about 90% of the viewport, keeping the aspect ratio;
    - the same `errorBuilder` placeholder, used when loading fails inside the dialog.
    
    Escape, a barrier tap and the close button all dismiss it (FR-015).
- **Call sites**:
  - The photo cell in `products_list_screen.dart:128-132`.
  - The saved-photo branch of `product_detail_screen.dart` `_thumbnail()`. A photo picked but not yet uploaded (`pendingPhotoBytes`) is not previewable.
  - No other `ProductPhoto` call site changes, because `onTap` defaults to null.
- **Row-tap isolation (FR-016)**: An `InkWell` inside the cell content wins the gesture arena over data_table_2's `TableRowInkWell`. The code column's in-cell `IconButton` (`products_list_screen.dart:133-153`) already relies on this. No `DataTableView` change is needed.
- **Alternatives considered**:
  - Adding a `DataCell.onTap` hook to `DataTableView`. Rejected as unnecessary API surface.
  - Reusing the document `InteractiveViewer`. Rejected because zoom is out of scope (spec, Assumptions).
  - A stateful `ProductPhoto` that tracks errors. Rejected because `frameBuilder` gives the same result without state.

## R14 — Thumbnail spacing: fit the photo inside the row, don't grow the row

- **Decision**: The list photo is sized from the row height:
  - The photo is `size = (density.tableDataRowHeight ?? 44) - 2 * spacing.xxs`, which is 36 px at pointer density.
  - It is wrapped in `Padding(EdgeInsets.symmetric(vertical: spacing.xxs, horizontal: spacing.xs))` and centered in its column.
  - The column's `fixedWidth` shrinks from 120 to `size + 2 * spacing.xs` (52 px at pointer density), which gives room back to the text columns.
  
  Today the 84 px photo is clamped by the 44 px row, so it touches both borders. On the detail screen, the 168 px thumbnail gets `spacing.xs` padding so it never touches the button column (FR-019).
- **Rationale**:
  - §VI requires identical row behaviour across all shared tables and spacing taken from tokens. A per-table row height would break both.
  - Symmetric vertical padding is a §VI rule that tests can measure.
  - Now that a larger view is one click away (R13), a smaller thumbnail is acceptable.
- **Alternatives considered**:
  - A per-table `dataRowHeight` override (`DataRow2.specificRowHeight`). Rejected: it breaks table uniformity and makes the product list much taller.
  - Padding the photo but keeping it at 84 px. Rejected: it would still be clipped.
- **Test impact**: `products_list_screen_test.dart:295-312` asserts `size == 84`. That test changes to assert the derived size, plus measured symmetric insets (§VI measuring-test rule).
