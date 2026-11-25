# Implementation Plan: Commissions

**Branch**: `078-commissions` | **Date**: 2026-11-25 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/078-commissions/spec.md` (mictlanix/mbe-roadmap#34)

## Summary

This adds **Comisiones** to the back office's Finanzas group. It has three screens:
- **Months list**: every month with a period, its state and total.
- **Month**: the live or stored totals per agent. Choosing an agent shows their by-label totals and paged lines, with a read-only panel per line. The month can be closed, reopened and marked paid behind confirmations.
- **Settings**: five sections behind a segmented switch: labels, participation types, agents with their scheme, a per-agent rate grid, and product labels.

All 24 routes already exist in the generated client (`CommissionsApi`). No codegen or mbe-api change is needed.
- Eight error codes and seven resource nouns get Spanish and English messages (research R13).
- Two pieces move into core so this feature does not copy them: refunds' private info banner (R5) and customer discounts' percent parsing (R12).
- `AppFormatters` gains `monthYear` (R4).

## Technical Context

**Language/Version**: Dart 3 / Flutter (the stable channel pinned by the repo)

**Primary Dependencies**: flutter_riverpod + riverpod_generator, go_router, freezed, dio, the generated `mbe_api_client` (built_value), decimal, intl / flutter_localizations

**Storage**: N/A (online-only, §VII)

**Testing**:
- `flutter test`: unit tests, and widget tests with mocktail fakes.
- Live API tests in `test/integration/`: writes are gated by `MBE_WRITE=true`, and period close/reopen by `MBE_COMMISSIONS_PERIODS=true`. Pay is never automated (R14).
- A device walkthrough in `integration_test/`, run under `caffeinate -dimsu`.

**Target Platform**: Desktop (macOS) and web, Expanded tier first (§VI)

**Project Type**: Flutter client app (one project)

**Performance Goals**:
- **Round trips**: one for the months list. Two for a month (the detail, plus the cached months list for the chain rules). The agents list is read once per screen.
- **Paging**: a month's lines (thousands) are paged client-side from one response. Totals are never recomputed from the page.
- **Rate grid**: a cell write patches the grid in place, with no refetch.

**Constraints**:
- Spanish UI text built from codes (§III).
- One formatting surface, including the month name and percent entry (§V).
- `can(112, …)` on every action, absent when not allowed (§IV).
- Filter drawer for every facet, including the agent pivot. No AppBar actions (§VI).

**Scale/Scope**:
- 3 routes. 5 settings sections.
- 7 dialogs and panels: Abrir mes, the close, reopen and pay prompts, the line panel, assign label, and the product-label dialog. Plus 3 record panels (label, participation, agent).
- 1 nav destination and 24 endpoints.
- 8 new error codes and 7 resource nouns. About 110 new l10n keys.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Result | How |
|---|---|---|
| **I. Feature-first layers** | Pass | New `lib/features/commissions/` with `domain/` (entities, repository interface), `data/` (implementation over `CommissionsApi`) and `presentation/` (`periods/`, `settings/`) (R1). Cross-feature reads go through `data/` providers only: `employeeDisplayNameProvider` and `employeeRepositoryProvider` (catalog), and `productRepositoryProvider` (catalog). |
| **II. Riverpod** | Pass | `AsyncNotifier` controllers for the months, the month (family on month + agent), the rate grid (family on agent) and product labels. A keepAlive actions notifier returns `AppError?` and invalidates the month and the list. The repository is a provider ([contracts/repository.md](contracts/repository.md)). |
| **III. Contract-driven API** | Pass | Generated `CommissionsApi` only. Rates are `Decimal`, never `double`. Every reachable code gets a message ([contracts/error-messages.md](contracts/error-messages.md)), with `code-scope.tsv` flipped to `IN` and the coverage count raised from 206 to 214. No mbe-api change. Agent and employee names are resolved client-side (R2, R3). |
| **IV. Deny-by-default RBAC** | Pass | Nav, routes and `_routeGate` use `can(112, read)`. Create shows the "+" actions. Update shows ✎, grid edits, Asignar, Cerrar, Reabrir and Pagar. Delete shows Eliminar and clearing a rate. Pickers also need read on employees and products, with names degrading to `#id`. |
| **V. Material 3 / formatting** | Pass | Only shared components: `CatalogFilterBar`, `showCatalogFilterSheet`, `DataTableView`, `CatalogPagination`/`CatalogPage`, `StatusChip`, `FactStripRow`, `ResponsiveDialog`, `showRecordSheet`, `RecordFormActions`, `CatalogEntityPicker`, `ConfirmableTextField`, `InlineErrorText`, `ErrorBanner`, `FormErrorBanner`, `ListStateViews`, plus the promoted `InfoBanner`. Money, percent, rate, dates and month names go through `formattersProvider`. Percent entry uses the promoted `PercentInput` (R12). The largest text level is quickstart step 17. |
| **VI. List and record surface** | Pass | **Months list**: filter row with no search (the endpoint has none) and an Estado facet, a table, and client pagination (R9). **Month**: a full screen (own URL, owns lines). The agent pivot is in the drawer and shown in the strip (R7). The line panel is read-only, with no Edit or View toggle, because a line is not a record (R8). Close, Reopen and Pay sit in the body action row (R6). **Settings**: label, participation and agent use the panel surface with `RecordFormActions`, the shared Edit icon and a read-only row click. Agents carry one extra row action ("Ver tasas"). Product labels: no search (the endpoint has none), drawer facets, server pagination (R10). |
| **VII. Online-only** | Pass | No caching or printing. The printed ticket belongs to roadmap#101. |

