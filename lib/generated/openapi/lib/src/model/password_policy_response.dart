//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'password_policy_response.g.dart';

/// PasswordPolicyResponse
///
/// Properties:
/// * [minLength]
/// * [requireUpper]
/// * [requireLower]
/// * [requireDigit]
/// * [requireSymbol]
@BuiltValue()
abstract class PasswordPolicyResponse
    implements Built<PasswordPolicyResponse, PasswordPolicyResponseBuilder> {
  @BuiltValueField(wireName: r'min_length')
  int get minLength;

  @BuiltValueField(wireName: r'require_upper')
  bool get requireUpper;

  @BuiltValueField(wireName: r'require_lower')
  bool get requireLower;

  @BuiltValueField(wireName: r'require_digit')
  bool get requireDigit;

  @BuiltValueField(wireName: r'require_symbol')
  bool get requireSymbol;

  PasswordPolicyResponse._();

  factory PasswordPolicyResponse([
    void updates(PasswordPolicyResponseBuilder b),
  ]) = _$PasswordPolicyResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PasswordPolicyResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PasswordPolicyResponse> get serializer =>
      _$PasswordPolicyResponseSerializer();
}

class _$PasswordPolicyResponseSerializer
    implements PrimitiveSerializer<PasswordPolicyResponse> {
  @override
  final Iterable<Type> types = const [
    PasswordPolicyResponse,
    _$PasswordPolicyResponse,
  ];

  @override
  final String wireName = r'PasswordPolicyResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PasswordPolicyResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'min_length';
    yield serializers.serialize(
      object.minLength,
      specifiedType: const FullType(int),
    );
    yield r'require_upper';
    yield serializers.serialize(
      object.requireUpper,
      specifiedType: const FullType(bool),
    );
    yield r'require_lower';
    yield serializers.serialize(
      object.requireLower,
      specifiedType: const FullType(bool),
    );
    yield r'require_digit';
    yield serializers.serialize(
      object.requireDigit,
      specifiedType: const FullType(bool),
    );
    yield r'require_symbol';
    yield serializers.serialize(
      object.requireSymbol,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PasswordPolicyResponse object, {
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
    required PasswordPolicyResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'min_length':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.minLength = valueDes;
          break;
        case r'require_upper':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )
                  as bool;
          result.requireUpper = valueDes;
          break;
        case r'require_lower':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )
                  as bool;
          result.requireLower = valueDes;
          break;
        case r'require_digit':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )
                  as bool;
          result.requireDigit = valueDes;
          break;
        case r'require_symbol':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )
                  as bool;
          result.requireSymbol = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PasswordPolicyResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PasswordPolicyResponseBuilder();
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
