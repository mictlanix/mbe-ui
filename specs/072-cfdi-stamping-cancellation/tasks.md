---
description: "Task list for 072-cfdi-stamping-cancellation"
---

# Tasks: CFDI Stamping, Refresh and Cancellation

**Input**: Design documents from `specs/072-cfdi-stamping-cancellation/`

**Prerequisites**: plan.md, spec.md, research.md (R1–R13), data-model.md, contracts/ui-contracts.md (C15–C24), wireframes.md, quickstart.md

**Tests**: The spec doesn't ask for a test suite as such, but the constitution's quality gates and research R13 require tests. Test tasks sit inside each story, after the code they cover.

**Organization**: Grouped by user story (US1–US5, spec.md). US1, US2 and US3 are P1 and together are the MVP: every state shown correctly, stamping, and cancelling. US4 (refresh) and US5 (cancellation history) are P2. Phase 2 holds what two or more stories share.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: parallelizable (different files, no dependency on an incomplete task)
- **[Story]**: US1 see every state · US2 stamp · US3 cancel · US4 refresh · US5 cancellation history

## Cross-story notes

- **Spec 066 is the base.** Everything is in `lib/features/invoicing` (paths below are relative to the repo root). Mirror what 066 did for confirm and reopen: `showConfirmInvoiceDialog` and `_ConfirmActionDialog` in `presentation/invoice_action_dialogs.dart`, `confirm`/`reopen` in `presentation/fiscal_document_actions.dart`, and `_confirm`/`_reopen` in `presentation/fiscal_document_detail_screen.dart`.
- **Labels.** The issued state keeps its existing label ("Timbrado" / "Stamped", spec 066). Design documents that say "Emitido" or "emitida" mean that state. The new states are "Timbrando" and "Cancelación pendiente".
- **Wire names are not enum names.** `FiscalDocumentStatus.cancellationPending` goes on the wire as `cancellation_pending`. Today the list repository and the filter both write `status.name`, which is wrong for that value. T004 adds `wireName`, and every place that talks to the server or the URL uses it.
- **Generated client.** The method names are long: `stampFiscalDocumentApiV1FiscalDocumentsFiscalDocumentIdStampPost`, `cancelFiscalDocumentApiV1FiscalDocumentsFiscalDocumentIdCancelPost`, `refreshFiscalDocumentApiV1FiscalDocumentsFiscalDocumentIdRefreshPost` (in `lib/generated/openapi/lib/src/api/fiscal_documents_api.dart`). The status enums are built_value classes, so a Dart `switch` over them is not exhaustive. T005 compensates with a test. No client regeneration is needed.
- **Shared files.** Do these sequentially, not in parallel:
  - `lib/features/invoicing/presentation/fiscal_document_detail_screen.dart`: T009, T010 (US1), T013, T016 (US2), T022 (US3), T026 (US4), T028 and T029 (US5) each add to it. Every control is a nullable callback or a condition, so an absent right or state means the control is not in the tree.
  - `lib/features/invoicing/presentation/invoice_action_dialogs.dart`: T014 (US2) only.
  - `lib/features/invoicing/presentation/fiscal_document_refusal.dart`: T015 (US2) adds the hint, and T025 (US4) adds the info notice.
  - `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb`: T003 adds every key once. If a later task needs another, add it there and run `flutter gen-l10n`. Never hand-edit `lib/l10n/app_localizations*.dart`.
- **Generated code.** After editing a freezed or `riverpod` file, run `dart run build_runner build --delete-conflicting-outputs` at the repo root. Never run two build_runner processes at once: tasks that both need it are not marked [P] against each other.
- **Formatting.** Format only the files you changed (`dart format <files>`). Never `dart format .`, and never format `lib/generated/`.
- **Dates** go through `formattersProvider` (§V). Spacing comes from `Theme.of(context).spacing`, colours from `ColorScheme` (research R10). No hex values.
- **Never match server prose** (§III). Refusals are shown through `FiscalDocumentRefusal` / `AppError.localizedMessage`, built from the error's `code` and `params`. Recognition keys on the code. The one verbatim text is the PAC's, and it reaches the screen as a `pac.rejected` param or a history field.
- **Rights.** Stamp, cancel and refresh need `access.can(SystemObject.fiscalDocuments, AccessRight.update)`. A missing right means the control is absent, never disabled.
- **Status and outcome names come from l10n**, never from `enum.name`.
- **Simplifications.** Any shortcut carries a comment `// simplified: <ceiling>, <what to do when it binds>`.

