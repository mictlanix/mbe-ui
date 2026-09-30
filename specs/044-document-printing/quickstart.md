# Quickstart: Document Printing

**Feature**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md)

How to prove the feature works. The contracts are in [contracts/](./contracts/), the types in [data-model.md](./data-model.md).

## Prerequisites

- On branch `044-document-printing`, with `flutter pub get` run after `printing` was added. Flutter 3.44.x. `printing` 5.15.1 needs Dart ≥ 3.12 to build (research R1).
- `web/pdfjs/pdf.min.mjs`, `web/pdfjs/pdf.worker.min.mjs` and `web/pdfjs/LICENSE` exist (pdfjs-dist 6.2.108), and `web/index.html` sets `dartPdfJsBaseUrl = "./pdfjs/"` (research R3).
- For live checks: an mbe-api at or after mbe-api#231, plus `.env` with `MBE_POS_*` (the admin account). See the POS integration-test memory: use `--dart-define=MBE_POS_PRODUCT_PATTERN=clavo`.

## 1. Automated tests

```bash
# Byte-body error mapping (research R9) — the first auth_interceptor test
flutter test test/unit/core/network/auth_interceptor_test.dart

# The document module: source, controller, zoom and page-in-view arithmetic
flutter test test/unit/core/documents/

# The preview dialog and every call site
flutter test test/widget/core/documents/ test/widget/features/sales/

# Everything, as the quality gate
flutter test test/unit test/widget

# Live: fetch all three documents, byte-equality (SC-003), 409 message (SC-005)
flutter test test/integration/document_printing_flow_test.dart \
  --dart-define-from-file=.env --dart-define=MBE_POS_PRODUCT_PATTERN=clavo
```

**Expected**: all tests pass. The integration test *skips* rather than fails when it can't find its fixtures at runtime: a completed sale, a closed session and an open session. A silent skip means the data wasn't found, not that the flow passed.

## 2. Manual checks in Chrome (`flutter run -d chrome --dart-define-from-file=.env`)

| # | Steps | Expected | Covers |
|---|---|---|---|
| M1 | Complete a POS sale, then in "Venta completada" press **Imprimir ticket**. | The browser's print preview opens with the "Ticket de Venta", 72 mm wide. The dialog stays open, and "Nueva venta" is still the filled button. **Time it from the press to the print preview appearing: under 3 s.** | US1, FR-002, SC-001 |
| M2 | POS sales list: press the ticket icon on a draft and on a paid sale. | The preview opens. The draft shows "Punto de Venta" (pre-payment), the paid sale shows the receipt. The page indicator reads "Página 1 / 1". | US4, FR-003 |
| M3 | In the preview, use `[+]` twice, pinch (trackpad), Ctrl/⌘ + wheel, a plain wheel, then `[⤢]`. | The level readout changes through the steps. A plain wheel scrolls and doesn't zoom. `[⤢]` returns to fit-to-width. You can pan a zoomed page. | FR-011, US2-8 |
| M4 | Open a pedido with more than one page from the order workspace. | "Página 1 / N" updates as you scroll. **Descargar** saves `pedido-000XXXXX.pdf`. **Time it from pressing Ver pedido to every page being visible: under 3 s.** | US5, US2-3, US2-6, SC-002 |
| M5 | In the workspace, type into the comment field without pressing Enter, then press **Ver pedido**. | The "Cambios sin confirmar" prompt appears. "Seguir editando" cancels; "Conservar" saves, then the preview opens showing the new comment. | FR-009 |
| M6 | Close a cash session, then press **Ver corte** in "Sesión cerrada". | The dialog closes, and the preview opens over a detail screen that now shows *Cerrada* with its own **Ver corte**. The close message no longer says "no se mostrarán de nuevo". **Then time a reprint: from the cash sessions list, open that session and get its cut on screen in under 30 s.** | US3, FR-005/007/008, SC-007 |
| M7 | Stop mbe-api and open any preview. | An error banner with Reintentar. Restart the API, press Reintentar, and the document loads. | FR-013 |
| M8 | Sign in as a user without `salesOrders` read, then as one without `pos` read. | No ticket or pedido actions for the first; no Ver corte for the second. | FR-040, SC-008 |
| M9 | DevTools → Network, preserve log. Open, zoom, print and download a document. | Every request goes to the app's own origin or mbe-api. None to unpkg or any other host. | FR-014, SC-004 |

## 3. Hardware and device checks

| # | Steps | Expected | Covers |
|---|---|---|---|
| H1 | M1 with a real 80 mm thermal printer through the OS dialog, at actual size (not "fit to page"). | The full 72 mm width prints with nothing clipped, and no blank paper feeds beyond the printer's own feed. | SC-006 |
| H2 | Open a pedido in a phone browser (or Chrome's device mode with a mobile UA). | The dialog is full-screen. Pinch and `[+]` make the letter page readable. **Imprimir** opens the PDF in a new tab; **Descargar** downloads it. | FR-010/011, edge case (research R5) |

## Deployment note (research R4)

`web/index.html` sets no Content Security Policy today. If one is added, the `printing` package needs these directives:

- `script-src 'self' 'unsafe-eval' 'unsafe-inline'`. pdf.js is reached through `eval`, and printing injects an inline iframe script.
- `worker-src 'self' blob:`

Without them, the preview and printing fail on web.
