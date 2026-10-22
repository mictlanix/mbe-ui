# UI Contracts: Supplier Sub-Panels

**Feature**: [spec.md](./spec.md) | **Wireframes**: [wireframes.md](../wireframes.md) | **Data model**: [data-model.md](../data-model.md)

These are the interfaces the new and changed widgets expose to one another, and to tests. The widget keys listed here are a contract: tests rely on them.

## C1. Routes

| Path | Screen | Mode |
|---|---|---|
| `/suppliers/new` | `SupplierDetailScreen()` | create |
| `/suppliers/:supplierId` | `SupplierDetailScreen(supplierId: id)` | edit, or view when the user lacks Suppliers Update |
| `/suppliers/:supplierId?view=true` | `SupplierDetailScreen(supplierId: id, forceReadOnly: true)` | view |

- All three are covered by the existing `PrivilegeGate(SystemObject.suppliers, AccessRight.read)`.
- The list pushes them. Row tap goes to view, the Edit icon to edit, and New to create. `showRecordSheet` is no longer used for suppliers.

## C2. `SupplierDetailScreen`

```dart
SupplierDetailScreen({Key? key, int? supplierId, bool forceReadOnly = false})
```

- **Title:** `newSupplierTitle`, `viewSupplierTitle` or `editSupplierTitle`. The `AppBar` has no actions (§VI).
- **Leaving:** `PopScope(canPop: false)` asks through `confirmDiscardChanges` when the form is dirty.
- **Hosts** `SupplierForm`, passing:
  - `onEditRequested: () => context.replace('/suppliers/$id')`
  - `onCreated: (id) => context.replace('/suppliers/$id')` (FR-015a)

## C3. `SupplierForm` (changed)

```dart
SupplierForm({Key? key, int? supplierId, bool forceReadOnly = false,
              VoidCallback? onEditRequested, ValueChanged<int>? onCreated})
```

- **After a save:**
  - A successful create calls `onCreated(supplierId)` when it is set, and pops otherwise.
  - An update or delete pops, as today.
- **Layout, top to bottom,** in one `ResponsiveFormGrid`:
  1. The six fields.
  2. A `Divider`.
  3. Addresses and Contacts, paired.
  4. A `Divider`.
  5. Bank accounts, full width.
  6. A `Divider`.
  7. Agreements, full width.
  8. `RecordFormActions`.
- **Keys:**
  - The existing ones stay.
  - The sections: `supplier_addresses_section`, `supplier_contacts_section`, `supplier_bank_accounts_section` and `supplier_agreements_section`.
  - The conflict banners: `supplier_save_conflict_banner` and `supplier_delete_conflict_banner`.

## C4. `LinkedRecordsSection<T>` usage (unchanged widget)

There are three instances, wired as in `customer_form.dart`.

| Section | `sectionId` | `T` | `labelOf` / `subtitleOf` | `searchExisting` when | `onCreateNew` when |
|---|---|---|---|---|---|
| Addresses | `addresses` | `AddressListItem` | label / address line (FR-002) | `can(addresses, read)` | `can(addresses, create)` → `showAddressInlineCreateDialog` |
| Contacts | `contacts` | `Contact` | name / job title · phone · email | `can(contacts, read)` | `can(contacts, create)` → `showContactInlineCreateDialog` |
| Bank accounts | `bank_accounts` | `BankAccount` | `bank · number` / reference | `can(bankAccounts, read)` | `can(bankAccounts, create)` → `showBankAccountInlineCreateDialog` |

`editable` = fields enabled. That means not read-only and the user has Suppliers Update or, in create mode, Create (FR-018 and FR-019).

## C5. `SupplierAgreementsSection` (new, `presentation/supplier_agreements_section.dart`)

```dart
SupplierAgreementsSection({Key? key, required int? supplierId, required bool readOnly})
```

- **When `supplierId == null`,** it shows the note `supplierAgreementsAfterSaveNote`, with key `supplier_agreements_after_save_note`, and no add control (FR-015).
- **Otherwise** it watches `supplierAgreementsControllerProvider(supplierId)` and renders the loading, `ListFailedView` (retry invalidates), empty-text or `DataTableView` state.
- **Columns:** Start, End and Notes, with Notes dropped on `LayoutTier.compact` (research R12).
- **Edit** is the only row action, as a `CatalogAction.edit` icon with key `edit_agreement_<id>`. It is shown only when `!readOnly && can(suppliers, update)`.
- **Add:** `FilledButton.icon` with key `add_agreement_button`, under the same condition.
- **Both** open `showSupplierAgreementDialog`.

## C6. `showSupplierAgreementDialog` (new)

```dart
Future<void> showSupplierAgreementDialog(BuildContext context,
    {required int supplierId, SupplierAgreement? existing})
```

- **Fields:** `agreement_start_field` and `agreement_end_field` (date pickers), and `agreement_comment_field` (≤ 500).
- **Actions:**
  - `agreement_save_button` is disabled until `canSubmit` (data model).
  - `agreement_cancel_button`.
  - `agreement_delete_button` appears in edit mode only. It asks for confirmation (key `confirm_delete_agreement_button`) and then deletes.
- **End before start** shows the error `supplierAgreementEndBeforeStartError` under the End field.
- **On success** the controller invalidates `supplierAgreementsControllerProvider(supplierId)` and the dialog pops.
- **On a server error** the dialog stays open with an `ErrorBanner`.

## C7. `showBankAccountInlineCreateDialog` (new)

```dart
Future<BankAccount?> showBankAccountInlineCreateDialog(BuildContext context)
```

- **Fields:** `bank_account_bank_name_field`, `bank_account_number_field`, `bank_account_reference_field`, `bank_account_routing_field` and `bank_account_comment_field`.
- **Returns** the created record, or `null` on cancel.
- **On failure** the dialog stays open with an `ErrorBanner`, and nothing is linked.
- **Structure:** the same as `contact_inline_create.dart`.

## C8. Generated client use (no regeneration)

The client already has everything this plan uses:
- `SuppliersApi`: get, create, update, delete, and `list/create/update/deleteAgreement…`.
- `BankAccountsApi`: `listBankAccountsApiV1BankAccountsGet` and `createBankAccountApiV1BankAccountsPost`.
- `SupplierCreate`/`SupplierUpdate`: `addresses`, `contacts` and `bankAccounts`, each `BuiltList<int>?`.

No mbe-api change is needed.
