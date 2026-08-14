//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/entity_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'user_profile_list_item.g.dart';

/// No `privileges`: a catalog page of twenty profiles would fetch masks it will not render.
///
/// Properties:
/// * [userProfileId]
/// * [name]
/// * [description]
/// * [status]
@BuiltValue()
abstract class UserProfileListItem
    implements Built<UserProfileListItem, UserProfileListItemBuilder> {
  @BuiltValueField(wireName: r'user_profile_id')
  int get userProfileId;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'description')
  String? get description;

  @BuiltValueField(wireName: r'status')
  EntityStatus get status;
  // enum statusEnum {  0,  1,  2,  };

  UserProfileListItem._();

  factory UserProfileListItem([void updates(UserProfileListItemBuilder b)]) =
      _$UserProfileListItem;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UserProfileListItemBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UserProfileListItem> get serializer =>
      _$UserProfileListItemSerializer();
}

class _$UserProfileListItemSerializer
    implements PrimitiveSerializer<UserProfileListItem> {
  @override
  final Iterable<Type> types = const [
    UserProfileListItem,
    _$UserProfileListItem,
  ];

  @override
  final String wireName = r'UserProfileListItem';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UserProfileListItem object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'user_profile_id';
    yield serializers.serialize(
      object.userProfileId,
      specifiedType: const FullType(int),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'description';
    yield object.description == null
        ? null
        : serializers.serialize(
            object.description,
            specifiedType: const FullType.nullable(String),
          );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(EntityStatus),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    UserProfileListItem object, {
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
    required UserProfileListItemBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'user_profile_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.userProfileId = valueDes;
          break;
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
                    specifiedType: const FullType(EntityStatus),
                  )
                  as EntityStatus;
          result.status = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UserProfileListItem deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UserProfileListItemBuilder();
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
