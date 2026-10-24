---
description: "Task list for 052-customer-discounts"
---

# Tasks: Customer Discounts

**Input**: Design documents from `specs/052-customer-discounts/`

**Prerequisites**: plan.md, spec.md, wireframes.md, research.md (R1–R11), data-model.md, contracts/ui-contracts.md (C1–C7), quickstart.md

**Tests**: The spec does not ask for a test suite as such, but the constitution's quality gates and research R11 require tests. Test tasks are included inside each story, after the code they cover.

**Organization**: Grouped by user story (US1–US3, spec.md). US2 and US3 build on the section and repository that Foundational and US1 deliver. US3 reuses the dialog that US2 delivers.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: parallelizable (different files, no dependency on an incomplete task)
- **[Story]**: US1 see a customer's discounts · US2 add a discount · US3 change or remove a discount

## Cross-story notes

- **Shared files.** Several stories edit the same files, so do these sequentially, not in parallel:
  - `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb`: every story adds keys (contracts C6). Run `flutter gen-l10n` after each arb task and commit the regenerated `lib/l10n/app_localizations*.dart` files. Never hand-edit those.
  - `lib/features/catalog/presentation/customer_form.dart`: US1 and US2.
  - `lib/features/catalog/presentation/customer_discount_dialog_controller.dart` and `customer_discount_dialog.dart`: US2 then US3.
  - `lib/features/catalog/presentation/customer_discounts_section.dart`: US1, US2, US3.
- **Generated code.** After editing a freezed or `@riverpod` file, run `dart run build_runner build --delete-conflicting-outputs`.
- **No backend work.** Nothing here touches mbe-api, and the OpenAPI client is not regenerated unless T001's drift check finds a change (contracts C7).
- **Formatting.** Format only the files you changed (`dart format <files>`). Never `dart format .`.
- **Percentages.** Every displayed percentage goes through `formattersProvider` (constitution §V, `test/unit/core/formatting_guard_test.dart` fails the suite otherwise). No widget builds a `NumberFormat` or calls `toStringAsFixed`.
- **Language.** User-visible text is in Spanish and English (FR-014). The Spanish wording in contracts C6 is the starting point.
- **Mirror, don't copy blindly.** The closest precedent is spec 050's agreements: `supplier_agreements_section.dart`, `supplier_agreements_controller.dart`, `supplier_agreement_dialog.dart`, `supplier_agreement_dialog_controller.dart`. Read the matching file before writing each new one, and keep its structure, comment density and naming style.
- **Spacing tokens, not the precedent's literals.** Constitution §V requires every padding, margin and gap to come from the design tokens. The agreement files above use literals (`EdgeInsets.all(24)`, `SizedBox(height: 16)`, `spacing: 8`). Don't copy those. Take every gap from `Theme.of(context).spacing` (as `customer_detail_screen.dart` does with `spacing.lg`). No automated guard catches this, so check it in review.

---

## Phase 1: Setup

**Purpose**: a known-good baseline, so later failures are attributable.

- [ ] T001 Run `flutter analyze` and the customer and supplier test files (`test/**/customer*_test.dart`, `test/**/supplier_agreement*_test.dart`, `test/**/linked_records_section_test.dart`) on the clean branch; note any pre-existing failures so they are not blamed on this feature. Then check the generated client for drift: regenerate `lib/generated/openapi/` with `tool/generate_api_client.sh` against the dev mbe-api's `/openapi.json`, and expect `git status lib/generated` to show no changes. The script deletes and rewrites the whole folder, and needs Docker and a running mbe-api. If the diff is unexpected, run `git restore lib/generated`, then stop and review the change against contracts C7 before continuing.

---

## Phase 2: Foundational (blocks every story)

**Purpose**: the entity and the four repository methods that all three stories call.

