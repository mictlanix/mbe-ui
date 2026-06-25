# Feature Specification: Product Photo Display & Upload

**Feature Branch**: `004-product-image-upload`

**Created**: 2026-06-23

**Status**: Draft

**Input**: User description: "Add product photo/image display and upload: admin/staff with edit privilege on the Products system object can upload, replace, and remove a product's photo from the product detail/edit screen; the product list and detail views display the product's photo (or a placeholder when none is set). This was explicitly deferred from the 002-product-catalog spec (see its Assumptions section) and should now be implemented as its own feature, following the same RBAC gating (Products system object, deny-by-default) and validation rigor established in 002-product-catalog."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - View product photos while browsing (Priority: P1)

A staff member browsing or searching the product catalog sees each product's photo in the list and on its detail screen, so they can visually confirm they have the right item, with a clear placeholder shown for products that have no photo yet.

**Why this priority**: Display is the read-only half of this feature and benefits every user immediately, including those without edit privilege; it is also the foundation users need before upload is useful (they need to see what's already there or missing).

**Independent Test**: Can be fully tested by signing in as a read-only user, opening the catalog list and a product's detail screen, and confirming a photo (or a placeholder) renders in both places without requiring any upload capability.

**Acceptance Scenarios**:

1. **Given** a product with a photo set, **When** a user views the catalog list or the product's detail screen, **Then** that product's photo is displayed.
2. **Given** a product with no photo set, **When** a user views the catalog list or the product's detail screen, **Then** a consistent placeholder image is displayed instead.
3. **Given** a product photo fails to load (e.g., broken/unreachable file), **When** the list or detail screen renders, **Then** the placeholder is shown in its place rather than a broken-image icon or layout break.

---

### User Story 2 - Upload a photo for a product (Priority: P1)

A user with edit privilege on the Products system object adds a photo to a product that doesn't have one yet, from the product detail/edit screen, so the catalog becomes visually identifiable.

**Why this priority**: Without upload, display alone has nothing new to show beyond placeholders; upload is the core write capability this feature exists to deliver and is needed for the MVP alongside display.

**Independent Test**: Can be fully tested by signing in as a user with edit privilege, opening a product without a photo, uploading a valid image file, saving, and confirming the photo now appears on that product's detail screen and in the list.

**Acceptance Scenarios**:

1. **Given** a user with edit privilege viewing a product with no photo, **When** they select a valid image file and save, **Then** the photo is stored and immediately displayed on the product's detail screen and in the catalog list.
2. **Given** a user attempts to upload a file that is not a supported image type, **When** they try to save, **Then** the system rejects the file with a clear message and no photo is changed.
3. **Given** a user attempts to upload an image file larger than the maximum allowed size, **When** they try to save, **Then** the system rejects the file with a clear message stating the size limit.
4. **Given** a user without edit privilege views a product, **When** they view the detail screen, **Then** no upload/replace/remove action is available to them, even if the product has no photo.

---

### User Story 3 - Replace or remove an existing product photo (Priority: P2)

A user with edit privilege updates a product's existing photo with a new one, or removes it entirely (reverting to the placeholder), to correct an outdated or incorrect image.

**Why this priority**: Necessary for keeping the catalog accurate over time, but secondary to first getting display and initial upload working — most products will only need an initial photo at launch.

**Independent Test**: Can be fully tested by opening a product that already has a photo, replacing it with a different valid image, confirming the new photo displays everywhere the product appears, then removing it and confirming the placeholder returns.

**Acceptance Scenarios**:

1. **Given** a product with an existing photo, **When** a user with edit privilege uploads a new valid image and saves, **Then** the previous photo is replaced and the new photo displays wherever the product appears.
2. **Given** a product with an existing photo, **When** a user with edit privilege chooses to remove the photo and saves, **Then** the product reverts to displaying the standard placeholder everywhere it appears.
3. **Given** a user without edit privilege opens a product with an existing photo, **When** they view the detail screen, **Then** the photo is displayed but no replace/remove action is available.

---

### Edge Cases

- What happens when a user selects an image file but never saves the form (navigates away)? The product's stored photo must remain unchanged — uploads only take effect on save, consistent with how other product fields behave in 002-product-catalog.
- How does the system handle two users editing the same product's photo concurrently? The same conflict-handling behavior used for other product fields applies (last successful save wins); this feature does not introduce new concurrency rules.
- What happens if a user attempts to remove a photo from a product that already has none? The remove action should be unavailable/disabled in that state, not an error.
- How does the system handle an upload that is interrupted (e.g., network failure) partway through? The product's previously stored photo must remain unchanged; the user sees an explicit upload-failure message and may retry.
- How does the list view handle rendering many product photos at once without degrading scroll/load performance? Photos must load incrementally/lazily alongside the existing paginated list rather than blocking the list from rendering.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST display each product's photo on the catalog list view and on the product detail screen.
- **FR-002**: System MUST display a consistent placeholder image, in place of a photo, for any product that has no photo set or whose photo fails to load.
- **FR-003**: System MUST allow a user with edit privilege on the `Products` system object to upload a new photo for a product that has none, from the product detail/edit screen.
- **FR-004**: System MUST allow a user with edit privilege to replace an existing product photo with a new one.
- **FR-005**: System MUST allow a user with edit privilege to remove an existing product photo, reverting the product to the placeholder state.
- **FR-006**: System MUST validate that an uploaded file is a supported image type (JPEG or PNG) and reject unsupported types with a clear, actionable message.
- **FR-007**: System MUST validate that an uploaded image does not exceed the maximum allowed file size (2 MB, matching the backend's enforced limit) and reject oversized files with a clear, actionable message stating the limit.
- **FR-008**: System MUST gate upload, replace, and remove actions behind the existing RBAC system using the `Products` system object's edit privilege, deny-by-default — users without that privilege cannot perform these actions and the corresponding UI affordances MUST NOT be shown.
- **FR-009**: System MUST allow a user with read-only privilege on `Products` to view product photos without exposing upload/replace/remove actions.
- **FR-010**: System MUST apply photo changes (upload, replace, remove) only when the containing product form is saved, consistent with how other editable product fields behave; an unsaved selection MUST NOT alter the stored photo.
- **FR-011**: System MUST reflect a successfully saved photo change everywhere the product is displayed (list and detail) without requiring a manual page refresh beyond the existing save/refresh flow.

### Key Entities

- **Product Photo**: A single image associated with a Product, used for visual identification in list and detail views. A product has at most one photo at a time; absence of a photo is a valid, expected state represented by a placeholder. Replacing a photo discards the previous one (no photo history/versioning).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A user with edit privilege can upload a valid photo for a product and see it reflected in both the list and detail views in under 30 seconds from selecting the file.
- **SC-002**: 100% of attempts to upload an unsupported file type or an oversized file are rejected with a clear, actionable message — none silently succeed or fail.
- **SC-003**: 0% of users lacking edit privilege on `Products` can successfully upload, replace, or remove a product photo, whether through the UI or by directly invoking the underlying action.
- **SC-004**: 100% of products without a photo display the standard placeholder consistently across list and detail views, with no broken-image states.
- **SC-005**: Replacing or removing a product's photo is reflected everywhere that product is displayed on the very next view refresh, with no stale photo shown.

## Assumptions

- This feature scopes a single photo per product (no photo galleries or multiple images per product); the legacy data model's photo/image field is treated as a single-value field, consistent with how 002-product-catalog deferred this exact capability.
- Supported image formats are JPEG and PNG, and the maximum upload size is 2 MB; this matches the backend API's actual enforced limit (confirmed during planning) rather than being an arbitrary client-side choice.
- Photo storage, retrieval, and any server-side image processing (resizing, thumbnailing, format conversion) are backend/API concerns; this spec describes client-facing upload, display, replace, and remove behavior and assumes the API contract supports storing and serving a single photo per product.
- RBAC gating reuses the existing `Products` system object and its edit privilege introduced in 002-product-catalog and the auth feature; no new system object or privilege is introduced for photos specifically.
- Photo changes follow the same save-on-submit pattern as other product fields (per FR-010); there is no separate "save photo immediately" action independent of the product form's save.
- FR-001's list-view photo display depends on mbe-api's list endpoint returning a photo URL per row. This was initially a gap discovered during implementation — mbe-api's `ProductListItem` schema didn't include `photo` — and was tracked as [mictlanix/mbe-api#71](https://github.com/mictlanix/mbe-api/issues/71). That issue has since been resolved (mbe-api now resolves `photo` to a full URL on the list endpoint the same way the detail endpoint always has); the catalog list and detail screen both show real photos per FR-001 as originally specified.
- No photo history/versioning is required — replacing or removing a photo permanently discards the prior image, consistent with the legacy system's behavior for this field.
- Legacy products whose photo lives on the old `mbe` app's web server (resolved via a separately-configurable `legacyPhotosBaseUrl`, research.md §6) display correctly on desktop and mobile builds, but not on the Flutter Web build unless that server sends CORS headers — accepted as a known, web-only limitation outside mbe-ui's/mbe-api's control rather than worked around (research.md §6).
