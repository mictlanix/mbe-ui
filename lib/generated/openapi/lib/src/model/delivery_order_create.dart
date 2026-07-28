//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/fulfillment_type.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'delivery_order_create.g.dart';

/// Raised from a sales order — the only origin (spec Assumptions).
///
/// Properties:
/// * [salesOrder]
/// * [fulfillmentType]
@BuiltValue()
abstract class DeliveryOrderCreate
    implements Built<DeliveryOrderCreate, DeliveryOrderCreateBuilder> {
  @BuiltValueField(wireName: r'sales_order')
  int get salesOrder;

  @BuiltValueField(wireName: r'fulfillment_type')
  FulfillmentType? get fulfillmentType;
  // enum fulfillmentTypeEnum {  0,  1,  };

  DeliveryOrderCreate._();

  factory DeliveryOrderCreate([void updates(DeliveryOrderCreateBuilder b)]) =
      _$DeliveryOrderCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DeliveryOrderCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DeliveryOrderCreate> get serializer =>
      _$DeliveryOrderCreateSerializer();
}

class _$DeliveryOrderCreateSerializer
    implements PrimitiveSerializer<DeliveryOrderCreate> {
  @override
  final Iterable<Type> types = const [
    DeliveryOrderCreate,
    _$DeliveryOrderCreate,
  ];

  @override
  final String wireName = r'DeliveryOrderCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DeliveryOrderCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'sales_order';
    yield serializers.serialize(
      object.salesOrder,
      specifiedType: const FullType(int),
    );
    if (object.fulfillmentType != null) {
      yield r'fulfillment_type';
      yield serializers.serialize(
        object.fulfillmentType,
        specifiedType: const FullType.nullable(FulfillmentType),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    DeliveryOrderCreate object, {
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
    required DeliveryOrderCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'sales_order':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.salesOrder = valueDes;
          break;
        case r'fulfillment_type':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(FulfillmentType),
                  )
                  as FulfillmentType?;
          if (valueDes == null) continue;
          result.fulfillmentType = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DeliveryOrderCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DeliveryOrderCreateBuilder();
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
