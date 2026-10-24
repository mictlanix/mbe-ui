# Implementation Plan: Quotation PDF and Email

**Branch**: `053-quote-pdf-email` | **Date**: 2026-10-24 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/053-quote-pdf-email/spec.md`, covering
mictlanix/mbe-roadmap#31. It consumes mbe-api spec 024 (PR #254). Screens:
[wireframes.md](./wireframes.md).

## Summary

The quote screen gains two header actions.

**"Ver cotización"** (every state):
- It is a fourth `DocumentKind` in the shared `core/documents/` module from spec 044, so
  preview, print, download and error/retry come with no new UI.
- It copies "Ver pedido": it waits for in-flight writes and resolves unconfirmed text first.

**"Enviar por correo"** (confirmed quotes only):
- It opens a new shared `ResponsiveDialog`: a regular dialog on wide screens, full screen on
  phones.
- Recipients are `FilterChip`s built from the quote customer's contact and fiscal-recipient
  emails, plus typed addresses. The selected chips are the recipients.
- The send is a new `SalesQuoteRepository.email` call. Each server refusal (409, 422, 502,
  503) gets its own message through the shared `ErrorBanner`.
- Success closes the dialog with a snackbar listing the recipients. A 409 refreshes the
  quote when the dialog closes.

On phones, both actions sit behind an overflow menu in the header.

No mbe-api work or codegen is needed: both endpoints and their client methods already exist.

## Technical Context

**Language/Version**: Dart `^3.10.3`, Flutter 3.44.x stable (unchanged)

**Primary Dependencies**: Existing only. These are `dio`, Riverpod (+ `riverpod_generator`),
`freezed`, the generated `mbe_api_client`, `printing` (via `core/documents/`), and
`flutter_localizations` / `intl`. No new packages.

**Storage**: None. The PDF is held in memory while previewed; recipients are dialog state (§VII).

**Testing**:
- `flutter_test` + `mocktail` unit tests, with the dio adapter stubbed as in
  `document_source_impl_test.dart`.
- Widget tests with `ProviderScope` overrides (`documentSourceProvider`,
  `documentOutputProvider`, `salesQuoteRepositoryProvider`, `authProvider`).
- Goldens for the new core widget.
- One live `test/integration/` flow, where the email step is opt-in.

**Target Platform**: Web in desktop Chrome first. Android and desktop use the same code.

**Project Type**: Flutter client application, feature-first layered

**Performance Goals**:
- SC-001: the document reaches the screen in one action. This is the existing preview
  path, about 3 s as in spec 044.
- SC-002: under 30 s from open to sent. This is dominated by synchronous SMTP on the server.

**Constraints**:
- No new `SystemObject`; both actions are gated by `salesQuotes` Read, matching the server.
- No mbe-api changes (§III).
- `AppBar.actions` stays empty.
- All spacing comes from tokens.
- The client address check must match the server's regex exactly (research R8).

**Scale/Scope**:
- **New source files (5)**:
  - `core/widgets/responsive_dialog.dart`
  - `features/sales/domain/quote_email.dart` (+ `.freezed.dart`)
  - `features/sales/presentation/quotes/quote_email_controller.dart` (+ `.g.dart`)
  - `features/sales/presentation/quotes/quote_email_dialog.dart`
- **Edited source files (6)**:
  - `document_kind.dart`
  - `document_source_impl.dart`
  - `sales_quote_repository.dart`
  - `sales_quote_repository_impl.dart`
  - `quote_header_panel.dart`
  - the two `.arb` files (about 22 keys)
- **Tests**: 6 new files and 4 extended (research R13).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Verdict | How |
|---|---|---|
| **I. Feature-first layering** | Pass | Domain (`QuoteEmailReceipt`, `isPlausibleEmail`, repository interface) is in `features/sales/domain`, data in `features/sales/data`, and the dialog and controller in `features/sales/presentation/quotes`. The shared dialog is in `core/widgets`, and the document kind extends `core/documents`. Presentation never imports `data/` except for provider symbols, following the repo's existing practice (spec 044 plan, §I row). |
| **II. Riverpod** | Pass | `QuoteEmailController` is a codegen `Notifier` family holding local UI state (§II: local state → `Notifier`). Suggestions come from the existing `saleCustomerControllerProvider` `AsyncNotifier`. Repositories stay providers, so tests override them. |
| **III. Contract-driven API** | Pass | Uses the two generated methods as emitted, and `QuoteEmailResponse` is mapped to a `freezed` entity. Errors go through `_toAppError`/`mapDioException` to shared `AppError` types and render in the shared `ErrorBanner` (research R5). **No mbe-api change needed**: spec 024 has shipped and the client is current (R1). |
| **IV. Deny-by-default RBAC** | Pass | `DocumentKind.salesQuote` carries the `salesQuotes`/read gate, and the email action checks the same. Both are absent, not disabled, without it. No new `SystemObject`. |
| **V. Material 3 design system** | Pass | Uses `Dialog`/`Dialog.fullscreen`, `FilterChip`, `OutlinedButton.icon`, `FilledButton`, `MenuAnchor`, `SnackBar` and `ErrorBanner`. Spacing comes from `Theme.of(context).spacing`, not the pricing screen's literal `8`. Strings are in `.arb` for es-MX and en. No date or number is formatted (`sentAt` is not displayed). |
| **VI. Desktop/web-first, compact-ready** | **Pass with one recorded deviation** | Breakpoints come only from `LayoutBreakpoints`. The new dialog is a shared `core/widgets/` component with goldens. On wide tiers the header actions are body `OutlinedButton`s, per the rule. **On compact they sit in an overflow menu**, which §VI permits only for list rows; see Complexity Tracking. |
| **VII. Online-only, server-rendered** | Pass | The PDF is the server's bytes through the existing preview. Email is rendered and sent by the server. Nothing is cached. |
| **Stack** | Pass | No new dependency. |
| **Quality gates** | Pass | Unit (repository, controller, validator, document kind), widget (shared dialog, quote screen, email dialog), golden, and one live integration flow. The "mbe-api changed" step is satisfied: no codegen, the `QuoteEmailReceipt` mapping is added, and there is no RBAC table change. |

**Post-design re-check** (after Phase 1): still passing, with the one recorded deviation.
- The design adds a single shared widget (`ResponsiveDialog`), which the user chose in the
  wireframe review (OQ3).
- Its only caller today is the email dialog. `DocumentPreviewDialog` keeps its own frame;
  migrating it is out of scope.
- No amendment is needed. If phone-tier overflow menus for screen-level actions recur,
  that is the time to amend §VI with the criterion. This plan does not.

## Project Structure

### Documentation (this feature)

```text
specs/053-quote-pdf-email/
├── spec.md
├── wireframes.md
├── plan.md                         # this file
├── research.md                     # Phase 0 (R1–R14)
├── data-model.md                   # Phase 1
├── contracts/
│   ├── consumed-endpoints.md       # E1 document, E2 email, E3 customer
│   └── ui-contracts.md             # C1 ResponsiveDialog … C5 header actions
├── quickstart.md                   # Phase 1: validation guide
├── checklists/requirements.md
└── tasks.md                        # Phase 2 (/speckit-tasks — not created here)
```

### Source Code (repository root)

```text
lib/core/widgets/responsive_dialog.dart                             # NEW  C1
lib/core/documents/domain/document_kind.dart                        # EDIT salesQuote + fallback name
lib/core/documents/data/document_source_impl.dart                   # EDIT SalesQuotesApi + switch arm

