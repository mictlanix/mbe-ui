# Quickstart: Validating Product Photo Display & Upload

End-to-end validation steps for the acceptance scenarios in [spec.md](./spec.md). Run against a real mbe-api instance — this feature has no mocked/offline mode (constitution §VII). Builds on specs/002-product-catalog, which already shipped the `/products` list and detail screens this feature extends.

## Prerequisites

1. **mbe-api running locally**:
   ```bash
   cd ../mbe-api
   uv run uvicorn app.main:app --reload
   ```
   Confirms the photo endpoints exist at `http://127.0.0.1:8000/openapi.json` (contracts/mbe-api-products-photo.md): `POST /api/v1/products/{product_id}/image` and the existing `PUT /api/v1/products/{product_id}`.
2. **A signed-in mbe-ui session** for two account profiles (no new privilege is introduced — reuses `SystemObject.products`, research.md §1):
   - An account with `SystemObject.products` Update — to upload/replace/remove photos.
   - An account with `SystemObject.products` Read only (no Update) — to validate FR-009/SC-003.
3. **At least one existing product with no photo** and, separately, **one existing product with a photo already set** (upload one via this feature first if none exists) — to validate both the "add" and "replace/remove" paths independently.
4. **Two valid test image files** (one JPEG, one PNG, each under 2 MB) and **one oversized image** (over 2 MB) and **one non-image file** (e.g. a `.txt` renamed or a real `.pdf`) for validation testing (FR-006, FR-007).

## Setup (mbe-ui)

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

No codegen re-run is needed against mbe-api's OpenAPI spec — the photo endpoints already exist in the generated client today; this feature calls them via hand-rolled `dio` requests instead (research.md §3), so no `tool/generate_api_client.sh` step is required unless mbe-api's contract changes for an unrelated reason.

## Run

```bash
flutter run -d chrome      # or -d macos / -d windows / -d linux
```

## Validation scenarios

### Story 1 — View product photos while browsing (P1)

1. **Photo displays** (Acceptance Scenario 1, FR-001): sign in with either account, open `/products` and find the product that already has a photo. Expect: its photo renders in the list row and again on its detail screen.
2. **Placeholder for no photo** (Acceptance Scenario 2, FR-002, SC-004): find the product with no photo. Expect: a consistent placeholder renders in both the list and detail screen — no broken-image icon, no layout shift versus rows/screens that do have a photo.
3. **Broken photo fails over to placeholder** (Acceptance Scenario 3): temporarily stop mbe-api (or block the `/images` path) while a product with a photo is on screen and trigger a reload. Expect: the placeholder renders instead of a broken-image icon.

### Story 2 — Upload a photo for a product (P1)

1. **Valid upload** (Acceptance Scenario 1, FR-003, SC-001): sign in with the Update account, open the no-photo product, pick the valid JPEG (or PNG), save. Expect: within ~30s the photo appears on the detail screen and, after returning to `/products`, in the list row too.
2. **Unsupported file type** (Acceptance Scenario 2, FR-006, SC-002): attempt to pick the non-image file. Expect: rejected with a clear message; the product's photo (or lack thereof) is unchanged.
3. **Oversized file** (Acceptance Scenario 3, FR-007, SC-002): attempt to pick the oversized image. Expect: rejected with a message stating the 2 MB limit; unchanged otherwise.
4. **No edit privilege** (Acceptance Scenario 4, FR-008, SC-003): sign in with the Read-only account, open the no-photo product. Expect: no upload affordance is shown at all, even though the product has no photo.

### Story 3 — Replace or remove an existing product photo (P2)

1. **Replace** (Acceptance Scenario 1, FR-004): with the Update account, open the product that already has a photo, pick the *other* valid test image, save. Expect: the new photo replaces the old one everywhere the product is displayed.
2. **Remove** (Acceptance Scenario 2, FR-005, SC-005): on the same product, choose remove, save. Expect: the product reverts to the placeholder everywhere it's displayed on the very next view/refresh.
3. **Read-only cannot replace/remove** (Acceptance Scenario 3, FR-009): sign in with the Read-only account, open a product that has a photo. Expect: the photo is visible but no replace/remove affordance is shown.

### Edge cases to spot-check

- Pick a new photo in the edit form, then navigate away **without saving**. Reopen the product. Expect: the original photo (or lack thereof) is unchanged — the unsaved pick had no effect (spec.md Edge Cases, FR-010).
- Open the product that has no photo and confirm the remove action is absent/disabled (spec.md Edge Cases) — there is nothing to remove.
- Disconnect network mid-upload (or stop mbe-api) after picking a valid file and saving. Expect: an explicit upload-failure message; the product's previously stored photo is unchanged; retry succeeds once connectivity is restored.

## Out of scope reminders (do not test as failures)

- Multiple photos / photo galleries per product, photo history/versioning, and any server-side image-processing behavior beyond what mbe-api already does (resize/re-encode) are explicitly out of scope (spec.md Assumptions).