---

## Phase 1: Setup

**Purpose**: a known-good baseline, so later failures are attributable.

- [ ] T001 Run `flutter analyze` and the tests this feature touches: `test/unit/features/invoicing`, `test/widget/features/invoicing`, `test/unit/core/errors`. Note any failure that exists before this work, so it isn't blamed on this feature. The failures in `test/golden/core_widgets_golden_test.dart` are already known (mbe-ui#209).

---

## Phase 2: Foundational (blocks all user stories)

**Purpose**: the pieces two or more stories use: the six-state enum, the new entities, the repository and action methods, every string, and every error code.

- [ ] T002 [P] Create the three new domain files in `lib/features/invoicing/domain/entities/`, per data-model.md. `fiscal_stamp.dart`: freezed `FiscalStamp` with `uuid`, `stamped`, `satCertificate`, `providerRfc`, `simulated`. `fiscal_cancellation.dart`: freezed `FiscalCancellation` with `id`, `reason`, `substitution`, `outcome`, `rawOutcome`, `pacCode`, `pacMessage`, `requestedBy`, `requestedAt`, `answeredAt`, `resolvedAt`, plus the `CancellationOutcome` enum (`requested, pending, accepted, expired, rejected, notCancellable, failed, unknown`) with an `isOpen` getter (requested or pending) and a `fromWire(String)` that maps an unrecognised string to `unknown`. `sat_cancellation_reason.dart`: enum `SatCancellationReason` (`withRelation`=01, `withoutRelation`=02, `notCarriedOut`=03, `globalInvoiceNominative`=04) with `code`, `needsSubstitute` (true only for 01) and `fromCode(String)` returning null for anything else. Run build_runner.
- [ ] T003 Add every new string to **both** `lib/l10n/app_es.arb` and `lib/l10n/app_en.arb` (with `key` descriptions like the neighbours, `"description": "spec 072: <key>"`), then run `flutter gen-l10n`. Keys, by group — **states**: `fiscalDocumentStatusStamping` (Timbrando / Stamping), `fiscalDocumentStatusCancellationPending` (Cancelación pendiente / Cancellation pending). **Banners**: replace `fiscalDocumentBannerSealed` with the C16 sealed texts (plain, plus the "stamp or reopen" and "stamp" advice variants), and add `fiscalDocumentBannerStamping` (with `{since}`), `fiscalDocumentBannerStampingNoRefresh`, `fiscalDocumentBannerCancellationPending` (with `{requested}`) and a variant without a date. **Facts and badge**: `fiscalDocumentFactStamped` ("Fecha de timbrado" / "Stamped on"; not plain "Timbrado", which is already the issued state), SAT certificate, PAC, "Sustituida por", and `fiscalDocumentSimulatedBadge` ("Timbrado simulado, sin validez fiscal"). **Actions**: Timbrar, Cancelar ante el SAT, Consultar estado, Enviar cancelación, Volver. **Stamp dialog**: title (with kind and folio), body. **Cancel dialog**: title, reason label, the four reason descriptions (SAT's official Spanish text for 01–04; an English translation), "Documento que la sustituye", "Cambiar", no-candidates text, send note. **History**: section title "Cancelaciones", the seven outcome labels plus "Desconocido ({value})", "Solicitó {who} · {when}", "Respuesta", "Resuelta", "PAC {code} · «{message}»". **Snackbars and notices**: stamped (with and without " (simulado)"), cancellation sent ({state}), refresh moved to {state}, "Sigue en proceso…". **Errors** (the `apiError…` keys): the 12 new codes (`fiscal_document.cancellation_open, has_live_documents` with `{documents}`, `not_cancellable, nothing_to_refresh, stamping, substitution_invalid, substitution_required, unknown_cancellation_reason` with `{reason}`; `pac.not_configured, rejected` with `{code}` and `{message}`, `timeout, unavailable`), the stamp hint for `issue_date_out_of_range` (research R9), and the neutral rewording of `apiErrorFiscalDocumentNotSealed`, `apiErrorFiscalDocumentNotIssued` and `apiErrorFiscalDocumentNoValidCertificate` (they now apply to stamp and cancel too). The new Spanish texts are drafted in wireframes.md and ui-contracts.md C15–C24; every English text is its own translation, not a copy.
- [ ] T004 Edit `lib/features/invoicing/domain/entities/fiscal_document.dart` (depends on T002 and T003). Extend `FiscalDocumentStatus` to six values **in lifecycle order**: `draft, sealed, stamping, issued, cancellationPending, cancelled`, and give it a `String get wireName` (`draft`, `sealed`, `stamping`, `issued`, `cancellation_pending`, `cancelled`) and a `static FiscalDocumentStatus? fromWire(String?)`. Add to `FiscalDocument`: `FiscalStamp? stamp`, `DateTime? stampingSince`, `String? cancellationSubstitution`, and `Default(<FiscalCancellation>[]) List<FiscalCancellation> cancellations`. Add getters `canStamp` (sealed), `canCancel` (issued), `canRefresh` (stamping or cancellationPending) and `openCancellation` (first cancellation whose outcome `isOpen`, else null). Change `hasDocuments` to issued, cancellationPending or cancelled. Then make every exhaustive `switch` over the enum compile: in `lib/features/invoicing/presentation/fiscal_document_status_chip.dart` add the two new arms to the label function (`fiscalDocumentStatusLabel`, using the l10n keys T003 adds) and to `fiscalDocumentStatusColors` (`tertiaryContainer` / `onTertiaryContainer` for stamping and cancellationPending, research R10). Run build_runner. It uses the l10n getters T003 generated.
- [ ] T005 Edit `lib/features/invoicing/data/fiscal_document_repository_impl.dart` and `lib/features/invoicing/domain/repositories/fiscal_document_repository.dart` (depends on T004). (a) Replace `_status(String name)` with two functions that map each constant explicitly, `_responseStatus(api.FiscalDocumentResponseStatusEnum)` and `_summaryStatus(api.FiscalDocumentSummaryStatusEnum)`, with no draft fallback: an unmapped constant throws `StateError`. Note the sealed constant is `sealed_`. Use them in `_summary` and `_detail`. (b) In `list`, send `status?.wireName` instead of `status?.name`. (c) In `_detail`, map `r.stamp` to `FiscalStamp?`, `r.stampingSince`, `r.cancellationSubstitution`, and `r.cancellations` to `List<FiscalCancellation>` (`CancellationOutcome.fromWire(c.status)`, keep the raw string, and do not map `lastCheckedAt`). A null list maps to an empty one. (d) Add `Future<FiscalDocument> stamp(int id)`, `Future<FiscalDocument> cancel(int id, SatCancellationReason reason, {String? substitution})` and `Future<FiscalDocument> refresh(int id)` to the interface and the implementation, each through `_document(...)` like `confirm`. The cancel request is `FiscalDocumentCancelRequest`; send `substitution` only when `reason.needsSubstitute`. (e) In `test/unit/features/invoicing/fiscal_document_repository_impl_test.dart` and `fiscal_document_fixtures.dart`: add a test that iterates `FiscalDocumentResponseStatusEnum.values` and `FiscalDocumentSummaryStatusEnum.values` and asserts every constant maps and the six domain states are all reached (research R1); a test that a response with a stamp, a `stamping_since`, a substitution and two cancellations (one with an unrecognised status string) maps correctly; and tests that stamp, cancel (01 sends the substitution, 02 does not) and refresh call the right operations.
- [ ] T006 Edit `lib/features/invoicing/presentation/fiscal_document_actions.dart` (depends on T005). Add `Future<AppError?> stamp(int id)` and `Future<AppError?> cancel(int id, SatCancellationReason reason, {String? substitution})`, both through the existing `_run`. Add `Future<({AppError? error, FiscalDocumentStatus? status})> refresh(int id)`: it reads the status the server returned from the repository's result (so it can't use `_run`'s `Object?` return unchanged; return the document's status when the write went through, null when refused), and still invalidates the detail always and the list unless the server refused. Run build_runner. Extend `test/unit/features/invoicing/fiscal_document_actions_test.dart`: each write invalidates the detail; the list is invalidated on success and on `NetworkError` but not on a refusal; refresh returns the new status on success.
- [ ] T007 Add the URL and filter round-trip (depends on T004) for all six states in `lib/features/invoicing/presentation/fiscal_documents_filter.dart`: `fromQuery` matches `status` by `wireName` (via `FiscalDocumentStatus.fromWire`), `toQuery` writes `status?.wireName`. The four old values keep their URLs because their name and wire name are equal. In `lib/features/invoicing/presentation/fiscal_documents_list_screen.dart` change the state dropdown's `onChanged` to `goTo(query.withFacet('status', s?.wireName))`; its items already come from `FiscalDocumentStatus.values`, so all six appear, in lifecycle order. Extend `test/unit/features/invoicing/fiscal_documents_filter_test.dart` with a round trip of each of the six states (`cancellation_pending` in the URL) and a case where an unknown value in the URL is dropped.
- [ ] T008 Localize the 12 new error codes (depends on T003). In `lib/core/errors/localize_problem.dart`: add the 12 `api.ErrorCode` members (they are named like `fiscalDocumentPeriodCancellationOpen` and `pacPeriodRejected`; check `lib/generated/openapi/lib/src/model/error_code.dart`) to `localizedErrorCodes` and give each a message arm, following the neighbouring `fiscalDocumentPeriod…` arms. `has_live_documents` joins the `documents` list param with the locale's list separator and has no message when the param is missing or not a list of strings; `pac.rejected` builds `"{code} · «{message}»"` from its two params after the localized lead-in (research R9); a missing or mistyped param means no message, so the shared fallback applies (spec 058 FR-004). Add 12 `code` rows to `specs/058-localized-api-errors/contracts/code-scope.tsv` with verdict `IN` (copy the column layout of the existing `fiscal_document.*` rows: kind, name, HTTP status, params, verdict, example routes, note), and in `test/unit/core/errors/catalog_coverage_test.dart` change the expected count from 165 to 177 and add the codes whose message needs a param to the `needParams` set: `fiscal_document.has_live_documents`, `fiscal_document.unknown_cancellation_reason` and `pac.rejected`. `fiscal_document.substitution_invalid` and every other new code is a fixed sentence (its `substitution` param is not shown), so it stays out of `needParams`. Add the 12 codes to `test/unit/core/errors/problem_fixtures.dart` and cover the param cases in a new `test/unit/core/errors/localize_problem_cancellation_test.dart` (list joined; PAC text verbatim; missing param → no message), in both languages.

