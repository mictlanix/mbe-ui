//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/employee_response.dart';
import 'package:mbe_api_client/src/model/date.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'vehicle_operator_response.g.dart';

/// VehicleOperatorResponse
///
/// Properties:
/// * [vehicleOperatorId]
/// * [driver]
/// * [licenseType]
/// * [driverLicenseNumber]
/// * [issueDate]
/// * [expirationDate]
/// * [issuingLocation]
/// * [creationTime]
/// * [modificationTime]
/// * [creator]
/// * [updater]
/// * [active]
/// * [daysUntilExpiry]
@BuiltValue()
abstract class VehicleOperatorResponse
    implements Built<VehicleOperatorResponse, VehicleOperatorResponseBuilder> {
  @BuiltValueField(wireName: r'vehicle_operator_id')
  int get vehicleOperatorId;

  @BuiltValueField(wireName: r'driver')
  EmployeeResponse get driver;

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

  @BuiltValueField(wireName: r'creation_time')
  DateTime get creationTime;

  @BuiltValueField(wireName: r'modification_time')
  DateTime get modificationTime;

  @BuiltValueField(wireName: r'creator')
  EmployeeResponse get creator;

  @BuiltValueField(wireName: r'updater')
  EmployeeResponse get updater;

  @BuiltValueField(wireName: r'active')
  bool get active;

  @BuiltValueField(wireName: r'days_until_expiry')
  int? get daysUntilExpiry;

  VehicleOperatorResponse._();

  factory VehicleOperatorResponse([
    void updates(VehicleOperatorResponseBuilder b),
  ]) = _$VehicleOperatorResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(VehicleOperatorResponseBuilder b) =>
      b..daysUntilExpiry = 0;

  @BuiltValueSerializer(custom: true)
  static Serializer<VehicleOperatorResponse> get serializer =>
      _$VehicleOperatorResponseSerializer();
}

class _$VehicleOperatorResponseSerializer
    implements PrimitiveSerializer<VehicleOperatorResponse> {
  @override
  final Iterable<Type> types = const [
    VehicleOperatorResponse,
    _$VehicleOperatorResponse,
  ];

  @override
  final String wireName = r'VehicleOperatorResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    VehicleOperatorResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'vehicle_operator_id';
    yield serializers.serialize(
      object.vehicleOperatorId,
      specifiedType: const FullType(int),
    );
    yield r'driver';
    yield serializers.serialize(
      object.driver,
      specifiedType: const FullType(EmployeeResponse),
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
    yield r'creation_time';
    yield serializers.serialize(
      object.creationTime,
      specifiedType: const FullType(DateTime),
    );
    yield r'modification_time';
    yield serializers.serialize(
      object.modificationTime,
      specifiedType: const FullType(DateTime),
    );
    yield r'creator';
    yield serializers.serialize(
      object.creator,
      specifiedType: const FullType(EmployeeResponse),
    );
    yield r'updater';
    yield serializers.serialize(
      object.updater,
      specifiedType: const FullType(EmployeeResponse),
    );
    yield r'active';
    yield serializers.serialize(
      object.active,
      specifiedType: const FullType(bool),
    );
    if (object.daysUntilExpiry != null) {
      yield r'days_until_expiry';
      yield serializers.serialize(
        object.daysUntilExpiry,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    VehicleOperatorResponse object, {
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
    required VehicleOperatorResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'vehicle_operator_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.vehicleOperatorId = valueDes;
          break;
        case r'driver':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(EmployeeResponse),
                  )
                  as EmployeeResponse;
          result.driver.replace(valueDes);
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
        case r'creation_time':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )
                  as DateTime;
          result.creationTime = valueDes;
          break;
        case r'modification_time':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )
                  as DateTime;
          result.modificationTime = valueDes;
          break;
        case r'creator':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(EmployeeResponse),
                  )
                  as EmployeeResponse;
          result.creator.replace(valueDes);
          break;
        case r'updater':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(EmployeeResponse),
                  )
                  as EmployeeResponse;
          result.updater.replace(valueDes);
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
        case r'days_until_expiry':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.daysUntilExpiry = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  VehicleOperatorResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = VehicleOperatorResponseBuilder();
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
