//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/delivery_order_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'delivery_order_event_response.g.dart';

/// DeliveryOrderEventResponse
///
/// Properties:
/// * [deliveryOrderEventId]
/// * [fromStatus]
/// * [toStatus]
/// * [employee]
/// * [eventTime]
/// * [reason]
@BuiltValue()
abstract class DeliveryOrderEventResponse
    implements
        Built<DeliveryOrderEventResponse, DeliveryOrderEventResponseBuilder> {
  @BuiltValueField(wireName: r'delivery_order_event_id')
  int get deliveryOrderEventId;

  @BuiltValueField(wireName: r'from_status')
  DeliveryOrderStatus? get fromStatus;
  // enum fromStatusEnum {  0,  1,  2,  3,  4,  5,  6,  7,  8,  9,  10,  };

  @BuiltValueField(wireName: r'to_status')
  DeliveryOrderStatus get toStatus;
  // enum toStatusEnum {  0,  1,  2,  3,  4,  5,  6,  7,  8,  9,  10,  };

  @BuiltValueField(wireName: r'employee')
  int get employee;

  @BuiltValueField(wireName: r'event_time')
  DateTime get eventTime;

  @BuiltValueField(wireName: r'reason')
  String? get reason;

  DeliveryOrderEventResponse._();

  factory DeliveryOrderEventResponse([
    void updates(DeliveryOrderEventResponseBuilder b),
  ]) = _$DeliveryOrderEventResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DeliveryOrderEventResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DeliveryOrderEventResponse> get serializer =>
      _$DeliveryOrderEventResponseSerializer();
}

class _$DeliveryOrderEventResponseSerializer
    implements PrimitiveSerializer<DeliveryOrderEventResponse> {
  @override
  final Iterable<Type> types = const [
    DeliveryOrderEventResponse,
    _$DeliveryOrderEventResponse,
  ];

  @override
  final String wireName = r'DeliveryOrderEventResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DeliveryOrderEventResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'delivery_order_event_id';
    yield serializers.serialize(
      object.deliveryOrderEventId,
      specifiedType: const FullType(int),
    );
    yield r'from_status';
    yield object.fromStatus == null
        ? null
        : serializers.serialize(
            object.fromStatus,
            specifiedType: const FullType.nullable(DeliveryOrderStatus),
          );
    yield r'to_status';
    yield serializers.serialize(
      object.toStatus,
      specifiedType: const FullType(DeliveryOrderStatus),
    );
    yield r'employee';
    yield serializers.serialize(
      object.employee,
      specifiedType: const FullType(int),
    );
    yield r'event_time';
    yield serializers.serialize(
      object.eventTime,
      specifiedType: const FullType(DateTime),
    );
    yield r'reason';
    yield object.reason == null
        ? null
        : serializers.serialize(
            object.reason,
            specifiedType: const FullType.nullable(String),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    DeliveryOrderEventResponse object, {
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
    required DeliveryOrderEventResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'delivery_order_event_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.deliveryOrderEventId = valueDes;
          break;
        case r'from_status':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(DeliveryOrderStatus),
                  )
                  as DeliveryOrderStatus?;
          if (valueDes == null) continue;
          result.fromStatus = valueDes;
          break;
        case r'to_status':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DeliveryOrderStatus),
                  )
                  as DeliveryOrderStatus;
          result.toStatus = valueDes;
          break;
        case r'employee':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.employee = valueDes;
          break;
        case r'event_time':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )
                  as DateTime;
          result.eventTime = valueDes;
          break;
        case r'reason':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.reason = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DeliveryOrderEventResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DeliveryOrderEventResponseBuilder();
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
