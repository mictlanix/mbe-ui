# Tasks: Presentation Consistency — One Formatting Surface & Flex Spacing

**Input**: Design documents from `/specs/028-presentation-consistency/`
**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md), [data-model.md](data-model.md), [contracts/](contracts/), [quickstart.md](quickstart.md)

**Tests**: Included. The spec's acceptance scenarios and success criteria (round-trip guarantee, the guard, golden/screenshot parity) are only verifiable with tests, and research R8 specifies the test strategy explicitly.

**Organization**: Phase 3 (US1, P1) and Phase 4 (US2, P2) are independently shippable. They touch disjoint files with one exception — `sale_line_card.dart`, touched by US1 for a call site and by US2 as its worked example — sequenced so US1's edit to that file lands first (plan.md Structure Decision).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: US1 or US2
- Every task names an exact file path from the repo root

## Path Conventions

Flutter application, single project. `lib/` for source, `test/` for tests, both at repo root (plan.md Project Structure).

---

## Phase 1: Setup

**Purpose**: Nothing to initialize — this feature adds one new source directory inside an already-configured project. No dependency, script, or tool needs to change.

- [X] T001 Confirm `flutter analyze` and `flutter test` are green on a clean checkout of `028-presentation-consistency` before any change, so every later regression is attributable to this feature

**Checkpoint**: Baseline confirmed clean. No other setup exists for this feature.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: The formatting surface, its configuration, and the migration's stay-behind boundary. Every US1 call-site task depends on this phase; US2 depends on nothing here and could start in parallel.

**⚠️ CRITICAL**: T002–T012 must all complete before any US1 call-site migration task (T013+) starts — every migration task imports `formattersProvider`.