**Checkpoint**: `flutter analyze` is clean, the unit tests of T005–T008 pass, and the app shows six states on the list.

---

## Phase 3: User Story 1 - See every fiscal state correctly (P1) 🎯 MVP

**Goal**: A document in any of the six states shows that state in the list, the filter and the detail, and a stamping or cancellation-pending document is never editable.

**Independent Test**: Using the simulator, leave one document stamping and one cancellation pending. Filter the list by each, open each, and check the label, the banner, and that no edit, confirm or reopen action is offered.

- [ ] T009 [US1] Edit `_StatusBanner` in `lib/features/invoicing/presentation/fiscal_document_detail_screen.dart` (C16). Add `stamping` (uses `stampingSince`; the "or check it now" clause only with update access to fiscal documents) and `cancellation_pending` (uses `document.openCancellation?.requestedAt`; no date when null) banners with the tertiary pair, replace the sealed text (no more "stamping is not yet available"): users without update access get the short text, and with update access the advice differs for invoices ("stamp it, or reopen it") and other types ("stamp it"). The banner needs the user's right, so read `accessControlProvider` inside it.
- [ ] T010 [US1] Change `_FiscalDocumentBodyState.build` in `lib/features/invoicing/presentation/fiscal_document_detail_screen.dart` so `offerFiles` uses the new `hasDocuments` (PDF and XML for issued, cancellation pending and cancelled). The edit, confirm and reopen conditions already depend on `isEditableDraft` and `canReopen`, which are false for the new states; leave them.
- [ ] T011 [P] [US1] Extend `test/widget/features/invoicing/fiscal_document_status_chip_test.dart`: six labels, and the two new colour pairs are `tertiaryContainer` and are different from the other four. Extend `test/widget/features/invoicing/fiscal_documents_list_screen_test.dart`: a row per state shows its label, the state dropdown lists the six in lifecycle order, picking Cancelación pendiente navigates with `status=cancellation_pending` and the repository receives that state.
- [ ] T012 [US1] Extend `test/widget/features/invoicing/fiscal_document_detail_screen_test.dart` (and `fiscal_document_fixtures.dart` for a stamping and a cancellation-pending document): each of those two states shows its banner and its label; neither offers edit header, add order or product, line edit, confirm or reopen (SC-003); PDF and XML are offered for cancellation pending but not for stamping or sealed; the sealed banner no longer contains the old "not available" text; a read-only user gets the short sealed banner.

