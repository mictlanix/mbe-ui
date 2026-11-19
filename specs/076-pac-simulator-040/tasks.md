---
description: "Task list for 076-pac-simulator-040"
---

# Tasks: Pick Up the Real-PAC Simulator (mbe-api spec 040)

**Input**: Design documents from `specs/076-pac-simulator-040/`

**Prerequisites**: plan.md, spec.md, research.md (R1–R7), data-model.md, contracts/ui-and-tests.md (C1–C5), quickstart.md

**Tests**: The constitution's quality gates require tests, and most of this feature is test code. Test tasks sit inside each story.

**Organization**: Grouped by user story (US1–US3, spec.md).
- **P1 (the MVP)**: US1, the live tests follow the new simulator.
- **P2**: US2, the 72-hour notice.
- **P3**: US3, documents stamped before the switch.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: parallelizable (different files, no dependency on an incomplete task)
- **[Story]**: US1 live tests · US2 72-hour notice · US3 old and new simulated stamps

## Cross-story notes

- **Shared file.** `test/integration/fiscal_documents_live_test.dart` is edited by T004 to T008. Do those sequentially.
- **Shared file.** `test/widget/features/invoicing/fiscal_document_detail_screen_test.dart` is edited by T010 (US2), T011 (US2) and T013 (US3). Do those sequentially.
- **Live writes.** T014 stamps real documents on dev and spends folios. **Ask the user before running it.**
- **Generated code.** Regenerating the API client is T001 only. After editing the `.arb` files run `flutter gen-l10n`. Never hand-edit `lib/generated/openapi/**` or `lib/l10n/app_localizations*.dart`.
- **Formatting.** Run `dart format` on the changed files only, never repo-wide.
- **Where the simulator is touched.** Only the three live groups call it (072 at line ~559, 073 at ~866, 074 at ~1044). No screen does. The groups already set outcomes in the order 040 requires (research R1), so existing steps stay as they are.

---

## Phase 1: Setup

- [X] T001 Regenerate the API client against a local mbe-api on `main` at 1713acd or later: start it, then run `tool/generate_api_client.sh`. Afterwards run `grep -rn "next_stamp\|next_cancellation\|nextStamp\|nextCancellation" lib test integration_test`. It must find nothing (SC-002). List any change outside `PacSimulationResponse` in the commit message and the PR. Commit the result on its own as `chore(api): regenerate client for mbe-api spec 040`. **Done 2026-11-19:** main already carried the regenerated client (569f5b5d, merged into this branch as 59cb565d). A fresh regeneration from mbe-api's OpenAPI (dumped from its checkout, no server) produced no diff, and the grep finds nothing. Nothing to commit.

**Checkpoint**: the client matches mbe-api 040. Nothing else in the app changes yet.

---

## Phase 2: Foundational

None. The stories share no code.

---

## Phase 3: User Story 1 - The live PAC tests run again against the new simulator (Priority: P1) 🎯 MVP

**Goal**: The 072, 073 and 074 live groups follow the new simulator's rules, expect the new provider RFC, and skip cleanly when the simulator is off.

**Independent Test**: Quickstart §3 (simulator on) passes with no fewer steps than before. Quickstart §4 (simulator off) reports the three groups skipped and none failed.

