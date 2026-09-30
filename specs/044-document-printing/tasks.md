---

description: "Task list for Document Printing"
---

# Tasks: Document Printing

**Input**: Design documents from `/specs/044-document-printing/`
**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/document-module.md](./contracts/document-module.md), [contracts/consumed-endpoints.md](./contracts/consumed-endpoints.md), [wireframes.md](./wireframes.md), [quickstart.md](./quickstart.md)

**Tests**: Included. The constitution's Development Workflow & Quality Gates require unit coverage for repositories and logic, widget coverage for core widgets and critical screens, and a golden-path integration flow. [research.md](./research.md) R15 names the exact suites. Within each story, tests come first and are expected to fail before the implementation task that satisfies them.

**Organization**: Tasks are grouped by user story (spec.md US1–US5). Everything all five stories share, meaning the `printing` dependency, the self-hosted pdf.js, the byte-error fix, the document source, the output and `DocumentActions.printDirect`, is in Phases 1–2. After Phase 2:

- **US1** needs nothing else. It uses `printDirect`, which has no preview.
- **US2** builds the preview dialog and adds `DocumentActions.preview`.
- **US3, US4 and US5 each need US2**, because they open the preview.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no unresolved dependency)
- **[Story]**: US1–US5, or omitted for Setup/Foundational/Polish
- File paths are exact and relative to the repository root
- Providers: check whether neighbouring providers (for example `salesOrderRepositoryProvider` in `lib/features/sales/data/sales_order_repository_impl.dart`) use `riverpod_generator`. If so, use the same annotation style and run `dart run build_runner build --delete-conflicting-outputs` after adding one.

---

## Phase 1: Setup

**Purpose**: Dependencies and web assets, plus a baseline so a later regression is attributable to this feature.

- [X] T001 Confirm `044-document-printing` is checked out and run `flutter pub get` at the repository root. Run `flutter analyze` and `flutter test test/unit test/widget`, and record the pass count, the analyzer issue count, and **which tests already fail** (for example `test/unit/features/repository_list_params_audit_test.dart`), so none of them is later blamed on this feature
- [X] T002 [P] In `pubspec.yaml`, add `printing: ^5.15.1` under `dependencies` (research R1). Run `flutter pub get` and confirm it resolves. **`environment.sdk` stays `^3.10.3`**: raising it alone gives `mbe_ui` a newer language version than the generated client and breaks every import of it (research R1)
- [X] T003 [P] Vendor pdf.js 6.2.108 for the web build (research R3): fetch `pdfjs-dist@6.2.108` (for example `npm pack pdfjs-dist@6.2.108` in the scratchpad directory), and copy `build/pdf.min.mjs`, `build/pdf.worker.min.mjs` and its `LICENSE` into `web/pdfjs/`. Do not copy `cmaps/` or `wasm/`
- [X] T004 [P] In `web/index.html`, add `<script>var dartPdfJsBaseUrl = "./pdfjs/";</script>` in `<head>` (before `flutter_bootstrap.js` runs). Use `"./pdfjs/"`: the leading `./` is required because the package loads it with a dynamic `import()`, which rejects a bare specifier; keep the trailing slash, because the package appends file names directly (research R3)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: The `core/documents/` module without any UI, plus the shared byte-error fix. **No user story can be built until this phase's checkpoint passes.**

### Byte error bodies (FR-030, research R9)

- [X] T005 [P] Write `test/unit/core/network/auth_interceptor_test.dart`, the first test of this file. Using `mapDioException` and the interceptor's `onError`, assert that with `Response.data` as a `Uint8List` and a JSON content type:
  - a 404 body `{"detail":"Sales order not found"}` yields `NotFoundError` with that message
  - a 409 body `{"detail":"Cash session is not closed"}` yields `ServerError(statusCode: 409)` with that message
  - a 403 body yields `ServerError(statusCode: 403)` with `Insufficient privileges`
  - a 422 body yields `ValidationError` with its field errors
  - a 401 byte body yields `AuthError` and still triggers the unauthorized callback (edge case "session expires while a document loads")
  - a non-JSON byte body yields a null message and does not throw
  - a body that is already a `Map` behaves exactly as today. This test fails until T006
- [X] T006 In `lib/core/network/auth_interceptor.dart`, make `_detailFrom` and `_fieldErrorsFrom` first normalize `response.data`. When it is a `List<int>` and the `content-type` is JSON, decode it as UTF-8 JSON, catching decode errors and falling back to null. The existing `is! Map` / `is! List` guards then run unchanged. Do not add a new `AppError` subtype for 409 (research R9) (depends on T005)

