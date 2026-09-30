# Contract: `core/documents` module

The shared surface every call site uses. Call sites depend only on `DocumentActions` and `DocumentRef`/`DocumentKind`, never on the `printing` package or the generated APIs. That is what keeps a future server-side print path additive (FR-015, research R11).

## Domain interfaces (`lib/core/documents/domain/`)

```dart
abstract interface class DocumentSource {
  /// Fetches the PDF mbe-api renders for [ref].
  /// Throws AppError (NotFound / Server(403|409|5xx) / Network / Auth) carrying the server's detail (FR-030).
  Future<RenderedDocument> fetch(DocumentRef ref);
}

abstract interface class DocumentOutput {
  /// Opens the device print dialog with [document]'s bytes.
  /// A user cancel is NOT an error (FR-031).
  Future<void> print(RenderedDocument document);

  /// Downloads (web) or offers the file for saving/sharing (native) under document.filename (FR-012, research R6).
  Future<void> save(RenderedDocument document);

  /// Rasterizes every page, in order (research R2, R7).
  Stream<DocumentPage> raster(RenderedDocument document);
}
```

Providers:
- `documentSourceProvider` → `DocumentSourceImpl` (data/).
- `documentOutputProvider` → `PrintingDocumentOutput` (data/).

Tests override both (Principle II).

## Presentation API (`lib/core/documents/presentation/`)

```dart
/// The only entry points call sites use.
class DocumentActions {
  /// Opens the shared preview dialog (FR-010): a modal Dialog at ≥ medium, Dialog.fullscreen on Compact.
  /// Re-checks ref.kind's gate first (FR-041). On failure it still opens the dialog, directly in its
  /// error state with the permission error and no fetch, so it never throws and call sites need no
  /// error handling.
  Future<void> preview(BuildContext context, DocumentRef ref);

  /// Fetches, then prints straight away, with no preview. Used ONLY by the POS completion dialog (FR-002).
  /// Re-checks the gate first. Throws AppError for the caller to show inline.
  Future<void> printDirect(DocumentRef ref);
}

final documentActionsProvider = Provider<DocumentActions>(...);

/// Whether the current user may open [kind] (FR-040). Call sites use it to hide actions.
bool canOpenDocument(AccessControlService access, DocumentKind kind);
```

### Behaviour guarantees

| # | Guarantee | Source |
|---|---|---|
| G1 | While a fetch for the same `DocumentRef` is in flight, a second `printDirect` or `preview` call is ignored. | FR-032 |
| G2 | The bytes given to `print` and `save` are exactly the bytes returned by `fetch`. | FR-020 |
| G3 | Nothing is cached between opens; each `preview` fetches again. | FR-022 |
| G4 | The preview never shows a partial page list. It is loading, loaded (all pages) or error. | FR-013, edge case "network drops" |
| G5 | Closing the preview returns to the caller with no state change there. | US2-7 |

## Preview dialog regions

The wireframes define the layout: [wireframes.md](../wireframes.md), "Shared document preview".

| Region | Content | Keys (for tests) |
|---|---|---|
| Title bar | `ref.title`, plus a close `IconButton` (leading on Compact, trailing otherwise) | `document_preview_close` |
| Page area | the zoomable viewer (research R8); or the loading indicator; or, on error, a heading (`documentLoadFailedError`), then `ErrorBanner(error)`, then a separate `TextButton` Reintentar. `ErrorBanner` has no retry slot. | `document_preview_pages`, `document_preview_retry` |
| Action bar | `[−]` level `[+]` `[⤢]`, then "Página n / N", then `OutlinedButton.icon` Descargar and `FilledButton.icon` Imprimir | `document_zoom_out`, `document_zoom_level`, `document_zoom_in`, `document_zoom_fit`, `document_page_indicator`, `document_download`, `document_print` |

## Call sites

| Call site | Entry | Gate | Notes |
|---|---|---|---|
| `pos_workspace_screen.dart` `_finish` dialog | `printDirect(DocumentRef(saleTicket, sale.id, …))` from an `OutlinedButton.icon` placed before the `FilledButton` "Nueva venta" | `salesOrders` read | Busy and error states shown inline in the dialog; the dialog stays open (FR-002, US1). |
| `pos_sales_list_screen.dart` row | `preview(saleTicket, openSale.id)` as the single `CatalogRowAction` | `salesOrders` read | FR-003 |
| `orders/order_header_panel.dart` `_headerRow` | `preview(salesOrder, sale.id)`, after `resolveUnconfirmedEdits` | `salesOrders` read | Disabled while pending writes > 0 (FR-009, research R13). |
| `cash_session_detail_screen.dart` close dialog | pop the dialog, then `preview(cashCut, session.id)` | `pos` read | FR-005 |
| `cash_session_detail_screen.dart` body (closed only) | `preview(cashCut, session.id)` | `pos` read | FR-006 |
