//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/date.dart';
import 'package:mbe_api_client/src/model/entity_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'employee_response.g.dart';

/// EmployeeResponse
///
/// Properties:
/// * [employeeId]
/// * [firstName]
/// * [lastName]
/// * [nickname]
/// * [gender]
/// * [birthday]
/// * [taxpayerId]
/// * [salesPerson]
/// * [status]
/// * [personalId]
/// * [startJobDate]
/// * [enrollNumber]
/// * [comment]
@BuiltValue()
abstract class EmployeeResponse
    implements Built<EmployeeResponse, EmployeeResponseBuilder> {
  @BuiltValueField(wireName: r'employee_id')
  int get employeeId;

  @BuiltValueField(wireName: r'first_name')
  String get firstName;

  @BuiltValueField(wireName: r'last_name')
  String get lastName;

  @BuiltValueField(wireName: r'nickname')
  String get nickname;

  @BuiltValueField(wireName: r'gender')
  int get gender;

  @BuiltValueField(wireName: r'birthday')
  Date get birthday;

  @BuiltValueField(wireName: r'taxpayer_id')
  String? get taxpayerId;

  @BuiltValueField(wireName: r'sales_person')
  bool get salesPerson;

  @BuiltValueField(wireName: r'status')
  EntityStatus get status;
  // enum statusEnum {  0,  1,  2,  };

  @BuiltValueField(wireName: r'personal_id')
  String? get personalId;

  @BuiltValueField(wireName: r'start_job_date')
  Date get startJobDate;

  @BuiltValueField(wireName: r'enroll_number')
  int? get enrollNumber;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  EmployeeResponse._();

  factory EmployeeResponse([void updates(EmployeeResponseBuilder b)]) =
      _$EmployeeResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EmployeeResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<EmployeeResponse> get serializer =>
      _$EmployeeResponseSerializer();
}

class _$EmployeeResponseSerializer
    implements PrimitiveSerializer<EmployeeResponse> {
  @override
  final Iterable<Type> types = const [EmployeeResponse, _$EmployeeResponse];

  @override
  final String wireName = r'EmployeeResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EmployeeResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'employee_id';
    yield serializers.serialize(
      object.employeeId,
      specifiedType: const FullType(int),
    );
    yield r'first_name';
    yield serializers.serialize(
      object.firstName,
      specifiedType: const FullType(String),
    );
    yield r'last_name';
    yield serializers.serialize(
      object.lastName,
      specifiedType: const FullType(String),
    );
    yield r'nickname';
    yield serializers.serialize(
      object.nickname,
      specifiedType: const FullType(String),
    );
    yield r'gender';
    yield serializers.serialize(
      object.gender,
      specifiedType: const FullType(int),
    );
    yield r'birthday';
    yield serializers.serialize(
      object.birthday,
      specifiedType: const FullType(Date),
    );
    yield r'taxpayer_id';
    yield object.taxpayerId == null
        ? null
        : serializers.serialize(
            object.taxpayerId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'sales_person';
    yield serializers.serialize(
      object.salesPerson,
      specifiedType: const FullType(bool),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(EntityStatus),
    );
    yield r'personal_id';
    yield object.personalId == null
        ? null
        : serializers.serialize(
            object.personalId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'start_job_date';
    yield serializers.serialize(
      object.startJobDate,
      specifiedType: const FullType(Date),
    );
    yield r'enroll_number';
    yield object.enrollNumber == null
        ? null
        : serializers.serialize(
            object.enrollNumber,
            specifiedType: const FullType.nullable(int),
          );
    yield r'comment';
    yield object.comment == null
        ? null
        : serializers.serialize(
            object.comment,
            specifiedType: const FullType.nullable(String),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    EmployeeResponse object, {
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
    required EmployeeResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'employee_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.employeeId = valueDes;
          break;
        case r'first_name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.firstName = valueDes;
          break;
        case r'last_name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.lastName = valueDes;
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
        case r'gender':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.gender = valueDes;
          break;
        case r'birthday':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(Date),
                  )
                  as Date;
          result.birthday = valueDes;
          break;
        case r'taxpayer_id':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.taxpayerId = valueDes;
          break;
        case r'sales_person':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )
                  as bool;
          result.salesPerson = valueDes;
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
        case r'personal_id':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.personalId = valueDes;
          break;
        case r'start_job_date':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(Date),
                  )
                  as Date;
          result.startJobDate = valueDes;
          break;
        case r'enroll_number':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.enrollNumber = valueDes;
          break;
        case r'comment':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.comment = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  EmployeeResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EmployeeResponseBuilder();
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
