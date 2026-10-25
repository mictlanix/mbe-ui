import 'package:built_collection/built_collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mbe_ui/features/sales/domain/quote_email.dart';

/// An address of exactly [length] characters ending in `@b.mx`.
String _addressOfLength(int length) =>
    '${'a' * (length - '@b.mx'.length)}@b.mx';

void main() {
  group('isPlausibleEmail', () {
    test('accepts a plain address and trims surrounding whitespace', () {
      expect(isPlausibleEmail('a@b.mx'), isTrue);
      expect(isPlausibleEmail(' a@b.mx '), isTrue);
    });

    test('rejects malformed addresses', () {
      for (final value in ['a@', '@b.mx', 'a@b', 'a b@c.mx', '', '   ']) {
        expect(isPlausibleEmail(value), isFalse, reason: '"$value"');
      }
    });

    test('accepts 254 characters and rejects 255', () {
      expect(_addressOfLength(254), hasLength(254));
      expect(isPlausibleEmail(_addressOfLength(254)), isTrue);
      expect(_addressOfLength(255), hasLength(255));
      expect(isPlausibleEmail(_addressOfLength(255)), isFalse);
    });
  });

  group('QuoteEmailReceipt.fromResponse', () {
    test('maps recipients and sentAt', () {
      final sentAt = DateTime(2026, 10, 24, 10, 30);
      final response = api.QuoteEmailResponse(
        (b) => b
          ..recipients = ListBuilder<String>(['a@b.mx', 'c@d.mx'])
          ..sentAt = sentAt,
      );

      final receipt = QuoteEmailReceipt.fromResponse(response);

      expect(receipt.recipients, ['a@b.mx', 'c@d.mx']);
      expect(receipt.sentAt, sentAt);
    });
  });
}
