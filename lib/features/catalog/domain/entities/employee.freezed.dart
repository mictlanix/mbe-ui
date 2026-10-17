// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'employee.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Employee {

 int get employeeId; String get firstName; String get lastName; String get nickname; Gender? get gender; DateTime get birthday; String? get taxpayerId; bool get salesPerson; EntityStatus get status; String? get personalId; DateTime get startJobDate; int? get enrollNumber; String? get comment;
/// Create a copy of Employee
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmployeeCopyWith<Employee> get copyWith => _$EmployeeCopyWithImpl<Employee>(this as Employee, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Employee;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Employee&&(identical(other.employeeId, _this.employeeId) || other.employeeId == _this.employeeId)&&(identical(other.firstName, _this.firstName) || other.firstName == _this.firstName)&&(identical(other.lastName, _this.lastName) || other.lastName == _this.lastName)&&(identical(other.nickname, _this.nickname) || other.nickname == _this.nickname)&&(identical(other.gender, _this.gender) || other.gender == _this.gender)&&(identical(other.birthday, _this.birthday) || other.birthday == _this.birthday)&&(identical(other.taxpayerId, _this.taxpayerId) || other.taxpayerId == _this.taxpayerId)&&(identical(other.salesPerson, _this.salesPerson) || other.salesPerson == _this.salesPerson)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.personalId, _this.personalId) || other.personalId == _this.personalId)&&(identical(other.startJobDate, _this.startJobDate) || other.startJobDate == _this.startJobDate)&&(identical(other.enrollNumber, _this.enrollNumber) || other.enrollNumber == _this.enrollNumber)&&(identical(other.comment, _this.comment) || other.comment == _this.comment));
}


@override
int get hashCode {
  final _this = this as Employee;
  return Object.hash(runtimeType,_this.employeeId,_this.firstName,_this.lastName,_this.nickname,_this.gender,_this.birthday,_this.taxpayerId,_this.salesPerson,_this.status,_this.personalId,_this.startJobDate,_this.enrollNumber,_this.comment);
}

@override
String toString() {
  final _this = this as Employee;
  return 'Employee(employeeId: ${_this.employeeId}, firstName: ${_this.firstName}, lastName: ${_this.lastName}, nickname: ${_this.nickname}, gender: ${_this.gender}, birthday: ${_this.birthday}, taxpayerId: ${_this.taxpayerId}, salesPerson: ${_this.salesPerson}, status: ${_this.status}, personalId: ${_this.personalId}, startJobDate: ${_this.startJobDate}, enrollNumber: ${_this.enrollNumber}, comment: ${_this.comment})';
}


}

/// @nodoc
abstract mixin class $EmployeeCopyWith<$Res>  {
  factory $EmployeeCopyWith(Employee value, $Res Function(Employee) _then) = _$EmployeeCopyWithImpl;
@useResult
$Res call({
 int employeeId, String firstName, String lastName, String nickname, Gender? gender, DateTime birthday, String? taxpayerId, bool salesPerson, EntityStatus status, String? personalId, DateTime startJobDate, int? enrollNumber, String? comment
});




}
/// @nodoc
class _$EmployeeCopyWithImpl<$Res>
    implements $EmployeeCopyWith<$Res> {
  _$EmployeeCopyWithImpl(this._self, this._then);

  final Employee _self;
  final $Res Function(Employee) _then;

/// Create a copy of Employee
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? employeeId = null,Object? firstName = null,Object? lastName = null,Object? nickname = null,Object? gender = freezed,Object? birthday = null,Object? taxpayerId = freezed,Object? salesPerson = null,Object? status = null,Object? personalId = freezed,Object? startJobDate = null,Object? enrollNumber = freezed,Object? comment = freezed,}) {
  return _then(Employee(
employeeId: null == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as int,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,nickname: null == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender?,birthday: null == birthday ? _self.birthday : birthday // ignore: cast_nullable_to_non_nullable
as DateTime,taxpayerId: freezed == taxpayerId ? _self.taxpayerId : taxpayerId // ignore: cast_nullable_to_non_nullable
as String?,salesPerson: null == salesPerson ? _self.salesPerson : salesPerson // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus,personalId: freezed == personalId ? _self.personalId : personalId // ignore: cast_nullable_to_non_nullable
as String?,startJobDate: null == startJobDate ? _self.startJobDate : startJobDate // ignore: cast_nullable_to_non_nullable
as DateTime,enrollNumber: freezed == enrollNumber ? _self.enrollNumber : enrollNumber // ignore: cast_nullable_to_non_nullable
as int?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Employee].
extension EmployeePatterns on Employee {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Employee value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Employee() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Employee value)  $default,){
final _that = this;
switch (_that) {
case _Employee():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Employee value)?  $default,){
final _that = this;
switch (_that) {
case _Employee() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int employeeId,  String firstName,  String lastName,  String nickname,  Gender? gender,  DateTime birthday,  String? taxpayerId,  bool salesPerson,  EntityStatus status,  String? personalId,  DateTime startJobDate,  int? enrollNumber,  String? comment)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Employee() when $default != null:
return $default(_that.employeeId,_that.firstName,_that.lastName,_that.nickname,_that.gender,_that.birthday,_that.taxpayerId,_that.salesPerson,_that.status,_that.personalId,_that.startJobDate,_that.enrollNumber,_that.comment);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int employeeId,  String firstName,  String lastName,  String nickname,  Gender? gender,  DateTime birthday,  String? taxpayerId,  bool salesPerson,  EntityStatus status,  String? personalId,  DateTime startJobDate,  int? enrollNumber,  String? comment)  $default,) {final _that = this;
switch (_that) {
case _Employee():
return $default(_that.employeeId,_that.firstName,_that.lastName,_that.nickname,_that.gender,_that.birthday,_that.taxpayerId,_that.salesPerson,_that.status,_that.personalId,_that.startJobDate,_that.enrollNumber,_that.comment);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int employeeId,  String firstName,  String lastName,  String nickname,  Gender? gender,  DateTime birthday,  String? taxpayerId,  bool salesPerson,  EntityStatus status,  String? personalId,  DateTime startJobDate,  int? enrollNumber,  String? comment)?  $default,) {final _that = this;
switch (_that) {
case _Employee() when $default != null:
return $default(_that.employeeId,_that.firstName,_that.lastName,_that.nickname,_that.gender,_that.birthday,_that.taxpayerId,_that.salesPerson,_that.status,_that.personalId,_that.startJobDate,_that.enrollNumber,_that.comment);case _:
  return null;

}
}

}

