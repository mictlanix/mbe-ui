# Implementation Plan: Delivery Order Approval

**Branch**: `062-delivery-order-approval` | **Date**: 2026-11-15 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/062-delivery-order-approval/spec.md`

Roadmap: Closes mictlanix/mbe-roadmap#39.

**Upstream.** Nothing blocks this feature. Every endpoint is already in the generated client. mbe-api#314, the facility check on reads and writes by id, is closed (research R12). The approval-required switch is a server env var that defaults to off. The UI doesn't need it to build or unit-test, but the live walkthrough does (quickstart prerequisites).

## Summary

The back office gets "Aprobación de entregas" in the Logística group: the delivery orders waiting for approval at the user's facility. A supervisor approves an order (a delivery moves to En preparación, a pickup to Aprobada) or rejects it with a reason, which sends it back to Borrador. They can act from the queue row or from the spec 061 detail screen, which gains the same two actions.

**Technical approach.**
- **Data.** Three methods on the existing `DeliveryOrderAdminRepository`, over the generated approval endpoints. No new entities (R1, R2).
- **Queue.** A paged `AsyncNotifier` on `fetchClampedPage`, a table with no filter row, and the no-facility branch from spec 061 (R3).
- **Row tap.** It pushes the spec 061 detail screen when the user has Delivery Orders read, and does nothing otherwise (R4).
- **Writes.** `approve` and `reject` on the existing `DeliveryOrderActions`, which now also invalidates the queue for every delivery-order write (R6).
- **Dialogs.** Shared by the queue and the detail screen. Each keeps a refusal inside the dialog and returns the server's new status (R5).
- **Detail screen.** Rechazar and Aprobar join the action area. The 71-update gate becomes per button (R7).
- **Errors.** One new localized code, `delivery_order.not_pending_approval` (R9).

## Technical Context

**Language/Version**: Dart `^3.10.3`, Flutter stable (unchanged)

**Primary Dependencies**:
- Riverpod 3 (riverpod_generator), `go_router`, `data_table_2`, and the generated `mbe_api_client`.
- No new packages, and no client regeneration.

**Storage**: N/A (online-only, §VII)

**Testing**:
- `flutter_test` + `mocktail` with `ProviderScope` overrides.
- Templates from spec 060: `verification_queue_controller_test.dart`, `payment_verification_screen_test.dart`, `payment_verification_quickstart_test.dart`.
- Templates from spec 061: `delivery_order_actions_test.dart`, `delivery_order_detail_screen_test.dart`, `delivery_order_dialogs_test.dart`, `delivery_order_admin_repository_impl_test.dart`.

**Target Platform**: web and desktop first, with a compact tier required (§VI)

**Project Type**: Flutter client application, feature-first layered

**Performance Goals**:

| Action | Requests |
|---|---|
| Queue page | 1, plus the cached per-customer and per-address name lookups |
| Approve or reject | 1 write, then a refetch of the queue page, plus the order and events if the detail screen is open |

**Constraints**:
- Spacing comes from tokens.
- Every string goes in both `.arb` files.
- Status names come from l10n.
- Dates go through `formattersProvider`.
- Format only the changed files.

**Scale/Scope**:

| | Files |
|---|---|
| **New source (4)** | `presentation/delivery_order_approval/{delivery_order_approval_screen, delivery_order_approval_queue_controller, approval_dialogs, approval_target}.dart`, plus the generated part |
| **New tests (4)** | unit: `delivery_order_approval_queue_controller_test`; widget: `delivery_order_approval_screen_test`, `approval_dialogs_test`; live: `integration_test/delivery_order_approval_quickstart_test.dart` |
| **Edited source (≈9)** | `domain/repositories/delivery_order_admin_repository.dart`, `data/delivery_order_admin_repository_impl.dart`, `presentation/delivery_orders/delivery_order_actions.dart`, `presentation/delivery_orders/delivery_order_detail_screen.dart`, `core/navigation/nav_destinations.dart`, `app/router/app_router.dart`, `core/errors/localize_problem.dart`, both `.arb` files, `specs/058-localized-api-errors/contracts/code-scope.tsv` |
| **Edited tests (≈6)** | `delivery_order_admin_repository_impl_test`, `delivery_order_actions_test`, `delivery_order_detail_screen_test`, `problem_fixtures` (`catalog_coverage_test` reads the TSV and isn't edited), `nav_destinations_test`, `app_router_test` |

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

These verdicts are against **v1.15.0**.

| Principle | Verdict | How |
|---|---|---|
| **I. Feature-first layering** | Pass | Everything is in `features/sales/{domain,data,presentation}`. The queue gets its own presentation folder beside `delivery_orders/` because it is a separate screen with a separate right. Presentation reaches data only through the repository provider. |
| **II. Riverpod** | Pass | The queue is an `AsyncNotifier` family keyed by page. Writes go through the existing keep-alive `DeliveryOrderActions`, and the page index is URL state. |
| **III. Contract-driven API** | Pass | Only generated operations are used. **API error text:** the two new writes can return `delivery_order.not_pending_approval` (new: both locales, catalog set, TSV row to `IN`), `delivery_order.reason_required` and `state.transition_invalid` (both already `IN`; their endpoint lists gain the approval endpoints), and the generic `resource.not_found`, `auth.forbidden` and `auth.not_authenticated`. R9 lists them, as the gate requires. **Upstream:** no gap. #314 is closed. |
| **IV. Deny-by-default RBAC** | Pass | The nav entry and route gate are on DeliveryOrderApproval (94) read. The row icons and the detail buttons need 94 update and are absent without it. Row tap needs DeliveryOrders (71) read, because it opens a 71-gated route. The route and nav entry document 94 in code. **Facility scoping** is server-side on the queue (R1). Writes are facility-checked by the server through #314 (R12). The client adds no facility guard because none is needed, and that is commented in the controller, as spec 060 did. |
| **V. Material 3 / design system** | Pass | Shared components only: `DataTableView`, `CatalogPagination`, `CatalogListStateView`, `buildCatalogRowActions` (with the `primaryAction` slot from spec 060), `ResponsiveDialog`, `FormErrorBanner`/`ErrorBanner` (through spec 061's `DeliveryOrderRefusal`), and spec 061's name cells. **Largest text level:** checked in quickstart step 11. |
| **VI. List and record-surface rules** | Pass | **List:** a table and pagination. The filter row is left out because there is nothing to search or filter, and the count is in the pagination footer only. **Row actions:** ✓ primary and ✕ secondary, within the two-icon limit. **Record surface:** the queue opens the order's one existing surface, the spec 061 detail screen. There is no second surface; the 060-style panel was explicitly declined in Clarification Q1. **AppBar actions:** none. |
| **VII. Online-only** | Pass | Nothing is persisted. |
| **Quality gates** | Pass | Unit, widget and live tests are listed in R11. `flutter analyze` must be clean, and catalog coverage is enforced. |

**Post-design re-check** (after Phase 1): unchanged.
- One `core/` touch: `localize_problem.dart`, which the catalog rule requires.
- One behavioural change to spec 061 code: `_actionButtons` gates spec 061's buttons on 71 update one by one instead of all at once. The visible result for every existing rights combination is the same, and `delivery_order_detail_screen_test` pins it.
- No deviation needs Complexity Tracking.

## Project Structure

### Documentation (this feature)

```text
specs/062-delivery-order-approval/
├── spec.md                # /speckit-specify (2026-11-15)
├── wireframes.md          # /speckit-wireframes-draft (Open Questions resolved in research)
├── plan.md                # This file
├── research.md            # Phase 0 (R1–R12)
├── data-model.md          # Phase 1
├── quickstart.md          # Phase 1
├── contracts/
│   └── ui-contracts.md    # Phase 1 (C1–C9)
├── checklists/
│   └── requirements.md
└── tasks.md               # /speckit-tasks (not yet)
```

### Source Code (repository root)

```text
lib/features/sales/
├── domain/repositories/delivery_order_admin_repository.dart   # +approvalQueue, approve, reject (C6)
├── data/delivery_order_admin_repository_impl.dart             # same
└── presentation/
    ├── delivery_order_approval/                               # new
    │   ├── delivery_order_approval_screen.dart                # C2, C8
    │   ├── delivery_order_approval_queue_controller.dart      # R3
    │   ├── approval_dialogs.dart                              # C3, C4
    │   └── approval_target.dart                               # data-model §1
    └── delivery_orders/
        ├── delivery_order_actions.dart                        # +approve, reject; invalidates queue (C5)
        └── delivery_order_detail_screen.dart                  # Rechazar/Aprobar, per-button gating (C7)
