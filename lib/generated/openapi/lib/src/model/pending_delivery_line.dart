//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pending_delivery_line.g.dart';

/// PendingDeliveryLine
///
/// Properties:
/// * [deliveryOrder]
/// * [deliveryOrderDetail]
/// * [serial]
/// * [customer]
/// * [shipTo]
/// * [date]
/// * [priority]
/// * [product]
/// * [productCode]
/// * [productName]
/// * [warehouse]
/// * [openQuantity]
@BuiltValue()
abstract class PendingDeliveryLine
    implements Built<PendingDeliveryLine, PendingDeliveryLineBuilder> {
  @BuiltValueField(wireName: r'delivery_order')
  int get deliveryOrder;

  @BuiltValueField(wireName: r'delivery_order_detail')
  int get deliveryOrderDetail;

  @BuiltValueField(wireName: r'serial')
  int? get serial;

  @BuiltValueField(wireName: r'customer')
  int get customer;

  @BuiltValueField(wireName: r'ship_to')
  int? get shipTo;

  @BuiltValueField(wireName: r'date')
  DateTime? get date;

  @BuiltValueField(wireName: r'priority')
  int get priority;

  @BuiltValueField(wireName: r'product')
  int get product;

  @BuiltValueField(wireName: r'product_code')
  String get productCode;

  @BuiltValueField(wireName: r'product_name')
  String get productName;

  @BuiltValueField(wireName: r'warehouse')
  int get warehouse;

  @BuiltValueField(wireName: r'open_quantity')
  String get openQuantity;

  PendingDeliveryLine._();

  factory PendingDeliveryLine([void updates(PendingDeliveryLineBuilder b)]) =
      _$PendingDeliveryLine;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PendingDeliveryLineBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PendingDeliveryLine> get serializer =>
      _$PendingDeliveryLineSerializer();
}

class _$PendingDeliveryLineSerializer
    implements PrimitiveSerializer<PendingDeliveryLine> {
  @override
  final Iterable<Type> types = const [
    PendingDeliveryLine,
    _$PendingDeliveryLine,
  ];

  @override
  final String wireName = r'PendingDeliveryLine';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PendingDeliveryLine object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'delivery_order';
    yield serializers.serialize(
      object.deliveryOrder,
      specifiedType: const FullType(int),
    );
    yield r'delivery_order_detail';
    yield serializers.serialize(
      object.deliveryOrderDetail,
      specifiedType: const FullType(int),
    );
    yield r'serial';
    yield object.serial == null
        ? null
        : serializers.serialize(
            object.serial,
            specifiedType: const FullType.nullable(int),
          );
    yield r'customer';
    yield serializers.serialize(
      object.customer,
      specifiedType: const FullType(int),
    );
    yield r'ship_to';
    yield object.shipTo == null
        ? null
        : serializers.serialize(
            object.shipTo,
            specifiedType: const FullType.nullable(int),
          );
    yield r'date';
    yield object.date == null
        ? null
        : serializers.serialize(
            object.date,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'priority';
    yield serializers.serialize(
      object.priority,
      specifiedType: const FullType(int),
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
    yield r'open_quantity';
    yield serializers.serialize(
      object.openQuantity,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PendingDeliveryLine object, {
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
    required PendingDeliveryLineBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'delivery_order':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.deliveryOrder = valueDes;
          break;
        case r'delivery_order_detail':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.deliveryOrderDetail = valueDes;
          break;
        case r'serial':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.serial = valueDes;
          break;
        case r'customer':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.customer = valueDes;
          break;
        case r'ship_to':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.shipTo = valueDes;
          break;
        case r'date':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(DateTime),
                  )
                  as DateTime?;
          if (valueDes == null) continue;
          result.date = valueDes;
          break;
        case r'priority':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.priority = valueDes;
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
  PendingDeliveryLine deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PendingDeliveryLineBuilder();
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