- [X] T002 [US1] In `test/integration/fiscal_documents_live_test.dart`, add one helper next to `_Step` that probes the simulator (contract C4): call `GET /pac-simulator/fiscal-documents/0` through `api.PacSimulatorApi(dio, appSerializers)`. If the answer is a 404 whose problem code is `request.route_not_found`, return `false` (simulator off). Any other `DioException` that carries a different code (for example `fiscal_document.not_found`) or a 2xx means the simulator is on: return `true`. Anything else (network, 401, 5xx) rethrows. Read the code the way the file's other steps do, from `AppError.problem?.codeName` after the repository layer's mapping, or from the response body if the generated API throws a raw `DioException`. Check which one it is before writing the helper: `PacSimulatorApi` is called on the test's `dio` directly, without a repository, so look at how the file's existing `outcome()` and `receiver()` failures surface, and at `lib/core/errors/app_error.dart` for the mapped form. Never match the server's prose.
- [X] T003 [US1] In `test/integration/fiscal_documents_live_test.dart`, extend the file's header comment (the `Spec 072` / `073` / `074` paragraphs near lines 50 to 75) with the 040 ordering rules (contract C5): a stamp outcome is set after the last seal and never while the document is stamping; a cancellation outcome is set after the stamp; after `not_cancellable` a successful cancel needs a new document (every later cancel of that document answers 409); simulated stamps carry `SIM010101SI0`; the simulated groups skip when the simulator is off.
- [X] T004 [US1] In `test/integration/fiscal_documents_live_test.dart`, at the top of the 072 group (`'Stamp, cancel and refresh against the simulated PAC (spec 072)'`), after the `step` and `sim` setup and before any document is sealed, call the T002 helper. When it returns `false`, call `markTestSkipped('the PAC simulator is off on this server (PAC_PROVIDER is not simulated)')` and return.
- [X] T005 [US1] In the same file, do the same at the top of the 073 group (`'Credit note against the simulated PAC (spec 073)'`).
- [X] T006 [US1] In the same file, do the same at the top of the 074 group (`'Payment receipt against the simulated PAC (spec 074)'`).
- [X] T007 [US1] In the same file, add `expect(a.stamp!.providerRfc, 'SIM010101SI0')` next to the existing `simulated` assertion of step `A: seal, stamp: issued, with a simulated stamp` (072), and the same assertion on the stamp in step `stamp: issued, with a simulated stamp` of the 073 group and of the 074 group. Use a `reason:` that names mbe-api spec 040.
- [X] T008 [US1] In the same file, confirm by reading each of the three groups that no step reads a field of the simulator's response, sets a stamp outcome on a document that was resealed after it was chosen, or sets a cancellation outcome before `stamp`. This is research R1. If one does, fix it. Otherwise add no code.

**Checkpoint**: US1 is complete once T014 and T015 pass. The offline compile (`flutter analyze test/integration/fiscal_documents_live_test.dart`) is clean before then.

---

## Phase 4: User Story 2 - A billing user waiting on a pending cancellation is told how long it can take (Priority: P2)

**Goal**: After a refresh that leaves a cancellation pending, the notice says SAT and the receiver can take up to 72 hours. A document still stamping keeps the "few minutes" notice.

**Independent Test**: The widget tests of T010 and T011 pass in es and en. Quickstart §2.

- [X] T009 [US2] Add the key `fiscalDocumentCancellationStillPending` to both ARB files, right after `fiscalDocumentStillInProcess`, then run `flutter gen-l10n`:
  - `lib/l10n/app_es.arb`: `"fiscalDocumentCancellationStillPending": "La cancelación sigue en proceso. El SAT y el receptor pueden tardar hasta 72 horas en resolverla; mientras tanto el documento sigue vigente."`
  - `lib/l10n/app_en.arb`: `"fiscalDocumentCancellationStillPending": "The cancellation is still in process. SAT and the receiver can take up to 72 hours to settle it; the document stays valid meanwhile."`, with `"@fiscalDocumentCancellationStillPending": {"description": "spec 076: info notice after a refresh that left a cancellation pending"}`.
