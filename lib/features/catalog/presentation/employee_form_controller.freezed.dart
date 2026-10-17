// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'employee_form_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EmployeeFormState {

 int? get employeeId; String get firstName; String get lastName; String get nickname; Gender? get gender; DateTime? get birthday; String get taxpayerId; bool get salesPerson; EntityStatus get status; String get personalId; DateTime? get startJobDate; String get enrollNumber; String get comment; bool get loading; bool get submitting; bool get saved; bool get deleted; String? get error; String? get errorDetail; Map<String, String> get fieldErrors;
/// Create a copy of EmployeeFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmployeeFormStateCopyWith<EmployeeFormState> get copyWith => _$EmployeeFormStateCopyWithImpl<EmployeeFormState>(this as EmployeeFormState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as EmployeeFormState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmployeeFormState&&(identical(other.employeeId, _this.employeeId) || other.employeeId == _this.employeeId)&&(identical(other.firstName, _this.firstName) || other.firstName == _this.firstName)&&(identical(other.lastName, _this.lastName) || other.lastName == _this.lastName)&&(identical(other.nickname, _this.nickname) || other.nickname == _this.nickname)&&(identical(other.gender, _this.gender) || other.gender == _this.gender)&&(identical(other.birthday, _this.birthday) || other.birthday == _this.birthday)&&(identical(other.taxpayerId, _this.taxpayerId) || other.taxpayerId == _this.taxpayerId)&&(identical(other.salesPerson, _this.salesPerson) || other.salesPerson == _this.salesPerson)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.personalId, _this.personalId) || other.personalId == _this.personalId)&&(identical(other.startJobDate, _this.startJobDate) || other.startJobDate == _this.startJobDate)&&(identical(other.enrollNumber, _this.enrollNumber) || other.enrollNumber == _this.enrollNumber)&&(identical(other.comment, _this.comment) || other.comment == _this.comment)&&(identical(other.loading, _this.loading) || other.loading == _this.loading)&&(identical(other.submitting, _this.submitting) || other.submitting == _this.submitting)&&(identical(other.saved, _this.saved) || other.saved == _this.saved)&&(identical(other.deleted, _this.deleted) || other.deleted == _this.deleted)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.errorDetail, _this.errorDetail) || other.errorDetail == _this.errorDetail)&&const DeepCollectionEquality().equals(other.fieldErrors, _this.fieldErrors));
}


@override
int get hashCode {
  final _this = this as EmployeeFormState;
  return Object.hashAll([runtimeType,_this.employeeId,_this.firstName,_this.lastName,_this.nickname,_this.gender,_this.birthday,_this.taxpayerId,_this.salesPerson,_this.status,_this.personalId,_this.startJobDate,_this.enrollNumber,_this.comment,_this.loading,_this.submitting,_this.saved,_this.deleted,_this.error,_this.errorDetail,const DeepCollectionEquality().hash(_this.fieldErrors)]);
}

@override
String toString() {
  final _this = this as EmployeeFormState;
  return 'EmployeeFormState(employeeId: ${_this.employeeId}, firstName: ${_this.firstName}, lastName: ${_this.lastName}, nickname: ${_this.nickname}, gender: ${_this.gender}, birthday: ${_this.birthday}, taxpayerId: ${_this.taxpayerId}, salesPerson: ${_this.salesPerson}, status: ${_this.status}, personalId: ${_this.personalId}, startJobDate: ${_this.startJobDate}, enrollNumber: ${_this.enrollNumber}, comment: ${_this.comment}, loading: ${_this.loading}, submitting: ${_this.submitting}, saved: ${_this.saved}, deleted: ${_this.deleted}, error: ${_this.error}, errorDetail: ${_this.errorDetail}, fieldErrors: ${_this.fieldErrors})';
}


}

