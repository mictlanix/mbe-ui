//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/date.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'analytics_point.g.dart';

/// AnalyticsPoint
///
/// Properties:
/// * [date]
/// * [value]
@BuiltValue()
abstract class AnalyticsPoint
    implements Built<AnalyticsPoint, AnalyticsPointBuilder> {
  @BuiltValueField(wireName: r'date')
  Date get date;

  @BuiltValueField(wireName: r'value')
  String? get value;

  AnalyticsPoint._();

  factory AnalyticsPoint([void updates(AnalyticsPointBuilder b)]) =
      _$AnalyticsPoint;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AnalyticsPointBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AnalyticsPoint> get serializer =>
      _$AnalyticsPointSerializer();
}

class _$AnalyticsPointSerializer
    implements PrimitiveSerializer<AnalyticsPoint> {
  @override
  final Iterable<Type> types = const [AnalyticsPoint, _$AnalyticsPoint];

  @override
  final String wireName = r'AnalyticsPoint';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AnalyticsPoint object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'date';
    yield serializers.serialize(
      object.date,
      specifiedType: const FullType(Date),
    );
    yield r'value';
    yield object.value == null
        ? null
        : serializers.serialize(
            object.value,
            specifiedType: const FullType.nullable(String),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    AnalyticsPoint object, {
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
    required AnalyticsPointBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'date':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(Date),
                  )
                  as Date;
          result.date = valueDes;
          break;
        case r'value':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.value = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AnalyticsPoint deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AnalyticsPointBuilder();
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
