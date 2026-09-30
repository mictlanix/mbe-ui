import 'document_ref.dart';

/// Where a fetched document goes: the print dialog, a saved file, or the
/// preview's page images.
///
/// Hiding the `printing` package behind this keeps every test independent of
/// platform channels and pdf.js, and keeps a future server-side "send to
/// printer" path additive (FR-015, research R11).
abstract interface class DocumentOutput {
  /// Opens the device print dialog with [document]'s bytes. A user cancel is
  /// not an error (FR-031).
  Future<void> print(RenderedDocument document);

  /// Downloads (web) or offers for saving/sharing (native) the bytes under
  /// `document.filename` (FR-012, research R6).
  Future<void> save(RenderedDocument document);

  /// Rasterizes every page, in order (research R2, R7).
  Stream<DocumentPage> raster(RenderedDocument document);
}
