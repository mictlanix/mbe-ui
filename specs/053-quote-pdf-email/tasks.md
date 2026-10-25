---
description: "Task list for 053-quote-pdf-email"
---

# Tasks: Quotation PDF and Email

**Input**: Design documents from `specs/053-quote-pdf-email/`

**Prerequisites**: plan.md, spec.md, wireframes.md, research.md (R1–R14), data-model.md, contracts/consumed-endpoints.md (E1–E3), contracts/ui-contracts.md (C1–C5), quickstart.md

**Tests**: The spec does not ask for a test suite as such, but the constitution's quality gates and research R13 require tests. Test tasks are included inside each story, after the code they cover.

**Organization**: Grouped by user story (US1–US2, spec.md). US1 is the MVP and shares no code with US2 except the quote header file. US2 adds the email button and the compact overflow menu on top of US1's header.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: parallelizable (different files, no dependency on an incomplete task)
- **[Story]**: US1 view, print or download a quote · US2 email a confirmed quote

## Cross-story notes

- **Shared files.** Do these sequentially, not in parallel:
  - `lib/features/sales/presentation/quotes/quote_header_panel.dart`: T008 (US1), then T024 and T025 (US2).
  - `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb`: T007 (US1), then T019 (US2). Run `flutter gen-l10n` after each arb task and commit the regenerated `lib/l10n/app_localizations*.dart` files. Never hand-edit those.
  - `test/widget/features/sales/quote_screen_documents_test.dart`: T009, then T026.
- **Generated code.** After editing a freezed or `@riverpod` file, run `dart run build_runner build --delete-conflicting-outputs`.
- **No backend work.** Nothing here touches mbe-api, and the OpenAPI client is not regenerated (research R1). Both endpoints and their client methods already exist.
- **Formatting.** Format only the files you changed (`dart format <files>`). Never `dart format .`.
- **Spacing tokens, not literals.** Constitution §V requires every padding, margin and gap to come from `Theme.of(context).spacing`. `pricing_grid_screen.dart`'s chip `Wrap` uses a literal `8` and `ErrorBanner` uses literals; don't copy them into new code. No automated guard catches this, so check it in review.
- **Mirror, don't copy blindly.** The closest precedents:
  - "Ver pedido": `lib/features/sales/presentation/orders/order_header_panel.dart` (`_viewPedido` at lines 136–159, the trailing `Wrap` at 501–520) and `test/widget/features/sales/order_workspace_view_pedido_test.dart`.
  - Compact full-screen switch: `lib/core/documents/presentation/document_preview_dialog.dart` (lines 80 and 116–125).
  - Menu idiom: `lib/core/widgets/user_menu_button.dart` (`MenuAnchor` + `MenuItemButton`).
  - Chip construction: `lib/features/pricing/presentation/pricing_grid_screen.dart` (around lines 781–798).

  Read the matching file before writing each new one, and keep its structure, comment density and naming style.
- **Language.** User-visible text is in Spanish and English. The Spanish wording in T007 and T019 is the starting point; the wireframes show where each string appears.

---

## Phase 1: Setup

**Purpose**: a known-good baseline, so later failures are attributable.

- [X] T001 Run `flutter analyze`, then `flutter test test/unit/core/documents test/widget/features/sales/quote_screen_test.dart test/widget/features/sales/order_workspace_view_pedido_test.dart test/golden` on the clean branch, and note any pre-existing failures so they are not blamed on this feature. Then confirm the generated client already has both methods: `grep -n "printSalesQuoteDocumentApiV1SalesQuotesSalesQuoteIdDocumentGet\|emailSalesQuoteApiV1SalesQuotesSalesQuoteIdEmailPost" lib/generated/openapi/lib/src/api/sales_quotes_api.dart` must print both. If either is missing, stop: codegen is needed and the plan's R1 no longer holds. Then check the two models for schema drift: fetch the dev mbe-api's `/openapi.json` and compare its `QuoteEmailRequest` (`to`) and `QuoteEmailResponse` (`recipients`, `sent_at`) schemas with `lib/generated/openapi/lib/src/model/quote_email_request.dart` and `quote_email_response.dart`. If they differ, stop and regenerate before continuing.