**Checkpoint**: US1 works alone: the app is safe against the two new states.

---

## Phase 4: User Story 2 - Stamp a sealed document (P1) 🎯 MVP

**Goal**: A user with update access stamps a sealed document of any type, sees its stamp and the simulated badge, and gets the specific message when the PAC refuses, is unavailable or times out.

**Independent Test**: Seal an invoice and stamp it against the simulator: it shows the Timbrado state, UUID, stamp date, SAT certificate, PAC RFC, the simulated badge, the PDF and XML actions, and no Reabrir.

- [ ] T013 [US2] Add the stamp facts to `_HeaderFacts` in `lib/features/invoicing/presentation/fiscal_document_detail_screen.dart` (C17), shown when `document.stamp != null`: keep the existing UUID fact, add `fiscal_document_stamped` (label "Fecha de timbrado" / "Stamped on", date and time), `fiscal_document_sat_certificate` and `fiscal_document_provider_rfc`, each with `emptyValuePlaceholder` when null. Add `fiscal_document_simulated_badge`, a shared `StatusChip` (`lib/core/widgets/status_chip.dart`) with `errorContainer` / `onErrorContainer` and a warning icon, beside the state chip, only when `stamp.simulated`.
- [ ] T014 [US2] In `lib/features/invoicing/presentation/invoice_action_dialogs.dart` add `showStampFiscalDocumentDialog(BuildContext, {required FiscalDocument document})`, built on `_ConfirmActionDialog` like `showConfirmInvoiceDialog` (C20): keys `fiscal_document_stamp_dialog` and `fiscal_document_stamp_submit`; the title and body from T003; `run: (actions) => actions.stamp(document.id)`. Any refusal closes the dialog and is answered to the caller.
- [ ] T015 [US2] Edit `lib/features/invoicing/presentation/fiscal_document_refusal.dart` (C24): give `FiscalDocumentRefusal` an optional `hint` string shown under the message (key `fiscal_document_refusal_hint`).
- [ ] T016 [US2] In `lib/features/invoicing/presentation/fiscal_document_detail_screen.dart` add the **Timbrar** action (C18): a `FilledButton` with key `fiscal_document_stamp`, present when `document.canStamp` and `can(23, update)`, placed last in the action row. Its handler `_stamp` mirrors `_confirm`: clear `_actionError`, open the dialog, on an error set `_actionError`, otherwise read the reloaded document and show a snackbar with the stamped message (adding " (simulado)" when `stamp.simulated`). When the refusal came from stamp and its code is `fiscal_document.issue_date_out_of_range`, pass the stamp hint from T003 to `FiscalDocumentRefusal`. The refusal slot needs the code, so keep the `AppError` and check its code, not its text (§III).
- [ ] T017 [P] [US2] Extend `test/widget/features/invoicing/invoice_action_dialogs_test.dart`: the stamp dialog shows its title and body, runs `stamp`, closes with the result, shows progress while running, and closes with the error on a refusal.
- [ ] T018 [US2] Extend `test/widget/features/invoicing/fiscal_document_detail_screen_test.dart`: a sealed document shows Timbrar and Reabrir with update access and neither without; an invoice and a non-invoice document both offer Timbrar; after stamping, the document shows the stamp facts, PDF and XML and no Reabrir; the badge appears only when `simulated`; a legacy stamp with null certificate and PAC RFC shows the placeholder and no badge; a `pac.rejected` refusal shows the lead-in and the PAC's text verbatim and the document stays sealed; a `pac.timeout` refusal followed by a detail that now returns stamping shows the Timbrando banner and Consultar estado is the action; an `issue_date_out_of_range` refusal from stamp shows the hint and the same code from another action does not.

