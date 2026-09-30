import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Regeneration guard for contract fact E1 (spec 044,
/// contracts/consumed-endpoints.md).
///
/// mbe-api declares each print route's 200 as `application/pdf` with a binary
/// schema. If a regeneration ever emits anything else, dio's default
/// transformer decodes the PDF as UTF-8 with `allowMalformed: true`, which
/// swaps every invalid byte for U+FFFD and yields a corrupt PDF **without
/// throwing**. So the generated methods must return `Uint8List` and ask dio
/// for bytes, and this test fails the build if they stop doing so.
void main() {
  const apiDir = 'lib/generated/openapi/lib/src/api';

  const methods = {
    'sales_orders_api.dart': [
      'printSalesOrderTicketApiV1SalesOrdersSalesOrderIdTicketGet',
      'printSalesOrderDocumentApiV1SalesOrdersSalesOrderIdDocumentGet',
    ],
    'cash_sessions_api.dart': [
      'printCashSessionCutApiV1CashSessionsCashSessionIdTicketGet',
    ],
  };

  for (final entry in methods.entries) {
    final source = File('$apiDir/${entry.key}').readAsStringSync();

    for (final name in entry.value) {
      test(
        '${entry.key}: $name returns bytes and requests ResponseType.bytes',
        () {
          // The generator wraps a long signature onto a second line, so match
          // across whitespace rather than line by line.
          final signature = RegExp(
            'Future<Response<Uint8List>>\\s+$name\\s*\\(',
          ).firstMatch(source);
          expect(
            signature,
            isNotNull,
            reason:
                '$name must be `Future<Response<Uint8List>>`: a JSON return '
                'type means the print route lost its binary schema and the '
                'client would corrupt the PDF (research §8.2).',
          );

          // The body runs to the next generated method's doc comment.
          final rest = source.substring(signature!.end);
          final next = rest.indexOf('\n  /// ');
          final body = next == -1 ? rest : rest.substring(0, next);
          expect(
            body,
            contains('responseType: ResponseType.bytes'),
            reason: '$name must request ResponseType.bytes.',
          );
        },
      );
    }
  }
}
