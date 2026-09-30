# Implementation Plan: Show Timestamps as the Local Times They Are

**Branch**: `043-wall-clock-datetimes` | **Date**: 2026-09-26 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/043-wall-clock-datetimes/spec.md`, resolving mictlanix/mbe-ui#176.

## Summary

Every timestamp read from mbe-api renders six hours ahead, because the generated client's `Iso8601DateTimeSerializer` parses the API's offset-less wall-clock strings as local and then converts them to UTC. The fix replaces that one serializer with a `WallClockDateTimeSerializer` that reads offset-less values unchanged and honors an offset if one ever appears, and writes a value's own fields with no suffix. It is registered through the `Serializers` argument every generated API class already accepts, so no generated file changes and regeneration cannot undo it.

In the same change, PR #180's outgoing compensation (`.toUtc()` in `wireDate`/`wireDateEnd`) is removed. Under the new writing rule it would serialize as `…T06:00:00.000` and silently cost the register the first six hours of its day. A source-scan guard keeps any data-access path from reaching for the old serializers again.

## Technical Context

**Language/Version**: Dart `^3.10.3`, Flutter 3.44.2 (stable)

**Primary Dependencies**: `built_value` 8.13.0 (resolved) and `built_collection` 5.1.1 via the generated `mbe_api_client`; `dio` 5.9.2; `intl` 0.20.2 for display, untouched. No new dependency.

**Storage**: None. Online-only (constitution §VII).

**Testing**: `flutter_test` and `mocktail`. Repository tests drive the real generated client through a stubbed dio adapter, which is where every affected fixture lives. `integration_test` flows run against a live mbe-api.

**Target Platform**: Web first in development (Chrome), plus desktop and mobile. `DateTime` parsing behaves the same on dart2js and the VM for everything this feature relies on (research R9).

**Project Type**: Flutter client application, feature-first layered.

**Performance Goals**: None specific. One `DateTime.parse` per field, as today.

**Constraints**: No hand edits under `lib/generated/` (constitution §III). The viewer's timezone is assumed to be the facility's (spec Assumptions). The test suite must pass in any host timezone, including DST-observing ones (FR-010). There is no CI workflow in this repo, so that is proven by explicit `TZ=` runs (research R13).

**Scale/Scope**:

- 1 new source file: the serializer and `appSerializers`, in `lib/core/network/`.
- 45 references to `standardSerializers` switch to `appSerializers`: 33 in 30 `lib/` files, 12 in 4 `test/` files.
- 2 helpers lose their `.toUtc()`: `wireDate`, `wireDateEnd`.
- 27 offset-bearing fixtures rewritten across 9 unit test files (research R6), plus the expectations PR #180 made computed, which go back to plain literals (see *Test expectations* below).
- 2 new test files: the rule and the guard. 1 extended: cash session staleness.
- 2 documents: a PATCH to the constitution (1.13.0 → 1.13.1) and the matching DESIGN.md edit (research R11).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Verdict | How |
|---|---|---|
| **I. Feature-first layering** | Pass | The serializer is shared infrastructure every feature's `data/` layer consumes, so it lives in `lib/core/network/` beside `dio_client.dart`. No `presentation/` or `domain/` file changes except tests. |
| **II. Riverpod for DI** | Pass | Repositories stay providers, unchanged. `appSerializers` is a top-level value, like the generated `standardSerializers` it replaces. The principle asks for providers where tests substitute fakes. No test should substitute this one: the guard exists to make every test use the real conversion. |
| **III. Contract-driven API** | Pass | No generated file is edited; the override enters through the generated constructors' own `Serializers` argument. Codegen is already current against the #228 schema (`db64d5b`). No mbe-api change is needed: #228 shipped. DTO-to-`freezed` mapping is unchanged. |
| **IV. Deny-by-default RBAC** | Not affected | No route or action changes. |
| **V. Material 3 design system** | Pass | No UI change. Displays still go through `formattersProvider` (spec 028). |
| **VI. Desktop/web-first layout** | Not affected | No layout change. |
| **VII. Online-only** | Pass | No storage or caching. |
| **Stack** | Pass | `dio` only, no new dependency. |
| **Quality gates** | Pass | Unit tests for the rule, the guard and staleness; repository tests updated; live checks in [quickstart.md](./quickstart.md). |

**One wording conflict, resolved in this feature.** Constitution §III, line 280, and DESIGN.md, line 201, tell authors to deserialize the upload-bypass response with `standardSerializers.deserialize`. After this feature the guard fails the build on exactly that. The fix is a PATCH amendment naming `appSerializers`, DESIGN.md first as governance requires. It changes no principle.

**Post-design re-check**: unchanged. Phase 1 introduced no new file outside `lib/core/network/`, no provider, no dependency. The wording amendment above is the only constitution touch.

## Project Structure

### Documentation (this feature)

```text
specs/043-wall-clock-datetimes/
├── spec.md                  # Feature specification
├── plan.md                  # This file
├── research.md              # Phase 0: 13 decisions, each checked against a probe or the live API
├── data-model.md            # Phase 1: the business timestamp, its three forms, the scope boundary
├── contracts/
│   └── wire-datetime.md     # Phase 1: the read and write tables, the shared Serializers, the guard
├── quickstart.md            # Phase 1: validation, fastest to live
├── checklists/
│   └── requirements.md      # Spec quality checklist
└── tasks.md                 # Phase 2 output (/speckit-tasks, not created here)
```

### Source Code (repository root)

```text
lib/
├── core/network/
│   └── api_serializers.dart                 # NEW: WallClockDateTimeSerializer + appSerializers
├── features/
│   ├── auth/data/*_repository_impl.dart          # standardSerializers → appSerializers
│   ├── catalog/data/*_repository_impl.dart       # same, incl. the two upload-bypass deserialize calls
│   ├── pricing/data/*_repository_impl.dart       # same
│   └── sales/data/
│       ├── *_repository_impl.dart                # same
│       └── sales_order_repository_impl.dart      # also: wireDate/wireDateEnd lose .toUtc()
└── generated/openapi/                       # UNCHANGED (constitution §III)

test/
├── unit/core/network/
│   ├── wall_clock_date_time_serializer_test.dart  # NEW: the contract's tables, DST row, round trip
│   └── serializers_guard_test.dart                # NEW: source scan (research R7)
├── unit/features/sales/cash_session_status_test.dart  # EXTEND: evening start, through the real mapping
├── unit/features/**/                        # 9 files: offset-less fixtures, local expectations
├── unit/features/sales/sales_order_list_open_test.dart  # repurpose the "local is refused" guard (R5)
├── widget/features/sales/open_sales_selector_test.dart  # _startOfToday expectation
└── integration/*_flow_test.dart             # 3 files: standardSerializers → appSerializers

.specify/memory/constitution.md              # PATCH 1.13.1: §III names appSerializers
DESIGN.md                                    # the matching wording, edited first
```

**Structure Decision**: The existing feature-first layout. The only new source file sits in the shared `lib/core/network/` because every feature's data layer depends on it. Everything else is a change to an existing file.

## Implementation notes for tasks

These are the ordering and review risks the task list must respect.

**The swap and the helper change are one atomic step.** Switching to `appSerializers` without removing `.toUtc()` makes every date filter start at 06:00 local. Removing `.toUtc()` without the swap makes the old serializer throw `ArgumentError` on the now-local values. Neither half is safe alone, so they must land in the same commit, with the filter-query tests updated alongside (research R4).

**Test expectations.** PR #180 replaced literals like `'2026-08-10T00:00:00.000Z'` with computed values such as `DateTime(2026, 8, 10).toUtc().toIso8601String()`, because the stopgap's wire value depended on the host zone. Under the new rule the wire value no longer depends on the host at all, so those expectations become plain literals again, `'2026-08-10T00:00:00.000'`. A literal is now the stronger assertion: it states the exact string mbe-api must receive. Affected: `sales_order_list_open_test.dart`, `sales_order_list_orders_test.dart`, `sales_order_update_header_test.dart`, `open_sales_selector_test.dart`.

**Order of work.**

1. The serializer, `appSerializers`, and the rule's unit test. Independent of everything else.
2. The guard test. It fails at first, listing all 34 files. That list is the checklist for step 3.
3. The atomic step: every `standardSerializers` switch, the two helpers, and the filter-query expectations. The guard passes when this is done.
4. Fixture migration in the 9 unit test files, and the `listOpen` guard repurpose.
5. The staleness test through the real mapping.
6. DESIGN.md, then the constitution PATCH.
7. The three-timezone suite run, the live checks, the date-only canary (FR-005), then the regeneration survival check (FR-007).

Steps 4 and 5 can run in parallel with each other once 3 is in. Step 6 is independent and can land any time.

**Not planned, deliberately**: renaming `wireDate`/`wireDateEnd` (research R4), a lint rule instead of the scan (R7), any change to the date-only `Date` fields (data-model), any data backfill (spec Assumptions).

## Complexity Tracking

No constitution violations. Nothing to justify.
