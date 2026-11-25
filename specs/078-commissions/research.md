# Research: Commissions

**Feature**: [spec.md](spec.md) | **Plan**: [plan.md](plan.md) | **Date**: 2026-11-25

The spec's clarifications settled the scope questions (rate grid, where labels are set,
totals-only until an agent is chosen, line detail in a side panel, one settings screen).
This file settles the rest: the wireframes' open questions 2–7, 10 and 11, and what the
codebase and mbe-api showed.

## R1 — A new feature module, `lib/features/commissions/`

- **Decision**: Commissions gets its own module with `domain/`, `data/` and `presentation/`. Routes are `/commissions`, `/commissions/:year/:month` and `/commissions/settings`, so the folder mirrors the route.
- **Rationale**: Commissions spans sales (orders, refunds), catalog (products, employees) and finance (payout), so none of those modules owns it. One API class (`CommissionsApi`) and one SystemObject (112) cover all of it.
- **Alternatives**: `features/sales/` (wrong owner, and that module is already the largest); `features/catalog/` for settings plus `sales/` for periods (splits one privilege and one menu entry across two modules).

## R2 — Who closed, reopened or paid: employee ids, resolved by the employee name lookup

- **Finding**: In mbe-api, `closed_by`, `reopened_by` and `paid_by` are foreign keys to `employee.employee_id`, set from the caller's employee (`app/models/commission.py:105-109`, `commission_service.py` l.586/624/643). They are not user ids, so the spec's assumption that they were user numbers was wrong.
- **Decision**: Show them with `employeeDisplayNameProvider(id)` (`lib/features/catalog/data/employee_repository_impl.dart:24`), which falls back to `#id`. A feature-local `CommissionEmployeeName` widget wraps it, modeled on `InventoryEmployeeName`.
- **Rationale**: The lookup already exists and degrades to `#id` without Employees read. No mbe-api issue is needed.
- **Spec impact**: The "Who closed/paid" assumption is corrected to "employee", and the mbe-api fallback is dropped.

## R3 — Agent names: from the agents list, then the employee lookup

