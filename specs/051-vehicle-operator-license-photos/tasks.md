---
description: "Task list for 051-vehicle-operator-license-photos"
---

# Tasks: Vehicle Operator License Photos

**Input**: Design documents from `specs/051-vehicle-operator-license-photos/`

**Prerequisites**: plan.md, spec.md, research.md (R1–R10), data-model.md, contracts/consumed-endpoints.md (C1–C5), contracts/ui.md, quickstart.md

**Tests**: The spec doesn't ask for a test suite as such, but the constitution's quality gates and research R10 require tests. Test tasks sit inside each story, after the code they cover.

**Organization**: Grouped by user story (US1–US3, spec.md). US1 and US2 are both P1. US2 depends only on Foundational and on US1's section widget, so it can follow immediately. US3 builds on US1's save sequence.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: parallelizable (different files, no dependency on an incomplete task)
- **[Story]**: US1 attach · US2 view and enlarge · US3 replace and remove

## Cross-story notes

- **Shared files.** Several tasks edit the same files, so do these sequentially, not in parallel:
  - `lib/features/catalog/presentation/vehicle_operator_form_controller.dart`: T009, T010, T016
  - `lib/features/catalog/presentation/vehicle_operator_form.dart`: T011, T014, T017
  - `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb`: T006 only. Run `flutter gen-l10n` after it and commit the regenerated `lib/l10n/app_localizations*.dart` files. Never hand-edit those.
  - `test/unit/features/catalog/vehicle_operator_form_controller_test.dart`: T012, T018
  - `test/widget/features/catalog/vehicle_operator_form_test.dart`: T013, T015, T019
- **Generated code.** After editing a freezed or `@riverpod` file, run `dart run build_runner build --delete-conflicting-outputs`.
- **No backend work.** Nothing here touches mbe-api, and the OpenAPI client is not regenerated beyond the drift check in T001.
- **Language.** User-visible text is in Spanish and English (FR-015).
- **Privacy.** Photo bytes must never be written to disk or exposed by URL (FR-004, R3). Don't add `Image.network`, a keep-alive provider, or any persistence.

---

## Phase 1: Setup

**Purpose**: a known-good baseline, so later failures are attributable.

- [X] T001 Run `flutter analyze` and the vehicle operator and product photo tests (`test/**/vehicle_operator*_test.dart`, `test/**/product_photo*_test.dart`, `test/**/product_form*_test.dart`) on the clean branch. Note any pre-existing failures so they are not blamed on this feature. Then check the generated client for drift: regenerate `lib/generated/openapi/` from the dev mbe-api's `/openapi.json` the same way earlier regenerations were done, and expect `git status lib/generated` to show no changes. If it does change, stop and review the diff against contracts C1–C5 before continuing.

---

## Phase 2: Foundational (blocks all stories)

**Purpose**: the data path and shared pieces every story uses.

- [X] T002 [P] Add `bool hasLicensePhoto` (default `false`) to `VehicleOperator` in `lib/features/catalog/domain/entities/vehicle_operator.dart`, mapped in `fromResponse` from `response.hasLicensePhoto ?? false` (data-model §1). Run build_runner.
- [X] T003 [P] Add `getLicensePhoto`, `uploadLicensePhoto` and `removeLicensePhoto` to `lib/features/catalog/domain/repositories/vehicle_operator_repository.dart` with the signatures in data-model §2.
- [X] T004 Implement the three methods in `lib/features/catalog/data/vehicle_operator_repository_impl.dart` (depends on T002, T003):
  - Keep the `Dio` passed to the constructor in a `_dio` field.
  - `getLicensePhoto`: `_dio.get<List<int>>('/api/v1/vehicle-operators/$id/license-photo', options: Options(responseType: ResponseType.bytes))`. Return the bytes as a `Uint8List`. Throw `AppError.server()` when the body is null or does not start with the PNG signature `89 50 4E 47 0D 0A 1A 0A` (R1, same idea as `_looksLikePdf` in `lib/core/documents/data/document_source_impl.dart`).
  - `uploadLicensePhoto`: the generated `uploadLicensePhotoApiV1VehicleOperatorsVehicleOperatorIdLicensePhotoPost` with `MultipartFile.fromBytes(bytes, filename: filename)`, mapped through `VehicleOperator.fromResponse` (R2).
  - `removeLicensePhoto`: the generated `deleteLicensePhotoApiV1VehicleOperatorsVehicleOperatorIdLicensePhotoDelete`.
  - Wrap every call in `try … on DioException catch (e) { throw _toAppError(e); }` like the existing methods.