- [ ] T002 [P] Create the freezed `CustomerDiscount` entity in `lib/features/catalog/domain/entities/customer_discount.dart` with the fields in data-model.md (`customerDiscountId`, `customerId`, `productId`, `productCode`, `productName`, `discount` as the wire string fraction) and a `fromResponse(CustomerDiscountResponse)` factory, following `supplier_agreement.dart`.
- [ ] T003 Add `listDiscounts`, `createDiscount`, `updateDiscount` and `deleteDiscount` to the `CustomerRepository` interface in `lib/features/catalog/domain/repositories/customer_repository.dart`, with the signatures and thrown errors in data-model.md. Document that `discount` is always the fraction string.
- [ ] T004 Implement the four methods in `lib/features/catalog/data/customer_repository_impl.dart` using the generated `CustomersApi` discount operations, mapping with `CustomerDiscount.fromResponse` and rethrowing through the file's `_toAppError`. Add a file-local `_setDiscount(DiscountBuilder, String)` that sends the String arm (`AnyOf2<String, num>(values: {0: value})`), next to `_setCreditLimit`. Find the generated method names in `lib/generated/openapi/lib/src/api/customers_api.dart` (lines around 138, 582 and 777 for create, list and update/delete).
- [ ] T005 [P] Extend `test/unit/features/catalog/customer_repository_impl_test.dart` with tests for the four methods: the list maps rows in server order, create sends `{product, discount}` with the String arm, update sends only `{discount}`, delete returns normally, and 404, 409 and 422 map to `NotFoundError`, `ServerError(statusCode: 409)` and `ValidationError` (research R6). Use the file's existing Dio stubbing style.
- [ ] T006 Run `dart run build_runner build --delete-conflicting-outputs`, then `flutter test test/unit/features/catalog/customer_repository_impl_test.dart`; it must pass.

**Checkpoint**: the repository can list, create, update and delete discounts.

---

## Phase 3: User Story 1 — See a customer's product discounts (P1) 🎯 MVP

**Goal**: the customer page shows a Discounts section listing every discount, read-only for users who can't edit.

**Independent Test**: open a customer that has discounts on the server: every one is listed in product-code order at the right percentage. A customer with none shows the empty state. A user without Customers Update sees rows but no controls (quickstart §2 steps 1–3, §4 step 1).

- [ ] T007 [US1] Add the US1 keys from contracts C6 to `lib/l10n/app_es.arb` and `lib/l10n/app_en.arb`: `customerDiscountsSection`, `customerDiscountsEmpty`, `customerDiscountsAfterSaveNote`, `customerDiscountColumnCode`, `customerDiscountColumnProduct`, `customerDiscountColumnDiscount`. Run `flutter gen-l10n`.
- [ ] T008 [US1] Create `lib/features/catalog/presentation/customer_discounts_controller.dart`: a `@riverpod` class `CustomerDiscountsController` with `build(int customerId)` that returns `ref.read(customerRepositoryProvider).listDiscounts(customerId: customerId)` unchanged, because the server orders by product code (research R7). Model it on `supplier_agreements_controller.dart`, without the sort. Run build_runner.
- [ ] T009 [US1] Create `lib/features/catalog/presentation/customer_discounts_section.dart` with `CustomerDiscountsSection({customerId, readOnly})` per contracts C3. Cover the states: `customerId == null` shows the title and `customerDiscountsAfterSaveNote` (key `customer_discounts_after_save_note`) and never touches the provider; loading; error through `ListFailedView` with retry that invalidates the family; empty text; rows in a `DataTableView<CustomerDiscount>` (key `customer_discounts_table`) with Code (S), Product (L) and Discount (S, right-aligned, `fmt.display.percent(d.discount)`) columns. On the compact tier (`LayoutBreakpoints.isCompact`) drop the Code column and prefix it into the Product cell as `code · name`. Set the section key `customer_discounts_section` where it is placed. Build the header as a `Wrap` (title, then the add control in US2), so on narrow widths the button drops below the title instead of overflowing (contracts C3). Add and Edit controls come in US2 and US3, so leave a clear place for them. Mirror `supplier_agreements_section.dart` for structure, with gaps from `Theme.of(context).spacing`, not its literals.
- [ ] T010 [US1] Place the section in `lib/features/catalog/presentation/customer_form.dart`: after the Taxpayers section and the generic-taxpayer note, add `FormGridChild(span: FormGridSpan.full, Divider())` then a full-width `CustomerDiscountsSection(key: const Key('customer_discounts_section'), customerId: widget.customerId, readOnly: readOnly)`, before `RecordFormActions` (contracts C2).
- [ ] T011 [P] [US1] Create `test/unit/features/catalog/customer_discounts_controller_test.dart`: it loads the repository's list unchanged and keeps server order, and surfaces a repository error as `AsyncError`. Use `ProviderContainer` with a mocked `customerRepositoryProvider`, like `supplier_agreements_controller_test.dart`.
- [ ] T012 [P] [US1] Create `test/widget/features/catalog/customer_discounts_section_test.dart`: three rows show code, name and `NN.NN %` (including that `0.125` shows `12.50 %`, FR-003), the empty text, the after-save note with no provider read when `customerId` is null, the error view with retry, the compact tier shows `code · name` and no Code column, and with `readOnly: true` or without Customers Update there are no add or edit controls. Follow `supplier_agreements_section_test.dart`.
- [ ] T013 [US1] Extend `test/widget/features/catalog/customer_detail_screen_test.dart` with a case that the Discounts section appears below Taxpayers on an edit screen and shows the after-save note on `/customers/new`. Run `flutter test test/widget/features/catalog test/unit/features/catalog`; it must pass.

