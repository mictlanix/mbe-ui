---
description: "Task list for 078-commissions"
---

# Tasks: Commissions

**Input**: Design documents from `specs/078-commissions/`

**Prerequisites**: plan.md, spec.md, research.md (R1–R15), data-model.md, contracts/ui-contract.md, contracts/repository.md, contracts/error-messages.md, quickstart.md, wireframes.md

**Tests**: The spec doesn't ask for a test suite as such, but the constitution's quality gates require tests. Test tasks sit inside each story, after the code they cover.

**Organization**: Grouped by user story (US1–US6, spec.md).
- **P1 (the MVP)**: US3 the list of months, US1 review and close a month, US2 pay and reopen. All three are P1. They are ordered by dependency: the month screen is reached from the list, and the pay and reopen buttons sit on the month screen.
- **P2**: US4 labels, participation types and agents; US5 agent rates; US6 product labels.

Phase 2 holds what two or more stories share: three small core changes, the error messages, the strings, the entities, the repository and the lookups. Unlike 069, three shipped files change: the refund screen's banner, the customer-discount percent parsing, and `AppFormatters` (plan.md, Complexity Tracking). The existing tests of the first two are the regression check.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: parallelizable (different files, no dependency on an incomplete task)
- **[Story]**: US1 review and close · US2 pay and reopen · US3 months list · US4 labels, participations, agents · US5 agent rates · US6 product labels

## Cross-story notes

- **This is a new module, `lib/features/commissions/`.** There is no 078 precedent to mirror file by file, so these are the closest precedents. Open each before writing its commissions counterpart:
  - **Repository, entities, controllers**: `lib/features/inventory/data/inventory_transfer_repository_impl.dart` (the provider in the impl file, mapping by private top-level functions, `DioException` → `AppError`) and its test `test/unit/features/inventory/inventory_transfer_repository_impl_test.dart` (a real Dio with a fake HTTP adapter). Fixtures: `test/unit/features/inventory/inventory_transfer_fixtures.dart`.
  - **Settings panels**: `lib/features/catalog/presentation/labels_list_screen.dart`, `label_form.dart` and `label_form_controller.dart`.
  - **State-transition body action row and prompts**: `lib/features/inventory/presentation/transfers/inventory_transfer_detail_screen.dart` and `transfer_dialogs.dart`.
  - **Read-only record sheet**: `showVerificationPaymentPanel` in `lib/features/sales/presentation/payment_verification/verification_payment_panel.dart`.
  - **Client-side paging**: `lib/features/auth/presentation/admin/privileges_grid.dart` (`CatalogPage` + `onPageChanged`).
  - **Section switch in the filter row**: `payments_scope_switch` in `lib/features/sales/presentation/payments/payments_list_screen.dart`.
  - **Pivot shown in a strip, picked in the drawer**: `lib/features/inventory/presentation/kardex/kardex_screen.dart`.
  - **Editable cells**: `lib/core/widgets/confirmable_text_field.dart`.
  - **Product picker**: `lib/features/inventory/presentation/issues/add_issue_line_dialog.dart`.
  - **Widget harness**: `test/widget/features/inventory/inventory_harness.dart`.
  - **Live test**: `test/integration/inventory_transfers_live_test.dart`. **Device test**: `integration_test/inventory_transfers_quickstart_test.dart`.
- **Shared files.** Do these sequentially, not in parallel:
  - `lib/features/commissions/presentation/periods/commission_month_screen.dart`: T017 (US1) creates it with the strip, audit line, banner, both totals views, the lines table and the Cerrar mes button with the blocked reasons. T024 (US2) adds Reabrir and Marcar pagado. T033 (US6) adds the Asignar… cell.
  - `lib/features/commissions/presentation/periods/commission_period_actions.dart`: T019 (US1) creates it with close, T023 (US2) adds reopen and pay, and T033 (US6) adds assign label.
  - `lib/features/commissions/presentation/periods/period_dialogs.dart`: T018 (US1) creates it with the close prompt, and T022 (US2) adds the reopen and pay prompts.
  - `lib/features/commissions/presentation/settings/commission_settings_screen.dart`: T028 (US4) creates it with the section switch, the note, and the labels, participations and agents sections. T030 (US5) adds the rates section, and T032 (US6) adds the products section.
  - `lib/app/router/app_router.dart` and `lib/core/navigation/nav_destinations.dart`: T013 (US3) adds the nav entry, the branch, the list route and the gate. T015 (US3) adds the month route. T028 (US4) adds the settings route, **declared before `/:year/:month`**.
  - `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb`: T005 adds the error-message keys and T006 adds every other commissions key once. If a later task needs another, add it there and run `flutter gen-l10n`. Never hand-edit `lib/l10n/app_localizations*.dart`.
  - `test/widget/features/commissions/commission_harness.dart`: T012 creates it, and later tests only use it.
