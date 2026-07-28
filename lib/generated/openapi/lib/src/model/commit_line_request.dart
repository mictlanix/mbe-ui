//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/quantity.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'commit_line_request.g.dart';

/// CommitLineRequest
///
/// Properties:
/// * [deliveryOrderDetail]
/// * [quantity]
/// * [comment]
@BuiltValue()
abstract class CommitLineRequest
    implements Built<CommitLineRequest, CommitLineRequestBuilder> {
  @BuiltValueField(wireName: r'delivery_order_detail')
  int get deliveryOrderDetail;

  @BuiltValueField(wireName: r'quantity')
  Quantity? get quantity;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  CommitLineRequest._();

  factory CommitLineRequest([void updates(CommitLineRequestBuilder b)]) =
      _$CommitLineRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CommitLineRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CommitLineRequest> get serializer =>
      _$CommitLineRequestSerializer();
}

class _$CommitLineRequestSerializer
    implements PrimitiveSerializer<CommitLineRequest> {
  @override
  final Iterable<Type> types = const [CommitLineRequest, _$CommitLineRequest];

  @override
  final String wireName = r'CommitLineRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CommitLineRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'delivery_order_detail';
    yield serializers.serialize(
      object.deliveryOrderDetail,
      specifiedType: const FullType(int),
    );
    if (object.quantity != null) {
      yield r'quantity';
      yield serializers.serialize(
        object.quantity,
        specifiedType: const FullType.nullable(Quantity),
      );
    }
    if (object.comment != null) {
      yield r'comment';
      yield serializers.serialize(
        object.comment,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CommitLineRequest object, {
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
    required CommitLineRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'delivery_order_detail':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.deliveryOrderDetail = valueDes;
          break;
        case r'quantity':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(Quantity),
                  )
                  as Quantity?;
          if (valueDes == null) continue;
          result.quantity.replace(valueDes);
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
  CommitLineRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CommitLineRequestBuilder();
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
