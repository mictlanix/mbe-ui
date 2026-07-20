//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/privilege_update.dart';
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/entity_status.dart';
import 'package:mbe_api_client/src/model/user_settings_update.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'user_update.g.dart';

/// UserUpdate
///
/// Properties:
/// * [email]
/// * [employeeId]
/// * [administrator]
/// * [status]
/// * [privileges]
/// * [settings]
@BuiltValue()
abstract class UserUpdate implements Built<UserUpdate, UserUpdateBuilder> {
  @BuiltValueField(wireName: r'email')
  String? get email;

  @BuiltValueField(wireName: r'employee_id')
  int? get employeeId;

  @BuiltValueField(wireName: r'administrator')
  bool? get administrator;

  @BuiltValueField(wireName: r'status')
  EntityStatus? get status;
  // enum statusEnum {  0,  1,  2,  };

  @BuiltValueField(wireName: r'privileges')
  BuiltList<PrivilegeUpdate>? get privileges;

  @BuiltValueField(wireName: r'settings')
  UserSettingsUpdate? get settings;

  UserUpdate._();

  factory UserUpdate([void updates(UserUpdateBuilder b)]) = _$UserUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UserUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UserUpdate> get serializer => _$UserUpdateSerializer();
}

class _$UserUpdateSerializer implements PrimitiveSerializer<UserUpdate> {
  @override
  final Iterable<Type> types = const [UserUpdate, _$UserUpdate];

  @override
  final String wireName = r'UserUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UserUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.email != null) {
      yield r'email';
      yield serializers.serialize(
        object.email,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.employeeId != null) {
      yield r'employee_id';
      yield serializers.serialize(
        object.employeeId,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.administrator != null) {
      yield r'administrator';
      yield serializers.serialize(
        object.administrator,
        specifiedType: const FullType.nullable(bool),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType.nullable(EntityStatus),
      );
    }
    if (object.privileges != null) {
      yield r'privileges';
      yield serializers.serialize(
        object.privileges,
        specifiedType: const FullType.nullable(BuiltList, [
          FullType(PrivilegeUpdate),
        ]),
      );
    }
    if (object.settings != null) {
      yield r'settings';
      yield serializers.serialize(
        object.settings,
        specifiedType: const FullType.nullable(UserSettingsUpdate),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    UserUpdate object, {
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
    required UserUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'email':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.email = valueDes;
          break;
        case r'employee_id':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.employeeId = valueDes;
          break;
        case r'administrator':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(bool),
                  )
                  as bool?;
          if (valueDes == null) continue;
          result.administrator = valueDes;
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
                      FullType(PrivilegeUpdate),
                    ]),
                  )
                  as BuiltList<PrivilegeUpdate>?;
          if (valueDes == null) continue;
          result.privileges.replace(valueDes);
          break;
        case r'settings':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(UserSettingsUpdate),
                  )
                  as UserSettingsUpdate?;
          if (valueDes == null) continue;
          result.settings.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UserUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UserUpdateBuilder();
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