- **Generated code.** After editing a freezed or `@riverpod` file, run `dart run build_runner build --delete-conflicting-outputs` at the repo root. Never run two build_runner processes at once. **[P] means the files don't overlap**, not that build_runner may run concurrently: when [P] tasks are worked together, write their sources, then run build_runner once for the group. No client regeneration is needed: `CommissionsApi` already has every operation this spec calls.
- **Formatting.** Format only the files you changed (`dart format <files>`). Never `dart format .`, and never format `lib/generated/`.
- **Money, rates, percents, dates and month names** go through `formattersProvider` (constitution §V). No `NumberFormat`, no `DateFormat`, no `toStringAsFixed`. Money, rates and shares are `Decimal`, never `double`; the wire carries them as strings. Read-only rates (tables, line panel) use `formatters.percent`. Editable rate fields are filled with `formatters.field.rate` and parsed with `PercentInput` (research R12). Never mix the two.
- **Spacing tokens, not literals** (`Theme.of(context).spacing`). No automated guard catches a literal, so check it in review.
- **Never match or show server prose** (§III). Show refusals through `AppError.localizedMessage` / `ErrorBanner`, which build the text from the error's `code`. Recognition keys on the code.
- **Status and scheme names come from l10n**, never from `enum.name`.
- **Rights (§IV).** Every control follows the availability table in data-model.md and the rights lines in contracts/ui-contract.md. A missing right means the control is absent, never disabled. Document `SystemObject.commissionsBySalesPerson` (112) in a comment where a route, nav entry or control is gated. The server decides every business rule; the UI's availability rules are guidance (FR-011).
- **Surfaces (§VI).** The month is a full screen. Label, participation and agent are panels. The line panel is read-only and is not a record: no Edit, no View toggle. The AppBar has no actions anywhere. Months and settings lists follow filter row → list → pagination.
- **Simplifications.** Any shortcut carries a comment `// simplified: <ceiling>, <what to do when it binds>`.

---

## Phase 1: Setup

**Purpose**: a known-good baseline, so later failures are attributable.

- [ ] T001 Run `flutter analyze` and the tests this feature touches: `test/unit/core/errors/`, `test/unit/core/formatting/`, `test/unit/core/navigation/nav_destinations_test.dart`, `test/unit/app/router/app_router_test.dart`, `test/unit/features/catalog/customer_discount_dialog_controller_test.dart`, `test/widget/features/sales/` (the refund screen tests), and `test/unit/core/formatting_guard_test.dart`. Record any failure that predates this feature, so it isn't blamed on the new code. (The golden failures recorded for `core_widgets` in earlier specs fail identically on main and are outside these folders.)

---

## Phase 2: Foundational (blocks every story)

**Purpose**: the shared core pieces, the messages and strings, the entities and the repository.

