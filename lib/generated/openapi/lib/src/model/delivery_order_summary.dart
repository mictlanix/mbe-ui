//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/delivery_order_status.dart';
import 'package:mbe_api_client/src/model/fulfillment_type.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'delivery_order_summary.g.dart';

/// DeliveryOrderSummary
///
/// Properties:
/// * [deliveryOrderId]
/// * [facility]
/// * [serial]
/// * [customer]
/// * [salesOrders]
/// * [shipTo]
/// * [date]
/// * [priority]
/// * [status]
/// * [fulfillmentType]
/// * [parentDeliveryOrder]
@BuiltValue()
abstract class DeliveryOrderSummary
    implements Built<DeliveryOrderSummary, DeliveryOrderSummaryBuilder> {
  @BuiltValueField(wireName: r'delivery_order_id')
  int get deliveryOrderId;

  @BuiltValueField(wireName: r'facility')
  int get facility;

  @BuiltValueField(wireName: r'serial')
  int? get serial;

  @BuiltValueField(wireName: r'customer')
  int get customer;

  @BuiltValueField(wireName: r'sales_orders')
  BuiltList<int>? get salesOrders;

  @BuiltValueField(wireName: r'ship_to')
  int? get shipTo;

  @BuiltValueField(wireName: r'date')
  DateTime? get date;

  @BuiltValueField(wireName: r'priority')
  int get priority;

  @BuiltValueField(wireName: r'status')
  DeliveryOrderStatus get status;
  // enum statusEnum {  0,  1,  2,  3,  4,  5,  6,  7,  8,  9,  10,  };

  @BuiltValueField(wireName: r'fulfillment_type')
  FulfillmentType get fulfillmentType;
  // enum fulfillmentTypeEnum {  0,  1,  };

  @BuiltValueField(wireName: r'parent_delivery_order')
  int? get parentDeliveryOrder;

  DeliveryOrderSummary._();

  factory DeliveryOrderSummary([void updates(DeliveryOrderSummaryBuilder b)]) =
      _$DeliveryOrderSummary;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DeliveryOrderSummaryBuilder b) =>
      b..salesOrders = ListBuilder();

  @BuiltValueSerializer(custom: true)
  static Serializer<DeliveryOrderSummary> get serializer =>
      _$DeliveryOrderSummarySerializer();
}

class _$DeliveryOrderSummarySerializer
    implements PrimitiveSerializer<DeliveryOrderSummary> {
  @override
  final Iterable<Type> types = const [
    DeliveryOrderSummary,
    _$DeliveryOrderSummary,
  ];

  @override
  final String wireName = r'DeliveryOrderSummary';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DeliveryOrderSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'delivery_order_id';
    yield serializers.serialize(
      object.deliveryOrderId,
      specifiedType: const FullType(int),
    );
    yield r'facility';
    yield serializers.serialize(
      object.facility,
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
    if (object.salesOrders != null) {
      yield r'sales_orders';
      yield serializers.serialize(
        object.salesOrders,
        specifiedType: const FullType(BuiltList, [FullType(int)]),
      );
    }
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
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(DeliveryOrderStatus),
    );
    yield r'fulfillment_type';
    yield serializers.serialize(
      object.fulfillmentType,
      specifiedType: const FullType(FulfillmentType),
    );
    yield r'parent_delivery_order';
    yield object.parentDeliveryOrder == null
        ? null
        : serializers.serialize(
            object.parentDeliveryOrder,
            specifiedType: const FullType.nullable(int),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    DeliveryOrderSummary object, {
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
    required DeliveryOrderSummaryBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'delivery_order_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.deliveryOrderId = valueDes;
          break;
        case r'facility':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.facility = valueDes;
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
        case r'sales_orders':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltList, [FullType(int)]),
                  )
                  as BuiltList<int>;
          result.salesOrders.replace(valueDes);
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
        case r'status':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DeliveryOrderStatus),
                  )
                  as DeliveryOrderStatus;
          result.status = valueDes;
          break;
        case r'fulfillment_type':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(FulfillmentType),
                  )
                  as FulfillmentType;
          result.fulfillmentType = valueDes;
          break;
        case r'parent_delivery_order':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.parentDeliveryOrder = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DeliveryOrderSummary deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DeliveryOrderSummaryBuilder();
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
