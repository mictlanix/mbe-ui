# Quickstart: Validating Vehicle Operator License Photos

**Prerequisites**:
- The local mbe-api is running with `LICENSE_PHOTOS_DIR` configured.
- mbe-ui `.env` points at it.
- The `MBE_POS_*` admin account (see memory: dev tenant accounts) for full access.
- A second account with Read on Vehicle Operators but **without** Update, for Q6.
- Test images: one PNG under 2 MB, one JPG over 2 MB, and one `.pdf` file.

## Automated

```bash
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter analyze
flutter test test/unit/features/catalog/vehicle_operator_form_controller_test.dart \
             test/unit/features/catalog/vehicle_operator_repository_impl_test.dart \
             test/widget/features/catalog/vehicle_operator_form_test.dart
flutter test   # full suite: product photo preview must be unaffected (R7)
```

Expected: no errors, all tests pass. The coverage expected of these tests is listed in [research.md R10](research.md).

## Manual (live backend)

| # | Scenario | Steps | Expected |
|---|---|---|---|
| Q1 | Attach (US1) | Open an operator without a photo, Upload the PNG, then Save | The panel closes. Reopen: the thumbnail shows the photo. |
| Q2 | View and enlarge (US2) | Click the thumbnail | Preview dialog with the driver's name. Esc closes it. |
| Q3 | Replace and remove (US3) | Replace with another image and Save; then Remove and Save | The new image shows; then the placeholder shows. Remove before Save marks the form dirty. |
| Q4 | **§III multipart check** | During Q1, watch the network tab or API log | The POST is `multipart/form-data` with a real `file` part and returns 200 with `has_license_photo: true`. If it doesn't, apply the R2 fallback. |
| Q5 | Privacy (FR-004, SC-003) | `curl -i $API/api/v1/vehicle-operators/<id>/license-photo` without a token | 401. No public `/images/...` path exists for the photo. |
| Q6 | Read-only user (FR-013) | Sign in as the Read-only account and open the operator | The photo shows with no Upload, Replace or Remove controls. |
| Q7 | Create with photo (FR-011) | New operator, fill in the fields, Upload the PNG, Save | The operator is created with a photo. |
| Q8 | Rejections (FR-006) | Pick the over-2 MB JPG, then the `.pdf` file (if the picker allows it) | Inline errors; nothing sent. |
| Q9 | Partial failure (FR-012) | Stop mbe-api's photo storage (for example, make `LICENSE_PHOTOS_DIR` read-only) and save a staged photo | Banner: fields saved, photo not. The panel stays open with the photo still staged. Fix storage and Save again: it succeeds with no duplicate operator. |
| Q10 | Unavailable (FR-014) | Delete the photo file on disk for an operator that has one, then open it | "Photo unavailable" caption; the rest of the form works. |
