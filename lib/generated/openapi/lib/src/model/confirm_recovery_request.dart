//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'confirm_recovery_request.g.dart';

/// ConfirmRecoveryRequest
///
/// Properties:
/// * [recoveryToken] 
/// * [newPassword] 
@BuiltValue()
abstract class ConfirmRecoveryRequest implements Built<ConfirmRecoveryRequest, ConfirmRecoveryRequestBuilder> {
  @BuiltValueField(wireName: r'recovery_token')
  String get recoveryToken;

  @BuiltValueField(wireName: r'new_password')
  String get newPassword;

  ConfirmRecoveryRequest._();

  factory ConfirmRecoveryRequest([void updates(ConfirmRecoveryRequestBuilder b)]) = _$ConfirmRecoveryRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ConfirmRecoveryRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ConfirmRecoveryRequest> get serializer => _$ConfirmRecoveryRequestSerializer();
}

class _$ConfirmRecoveryRequestSerializer implements PrimitiveSerializer<ConfirmRecoveryRequest> {
  @override
  final Iterable<Type> types = const [ConfirmRecoveryRequest, _$ConfirmRecoveryRequest];

  @override
  final String wireName = r'ConfirmRecoveryRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ConfirmRecoveryRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'recovery_token';
    yield serializers.serialize(
      object.recoveryToken,
      specifiedType: const FullType(String),
    );
    yield r'new_password';
    yield serializers.serialize(
      object.newPassword,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ConfirmRecoveryRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ConfirmRecoveryRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'recovery_token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.recoveryToken = valueDes;
          break;
        case r'new_password':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.newPassword = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ConfirmRecoveryRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ConfirmRecoveryRequestBuilder();
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

