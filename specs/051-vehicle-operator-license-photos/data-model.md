# Data Model: Vehicle Operator License Photos

**Spec**: [spec.md](spec.md) | **Research**: [research.md](research.md)

No new entities. Existing types gain a few fields, and one provider is added.

## 1. `VehicleOperator` (domain entity)

`lib/features/catalog/domain/entities/vehicle_operator.dart`

| Field | Type | Source | Notes |
|---|---|---|---|
| `hasLicensePhoto` | `bool` | `VehicleOperatorResponse.hasLicensePhoto ?? false` | New. The server never exposes the stored filename. |

## 2. `VehicleOperatorRepository` (domain interface + impl)

New methods:

| Method | Returns | Backend call | Notes |
|---|---|---|---|
| `getLicensePhoto({required int vehicleOperatorId})` | `Future<Uint8List>` | `GET …/license-photo` | Raw bytes (R1); a non-PNG 200 response throws `ServerError` |
| `uploadLicensePhoto({required int vehicleOperatorId, required Uint8List bytes, required String filename})` | `Future<VehicleOperator>` | `POST …/license-photo` (multipart `file`) | Generated wrapper (R2) |
| `removeLicensePhoto({required int vehicleOperatorId})` | `Future<void>` | `DELETE …/license-photo` | 204 |

Every `DioException` maps through the existing `_toAppError`.

## 3. `licensePhotoProvider` (new)

`lib/features/catalog/presentation/license_photo_provider.dart`. This is an `@riverpod` auto-dispose family of type `Future<Uint8List>`, keyed by `int vehicleOperatorId`, that calls `getLicensePhoto`.

- Watched by the form only when `hasLicensePhoto && pendingLicensePhotoBytes == null && !licensePhotoMarkedForRemoval`.
- Invalidated by the controller after a successful upload or remove.
- Never persisted (§VII, R3).

## 4. `VehicleOperatorFormState` (additions)

| Field | Type | Default | Meaning |
|---|---|---|---|
| `hasLicensePhoto` | `bool` | `false` | The server has a photo. Set by `loadForEdit` and updated after the photo step. |
| `pendingLicensePhotoBytes` | `Uint8List?` | `null` | Picked, validated, and not yet saved |
| `pendingLicensePhotoFilename` | `String?` | `null` | Sent as the multipart filename |
| `licensePhotoMarkedForRemoval` | `bool` | `false` | Remove on save |

New error codes in `VehicleOperatorFormErrorCode`:
- field error `licensePhoto`: `licensePhotoInvalidType`, `licensePhotoTooLarge`
- form-level error: `licensePhotoSaveFailed`

### Derived values (widget)

- `showsPhoto = pendingLicensePhotoBytes != null || (hasLicensePhoto && !licensePhotoMarkedForRemoval)`. This chooses replace + remove versus upload.
- `canEditPhoto = !readOnly && can(vehicleOperators, Update)` (R5).
- The section is hidden only when `!_isEdit && !canEditPhoto`.

### Transitions

| Event | Guard | Effect |
|---|---|---|
| `licensePhotoPicked(bytes, name)` | extension not in `.jpg/.jpeg/.png` | `fieldErrors['licensePhoto'] = licensePhotoInvalidType`; staged/saved photo unchanged |
| | `bytes.length > 2 MiB` | `fieldErrors['licensePhoto'] = licensePhotoTooLarge`; unchanged |
| | otherwise | stage the bytes and name; `licensePhotoMarkedForRemoval = false`; clear the `licensePhoto` field error |
| `licensePhotoRemoveRequested()` | nothing saved or staged | no-op |
| | otherwise | `licensePhotoMarkedForRemoval = hasLicensePhoto`; clear the staged bytes and name |

The second remove case clears a staged-only image back to "none". It only marks a server deletion when there is one to delete, which avoids the DELETE endpoint's 404.

### Save sequence

The fields step (create or update) is unchanged. It is followed by a photo step:

| Fields step | Photo step | Resulting state |
|---|---|---|
| fails | not attempted | unchanged from today (`createFailed` / `updateFailed` / field errors) |
| succeeds | nothing staged | `saved: true` |
| succeeds | upload or remove succeeds | `hasLicensePhoto` updated; staging cleared; `licensePhotoProvider(id)` invalidated; `saved: true` |
| succeeds | upload or remove fails | `vehicleOperatorId` set (from create); staging **kept**; `submitting: false`; `saved` stays `false`; `error: licensePhotoSaveFailed` + `errorDetail` |

**Retry**: Save dispatches on `formState.vehicleOperatorId != null`, so a retry after a create runs `submitUpdate` (R4).

Dirty check: staging and removal change the freezed state, so the existing `_snapshot != current` comparison reports them as unsaved (FR-010) with no extra code.
