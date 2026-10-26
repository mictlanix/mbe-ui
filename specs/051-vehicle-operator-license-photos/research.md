# Research: Vehicle Operator License Photos

**Spec**: [spec.md](spec.md) | **Plan**: [plan.md](plan.md)

All Technical Context unknowns are resolved below. The backend facts come from reading mbe-api at `HEAD` (`app/api/v1/endpoints/vehicle_operators.py`, introduced in mbe-api `6a8ce82`) and from the live `GET /openapi.json` on the local dev server (2026-10-23).

---

## R1. Fetching the stored photo: raw-bytes dio GET, not the generated method

**Decision**: `VehicleOperatorRepositoryImpl.getLicensePhoto` calls the shared `dioProvider` dio directly:

```
GET /api/v1/vehicle-operators/{id}/license-photo
Options(responseType: ResponseType.bytes)
```

It returns the body as a `Uint8List`. Before returning, it checks the bytes start with the PNG signature (`89 50 4E 47 0D 0A 1A 0A`), the same way `DocumentSourceImpl` checks for `%PDF-`. A 200 response whose body is not a PNG (for example a proxy's HTML page) maps to `AppError.server()`.

Separately, we file an mbe-api issue asking that the route declare its real media type (see R1a). When that ships, regenerate the client and switch the repository to the generated method.

**Rationale**:
- The live OpenAPI documents the GET's 200 response as `application/json` with an empty schema. FastAPI does this by default for a `FileResponse` return with no `response_class`/`responses=` override.
- Because of that, the generated `getLicensePhoto…Get` returns `Response<JsonObject>`. It asks dio for the default JSON response type. A PNG body then comes back as a lossy UTF-8 string, or fails to decode, and is wrapped as a `StringJsonObject`. The image bytes cannot be recovered from it.
- The spec 044 PDF endpoints did not have this problem because mbe-api declared `application/pdf`, so the generator emitted `ResponseType.bytes`.
- Going through `dioProvider` keeps the request on the shared `AuthInterceptor`, which provides:
  - the bearer token (FR-004);
  - the 401 handling that ends the session;
  - error mapping. `_jsonBodyOf` already re-decodes JSON error bodies that arrive as bytes, so `{"detail": "License photo not found"}` still becomes a `NotFoundError` with its message.

**Alternatives considered**:
- *`Image.network(url, headers: {Authorization: …})`*: rejected.
  - It bypasses dio, which breaks §III ("all HTTP access MUST go through dio").
  - It loses the interceptor's 401/session handling and error mapping.
  - It needs the raw token in the widget layer.
  - On web it depends on renderer-specific header support.
- *Wait for the upstream fix before building*: rejected. The bypass is about 10 lines, uses an established pattern (raw `dio` + `appSerializers` for multipart uploads), and is easy to remove later. Blocking a weight-1 issue on a cross-repo round-trip isn't worth it.
- *Hand-edit the generated method*: forbidden by §III, and the next regeneration would overwrite it anyway.

### R1a. Upstream issue to file (mbe-api)

> **License photo GET is documented as `application/json`, so generated clients can't read the image**
>
> `GET /api/v1/vehicle-operators/{id}/license-photo` returns `FileResponse(..., media_type='image/png')`, but the route declares no `response_class` or `responses=`. The OpenAPI therefore advertises `200 → application/json, schema {}`. openapi-generator's dio client then requests JSON and wraps the PNG as a `JsonObject`, losing the bytes. mbe-ui works around this with a raw dio call.
>
> **Ask**: declare the real media type, for example `@router.get(..., response_class=FileResponse, responses={200: {"content": {"image/png": {}}, "description": "License photo (PNG)"}})`, so the 200 response is `image/png` with `schema: {type: string, format: binary}`.
>
> **Ref**: mictlanix/mbe-roadmap#21 (UI) / #20 (API).

Per §III, filing this is an outward-facing action, so it waits for the user's go-ahead. It is recorded as a non-blocking dependency in the plan.

---

## R2. Uploading: use the generated method, verify live once

**Decision**: `uploadLicensePhoto` calls the generated `uploadLicensePhotoApiV1VehicleOperatorsVehicleOperatorIdLicensePhotoPost(vehicleOperatorId:, file: MultipartFile.fromBytes(bytes, filename: filename))`. It maps the returned `VehicleOperatorResponse` through `VehicleOperator.fromResponse`. `removeLicensePhoto` calls the generated `delete…LicensePhotoDelete`.

**Rationale**:
- The generator emitted a real `MultipartFile file` parameter here, not the `String` regression §III warns about.
- The DELETE is a plain 204.
- §III still requires one live upload before the wrapper is trusted. That check is quickstart step Q4.

**Fallback**: if Q4 shows a regression, switch to the `ProductRepositoryImpl.uploadPhoto` pattern: `dio.post` + `FormData.fromMap({'file': MultipartFile.fromBytes(...)})`, deserializing with `appSerializers` (never `standardSerializers`, because of spec 043). Record the switch in this file.

---

## R3. Holding the fetched photo: an auto-disposing in-memory provider

**Decision**: add `licensePhotoProvider`, an `@riverpod` auto-dispose `Future<Uint8List>` family keyed by `vehicleOperatorId`, in a new `license_photo_provider.dart`.
- The form watches it only when the loaded operator has `hasLicensePhoto == true`.
- After a successful upload or remove, the controller invalidates it for that id.

**Rationale**:
- §VII forbids caching layers.
- The photo is personal data, so it must not outlive the screen. Auto-dispose drops the bytes when the form closes.
- `Image.memory` keeps the decoded image only in Flutter's in-process `ImageCache`, which is cleared with the process and never written to disk.
- Keeping the fetch out of `VehicleOperatorFormState` means:
  - the dirty-check snapshot (`_snapshot != current`) never sees an async load as an edit;
  - a failed photo load can't block the form, because it is a separate `AsyncValue` (FR-014).

**Alternatives considered**:
- *Fetch inside `loadForEdit` and store bytes in form state*: rejected.
  - A photo failure would mix into the form's `loadFailed` path.
  - It doubles the open latency for operators without a photo, unless guarded anyway.
  - It puts about 1 MB into the freezed equality used by the dirty check.
- *A keep-alive cache across forms*: rejected by §VII and privacy.

---

## R4. Staging and the save sequence (mirrors the product photo flow, with one deliberate difference)

**Decision**: the form state gains:
- `hasLicensePhoto`
- `pendingLicensePhotoBytes`
- `pendingLicensePhotoFilename`
- `licensePhotoMarkedForRemoval`

They follow the same transitions as `ProductFormController` (`photoPicked` / `photoRemoveRequested`; picking clears a pending removal and vice versa, FR-009). On save:

1. Validate the fields and check permission, both unchanged.
2. Create or update the fields, unchanged. On create, write the new `vehicleOperatorId` into state immediately.
3. Run the photo step:
   - if bytes are staged, upload them;
   - otherwise, if a removal is pending and the server photo exists, delete it.
4. On success, invalidate `licensePhotoProvider(id)` and the list, then set `saved: true` as today (the panel closes).
5. **If the photo step fails, do not set `saved`.** Keep the staged change. Set `error: licensePhotoSaveFailed` with the server detail. Fields already saved stay saved, and the list is already invalidated. The panel stays open, so the user can press Save again to retry (FR-012).

**The deliberate difference from products**: `ProductFormController` sets `saved: true` even when the photo upload fails. That is harmless on the product full screen. The vehicle operator form, however, lives in the catalog panel, which closes itself on `saved`. That would throw away the staged image and contradict FR-012.

**Retry after a create** is the trap:
- After step 2 of a create, the operator exists. A second `submitCreate` would create a duplicate.
- So the form's Save dispatch becomes `formState.vehicleOperatorId != null ? submitUpdate : submitCreate`, instead of keying off the widget's `_isEdit`.
- The retry therefore re-sends the fields, which is an idempotent PUT, and then the photo.

---

## R5. Who sees the photo controls: update access, also in create mode

**Decision**: `canEditPhoto = !readOnly && can(vehicleOperators, Update)`.

| Mode | Has update access | Behavior |
|---|---|---|
| Edit | yes | Thumbnail plus upload / replace / remove controls |
| Edit | no (read-only) | Thumbnail only (FR-013) |
| Create | yes | Section with placeholder plus upload control |
| Create | no (create only) | Section is hidden entirely |

**Rationale**:
- mbe-api guards both POST and DELETE `…/license-photo` with `_UPDATE`, not `_CREATE`.
- A create-only user's staged photo would be rejected with 403 after the operator was created, and could never be fixed from that account.
- Hiding the control is consistent with §IV ("hidden, never disabled").
- The GET uses `_READ`, which the form already requires to open at all.

---

## R6. Client-side validation: product rules, duplicated constants

**Decision**: the operator controller has its own `_maxLicensePhotoBytes = 2 * 1024 * 1024` and `_validLicensePhotoExtensions = ['.jpg', '.jpeg', '.png']`, with the same checks as `ProductFormController.photoPicked`. The file picker uses the same `FileType.custom` + `allowedExtensions` + `withData: true` call.

**Rationale**:
- The spec fixes the rule as identical to products (FR-006, Assumptions).
- Two private constants are simpler than a shared module for two callers.
- If a third photo field appears, extract them then.

---

## R7. The enlarged view: generalize the existing preview dialog slightly

**Decision**:
- In `lib/core/widgets/product_photo_preview.dart`, add `showPhotoPreview(context, {required ImageProvider image, required String title, required Widget Function(double side) placeholder})`. Its dialog body is the existing `_ProductPhotoPreviewDialog`, with `Image.network(photoUrl)` replaced by `Image(image: image)`.
- `showProductPhotoPreview` keeps its signature and delegates with `NetworkImage(photoUrl)` and its current `ProductPhoto(photoUrl: null)` placeholder. Product behavior is unchanged.
- The license thumbnail calls `showPhotoPreview(image: MemoryImage(bytes), title: driverName, placeholder: …)`.

**Rationale**:
- §VI asks for shared visual components to live once in `core/widgets/`.
- The dialog (sizing, close button, Escape/click-outside dismissal) is exactly what FR-003 needs.
- The only coupling is to a URL, so a small additive generalization avoids copying about 90 lines.

**Alternatives considered**:
- *Copy the dialog into the operator feature*: rejected as duplication of a core widget.
- *Rename the file or widget to a generic name*: rejected. It churns product imports for no behavior change, and CLAUDE.md asks for surgical changes.

---

## R8. The thumbnail and section widget: feature-local

**Decision**: a private `_LicensePhotoSection` in `vehicle_operator_form.dart` copies the product `_PhotoSection` layout:
- 168 px thumbnail;
- actions beside it on non-compact widths, stacked below on compact;
- full-width `FormGridChild`, placed after the issuing location and before the status.

The thumbnail renders one of five states:

| State | Shown when | Renders |
|---|---|---|
| staged | `pendingLicensePhotoBytes != null` | `Image.memory(pending)` |
| none | no photo, or removal pending | placeholder, `Icons.badge_outlined` |
| loading | `licensePhotoProvider` is loading | placeholder-sized progress indicator |
| loaded | provider has data | `Image.memory(bytes)`, tappable, opens the R7 preview |
| unavailable | provider error | placeholder plus "Photo unavailable" caption, not tappable (FR-014) |

**Rationale**:
- One consumer, so there's no `core/widgets/` extraction (CLAUDE.md §2).
- `ProductPhoto` is URL-based and product-iconed, so reusing it would need the same generalization for no second caller.
- Extracting a shared `_PhotoSection` would refactor the working product screen, which is out of scope.

---

## R9. Localization

**Decision**:
- Reuse `uploadPhotoButton`, `replacePhotoButton` and `removePhotoButton`.
- Add new es/en keys:
  - `licensePhotoLabel` ("License photo" / "Foto de la licencia")
  - `licensePhotoUnavailable`
  - `licensePhotoInvalidTypeError`
  - `licensePhotoTooLargeError`
  - `licensePhotoSaveFailedError` ("The operator was saved, but the license photo could not be saved. Press Save to try again.")
- Regenerate `app_localizations*.dart`.

**Rationale**: the product error strings name "product", so they can't be reused verbatim (FR-015).

---

## R10. Tests

**Decision**:
- **Unit tests**:
  - Controller: staging, mutual exclusion, size/type rejection, and the three save outcomes, including create → photo fails → retry calls update, not create.
  - Repository, with mocked dio: PNG bytes returned, non-PNG 200 → `ServerError`, JSON 404 → `NotFoundError`, upload maps the response, delete is called.
- **Widget tests** on `vehicle_operator_form_test.dart`:
  - each thumbnail state;
  - the control visibility matrix from R5;
  - the dirty flag set by staging or removal;
  - the preview opening.
- **Live check**: quickstart Q4 (one real upload / GET / DELETE round-trip against the dev tenant), as §III requires for the multipart wrapper. Automated as `test/integration/vehicle_operator_license_photo_live_test.dart`, which borrows an existing photo-less operator (creating one is rejected with 409 on the dev tenant for any input) and restores it afterwards; it also covers the unauthenticated 401 (Q5).
