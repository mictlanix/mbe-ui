//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'privilege_response.g.dart';

/// PrivilegeResponse
///
/// Properties:
/// * [systemObject]
/// * [privileges]
/// * [allowCreate]
/// * [allowRead]
/// * [allowUpdate]
/// * [allowDelete]
@BuiltValue()
abstract class PrivilegeResponse
    implements Built<PrivilegeResponse, PrivilegeResponseBuilder> {
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

  PrivilegeResponse._();

  factory PrivilegeResponse([void updates(PrivilegeResponseBuilder b)]) =
      _$PrivilegeResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PrivilegeResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PrivilegeResponse> get serializer =>
      _$PrivilegeResponseSerializer();
}

class _$PrivilegeResponseSerializer
    implements PrimitiveSerializer<PrivilegeResponse> {
  @override
  final Iterable<Type> types = const [PrivilegeResponse, _$PrivilegeResponse];

  @override
  final String wireName = r'PrivilegeResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PrivilegeResponse object, {
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
    PrivilegeResponse object, {
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
    required PrivilegeResponseBuilder result,
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
  PrivilegeResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PrivilegeResponseBuilder();
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
