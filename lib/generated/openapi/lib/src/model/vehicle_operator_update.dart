//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/date.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'vehicle_operator_update.g.dart';

/// VehicleOperatorUpdate
///
/// Properties:
/// * [driver] 
/// * [licenseType] 
/// * [driverLicenseNumber] 
/// * [issueDate] 
/// * [expirationDate] 
/// * [issuingLocation] 
/// * [active] 
@BuiltValue()
abstract class VehicleOperatorUpdate implements Built<VehicleOperatorUpdate, VehicleOperatorUpdateBuilder> {
  @BuiltValueField(wireName: r'driver')
  int? get driver;

  @BuiltValueField(wireName: r'license_type')
  String? get licenseType;

  @BuiltValueField(wireName: r'driver_license_number')
  String? get driverLicenseNumber;

  @BuiltValueField(wireName: r'issue_date')
  Date? get issueDate;

  @BuiltValueField(wireName: r'expiration_date')
  Date? get expirationDate;

  @BuiltValueField(wireName: r'issuing_location')
  String? get issuingLocation;

  @BuiltValueField(wireName: r'active')
  bool? get active;

  VehicleOperatorUpdate._();

  factory VehicleOperatorUpdate([void updates(VehicleOperatorUpdateBuilder b)]) = _$VehicleOperatorUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(VehicleOperatorUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<VehicleOperatorUpdate> get serializer => _$VehicleOperatorUpdateSerializer();
}

class _$VehicleOperatorUpdateSerializer implements PrimitiveSerializer<VehicleOperatorUpdate> {
  @override
  final Iterable<Type> types = const [VehicleOperatorUpdate, _$VehicleOperatorUpdate];

  @override
  final String wireName = r'VehicleOperatorUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    VehicleOperatorUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.driver != null) {
      yield r'driver';
      yield serializers.serialize(
        object.driver,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.licenseType != null) {
      yield r'license_type';
      yield serializers.serialize(
        object.licenseType,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.driverLicenseNumber != null) {
      yield r'driver_license_number';
      yield serializers.serialize(
        object.driverLicenseNumber,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.issueDate != null) {
      yield r'issue_date';
      yield serializers.serialize(
        object.issueDate,
        specifiedType: const FullType.nullable(Date),
      );
    }
    if (object.expirationDate != null) {
      yield r'expiration_date';
      yield serializers.serialize(
        object.expirationDate,
        specifiedType: const FullType.nullable(Date),
      );
    }
    if (object.issuingLocation != null) {
      yield r'issuing_location';
      yield serializers.serialize(
        object.issuingLocation,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.active != null) {
      yield r'active';
      yield serializers.serialize(
        object.active,
        specifiedType: const FullType.nullable(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    VehicleOperatorUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required VehicleOperatorUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'driver':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.driver = valueDes;
          break;
        case r'license_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.licenseType = valueDes;
          break;
        case r'driver_license_number':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.driverLicenseNumber = valueDes;
          break;
        case r'issue_date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(Date),
          ) as Date?;
          if (valueDes == null) continue;
          result.issueDate = valueDes;
          break;
        case r'expiration_date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(Date),
          ) as Date?;
          if (valueDes == null) continue;
          result.expirationDate = valueDes;
          break;
        case r'issuing_location':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.issuingLocation = valueDes;
          break;
        case r'active':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
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
  VehicleOperatorUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = VehicleOperatorUpdateBuilder();
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