### Domain types and interfaces (data-model.md, contracts/document-module.md)

- [X] T007 [P] Create `lib/core/documents/domain/document_kind.dart`: `enum DocumentKind { saleTicket, salesOrder, cashCut }` with, per kind, its gate (`SystemObject.salesOrders`/`salesOrders`/`pos`, all with `AccessRight.read`, research R12) and a `fallbackFilename(int recordId)` that yields `ticket-{id:08d}.pdf`, `pedido-{id:08d}.pdf` and `corte-{id:06d}.pdf` (research R10)
- [X] T008 [P] Create `lib/core/documents/domain/document_ref.dart` with three immutable classes as in data-model.md:
  - `DocumentRef` (`kind`, `recordId` > 0, `title`), with value equality
  - `RenderedDocument` (`bytes`, `filename`)
  - `DocumentPage` (`image` as `ImageProvider`, `size`)
- [X] T009 [P] Create `lib/core/documents/domain/document_source.dart` (`fetch(DocumentRef) → Future<RenderedDocument>`) and `lib/core/documents/domain/document_output.dart` (`print`, `save`, `raster` per contracts/document-module.md)

### Document source (FR-020, FR-030)

- [X] T010 [P] Write `test/unit/core/documents/generated_client_bytes_test.dart`: a `dart:io` source check that, in `lib/generated/openapi/lib/src/api/sales_orders_api.dart` and `cash_sessions_api.dart`, the three print methods (`printSalesOrderTicket…`, `printSalesOrderDocument…`, `printCashSessionCut…`) are declared `Future<Response<Uint8List>>` and contain `responseType: ResponseType.bytes`. This is the regeneration guard for contract fact E1. The generated signatures wrap onto a second line (`Future<Response<Uint8List>>\n  printSalesOrder…({`), so match across whitespace, not line by line
- [X] T011 [P] Write `test/unit/core/documents/document_source_impl_test.dart`, using the stubbed dio adapter pattern of `test/unit/features/sales/cash_session_repository_impl_test.dart`, with the interceptor attached so byte errors run through the real mapping. Assert:
  - bytes come back identical to the stub's body, and a body not starting with `%PDF-` is a `ServerError`
  - `Content-Disposition: inline; filename="pedido-00001234.pdf"` is parsed, and a missing or unparseable header falls back to `DocumentKind.fallbackFilename`
  - 404, 403 and 409 byte JSON bodies surface as the right `AppError` with the server's detail
  - a connection error becomes `NetworkError`. Fails until T012
- [X] T012 Create `lib/core/documents/data/document_source_impl.dart`: `DocumentSourceImpl(Dio)` builds `SalesOrdersApi(dio, appSerializers)` and `CashSessionsApi(dio, appSerializers)` (`appSerializers` from `lib/core/network/api_serializers.dart`, never `standardSerializers`), maps each `DocumentKind` to its generated method, reads `Response.headers` for the file name, and maps `DioException` with the `error.error is AppError ? … : mapDioException(error)` pattern used by `_toAppError` in `sales_order_repository_impl.dart`. Add `documentSourceProvider` (depends on T006, T007, T008, T009, T011)

### Document output (FR-012, research R5–R7)

- [X] T013 [P] Write `test/unit/core/documents/printing_document_output_test.dart`. First, for the pure function `double rasterDpiFor(double widthPt, double heightPt)`, assert:
  - Letter (612 × 792 pt) yields 200
  - a 72 mm × 1000 mm ticket yields 200
  - a page whose side would exceed 30 000 px or whose area would exceed 16 MP at 200 dpi yields a lower dpi that satisfies both caps
  - the result is never below a sane floor (for example 36)

  Then, with a fake injected print function (see T014): a `false` result (user cancelled, on native) completes normally, with no throw and no error (FR-031); `print` hands over exactly the document's bytes and filename; `save` passes the filename through. Fails until T014
