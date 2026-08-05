# Implementation Plan: Cash Session Open, Close and Count

**Branch**: `021-cash-sessions` | **Date**: 2026-08-04 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/021-cash-sessions/spec.md`

## Summary

Cashiers get a shift: open a cash drawer session with a declared opening amount, close it by
counting denominations against an advisory expected-cash figure, and browse or recover past
and abandoned sessions. Two screens, one new feature module, no backend change.

The backend is already complete and the generated client already carries all five
operations, so this is a pure client feature. What shapes it is six findings from
[research.md](./research.md), four of which contradict the obvious implementation:

1. **The two open conflicts are disambiguated by re-reading state, not by parsing text**
   (research §4). Both refusals are HTTP 409 and the spec records their `detail` strings as
   the only server-side discriminator — so the natural implementation matches those strings.
   That would couple the UI to untranslated English prose no contract stabilizes. The client
   has a better discriminator: `GET /current` is authoritative about whether *this user* has
   a session, which is exactly what separates "your session is blocking you" from "someone
   else's drawer is busy". The re-read is also required anyway, because the cashier-busy
   remedy is to navigate to the blocking session. No new error plumbing is needed either:
   the dio interceptor already extracts FastAPI's `detail` for any unhandled status, so a
   409 arrives as `ServerError(statusCode: 409, message: <detail>)`.

2. **The count and close live on the detail screen, not in a dialog** (research §6). This
   falls out of constitution §VI — record actions belong on the record's own screen — and it
   pays off twice: the count is implemented once yet reachable from both the cashier's own
   shift panel and a supervisor recovering someone else's abandoned session (User Story 4),
   and the history row consequently needs no action icons at all. It also means
   `RecordFormActions` is correctly **not** used: its modes are create/view/edit and its
   buttons are Delete/Edit/Save, and a cash session is none of those.

3. **The drawer picker needs a privilege the cashier may not have** (research §7). Listing
   drawers is gated on `CASH_DRAWERS (10)`, a *different* system object from the `POS (44)`
   that gates opening a session. A cashier provisioned only for counter work can open a
   session but would get a 403 from the picker. The save is that `user_settings` already
   carries `cashDrawerName` resolved server-side, so the common path needs no drawer request
   at all. This produces a three-way fork the spec does not describe, and FR-007 needs a
   touch-up as a result — flagged, not silently diverged from.

4. **Exact decimal arithmetic requires a new dependency, against the local convention**
   (research §2). mbe-ui carries decimals as `String` end to end and never parses them for
   arithmetic; that convention exists because nothing until now *computed* on money. This
   feature's whole purpose is computing on money, and the difference is compared against
   zero to decide over/short — which `double` cannot be trusted for. `decimal 3.2.6` is
   added, confined to one file, with entities still carrying `String`.

5. **Three bare foreign keys must be resolved client-side** (research §5). `cash_drawer`,
   `cashier` and `cash_supervisor` come back as raw ints, where the rest of the API expands
   FKs to `{id, name}`. Drawers resolve via one cached page; employees via the existing
   per-id provider, since employees can exceed the hard 100-record page cap and there is no
   fetch-many-by-id. This is the first place in the codebase that resolves an FK per list
   row, and the real fix is upstream (issue A below).

6. **Status is derived, not returned** (research §9). Only `GET /current` reports a state,
   and only for the caller. Every list row and detail must replicate mbe-api's rule
   (`end == null` → open; open and started before today → stale). Putting that in a pure
   domain function is what makes SC-006 testable as a property instead of by driving three
   screens.

Two shared cleanups are required rather than optional, because the feature cannot legally
reach the code it needs: the money formatter is promoted out of `features/pricing` into
`core/widgets` (constitution §I forbids cross-feature `presentation` imports), and the
payment-method label mapper is promoted out of a private catalog-screen function. Both are
mechanical, and both are also planned by spec 020 — see research §15 for why that is
idempotent rather than conflicting.

Net: **1 new feature module (~19 files), 2 shared promotions (11 call sites), 1 new
dependency, 5 shared files edited, 1 file deleted, ~11 test files, and 2 mbe-api issues to
file.**

## Technical Context

**Language/Version**: Dart 3.10.3 / Flutter (stable)

**Primary Dependencies**: `flutter_riverpod` + `riverpod_generator`, `go_router`, `freezed`,
`dio` via the generated `mbe_api_client`, `flutter_localizations`/`intl`, `data_table_2`.
**One new dependency: `decimal ^3.2.6`** (pulls `rational 2.2.3`) — resolved clean via
`flutter pub add --dry-run decimal`, justified in Complexity Tracking.

**Storage**: N/A — online-only, all reads and writes go to mbe-api (constitution §VII). An
abandoned mid-count entry is intentionally not persisted.

**Testing**: `flutter_test` with `mocktail` mocking the *domain repository interface* (never
the generated client), plus one live-backend integration test guarded by
`--dart-define-from-file=.env`

**Target Platform**: Web (Chrome) primary, macOS/desktop; compact tier below 600 px

**Project Type**: Single Flutter application, feature-first layering

**Performance Goals**: The shift panel is one request. A 20-row history page costs
1 (sessions) + 1 (drawers, cached across pages) + N requests, where N is the number of
*distinct* cashiers on the page — typically 1–3 for a drawer-filtered view, worst case 20.
Detail is 1 + 1 + up to 2. Issue A below collapses all of it to one request per page.

**Constraints**: mbe-api caps every list request at 100 records; the history list has
exactly one filter (`cash_drawer`) and a fixed `cash_session_id DESC` sort; the closing
denomination breakdown is write-only and never readable; the `NavBranch` ↔ router
build-order invariant has no compile-time enforcement; the generated `OpeningAmount` and
`Denomination` types are `AnyOf<String, num>` wrappers requiring a `String`-arm-at-key-`0`
shim, where the reverse order throws at runtime.

**Scale/Scope**: 2 new screens, 1 new module, 5 shared files edited, page size 20.

**Reference-tenant reality**: production data contains cashiers with three and four sessions
open simultaneously, left by the legacy monolith. `GET /current` returns only the newest, so
those are unreachable except through the history list — this is the condition User Story 4
exists for, and it is real data, not a hypothetical.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design — result below is
post-design.*

| Principle | Verdict | Notes |
|---|---|---|
| **I. Feature-first layered architecture** | **PASS** | New `lib/features/sales/` with `domain`/`data`/`presentation`. `presentation` imports only `domain`. Importing `features/catalog/domain` for `CashDrawer`/`Employee` is sanctioned — §I names `catalog` the shared master-data module. Two promotions exist precisely to avoid a cross-feature `presentation` import. |
| **II. Riverpod for state & DI** | **PASS** | `@riverpod` `AsyncNotifier` for current-session and the list family; synchronous `Notifier` for the two form states; repository behind a `Provider` so tests override it. No new DI framework. |
| **III. Contract-driven API integration** | **PASS with 2 filed dependencies** | No hand-written DTOs; generated client used as-is with no codegen run needed. Errors map through the existing `AppError` union and `ErrorBanner`. Two mbe-api gaps are recorded as issues to file (below), not patched cross-repo. |
| **IV. Deny-by-default RBAC** | **PASS** | Route gated on `pos`/`read`; open on `pos`/`create`; close on `cashSessionClose`/`update`; drawer picker on `cashDrawers`/`read`. Every gated action is *absent* without privilege, never disabled. Controllers re-check at submit. Nav entry hidden by `navDestinationsProvider`. |
| **V. Material 3, white-labeled** | **PASS** | Material 3 only. All strings in both ARBs. All amounts and dates via `intl` through the shared formatter — no manual formatting. No brand token touched. |
| **VI. Desktop/web-first, compact-ready** | **PASS with 1 recorded deviation** | Shared `DataTableView`, `CatalogFilterBar`, `CatalogListStateView`, `ResponsiveFormGrid`, `LayoutBreakpoints`, `fetchClampedPage` pagination. Row click opens read-only detail; zero row action icons; Close is a body `FilledButton`, not an app-bar icon. **Deviation: no search box** — see Complexity Tracking. `RecordFormActions` unused is compliant, not a deviation: Close is not Edit/Save/Delete, and the record has none of those. |
| **VII. Online-only** | **PASS** | No caching layer, no offline store, no local persistence of an in-progress count. No PDF work. |

### mbe-api dependencies to file as issues

Per §III and the Workflow section, a needed backend change is filed upstream and recorded
here, never patched from an mbe-ui session. Neither blocks implementation; both delete
client code once shipped. Confirmed **zero** open issues currently on `mictlanix/mbe-api`,
so neither is already filed.

- **Issue A — expand the cash-session foreign keys.** Return `cash_drawer`, `cashier` and
  `cash_supervisor` as `{id, name}`, matching `CashDrawerResponse.facility`. Deletes the
  drawer-map provider and the per-row employee lookups entirely, and removes up to 20
  requests from a full history page.
- **Issue B — filters and sort on `GET /cash-sessions`.** Add a cashier filter, a date-range
  filter, a status filter and a sort choice. This is what would let the history list satisfy
  §VI's filtering rule, which it otherwise cannot.

## Project Structure

### Documentation (this feature)

```text
specs/021-cash-sessions/
├── plan.md                          # This file
├── spec.md                          # Feature specification
├── research.md                      # Phase 0 — 15 decisions
├── data-model.md                    # Phase 1 — entities, states, form shapes
├── quickstart.md                    # Phase 1 — validation guide
├── contracts/
│   ├── mbe-api-cash-sessions.md     # The 5 operations as consumed
│   ├── routes.md                    # Routes, gate, nav destination
│   └── cash-session-screens.md      # Screen behavior contract
├── checklists/
│   └── requirements.md              # Spec quality checklist
└── tasks.md                         # Phase 2 — NOT created by /speckit-plan
```

### Source Code (repository root)

```text
lib/
├── app/router/
│   └── app_router.dart                          # EDIT: branch 17, detail route, gate clause
├── core/
│   ├── domain/
│   │   └── payment_method.dart                  # EDIT: + shared paymentMethodLabel()
│   ├── navigation/
│   │   └── nav_destinations.dart                # EDIT: NavBranch.cashSessions, destination
│   └── widgets/
│       └── money_formatters.dart                # NEW: promoted from features/pricing
├── features/
│   ├── pricing/presentation/
│   │   └── pricing_formatters.dart              # DELETED: moved to core/widgets
│   └── sales/                                   # NEW module (spec 020 also creates it)
│       ├── domain/
│       │   ├── entities/
│       │   │   ├── cash_session.dart            # + PaymentMethodTotal
│       │   │   ├── current_session.dart         # + SessionState
│       │   │   └── denomination_count.dart
│       │   ├── repositories/
│       │   │   └── cash_session_repository.dart # + CashSessionListResult
│       │   ├── cash_session_status.dart         # enum + pure derivation
│       │   ├── denominations.dart               # the MXN ladder
│       │   └── money.dart                       # decimal arithmetic (also in spec 020)
│       ├── data/
│       │   └── cash_session_repository_impl.dart # + repo & drawer-map providers
│       └── presentation/
│           ├── cash_sessions_screen.dart         # shift panel + history list
│           ├── cash_sessions_list_controller.dart # + CashSessionFilter
│           ├── cash_session_detail_screen.dart   # summary + count + close
│           ├── current_session_controller.dart
│           ├── open_session_form_controller.dart
│           ├── close_session_form_controller.dart
│           └── widgets/
│               ├── shift_panel.dart
│               ├── cash_session_status_chip.dart
│               └── denomination_count_table.dart
└── l10n/
    ├── app_en.arb                               # EDIT: new keys + @ blocks
    └── app_es.arb                               # EDIT: new keys

