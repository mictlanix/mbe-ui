//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/pending_delivery_bucket.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pending_deliveries_response.g.dart';

/// PendingDeliveriesResponse
///
/// Properties:
/// * [buckets]
@BuiltValue()
abstract class PendingDeliveriesResponse
    implements
        Built<PendingDeliveriesResponse, PendingDeliveriesResponseBuilder> {
  @BuiltValueField(wireName: r'buckets')
  BuiltList<PendingDeliveryBucket> get buckets;

  PendingDeliveriesResponse._();

  factory PendingDeliveriesResponse([
    void updates(PendingDeliveriesResponseBuilder b),
  ]) = _$PendingDeliveriesResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PendingDeliveriesResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PendingDeliveriesResponse> get serializer =>
      _$PendingDeliveriesResponseSerializer();
}

class _$PendingDeliveriesResponseSerializer
    implements PrimitiveSerializer<PendingDeliveriesResponse> {
  @override
  final Iterable<Type> types = const [
    PendingDeliveriesResponse,
    _$PendingDeliveriesResponse,
  ];

  @override
  final String wireName = r'PendingDeliveriesResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PendingDeliveriesResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'buckets';
    yield serializers.serialize(
      object.buckets,
      specifiedType: const FullType(BuiltList, [
        FullType(PendingDeliveryBucket),
      ]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PendingDeliveriesResponse object, {
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
    required PendingDeliveriesResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'buckets':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltList, [
                      FullType(PendingDeliveryBucket),
                    ]),
                  )
                  as BuiltList<PendingDeliveryBucket>;
          result.buckets.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PendingDeliveriesResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PendingDeliveriesResponseBuilder();
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
