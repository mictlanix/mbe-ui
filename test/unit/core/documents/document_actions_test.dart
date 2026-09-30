import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_ui/core/documents/domain/document_kind.dart';
import 'package:mbe_ui/core/documents/domain/document_ref.dart';
import 'package:mbe_ui/core/documents/presentation/document_actions.dart';
import 'package:mbe_ui/core/errors/app_error.dart';

import 'document_fakes.dart';

const _ticket = DocumentRef(
  kind: DocumentKind.saleTicket,
  recordId: 42,
  title: 'Ticket · Folio #42',
);

void main() {
  group('DocumentActions.printDirect', () {
    test('fetches once, then prints exactly the bytes it fetched', () async {
      final source = FakeDocumentSource();
      final output = FakeDocumentOutput();
      final container = documentContainer(
        user: salesOrdersReader,
        source: source,
        output: output,
      );
      addTearDown(container.dispose);

      await container.read(documentActionsProvider).printDirect(_ticket);

      expect(source.fetched, [_ticket]);
      expect(output.printed, hasLength(1));
      expect(output.printed.single.bytes, orderedEquals(fakeDocument().bytes));
      expect(
        output.rastered,
        isEmpty,
        reason: 'direct print skips the preview',
      );
    });

    test('hands the fetched document to the output untouched', () async {
      final document = fakeDocument(
        filename: 'ticket-00000042.pdf',
        tail: [200, 201, 0, 255],
      );
      final source = FakeDocumentSource(handler: (ref) async => document);
      final output = FakeDocumentOutput();
      final container = documentContainer(
        user: salesOrdersReader,
        source: source,
        output: output,
      );
      addTearDown(container.dispose);

      await container.read(documentActionsProvider).printDirect(_ticket);

      expect(output.printed.single, same(document));
    });

    test('a user without the kind\'s privilege gets a 403 and no fetch '
        '(FR-041)', () async {
      final source = FakeDocumentSource();
      final output = FakeDocumentOutput();
      final container = documentContainer(
        user: posReader, // reads the point of sale, not sales orders
        source: source,
        output: output,
      );
      addTearDown(container.dispose);

      await expectLater(
        container.read(documentActionsProvider).printDirect(_ticket),
        throwsA(
          isA<ServerError>()
              .having((e) => e.statusCode, 'statusCode', 403)
              .having((e) => e.message, 'message', 'Insufficient privileges'),
        ),
      );
      expect(source.fetched, isEmpty);
      expect(output.printed, isEmpty);
    });

    test('a second call for the same document while the first is in flight '
        'is ignored (FR-032, contract G1)', () async {
      final gate = Completer<void>();
      final source = FakeDocumentSource(
        handler: (ref) async {
          await gate.future;
          return fakeDocument();
        },
      );
      final output = FakeDocumentOutput();
      final container = documentContainer(
        user: salesOrdersReader,
        source: source,
        output: output,
      );
      addTearDown(container.dispose);
      final actions = container.read(documentActionsProvider);

      final first = actions.printDirect(_ticket);
      await actions.printDirect(_ticket); // ignored: returns at once
      expect(source.fetched, hasLength(1));

      gate.complete();
      await first;
      expect(output.printed, hasLength(1));

      // Once it settles, the same document can be printed again.
      await actions.printDirect(_ticket);
      expect(source.fetched, hasLength(2));
      expect(output.printed, hasLength(2));
    });

    test('a different document is not blocked by one in flight', () async {
      final gate = Completer<void>();
      final source = FakeDocumentSource(
        handler: (ref) async {
          if (ref.recordId == 42) {
            await gate.future;
          }
          return fakeDocument();
        },
      );
      final container = documentContainer(
        user: salesOrdersReader,
        source: source,
      );
      addTearDown(container.dispose);
      final actions = container.read(documentActionsProvider);

      final first = actions.printDirect(_ticket);
      await actions.printDirect(
        const DocumentRef(
          kind: DocumentKind.saleTicket,
          recordId: 43,
          title: 't',
        ),
      );
      expect(source.fetched.map((r) => r.recordId), [42, 43]);

      gate.complete();
      await first;
    });

    test('a fetch error propagates as an AppError and clears the guard so '
        'retry works', () async {
      var attempts = 0;
      final source = FakeDocumentSource(
        handler: (ref) async {
          attempts++;
          if (attempts == 1) {
            throw const AppError.notFound('Sales order not found');
          }
          return fakeDocument();
        },
      );
      final output = FakeDocumentOutput();
      final container = documentContainer(
        user: salesOrdersReader,
        source: source,
        output: output,
      );
      addTearDown(container.dispose);
      final actions = container.read(documentActionsProvider);

      await expectLater(
        actions.printDirect(_ticket),
        throwsA(
          isA<NotFoundError>().having(
            (e) => e.message,
            'message',
            'Sales order not found',
          ),
        ),
      );
      expect(output.printed, isEmpty);

      await actions.printDirect(_ticket);
      expect(output.printed, hasLength(1));
    });

    test('a cancelled print is not an error (FR-031)', () async {
      final output = FakeDocumentOutput()..printHandler = (document) async {};
      final container = documentContainer(
        user: salesOrdersReader,
        output: output,
      );
      addTearDown(container.dispose);

      await expectLater(
        container.read(documentActionsProvider).printDirect(_ticket),
        completes,
      );
    });
  });

  group('canOpenDocument mirrors each kind\'s gate (FR-040)', () {
    bool can(user, DocumentKind kind) => canOpenDocument(accessFor(user), kind);

    test('a sales-orders reader may open the ticket and the pedido, not the '
        'cut', () {
      expect(can(salesOrdersReader, DocumentKind.saleTicket), isTrue);
      expect(can(salesOrdersReader, DocumentKind.salesOrder), isTrue);
      expect(can(salesOrdersReader, DocumentKind.cashCut), isFalse);
    });

    test(
      'a point-of-sale reader may open the cut, not the ticket or pedido',
      () {
        expect(can(posReader, DocumentKind.cashCut), isTrue);
        expect(can(posReader, DocumentKind.saleTicket), isFalse);
        expect(can(posReader, DocumentKind.salesOrder), isFalse);
      },
    );

    test('a user with no privileges may open nothing', () {
      for (final kind in DocumentKind.values) {
        expect(can(noPrivileges, kind), isFalse, reason: '$kind');
      }
    });

    test('an administrator may open everything', () {
      for (final kind in DocumentKind.values) {
        expect(can(administrator, kind), isTrue, reason: '$kind');
      }
    });
  });
}