- [ ] T002 [P] Add `String monthYear(int year, int month)` to `lib/core/formatting/app_formatters.dart`: "octubre 2026" in es, "October 2026" in en, built with `DateFormat.yMMMM` under the provider's locale and capitalized per locale convention (research R4). Add tests to `test/unit/core/formatting/app_formatters_display_test.dart`: both locales, month 1 and 12, and an out-of-range month returning the shared placeholder instead of throwing. The existing guard (`formatting_guard_test.dart`) must still pass.
- [ ] T003 [P] Move the percent parsing and validation out of `lib/features/catalog/presentation/customer_discount_dialog_controller.dart` into `lib/core/formatting/percent_input.dart`: `PercentInput.parse(String text, {int maxDecimals})` → `Decimal?` (a fraction), and a validator returning an error key (invalid / out of range 0–100 / too many decimals). Keep customer discounts' `maxDecimals = 6` and behaviour unchanged by pointing the controller at it (research R12). Move the matching assertions into `test/unit/core/formatting/percent_input_test.dart` and add `maxDecimals: 4` cases (2.5 → 0.025, 0.0125 → 0.000125, 0.00001 refused). `test/unit/features/catalog/customer_discount_dialog_controller_test.dart` must pass unchanged. Keep `customerDiscountPercentMaxDecimals` exported if tests import it.
- [ ] T004 [P] Promote refunds' private `_InfoBanner` (`lib/features/sales/presentation/refunds/refund_detail_screen.dart:793-820`) into `lib/core/widgets/info_banner.dart` as `InfoBanner({required String message})`, with the same look (`secondaryContainer`, `shapes.mdRadius`, `spacing.md`, an `info_outline` icon). Switch the refund screen to it and delete the private copy. Add `test/widget/core/widgets/info_banner_test.dart` (renders the message and icon). The existing refund screen widget tests must pass unchanged (research R5).
- [ ] T005 Add the 8 commission error codes and 7 resource nouns (research R13, contracts/error-messages.md): add the codes to `localizedErrorCodes` and the `localizeProblem` switch in `lib/core/errors/localize_problem.dart` (rendering `{period}` with `formatters.monthYear`), add `commission`, `commission_agent`, `commission_participation`, `commission_salesperson`, `commission_product`, `commission_period` and `commission_period_line` to `resourceNoun` and `resourceGender`, add the `apiError…` and `apiResource…` keys to `lib/l10n/app_es.arb` and `lib/l10n/app_en.arb`, flip the 8 rows in `specs/058-localized-api-errors/contracts/code-scope.tsv` from `OUT` to `IN`, add fixtures to `test/unit/core/errors/problem_fixtures.dart`, add the 8 to `needParams`, and raise `expect(checked, 206)` to `214` in `test/unit/core/errors/catalog_coverage_test.dart`. Run `flutter gen-l10n`. **Check:** `catalog_coverage_test` passes, and a missing `year` or `month` falls back to the generic message.
- [ ] T006 Add every other commissions string once, to `lib/l10n/app_es.arb` and `lib/l10n/app_en.arb` (es first, then en), and run `flutter gen-l10n`: `navCommissions` ("Comisiones"), the months list (title, columns, empty message, "Abrir mes…", "Configuración", "Ver {month}", the Estado facet), the month screen (titles, the live notice, totals headings, the audit lines, "Sin etiqueta", "Devolución", every column heading), the status names (Abierto, Cerrado, Pagado), the scheme names (Pago total, Pagos parciales), the three action prompts of contracts/ui-contract.md, the three blocked-close reasons (`commissionCloseBlockedNotEnded`, `commissionCloseBlockedPrevious`, `commissionCloseBlockedLater`), the line panel labels, the settings sections and the FR-018 note, the label, participation and agent forms, the grid (including `commissionRateClearNotAllowed`), the product-labels dialog, the validation messages (`commissionNameRequired`, `percentInvalid`, `percentOutOfRange`, `percentTooPrecise`) and every empty, loading and error state. Reuse existing common keys (Cancelar, Guardar, Eliminar, Reintentar) rather than duplicating them.
- [ ] T007 [P] Create `lib/features/commissions/domain/entities/commission_period.dart` (freezed, per data-model.md): `CommissionPeriodStatus` (open, closed, paid; an unknown value maps to open), `CommissionMonth` (year, month, `previous`, `next`, ordering, `isAfterCurrent(now)`), `CommissionPeriodSummary`, `CommissionPeriod` (with `grandTotal`, `lineCount`, `totalsByAgent`, `totalsByLabel(agentId)` derived from the totals), `CommissionTotal`, `CommissionMovement` and `CommissionLine`. Money, rates and quantities are `Decimal`. Run build_runner.
- [ ] T008 [P] Create `lib/features/commissions/domain/entities/commission_settings.dart` (freezed): `CommissionScheme` (fullyPaid = 1, partialPayments = 2), `CommissionLabel`, `CommissionParticipation`, `CommissionAgent`, `CommissionAgentRate`, `CommissionProductLabel` and `CommissionProductLabelPage`. Run build_runner (once for T007 and T008 together).
- [ ] T009 Create `lib/features/commissions/domain/repositories/commission_repository.dart` with the methods of contracts/repository.md (periods and settings).
- [ ] T010 Create `lib/features/commissions/data/commission_repository_impl.dart`: `commissionRepositoryProvider` built on `api.CommissionsApi(dio, appSerializers)`, the private mapping functions (strings → `Decimal`, status and scheme enums, `closedBy`/`reopenedBy`/`paidBy` as employee ids), a null body throwing `AppError.server()`, and `DioException` → `AppError` as in `inventory_transfer_repository_impl.dart`. Product-label paging passes `skip` and `limit`; period detail passes `salesperson` only when an agent is chosen.
- [ ] T011 Add `test/unit/features/commissions/commission_fixtures.dart` (builders for every entity and a JSON body per endpoint) and `test/unit/features/commissions/commission_repository_impl_test.dart` (a real Dio with a fake HTTP adapter, as the transfers test does): mapping of every endpoint, `Decimal` round trips of `"0.025000"`, the `salesperson` query only when chosen, `skip`/`limit` on product labels, an unknown status, and the 409 and 422 refusals reaching `AppError` with their codes.
- [ ] T012 [P] Create `lib/features/commissions/presentation/shared/commission_lookups.dart` (`commissionAgentsProvider`, `commissionLabelsProvider`, `commissionParticipationsProvider`, and an agent-name resolver: the agents list first, then `employeeDisplayNameProvider`, then `#id`, research R3) and `commission_employee_name.dart` (`CommissionEmployeeName`, modeled on `InventoryEmployeeName`, research R2). Create `test/widget/features/commissions/commission_harness.dart` (provider overrides with a mocktail `CommissionRepository` and the access fixtures for rights × screens, modeled on `inventory_harness.dart`) and `test/unit/features/commissions/commission_lookups_test.dart` (a former agent falls back to the employee name, then to `#id`).

