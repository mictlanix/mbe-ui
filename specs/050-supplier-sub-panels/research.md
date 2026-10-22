# Research: Supplier Sub-Panels

**Feature**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md) | **Date**: 2026-10-22

Each entry gives the decision, why it was made, and what was rejected. The paths come from the codebase survey done during planning.

---

## R1. Record surface: a full detail screen

- **Decision.** Suppliers move from the side panel to a full detail screen. It is a `SupplierDetailScreen` built on the same pattern as `CustomerDetailScreen` (`lib/features/catalog/presentation/customer_detail_screen.dart`).
- **Rationale.** Constitution v1.14.0 §VI requires a full detail screen for any entity with linked-record sections, and Suppliers gains four of them (Clarifications Q1).
- **Dependency.** The v1.14.0 amendment is on branch `docs/record-surface-criteria` and has not merged. Under v1.13.3, the move contradicts §VI's enumerated panel list. That amendment must merge before this feature does.
- **Alternatives considered.** Keeping the 640 px panel was rejected in the spec's clarification.

## R2. Routes

- **Decision.** Add top-level `GoRoute`s `/suppliers/new` and `/suppliers/:supplierId` (with `?view=true` for read-only), mirroring `app_router.dart:386-396` for customers. The list screen switches its three `_openSupplierSheet` call sites (`suppliers_list_screen.dart:86-92`, `:144-149`, `:150-158`) to `context.push(...)`, as the customers list does (`customers_list_screen.dart:75-76`, `:155-161`). `_openSupplierSheet` is then removed.
- **Rationale.** This is the existing pattern. The `PrivilegeGate` at `app_router.dart:646` uses `startsWith('/suppliers')`, so it already covers the new paths.
- **Alternatives considered.** Nesting the routes under the shell branch. Customers chose top-level routes so that the detail screen gets its own `AppBar` and back button; suppliers should match.

## R3. Form state and saving the links

- **Decision.** `SupplierFormState` gains three lists:
  - `@Default([]) List<AddressListItem> addresses`
  - `@Default([]) List<Contact> contacts`
  - `@Default([]) List<BankAccount> bankAccounts`

  `SupplierFormController` gains add and remove methods for each, mirroring `customer_form_controller.dart:150-178`: each one de-duplicates by id and clears errors. When saving:
  - `submitUpdate` always sends all three id lists. Replace-all is the server contract, and `[]` clears the last link.
  - `submitCreate` sends a list only when it is non-empty, the same `_orNullList` rule customers use.

  The repository sets `SupplierCreate/SupplierUpdate.addresses/contacts/bankAccounts` as `ListBuilder<int>`. Those fields already exist in the generated models.
- **Rationale.** This keeps the customer behaviour identical (FR-008) and reuses the entity factories `AddressListItem.fromResponse` and `Contact.fromResponse`.
- **Alternatives considered.** Sending a list only when it changed. That is a riskier diff to compute, and replace-all of the full list is already proven on customers.

## R4. Agreements live in their own provider, not in the form state

- **Decision.** Add a `supplierAgreementsControllerProvider(int supplierId)` family that loads `GET /suppliers/{id}/agreements` (`listAgreementsApiV1SuppliersSupplierIdAgreementsGet`) and sorts by `start` descending (FR-016). The agreements embedded in `SupplierDetailResponse` are **not** mapped.
  - The agreement dialog's controller calls create, update or delete, then invalidates that family. This is the certificates pattern: `taxpayer_certificate_upload_controller.dart:110`.
- **Rationale.** Agreement changes take effect at once (FR-012), while link changes wait for Save (FR-008).
  - If agreements lived in the form state and the supplier were reloaded after each agreement change, the reload would throw away unsaved field and link edits.
  - A separate provider refreshes only the Agreements section.
- **Alternatives considered.**
  - Seeding the provider from the embedded list to save one request. Rejected: it gives two sources of truth for the same data, for a saving of one small request.
  - Mapping agreements into `Supplier`, which is unneeded once they have their own provider.

## R5. Staying on the page after create

- **Decision.**
  - `SupplierFormController.submitCreate` stores the created id in `supplierId`, as customers already do (`customer_form_controller.dart:317-321`).
  - `SupplierForm` gains an optional `ValueChanged<int>? onCreated`. When a create succeeds and `onCreated` is set, the form calls it instead of `Navigator.pop()`.
  - `SupplierDetailScreen` passes `onCreated: (id) => context.replace('/suppliers/$id')`, which reopens the screen in edit mode with Agreements enabled (FR-015a).
  - Updates and deletes still pop (`supplier_form.dart:89-93`).
