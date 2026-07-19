//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'vehicle_create.g.dart';

/// VehicleCreate
///
/// Properties:
/// * [licensePlate]
/// * [name]
/// * [nickname]
/// * [tonsCapacity]
/// * [active]
@BuiltValue()
abstract class VehicleCreate
    implements Built<VehicleCreate, VehicleCreateBuilder> {
  @BuiltValueField(wireName: r'license_plate')
  String get licensePlate;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'nickname')
  String get nickname;

  @BuiltValueField(wireName: r'tons_capacity')
  int get tonsCapacity;

  @BuiltValueField(wireName: r'active')
  bool? get active;

  VehicleCreate._();

  factory VehicleCreate([void updates(VehicleCreateBuilder b)]) =
      _$VehicleCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(VehicleCreateBuilder b) => b..active = true;

  @BuiltValueSerializer(custom: true)
  static Serializer<VehicleCreate> get serializer =>
      _$VehicleCreateSerializer();
}

class _$VehicleCreateSerializer implements PrimitiveSerializer<VehicleCreate> {
  @override
  final Iterable<Type> types = const [VehicleCreate, _$VehicleCreate];

  @override
  final String wireName = r'VehicleCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    VehicleCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'license_plate';
    yield serializers.serialize(
      object.licensePlate,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'nickname';
    yield serializers.serialize(
      object.nickname,
      specifiedType: const FullType(String),
    );
    yield r'tons_capacity';
    yield serializers.serialize(
      object.tonsCapacity,
      specifiedType: const FullType(int),
    );
    if (object.active != null) {
      yield r'active';
      yield serializers.serialize(
        object.active,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    VehicleCreate object, {
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
    required VehicleCreateBuilder result,
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
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.licensePlate = valueDes;
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
        case r'nickname':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.nickname = valueDes;
          break;
        case r'tons_capacity':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.tonsCapacity = valueDes;
          break;
        case r'active':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )
                  as bool;
          result.active = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  VehicleCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = VehicleCreateBuilder();
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