- [X] T002 [P] Add `FormattingSettings` (7 fields: `datePattern`, `dateTimePattern`, `currencySymbol`, `currencyCode`, `currencyDecimalDigits`, `percentDecimalDigits`, `quantityDecimalDigits`) in `lib/core/config/app_settings.dart`, defaults per data-model.md §1 (`yyyy-MM-dd`, `yyyy-MM-dd HH:mm`, `$`, `MXN`, `2`, `2`, `0`), each falling back to its default on a malformed `--dart-define` value rather than throwing (constitution §V, matching `BrandConfig._parseSeedColor`'s existing fallback pattern)
- [X] T003 [P] Unit tests for `FormattingSettings.fromEnvironment` fallback behavior — malformed digit counts, empty pattern strings — in `test/unit/core/config/app_settings_test.dart` (extend the existing file; write first, confirm failing against T002's stub)
- [X] T004 [US1-blocking] Wire `FormattingSettings` into `AppSettings` and `AppSettings.fromEnvironment()` in `lib/core/config/app_settings.dart` (depends on T002)
- [X] T005 [P] Create `lib/core/formatting/app_formatters.dart`: the `AppFormatters` value object with `display.*` (`currency`, `percent`, `date`, `dateTime`, `quantity`) and `field.*` (`price`, `rate`, `quantity` + inverses `parsePrice`, `parseRate`, `parseQuantity`) per contracts/formatting-surface.md and data-model.md §2 — `String` in/out, `Decimal.tryParse` internally, `double` only at the final `NumberFormat.format` call (research R1), null/unparseable → `—` everywhere (data-model.md §2.3)
- [X] T006 [P] Create `lib/core/formatting/formatters_provider.dart`: `formattersProvider`, a `Provider<AppFormatters>` derived from `appSettingsProvider` and the existing `resolvedLocaleProvider` (`lib/core/settings/user_display_preferences_controller.dart:117`) — no new locale resolution, compose the shipped one (research R1)
- [X] T007 [P] [US1] Unit tests for every `display.*` method in `test/unit/core/formatting/app_formatters_display_test.dart` — one example per method reproducing the worked examples in contracts/formatting-surface.md, plus null and unparseable input → `—`
- [X] T008 [P] [US1] Unit tests for every `field.*` method + inverse in `test/unit/core/formatting/app_formatters_field_test.dart`, including the documented examples (`"50.0000000"` → `50.00`, `"0.1600"` → `16`)
- [X] T009 [US1] Property test asserting `parseX(field.x(v)) == v` for every `field.*`/`parseX` pair over generated decimal-string values, including values whose stored precision exceeds displayed precision, in `test/unit/core/formatting/app_formatters_roundtrip_test.dart` (research R8; depends on T005)
- [X] T010 [US1] Widget test confirming `formattersProvider` resolves once per build (not reconstructed per rebuild-triggering state change) in `test/unit/core/formatting/formatters_provider_test.dart` (depends on T006)
- [X] T011 Add the 7 formatting keys to `.env.template`'s "App settings" section, each with its default and the commented worked examples from contracts/formatting-surface.md's pattern-reference block (explicit-pattern table, skeleton table, number-knob table) — this file is the deployer-facing source, must not drift from the contract (FR-014, FR-016)
- [X] T012 [P] Add a `deploy/<customer>.env`-style example block to `deploy/README.md` showing `DATE_FORMAT=d/M/yyyy` as the opt-out case, matching the existing brand/locale examples already documented there

**Checkpoint**: `AppFormatters`/`formattersProvider` exist, are tested, and are documented. No call site has been touched yet — both `MoneyFormatters` and `money.dart`'s display helpers are still live. The app's behavior is unchanged.

---

## Phase 3: User Story 1 - Every value reads the same way, everywhere (Priority: P1) 🎯 MVP

**Goal**: One formatting surface, configurable per deployment, replacing three disagreeing implementations across ≈76 call sites in 28 files (data-model.md §2.4; research R3's corrected count).

**Independent Test**: Build with no `.env` — every date reads `2026-08-17`, every amount `$1,234.50`. Rebuild with `DATE_FORMAT=d/M/yyyy` — every date switches together, no screen left behind. Open a record with a null date and a null amount — both render `—` (quickstart.md scenarios 1–3).

### Migrate `MoneyFormatters` call sites (50 sites, 22 files → `display.*`)

Grouped by feature module; files within a group are `[P]` (disjoint files, all depend only on the Foundational phase).

- [X] T013 [P] [US1] Migrate `lib/core/widgets/date_range_filter_chip.dart` (2 sites) to `ref.watch(formattersProvider).display.*`
- [X] T014 [P] [US1] Migrate `lib/features/sales/presentation/cash_session_detail_screen.dart` (10 sites)
- [X] T015 [P] [US1] Migrate `lib/features/sales/presentation/cash_sessions_screen.dart` (5 sites) — including its hand-written `'—'` for a missing session end (data-model.md §2.3), which becomes the shared em-dash rather than a local literal
- [X] T016 [P] [US1] Migrate `lib/features/sales/presentation/capture/sale_totals_bar.dart` (4 sites)
- [X] T017 [P] [US1] Migrate `lib/features/sales/presentation/pos_sales_list_screen.dart` (3 sites) — leave `pos_sales_list_controller.dart`'s `_dateFacetFormat` untouched, it is exempt (data-model.md §3)
- [X] T018 [P] [US1] Migrate `lib/features/pricing/presentation/pricing_screen.dart` (3 sites)
- [X] T019 [P] [US1] Migrate `lib/features/pricing/presentation/exchange_rates_list_screen.dart` (3 sites) — its separate filter-drawer non-compliance (research R3) stays out of scope, touch only the formatting calls
- [X] T020 [P] [US1] Migrate `lib/features/sales/presentation/widgets/denomination_count_table.dart` (2 sites)
- [X] T021 [P] [US1] Migrate `lib/features/sales/presentation/capture/customer_bar.dart` (2 sites)
- [X] T022 [P] [US1] Migrate `lib/features/pricing/presentation/price_lists_list_screen.dart` (2 sites)
- [X] T023 [P] [US1] Migrate `lib/features/catalog/presentation/employee_detail_screen.dart` (2 sites)
- [X] T024 [P] [US1] Migrate `lib/features/catalog/presentation/vehicle_operator_detail_screen.dart` (2 sites)
- [X] T025 [P] [US1] Migrate `lib/features/sales/presentation/open_sales_selector.dart` (1 site)
- [X] T026 [P] [US1] Migrate `lib/features/sales/presentation/capture/sale_line_row.dart` (1 site)
- [X] T027 [P] [US1] Migrate `lib/features/sales/presentation/capture/sale_line_card.dart` (1 site) — **do this before Phase 4 touches this same file for spacing**
- [X] T028 [P] [US1] Migrate `lib/features/sales/presentation/payment/applied_payments_panel.dart` (1 site)
- [X] T029 [P] [US1] Migrate `lib/features/sales/presentation/payment/payment_summary_panel.dart` (1 site)
- [X] T030 [P] [US1] Migrate `lib/features/sales/presentation/payment/payment_capture_pane.dart` (1 site)
- [X] T031 [P] [US1] Migrate `lib/features/sales/presentation/delivery/destination_editor.dart` (1 site)
- [X] T032 [P] [US1] Migrate `lib/features/sales/presentation/delivery/destination_card.dart` (1 site) — this file also has a `money.dart` display-helper call site, see T036
- [X] T033 [P] [US1] Migrate `lib/features/catalog/presentation/suppliers_list_screen.dart` (1 site)
- [X] T034 [P] [US1] Migrate `lib/features/pricing/presentation/exchange_rate_detail_screen.dart` (1 site)

### Migrate the inline `DateFormat.yMd()` (1 site → `display.date`)

- [X] T035 [P] [US1] Migrate `lib/features/catalog/presentation/taxpayer_certificates_section.dart:51` from inline `DateFormat.yMd()` to `ref.watch(formattersProvider).display.date`, dropping the local `package:intl` import

### Migrate `money.dart` display helpers (25 sites, 5 files → `field.*` / `display.percent`)

- [X] T036 [P] [US1] Migrate `lib/features/sales/presentation/capture/sale_line_editing.dart` (19 `formatQuantity` sites — the bulk of this path) to `formattersProvider`'s `field.*`/`display.*` equivalents
- [X] T037 [P] [US1] Migrate `lib/features/sales/presentation/delivery/delivery_step.dart`
- [X] T038 [P] [US1] Migrate `lib/features/sales/presentation/delivery/destination_card.dart` (also touched by T032 for its `MoneyFormatters` site — same file, sequence T032 then T038)
- [X] T039 [P] [US1] Migrate `lib/features/sales/presentation/delivery/destination_counter_row.dart`
- [X] T040 [P] [US1] Migrate `lib/features/sales/presentation/delivery/line_distribution_panel.dart` — remaining `formatPrice`/`formatRateAsPercent`/`formatRateAsPercentWithSymbol`/`parsePercentAsRate` sites across this group

### Remove the superseded paths

- [X] T041 [US1] Delete `lib/core/widgets/money_formatters.dart` and its test `test/unit/core/widgets/money_formatters_test.dart` (depends on T013–T034 all landing — verify zero remaining references first)
- [X] T042 [US1] Remove the display helpers (`formatQuantity`, `formatPrice`, `formatRateAsPercent`, `formatRateAsPercentWithSymbol`, `parsePercentAsRate`) from `lib/features/sales/domain/money.dart`, **keeping every arithmetic function** (`parseAmount`, `formatAmount`, `extendedAmount`, `countedTotal`, `expectedCash`, `difference`, `addAmounts`, `subtractAmounts`, `compareAmounts`, `isZeroAmount`, `halveAmount`) — `formatAmount(Decimal)` stays despite its name, it produces the wire string `display.currency` consumes, not a display rendering (research R6); update `test/unit/features/sales/money_test.dart` to drop the removed functions' tests only (depends on T036–T040)

### The guard (lands last, per research R8/plan.md's one hard ordering constraint)

- [X] T043 [US1] Create `test/unit/core/formatting_guard_test.dart`, modeled on `test/unit/core/layering_test.dart`'s scan pattern: fail with offending file+line when a file under `lib/` outside the allowlist imports `package:intl`, or under `lib/**/presentation/` calls `toStringAsFixed(`. Allowlist (data-model.md §3): `lib/core/formatting/**`, `lib/generated/**`, `lib/l10n/app_localizations*.dart`, `lib/main.dart`, `lib/features/sales/presentation/pos_sales_list_controller.dart`. **Depends on T041 and T042 — landing this earlier fails the suite for the whole migration (research R8).**
- [X] T044 [US1] Verify the guard actually fails: temporarily add `import 'package:intl/intl.dart';` to any `lib/features/` file, confirm `flutter test test/unit/core/formatting_guard_test.dart` goes red naming that file, then revert (quickstart.md scenario 7, SC-006)

### Re-baseline (US1's cost, paid once)

- [X] T045 [US1] Run `flutter test test/golden` post-migration to enumerate every baseline broken by the ISO-date and percent-rendering changes — this failure list *is* the inventory, per research R5
- [X] T046 [US1] Re-record with `flutter test test/golden --update-goldens && flutter test test/screenshots --update-goldens`; open at least one regenerated PNG and confirm real Archivo glyphs render, not placeholder boxes, before trusting the run (`test/golden/README.md`'s font check)
- [X] T047 [US1] Land the re-recorded baselines through CI per `test/golden/README.md` ("CI is the source of truth"); a local-only `--update-goldens` is not sufficient to close this task

### Governance

- [X] T048 [US1] Amend `.specify/memory/constitution.md` §V: land the single-formatting-surface rule that v1.11.0 drafted and withheld ("a rule requiring every screen to use a component that does not exist yet is unsatisfiable... it amends in with the spec that builds the surface"), bump the constitution version per its own Governance section (depends on T043 — the rule lands with the code that satisfies it, not before)

**Checkpoint**: US1 fully functional and independently testable — quickstart.md scenarios 1–8 all pass. `MoneyFormatters` and `money.dart`'s display helpers no longer exist (SC-008).

---

## Phase 4: User Story 2 - Uniform gaps are expressed as spacing, not spacer widgets (Priority: P2)

**Goal**: Convert `SizedBox` spacers to `Flex.spacing` wherever every gap in a `Row`/`Column` is uniform; change no rendered pixel (contracts/spacing-conversion.md).

**Independent Test**: Golden and screenshot suites pass unchanged before and after; converted files show one declared gap per Flex instead of interleaved spacer widgets (quickstart.md, "then, after US2's spacing conversion").

**Prerequisite**: US1's re-recorded baselines (T046/T047) must exist first — this story's acceptance criterion is "no baseline moves," so it needs the post-ISO baselines to compare against, not the pre-migration ones.

- [X] T049 [US2] Convert `lib/features/sales/presentation/capture/sale_line_card.dart`'s outer `Column` per contracts/spacing-conversion.md's worked example: `spacing: 8` on the `Column`, remove all 4 `SizedBox(height: 8)`, and remove the `Padding(EdgeInsets.only(top: 8))` wrapper around the conditional shortfall child (the collection-`if` case the contract calls out by name) — **after** T027, not before, since T027 touches this same file for its formatting call site
- [X] T050 [P] [US2] Convert the discount/tax `Row` and the warning icon/text `Row` in `sale_line_card.dart` (the two other convertible sites named in the spec's worked example) — same file as T049, sequence after it
- [X] T051 [P] [US2] Hand-review and convert the remaining clean candidates from research R7's scan (`brand_nav_header.dart`, `catalog_action_icons.dart`, `forgot_password_screen.dart`, `user_profiles_list_screen.dart`, `address_inline_create.dart`, `contact_inline_create.dart`, `facilities_list_screen.dart`, `facility_detail_screen.dart`, `product_detail_screen.dart`, `taxpayer_certificate_upload_dialog.dart`, `vehicles_list_screen.dart`, `facility_card.dart`, `facility_child_row.dart`, `facility_child_section.dart`, `merge_comparison_table.dart`, `merge_review_panel.dart`, and the rest of the ~40 the scan flagged) — apply the rubric by hand per file, since the scan is a floor and cannot see through collection-`if` children (research R7); record every conversion
- [X] T052 [US2] Sweep the full `lib/` tree once more by hand for uniform-gap Flexes the mechanical scan missed because of a collection-`if` child (the exact blind spot T049 exemplifies) — this is where the true total exceeds the scan's 40
- [X] T053 [US2] Record every skipped `Row`/`Column` encountered during T051/T052 with its reason (non-uniform / partial gaps / edge pad / single child) per data-model.md §4's inventory shape, so a later reader can distinguish a deliberate skip from an unexamined site (FR-028)
- [X] T054 [US2] Run `flutter test test/golden test/screenshots` after all conversions; zero baselines may change — any diff is a conversion bug to fix, not a baseline to re-record (FR-027, contracts/spacing-conversion.md's Acceptance section)

**Checkpoint**: Every uniform-gap `Row`/`Column` found declares `spacing` once; every skip is recorded; no baseline moved.

---

## Phase 5: Polish & Cross-Cutting Concerns

- [X] T055 [P] Update any developer-facing doc referencing `MoneyFormatters` or `money.dart`'s removed helpers (grep for both names across `specs/*/`, `DESIGN.md` if present) so no stale pointer survives the deletion in T041/T042
- [X] T056 Run `flutter analyze` and the full `flutter test` suite; confirm clean — no `package:intl` import outside the allowlist, no `toStringAsFixed` under `presentation/`, zero golden/screenshot diffs
- [X] T057 Walk quickstart.md scenarios 1–9 end-to-end in a running app as a final manual pass before calling the feature done

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies.
- **Foundational (Phase 2)**: Depends on Setup. **Blocks every US1 task** (T013 onward) — none of them compile without `formattersProvider`.
- **US1 (Phase 3)**: Depends on Foundational. Internally ordered: call-site migration (T013–T040) → deletion (T041–T042) → guard (T043–T044, must be last) → re-baseline (T045–T047) → governance (T048, after the guard).
- **US2 (Phase 4)**: Depends only on Foundational for compilation purposes, but its acceptance criterion (no baseline moves) requires comparing against US1's re-recorded baselines — so in practice it starts after T046/T047, not before. This is the one cross-story ordering constraint (plan.md Structure Decision), confined to `sale_line_card.dart` (T027 before T049/T050).
- **Polish (Phase 5)**: Depends on both stories being complete.

### Parallel Opportunities

- T002, T005, T006 (Foundational) are `[P]` — different files, no shared state.
- T013–T034 (Phase 3, `MoneyFormatters` migration) are all `[P]` against each other — 22 disjoint files — **except** T027, which Phase 4 also touches; T027 itself may run in parallel with the others, it just must complete before T049.
- T036–T040 (Phase 3, `money.dart` migration) are `[P]` against each other and against T013–T034 — disjoint file sets.
- T051 (Phase 4, bulk hand-conversion) is internally parallelizable per file; listed as one task here because the file list is long and each conversion is small, but a team could split it further.

### Within Each User Story

- Foundational tests (T003, T007–T010) are written to fail against stubs first, per the Tests note at the top.
- Migration before deletion before guard before governance (US1's one hard sequencing rule — research R8).
- US2 has no internal test-first step: its correctness criterion is the *existing* golden/screenshot suites passing unchanged (contracts/spacing-conversion.md), not new tests.

---

## Parallel Example: User Story 1 call-site migration

```bash
# After Foundational (T002-T012) completes, launch a batch of independent migrations:
Task: "Migrate lib/core/widgets/date_range_filter_chip.dart (2 sites)"
Task: "Migrate lib/features/sales/presentation/cash_sessions_screen.dart (5 sites)"
Task: "Migrate lib/features/sales/presentation/capture/sale_totals_bar.dart (4 sites)"
Task: "Migrate lib/features/pricing/presentation/pricing_screen.dart (3 sites)"
# ... any subset of T013-T040 not sharing a file can run together.
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Phase 1 (T001) — trivial, confirms the starting point is clean.
2. Phase 2 (T002–T012) — build and document the surface; nothing user-visible changes yet.
3. Phase 3 (T013–T048) — migrate, delete, guard, re-baseline, amend the constitution.
4. **STOP and VALIDATE**: run quickstart.md scenarios 1–8. This alone is the feature's whole reason for existing (spec.md's "Why this priority" for US1) and is shippable on its own.

### Incremental Delivery

1. Setup + Foundational → surface exists, nothing migrated, app behavior unchanged.
2. US1 → every screen reads consistently; ISO dates; deployment-configurable; guarded against regression. **Ship here if US2 isn't ready.**
3. US2 → mechanical cleanup, zero user-visible change. Ship whenever convenient — it has no dependency on anything shipping alongside it apart from the one-file sequencing noted above.

### Notes

- [P] tasks touch different files with no shared state.
- Commit after each task or logical group (e.g., one commit per file-group in T013–T040, one commit per Foundational task).
- The guard (T043) is a hard gate, not a suggestion: if any call site was missed, this test is what catches it — do not skip ahead of it.
- US2's 40-candidate estimate (research R7) is a floor, not a target — T052 exists specifically because the mechanical scan cannot see through collection-`if` children, so treat "the scan found 40" as a lower bound on the review, not the definition of done.
