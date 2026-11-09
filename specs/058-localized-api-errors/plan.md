# Implementation Plan: Localized API Messages from Error Codes

**Branch**: `058-localized-api-errors` | **Date**: 2026-11-09 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/058-localized-api-errors/spec.md`

## Summary

The app keeps the server's `code`, `params` and parts on every `AppError` and turns them into es/en text when it shows the error. Parsing stays in the one place every request already passes through, `mapDioException`. It reads the code as a string first and maps it to the generated `ErrorCode` enum, so a code newer than the app is kept as unknown rather than throwing (research R2). Rendering goes through one function, `localizeProblem`, which returns `null` for anything it cannot render (R4), and one extension, `userMessage`, which falls back to today's English text.

`ErrorBanner` shows the localized text instead of the generic headline plus English line (R5). The form controllers stop storing English text and keep the `AppError` itself. A new shared `FormErrorBanner` renders the form's own headline plus the localized reason, replacing about 25 hand-built copies (R6).

Special paths move to codes, with today's checks kept as fallbacks:
- password change and credit hold, recognized centrally in `mapDioException` (R8);
- the busy drawer and busy cashier on opening a session (R8);
- "nothing to return" on opening a refund (R8).

The confirm refusals read both the current dict and the announced phase-3 parts (R9).

The scope is 96 codes, 9 validation types and 42 record nouns. It was measured by following a call graph from the 182 routes the app calls (R1); the list is in [contracts/message-catalog.md](contracts/message-catalog.md).

## Technical Context

**Language/Version**: Dart 3.x / Flutter (stable, as pinned in `pubspec.yaml`)

**Primary Dependencies**: `flutter_localizations` + `intl` (ARB, gen-l10n), `freezed` (`AppError`), `flutter_riverpod` (`formattersProvider`), `dio` (interceptor), generated `mbe_api_client` (`ErrorCode` enum, `appSerializers`)

**Storage**: N/A

**Testing**: `flutter test`: unit (`test/unit/`), widget (`test/widget/`), golden (`test/golden/`), and the live quickstart checks against mbe_dev

**Target Platform**: Web, macOS, iOS, Android (same build)

**Project Type**: Flutter client app (feature-first layers, `lib/core` + `lib/features/*`)

**Performance Goals**: N/A. Rendering a message is a switch plus formatting, at display time only.

**Constraints**:
- No server change; the contract is mbe-api spec 036 as shipped.
- An unknown code must never throw.
- The l10n parity test stays green.
- Format only the files the change touches; never run `dart format` repo-wide.

**Scale/Scope**:
- 96 codes, 9 validation types and 42 record nouns (contracts/message-catalog.md), which is about 200 new ARB entries per locale, counting the noun gender keys and list helpers;
- 24 form controllers, with 442 `errorDetail` references across 55 files;
- 62 `ErrorBanner` call sites;
- 7 non-form `serverMessage` displays.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|---|---|---|
| I. Feature-first layers | PASS | The problem entity, the localizer and the message text live in `lib/core/errors/`, and the shared widget in `lib/core/widgets/`. Features consume them and add no layer. |
| II. Riverpod | PASS | Formatters come from `formattersProvider`. `ErrorBanner` becomes a `ConsumerWidget` to read them (R5). |
| III. Contract-driven API | PASS, see note | Errors still map to the shared `AppError` variants and render through the shared widget. This feature removes 25 ad-hoc form copies. The problem body is read from raw JSON, as `_detailFrom` does today, rather than through the generated `Problem` deserializer. That deserializer throws on an unknown `ErrorCode` and types `params` as opaque `JsonObject`s (R2). This is a mapping step into a domain entity, not a hand-written DTO, and the generated `ErrorCode` stays the source of the code list. |
| IV. Deny-by-default RBAC | PASS | No gate changes. The `auth.forbidden` message is generic; the grants in `required` are not listed, because the app has no localized privilege names (R4). |
| V. Material 3 design system | PASS | Same banner look. `FormErrorBanner` is the same `ErrorBanner` with a headline plus a reason. |
| VI. Layout | PASS | No layout change. |
| VII. Online-only | PASS | No offline concern. |
| Quality gates | PASS | Unit tests cover parsing, the localizer for every in-scope code, and the fallbacks. Widget tests cover the banner and form banner, golden refresh, and the parity test. The live checks are in quickstart. No codegen re-run is needed: the client was regenerated in `efcec8f`. |

**Re-check after Phase 1**: PASS. The design adds one domain entity (`ApiProblem`), one function, one extension and one widget, all in `core`. The external dependency, an mbe-api issue for phase-3 part codes, is recorded in Complexity Tracking.

## Project Structure

### Documentation (this feature)

```text
specs/058-localized-api-errors/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── error-mapping.md      # body → ApiProblem → AppError; fallbacks; special paths
│   ├── display.md            # userMessage, ErrorBanner, FormErrorBanner, form state
│   ├── message-catalog.md    # every in-scope code / validation type / noun → ARB key, params, en, es
│   └── code-scope.tsv        # R1 evidence: every code, validation type and resource name, IN/OUT, example routes
└── tasks.md                  # /speckit-tasks
```

### Source Code (repository root)

```text
lib/core/errors/
├── app_error.dart              # + ApiProblem? problem on validation/auth/notFound/server/creditHold
├── api_problem.dart            # NEW: ApiProblem, ApiProblemPart, typed param accessors
├── localize_problem.dart       # NEW: localizeProblem, localizeValidationType, serverFieldValue, resourceNoun, userMessage extension
lib/core/network/
├── auth_interceptor.dart       # mapDioException parses code/params/errors; password change + credit codes; logs
lib/core/widgets/
├── error_banner.dart           # ConsumerWidget; localized text replaces headline + English
├── form_error_banner.dart      # NEW: headline + localized reason (replaces ~25 hand-built copies)
lib/l10n/app_en.arb, app_es.arb # + apiError*, apiValidation*, apiResource* entries
lib/features/**/presentation/*_form_controller.dart, *_controller.dart   # errorDetail → errorCause (AppError?)
lib/features/**/presentation/*_form.dart, *_screen.dart, *_dialog.dart   # FormErrorBanner
lib/features/sales/data/sales_order_repository_impl.dart   # _toSalesOrderError / _toConfirmError by code, both shapes
lib/features/sales/presentation/open_session_form_controller.dart        # busy codes, re-fetch as fallback
lib/features/sales/presentation/refunds/refund_open_or_resume.dart       # nothing-to-return by code; no English append
lib/features/sales/presentation/refunds/refund_detail_screen.dart        # line errors via userMessage
lib/features/sales/presentation/delivery/destination_card.dart          # userMessage inside its template
lib/features/pricing/presentation/{price_cell,pricing_grid_controller}.dart   # RejectedEdit.cause; tooltip via userMessage

test/unit/core/errors/          # api_problem_test, localize_problem_test (every in-scope code, en + es), catalog_coverage_test
test/unit/core/network/         # auth_interceptor_test: new groups; existing groups unchanged
test/widget/core/widgets/       # error_banner_test (+ProviderScope), form_error_banner_test
test/golden/                    # error banner localized case
```

**Structure Decision**: everything shared lives in `lib/core/errors` and `lib/core/widgets`, next to the existing `AppError` and `ErrorBanner`. Feature files only change how they store and show an error. The structure is unchanged.

## Complexity Tracking

| Item | Why needed | Simpler alternative rejected because |
|---|---|---|
| Problem bodies read from raw JSON instead of the generated `Problem` deserializer (§III note) | The generated deserializer throws on an `ErrorCode` the client doesn't know (a newer server), and it types `params` as `JsonObject`. | Using it would make every new server code crash error handling, which breaks FR-002. |
| External dependency: an mbe-api issue for phase-3 part codes (R9) | Phase 3 will move stock and zero-price lines into `errors[]` items that carry only `code` + `params`, and their codes are not defined yet. Without them published, or without a per-part `detail`, the app can read the new shape but cannot name the reason for an unknown part. | Guessing codes now would be wrong. Not reading the new shape would break the POS on the day phase 3 ships. The issue is drafted in research R9 and filed with the user's go-ahead. |
