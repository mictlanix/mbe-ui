//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/date.dart';
import 'package:mbe_api_client/src/model/entity_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'employee_update.g.dart';

/// EmployeeUpdate
///
/// Properties:
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
abstract class EmployeeUpdate
    implements Built<EmployeeUpdate, EmployeeUpdateBuilder> {
  @BuiltValueField(wireName: r'first_name')
  String? get firstName;

  @BuiltValueField(wireName: r'last_name')
  String? get lastName;

  @BuiltValueField(wireName: r'nickname')
  String? get nickname;

  @BuiltValueField(wireName: r'gender')
  int? get gender;

  @BuiltValueField(wireName: r'birthday')
  Date? get birthday;

  @BuiltValueField(wireName: r'taxpayer_id')
  String? get taxpayerId;

  @BuiltValueField(wireName: r'sales_person')
  bool? get salesPerson;

  @BuiltValueField(wireName: r'status')
  EntityStatus? get status;
  // enum statusEnum {  0,  1,  2,  };

  @BuiltValueField(wireName: r'personal_id')
  String? get personalId;

  @BuiltValueField(wireName: r'start_job_date')
  Date? get startJobDate;

  @BuiltValueField(wireName: r'enroll_number')
  int? get enrollNumber;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  EmployeeUpdate._();

  factory EmployeeUpdate([void updates(EmployeeUpdateBuilder b)]) =
      _$EmployeeUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EmployeeUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<EmployeeUpdate> get serializer =>
      _$EmployeeUpdateSerializer();
}

class _$EmployeeUpdateSerializer
    implements PrimitiveSerializer<EmployeeUpdate> {
  @override
  final Iterable<Type> types = const [EmployeeUpdate, _$EmployeeUpdate];

  @override
  final String wireName = r'EmployeeUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EmployeeUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.firstName != null) {
      yield r'first_name';
      yield serializers.serialize(
        object.firstName,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.lastName != null) {
      yield r'last_name';
      yield serializers.serialize(
        object.lastName,
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
    if (object.gender != null) {
      yield r'gender';
      yield serializers.serialize(
        object.gender,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.birthday != null) {
      yield r'birthday';
      yield serializers.serialize(
        object.birthday,
        specifiedType: const FullType.nullable(Date),
      );
    }
    if (object.taxpayerId != null) {
      yield r'taxpayer_id';
      yield serializers.serialize(
        object.taxpayerId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.salesPerson != null) {
      yield r'sales_person';
      yield serializers.serialize(
        object.salesPerson,
        specifiedType: const FullType.nullable(bool),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType.nullable(EntityStatus),
      );
    }
    if (object.personalId != null) {
      yield r'personal_id';
      yield serializers.serialize(
        object.personalId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.startJobDate != null) {
      yield r'start_job_date';
      yield serializers.serialize(
        object.startJobDate,
        specifiedType: const FullType.nullable(Date),
      );
    }
    if (object.enrollNumber != null) {
      yield r'enroll_number';
      yield serializers.serialize(
        object.enrollNumber,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.comment != null) {
      yield r'comment';
      yield serializers.serialize(
        object.comment,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    EmployeeUpdate object, {
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
    required EmployeeUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'first_name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.firstName = valueDes;
          break;
        case r'last_name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.lastName = valueDes;
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
        case r'gender':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.gender = valueDes;
          break;
        case r'birthday':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(Date),
                  )
                  as Date?;
          if (valueDes == null) continue;
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
                    specifiedType: const FullType.nullable(bool),
                  )
                  as bool?;
          if (valueDes == null) continue;
          result.salesPerson = valueDes;
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
                    specifiedType: const FullType.nullable(Date),
                  )
                  as Date?;
          if (valueDes == null) continue;
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
  EmployeeUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EmployeeUpdateBuilder();
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