**Checkpoint**: US1 and US2 work: sealed invoices can be stamped on dev.

---

## Phase 5: User Story 3 - Cancel an issued document (P1) 🎯 MVP

**Goal**: A user with update access cancels an issued document of any type with a SAT reason, choosing the substitute for reason 01. The document ends cancelled, or cancellation pending, and each refusal is specific.

**Independent Test**: Cancel one issued invoice with reason 02 (accepted at once, so Cancelado), and another with reason 01 and a substitute (set to need the receiver, so Cancelación pendiente). Try an invoice with a live payment receipt and read the document list in the message.

- [ ] T019 [US3] Extract the candidate search out of `_AddRelationDialog` in `lib/features/invoicing/presentation/add_relation_dialog.dart` into the new feature-local widget `lib/features/invoicing/presentation/fiscal_document_candidate_picker.dart` (C22, research R7). Inputs: `issuerRfc`, a single `FiscalDocumentStatus status`, `excludeId`, `recipientRfc` (the initial search text, and a filter that keeps only rows with that recipient RFC), `onPicked`, and a `keyPrefix` so the relation dialog keeps its existing keys (`add_relation_row_<id>`, `add_relation_load_more`, `add_relation_empty`). It keeps search-as-you-type, "load more" and the empty state. Re-host it in the relation dialog with no behaviour change, listing cancelled documents for 04 and issued ones for 07 as today. `test/widget/features/invoicing/add_relation_dialog_test.dart` must stay green unchanged.
- [ ] T020 [P] [US3] Add `test/widget/features/invoicing/fiscal_document_candidate_picker_test.dart`: lists only the requested status, never the excluded id, searches as the user types, loads more, shows the empty state, and uses the key prefix it is given.
- [ ] T021 [US3] Create `lib/features/invoicing/presentation/cancel_fiscal_document_dialog.dart` with `showCancelFiscalDocumentDialog(BuildContext, {required FiscalDocument document})` (C21), a `ResponsiveDialog` with `hasUnsavedChanges` once a reason is picked. Keys: `cancel_cfdi_dialog`, `cancel_cfdi_reason_<code>` (radio buttons, none preselected), `cancel_cfdi_substitute` (the T019 picker with `status: issued`, `excludeId: document.id`, the document's issuer and recipient RFC, shown only for 01), `cancel_cfdi_substitute_selected` with a Cambiar control, `cancel_cfdi_no_candidates`, `cancel_cfdi_submit` (enabled only with a reason, and for 01 a picked substitute), `cancel_cfdi_back`. Picking a substitute stores its UUID, so only a document with a `stampUuid` is selectable. Submitting runs `actions.cancel(document.id, reason, substitution: uuid)` with a busy flag. The refusals `fiscal_document.substitution_invalid`, `.substitution_required` and `.unknown_cancellation_reason` show inline and keep the dialog open; every other refusal closes the dialog and is answered to the caller. The dialog's own text is the confirmation: no second prompt. Answers `null` when the user backed out.
- [ ] T022 [US3] In `lib/features/invoicing/presentation/fiscal_document_detail_screen.dart` add **Cancelar ante el SAT** (C18): an `OutlinedButton` with key `fiscal_document_cancel_cfdi`, foreground `colorScheme.error`, present when `document.canCancel` and `can(23, update)`, placed before Reabrir. Its handler `_cancel` mirrors `_reopen`: on an error set `_actionError`, otherwise read the reloaded document and show a snackbar with the state the server returned ("Cancelación enviada: {state}"). The existing cancelled banner is unchanged.
- [ ] T023 [P] [US3] Add `test/widget/features/invoicing/cancel_fiscal_document_dialog_test.dart`: Enviar is disabled until a reason is picked; 02, 03 and 04 show no substitute picker; 01 shows it and keeps Enviar disabled until a substitute is picked; Cambiar returns to the picker; no candidates shows the explanation; `cancel` is called with the reason and, only for 01, the substitute's UUID; `substitution_invalid` stays inline and the dialog stays open; `has_live_documents` closes the dialog with the error; backing out sends nothing and returns null; a discard prompt appears when closing with a reason picked.
- [ ] T024 [US3] Extend `test/widget/features/invoicing/fiscal_document_detail_screen_test.dart`: Cancelar ante el SAT appears for an issued document of any type with update access and for nothing else (not sealed, stamping, cancellation pending or cancelled; not for read-only users); a cancellation that returns cancelled shows the cancelled banner and no Cancelar; one that returns cancellation pending shows its banner and no Cancelar; a `has_live_documents` refusal shows both series-and-folio entries and the document stays issued; `pac.rejected`, `pac.unavailable` and `fiscal_document.not_cancellable` each show their own message.

**Checkpoint**: US1–US3 (the MVP) work: stamp, then cancel, end to end against the simulator.

---

## Phase 6: User Story 4 - Refresh a document in process (P2)

**Goal**: A user with update access refreshes a stamping or cancellation-pending document and is told what happened.

**Independent Test**: With the simulator, leave a document stamping (timeout, but stamped) and refresh: Timbrado. Leave a cancellation pending, have the receiver reject it, refresh: Timbrado again with a rejected entry in its history. Refresh a document still in process: an info notice, not an error.

- [ ] T025 [US4] Add the info notice to `lib/features/invoicing/presentation/fiscal_document_refusal.dart` (C23): `FiscalDocumentNotice`, dismissible, key `fiscal_document_still_in_process`, using the `_StatusBanner` Material pattern (`primaryContainer`, an info icon, tokens for spacing). It is not an `AppError` and not an `ErrorBanner`.
- [ ] T026 [US4] In `lib/features/invoicing/presentation/fiscal_document_detail_screen.dart` add **Consultar estado** (C18): a `FilledButton` with key `fiscal_document_refresh`, present when `document.canRefresh` and `can(23, update)`. Add a `_running` flag: while a refresh runs, every button in the action row is disabled and the refresh button shows a progress indicator (FR-021). Its handler `_refresh` records the status before the call and calls `actions.refresh`. On an error set `_actionError` (this includes `nothing_to_refresh`; the actions notifier already re-reads the detail, so the resolved state shows). On success with the **same** status show the notice from T025; with a **different** status show a snackbar "{folio}: {new state label}" (C23).
- [ ] T027 [US4] Extend `test/widget/features/invoicing/fiscal_document_detail_screen_test.dart`: Consultar estado appears for stamping and for cancellation pending with update access and not otherwise; a refresh that returns the same status shows the "still in process" notice and no error, and the notice can be dismissed; one that returns a new status shows the snackbar and the document's new state; `nothing_to_refresh` shows the refusal and the screen shows the document as the server now has it; all buttons are disabled while the refresh runs (hold the repository's future); a rejected cancellation takes the document back to Timbrado with Cancelar offered again.

