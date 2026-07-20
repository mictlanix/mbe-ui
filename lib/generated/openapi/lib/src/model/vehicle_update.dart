//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/entity_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'vehicle_update.g.dart';

/// VehicleUpdate
///
/// Properties:
/// * [licensePlate]
/// * [name]
/// * [nickname]
/// * [tonsCapacity]
/// * [status]
@BuiltValue()
abstract class VehicleUpdate
    implements Built<VehicleUpdate, VehicleUpdateBuilder> {
  @BuiltValueField(wireName: r'license_plate')
  String? get licensePlate;

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'nickname')
  String? get nickname;

  @BuiltValueField(wireName: r'tons_capacity')
  int? get tonsCapacity;

  @BuiltValueField(wireName: r'status')
  EntityStatus? get status;
  // enum statusEnum {  0,  1,  2,  };

  VehicleUpdate._();

  factory VehicleUpdate([void updates(VehicleUpdateBuilder b)]) =
      _$VehicleUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(VehicleUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<VehicleUpdate> get serializer =>
      _$VehicleUpdateSerializer();
}

class _$VehicleUpdateSerializer implements PrimitiveSerializer<VehicleUpdate> {
  @override
  final Iterable<Type> types = const [VehicleUpdate, _$VehicleUpdate];

  @override
  final String wireName = r'VehicleUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    VehicleUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.licensePlate != null) {
      yield r'license_plate';
      yield serializers.serialize(
        object.licensePlate,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.nickname != null) {
      yield r'nickname';
      yield serializers.serialize(
        object.nickname,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.tonsCapacity != null) {
      yield r'tons_capacity';
      yield serializers.serialize(
        object.tonsCapacity,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType.nullable(EntityStatus),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    VehicleUpdate object, {
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
    required VehicleUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'license_plate':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.licensePlate = valueDes;
          break;
        case r'name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.name = valueDes;
          break;
        case r'nickname':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.nickname = valueDes;
          break;
        case r'tons_capacity':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.tonsCapacity = valueDes;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  VehicleUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = VehicleUpdateBuilder();
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