- [X] T014 Create `lib/core/documents/data/printing_document_output.dart`: `rasterDpiFor` plus `PrintingDocumentOutput`.
  - `print` calls `layoutPdf(onLayout: (_) async => bytes, name: filename)`, ignores the returned bool, and never treats false as an error (FR-031, research R5). The constructor takes `layoutPdf` and `sharePdf` as injectable function parameters, defaulting to `Printing.layoutPdf` / `Printing.sharePdf`, so T013 can fake them
  - `save` calls `sharePdf(bytes:, filename:)` (research R6)
  - `raster` makes **two passes**, because `Printing.raster` takes one dpi for every page and a page's size is only known once it has been rastered. First it rasters page 0 alone at 72 dpi (`pages: [0]`), where one pixel equals one point, to read the page size in points. Then it rasters all pages at `rasterDpiFor(width, height)` and yields `DocumentPage`s. One dpi for all pages is right for these documents, because a ticket or cut is one page and a pedido's pages are all Letter (research R2, R7).

  Add `documentOutputProvider` (depends on T008, T009, T013)

### Document actions (FR-002, FR-032, FR-040, FR-041)

- [X] T015 [P] Write `test/unit/core/documents/document_actions_test.dart` with fake `DocumentSource`/`DocumentOutput` and an overridden `accessControlProvider`. Assert:
  - `printDirect` fetches once, then prints exactly the bytes fetched
  - a user without the kind's gate gets a 403 `ServerError`, and the fake source records zero calls (FR-041)
  - a second `printDirect` for the same `DocumentRef` while the first is in flight is ignored, and a call after it settles works (FR-032, contract G1)
  - a fetch error propagates as `AppError` and leaves the in-flight guard cleared so retry works
  - `canOpenDocument` mirrors each kind's gate, admin included. Fails until T016

  (The `preview` cases are added in T024, with the dialog.)
- [X] T016 Create `lib/core/documents/presentation/document_actions.dart`: `canOpenDocument(AccessControlService, DocumentKind)`, and `DocumentActions` with `printDirect(DocumentRef)`, re-checking the gate through `accessControlProvider` before any fetch and guarding in-flight calls by `DocumentRef`. Add `documentActionsProvider`. `preview` is added in T029 (depends on T012, T014, T015)

### Localization

- [X] T017 Add the shared keys to `lib/l10n/app_en.arb` (with `@key` metadata blocks, since that is the template file) and `lib/l10n/app_es.arb`, using the flat camelCase, feature-prefixed, fixed-suffix convention (research R15, research §8.5): `documentPrintAction` (Imprimir), `documentDownloadAction` (Descargar), `documentLoadingMessage`, `documentLoadFailedError`, `documentCloseTooltip`, `documentZoomOutTooltip`, `documentZoomInTooltip`, `documentZoomFitTooltip`, `documentPageIndicator` (placeholders `current`, `total`), and the three title keys `documentTicketTitle` (placeholder `reference`: "Ticket · Folio #…"), `documentSalesOrderTitle` (`reference`: "Pedido · …"), `documentCashCutTitle` (`reference`: "Corte de caja · …"). Reuse existing `retryButton` and the `errorNetworkGeneric` / `errorServerGeneric` / `errorNotFoundGeneric` family. Run `flutter gen-l10n` and `flutter test test/unit/core/l10n_parity_test.dart`

**Checkpoint**: `flutter test test/unit/core/network test/unit/core/documents` passes, and `flutter analyze` shows no new issues against the T001 baseline. The module has no UI yet.

---

## Phase 3: User Story 1 - A cashier prints the ticket when a sale is completed (Priority: P1) 🎯 MVP

**Goal**: The "Venta completada" dialog offers "Imprimir ticket", which opens the print dialog with the final receipt in one press.

**Independent Test** (spec US1): complete a POS sale, press "Imprimir ticket", and confirm the print dialog opens with the receipt for that folio. Widget-level, with a fake source and output: the button appears only with `salesOrders` read, calls `printDirect` for that sale's id, and shows busy and error states without closing the dialog.

### Tests for User Story 1

- [X] T018 [P] [US1] Write `test/widget/features/sales/pos_sale_completed_dialog_test.dart`, using `pos_test_harness.dart` and overriding `documentSourceProvider`/`documentOutputProvider`. Assert:
  - "Imprimir ticket" (key `print_ticket_button`) is an `OutlinedButton`, sits before "Nueva venta" (key `start_new_sale_button`, still the `FilledButton`), and is absent for a user lacking `salesOrders` read (FR-002, FR-040, US1-5)
  - pressing it fetches the ticket for the sale's id and prints the bytes, with no preview route pushed (FR-002, US1-1)
  - the dialog is still showing afterwards (US1-2)
  - while fetching, the button shows progress and a second press adds no fetch (US1-3, FR-032)
  - a failing fetch shows an `ErrorBanner` with the server's reason, the button reads "Reintentar", retry works, and "Nueva venta" still works (US1-4)
  - **Fails until T020–T021**