- [X] T010 [US2] In `lib/features/invoicing/presentation/fiscal_document_detail_screen.dart`, at the `FiscalDocumentNotice` with key `fiscal_document_still_in_process` (line ~696), choose the message by the document's status (contract C1, research R3): `_document.status == FiscalDocumentStatus.cancellationPending` gives `l10n.fiscalDocumentCancellationStillPending`, and anything else gives `l10n.fiscalDocumentStillInProcess`. Keep the key, the `onDismissed` handler and the `_stillInProcess` flag as they are. Read the status from `_document`, because the screen shows the refreshed document.
- [X] T011 [US2] In `test/widget/features/invoicing/fiscal_document_detail_screen_test.dart`, next to the test at line ~582 (`'a refresh that leaves the document in process is a note…'`), add two tests using the existing `pending()` helper (line ~441) and `access(update: true)`:
  1. Refreshing a `pending()` document that stays pending shows `fiscal_document_still_in_process` with `l10n.fiscalDocumentCancellationStillPending` and no `l10n.fiscalDocumentStillInProcess`; no refusal is shown; the notice can be dismissed.
  2. The same in English: load `AppLocalizations` for `Locale('en')` for the expectation and pump the screen with the English locale, as `test/widget/features/invoicing/receipt_detail_test.dart` does (lines ~584 to ~594: `AppLocalizations.delegate.load(const Locale('en'))` and `locale: const Locale('en')`). The English text mentions "72 hours".
  3. **Largest text level** (constitution §V, plan Constitution Check V). Refresh a `pending()` document at the largest level, `MediaQuery(data: MediaQueryData(textScaler: TextScaler.linear(1.3)))`, the way `test/widget/features/sales/sale_line_symmetry_test.dart` does (lines ~113 to ~122), with the default 1400×1000 surface. `pumpDetail` (line ~107) builds its own `MaterialApp` and has no text-scale input, so give it an optional `TextScaler? textScaler` parameter that wraps the app's `builder` child in that `MediaQuery`. Existing callers stay unchanged. Then refresh again at a compact surface (`surface: const Size(400, 900)`). In both cases the notice shows the full Spanish text and `tester.takeException()` is null, so there is no overflow.
  Keep the existing stamping test unchanged: it already proves that a stamping document still shows `fiscalDocumentStillInProcess`.

**Checkpoint**: US2 is independently testable with `flutter test test/widget/features/invoicing/fiscal_document_detail_screen_test.dart`.

---

## Phase 5: User Story 3 - Documents stamped before the switch still read correctly (Priority: P3)

**Goal**: Both provider RFCs show the simulated badge, and the 72-hour "failed" close reads correctly. No screen code changes.

**Independent Test**: Quickstart §2. The unit and widget suites pass.