- **Decision**: Totals and lines carry the agent's employee id only. Names come from `GET /commissions/agents` (same privilege, about 6 rows, read once per screen). A former agent (FR-006 edge case) falls back to `employeeDisplayNameProvider`, then to `#id`.
- **Alternatives**: Ask mbe-api to join names into totals and lines (the api#324–#330 pattern). Rejected because the agents list covers every current agent and the fallback covers the rest. Asking upstream would block the feature for a cosmetic gain.

## R4 — Choosing a month (wireframe Q2)

- **Decision**: These stay feature-local:
  - an "Abrir mes…" `ResponsiveDialog` with month and year dropdowns, defaulting to the previous calendar month and offering nothing after the current month;
  - ‹ › steppers in the month screen's `FactStripRow`, with › hidden past the current month.
- **Formatting**: A month name must go through the formatting surface (§V), so `AppFormatters` gains `monthYear(int year, int month)` ("octubre de 2026" / "October 2026", `DateFormat.yMMMM` under the provider's locale; lowercase by default as Spanish writes it, with `capitalize: true` for titles and table cells). `monthName(int month, {capitalize})` (`DateFormat.LLLL`, the stand-alone form) labels the Mes dropdown, beside its own Año dropdown. The guard test keeps any widget from building its own `DateFormat`.
- **Alternatives**: A shared month picker in `core/widgets/`, rejected because there is one caller. `showDatePicker` with day ignored, rejected because it offers days, which is confusing.

## R5 — The "live, not final" notice (wireframe Q4)

- **Finding**: `core/widgets/` has no info-toned banner. `ErrorBanner` is error-toned. Refunds has a private `_InfoBanner` (`refund_detail_screen.dart:793-820`): `secondaryContainer`, an info icon and text.
- **Decision**: Promote it to `core/widgets/info_banner.dart` (`InfoBanner({required String message})`) and switch the refund screen to it, with no visual change. Commissions uses it for the open-month notice and the settings note (FR-018).
- **Rationale**: §VI says shared banners belong in `core/widgets/`. A second private copy is what the constitution exists to prevent. The refund screen change is a one-line swap with its existing widget test as the check.

## R6 — Close, Reopen, Pay placement and prompts (wireframe Q3)

- **Decision**: The month screen ends with a body action row, the dominant pattern (`inventory_count_detail_screen.dart:265-376`, transfers, invoice stamping): `Align(centerEnd, Wrap(...))`. From left to right:
  - "Reabrir" as an `OutlinedButton`;
  - "Marcar pagado" or "Cerrar mes" as a `FilledButton`, rightmost.
  - An `ErrorBanner` sits above the row for refusals.

  `RecordFormActions` is not used: a month is not edited, saved or deleted.
- **Prompts**: Feature-local `showCloseCommissionPeriodDialog`, `showReopenCommissionPeriodDialog` and `showPayCommissionPeriodDialog` in `period_dialogs.dart`, each built on `showResponsiveDialog` as the transfer and count prompts are. They are not destructive-styled: `showRecordDeleteConfirmation` is for deletes.
- **Close prompt text** shows the month's line count and total from the loaded detail, all agents.

## R7 — The agent pivot on the month screen (wireframe Q5)

- **Decision**: Follow the kardex and stock precedent, which keeps §VI intact with no exception:
  - The agent picker lives in the filter drawer (`showCatalogFilterSheet`).
  - The chosen agent shows in the `FactStripRow` with a clear (×) control.
  - Choosing a row in the all-agents totals table also selects that agent.

  The selection lives in the URL (`?agent=17`), so a reload or a shared link keeps it.
- **Rationale**: Clicking a totals row is the fast path, the drawer is the formal path, and the strip shows the state. This removes the need to document a §VI exception.

## R8 — Lines paging and the line panel (FR-005, FR-005a)

- **Decision**:
  - The period detail is one GET (`?salesperson=` when an agent is chosen).
  - Lines are paged client-side with `CatalogPage` (precedent: `auth/presentation/admin/privileges_grid.dart:109`), 50 per page.
  - Totals come from the response, never from the visible page.
  - Choosing a line opens `showRecordSheet` read-only (precedent: `showVerificationPaymentPanel`, `isDirty: () => false`), listing every FR-005a value. This is not a record surface (§VI): a line has no record of its own, no Edit and no View toggle.
- **Lines-table facets** (Movimiento, Etiqueta, Participación), drawn as optional in the wireframes, are **not built**: the spec does not ask for them (CLAUDE.md §2).
- **Order link** (wireframe Q10): not built. The spec does not ask for one.

## R9 — Months list: filtering and paging (wireframe Q6)

- **Decision**:
  - `GET /periods` returns every month with a row and takes no parameters.
  - The list has no search box, because the endpoint has none (§VI tells the filter row to omit it).
  - It has one **Estado** facet (Abierto / Cerrado / Pagado) applied client-side in the filter drawer.
  - It is paged client-side with `CatalogPage`, 25 per page. The set grows by at most 12 rows a year, but §VI asks for paging on any growing list.

## R10 — Settings screen sections (clarified) and their filter rows

- **Route**: `/commissions/settings?section=labels|participations|agents|rates|products`. A `SegmentedButton` sits in `CatalogFilterBar.actions` and switches sections through the URL (the payments-scope precedent). Below 840 px, `CatalogFilterBar` already wraps it under the row. At compact width it becomes a `DropdownButton` of the same five sections.
- **Labels, participations, agents**:
  - Bounded lists: one GET each, filtered by client-side search over the loaded rows, no paging.
  - `DataTableView` with the shared Edit icon. Row click opens the read-only panel.
  - The record surface is `showRecordSheet` (§VI: few fields, no child collections).
- **Product labels**: The endpoint has **no text search**: only the `commission` and `product` ids, `skip` and `limit` (`commissions.py:276-280`). So:
  - The filter row omits search (§VI).
  - The filter drawer has two facets: **Etiqueta** (label picker) and **Producto** (`CatalogEntityPicker<ProductListItem>` over `productRepositoryProvider.list(search:)`, the `add_issue_line_dialog.dart:106-123` precedent).
  - It is server-paged with `CatalogPagination`, 20 per page (API maximum 100).
  - "Asignar etiqueta" (toolbar) opens a dialog that picks any product and a label (FR-016, clarification).
  - Row Edit opens the same dialog with that product fixed, plus "Quitar etiqueta".
- **Spec impact**: FR-016's "searchable by product" is met by the Producto facet (pick a product), not a search box.

## R11 — The rate grid (wireframe Q11)

- **Decision**: A feature-local `AgentRatesGrid`, built from:
  - a `DataTableView` with one row per label;
  - one column per participation type (`fixedWidth`, numeric) after the label name and its rate;
  - in each cell, a `ConfirmableTextField` (core) parsing a percentage, with the cell's last refusal shown under it in `InlineErrorText`.
- **Writes**:

  | Before | After | Request |
  |---|---|---|
  | empty | a value | `POST /agent-rates` |
  | a value | a different value | `PUT /agent-rates/{id}` |
  | a value | empty | `DELETE /agent-rates/{id}` |

  The grid holds the `id`s from `GET /agent-rates?salesperson=`.
- **Why `ConfirmableTextField` and not the pricing grid's `price_cell`**: `price_cell` keeps a refused value flagged on screen because a price sheet is edited in bulk. A rate is edited one cell at a time, and §III wants the refusal reason shown. `ConfirmableTextField`'s contract (confirm on submit, discard on blur, acknowledge the discard) is what FR-015 needs, and it already lives in core.
- **Agent pivot**: The agent picker sits in the filter drawer and the chosen agent in a `FactStripRow`, the same as R7. It defaults to the first agent by name. The Agents list row offers "Ver tasas" (its one extra action, §VI), which opens this section filtered to that agent.
- **Read-only user**: Cells render as text through `formattersProvider.percent`.

## R12 — Percent entry and display (FR-017)

- **Finding**: `validateCustomerDiscountPercent` (`customer_discount_dialog_controller.dart:27-47`) is the only percent-entry logic. It parses with `Decimal.tryParse`, checks 0–100, limits decimals, and is private to catalog's presentation. The server stores rates with 6 fractional digits (`"0.025000"`).
- **Decision**: Move the parsing and validation, unchanged, into `lib/core/formatting/percent_input.dart` (`PercentInput.parse(String, {int maxDecimals})` → `Decimal?` fraction, plus a validator returning an error key), and point the customer-discount controller at it.
  - Commissions uses `maxDecimals: 4`: 4 percent digits make 6 fraction digits, which is exactly what the server keeps, so nothing is lost (FR-017).
  - The customer-discount tests are the regression check.
- **Display** (read-only): `formatters.percent`, two decimals with `%` ("2.50 %", "1.25 %"). The rates the scope document names (labels 0.2–4%, shares 50% and 100%) and every effective rate they make (smallest: ARMEX 0.2% × 50% = 0.10 %) are exact at two percent decimals, so the table and the line panel both use it. This is an assumption about the data: the live test (T034) reports any label rate, share or line rate with more than four fraction digits, and if one exists, T002 adds a full-precision display method instead.
- **Editable** (grid cells, label rate field): `formatters.field.rate` fills the field at full precision with no `%` (`"0.025"` → `"2.5"`), the way customer discounts do. `PercentInput.parse` reads it back. §V keeps these two paths apart. Display never uses `field.rate`, and fields never use `percent`.
- **Alternatives**: A third copy inside commissions, rejected by §V (one formatting surface, editable fields included).

## R13 — Error coverage (§III)

- **Measured** from `mbe-api/app/services/commission_service.py` and `app/api/v1/endpoints/commissions.py`: see [contracts/error-messages.md](contracts/error-messages.md).
- **New**: 8 codes. The 7 `commission_period.*` codes carry `{year, month}`, rendered with `monthYear`. `commission_agent.salesperson_not_agent` carries `{salesperson_id}`.
- **Reused**: `resource.not_found`, `resource.already_exists`, `resource.still_referenced`, `auth.forbidden`, `request.*`.
- **New resource nouns** (with grammatical gender) so the reused messages name the thing:
  - `commission` → "etiqueta de comisión"
  - `commission_agent` → "agente"
  - `commission_participation` → "tipo de participación"
  - `commission_salesperson` → "tasa de agente"
  - `commission_product` → "etiqueta de producto"
  - `commission_period` → "periodo de comisiones"
  - `commission_period_line` → "línea de comisión"
- `code-scope.tsv`: 8 rows OUT → IN. `catalog_coverage_test`: `expect(checked, 206)` → `214`.

## R14 — Live tests must not pay a month or start the close chain in shared data

- **Finding**: Paying is final (FR-009). The first close starts the sequence that every later month depends on (spec 025 FR-010a). Both change mbe_dev for everyone.
- **Decision**: `test/integration/commissions_live_test.dart`:
  - **Reads**: periods, a month, agents, labels, rates, product labels. Always run.
  - **Writes** (`MBE_WRITE=true`): settings round trips on throwaway rows. Create a label → set a rate for an existing agent under a temporary participation type → label a product that has none → remove all three in reverse order. This also checks the `still_referenced` refusal on deleting the label before its rate.
  - **Close and reopen** run only under a separate `MBE_COMMISSIONS_PERIODS=true`, and only when the latest closed month can be reopened afterwards. Pay is never automated: it is a quickstart manual step on a throwaway database.

## R15 — Navigation and routing

- `NavBranch.commissions = 37`. Its `kNavigationTree` child goes in `finance` after `expenses`, with `PrivilegeGate(SystemObject.commissionsBySalesPerson, AccessRight.read)`. A `StatefulShellBranch` is appended to the shell in the same order.
- Routes are top-level `GoRoute`s under the branch:
  - `/commissions` (months);
  - `/commissions/settings`, declared before the next one;
  - `/commissions/:year/:month`, with `int.tryParse` on both and a month range check, falling back to the list.
- A `_routeGate` prefix rule for `/commissions` requires Read.