### Implementation for User Story 1

- [X] T019 [US1] Add `posSalePrintTicketAction` ("Imprimir ticket") and `posSalePrintTicketError` ("No se pudo imprimir el ticket.") to `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb`, then run `flutter gen-l10n`
- [X] T020 [US1] Create `lib/features/sales/presentation/pos_sale_completed_dialog.dart`: a `ConsumerStatefulWidget` extracted from the `AlertDialog` built in `_finish`, keeping the same title, folio content and `start_new_sale_button`, and adding the `OutlinedButton.icon` `print_ticket_button` per [wireframes.md](./wireframes.md) (POS "Venta completada" dialog). It is hidden without `salesOrders` read via `canOpenDocument`, calls `documentActionsProvider.printDirect(DocumentRef(saleTicket, saleId, title))` (title from `documentTicketTitle`, with the reference rule in data-model.md › DocumentRef), disables itself and shows progress while running. On failure it shows, in the dialog content, a `Text` heading `posSalePrintTicketError` above `ErrorBanner(error: …)`. `ErrorBanner` has no retry of its own, so retry is the print button itself, relabelled with the existing `retryButton` string. It never pops itself (FR-002) (depends on T016, T019)
- [X] T021 [US1] In `lib/features/sales/presentation/pos_workspace_screen.dart`, replace the inline `AlertDialog` in `_finish` (~L649-677) with `PosSaleCompletedDialog`, passing the sale's id and the same reference text (`serial ?? provisionalReference`). Keep the `openSalesSelectorControllerProvider` invalidation and the `startNew()` + `reset()` behaviour of "Nueva venta" exactly as today (depends on T020)

**Checkpoint**: T018 passes and existing `test/widget/features/sales/` POS tests still pass. US1 alone is a shippable increment.

---

## Phase 4: User Story 2 - A user previews a document and prints or downloads it (Priority: P1)

**Goal**: One shared preview dialog (full-screen on Compact) showing the server-rendered pages, with zoom, a page indicator, Imprimir and Descargar.

**Independent Test** (spec US2): open a preview through `DocumentActions.preview` with a fake source and output. Confirm the pages render in order, zoom and page indicator behave, Imprimir and Descargar receive the same bytes, loading and error states match the wireframes, and closing returns to the caller.

### Tests for User Story 2

- [X] T022 [P] [US2] Write `test/unit/core/documents/document_zoom_test.dart` for pure zoom and page logic. Assert:
  - the step list is 50/75/100/125/150/200/300/400 % of fit-to-width
  - `next`/`previous` from an arbitrary scale (for example 137 %) go to the adjacent step, and are no-ops at 400 % and 50 %
  - pinch values clamp to [50 %, 400 %]
  - the level readout rounds to a whole percent
  - `pageInView` picks the page crossing the viewport's vertical centre for several offsets, scales and unequal page heights, including a single-page document and a document scrolled past its end. Fails until T025
- [X] T023 [P] [US2] Write `test/unit/core/documents/document_preview_controller_test.dart` with fake source and output. Assert:
  - loading → loaded carries `RenderedDocument` plus every page in order
  - a fetch error and a raster error both end in `AsyncError(AppError)`
  - retry (invalidate) fetches again, and nothing is cached between opens (FR-022, G3)
  - no partial page list is ever exposed (G4). Fails until T026
- [X] T024 [P] [US2] Write `test/widget/core/documents/document_preview_dialog_test.dart` for every state in [wireframes.md](./wireframes.md), "Shared document preview". Assert:
  - loading: indicator, "Cargando documento…", both action buttons disabled, indicator reads "Página – / –"
  - loaded ticket (one narrow page) and loaded letter (three pages): "Página 1 / N", and the page indicator changes when scrolled to a later page
  - Imprimir and Descargar call the fake output with the same bytes and filename (G2)
  - `[+]`/`[−]`/`[⤢]` change the level readout, and the ends disable their buttons
  - a plain wheel scrolls without changing zoom, and Ctrl + wheel zooms
  - error: `ErrorBanner` shows the server's reason and Reintentar refetches
  - at Compact width, a full-screen dialog with the close button leading. At Medium and wider, a constrained dialog
  - closing pops back to the caller with no other change (G5)
  - **Action-bar alignment (constitution §VI, v1.11.0)**: the action bar is a control band (icon buttons, the level readout, the page indicator, two labelled buttons). Measure it the way `test/widget/features/sales/sale_line_row_test.dart` does: symmetric vertical insets, and one shared text baseline for the level readout, the page indicator and the two button labels. Check at both Medium and Compact width
  - calling `DocumentActions.preview` twice for the same ref while its dialog is open pushes one dialog and fetches once (FR-032, spec edge case "presses the print action twice quickly")
  - `preview` for a user lacking the kind's gate opens the dialog directly in its error state with the permission error, and the fake source records zero calls (FR-041, contracts/document-module.md)
  - Fails until T027–T029

