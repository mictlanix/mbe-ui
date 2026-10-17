// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vehicle_form_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VehicleFormState {

 int? get vehicleId; String get licensePlate; String get name; String get nickname; String get tonsCapacity; EntityStatus get status; bool get loading; bool get submitting; bool get saved; bool get deleted; String? get error; String? get errorDetail; Map<String, String> get fieldErrors;
/// Create a copy of VehicleFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VehicleFormStateCopyWith<VehicleFormState> get copyWith => _$VehicleFormStateCopyWithImpl<VehicleFormState>(this as VehicleFormState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as VehicleFormState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VehicleFormState&&(identical(other.vehicleId, _this.vehicleId) || other.vehicleId == _this.vehicleId)&&(identical(other.licensePlate, _this.licensePlate) || other.licensePlate == _this.licensePlate)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.nickname, _this.nickname) || other.nickname == _this.nickname)&&(identical(other.tonsCapacity, _this.tonsCapacity) || other.tonsCapacity == _this.tonsCapacity)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.loading, _this.loading) || other.loading == _this.loading)&&(identical(other.submitting, _this.submitting) || other.submitting == _this.submitting)&&(identical(other.saved, _this.saved) || other.saved == _this.saved)&&(identical(other.deleted, _this.deleted) || other.deleted == _this.deleted)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.errorDetail, _this.errorDetail) || other.errorDetail == _this.errorDetail)&&const DeepCollectionEquality().equals(other.fieldErrors, _this.fieldErrors));
}


@override
int get hashCode {
  final _this = this as VehicleFormState;
  return Object.hash(runtimeType,_this.vehicleId,_this.licensePlate,_this.name,_this.nickname,_this.tonsCapacity,_this.status,_this.loading,_this.submitting,_this.saved,_this.deleted,_this.error,_this.errorDetail,const DeepCollectionEquality().hash(_this.fieldErrors));
}

@override
String toString() {
  final _this = this as VehicleFormState;
  return 'VehicleFormState(vehicleId: ${_this.vehicleId}, licensePlate: ${_this.licensePlate}, name: ${_this.name}, nickname: ${_this.nickname}, tonsCapacity: ${_this.tonsCapacity}, status: ${_this.status}, loading: ${_this.loading}, submitting: ${_this.submitting}, saved: ${_this.saved}, deleted: ${_this.deleted}, error: ${_this.error}, errorDetail: ${_this.errorDetail}, fieldErrors: ${_this.fieldErrors})';
}


}

/// @nodoc
abstract mixin class $VehicleFormStateCopyWith<$Res>  {
  factory $VehicleFormStateCopyWith(VehicleFormState value, $Res Function(VehicleFormState) _then) = _$VehicleFormStateCopyWithImpl;
@useResult
$Res call({
 int? vehicleId, String licensePlate, String name, String nickname, String tonsCapacity, EntityStatus status, bool loading, bool submitting, bool saved, bool deleted, String? error, String? errorDetail, Map<String, String> fieldErrors
});




}
/// @nodoc
class _$VehicleFormStateCopyWithImpl<$Res>
    implements $VehicleFormStateCopyWith<$Res> {
  _$VehicleFormStateCopyWithImpl(this._self, this._then);

  final VehicleFormState _self;
  final $Res Function(VehicleFormState) _then;

/// Create a copy of VehicleFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? vehicleId = freezed,Object? licensePlate = null,Object? name = null,Object? nickname = null,Object? tonsCapacity = null,Object? status = null,Object? loading = null,Object? submitting = null,Object? saved = null,Object? deleted = null,Object? error = freezed,Object? errorDetail = freezed,Object? fieldErrors = null,}) {
  return _then(VehicleFormState(
vehicleId: freezed == vehicleId ? _self.vehicleId : vehicleId // ignore: cast_nullable_to_non_nullable
as int?,licensePlate: null == licensePlate ? _self.licensePlate : licensePlate // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,nickname: null == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String,tonsCapacity: null == tonsCapacity ? _self.tonsCapacity : tonsCapacity // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
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


/// Adds pattern-matching-related methods to [VehicleFormState].
extension VehicleFormStatePatterns on VehicleFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VehicleFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VehicleFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VehicleFormState value)  $default,){
final _that = this;
switch (_that) {
case _VehicleFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VehicleFormState value)?  $default,){
final _that = this;
switch (_that) {
case _VehicleFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? vehicleId,  String licensePlate,  String name,  String nickname,  String tonsCapacity,  EntityStatus status,  bool loading,  bool submitting,  bool saved,  bool deleted,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VehicleFormState() when $default != null:
return $default(_that.vehicleId,_that.licensePlate,_that.name,_that.nickname,_that.tonsCapacity,_that.status,_that.loading,_that.submitting,_that.saved,_that.deleted,_that.error,_that.errorDetail,_that.fieldErrors);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? vehicleId,  String licensePlate,  String name,  String nickname,  String tonsCapacity,  EntityStatus status,  bool loading,  bool submitting,  bool saved,  bool deleted,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)  $default,) {final _that = this;
switch (_that) {
case _VehicleFormState():
return $default(_that.vehicleId,_that.licensePlate,_that.name,_that.nickname,_that.tonsCapacity,_that.status,_that.loading,_that.submitting,_that.saved,_that.deleted,_that.error,_that.errorDetail,_that.fieldErrors);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? vehicleId,  String licensePlate,  String name,  String nickname,  String tonsCapacity,  EntityStatus status,  bool loading,  bool submitting,  bool saved,  bool deleted,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)?  $default,) {final _that = this;
switch (_that) {
case _VehicleFormState() when $default != null:
return $default(_that.vehicleId,_that.licensePlate,_that.name,_that.nickname,_that.tonsCapacity,_that.status,_that.loading,_that.submitting,_that.saved,_that.deleted,_that.error,_that.errorDetail,_that.fieldErrors);case _:
  return null;

}
}

}