**Checkpoint**: US1 is shippable on its own, as a read-only section.

---

## Phase 4: User Story 2 — Add a discount on a product (P1)

**Goal**: on a saved customer, the user adds a discount through a dialog; a new customer stays open after its first save so discounts can be added at once.

**Independent Test**: add a 10 % discount on a product: it appears, survives a reload, a repeat is refused, and a new order for that customer starts that line at 10 % (quickstart §2 steps 4–7 and 10–15, §3).

- [ ] T014 [US2] Add the US2 keys from contracts C6 to both `.arb` files: `addCustomerDiscountButton`, `newCustomerDiscountDialogTitle`, `customerDiscountProductLabel`, `customerDiscountPercentLabel`, the four `customerDiscountPercent*Error` messages, `customerDiscountDuplicateError`, `customerDiscountProductMissingError`, `customerDiscountSaveFailedError`. Run `flutter gen-l10n`.
- [ ] T015 [US2] Create `lib/features/catalog/presentation/customer_discount_dialog_controller.dart` per data-model.md: freezed `CustomerDiscountDialogState` (`product`, `percent`, `percentDirty`, `submitting`, `done`, `error`, `errorDetail`, `fieldErrors`) with a derived `percentError` and `canSubmit`, an error-code class `CustomerDiscountDialogErrorCode`, and a `@riverpod` controller family `(int customerId, CustomerDiscount? existing)`. Implement `productSelected`, `percentChanged`, and `submit` for the add path: convert with `fmt.field.parseRate` (take the formatters from a provider read, not `Localizations`), call `createDiscount`, invalidate `customerDiscountsControllerProvider(customerId)` and set `done`. Validate per research R4 (non-empty, parses, 0 ≤ value ≤ 100, at most 6 decimals via `Decimal.scale`). Map failures per the research R6 table: 409 to `duplicateProduct` and invalidate the list, 422 plain detail to `productMissing`, 422 with field errors into `fieldErrors`, anything else to `saveFailed` with `serverMessage`. Model it on `supplier_agreement_dialog_controller.dart`. Leave the edit and delete paths for US3. Run build_runner.
- [ ] T016 [US2] Create `lib/features/catalog/presentation/customer_discount_dialog.dart` with `showCustomerDiscountDialog(context, {customerId, takenProductIds, existing})` per contracts C4, add mode only for now. Include the `Dialog` (max width 560), the title, an `ErrorBanner` above the fields for `error`, a `CatalogEntityPicker<ProductListItem>` (key `customer_discount_product_field`) whose `optionsBuilder` calls `productRepositoryProvider.list(search: q, status: EntityStatus.active, limit: 20)` and drops `takenProductIds`, with `optionImageUrl: (i) => i.photo` and `optionSubtitle: (i) => i.code`, and the percentage `TextFormField` (key `customer_discount_percent_field`, decimal keyboard, `%` suffix, error text from the localized `percentError` or `fieldErrors['discount']`). Cancel (`customer_discount_cancel_button`) and Save (`customer_discount_save_button`, enabled by `canSubmit`, spinner while submitting). Close on `done` the way `supplier_agreement_dialog.dart` does. Copy its structure and the picker wiring from `merge_products_screen.dart`, with every padding and gap from `Theme.of(context).spacing` instead of the agreement dialog's literals (constitution §V).
- [ ] T017 [US2] Wire the add button into `customer_discounts_section.dart`: a `FilledButton.icon` (key `add_customer_discount_button`, `CatalogAction.create.icon`, `addCustomerDiscountButton`) in the header, shown only when the customer is saved, the discounts list has loaded (`AsyncData`), `!readOnly`, and the user has Customers Update **and** Products Read (research R5, R9). While the list is loading or failed the button is hidden, so `takenProductIds` is always complete and FR-005 holds. On press call `showCustomerDiscountDialog` with `takenProductIds` taken from the loaded list. The label stays `addCustomerDiscountButton` on every tier: the header's `Wrap` from T009 moves it below the title when it doesn't fit (wireframes OQ-2, resolved). No compact-only key.
- [ ] T018 [US2] Key the customer form controller by customer id (research R8, mbe-ui#207). In `lib/features/catalog/presentation/customer_form_controller.dart` change `build()` to `build(int? customerId)`. In `customer_form.dart` read `customerFormControllerProvider(widget.customerId)` everywhere it reads or watches the provider. In `lib/features/sales/presentation/customer_inline_create.dart` read `customerFormControllerProvider(null)`. Run build_runner, then `flutter analyze` to catch every remaining call site; fix the existing tests' provider reads in `test/unit/features/catalog/customer_form_controller_test.dart` and any widget test that reads the provider.
- [ ] T019 [US2] Stay on the customer after create (FR-007a, contracts C1/C2). Add `ValueChanged<int>? onCreated` to `CustomerForm`. In its save handler copy the post-save logic from `supplier_form.dart` (the `_snapshot != null` guard, then `onCreated(createdId)` when the save was a create and `onCreated` is set, otherwise `Navigator.of(context).pop()`). In `customer_detail_screen.dart` pass `onCreated: (id) => context.replace('/customers/$id')`. An update and a delete still pop.
- [ ] T020 [P] [US2] Create `test/unit/features/catalog/customer_discount_dialog_controller_test.dart` for the add path: `canSubmit` needs a product and a valid percentage; `percentError` for empty, `abc`, `-1`, `101`, `1.1234567`, and valid `0`, `100`, `12.5`, `0.000001`, `10.000000` and `10.0000000` (trailing zeros carry no precision, so they don't count toward the 6-decimal limit, research R4); submit sends the fraction string (`10` → `0.1`) with the picked product id; success invalidates the list and sets `done`; 409, 422 plain detail, 422 field errors and a generic failure each give the R6 state and keep the input; a 409 also invalidates the list.
- [ ] T021 [P] [US2] Create `test/widget/features/catalog/customer_discount_dialog_test.dart` for add mode: the picker excludes `takenProductIds`, searches active products only, Save stays disabled until a product and a valid percentage exist, each invalid input shows its message, the banner shows for the duplicate and missing-product cases while the input is kept, and Cancel closes without calling the repository.
- [ ] T022 [US2] Extend `test/widget/features/catalog/customer_discounts_section_test.dart`: the add button is visible only for a saved customer with Customers Update, Products Read and `!readOnly`, once the list has loaded; hidden otherwise (including Update without Products Read, and while the list is loading or failed); on a narrow width the button wraps below the title without an overflow error; pressing it opens the dialog; a successful add refreshes the list.
- [ ] T023 [US2] Extend `test/widget/features/catalog/customer_detail_screen_test.dart`: after a first save the screen replaces itself with `/customers/:id` in edit mode and the add button is available; an update still pops to the list; and, as in `supplier_detail_screen_test.dart`, a create opened while the previous customer's screen is still closing starts empty (mbe-ui#207). Extend `customer_form_controller_test.dart` so two different keys never share state.
- [ ] T024 [P] [US2] Add a regression test under `test/widget/features/sales/`, beside `capture_step_gate_test.dart`. Adding a product through `CaptureStep` calls the editor's `addLine` with no `discountRate`, so the server applies the customer's discount (FR-013, research R10). `CaptureStep` is shared by POS, the order workspace and the quote screen, so one capture-level test covers orders and quotes. Also assert that `SaleEditing.addLine` and `QuoteEditing.addLine` pass a `null` `discountRate` through to their repositories unchanged. Use the same fakes `capture_step_gate_test.dart` uses.
- [ ] T025 [US2] Run `dart run build_runner build --delete-conflicting-outputs`, `flutter gen-l10n`, `flutter analyze`, and `flutter test test/unit test/widget`; all must pass, including the formatting guard.

**Checkpoint**: US1 and US2 together deliver view and add, and fix #207.

---

## Phase 5: User Story 3 — Change or remove a discount (P2)

**Goal**: the user corrects a percentage or removes a discount, each taking effect when its dialog is confirmed.

**Independent Test**: change 10 % to 12.5 %, then remove the discount; reopen after each step (quickstart §2 steps 8, 9 and 11, §3 step 3).

- [ ] T026 [US3] Add the US3 keys from contracts C6 to both `.arb` files: `editCustomerDiscountDialogTitle`, `customerDiscountMissingError`, `customerDiscountDeleteFailedError`, `deleteCustomerDiscountButton`, `deleteCustomerDiscountConfirmTitle`, `deleteCustomerDiscountConfirmMessage` (placeholders `code` and `name`). Run `flutter gen-l10n`.
- [ ] T027 [US3] Add edit and delete to `customer_discount_dialog_controller.dart`. Seed `percent` from `fmt.field.rate(existing.discount)` when `existing != null`. `submit` in edit mode calls `updateDiscount`; when `percentDirty` is false it sends `existing.discount` unchanged, otherwise the parsed fraction (research R3). `delete()` calls `deleteDiscount`. Both invalidate the list and set `done` on success. A `NotFoundError` gives `discountMissing` and invalidates the list. Other failures give `saveFailed` or `deleteFailed` with `serverMessage`. Run build_runner.
- [ ] T028 [US3] Add edit mode to `customer_discount_dialog.dart` (contracts C4): `editCustomerDiscountDialogTitle`; a read-only `InputDecorator` with the same key `customer_discount_product_field` showing `code — name` in place of the picker (FR-008); the percentage field seeded from the controller; and, leftmost, an outlined error-coloured Delete button (key `customer_discount_delete_button`) that goes through `showRecordDeleteConfirmation` with `deleteCustomerDiscountConfirmTitle` / `deleteCustomerDiscountConfirmMessage(code, name)` and confirm key `confirm_delete_customer_discount_button`, then calls `controller.delete()` (FR-009). Map the `discountMissing` and `deleteFailed` codes to banner text.
- [ ] T029 [US3] Add the row Edit action in `customer_discounts_section.dart`: `rowActionsBuilder` returns `buildCatalogRowActions(editTooltip: l10n.editActionTooltip, editKey: Key('edit_customer_discount_${d.customerDiscountId}'), onEdit: ...)` calling `showCustomerDiscountDialog` with `existing: d` and the taken ids, only when `!readOnly` and the user has Customers Update. It does not need Products Read. Add no Delete icon (§VI).
- [ ] T030 [P] [US3] Extend `customer_discount_dialog_controller_test.dart` for edit and delete: the percentage seeds at full precision (`0.12500000` → `12.5`); an untouched edit sends the original string; a changed percentage sends the converted fraction; the update never sends a product; delete calls the repository once; a 404 gives `discountMissing` and invalidates; failures keep the dialog open.
- [ ] T031 [P] [US3] Extend `customer_discount_dialog_test.dart` for edit mode: the product is shown read-only and can't be changed, the percentage is seeded, Delete appears only in edit mode, it asks for confirmation naming the product, cancelling the confirmation deletes nothing, confirming removes it and closes the dialog, and the missing-discount banner shows.
- [ ] T032 [US3] Extend `customer_discounts_section_test.dart`: each row has exactly one action, Edit, and no Delete icon; Edit is hidden for `readOnly` and for users without Customers Update; Edit shows without Products Read; a discount whose product has since been deactivated is still listed and its edit dialog opens with the product shown read-only (spec edge case "Inactive product"); a successful edit or removal refreshes only the list (the customer form's pending edits are untouched, FR-010: pump the whole `CustomerForm`, edit the name, change a discount, and assert the name field is still dirty).
- [ ] T033 [US3] Run `dart run build_runner build --delete-conflicting-outputs`, `flutter gen-l10n`, `flutter analyze`, and `flutter test test/unit test/widget`; all must pass.

**Checkpoint**: all three stories work.

---

## Phase 6: Polish & cross-cutting

- [ ] T034 [P] Create `test/integration/customer_discounts_live_test.dart` modelled on `supplier_sub_panels_live_test.dart` (same `--dart-define` credentials, runtime fixture discovery): find a customer and an active product with no discount for it, create a 10 % discount, confirm a repeat create gets 409, update it to 12.5 % and read back the fraction `0.125`, delete it, confirm a second delete gets 404, and leave the customer as found. Run it against the dev tenant.
- [ ] T035 Walk through quickstart.md §2 (manual), §3 (sales picks up the discount) and §4 (access) against the dev tenant on a web or macOS build, and record the results in the PR description. Also time step 6 (picking a product and saving a discount should take under 30 seconds, SC-002), and open the customer with the most discounts to check the page scrolls rather than truncating (spec edge case "Many discounts"). Use `integration_test` on macOS rather than Flutter Driver if you automate it (memory: Driver drops taps on web), and the `MBE_READONLY` account for §4.
- [ ] T036 [P] Add `integration_test/customer_discounts_quickstart_test.dart` only if T035 found a step that is hard to repeat by hand; otherwise skip it and say so in the PR.
- [ ] T037 Run `dart format` on only the files this feature changed (`git diff --name-only`, excluding generated `.g.dart`, `.freezed.dart` and `lib/l10n/app_localizations*.dart`), then `flutter analyze` and the full `flutter test test/unit test/widget`; all must be clean. Confirm `git status` shows no unrelated files, and that `specs/051-vehicle-operator-license-photos/` is not part of this branch's commits.
- [ ] T038 Write the PR description: it uses `Closes mictlanix/mbe-roadmap#16` under "Roadmap" and `Closes #207`, and lists the three spec amendments from planning (FR-003 percent format, period-only decimal separator, active-products-only picker).

---

## Dependencies & execution order

- **Phase 1** → **Phase 2** → **Phase 3 (US1)** → **Phase 4 (US2)** → **Phase 5 (US3)** → **Phase 6**.
- **US2 depends on US1's section and controller** (T017 edits the section; the dialog invalidates the list family).
- **US3 depends on US2's dialog and dialog controller** (it adds the edit and delete paths to the same files).
- Within Phase 2, T002 comes first; T003 and T004 follow it; T005 follows T004.
- T018 (the family key) must finish before T019, T023 and the other form-state tests.
- Phase 6 comes last, because the live and quickstart runs need everything in place.

## Parallel opportunities

- **Phase 2:** T002 and T005's test scaffolding can start together.
- **US1:** T011 and T012 run in parallel once T008 and T009 exist.
- **US2:** T020, T021 and T024 are independent of each other once T015 and T016 exist. T018 and T019 touch different files from T015 and T016 and can run in parallel with them after T014.
- **US3:** T030 and T031 run in parallel after T027 and T028.
- **Phase 6:** T034 and T036 are independent.

## Implementation strategy

- **MVP:** Phases 1–3. This delivers a read-only Discounts section, which is a useful lookup on its own. Roadmap#16 isn't finished at this point, though: its legacy actions are add and change/remove.
- **Release:** the full scope is Phases 1–6. US2 and US3 are small additions to US1's section, so ship them together in one PR (`Closes mictlanix/mbe-roadmap#16`).
- **Order inside US2:** do T018 and T019 (family key and stay-after-create) early in the phase. They change shared form state, so any breakage shows up before the dialog work builds on it.
- **Risk to watch:** T018 touches the shared customer form provider, and the POS quick-create dialog reads it too. Run the sales tests after it, not only the catalog ones.

## Requirement coverage

| Requirement | Tasks |
|---|---|
| FR-001 section on the page | T009, T010 |
| FR-002, FR-003 list and percent format | T009, T012 |
| FR-004 add dialog | T015, T016, T017 |
| FR-005 picker excludes taken, active only | T016, T017, T021, T022 |
| FR-006 percentage rules | T015, T020, T021 |
| FR-007, FR-007a not-yet-saved note, stay after create | T009, T019, T023 |
| FR-008 edit, product fixed | T028, T031 |
| FR-009 remove inside the dialog with confirmation | T028, T031 |
| FR-010 independent saving | T015, T027, T032 |
| FR-011 refused saves | T015, T020, T027, T030 |
| FR-012 rights | T017, T022, T029, T032 |
| FR-013 sales lines | T024, T035 |
| FR-014 Spanish and English | T007, T014, T026 |
| SC-001..SC-006 | T034, T035 |
| mbe-ui#207 | T018, T023 |
