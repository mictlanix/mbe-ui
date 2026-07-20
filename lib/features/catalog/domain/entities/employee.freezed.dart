// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'employee.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Employee {
  int get employeeId => throw _privateConstructorUsedError;
  String get firstName => throw _privateConstructorUsedError;
  String get lastName => throw _privateConstructorUsedError;
  String get nickname => throw _privateConstructorUsedError;
  Gender? get gender => throw _privateConstructorUsedError;
  DateTime get birthday => throw _privateConstructorUsedError;
  String? get taxpayerId => throw _privateConstructorUsedError;
  bool get salesPerson => throw _privateConstructorUsedError;
  EntityStatus get status => throw _privateConstructorUsedError;
  String? get personalId => throw _privateConstructorUsedError;
  DateTime get startJobDate => throw _privateConstructorUsedError;
  int? get enrollNumber => throw _privateConstructorUsedError;
  String? get comment => throw _privateConstructorUsedError;

  /// Create a copy of Employee
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EmployeeCopyWith<Employee> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EmployeeCopyWith<$Res> {
  factory $EmployeeCopyWith(Employee value, $Res Function(Employee) then) =
      _$EmployeeCopyWithImpl<$Res, Employee>;
  @useResult
  $Res call({
    int employeeId,
    String firstName,
    String lastName,
    String nickname,
    Gender? gender,
    DateTime birthday,
    String? taxpayerId,
    bool salesPerson,
    EntityStatus status,
    String? personalId,
    DateTime startJobDate,
    int? enrollNumber,
    String? comment,
  });
}