**Checkpoint**: `flutter analyze` is clean, `catalog_coverage_test` passes at 214, and the customer-discount and refund tests pass unchanged.

---

## Phase 3: User Story 3 — See the history of months (Priority: P1) 🎯 first slice

**Goal**: Finanzas › Comisiones lists the months with a period, newest first, and lets the user open any month.

**Independent Test**: With closed, paid and reopened months, the list shows each with its state, total and dates. Open one. Pick a never-closed month in "Abrir mes…". With no month closed, the empty state offers the previous month.

- [ ] T013 [US3] Add `NavBranch.commissions = 37` and a child of the `finance` group after Gastos in `lib/core/navigation/nav_destinations.dart` (label `navCommissions`, route `/commissions`, `PrivilegeGate(SystemObject.commissionsBySalesPerson, AccessRight.read)`), append the matching `StatefulShellBranch` and the `/commissions` route in `lib/app/router/app_router.dart`, and add the `/commissions` prefix rule to `_routeGate` (Read). Update `test/unit/core/navigation/nav_destinations_test.dart` and `test/unit/app/router/app_router_test.dart` (branch 37, entry hidden without Read, route redirects without Read).
- [ ] T014 [P] [US3] Create `lib/features/commissions/presentation/periods/commission_period_status_chip.dart` (`StatusChip<CommissionPeriodStatus>`: open → neutral, closed → info, paid → success) and `commission_periods_controller.dart` (`AsyncNotifier` over `listPeriods`, with a client-side Estado filter and page, 25 per page, research R9). Add `test/unit/features/commissions/commission_periods_controller_test.dart` (filtering, paging, newest first) and `test/widget/features/commissions/commission_period_status_chip_test.dart`. Run build_runner.
- [ ] T015 [US3] Create `lib/features/commissions/presentation/periods/commission_periods_screen.dart` (`commissionsPath`): `CatalogFilterBar` with no search, "Abrir mes…" and "Configuración" in `actions` (icon only below 600 px), the badged filters button with the Estado facet; a `DataTableView` of Mes · Estado · Total (numeric) · Cerrado el · Pagado el with `CatalogPagination`; row tap navigates to the month; `ListStateViews` for loading, error and the empty message with a `FilledButton` "Ver {previous month}" (the filters button hidden when empty). Add `open_month_dialog.dart` (a `ResponsiveDialog` with Mes and Año dropdowns, defaulting to the previous month, offering nothing after the current month) and declare the `/commissions/:year/:month` route (`commissionMonthPath`, `int.tryParse` on both, an invalid or future month redirecting to `/commissions`) in `lib/app/router/app_router.dart`. Add `test/widget/features/commissions/commission_periods_screen_test.dart` (populated, empty, loading, error, the Estado facet, row navigation, "Abrir mes…", a reopened month showing Abierto and $0.00, and the compact two-line cards).

**Checkpoint**: the list is reachable from the menu, and any month can be opened by address.

---

## Phase 4: User Story 1 — Review and close a month's commissions (Priority: P1) 🎯 MVP

**Goal**: A manager opens a month, reviews totals per agent, picks an agent to see their by-label totals and lines, and closes the month behind a confirmation.

**Independent Test**: Open last month (never closed): live banner, grand total, agents table, no lines. Pick an agent: label totals equal the sum of their lines. Open a line: every value shows. Close and confirm: Cerrado, with who and when, same totals. The current month and a month whose previous is open show why they cannot be closed.

