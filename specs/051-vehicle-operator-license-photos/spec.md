# Feature Specification: Vehicle Operator License Photos

**Feature Branch**: `051-vehicle-operator-license-photos`

**Created**: 2026-10-23

**Status**: Draft

**Input**: User description: "Vehicle operator license photos (covers mictlanix/mbe-roadmap#21, legacy scope 01 §1.16). Let back-office users attach, view, replace, and remove a photo of a vehicle operator's driver license from the Vehicle Operator form. The photo is personal data: stored privately and served only to signed-in users, not at a public address like product photos. Limit 2 MB; the server scales any image to 1024 px wide and keeps it as PNG. The file is removed when the photo is replaced or cleared, and when the operator is deleted. Follow the product photo upload, replace, and remove flow on the product detail screen."

Roadmap: mictlanix/mbe-roadmap#21

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Attach a license photo to an operator (Priority: P1)

A back-office user with permission to edit vehicle operators opens an operator's form, picks an image of the driver's license from their device, sees a preview of it in the form, and saves. From then on the operator record has a license photo.

**Why this priority**: Without a way to attach a photo there is nothing to view, replace, or remove. This is the core of the legacy behavior being migrated.

**Independent Test**: Open an operator that has no photo, pick a valid image, save, then reopen the operator. The form shows the photo.

**Acceptance Scenarios**:

1. **Given** an existing operator with no license photo and a user who can edit operators, **When** the user picks a JPG or PNG image of 2 MB or less, **Then** the form shows a preview of the picked image and marks the form as having unsaved changes.
2. **Given** a picked image is staged, **When** the user saves, **Then** the photo is stored for that operator, and reopening the operator shows it.
3. **Given** a picked image is staged, **When** the user discards the changes or leaves the form without saving, **Then** no photo is stored.
4. **Given** the user is creating a new operator, **When** they pick an image and save, **Then** the operator is created and the photo is attached to it in the same save.

---

### User Story 2 - View an operator's license photo (Priority: P1)

A user who can view vehicle operators opens an operator that has a license photo and sees it in the form. They can open it larger to read the license details.

**Why this priority**: Checking a driver's license (number, type, expiration) against the stored record is the reason the photo is kept. It has equal priority with attaching, because a stored photo that can't be seen is useless.

**Independent Test**: Open an operator that already has a photo (one attached through Story 1, or one already on the server). The photo shows in the form and can be enlarged.

**Acceptance Scenarios**:

1. **Given** an operator with a license photo, **When** the user opens the operator's form, **Then** the form shows the photo as a thumbnail.
2. **Given** the thumbnail is shown, **When** the user activates it, **Then** the photo opens at a size large enough to read the license text.
3. **Given** an operator without a license photo, **When** the user opens the form, **Then** the form shows an empty placeholder rather than a broken image.
4. **Given** a user who can view operators but not edit them, **When** they open an operator with a photo, **Then** they see the photo but no upload, replace, or remove controls.

---

### User Story 3 - Replace or remove a license photo (Priority: P2)

When a driver renews their license, a user with edit permission replaces the stored photo with a new one. When a photo is wrong or no longer needed, the user removes it.

**Why this priority**: This keeps records correct over time. It is less frequent than attaching and viewing.

**Independent Test**: On an operator that has a photo, replace it with a different image and save, and check that the new image shows. Then remove it and save, and check that the placeholder shows.

**Acceptance Scenarios**:

1. **Given** an operator with a photo, **When** the user picks a new image and saves, **Then** the new photo replaces the old one.
2. **Given** an operator with a photo, **When** the user chooses to remove it, **Then** the form shows the placeholder and marks the form as having unsaved changes. The photo is not removed until the user saves.
3. **Given** the user removed the photo but has not saved, **When** they pick a new image, **Then** the new image is staged instead and the pending removal is cancelled.
4. **Given** the user removed the photo and saved, **When** they reopen the operator, **Then** there is no photo.

---

### Edge Cases

