# Data Model: Document Printing

**Feature**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md)

Nothing is persisted (FR-022, constitution §VII). These are the in-memory types that carry a document from a call site to the printer. All of them live in `lib/core/documents/domain/` except the preview state, which lives in `presentation/`.

## DocumentKind (enum)

What a document is: which endpoint serves it, which privilege gates it, and how its fallback file name is formed.

| Value | Endpoint (generated method) | Gate (FR-040) | Fallback file name (R10) | Page geometry (server-owned) |
|---|---|---|---|---|
| `saleTicket` | `GET /sales-orders/{id}/ticket` (`SalesOrdersApi.printSalesOrderTicket…`) | `salesOrders` + `read` | `ticket-{id:08d}.pdf` | 72 mm wide, one page, height fitted to content |
| `salesOrder` | `GET /sales-orders/{id}/document` (`SalesOrdersApi.printSalesOrderDocument…`) | `salesOrders` + `read` | `pedido-{id:08d}.pdf` | Letter, multi-page |
| `cashCut` | `GET /cash-sessions/{id}/ticket` (`CashSessionsApi.printCashSessionCut…`) | `pos` + `read` | `corte-{id:06d}.pdf` | 72 mm wide, one page, height fitted to content |

The client never branches on geometry. It is listed only so the tests know what to expect (FR-021).

## DocumentRef

An immutable request for one document (spec: "Document reference").

| Field | Type | Rules |
|---|---|---|
| `kind` | `DocumentKind` | required |
| `recordId` | `int` | required, > 0. For `saleTicket` and `salesOrder` it is a sales order id; for `cashCut` it is a cash session id. |
| `title` | `String` | required. The localized preview title. Built by the call site with one rule per kind: **ticket**: "Ticket · Folio #{serial}" when the sale has a serial; otherwise the POS completion dialog uses its provisional reference, and the POS list (where `OpenSale` has none) uses the sales order id padded to 8 digits. **Pedido**: "Pedido · {id:08d}". **Cut**: "Corte de caja · {id:06d}". The padded forms match the server's file names. |

Equality is by value (`kind`, `recordId`, `title`), so it can key a provider family.

## RenderedDocument

The bytes mbe-api returned (spec: "Rendered document").

| Field | Type | Rules |
|---|---|---|
| `bytes` | `Uint8List` | non-empty, and starts with `%PDF-`. Anything else is a `ServerError` (FR-020). It is never modified (FR-021). |
| `filename` | `String` | from `Content-Disposition`, or the kind's fallback (R10) |

It is held only while the preview is open or a print is in progress. It is never written to storage or cached across opens (FR-022).

## DocumentPage

One rasterized page (R2, R7).

| Field | Type | Rules |
|---|---|---|
| `image` | `ImageProvider` | the rastered page |
| `size` | `Size` | the page's size in PDF points (1/72 inch), not raster pixels, so it does not depend on the dpi used. It sets the aspect ratio drawn in the preview, and how wide a page narrower than the preview (a 72 mm ticket) is shown (FR-011). |

## DocumentPreviewState (presentation)

`DocumentPreviewController` is an `AsyncNotifier` family keyed by `DocumentRef`. It exposes `AsyncValue<DocumentPreviewData>` (Principle II). Zoom and page-in-view are local UI state kept in the viewer (plain `Notifier`/controller), not in this `AsyncValue`.

```text
          open ──► loading ──fetch ok + raster ok──► loaded(document, pages)
                     │                                   │
                     └──fetch/raster error──► error(AppError) ──retry──► loading
```

- **loading**: Descargar and Imprimir are disabled; the page indicator reads "– / –" (FR-013).
- **loaded**: `DocumentPreviewData { RenderedDocument document; List<DocumentPage> pages; }`. The page indicator shows "Página n / pages.length" (FR-011).
- **error**: `AppError`, whose server detail is shown through `ErrorBanner` (FR-013, FR-030). Retry invalidates the family entry, which fetches again (FR-022).
- The entry is autoDispose: closing the dialog drops the bytes and pages.

## Zoom model (viewer-local)

| Item | Value |
|---|---|
| Opening level | fit-to-width (= 100 %) |
| Steps | 50 · 75 · 100 · 125 · 150 · 200 · 300 · 400 % of fit-to-width (R7) |
| `[−]` / `[+]` | the next lower or higher step from the current scale; disabled at the ends |
| `[⤢]` | back to fit-to-width, scrolled to the top of the current page |
| Pinch / Ctrl-⌘ + wheel | continuous, clamped to [50 %, 400 %]; the readout shows the rounded level |

## Where each state change comes from

| Trigger | Effect |
|---|---|
| Cash session closed | `cashSessionDetailControllerProvider(id)` is invalidated → the detail shows the closed state and "Ver corte" (FR-007, R14) |
| Order workspace pending writes > 0 | "Ver pedido" is disabled (FR-009, R13) |
| Unconfirmed edits present on "Ver pedido" | `resolveUnconfirmedEdits`: keep/discard proceeds; keep-editing cancels (FR-009) |
