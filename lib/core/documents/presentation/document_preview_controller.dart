import 'package:flutter/foundation.dart' show immutable;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/documents/data/document_source_impl.dart';
import 'package:mbe_ui/core/documents/data/printing_document_output.dart';
import 'package:mbe_ui/core/documents/domain/document_ref.dart';
import 'package:mbe_ui/core/documents/presentation/document_access.dart';
import 'package:mbe_ui/core/errors/app_error.dart';

part 'document_preview_controller.g.dart';

/// What the preview shows once loaded: the bytes as the server sent them (what
/// Imprimir and Descargar hand over) and every page, rastered.
@immutable
class DocumentPreviewData {
  const DocumentPreviewData({required this.document, required this.pages});

  final RenderedDocument document;
  final List<DocumentPage> pages;
}

/// Fetches a document and rasters its pages for the preview (spec 044 US2).
///
/// Loading → loaded → error, and never a partial page list: the state is
/// `AsyncData` only once every page exists (contract G4). Auto-disposed, so
/// closing the preview drops the bytes and pages, and the next open fetches
/// again (FR-022, contract G3). A retry is `ref.invalidate` on this provider.
@riverpod
class DocumentPreviewController extends _$DocumentPreviewController {
  @override
  Future<DocumentPreviewData> build(DocumentRef document) async {
    // Re-checked here, not only where the button is shown, so no path to the
    // network skips it (FR-041). A refusal is an error state like any other.
    requireDocumentAccess(ref.read(accessControlProvider), document.kind);

    final source = ref.watch(documentSourceProvider);
    final output = ref.watch(documentOutputProvider);

    try {
      final rendered = await source.fetch(document);
      final pages = await output.raster(rendered).toList();
      if (pages.isEmpty) throw const AppError.server();
      return DocumentPreviewData(document: rendered, pages: pages);
    } on AppError {
      rethrow;
    } catch (_) {
      // A rasterizing failure (pdf.js missing, a platform error) is not an
      // AppError; the preview's error state needs one.
      throw const AppError.server();
    }
  }
}