- [X] T012 [P] [US3] In `test/unit/features/invoicing/fiscal_document_fixtures.dart`, change the default `providerRfc` of `aStamp` (line ~161) from `'SIM010101SIM'` to `'SIM010101SI0'`. In `test/unit/features/invoicing/fiscal_document_repository_impl_test.dart`, change the stamp JSON (line ~692) and the expectation (line ~742) the same way. Then run both suites and fix any other expectation of the old value that the change breaks.
- [X] T013 [US3] In `test/widget/features/invoicing/fiscal_document_detail_screen_test.dart`, update the two expectations of `'SIM010101SIM'` (lines ~959 and ~1008) to follow the new default, and add two tests (contracts C3 and C2):
  1. A document with `aStamp(simulated: true, providerRfc: 'SIM010101SIM')` (a migrated one) shows `fiscal_document_simulated_badge` and the text `SIM010101SIM`. A document with the new default shows the badge and `SIM010101SI0`.
  2. An `issued` document whose newest cancellation is `aCancellation(outcome: CancellationOutcome.failed)` shows the issued state, a history row with `l10n.fiscalDocumentCancellationOutcomeFailed`, and the cancel button `fiscal_document_cancel_cfdi` for a user with cancel rights (the same key the file's existing cancel tests use, lines ~556 and ~647).

**Checkpoint**: US3 is independently testable with `flutter test test/unit/features/invoicing test/widget/features/invoicing`.

---

## Phase 6: Polish & cross-cutting concerns

- [ ] T014 Run the live test with the simulator on, **after asking the user** (it stamps documents and spends folios on dev): `flutter test test/integration/fiscal_documents_live_test.dart --dart-define-from-file=.env --dart-define=MBE_WRITE=true` (see the memory note on POS integration-test invocation for the product pattern). Expect the 072, 073 and 074 groups to pass with no fewer steps than before and every simulated stamp to carry `SIM010101SI0` (SC-001). Report the PASS/FAIL list. **Run 2026-11-19 (local dev API, simulator on):** the Facturas, 073 and 074 groups pass in full, and every simulated stamp carried `SIM010101SI0`. In 072, 10 of 11 steps pass. `B: cancel again, the receiver accepts` fails because mbe-api closes a second cancellation, made after the receiver rejected the first, as `rejected` at once (document #63952, `answered_at` null, then 409 `nothing_to_refresh`). That is a spec 040 regression upstream: the step passed before 040. It is reported as mictlanix/mbe-api#349. The step stays as written, and this task stays open until the fix ships and the step passes. **Re-run tracked in #295.**
- [ ] T015 Run the live test against a server whose `PAC_PROVIDER` is not `simulated` (for example a local mbe-api with `PAC_PROVIDER=none`). Expect the three groups to report skipped with the "simulator is off" reason, none failing, and no document sealed (SC-003). If no such server can be started, say so and leave this task open, because the probe's 404 code is then verified only by reading mbe-api's source. **Deferred 2026-11-19 to #292** (no simulator-off server available).
- [X] T016 Run `dart format` on only the changed Dart files, then `flutter analyze`, which must be clean.
- [X] T017 Run the whole offline suite with `flutter test`. It must pass (SC-005). If a failure is outside invoicing, check whether the regenerated client (T001) caused it before touching anything. **Done 2026-11-19:** 6472 passed. The only failures are outside this feature and environmental: `test/integration/auth_flow_test.dart` (needs a live server on 127.0.0.1:8000) and, in one of two runs, the known `test/golden/core_widgets_golden_test.dart` gap (ui#209), which also fails on a clean tree. Pre-existing, not fixed: at text level 1.3 on desktop the lines table's description cell overflows its 44 px row by 3 px (`fiscal_document_detail_screen.dart` ~1273); It was fixed afterwards in 9b84a583: the cell tightens its line height only when the two lines don't fit, a test covers all four text levels, and T011's text-size test uses a document with lines again.
- [ ] T018 Walk quickstart §5 on dev by hand if the user wants it: an old and a new simulated invoice, and a pending cancellation refreshed once. Record what was and wasn't done in the PR. **Deferred 2026-11-19 to #293** (manual checks).
- [X] T019 Open the PR with `Closes #288` and, under "Roadmap", `Part of mictlanix/mbe-roadmap#52`, `#54` and `#56` (all closed by earlier specs, so "Part of"). Mention that the 72-hour notice is the only visible change. Under "Not verified", list spec US3 scenario 3 (cancelling a document stamped by the old simulator goes pending) unless T018 walked it. That outcome is the server's, and no automated test can create an old-simulator document.

---

## Dependencies & execution order

```text
T001 (client)
  ├── T002 → T003 → T004 → T005 → T006 → T007 → T008        (US1, one file)
  │                                       └─ T014, T015 (live runs, need the user)
  └── T009 → T010 → T011                                      (US2)
T012 [P] (any time) → T013 (after T011, same file)            (US3)
T016 → T017 → T018 → T019                                      (polish, after all stories)
```

- **US1, US2 and US3 do not depend on each other.** US2's T011 and US3's T013 edit the same widget test file, so do them one after the other.
- **T012 is [P]** with everything, T001 included: it needs nothing from the regenerated client. T013 waits for T011.
- **T014 and T015** need T001 and T002 to T008. Neither needs the other stories.

## Parallel example

After T001: one worker on the live test (T002 to T008), another on the notice (T009 to T011), and a third on T012. Join at T013, then run the polish tasks.

## Implementation strategy

- **MVP**: US1 (T001 to T008, then T014). It restores the only automated proof that stamping and cancellation work end to end.
- **Then** US2, the one visible change, and US3, which is mostly test coverage.
- Commit per phase: the client alone (T001), the live test (US1), the notice and its strings (US2), the offline tests (US3).
