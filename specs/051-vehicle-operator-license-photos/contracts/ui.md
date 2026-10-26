# Contract: Vehicle Operator Form — License Photo Section

The surface is the existing catalog panel that hosts `VehicleOperatorForm` (`SystemObject.vehicleOperators`, 89). No new route is added.

## Placement

A full-width `FormGridChild`, placed after **Issuing location** and before **Status**.
- Non-compact widths: 168 px thumbnail with the actions to its right.
- Compact widths: the actions stack below the thumbnail.

This mirrors the product `_PhotoSection`.

## Visibility (R5)

| Mode | `can(Update)` | Section | Controls |
|---|---|---|---|
| create | yes | shown (placeholder) | Upload |
| create | no | **hidden** | — |
| view (read-only, or update granted but not yet in edit) | any | shown | none |
| edit | yes | shown | Upload, or Replace + Remove |

## Thumbnail states (R8)

| State | Condition | Render | Tap |
|---|---|---|---|
| staged | pending bytes | `Image.memory(pending)` | — |
| none | no server photo, or removal pending | placeholder (`Icons.badge_outlined`) | — |
| loading | provider loading | placeholder-sized progress indicator | — |
| loaded | provider data | `Image.memory(bytes)` | opens `showPhotoPreview` titled with the driver's name |
| unavailable | provider error | placeholder plus `licensePhotoUnavailable` caption | — |

## Keys (for tests)

| Key | Element |
|---|---|
| `license_photo_section` | section root |
| `license_photo_thumbnail` | tappable loaded image |
| `upload_license_photo_button` | upload |
| `replace_license_photo_button` | replace |
| `remove_license_photo_button` | remove |
| `license_photo_unavailable` | unavailable caption |
| `photo_preview_dialog` | the existing preview dialog key, reused |

## Messages

| Situation | Where shown | Key |
|---|---|---|
| Wrong type | field error under the section | `licensePhotoInvalidTypeError` |
| Over 2 MB | field error under the section | `licensePhotoTooLargeError` |
| Fields saved but photo step failed | form `ErrorBanner` with `errorDetail`; panel stays open | `licensePhotoSaveFailedError` |