/// @nodoc
class _$EmployeeCopyWithImpl<$Res, $Val extends Employee>
    implements $EmployeeCopyWith<$Res> {
  _$EmployeeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Employee
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? employeeId = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? nickname = null,
    Object? gender = freezed,
    Object? birthday = null,
    Object? taxpayerId = freezed,
    Object? salesPerson = null,
    Object? status = null,
    Object? personalId = freezed,
    Object? startJobDate = null,
    Object? enrollNumber = freezed,
    Object? comment = freezed,
  }) {
    return _then(
      _value.copyWith(
            employeeId: null == employeeId
                ? _value.employeeId
                : employeeId // ignore: cast_nullable_to_non_nullable
                      as int,
            firstName: null == firstName
                ? _value.firstName
                : firstName // ignore: cast_nullable_to_non_nullable
                      as String,
            lastName: null == lastName
                ? _value.lastName
                : lastName // ignore: cast_nullable_to_non_nullable
                      as String,
            nickname: null == nickname
                ? _value.nickname
                : nickname // ignore: cast_nullable_to_non_nullable
                      as String,
            gender: freezed == gender
                ? _value.gender
                : gender // ignore: cast_nullable_to_non_nullable
                      as Gender?,
            birthday: null == birthday
                ? _value.birthday
                : birthday // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            taxpayerId: freezed == taxpayerId
                ? _value.taxpayerId
                : taxpayerId // ignore: cast_nullable_to_non_nullable
                      as String?,
            salesPerson: null == salesPerson
                ? _value.salesPerson
                : salesPerson // ignore: cast_nullable_to_non_nullable
                      as bool,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as EntityStatus,
            personalId: freezed == personalId
                ? _value.personalId
                : personalId // ignore: cast_nullable_to_non_nullable
                      as String?,
            startJobDate: null == startJobDate
                ? _value.startJobDate
                : startJobDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            enrollNumber: freezed == enrollNumber
                ? _value.enrollNumber
                : enrollNumber // ignore: cast_nullable_to_non_nullable
                      as int?,
            comment: freezed == comment
                ? _value.comment
                : comment // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EmployeeImplCopyWith<$Res>
    implements $EmployeeCopyWith<$Res> {
  factory _$$EmployeeImplCopyWith(
    _$EmployeeImpl value,
    $Res Function(_$EmployeeImpl) then,
  ) = __$$EmployeeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int employeeId,
    String firstName,
    String lastName,
    String nickname,
    Gender? gender,
    DateTime birthday,
    String? taxpayerId,
    bool salesPerson,
    EntityStatus status,
    String? personalId,
    DateTime startJobDate,
    int? enrollNumber,
    String? comment,
  });
}

/// @nodoc
class __$$EmployeeImplCopyWithImpl<$Res>
    extends _$EmployeeCopyWithImpl<$Res, _$EmployeeImpl>
    implements _$$EmployeeImplCopyWith<$Res> {
  __$$EmployeeImplCopyWithImpl(
    _$EmployeeImpl _value,
    $Res Function(_$EmployeeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Employee
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? employeeId = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? nickname = null,
    Object? gender = freezed,
    Object? birthday = null,
    Object? taxpayerId = freezed,
    Object? salesPerson = null,
    Object? status = null,
    Object? personalId = freezed,
    Object? startJobDate = null,
    Object? enrollNumber = freezed,
    Object? comment = freezed,
  }) {
    return _then(
      _$EmployeeImpl(
        employeeId: null == employeeId
            ? _value.employeeId
            : employeeId // ignore: cast_nullable_to_non_nullable
                  as int,
        firstName: null == firstName
            ? _value.firstName
            : firstName // ignore: cast_nullable_to_non_nullable
                  as String,
        lastName: null == lastName
            ? _value.lastName
            : lastName // ignore: cast_nullable_to_non_nullable
                  as String,
        nickname: null == nickname
            ? _value.nickname
            : nickname // ignore: cast_nullable_to_non_nullable
                  as String,
        gender: freezed == gender
            ? _value.gender
            : gender // ignore: cast_nullable_to_non_nullable
                  as Gender?,
        birthday: null == birthday
            ? _value.birthday
            : birthday // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        taxpayerId: freezed == taxpayerId
            ? _value.taxpayerId
            : taxpayerId // ignore: cast_nullable_to_non_nullable
                  as String?,
        salesPerson: null == salesPerson
            ? _value.salesPerson
            : salesPerson // ignore: cast_nullable_to_non_nullable
                  as bool,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as EntityStatus,
        personalId: freezed == personalId
            ? _value.personalId
            : personalId // ignore: cast_nullable_to_non_nullable
                  as String?,
        startJobDate: null == startJobDate
            ? _value.startJobDate
            : startJobDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        enrollNumber: freezed == enrollNumber
            ? _value.enrollNumber
            : enrollNumber // ignore: cast_nullable_to_non_nullable
                  as int?,
        comment: freezed == comment
            ? _value.comment
            : comment // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$EmployeeImpl implements _Employee {
  const _$EmployeeImpl({
    required this.employeeId,
    required this.firstName,
    required this.lastName,
    required this.nickname,
    required this.gender,
    required this.birthday,
    this.taxpayerId,
    required this.salesPerson,
    required this.status,
    this.personalId,
    required this.startJobDate,
    this.enrollNumber,
    this.comment,
  });

  @override
  final int employeeId;
  @override
  final String firstName;
  @override
  final String lastName;
  @override
  final String nickname;
  @override
  final Gender? gender;
  @override
  final DateTime birthday;
  @override
  final String? taxpayerId;
  @override
  final bool salesPerson;
  @override
  final EntityStatus status;
  @override
  final String? personalId;
  @override
  final DateTime startJobDate;
  @override
  final int? enrollNumber;
  @override
  final String? comment;

  @override
  String toString() {
    return 'Employee(employeeId: $employeeId, firstName: $firstName, lastName: $lastName, nickname: $nickname, gender: $gender, birthday: $birthday, taxpayerId: $taxpayerId, salesPerson: $salesPerson, status: $status, personalId: $personalId, startJobDate: $startJobDate, enrollNumber: $enrollNumber, comment: $comment)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EmployeeImpl &&
            (identical(other.employeeId, employeeId) ||
                other.employeeId == employeeId) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.birthday, birthday) ||
                other.birthday == birthday) &&
            (identical(other.taxpayerId, taxpayerId) ||
                other.taxpayerId == taxpayerId) &&
            (identical(other.salesPerson, salesPerson) ||
                other.salesPerson == salesPerson) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.personalId, personalId) ||
                other.personalId == personalId) &&
            (identical(other.startJobDate, startJobDate) ||
                other.startJobDate == startJobDate) &&
            (identical(other.enrollNumber, enrollNumber) ||
                other.enrollNumber == enrollNumber) &&
            (identical(other.comment, comment) || other.comment == comment));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    employeeId,
    firstName,
    lastName,
    nickname,
    gender,
    birthday,
    taxpayerId,
    salesPerson,
    status,
    personalId,
    startJobDate,
    enrollNumber,
    comment,
  );

  /// Create a copy of Employee
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EmployeeImplCopyWith<_$EmployeeImpl> get copyWith =>
      __$$EmployeeImplCopyWithImpl<_$EmployeeImpl>(this, _$identity);
}

abstract class _Employee implements Employee {
  const factory _Employee({
    required final int employeeId,
    required final String firstName,
    required final String lastName,
    required final String nickname,
    required final Gender? gender,
    required final DateTime birthday,
    final String? taxpayerId,
    required final bool salesPerson,
    required final EntityStatus status,
    final String? personalId,
    required final DateTime startJobDate,
    final int? enrollNumber,
    final String? comment,
  }) = _$EmployeeImpl;

  @override
  int get employeeId;
  @override
  String get firstName;
  @override
  String get lastName;
  @override
  String get nickname;
  @override
  Gender? get gender;
  @override
  DateTime get birthday;
  @override
  String? get taxpayerId;
  @override
  bool get salesPerson;
  @override
  EntityStatus get status;
  @override
  String? get personalId;
  @override
  DateTime get startJobDate;
  @override
  int? get enrollNumber;
  @override
  String? get comment;

  /// Create a copy of Employee
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EmployeeImplCopyWith<_$EmployeeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
