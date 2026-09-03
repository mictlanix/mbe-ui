//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/delivery_order_line_response.dart';
import 'package:mbe_api_client/src/model/delivery_order_status.dart';
import 'package:mbe_api_client/src/model/fulfillment_type.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'delivery_order_response.g.dart';

/// DeliveryOrderResponse
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
/// * [contact]
/// * [comment]
/// * [rejectionReason]
/// * [proofOfDelivery]
/// * [creationTime]
/// * [modificationTime]
/// * [lines]
@BuiltValue()
abstract class DeliveryOrderResponse
    implements Built<DeliveryOrderResponse, DeliveryOrderResponseBuilder> {
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
  // enum fulfillmentTypeEnum {  0,  1,  2,  };

  @BuiltValueField(wireName: r'parent_delivery_order')
  int? get parentDeliveryOrder;

  @BuiltValueField(wireName: r'contact')
  int? get contact;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  @BuiltValueField(wireName: r'rejection_reason')
  String? get rejectionReason;

  @BuiltValueField(wireName: r'proof_of_delivery')
  int? get proofOfDelivery;

  @BuiltValueField(wireName: r'creation_time')
  DateTime get creationTime;

  @BuiltValueField(wireName: r'modification_time')
  DateTime get modificationTime;

  @BuiltValueField(wireName: r'lines')
  BuiltList<DeliveryOrderLineResponse>? get lines;

  DeliveryOrderResponse._();

  factory DeliveryOrderResponse([
    void updates(DeliveryOrderResponseBuilder b),
  ]) = _$DeliveryOrderResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DeliveryOrderResponseBuilder b) => b
    ..salesOrders = ListBuilder()
    ..lines = ListBuilder();

  @BuiltValueSerializer(custom: true)
  static Serializer<DeliveryOrderResponse> get serializer =>
      _$DeliveryOrderResponseSerializer();
}

class _$DeliveryOrderResponseSerializer
    implements PrimitiveSerializer<DeliveryOrderResponse> {
  @override
  final Iterable<Type> types = const [
    DeliveryOrderResponse,
    _$DeliveryOrderResponse,
  ];

  @override
  final String wireName = r'DeliveryOrderResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DeliveryOrderResponse object, {
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
    yield r'contact';
    yield object.contact == null
        ? null
        : serializers.serialize(
            object.contact,
            specifiedType: const FullType.nullable(int),
          );
    yield r'comment';
    yield object.comment == null
        ? null
        : serializers.serialize(
            object.comment,
            specifiedType: const FullType.nullable(String),
          );
    yield r'rejection_reason';
    yield object.rejectionReason == null
        ? null
        : serializers.serialize(
            object.rejectionReason,
            specifiedType: const FullType.nullable(String),
          );
    yield r'proof_of_delivery';
    yield object.proofOfDelivery == null
        ? null
        : serializers.serialize(
            object.proofOfDelivery,
            specifiedType: const FullType.nullable(int),
          );
    yield r'creation_time';
    yield serializers.serialize(
      object.creationTime,
      specifiedType: const FullType(DateTime),
    );
    yield r'modification_time';
    yield serializers.serialize(
      object.modificationTime,
      specifiedType: const FullType(DateTime),
    );
    if (object.lines != null) {
      yield r'lines';
      yield serializers.serialize(
        object.lines,
        specifiedType: const FullType(BuiltList, [
          FullType(DeliveryOrderLineResponse),
        ]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    DeliveryOrderResponse object, {
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
    required DeliveryOrderResponseBuilder result,
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
                    specifiedType: const FullType.nullable(BuiltList, [
                      FullType(int),
                    ]),
                  )
                  as BuiltList<int>?;
          if (valueDes == null) continue;
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
        case r'contact':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.contact = valueDes;
          break;
        case r'comment':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.comment = valueDes;
          break;
        case r'rejection_reason':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.rejectionReason = valueDes;
          break;
        case r'proof_of_delivery':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.proofOfDelivery = valueDes;
          break;
        case r'creation_time':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )
                  as DateTime;
          result.creationTime = valueDes;
          break;
        case r'modification_time':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )
                  as DateTime;
          result.modificationTime = valueDes;
          break;
        case r'lines':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(BuiltList, [
                      FullType(DeliveryOrderLineResponse),
                    ]),
                  )
                  as BuiltList<DeliveryOrderLineResponse>?;
          if (valueDes == null) continue;
          result.lines.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DeliveryOrderResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DeliveryOrderResponseBuilder();
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