- **Rationale.** This is the smallest change that keeps the existing pop behaviour for update and delete. `replace` rather than `push` means Back returns to the list, not to an empty "New" form.
- **Alternatives considered.** A `stayAfterCreate` flag in the state. It is a callback in disguise and harder to test.

## R6. Bank accounts: entity, repository, inline-create dialog

- **Decision.** Add the following in `features/catalog`:
  - `domain/entities/bank_account.dart`: `BankAccount` with `bankAccountId`, `bankName`, `accountNumber`, `reference?`, `routingNumber?` and `comment?`, plus `fromResponse`.
  - `domain/repositories/bank_account_repository.dart` and `data/bank_account_repository_impl.dart`, with `list({search, skip, limit})` and `create(...)`. They mirror `address_repository_impl.dart:14-81`, use `BankAccountsApi(dio, appSerializers)`, and map errors through `_toAppError`. The list endpoint has no status filter.
  - `presentation/bank_account_inline_create.dart` and `bank_account_inline_create_controller.dart`, mirroring `contact_inline_create.dart` (167 lines) and its controller (105 lines). The entry point is `Future<BankAccount?> showBankAccountInlineCreateDialog(BuildContext)`.
- **Validation.** Bank name and account number are required. The length limits are 250, 20, 20, 18 and 500, matching the server schema (FR-007). Server `ValidationError`s map by `loc.last`.
- **Alternatives considered.** A generic inline-create dialog. Rejected: three copies of one pattern is acceptable, and the existing two were never generalised (constitution, simplicity).

## R7. Conflict (409) messages

- **Decision.** In `SupplierFormController`, an `AppError` that is `ServerError` with `statusCode == 409` maps to new error codes:
  - `SupplierFormErrorCode.saveConflict` on create or update. It is localised to the combined message (FR-011, Clarifications Q4).
  - `SupplierFormErrorCode.deleteConflict` on delete. It is localised to the "remove the links and agreements first" message (FR-017).

  The precedent is `open_session_form_controller.dart:169`. The repository needs no change, because `auth_interceptor.dart:62-76` already maps 409 to `ServerError(statusCode: 409)`.
- **Rationale.** mbe-api returns the same generic `IntegrityError` body for every supplier conflict, so the status code is the only signal there is. On delete it can only mean links or agreements remain, so that message can be specific. On save it cannot.
- **Alternatives considered.** Adding an `AppError.conflict` variant. It would change a core type that every feature switches on, for two call sites. That waits for mbe-api#147's error codes, tracked by UI #148.

## R8. The agreement dialog

- **Decision.** One dialog serves both add and edit: `supplier_agreement_dialog.dart` and `supplier_agreement_dialog_controller.dart`.
  - **Entry point:** `showSupplierAgreementDialog(context, {required int supplierId, SupplierAgreement? existing})`.
  - **Controller state:** `start` and `end` (`DateTime?`), `comment`, `submitting`, `done`, `error`, `errorDetail` and `fieldErrors`.
  - **Validation** (FR-013): both dates are required, `end >= start`, and the comment is at most 500 characters. Saving is disabled until validation passes. Equal dates are valid.
  - **Submitting:** a create calls `createAgreement…Post`, an edit calls `updateAgreement…Put`, and `delete()` calls `deleteAgreement…Delete`. Each invalidates `supplierAgreementsControllerProvider(supplierId)` and pops.
  - **Deleting:** `Eliminar` appears only in edit mode. It asks first through the same confirmation component `RecordFormActions` uses (`RecordDeleteConfirmation`), as Clarifications Q2 decided.
  - **Date fields:** the `InkWell` + `InputDecorator` + `showDatePicker` pattern from `vehicle_operator_form.dart:202-229`, shown with `fmt.display.date`. Dates are sent with `DateTime.toDate()` and read with `Date.toDateTime()` (generated `model/date.dart`).
- **Alternatives considered.** Separate add and edit dialogs, which would duplicate the same fields. A row Delete icon, which §VI rejects (Clarifications Q2).

## R9. Access control

