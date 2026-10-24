# Research: Quotation PDF and Email

**Feature**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md) | **Date**: 2026-10-24

All of the spec's open questions were settled in its Clarifications sessions and the
wireframe review, so nothing here resolves a NEEDS CLARIFICATION. Each entry instead fixes
how one requirement maps onto code that already exists.

## R1 — The backend is done; codegen is current

- **Decision**: No mbe-api change and no codegen run.
- **Facts**:
  - mbe-api spec 024 (PR #254, merged) ships `GET /sales-quotes/{id}/document` and
    `POST /sales-quotes/{id}/email`.
  - The generated client already has both methods:
    - `printSalesQuoteDocumentApiV1SalesQuotesSalesQuoteIdDocumentGet` (`sales_quotes_api.dart:920`)
      returns `Uint8List` and already sets `ResponseType.bytes`.
    - `emailSalesQuoteApiV1SalesQuotesSalesQuoteIdEmailPost` (`:598`) takes
      `QuoteEmailRequest{to}` and returns `QuoteEmailResponse{recipients, sentAt}`.
- **Server rules the UI relies on** (`mbe-api/app/api/v1/endpoints/sales_quotes.py:101-106`,
  `app/schemas/sales_quote.py:123-138`):
  - Both endpoints need only `SALES_QUOTES` Read.
  - Email is refused with 409 unless the quote is confirmed.
  - Recipients are trimmed, deduplicated case-insensitively, and checked against
    `^[^@\s]+@[^@\s]+\.[^@\s]+$` with a 254-character limit; 1–10 per send, else 422.
  - A refusal from the mail server is 502; unconfigured mail is 503.
- **Alternatives considered**: none. Constitution §III forbids hand-written DTOs.

## R2 — The quote document is a fourth `DocumentKind`

- **Decision**:
  - Add `DocumentKind.salesQuote(SystemObject.salesQuotes)`.
  - Its `fallbackFilename` is `cotizacion-%08d.pdf`, matching the server's name.
  - `DocumentSourceImpl` gains an `api.SalesQuotesApi` and a switch arm for the new kind.
- **Rationale**: spec 044 built `core/documents/` so that a new PDF costs:
  - one enum value;
  - two exhaustive switch arms (`document_kind.dart:33`, `document_source_impl.dart:37`), which
    fail to compile until they are written;
  - one entry in `test/unit/core/documents/generated_client_bytes_test.dart:17-25`.

  Preview, print, download, zoom, error/retry and the access re-check all come free, which
  covers FR-002 to FR-004.
- **Title**: `documentSalesQuoteTitle` = "Cotización · {reference}", with the reference
  being the quote id padded to 8 digits. This matches the pedido title and the server's
  filename, and a draft has no serial anyway.
- **Alternatives considered**: a quote-specific preview path. Rejected because it
  duplicates the shared module, which is what spec 044 was built to prevent.

## R3 — "Ver cotización" copies "Ver pedido"

- **Decision**: In `QuoteHeaderPanel._headerRow`'s `trailing` slot, add an
  `OutlinedButton.icon` (`Icons.description_outlined`, key `sales_quote_view_document_button`). It is:
  - shown only when `canOpenDocument(access, DocumentKind.salesQuote)` (FR-001, FR-016);
  - disabled while `pendingWritesProvider(salesQuoteWritesScope) > 0`;
  - on tap, it awaits `resolveUnconfirmedEdits(context, ref, salesQuoteWritesScope)` and
    then calls `documentActionsProvider.preview(...)` (FR-005).
- **Rationale**: this is exactly `OrderHeaderPanel._viewPedido` (`order_header_panel.dart:136-159`,
  `:501-520`). The quote screen already has the write scope
  (`sales_quote_write_scope.dart`) and the resolver
  (`unconfirmed_edits_resolver.dart:30`).
- **States**: the button is offered for every `SaleStatus`. A confirmed or cancelled quote
  never has pending writes, so the gate only ever bites on drafts.

## R4 — The email call goes through the quote repository

- **Decision**: add
  `Future<QuoteEmailReceipt> email({required int quoteId, required List<String> recipients})`
  to `SalesQuoteRepository`. The implementation builds
  `api.QuoteEmailRequest((b) => b.to = ListBuilder<String>(recipients))` and maps the
  response to a `freezed` `QuoteEmailReceipt`.
- **Error mapping**: use `_toAppError` (`sales_quote_repository_impl.dart:277`), **not**
  `_toQuoteError`. The latter turns a 422 with a plain-string `detail` into `CreditHoldError`,
  which is right for quote writes and wrong here, where a 422 means bad recipients.
  `mapDioException` then gives:

  | Status | `AppError` |
  |---|---|
  | 422 | `ValidationError(fieldErrors, detail)` |
  | 409, 502, 503 | `ServerError(statusCode, detail)` |
  | no response | `NetworkError` |
  | 401 | `AuthError` (the session interceptor handles it) |

- **Rationale**: the repository already owns `SalesQuotesApi` (`:22`), so there is no new
  provider. Principle I is kept: presentation sees a domain entity and `AppError`.
- **Alternatives considered**: putting the call in `core/documents/`. Rejected because
  email is a quote action, not a document-rendering concern, and no other document is
  emailed yet.

## R5 — Mapping each failure to its message (FR-013)

- **Decision**: a pure function `quoteEmailFailureOf(AppError) → QuoteEmailFailure`
  classifies the error:
  - `notSendable` (409)
  - `invalidRecipients` (422)
  - `mailRefused` (502)
  - `mailUnavailable` (503)
  - `other` (anything else)
- **Display**: the dialog always renders through the shared `ErrorBanner` (§III):
  - For `notSendable`, `mailRefused` and `mailUnavailable` it passes
    `AppError.server(statusCode: s, message: <localized cause text>)`. The banner shows its
    generic server headline with our cause line beneath it, so each cause reads differently
    without a bespoke banner.
  - For `invalidRecipients` and `other` it passes the original error unchanged, so the
    server's reason or the network text appears as everywhere else.
- **Rationale**: `ErrorBanner` already renders headline + `message` (`error_banner.dart:84-108`).
  Re-wrapping keeps a single error widget and still meets "a distinct message for each case".
- **Alternatives considered**:
  - Adding an `overrideMessage` parameter to `ErrorBanner`. Rejected because it is a
    shared-widget API change for one caller.
  - A bespoke `MaterialBanner` per cause. Rejected because it breaks §III's
    single-error-surface rule.

## R6 — Recipient suggestions come from the quote's customer

- **Decision**: read `saleCustomerControllerProvider(sale.customer)`
  (`capture/sale_customer_controller.dart:14-17`). Its `Customer` embeds the full `contacts`
  (with `email` nullable) and `taxpayers` (with `email` required) lists, from a single
  `GET /customers/{id}`. The dialog takes the addresses from those two lists:
  - It drops null or blank emails.
  - It trims each address and compares them by lower case.
  - It orders them contacts first, then fiscal recipients, each in server order.
  - For a duplicated address, the first occurrence wins, so the contact's name is used (FR-008).
- **Access**: the server accepts `GET /customers/{id}` for `CUSTOMERS`, `SALES_ORDERS`,
  `SALES_QUOTES` or `POS` Read (`customers.py:34-39`), so a quote reader can always load
  it. No client gate is added.
- **Rationale**: the quote screen already watches this provider for its customer bar
  (`customer_bar.dart:403`), so the dialog usually opens with the data cached. The
  standalone `/contacts` and `/taxpayer-recipients` lists cannot filter by customer.
- **Load states**: the dialog renders the provider's `AsyncValue` as loading, error with a
  retry (invalidating the provider), empty, or chips. Typing an address works in every one
  of these states (wireframes: loading/failed/no known addresses).

## R7 — Recipient state is a local `Notifier`

- **Decision**: add `QuoteEmailController`, an autoDispose `Notifier` family keyed by
  quote id, under `features/sales/presentation/quotes/`. It holds the immutable
  `QuoteEmailState` described in [data-model.md](./data-model.md) and exposes these
  methods:
  - `seed(suggestions)`
  - `toggle(key)`
  - `addTyped(text) → AddResult`
  - `send()`
  - `clearFailure()`

  All the rules live here and are unit-tested without widgets:
  - toggling a chip;
  - the 10-recipient limit;
  - a typed address that duplicates an existing chip selects that chip instead;
  - a typed chip stays when deselected;
  - recipient validation;
  - the in-flight guard.
- **Rationale**: §II says local UI state uses `Notifier`. The send is a one-shot command
  rather than server-sourced data, so an `AsyncNotifier` would add nothing.
- **Seeding**: the dialog calls `seed` when the suggestions first resolve. Seeding is
  idempotent: it merges new suggestions without clearing the selection or the typed chips,
  so a late load or a retry never drops what the user picked.

## R8 — Client-side address check copies the server's

- **Decision**: add a domain helper `isPlausibleEmail(String)` that trims, checks for at
  most 254 characters, and matches `^[^@\s]+@[^@\s]+\.[^@\s]+$`. That is the server's own
  pattern (R1), so the client never rejects an address the server would accept, or the
  reverse. It lives in `lib/features/sales/domain/quote_email.dart` next to the receipt
  entity.
- **Rationale**: no email validator exists in `lib/`. The contact form relies on the
  server's field error, but here a bad address must be stopped before it becomes a chip
  (FR-010). A stricter RFC parser would disagree with the server.
- **Alternatives considered**: putting it in `CatalogFieldValidators`. Rejected because
  that class is catalog-form specific, and no catalog form asked for it.

## R9 — The new shared `ResponsiveDialog` (FR-015b)

- **Decision**: add `lib/core/widgets/responsive_dialog.dart` with:
  - a `ResponsiveDialog` widget taking `title`, `body`, `actions` (a primary action plus
    an optional secondary one), `dismissible` and `maxWidth` (default 560);
  - a `showResponsiveDialog<T>(context, builder)` helper.

  Its layout follows `LayoutBreakpoints.isCompact(context)`:
  - **Wide**: `Dialog` → title row, scrollable body, trailing action row (secondary, then
    primary), width `min(maxWidth, screen − 80)`.
  - **Compact**: `Dialog.fullscreen` → top bar with close (leading), title, and the primary
    action (trailing); scrollable body; no bottom action row.
  - When `dismissible` is false, it sets `PopScope(canPop: false)`, disables the close
    control, and makes the barrier non-dismissible (FR-011).
- **Rationale**: the user chose a shared component (wireframe review, OQ3). The only
  existing compact/full-screen switch is private to `document_preview_dialog.dart:80,116-125`.
  This widget generalises that pattern for forms, leaving the preview untouched (migrating
  it is out of scope).
- **Golden obligation**: `test/golden/core_widgets_golden_test.dart:40-87` fails unless
  every `lib/core/widgets/*.dart` file is covered or excluded. This widget is covered with
  light/dark × narrow/wide goldens.
- **Alternatives considered**: `AlertDialog` plus a separate `Dialog.fullscreen` branch in
  the feature. The user rejected that in the wireframe review.

## R10 — Phone overflow menu in the quote header (FR-015a)

- **Decision**: when `LayoutBreakpoints.isCompact(context)` is true, `QuoteHeaderPanel`'s
  trailing slot renders "Más detalles" plus a `MenuAnchor` whose trigger is an
  `IconButton(Icons.more_vert)` with tooltip `salesQuoteMoreActionsTooltip`. It holds one
  `MenuItemButton` per available action (leading icon, same keys suffixed `_menu_item`),
  with the same gates and disabled state as the buttons. On wider tiers both actions render
  as `OutlinedButton.icon`. If the user lacks both actions, there is no menu at all.
- **Rationale**: `MenuAnchor` + `MenuItemButton` is the repo's existing menu idiom
  (`user_menu_button.dart:27`, `open_sales_selector.dart:52`). `buildCatalogRowActions`'s
  `PopupMenuButton` is for row actions only and assumes an Edit icon, so it does not fit.
- **Constitution**: §VI requires screen-level actions to be body
  `FilledButton`/`OutlinedButton`s and only allows an overflow menu for list rows. This is a
  compact-only deviation the user asked for, recorded in the plan's Complexity Tracking.

## R11 — Dialog result, snackbar and refresh (FR-012, FR-014)

- **Decision**: `showQuoteEmailDialog(context, sale)` returns `Future<QuoteEmailOutcome?>`,
  which is one of:
  - `sent(receipt)`: the caller shows a `SnackBar` reading
    `salesQuoteEmailSentMessage(recipients.join(', '))`, wrapping, using the
    `ScaffoldMessenger` captured before the dialog opened (`apply_profile_dialog.dart:118`
    idiom).
  - `staleQuote`: the dialog was closed after a 409. The caller calls
    `quoteEditorControllerProvider(id).notifier.refresh()`, the same refresh
    `quote_screen.dart:150-167` runs after a refused cancel.
  - `null`: cancelled with no 409 seen.
- **Rationale**: this keeps the dialog free of the quote screen's controller and testable
  on its own.

## R12 — "Enviar por correo" placement and gate

- **Decision**: render "Enviar por correo" (`OutlinedButton.icon`, `Icons.email_outlined`,
  key `sales_quote_email_button`) after "Ver cotización" in the same trailing `Wrap`. It is
  shown only when:
  - `access.can(SystemObject.salesQuotes, AccessRight.read)`;
  - `sale.status == SaleStatus.completed`;

  which covers FR-006 and FR-016. `SaleStatus.paid` never occurs for quotes (the header
  already maps it to "Confirmada"), and is treated as not sendable so the client never
  offers what the server would refuse.
- **Rationale**: the user chose the header strip (wireframe review, OQ1). The totals-bar
  `_secondaryAction` row is left alone.

## R13 — Tests

| Layer | File | Covers |
|---|---|---|
| Unit | `test/unit/core/documents/document_source_impl_test.dart` (extend) | quote route, `cotizacion-` fallback, Content-Disposition |
| Unit | `test/unit/core/documents/generated_client_bytes_test.dart` (extend) | quote document method returns bytes |
| Unit | `test/unit/core/documents/document_actions_test.dart` (extend) | `salesQuote` gate: quote reader yes, order-only reader no |
| Unit | `test/unit/features/sales/sales_quote_repository_email_test.dart` (new) | request body, receipt mapping, 409/422/502/503/network → `AppError` |
| Unit | `test/unit/features/sales/quote_email_controller_test.dart` (new) | merge/dedupe/order, toggle, limit, typed add, validation, in-flight guard, failure classification |
| Unit | `test/unit/features/sales/quote_email_test.dart` (new) | `isPlausibleEmail` parity cases with the server regex |
| Widget | `test/widget/core/widgets/responsive_dialog_test.dart` (new) | wide vs compact shell, non-dismissible while busy |
| Golden | `test/golden/core_widgets_golden_test.dart` (extend) | `ResponsiveDialog` light/dark × narrow/wide |
| Widget | `test/widget/features/sales/quote_screen_documents_test.dart` (new) | buttons by state/privilege, compact menu, draft pending-write gate, preview fetch ref |
| Widget | `test/widget/features/sales/quote_email_dialog_test.dart` (new) | every wireframe state, success snackbar, 409 → refresh |
| Integration | `test/integration/quote_pdf_email_flow_test.dart` (new, live) | fetch a quote PDF; email only when `MBE_QUOTE_EMAIL_TO` is defined |

- Fakes reuse `test/unit/core/documents/document_fakes.dart`.
- Access follows `order_workspace_view_pedido_test.dart:141-142` (a fixed `AuthState` with privileges).
- The live email step is opt-in so a run never mails a real customer, and it needs mail
  configured on the deployment (spec Assumptions).

## R14 — Localization

New keys, in both `app_es.arb` and `app_en.arb`:
- **Document title**: `documentSalesQuoteTitle`.
- **Header actions**:
  - `salesQuoteViewDocumentAction` "Ver cotización"
  - `salesQuoteEmailAction` "Enviar por correo"
  - `salesQuoteMoreActionsTooltip`
- **Dialog text**:
  - `salesQuoteEmailDialogTitle` (`{reference}`)
  - `salesQuoteEmailRecipientsLabel`
  - `salesQuoteEmailOtherAddressLabel`
  - `salesQuoteEmailAddAction`
  - `salesQuoteEmailSendAction`
  - `salesQuoteEmailSendingLabel`
  - `salesQuoteEmailLimitHint`
  - `salesQuoteEmailCounter` (`{count}`)
  - `salesQuoteEmailLimitReached`
  - `salesQuoteEmailInvalidAddress`
  - `salesQuoteEmailNoKnownAddresses`
  - `salesQuoteEmailSuggestionsLoading`
  - `salesQuoteEmailSuggestionsFailed`
- **Failure causes**:
  - `salesQuoteEmailNotSendable`
  - `salesQuoteEmailMailRefused`
  - `salesQuoteEmailMailUnavailable`
- **Success**: `salesQuoteEmailSentMessage` (`{recipients}`).

That is about 22 keys, named `salesQuote<Thing>` like the screen's existing keys
(`app_es.arb:867-892`). The existing `retryButton` ("Reintentar", `:118`) and
`cancelButton` ("Cancelar", `:214`) are reused.
