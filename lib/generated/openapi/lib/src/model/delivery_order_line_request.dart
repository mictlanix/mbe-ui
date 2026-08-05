//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/quantity1.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'delivery_order_line_request.g.dart';

/// One sales-order line, and how much of it this delivery should carry (#138).
///
/// Properties:
/// * [salesOrderDetail]
/// * [quantity]
@BuiltValue()
abstract class DeliveryOrderLineRequest
    implements
        Built<DeliveryOrderLineRequest, DeliveryOrderLineRequestBuilder> {
  @BuiltValueField(wireName: r'sales_order_detail')
  int get salesOrderDetail;

  @BuiltValueField(wireName: r'quantity')
  Quantity1 get quantity;

  DeliveryOrderLineRequest._();

  factory DeliveryOrderLineRequest([
    void updates(DeliveryOrderLineRequestBuilder b),
  ]) = _$DeliveryOrderLineRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DeliveryOrderLineRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DeliveryOrderLineRequest> get serializer =>
      _$DeliveryOrderLineRequestSerializer();
}

class _$DeliveryOrderLineRequestSerializer
    implements PrimitiveSerializer<DeliveryOrderLineRequest> {
  @override
  final Iterable<Type> types = const [
    DeliveryOrderLineRequest,
    _$DeliveryOrderLineRequest,
  ];

  @override
  final String wireName = r'DeliveryOrderLineRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DeliveryOrderLineRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'sales_order_detail';
    yield serializers.serialize(
      object.salesOrderDetail,
      specifiedType: const FullType(int),
    );
    yield r'quantity';
    yield serializers.serialize(
      object.quantity,
      specifiedType: const FullType(Quantity1),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DeliveryOrderLineRequest object, {
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
    required DeliveryOrderLineRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'sales_order_detail':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.salesOrderDetail = valueDes;
          break;
        case r'quantity':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(Quantity1),
                  )
                  as Quantity1;
          result.quantity.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DeliveryOrderLineRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DeliveryOrderLineRequestBuilder();
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
