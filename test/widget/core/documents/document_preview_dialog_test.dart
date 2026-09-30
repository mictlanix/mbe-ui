import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/documents/data/document_source_impl.dart';
import 'package:mbe_ui/core/documents/data/printing_document_output.dart';
import 'package:mbe_ui/core/documents/domain/document_kind.dart';
import 'package:mbe_ui/core/documents/domain/document_ref.dart';
import 'package:mbe_ui/core/documents/presentation/document_actions.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';

import '../../../unit/core/documents/document_fakes.dart';
import '../../features/sales/pos_test_harness.dart';

/// Spec 044 US2: the shared preview dialog, in every state the wireframes draw.
///
/// Opened through `DocumentActions.preview`, the way every call site does.
const _ticket = DocumentRef(
  kind: DocumentKind.saleTicket,
  recordId: 42,
  title: 'Ticket · Folio #42',
);

const _pedido = DocumentRef(
  kind: DocumentKind.salesOrder,
  recordId: 1234,
  title: 'Pedido · 00001234',
);

const _expanded = Size(1000, 800);
const _medium = Size(700, 800);
const _compact = Size(400, 800);

/// The widest phone: still the Compact tier (< 600), with room for the zoom
/// controls and the page indicator on one row in the test font, which is
/// wider than the real one.
const _compactWide = Size(560, 800);

