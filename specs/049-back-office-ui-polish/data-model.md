# Data Model: Back-Office UI Polish

**Feature**: [spec.md](./spec.md) | **Research**: [research.md](./research.md)

No backend schema changes. Only client-side value types change.

## 1. `AppSettings.multiCurrencyEnabled` (new field)

| Field | Type | Source | Default | Fallback |
|---|---|---|---|---|
| `multiCurrencyEnabled` | `bool` | `MULTI_CURRENCY_ENABLED` (build-time `--dart-define-from-file`) | `false` | Anything other than case-insensitive `true` or `false` resolves to `false` |

- Exposed as `multiCurrencyEnabledProvider` (`Provider<bool>`), derived from `appSettingsProvider`.
- Immutable for the life of the process. Not reachable from the UI (constitution §V).

## 2. `NavDestination.requiresMultiCurrency` (new field)

| Field | Type | Default | Meaning |
|---|---|---|---|
| `requiresMultiCurrency` | `bool` | `false` | The destination is shown and its route reachable only while `multiCurrencyEnabled` is `true`. This is checked in addition to `gate`. |

- Set only on the `exchange-rates` destination.
- `routeRequiresMultiCurrency(location)` is derived from the navigation tree: it is true when some destination with the flag has a `route` that is a prefix of `location`.

**Visibility rule**: `visible = (!requiresMultiCurrency || multiCurrencyEnabled) && gatePasses`.

## 3. `Facility.logo` (meaning changes)

- **Before**: the raw `FacilityResponse.logo` string, typed by the user.
- **After**: the same value resolved through `resolvePhotoUrl`, giving an absolute URL ready to fetch, or `null`. It is read-only on the client and written only by the logo upload endpoint.

## 4. `FacilityFormState` (fields changed)

| Field | Change | Type | Notes |
|---|---|---|---|
| `logo` | **removed** | — | No longer edited as text or sent on create/update (R4 latent-overwrite fix). |
| `logoUrl` | **added** | `String?` | The loaded facility's resolved logo, for display. Replaced by the upload response after a successful upload. |
| `pendingLogoBytes` | **added** | `Uint8List?` | The image picked and validated, staged until save. |
| `pendingLogoFilename` | **added** | `String?` | The original filename of the staged bytes, needed for the multipart part. |
| `fieldErrors['logo']` | **new key** | `String` | `FacilityFormErrorCode.logoInvalidType` or `logoTooLarge`. |
| `error` | **new code** | `String` | `FacilityFormErrorCode.logoUploadFailed`, set together with `saved: true`. |

**Validation** (`logoPicked`):
- The extension must be `.jpg`, `.jpeg` or `.png` (case-insensitive).
- The size must be ≤ 2 MB, matching both the server's `_MAX_BYTES` and the product photo limit.
- On failure, the staged bytes and `logoUrl` are left untouched.

**State transitions**:

```text
idle ──logoPicked(valid)──▶ staged(pendingLogoBytes)
idle/staged ──logoPicked(invalid)──▶ same + fieldErrors['logo']
staged ──submit ok──▶ uploading ──ok──▶ saved(logoUrl = response.logo, pending cleared)
                                 └─fail─▶ saved + error=logoUploadFailed (pending kept for retry)
staged ──submit fails──▶ staged + error (no upload attempted)
```

## 5. `FacilityRepository` (interface change)

| Member | Change |
|---|---|
| `create(..., String? logo, ...)` | The `logo` parameter is removed. |
| `update(..., String? logo, ...)` | The `logo` parameter is removed, so logo is never sent on PUT. |
| `uploadLogo({required int facilityId, required Uint8List bytes, required String filename}) → Future<Facility>` | **Added**. Calls `POST /api/v1/facilities/{id}/logo` through the generated `FacilitiesApi`. |

## 6. `PaymentAmountField.currency` (type change)

`Currency` becomes `Currency?`. With `null`, no currency prefix is rendered.

## 7. `DataTableView` (new optional parameters)

| Parameter | Type | Default | Applies to | Effect |
|---|---|---|---|---|
| `shrinkWrap` | `bool` | `false` | unpaginated only | The table's height is computed from its own heading, row and divider heights, so it never scrolls vertically. |
| `margin` | `EdgeInsetsGeometry?` | `null` (theme `cardTheme.margin`) | unpaginated only | The margin of the wrapping `Card`. |
