---

description: "Task list for Product Photo Display & Upload"

---

# Tasks: Product Photo Display & Upload

**Input**: Design documents from `/specs/004-product-image-upload/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/](./contracts/), [quickstart.md](./quickstart.md)

**Tests**: Included per constitution §"Development Workflow & Quality Gates"
(unit/widget/integration tests are a quality gate, not optional, for this
project). Write each story's tests first; confirm they fail before
implementing.

**Organization**: Tasks are grouped by user story (spec.md priorities P1/P2)
to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no unmet dependencies)
- **[Story]**: Maps the task to US1 (View product photos while browsing),
  US2 (Upload a photo for a product), or US3 (Replace or remove an existing
  product photo)
- File paths are relative to the repository root

## Path Conventions

Single Flutter project per plan.md "Project Structure": `lib/`, `test/` at
repository root. This feature extends `lib/features/catalog/` (created by
002-product-catalog) and adds one new shared widget under
`lib/core/widgets/` — no new top-level directories, no new route.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Add the one new dependency this feature needs before any code
references it.

- [X] T001 Add `file_picker` to `pubspec.yaml` (research.md §4) and run
  `flutter pub get`.

**Checkpoint**: `file_picker` resolves and is importable.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: The shared photo/placeholder rendering widget and the two new
repository operations that every user story depends on (US1 needs display,
US2/US3 need both display-in-preview and the upload/remove calls).

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [X] T002 [P] Create the shared `ProductPhoto` widget (`Image.network` with
  an `errorBuilder` falling back to a placeholder; renders the placeholder
  directly when given a `null` URL — research.md §5, data-model.md "Derived
  display rule") in `lib/core/widgets/product_photo.dart`.
- [X] T003 [P] Widget test for `ProductPhoto`: renders the network image for
  a non-null URL, renders the placeholder for a `null` URL, and renders the
  placeholder when the network image fails to load, in
  `test/widget/core/widgets/product_photo_test.dart` (write first, confirm
  it fails before T002 lands).
- [X] T004 [P] Add `uploadPhoto({required int productId, required Uint8List
  bytes, required String filename}) -> Product` and `removePhoto({required
  int productId}) -> Product` to the `ProductRepository` interface in
  `lib/features/catalog/domain/repositories/product_repository.dart`
  (data-model.md "No new repository entity, two new repository operations").
- [X] T005 Implement `ProductRepositoryImpl.uploadPhoto` (raw
  `dio.post('/api/v1/products/$productId/image', data: FormData.fromMap({...
  MultipartFile.fromBytes(bytes, filename: filename) ...}))`) and
  `.removePhoto` (raw `dio.put('/api/v1/products/$productId', data:
  {'photo': null})`) in
  `lib/features/catalog/data/product_repository_impl.dart`, mapping errors
  through the existing `_toAppError(DioException)` helper, per
  contracts/mbe-api-products-photo.md (depends on T004).
- [X] T006 [P] `ProductRepositoryImpl.uploadPhoto`/`.removePhoto` tests
  covering `200`, `404`, `422` (unsupported type / oversized file, upload
  only), and a network/timeout error → `NetworkError` mapping (spec.md Edge
  Cases — interrupted upload), → `AppError` mapping, and asserting the raw
  request shape (multipart field name `file` for upload; JSON body
  `{"photo": null}` for remove) in
  `test/unit/features/catalog/product_repository_impl_test.dart` (extends
  the file from 002-product-catalog; write first, confirm it fails before
  T005 lands).

**Checkpoint**: `ProductRepository.uploadPhoto`/`.removePhoto` work
end-to-end against a real mbe-api instance; `ProductPhoto` renders correctly
in isolation. No screens wired up yet — user-story implementation can now
begin.

---

## Phase 3: User Story 1 - View product photos while browsing (Priority: P1) 🎯 MVP

**Goal**: Every product's photo (or a placeholder, if none/broken) displays
on both the catalog list and the product detail screen, for any user with
`products` Read access — no edit capability required (FR-001, FR-002).

**Independent Test**: quickstart.md "Story 1" — photo displays for a product
that has one, placeholder displays for a product that doesn't, placeholder
displays after simulating a broken photo URL.

### Tests for User Story 1

- [X] T007 [P] [US1] Widget test for `ProductsListScreen`: each row renders
  a `ProductPhoto` for its `ProductListItem.photo` value, which is always
  `null` today since mbe-api's list endpoint doesn't return a photo yet
  (placeholder-for-null case only — see T010; [mictlanix/mbe-api#71](https://github.com/mictlanix/mbe-api/issues/71)) in
  `test/widget/features/catalog/products_list_screen_test.dart` (extends the
  002-product-catalog file; write first, confirm it fails).
- [X] T008 [P] [US1] Widget test for `ProductDetailScreen` (read/view mode):
  renders a `ProductPhoto` for the loaded product's `photo` value in
  `test/widget/features/catalog/product_detail_screen_test.dart` (extends
  the 002-product-catalog file; write first, confirm it fails).
- [X] T009 [P] [US1] Integration test: open `/products` and confirm every
  list row shows the placeholder (mbe-api#71 — list rows have no photo
  data yet), then open a product with a photo and a product without one
  and confirm the detail screen shows the real photo / placeholder
  respectively, in
  `test/integration/product_photo_flow_test.dart` (new file; quickstart
  Story 1 scenarios 1-2, adjusted for the list-view limitation; write
  first, confirm it fails).

### Implementation for User Story 1

- [X] T010 [US1] Add a `photo` field to the `ProductListItem` entity,
  mapped from `ProductListItem.fromResponse` as `null` for now (the
  backend's list-row projection has no `photo` field —
  [mictlanix/mbe-api#71](https://github.com/mictlanix/mbe-api/issues/71); this keeps the entity forward-compatible so
  only the one-line mapping needs to change once that field ships, not the
  screen) in
  `lib/features/catalog/domain/entities/product_list_item.dart` (depends on
  T002).
- [X] T011 [US1] Render a `ProductPhoto` per row (always the placeholder
  today, per T010) in `ProductsListScreen`'s `DataTableView` column
  definition in
  `lib/features/catalog/presentation/products_list_screen.dart` (depends on
  T002, T010).
- [X] T012 [US1] Render a `ProductPhoto` for the loaded product's `photo` on
  `ProductDetailScreen` (view/edit mode, read-only positioning — no
  upload/replace/remove controls yet, those are US2/US3) in
  `lib/features/catalog/presentation/product_detail_screen.dart` (depends on
  T002).

**Checkpoint**: User Story 1 is fully functional and independently
testable — every product's photo or placeholder renders correctly in both
the list and detail views, with no edit capability required yet.

**Update**: [mictlanix/mbe-api#71](https://github.com/mictlanix/mbe-api/issues/71) (referenced in T007/T009/T010/T011 below as an
open limitation at the time those tasks were implemented) has since been
resolved — mbe-api's list endpoint now resolves `photo` to a full URL per
row, mirroring the detail endpoint. `ProductListItem.fromResponse` was
updated to map it directly (no longer hardcoded to `null`), and the
list-screen/integration tests were updated accordingly. The task
descriptions below are left as written to record what was actually true
at implementation time.

---

## Phase 4: User Story 2 - Upload a photo for a product (Priority: P1)

**Goal**: A user with `products` Update privilege can pick a valid image
file for a product that has none and, on save, see it persisted and
displayed in both list and detail views; invalid files (wrong type,
oversized) are rejected client-side with a clear message before any upload
attempt; a user without Update privilege never sees the upload affordance
(FR-003, FR-006, FR-007, FR-008, FR-010, FR-011).

**Independent Test**: quickstart.md "Story 2" — valid upload, unsupported
file type, oversized file, no-Update-privilege visibility check.

### Tests for User Story 2

- [X] T013 [P] [US2] `ProductFormController` tests: `photoPicked(bytes,
  filename)` stages `pendingPhotoBytes`/`pendingPhotoFilename` and clears
  `photoMarkedForRemoval`; client-side validation rejects a non-JPEG/PNG
  file or one over 2 MB with a field error and does not stage it; `loadForEdit`
  populates `photo` from the loaded `Product` in
  `test/unit/features/catalog/product_form_controller_test.dart` (extends
  the 002-product-catalog file; write first, confirm it fails).
- [X] T014 [P] [US2] `ProductFormController` tests: `submitCreate()` creates
  the product first, then — if a photo is staged — calls
  `ProductRepository.uploadPhoto` with the newly-returned `productId`, and
  surfaces an upload-specific, non-blocking error if that second call fails
  while still marking the create itself as saved (data-model.md "Save
  (create)") in
  `test/unit/features/catalog/product_form_controller_test.dart` (same file
  as T013; write first, confirm it fails).
- [X] T015 [P] [US2] Widget test for `ProductDetailScreen`: an upload/pick
  control is shown for a no-photo product only when `can(products, update)`
  is true, hidden entirely otherwise (FR-008, FR-009); picking an invalid
  file shows a field error and does not call the repository, in
  `test/widget/features/catalog/product_detail_screen_test.dart` (extends
  the file from T008; write first, confirm it fails).
- [X] T016 [US2] Integration test: with the Update-privilege account, pick a
  valid JPEG/PNG for a no-photo product, save, and confirm the photo appears
  on the detail screen and (after returning) in the list row; attempt an
  unsupported file type and confirm rejection with no change; attempt an
  oversized file and confirm rejection with no change; confirm the
  Read-only account sees no upload affordance, in
  `test/integration/product_photo_flow_test.dart` (extends T009's file;
  quickstart Story 2 scenarios 1-4; write first, confirm it fails).

### Implementation for User Story 2

- [X] T017 [US2] Add `photo`, `pendingPhotoBytes`, `pendingPhotoFilename`,
  `photoMarkedForRemoval` fields to `ProductFormState`, populate `photo` in
  `loadForEdit`, and add a `photoPicked(Uint8List bytes, String filename)`
  action with client-side type (JPEG/PNG) and size (≤2 MB) validation
  (FR-006, FR-007) in
  `lib/features/catalog/presentation/product_form_controller.dart`
  (data-model.md "ProductFormState"; depends on T013).
- [X] T018 [US2] Extend `submitCreate()` to, after a successful product
  creation, call `ProductRepository.uploadPhoto` when `pendingPhotoBytes` is
  set, using the newly-created product's id; surface a distinct, non-
  blocking error on upload failure without un-marking the create as `saved`
  (data-model.md "Save (create)"). **Move the existing
  `ref.invalidate(productsListControllerProvider)` call (currently
  immediately after the create call) to fire after the upload call as well**
  — i.e. invalidate once after create, and again after a staged upload
  completes — so the list view reflects the new photo on its next refresh
  (FR-011, SC-001) rather than the pre-upload state in
  `lib/features/catalog/presentation/product_form_controller.dart` (depends
  on T005, T017).
- [X] T019 [US2] Extend `submitUpdate()` to, after the existing field `PUT`
  succeeds, call `ProductRepository.uploadPhoto` when `pendingPhotoBytes` is
  set (data-model.md "Save (edit)"). **Add a second
  `ref.invalidate(productsListControllerProvider)` call after the upload
  call succeeds** (in addition to the existing one after the field `PUT`),
  so the list view reflects the new photo on its next refresh rather than
  the pre-upload state (FR-011, SC-005) in
  `lib/features/catalog/presentation/product_form_controller.dart` (depends
  on T005, T017; T019 and T018 touch the same file as each other and as
  US3's T024 — sequence, do not parallelize).
- [X] T020 [US2] Add a file-picker (`file_picker`) upload control to
  `ProductDetailScreen`, calling `photoPicked`, gated by
  `can(SystemObject.products, AccessRight.update)` — shown whenever there is
  no current/staged photo (FR-003, FR-008, FR-009) in
  `lib/features/catalog/presentation/product_detail_screen.dart` (depends on
  T001, T012, T017).

**Checkpoint**: User Stories 1 AND 2 both work independently — viewing
photos and uploading a first photo for a product are both fully usable.

---

## Phase 5: User Story 3 - Replace or remove an existing product photo (Priority: P2)

**Goal**: A user with `products` Update privilege can replace a product's
existing photo with a new valid one, or remove it entirely (reverting to
the placeholder), on save; a user without Update privilege sees the photo
but never the replace/remove affordances; remove is unavailable on a
product that already has none (FR-004, FR-005, FR-009, spec.md Edge Cases).

**Independent Test**: quickstart.md "Story 3" — replace an existing photo,
remove an existing photo, confirm no replace/remove affordance for a
Read-only account.

### Tests for User Story 3

- [X] T021 [P] [US3] `ProductFormController` tests: `photoRemoveRequested()`
  sets `photoMarkedForRemoval` and clears any staged
  `pendingPhotoBytes`/`pendingPhotoFilename`; calling `photoPicked` after a
  removal request clears `photoMarkedForRemoval` again (mutually exclusive
  per data-model.md); `photoRemoveRequested()` is a no-op when there is
  no current photo and nothing staged, in
  `test/unit/features/catalog/product_form_controller_test.dart` (extends
  T013/T014's file; write first, confirm it fails).
- [X] T022 [P] [US3] `ProductFormController` tests: `submitUpdate()` calls
  `ProductRepository.removePhoto` when `photoMarkedForRemoval` is true and
  no new photo is staged (data-model.md "Save (edit)") in
  `test/unit/features/catalog/product_form_controller_test.dart` (same file
  as T021; write first, confirm it fails).
- [X] T023 [P] [US3] Widget test for `ProductDetailScreen`: replace and
  remove controls render for a product with a photo only when
  `can(products, update)` is true; the remove control is absent/disabled
  for a product with no photo; neither control is shown for a Read-only
  account, in `test/widget/features/catalog/product_detail_screen_test.dart`
  (extends T015's file; write first, confirm it fails).
- [X] T024 [US3] Integration test: with the Update-privilege account,
  replace an existing photo with a different valid image and confirm it
  updates everywhere the product is displayed; remove an existing photo and
  confirm the placeholder returns everywhere; confirm the Read-only account
  sees the photo but no replace/remove affordance, in
  `test/integration/product_photo_flow_test.dart` (extends T016's file;
  quickstart Story 3 scenarios 1-3; write first, confirm it fails).

### Implementation for User Story 3

- [X] T025 [US3] Add a `photoRemoveRequested()` action to
  `ProductFormController` (sets `photoMarkedForRemoval`, clears
  `pendingPhotoBytes`/`pendingPhotoFilename`; no-ops when there is no
  current photo and nothing staged) and update `photoPicked` to clear
  `photoMarkedForRemoval` (data-model.md "State transitions") in
  `lib/features/catalog/presentation/product_form_controller.dart` (depends
  on T017).
- [X] T026 [US3] Extend `submitUpdate()` to call
  `ProductRepository.removePhoto` when `photoMarkedForRemoval` is true and
  no new photo is staged, else `uploadPhoto` as added in T019, else neither
  (data-model.md "Save (edit)"). The `removePhoto` branch must also trigger
  the same second `ref.invalidate(productsListControllerProvider)` call
  T019 added for the upload branch, so the list view reflects the photo's
  removal on its next refresh rather than the pre-removal state (FR-011,
  SC-005) in
  `lib/features/catalog/presentation/product_form_controller.dart` (depends
  on T005, T019, T025; sequence after T019, same file).
- [X] T027 [US3] Add replace and remove controls to `ProductDetailScreen`
  for a product/staged-state that currently has a photo, gated by
  `can(SystemObject.products, AccessRight.update)` — replace reuses the
  file-picker flow from T020 (calls `photoPicked`), remove calls
  `photoRemoveRequested` and is hidden/disabled when there is no current
  photo (FR-004, FR-005, FR-008, FR-009, spec.md Edge Cases) in
  `lib/features/catalog/presentation/product_detail_screen.dart` (depends on
  T020, T025; sequence after T020, same file).

**Checkpoint**: All three user stories are independently functional —
viewing, uploading, and replacing/removing product photos all work
end-to-end with deny-by-default RBAC enforced throughout.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final consistency pass across all three stories.

- [X] T028 [P] Run `dart run build_runner build --delete-conflicting-outputs`
  and resolve any `freezed`/`riverpod_generator` codegen errors introduced
  by `ProductFormState`'s new fields.
- [X] T029 [P] Add/update `es-MX` localized strings (`.arb` files under
  `lib/l10n/`) for all new upload/replace/remove affordances and error
  messages introduced in Phases 3-5 (constitution §V).
- [X] T030 Run `flutter analyze` across `lib/features/catalog/` and
  `lib/core/widgets/product_photo.dart` and resolve all warnings/errors.
- [ ] T031 Execute [quickstart.md](./quickstart.md) end-to-end against a
  local mbe-api instance (Stories 1-3 validation scenarios plus the Edge
  Cases spot-checks) and fix any discrepancies found.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately.
- **Foundational (Phase 2)**: Depends on Phase 1 (T005's multipart call
  needs `file_picker`'s byte format conventions settled, and T002-T006 are
  otherwise independent of T001, but Phase 2 is sequenced after Phase 1 per
  template convention). BLOCKS all user stories.
- **User Story 1 (Phase 3)**: Depends on Phase 2 completion (needs
  `ProductPhoto`). No dependency on US2/US3.
- **User Story 2 (Phase 4)**: Depends on Phase 2 completion and, for the
  detail-screen task (T020), on US1's T012 (same screen, photo already
  rendered there). Independent of US3 at the user-value level, but shares
  `product_form_controller.dart`/`product_detail_screen.dart` with it.
- **User Story 3 (Phase 5)**: Depends on Phase 2 and on User Story 2's
  `ProductFormController`/`ProductDetailScreen` extensions (T017-T020) — it
  extends the same files rather than creating new ones, so US3 cannot start
  in parallel with US2 even though it is a logically distinct, independently
  testable story.
- **Polish (Phase 6)**: Depends on whichever of Phases 3-5 are complete.

### Within Each User Story

- Tests (T007-T009, T013-T016, T021-T024) MUST be written and FAIL before
  their corresponding implementation tasks.
- Repository/state changes before screen wiring.
- Story complete before moving to the next priority where files overlap.

### Parallel Opportunities

- Phase 2: T002/T003 (widget + its test) and T004 (repository interface)
  can run in parallel; T005/T006 follow T004.
- User Story 1's three test tasks (T007-T009) can run in parallel; its three
  implementation tasks (T010-T012) touch three different files and can run
  in parallel once Phase 2 completes.
- User Stories 2 and 3 share `product_form_controller.dart` and
  `product_detail_screen.dart` and must be sequenced (US2 → US3), even
  though each delivers independent, demoable value once its own phase
  completes.
- All `[P]` test tasks within a story can run in parallel with each other.

---

## Parallel Example: User Story 1

```bash
# Tests (after Phase 2 checkpoint):
Task: "ProductsListScreen widget test (photo per row) in test/widget/features/catalog/products_list_screen_test.dart"
Task: "ProductDetailScreen widget test (photo display) in test/widget/features/catalog/product_detail_screen_test.dart"
Task: "product_photo_flow_test.dart integration test (Story 1 scenarios)"

