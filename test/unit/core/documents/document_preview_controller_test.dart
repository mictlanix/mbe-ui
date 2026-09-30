import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_ui/core/documents/domain/document_kind.dart';
import 'package:mbe_ui/core/documents/domain/document_ref.dart';
import 'package:mbe_ui/core/documents/presentation/document_preview_controller.dart';
import 'package:mbe_ui/core/errors/app_error.dart';

import 'document_fakes.dart';

const _ticket = DocumentRef(
  kind: DocumentKind.saleTicket,
  recordId: 42,
  title: 'Ticket · Folio #42',
);

void main() {
  group('DocumentPreviewController', () {
    test(
      'goes loading → loaded with the document and every page, in order',
      () async {
        final document = fakeDocument();
        final pages = [
          fakePage(width: 612, height: 792),
          fakePage(width: 612, height: 700),
          fakePage(width: 612, height: 500),
        ];
        final container = documentContainer(
          user: salesOrdersReader,
          source: FakeDocumentSource(handler: (ref) async => document),
          output: FakeDocumentOutput(pages: pages),
        );
        addTearDown(container.dispose);

        final states = <AsyncValue<DocumentPreviewData>>[];
        container.listen(
          documentPreviewControllerProvider(_ticket),
          (previous, next) => states.add(next),
          fireImmediately: true,
        );
        expect(states.first, isA<AsyncLoading<DocumentPreviewData>>());

        final data = await container.read(
          documentPreviewControllerProvider(_ticket).future,
        );

        expect(data.document, same(document));
        expect(data.pages, orderedEquals(pages));
        expect(states.last, isA<AsyncData<DocumentPreviewData>>());
      },
    );

    test(
      "a fetch error ends in an AppError with the server's reason",
      () async {
        final container = documentContainer(
          user: salesOrdersReader,
          source: FakeDocumentSource(
            handler: (ref) async =>
                throw const AppError.notFound('Sales order not found'),
          ),
        );
        addTearDown(container.dispose);
        final subscription = container.listen(
          documentPreviewControllerProvider(_ticket),
          (previous, next) {},
        );
        addTearDown(subscription.close);

        await expectLater(
          container.read(documentPreviewControllerProvider(_ticket).future),
          throwsA(
            isA<NotFoundError>().having(
              (e) => e.message,
              'message',
              'Sales order not found',
            ),
          ),
        );
        expect(
          container.read(documentPreviewControllerProvider(_ticket)).error,
          isA<NotFoundError>(),
        );
      },
    );

    test(
      'a rasterizing failure is a generic AppError, not a raw exception',
      () async {
        final container = documentContainer(
          user: salesOrdersReader,
          output: FakeDocumentOutput(
            rasterHandler: (document) =>
                Stream.error(StateError('pdf.js failed to load')),
          ),
        );
        addTearDown(container.dispose);
        final subscription = container.listen(
          documentPreviewControllerProvider(_ticket),
          (previous, next) {},
        );
        addTearDown(subscription.close);

        await expectLater(
          container.read(documentPreviewControllerProvider(_ticket).future),
          throwsA(isA<ServerError>()),
        );
      },
    );

    test('a document with no pages is an error', () async {
      final container = documentContainer(
        user: salesOrdersReader,
        output: FakeDocumentOutput(pages: const []),
      );
      addTearDown(container.dispose);
      final subscription = container.listen(
        documentPreviewControllerProvider(_ticket),
        (previous, next) {},
      );
      addTearDown(subscription.close);

      await expectLater(
        container.read(documentPreviewControllerProvider(_ticket).future),
        throwsA(isA<ServerError>()),
      );
    });

    test('never exposes a partial page list while pages are still being '
        'rastered (G4)', () async {
      final pages = StreamController<DocumentPage>();
      final container = documentContainer(
        user: salesOrdersReader,
        output: FakeDocumentOutput(rasterHandler: (document) => pages.stream),
      );
      addTearDown(container.dispose);

      final states = <AsyncValue<DocumentPreviewData>>[];
      container.listen(
        documentPreviewControllerProvider(_ticket),
        (previous, next) => states.add(next),
        fireImmediately: true,
      );

      pages.add(fakePage());
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      expect(
        container.read(documentPreviewControllerProvider(_ticket)),
        isA<AsyncLoading<DocumentPreviewData>>(),
        reason: 'one page of two is not a loaded document',
      );

      pages.add(fakePage());
      await pages.close();
      final data = await container.read(
        documentPreviewControllerProvider(_ticket).future,
      );

      expect(data.pages, hasLength(2));
      expect(states.whereType<AsyncData<DocumentPreviewData>>(), hasLength(1));
    });

    test('retry (invalidate) fetches again', () async {
      final source = FakeDocumentSource();
      final container = documentContainer(
        user: salesOrdersReader,
        source: source,
      );
      addTearDown(container.dispose);
      final subscription = container.listen(
        documentPreviewControllerProvider(_ticket),
        (previous, next) {},
      );
      addTearDown(subscription.close);

      await container.read(documentPreviewControllerProvider(_ticket).future);
      expect(source.fetched, hasLength(1));

      container.invalidate(documentPreviewControllerProvider(_ticket));
      await container.read(documentPreviewControllerProvider(_ticket).future);

      expect(source.fetched, hasLength(2));
    });

    test('nothing is cached between opens (FR-022, G3)', () async {
      final source = FakeDocumentSource();
      final output = FakeDocumentOutput();
      final container = documentContainer(
        user: salesOrdersReader,
        source: source,
        output: output,
      );
      addTearDown(container.dispose);

      var open = container.listen(
        documentPreviewControllerProvider(_ticket),
        (previous, next) {},
      );
      await container.read(documentPreviewControllerProvider(_ticket).future);
      open.close(); // the dialog was closed
      await container.pump();

      open = container.listen(
        documentPreviewControllerProvider(_ticket),
        (previous, next) {},
      );
      addTearDown(open.close);
      await container.read(documentPreviewControllerProvider(_ticket).future);

      expect(source.fetched, hasLength(2));
      expect(output.rastered, hasLength(2));
    });

    test("a user without the kind's privilege gets a 403 and nothing is "
        'fetched (FR-041)', () async {
      final source = FakeDocumentSource();
      final output = FakeDocumentOutput();
      final container = documentContainer(
        user: posReader, // no sales-orders read
        source: source,
        output: output,
      );
      addTearDown(container.dispose);
      final subscription = container.listen(
        documentPreviewControllerProvider(_ticket),
        (previous, next) {},
      );
      addTearDown(subscription.close);

      await expectLater(
        container.read(documentPreviewControllerProvider(_ticket).future),
        throwsA(
          isA<ServerError>()
              .having((e) => e.statusCode, 'statusCode', 403)
              .having((e) => e.message, 'message', 'Insufficient privileges'),
        ),
      );
      expect(source.fetched, isEmpty);
      expect(output.rastered, isEmpty);
    });
  });
}