test/
├── unit/
│   ├── app/router/app_router_test.dart          # EDIT: gate, branch index, pumpAt override
│   ├── core/widgets/money_formatters_test.dart   # MOVED from unit/features/pricing/
│   └── features/sales/
│       ├── cash_session_test.dart
│       ├── cash_session_status_test.dart
│       ├── money_test.dart
│       ├── denominations_test.dart
│       ├── cash_session_repository_impl_test.dart
│       ├── current_session_controller_test.dart
│       ├── open_session_form_controller_test.dart
│       ├── close_session_form_controller_test.dart
│       └── cash_sessions_list_controller_test.dart
├── widget/features/sales/
│   ├── cash_sessions_screen_test.dart
│   ├── cash_session_detail_screen_test.dart
│   └── cash_session_status_chip_test.dart
└── integration/
    └── cash_session_flow_test.dart              # live backend, .env guarded

pubspec.yaml                                     # EDIT: + decimal ^3.2.6
.env.template                                    # EDIT: + MBE_CASH_SESSION_* vars
```

**Also edited by the formatter promotion** (9 source call sites, 2 test files):
`features/pricing/presentation/{price_lists_list_screen,pricing_screen,exchange_rate_detail_screen,exchange_rates_list_screen}.dart`,
`features/catalog/presentation/{employee_detail_screen,vehicle_operator_detail_screen,suppliers_list_screen}.dart`,
`main.dart` (a comment), and
`test/widget/features/pricing/exchange_rate_detail_screen_test.dart`.

**Structure Decision**: A new `lib/features/sales/` module, the first business module after
`catalog` and `pricing`, named by constitution §I. It owns the cash-session repository and
screens; it owns no master data — `CashDrawer` and `Employee` stay in `catalog`. Routes take
the nested `/sales/...` form the constitution's Technology Stack section prescribes and spec
020 also adopts, deliberately diverging from the 15 flat business routes (research §1). The
two promotions land in `core/` because constitution §VI requires shared formatters there and
§I forbids the cross-feature `presentation` import that would otherwise be needed.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| **§VI: list screen ships without a search box** | `GET /cash-sessions` has no `search` parameter, and a cash session has no free-text field to search — it is four ids, two timestamps and an amount. The drawer facet is the only filter the endpoint supports. | Client-side filtering over the fetched page was rejected outright: it produces results that are silently wrong across page boundaries, which is worse than no search. Carrying a dead `search` field wired to a non-existent parameter (the spec-013 precedent) was rejected because that precedent was for a parameter mbe-api had already agreed to ship; nothing is agreed here yet. Filed as **issue B**; the box appears once the parameter exists. |
| **New dependency: `decimal ^3.2.6`** | The feature computes a counted total, an expected figure, and a difference compared against zero to decide over/short. `double` cannot be trusted for that comparison, and the underlying column permits four decimal places. | Hand-rolled integer minor units would avoid the dependency, and the ladder alone could be summed exactly as `int` — but the *expected* figure is built from server-supplied decimal strings, so a bespoke string-to-scaled-integer parser would be needed. That is a small amount of code carrying a large amount of risk in the one place this feature can be wrong about money. Confined to `money.dart`; entities still carry `String`. |
| **Shared promotion: `pricing_formatters.dart` → `core/widgets/money_formatters.dart` (11 files touched)** | The feature needs currency and date formatting and cannot legally reach the existing formatter: §I forbids `presentation` importing another feature's `presentation`, and §VI requires shared formatters in `core/widgets/`. | Duplicating the formatter in `features/sales` violates §VI. Importing across features violates §I. Doing nothing leaves no legal way to format an amount. The move is mechanical and preserves behavior exactly — notably it does **not** fix the hard-coded `$` symbol or the `'es_MX'` locale default, since changing those would alter what four existing pricing screens render, which no requirement asks for. |
| **Shared promotion: `_paymentMethodLabel` out of a private catalog screen** | FR-031 renders per-method totals with localized labels. The ARB keys exist; the enum→label mapping is private to `payment_method_option_detail_screen.dart`. | Copying a 15-arm switch guarantees drift the moment a payment method is added. One caller is updated; the mapping moves next to the enum it maps. |
| **First per-row FK resolution in the codebase** | `CashSessionResponse` returns three bare ints where the rest of the API expands FKs. All 8 existing `*DisplayNameProvider` call sites resolve exactly one id, for a filter chip or a detail field. | Load-all for employees was rejected as unsafe — employees can exceed the hard 100-record cap and there is no fetch-many-by-id, so the map would be silently incomplete. Showing raw ids fails FR-027's readability intent. Drawers *do* use a cached load-all because they are few and the coverage is checkable against `total`. Filed as **issue A**, which deletes this code. |