- [ ] T016 [P] [US1] Create `lib/features/commissions/presentation/periods/commission_month_controller.dart`: a family `AsyncNotifier<CommissionPeriod>` keyed by month and agent (`getPeriod`), the months list read alongside it, and the action availability of data-model.md as a pure function (`closeAvailability` returning available, or one of three blocked reasons: not ended, previous not closed, later closed; reopen and pay availability are added in T021). The agent selection is read from the route's `?agent=`. Add `test/unit/features/commissions/commission_month_controller_test.dart`: grand total and per-agent totals are the sums of the server's totals, the by-label rows for one agent, the three blocked reasons, "closed or paid" both counting as closed for the chain, the first close with nothing closed, the current month, and an agent whose refunds outweigh their sales (a negative total, kept negative, never clamped to zero).
- [ ] T017 [US1] Create `lib/features/commissions/presentation/periods/commission_month_screen.dart` per contracts/ui-contract.md: the `FactStripRow` (‹ month ›, hidden past the current month; `StatusChip`; the chosen agent with a clear (×); the badged filters button with the Agente picker drawer, R7), the audit line from `CommissionEmployeeName`, the `InfoBanner` live notice on open months, the all-agents totals table (a row tap selects the agent), the agent view (their total and scheme, the by-label table, and the lines `DataTableView` client-paged 50 with ↩ and "Devolución" on refunds and "Sin etiqueta" on unlabelled lines), `ListStateViews`, and the Cerrar mes `FilledButton` in the body action row or, in its place, the blocked reason as text. Show nothing as an action without Update. Keep the header while loading.
- [ ] T018 [P] [US1] Create `lib/features/commissions/presentation/periods/commission_line_panel.dart` (`showRecordSheet`, read-only, `isDirty: () => false`, titled "Línea del pedido {n}") listing every FR-005a value with rates through `formatters.percent`, and `period_dialogs.dart` with `showCloseCommissionPeriodDialog` (`showResponsiveDialog`, not dismissible while in flight, the line count and total in the body). Add `test/widget/features/commissions/commission_period_dialogs_test.dart` (the close prompt text, Cancelar changes nothing, the spinner and the non-dismissible state while closing).
- [ ] T019 [US1] Create `lib/features/commissions/presentation/periods/commission_period_actions.dart`: a keepAlive notifier returning `AppError?`, with `close(month)`, which on success invalidates the month and the months list, and on refusal keeps the error for the `ErrorBanner` and still re-reads both (FR-010). Add `test/unit/features/commissions/commission_period_actions_test.dart` (success refreshes both, each refusal code surfaces and refreshes). Run build_runner.
- [ ] T020 [US1] Add `test/widget/features/commissions/commission_month_screen_test.dart`: open with no agent (totals only, banner, no lines), choosing an agent from the table and from the drawer (the URL carries `?agent=`), the by-label totals and the lines, a refund row, an unlabelled row, a former agent shown by number, a negative agent total formatted as a negative amount, closing with confirm and with Cancelar, a refused close with its translated message, the three blocked reasons with no button, the closed state (audit line, no banner), loading and error with the header kept, a user with Read only (no Cerrar mes), and the compact cards. Add `test/widget/features/commissions/commission_line_panel_test.dart` (every value, scheme 2 share only on scheme 2 sales, read-only, no Edit).

**Checkpoint**: US3 and US1 are shippable. A month can be reviewed and closed.

---

## Phase 5: User Story 2 — Pay a month, or reopen it (Priority: P1)

**Goal**: A closed month can be marked paid (final) or, while it is the latest closed month, reopened.

**Independent Test**: With a closed, unpaid latest month, reopen it and confirm: it is Open and computed live. Close it again. Mark it paid and confirm: Pagado with who and when, and neither action is offered.

