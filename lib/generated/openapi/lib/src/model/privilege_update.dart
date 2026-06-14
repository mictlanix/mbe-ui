//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'privilege_update.g.dart';

/// PrivilegeUpdate
///
/// Properties:
/// * [systemObject] 
/// * [privileges] 
@BuiltValue()
abstract class PrivilegeUpdate implements Built<PrivilegeUpdate, PrivilegeUpdateBuilder> {
  @BuiltValueField(wireName: r'system_object')
  int get systemObject;

  @BuiltValueField(wireName: r'privileges')
  int get privileges;

  PrivilegeUpdate._();

  factory PrivilegeUpdate([void updates(PrivilegeUpdateBuilder b)]) = _$PrivilegeUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PrivilegeUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PrivilegeUpdate> get serializer => _$PrivilegeUpdateSerializer();
}

class _$PrivilegeUpdateSerializer implements PrimitiveSerializer<PrivilegeUpdate> {
  @override
  final Iterable<Type> types = const [PrivilegeUpdate, _$PrivilegeUpdate];

  @override
  final String wireName = r'PrivilegeUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PrivilegeUpdate object, {
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
  }

  @override
  Object serialize(
    Serializers serializers,
    PrivilegeUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PrivilegeUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'system_object':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.systemObject = valueDes;
          break;
        case r'privileges':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.privileges = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PrivilegeUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PrivilegeUpdateBuilder();
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

