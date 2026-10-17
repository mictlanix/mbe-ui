# Research: Catalog Improvements (046)

Every decision below rests on an audit of mbe-ui, mbe-api and the legacy `mbe` docs carried out on 2026-10-16; file references are mbe-ui paths unless noted otherwise. No backend change is needed: every decision uses endpoints and fields that already exist in the generated client.

## R1 — Customer surface stays the shared side panel *(superseded 2026-10-17 — see R16)*

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
  
  The provider's `FacilityType facilityType` family parameter is dropped too, so the provider is keyed by `facilityId` alone. Once the gate is gone the type changes nothing about what is fetched, and keeping it in the key would only cause a pointless refetch on a type change. Callers update to match, notably `facility_form_controller.dart:199-201` `_invalidateOwnChildren`.
- **Rationale**: mbe-api never enforced the rule (spec 018 research §2). The forms for points of sale and cash drawers already accept any facility.
- **Tests to invert**:
  - `facilities_list_screen_test.dart:342`: now expect all three sections and no note.
  - `facility_children_controller_test.dart:149-178`: now expect all three fetches, with the single-key provider.
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

## R15 — Code-generator upgrade (added during implementation, 2026-10-17)

- **Why**: `build_runner` could not run on the installed toolchain. The locked `analyzer` 7.6.0 understands language 3.9 only; Flutter 3.47.7 / Dart 3.13 ship framework code with dot shorthands, which made the analyzer crash (`Missing implementation of visitDotShorthandPropertyAccess`). No `@freezed`/`@riverpod` change could be generated by anyone. The user chose to upgrade the generators rather than run codegen on an older Flutter.
- **Versions**: `flutter_riverpod` ^3.4.3, `riverpod_annotation` ^4.0.7, `riverpod_generator` ^4.0.9, `freezed` ^4.0.2, `freezed_annotation` ^3.1.0, `build_runner` ^2.16.2, `json_serializable` ^6.14.1. The generated OpenAPI client is untouched.
- **Mechanical migration**:
  - 120 freezed classes marked `abstract` (single-shape; the one union, `AppError`, was already `sealed`). `when`/`map` remain available (freezed 3.1+).
  - Typed provider refs (`FooRef ref`) became `Ref ref`; `valueOrNull` became `value`.
  - `StateProvider` now comes from `flutter_riverpod/legacy.dart`; `Override`/`ProviderListenable` from `flutter_riverpod/misc.dart`.
  - `AuthNotifier`'s provider is now `authProvider` (riverpod_generator 3+ strips a `Notifier` suffix by default).
- **Behavior decisions**:
  - **Automatic retry is off**, at the app root (`main.dart`) and in every test scope. Riverpod 3 retries a failing provider up to 10 times by default; the app surfaces failures at once with an explicit Retry (constitution §III), so this keeps today's behavior.
  - **Async writes keep their notifier alive** (`ref.keepAlive()` for the duration): the sale/quote editors' `tracked` and `ensureOpen`, the delivery controller's `_tracked`, and the close-session submit. Riverpod 3 forbids using a disposed provider's ref; riverpod 2 silently dropped such writes, and in these flows the write's result (an opened sale, a created destination, the post-close refresh) must still land.
  - **Late writes are dropped safely** where nothing should survive: `UnconfirmedEdits.remove` checks `ref.mounted`, and `TrackedEditing.publish` skips a write to an already-disposed editor.
  - `productLookupController` watches its repository before its `await`.
- **Not caused by this work** (left for the team): golden/screenshot pixel diffs of 0.00–0.02% (Flutter 3.47 rendering), `repository_list_params_audit_test` (the generated products client gained `perishable`/`seriable`/`invoiceable` filters), and the live `auth_flow_test` (the dev backend answers a wrong password with 500).

## As-built notes (2026-10-17)

- **R3**: create sends a link list only when it is non-empty (`null` otherwise), keeping the POS rule that an unset RFC is never sent as `[]`; update always sends the complete lists, which is how the last link is removed.
- **R11**: with the `facilityType` key gone, the warehouse, point-of-sale and cash-drawer form controllers no longer fetch the facility just to invalidate its children.
- **R13**: the tap target is a `GestureDetector` + click cursor (no `Material` ancestor needed in a table cell). The close button reuses the existing `documentCloseTooltip` string, so no preview strings were added. `product_photo_preview.dart` is a documented golden exclusion (network image only).
- **C1**: keys are built from a stable `sectionId` (`addresses`, `contacts`, `taxpayers`): `linked_new_<section>`, `linked_picker_<section>_<n>`, `linked_row_<section>_<id>`, `unlink_<section>_<id>`; the picker is boxed (with its "Link an existing …" label) rather than bare.
- **R14, amended 2026-10-17**: at the product owner's request the thumbnail inset is a 1.2 px literal on all four sides (photo ≈ 41.6 px, column ≈ 44 px), a recorded exception to §VI's token rule (plan, Complexity Tracking). The detail screen's 8 px padding is unchanged.
- **Tests**: a shared `test/helpers/network_image_stub.dart` serves a real 1×1 PNG to `Image.network`, so tests can reach a photo's loaded state.

## R16 — Customer form on its own screen (2026-10-17, supersedes R1)

- **Decision**: Customers get a full detail screen, `CustomerDetailScreen`, on `/customers/new` and `/customers/:customerId` (`?view=true` for read-only), hosting the same `CustomerForm`. The list pushes those routes instead of opening `showRecordSheet`; `/customers` leaves the spec 035 legacy-redirect list.
- **Rationale**: The product owner found the form, with its three linked-record sections, too much for a 640 px panel. Constitution §VI was amended (v1.13.3, PATCH) to list Customers among the full-screen entities; DESIGN.md §4.2 records the same move.
- **Details**:
  - Edit on the read-only screen replaces the route with the edit route, so the AppBar title follows the mode (the Facilities pattern); `CustomerForm.onEditRequested` carries that, and `didUpdateWidget` follows a changed `forceReadOnly`, since the router keeps the same widget across the replace.
  - Back navigation with unsaved edits shows the same discard prompt the panel did (spec US1 scenario 7), now the shared `confirmDiscardChanges` in `core/widgets/app_side_sheet.dart`.
  - With the wider surface, Addresses and Contacts pair side by side on wide tiers; Tax recipients stays full width.

