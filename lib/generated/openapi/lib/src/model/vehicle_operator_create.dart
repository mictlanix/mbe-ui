//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/date.dart';
import 'package:mbe_api_client/src/model/entity_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'vehicle_operator_create.g.dart';

/// VehicleOperatorCreate
///
/// Properties:
/// * [driver]
/// * [licenseType]
/// * [driverLicenseNumber]
/// * [issueDate]
/// * [expirationDate]
/// * [issuingLocation]
/// * [status]
@BuiltValue()
abstract class VehicleOperatorCreate
    implements Built<VehicleOperatorCreate, VehicleOperatorCreateBuilder> {
  @BuiltValueField(wireName: r'driver')
  int get driver;

  @BuiltValueField(wireName: r'license_type')
  String get licenseType;

  @BuiltValueField(wireName: r'driver_license_number')
  String get driverLicenseNumber;

  @BuiltValueField(wireName: r'issue_date')
  Date get issueDate;

  @BuiltValueField(wireName: r'expiration_date')
  Date get expirationDate;

  @BuiltValueField(wireName: r'issuing_location')
  String get issuingLocation;

  @BuiltValueField(wireName: r'status')
  EntityStatus? get status;
  // enum statusEnum {  0,  1,  2,  };

  VehicleOperatorCreate._();

  factory VehicleOperatorCreate([
    void updates(VehicleOperatorCreateBuilder b),
  ]) = _$VehicleOperatorCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(VehicleOperatorCreateBuilder b) =>
      b..status = EntityStatus.number0;

  @BuiltValueSerializer(custom: true)
  static Serializer<VehicleOperatorCreate> get serializer =>
      _$VehicleOperatorCreateSerializer();
}

class _$VehicleOperatorCreateSerializer
    implements PrimitiveSerializer<VehicleOperatorCreate> {
  @override
  final Iterable<Type> types = const [
    VehicleOperatorCreate,
    _$VehicleOperatorCreate,
  ];

  @override
  final String wireName = r'VehicleOperatorCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    VehicleOperatorCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'driver';
    yield serializers.serialize(
      object.driver,
      specifiedType: const FullType(int),
    );
    yield r'license_type';
    yield serializers.serialize(
      object.licenseType,
      specifiedType: const FullType(String),
    );
    yield r'driver_license_number';
    yield serializers.serialize(
      object.driverLicenseNumber,
      specifiedType: const FullType(String),
    );
    yield r'issue_date';
    yield serializers.serialize(
      object.issueDate,
      specifiedType: const FullType(Date),
    );
    yield r'expiration_date';
    yield serializers.serialize(
      object.expirationDate,
      specifiedType: const FullType(Date),
    );
    yield r'issuing_location';
    yield serializers.serialize(
      object.issuingLocation,
      specifiedType: const FullType(String),
    );
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(EntityStatus),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    VehicleOperatorCreate object, {
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
    required VehicleOperatorCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'driver':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.driver = valueDes;
          break;
        case r'license_type':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.licenseType = valueDes;
          break;
        case r'driver_license_number':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.driverLicenseNumber = valueDes;
          break;
        case r'issue_date':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(Date),
                  )
                  as Date;
          result.issueDate = valueDes;
          break;
        case r'expiration_date':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(Date),
                  )
                  as Date;
          result.expirationDate = valueDes;
          break;
        case r'issuing_location':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.issuingLocation = valueDes;
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
  VehicleOperatorCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = VehicleOperatorCreateBuilder();
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
