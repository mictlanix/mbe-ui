# Implementation Plan: Pick Up the Real-PAC Simulator (mbe-api spec 040)

**Branch**: `076-pac-simulator-040` | **Date**: 2026-11-19 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/076-pac-simulator-040/spec.md`

## Summary

mbe-api spec 040 (PR #348, merged at 1713acd) moved the PAC simulator into the CFDI library. The app's screens never call the simulator; only the live test does. Research found that the live test already sets its outcomes in the order 040 requires (R1). The work is therefore small:

1. Regenerate the API client, which drops `next_stamp` and `next_cancellation` (R2).
2. In the live test, probe the simulator at the start of each of the three simulated groups and skip cleanly when it is off (R4). Assert the new provider RFC `SIM010101SI0` (R5).
3. Show a 72-hour notice, instead of "check back in a few minutes", after a refresh that leaves a cancellation pending (R3). This is one new string in both languages.
4. Update the offline tests' simulated stamp to the new RFC, keep one test with the old RFC, and pin the "failed after 72 hours" state with a widget test (R5, R6).

## Technical Context

**Language/Version**: Dart `^3.10.3`, Flutter 3.47.7 stable (unchanged)

**Primary Dependencies**:
- The regenerated `mbe_api_client`, with `PacSimulatorApi` used by the live test only.
- Riverpod 3, freezed.
- No new packages.

**Storage**: N/A (online-only, §VII)

**Testing**:
- `flutter_test` + `mocktail`, with the existing `fiscal_document_fixtures.dart` and the detail-screen harness.
- The live test `test/integration/fiscal_documents_live_test.dart` runs behind `MBE_WRITE=true` on dev. Ask the user first, because it stamps documents and spends folios.

**Target Platform**: web and desktop first, compact tier (§VI). No layout changes.

**Project Type**: Flutter client application, feature-first layered

**Performance Goals**: none new. The probe adds one GET per simulated live group.

**Constraints**:
- Every string goes in both `.arb` files.
- Format only the changed files.
- Never hand-edit generated code.
- Decide the simulated badge by `stamp.simulated`, never by the RFC.

**Scale/Scope**:

| | Files |
|---|---|
| **Regenerated** | `lib/generated/openapi/**` (via `tool/generate_api_client.sh`) |
| **Edited source (3)** | `lib/features/invoicing/presentation/fiscal_document_detail_screen.dart` (the notice's text by status); `lib/l10n/app_es.arb`, `lib/l10n/app_en.arb` (one key), plus the generated `app_localizations*.dart` |
| **Edited tests (4)** | `test/integration/fiscal_documents_live_test.dart` (probe, RFC assertions, header note on ordering); `test/unit/features/invoicing/fiscal_document_fixtures.dart` and `fiscal_document_repository_impl_test.dart` (new RFC); `test/widget/features/invoicing/fiscal_document_detail_screen_test.dart` (72-hour notice in es/en and at the largest text level, failed-after-72h state, both RFCs show the badge) |

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

These verdicts are against **v1.15.0**.

| Principle | Verdict | How |
|---|---|---|
| **I. Feature-first layering** | Pass | The one source change is in `features/invoicing/presentation`. |
| **II. Riverpod** | Pass | No new state. The notice still uses the screen's local `_stillInProcess` flag and reads the document's status. |
| **III. Contract-driven API** | Pass | **Codegen**: re-run because the contract changed (R2). **Error text**: no new reachable codes. The simulator's refusals are test-only, and the probe keys on `request.route_not_found` by code, never by prose (R4, R7). **Upstream**: nothing to file. The "not received by SAT" variant of `failed` is noted in the spec's assumptions as a possible request, not a dependency. |
| **IV. Deny-by-default RBAC** | Pass | No change. The notice appears only after a refresh, which already requires 23 update. |
| **V. Material 3 / design system** | Pass | The same `FiscalDocumentNotice`, only with a different string. The longer Spanish sentence wraps inside the notice. It is checked at the largest text level (1.3) and at a compact width in the widget test (tasks T011, quickstart §2). |
| **VI. List and record-surface rules** | Pass | No list, surface, control band or action changes. |
| **VII. Online-only, server-rendered documents** | Pass | The PDF and its simulated banner stay the server's. |
| **Quality gates** | Pass | Unit, widget and live checks are in quickstart §2 to §4. `flutter analyze` must be clean. |

**Post-design re-check** (after Phase 1): unchanged. No deviation needs Complexity Tracking.

## Project Structure

### Documentation (this feature)

```text
specs/076-pac-simulator-040/
├── spec.md
├── plan.md              # This file
├── research.md          # R1–R7
├── data-model.md        # field changes, simulator outcome rules, new l10n key
├── quickstart.md        # contract, offline, live on/off checks
├── contracts/
│   └── ui-and-tests.md  # C1–C5
├── checklists/
│   └── requirements.md
└── tasks.md             # /speckit-tasks (not created here)
```

### Source Code (repository root)

```text
lib/
├── generated/openapi/                      # regenerated
├── features/invoicing/presentation/
│   └── fiscal_document_detail_screen.dart  # notice text by status (R3)
└── l10n/app_{es,en}.arb                    # fiscalDocumentCancellationStillPending
test/
├── integration/fiscal_documents_live_test.dart          # probe + RFC (R4, R5)
├── unit/features/invoicing/{fiscal_document_fixtures,fiscal_document_repository_impl_test}.dart
└── widget/features/invoicing/fiscal_document_detail_screen_test.dart
```

**Structure Decision**: The existing feature-first layout. Everything stays in `features/invoicing`, its tests and the generated client.

## Complexity Tracking

None.