- [X] T005 Extend `test/unit/features/catalog/vehicle_operator_repository_impl_test.dart` (R10):
  - PNG bytes are returned as-is.
  - A 200 with a non-PNG body (for example HTML) throws a server error.
  - A JSON 404 delivered as bytes becomes a `NotFoundError` carrying its `detail` message.
  - Upload maps the response, and `hasLicensePhoto` is true on the returned entity.
  - Remove calls the DELETE.
  - `fromResponse` maps `hasLicensePhoto` and defaults to false when absent.
- [X] T006 [P] Add the l10n keys to `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb` (R9): `licensePhotoLabel`, `licensePhotoUnavailable`, `licensePhotoInvalidTypeError`, `licensePhotoTooLargeError`, `licensePhotoSaveFailedError`. The reused `uploadPhotoButton`, `replacePhotoButton` and `removePhotoButton` already exist. Run `flutter gen-l10n`.
- [X] T007 Create `lib/features/catalog/presentation/license_photo_provider.dart`: an `@riverpod` auto-dispose `Future<Uint8List>` family keyed by `int vehicleOperatorId`, calling `vehicleOperatorRepositoryProvider.getLicensePhoto` (data-model §3, R3). It must not be keep-alive. Run build_runner. Depends on T003.
- [X] T008 [P] In `lib/core/widgets/product_photo_preview.dart`, add `Future<void> showPhotoPreview(BuildContext, {required ImageProvider image, required String title, required Widget Function(double side) placeholder})`. Make the existing dialog body use `Image(image: image)` with `placeholder` as the `errorBuilder` result. Keep `showProductPhotoPreview` with its current signature, delegating to it with `NetworkImage(photoUrl)` and the current `ProductPhoto(photoUrl: null, …)` placeholder (R7). Keep the `photo_preview_dialog`, `photo_preview_close` keys and the dismissal behavior. Product behavior must not change: re-run the product photo preview tests.

**Checkpoint**: `flutter analyze` is clean, and T005 plus the product photo preview tests pass.

---

## Phase 3: User Story 1 — Attach a license photo (P1) 🎯 MVP

**Goal**: pick an image on the operator form, see a preview, and have it stored when the form is saved, in both create and edit mode.

**Independent test**: open an operator without a photo, Upload a PNG, Save, reopen: the photo is there (quickstart Q1, Q4, Q7, Q8, Q9).

- [X] T009 [US1] In `lib/features/catalog/presentation/vehicle_operator_form_controller.dart`, add to `VehicleOperatorFormState` the four fields from data-model §4: `hasLicensePhoto`, `pendingLicensePhotoBytes`, `pendingLicensePhotoFilename`, `licensePhotoMarkedForRemoval`. Add the error codes `licensePhotoInvalidType`, `licensePhotoTooLarge` and `licensePhotoSaveFailed` to `VehicleOperatorFormErrorCode`. Set `hasLicensePhoto` from the entity in `loadForEdit`. Add `licensePhotoPicked(Uint8List bytes, String filename)`: reject by extension (`.jpg/.jpeg/.png`) and by size (more than 2 MiB) into `fieldErrors['licensePhoto']`, leaving the staged and saved photo untouched. Otherwise stage it, clear a pending removal and clear the field error (R6; same checks as `ProductFormController.photoPicked`). Run build_runner.
- [X] T010 [US1] In the same controller, add the upload photo step after the fields step in both `submitCreate` and `submitUpdate` (R4, data-model §4 "Save sequence"):
  - On a create, store the new `vehicleOperatorId` in state as soon as the fields step succeeds.
  - If bytes are staged, call `uploadLicensePhoto`. On success set `hasLicensePhoto: true`, clear the staging, `ref.invalidate(licensePhotoProvider(id))`, then `saved: true`.
  - On failure, **do not set `saved`**. Keep the staging, set `submitting: false`, and set `error: licensePhotoSaveFailed` with `errorDetail`. The list is already invalidated.
  - With nothing staged, behavior is unchanged.
- [X] T011 [US1] In `lib/features/catalog/presentation/vehicle_operator_form.dart` add a private `_LicensePhotoSection` (R8, contracts/ui.md), placed after Issuing location and before Status as a full-width `FormGridChild`:
  - 168 px thumbnail; actions beside it, or stacked below on compact widths (`LayoutBreakpoints.isCompact`). Spacing comes from tokens.
  - For now it renders the **staged** state (`Image.memory`) and the **none** state (placeholder with `Icons.badge_outlined`).
  - The Upload button (`upload_license_photo_button`) opens `FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['jpg','jpeg','png'], withData: true)` and calls `licensePhotoPicked` (copy the shape of `_pickPhoto` in `product_detail_screen.dart`).
  - Show the section's field error (`licensePhotoInvalidTypeError` or `licensePhotoTooLargeError`) beneath it.
  - Visibility per R5: `canEditPhoto = !readOnly && can(vehicleOperators, Update)`. Hide the whole section when `!_isEdit && !canEditPhoto`. In view mode, show it with no controls.
  - Map the new error codes in `_localizeFormError` and `_localizeFieldError`.
  - Change the Save dispatch from `_isEdit ? submitUpdate : submitCreate` to `formState.vehicleOperatorId != null ? submitUpdate : submitCreate`, so a retry after a failed photo step on a create doesn't create a duplicate (R4).
  - Keys: `license_photo_section`, `upload_license_photo_button`.
