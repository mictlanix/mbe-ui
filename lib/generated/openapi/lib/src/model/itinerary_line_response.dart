//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/shortfall_reason.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'itinerary_line_response.g.dart';

/// ItineraryLineResponse
///
/// Properties:
/// * [deliveriesItineraryDetailId]
/// * [deliveryOrderDetail]
/// * [committedQuantity]
/// * [sentQuantity]
/// * [deliveredQuantity]
/// * [returnedQuantity]
/// * [reasonCode]
/// * [comment]
@BuiltValue()
abstract class ItineraryLineResponse
    implements Built<ItineraryLineResponse, ItineraryLineResponseBuilder> {
  @BuiltValueField(wireName: r'deliveries_itinerary_detail_id')
  int get deliveriesItineraryDetailId;

  @BuiltValueField(wireName: r'delivery_order_detail')
  int get deliveryOrderDetail;

  @BuiltValueField(wireName: r'committed_quantity')
  String get committedQuantity;

  @BuiltValueField(wireName: r'sent_quantity')
  String get sentQuantity;

  @BuiltValueField(wireName: r'delivered_quantity')
  String get deliveredQuantity;

  @BuiltValueField(wireName: r'returned_quantity')
  String get returnedQuantity;

  @BuiltValueField(wireName: r'reason_code')
  ShortfallReason? get reasonCode;
  // enum reasonCodeEnum {  0,  1,  2,  3,  4,  };

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  ItineraryLineResponse._();

  factory ItineraryLineResponse([
    void updates(ItineraryLineResponseBuilder b),
  ]) = _$ItineraryLineResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ItineraryLineResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ItineraryLineResponse> get serializer =>
      _$ItineraryLineResponseSerializer();
}

class _$ItineraryLineResponseSerializer
    implements PrimitiveSerializer<ItineraryLineResponse> {
  @override
  final Iterable<Type> types = const [
    ItineraryLineResponse,
    _$ItineraryLineResponse,
  ];

  @override
  final String wireName = r'ItineraryLineResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ItineraryLineResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'deliveries_itinerary_detail_id';
    yield serializers.serialize(
      object.deliveriesItineraryDetailId,
      specifiedType: const FullType(int),
    );
    yield r'delivery_order_detail';
    yield serializers.serialize(
      object.deliveryOrderDetail,
      specifiedType: const FullType(int),
    );
    yield r'committed_quantity';
    yield serializers.serialize(
      object.committedQuantity,
      specifiedType: const FullType(String),
    );
    yield r'sent_quantity';
    yield serializers.serialize(
      object.sentQuantity,
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
    yield r'reason_code';
    yield object.reasonCode == null
        ? null
        : serializers.serialize(
            object.reasonCode,
            specifiedType: const FullType.nullable(ShortfallReason),
          );
    yield r'comment';
    yield object.comment == null
        ? null
        : serializers.serialize(
            object.comment,
            specifiedType: const FullType.nullable(String),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    ItineraryLineResponse object, {
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
    required ItineraryLineResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'deliveries_itinerary_detail_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.deliveriesItineraryDetailId = valueDes;
          break;
        case r'delivery_order_detail':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.deliveryOrderDetail = valueDes;
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
        case r'sent_quantity':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.sentQuantity = valueDes;
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
        case r'reason_code':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(ShortfallReason),
                  )
                  as ShortfallReason?;
          if (valueDes == null) continue;
          result.reasonCode = valueDes;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ItineraryLineResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ItineraryLineResponseBuilder();
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
