//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'recover_password_admin_response.g.dart';

/// Returned to admin after triggering a password recovery for a user.
///
/// Properties:
/// * [recoveryToken] 
/// * [expiresAt] 
@BuiltValue()
abstract class RecoverPasswordAdminResponse implements Built<RecoverPasswordAdminResponse, RecoverPasswordAdminResponseBuilder> {
  @BuiltValueField(wireName: r'recovery_token')
  String get recoveryToken;

  @BuiltValueField(wireName: r'expires_at')
  String get expiresAt;

  RecoverPasswordAdminResponse._();

  factory RecoverPasswordAdminResponse([void updates(RecoverPasswordAdminResponseBuilder b)]) = _$RecoverPasswordAdminResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RecoverPasswordAdminResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RecoverPasswordAdminResponse> get serializer => _$RecoverPasswordAdminResponseSerializer();
}

class _$RecoverPasswordAdminResponseSerializer implements PrimitiveSerializer<RecoverPasswordAdminResponse> {
  @override
  final Iterable<Type> types = const [RecoverPasswordAdminResponse, _$RecoverPasswordAdminResponse];

  @override
  final String wireName = r'RecoverPasswordAdminResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RecoverPasswordAdminResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'recovery_token';
    yield serializers.serialize(
      object.recoveryToken,
      specifiedType: const FullType(String),
    );
    yield r'expires_at';
    yield serializers.serialize(
      object.expiresAt,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RecoverPasswordAdminResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RecoverPasswordAdminResponseBuilder result,
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
        case r'expires_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.expiresAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RecoverPasswordAdminResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RecoverPasswordAdminResponseBuilder();
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