---

## Phase 7: User Story 5 - Review the cancellation history (P2)

**Goal**: The detail shows every cancellation request, newest first, and the substitute of a cancelled document.

**Independent Test**: Cancel a document, have the receiver reject it, refresh, cancel again and have it accepted. The detail shows two requests, newest first, the older one rejected with the PAC's code and message.

- [ ] T028 [US5] Add `_CancellationsSection` to `lib/features/invoicing/presentation/fiscal_document_detail_screen.dart` (C19), after the related documents and before the totals, built like `_RelationsSection` (a section title and one row per entry, no table): key `fiscal_document_cancellations`, shown only when `document.cancellations` is non-empty; rows keyed `fiscal_document_cancellation_<id>`, in the order given (the server sends newest first). Each row: the reason code and its `SatCancellationReason` label (the raw code when `fromCode` returns null), a `StatusChip` for the outcome (research R10 colours: requested and pending tertiary; accepted and expired error; rejected, not cancellable and failed `surfaceContainerHighest`; unknown neutral, labelled "Desconocido ({raw})"), the substitute UUID when present, "Solicitó {name or #id} · {requestedAt}" with the name from `employeeDisplayNameProvider(requestedBy)` through the existing `_ResolvedName` (falling back to `#id`), "Respuesta {answeredAt or —}" and "Resuelta {resolvedAt or —}", and when present "PAC {pacCode} · «{pacMessage}»" verbatim. On compact the facts stack vertically.
- [ ] T029 [US5] Add the `fiscal_document_substitution` fact ("Sustituida por {UUID}") to `_HeaderFacts` in the same file, shown when `document.cancellationSubstitution` is set (C17).
- [ ] T030 [US5] Extend `test/widget/features/invoicing/fiscal_document_detail_screen_test.dart`: with two cancellations (rejected, then accepted) both rows show, in the given order, with their labels, times and the PAC code and message verbatim; an open request shows "—" for the missing answer and resolution; a requester whose name lookup fails shows `#id`; an unrecognised outcome string shows "Desconocido (…)"; a document with no cancellations shows no section; the substitution fact shows only when set; a legacy-stamped document shows its stamp without a badge; a cancelled document and a cancellation-pending one still show their stamp facts (FR-007). Add the same checks at a compact width (rows stack, nothing overflows).

