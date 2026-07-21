# Implementation Plan: Facilities and their Facility-Scoped Operational Catalogs

**Branch**: `014-facility-scoped-catalogs` | **Date**: 2026-07-21 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/014-facility-scoped-catalogs/spec.md`

## Summary

Deliver full CRUD catalog UIs for four master-data entities mbe-api exposes with
complete Create/Read/Update/Delete endpoints and generated clients that mbe-ui
does not consume today: **Warehouses**, **Cash Drawers**, **Points of Sale**, and
their parent **Facilities**. Each entity gets a paginated list screen (shared
search box + a facility/status/warehouse filter drawer) and a create/view/edit
detail screen, modeled directly on the just-shipped spec-012/013 catalogs
(`vehicle_operators_list_screen.dart` / `vehicle_operator_detail_screen.dart` for
the FK-picker + FK-filter shape; `customers_list_screen.dart` for the status
facet).

All work lands **inside the existing `lib/features/catalog/` module** — the
constitution's designated shared master-data module (§I) — extended with one
sub-tree per entity, exactly as specs 012 and 013 did. The structure decision is
identical and not re-litigated here.

Planning decisions that shape the work:

1. **No codegen and no new third-party dependency.** All four generated API
   clients (`WarehousesApi`, `PointsOfSaleApi`, `CashDrawersApi`,
   `FacilitiesApi`) plus the supporting `AddressesApi` and `TaxpayerIssuersApi`
   already ship full methods under `lib/generated/openapi/`, regenerated
   2026-07-21 after mbe-api closed the last of the feature's upstream issues
   (research.md §1). This feature adds **no** RBAC codegen for the three
   operational catalogs — `warehouses(4)`, `pointsOfSale(9)`, `cashDrawers(10)`
   already exist in `system_object.dart`.
2. **One RBAC-mirror correction is required (FR-027).** mbe-api's `FACILITIES`
   object **reuses** the legacy stores slot (`= 29`), and `STORES` /
   `PRODUCTION_SITES` were removed upstream. The app's mirror still declares
   `stores(29)` and `productionSites(107)`; both are now wrong. `stores(29)` →
   `facilities(29)` is renamed and `productionSites(107)` removed
   (research.md §2). This is the only shared-kernel edit outside the three
   modified integration files.
3. **Warehouses and Cash Drawers are the same shape.** Both are
   `{facility: FK, code, name, comment?, status}` with a `facility`/`status`
   filter — a near-verbatim pair, differing only in names, routes, l10n keys,
   and RBAC object (research.md §3). Points of Sale adds a second FK
   (`warehouse`) as both a form field and a filter facet.
4. **Facility/warehouse pickers reuse the spec-012/013 `CatalogEntityPicker`.**
   The facility picker is the exact `CatalogEntityPicker<FacilityListItem>`
   construction the customer form's salesperson picker and the operator form's
   driver picker already use, backed by a new `facilityRepositoryProvider`. The
   FK **filter** facet reuses the vehicle-operators driver-filter pattern (an
   FK picker inside `CatalogFilterSheet`); the status facet reuses the
   product/customer `EntityStatusControls` pattern (research.md §4, §6).
5. **The Facility form is the one genuinely new shape**, carrying three
   sub-pickers and one accepted compromise:
   - a **SAT postal-code location picker** — reuse the existing SAT-catalog
     picker path (`SatCatalogsApi.listPostalCodes`), the same `CatalogEntityPicker`
     construction the product form's SAT pickers use (research.md §7);
   - an **address picker with inline create** — a `CatalogEntityPicker<AddressListItem>`
     over `AddressesApi`, plus an inline "new address" dialog posting to
     `AddressesApi.create`, gated on `addresses(11)` (research.md §8);
   - a **taxpayer autocomplete** — `CatalogEntityPicker<TaxpayerIssuerListItem>`
     over `TaxpayerIssuersApi.list`, gated on `taxpayers(24)`, storing the
     issuer RFC (research.md §9);
   - `type` (Store/Production Site) via a new `FacilityType` domain enum and
     `AddressType` likewise, following the hand-written `EntityStatus`/`Gender`
     pattern the generator forces (research.md §5).
6. **Point-of-sale facility↔warehouse coupling is a UI guard over a real
   backend invariant.** mbe-api#102 shipped server-side validation, so the
   warehouse picker being scoped to the selected facility (and forcing
   reselection on facility change) is a UX convenience, not the only defense;
   a server rejection is still surfaced (research.md §10).

Consequently this feature modifies `app_router.dart`, `nav_destinations.dart`,
`system_object.dart` (FR-027), and the two `.arb` files; adds two shared-kernel
domain enums (`FacilityType`, `AddressType`); and everything else is new files
under `lib/features/catalog/`.

## Technical Context

**Language/Version**: Dart `^3.10.3` (per `pubspec.yaml`), Flutter stable channel
matching that SDK constraint — same as specs 002/005/011/012/013.

**Primary Dependencies**: `flutter_riverpod` + `riverpod_annotation` /
`riverpod_generator`, `go_router`, `dio`, `freezed` / `freezed_annotation` +
`json_serializable`, `intl` (`es-MX`), `data_table_2`. **No new dependency is
introduced** — the address-inline-create dialog and all pickers use Flutter's
built-in `Autocomplete`/`showDialog` via the existing `CatalogEntityPicker` and
`core/widgets/`.

**Storage**: N/A — no local database/cache (constitution §VII). All list/form
state is in-memory only.

**Testing**: `flutter_test` for unit/widget, `mocktail` for repository fakes,
`integration_test` for the golden-path CRUD flows against a local mbe-api
(quickstart.md).

**Target Platform**: Web, Windows, macOS, Linux — Expanded (desktop/web) tier,
Compact tier inherited from spec 010's adaptive shell.

**Project Type**: Single Flutter project, feature-first — **extends** the
existing `lib/features/catalog/` module (see Structure Decision).

**Performance Goals**: Each list screen renders one paginated page
(`skip`/`limit`, default 20) per fetch. All FKs the list/detail screens display
arrive **pre-expanded** on the response — `WarehouseResponse.facility` as a
`FacilitySummary`, `PointSaleResponse.warehouse` as a `WarehouseSummary`,
`FacilityResponse.address` as a full `AddressResponse` (mbe-api#101) and
`.location` as a `SatCatalogResponse` — so there is **no N+1 per-row lookup** on
any screen (research.md §11). Pickers debounce search at 300 ms via the shared
`CatalogEntityPicker`.

**Constraints**: Deny-by-default RBAC on four distinct objects
(`warehouses`/`pointsOfSale`/`cashDrawers`/`facilities`) plus read-gating the
address-create path on `addresses(11)` and the taxpayer autocomplete on
`taxpayers(24)`. Client-side gating only, consistent with the posture
products/pricing/spec-012/013 already record. Free-text search is server-side on
every list endpoint (all shipped 2026-07-21; research.md §1). The facility's
`taxpayer` is an autocomplete over registered issuers storing the RFC; issuer
*creation* is out of scope (FR-034a).

**Scale/Scope**: 8 screens (4 list + 4 detail), ~4 list controllers + 4 form
controllers + 4 filter controllers (one per catalog; Warehouses/Cash Drawers/
Points of Sale carry a facility facet, Facilities is status-only) + 1
inline-address sub-controller, 6 new repositories (Warehouse, PointSale,
CashDrawer, Facility, Address, TaxpayerIssuer — interfaces + impls) + 4 `freezed`
detail entities (list rows reuse the detail entity; no separate list-item types)
+ 3 picker view models (Facility, Address, TaxpayerIssuer), 2 new shared-kernel
enums, 4 router branches + 8 sub-routes, 4 nav destinations, 1 RBAC-mirror
correction, ~110 new l10n keys.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|---|---|---|
| I. Feature-First Layered Architecture | ✅ PASS | Extends `lib/features/catalog/{data,domain,presentation}` with one sub-tree per entity; `presentation` imports only `domain`; `data` implements `domain` repository interfaces. The two new enums are shared-kernel (`core/domain/`), not per-feature. |
| II. Riverpod for State & DI | ✅ PASS | Each entity gets `Notifier`-based list + form controllers exposing `AsyncValue`; Warehouses/Cash Drawers/Points of Sale each add a filter `Notifier`; the Facility form adds an inline-address sub-controller. All six repositories exposed as providers for test overrides. |
| III. Contract-Driven API Integration | ✅ PASS | Consumes the already-generated `Warehouses`/`PointsOfSale`/`CashDrawers`/`Facilities`/`Addresses`/`TaxpayerIssuers` APIs; **no hand-written DTOs**; generated files not edited. Errors map to shared error types via `ErrorBanner`. Every former backend gap was filed as an mbe-api issue per §III (nine issues, #86–#93 and #100–#102) and **all shipped upstream and were regenerated** before this plan — zero open dependency (research.md §1). |
| IV. Deny-by-Default RBAC | ✅ PASS | Reuses `accessControlProvider.can(...)`. The three operational objects pre-exist; `facilities(29)` is corrected into the mirror (FR-027); the address-create path gates on `addresses(11)` and the taxpayer autocomplete on `taxpayers(24)`, both already present. Routes gated via `_routeGate`, nav via `navDestinationsProvider`'s filter, actions hidden (not disabled) without privilege. |
| V. Material 3 White-Labeled Design System | ✅ PASS | No new theming. Status via the existing `EntityStatusCell`/`EntityStatusControls`; dates n/a (no date fields in this feature). All new strings added to both `.arb` files; no manual formatting. |
| VI. Desktop/Web-First, Compact-Ready Layout | ✅ PASS | All four list screens reuse `DataTableView`, `CatalogPagination`, `CatalogFilterBar`/`CatalogSearchBar`, `CatalogFilterSheet`; single Edit row action via `catalog_action_icons`; row-click → read-only view; toolbar `FilledButton` Create; delete-in-form-body. Detail forms use `ResponsiveFormGrid`. All four ship a `CatalogFilterSheet` drawer (every entity has a real facet). The inline-address dialog is a Material 3 `Dialog` with a `ResponsiveFormGrid` body. `AppBar.actions` carries only the read-only→edit toggle. |
| VII. Online-Only, Server-Rendered Documents | ✅ PASS | No local persistence, no caching, no document generation. |

**On §VI and the filter drawers**: every one of the four catalogs exposes a real
backend facet (`facility` + `status`; Points of Sale adds `warehouse`; Facilities
has `status`), so all four ship the search box **and** a filter drawer — no
search-only screens in this feature, no deviation.

**On the inline-address dialog and §VI**: creating an address from within the
facility form is not a second catalog screen — it is a modal sub-form scoped to
completing the facility (FR-031). It reuses `ResponsiveFormGrid` and the shared
form-field wrappers, introduces no list/table, and is gated on `addresses(11)`.
This is consistent with §VI rather than an exception to it.

**Post-Phase 1 re-check**: ✅ still passing. Phase 1 introduced no new dependency,
no generated-file edits, no local persistence; the two new shared-kernel enums
follow the established `EntityStatus`/`Gender` precedent and the one RBAC-mirror
edit is a correctness fix mandated by the backend (FR-027).

## Project Structure

### Documentation (this feature)

```text
specs/014-facility-scoped-catalogs/
├── plan.md                       # This file
├── spec.md                       # Feature spec
├── research.md                   # Phase 0 output
├── data-model.md                 # Phase 1 output
├── quickstart.md                 # Phase 1 output
├── contracts/                    # Phase 1 output
│   ├── mbe-api-catalogs.md        # endpoint/DTO contract per entity + the (resolved) upstream deps
│   └── routes.md                  # routes, nav, RBAC gating, NavBranch invariant
├── checklists/
│   └── requirements.md           # spec quality checklist (already created)
└── tasks.md                      # Phase 2 output (/speckit-tasks — not created here)
```

### Source Code (repository root)

```text
lib/
├── app/
│   └── router/
│       └── app_router.dart              # MODIFIED: 4 shell branches + 8 sub-routes + _routeGate entries
├── core/
│   ├── navigation/
│   │   └── nav_destinations.dart        # MODIFIED: 4 NavDestinations + 4 NavBranch indices (order MUST match router)
│   ├── access/
│   │   └── system_object.dart           # MODIFIED (FR-027): stores(29)→facilities(29); remove productionSites(107)
│   └── domain/
│       ├── facility_type.dart           # NEW: Store(0)/ProductionSite(1) — hand-named, EntityStatus/Gender pattern
│       └── address_type.dart            # NEW: Other(0)/Home(1)/Work(2)/Business(3)/Fiscal(4)
├── l10n/
│   └── app_*.arb                        # MODIFIED: nav titles, column headers, field labels, validation, empty states
└── features/
    └── catalog/                         # EXTENDED (existing module)
        ├── data/
        │   ├── warehouse_repository_impl.dart        # NEW: wraps WarehousesApi
        │   ├── cash_drawer_repository_impl.dart      # NEW: wraps CashDrawersApi
        │   ├── point_sale_repository_impl.dart       # NEW: wraps PointsOfSaleApi
        │   ├── facility_repository_impl.dart         # NEW: wraps FacilitiesApi
        │   ├── address_repository_impl.dart          # NEW: wraps AddressesApi (list + create for inline)
        │   └── taxpayer_issuer_repository_impl.dart  # NEW: wraps TaxpayerIssuersApi (list only, for autocomplete)
        ├── domain/
        │   ├── entities/
        │   │   ├── warehouse.dart                    # list rows reuse the detail entity — no separate *_list_item (data-model.md)
        │   │   ├── cash_drawer.dart
        │   │   ├── point_sale.dart
        │   │   ├── facility.dart
        │   │   ├── facility_list_item.dart           # picker/filter view model consumed by the other 3 catalogs
        │   │   ├── address_list_item.dart            # picker view model (+ inline-create payload)
        │   │   └── taxpayer_issuer_list_item.dart    # picker view model
        │   └── repositories/
        │       ├── warehouse_repository.dart / cash_drawer_repository.dart
        │       ├── point_sale_repository.dart / facility_repository.dart
        │       ├── address_repository.dart / taxpayer_issuer_repository.dart
        └── presentation/
            ├── warehouses_list_screen.dart + warehouses_list_controller.dart (+ filter)
            ├── warehouse_detail_screen.dart + warehouse_form_controller.dart
            ├── cash_drawers_list_screen.dart + cash_drawers_list_controller.dart (+ filter)
            ├── cash_drawer_detail_screen.dart + cash_drawer_form_controller.dart
            ├── points_of_sale_list_screen.dart + points_of_sale_list_controller.dart (+ filter)
            ├── point_sale_detail_screen.dart + point_sale_form_controller.dart
            ├── facilities_list_screen.dart + facilities_list_controller.dart (+ filter)
            ├── facility_detail_screen.dart + facility_form_controller.dart
            └── address_inline_create.dart + address_inline_create_controller.dart  # modal sub-form (FR-031/032)