/// @nodoc
abstract mixin class $EmployeeFormStateCopyWith<$Res>  {
  factory $EmployeeFormStateCopyWith(EmployeeFormState value, $Res Function(EmployeeFormState) _then) = _$EmployeeFormStateCopyWithImpl;
@useResult
$Res call({
 int? employeeId, String firstName, String lastName, String nickname, Gender? gender, DateTime? birthday, String taxpayerId, bool salesPerson, EntityStatus status, String personalId, DateTime? startJobDate, String enrollNumber, String comment, bool loading, bool submitting, bool saved, bool deleted, String? error, String? errorDetail, Map<String, String> fieldErrors
});




}
/// @nodoc
class _$EmployeeFormStateCopyWithImpl<$Res>
    implements $EmployeeFormStateCopyWith<$Res> {
  _$EmployeeFormStateCopyWithImpl(this._self, this._then);

  final EmployeeFormState _self;
  final $Res Function(EmployeeFormState) _then;

/// Create a copy of EmployeeFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? employeeId = freezed,Object? firstName = null,Object? lastName = null,Object? nickname = null,Object? gender = freezed,Object? birthday = freezed,Object? taxpayerId = null,Object? salesPerson = null,Object? status = null,Object? personalId = null,Object? startJobDate = freezed,Object? enrollNumber = null,Object? comment = null,Object? loading = null,Object? submitting = null,Object? saved = null,Object? deleted = null,Object? error = freezed,Object? errorDetail = freezed,Object? fieldErrors = null,}) {
  return _then(EmployeeFormState(
employeeId: freezed == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as int?,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,nickname: null == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender?,birthday: freezed == birthday ? _self.birthday : birthday // ignore: cast_nullable_to_non_nullable
as DateTime?,taxpayerId: null == taxpayerId ? _self.taxpayerId : taxpayerId // ignore: cast_nullable_to_non_nullable
as String,salesPerson: null == salesPerson ? _self.salesPerson : salesPerson // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus,personalId: null == personalId ? _self.personalId : personalId // ignore: cast_nullable_to_non_nullable
as String,startJobDate: freezed == startJobDate ? _self.startJobDate : startJobDate // ignore: cast_nullable_to_non_nullable
as DateTime?,enrollNumber: null == enrollNumber ? _self.enrollNumber : enrollNumber // ignore: cast_nullable_to_non_nullable
as String,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as bool,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,errorDetail: freezed == errorDetail ? _self.errorDetail : errorDetail // ignore: cast_nullable_to_non_nullable
as String?,fieldErrors: null == fieldErrors ? _self.fieldErrors : fieldErrors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

}


/// Adds pattern-matching-related methods to [EmployeeFormState].
extension EmployeeFormStatePatterns on EmployeeFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EmployeeFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EmployeeFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EmployeeFormState value)  $default,){
final _that = this;
switch (_that) {
case _EmployeeFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EmployeeFormState value)?  $default,){
final _that = this;
switch (_that) {
case _EmployeeFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? employeeId,  String firstName,  String lastName,  String nickname,  Gender? gender,  DateTime? birthday,  String taxpayerId,  bool salesPerson,  EntityStatus status,  String personalId,  DateTime? startJobDate,  String enrollNumber,  String comment,  bool loading,  bool submitting,  bool saved,  bool deleted,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EmployeeFormState() when $default != null:
return $default(_that.employeeId,_that.firstName,_that.lastName,_that.nickname,_that.gender,_that.birthday,_that.taxpayerId,_that.salesPerson,_that.status,_that.personalId,_that.startJobDate,_that.enrollNumber,_that.comment,_that.loading,_that.submitting,_that.saved,_that.deleted,_that.error,_that.errorDetail,_that.fieldErrors);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? employeeId,  String firstName,  String lastName,  String nickname,  Gender? gender,  DateTime? birthday,  String taxpayerId,  bool salesPerson,  EntityStatus status,  String personalId,  DateTime? startJobDate,  String enrollNumber,  String comment,  bool loading,  bool submitting,  bool saved,  bool deleted,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)  $default,) {final _that = this;
switch (_that) {
case _EmployeeFormState():
return $default(_that.employeeId,_that.firstName,_that.lastName,_that.nickname,_that.gender,_that.birthday,_that.taxpayerId,_that.salesPerson,_that.status,_that.personalId,_that.startJobDate,_that.enrollNumber,_that.comment,_that.loading,_that.submitting,_that.saved,_that.deleted,_that.error,_that.errorDetail,_that.fieldErrors);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? employeeId,  String firstName,  String lastName,  String nickname,  Gender? gender,  DateTime? birthday,  String taxpayerId,  bool salesPerson,  EntityStatus status,  String personalId,  DateTime? startJobDate,  String enrollNumber,  String comment,  bool loading,  bool submitting,  bool saved,  bool deleted,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)?  $default,) {final _that = this;
switch (_that) {
case _EmployeeFormState() when $default != null:
return $default(_that.employeeId,_that.firstName,_that.lastName,_that.nickname,_that.gender,_that.birthday,_that.taxpayerId,_that.salesPerson,_that.status,_that.personalId,_that.startJobDate,_that.enrollNumber,_that.comment,_that.loading,_that.submitting,_that.saved,_that.deleted,_that.error,_that.errorDetail,_that.fieldErrors);case _:
  return null;

}
}

}