**Post-design re-check (after Phase 1)**: Pass.
- `core/` gains three things, each with a second caller in this change:
  - `InfoBanner` (refunds + commissions);
  - `PercentInput` (customer discounts + commissions);
  - `AppFormatters.monthYear` (commissions plus the 8 error messages).
- No other existing screen changes behavior.

## Project Structure

### Documentation (this feature)

```text
specs/078-commissions/
├── plan.md              # This file
├── research.md          # Phase 0: R1–R15
├── data-model.md        # Phase 1: entities, action availability, grid model, validation
├── quickstart.md        # Phase 1: automated + manual walkthrough
├── wireframes.md        # Pre-plan drawings (open questions answered in spec + research)
├── contracts/
│   ├── ui-contract.md       # routes, nav, screens, dialogs, rights
│   ├── repository.md        # CommissionRepository ↔ endpoints, controllers
│   └── error-messages.md    # 8 new codes, 7 nouns, reused codes
└── tasks.md             # Phase 2 (/speckit-tasks)
```

### Source Code (repository root)

```text
lib/features/commissions/
├── domain/
│   ├── entities/commission_period.dart          # NEW: CommissionPeriodStatus, CommissionMonth, CommissionPeriodSummary,
│   │                                            #      CommissionPeriod, CommissionTotal, CommissionLine, CommissionMovement
│   ├── entities/commission_settings.dart        # NEW: CommissionLabel, CommissionParticipation, CommissionAgent,
│   │                                            #      CommissionScheme, CommissionAgentRate, CommissionProductLabel(+Page)
│   └── repositories/commission_repository.dart  # NEW
├── data/
│   └── commission_repository_impl.dart          # NEW: commissionRepositoryProvider, mapping, DioException→AppError
└── presentation/
    ├── shared/
    │   ├── commission_employee_name.dart        # NEW (R2)
    │   └── commission_lookups.dart              # NEW: agents / labels / participations providers, agent-name resolution (R3)
    ├── periods/
    │   ├── commission_periods_screen.dart       # commissionsPath = '/commissions'
    │   ├── commission_periods_controller.dart
    │   ├── commission_period_status_chip.dart
    │   ├── open_month_dialog.dart
    │   ├── commission_month_screen.dart         # commissionMonthPath(y, m)
    │   ├── commission_month_controller.dart     # + action availability (data-model)
    │   ├── commission_period_actions.dart       # close, reopen, pay; assign label from a line
    │   ├── commission_line_panel.dart
    │   ├── assign_label_dialog.dart
    │   └── period_dialogs.dart                  # close / reopen / pay prompts
    └── settings/
        ├── commission_settings_screen.dart      # commissionSettingsPath, section switch
        ├── labels_section.dart, label_form.dart, label_form_controller.dart
        ├── participations_section.dart, participation_form.dart, participation_form_controller.dart
        ├── agents_section.dart, agent_form.dart, agent_form_controller.dart
        ├── agent_rates_section.dart, agent_rates_grid.dart, agent_rates_controller.dart
        └── product_labels_section.dart, product_labels_controller.dart, product_label_dialog.dart

lib/core/widgets/info_banner.dart                     # NEW (R5), promoted from refunds
lib/features/sales/presentation/refunds/refund_detail_screen.dart   # _InfoBanner → InfoBanner
lib/core/formatting/percent_input.dart                # NEW (R12), moved from customer discounts
lib/features/catalog/presentation/customer_discount_dialog_controller.dart   # uses PercentInput
lib/core/formatting/app_formatters.dart               # + monthYear (R4)
lib/app/router/app_router.dart                        # branch 37, settings before :year/:month, _routeGate
lib/core/navigation/nav_destinations.dart             # NavBranch.commissions = 37; child of 'finance' after expenses
lib/core/errors/localize_problem.dart                 # 8 codes, 7 nouns
lib/l10n/app_es.arb, app_en.arb                       # commission… keys, navCommissions, apiError…, apiResource…
specs/058-localized-api-errors/contracts/code-scope.tsv   # 8 rows OUT → IN

test/unit/core/errors/problem_fixtures.dart, catalog_coverage_test.dart   # 206 → 214; needParams
test/unit/core/formatting/                            # monthYear, PercentInput (moved tests + maxDecimals 4)
test/unit/features/commissions/                       # fixtures, repository impl, month (availability, totals),
                                                      # periods, rate grid writes, product labels
test/widget/core/widgets/info_banner_test.dart
test/widget/features/commissions/                     # months list, month (open/closed/paid/blocked, rights),
                                                      # line panel, dialogs, settings sections, rate grid, large text
test/unit/core/navigation/nav_destinations_test.dart, test/unit/app/router/app_router_test.dart
test/integration/commissions_live_test.dart
integration_test/commissions_quickstart_test.dart
```

