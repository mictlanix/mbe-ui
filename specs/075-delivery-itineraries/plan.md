# Implementation Plan: Delivery Itineraries

**Branch**: `075-delivery-itineraries` | **Date**: 2026-11-18 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/075-delivery-itineraries/spec.md` (mictlanix/mbe-roadmap#41)

## Summary

This adds "Itinerarios", the fourth screen of the back office's Logística group.
- The list shows trips with their vehicle, operator, warehouse and status.
- On the trip screen, an Abierto trip gets stops (one per delivery order) and its lines are loaded, adjusted or released. Then it departs.
- On an En ruta trip, each stop is closed from the returned paperwork: the receiver, the delivered quantity and reason per line, and one proof (an uploaded image or a signature drawn on screen). The trip closes itself after its last stop.
- En ruta and Cerrado trips print the trip ticket and the delivery notes.

All 15 routes exist in the generated client (`DeliveryItinerariesApi`). No codegen is needed to start. mbe-api#343 (a stop's delivery order, and names on stops, lines and rows) shipped on 2026-11-18 (mbe-api#344), and the client was regenerated in a8290511. Names are mapped from the server, with no lookups (research R2–R3). Fifteen error codes and two resource nouns get Spanish and English messages (R13).

The code extends 063's `DeliveryItineraryRepository` in `lib/features/sales/` and follows 061's detail and actions pattern. It adds two `DocumentKind`s for printing, and one feature-local widget, `SignaturePad` (R9).

## Technical Context

**Language/Version**: Dart 3 / Flutter (the stable channel pinned by the repo)

**Primary Dependencies**: flutter_riverpod + riverpod_generator, go_router, freezed, dio, the generated `mbe_api_client` (built_value), decimal, intl / flutter_localizations, file_picker (already a dependency), printing (spec 044). No new package.

**Storage**: N/A (online-only, §VII).

**Testing**:
- `flutter test`: unit tests, and widget tests with mocktail fakes.
- `test/integration/delivery_itineraries_live_test.dart`, with writes gated by `MBE_WRITE=true`. It covers both proof kinds, per the §III multipart rule.
- `integration_test/delivery_itineraries_quickstart_test.dart` (run under `caffeinate -dimsu`).

**Target Platform**: Desktop (macOS) and web, Expanded tier first (§VI)

**Project Type**: Flutter client app (one project)

**Performance Goals**:
- One round trip for the list and one for the trip screen.
- Every write returns the full trip, with no extra GET.
- On an Abierto trip only: one cached order read per stop for open quantities, and one operator read for the licence expiry (R2, R4).

**Constraints**:
- Spanish text built from error codes (§III).
- One formatting surface (§V).
- Rights mirrored with `can(87, …)`, and an action is absent when not allowed (§IV).
- The filter drawer and pagination on the list (§VI).
- No AppBar actions (§VI).

**Scale/Scope**:
- 2 screens (list, trip) and 9 dialogs: new, header, add stop, load line, quantity, close stop, and the release / remove / cancel / depart prompts.
- 1 nav destination, 15 endpoints and 2 document kinds.
- 15 error codes and 2 resource nouns.
- About 90 new l10n keys.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Result | How |
|---|---|---|
| **I. Feature-first layers** | Pass | Inside `lib/features/sales/`, beside 061–063 (R1). `domain/` gets the itinerary entities and enums, and the extended repository interface. `data/` gets the implementation and the mapping. Presentation gets `delivery_itineraries/`. Cross-feature reads (catalog): `warehouseDisplayNameProvider`, `VehicleRepository`, `VehicleOperatorRepository`. The delivery-order repository is in the same feature. |
| **II. Riverpod** | Pass | List and trip are `AsyncNotifier` controllers. A `keepAlive` actions notifier returns `AppError?` and updates the detail, the list, and the 061/063 providers (R10). The repository and the lookups are providers. |
| **III. Contract-driven API** | Pass | Generated `DeliveryItinerariesApi` only, with no hand-written DTOs. `closeStop` uses the generated `MultipartFile` parameter, and the live test checks it before it's trusted (R12). Every reachable code gets a message ([contracts/error-messages.md](contracts/error-messages.md)): `code-scope.tsv` flips to `IN`, and the coverage count goes 191 → 206. The licence warning's uncoded English text is never shown; the app builds its own (R4). The needed backend change is filed as mbe-api#343, plus a comment for the two gaps. |
| **IV. Deny-by-default RBAC** | Pass | Route and nav: `can(87, read)`. Create: "Nuevo itinerario". Update: header, stops, loads, depart, cancel, close stop. Read: print. Pickers also need 71 read (orders) and vehicle/operator read. The order link needs 71 read. The action matrix is in [data-model.md](data-model.md). |
| **V. Material 3 / formatting** | Pass | Shared components only (see [contracts/ui-contract.md](contracts/ui-contract.md)). Quantities, dates, times and ids go through `formattersProvider`. The **largest text level** is checked in quickstart step 13. |
| **VI. List and record surface** | Pass (document reading, as 067–069) | **List**: filter row (no search, since the endpoint has none), table and pagination. **Surface**: a full screen with its own route, because a trip owns stops. **No row Edit icon and no View toggle.** **The AppBar has no actions.** Print and status actions are body buttons. |
| **VII. Online-only** | Pass | PDFs are server-rendered and shown through the spec 044 preview. There is no local storage. |

**Post-design re-check (after Phase 1)**: Pass. Nothing is added to `core/widgets/`. `SignaturePad` stays feature-local until a second caller needs it (R9). `DocumentKind` gains two values in `core/documents/`, the shared surface built for this. 061–063 code changes only in the 063 repository interface (extended) and the nav group comment.

## Project Structure

### Documentation (this feature)

```text
specs/075-delivery-itineraries/
├── plan.md              # This file
├── research.md          # Phase 0: R1–R15
├── data-model.md        # Phase 1: entities, enums, states, action availability
├── quickstart.md        # Phase 1: validation walkthrough
├── contracts/
│   ├── ui-contract.md       # routes, nav, screens, dialogs
│   ├── repository.md        # repository ↔ endpoints, lookups, actions, controllers
│   └── error-messages.md    # 15 codes + 2 resources, reused codes, enrichment
└── tasks.md             # Phase 2 (/speckit-tasks)
```

### Source Code (repository root)

```text
lib/features/sales/
├── domain/
│   ├── entities/delivery_itinerary.dart                 # NEW: ItineraryStatus, StopOutcome, ShortfallReason,
│   │                                                    #      ItinerarySummary, ItineraryPage, Itinerary, ItineraryStop,
│   │                                                    #      ItineraryLine, StopClosure, StopClosureLine, ProofImage
│   └── repositories/delivery_itinerary_repository.dart  # EXTENDED (063): list, getById, create, … closeStop
├── data/
│   └── delivery_itinerary_repository_impl.dart          # EXTENDED: mapping (exhaustive enums), closeStop multipart
└── presentation/
    └── delivery_itineraries/                            # NEW
        ├── delivery_itineraries_list_screen.dart        # deliveryItinerariesPath = '/sales/delivery-itineraries'
        ├── delivery_itineraries_list_controller.dart
        ├── delivery_itineraries_filter.dart             # status, dateFrom/To, vehicleId, operatorId, warehouseId
        ├── itinerary_status_chip.dart                   # + stop outcome chip
        ├── delivery_itinerary_detail_screen.dart
        ├── delivery_itinerary_detail_controller.dart
        ├── delivery_itinerary_actions.dart
        ├── itinerary_lookups.dart                       # itineraryOrder (open qty), operator licence expiry (R2, R4)
        ├── itinerary_stop_card.dart
        ├── new_itinerary_dialog.dart
        ├── itinerary_header_dialog.dart
        ├── add_stop_dialog.dart
        ├── load_line_dialog.dart
        ├── close_stop_dialog.dart
        ├── signature_pad.dart
        ├── itinerary_dialogs.dart                       # quantity, release, remove stop, cancel, depart prompts
        └── itinerary_print.dart                         # canPrintItinerary + the two openers

