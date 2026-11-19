# Research: Pick Up the Real-PAC Simulator (spec 076)

Sources:
- mbe-api `main` at 1713acd, which merged PR #348 (`040-real-pac`): `specs/040-real-pac/{spec,quickstart}.md`, `app/api/v1/endpoints/pac_simulator.py` and `app/services/pac/__init__.py`.
- This repo at a06d9ad4.

## R1. Does the live test already follow the new ordering?

**Decision**: Mostly yes. Keep the existing scenarios as they are, add the two checks the spec asks for (R4, R5), and confirm everything with a live run.

**Findings** in `test/integration/fiscal_documents_live_test.dart`:

| Group | Scenario | Order today | 040 rule |
|---|---|---|---|
| 072 | A: stamp, then cancel accepted | seal → `stamp` → PUT `{cancellation: accepted}` → `cancel` | cancellation outcome after the stamp ✔ |
| 072 | B: timeout that did stamp | seal → PUT `{stamp: timeout_stamped}` → `stamp` → `refresh` | stamp outcome after the last seal ✔. The document is not stamping when the outcome is set ✔ |
| 072 | B: pending, rejected, then pending, accepted | issued → PUT `{cancellation: pending}` → `cancel` → `refresh` (unchanged) → receiver → `refresh` | ✔. The "unchanged" refresh is the 72-hour rule's "nothing yet" case. It still stays pending ✔ |
| 072 | D: cancel with 01 | seal → `stamp` → PUT `{accepted}` → `cancel` | ✔ |
| 073 | credit note cancel | `stamp` → PUT `{accepted}` → `cancel` | ✔ |
| 074 | receipt, then invoice cancel | each `stamp`ed before `simulate()` | ✔ |

- No group reads the simulator's response: the futures are `Future<void>`. So the removed `next_stamp`/`next_cancellation` fields are referenced only inside the generated client.
- No group uses `not_cancellable`, so the "permanent" rule (FR-005) has nothing to fix today. The rule is written into the test's header comment so that a future scenario respects it.
- No group reopens and reseals after choosing a stamp outcome.

**Alternatives considered**:
- Rewriting the groups to mirror quickstart §5's 13 rows one for one. Rejected: FR-006 asks for no fewer scenarios than before, not for all of them, and the API's own suite already walks all 16. Widening the UI's live test is out of scope.

## R2. Regenerate the client

**Decision**: Run `tool/generate_api_client.sh` against a local mbe-api on `main` (1713acd or later). Commit the result as its own `chore` commit, as earlier specs did.

**Rationale**: Constitution §III says codegen must be re-run when the contract changes. The client in this repo (a8290511, 2026-11-18) still has `PacSimulationResponse.nextStamp` and `nextCancellation`. Both are nullable and unused, so nothing breaks before the regeneration, but the contract is out of date.

**Check after regenerating**: the diff should touch only the simulator response, plus any unrelated changes mbe-api merged since a8290511. Anything outside invoicing is reported in the PR and not hidden. Run `dart run build_runner` only where the script requires it. Do not format the whole repo (see the memory note on repo-wide `dart format`).

## R3. How the "still in process" notice chooses its wording

**Decision**: In `_FiscalDocumentDetailBodyState._refresh`, keep `_stillInProcess` as it is. Choose the message when the notice is built:
- if the reloaded document is `cancellationPending`, show the new `fiscalDocumentCancellationStillPending`;
- otherwise (stamping), show the existing `fiscalDocumentStillInProcess`.

**Rationale**: Only two statuses can be refreshed: `stamping` and `cancellationPending` (`canRefresh`). Choosing by status keeps a single notice widget and its key, `fiscal_document_still_in_process`. The existing tests for showing and dismissing it stay valid.

**Wording**:
- es: "La cancelación sigue en proceso. El SAT y el receptor pueden tardar hasta 72 horas en resolverla; mientras tanto el documento sigue vigente."
- en: "The cancellation is still in process. SAT and the receiver can take up to 72 hours to settle it; the document stays valid meanwhile."

It says "up to 72 hours" with no countdown, because the API exposes no deadline (spec assumption). Both an open request still `requested` (a timeout on cancel) and one that is `pending` have the status `cancellationPending`, and the same sentence holds for both.

**Alternatives considered**:
- Counting down from `answeredAt` plus 72 hours. Rejected: `answeredAt` is the PAC's answer only for some outcomes, and the spec chose a general rule.
- Changing the pending banner (`fiscalDocumentBannerCancellationPending`) as well. Rejected: it already says the document stays live while the receiver answers, and it was never wrong. Only the "check back in minutes" advice is.

## R4. Skipping when the simulator is off

**Decision**: At the start of each of the three simulated groups (072, 073, 074), probe `GET /pac-simulator/fiscal-documents/0` through the generated `PacSimulatorApi`:
- **404 with code `request.route_not_found`**: the simulator is off. Call `markTestSkipped('the PAC simulator is off on this server (PAC_PROVIDER is not simulated)')` and return.
- **Any other answer** (404 `fiscal_document.not_found` or similar): the simulator is on. Continue.
- **Anything else unexpected** (network, 401, 5xx): rethrow, so the test fails as it does today.

**Findings**: when the provider is not `simulated`, the simulator answers 404 with `request.route_not_found`, checked before authentication. When it is on, an unknown id answers `not_found(FiscalDocument, 0)`, which has a different code. So id 0 tells the two apart without creating a document. The probe runs before any document is sealed, so a skipped run spends no folio.

**Alternatives considered**:
- A `--dart-define` flag such as `MBE_PAC_SIMULATED`. Rejected: one more thing to remember, and it can disagree with the server.
- Catching 404 on the first `PUT`. Rejected: by then a document has been sealed, and the folio is spent.
- `markTestSkipped` versus a skipped step: `markTestSkipped` marks the whole test skipped. That is the intent here, as in `pos_delivery_split_flow_test.dart`.

## R5. Provider RFC checks

**Decision**:
- **Live test**: in step A (072) and in the stamp steps of 073 and 074, assert `stamp.providerRfc == 'SIM010101SI0'` next to the existing `simulated` assertion.
- **Offline tests**: change the default in `fiscal_document_fixtures.dart` and the mapping test's JSON to `SIM010101SI0`. Keep one widget test that renders `SIM010101SIM` with `simulated: true` to prove migrated documents still show the badge (FR-013).

**Rationale**: FR-012 requires that the simulated badge is decided by the flag, never by the RFC. The screen already uses `stamp.simulated` (`fiscal_document_detail_screen.dart` at lines 391 and 968). A test showing both RFCs with the badge pins that down.

## R6. The 72-hour close (FR-011)

**Decision**: No code change. Add a widget test if one is missing: an issued document whose newest cancellation is `failed` shows the issued banner, the failed row in the history, and "Cancelar" for a user with cancel rights.

**Rationale**: When the server closes the request after 72 hours, it sends `status: issued` and a `failed` cancellation. Spec 072 already maps that state (`CancellationOutcome.failed` gives "Falló", and `canCancel` depends on status). The live test cannot drive the 72-hour wait, so a widget test is the proof.

## R7. Error codes

**Decision**: Add no translations.

**Findings**:
- `fiscal_document.not_stamped` and `fiscal_document.stamping` already have messages (specs 066 and 072), from endpoints the app calls.
- On the simulator they are seen only by the tests, and the simulator is outside the coverage rule (§III exception).
- `request.route_not_found` is read in the probe by its code, never shown to anyone.
- `catalog_coverage_test` is unaffected.
