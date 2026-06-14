//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
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
/// * [disabled] 
@BuiltValue()
abstract class UserListItem implements Built<UserListItem, UserListItemBuilder> {
  @BuiltValueField(wireName: r'user_id')
  String get userId;

  @BuiltValueField(wireName: r'email')
  String get email;

  @BuiltValueField(wireName: r'employee_id')
  int? get employeeId;

  @BuiltValueField(wireName: r'administrator')
  bool get administrator;

  @BuiltValueField(wireName: r'disabled')
  bool get disabled;

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
    yield object.employeeId == null ? null : serializers.serialize(
      object.employeeId,
      specifiedType: const FullType.nullable(int),
    );
    yield r'administrator';
    yield serializers.serialize(
      object.administrator,
      specifiedType: const FullType(bool),
    );
    yield r'disabled';
    yield serializers.serialize(
      object.disabled,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    UserListItem object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
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
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.userId = valueDes;
          break;
        case r'email':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.email = valueDes;
          break;
        case r'employee_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.employeeId = valueDes;
          break;
        case r'administrator':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.administrator = valueDes;
          break;
        case r'disabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.disabled = valueDes;
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

