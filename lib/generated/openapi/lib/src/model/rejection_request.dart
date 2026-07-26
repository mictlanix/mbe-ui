//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'rejection_request.g.dart';

/// RejectionRequest
///
/// Properties:
/// * [reason]
@BuiltValue()
abstract class RejectionRequest
    implements Built<RejectionRequest, RejectionRequestBuilder> {
  @BuiltValueField(wireName: r'reason')
  String get reason;

  RejectionRequest._();

  factory RejectionRequest([void updates(RejectionRequestBuilder b)]) =
      _$RejectionRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RejectionRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RejectionRequest> get serializer =>
      _$RejectionRequestSerializer();
}

class _$RejectionRequestSerializer
    implements PrimitiveSerializer<RejectionRequest> {
  @override
  final Iterable<Type> types = const [RejectionRequest, _$RejectionRequest];

  @override
  final String wireName = r'RejectionRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RejectionRequest object, {
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
    RejectionRequest object, {
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
    required RejectionRequestBuilder result,
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
  RejectionRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RejectionRequestBuilder();
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
