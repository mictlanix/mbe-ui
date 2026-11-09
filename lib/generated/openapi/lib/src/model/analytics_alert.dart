//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/analytics_detail_request.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'analytics_alert.g.dart';

/// AnalyticsAlert
///
/// Properties:
/// * [key] - overdue_credit_orders | lines_below_cost | lines_without_cost | refund_rate
/// * [facility] - refund_rate only: one alert per facility where it fires.
/// * [count]
/// * [amount]
/// * [detail]
@BuiltValue()
abstract class AnalyticsAlert
    implements Built<AnalyticsAlert, AnalyticsAlertBuilder> {
  /// overdue_credit_orders | lines_below_cost | lines_without_cost | refund_rate
  @BuiltValueField(wireName: r'key')
  String get key;

  /// refund_rate only: one alert per facility where it fires.
  @BuiltValueField(wireName: r'facility')
  int? get facility;

  @BuiltValueField(wireName: r'count')
  int get count;

  @BuiltValueField(wireName: r'amount')
  String? get amount;

  @BuiltValueField(wireName: r'detail')
  AnalyticsDetailRequest get detail;

  AnalyticsAlert._();

  factory AnalyticsAlert([void updates(AnalyticsAlertBuilder b)]) =
      _$AnalyticsAlert;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AnalyticsAlertBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AnalyticsAlert> get serializer =>
      _$AnalyticsAlertSerializer();
}

class _$AnalyticsAlertSerializer
    implements PrimitiveSerializer<AnalyticsAlert> {
  @override
  final Iterable<Type> types = const [AnalyticsAlert, _$AnalyticsAlert];

  @override
  final String wireName = r'AnalyticsAlert';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AnalyticsAlert object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'key';
    yield serializers.serialize(
      object.key,
      specifiedType: const FullType(String),
    );
    if (object.facility != null) {
      yield r'facility';
      yield serializers.serialize(
        object.facility,
        specifiedType: const FullType.nullable(int),
      );
    }
    yield r'count';
    yield serializers.serialize(
      object.count,
      specifiedType: const FullType(int),
    );
    yield r'amount';
    yield object.amount == null
        ? null
        : serializers.serialize(
            object.amount,
            specifiedType: const FullType.nullable(String),
          );
    yield r'detail';
    yield serializers.serialize(
      object.detail,
      specifiedType: const FullType(AnalyticsDetailRequest),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AnalyticsAlert object, {
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
    required AnalyticsAlertBuilder result,
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
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.key = valueDes;
          break;
        case r'facility':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.facility = valueDes;
          break;
        case r'count':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.count = valueDes;
          break;
        case r'amount':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.amount = valueDes;
          break;
        case r'detail':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(AnalyticsDetailRequest),
                  )
                  as AnalyticsDetailRequest;
          result.detail.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AnalyticsAlert deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AnalyticsAlertBuilder();
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
