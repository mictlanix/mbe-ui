//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'proof_of_delivery_response.g.dart';

/// ProofOfDeliveryResponse
///
/// Properties:
/// * [proofOfDeliveryId]
/// * [receiverName]
/// * [receiverIdShown]
/// * [capturedTime]
/// * [capturedBy]
/// * [imageFile]
@BuiltValue()
abstract class ProofOfDeliveryResponse
    implements Built<ProofOfDeliveryResponse, ProofOfDeliveryResponseBuilder> {
  @BuiltValueField(wireName: r'proof_of_delivery_id')
  int get proofOfDeliveryId;

  @BuiltValueField(wireName: r'receiver_name')
  String get receiverName;

  @BuiltValueField(wireName: r'receiver_id_shown')
  String get receiverIdShown;

  @BuiltValueField(wireName: r'captured_time')
  DateTime get capturedTime;

  @BuiltValueField(wireName: r'captured_by')
  int get capturedBy;

  @BuiltValueField(wireName: r'image_file')
  String get imageFile;

  ProofOfDeliveryResponse._();

  factory ProofOfDeliveryResponse([
    void updates(ProofOfDeliveryResponseBuilder b),
  ]) = _$ProofOfDeliveryResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProofOfDeliveryResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ProofOfDeliveryResponse> get serializer =>
      _$ProofOfDeliveryResponseSerializer();
}

class _$ProofOfDeliveryResponseSerializer
    implements PrimitiveSerializer<ProofOfDeliveryResponse> {
  @override
  final Iterable<Type> types = const [
    ProofOfDeliveryResponse,
    _$ProofOfDeliveryResponse,
  ];

  @override
  final String wireName = r'ProofOfDeliveryResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProofOfDeliveryResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'proof_of_delivery_id';
    yield serializers.serialize(
      object.proofOfDeliveryId,
      specifiedType: const FullType(int),
    );
    yield r'receiver_name';
    yield serializers.serialize(
      object.receiverName,
      specifiedType: const FullType(String),
    );
    yield r'receiver_id_shown';
    yield serializers.serialize(
      object.receiverIdShown,
      specifiedType: const FullType(String),
    );
    yield r'captured_time';
    yield serializers.serialize(
      object.capturedTime,
      specifiedType: const FullType(DateTime),
    );
    yield r'captured_by';
    yield serializers.serialize(
      object.capturedBy,
      specifiedType: const FullType(int),
    );
    yield r'image_file';
    yield serializers.serialize(
      object.imageFile,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ProofOfDeliveryResponse object, {
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
    required ProofOfDeliveryResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'proof_of_delivery_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.proofOfDeliveryId = valueDes;
          break;
        case r'receiver_name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.receiverName = valueDes;
          break;
        case r'receiver_id_shown':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.receiverIdShown = valueDes;
          break;
        case r'captured_time':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )
                  as DateTime;
          result.capturedTime = valueDes;
          break;
        case r'captured_by':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.capturedBy = valueDes;
          break;
        case r'image_file':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.imageFile = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ProofOfDeliveryResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProofOfDeliveryResponseBuilder();
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
