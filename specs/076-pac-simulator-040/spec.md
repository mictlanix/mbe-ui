# Feature Specification: Pick Up the Real-PAC Simulator (mbe-api spec 040)

**Feature Branch**: `076-pac-simulator-040`

**Created**: 2026-11-19

**Status**: Draft

**Input**: Covers mictlanix/mbe-ui#288 ([UI] Pick up mbe-api spec 040: the PAC simulator's routes and behavior changed), a follow-up to mictlanix/mbe-ui#274. Screens: mictlanix/mbe-roadmap#52, mictlanix/mbe-roadmap#54, mictlanix/mbe-roadmap#56 (CFDI stamping/cancellation, payment receipts, credit notes; specs 072–074). Server side: mbe-api spec 040 (`040-real-pac`, mbe-api PR #348, merged 2026-11-19), API roadmap mictlanix/mbe-roadmap#46 and #51. Scenario steps: mbe-api `specs/040-real-pac/quickstart.md` §5.

## Context

mbe-api spec 040 replaced the API's own stamping simulator with the one in the CFDI library (mictlanix/cfdi). That library will also be the API's real PAC (Multifacturas). Spec 072 built stamping, refresh and cancellation in the app against the old simulator. Specs 073 and 074 added credit notes and payment receipts on the same flow. Everything in #274 still holds except the following.

**The simulator's test controls** (`/pac-simulator/fiscal-documents/{id}`, used only by the app's live tests, never by a screen):

- Reading or setting an outcome now returns only the document's UUID, SAT status and cancellation status. The "next stamp" and "next cancellation" fields are gone. Before a stamp, the UUID is empty, the SAT status is `not_found` and the cancellation status is `none`.
- A **cancellation outcome needs the stamp first**. Setting one on an unstamped document is refused (409 `fiscal_document.not_stamped`).
- A **stamp outcome belongs to the document as last sealed**. Reopening and sealing again discards it. Setting one while the document is stamping is refused (409 `fiscal_document.stamping`).
- **"Not cancellable" is permanent** for that document. Every later cancel is refused (409 `fiscal_document.not_cancellable`), so a successful cancel needs a new document.
- Request bodies, paths, privileges, and the 404 when the simulator is off are unchanged.

**What users can see:**

- **Simulated stamps carry a new provider RFC**, `SIM010101SI0`, replacing `SIM010101SIM`, which SAT's schema rejects. Documents stamped earlier were migrated. They are still marked simulated and still print the "DOCUMENTO SIMULADO" banner.
- **The simulator no longer knows documents stamped before the switch.** Cancelling one is answered as pending, waiting for the receiver.
- **A pending cancellation can now stay pending for up to 72 hours.** Before, a refresh that found no cancellation at SAT closed the request at once as "not received by SAT" (`failed`) and returned the document to issued. Now a refresh in the first 72 hours after the PAC's answer changes nothing. Only a refresh after that closes the request as failed.

**Servers:** dev and test both run the simulator for now. Test will later move to Multifacturas' test mode. From then on the simulator's controls answer 404 there, and the simulated scenarios run on dev only.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - The live PAC tests run again against the new simulator (Priority: P1)

A developer or QA runs the live stamping, cancellation, credit-note and payment-receipt tests against dev. The tests set up each scenario in the order the new simulator requires: seal, then choose the stamp outcome; stamp, then choose the cancellation outcome; use a new document after "not cancellable". They read only what the simulator still returns. They pass, and they confirm that the screens' flows of specs 072–074 still behave as before.

**Why this priority**: These tests are the only automated proof that stamping and cancellation work end to end. Until they follow the new rules they fail or test the wrong thing, and every later CFDI change ships without that proof.

**Independent Test**: Run the live fiscal-document tests with writes enabled against dev. Every scenario they cover passes, and none of them reads a field the simulator no longer returns.

**Acceptance Scenarios**:

1. **Given** a sealed invoice, **When** the test stamps it with no outcome chosen, **Then** it is issued with a simulated stamp whose provider RFC is `SIM010101SI0`.
2. **Given** a sealed invoice, **When** the test chooses a stamp outcome (rejected, unavailable, timeout that did stamp, timeout that did not) after the last seal and then stamps, **Then** the document ends as quickstart §5 describes for that outcome.
3. **Given** an issued invoice, **When** the test chooses a cancellation outcome (accepted, pending then accepted/rejected/expired, rejected by the PAC, unavailable, timeout) and then cancels and refreshes as needed, **Then** the document and its cancellation history end as quickstart §5 describes.
4. **Given** an invoice whose cancellation was answered "not cancellable", **When** the test needs a successful cancel afterwards, **Then** it uses a new document rather than the same one.
5. **Given** a server where the simulator is off (its controls answer 404), **When** the simulated scenarios run, **Then** they are skipped with a stated reason, not reported as failures.
6. **Given** the credit-note and payment-receipt scenarios (specs 073, 074), **When** they run, **Then** they follow the same ordering rules and pass.

---

### User Story 2 - A billing user waiting on a pending cancellation is told how long it can take (Priority: P2)

A billing user cancels an issued invoice. The PAC accepts the request and the receiver must answer, so the document shows "cancellation pending". The user taps "Consultar estado" a few minutes later. Nothing has changed. The app now tells them that SAT and the receiver can take up to 72 hours. It no longer tells them to check back in a few minutes. Once the 72 hours have passed with no word from SAT, a refresh closes the request and the document is issued (live) again. The history shows that request as failed.

**Why this priority**: Users see this every time a cancellation needs the receiver's acceptance. "Check back in a few minutes" for something that can take three days sends them back over and over, or makes them think the app is stuck.

**Independent Test**: Open a document with an open, pending cancellation. Refresh it while SAT still has nothing to report, and read the notice. Open a document whose pending request the server closed after 72 hours, and read its banner and history.

**Acceptance Scenarios**:

1. **Given** a document with a pending cancellation, **When** a refresh leaves it pending, **Then** the notice says the cancellation can take up to 72 hours for SAT and the receiver, and the document stays live in the meantime.
2. **Given** a document that is stamping, **When** a refresh leaves it stamping, **Then** the notice keeps saying to check again in a few minutes, as today.
3. **Given** a pending cancellation the server closed after 72 hours, **When** the user opens or refreshes the document, **Then** the document shows as issued, the request appears in the history as failed, and "Cancelar" is offered again to anyone allowed to cancel.

---

### User Story 3 - Documents stamped before the switch still read correctly (Priority: P3)

A user opens an invoice, credit note or payment receipt that the old simulator stamped. It still shows the "simulated stamp" badge and its provider RFC, `SIM010101SIM`, and its PDF still carries the simulated banner. If they cancel it, the request goes pending and waits for the receiver, as for any pending cancellation.

**Why this priority**: These documents only exist on dev and test, and nothing on the screen needs to change. The point of this story is to confirm that, and to keep the offline tests in line with what the server now sends.

**Independent Test**: Open a document stamped before 2026-11-19 on dev and one stamped after. Both show the simulated badge, each with its own provider RFC. The offline tests' sample stamp uses the new RFC.

**Acceptance Scenarios**:

1. **Given** a document stamped before the switch, **When** it is opened, **Then** it shows the simulated badge and provider RFC `SIM010101SIM`, exactly as before.
2. **Given** a document stamped after the switch, **When** it is opened, **Then** it shows the simulated badge and provider RFC `SIM010101SI0`.
3. **Given** a document stamped before the switch, **When** it is cancelled, **Then** it becomes cancellation pending, and the user sees the guidance of User Story 2.

---

### Edge Cases