void main() {
  late FakeDocumentSource source;
  late FakeDocumentOutput output;

  setUp(() {
    source = FakeDocumentSource();
    output = FakeDocumentOutput();
  });

  final launcher = find.byKey(const Key('open_preview'));
  final title = find.byKey(const Key('document_preview_title'));
  final pages = find.byKey(const Key('document_preview_pages'));
  final closeButton = find.byKey(const Key('document_preview_close'));
  final zoomOut = find.byKey(const Key('document_zoom_out'));
  final zoomIn = find.byKey(const Key('document_zoom_in'));
  final zoomFit = find.byKey(const Key('document_zoom_fit'));
  final level = find.byKey(const Key('document_zoom_level'));
  final indicator = find.byKey(const Key('document_page_indicator'));
  final download = find.byKey(const Key('document_download'));
  final print = find.byKey(const Key('document_print'));
  final actionBar = find.byKey(const Key('document_action_bar'));
  final surface = find.byKey(const Key('document_preview_surface'));
  final retry = find.byKey(const Key('document_preview_retry'));

  /// Pumps a launcher and taps it, so the dialog is opened as in production.
  Future<ProviderContainer> openPreview(
    WidgetTester tester, {
    DocumentRef document = _ticket,
    user,
    Size surface = _expanded,
    bool settle = true,
  }) async {
    final container = await pumpPos(
      tester,
      Consumer(
        builder: (context, ref, _) => Center(
          child: TextButton(
            key: const Key('open_preview'),
            onPressed: () =>
                ref.read(documentActionsProvider).preview(context, document),
            child: const Text('open'),
          ),
        ),
      ),
      overrides: [
        accessControlProvider.overrideWithValue(
          accessFor(user ?? salesOrdersReader),
        ),
        documentSourceProvider.overrideWithValue(source),
        documentOutputProvider.overrideWithValue(output),
      ],
      surface: surface,
    );
    await tester.tap(launcher);
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }
    return container;
  }

  /// A mouse wheel over the page area.
  Future<void> wheel(WidgetTester tester, Offset delta) async {
    final pointer = TestPointer(1, PointerDeviceKind.mouse);
    await tester.sendEventToBinding(pointer.hover(tester.getCenter(pages)));
    await tester.sendEventToBinding(pointer.scroll(delta));
    await tester.pump();
  }

  int percent(WidgetTester tester) => int.parse(
    tester.widget<Text>(level).data!.replaceAll(RegExp(r'[^0-9]'), ''),
  );

  group('loading', () {
    testWidgets('shows progress, no active actions, and a dash for the page '
        'count (FR-013)', (tester) async {
      final gate = Completer<void>();
      source.handler = (ref) async {
        await gate.future;
        return fakeDocument();
      };
      await openPreview(tester, settle: false);
      await tester.pump();

      expect(find.text('Ticket · Folio #42'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Cargando documento…'), findsOneWidget);
      expect(find.text('Página – / –'), findsOneWidget);
      expect(tester.widget<OutlinedButton>(download).onPressed, isNull);
      expect(tester.widget<FilledButton>(print).onPressed, isNull);
      expect(tester.widget<IconButton>(zoomIn).onPressed, isNull);
      expect(tester.widget<IconButton>(zoomOut).onPressed, isNull);

      gate.complete();
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(print).onPressed, isNotNull);
    });
  });

  group('loaded', () {
    testWidgets('a ticket is one narrow page at its natural size, centred, '
        'not stretched to the dialog (FR-011)', (tester) async {
      output.pages = [fakePage(width: 204, height: 600)];
      await openPreview(tester);

      expect(find.text('Página 1 / 1'), findsOneWidget);
      expect(find.text('100 %'), findsOneWidget);
      final page = find.byKey(const Key('document_page_0'));
      final size = tester.getSize(page);
      // 72 mm = 204 pt = 272 logical px at 96 dpi; the dialog is far wider.
      expect(size.width, closeTo(272, 0.5));
      expect(size.height, closeTo(272 * 600 / 204, 0.5));
      expect(
        tester.getCenter(page).dx,
        closeTo(tester.getCenter(pages).dx, 0.5),
      );
    });

    testWidgets('a letter document is several pages at its natural width', (
      tester,
    ) async {
      output.pages = [
        for (var i = 0; i < 3; i++) fakePage(width: 612, height: 792),
      ];
      await openPreview(tester, document: _pedido);

      expect(find.text('Página 1 / 3'), findsOneWidget);
      final size = tester.getSize(find.byKey(const Key('document_page_0')));
      expect(size.width, closeTo(816, 0.5)); // 612 pt at 96 dpi
      expect(size.height, closeTo(1056, 0.5)); // true proportions
    });

    testWidgets('a page wider than the preview is fitted to its width', (
      tester,
    ) async {
      output.pages = [fakePage(width: 612, height: 792)];
      await openPreview(tester, document: _pedido, surface: _medium);

      final size = tester.getSize(find.byKey(const Key('document_page_0')));
      final available = tester.getSize(pages).width;
      expect(size.width, lessThan(816));
      expect(size.width, closeTo(available - 2 * 16, 0.5));
      expect(size.height / size.width, closeTo(792 / 612, 0.001));
    });

    testWidgets('Imprimir and Descargar hand over the same bytes and file '
        'name (contract G2)', (tester) async {
      final document = fakeDocument(
        filename: 'ticket-00000042.pdf',
        tail: [200, 201, 0, 255],
      );
      source.handler = (ref) async => document;
      await openPreview(tester);

      await tester.tap(print);
      await tester.pumpAndSettle();
      await tester.tap(download);
      await tester.pumpAndSettle();

      expect(output.printed.single, same(document));
      expect(output.saved.single, same(document));
      expect(find.byType(ErrorBanner), findsNothing);
      // The dialog stays open after either.
      expect(title, findsOneWidget);
    });

    testWidgets('a print or download failure shows the reason and keeps the '
        'document', (tester) async {
      output.printHandler = (document) async =>
          throw const AppError.server(message: 'Printer offline');
      await openPreview(tester);

      await tester.tap(print);
      await tester.pumpAndSettle();

      expect(find.byType(ErrorBanner), findsOneWidget);
      expect(find.text('Printer offline'), findsOneWidget);
      expect(pages, findsOneWidget);
      expect(tester.widget<FilledButton>(print).onPressed, isNotNull);
    });
  });

  group('zoom (FR-011, US2-8)', () {
    testWidgets('the buttons step through the levels and the readout follows', (
      tester,
    ) async {
      await openPreview(tester);

      await tester.tap(zoomIn);
      await tester.pump();
      expect(find.text('125 %'), findsOneWidget);
      await tester.tap(zoomIn);
      await tester.pump();
      expect(find.text('150 %'), findsOneWidget);
      await tester.tap(zoomOut);
      await tester.pump();
      expect(find.text('125 %'), findsOneWidget);
      await tester.tap(zoomFit);
      await tester.pump();
      expect(find.text('100 %'), findsOneWidget);
    });

    testWidgets('each end disables its button', (tester) async {
      await openPreview(tester);

      for (var i = 0; i < 5; i++) {
        await tester.tap(zoomIn); // 125, 150, 200, 300, 400
        await tester.pump();
      }
      expect(find.text('400 %'), findsOneWidget);
      expect(tester.widget<IconButton>(zoomIn).onPressed, isNull);

      await tester.tap(zoomFit);
      await tester.pump();
      for (var i = 0; i < 2; i++) {
        await tester.tap(zoomOut); // 75, 50
        await tester.pump();
      }
      expect(find.text('50 %'), findsOneWidget);
      expect(tester.widget<IconButton>(zoomOut).onPressed, isNull);
    });

    testWidgets('a plain wheel scrolls and does not zoom', (tester) async {
      output.pages = [
        for (var i = 0; i < 3; i++) fakePage(width: 612, height: 792),
      ];
      await openPreview(tester, document: _pedido);
      expect(find.text('Página 1 / 3'), findsOneWidget);

      await wheel(tester, const Offset(0, 1200));

      expect(find.text('100 %'), findsOneWidget);
      expect(find.text('Página 2 / 3'), findsOneWidget);
    });

    testWidgets('Ctrl + wheel zooms', (tester) async {
      await openPreview(tester);
      expect(percent(tester), 100);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await wheel(tester, const Offset(0, -200));
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);

      expect(percent(tester), greaterThan(100));
    });
  });

  group('page indicator', () {
    testWidgets('follows the page in view as the document scrolls', (
      tester,
    ) async {
      output.pages = [
        for (var i = 0; i < 3; i++) fakePage(width: 612, height: 792),
      ];
      await openPreview(tester, document: _pedido);

      expect(find.text('Página 1 / 3'), findsOneWidget);
      await wheel(tester, const Offset(0, 1200));
      expect(find.text('Página 2 / 3'), findsOneWidget);
      await wheel(tester, const Offset(0, 1500));
      expect(find.text('Página 3 / 3'), findsOneWidget);
    });
  });

  group('error', () {
    testWidgets("shows the server's reason and retry fetches again (US2-5)", (
      tester,
    ) async {
      var attempts = 0;
      source.handler = (ref) async {
        attempts++;
        if (attempts == 1) {
          throw const AppError.server(
            statusCode: 409,
            message: 'Cash session is not closed',
          );
        }
        return fakeDocument();
      };
      await openPreview(tester);

      expect(find.byType(ErrorBanner), findsOneWidget);
      expect(find.text('Cash session is not closed'), findsOneWidget);
      expect(find.text('No se pudo cargar el documento.'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
      expect(tester.widget<FilledButton>(print).onPressed, isNull);
      expect(tester.widget<OutlinedButton>(download).onPressed, isNull);

      await tester.tap(retry);
      await tester.pumpAndSettle();

      expect(source.fetched, hasLength(2));
      expect(find.byType(ErrorBanner), findsNothing);
      expect(pages, findsOneWidget);
    });

    testWidgets('a user without the kind\'s privilege sees the permission '
        'error and nothing is fetched (FR-041)', (tester) async {
      await openPreview(tester, user: posReader);

      expect(find.text('Insufficient privileges'), findsOneWidget);
      expect(source.fetched, isEmpty);
      expect(output.rastered, isEmpty);
    });
  });

  group('the dialog surface (FR-010)', () {
    testWidgets('is a constrained dialog on the expanded tier', (tester) async {
      await openPreview(tester);

      final size = tester.getSize(surface);
      expect(size.width, lessThanOrEqualTo(960));
      expect(size.width, lessThan(_expanded.width));
      expect(size.height, lessThan(_expanded.height));
    });

    testWidgets('fills the screen on a phone, with the close button leading', (
      tester,
    ) async {
      await openPreview(tester, surface: _compact);

      expect(tester.getSize(surface), _compact);
      expect(
        tester.getTopLeft(closeButton).dx,
        lessThan(tester.getTopLeft(title).dx),
      );
    });

    testWidgets('closing returns to the caller unchanged (US2-7, G5)', (
      tester,
    ) async {
      await openPreview(tester);

      await tester.tap(closeButton);
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsNothing);
      expect(launcher, findsOneWidget);
    });

    testWidgets('a second open while one is showing adds no second dialog '
        'and no second fetch (FR-032)', (tester) async {
      final container = await openPreview(tester, settle: false);
      final context = tester.element(launcher);

      // Same frame as the first open: the dialog is not up yet.
      unawaited(
        container.read(documentActionsProvider).preview(context, _ticket),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsOneWidget);
      expect(source.fetched, hasLength(1));
    });
  });

  group('the action bar never overflows', () {
    testWidgets('at 320 px wide with text scaled to 200 %', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await openPreview(tester, surface: const Size(320, 640));

      expect(tester.takeException(), isNull);
      expect(print, findsOneWidget);
      expect(download, findsOneWidget);
      expect(zoomIn, findsOneWidget);
      expect(indicator, findsOneWidget);
    });
  });

  group('action bar alignment (constitution §VI, v1.11.0)', () {
    /// One shared text baseline: same style and equal centres for text that
    /// sits in one horizontal band.
    void expectSharedBaseline(WidgetTester tester, List<Finder> texts) {
      final centres = [for (final t in texts) tester.getCenter(t).dy];
      final heights = [for (final t in texts) tester.getSize(t).height];
      for (var i = 1; i < texts.length; i++) {
        expect(centres[i], closeTo(centres[0], 0.5), reason: 'text $i');
        expect(heights[i], closeTo(heights[0], 0.5), reason: 'text $i height');
      }
    }

    Finder labelOf(Finder button, String label) =>
        find.descendant(of: button, matching: find.text(label));

    testWidgets('the readout, the page indicator and both button labels share '
        'one baseline, and the band has symmetric vertical insets', (
      tester,
    ) async {
      await openPreview(tester);

      expectSharedBaseline(tester, [
        level,
        indicator,
        labelOf(download, 'Descargar'),
        labelOf(print, 'Imprimir'),
      ]);

      final bar = tester.getRect(actionBar);
      final tallest =
          [
            tester.getRect(download),
            tester.getRect(print),
            tester.getRect(zoomIn),
          ].fold<Rect>(
            tester.getRect(print),
            (a, b) => Rect.fromLTRB(
              a.left < b.left ? a.left : b.left,
              a.top < b.top ? a.top : b.top,
              a.right > b.right ? a.right : b.right,
              a.bottom > b.bottom ? a.bottom : b.bottom,
            ),
          );
      expect(tallest.top - bar.top, closeTo(bar.bottom - tallest.bottom, 0.5));
    });

    testWidgets('the same holds on a phone, in each of its two rows', (
      tester,
    ) async {
      await openPreview(tester, surface: _compactWide);

      // Row 1: zoom and the page indicator. Row 2: the two buttons.
      expectSharedBaseline(tester, [level, indicator]);
      expectSharedBaseline(tester, [
        labelOf(download, 'Descargar'),
        labelOf(print, 'Imprimir'),
      ]);
      expect(
        tester.getTopLeft(print).dy,
        greaterThan(tester.getBottomLeft(level).dy),
        reason: 'the buttons wrap onto a second line',
      );
    });
  });
}