### Implementation for User Story 2

- [X] T025 [P] [US2] Create `lib/core/documents/presentation/document_zoom.dart`: the zoom steps, `nextStep`/`previousStep`, `clampScale`, the readout formatter and `pageInView(...)`, all pure and Flutter-free (research R7, R8, data-model.md "Zoom model") (depends on T022)
- [X] T026 [US2] Create `lib/core/documents/presentation/document_preview_controller.dart`: an autoDispose `AsyncNotifier` family keyed by `DocumentRef` that fetches through `documentSourceProvider`, rasters through `documentOutputProvider`, and exposes `AsyncValue<DocumentPreviewData>` (`RenderedDocument document`, `List<DocumentPage> pages`). Emit `AsyncData` only once all pages exist (depends on T012, T014, T023)
- [X] T027 [US2] Create `lib/core/documents/presentation/document_page_viewer.dart`: pages stacked vertically inside `InteractiveViewer(constrained: false)` with a `TransformationController`, each page drawn at its true aspect ratio on a neutral surround (a `ColorScheme` surface-container role, never a hard-coded colour, per §V) and opening fitted to width (FR-011). A `Listener` on `PointerScrollEvent` zooms only when Ctrl or ⌘ is held and otherwise pans vertically, with the viewer's own wheel-zoom disabled. Expose zoom-in, zoom-out and fit as methods for the action bar, and report the page in view through `document_zoom.dart` (research R8) (depends on T025)
- [X] T028 [US2] Create `lib/core/documents/presentation/document_preview_dialog.dart` per [wireframes.md](./wireframes.md), with keys from contracts/document-module.md ("Preview dialog regions"). A `Dialog` with a maximum width and height from `core/design/spacing.dart` tokens at Medium and wider, and `Dialog.fullscreen` when `LayoutBreakpoints.isCompact`. The title bar shows `ref.title` and a close `IconButton` (leading on Compact). The page area shows one of three things: a `CircularProgressIndicator` with `documentLoadingMessage`; or, on error, a `Text` heading `documentLoadFailedError` above `ErrorBanner(error: …)` followed by a separate `TextButton` labelled with `retryButton` (key `document_preview_retry`), since `ErrorBanner` has no retry of its own; or the viewer. The action bar has zoom controls, "Página n / N" and the two buttons, disabled unless loaded. Imprimir calls `documentOutputProvider.print`, Descargar calls `.save`, and a print/save `AppError` shows through `ErrorBanner` (depends on T017, T026, T027)
- [X] T029 [US2] Extend `lib/core/documents/presentation/document_actions.dart` with `preview(BuildContext, DocumentRef)`. It ignores a repeated call for the same ref while its dialog is open, and `showDialog`s the `DocumentPreviewDialog`. It re-checks the gate first, and on failure **still opens the dialog, directly in its error state** with the permission error and no fetch. So `preview` never throws, and no call site needs error handling (FR-041, contracts/document-module.md) (depends on T016, T028)

**Checkpoint**: T022–T024 pass. US2 has no call site yet, so nothing appears in the running app until US3.

---

## Phase 5: User Story 3 - A supervisor prints the cash cut at close and reprints it later (Priority: P1)

**Goal**: "Ver corte" in the "Sesión cerrada" dialog and on a closed session's detail screen, with the detail refreshed after close and the close message no longer claiming the figures won't be shown again.

**Independent Test** (spec US3): close a session, press "Ver corte" in the dialog, and see the cut in the preview over a detail screen already showing the session as closed with its own "Ver corte". Widget-level: the action shows only for closed sessions and only with `pos` read.

### Tests for User Story 3