- [ ] T021 [US2] Extend the availability function in `lib/features/commissions/presentation/periods/commission_month_controller.dart` with reopen (closed and no later month closed or paid) and pay (closed), per data-model.md, and extend `test/unit/features/commissions/commission_month_controller_test.dart` (not the latest closed month → no Reabrir, paid → neither, open → neither).
- [ ] T022 [US2] Add `showReopenCommissionPeriodDialog` and `showPayCommissionPeriodDialog` to `lib/features/commissions/presentation/periods/period_dialogs.dart` (the pay prompt warns the month becomes final and shows the total; the reopen prompt says the stored lines are discarded and recalculated on the next close). Extend `commission_period_dialogs_test.dart`.
- [ ] T023 [US2] Add `reopen(month)` and `pay(month)` to `lib/features/commissions/presentation/periods/commission_period_actions.dart`, with the same refresh and refusal handling as close, and extend `test/unit/features/commissions/commission_period_actions_test.dart` (each of the five reopen and pay refusal codes surfaces and refreshes).
- [ ] T024 [US2] Add the Reabrir (`OutlinedButton`) and Marcar pagado (`FilledButton`) buttons to the body action row in `lib/features/commissions/presentation/periods/commission_month_screen.dart`, offered per the availability function and only with Update, and extend `commission_month_screen_test.dart`: the closed latest month (both buttons), a closed month that is not the latest (Marcar pagado only), a paid month (none), reopening to Abierto with its live banner, paying with the warning, refused reopen and pay with their messages, and the audit line growing ("Reabierto el …", "Pagado el …").

**Checkpoint**: the whole monthly cycle works: US3 + US1 + US2 are the MVP.

---

## Phase 6: User Story 4 — Maintain labels, participation types and agents (Priority: P2)

**Goal**: Manage the three small catalogs from one settings screen.

**Independent Test**: Create a label at 3%, edit to 3.5%, try 120% (refused before sending), delete it. Add a salesperson as an agent under Pagos parciales, switch to Pago total, remove them. Rename a participation type. Deleting a label or participation in use, or an agent with rates, shows the translated refusal.

- [ ] T025 [P] [US4] Create the labels section in `lib/features/commissions/presentation/settings/`: `labels_section.dart` (client search, "+ Nueva etiqueta" with Create, a `DataTableView` of Nombre · Tasa (`formatters.percent`, numeric) · Comentario · the shared Edit icon with Update, row tap → read-only panel), `label_form.dart` and `label_form_controller.dart` (modeled on the catalog label form: `showRecordSheet`, `ResponsiveFormGrid`, `RecordFormActions` Delete then Edit/Save; Tasa entered as a percentage through `PercentInput` with `maxDecimals: 4`, validated 0–100 before sending; the refusal in `FormErrorBanner`). Add `test/unit/features/commissions/label_form_controller_test.dart` (blank name, out of range, too many decimals, 2.5 → 0.025) and `test/widget/features/commissions/labels_section_test.dart` (rights × actions, in-use refusal message, read-only mode). Run build_runner.
- [ ] T026 [P] [US4] Create the participations section: `participations_section.dart`, `participation_form.dart` and `participation_form_controller.dart` in `lib/features/commissions/presentation/settings/` (a Nombre-only panel, client search, "+ Nueva participación"). Add `test/unit/features/commissions/participation_form_controller_test.dart` and `test/widget/features/commissions/participations_section_test.dart` (the in-use refusal). Run build_runner (once for the group, see Generated code).
- [ ] T027 [P] [US4] Create the agents section: `agents_section.dart` (client search, "+ Nuevo agente", a table of Agente (`CommissionEmployeeName`) · Esquema · ✎ and the one extra row action "Ver tasas" linking to `/commissions/settings?section=rates&agent=`), `agent_form.dart` and `agent_form_controller.dart` (a panel: Empleado via `CatalogEntityPicker<EmployeeListItem>` with `salesPerson: true` and current agents excluded, read-only on edit; Esquema as a radio; the note that the change applies from the next calculation and never alters closed months). Add `test/unit/features/commissions/agent_form_controller_test.dart` and `test/widget/features/commissions/agents_section_test.dart` (current agents excluded from the picker, scheme change, the `still_referenced` refusal on removing an agent with rates, "Ver tasas"). Run build_runner (once for the group, see Generated code).
- [ ] T028 [US4] Create `lib/features/commissions/presentation/settings/commission_settings_screen.dart` (`commissionSettingsPath`): the `SegmentedButton` in `CatalogFilterBar.actions` (a `DropdownButton` below 600 px) writing `?section=`, the `InfoBanner` with the FR-018 note on every section, and the labels, participations and agents sections. Add the `/commissions/settings` route in `lib/app/router/app_router.dart` **before** `/commissions/:year/:month`, and extend `test/unit/app/router/app_router_test.dart` (`settings` is not read as a year). Add `test/widget/features/commissions/commission_settings_screen_test.dart` (switching sections through the URL, the note, the compact dropdown, and a Read-only user seeing no actions).

**Checkpoint**: the three catalogs can be maintained.

---

## Phase 7: User Story 5 — Maintain agent rates (Priority: P2)

**Goal**: Edit one agent's shares as a grid of labels × participation types.