lib/generated/openapi/                   # REGENERATED 2026-07-21 (research.md §1); not hand-edited

test/
├── unit/features/catalog/               # mapping (FK-summary expansion, address/taxpayer resolve, FacilityType/AddressType round-trip), validators
├── widget/features/catalog/             # 8 screens + inline-address dialog: read-only vs editable, facility/warehouse/status filter drawers, empty states, RBAC hiding, address-create-gated-on-addresses(11)
└── integration/facility_catalogs_flow_test.dart # create facility (with inline address + taxpayer pick) → create warehouse under it → create point of sale picking that warehouse → create cash drawer
```

**Structure Decision**: **Extend the existing `lib/features/catalog/` module**,
identical to specs 012 and 013 and for the same reason: constitution §I
designates `catalog` as the shared master-data module, and Facilities/Warehouses/
Points of Sale/Cash Drawers are master-data catalogs of exactly that kind. The
feature modifies `app_router.dart`, `nav_destinations.dart`, `system_object.dart`
(FR-027) and the `.arb` files; adds two `core/domain/` enums; and reuses
`core/network`, `core/errors`, `core/access`, and every `core/widgets/` component
(including `CatalogEntityPicker`, `CatalogFilterSheet`, `EntityStatusControls`,
`ResponsiveFormGrid`) unmodified.

## Risks

| Risk | Impact | Mitigation |
|---|---|---|
| **`FacilityResponse.taxpayer` is not FK-expanded** — it returns the bare RFC, unlike `address`/`location`. | A facility's taxpayer shows as an RFC, not the issuer name, on list/detail unless resolved. | Spec FR-034b explicitly allows showing the RFC (it is human-meaningful) and forbids a per-row resolve. Detail screen MAY resolve the single issuer via `TaxpayerIssuersApi.get`; the list shows the RFC. No N+1 (research.md §9, §11). |
| **Inline address create is partial-failure-prone** — address POST succeeds, then facility save fails. | An orphaned address plus lost work. | The created address is kept and stays selected on the returned-to facility form (spec Edge Cases, FR-031); it is never rolled back client-side. Unit/widget-tested. |
| **RBAC-mirror correction (FR-027) touches a shared enum** other features read. | A wrong edit could mis-gate an unrelated screen. | `stores(29)` is consumed only by legacy report objects already keyed by their own constants; a repo-wide grep for `SystemObject.stores`/`productionSites` gates the edit (research.md §2). Any consumer found is reported, not silently rebound. |
| **NavBranch indices drift from router branch order** | Wrong nav item highlighted | Add the four branches in the same order in both `nav_destinations.dart` and `app_router.dart`; the invariant is documented at `nav_destinations.dart` and was honored by specs 012/013 (contracts/routes.md). |
| **Point-of-sale facility change strands the warehouse** | A saved record could pair mismatched FKs | The form forces warehouse reselection when the facility changes to one the current warehouse does not belong to (FR-022); the backend also rejects it (mbe-api#102), so a slipped-through mismatch is caught server-side and surfaced via `ErrorBanner`. |
| **Deletion-while-referenced rules** | A delete may be rejected server-side (a facility referenced by a warehouse, a warehouse by a point of sale) | UI surfaces any rejection via `ErrorBanner` and never pre-blocks the attempt (spec Edge Cases). |

## Follow-ups (not blocking)

- **External dependencies — all RESOLVED (verified 2026-07-21).** Nine mbe-api
  issues filed across this spec's life (#86–#93 search/facility gaps; #100–#102
  taxpayer issuers / address expansion / point-of-sale validation) all shipped
  upstream and were regenerated into the client. No open cross-repo dependency
  remains (spec Upstream Dependencies, research.md §1).
- **Deferred (explicitly out of scope)**: a **dedicated Taxpayer Issuers
  catalog** (and its `TaxpayerCertificatesApi` CSD certificates) — the full
  issuer API now exists and is gated on `taxpayers(24)`, but this feature only
  reads issuers for the facility autocomplete (FR-034a). A clean follow-up
  feature. Likewise a standalone **Addresses catalog** (addresses have full CRUD
  + `addresses(11)`), which this feature reaches only through the facility
  form's picker + inline-create.
- **Possible upstream nicety**: expanding `FacilityResponse.taxpayer` to the
  issuer object the way `address`/`location` already are, which would let the
  detail screen show the issuer name with zero extra requests and retire
  FR-034b's RFC-on-list allowance. Not filed (not needed by this feature).

## Complexity Tracking

*No constitution violations — this section is intentionally empty.* The notes
under Constitution Check (four filter drawers under §VI; the inline-address
modal under §VI) are scope clarifications with precedent from specs 012/013, not
deviations. The FR-027 RBAC-mirror correction and the two new hand-named enums
follow existing shared-kernel precedent (`EntityStatus`, `Gender`) and are
mandated by the generated contract, not optional complexity.