- [X] T030 [P] [US3] Extend `test/widget/features/sales/cash_session_detail_screen_test.dart`. Assert:
  - a closed session shows "Ver corte" in the body with `pos` read, and not without it (FR-006, FR-040)
  - an open session shows none (US3-5)
  - the close dialog's message no longer contains "no se mostrarán de nuevo" (FR-008)
  - the dialog shows "Ver corte" with `pos` read and not without it (edge case: close privilege without cut privilege)
  - pressing it closes the dialog first, then the preview opens, so exactly one dialog route is ever on the stack (FR-005)
  - after the close, the screen re-reads the session and shows the closed state (FR-007, US3-4). Fails until T033–T034
- [X] T031 [P] [US3] Extend `test/unit/features/sales/close_session_form_controller_test.dart`: after a successful `submit`, `cashSessionDetailControllerProvider(sessionId)` is invalidated, so its repository `get` is called again, alongside the two invalidations that already exist (FR-007, research R14). Fails until T033

### Implementation for User Story 3

- [X] T032 [US3] In `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb`, add `cashSessionViewCutAction` ("Ver corte"), and reword `cashSessionCloseSuccessMessage` by dropping its last sentence ("Estas cifras no se mostrarán de nuevo."), keeping the three placeholders. Run `flutter gen-l10n` (FR-008)
- [X] T033 [US3] In `lib/features/sales/presentation/close_session_form_controller.dart` (~L131-141), also `ref.invalidate(cashSessionDetailControllerProvider(cashSessionId))` after a successful close, where it already invalidates `currentSessionControllerProvider` and `cashSessionsListControllerProvider` (research R14) (depends on T031)
- [X] T034 [US3] In `lib/features/sales/presentation/cash_session_detail_screen.dart`:
  - For a closed session, add an `OutlinedButton.icon` "Ver corte" in the body, in the slot `_CloseSection` occupies for an open one. It is gated by `canOpenDocument(access, DocumentKind.cashCut)`, never placed in `AppBar.actions`, and calls `documentActionsProvider.preview(DocumentRef(cashCut, session.id, documentCashCutTitle(...)))`.
  - In the success `AlertDialog` (~L287-307), add an `OutlinedButton` "Ver corte" gated the same way, which pops the dialog with a result value. After `await showDialog`, and if `context.mounted`, call `preview`, so the dialogs never stack (depends on T016, T029, T032, T033)

**Checkpoint (first real browser run)**: `flutter run -d chrome --dart-define-from-file=.env`, then quickstart M6, M3 and M9. Confirm in DevTools → Network that pdf.js loads from `/pdfjs/` and that nothing goes to unpkg or any other third-party host.

---

## Phase 6: User Story 4 - A cashier reprints a ticket from the POS sales list (Priority: P2)

**Goal**: A "Ver ticket" row action on every saved sale in the POS list, opening the ticket in the preview.

**Independent Test** (spec US4): from the POS sales list, open a completed sale's ticket from its row and see the preview. Widget-level: the icon shows with `salesOrders` read, rows that also have Edit still show exactly two icons, and a row tap still opens the sale.

### Tests for User Story 4

- [X] T035 [P] [US4] Extend `test/widget/features/sales/pos_sales_list_screen_test.dart`. Assert:
  - a "Ver ticket" icon on a draft, a paid and a cancelled row when `salesOrders` read is held, and none without it (FR-003, FR-040, US4-1)
  - a row that also has Edit shows exactly two icons and no overflow menu (US4-4)
  - tapping it opens the preview for that row's sale id with the ticket kind (US4-2, US4-3)
  - tapping the row still opens the sale. Fails until T037

### Implementation for User Story 4

- [X] T036 [US4] Add `posSaleViewTicketTooltip` ("Ver ticket") to `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb`, then run `flutter gen-l10n`
- [X] T037 [US4] In `lib/features/sales/presentation/pos_sales_list_screen.dart` (`rowActionsBuilder`, ~L229-250), pass one `CatalogRowAction` (`Icons.receipt_long_outlined`, tooltip `posSaleViewTicketTooltip`) as `extraActions` to `buildCatalogRowActions`, shown only when `canOpenDocument(access, DocumentKind.saleTicket)`. It calls `preview(DocumentRef(saleTicket, openSale.id, documentTicketTitle(folio)))`, with the reference rule in data-model.md › DocumentRef: the serial when it is set, otherwise the sales order id padded to 8 digits. `OpenSale` has no provisional reference, and a draft's `serial` is null. Do not add a second extra action, since two or more would collapse into a kebab (FR-003) (depends on T029, T036)

