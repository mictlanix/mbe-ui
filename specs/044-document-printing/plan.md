# Implementation Plan: Document Printing

**Branch**: `044-document-printing` | **Date**: 2026-09-30 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/044-document-printing/spec.md`, consuming mbe-api#231 (issue #230). Pre-spec foundation: [docs/document-printing-research.md](../../docs/document-printing-research.md). Screens: [wireframes.md](./wireframes.md).

## Summary

mbe-api now renders three PDFs: the sale ticket, the pedido and the cash cut. mbe-ui gains a shared `core/documents/` module:
- one fetch path over the three generated methods;
- a `printing`-backed output for print, save and raster;
- one modal **preview dialog** with our own zoomable page viewer, which is full-screen on Compact.

Call sites reach it only through `DocumentActions.preview` / `printDirect`:
- the POS completion dialog (direct print);
- the POS sales list row;
- the order workspace header;
- the cash-session close dialog and detail screen.

pdf.js is served from the app's own origin, so a preview reaches no third party. A one-file fix in `auth_interceptor.dart` re-reads JSON error bodies that arrive as bytes, so the server's own reason reaches `ErrorBanner`. The cash detail refreshes after close, and the close message stops saying the figures can't be seen again.

## Technical Context

**Language/Version**: Dart `^3.10.3` (unchanged, research R1; `printing` needs Dart ≥ 3.12 at build time, which the installed toolchain has), Flutter 3.44.2 stable

**Primary Dependencies**:
- New: `printing` ^5.15.1, which brings `pdf`, `image`, `http` and `web` transitively.
- Vendored web asset: `pdfjs-dist` 6.2.108 (`pdf.min.mjs`, `pdf.worker.min.mjs`, `LICENSE`) under `web/pdfjs/`.
- Existing: `dio` 5.9.2, Riverpod, the generated `mbe_api_client` (regenerated in `93bb31f`), `flutter_localizations` / `intl`.

**Storage**: None. Documents are held in memory only while open (FR-022, §VII).

**Testing**:
- `flutter_test` + `mocktail` unit tests. The document source goes through the stubbed dio adapter used by `cash_session_repository_impl_test.dart`.
- Widget tests with `ProviderScope` overrides of `documentSourceProvider` / `documentOutputProvider`.
- One live `test/integration/` flow with `--dart-define-from-file=.env`.

**Target Platform**: Web in desktop Chrome first. Android and desktop builds use the same code through `printing`'s native backends (research R2). Phone and tablet browsers degrade printing to a new tab (R5).

**Project Type**: Flutter client application, feature-first layered

**Performance Goals**: SC-001/SC-002 — the print dialog or a loaded preview within 3 s on a store connection. That covers one fetch, which mbe-api renders in under 1 s, plus a single raster pass at ≤ 200 dpi (R7). Zoom never re-renders.

**Constraints**:
- No third-party runtime host (FR-014).
- Bytes are never altered (FR-020/021).
- `AppBar.actions` stays empty (§VI).
- No new `SystemObject` (R12).
- Pages are capped at 30 000 px a side and 16 MP (R7).
- Any future CSP must carry the directives in [quickstart.md](./quickstart.md) § Deployment (R4).

**Scale/Scope**:
- New module `lib/core/documents/`, 12 source files:
  - domain (4): kind, ref/rendered/page, and 2 interfaces
  - data (2): the source impl and the printing output
  - presentation (6): actions, the access gate, preview dialog, controller, page viewer, zoom/page math
- Edits to 6 existing files: `auth_interceptor.dart`, `pos_workspace_screen.dart`, `pos_sales_list_screen.dart`, `order_header_panel.dart`, `cash_session_detail_screen.dart`, `close_session_form_controller.dart`.
- Also `pubspec.yaml` (adds `printing` only), `web/index.html`, and both `.arb` files: about 17 new keys, and 1 reworded (`cashSessionCloseSuccessMessage`).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Verdict | How |
|---|---|---|
| **I. Feature-first layering** | Pass | Three features consume the documents, so the module is shared infrastructure in `lib/core/documents/{domain,data,presentation}`, like `core/network/`. Feature call sites import only `core/documents/presentation` and `domain`. Inside the module, `presentation/` reads its own `data/` providers (`documentSourceProvider`, `documentOutputProvider`). That follows the repo's existing provider-import practice, e.g. `cash_session_detail_controller.dart:3` importing `cash_session_repository_impl.dart` for its provider. |
| **II. Riverpod** | Pass | `documentSourceProvider`, `documentOutputProvider` and `documentActionsProvider` are providers, overridable in tests. `DocumentPreviewController` is an autoDispose `AsyncNotifier` family exposing `AsyncValue`. Zoom and page-in-view are local UI state. |
| **III. Contract-driven API** | Pass | Uses the three generated methods as emitted. `ResponseType.bytes` and `Uint8List` were verified (research §8.2, contract E1). No generated file is edited and no dio bypass is used. A PDF has no DTO, so there is no `freezed` mapping. Errors map to shared `AppError` types through the fixed `mapDioException` (R9). **No mbe-api change needed**: #231 has shipped, and codegen is current (`93bb31f`). |
| **IV. Deny-by-default RBAC** | Pass | Each `DocumentKind` carries its gate (`salesOrders`/`pos` + `read`), matching mbe-api. Actions are hidden, not disabled, without it, and re-checked before fetching (FR-040/041). No new `SystemObject`, so the `core/` table is untouched. |
| **V. Material 3 design system** | Pass | Uses `Dialog`/`Dialog.fullscreen`, `FilledButton.icon`/`OutlinedButton.icon`, `IconButton`, `ErrorBanner`, and tokens from `core/design/spacing.dart`. No Cupertino branch. |
| **VI. Desktop/web-first layout** | Pass | All actions are body buttons: the POS row uses the shared `buildCatalogRowActions` with one extra action; the others are `FilledButton`/`OutlinedButton` in the body; `AppBar.actions` stays empty. The preview is a modal dialog, not a record surface, so the side-sheet / detail-screen rules don't apply (wireframes, OQ2). Compact tier via `LayoutBreakpoints`. Panning a zoomed page is inside a document canvas, not table horizontal scroll (R8). |
| **VII. Online-only, server-rendered documents** | Pass | This is the principle's blessed path: mbe-ui previews, prints and saves mbe-api's bytes through `printing`, and never renders or alters them. Nothing is cached. |
| **Stack** | Pass | `printing` is the stack's named documents package; this feature is what finally adds it. |
| **Quality gates** | Pass | Unit (interceptor, source, controller), widget (dialog plus all call sites), and one integration flow against live mbe-api (R15). The constitution's "mbe-api changed" workflow step is satisfied: codegen was re-run, there is no mapping to add, and there is no RBAC table change. |

**Post-design re-check** (after Phase 1): still passing.
- The design added only `core/documents/`, one vendored web folder and one `index.html` global.
- The two new shared presentation pieces, the dialog frame and the page viewer, have no existing counterpart in `core/widgets/` (wireframes, OQ1). They live in `core/documents/presentation/` because they are document-specific.
- No amendment is needed.

## Project Structure

### Documentation (this feature)

```text
specs/044-document-printing/
├── spec.md
├── wireframes.md
├── plan.md                        # this file
├── research.md                    # Phase 0 (R1–R15)
├── data-model.md                  # Phase 1
├── contracts/
│   ├── document-module.md         # the core/documents surface call sites use
│   └── consumed-endpoints.md      # what mbe-ui relies on from mbe-api#231
├── quickstart.md                  # Phase 1: validation guide
├── checklists/requirements.md
└── tasks.md                       # Phase 2 (/speckit-tasks — not created here)
```

### Source Code (repository root)

```text
lib/core/documents/                          # NEW
├── domain/
│   ├── document_kind.dart                   # enum + gate + fallback filename
│   ├── document_ref.dart                    # DocumentRef, RenderedDocument, DocumentPage
│   ├── document_source.dart                 # interface
│   └── document_output.dart                 # interface
├── data/
│   ├── document_source_impl.dart            # 3 generated methods, filename parse, _toAppError
│   └── printing_document_output.dart        # Printing.layoutPdf / sharePdf / raster, dpi cap
└── presentation/
    ├── document_access.dart                 # canOpenDocument / requireDocumentAccess (shared by actions and controller)
    ├── document_actions.dart                # preview() / printDirect(), in-flight guards
    ├── document_preview_dialog.dart         # Dialog vs Dialog.fullscreen, title/action bars
    ├── document_preview_controller.dart     # AsyncNotifier family (fetch → raster)
    ├── document_zoom.dart                   # pure zoom steps, clamp, readout, page-in-view
    └── document_page_viewer.dart            # InteractiveViewer, zoom steps, wheel handling, page-in-view