**Independent Test**: Choose an agent. Type 100 in an empty cell and press Enter (created), change it to 80 (updated), clear it (removed). A value of 120 is refused before sending. Leaving a cell without Enter discards with acknowledgement. A rejected write shows its reason under the cell.

- [ ] T029 [P] [US5] Create `lib/features/commissions/presentation/settings/agent_rates_controller.dart`: a family `AsyncNotifier<AgentRateGrid>` keyed by agent, building rows from the labels and columns from the participation types plus the agent's rates (data-model.md), with `writeCell(labelId, participationId, text)` choosing create, update or delete per research R11, patching the grid in place with no refetch, and keeping the last refusal per cell. Expose per cell whether it is writable for the current rights (empty → Create, filled → Update) and whether it may be cleared (Delete), per the rights table in contracts/ui-contract.md. Add `test/unit/features/commissions/agent_rates_controller_test.dart`: every label and participation appears including empty cells, the three write kinds, writability per right (an empty cell without Create and a filled cell without Update are not writable), clearing without Delete refused, a duplicate (`resource.already_exists`) and a non-agent (`commission_agent.salesperson_not_agent`) refusal kept on its cell, and the cell reverting. Run build_runner.
- [ ] T030 [US5] Create `lib/features/commissions/presentation/settings/agent_rates_grid.dart` and `agent_rates_section.dart`: a `DataTableView` with one row per label (name and its rate) and one fixed-width numeric column per participation type, each cell a `ConfirmableTextField` filled with `formatters.field.rate` and parsed through `PercentInput` (`maxDecimals: 4`), with `InlineErrorText` under it, but only where the controller says the cell is writable; any other cell is plain text through `formatters.percent`; the agent chosen in the filter drawer (`CatalogEntityPicker` over agents, defaulting to the first by name) and shown in a `FactStripRow`; and `?agent=` read from the route. Add the section to `commission_settings_screen.dart`. Add `test/widget/features/commissions/agent_rates_grid_test.dart`: the three writes through typing and Enter, a Create-only user editing empty cells but not filled ones, an Update-only user editing filled cells but not empty ones, 120 refused before sending, blur discarding with acknowledgement, a server refusal under the cell, Read-only as text, the agent from "Ver tasas", and the compact one-block-per-label layout. Because a grid row is a non-trivial control band (label name, label rate, three fields with a `%` suffix), the test also measures it (§VI): symmetric top and bottom insets per row, and a shared text baseline between the label name, the label rate and each cell's text, at the default and the largest text level.

**Checkpoint**: rates can be maintained without a developer.

---

## Phase 8: User Story 6 — Assign products to labels (Priority: P2)

**Goal**: Set, change or remove a product's label, from the product-labels list and from an unlabelled line of an open month.

**Independent Test**: Filter by a label and by a product. Give an unlabelled product a label from "Asignar etiqueta", change it, remove it. On an open month, "Asignar…" on a "Sin etiqueta" line labels the product and the month recomputes. A closed month offers no Asignar.

