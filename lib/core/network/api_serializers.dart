import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

/// mbe-api (mictlanix/mbe-api#228) declares every `format: date-time` field as
/// naive local wall-clock time in its business timezone, with no UTC offset,
/// and converts an inbound offset to that timezone rather than dropping it.
/// The generated client's own `Iso8601DateTimeSerializer` assumes the
/// opposite: it reads an offset-less string as local and then calls
/// `.toUtc()`, which is exactly the six-hour display shift filed as
/// mictlanix/mbe-ui#176 — the value's fields survive, but the flag it now
/// carries makes every formatter print the wrong ones.
///
/// This serializer treats the wire the way mbe-api actually means it:
///
/// - **Read**: no offset in the string → the parsed local value, unchanged.
///   An offset present → converted to local via `.toLocal()`, so a future
///   aware-UTC API response would still render correctly (contracts/
///   wire-datetime.md, research.md R2).
/// - **Write**: a value's own fields, formatted as text with no suffix,
///   regardless of its `isUtc` flag. Never rebuilt through `DateTime(...)`
///   from those fields — that construction re-derives the offset from the
///   *host's* current calendar, which silently disagrees with itself across
///   a daylight-saving change (research.md R3). Formatting the fields
///   directly asks the host's calendar nothing, so `DateTime(2026, 9, 27)`
///   and `DateTime.utc(2026, 9, 27)` write identically, and writing never
///   throws — replacing the `ArgumentError` `Iso8601DateTimeSerializer` threw
///   on any non-UTC value (the promise-date-picker crash PR #180 patched
///   around on the outgoing side only).
class WallClockDateTimeSerializer implements PrimitiveSerializer<DateTime> {
  const WallClockDateTimeSerializer();

  @override
  Iterable<Type> get types => BuiltList<Type>([DateTime]);

  @override
  String get wireName => 'DateTime';

  @override
  DateTime deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final parsed = DateTime.parse(serialized as String);
    return parsed.isUtc ? parsed.toLocal() : parsed;
  }

  @override
  Object serialize(
    Serializers serializers,
    DateTime dateTime, {
    FullType specifiedType = FullType.unspecified,
  }) {
    String pad(int value, int width) => value.toString().padLeft(width, '0');
    final date = '${pad(dateTime.year, 4)}-${pad(dateTime.month, 2)}-${pad(dateTime.day, 2)}';
    final time =
        '${pad(dateTime.hour, 2)}:${pad(dateTime.minute, 2)}:${pad(dateTime.second, 2)}';
    return '$date' 'T' '$time' '.${pad(dateTime.millisecond, 3)}';
  }
}

/// The one shared conversion every data-access path uses (FR-006):
/// mbe-api client's `standardSerializers` with [WallClockDateTimeSerializer]
/// layered on top, displacing the generated `Iso8601DateTimeSerializer` for
/// the `DateTime` type the same way that serializer itself displaces
/// built_value's own default (a later `add` for the same type/wire name
/// replaces the earlier one).
///
/// Every repository constructs its generated `*Api` with this value instead
/// of the raw `api.standardSerializers` — enforced by
/// `test/unit/core/network/serializers_guard_test.dart` (FR-009), so a new
/// repository copied from an old one cannot silently reintroduce the shift.
final appSerializers =
    (api.standardSerializers.toBuilder()..add(const WallClockDateTimeSerializer())).build();
