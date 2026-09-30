import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import 'package:mbe_ui/core/documents/domain/document_output.dart';
import 'package:mbe_ui/core/documents/domain/document_ref.dart';

final documentOutputProvider = Provider<DocumentOutput>((ref) {
  return PrintingDocumentOutput();
});

/// Opens the platform print dialog for [bytes]. `true` unless the user
/// cancelled, on platforms that can tell (web cannot).
typedef PrintPdf = Future<bool> Function(Uint8List bytes, String name);

/// Downloads (web) or offers for saving/sharing (native) [bytes].
typedef SharePdf = Future<bool> Function(Uint8List bytes, String filename);

/// Rasters a PDF's [pages] (all when null) at [dpi].
typedef RasterPdf =
    Stream<PdfRaster> Function(
      Uint8List bytes, {
      List<int>? pages,
      required double dpi,
    });

const _defaultDpi = 200.0;
const _floorDpi = 36.0;
const _probeDpi = 72.0; // one pixel per point
const _maxSidePx = 30000.0;
const _maxAreaPx = 16e6;

/// The resolution to raster a page of [widthPt] × [heightPt] points at
/// (spec 044 research R7): 200 dpi, lowered only when the page would pass
/// 30 000 px on a side or 16 MP in area — browsers cap canvases near there,
/// and only an unusually long ticket gets close. Never below 36 dpi, and an
/// unusable size falls back to the default.
double rasterDpiFor(double widthPt, double heightPt) {
  if (widthPt <= 0 || heightPt <= 0) return _defaultDpi;
  final bySide = _maxSidePx * 72 / math.max(widthPt, heightPt);
  final byArea = 72 * math.sqrt(_maxAreaPx / (widthPt * heightPt));
  return math.max(_floorDpi, math.min(_defaultDpi, math.min(bySide, byArea)));
}

/// `DocumentOutput` backed by the `printing` package (research R2, R5, R6).
///
/// The three platform calls are injectable so tests can fake them: they are
/// static methods over platform channels and, on web, pdf.js.
class PrintingDocumentOutput implements DocumentOutput {
  PrintingDocumentOutput({
    PrintPdf? printPdf,
    SharePdf? sharePdf,
    RasterPdf? rasterPdf,
  }) : _printPdf = printPdf ?? _layoutPdf,
       _sharePdf = sharePdf ?? _defaultSharePdf,
       _rasterPdf = rasterPdf ?? _defaultRasterPdf;

  final PrintPdf _printPdf;
  final SharePdf _sharePdf;
  final RasterPdf _rasterPdf;

  /// The result is ignored on purpose: a native `false` is a user cancel, and
  /// web reports `true` whether the user printed, cancelled, or a pop-up
  /// blocker stopped the tab (research R5). Neither is an error (FR-031).
  @override
  Future<void> print(RenderedDocument document) async {
    await _printPdf(document.bytes, document.filename);
  }

  @override
  Future<void> save(RenderedDocument document) async {
    await _sharePdf(document.bytes, document.filename);
  }

  /// Two passes, because `Printing.raster` takes one dpi for every page and a
  /// page's size is only known once it has been rastered. Page 0 is rastered
  /// alone at 72 dpi (one pixel per point) to learn the size; then every page
  /// is rastered at the dpi [rasterDpiFor] picks. One dpi for all pages suits
  /// these documents: a ticket or cut is one page and a pedido's are all
  /// Letter.
  @override
  Stream<DocumentPage> raster(RenderedDocument document) async* {
    PdfRaster? probe;
    await for (final page in _rasterPdf(
      document.bytes,
      pages: const [0],
      dpi: _probeDpi,
    )) {
      probe = page;
      break;
    }
    if (probe == null) return;

    final dpi = rasterDpiFor(probe.width.toDouble(), probe.height.toDouble());
    await for (final page in _rasterPdf(document.bytes, dpi: dpi)) {
      // Pixels back to points, so the page's size does not depend on the
      // resolution it happened to be rastered at.
      final toPoints = 72 / dpi;
      yield DocumentPage(
        image: MemoryImage(await page.toPng()),
        size: Size(page.width * toPoints, page.height * toPoints),
      );
    }
  }
}

Future<bool> _layoutPdf(Uint8List bytes, String name) =>
    Printing.layoutPdf(onLayout: (_) async => bytes, name: name);

Future<bool> _defaultSharePdf(Uint8List bytes, String filename) =>
    Printing.sharePdf(bytes: bytes, filename: filename);

Stream<PdfRaster> _defaultRasterPdf(
  Uint8List bytes, {
  List<int>? pages,
  required double dpi,
}) => Printing.raster(bytes, pages: pages, dpi: dpi);
