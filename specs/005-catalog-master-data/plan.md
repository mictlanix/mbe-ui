# Implementation Plan: Product Catalog Master-Data Integration

**Branch**: `005-catalog-master-data` | **Date**: 2026-07-05 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/005-catalog-master-data/spec.md`

## Summary

Extend the existing product catalog (002-product-catalog) to wire the `Product` domain entity to the five master-data reference types that mbe-api now exposes with FK expansion: Supplier, SAT Unit of Measurement, SAT Product/Service Key, Price List (read-only name display), and Labels (display + assignment). The API team resolved the two blockers filed during spec (issues #73 and #74): SAT catalog list endpoints now support `search` and return `description`; `ProductResponse` now embeds full FK objects server-side and includes a `labels` list; `ProductCreate`/`ProductUpdate` accept `supplier`, `key`, and `labels` fields. This means the implementation is purely additive on the client: update domain entity mappings, extend repository interfaces, add three new read-only repositories (Supplier, SAT, Label), add two new shared form-picker widgets, extend the form controller and filter controller, and update the three screens.

## Technical Context

**Language/Version**: Dart `^3.10.3`, Flutter stable — same as specs 001–004.

**Primary Dependencies**: `flutter_riverpod` + `riverpod_annotation`/`riverpod_generator`, `go_router`, `dio`, `freezed`/`freezed_annotation`, `built_value`/`built_collection` — all already present. **No new pub dependencies needed**: Flutter's built-in `Autocomplete<T>` widget covers the picker UX (research.md §2); no third-party search-picker package is required.

**Storage**: N/A — online-only, no local cache (constitution §VII). Picker search results are transient async state; label list is a single `FutureProvider` call per form open, not persisted.

**Testing**: `flutter_test` (unit + widget tests), `mocktail` for repository fakes (five repositories to mock: `ProductRepository`, `SupplierRepository`, `SatCatalogRepository`, `LabelRepository`, and the existing `AccessControlService`). Integration tests via `integration_test` against a local mbe-api instance (quickstart.md).

**Target Platform**: Web, Windows, macOS, Linux — Expanded (desktop/web) layout tier, same as specs 001–004.

**Project Type**: Single Flutter project, feature-first; this feature extends `lib/features/catalog/` only. Two new shared widgets go in `lib/core/widgets/`.

**Performance Goals**: Picker dropdown results appear within 1 second of typing a search term (SC-001); label chips render immediately on form open (loaded once via `FutureProvider`). No degradation to the products list page-load time (SC-005).

**Constraints**: `Autocomplete<T>` fires `optionsBuilder` on every text change — must debounce 300 ms to avoid per-keystroke API calls (research.md §2). Label multi-picker loads up to 100 labels at once; if a deployment has more, a future iteration can add server-side search to the picker's chip display. The existing `CatalogSearchBar` pattern (submit-on-Enter only) is intentionally NOT used for form pickers — pickers must show suggestions as the user types.

**Scale/Scope**: No new screens or routes. Modifies three existing screens (`products_list_screen.dart`, `product_detail_screen.dart`, `product_form_controller.dart`/its screen), three existing domain entities (`product.dart`, `product_list_item.dart`, `product_price.dart`), one existing repository interface+impl (`product_repository.dart`/`_impl.dart`), and two existing controllers (`product_form_controller.dart`, `products_list_controller.dart`). Adds six new domain entity files, three new repository pairs, and two new shared widgets.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|---|---|---|
| I. Feature-First Layered Architecture | ✅ PASS | All new code lives in `lib/features/catalog/{data,domain}` or `lib/core/widgets/`. New repositories have interfaces in `domain/` and impls in `data/`, as required. New shared picker widgets live in `core/widgets/`. No cross-layer imports violated: `presentation` → `domain` only. |
| II. Riverpod for State & DI | ✅ PASS | All new repos exposed as `Provider<T>`. Label list is a `FutureProvider` (async, cached per form open). Picker debounce state is widget-local `_timer` on the `CatalogEntityPicker<T>` `StatefulWidget` — not Riverpod state, which is correct since it's transient UI timing, not application state. Form state remains on the existing `ProductFormController` (`Notifier`). |
| III. Contract-Driven API Integration | ✅ PASS | All three new repositories use the generated `SuppliersApi`, `LabelsApi`, `SatCatalogsApi` wrapper methods. No raw `dio` calls needed — unlike 004, no codegen gaps exist for these read-only endpoints. The updated `ProductRepository.create`/`update` pass the new `supplier`/`key`/`labels` fields to the existing generated `ProductCreate`/`ProductUpdate` models. |
| IV. Deny-by-Default RBAC | ✅ PASS | Reuses `accessControlProvider.can(SystemObject.products, AccessRight.update)` for all new editable controls (pickers on form, label chip edits). Detail screen shows all resolved values (supplier name, SAT descriptions, labels) to any user with at least `Read` on Products. `CatalogEntityPicker` and `LabelMultiPicker` both accept an `enabled` parameter that is `false` for read-only users. |
| V. Material 3 White-Labeled Design System | ✅ PASS | `Autocomplete<T>` and `FilterChip` are standard Material 3 components. No new theming or hardcoded colors introduced. |
| VI. Desktop/Web-First, Compact-Ready Layout | ✅ PASS | `CatalogEntityPicker<T>` and `LabelMultiPicker` are implemented once in `core/widgets/` and reused across all three pickers — no per-field reimplementation. Label filter uses the existing `CatalogFilterBar` pattern. The products list already has pagination and search; the label filter chip is added alongside existing filter chips. |
| VII. Online-Only, Server-Rendered Documents | ✅ PASS | No local persistence of picker results or label list. Label `FutureProvider` result is Riverpod in-memory state, discarded on provider disposal (form navigation-away). |

No exceptions — all seven principles pass cleanly.

## Project Structure

### Documentation (this feature)

```text
specs/005-catalog-master-data/
├── plan.md                                        # This file
├── research.md                                    # Phase 0 output
├── data-model.md                                  # Phase 1 output
├── quickstart.md                                  # Phase 1 output
├── contracts/
│   ├── mbe-api-products-v2.md                     # Phase 1 output
│   └── mbe-api-master-data-pickers.md             # Phase 1 output
└── tasks.md                                       # Phase 2 output (/speckit-tasks)
```

### Source Code (repository root)

```text
lib/
├── core/
│   └── widgets/
│       ├── catalog_entity_picker.dart             # NEW: generic single-select search picker
│       └── label_multi_picker.dart                # NEW: multi-select label chip picker
└── features/
    └── catalog/
        ├── data/
        │   ├── product_repository_impl.dart        # MODIFIED: + supplier/key/labels on create/update,
        │   │                                       #            + label on list
        │   ├── supplier_repository_impl.dart        # NEW
        │   ├── sat_catalog_repository_impl.dart     # NEW
        │   └── label_repository_impl.dart           # NEW
        ├── domain/
        │   ├── entities/
        │   │   ├── product.dart                    # MODIFIED: expand supplier/unit/key/price-list/labels
        │   │   ├── product.freezed.dart            # REGENERATED
        │   │   ├── product_list_item.dart          # MODIFIED: unitOfMeasurement → code+name
        │   │   ├── product_list_item.freezed.dart  # REGENERATED
        │   │   ├── product_price.dart              # MODIFIED: priceList int → id+name
        │   │   ├── product_price.freezed.dart      # REGENERATED
        │   │   ├── product_label.dart              # NEW: domain entity (labelId, name)
        │   │   ├── sat_unit.dart                   # NEW: domain entity (code, name, desc, symbol)
        │   │   ├── sat_catalog_item.dart           # NEW: domain entity (code, description)
        │   │   ├── supplier_list_item.dart          # NEW: domain entity (supplierId, code, name)
        │   │   └── label_item.dart                 # NEW: domain entity (labelId, name)
        │   └── repositories/
        │       ├── product_repository.dart          # MODIFIED: + supplier/key/labels/label params
        │       ├── supplier_repository.dart          # NEW
        │       ├── sat_catalog_repository.dart       # NEW
        │       └── label_repository.dart             # NEW
        └── presentation/
            ├── products_list_controller.dart         # MODIFIED: + label: int? in ProductFilter
            ├── products_list_screen.dart              # MODIFIED: + label filter chip/dropdown
            ├── product_form_controller.dart           # MODIFIED: + supplier/key/label state fields
            │                                         #             + labelToggled(), supplierSelected(),
            │                                         #               unitSelected(), satKeySelected()
            ├── product_form_controller.freezed.dart  # REGENERATED
            ├── product_form_controller.g.dart        # REGENERATED
            └── product_detail_screen.dart             # MODIFIED: display expanded fields + labels

test/
├── unit/
│   └── features/catalog/
│       ├── supplier_repository_test.dart            # NEW
│       ├── sat_catalog_repository_test.dart         # NEW
│       ├── label_repository_test.dart               # NEW
│       └── product_form_controller_test.dart        # EXTENDED: picker selection + label toggle tests
└── widget/
    └── features/catalog/
        ├── catalog_entity_picker_test.dart           # NEW
        ├── label_multi_picker_test.dart              # NEW
        └── product_detail_screen_test.dart           # EXTENDED: label display, supplier name, price-list name
```

**Structure Decision**: Pure extension of `lib/features/catalog/` — no new feature folder or routes. All new pickers go in `core/widgets/` once, per constitution §VI. New domain entities are minimal `@freezed` classes with `fromResponse` factories, staying in `lib/features/catalog/domain/entities/` since the catalog module is the shared master-data kernel per the constitution.

## Complexity Tracking

> No constitution violations in this plan. Table intentionally omitted.
