# Tasks: Price List Retirement UI

**Input**: Design documents from `/specs/034-price-list-retirement-ui/`
**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md), [data-model.md](data-model.md), [contracts/](contracts/), [quickstart.md](quickstart.md)

**Tests**: included throughout, matching this repo's established practice (constitution § Development Workflow & Quality Gates; the same split `016-product-merge-review` and `033-bulk-pricing-grid` used).

**Organization**: grouped by user story (spec.md's US1–US5), after one Foundational phase every story depends on. All five stories converge on two files — `price_list_delete_dialog.dart` and the two `.arb` files — so most cross-story `[P]` markers are absent by necessity, not oversight; parallelism exists *within* a phase, documented per phase below.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: can run in parallel (different files, no dependency on an incomplete task)
- **[Story]**: which user story this task belongs to (US1–US5)

## Path Conventions

Single Flutter project. `lib/features/pricing/`, `lib/core/formatting/`, `lib/l10n/`, `test/{unit,widget,integration}/` — exactly as laid out in [plan.md](plan.md)'s Project Structure.

---

## Phase 1: Setup

**Purpose**: Baseline only — this feature adds files to an already-configured project (no new dependency, no new tool).

- [ ] T001 Confirm `flutter analyze` is clean and `flutter test` is fully green on a clean checkout of `034-price-list-retirement-ui` **before any change**, and record the pass/fail counts — every later regression is attributable to this feature from that baseline

**Checkpoint**: Baseline recorded.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: The domain model, the repository surface, the preview provider, and the one formatting-surface addition. Nothing in US1–US5 renders without this.

- [ ] T002 [P] Create `PriceListDeleteFate` enum (`destroyed`/`moved`/`blocking`), `PriceListDeleteCategory` (freezed: `key`, `count`, derived `fate` matching the **exact** `category` string — `product_price.list`→destroyed, `customer.price_list`→moved, anything else→blocking — and derived `table`), and `PriceListDeletePreview` (freezed: `categories`, `total`, derived `isEmpty`, `isBlocked`, `movedCount`, `destroyedCount`, plus `fromResponse(PriceListDeletePreviewResponse)`) in `lib/features/pricing/domain/entities/price_list_delete_preview.dart` (data-model.md §1, research.md R2)
- [ ] T003 [P] Add `DisplayFormatters.count(int)` to `lib/core/formatting/app_formatters.dart`, backed by `NumberFormat.decimalPattern(locale)` (data-model.md §6, research.md R3)
- [ ] T004 Run `dart run build_runner build --delete-conflicting-outputs` and confirm `price_list_delete_preview.freezed.dart` regenerates cleanly (depends on T002)
- [ ] T005 Extend `PriceListRepository` in `lib/features/pricing/domain/repositories/price_list_repository.dart`: add `Future<PriceListDeletePreview> deletePreview({required int priceListId})`; widen `delete` to `Future<void> delete({required int priceListId, int? replacement})` (data-model.md §2; depends on T004)
- [ ] T006 Implement both in `lib/features/pricing/data/price_list_repository_impl.dart`, forwarding to the generated `previewPriceListDeleteApiV1PriceListsPriceListIdDeletePreviewGet` and `deletePriceListApiV1PriceListsPriceListIdDelete(replacement:)`, mapped through the existing `_toAppError` (contracts/mbe-api-price-list-retirement.md §1–2; depends on T005)
- [ ] T007 Create `priceListDeletePreviewProvider` (`@riverpod` auto-disposing family keyed by `priceListId`) in `lib/features/pricing/presentation/price_list_delete_preview_provider.dart`, then re-run `dart run build_runner build --delete-conflicting-outputs` (data-model.md §3, research.md R4; depends on T006)
- [ ] T008 [P] Unit-test `PriceListDeleteCategory.fate`/`PriceListDeletePreview` in `test/unit/features/pricing/price_list_delete_preview_test.dart` — all three fates by **whole key** including an invented future key (e.g. `product_price.tax_zone`) that must still block, `isBlocked`, `movedCount`/`destroyedCount`, and the empty preview (research.md R2; depends on T004)
- [ ] T009 [P] Unit-test `display.count` grouping in `test/unit/core/formatting/app_formatters_display_test.dart` — `4312` → `4,312` (en) and `4.312` (es-MX) (depends on T003)
- [ ] T010 [P] Extend `test/unit/features/pricing/price_list_repository_impl_test.dart` — preview mapping and server order preserved; `replacement` reaching the query and omitted entirely when null; a 409 mapped to `ServerError(409, detail)` with the server's sentence intact (depends on T006)

**Checkpoint**: The data path exists, is tested, and nothing in `presentation/` yet depends on it.

---

## Phase 3: User Story 1 - Seeing what a deletion destroys before committing (Priority: P1) 🎯 MVP

**Goal**: Delete opens a review dialog showing every attached category with its count and fate, a server-computed total, and a confirm button naming what it destroys — replacing today's one-line confirmation.

**Independent Test**: Open a price list with prices and no customers, press Delete: the dialog shows the price count marked "deleted permanently", the total, and a confirm button reading "Delete list and N prices"; confirm and the prices are gone.

- [ ] T011 [US1] Create `PriceListDeleteSummary` in `lib/features/pricing/presentation/widgets/price_list_delete_summary.dart` — bordered/clipped panel, one row per category (label from `category.table` via translated strings for `product_price`/`customer`, a private humanized fallback for anything else — research.md R6 — never dropping a row), a parenthesized fate note per §row (`priceListDeleteFateDestroyed`/`Moved`/`Blocking`), counts via `fmt.display.count`, a total footer using the **server's** `total` (never re-summed), and the caption below the panel (contracts/price-list-delete-dialog.md §3; depends on T002, T003)
- [ ] T012 [P] [US1] Widget-test `PriceListDeleteSummary` in `test/widget/features/pricing/price_list_delete_summary_test.dart` — all three fate notes render, an unlabelled category is humanized and never dropped, the rendered total is the server's `total` even when it doesn't equal the sum of a fixture's rows, and the customers row exposes `price_list_delete_customers_link` (depends on T011)
- [ ] T013 [US1] Create `PriceListDeleteDialog` in `lib/features/pricing/presentation/price_list_delete_dialog.dart` — `showPriceListDeleteDialog(BuildContext, {required PriceList priceList})` → `Future<PriceListDeleteOutcome?>` (the `({int movedCount, String? replacementName})?` record from data-model.md §4.3); renders the title, the lead line (suppressed only in the blocked state — not reachable yet), the loading skeleton, the clean note (FR-008) when `preview.isEmpty`, and `PriceListDeleteSummary` otherwise; `barrierDismissible: false` and a `PopScope` blocking back/escape (contracts/price-list-delete-dialog.md §2, §4; depends on T007, T011)
- [ ] T014 [US1] Add the confirm-button label rule to `price_list_delete_dialog.dart` — `destroyedCount > 0` → "Delete list and N prices", else "Delete list" (data-model.md §4.2; depends on T013)
- [ ] T015 [US1] Change `PriceListFormController.delete()` to `Future<bool> delete({int? replacement})` in `lib/features/pricing/presentation/price_list_form_controller.dart`; remove `deleted` from `PriceListFormState` — keep the existing RBAC pre-check, `submitting` toggling, and `error`/`errorDetail` reporting unchanged (research.md R9, data-model.md §5; depends on T006)
- [ ] T016 [US1] Wire `PriceListDetailScreen` (`lib/features/pricing/presentation/price_list_detail_screen.dart`): pass `deleteConfirmation: null` to `RecordFormActions`, route `onDelete` to `showPriceListDeleteDialog`; on a non-null outcome show the snackbar (`priceListDeletedMessage` for now — the with-move variant lands in US2) **then** `context.pop()`, matching `merge_products_screen.dart`'s ordering (contracts/price-list-delete-dialog.md §1.1; depends on T013, T015)
- [ ] T017 [US1] Add l10n keys `priceListDeleteLead`, `priceListDeleteRelatedTitle`, `priceListDeleteTotalLabel`, `priceListDeleteTotalCaption`, `priceListDeleteFateDestroyed`, `priceListDeleteFateMoved`, `priceListDeleteFateBlocking`, `priceListDeleteCategoryProductPrice`, `priceListDeleteCategoryCustomer`, `priceListDeleteViewCustomers`, `priceListDeleteCleanNote`, `priceListDeleteConfirm`, `priceListDeleteConfirmPrices` (ICU plural, `count`+`formatted` placeholders per contracts §5.1), `priceListDeletedMessage` to `lib/l10n/app_es.arb` first, then `lib/l10n/app_en.arb`; remove `deletePriceListConfirmMessage` from both, keep `deletePriceListConfirmTitle` (reused as-is) (contracts/price-list-delete-dialog.md §5; depends on none — sequenced here as the phase's key set)
- [ ] T018 [US1] Run `flutter gen-l10n` and fix any compile fallout from the removed key (depends on T017)
- [ ] T019 [US1] Rewrite the "a user with delete privilege sees the Delete button, and confirming …" case in `test/widget/features/pricing/price_list_detail_screen_test.dart`: Delete opens `PriceListDeleteDialog` (not the old `AlertDialog`); keep the "no Delete without the privilege" assertions unchanged (depends on T016, T018)
- [ ] T020 [P] [US1] Widget-test `PriceListDeleteDialog`'s loading/clean/priced states and the confirm-button label rule in `test/widget/features/pricing/price_list_delete_dialog_test.dart` (depends on T014, T018)
- [ ] T021 [P] [US1] Extend `test/unit/features/pricing/price_list_form_controller_test.dart` — `delete({replacement})` returns `true` on success and `false` with `error`/`errorDetail` retained on failure; RBAC denial sets the error and issues no request (depends on T015)

**Checkpoint**: A list with prices and no customers can be reviewed and deleted end to end. The old bare confirmation is gone for every price list.

---

## Phase 4: User Story 2 - Naming where the list's customers go (Priority: P1)

**Goal**: When customers are assigned, a required replacement picker gates the destructive action; once chosen, the dialog states the move and submits it atomically.

**Independent Test**: Open a list with customers assigned, confirm the destructive button stays disabled until a replacement is picked (and that the list itself is never offered), pick one, confirm, and see every one of those customers now on the named list.

- [ ] T022 [US2] Add the replacement picker to `price_list_delete_dialog.dart` — `CatalogEntityPicker<PriceList>` over `PriceListRepository.list(search:)`, filtering the list being deleted out of the results client-side (FR-010), shown whenever `preview.movedCount > 0` (contracts/price-list-delete-dialog.md §4.1; depends on T013)
- [ ] T023 [US2] Add the picker's helper-text priority (chosen+required → "All N customers move to X.", not-chosen+required → required helper) to `price_list_delete_dialog.dart` (contracts §4.1; depends on T022)
- [ ] T024 [US2] Gate the confirm button on `replacement != null` whenever the picker is shown as required (data-model.md §4.1 row "assigned"; depends on T014, T022)
- [ ] T025 [US2] Route the chosen replacement into `PriceListFormController.delete(replacement: chosen?.priceListId)` and extend the confirm-button label rule: `destroyedCount == 0 && movedCount > 0` → "Delete list and move N customers" (depends on T015, T024)
- [ ] T026 [US2] Add `price_list_delete_customers_link` to the Customers row in `PriceListDeleteSummary` — pops the dialog, then `context.go('/customers?priceList=<id>')` (FR-006; depends on T011, T013)
- [ ] T027 [US2] Extend the `PriceListDetailScreen` snackbar composition from T016 to the with-move wording when `outcome.replacementName != null` (FR-017; depends on T016, T025)
- [ ] T028 [US2] Add l10n keys `priceListDeleteReplacementLabel`, `priceListDeleteReplacementLabelOptional`, `priceListDeleteReplacementRequiredHelper`, `priceListDeleteReplacementOptionalHelper`, `priceListDeleteReplacementChosenHelper` (ICU plural), `priceListDeleteConfirmCustomers` (ICU plural), `priceListDeletedWithMoveMessage` (ICU plural) to `app_es.arb` first, then `app_en.arb` (contracts §5; depends on T017)
- [ ] T029 [US2] Run `flutter gen-l10n` (depends on T028)
- [ ] T030 [P] [US2] Widget-test the picker in `test/widget/features/pricing/price_list_delete_dialog_test.dart` — the list being deleted is never an option, the confirm gate holds until chosen, and the chosen-helper text updates (depends on T024, T029)
- [ ] T031 [P] [US2] Widget-test the customers-row navigation in `test/widget/features/pricing/price_list_delete_summary_test.dart` — tapping it pops the dialog and the navigation target carries the price list's id (depends on T026)

**Checkpoint**: The golden path (US1 + US2) is complete: any list, with or without customers, can be retired in one confirmed action.

---

## Phase 5: User Story 3 - Acknowledging an irreversible destruction (Priority: P2)

**Goal**: An unticked acknowledgment blocks the destructive action whenever anything is attached to the list; a clean list demands none.

**Independent Test**: Open a list with prices or customers, confirm the button stays disabled while unticked, tick it, confirm it enables; untick and confirm it disables again.

- [ ] T032 [US3] Add the acknowledgment `CheckboxListTile` (key `price_list_delete_acknowledge`) to `price_list_delete_dialog.dart`, shown whenever the preview resolved non-empty and unblocked, or the preview errored; gate the confirm button on it (FR-014; depends on T013, T014)
- [ ] T033 [US3] Add l10n key `priceListDeleteAcknowledge` to `app_es.arb` first, then `app_en.arb`, and run `flutter gen-l10n` (depends on T017)
- [ ] T034 [P] [US3] Widget-test the acknowledgment in `test/widget/features/pricing/price_list_delete_dialog_test.dart` — ticking/unticking toggles the confirm gate; the clean state (`isEmpty`) shows no acknowledgment at all (FR-008 edge case; depends on T032, T033)

**Checkpoint**: Every non-empty deletion requires an explicit, resettable acknowledgment before it can be confirmed.

---

## Phase 6: User Story 4 - Being told, before submitting, that the list cannot be retired (Priority: P2)

**Goal**: A blocking category (anything but the two known ones) is shown before submission, with no way to confirm; a real 409 (the race the report can't see) is still handled and preserves the operator's input.

**Independent Test**: Point a non-price, non-customer record at a list, open Delete: the dialog names the blockage, offers only Close, and no `DELETE` is ever sent.

- [ ] T035 [US4] Add the blocked banner to `price_list_delete_dialog.dart` — shown when `preview.isBlocked`; suppress the lead line in this state; mark blocking rows in `PriceListDeleteSummary`; render only a Close action, no destructive button at all (contracts §2, FR-018; depends on T011, T013)
- [ ] T036 [US4] Add l10n key `priceListDeleteBlockedBanner` to `app_es.arb` first, then `app_en.arb`, and run `flutter gen-l10n` (depends on T017)
- [ ] T037 [P] [US4] Widget-test the blocked state in `test/widget/features/pricing/price_list_delete_dialog_test.dart` — banner shown, blocking row marked, no confirm button present, Close only (depends on T035, T036)
- [ ] T038 [US4] Handle a submitted-and-refused deletion in `price_list_delete_dialog.dart`: render `ErrorBanner` with the mapped `AppError`, keep the dialog open, and preserve the chosen replacement across the failure (research.md R10, FR-019; depends on T024, T032)
- [ ] T039 [P] [US4] Widget-test the refusal path in `test/widget/features/pricing/price_list_delete_dialog_test.dart` — a rejected `delete()` call leaves the dialog open with the server's sentence shown, the replacement still selected, and no `deleted` state anywhere (depends on T038)

**Checkpoint**: No submission can be made against a review that already predicts its own refusal, and a genuine refusal never loses the operator's work.

---

## Phase 7: User Story 5 - Deleting when the report cannot be loaded (Priority: P3)

**Goal**: A failed preview degrades the dialog rather than blocking it — the operator is told, the replacement becomes optional, and the deletion may still be attempted.

**Independent Test**: Make the preview request fail, open Delete: the dialog says the dependencies could not be loaded, still allows confirming, and — if the server then refuses — shows that refusal.

- [ ] T040 [US5] Add the `previewFailed` state to `price_list_delete_dialog.dart` — the degraded note, the replacement picker shown as **optional** with its "used only if customers turn out to be assigned" helper, and the acknowledgment still required before confirming (FR-020; depends on T022, T032)
- [ ] T041 [US5] Add l10n key `priceListDeletePreviewFailedNote` to `app_es.arb` first, then `app_en.arb`, and run `flutter gen-l10n` (depends on T017)
- [ ] T042 [P] [US5] Widget-test the degraded state in `test/widget/features/pricing/price_list_delete_dialog_test.dart` — note shown, picker optional, confirm reachable once acknowledged, and a subsequent server refusal still renders via `ErrorBanner` (depends on T040, T041)

**Checkpoint**: All seven dialog states from contracts/price-list-delete-dialog.md §2 exist and are independently tested.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: The two automated guards this feature must pass without modification, the end-to-end proof, and the manual/visual checks nothing else covers.

- [ ] T043 [P] Write `test/integration/price_list_retirement_flow_test.dart` against a live mbe-api — preview → pick replacement → acknowledge → confirm → 204 → the moved customers read as being on the replacement (quickstart.md manual steps 1–9; depends on T032, T038)
- [ ] T044 Run `test/unit/core/l10n_parity_test.dart` and `test/unit/core/formatting_guard_test.dart`; both MUST pass with **no** edit to either file — a failure here means a key was added to only one `.arb` file, or `package:intl` was reached for outside `lib/core/formatting/` (depends on T017, T028, T033, T036, T041)
- [ ] T045 Walk quickstart.md's manual steps 1–15 end to end against a local mbe-api, including the blocked-state check (step 10) with whatever data the dev tenant can produce, and report honestly if step 10 could only be exercised as a widget test (depends on T037, T039, T042, T043)
- [ ] T046 [P] Verify constitution §V's largest text-size level against the dialog on list **B** (prices + customers, quickstart step 15) — no clipping, overflow, or hidden content (depends on T032)
- [ ] T047 [P] Final sweep: `flutter analyze` clean and `flutter test` fully green, and no remaining reference anywhere in `test/` to the retired `confirm_delete_price_list_button` key (depends on T019, T044)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: none.
- **Foundational (Phase 2)**: depends on Setup — **blocks every user story**.
- **US1 (Phase 3)**: depends on Foundational only. This is the MVP slice.
- **US2 (Phase 4)**: depends on US1 (extends the same dialog file and the same `delete()` signature).
- **US3 (Phase 5)**: depends on US1 (the confirm gate US3 adds sits beside the one US1 already built). Independent of US2 — either order works.
- **US4 (Phase 6)**: depends on US1 for the dialog shell; its refusal-preservation task (T038) depends on US2's picker (T024) and US3's acknowledgment (T032) both existing.
- **US5 (Phase 7)**: depends on US2's picker (T022, for the optional variant) and US3's acknowledgment (T032).
- **Polish (Phase 8)**: depends on all five stories.

**Why this isn't five independent file sets**: unlike a feature with one screen per story, all five stories add states and gates to *one* dialog. The independence the spec asks for is behavioral — each story's acceptance scenarios hold on their own once its tasks land — not file-level parallelism. `RecordFormActions`, the repository, and the formatting surface are the only pieces genuinely shared and finished in Foundational.

### Parallel Opportunities

- T002 and T003 (Foundational) — different files, no dependency between them.
- T008, T009, T010 (Foundational tests) — once their respective implementations exist.
- T011 and T003 already noted; within US1, T012/T020/T021 run in parallel once their dependencies land.
- Every `[P]`-marked test task within a phase runs in parallel with its siblings.

---

## Parallel Example: Foundational Phase

```bash
# Independent domain/formatter work:
Task: "Create PriceListDeleteFate/Category/Preview in lib/features/pricing/domain/entities/price_list_delete_preview.dart"
Task: "Add DisplayFormatters.count(int) to lib/core/formatting/app_formatters.dart"

# After both land and build_runner has run:
Task: "Unit-test fate mapping in test/unit/features/pricing/price_list_delete_preview_test.dart"
Task: "Unit-test display.count grouping in test/unit/core/formatting/app_formatters_display_test.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 (Setup) and Phase 2 (Foundational).
2. Complete Phase 3 (US1).
3. **Stop and validate**: any list with prices and no customers can be reviewed and deleted; the counted breakdown and total render correctly.
4. This is already a strict improvement over today's dialog and is independently shippable.

### Incremental Delivery

1. Foundational → US1 (MVP: the review, for the simplest lists).
2. Add US2 → the golden path (any list, any customer count) is complete.
3. Add US3 → every non-empty deletion requires acknowledgment.
4. Add US4 → no submission is made against a review that already predicts refusal.
5. Add US5 → a failed preview degrades gracefully instead of blocking.
6. Polish → the two guard suites, the integration test, and the manual pass.

### Suggested Sequencing for a Single Implementer

Phases in the order written (1 → 8) is the dependency order; there is no benefit to reordering US3 ahead of US2 or vice versa, since both depend only on US1 and neither touches the other's code.

---

## Notes

- `[P]` tasks touch different files or are read-only against an already-landed file.
- `[Story]` labels trace every task to spec.md's US1–US5 for independent verification.
- Every `flutter gen-l10n` task exists because a `.arb` key change alone does not regenerate `AppLocalizations` — skipping it produces a stale getter, not a compile error, until the next full build.
- Commit after each checkpoint; stop at any checkpoint to validate that story's independent test from spec.md before continuing.
- Avoid: adding a category-fate special case anywhere outside `PriceListDeleteCategory.fate` (T002) — every other file trusts that single source.