lib/core/network/auth_interceptor.dart               # EDIT: bytes → JSON before detail/field-error guards (R9)
lib/features/sales/presentation/pos_workspace_screen.dart          # EDIT: "Imprimir ticket" in _finish dialog
lib/features/sales/presentation/pos_sales_list_screen.dart         # EDIT: "Ver ticket" CatalogRowAction
lib/features/sales/presentation/orders/order_header_panel.dart     # EDIT: "Ver pedido" in _headerRow
lib/features/sales/presentation/cash_session_detail_screen.dart    # EDIT: "Ver corte" (close dialog + closed body)
lib/features/sales/presentation/close_session_form_controller.dart # EDIT: invalidate detail after close (R14)
lib/l10n/app_en.arb, app_es.arb                                    # EDIT: new keys; reword close message
pubspec.yaml                                                       # EDIT: printing (sdk constraint unchanged, research R1)
web/index.html                                                     # EDIT: dartPdfJsBaseUrl
web/pdfjs/{pdf.min.mjs,pdf.worker.min.mjs,LICENSE}                 # NEW (vendored pdfjs-dist 6.2.108)

test/unit/core/network/auth_interceptor_test.dart                  # NEW
test/unit/core/documents/                                          # NEW: source, controller, zoom/page math
test/widget/core/documents/document_preview_dialog_test.dart       # NEW
test/widget/features/sales/…                                       # EXTEND: pos dialog, pos list, order workspace, cash detail
test/integration/document_printing_flow_test.dart                  # NEW (live)
```

**Structure Decision**: The shared module goes under `lib/core/documents/` with the same three layers as a feature (Principle I). The call-site edits stay in `features/sales/presentation/`, the only feature that prints today. `docs/document-printing-research.md` is the upstream record and gets no further changes.

## Implementation Order

1. **Foundation**:
   - add `printing`, bump the SDK constraint, vendor pdf.js, set the `index.html` global;
   - fix the interceptor with its test (R9);
   - add the domain types.

   Verify: the unit tests pass, and a scratch `Printing.raster` call in Chrome loads pdf.js from `/pdfjs/` (M9).
2. **Document source**, with its unit test (byte integrity, filename, errors).
3. **Preview**: controller, page viewer, dialog, and `DocumentActions`, with unit and widget tests. This delivers US2.
4. **Call sites**, in priority order, each with widget tests:
   1. POS completion (US1)
   2. cash close and detail (US3, including R14 and the message reword)
   3. POS list (US4)
   4. order workspace (US5, R13)
5. **l10n** for es-MX and en (parity test), then the live integration flow and the quickstart manual checks.

## Complexity Tracking

> No constitution violations. Two non-obvious costs are recorded so review can weigh them:

| Item | Why needed | Simpler alternative rejected because |
|---|---|---|
| Vendoring pdfjs-dist (about 1.5 MB) into `web/pdfjs/` | FR-014/SC-004: the preview must not load code from a public CDN, and `printing`'s web raster uses pdf.js | The package's unpkg default violates FR-014. A custom `js_interop` pdf.js binding would duplicate the mandated package and still leave print's CSP needs (research R3, R4). |
| Future CSP must allow `'unsafe-eval'`/`'unsafe-inline'` | The `printing` web plugin reaches pdf.js via `eval` and prints via an injected inline script | No CSP exists today, so nothing is relaxed now. Avoiding it needs a hand-written web print and raster path beside the mandated package (research R4). |