lib/core/navigation/nav_destinations.dart                      # NavBranch 27 + Logística entry (C1)
lib/app/router/app_router.dart                                 # branch + _routeGate clause (C1)
lib/core/errors/localize_problem.dart                          # not_pending_approval (C9)
lib/l10n/app_{es,en}.arb
specs/058-localized-api-errors/contracts/code-scope.tsv
test/unit/features/sales/…, test/widget/features/sales/…, integration_test/delivery_order_approval_quickstart_test.dart
```

**Structure Decision**: a single Flutter app. The approval queue is a sibling presentation folder of `delivery_orders/`. It shares that folder's repository, actions notifier, name cells and refusal widget, and adds nothing under `domain/entities`.

## Dependencies and risks

- **Approval is off by default on the server.** `delivery_order_approval_required` is a deployment env var, `False` by default. On a server where it's off, the queue is always empty and the feature looks dead. That is correct behaviour (spec edge case), but verifying it needs a server with the variable on. Whether production turns it on is a deployment decision outside this feature. Record the question in the PR so it gets answered before go-live.
- **The detail screen's gating changes.** Splitting the early `if (!canUpdate) return []` touches every spec 061 action. Mitigation: the spec 061 action-matrix test (T039 there) must still pass unchanged, and the new matrix (data-model §4) is added beside it.
- **Cancel and Reject side by side.** Users with both rights see two reason-taking actions on a pending order. Mitigation: the dialog notes say what each does (wireframe Open Question 3). Revisit if the walkthrough shows confusion.
- **Live writes leave data.** Each `MBE_WRITE` run leaves one approved order and one rejected draft.

## Complexity Tracking

No constitution violations need justification.
