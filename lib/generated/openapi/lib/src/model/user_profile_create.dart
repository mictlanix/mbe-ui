//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/profile_privilege_update.dart';
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/entity_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'user_profile_create.g.dart';

/// UserProfileCreate
///
/// Properties:
/// * [name]
/// * [description]
/// * [status]
/// * [privileges]
@BuiltValue()
abstract class UserProfileCreate
    implements Built<UserProfileCreate, UserProfileCreateBuilder> {
  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'description')
  String? get description;

  @BuiltValueField(wireName: r'status')
  EntityStatus? get status;
  // enum statusEnum {  0,  1,  2,  };

  @BuiltValueField(wireName: r'privileges')
  BuiltList<ProfilePrivilegeUpdate>? get privileges;

  UserProfileCreate._();

  factory UserProfileCreate([void updates(UserProfileCreateBuilder b)]) =
      _$UserProfileCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UserProfileCreateBuilder b) =>
      b..status = EntityStatus.number0;

  @BuiltValueSerializer(custom: true)
  static Serializer<UserProfileCreate> get serializer =>
      _$UserProfileCreateSerializer();
}

class _$UserProfileCreateSerializer
    implements PrimitiveSerializer<UserProfileCreate> {
  @override
  final Iterable<Type> types = const [UserProfileCreate, _$UserProfileCreate];

  @override
  final String wireName = r'UserProfileCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UserProfileCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    if (object.description != null) {
      yield r'description';
      yield serializers.serialize(
        object.description,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(EntityStatus),
      );
    }
    if (object.privileges != null) {
      yield r'privileges';
      yield serializers.serialize(
        object.privileges,
        specifiedType: const FullType.nullable(BuiltList, [
          FullType(ProfilePrivilegeUpdate),
        ]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    UserProfileCreate object, {
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
    required UserProfileCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.name = valueDes;
          break;
        case r'description':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.description = valueDes;
          break;
        case r'status':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(EntityStatus),
                  )
                  as EntityStatus?;
          if (valueDes == null) continue;
          result.status = valueDes;
          break;
        case r'privileges':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(BuiltList, [
                      FullType(ProfilePrivilegeUpdate),
                    ]),
                  )
                  as BuiltList<ProfilePrivilegeUpdate>?;
          if (valueDes == null) continue;
          result.privileges.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UserProfileCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UserProfileCreateBuilder();
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
