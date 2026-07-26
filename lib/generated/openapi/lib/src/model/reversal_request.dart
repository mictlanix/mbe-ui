//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'reversal_request.g.dart';

/// The reason is mandatory — SC-009 allows no anonymous or unexplained reversal.
///
/// Properties:
/// * [reason]
@BuiltValue()
abstract class ReversalRequest
    implements Built<ReversalRequest, ReversalRequestBuilder> {
  @BuiltValueField(wireName: r'reason')
  String get reason;

  ReversalRequest._();

  factory ReversalRequest([void updates(ReversalRequestBuilder b)]) =
      _$ReversalRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReversalRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReversalRequest> get serializer =>
      _$ReversalRequestSerializer();
}

class _$ReversalRequestSerializer
    implements PrimitiveSerializer<ReversalRequest> {
  @override
  final Iterable<Type> types = const [ReversalRequest, _$ReversalRequest];

  @override
  final String wireName = r'ReversalRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReversalRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ReversalRequest object, {
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
    required ReversalRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'reason':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
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
  ReversalRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReversalRequestBuilder();
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