- [ ] T031 [P] [US6] Create `lib/features/commissions/presentation/settings/product_labels_controller.dart`: an `AsyncNotifier` with the Etiqueta and Producto filters and a server-side page of 20 (`listProductLabels`), plus `set` and `remove`. Add `test/unit/features/commissions/product_labels_controller_test.dart` (filters sent as `commission` and `product`, paging, set and remove refresh the page). Run build_runner.
- [ ] T032 [US6] Create `lib/features/commissions/presentation/settings/product_label_dialog.dart` (a `ResponsiveDialog`: Producto via `CatalogEntityPicker<ProductListItem>` over `productRepositoryProvider.list(search:)`, fixed on edit; Etiqueta picker; "Quitar etiqueta" on edit; the FR-018 note) and `product_labels_section.dart` (no search, the badged filters button with Etiqueta and Producto facets, "+ Asignar etiqueta" with Update (it is a PUT), "Quitar etiqueta" with Delete, a `DataTableView` of Código · Producto · Etiqueta · ✎, `CatalogPagination` server-side). Add the section to `commission_settings_screen.dart`. Add `test/widget/features/commissions/product_labels_section_test.dart` (both facets, paging, assign to an unlabelled product, change, remove, refusals, Read-only, and a Create-only user seeing no "+ Asignar etiqueta").
- [ ] T033 [US6] Create `lib/features/commissions/presentation/periods/assign_label_dialog.dart` (a `ResponsiveDialog`: the product read-only, the label picker, the FR-018 note), add `assignLabel(productId, labelId)` to `commission_period_actions.dart` (it sets the product's label, then invalidates the open month so it recomputes, FR-016a), and add the "Asignar…" cell to unlabelled lines in `commission_month_screen.dart`, offered only on open months and with Update. Extend `commission_month_screen_test.dart` (Asignar on an open month recomputes, absent on closed and paid months, absent without Update) and `commission_period_actions_test.dart`.

**Checkpoint**: all six stories are done.

---

## Phase 9: Polish and cross-cutting

- [ ] T034 [P] Add `test/integration/commissions_live_test.dart` (modeled on `inventory_transfers_live_test.dart`, run with `--dart-define-from-file=.env.settings --dart-define-from-file=.env`): reads always (periods, a month with and without an agent, agents, labels, participations, rates, product labels); writes under `MBE_WRITE=true` as throwaway round trips (create a label → a temporary participation → a rate for an existing agent → label a product that has none, then remove all in reverse order, and check the `still_referenced` refusal when deleting the label before its rate); close and reopen under `MBE_COMMISSIONS_PERIODS=true` only, and only when the latest closed month can be reopened afterwards. **Pay is never automated** (research R14). Discover its fixtures at run time rather than hard-coding ids. In the read pass, report (fail with the offending values) any label rate, agent share or line effective rate with more than four fraction digits, since read-only display rounds to two percent decimals (research R12).
- [ ] T035 [P] Add `integration_test/commissions_quickstart_test.dart` (modeled on `inventory_transfers_quickstart_test.dart`): sign in, open a month, choose an agent, open a line, create and delete a label, and edit a rate cell. Run it under `caffeinate -dimsu flutter test … -d macos` with the two define files.
- [ ] T036 [P] Add `test/widget/features/commissions/commission_large_text_test.dart`: the months list, the month with lines, and the rate grid at the largest of the four text-size levels at desktop width, with no overflow and no clipped content (§V).
- [ ] T037 [P] Redraw the month and lines blocks of `specs/078-commissions/wireframes.md` to match the clarifications: the all-agents view is totals only, the agent selector is in the drawer with the chosen agent in the strip, the lines table has the core columns plus the read-only panel, and the settings are one screen with five sections. Mark the resolved open questions as settled instead of open.
- [ ] T038 Run the full quickstart (`specs/078-commissions/quickstart.md`) steps 1–5 and 9–19 against the dev backend, and steps 6–8 on a throwaway database only. Record anything that differs from the spec in `specs/078-commissions/` before closing the feature.
- [ ] T039 Run `flutter analyze` and the whole suite once: `flutter test`. Compare against the baseline of T001; the only failures allowed are those recorded there. Run `dart format` on the changed files only.

---

## Dependencies and order

- **Phase 1 → Phase 2 → stories.** Phase 2 blocks every story.
- Within Phase 2: T002, T003, T004, T007 and T008 can run in parallel (T007 and T008 must not run build_runner at once). T005 needs T002 (it uses `monthYear`). T006 is independent of the others but must finish before any screen task. T009 needs T007 and T008. T010 needs T009. T011 needs T010. T012 needs T010 and T006.
- **US3 → US1 → US2**: the month screen needs the list's route (T015), and US2 extends US1's screen, actions and dialogs.
- **US4, US5 and US6** depend on Phase 2 only, apart from the shared settings screen: T028 creates it, and T030 and T032 add to it. US5 needs US4's screen (T028). US6's section needs T028 too. US6's assign-from-a-line task (T033) needs US1's month screen.
- **Phase 9** needs every story.

```
Phase 1 → Phase 2 ─┬─ US3 → US1 → US2 ─────────────┐
                   ├─ US4 → US5 ───────────────────┼─→ Phase 9
                   └─ US4 → US6 (T033 needs US1) ──┘
```

## Parallel opportunities

- Phase 2: T002, T003, T004 and T007/T008 touch different files.
- US4: the three sections (T025, T026, T027) are separate files, with build_runner run one at a time.
- US5's controller (T029) and US6's controller (T031) can be written in parallel once T028 exists.
- Phase 9: T034, T035, T036 and T037 are independent files.

## Implementation strategy

1. **MVP (the first demo)**: Phases 1–2 and US3, US1 and US2. A manager can open any month, review it, close it, reopen it and mark it paid. The settings the calculation reads are already in the shared database, so this works before any settings screen exists (spec US4).
2. **Increment 2**: US4, then US5 and US6 in either order.
3. **Last**: Phase 9, which includes the live and device tests that touch a real backend.
