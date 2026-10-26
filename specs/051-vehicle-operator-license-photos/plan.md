# Implementation Plan: Vehicle Operator License Photos

**Branch**: `051-vehicle-operator-license-photos` | **Date**: 2026-10-23 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/051-vehicle-operator-license-photos/spec.md`

**Roadmap**: Closes mictlanix/mbe-roadmap#21

## Summary

This feature adds a license photo section to the existing Vehicle Operator form. Users can attach, view, enlarge, replace, and remove a photo of the driver's license.

It follows the product photo flow:
- the user picks a file;
- the file is checked on the client (JPG/PNG, 2 MB or less);
- it is staged and previewed;
- it is uploaded or removed when the form is saved.

It differs from that flow in four places:

1. **Private fetch (R1).** The photo is read as bytes through the generated GET on the shared authenticated dio. It is never loaded from a URL. The first build used a raw-bytes GET because mbe-api documented the route as JSON; that was fixed upstream (R1a, mictlanix/mbe-api#257) and the bypass removed in T023.
2. **No persistence (R3).** The bytes are held in an auto-disposing provider and are never stored anywhere.
3. **Panel stays open on photo failure (R4).** If the photo step fails after the fields have saved, the panel stays open with the change still staged. A retry after a create runs an update, so no duplicate operator is created.
4. **Photo controls need update access (R5).** This holds in create mode too, because mbe-api guards upload and delete with Update.

## Technical Context

**Language/Version**: Dart `^3.10.3`, Flutter 3.47.7 stable (unchanged)

**Primary Dependencies**:
- Riverpod 3 (riverpod_generator), freezed 4, the generated `mbe_api_client`, and `file_picker` (already used by product photos).
- No new packages.
- The client already contains the license-photo endpoints and `hasLicensePhoto`. Regenerating is a drift check with no diff expected.

**Storage**: N/A. The app is online-only (§VII), and photo bytes live only in memory, in an auto-dispose provider.

**Testing**: `flutter_test` + `mocktail` with `ProviderScope` overrides, following the existing `vehicle_operator_*_test.dart` files. The multipart wrapper gets one live check (quickstart Q4), as §III requires.

**Target Platform**: Web and desktop first; compact layouts stack the photo actions under the thumbnail.

**Project Type**: Flutter client application, feature-first layered

**Performance Goals**:
- Opening an operator without a photo makes no extra request.
- Opening one with a photo makes one extra GET of about 1 MB or less (1024 px PNG), loaded separately from the form, so the fields render first (SC-002).

**Constraints**:
- The photo must never be reachable by URL or written to disk (FR-004, §VII).
- Actions the user lacks rights for are hidden, never disabled (§IV).
- The l10n files are regenerated, not hand-edited. Generated client files are not hand-edited.
- The product photo behavior must not change. The only change to that code is the additive preview generalization in R7.

**Scale/Scope**:

| | Files |
|---|---|
| **New (1 source file, plus generated code)** | `presentation/license_photo_provider.dart` |
| **Edited (6 source files)** | `domain/entities/vehicle_operator.dart`, `domain/repositories/vehicle_operator_repository.dart`, `data/vehicle_operator_repository_impl.dart`, `presentation/vehicle_operator_form_controller.dart`, `presentation/vehicle_operator_form.dart`, `core/widgets/product_photo_preview.dart` |
| **Edited, l10n** | both `.arb` files (about 5 keys), plus the regenerated localizations |
| **Tests** | the three existing operator test files extended; one new live test, `test/integration/vehicle_operator_license_photo_live_test.dart`; `product_photo_preview` tests re-run unchanged |

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Assessment | Status |
|---|---|---|
| **I. Feature-first layering** | The domain entity gets one field. The repository interface sits in domain and its implementation in data; the provider and widgets sit in presentation. The generated DTO is mapped in `VehicleOperator.fromResponse`. | ✅ |
| **II. Riverpod** | `licensePhotoProvider` uses `@riverpod` codegen with auto-dispose. The controller stays a codegen Notifier. | ✅ |
| **III. Contract-driven API** | Upload and delete use the generated wrappers, with the multipart live check in Q4. **GET bypasses the generated wrapper** because the published spec mis-declares the media type. The call still goes through the shared dio and interceptor, and errors still map to `AppError`. An upstream issue is drafted (R1a) rather than patching mbe-api. | ⚠️ justified, see Complexity Tracking |
| **IV. Deny-by-default RBAC** | Controls are gated on `can(vehicleOperators, Update)`, and the section is hidden for create-only users (R5). Viewing rides the existing Read gate. SystemObject 89 is already documented on the screen. | ✅ |
| **V. Material 3, white-label** | Token spacing is used, along with the theme `surfaceContainerHighest` placeholder and Material icons. No brand assets are involved. | ✅ |
| **VI. Desktop-first, compact-ready; shared components in core** | The section reflows on compact widths, as products do. The preview dialog is reused from `core/widgets/` through an additive generalization (R7) instead of a copy. The thumbnail section stays feature-local because it has one consumer. No record-surface change: the photo is one field, not a child section. | ✅ |
| **VII. Online-only** | No cache layer. Bytes are dropped with the form (R3). | ✅ |

**Post-design re-check (after Phase 1)**: unchanged. The data model adds no persistence, the contracts add no endpoints, and the only deviation remains the GET bypass recorded below.

## Project Structure

### Documentation (this feature)

```text
specs/051-vehicle-operator-license-photos/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── consumed-endpoints.md
│   └── ui.md
├── checklists/requirements.md
└── tasks.md             # /speckit-tasks
```

### Source Code (repository root)

```text
lib/
├── core/widgets/
│   └── product_photo_preview.dart          # + showPhotoPreview(ImageProvider) (R7)
├── features/catalog/
│   ├── domain/
│   │   ├── entities/vehicle_operator.dart  # + hasLicensePhoto
│   │   └── repositories/vehicle_operator_repository.dart  # + get/upload/removeLicensePhoto
│   ├── data/vehicle_operator_repository_impl.dart          # generated GET (R1), POST/DELETE (R2)
│   └── presentation/
│       ├── license_photo_provider.dart     # NEW: auto-dispose family (R3)
│       ├── vehicle_operator_form_controller.dart  # staging + save sequence (R4)
│       └── vehicle_operator_form.dart      # _LicensePhotoSection, picker, Save dispatch (R4, R5, R8)
└── l10n/app_{en,es}.arb                    # + licensePhoto* keys (R9)

