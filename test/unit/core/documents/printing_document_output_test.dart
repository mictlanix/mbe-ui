import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_ui/core/documents/data/printing_document_output.dart';
import 'package:mbe_ui/core/documents/domain/document_ref.dart';
import 'package:printing/printing.dart' show PdfRaster;

const _mm = 72 / 25.4;

void main() {
  group('rasterDpiFor (research R7)', () {
    test('a Letter page rasters at 200 dpi', () {
      expect(rasterDpiFor(612, 792), 200);
    });

    test('a 72 mm ticket a metre long rasters at 200 dpi', () {
      expect(rasterDpiFor(72 * _mm, 1000 * _mm), 200);
    });

    test('a page that would pass 30 000 px on a side is lowered to fit', () {
      const width = 72 * _mm;
      const height = 4200 * _mm; // 4.2 m of ticket
      final dpi = rasterDpiFor(width, height);

      expect(dpi, lessThan(200));
      expect(height * dpi / 72, lessThanOrEqualTo(30000.0 + 1e-6));
    });

    test('a page that would pass 16 MP is lowered to fit', () {
      const side = 2000.0; // points; 5 556 px a side at 200 dpi = 30.9 MP
      final dpi = rasterDpiFor(side, side);

      expect(dpi, lessThan(200));
      final px = side * dpi / 72;
      expect(px * px, lessThanOrEqualTo(16e6 + 1));
    });

    test('never goes below the floor, even for an absurd page', () {
      expect(rasterDpiFor(100, 1e6), 36);
    });

    test('an unusable size falls back to the default', () {
      expect(rasterDpiFor(0, 0), 200);
      expect(rasterDpiFor(-5, 100), 200);
    });
  });

  group('PrintingDocumentOutput.print', () {
    test('hands over exactly the document bytes and file name', () async {
      Uint8List? printedBytes;
      String? printedName;
      final output = PrintingDocumentOutput(
        printPdf: (bytes, name) async {
          printedBytes = bytes;
          printedName = name;
          return true;
        },
      );
      final document = _document([9, 8, 7]);

      await output.print(document);

      expect(printedBytes, same(document.bytes));
      expect(printedName, 'ticket-00000042.pdf');
    });

    test('a cancelled print (false, as native platforms report it) completes '
        'normally — it is not an error (FR-031)', () async {
      final output = PrintingDocumentOutput(
        printPdf: (bytes, name) async => false,
      );

      await expectLater(output.print(_document([1])), completes);
    });
  });

  group('PrintingDocumentOutput.save', () {
    test('passes the bytes and the file name through', () async {
      Uint8List? savedBytes;
      String? savedName;
      final output = PrintingDocumentOutput(
        sharePdf: (bytes, filename) async {
          savedBytes = bytes;
          savedName = filename;
          return true;
        },
      );
      final document = _document([4, 5]);

      await output.save(document);

      expect(savedBytes, same(document.bytes));
      expect(savedName, 'ticket-00000042.pdf');
    });
  });

  group('PrintingDocumentOutput.raster', () {
    test('probes page 0 at 72 dpi, then rasters every page at the chosen '
        'dpi', () async {
      final calls = <({List<int>? pages, double dpi})>[];
      final output = PrintingDocumentOutput(
        rasterPdf: (bytes, {pages, required dpi}) {
          calls.add((pages: pages, dpi: dpi));
          // At 72 dpi one pixel is one point: a Letter page.
          if (pages != null) return Stream.value(_page(612, 792));
          return Stream.fromIterable([_page(1700, 2200), _page(1700, 2200)]);
        },
      );

      final pages = await output.raster(_document([1])).toList();

      expect(calls, hasLength(2));
      expect(calls[0].pages, [0]);
      expect(calls[0].dpi, 72);
      expect(calls[1].pages, isNull);
      expect(calls[1].dpi, 200);
      expect(pages, hasLength(2));
      // Pixels at 200 dpi, back to points: a Letter page.
      expect(pages.first.size.width, closeTo(612, 1e-9));
      expect(pages.first.size.height, closeTo(792, 1e-9));
    });

    test('lowers the dpi for a page the probe shows to be very tall', () async {
      const heightPt = 4200 * _mm;
      final calls = <double>[];
      final output = PrintingDocumentOutput(
        rasterPdf: (bytes, {pages, required dpi}) {
          calls.add(dpi);
          if (pages != null) {
            return Stream.value(_page((72 * _mm).round(), heightPt.round()));
          }
          return Stream.value(_page(100, 30000));
        },
      );

      await output.raster(_document([1])).toList();

      expect(calls.first, 72);
      expect(calls.last, lessThan(200));
    });

    test(
      'a document with no pages yields nothing and does not throw',
      () async {
        final output = PrintingDocumentOutput(
          rasterPdf: (bytes, {pages, required dpi}) => const Stream.empty(),
        );

        expect(await output.raster(_document([1])).toList(), isEmpty);
      },
    );
  });
}

RenderedDocument _document(List<int> tail) => RenderedDocument(
  bytes: Uint8List.fromList([0x25, 0x50, 0x44, 0x46, 0x2D, ...tail]),
  filename: 'ticket-00000042.pdf',
);

PdfRaster _page(int width, int height) => _FakeRaster(width, height);

class _FakeRaster extends PdfRaster {
  _FakeRaster(int width, int height) : super(width, height, Uint8List(0));

  @override
  Future<Uint8List> toPng() async =>
      Uint8List.fromList([0x89, 0x50, 0x4E, 0x47]);
}