lib/core/documents/domain/document_kind.dart             # + itineraryTicket, itineraryDeliveryNotes
lib/core/documents/data/document_source_impl.dart        # + the two routes
lib/app/router/app_router.dart                           # branch 36 + detail route + _routeGate clause
lib/core/navigation/nav_destinations.dart                # NavBranch.deliveryItineraries = 36; 4th child of 'logistics'
lib/core/errors/localize_problem.dart                    # 15 codes + 2 resource nouns
lib/l10n/app_es.arb, app_en.arb                          # deliveryItinerar… keys, navDeliveryItineraries, apiError… keys
specs/058-localized-api-errors/contracts/code-scope.tsv   # 15 code rows OUT → IN; resource rows added

test/unit/core/errors/problem_fixtures.dart, catalog_coverage_test.dart   # fixtures; 191 → 206; needParams
test/unit/core/documents/                               # the two kinds' routes and fallback names
test/unit/features/sales/                               # itinerary fixtures, repository impl (mapping, closeStop body),
                                                        # filter, list/detail controllers, actions, lookups
test/widget/features/sales/                             # list, trip screen per status × rights, stop card, dialogs
                                                        # (close-stop validation), signature pad, large text
test/unit/core/navigation/nav_destinations_test.dart, test/unit/app/router/app_router_test.dart
test/integration/delivery_itineraries_live_test.dart
integration_test/delivery_itineraries_quickstart_test.dart
```

**Structure Decision**: Itineraries live in `lib/features/sales/` with delivery orders and the pending queue, under `/sales/delivery-itineraries` (route-mirrors-folders, as 061–063). The nav entry sits in Logística. The status chip, filter and lookups are local to `presentation/delivery_itineraries/`.

## Implementation order

1. **Errors**: the 15 codes and 2 resource nouns, their arb text, fixtures, `code-scope.tsv`, and the coverage count. **Check:** `catalog_coverage_test` passes at 206.
2. **Domain and data**: entities, enum mapping, the repository's new methods, and `closeStop`'s multipart body. Unit tests cover the mapping, the `lines` JSON and the errors.
3. **List and creation** (US4, and US1's create): filter, chip, controller, screen, nav, route, and the new-trip dialog. **Check:** the nav and router tests pass with branch 36.
4. **Trip screen and header**: detail controller, actions, header band and dialog, licence warning (R4), cancel. Widget tests cover rights × status.
5. **Departure and printing** (US2, US5): the depart guard and prompt, the two `DocumentKind`s, and print buttons.
6. **Stops** (US1 loading, US3 closing): the order lookup, the add-stop dialog, the stop card, the load and quantity dialogs, `SignaturePad`, and the close-stop dialog.
7. **Live and device**: `delivery_itineraries_live_test.dart` (both proof kinds, the shortfall child order, auto-close, the refusals) and the quickstart device test.

## External dependencies

- **mictlanix/mbe-api#343**: shipped 2026-11-18 in mbe-api#344. Migration 036 was applied to mbe_dev on 2026-11-18. The two gaps in the 2026-11-18 comment (the vehicle check on update, departure with empty stops) are not fixed upstream. The departure guard stays (R7), and the vehicle check on update stays a known gap.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| §VI row rules read as catalog-only (same reading as 067–069): list rows have no Edit icon and no View toggle, and loaded-line rows carry ✎ and 🗑. | A trip is a document with a status lifecycle, editable only while Abierto and edited in place on its screen. | Catalog row icons would lead from departed, closed and cancelled trips, most of the list, to a form with nothing to change. |
