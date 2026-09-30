import 'package:built_value/serializer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_ui/core/network/api_serializers.dart';

/// Pins [WallClockDateTimeSerializer] against
/// contracts/wire-datetime.md's read and write tables (spec 043,
/// mictlanix/mbe-ui#176). mbe-api (mictlanix/mbe-api#228) sends naive local
/// wall-clock time with no offset; the replaced `Iso8601DateTimeSerializer`
/// read that as local and then shifted it to UTC via `.toUtc()`, which is the
/// six-hour display bug this feature fixes.
void main() {
  const type = FullType(DateTime);
  final serializer = const WallClockDateTimeSerializer();

  DateTime deserialize(String wire) =>
      serializer.deserialize(appSerializers, wire, specifiedType: type);

  String serialize(DateTime value) =>
      serializer.serialize(appSerializers, value, specifiedType: type) as String;

  group('reading (FR-001, FR-002)', () {
    test('an offset-less string is read back unchanged, not shifted', () {
      final result = deserialize('2026-09-26T13:05:28');
      expect(result, DateTime(2026, 9, 26, 13, 5, 28));
      expect(result.isUtc, isFalse, reason: 'never UTC-flagged by design (data-model.md I-1)');
    });

    test('an offset-less string with fractional seconds is read back unchanged', () {
      final result = deserialize('2026-09-26T13:05:28.000');
      expect(result, DateTime(2026, 9, 26, 13, 5, 28));
    });

    test('a Z-suffixed string is converted to local time, not read literally', () {
      final wireInstant = DateTime.utc(2026, 9, 26, 13, 5, 28);
      final result = deserialize('2026-09-26T13:05:28Z');
      expect(
        result.isAtSameMomentAs(wireInstant),
        isTrue,
        reason: 'must be the same instant as the Z string names',
      );
      expect(result.isUtc, isFalse, reason: 'converted to local, not left UTC-flagged');
    });

    test('a numeric-offset string is converted to local time', () {
      final wireInstant = DateTime.parse('2026-09-26T13:05:28-06:00');
      final result = deserialize('2026-09-26T13:05:28-06:00');
      expect(result.isAtSameMomentAs(wireInstant), isTrue);
      expect(result.isUtc, isFalse);
    });

    test('an unparseable string still raises, as the replaced serializer did', () {
      expect(() => deserialize('not a date'), throwsFormatException);
    });
  });

  group('writing (FR-003)', () {
    test('a local value writes its own fields with no suffix', () {
      expect(serialize(DateTime(2026, 9, 27)), '2026-09-27T00:00:00.000');
    });

    test('a UTC-flagged value with the same fields writes identically — isUtc is ignored', () {
      expect(serialize(DateTime.utc(2026, 9, 27)), serialize(DateTime(2026, 9, 27)));
      expect(serialize(DateTime.utc(2026, 9, 27)), '2026-09-27T00:00:00.000');
    });

    test('milliseconds are kept — wireDateEnd\'s inclusive end-of-day needs them', () {
      expect(
        serialize(DateTime(2026, 9, 27, 23, 59, 59, 999)),
        '2026-09-27T23:59:59.999',
      );
    });

    test('microseconds are dropped — the API stores seconds and web cannot hold them', () {
      expect(
        serialize(DateTime(2026, 9, 27, 8, 5, 3, 7, 999)),
        '2026-09-27T08:05:03.007',
      );
    });

    test(
      'a DST-crossing wall-clock time writes its own fields on every host, '
      'never rebuilt through the host calendar (research R3)',
      () {
        // 2026-03-08 02:30 does not exist on a US host observing daylight
        // saving that night; rebuilding a local DateTime from these fields
        // would silently become 03:30 there. Formatting the fields as text
        // never asks the host's calendar anything.
        expect(
          serialize(DateTime.utc(2026, 3, 8, 2, 30)),
          '2026-03-08T02:30:00.000',
        );
      },
    );

    test('writing never throws on a local value — the ArgumentError this replaces', () {
      expect(() => serialize(DateTime(2026, 8, 20)), returnsNormally);
    });
  });

  group('round trip', () {
    for (final wire in [
      '2026-09-26T13:05:28.000',
      '2026-01-01T00:00:00.000',
      '2026-12-31T23:59:59.999',
    ]) {
      test('$wire round-trips through read then write unchanged', () {
        expect(serialize(deserialize(wire)), wire);
      });
    }
  });
}