- [X] T012 [US1] Extend `test/unit/features/catalog/vehicle_operator_form_controller_test.dart`:
  - Picking a valid file stages it and clears any field error.
  - A wrong extension is rejected, and an oversized file is rejected; in both cases a previously staged photo is kept.
  - `loadForEdit` sets `hasLicensePhoto`.
  - Update with a staged photo uploads, then sets `saved`, clears the staging and invalidates the provider.
  - Create with a staged photo creates the operator first, then uploads.
  - **Create, then the upload fails**: `saved` stays false, the staging is kept, `vehicleOperatorId` is set, and the error is `licensePhotoSaveFailed` with the server detail.
  - Nothing staged: no upload is attempted.
- [X] T013 [US1] Extend `test/widget/features/catalog/vehicle_operator_form_test.dart`:
  - The section shows the placeholder and the Upload button for an edit user with update access.
  - After a pick, the preview shows and the form reports dirty (FR-010).
  - The section is hidden in create mode for a user without Update.
  - After a failed photo step the panel stays open with the error banner.
  - Pressing Save again after a failed create photo calls update, not create (R4).
  - Stub `FilePicker` the way the product form tests do, or drive the controller method directly if the existing tests do.

**Checkpoint**: US1 works end-to-end on its own. A newly attached photo is stored, and the retry path is safe.

---

## Phase 4: User Story 2 — View and enlarge a license photo (P1)

**Goal**: show an operator's stored photo as a thumbnail that opens larger, and degrade gracefully when it can't be loaded.

**Independent test**: open an operator that already has a photo: the thumbnail shows, a click enlarges it, and a read-only user sees it without controls (quickstart Q2, Q6, Q10).

- [X] T014 [US2] In `_LicensePhotoSection` (`lib/features/catalog/presentation/vehicle_operator_form.dart`) add the server-photo states. Watch `licensePhotoProvider(id)` only when `hasLicensePhoto && pendingLicensePhotoBytes == null && !licensePhotoMarkedForRemoval` (data-model §3):
  - **loading**: a progress indicator the size of the placeholder.
  - **loaded**: `Image.memory(bytes)` with `Key('license_photo_thumbnail')`, a click cursor, and a tap that calls `showPhotoPreview(context, image: MemoryImage(bytes), title: <driver name>, placeholder: …)` from T008.
  - **unavailable** (provider error): the placeholder plus a `licensePhotoUnavailable` caption with `Key('license_photo_unavailable')`, not tappable (FR-014). The rest of the form stays usable.
  - In view mode (read-only) these states render with no controls (FR-013).
- [X] T015 [US2] Extend `test/widget/features/catalog/vehicle_operator_form_test.dart`, overriding `licensePhotoProvider` and using a tiny valid PNG fixture:
  - Loaded: the thumbnail shows, a tap opens `photo_preview_dialog` titled with the driver's name, and the close button dismisses it.
  - Loading and error states render as in contracts/ui.md, and the error case keeps the form fields enabled.
  - An operator without a photo makes **no** provider request.
  - A user with Read but not Update sees the photo and none of the Upload, Replace or Remove buttons.

**Checkpoint**: US1 and US2 together cover the P1 scope: attach and view.

---

## Phase 5: User Story 3 — Replace or remove a license photo (P2)

**Goal**: replace the stored photo with a new one, or remove it, each applied on save.

**Independent test**: on an operator with a photo, Replace and Save to see the new image; then Remove and Save to see the placeholder (quickstart Q3).

- [X] T016 [US3] In `vehicle_operator_form_controller.dart` add `licensePhotoRemoveRequested()` and the remove step in the save sequence (data-model §4):
  - With nothing saved or staged it is a no-op.
  - Otherwise it clears any staged bytes and filename, and sets `licensePhotoMarkedForRemoval = hasLicensePhoto`. A staged-only image therefore goes back to "none" without any server call.
  - In the photo step of `submitUpdate`, after the staged-upload branch, add: if no bytes are staged and a removal is pending, call `removeLicensePhoto`, then set `hasLicensePhoto: false`, clear the mark, invalidate the provider and set `saved: true`. A failure follows the same keep-open rule as T010.
  - Check that `licensePhotoPicked` clears the pending removal (T009).