**Checkpoint**: T035 passes, and quickstart M2 shows "Punto de Venta" for a draft and the receipt for a paid sale.

---

## Phase 7: User Story 5 - A salesperson prints the sales order document (Priority: P2)

**Goal**: "Ver pedido" in the order workspace header, opening the pedido only once pending edits have settled and unconfirmed text has been resolved.

**Independent Test** (spec US5): open a saved order in the order workspace and open its pedido to see a letter-size preview. Widget-level: the action follows the gate and the pending-writes and unconfirmed-edits rules.

### Tests for User Story 5

- [X] T038 [P] [US5] Write `test/widget/features/sales/order_workspace_view_pedido_test.dart` (a new file, in the style of `order_header_disclosure_test.dart`, rather than growing `order_workspace_test.dart`). Assert:
  - "Ver pedido" is offered for draft, completed, paid and cancelled orders with `salesOrders` read, and absent without it (FR-004, FR-040, US5-1)
  - it is disabled while `pendingWritesProvider('back-office-sale') > 0`, and enabled again when that returns to zero (FR-009)
  - with unconfirmed typed text registered in `unconfirmedEditsProvider`, pressing it shows the existing "Cambios sin confirmar" dialog
    - "Seguir editando" opens no preview and fetches nothing
    - "Conservar" confirms the entries first, then opens the preview
    - "Descartar" discards them, then opens the preview
  - with none registered, it opens the preview directly (US5-2)
  - it is a body action and `AppBar.actions` stays empty (FR-004). Fails until T040

### Implementation for User Story 5

- [X] T039 [US5] Add `salesOrderViewDocumentAction` ("Ver pedido") to `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb`, then run `flutter gen-l10n`
- [X] T040 [US5] In `lib/features/sales/presentation/orders/order_header_panel.dart` (`_headerRow`, ~L372), add an `OutlinedButton.icon` "Ver pedido" at the trailing edge, before or after the more/fewer-details toggle per [wireframes.md](./wireframes.md). It is gated by `canOpenDocument(access, DocumentKind.salesOrder)` and disabled while `pendingWritesProvider(ref.watch(saleWritesScopeProvider)) > 0`. On press it awaits `resolveUnconfirmedEdits(context, ref, scope)` (`lib/features/sales/presentation/unconfirmed_edits_resolver.dart`) and, only when that returns `true` and the widget is still mounted, calls `preview(DocumentRef(salesOrder, sale.id, documentSalesOrderTitle(sale id padded to 8 digits)))` (FR-009, research R13). `OrderHeaderPanel` is already a `ConsumerStatefulWidget` (`order_header_panel.dart:60`), so it can watch both providers directly (depends on T029, T039)

**Checkpoint**: T038 passes, and quickstart M4 and M5 behave as written.

---

## Phase 8: Polish & Cross-Cutting Concerns

