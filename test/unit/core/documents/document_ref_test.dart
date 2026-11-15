import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_ui/core/documents/domain/document_kind.dart';
import 'package:mbe_ui/core/documents/domain/document_ref.dart';

/// A `DocumentRef` keys the preview provider and the repeated-press guard, so
/// the warehouse a delivery ticket is limited to must be part of its identity
/// (spec 064 research R2).
void main() {
  DocumentRef ticket({int? warehouseId, String title = 'Ticket'}) =>
      DocumentRef(
        kind: DocumentKind.deliveryTicket,
        recordId: 30242,
        title: title,
        warehouseId: warehouseId,
      );

  test('refs differing only in warehouse are different documents', () {
    expect(ticket(warehouseId: 1), isNot(ticket(warehouseId: 2)));
    expect(ticket(warehouseId: 1), isNot(ticket()));
    expect(
      ticket(warehouseId: 1).hashCode,
      isNot(ticket(warehouseId: 2).hashCode),
    );
  });

  test('refs with the same warehouse are equal and hash alike', () {
    expect(ticket(warehouseId: 1), ticket(warehouseId: 1));
    expect(ticket(warehouseId: 1).hashCode, ticket(warehouseId: 1).hashCode);
  });

  test('a ref without a warehouse still equals an older-style ref', () {
    expect(
      ticket(),
      const DocumentRef(
        kind: DocumentKind.deliveryTicket,
        recordId: 30242,
        title: 'Ticket',
      ),
    );
  });

  test('only a delivery ticket can carry a warehouse', () {
    expect(
      () => DocumentRef(
        kind: DocumentKind.salesOrder,
        recordId: 1,
        title: 't',
        warehouseId: 1,
      ),
      throwsAssertionError,
    );
    expect(
      () => DocumentRef(
        kind: DocumentKind.deliveryOrderDocument,
        recordId: 1,
        title: 't',
        warehouseId: 1,
      ),
      throwsAssertionError,
    );
  });

  test('a warehouse id must be a real id', () {
    expect(() => ticket(warehouseId: 0), throwsAssertionError);
    expect(() => ticket(warehouseId: -3), throwsAssertionError);
  });
}