test/
├── unit/features/catalog/
│   ├── vehicle_operator_form_controller_test.dart   # extended
│   └── vehicle_operator_repository_impl_test.dart   # extended
└── widget/features/catalog/
    └── vehicle_operator_form_test.dart              # extended
```

**Structure Decision**: all work sits inside the existing catalog feature module and its current vehicle-operator files. The only `core/` touch is the additive preview overload.

## External Dependencies

| Dependency | State | Blocking? |
|---|---|---|
| mbe-api license-photo endpoints (`6a8ce82`, Read/Update guards at `HEAD`) | shipped | — |
| mbe-api: declare `image/png` on the GET (R1a) | shipped: mictlanix/mbe-api#257 (part 2), 2026-10-25 | No. Client regenerated and the call swapped (T023). |
| mbe-api: create/update write `updater = 0` and always fail with 409 | shipped: mictlanix/mbe-api#257 (part 1), 2026-10-25 | No longer. |

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|---|---|---|
| *(Resolved in T023 after mictlanix/mbe-api#257.)* §III: `getLicensePhoto` used a raw `dio.get(..., responseType: bytes)` instead of the generated method | mbe-api's OpenAPI declares the GET as `application/json`. The generated method requests JSON and wraps the PNG as a `JsonObject`, so the bytes can't be recovered. | Hand-editing the generated client is forbidden and would be overwritten. Patching mbe-api from here is forbidden. Waiting on the upstream fix blocks a weight-1 issue. The bypass still uses the shared dio, interceptor and `AppError` mapping, and is removed when R1a ships. |