- **A stamp outcome set before a reopen and reseal** is discarded by the server. A test that reseals must choose the outcome again after the last seal.
- **A cancellation chosen with no outcome on a stamp under 24 hours old** is cancelled at once. A test that needs "pending" must choose it explicitly.
- **Setting a stamp outcome while the document is stamping** is refused. A test chooses it before the stamp or after the refresh that settles it.
- **A refresh of a pending cancellation that settles in the meantime** (the receiver accepts, rejects or lets it expire) settles exactly as in spec 072. Only the "nothing yet" case changed.
- **Test server after the move to Multifacturas:** real stamps carry the PAC's own RFC and `simulated` is false. The live tests' simulated scenarios are skipped there (Story 1, scenario 5). Their non-simulated checks must not assume the simulated badge.
- **The two new simulator refusals** (`fiscal_document.not_stamped` and `fiscal_document.stamping` on the controls) are seen only by the tests. They need no user-facing message beyond what the app already has.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The app's API client MUST be regenerated from mbe-api's current published contract, so that the simulator's response has only UUID, SAT status and cancellation status.
- **FR-002**: Nothing in the app or its tests may read the simulator's removed "next stamp" or "next cancellation" fields.
- **FR-003**: The live tests MUST choose a stamp outcome only after the document's last seal and only while it is not stamping.
- **FR-004**: The live tests MUST choose a cancellation outcome only after the document is stamped.
- **FR-005**: The live tests MUST use a new document for any successful cancel that follows a "not cancellable" outcome.
- **FR-006**: The live tests MUST cover at least the scenarios they covered before this change (specs 072, 073, 074), with the steps of mbe-api quickstart §5. A scenario MUST NOT be dropped because its order of steps changed.
- **FR-007**: When the simulator's controls answer 404, the live tests' simulated scenarios MUST be skipped with a reason saying the simulator is off on that server. Every other failure MUST still fail.
- **FR-008**: The live tests MUST accept the new simulated provider RFC (`SIM010101SI0`). Wherever they check the RFC of a simulated stamp, they MUST check for that value.
- **FR-009**: After a refresh that leaves a cancellation pending, the detail screen MUST say that SAT and the receiver can take up to 72 hours and that the document stays live meanwhile. It MUST NOT suggest checking again in a few minutes. The notice for a document still stamping is unchanged.
- **FR-010**: The new wording MUST exist in every supported language (Spanish and English).
- **FR-011**: A document whose pending request the server closed as failed MUST show as issued, with the failed request in the cancellation history. The actions MUST match those of any issued document. This is already the behaviour, and it MUST still hold.
- **FR-012**: Documents stamped by the old simulator MUST keep showing the simulated badge and their stored provider RFC. Documents stamped by the new one MUST show the same badge with `SIM010101SI0`. Simulated detection MUST keep using the stamp's "simulated" flag, never the RFC value.
- **FR-013**: The offline tests' sample simulated stamp MUST use `SIM010101SI0`. At least one test MUST keep a stamp with the old RFC to prove that migrated documents still show the badge.

### Key Entities

- **Simulator state** (test-only): what the simulator reports for one document: its UUID (empty before the stamp), SAT status (`not_found` before the stamp) and cancellation status (`none` before any cancel). It no longer reports the outcome queued for the next call.
- **Cancellation request** (spec 072, unchanged in shape): one request to cancel a document. An open pending request now stays open until SAT settles it or 72 hours pass since the PAC's answer, whichever comes first.
- **Stamp** (spec 072, unchanged in shape): UUID, stamped date, SAT certificate, provider RFC, simulated flag. Simulated stamps now carry `SIM010101SI0`, and migrated older ones keep `SIM010101SIM`.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: The live fiscal-document tests (stamping and cancellation, credit notes, payment receipts) pass in full against dev with writes enabled, with no scenario fewer than before this change.
- **SC-002**: No code or test references the simulator's removed fields (0 occurrences outside the regenerated client's history).
- **SC-003**: Against a server with the simulator off, the simulated scenarios report as skipped with a reason, and 0 of them report as failures.
- **SC-004**: In both languages, a user refreshing a pending cancellation sees the "up to 72 hours" guidance, confirmed by a widget test of the detail screen.
- **SC-005**: The whole offline test suite passes, and a document with each provider RFC, old and new, shows the simulated badge.

## Assumptions

- **mbe-api spec 040 is merged and deployed to dev** (PR #348, merged 2026-11-19). Its published contract already drops the two fields, so regenerating the client is enough. No new mbe-api issue is needed.
- **The 72-hour wait cannot be read from the server.** No field gives the deadline, so the notice states the rule in general ("up to 72 hours") rather than counting down from the PAC's answer.
- **"Not received by SAT" stays a plain `failed` in the history**, as the API records it. The app does not try to tell it apart from other failures, such as a PAC that was unavailable on cancel. Telling them apart would need a distinct outcome or code from the API, and that would be a separate request.
- **The simulator's controls stay test-only.** No screen calls them, so their new refusals fall under the "codes returned only by endpoints the app does not call" exception of the constitution's API-error rule. No new translations are needed for them.
- **No screen changes beyond FR-009.** Stamping, refresh, cancel, the simulated badge and the printed banner already behave as spec 040 requires.
- **The move of the test server to Multifacturas' test mode is out of scope.** This spec only makes the live tests skip cleanly when that happens (FR-007). Real-PAC checks belong to the cutover (mictlanix/mbe-roadmap#57).