/// @nodoc


class _EmployeeFormState implements EmployeeFormState {
  const _EmployeeFormState({this.employeeId, this.firstName = '', this.lastName = '', this.nickname = '', this.gender, this.birthday, this.taxpayerId = '', this.salesPerson = false, this.status = EntityStatus.active, this.personalId = '', this.startJobDate, this.enrollNumber = '', this.comment = '', this.loading = false, this.submitting = false, this.saved = false, this.deleted = false, this.error, this.errorDetail,  Map<String, String> fieldErrors = const <String, String>{}}): _fieldErrors = fieldErrors;
  

@override final  int? employeeId;
@override@JsonKey() final  String firstName;
@override@JsonKey() final  String lastName;
@override@JsonKey() final  String nickname;
@override final  Gender? gender;
@override final  DateTime? birthday;
@override@JsonKey() final  String taxpayerId;
@override@JsonKey() final  bool salesPerson;
@override@JsonKey() final  EntityStatus status;
@override@JsonKey() final  String personalId;
@override final  DateTime? startJobDate;
@override@JsonKey() final  String enrollNumber;
@override@JsonKey() final  String comment;
@override@JsonKey() final  bool loading;
@override@JsonKey() final  bool submitting;
@override@JsonKey() final  bool saved;
@override@JsonKey() final  bool deleted;
@override final  String? error;
@override final  String? errorDetail;
 final  Map<String, String> _fieldErrors;
@override@JsonKey() Map<String, String> get fieldErrors {
  if (_fieldErrors is EqualUnmodifiableMapView) return _fieldErrors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_fieldErrors);
}


/// Create a copy of EmployeeFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmployeeFormStateCopyWith<_EmployeeFormState> get copyWith => __$EmployeeFormStateCopyWithImpl<_EmployeeFormState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmployeeFormState&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.nickname, nickname) || other.nickname == nickname)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.birthday, birthday) || other.birthday == birthday)&&(identical(other.taxpayerId, taxpayerId) || other.taxpayerId == taxpayerId)&&(identical(other.salesPerson, salesPerson) || other.salesPerson == salesPerson)&&(identical(other.status, status) || other.status == status)&&(identical(other.personalId, personalId) || other.personalId == personalId)&&(identical(other.startJobDate, startJobDate) || other.startJobDate == startJobDate)&&(identical(other.enrollNumber, enrollNumber) || other.enrollNumber == enrollNumber)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.saved, saved) || other.saved == saved)&&(identical(other.deleted, deleted) || other.deleted == deleted)&&(identical(other.error, error) || other.error == error)&&(identical(other.errorDetail, errorDetail) || other.errorDetail == errorDetail)&&const DeepCollectionEquality().equals(other.fieldErrors, _fieldErrors));
}


