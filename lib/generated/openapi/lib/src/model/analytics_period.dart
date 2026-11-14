//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/date.dart';
import 'package:mbe_api_client/src/model/relative_period.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'analytics_period.g.dart';

/// A view's period: a relative key resolved the day it runs, N days, or fixed dates.
///
/// Properties:
/// * [key]
/// * [days] - last_n_days only: 1-3,650.
/// * [start] - fixed only.
/// * [end] - fixed only; not before start.
@BuiltValue()
abstract class AnalyticsPeriod
    implements Built<AnalyticsPeriod, AnalyticsPeriodBuilder> {
  @BuiltValueField(wireName: r'key')
  RelativePeriod get key;
  // enum keyEnum {  today,  yesterday,  this_week,  this_month,  this_quarter,  this_year,  last_week,  last_month,  last_quarter,  last_year,  last_n_days,  fixed,  };

  /// last_n_days only: 1-3,650.
  @BuiltValueField(wireName: r'days')
  int? get days;

  /// fixed only.
  @BuiltValueField(wireName: r'start')
  Date? get start;

  /// fixed only; not before start.
  @BuiltValueField(wireName: r'end')
  Date? get end;

  AnalyticsPeriod._();

  factory AnalyticsPeriod([void updates(AnalyticsPeriodBuilder b)]) =
      _$AnalyticsPeriod;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AnalyticsPeriodBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AnalyticsPeriod> get serializer =>
      _$AnalyticsPeriodSerializer();
}

class _$AnalyticsPeriodSerializer
    implements PrimitiveSerializer<AnalyticsPeriod> {
  @override
  final Iterable<Type> types = const [AnalyticsPeriod, _$AnalyticsPeriod];

  @override
  final String wireName = r'AnalyticsPeriod';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AnalyticsPeriod object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'key';
    yield serializers.serialize(
      object.key,
      specifiedType: const FullType(RelativePeriod),
    );
    if (object.days != null) {
      yield r'days';
      yield serializers.serialize(
        object.days,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.start != null) {
      yield r'start';
      yield serializers.serialize(
        object.start,
        specifiedType: const FullType.nullable(Date),
      );
    }
    if (object.end != null) {
      yield r'end';
      yield serializers.serialize(
        object.end,
        specifiedType: const FullType.nullable(Date),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AnalyticsPeriod object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(
      serializers,
      object,
      specifiedType: specifiedType,
    ).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AnalyticsPeriodBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'key':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(RelativePeriod),
                  )
                  as RelativePeriod;
          result.key = valueDes;
          break;
        case r'days':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.days = valueDes;
          break;
        case r'start':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(Date),
                  )
                  as Date?;
          if (valueDes == null) continue;
          result.start = valueDes;
          break;
        case r'end':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(Date),
                  )
                  as Date?;
          if (valueDes == null) continue;
          result.end = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AnalyticsPeriod deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AnalyticsPeriodBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}
