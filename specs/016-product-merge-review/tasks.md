---
description: "Task list for Merge Products — Explicit Kept/Deleted Review"
---

# Tasks: Merge Products — Explicit Kept/Deleted Review

**Input**: Design documents from `/specs/016-product-merge-review/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/](./contracts/)

**Tests**: Test tasks ARE included — the constitution's "Development Workflow & Quality Gates" mandates unit tests for domain/controller logic and widget tests for critical screens, and plan.md's Technical Context specifies both for this feature.

**Organization**: Tasks are grouped by user story so each can be implemented and verified independently.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1–US5)
- Exact file paths are included in every task

## Path Conventions

Single Flutter project, feature-first layered per constitution §I. All work lands under `lib/features/catalog/presentation/` (plus `lib/l10n/`) and `test/`.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Localized strings for all new UI, before any widget references them

- [ ] T001 [P] Add new es-MX keys to `lib/l10n/app_es.arb`: `mergeKeptLabel`, `mergeDeletedLabel`, `mergeSwapTooltip`, `mergeComparisonTitle`, `mergeComparisonFieldHeader`, `mergeAcknowledgeLabel` (with a `{duplicateName}` placeholder), `mergeDiffBadge`; the diff-table field labels (`mergeFieldId`, `mergeFieldCode`, `mergeFieldSku`, `mergeFieldModel`, `mergeFieldBrand`, `mergeFieldUom`, `mergeFieldTaxRate`, `mergeFieldStatus`); the related-records keys (`mergeRelatedRecordsTitle`, `mergeRelatedDestroyedNote`, `mergeRelatedTotalLabel`, `mergeConfirmTotalLine` with a `{total}` placeholder); and one label per known preview category (`mergeCategorySalesOrderDetail`, `mergeCategoryPurchaseOrderDetail`, `mergeCategoryInventoryReceiptDetail`, `mergeCategoryInventoryIssueDetail`, `mergeCategoryInventoryTransferDetail`, `mergeCategoryLotSerialTracking`, `mergeCategoryProductPrice`, `mergeCategoryProductLabel`, `mergeCategoryFiscalDocumentDetail`, `mergeCategoryCommissionProduct`, `mergeCategoryCustomerDiscount`); replace `mergeConfirmMessage` with a four-placeholder version (`{canonicalName}`, `{canonicalCode}`, `{duplicateName}`, `{duplicateCode}`) per contracts/ui-contracts.md §6
- [ ] T002 [P] Add the matching en keys plus their `@`-metadata placeholder declarations to `lib/l10n/app_en.arb`, mirroring the existing `@mergeConfirmMessage` metadata style
- [ ] T003 Run `flutter gen-l10n` and confirm `lib/l10n/app_localizations.dart` exposes every new key with the expected signatures

**Checkpoint**: All new copy is localized and code-generated; no hardcoded strings will be needed downstream (constitution §V)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: State shape and the full-product comparison fetch that every user story below renders from

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T004 Extend `MergeProductsState` in `lib/features/catalog/presentation/merge_products_state.dart`: add the `acknowledged` field (default `false`), add the `reviewReady` derived getter (`bothSelected && !isSameProduct`), and update `canSubmit` to `reviewReady && acknowledged && !submission.isLoading` per data-model.md
- [ ] T005 Extend `MergeProductsController` in `lib/features/catalog/presentation/merge_products_controller.dart`: add `swap()` (exchanges `canonical`/`duplicate`, resets `acknowledged`) and `acknowledgeToggled()`, and reset `acknowledged: false` in the existing `canonicalSelected`/`duplicateSelected`/`canonicalCleared`/`duplicateCleared` mutators (research.md §3)
- [ ] T006 [P] Create `lib/features/catalog/presentation/merge_products_comparison_provider.dart` — a `@riverpod` function provider keyed by `(canonicalId, duplicateId)` that fetches both full `Product` records in parallel via `ProductRepository.get()` and returns `(Product kept, Product deleted)`, per contracts/product-repository.md
- [ ] T007 Run `dart run build_runner build --delete-conflicting-outputs` to regenerate `merge_products_state.freezed.dart`, `merge_products_controller.g.dart`, and the new provider's `.g.dart`
- [ ] T008 [P] Add `test/unit/features/catalog/merge_products_comparison_provider_test.dart`: both products fetched in parallel with the repository mocked, and a `NotFoundError` on either id surfacing as `AsyncError`

**Checkpoint**: State, controller operations, and the comparison data source exist and are unit-covered — user story UI can now be built

---

## Phase 3: User Story 1 - See exactly which product survives and which is destroyed (Priority: P1) 🎯 MVP

**Goal**: Render a side-by-side kept/deleted panel pair, built from full product records, before any confirmation dialog

**Independent Test**: With a canonical and duplicate selected, the review step shows two panels distinguishable by text label *and* visual treatment (not color alone), each with photo, name, code, SKU, and model; the deleted panel's name is struck through

- [ ] T009 [US1] Create `lib/features/catalog/presentation/widgets/merge_review_panel.dart` — the kept/deleted panel pair: each panel renders `Key('merge_kept_panel')` / `Key('merge_deleted_panel')`, a visible text label from `l10n.mergeKeptLabel`/`mergeDeletedLabel` plus a distinct container color and border (never color alone, FR-002), and photo (reusing `lib/core/widgets/product_photo.dart`), `productId`, name, code/SKU/model, status badge, unit-of-measure badge, and tax-rate badge; the deleted panel's name carries `TextDecoration.lineThrough`
- [ ] T010 [US1] Wire the review step into `lib/features/catalog/presentation/merge_products_screen.dart`: render it only when `state.reviewReady`, watch `mergeComparisonProvider(canonicalId:, duplicateId:)`, show a loading indicator (`Key('merge_comparison_loading')`) on `AsyncLoading` and the shared `ErrorBanner` on `AsyncError` — leaving the merge button disabled in both cases (FR-011) — and lay the panels side by side above `LayoutBreakpoints.compact` / stacked below it
- [ ] T011 [US1] Extend `test/widget/features/catalog/merge_products_screen_test.dart`: review step appears once both selections are valid and distinct; both panels render their labels and all required fields; the deleted name is struck through; the review step recomputes when a selection changes (no stale data); a failed comparison fetch shows the error banner and keeps the merge button disabled

**Checkpoint**: The core safety value ships — an operator can visually confirm which record survives before anything is submitted

---

## Phase 4: User Story 2 - Compare both products field by field (Priority: P1)

**Goal**: A diff table over the two full product records, flagging every field whose values differ

**Independent Test**: Two products differing in at least one field show that row flagged and matching rows unflagged; two identical products still render every row, none flagged

- [ ] T012 [US2] Create `lib/features/catalog/presentation/widgets/merge_comparison_table.dart` — one row per field (id, code, SKU, model, brand, unit of measure, tax rate, status per data-model.md), a persistent header row labeling the kept and deleted columns, and a `diff` flag per row computed as `kept.field != deleted.field`; flagged rows carry `Key('merge_diff_row')` and a visual treatment distinct from the panels' kept/deleted colors
- [ ] T013 [US2] Render the comparison table below the panels in `lib/features/catalog/presentation/merge_products_screen.dart`, sharing the same `AsyncValue` from `mergeComparisonProvider` (no second fetch)
- [ ] T014 [P] [US2] Add `test/widget/features/catalog/merge_comparison_table_test.dart`: diff computation across a matrix of matching/differing field combinations, including the all-fields-identical case rendering every row unflagged
- [ ] T015 [P] [US2] Extend `test/widget/features/catalog/merge_products_screen_test.dart` with a compact-width (`<600`) layout test asserting kept/deleted attribution stays unambiguous and no horizontal scroll is introduced (constitution §VI, FR-012)

**Checkpoint**: Meaningful discrepancies between two similar-looking products are now visible before the merge

---

## Phase 5: User Story 3 - Correct a backwards pick without starting over (Priority: P2)

**Goal**: A swap control that exchanges the kept and deleted roles consistently everywhere

**Independent Test**: Activating swap exchanges the panels, the table columns, and the underlying selections, with nothing left mismatched

- [ ] T016 [US3] Add the swap control (`Key('merge_swap_button')`, tooltip `l10n.mergeSwapTooltip`) between the two panels in `lib/features/catalog/presentation/widgets/merge_review_panel.dart`, calling `controller.swap()`
- [ ] T017 [P] [US3] Extend `test/unit/features/catalog/merge_products_controller_test.dart` with `swap()` transitions: `canonical`/`duplicate` exchange, and the resulting `mergeProducts` call would submit the post-swap canonical as `productId`
- [ ] T018 [P] [US3] Extend `test/widget/features/catalog/merge_products_screen_test.dart`: swap exchanges which product each panel shows and which column each table value falls under

**Checkpoint**: A backwards pick is recoverable in one tap instead of a full re-search

---

## Phase 6: User Story 4 - Be required to explicitly acknowledge what will be destroyed (Priority: P2)

**Goal**: An acknowledgment gate naming the specific doomed product, and a confirmation dialog restating both records

**Independent Test**: The merge button stays disabled until the acknowledgment is checked; swapping resets it; the final dialog names both products by name and code

- [ ] T019 [US4] Add the acknowledgment checkbox (`Key('merge_acknowledge_checkbox')`) to the review step in `lib/features/catalog/presentation/merge_products_screen.dart`, labeled with `l10n.mergeAcknowledgeLabel(state.duplicate!.name)` and bound to `state.acknowledged` / `controller.acknowledgeToggled()`
- [ ] T020 [US4] Extend `_confirmMerge`'s dialog content in `lib/features/catalog/presentation/merge_products_screen.dart` to call the four-placeholder `l10n.mergeConfirmMessage(canonicalName, canonicalCode, duplicateName, duplicateCode)` per contracts/ui-contracts.md §6, leaving the existing dialog keys, cancel/confirm flow, and `controller.submit()` call unchanged
- [ ] T021 [P] [US4] Extend `test/unit/features/catalog/merge_products_controller_test.dart`: `acknowledgeToggled()` flips the flag; `acknowledged` resets on every selection mutator and on `swap()`; `canSubmit` is false while unacknowledged
- [ ] T022 [P] [US4] Extend `test/widget/features/catalog/merge_products_screen_test.dart`: merge button disabled until acknowledged; the checkbox visibly unchecks itself after a swap and re-disables the button; the confirmation dialog shows both names and both codes; cancel leaves the review step and selections intact

**Checkpoint**: The destructive action now requires an affirmative, record-specific acknowledgment that cannot go stale

---

## Phase 7: User Story 5 - Understand the blast radius before merging (Priority: P3)

**Goal**: Show every category of record attached to the doomed product with counts and a total, sourced from the merge-preview endpoint

**Independent Test**: The review step lists per-category counts plus a server-supplied total; an unrecognized category still appears under a fallback label; price-list rows are marked destroyed rather than moved; a failed preview omits the section without blocking the merge

> **Note**: the endpoint and generated client already exist (mbe-api `990fa83` / mbe-ui `2d9b1e5`) — no regeneration needed, only mapping and UI. See research.md §4.

- [ ] T023 [US5] Create `lib/features/catalog/domain/entities/merge_preview.dart` — freezed `MergePreview { List<MergePreviewCategory> categories, int total }` and `MergePreviewCategory { String key, int count }` with the `isDestroyed` getter (`key` starting with `product_price.`), plus `fromResponse(ProductMergePreviewResponse)` preserving the server's category order and `total` verbatim (data-model.md)
- [ ] T024 [US5] Add `mergePreview({required int productId, required int duplicateId})` to `lib/features/catalog/domain/repositories/product_repository.dart` and implement it in `lib/features/catalog/data/product_repository_impl.dart` via the generated `previewProductMergeApiV1ProductsMergePreviewGet`, mapping through `MergePreview.fromResponse` and reusing the existing `_toAppError` chain (contracts/product-repository.md)
- [ ] T025 [US5] Add a merge-preview `@riverpod` provider keyed by `(canonicalId, duplicateId)` in `lib/features/catalog/presentation/merge_products_comparison_provider.dart`, exposing `AsyncValue<MergePreview>` independently of the comparison provider so a preview failure cannot block the review step
- [ ] T026 [US5] Add category label resolution in `lib/features/catalog/presentation/widgets/merge_related_records_summary.dart`: map known `table.column` keys to their `.arb` labels and humanize unrecognized keys (strip the `.column` suffix, underscores to spaces, sentence-case) — never drop a category or exclude it from the total (FR-006, SC-006)
- [ ] T027 [US5] Build the summary widget in the same file: one `Key('merge_related_category_row')` per category (label + count, server order), a destroyed-rather-than-moved qualifier on `isDestroyed` rows, a `Key('merge_related_total')` footer, `Key('merge_related_loading')` on `AsyncLoading`, and full omission on `AsyncError` (contracts/ui-contracts.md §3b)
- [ ] T028 [US5] Render the summary into the review step in `lib/features/catalog/presentation/merge_products_screen.dart` and append the total to the confirmation dialog as a separate `l10n.mergeConfirmTotalLine(total)` line that is skipped when the preview is pending or failed (contracts/ui-contracts.md §6)
- [ ] T029 [US5] Run `dart run build_runner build --delete-conflicting-outputs` for `merge_preview.freezed.dart` and the new provider's `.g.dart`
- [ ] T030 [P] [US5] Add `test/unit/features/catalog/merge_preview_test.dart` plus repository coverage in `test/unit/features/catalog/product_repository_impl_test.dart`: response→entity mapping preserves order and total, `isDestroyed` is true only for `product_price.*`, and a `DioException` maps to the expected `AppError`
- [ ] T031 [P] [US5] Add `test/widget/features/catalog/merge_related_records_summary_test.dart`: known categories render localized labels, an unknown key renders a humanized fallback (and is counted in the displayed total), a `product_price.*` row is marked destroyed, loading shows the placeholder, and an error omits the section while leaving the merge button enabled

**Checkpoint**: The operator can see the full blast radius — including record types the interface has never seen before — without it ever blocking or misdescribing the merge

---

## Phase 8: Polish & Cross-Cutting Concerns

- [ ] T032 Run `dart analyze lib test` and resolve any issues introduced by this feature
- [ ] T033 Run `flutter test` and confirm the full suite passes with no regressions in spec 008's existing merge coverage
- [ ] T034 Verify kept/deleted distinction survives a grayscale/color-blind check (labels and treatment carry the meaning without hue) per FR-002 and SC-001
- [ ] T035 Walk `specs/016-product-merge-review/quickstart.md` against a running app and record actual results in its "Automated coverage" section, matching spec 008's quickstart convention

---

## Dependencies

**Phase order**: Phase 1 → Phase 2 → (Phase 3 → Phase 4) → Phase 5 → Phase 6 → Phase 7 → Phase 8

- **Phase 1 (Setup)** blocks everything — widgets reference the generated l10n getters.
- **Phase 2 (Foundational)** blocks all user stories. Within it: T004 → T005 (controller's `swap()` needs the new state shape); T004/T006 → T007 (codegen); T006 → T008.
- **US1 (Phase 3)** blocks **US2 (Phase 4)** in practice: T013 renders the table into the same review-step scaffold T010 creates, and both share one `AsyncValue`.
- **US3 (Phase 5)** depends on US1 — the swap control lives inside the panel widget from T009.
- **US4 (Phase 6)** depends on Phase 2's `acknowledged` state and on US1's review step existing to host the checkbox. Independent of US3, except that T022 exercises the swap-reset interaction.
- **US5 (Phase 7)** depends on the review step existing (US1) to host the summary, and on Phase 6's dialog change only for T028's total line. Internally: T023 → T024 → T025 → T027/T028, with T026 feeding T027 and T029 (codegen) after T023/T025.

## Parallel Opportunities

- **Phase 1**: T001 and T002 (different `.arb` files).
- **Phase 2**: T006 and T008 can proceed alongside T004/T005 (different files); T008 lands after T006.
- **Phase 4**: T014 and T015 (different test files/concerns).
- **Phase 5**: T017 and T018 (unit vs. widget test files).
- **Phase 6**: T021 and T022 (unit vs. widget test files).
- **Phase 7**: T030 and T031 (unit vs. widget test files).

## Implementation Strategy

**MVP scope**: Phases 1–4 (both P1 stories). That delivers the entire safety rationale for this feature — an explicit kept/deleted presentation plus a field-level diff — and is independently shippable without swap, the acknowledgment gate, or the counts summary, since spec 008's existing confirmation dialog still guards the destructive action underneath.

**Incremental delivery**: Phase 5 (swap), Phase 6 (acknowledgment + restated confirmation), and Phase 7 (blast-radius summary) each add a self-contained increment on top of the MVP and can ship in separate passes. Phase 8 closes out quality gates.

**Nothing deferred**: FR-006 was previously out of scope pending [mictlanix/mbe-api#111](https://github.com/mictlanix/mbe-api/issues/111). That endpoint shipped and mbe-ui's client is already regenerated, so Phase 7 now implements it for real. No task in this list waits on an external dependency.