- [X] T041 [P] Write `test/integration/document_printing_flow_test.dart` against a live mbe-api, in the style of `test/integration/sales_orders_flow_test.dart` (bare `Dio`, `AuthRepositoryImpl(dio).login`, `String.fromEnvironment('MBE_POS_USERNAME')` credentials, skipping rather than failing when they are empty). Discover fixtures at runtime: a completed sale, a closed cash session and an open one. For each print endpoint, assert that `DocumentSourceImpl.fetch` returns bytes starting `%PDF-` that are **byte-identical** to a direct `dio.get` of the same URL (SC-003), and that the cut of an open session surfaces `Cash session is not closed` (SC-005). Run with `flutter test test/integration/document_printing_flow_test.dart --dart-define-from-file=.env --dart-define=MBE_POS_PRODUCT_PATTERN=clavo`. **Status: written and compiled, and it skips cleanly without credentials; it has not been run against a live mbe-api** (none was reachable when this was implemented), so its four checks are unproven until someone runs it. It creates nothing, so the product pattern define is not needed
- [X] T042 [P] Run `flutter analyze` and `flutter test test/unit test/widget`, and compare with the T001 baseline. No new analyzer issues, and no failures beyond the ones recorded there. Confirm `test/unit/core/l10n_parity_test.dart` passes with all new keys in both `.arb` files
- [X] T043 [P] Update `docs/document-printing-research.md` §8.6 and §0.1 to record two facts this feature found (research R4, R5): on web, `Printing.layoutPdf` cannot report a cancel or a blocked pop-up, and the package's web raster and print need `'unsafe-eval'` and `'unsafe-inline'` under any future CSP. Point the document's status line at spec 044
- [ ] T044 Run the manual checks in [quickstart.md](./quickstart.md): M1–M9 in Chrome, recording the stopwatch timings M1, M4 and M6 ask for against SC-001, SC-002 and SC-007, then H1 (real 80 mm thermal printer, actual size) and H2 (phone browser). Record each result. H1 and H2 need hardware and a device, so if they cannot run in this session, report them as not run rather than passed (SC-006)
  **Status (implementing session): partly verified, left open.**
  - *Done, automated, in a real browser (headless Chrome 154):* the release web build compiles with `printing`; `web/pdfjs/` is packaged and `index.html` carries `dartPdfJsBaseUrl = "./pdfjs/"`; a page served from that build loads the vendored pdf.js the way `printing_web` does, rasters a page at 200 dpi with its text drawn, and contacts no host but its own (part of **M9**; research R3). The bare `"pdfjs/"` was shown to fail, which is why the value starts with `./`.
  - *Not done, needs a person, a browser session and a live mbe-api:* **M1–M8** (the actual dialogs, print preview, zoom feel, the "Cambios sin confirmar" prompt, revoked privileges) and the **rest of M9** (a network capture of the app's own preview, not only of pdf.js). No mbe-api was reachable, and the app has no browser automation to drive it.
  - *Not done, needs hardware:* **H1** (a real 80 mm thermal printer at actual size) and **H2** (a phone browser). **SC-006 is unproven.**
  - *Not timed:* the stopwatch checks for SC-001, SC-002 and SC-007 (M1, M4, M6).
  - The live integration test (T041) has likewise not been run.

---

## Dependencies & Execution Order

### Phase dependencies

- **Phase 1 (Setup)**: T001 first; T002–T004 in parallel afterwards.
- **Phase 2 (Foundational)**: depends on T002 (the package). It **blocks every story**. Inside it:
  - T005 → T006
  - T007, T008 and T009 in parallel
  - T010 in parallel
  - T011 → T012, which needs T006–T009
  - T013 → T014, which needs T008–T009
  - T015 → T016, which needs T012 and T014
  - T017 any time before Phase 3
- **US1 (Phase 3)**: depends on Phase 2 only.
- **US2 (Phase 4)**: depends on Phase 2 and T017. It is independent of US1.
- **US3, US4, US5**: each depends on **US2** (T029). They are independent of one another and of US1.
- **Polish (Phase 8)**: after all wanted stories. T041 needs Phase 2 only, but runs last with the rest.

### Within each story

Tests are written first and fail. Then l10n keys, then the widget or controller, then the call-site edit. Anything sharing a file is sequential: all `.arb` edits, and `document_actions.dart` (T016 → T029).

### Story completion order

```text
Phase 1 → Phase 2 ─┬─► US1 (independent, shippable alone)
                   └─► US2 ─┬─► US3
                            ├─► US4
                            └─► US5
```

---

## Parallel Example

**Phase 2**, after T002:

```text
T005 (interceptor test)     T007 (document_kind)        T010 (generated-client guard)
T008 (document_ref)         T009 (interfaces)           T013 (raster dpi test)
```

**US2**, tests written together, then the two independent files:

```text
T022 (zoom test)   T023 (controller test)   T024 (dialog widget test)
                           then
T025 (document_zoom.dart)  ∥  T026 (preview controller)   → T027 → T028 → T029
```

**After US2**, three developers can take US3, US4 and US5 at once. They touch different screens. They share only the `.arb` files (T032, T036, T039), which must be merged sequentially.

---

## Implementation Strategy

### MVP first (US1)

1. Phase 1 and Phase 2.
2. Phase 3 (US1). The cashier can print the receipt at every sale, which was the gap that blocked stores from moving off legacy.
3. Stop and validate with quickstart M1 and, if a printer is at hand, H1.

### Incremental delivery

1. Add US2 and US3 next. That completes the P1 set, and the first real-browser run of pdf.js from `/pdfjs/` happens at US3's checkpoint.
2. Then US4 (reprints from the list) and US5 (the pedido), in either order.
3. Polish last.

### Notes

- Do not edit anything under `lib/generated/` (constitution §III). T010 exists to catch a regeneration that drops `ResponseType.bytes`.
- Do not implement a blocked pop-up or print-cancel message: the package cannot report either (research R5).
- Do not add a Content Security Policy. Only record the directives that a future one needs (research R4).
- Commit only when asked. The `/speckit-git-commit` hooks are optional.
