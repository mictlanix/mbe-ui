//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/entity_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'user_list_item.g.dart';

/// UserListItem
///
/// Properties:
/// * [userId]
/// * [email]
/// * [employeeId]
/// * [administrator]
/// * [status]
/// * [profileId]
/// * [profileName]
@BuiltValue()
abstract class UserListItem
    implements Built<UserListItem, UserListItemBuilder> {
  @BuiltValueField(wireName: r'user_id')
  String get userId;

  @BuiltValueField(wireName: r'email')
  String get email;

  @BuiltValueField(wireName: r'employee_id')
  int get employeeId;

  @BuiltValueField(wireName: r'administrator')
  bool get administrator;

  @BuiltValueField(wireName: r'status')
  EntityStatus get status;
  // enum statusEnum {  0,  1,  2,  };

  @BuiltValueField(wireName: r'profile_id')
  int? get profileId;

  @BuiltValueField(wireName: r'profile_name')
  String? get profileName;

  UserListItem._();

  factory UserListItem([void updates(UserListItemBuilder b)]) = _$UserListItem;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UserListItemBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UserListItem> get serializer => _$UserListItemSerializer();
}

class _$UserListItemSerializer implements PrimitiveSerializer<UserListItem> {
  @override
  final Iterable<Type> types = const [UserListItem, _$UserListItem];

  @override
  final String wireName = r'UserListItem';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UserListItem object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'user_id';
    yield serializers.serialize(
      object.userId,
      specifiedType: const FullType(String),
    );
    yield r'email';
    yield serializers.serialize(
      object.email,
      specifiedType: const FullType(String),
    );
    yield r'employee_id';
    yield serializers.serialize(
      object.employeeId,
      specifiedType: const FullType(int),
    );
    yield r'administrator';
    yield serializers.serialize(
      object.administrator,
      specifiedType: const FullType(bool),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(EntityStatus),
    );
    if (object.profileId != null) {
      yield r'profile_id';
      yield serializers.serialize(
        object.profileId,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.profileName != null) {
      yield r'profile_name';
      yield serializers.serialize(
        object.profileName,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    UserListItem object, {
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
    required UserListItemBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'user_id':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.userId = valueDes;
          break;
        case r'email':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.email = valueDes;
          break;
        case r'employee_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.employeeId = valueDes;
          break;
        case r'administrator':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )
                  as bool;
          result.administrator = valueDes;
          break;
        case r'status':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(EntityStatus),
                  )
                  as EntityStatus;
          result.status = valueDes;
          break;
        case r'profile_id':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.profileId = valueDes;
          break;
        case r'profile_name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.profileName = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UserListItem deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UserListItemBuilder();
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