/// @nodoc


class _Employee implements Employee {
  const _Employee({required this.employeeId, required this.firstName, required this.lastName, required this.nickname, required this.gender, required this.birthday, this.taxpayerId, required this.salesPerson, required this.status, this.personalId, required this.startJobDate, this.enrollNumber, this.comment});
  

@override final  int employeeId;
@override final  String firstName;
@override final  String lastName;
@override final  String nickname;
@override final  Gender? gender;
@override final  DateTime birthday;
@override final  String? taxpayerId;
@override final  bool salesPerson;
@override final  EntityStatus status;
@override final  String? personalId;
@override final  DateTime startJobDate;
@override final  int? enrollNumber;
@override final  String? comment;

/// Create a copy of Employee
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmployeeCopyWith<_Employee> get copyWith => __$EmployeeCopyWithImpl<_Employee>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Employee&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.nickname, nickname) || other.nickname == nickname)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.birthday, birthday) || other.birthday == birthday)&&(identical(other.taxpayerId, taxpayerId) || other.taxpayerId == taxpayerId)&&(identical(other.salesPerson, salesPerson) || other.salesPerson == salesPerson)&&(identical(other.status, status) || other.status == status)&&(identical(other.personalId, personalId) || other.personalId == personalId)&&(identical(other.startJobDate, startJobDate) || other.startJobDate == startJobDate)&&(identical(other.enrollNumber, enrollNumber) || other.enrollNumber == enrollNumber)&&(identical(other.comment, comment) || other.comment == comment));
}


@override
int get hashCode {
    return Object.hash(runtimeType,employeeId,firstName,lastName,nickname,gender,birthday,taxpayerId,salesPerson,status,personalId,startJobDate,enrollNumber,comment);
}

@override
String toString() {
    return 'Employee(employeeId: $employeeId, firstName: $firstName, lastName: $lastName, nickname: $nickname, gender: $gender, birthday: $birthday, taxpayerId: $taxpayerId, salesPerson: $salesPerson, status: $status, personalId: $personalId, startJobDate: $startJobDate, enrollNumber: $enrollNumber, comment: $comment)';
}


}

/// @nodoc
abstract mixin class _$EmployeeCopyWith<$Res> implements $EmployeeCopyWith<$Res> {
  factory _$EmployeeCopyWith(_Employee value, $Res Function(_Employee) _then) = __$EmployeeCopyWithImpl;
@override @useResult
$Res call({
 int employeeId, String firstName, String lastName, String nickname, Gender? gender, DateTime birthday, String? taxpayerId, bool salesPerson, EntityStatus status, String? personalId, DateTime startJobDate, int? enrollNumber, String? comment
});




}
/// @nodoc
class __$EmployeeCopyWithImpl<$Res>
    implements _$EmployeeCopyWith<$Res> {
  __$EmployeeCopyWithImpl(this._self, this._then);

  final _Employee _self;
  final $Res Function(_Employee) _then;

/// Create a copy of Employee
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? employeeId = null,Object? firstName = null,Object? lastName = null,Object? nickname = null,Object? gender = freezed,Object? birthday = null,Object? taxpayerId = freezed,Object? salesPerson = null,Object? status = null,Object? personalId = freezed,Object? startJobDate = null,Object? enrollNumber = freezed,Object? comment = freezed,}) {
  return _then(_Employee(
employeeId: null == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as int,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,nickname: null == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender?,birthday: null == birthday ? _self.birthday : birthday // ignore: cast_nullable_to_non_nullable
as DateTime,taxpayerId: freezed == taxpayerId ? _self.taxpayerId : taxpayerId // ignore: cast_nullable_to_non_nullable
as String?,salesPerson: null == salesPerson ? _self.salesPerson : salesPerson // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus,personalId: freezed == personalId ? _self.personalId : personalId // ignore: cast_nullable_to_non_nullable
as String?,startJobDate: null == startJobDate ? _self.startJobDate : startJobDate // ignore: cast_nullable_to_non_nullable
as DateTime,enrollNumber: freezed == enrollNumber ? _self.enrollNumber : enrollNumber // ignore: cast_nullable_to_non_nullable
as int?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