- **File too large**: The user picks an image larger than 2 MB. The form rejects it right away with a message giving the limit, and keeps the current or staged photo.
- **Unsupported file type**: The user picks a file that is not JPG or PNG. The form rejects it with a message listing the accepted types.
- **Server rejects the image**: The server can't decode the file, even though its name looked valid. The form shows a photo upload error, and the operator's other changes that were saved stay saved.
- **Photo fails to load**: The operator is marked as having a photo but the image can't be retrieved, for example because it is missing from storage, there is a network error, or the session expired. The form shows a "photo unavailable" state instead of a broken image, and the rest of the form stays usable.
- **Field save succeeds but photo upload fails**: The user changes fields and stages a photo. The fields save, but the upload fails. The user is told that only the photo failed and that the photo is still staged, so they can retry by saving again.
- **Remove with nothing to remove**: When there is no saved or staged photo, the remove control is not offered.
- **Operator deleted**: Deleting an operator deletes its photo too, on the server. The UI only needs its existing delete confirmation.
- **Picker cancelled**: The user opens the file picker and cancels. Nothing changes.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The Vehicle Operator form MUST show a license photo section in both create and edit mode.
- **FR-002**: When the operator has a stored license photo, the form MUST show it as a thumbnail. When it doesn't, the form MUST show an empty placeholder.
- **FR-003**: Users MUST be able to open the photo at a larger size to read it.
- **FR-004**: The photo MUST be retrieved only through the signed-in user's authenticated session. It MUST NOT be exposed or cached at a public or shareable address.
- **FR-005**: Users with permission to edit vehicle operators MUST be able to pick an image from their device to attach as the license photo, or to replace the current one.
- **FR-006**: The form MUST accept only JPG and PNG files of 2 MB or less, and MUST reject other files before saving, with a message stating why.
- **FR-007**: A picked image MUST be staged and previewed in the form, and MUST only be stored when the user saves the form, the same way field edits are saved.
- **FR-008**: Users with permission to edit vehicle operators MUST be able to mark the current photo for removal. The removal MUST take effect only when the user saves.
- **FR-009**: Picking a new image MUST cancel a pending removal, and marking for removal MUST discard a staged image.
- **FR-010**: Staging or removing a photo MUST count as an unsaved change, for the purposes of the form's save button state and its unsaved-changes guard.
- **FR-011**: Saving a new operator with a staged photo MUST create the operator and then attach the photo.
- **FR-012**: If the photo upload or removal fails after the operator's fields saved, the form MUST tell the user that only the photo step failed, and MUST keep the staged change so the user can retry.
- **FR-013**: Users without permission to edit vehicle operators MUST NOT see upload, replace, or remove controls. Users with view permission MUST still see the photo.
- **FR-014**: If a photo that the record says exists cannot be loaded, the form MUST show a "photo unavailable" state and stay usable.
- **FR-015**: All new user-facing text MUST be localized in Spanish and English.

### Key Entities

- **Vehicle Operator**: An existing catalog record (driver, license type, number, issue and expiration dates, issuing location, status). It gains a single "has license photo" flag. The photo's storage name is never exposed.
- **License Photo**: At most one image per operator. It is private personal data, stored by the server as a normalized PNG and readable only by signed-in users with view access to vehicle operators. Its lifetime is tied to the operator.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A user can attach a license photo to an existing operator in under 30 seconds: open the operator, pick the image, and save.
- **SC-002**: A user opening an operator that has a photo sees it in the form within 2 seconds on a normal office connection.
- **SC-003**: The photo can't be reached by a user who isn't signed in. Requesting it without a valid session fails every time.
- **SC-004**: 100% of invalid picks (wrong type, over 2 MB) are rejected before anything is sent, with a message that tells the user what to fix.
- **SC-005**: No save attempt leaves the user unsure whether the photo was stored. Every outcome (stored, removed, failed with the change kept) is shown in the form.

## Assumptions

- The server side is already done and deployed: upload, retrieve, and remove a license photo per operator, with a "has license photo" flag on the operator. Retrieving requires view access to vehicle operators; uploading and removing require edit access. Nothing new is needed from the backend.
- The interaction follows the product photo flow already in the app: stage, preview, apply on save, mark for removal, and the same client-side file-type and size checks. That keeps the two photo features consistent.
- The JPG/PNG restriction matches the product photo precedent, even though the server would accept any image format it can decode. Widening it is out of scope.
- Showing the photo in the operators list (as a thumbnail or a "has photo" indicator) is out of scope. The photo lives on the operator's form only.
- Capturing a photo directly with a device camera is out of scope beyond whatever the platform file picker already offers.
- Cropping, rotating, or editing the image in the app is out of scope. The server already normalizes size and format.
- The legacy business rules in the same scope section (alert when a license is within 30 days of expiring; block expired operators from delivery itineraries) are not part of this issue and stay out of scope.