- [X] T017 [US3] In `_LicensePhotoSection` add the Replace (`replace_license_photo_button`) and Remove (`remove_license_photo_button`) buttons. They are shown instead of Upload when `pendingLicensePhotoBytes != null || (hasLicensePhoto && !licensePhotoMarkedForRemoval)`, and only when `canEditPhoto`. Replace opens the same picker, and Remove calls `licensePhotoRemoveRequested`. Both are disabled while `submitting`. A pending removal shows the placeholder and the Upload button.
- [X] T018 [US3] Extend `test/unit/features/catalog/vehicle_operator_form_controller_test.dart`:
  - Marking for removal sets the mark and clears any staged bytes.
  - Remove on a form with no photo and nothing staged is a no-op.
  - Remove on a staged-only image clears it without setting the mark.
  - Picking after a pending removal cancels the removal.
  - Save with a pending removal calls `removeLicensePhoto`, clears `hasLicensePhoto` and invalidates the provider.
  - A replace uploads the new image and never calls remove.
  - A failed remove keeps the mark and `saved` stays false.
- [X] T019 [US3] Extend `test/widget/features/catalog/vehicle_operator_form_test.dart`:
  - With a photo, Replace and Remove show instead of Upload.
  - Tapping Remove shows the placeholder and the form becomes dirty.
  - Picking a new file after Remove stages it and cancels the removal.
  - No Replace or Remove appears for a read-only user.

**Checkpoint**: all three user stories work independently.

---

## Phase 6: Polish & cross-cutting

- [X] T020 Run `flutter analyze` and the full `flutter test`; fix anything this feature introduced. Check that the product photo preview and product form tests still pass unchanged (R7). *(Result: analyze shows only the 8 info-level lints that were there before; 3,302 tests pass. The 8 failures are all in `test/golden/core_widgets_golden_test.dart` (0.05% pixel diffs) and fail identically on a clean checkout, so they are not from this feature.)*
- [ ] T021 *(Q4, Q5 and the upload, read, replace, remove round trip are now automated in `test/integration/vehicle_operator_license_photo_live_test.dart`, run with `flutter test test/integration/vehicle_operator_license_photo_live_test.dart --dart-define-from-file=.env`. Passed against the local mbe-api on 2026-10-25, after mictlanix/mbe-api#257 shipped. Manual checks on macOS, 2026-10-26: Q1, Q2, Q3 and Q8 pass (the picker greys out PDFs). Q6, Q7, Q9 and Q10 are still to do.)* Run the manual quickstart Q1–Q10 against the live dev backend (`specs/051-vehicle-operator-license-photos/quickstart.md`). Q4 is the §III multipart check: if the generated upload wrapper doesn't send a real file part, apply the R2 fallback (`dio.post` + `FormData` + `MultipartFile.fromBytes`, deserialized with `appSerializers`) and record the change in research.md R2. Q5 must confirm the photo is unreachable without a token.
- [X] T022 *(Filed as mictlanix/mbe-api#257, together with the create/update 409 bug, `updater = 0`, found while trying to attach a photo.)* Only on the user's go-ahead, file the mbe-api issue drafted in research.md R1a (the GET declared as `application/json` instead of `image/png`), then add a link to it in plan.md's External Dependencies table. This is an outward-facing action and is not part of the build. Skip it if the user declines.
- [X] T023 After mictlanix/mbe-api#257 shipped, swap `getLicensePhoto`'s raw `dio.get` for the generated `getLicensePhoto…Get` (which now returns `Response<Uint8List>`), keeping the PNG signature check; update the §III row in plan.md (mbe-ui#214).

---

## Dependencies & execution order

```text
T001 ─► Foundational ─► US1 ─► US2 ─► US3 ─► Polish
```

- **Foundational**:
  - T002, T003, T006 and T008 are independent files and can run in parallel.
  - T004 needs T002 and T003.
  - T005 needs T004.
  - T007 needs T003.
- **US1** needs Foundational. Within it: T009 → T010 → T011, with T012 and T013 after the code they test.
- **US2** needs T007, T008 and US1's T011 (the section widget it extends).
- **US3** needs US1's T009–T011, because it extends the same controller and section. It doesn't depend on US2's viewing states, but its removal flow reads better to test once US2 exists.
- **Polish** needs all stories. T022 is independent of the code and waits for the user.

## Parallel example

```text
Foundational wave 1 (parallel): T002, T003, T006, T008
Foundational wave 2:            T004 (after T002+T003), T007 (after T003)
Then:                            T005
```

After Foundational, the work is mostly sequential because each story edits the same controller and form files.

## Implementation strategy

- **MVP (P1)**: Foundational plus US1 and US2, meaning attach and view. This delivers the legacy behavior's core. US3 can ship in the same PR, since it adds about 40 lines and shares the same files.
- **Incremental**: finish each checkpoint before starting the next phase, and run `flutter analyze` plus that story's tests each time.
- **Risk order**: the riskiest pieces are the raw-bytes GET (T004/T005) and the keep-open save sequence (T010/T012). Both come first and have dedicated tests.