lib/features/sales/domain/quote_email.dart                          # NEW  QuoteEmailReceipt, isPlausibleEmail
lib/features/sales/domain/repositories/sales_quote_repository.dart  # EDIT email()
lib/features/sales/data/sales_quote_repository_impl.dart            # EDIT email() via _toAppError
lib/features/sales/presentation/quotes/quote_email_controller.dart  # NEW  state, rules, failure classification
lib/features/sales/presentation/quotes/quote_email_dialog.dart      # NEW  showQuoteEmailDialog → QuoteEmailOutcome
lib/features/sales/presentation/quotes/quote_header_panel.dart      # EDIT trailing actions, compact menu
lib/l10n/app_es.arb, app_en.arb (+ generated app_localizations*)    # EDIT ~22 keys

test/unit/core/documents/document_source_impl_test.dart             # EXTEND
test/unit/core/documents/generated_client_bytes_test.dart           # EXTEND
test/unit/core/documents/document_actions_test.dart                 # EXTEND
test/unit/features/sales/sales_quote_repository_email_test.dart     # NEW
test/unit/features/sales/quote_email_controller_test.dart           # NEW
test/unit/features/sales/quote_email_test.dart                      # NEW
test/widget/core/widgets/responsive_dialog_test.dart                # NEW
test/golden/core_widgets_golden_test.dart (+ goldens/*.png)         # EXTEND
test/widget/features/sales/quote_screen_documents_test.dart         # NEW
test/widget/features/sales/quote_email_dialog_test.dart             # NEW
test/integration/quote_pdf_email_flow_test.dart                     # NEW (live, email opt-in)
```

**Structure Decision**: The feature lives in `features/sales/` (quotes) and extends two
`core/` modules. The quote screen file itself (`quote_screen.dart`) is not edited: both
actions live in `QuoteHeaderPanel`, which already receives the `Sale` and can read the
providers it needs.

## Implementation Order

1. **Document kind (US1)**: `DocumentKind.salesQuote`, the source switch arm, and the
   three extended `core/documents` tests.
   Verify: `flutter test test/unit/core/documents/`.
2. **Ver cotización (US1)**: the header button, draft gate, and l10n title and action, with
   widget tests. This delivers the MVP.
   Verify: M1–M3.
3. **Shared dialog**: `ResponsiveDialog` + `showResponsiveDialog`, with widget tests and
   four goldens registered in the covered set.
   Verify: `flutter test test/golden test/widget/core/widgets/`.
4. **Email domain and data**: `quote_email.dart` and `SalesQuoteRepository.email`, with
   repository tests for every status.
5. **Email controller**: seed, toggle, `addTyped`, send, and failure classification, with
   unit tests.
6. **Email dialog and header action (US2)**: every wireframe state, the snackbar and the
   409 refresh, with widget tests.
   Verify: M4–M10.
7. **Compact tier**: the overflow menu in the header and the full-screen dialog, with
   widget tests at < 600 px.
   Verify: M11.
8. **l10n parity, live integration flow, quickstart manual checks.**

## Complexity Tracking

| Item | Why needed | Simpler alternative rejected because |
|---|---|---|
| **§VI deviation**: on the compact tier, "Ver cotización" and "Enviar por correo" render inside a header overflow menu (`MenuAnchor`), not as body `OutlinedButton`s | The user chose it in the wireframe review (OQ2). Otherwise a phone header stacks three full-width buttons above the lines, pushing the quote content down. | Wrapping (the order screen's behaviour) was the drawing's first assumption, and the user rejected it. Icon-only buttons hide the labels the §VI rationale wants kept. The deviation is compact-only; wide tiers follow §VI exactly. |
| A new shared widget (`ResponsiveDialog`) with one caller | The user chose a shared component over a feature-local one (OQ3), so later form dialogs inherit the wide/compact switch instead of copying `DocumentPreviewDialog`'s private one. | A feature-local `AlertDialog` + `Dialog.fullscreen` branch was rejected by the user. Golden coverage is mandatory for any `core/widgets` file, so this costs four goldens. |
