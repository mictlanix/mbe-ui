//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'commit_order_request.g.dart';

/// Commit every open line of one delivery order in a single call (FR-038).
///
/// Properties:
/// * [deliveryOrder]
@BuiltValue()
abstract class CommitOrderRequest
    implements Built<CommitOrderRequest, CommitOrderRequestBuilder> {
  @BuiltValueField(wireName: r'delivery_order')
  int get deliveryOrder;

  CommitOrderRequest._();

  factory CommitOrderRequest([void updates(CommitOrderRequestBuilder b)]) =
      _$CommitOrderRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CommitOrderRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CommitOrderRequest> get serializer =>
      _$CommitOrderRequestSerializer();
}

class _$CommitOrderRequestSerializer
    implements PrimitiveSerializer<CommitOrderRequest> {
  @override
  final Iterable<Type> types = const [CommitOrderRequest, _$CommitOrderRequest];

  @override
  final String wireName = r'CommitOrderRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CommitOrderRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'delivery_order';
    yield serializers.serialize(
      object.deliveryOrder,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CommitOrderRequest object, {
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
    required CommitOrderRequestBuilder result,
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CommitOrderRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CommitOrderRequestBuilder();
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