## Phase 2: Foundational

None. US1 and US2 share no blocking prerequisite, so US1 starts straight after Phase 1.

---

## Phase 3: User Story 1 — View, print or download a quote (P1) 🎯 MVP

**Goal**: a quote in any state opens the shared document preview from the quote header.

**Independent test**: open a draft, a confirmed and a cancelled quote, choose "Ver cotización", and confirm the preview shows the server-rendered PDF with print and download working (quickstart M1–M3).

- [X] T002 [US1] Add `salesQuote(SystemObject.salesQuotes)` to `DocumentKind` in `lib/core/documents/domain/document_kind.dart`, with a doc comment like its siblings (`GET /sales-quotes/{id}/document` — the letter-size quote, in any state), and the `fallbackFilename` arm `DocumentKind.salesQuote => 'cotizacion-${_pad(recordId, 8)}.pdf'`. Both switches are exhaustive, so the build stays broken until T003 is done too.
- [X] T003 [US1] In `lib/core/documents/data/document_source_impl.dart`, add an `api.SalesQuotesApi` field and constructor parameter beside `_salesOrders` and `_cashSessions`, and the switch arm `DocumentKind.salesQuote => _salesQuotes.printSalesQuoteDocumentApiV1SalesQuotesSalesQuoteIdDocumentGet(salesQuoteId: ref.recordId)`. Update the provider in the same file that builds `DocumentSourceImpl` (build `SalesQuotesApi(dio, appSerializers)` the way it builds the other two), and any other `DocumentSourceImpl(` construction found with `grep -rn "DocumentSourceImpl(" lib test`.
- [X] T004 [P] [US1] Extend `test/unit/core/documents/document_source_impl_test.dart`: the `salesQuote` kind requests `/api/v1/sales-quotes/{id}/document`; with no usable `Content-Disposition` the name is `cotizacion-00000123.pdf` for id 123; a server-provided name wins; a non-PDF body is `AppError.server()`.
- [X] T005 [P] [US1] Add the quote document method to the `methods` map in `test/unit/core/documents/generated_client_bytes_test.dart` (lines 17–25) so it is checked to return `Uint8List` and request bytes.
- [X] T006 [P] [US1] Extend `test/unit/core/documents/document_actions_test.dart` (the per-kind gates around lines 198–228): a sales-quotes reader can open `DocumentKind.salesQuote` and cannot open `saleTicket` or `cashCut`; a sales-orders-only reader cannot open `salesQuote`.
- [X] T007 [US1] Add these keys to `lib/l10n/app_es.arb` and `lib/l10n/app_en.arb`, then `flutter gen-l10n`: `documentSalesQuoteTitle` ("Cotización · {reference}", placeholder `reference`, next to `documentSalesOrderTitle`) and `salesQuoteViewDocumentAction` ("Ver cotización", next to the other `salesQuote…Action` keys, around line 867).
- [X] T008 [US1] In `lib/features/sales/presentation/quotes/quote_header_panel.dart`, change `_headerRow`'s `trailing` (the single `sales_quote_more_details_toggle` button, around lines 228–237) to a `Wrap` like `order_header_panel.dart:501–520`, spacing from `theme.spacing`. Add an `OutlinedButton.icon` (`Icons.description_outlined`, label `salesQuoteViewDocumentAction`, key `sales_quote_view_document_button`) before the toggle, shown only when `canOpenDocument(ref.watch(accessControlProvider), DocumentKind.salesQuote)`, and disabled while `ref.watch(pendingWritesProvider(salesQuoteWritesScope)) > 0`. Its handler is a `_viewDocument` method like `_viewPedido`: build the title with `documentSalesQuoteTitle(sale.id.toString().padLeft(8, '0'))`, await `resolveUnconfirmedEdits(context, ref, salesQuoteWritesScope)`, return if it is false or `!mounted`, then `ref.read(documentActionsProvider).preview(context, DocumentRef(kind: DocumentKind.salesQuote, recordId: sale.id, title: title))`. Import what `order_header_panel.dart` imports for the same names.
- [X] T009 [US1] Create `test/widget/features/sales/quote_screen_documents_test.dart`, modelled on `order_workspace_view_pedido_test.dart` (override `documentSourceProvider` and `documentOutputProvider` with the fakes from `test/unit/core/documents/document_fakes.dart`, access through a fixed `AuthState`) and the `pumpQuotesRouted` harness in `test/widget/features/sales/pos_test_harness.dart` (it takes `overrides:` and a `surface:` size; see `quote_screen_test.dart` for its use). Cases: the button shows for draft, confirmed and cancelled quotes with sales-quotes read; it is absent without it; it is disabled while `pendingWritesProvider(salesQuoteWritesScope)` is above zero; a tap fetches `kind == salesQuote`, `recordId` and title `Cotización · 0000NNNN`; a draft with unconfirmed typed text shows the keep/discard prompt first and "Seguir editando" does not fetch; a failing fetch shows the preview's error state with retry, and closing it leaves the quote screen unchanged (spec US1 scenario 4).
- [X] T010 [US1] Run `dart run build_runner build --delete-conflicting-outputs`, `flutter analyze`, and `flutter test test/unit/core/documents test/widget/features/sales/quote_screen_documents_test.dart test/widget/features/sales/quote_screen_test.dart`; all must pass.