**Structure Decision**: Commissions gets a new feature module mirroring `/commissions`, because no existing module owns it (R1). Periods and settings are two presentation subfolders under one repository and one privilege.

## Implementation order

1. **Core**: `monthYear`, `PercentInput` (with the customer-discount switch), `InfoBanner` (with the refund switch). **Check:** the existing customer-discount and refund tests pass unchanged.
2. **Errors**: 8 codes and 7 nouns, arb text, fixtures, `code-scope.tsv`. **Check:** `catalog_coverage_test` passes at 214.
3. **Domain and data**: entities, status and scheme mapping, the repository. Unit tests cover the mapping, `Decimal` round trips and the errors.
4. **Months list and month (US1–US3, P1)**: controllers with action availability, screens, dialogs, line panel, nav and routes. Widget tests cover rights × states (open, closed, paid, blocked ×3).
5. **Settings: labels, participations, agents (US4)**.
6. **Rate grid (US5)**, then **product labels and Asignar from a line (US6)**.
7. **Live and device**: `commissions_live_test.dart` (R14) and the quickstart device test.

Steps 1–4 make a shippable P1 slice. Steps 5–6 are P2 and independent of each other.

## External dependencies

None. Every route is in the generated client. Names are resolved client-side (R2, R3), and the missing product-label text search is met by a product picker (R10). Nothing is filed against mbe-api.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| The line panel uses the record-sheet surface for something that is not a record: read-only, no Edit or View toggle. | FR-005a needs every value of a line, and the table cannot hold them (§VI forbids horizontal scroll). | A row expansion would be a new shared table behavior for one caller. A separate route per line has no identity to address (R8). |
| Two small, behavior-preserving changes to shipped screens (refunds' banner, customer discounts' percent parsing). | §V/§VI require one shared copy, and this feature is their second caller. | A feature-local third copy is what those principles forbid (R5, R12). |
