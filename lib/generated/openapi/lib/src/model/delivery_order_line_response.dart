//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'delivery_order_line_response.g.dart';

/// DeliveryOrderLineResponse
///
/// Properties:
/// * [deliveryOrderDetailId]
/// * [salesOrderDetail]
/// * [product]
/// * [productCode]
/// * [productName]
/// * [warehouse]
/// * [quantity]
/// * [committedQuantity]
/// * [deliveredQuantity]
/// * [returnedQuantity]
/// * [openQuantity] - What is still loadable: ordered less delivered, returned and committed (FR-026).  Returned quantity is subtracted because those goods are accounted for elsewhere — by the child order a partial delivery creates, or by the requeue that puts them back in play.
@BuiltValue()
abstract class DeliveryOrderLineResponse
    implements
        Built<DeliveryOrderLineResponse, DeliveryOrderLineResponseBuilder> {
  @BuiltValueField(wireName: r'delivery_order_detail_id')
  int get deliveryOrderDetailId;

  @BuiltValueField(wireName: r'sales_order_detail')
  int? get salesOrderDetail;

  @BuiltValueField(wireName: r'product')
  int get product;

  @BuiltValueField(wireName: r'product_code')
  String get productCode;

  @BuiltValueField(wireName: r'product_name')
  String get productName;

  @BuiltValueField(wireName: r'warehouse')
  int get warehouse;

  @BuiltValueField(wireName: r'quantity')
  String get quantity;

  @BuiltValueField(wireName: r'committed_quantity')
  String get committedQuantity;

  @BuiltValueField(wireName: r'delivered_quantity')
  String get deliveredQuantity;

  @BuiltValueField(wireName: r'returned_quantity')
  String get returnedQuantity;

  /// What is still loadable: ordered less delivered, returned and committed (FR-026).  Returned quantity is subtracted because those goods are accounted for elsewhere — by the child order a partial delivery creates, or by the requeue that puts them back in play.
  @BuiltValueField(wireName: r'open_quantity')
  String get openQuantity;

  DeliveryOrderLineResponse._();

  factory DeliveryOrderLineResponse([
    void updates(DeliveryOrderLineResponseBuilder b),
  ]) = _$DeliveryOrderLineResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DeliveryOrderLineResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DeliveryOrderLineResponse> get serializer =>
      _$DeliveryOrderLineResponseSerializer();
}

class _$DeliveryOrderLineResponseSerializer
    implements PrimitiveSerializer<DeliveryOrderLineResponse> {
  @override
  final Iterable<Type> types = const [
    DeliveryOrderLineResponse,
    _$DeliveryOrderLineResponse,
  ];

  @override
  final String wireName = r'DeliveryOrderLineResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DeliveryOrderLineResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'delivery_order_detail_id';
    yield serializers.serialize(
      object.deliveryOrderDetailId,
      specifiedType: const FullType(int),
    );
    yield r'sales_order_detail';
    yield object.salesOrderDetail == null
        ? null
        : serializers.serialize(
            object.salesOrderDetail,
            specifiedType: const FullType.nullable(int),
          );
    yield r'product';
    yield serializers.serialize(
      object.product,
      specifiedType: const FullType(int),
    );
    yield r'product_code';
    yield serializers.serialize(
      object.productCode,
      specifiedType: const FullType(String),
    );
    yield r'product_name';
    yield serializers.serialize(
      object.productName,
      specifiedType: const FullType(String),
    );
    yield r'warehouse';
    yield serializers.serialize(
      object.warehouse,
      specifiedType: const FullType(int),
    );
    yield r'quantity';
    yield serializers.serialize(
      object.quantity,
      specifiedType: const FullType(String),
    );
    yield r'committed_quantity';
    yield serializers.serialize(
      object.committedQuantity,
      specifiedType: const FullType(String),
    );
    yield r'delivered_quantity';
    yield serializers.serialize(
      object.deliveredQuantity,
      specifiedType: const FullType(String),
    );
    yield r'returned_quantity';
    yield serializers.serialize(
      object.returnedQuantity,
      specifiedType: const FullType(String),
    );
    yield r'open_quantity';
    yield serializers.serialize(
      object.openQuantity,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DeliveryOrderLineResponse object, {
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
    required DeliveryOrderLineResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'delivery_order_detail_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.deliveryOrderDetailId = valueDes;
          break;
        case r'sales_order_detail':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.salesOrderDetail = valueDes;
          break;
        case r'product':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.product = valueDes;
          break;
        case r'product_code':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.productCode = valueDes;
          break;
        case r'product_name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.productName = valueDes;
          break;
        case r'warehouse':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.warehouse = valueDes;
          break;
        case r'quantity':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.quantity = valueDes;
          break;
        case r'committed_quantity':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.committedQuantity = valueDes;
          break;
        case r'delivered_quantity':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.deliveredQuantity = valueDes;
          break;
        case r'returned_quantity':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.returnedQuantity = valueDes;
          break;
        case r'open_quantity':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.openQuantity = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DeliveryOrderLineResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DeliveryOrderLineResponseBuilder();
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