# Implementation:
Task: "Add photo to ProductListItem in lib/features/catalog/domain/entities/product_list_item.dart"
Task: "Render ProductPhoto per row in lib/features/catalog/presentation/products_list_screen.dart"
Task: "Render ProductPhoto on ProductDetailScreen in lib/features/catalog/presentation/product_detail_screen.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup.
2. Complete Phase 2: Foundational (CRITICAL — blocks all stories).
3. Complete Phase 3: User Story 1.
4. **STOP and VALIDATE**: run quickstart.md Story 1 against local mbe-api.
5. Demo: every product's photo or placeholder renders correctly in the list
   and detail views — no upload capability needed yet.

### Incremental Delivery

1. Setup + Foundational → `ProductRepository.uploadPhoto`/`.removePhoto`
   and `ProductPhoto` working, no screens wired up.
2. Add User Story 1 → validate independently → MVP demo (display only).
3. Add User Story 2 → validate independently → demo (first upload).
4. Add User Story 3 → validate independently → demo (replace/remove).
5. Phase 6 polish across all three.

---

## Notes

- `[P]` tasks touch different files with no unmet dependencies.
- `[Story]` labels (US1-US3) map to spec.md priorities P1 (US1, US2) / P2
  (US3).
- `product_form_controller.dart` and `product_detail_screen.dart` are
  extended across all three stories (T012/T017-T020 for US1/US2,
  T025-T027 for US3) — these are NOT parallel with each other at the file
  level even though each delivers independent user-facing value; sequence
  them US1 → US2 → US3.
- `product_repository.dart`/`product_repository_impl.dart` are extended
  once, in Phase 2 (T004-T005), with both new methods together — US2 and
  US3 only consume them, they don't modify the repository further.
- Commit after each task or logical group; stop at any checkpoint to
  validate a story independently.