**Checkpoint**: "Ver cotización" works on every quote. The feature could ship here as a partial delivery of mictlanix/mbe-roadmap#31.

---

## Phase 4: User Story 2 — Email a confirmed quote (P2)

**Goal**: a confirmed quote is emailed from a chip-based dialog, with a distinct message for each refusal, and phones get an overflow menu.

**Independent test**: confirm a quote, choose "Enviar por correo", select a chip and type another address, send, and see the snackbar and the delivered mail (quickstart M4–M11).

- [X] T011 [P] [US2] Create `lib/core/widgets/responsive_dialog.dart` with `ResponsiveDialogAction`, `ResponsiveDialog` and `showResponsiveDialog` exactly as in contracts C1. Tier comes from `LayoutBreakpoints.isCompact(context)` only. Wide: `Dialog` with title, scrollable body and trailing `[secondary] [primary]` row, width `min(maxWidth, screen − 80)`. Compact: `Dialog.fullscreen` with a top bar `[close] title … [primary as TextButton]`. `dismissible: false` sets `PopScope(canPop: false)` and disables the close control and secondary action. Copy the compact/wide switch from `document_preview_dialog.dart:80,116–125`; all spacing from `Theme.of(context).spacing`.
- [X] T012 [P] [US2] Create `test/widget/core/widgets/responsive_dialog_test.dart`: wide tier renders a `Dialog` with the action row; compact tier (surface under 600 px) renders `Dialog.fullscreen` with the primary action in the top bar and no bottom row; a `busy` action shows a spinner; with `dismissible: false`, Escape, back and a tap on the barrier do not pop, and the close control is disabled; a null `onPressed` disables the action.
- [X] T013 [US2] Register `responsive_dialog.dart` in `test/golden/core_widgets_golden_test.dart`: add it to `_coveredFiles` (the directory-scan test at lines 40–87 fails until it is covered or excluded with a reason), and add light/dark × narrow/wide goldens for a dialog with a short body and a busy primary action. Read `test/golden/README.md` first for how baselines are produced, then generate them as it says (`flutter test test/golden --update-goldens`), and review the four new PNGs by eye before keeping them.
- [X] T014 [P] [US2] Create `lib/features/sales/domain/quote_email.dart` with the freezed `QuoteEmailReceipt` (`List<String> recipients`, `DateTime sentAt`, plus a `fromResponse(QuoteEmailResponse)` factory like `lib/features/catalog/domain/entities/supplier_agreement.dart`'s) and `bool isPlausibleEmail(String)`: trim, at most 254 characters, matches `^[^@\s]+@[^@\s]+\.[^@\s]+$` (the server's pattern, research R8).
- [X] T015 [P] [US2] Create `test/unit/features/sales/quote_email_test.dart` for `isPlausibleEmail`: accepts `a@b.mx` and ` a@b.mx ` (trimmed); rejects `a@`, `@b.mx`, `a@b`, `a b@c.mx`, empty, and a 255-character address.
- [X] T016 [US2] Add `Future<QuoteEmailReceipt> email({required int quoteId, required List<String> recipients})` to `SalesQuoteRepository` in `lib/features/sales/domain/repositories/sales_quote_repository.dart`, with the doc comment from contracts C3 (throws `ServerError(409|502|503)`, `ValidationError`, `NetworkError`; never `CreditHoldError`).
- [X] T017 [US2] Implement `email` in `lib/features/sales/data/sales_quote_repository_impl.dart` with the generated `emailSalesQuoteApiV1SalesQuotesSalesQuoteIdEmailPost`, building `api.QuoteEmailRequest((b) => b.to = ListBuilder<String>(recipients))` (import `built_collection` as `delivery_order_repository_impl.dart:64` does), mapping with `QuoteEmailReceipt.fromResponse`, and rethrowing through `_toAppError` (`:277`), **not** `_toQuoteError`, so a 422 stays a `ValidationError`. Then fix every other implementer of the interface: `grep -rn "SalesQuoteRepository" test lib | grep -E "implements|extends|Mock|Fake"` and add the method to any hand-written fake.
- [X] T018 [P] [US2] Create `test/unit/features/sales/sales_quote_repository_email_test.dart` using the file's existing Dio stubbing style (see `test/unit/features/catalog/customer_repository_impl_test.dart`): the request body is `{"to": [...]}` to `/api/v1/sales-quotes/{id}/email`; the response maps to a receipt; 409, 502 and 503 map to `ServerError` with that `statusCode` and the server's `detail`; 422 maps to `ValidationError` (not `CreditHoldError`, even with a plain-string `detail`); no response maps to `NetworkError`.
- [X] T019 [US2] Add these keys to both `.arb` files (Spanish shown), then `flutter gen-l10n`; reuse the existing `retryButton` and `cancelButton`. `salesQuoteEmailAction` "Enviar por correo"; `salesQuoteMoreActionsTooltip` "Más acciones"; `salesQuoteEmailDialogTitle` "Enviar cotización {reference}"; `salesQuoteEmailRecipientsLabel` "Destinatarios"; `salesQuoteEmailOtherAddressLabel` "Otro correo"; `salesQuoteEmailAddAction` "Agregar"; `salesQuoteEmailSendAction` "Enviar"; `salesQuoteEmailSendingLabel` "Enviando…"; `salesQuoteEmailLimitHint` "Hasta 10 destinatarios."; `salesQuoteEmailCounter` "{count} de 10 destinatarios."; `salesQuoteEmailLimitReached` "10 de 10 destinatarios. No se pueden agregar más."; `salesQuoteEmailInvalidAddress` "No es un correo válido."; `salesQuoteEmailNoKnownAddresses` "Este cliente no tiene correos registrados."; `salesQuoteEmailSuggestionsLoading` "Cargando correos del cliente…"; `salesQuoteEmailSuggestionsFailed` "No se pudieron cargar los correos del cliente."; `salesQuoteEmailNotSendable` "La cotización ya no se puede enviar."; `salesQuoteEmailMailRefused` "El servidor de correo rechazó el envío. Intenta de nuevo o descarga la cotización."; `salesQuoteEmailMailUnavailable` "El envío de correo no está disponible. Descarga la cotización para enviarla."; `salesQuoteEmailSentMessage` "Cotización enviada a {recipients}". Declare the `{reference}`, `{count}` and `{recipients}` placeholders like the existing parameterised keys. Write natural English for the `app_en.arb` values.
- [X] T020 [US2] Create `lib/features/sales/presentation/quotes/quote_email_controller.dart` per data-model.md and contracts C4: `RecipientOrigin`, `RecipientChip`, a freezed `QuoteEmailState`, the result enums `RecipientToggleResult` (`toggled`, `limitReached`) and `AddTypedResult` (`added`, `selectedExisting`, `invalid`, `limitReached`), the `QuoteEmailFailure` enum, `quoteEmailFailureOf(AppError)` (409 → `notSendable`, `ValidationError` → `invalidRecipients`, 502 → `mailRefused`, 503 → `mailUnavailable`, else `other`), and an autoDispose `@riverpod` `Notifier` family keyed by quote id with `seed`, `toggle`, `addTyped`, `send` and `clearFailure`. Rules: `seed` merges non-blank emails by lower-case key (contacts first, first occurrence wins, never removes chips or changes the selection); `toggle` refuses an 11th selection; `addTyped` returns `invalid`, `selectedExisting`, `limitReached` or `added` as in the data model; a deselected typed chip stays; `send` is a no-op unless `canSend`, sets `sending`, calls `salesQuoteRepositoryProvider`'s `email`, keeps the selection on failure, latches `sawNotSendable` on 409, and always clears `sending`. Follow the structure of an existing local-state notifier such as `lib/features/catalog/presentation/customer_discount_dialog_controller.dart`.
- [X] T021 [P] [US2] Create `test/unit/features/sales/quote_email_controller_test.dart` with a mocktail `SalesQuoteRepository`: seeding order and dedupe (a shared address shows the contact's name), blank emails skipped, re-seeding keeps the selection and typed chips, toggle on and off, the limit at 10, `addTyped` for each result, the typed chip staying when deselected, `send` passing only selected addresses in chip order, a second `send` while sending doing nothing, each `AppError` mapping to its failure with the selection kept, and 409 latching `sawNotSendable`.
- [X] T022 [US2] Create `lib/features/sales/presentation/quotes/quote_email_dialog.dart` with the sealed `QuoteEmailOutcome` (`sent(QuoteEmailReceipt)`, `staleQuote`) and `showQuoteEmailDialog(BuildContext, {required Sale quote})` built on `showResponsiveDialog`, drawn as in wireframes.md "Dialog: Enviar cotización por correo". The title is `salesQuoteEmailDialogTitle` with the same reference the header strip shows, `quote.serial?.toString() ?? '#${quote.provisionalReference}'` (research R12), not the padded id the document title uses. Contents: the `FilterChip`s in a token-spaced `Wrap` with check mark and the keys from contracts C4 (label "owner · address", owner ellipsized before address); the suggestions come from `saleCustomerControllerProvider(quote.customer)` and call `seed` when they resolve (check the field names for the contact and fiscal-recipient owner name in `contact.dart` and `taxpayer_recipient.dart`), with the loading, failed-with-`retryButton` (invalidates the provider) and no-addresses states; the typed field with Add and Enter; the hint and counter text; the failure `ErrorBanner` using research R5 (409, 502, 503 re-wrap as `AppError.server(statusCode:, message: <localized cause>)`; 422 and other pass the original error); Send disabled unless `canSend`, showing `salesQuoteEmailSendingLabel` with a spinner while sending; `dismissible: false` while sending. Closing returns `staleQuote` if `sawNotSendable`, `sent(receipt)` after a success, else null.
- [X] T023 [P] [US2] Create `test/widget/features/sales/quote_email_dialog_test.dart` covering every wireframe state: chips with none selected and Send disabled; selecting and deselecting; a typed address becoming a selected chip; an invalid address showing the field error with no chip; the limit message at 10; no known addresses; suggestions loading and failed (retry reloads) with typing still working; sending (controls disabled, Escape does nothing); each failure banner text with the selection kept; success popping `sent`; 409 then close popping `staleQuote`; the title shows the quote's serial. Also assert the chip `Wrap`'s `spacing` and `runSpacing` equal the theme's spacing token (§V, no literals). Override `salesQuoteRepositoryProvider` and the customer provider.
- [X] T024 [US2] In `quote_header_panel.dart`, add the "Enviar por correo" `OutlinedButton.icon` (`Icons.email_outlined`, label `salesQuoteEmailAction`, key `sales_quote_email_button`) after "Ver cotización", shown only when `access.can(SystemObject.salesQuotes, AccessRight.read)` and `sale.status == SaleStatus.completed`. On tap: capture `ScaffoldMessenger.of(context)` and the quote controller notifier first, `await showQuoteEmailDialog(context, quote: sale)`, then for `sent` show a `SnackBar` with `salesQuoteEmailSentMessage(receipt.recipients.join(', '))`, and for `staleQuote` call `ref.read(quoteEditorControllerProvider(sale.id).notifier).refresh()`; guard with `mounted`.
- [X] T025 [US2] In `quote_header_panel.dart`, add the compact tier (contracts C5): when `LayoutBreakpoints.isCompact(context)`, the trailing slot is "Más detalles" plus a `MenuAnchor` whose trigger is `IconButton(Icons.more_vert)` (tooltip `salesQuoteMoreActionsTooltip`, key `sales_quote_more_actions_button`) holding one `MenuItemButton` per available action (leading icon, keys suffixed `_menu_item`), with the same gates, disabled state and handlers as the buttons (share the handlers, do not duplicate them). No menu at all when neither action is available. Other tiers keep the buttons. Follow `user_menu_button.dart` for the open/close toggle.
- [X] T026 [US2] Extend `test/widget/features/sales/quote_screen_documents_test.dart`: "Enviar por correo" shows only for a confirmed quote with sales-quotes read (including a confirmed quote with `hasExpired`), and is absent for draft, cancelled and without the privilege; a successful send shows the snackbar listing the recipients; a 409 then closing refreshes the quote (the repository's `getById` is called again); at a compact width the buttons are replaced by the ⋮ menu, which lists both items on a confirmed quote, only "Ver cotización" on a draft, and does not exist when neither action is available; "Más detalles" stays a button on compact. Use `pumpQuotesRouted(surface: const Size(500, 1600))` for the compact cases. Finally, measure the header control band (constitution §VI, following `test/widget/features/sales/order_header_density_test.dart`): on a wide surface, "Ver cotización", "Enviar por correo" and "Más detalles" share one vertical center; on compact, "Más detalles" and the ⋮ trigger share one; and the space above the band's controls equals the space below them.
- [X] T027 [US2] Run `dart run build_runner build --delete-conflicting-outputs`, `flutter analyze`, and `flutter test test/unit test/widget test/golden`; all must pass.

**Checkpoint**: a confirmed quote can be emailed from a wide or phone-sized screen.

---

## Phase 5: Polish & cross-cutting

- [X] T028 [P] Create `test/integration/quote_pdf_email_flow_test.dart` following `test/integration/document_printing_flow_test.dart`: find a quote at runtime and fetch its document, checking it starts with `%PDF-` and that the file name starts with `cotizacion-`; then, only when `MBE_QUOTE_EMAIL_TO` is defined, email a confirmed quote to that address and expect a receipt naming it. Skip, never fail, when no quote is found or the variable is unset. Run it as `flutter test test/integration/quote_pdf_email_flow_test.dart --dart-define-from-file=.env --dart-define=MBE_QUOTE_EMAIL_TO=<inbox>` (see the POS integration-test notes: use pattern `clavo` if a product search is needed).
- [X] T029 [P] Run the existing localization parity test (find it with `grep -rl "app_en.arb" test`) and confirm every key added in T007 and T019 exists in both files; remove any key left unused.
- [X] T030 Run the full gate: `flutter analyze && flutter test test/unit test/widget test/golden`. Confirm `dart format --set-exit-if-changed` on only the files this branch changed.
- [ ] T031 Work through quickstart.md M1–M12 in Chrome, recording which mbe-api deployment was used. M8 needs mail configured there and M9 needs it unconfigured; if either deployment is unavailable, say so in the PR rather than ticking the box. **Progress 2026-10-25:** M1–M7, M9 and M11 automated in `integration_test/quote_pdf_email_quickstart_test.dart` and passing against the local mbe-api (quickstart.md "Automated run"). Still open: M8 (needs mail and an inbox), M10, M12.
- [ ] T032 When the user asks for the PR, write its description with a "Roadmap" section reading `Closes mictlanix/mbe-roadmap#31`, and list the manual checks run and any left undone (T031).

---

## Dependencies & execution order

- **Phase 1** → **Phase 3 (US1)** → **Phase 4 (US2)** → **Phase 5**.
- **US2 depends on US1 only through `quote_header_panel.dart` and the shared test file**: T024 and T025 edit the header after T008, and T026 extends T009's file. US2's other work (T011–T023) touches no US1 file and can start once Phase 1 is done.
- T002 and T003 must both finish before the build compiles, because both switches over `DocumentKind` are exhaustive.
- T016 → T017 → T018. T014 comes before T016, because the interface returns `QuoteEmailReceipt`.
- T019 (l10n) comes before T022, T024 and T025, which use its keys.
- T020 needs T014 (the receipt and `isPlausibleEmail`) and T016–T017 (the repository's `email`). T020 comes before T022; T022 before T024.
- T024 before T025: the menu reuses the buttons' handlers.
- T013 (goldens) follows T011.
- Phase 5 comes last, because the live and quickstart runs need everything in place.

## Parallel opportunities

- **US1:** T004, T005 and T006 are independent test files once T002 and T003 exist.
- **US2:** T011 and T014 can start together. T012 and T015 can then run in parallel with the repository work (T016–T018). T021 and T023 can be written in parallel once T020 and T022 exist.
- **Phase 5:** T028 and T029 are independent.

## Implementation strategy

- **MVP:** Phases 1–3. This delivers "Ver cotización", which replaces the legacy Print / PDF action and has no mail-server dependency. Roadmap#31 isn't finished at this point, though: its other legacy actions are send email and the sent confirmation.
- **Release:** the full scope is Phases 1–5, shipped in one PR (`Closes mictlanix/mbe-roadmap#31`).
- **Order inside US2:** build the shared dialog and the domain/data layers (T011–T018) before the controller and dialog, so the rules are unit-tested before any UI exists.
- **Risks to watch:**
  - The golden baselines (T013): this repo has no CI for goldens (see the spec 028 note about T047), so generate them as `test/golden/README.md` says and look at them.
  - The mail server: M8 and M9 depend on the deployment's SMTP configuration, which mbe-ui doesn't control.

## Requirement coverage

| Requirement | Tasks |
|---|---|
| FR-001 "Ver cotización" in any state | T008, T009 |
| FR-002, FR-003, FR-004 shared preview, server bytes, file name | T002, T003, T004, T005 |
| FR-005 resolve pending edits first | T008, T009 |
| FR-006 email only for a confirmed quote | T024, T026 |
| FR-007 to FR-010 chips, order, limits, validation | T014, T015, T020, T021, T022, T023 |
| FR-009a typed address handling | T020, T021 |
| FR-011 no second submit, not dismissible | T011, T012, T020, T022, T023 |
| FR-012 success message lists recipients | T022, T024, T026 |
| FR-013 distinct failure messages | T017, T018, T019, T020, T022, T023 |
| FR-014 refresh after "no longer sendable" | T020, T022, T024, T026 |
| FR-015 header placement | T008, T024 |
| FR-015a phone overflow menu | T025, T026 |
| FR-015b shared responsive dialog | T011, T012, T013, T022 |
| FR-016 read-gated, no new privilege | T006, T008, T024 |
| FR-017 Spanish and English | T007, T019, T029 |
| SC-001 to SC-003 | T031 (M1, M8, M9), T018, T021 |
| SC-004 closes roadmap#31 | T032 |
