# Research: CFDI Stamping, Refresh and Cancellation

**Spec**: [spec.md](./spec.md) | **Wireframes**: [wireframes.md](./wireframes.md) | **Date**: 2026-11-17

The sources are mbe-api spec 039 (`specs/039-cfdi-stamping-cancellation`, merged in #334 and
#336), the handoff in mbe-ui#274, the generated client at `f4271b49`, and the spec 066 code
in `lib/features/invoicing`. Each entry ends with the wireframe open question (WQn) it
settles, if any.

## R1. Mapping the six states (FR-001, FR-003; WQ9)

**Decision**: Extend `FiscalDocumentStatus` to six values: `draft, sealed, stamping, issued,
cancellationPending, cancelled`. Replace `_status(String name)` in
`fiscal_document_repository_impl.dart` with two mappers keyed on the generated enum
constants, one for `FiscalDocumentResponseStatusEnum` and one for
`FiscalDocumentSummaryStatusEnum`. Neither has a draft fallback; an unmapped constant
throws `StateError`. A unit test iterates `<Enum>.values` for both and checks that every
value maps to a distinct domain state, so a seventh server state fails CI after
regeneration instead of rendering as a draft.

**Rationale**: Today's mapper matches on `enum.name`. For the new constant that name is
`cancellationPending`, and the string the mapper would need to expect is not obvious
(`sealed_` already shows the trap). Anything unmatched falls to `draft`. built_value
`EnumClass` isn't a Dart `enum`, so `switch` can't be exhaustive, and the `.values` test
takes its place. An unknown *wire* value never reaches the mapper: built_value's
`valueOf` throws during deserialization (spec 066's finding). So FR-003 was reworded and
there's no "unknown" chip.

**Alternatives**: An "unknown" domain state with a neutral chip. Rejected because it's
unreachable, as above.

## R2. Which actions each state offers (FR-004, FR-005, FR-006, FR-010, FR-015, FR-020)

**Decision**: These are entity getters, and the detail screen combines each with `can(23,
update)`:

| Getter | True when |
|---|---|
| `isEditableDraft` (unchanged) | invoice and draft |
| `canReopen` (unchanged) | invoice and sealed |
| `canStamp` (new) | sealed, **any type** |
| `canCancel` (new) | issued, any type |
| `canRefresh` (new) | stamping or cancellation pending |
| `hasDocuments` (changed) | issued, cancellation pending or cancelled |

**Rationale**: The server allows stamping and cancelling every type (spec 039 FR-016 and
FR-017), and a live payment receipt or credit note blocks its invoice's cancellation.
Reopen stays invoice-only because spec 066 drew it that way and the route is "Reopen
Invoice".

## R3. Action plumbing (FR-021; WQ2)

**Decision**: Add `stamp(id)`, `cancel(id, reason, substitution)` and `refresh(id)` to
`FiscalDocumentRepository` and to the keep-alive `FiscalDocumentActions` notifier, in the
same shape as `confirm` and `reopen`:

- They return `AppError?` and always invalidate the detail.
- The list is invalidated unless the server refused.

`refresh` is the exception: it returns `({AppError? error, FiscalDocumentStatus? status})`,
the status the server returned, so the screen can tell "still in process" from a resolved
document (R5).

Stamping runs inside its confirmation dialog, like confirm and reopen do, which shows
progress and blocks a second tap. Cancelling runs inside the cancel dialog. Refresh runs
from the action row with the screen's existing `_busy` handling: every button is disabled
and the running one shows a spinner.

**Rationale**: WQ2 is settled by the existing design. `FiscalDocumentActions` always
invalidates the detail, so after `pac.timeout`, `pac.unavailable` or `lock.busy` the
screen re-reads the document, and the banner shows its real state (sealed → stamping
after a timeout).

**Network failures**: the app sets no client timeout (`dio_client.dart`). A slow PAC
therefore comes back as the server's own 504 `pac.timeout`. A dropped connection is the
existing `NetworkError`, worded as "the result is not known". Because the detail
re-reads, the clerk sees stamping or issued.

## R4. Legacy stamps (FR-007, US5-5; WQ4)

**Decision**: Map `stamp` as nullable. Show the Timbrado, Certificado SAT and PAC facts
when `stamp != null`, each with `emptyValuePlaceholder` when its field is null. The
simulated badge follows `stamp.simulated`.

**Rationale**: `fiscal_document_service.get_document` (mbe-api) builds `stamp` from the
document's shared columns (`stamp_uuid`, `stamped`, `authority_certificate_number`,
`rfc_pac`) whenever `stamp_uuid` is set, so legacy-stamped documents get one too.
`simulated` is `rfc_pac == SIM010101SIM`, so a legacy stamp is never simulated.

## R5. Refresh outcomes (FR-016; WQ3)

**Decision**:

| Server answer | UI |
|---|---|
| 200, same status as before the call | Info notice "Sigue en proceso…" in the refusal slot. Info styling, dismissible, not an `AppError`. |
| 200, a different status | Snackbar naming the new state (e.g. "Factura A5240 emitida"). |
| 409 `fiscal_document.nothing_to_refresh` | Refusal message; the detail re-reads (R3) and shows the resolved state. |

**Rationale**: The handoff documents that refresh returns the document "in its resolved
(or unchanged) state". Comparing with the status held before the call is the only signal.
`last_checked_at` changes on every call, so it can't be used.

## R6. Cancellation reasons (FR-010; WQ7)

**Decision**: `SatCancellationReason` is a domain enum with `code` 01–04 and localized
labels in both `.arb` files: SAT's official Spanish description, and an English
translation. It isn't fetched.

**Rationale**: SAT fixes the set, the server rejects anything else with
`unknown_cancellation_reason`, and English needs its own text anyway. The app's SAT
catalogue repository serves catalogues that are large or change; this one does neither.

## R7. Substitute picker (FR-011; WQ8)

**Decision**: Extract the candidate search from `add_relation_dialog.dart` into a
feature-local widget, `fiscal_document_candidate_picker.dart`. It takes the issuer RFC, a
single `FiscalDocumentStatus` to list, an `excludeId`, and an initial search (the
recipient's RFC). It keeps search-as-you-type, "load more" and the empty state.

- The relation dialog keeps its behaviour: it lists cancelled documents for 04 and issued
  ones for 07.
- The cancel dialog lists issued documents, excluding the one being cancelled, and keeps
  only rows whose recipient RFC matches.

**Rationale**: The list API filters by issuer and a single `status` but not by recipient
(mbe-api `list_fiscal_documents`), which is why spec 066 already prefills the search with
the recipient's RFC. Offering only `issued` follows from the single-status filter and the
FR-011 rewording. Keeping two copies of a paged search would go against §I.

**Alternatives**: A free-text UUID field. Rejected: the picker's search already accepts a
UUID, and a picked row can't be a typo.

## R8. Requester names in the history (FR-017; WQ10)

**Decision**: `requested_by` is an **employee** id (mbe-api data-model: FK → `employee`).
Show it with the existing `employeeDisplayNameProvider(id)` through the detail's
`_ResolvedName`, falling back to `#id`, exactly as the customer and facility facts do. No
upstream change is requested.

**Rationale**: The provider already turns any failure, including a missing Employees read
right, into `null`, so the fallback covers clerks who can't read employees. One request per
distinct requester, cached by the family.

## R9. Error codes (FR-018, FR-019)

**Decision**:

- **12 new codes**, localized in both locales and added to
  `specs/058-localized-api-errors/contracts/code-scope.tsv` as `IN` (coverage 165 → 177):
  `fiscal_document.{cancellation_open, has_live_documents, not_cancellable,
  nothing_to_refresh, stamping, substitution_invalid, substitution_required,
  unknown_cancellation_reason}` and `pac.{not_configured, rejected, timeout,
  unavailable}`.
- **Params**:
  - `has_live_documents.documents` is a list of strings, joined with the locale's list
    separator.
  - `pac.rejected.pac_code` and `.pac_message` are rendered as `"{code} · «{message}»"`
    after a localized lead-in. They are **params**, so this follows §III: the text comes
    from the code plus params, never from `detail`.
  - `pac.timeout.state` is not shown; the re-read banner says it.
  - `substitution_invalid.substitution` is shown shortened.
  - `unknown_cancellation_reason.reason` is shown.

  With a param missing or of the wrong type, there's no message and the shared fallback
  applies (spec 058 FR-004).
- **Reused codes** whose current Spanish was written for one action are reworded neutrally:
  - `not_sealed`: today "Solo se puede reabrir…"; it now applies to stamp and reopen.
  - `not_issued`: today about PDF/XML; it now also applies to cancel.
  - `no_valid_certificate`: today "…para sellar"; it now also applies to cancel.

  `issue_date_out_of_range` keeps its text. When it comes back from **stamp**, the detail
  adds one extra line: "Reábrela, cambia la fecha de emisión (o déjala vacía) y confírmala
  de nuevo." That line is an action-context hint keyed on the code (§III allows branching
  on `code`).
- **`lock.busy`**: already localized.

**Rationale**: §III requires a message for every code an endpoint the app calls can
return. The spec 039 contract lists exactly these.

## R10. Colours and badge (FR-001, FR-008)

**Decision**:

- `fiscalDocumentStatusColors` gains `stamping` and `cancellationPending` →
  `tertiaryContainer` / `onTertiaryContainer`, the "waiting" pair delivery-order and POS
  chips already use.
- Banners for those two states use the same pair.
- The simulated badge is a `StatusChip` with `errorContainer` / `onErrorContainer`, a
  warning icon and the label "Timbrado simulado, sin validez fiscal". It sits next to the
  state chip in the header's state fact.
- The history outcome chip maps:
  - requested and pending → tertiary;
  - accepted and expired → error;
  - rejected, not cancellable and failed → `surfaceContainerHighest`.

  An unknown outcome string shows "Desconocido ({value})", neutral. The history `status` is
  a plain `String` in the client, so unlike R1 an unknown value does reach the app.

**Rationale**: The theme has no warning token; §V forbids hard-coded colours. "Waiting" is
visually distinct from neutral draft/sealed, issued (secondary) and cancelled (error).

## R11. Label length on compact (WQ5)

**Decision**: Keep "Cancelación pendiente" and let the chip wrap on compact rows.
`FiscalDocumentStatusChip` is already documented as never truncated.

**Rationale**: A shorter wording is a terminology choice. The user can change the label
later in one `.arb` key; nothing in the layout depends on it.

## R12. Simulated-PAC warning before stamping (WQ1)

**Decision**: None. The stamp dialog doesn't mention the simulator. After stamping, the
badge (and the PDF's red banner, server-side) say it.

**Rationale**: The app can't know about the simulator before the first stamp, and
production can never run it (spec 039: the service refuses to start).

## R13. Testing

**Decision**:

- **Unit**:
  - `fiscal_document_repository_impl_test`: the R1 `.values` exhaustiveness for both
    enums, plus stamp, cancel and history mapping.
  - `fiscal_document_actions_test`: stamp, cancel and refresh invalidation, and refresh's
    returned status.
  - `fiscal_documents_filter_test`: six states round-trip through the URL.
  - Error tests: `catalog_coverage_test` (165 → 177), `problem_fixtures` for the 12 codes,
    and a group test for the param cases (`has_live_documents` list, `pac.rejected`
    verbatim, a missing param → fallback).
- **Widget**:
  - `fiscal_document_detail_screen_test`: per state, the banner, actions and their absence
    without 23 update; stamp facts and badge; the history section; the refresh info
    notice vs. refusal; the stamp-context hint for `issue_date_out_of_range`.
  - `fiscal_document_status_chip_test`: six labels and colours.
  - New `cancel_fiscal_document_dialog_test`: reason required; 01 needs a substitute;
    inline vs. closing refusals.
  - New `fiscal_document_candidate_picker_test`.
  - Existing `add_relation_dialog_test` stays green after the extraction.
- **Live** (`test/integration/fiscal_documents_live_test.dart`, extended): behind
  `MBE_WRITE=true`, on dev only, and the user is asked first. It drives the simulator
  through the generated `PacSimulatorApi`, which only the test uses, never the app:
  - seal, stamp, check the stamp is issued and simulated;
  - cancel with 02, accepted;
  - stamp timeout_stamped, then refresh;
  - cancel pending, receiver reject, refresh → issued with history;
  - `has_live_documents` if a live receipt exists.
- **Templates**: spec 066's tests and `InvoiceHarness`.