/// @nodoc


class _VehicleFormState implements VehicleFormState {
  const _VehicleFormState({this.vehicleId, this.licensePlate = '', this.name = '', this.nickname = '', this.tonsCapacity = '', this.status = EntityStatus.active, this.loading = false, this.submitting = false, this.saved = false, this.deleted = false, this.error, this.errorDetail,  Map<String, String> fieldErrors = const <String, String>{}}): _fieldErrors = fieldErrors;
  

@override final  int? vehicleId;
@override@JsonKey() final  String licensePlate;
@override@JsonKey() final  String name;
@override@JsonKey() final  String nickname;
@override@JsonKey() final  String tonsCapacity;
@override@JsonKey() final  EntityStatus status;
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


/// Create a copy of VehicleFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VehicleFormStateCopyWith<_VehicleFormState> get copyWith => __$VehicleFormStateCopyWithImpl<_VehicleFormState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VehicleFormState&&(identical(other.vehicleId, vehicleId) || other.vehicleId == vehicleId)&&(identical(other.licensePlate, licensePlate) || other.licensePlate == licensePlate)&&(identical(other.name, name) || other.name == name)&&(identical(other.nickname, nickname) || other.nickname == nickname)&&(identical(other.tonsCapacity, tonsCapacity) || other.tonsCapacity == tonsCapacity)&&(identical(other.status, status) || other.status == status)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.saved, saved) || other.saved == saved)&&(identical(other.deleted, deleted) || other.deleted == deleted)&&(identical(other.error, error) || other.error == error)&&(identical(other.errorDetail, errorDetail) || other.errorDetail == errorDetail)&&const DeepCollectionEquality().equals(other.fieldErrors, _fieldErrors));
}


@override
int get hashCode {
    return Object.hash(runtimeType,vehicleId,licensePlate,name,nickname,tonsCapacity,status,loading,submitting,saved,deleted,error,errorDetail,const DeepCollectionEquality().hash(_fieldErrors));
}

@override
String toString() {
    return 'VehicleFormState(vehicleId: $vehicleId, licensePlate: $licensePlate, name: $name, nickname: $nickname, tonsCapacity: $tonsCapacity, status: $status, loading: $loading, submitting: $submitting, saved: $saved, deleted: $deleted, error: $error, errorDetail: $errorDetail, fieldErrors: $fieldErrors)';
}


}

/// @nodoc
abstract mixin class _$VehicleFormStateCopyWith<$Res> implements $VehicleFormStateCopyWith<$Res> {
  factory _$VehicleFormStateCopyWith(_VehicleFormState value, $Res Function(_VehicleFormState) _then) = __$VehicleFormStateCopyWithImpl;
@override @useResult
$Res call({
 int? vehicleId, String licensePlate, String name, String nickname, String tonsCapacity, EntityStatus status, bool loading, bool submitting, bool saved, bool deleted, String? error, String? errorDetail, Map<String, String> fieldErrors
});




}
/// @nodoc
class __$VehicleFormStateCopyWithImpl<$Res>
    implements _$VehicleFormStateCopyWith<$Res> {
  __$VehicleFormStateCopyWithImpl(this._self, this._then);

  final _VehicleFormState _self;
  final $Res Function(_VehicleFormState) _then;

/// Create a copy of VehicleFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? vehicleId = freezed,Object? licensePlate = null,Object? name = null,Object? nickname = null,Object? tonsCapacity = null,Object? status = null,Object? loading = null,Object? submitting = null,Object? saved = null,Object? deleted = null,Object? error = freezed,Object? errorDetail = freezed,Object? fieldErrors = null,}) {
  return _then(_VehicleFormState(
vehicleId: freezed == vehicleId ? _self.vehicleId : vehicleId // ignore: cast_nullable_to_non_nullable
as int?,licensePlate: null == licensePlate ? _self.licensePlate : licensePlate // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,nickname: null == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String,tonsCapacity: null == tonsCapacity ? _self.tonsCapacity : tonsCapacity // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
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