---

## Phase 8: Polish & cross-cutting

- [ ] T031 Extend `test/integration/fiscal_documents_live_test.dart` per research R13, behind `MBE_WRITE=true` and on the dev tenant only, **asking the user before it runs** (it consumes folios and stamps documents). It drives the simulator through the generated `PacSimulatorApi` (used by the test only, never by the app): seal → stamp → issued and `stamp.simulated`; stamp `timeout_stamped` → stamping → refresh → issued; cancel 02 accepted → cancelled; cancel `pending` → receiver `reject` → refresh → issued, with a `rejected` history entry; cancel 01 with a substitute → cancelled and `cancellation_substitution` set. Write it, run `flutter analyze` on it, and run it only with the user's go-ahead.
- [ ] T032 Run the full gate: `flutter analyze` (clean), `dart format` on the changed files only (never the whole repo), and `flutter test` for the whole suite. Compare against the T001 baseline: nothing new may fail.
- [ ] T033 Walk `quickstart.md` steps 1–22 against dev (the dev tenant, the simulator controls through the API), including compact width at the largest text size (step 14) and English (step 15). Record any step that cannot be run. Anything left becomes a manual-checks issue like spec 066's (mbe-ui#256), which you create only after asking the user.
- [ ] T034 Write `specs/072-cfdi-stamping-cancellation/pr-description.md`. The Roadmap section reads `Closes mictlanix/mbe-roadmap#52`, and the mbe-ui handoff `Closes #274`. Do not add `Part of` lines for roadmap#54 or #56 (this spec builds neither editor); say that in the PR text. Do not open the PR: the user does that.