@override
int get hashCode {
    return Object.hashAll([runtimeType,employeeId,firstName,lastName,nickname,gender,birthday,taxpayerId,salesPerson,status,personalId,startJobDate,enrollNumber,comment,loading,submitting,saved,deleted,error,errorDetail,const DeepCollectionEquality().hash(_fieldErrors)]);
}

@override
String toString() {
    return 'EmployeeFormState(employeeId: $employeeId, firstName: $firstName, lastName: $lastName, nickname: $nickname, gender: $gender, birthday: $birthday, taxpayerId: $taxpayerId, salesPerson: $salesPerson, status: $status, personalId: $personalId, startJobDate: $startJobDate, enrollNumber: $enrollNumber, comment: $comment, loading: $loading, submitting: $submitting, saved: $saved, deleted: $deleted, error: $error, errorDetail: $errorDetail, fieldErrors: $fieldErrors)';
}


}

/// @nodoc
abstract mixin class _$EmployeeFormStateCopyWith<$Res> implements $EmployeeFormStateCopyWith<$Res> {
  factory _$EmployeeFormStateCopyWith(_EmployeeFormState value, $Res Function(_EmployeeFormState) _then) = __$EmployeeFormStateCopyWithImpl;
@override @useResult
$Res call({
 int? employeeId, String firstName, String lastName, String nickname, Gender? gender, DateTime? birthday, String taxpayerId, bool salesPerson, EntityStatus status, String personalId, DateTime? startJobDate, String enrollNumber, String comment, bool loading, bool submitting, bool saved, bool deleted, String? error, String? errorDetail, Map<String, String> fieldErrors
});




}
/// @nodoc
class __$EmployeeFormStateCopyWithImpl<$Res>
    implements _$EmployeeFormStateCopyWith<$Res> {
  __$EmployeeFormStateCopyWithImpl(this._self, this._then);

  final _EmployeeFormState _self;
  final $Res Function(_EmployeeFormState) _then;

/// Create a copy of EmployeeFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? employeeId = freezed,Object? firstName = null,Object? lastName = null,Object? nickname = null,Object? gender = freezed,Object? birthday = freezed,Object? taxpayerId = null,Object? salesPerson = null,Object? status = null,Object? personalId = null,Object? startJobDate = freezed,Object? enrollNumber = null,Object? comment = null,Object? loading = null,Object? submitting = null,Object? saved = null,Object? deleted = null,Object? error = freezed,Object? errorDetail = freezed,Object? fieldErrors = null,}) {
  return _then(_EmployeeFormState(
employeeId: freezed == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as int?,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,nickname: null == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender?,birthday: freezed == birthday ? _self.birthday : birthday // ignore: cast_nullable_to_non_nullable
as DateTime?,taxpayerId: null == taxpayerId ? _self.taxpayerId : taxpayerId // ignore: cast_nullable_to_non_nullable
as String,salesPerson: null == salesPerson ? _self.salesPerson : salesPerson // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus,personalId: null == personalId ? _self.personalId : personalId // ignore: cast_nullable_to_non_nullable
as String,startJobDate: freezed == startJobDate ? _self.startJobDate : startJobDate // ignore: cast_nullable_to_non_nullable
as DateTime?,enrollNumber: null == enrollNumber ? _self.enrollNumber : enrollNumber // ignore: cast_nullable_to_non_nullable
as String,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as bool,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,errorDetail: freezed == errorDetail ? _self.errorDetail : errorDetail // ignore: cast_nullable_to_non_nullable
as String?,fieldErrors: null == fieldErrors ? _self._fieldErrors : fieldErrors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}

// dart format on
