//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/dimension_key.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'analytics_key.g.dart';

/// AnalyticsKey
///
/// Properties:
/// * [dimension]
/// * [value] - The id or value; null is \"none\".
/// * [label]
@BuiltValue()
abstract class AnalyticsKey
    implements Built<AnalyticsKey, AnalyticsKeyBuilder> {
  @BuiltValueField(wireName: r'dimension')
  DimensionKey get dimension;
  // enum dimensionEnum {  date,  weekday,  hour,  facility,  point_of_sale,  salesperson,  cash_session,  customer,  customer_type,  product,  brand,  model,  label,  payment_terms,  payment_method,  warehouse,  movement_type,  supplier,  aging_bucket,  due_bucket,  sales_agent,  commission_participation,  commission_status,  issuer,  document_status,  document_type,  };

  /// The id or value; null is \"none\".
  @BuiltValueField(wireName: r'value')
  String? get value;

  @BuiltValueField(wireName: r'label')
  String get label;

  AnalyticsKey._();

  factory AnalyticsKey([void updates(AnalyticsKeyBuilder b)]) = _$AnalyticsKey;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AnalyticsKeyBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AnalyticsKey> get serializer => _$AnalyticsKeySerializer();
}

class _$AnalyticsKeySerializer implements PrimitiveSerializer<AnalyticsKey> {
  @override
  final Iterable<Type> types = const [AnalyticsKey, _$AnalyticsKey];

  @override
  final String wireName = r'AnalyticsKey';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AnalyticsKey object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'dimension';
    yield serializers.serialize(
      object.dimension,
      specifiedType: const FullType(DimensionKey),
    );
    yield r'value';
    yield object.value == null
        ? null
        : serializers.serialize(
            object.value,
            specifiedType: const FullType.nullable(String),
          );
    yield r'label';
    yield serializers.serialize(
      object.label,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AnalyticsKey object, {
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
    required AnalyticsKeyBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'dimension':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DimensionKey),
                  )
                  as DimensionKey;
          result.dimension = valueDes;
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
        case r'label':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.label = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AnalyticsKey deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AnalyticsKeyBuilder();
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
