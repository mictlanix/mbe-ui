//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'profile_privilege_response.g.dart';

/// One entry of a profile. Same field set as `PrivilegeResponse` by design — a client renders a user's permissions and a profile's with the same component.
///
/// Properties:
/// * [systemObject]
/// * [privileges]
/// * [allowCreate]
/// * [allowRead]
/// * [allowUpdate]
/// * [allowDelete]
@BuiltValue()
abstract class ProfilePrivilegeResponse
    implements
        Built<ProfilePrivilegeResponse, ProfilePrivilegeResponseBuilder> {
  @BuiltValueField(wireName: r'system_object')
  int get systemObject;

  @BuiltValueField(wireName: r'privileges')
  int get privileges;

  @BuiltValueField(wireName: r'allow_create')
  bool get allowCreate;

  @BuiltValueField(wireName: r'allow_read')
  bool get allowRead;

  @BuiltValueField(wireName: r'allow_update')
  bool get allowUpdate;

  @BuiltValueField(wireName: r'allow_delete')
  bool get allowDelete;

  ProfilePrivilegeResponse._();

  factory ProfilePrivilegeResponse([
    void updates(ProfilePrivilegeResponseBuilder b),
  ]) = _$ProfilePrivilegeResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProfilePrivilegeResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ProfilePrivilegeResponse> get serializer =>
      _$ProfilePrivilegeResponseSerializer();
}

class _$ProfilePrivilegeResponseSerializer
    implements PrimitiveSerializer<ProfilePrivilegeResponse> {
  @override
  final Iterable<Type> types = const [
    ProfilePrivilegeResponse,
    _$ProfilePrivilegeResponse,
  ];

  @override
  final String wireName = r'ProfilePrivilegeResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProfilePrivilegeResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'system_object';
    yield serializers.serialize(
      object.systemObject,
      specifiedType: const FullType(int),
    );
    yield r'privileges';
    yield serializers.serialize(
      object.privileges,
      specifiedType: const FullType(int),
    );
    yield r'allow_create';
    yield serializers.serialize(
      object.allowCreate,
      specifiedType: const FullType(bool),
    );
    yield r'allow_read';
    yield serializers.serialize(
      object.allowRead,
      specifiedType: const FullType(bool),
    );
    yield r'allow_update';
    yield serializers.serialize(
      object.allowUpdate,
      specifiedType: const FullType(bool),
    );
    yield r'allow_delete';
    yield serializers.serialize(
      object.allowDelete,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ProfilePrivilegeResponse object, {
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
    required ProfilePrivilegeResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'system_object':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.systemObject = valueDes;
          break;
        case r'privileges':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.privileges = valueDes;
          break;
        case r'allow_create':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )
                  as bool;
          result.allowCreate = valueDes;
          break;
        case r'allow_read':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )
                  as bool;
          result.allowRead = valueDes;
          break;
        case r'allow_update':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )
                  as bool;
          result.allowUpdate = valueDes;
          break;
        case r'allow_delete':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )
                  as bool;
          result.allowDelete = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ProfilePrivilegeResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProfilePrivilegeResponseBuilder();
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