---

## Dependencies & Execution Order

```text
Phase 1 (T001)
   └─▶ Phase 2:  T002 ─┐
                 T003 ─┴─▶ T004 ─▶ T005 ─▶ T006
                           T004 ─▶ T007
                 T003 ─▶ T008
Phase 2 ─▶ US1 (T009–T012) ─▶ US2 (T013–T018) ─▶ US3 (T019–T024)   ← MVP
        ─▶ US4 (T025–T027)  needs US1's banner work (T009)
        ─▶ US5 (T028–T030)  needs only Phase 2
Polish (T031–T034) after the stories you ship
```

- **US1** has no dependency on another story. It is the safety fix and should land first.
- **US2** needs US1 (the detail screen's banner and `hasDocuments`).
- **US3** needs Phase 2 only, and its picker (T019) can be built any time after Phase 2. It shares `fiscal_document_detail_screen.dart` with US2, so do the detail edits after T016.
- **US4** and **US5** are independent of US2 and US3 apart from the shared detail screen file.

### Parallel opportunities

- T002 can start while T003 is being written (different files). T007 runs beside T005–T006.
- T011 beside T012 (different test files).
- T017 beside T018, T020 beside T021, T023 beside T022 (tests of a finished piece, different files).
- T019 and T020 (the picker) can be done by one person while another does US2.

## Implementation Strategy

1. **MVP = Phase 2 + US1 + US2 + US3.** After T024 a clerk can stamp and cancel against the simulator, and no document in a new state is ever editable.
2. **Land US1 first, even alone.** It fixes a live bug on dev (stamping and cancellation-pending documents opening as editable drafts), so it's worth merging early if the rest slips.
3. **Then US4 and US5**, either order.
4. **Live test last**, with the user's go-ahead. It writes to the dev tenant.