- **Decision.**

  | Control | Needs |
  |---|---|
  | Route, view | `suppliers` Read (existing gate) |
  | Edit toggle, Save, link, unlink | `suppliers` Update |
  | New supplier | `suppliers` Create |
  | Delete supplier | `suppliers` Delete |
  | Add, edit or remove an agreement | `suppliers` Update, and not read-only |
  | Picker for addresses / contacts / bank accounts | Read on `addresses` (11) / `contacts` (12) / `bankAccounts` (13) |
  | "Nuevo" for addresses / contacts / bank accounts | Create on the same object |

  Controls the user lacks a right for are hidden by passing `null` callbacks, as `LinkedRecordsSection` already supports.
- **Note.** `SystemObject.supplierAgreements` (14) exists, but mbe-api gates every agreement route with **Suppliers** Read or Update (`suppliers.py:106-156`). The UI follows the server, so a user who holds only 14 does not see controls the server would refuse.
- **Rationale.** Constitution §IV: deny by default, and hide rather than disable.

## R10. Picker queries

- **Decision.**
  - The address picker searches `status: active`, as on the customer form.
  - Contacts use `contactRepo.list(search:)`.
  - Bank accounts use `bankAccountRepo.list(search:)`.

  `LinkedRecordsSection` already drops records that are already linked (FR-009) and remounts the picker after each link.
- **Rationale.** These are the same queries customers use, plus the new bank-account repository.

## R11. Where `LinkedRecordsSection` lives

- **Decision.** It stays in `features/catalog/presentation/widgets/`.
- **Rationale.** Spec 046 deferred moving it to `core/widgets/` until a second consumer appeared. Suppliers is that consumer, but it lives in the same `catalog` feature, so there is still no cross-feature use to justify the move (§I).

## R12. Agreements on the compact tier

- **Decision.** `SupplierAgreementsSection` builds its `DataTableView` columns from the layout tier (`core/layout/breakpoints.dart`, `LayoutTier`). On `LayoutTier.compact` it leaves out the Notes column, which stays readable in the dialog.
- **Rationale.** `DataTableView` has no per-tier column hiding (`data_table_view.dart:205-215`: the compact-tier transformation is not built). Choosing columns in the section is local and needs no core change.
- **Alternatives considered.** Adding tier support to `DataTableView`. That is a core widget change with its own scope, and it is out of proportion for one column.

## R13. Tests

- **Unit**
  - `supplier_form_controller_test.dart`, extended: link add, remove and de-dupe; the replace-all update payload; create leaves out empty lists; create stores `supplierId`; 409 maps to `saveConflict` or `deleteConflict`.
  - `supplier_repository_impl_test.dart`, extended: the id lists in the request; the detail maps addresses, contacts and bank accounts.
  - New: `bank_account_repository_impl_test.dart`, `bank_account_inline_create_controller_test.dart`, `supplier_agreement_dialog_controller_test.dart` (end < start, equal dates, create, update, delete, invalidation) and `supplier_agreements_controller_test.dart` (sorting).
- **Widget**
  - New: `supplier_detail_screen_test.dart`, covering view, edit and create titles, the dirty-leave prompt, and stay-after-create.
  - `supplier_form_test.dart`, extended: the sections, privilege hiding per FR-018 and FR-019, and the conflict banners.
  - `suppliers_list_screen_test.dart`, updated: the row, Edit and New actions now push routes instead of opening the sheet.
  - New: `bank_account_inline_create_test.dart`, `supplier_agreement_dialog_test.dart` and `supplier_agreements_section_test.dart` (the compact tier drops Notes, and the row has a single Edit icon).
- **Live** (`test/integration/`)
  - New: `supplier_sub_panels_live_test.dart`. Through the repositories, it creates a bank account, creates a supplier linked to an existing address and contact (discovered at runtime, never hard-coded) plus the bank account, and reads the detail back.
  - It then adds, updates and deletes an agreement; confirms that delete is refused while links exist (409); unlinks; and deletes.
  - Cleanup runs in `tearDown`.
- **Rationale.** This follows the repo's runtime-discover fixtures pattern for live tests (spec 009), with the `crud_panel_flow_test.dart:138-205` shape.

## R14. l10n

- **Decision.** Add keys to `lib/l10n/app_en.arb` (the template) and `app_es.arb`, then regenerate `app_localizations*.dart`; never hand-edit the generated files.
- **Naming.** It follows the existing pattern: `supplier<Thing>Section`, `supplier<Thing>Empty`, `supplier<Thing>LinkLabel`, `supplierSaveConflictError`, `supplierDeleteConflictError`, `newBankAccountDialogTitle`, `bankAccount<Field>Label`, `supplierAgreement*`, and so on.
- **Count.** There are no `bank*` or `agreement*` keys yet, so there will be about 30 new keys.
