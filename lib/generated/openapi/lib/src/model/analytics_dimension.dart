//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/dimension_key.dart';
import 'package:mbe_api_client/src/model/grain.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'analytics_dimension.g.dart';

/// AnalyticsDimension
///
/// Properties:
/// * [key]
/// * [label]
/// * [grains] - Date only: the grains it can be grouped at.
@BuiltValue()
abstract class AnalyticsDimension
    implements Built<AnalyticsDimension, AnalyticsDimensionBuilder> {
  @BuiltValueField(wireName: r'key')
  DimensionKey get key;
  // enum keyEnum {  date,  weekday,  hour,  facility,  point_of_sale,  salesperson,  cash_session,  customer,  customer_type,  product,  brand,  model,  label,  payment_terms,  payment_method,  warehouse,  movement_type,  supplier,  aging_bucket,  due_bucket,  sales_agent,  commission_participation,  commission_status,  issuer,  document_status,  document_type,  };

  @BuiltValueField(wireName: r'label')
  String get label;

  /// Date only: the grains it can be grouped at.
  @BuiltValueField(wireName: r'grains')
  BuiltList<Grain> get grains;

  AnalyticsDimension._();

  factory AnalyticsDimension([void updates(AnalyticsDimensionBuilder b)]) =
      _$AnalyticsDimension;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AnalyticsDimensionBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AnalyticsDimension> get serializer =>
      _$AnalyticsDimensionSerializer();
}

class _$AnalyticsDimensionSerializer
    implements PrimitiveSerializer<AnalyticsDimension> {
  @override
  final Iterable<Type> types = const [AnalyticsDimension, _$AnalyticsDimension];

  @override
  final String wireName = r'AnalyticsDimension';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AnalyticsDimension object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'key';
    yield serializers.serialize(
      object.key,
      specifiedType: const FullType(DimensionKey),
    );
    yield r'label';
    yield serializers.serialize(
      object.label,
      specifiedType: const FullType(String),
    );
    yield r'grains';
    yield serializers.serialize(
      object.grains,
      specifiedType: const FullType(BuiltList, [FullType(Grain)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AnalyticsDimension object, {
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
    required AnalyticsDimensionBuilder result,
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
                    specifiedType: const FullType(DimensionKey),
                  )
                  as DimensionKey;
          result.key = valueDes;
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
        case r'grains':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltList, [FullType(Grain)]),
                  )
                  as BuiltList<Grain>;
          result.grains.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AnalyticsDimension deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AnalyticsDimensionBuilder();
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
