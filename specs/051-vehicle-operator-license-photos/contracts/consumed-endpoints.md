# Contract: Consumed mbe-api Endpoints

These endpoints already exist in mbe-api (`6a8ce82`, with authorization as at `HEAD`). This feature adds no backend change; the one upstream request (R1a) is non-blocking.

| # | Method & path | Auth (server) | Request | Success | Errors the UI handles | Client call |
|---|---|---|---|---|---|---|
| C1 | `GET /api/v1/vehicle-operators/{id}` | `VehicleOperators` Read | — | `VehicleOperatorResponse` incl. `has_license_photo: bool` | existing | generated (unchanged) |
| C2 | `POST /api/v1/vehicle-operators/{id}/license-photo` | `VehicleOperators` **Update** | multipart `file` (≤ 2 MB, any decodable image) | 200 `VehicleOperatorResponse` (`has_license_photo: true`) | 404 operator; 422 undecodable or too large (`detail` string); 403 | generated `upload…Post` (R2; live-verify Q4) |
| C3 | `GET /api/v1/vehicle-operators/{id}/license-photo` | `VehicleOperators` Read | — | 200 `image/png` bytes (width ≤ 1024 px) | 404 operator, no photo, or missing from storage; 401 | **raw dio, `ResponseType.bytes`** (R1) |
| C4 | `DELETE /api/v1/vehicle-operators/{id}/license-photo` | `VehicleOperators` **Update** | — | 204 | 404 no photo (avoided by the guard in data-model §4); 403 | generated `delete…LicensePhotoDelete` |
| C5 | `DELETE /api/v1/vehicle-operators/{id}` | `VehicleOperators` Delete | — | 204; the server also removes the photo file | existing | generated (unchanged) |

**Known OpenAPI gap**: C3 is documented as `200 application/json, schema {}`, but the server actually sends `image/png`. The fix is tracked upstream in R1a. When it ships:
1. regenerate the client;
2. check that the generated C3 method returns `Response<Uint8List>`;
3. replace the raw call.

**Codegen**: the generated client already contains C2–C4 and `hasLicensePhoto`. Regenerate once at the start as a drift check; no diff is expected beyond what's already committed.
