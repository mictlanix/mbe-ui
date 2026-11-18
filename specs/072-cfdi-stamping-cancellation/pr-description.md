# Facturas: stamp, cancel and refresh CFDIs

## Summary

Spec 066 stopped at a **sealed** invoice. mbe-api spec 039 now stamps, cancels and refreshes fiscal documents through a PAC contract, which on dev and test is a simulator. This PR adds those actions to the document detail and fixes how the app reads the two new server states.

- **Six states.** Draft, Sellado, **Timbrando**, Timbrado, **Cancelación pendiente** and Cancelado show as distinct chips in the list, the state filter (in lifecycle order) and the detail.
  - Before this PR, any state the app didn't know fell back to *draft*. A stamping or cancellation-pending document therefore opened as an editable draft. That bug is live on dev today.
- **Timbrar** on a sealed document of any type (after a confirmation). The detail then shows:
  - the stamp: UUID, stamp date, SAT certificate and PAC RFC;
  - a red **"Timbrado simulado, sin validez fiscal"** badge when the simulator stamped it;
  - Ver PDF and Descargar XML.

  Reabrir is gone once stamped.
- **Cancelar ante el SAT** on an issued document of any type.
  - The clerk picks one of SAT's four reasons. For **01** they also pick the replacement from that issuer's issued documents for the same recipient. That picker is the related-document search from spec 066, now extracted and shared.
  - SAT either cancels at once, or the document stays **Cancelación pendiente** until the receiver answers.
- **Consultar estado** on a stamping or cancellation-pending document asks the PAC now.
  - "Still in process" is an info note, not an error.
  - A resolved document shows its new state.
  - "Nothing to refresh" (someone already resolved it) is a refusal, and the screen then shows the document as it now is.
- **Cancelaciones**, a new section on the detail, lists every request, newest first. Each shows:
  - the reason and the outcome chip;
  - the substitute UUID, if any;
  - who asked, by employee name, falling back to `#id`;
  - when it was asked, answered and resolved;
  - the PAC's code and message as the PAC wrote them.

Spec: `specs/072-cfdi-stamping-cancellation/` (spec, wireframes, plan, research R1–R13, data model, contracts C15–C24, tasks).

## Roadmap

Closes mictlanix/mbe-roadmap#52
Closes #274

Stamping and cancelling work for payment receipts and CFDI credit notes too, because a live receipt or credit note blocks cancelling its invoice. Creating and editing them is still roadmap#54 and #56; this PR builds neither editor.

## Worth knowing

- **Stamping is its own step.** Confirm still only seals (spec 066), and a sealed document offers both Timbrar and Reabrir. If the 72-hour window has passed, the stamp refusal adds a hint: reopen it, change the issue date, and confirm again.
- **Wire name ≠ enum name.** `FiscalDocumentStatus.cancellationPending` goes on the wire and in the URL as `cancellation_pending`. The list call and the filter used to send `status.name`, which would have sent `cancellationPending`. The enum now carries `wireName`. The four old values have the same URL as before.
- **The status mapping covers both generated enums constant by constant, with no fallback.** A test checks that every generated constant maps to a domain state and that the counts match, so a seventh server state fails CI after regeneration instead of showing as a draft.
- **The PAC's text is shown as written,** inside our own localized sentence. It arrives as `pac.rejected`'s params (`pac_code`, `pac_message`) and as history fields, never as the server's `detail`, so it stays within constitution §III.
- **The issued state keeps its label "Timbrado"** ("Stamped") from spec 066. The new stamp-date fact is "Fecha de timbrado", so the two don't read the same.
- **The simulator's controls are API-only.** The app never calls `PacSimulatorApi`; only the live test does.
- **Who asked for a cancellation** is an *employee* id (`requested_by`). It is resolved with the existing `employeeDisplayNameProvider`, which falls back to `#id`, for example without Employees read.

## Rights

| Right | What it gives |
|---|---|
| FiscalDocuments (23) read | The new states, the stamp, the history, Ver PDF / Descargar XML on issued, pending and cancelled documents |
| FiscalDocuments (23) update | Timbrar, Cancelar ante el SAT, Consultar estado, and the "you can…" advice in the banners |

Every action is absent, never disabled, without its right or outside its state.

## Also in this PR

- **Errors (§III):** 12 new codes are localized in both languages and added `IN` to `code-scope.tsv` (coverage 165 → 177):
  - `fiscal_document.cancellation_open`, `has_live_documents` (lists the documents), `not_cancellable`, `nothing_to_refresh`, `stamping`, `substitution_invalid`, `substitution_required` and `unknown_cancellation_reason`;
  - `pac.not_configured`, `rejected`, `timeout` and `unavailable`.

  The text of `not_sealed`, `not_issued` and `no_valid_certificate` is reworded so it reads right from stamp and cancel too.
- **`FiscalDocumentCandidatePicker`** (feature-local) is extracted from the add-relation dialog. The relation dialog keeps its keys and behaviour, and its tests pass unchanged.
- **`FiscalDocumentRefusal`** gains an optional `hint`, and there is a new `FiscalDocumentNotice` for the "still in process" note.

## Tests

- `flutter analyze`: no issues.
- `flutter test` (whole suite): **6,091 passed, 83 skipped, 8 failed.** None of the failures come from this branch:
  - 6 × `test/golden/core_widgets_golden_test.dart`: known, mbe-ui#209.
  - `test/screenshots/pos_screens_screenshot_test.dart` "the sales list (US1) desktop, mixed row states": the same 2.36 % pixel diff on clean `main`.
  - `test/integration/auth_flow_test.dart` scenario 2: it needs a running mbe-api (connection refused).
- New and extended tests cover:
  - the exhaustive status mapping, and the wire name in the list call and the URL;
  - the stamp and history mapping, including an unknown outcome kept raw;
  - stamp, cancel and refresh in the repository: 01 sends the substitute, 02 doesn't;
  - the actions' invalidation and refresh's returned status;
  - the 12 codes and their param cases: the joined document list, the PAC text verbatim, and a missing param meaning no message;
  - the chips and their colours, and the list's six states;
  - per state and per right: the banners, the stamp facts and badge (including a legacy stamp), the Timbrar flow with each PAC outcome (including timeout → stamping) and the stale-date hint;
  - the cancel dialog: reasons, 01's substitute, Cambiar, no candidates, inline vs. closing refusals, the discard prompt and double taps;
  - refresh: still in process, resolved, `nothing_to_refresh`, buttons waiting while it runs;
  - the history at regular and compact width;
  - the extracted picker.
- **Live (`test/integration/fiscal_documents_live_test.dart`): written, not run.** The new test, *Stamp, cancel and refresh against the simulated PAC*, needs `MBE_WRITE=true` and a backend with `PAC_PROVIDER=simulated`. It seals and stamps four invoices, which uses four folios on the tenant. It is skipped without credentials and without `MBE_WRITE=true`.

## Manual checks (quickstart.md)

**Not run yet.** Steps 1–22, run against the dev simulator: the 13 simulator scenarios, read-only users, compact width at the largest text size, and English.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
