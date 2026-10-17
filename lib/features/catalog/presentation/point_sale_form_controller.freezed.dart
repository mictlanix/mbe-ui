// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'point_sale_form_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PointSaleFormState {

 int? get pointSaleId; int? get facilityId;/// The facility this point of sale belonged to when the form was opened
/// for editing — `null` in create mode. Captured once by [loadForEdit]
/// and never touched by [facilitySelected], so a save that moved the
/// point of sale to a different facility can invalidate both the old
/// and the new card (018-nested-facility-management research §6).
 int? get originalFacilityId; String get facilityDisplayText; String get code; String get name; int? get warehouseId; String get warehouseDisplayText; String get comment; EntityStatus get status; bool get loading; bool get submitting; bool get saved; bool get deleted; String? get error; String? get errorDetail; Map<String, String> get fieldErrors;
/// Create a copy of PointSaleFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PointSaleFormStateCopyWith<PointSaleFormState> get copyWith => _$PointSaleFormStateCopyWithImpl<PointSaleFormState>(this as PointSaleFormState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PointSaleFormState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PointSaleFormState&&(identical(other.pointSaleId, _this.pointSaleId) || other.pointSaleId == _this.pointSaleId)&&(identical(other.facilityId, _this.facilityId) || other.facilityId == _this.facilityId)&&(identical(other.originalFacilityId, _this.originalFacilityId) || other.originalFacilityId == _this.originalFacilityId)&&(identical(other.facilityDisplayText, _this.facilityDisplayText) || other.facilityDisplayText == _this.facilityDisplayText)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.warehouseId, _this.warehouseId) || other.warehouseId == _this.warehouseId)&&(identical(other.warehouseDisplayText, _this.warehouseDisplayText) || other.warehouseDisplayText == _this.warehouseDisplayText)&&(identical(other.comment, _this.comment) || other.comment == _this.comment)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.loading, _this.loading) || other.loading == _this.loading)&&(identical(other.submitting, _this.submitting) || other.submitting == _this.submitting)&&(identical(other.saved, _this.saved) || other.saved == _this.saved)&&(identical(other.deleted, _this.deleted) || other.deleted == _this.deleted)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.errorDetail, _this.errorDetail) || other.errorDetail == _this.errorDetail)&&const DeepCollectionEquality().equals(other.fieldErrors, _this.fieldErrors));
}


@override
int get hashCode {
  final _this = this as PointSaleFormState;
  return Object.hash(runtimeType,_this.pointSaleId,_this.facilityId,_this.originalFacilityId,_this.facilityDisplayText,_this.code,_this.name,_this.warehouseId,_this.warehouseDisplayText,_this.comment,_this.status,_this.loading,_this.submitting,_this.saved,_this.deleted,_this.error,_this.errorDetail,const DeepCollectionEquality().hash(_this.fieldErrors));
}

@override
String toString() {
  final _this = this as PointSaleFormState;
  return 'PointSaleFormState(pointSaleId: ${_this.pointSaleId}, facilityId: ${_this.facilityId}, originalFacilityId: ${_this.originalFacilityId}, facilityDisplayText: ${_this.facilityDisplayText}, code: ${_this.code}, name: ${_this.name}, warehouseId: ${_this.warehouseId}, warehouseDisplayText: ${_this.warehouseDisplayText}, comment: ${_this.comment}, status: ${_this.status}, loading: ${_this.loading}, submitting: ${_this.submitting}, saved: ${_this.saved}, deleted: ${_this.deleted}, error: ${_this.error}, errorDetail: ${_this.errorDetail}, fieldErrors: ${_this.fieldErrors})';
}


}

/// @nodoc
abstract mixin class $PointSaleFormStateCopyWith<$Res>  {
  factory $PointSaleFormStateCopyWith(PointSaleFormState value, $Res Function(PointSaleFormState) _then) = _$PointSaleFormStateCopyWithImpl;
@useResult
$Res call({
 int? pointSaleId, int? facilityId, int? originalFacilityId, String facilityDisplayText, String code, String name, int? warehouseId, String warehouseDisplayText, String comment, EntityStatus status, bool loading, bool submitting, bool saved, bool deleted, String? error, String? errorDetail, Map<String, String> fieldErrors
});




}
/// @nodoc
class _$PointSaleFormStateCopyWithImpl<$Res>
    implements $PointSaleFormStateCopyWith<$Res> {
  _$PointSaleFormStateCopyWithImpl(this._self, this._then);

  final PointSaleFormState _self;
  final $Res Function(PointSaleFormState) _then;

/// Create a copy of PointSaleFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pointSaleId = freezed,Object? facilityId = freezed,Object? originalFacilityId = freezed,Object? facilityDisplayText = null,Object? code = null,Object? name = null,Object? warehouseId = freezed,Object? warehouseDisplayText = null,Object? comment = null,Object? status = null,Object? loading = null,Object? submitting = null,Object? saved = null,Object? deleted = null,Object? error = freezed,Object? errorDetail = freezed,Object? fieldErrors = null,}) {
  return _then(PointSaleFormState(
pointSaleId: freezed == pointSaleId ? _self.pointSaleId : pointSaleId // ignore: cast_nullable_to_non_nullable
as int?,facilityId: freezed == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int?,originalFacilityId: freezed == originalFacilityId ? _self.originalFacilityId : originalFacilityId // ignore: cast_nullable_to_non_nullable
as int?,facilityDisplayText: null == facilityDisplayText ? _self.facilityDisplayText : facilityDisplayText // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,warehouseId: freezed == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int?,warehouseDisplayText: null == warehouseDisplayText ? _self.warehouseDisplayText : warehouseDisplayText // ignore: cast_nullable_to_non_nullable
as String,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
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


/// Adds pattern-matching-related methods to [PointSaleFormState].
extension PointSaleFormStatePatterns on PointSaleFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PointSaleFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PointSaleFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PointSaleFormState value)  $default,){
final _that = this;
switch (_that) {
case _PointSaleFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PointSaleFormState value)?  $default,){
final _that = this;
switch (_that) {
case _PointSaleFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? pointSaleId,  int? facilityId,  int? originalFacilityId,  String facilityDisplayText,  String code,  String name,  int? warehouseId,  String warehouseDisplayText,  String comment,  EntityStatus status,  bool loading,  bool submitting,  bool saved,  bool deleted,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PointSaleFormState() when $default != null:
return $default(_that.pointSaleId,_that.facilityId,_that.originalFacilityId,_that.facilityDisplayText,_that.code,_that.name,_that.warehouseId,_that.warehouseDisplayText,_that.comment,_that.status,_that.loading,_that.submitting,_that.saved,_that.deleted,_that.error,_that.errorDetail,_that.fieldErrors);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? pointSaleId,  int? facilityId,  int? originalFacilityId,  String facilityDisplayText,  String code,  String name,  int? warehouseId,  String warehouseDisplayText,  String comment,  EntityStatus status,  bool loading,  bool submitting,  bool saved,  bool deleted,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)  $default,) {final _that = this;
switch (_that) {
case _PointSaleFormState():
return $default(_that.pointSaleId,_that.facilityId,_that.originalFacilityId,_that.facilityDisplayText,_that.code,_that.name,_that.warehouseId,_that.warehouseDisplayText,_that.comment,_that.status,_that.loading,_that.submitting,_that.saved,_that.deleted,_that.error,_that.errorDetail,_that.fieldErrors);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? pointSaleId,  int? facilityId,  int? originalFacilityId,  String facilityDisplayText,  String code,  String name,  int? warehouseId,  String warehouseDisplayText,  String comment,  EntityStatus status,  bool loading,  bool submitting,  bool saved,  bool deleted,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)?  $default,) {final _that = this;
switch (_that) {
case _PointSaleFormState() when $default != null:
return $default(_that.pointSaleId,_that.facilityId,_that.originalFacilityId,_that.facilityDisplayText,_that.code,_that.name,_that.warehouseId,_that.warehouseDisplayText,_that.comment,_that.status,_that.loading,_that.submitting,_that.saved,_that.deleted,_that.error,_that.errorDetail,_that.fieldErrors);case _:
  return null;

}
}

}

/// @nodoc


class _PointSaleFormState implements PointSaleFormState {
  const _PointSaleFormState({this.pointSaleId, this.facilityId, this.originalFacilityId, this.facilityDisplayText = '', this.code = '', this.name = '', this.warehouseId, this.warehouseDisplayText = '', this.comment = '', this.status = EntityStatus.active, this.loading = false, this.submitting = false, this.saved = false, this.deleted = false, this.error, this.errorDetail,  Map<String, String> fieldErrors = const <String, String>{}}): _fieldErrors = fieldErrors;
  

@override final  int? pointSaleId;
@override final  int? facilityId;
/// The facility this point of sale belonged to when the form was opened
/// for editing — `null` in create mode. Captured once by [loadForEdit]
/// and never touched by [facilitySelected], so a save that moved the
/// point of sale to a different facility can invalidate both the old
/// and the new card (018-nested-facility-management research §6).
@override final  int? originalFacilityId;
@override@JsonKey() final  String facilityDisplayText;
@override@JsonKey() final  String code;
@override@JsonKey() final  String name;
@override final  int? warehouseId;
@override@JsonKey() final  String warehouseDisplayText;
@override@JsonKey() final  String comment;
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


/// Create a copy of PointSaleFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PointSaleFormStateCopyWith<_PointSaleFormState> get copyWith => __$PointSaleFormStateCopyWithImpl<_PointSaleFormState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PointSaleFormState&&(identical(other.pointSaleId, pointSaleId) || other.pointSaleId == pointSaleId)&&(identical(other.facilityId, facilityId) || other.facilityId == facilityId)&&(identical(other.originalFacilityId, originalFacilityId) || other.originalFacilityId == originalFacilityId)&&(identical(other.facilityDisplayText, facilityDisplayText) || other.facilityDisplayText == facilityDisplayText)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.warehouseDisplayText, warehouseDisplayText) || other.warehouseDisplayText == warehouseDisplayText)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.status, status) || other.status == status)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.saved, saved) || other.saved == saved)&&(identical(other.deleted, deleted) || other.deleted == deleted)&&(identical(other.error, error) || other.error == error)&&(identical(other.errorDetail, errorDetail) || other.errorDetail == errorDetail)&&const DeepCollectionEquality().equals(other.fieldErrors, _fieldErrors));
}


@override
int get hashCode {
    return Object.hash(runtimeType,pointSaleId,facilityId,originalFacilityId,facilityDisplayText,code,name,warehouseId,warehouseDisplayText,comment,status,loading,submitting,saved,deleted,error,errorDetail,const DeepCollectionEquality().hash(_fieldErrors));
}

@override
String toString() {
    return 'PointSaleFormState(pointSaleId: $pointSaleId, facilityId: $facilityId, originalFacilityId: $originalFacilityId, facilityDisplayText: $facilityDisplayText, code: $code, name: $name, warehouseId: $warehouseId, warehouseDisplayText: $warehouseDisplayText, comment: $comment, status: $status, loading: $loading, submitting: $submitting, saved: $saved, deleted: $deleted, error: $error, errorDetail: $errorDetail, fieldErrors: $fieldErrors)';
}


}

/// @nodoc
abstract mixin class _$PointSaleFormStateCopyWith<$Res> implements $PointSaleFormStateCopyWith<$Res> {
  factory _$PointSaleFormStateCopyWith(_PointSaleFormState value, $Res Function(_PointSaleFormState) _then) = __$PointSaleFormStateCopyWithImpl;
@override @useResult
$Res call({
 int? pointSaleId, int? facilityId, int? originalFacilityId, String facilityDisplayText, String code, String name, int? warehouseId, String warehouseDisplayText, String comment, EntityStatus status, bool loading, bool submitting, bool saved, bool deleted, String? error, String? errorDetail, Map<String, String> fieldErrors
});




}
/// @nodoc
class __$PointSaleFormStateCopyWithImpl<$Res>
    implements _$PointSaleFormStateCopyWith<$Res> {
  __$PointSaleFormStateCopyWithImpl(this._self, this._then);

  final _PointSaleFormState _self;
  final $Res Function(_PointSaleFormState) _then;

/// Create a copy of PointSaleFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pointSaleId = freezed,Object? facilityId = freezed,Object? originalFacilityId = freezed,Object? facilityDisplayText = null,Object? code = null,Object? name = null,Object? warehouseId = freezed,Object? warehouseDisplayText = null,Object? comment = null,Object? status = null,Object? loading = null,Object? submitting = null,Object? saved = null,Object? deleted = null,Object? error = freezed,Object? errorDetail = freezed,Object? fieldErrors = null,}) {
  return _then(_PointSaleFormState(
pointSaleId: freezed == pointSaleId ? _self.pointSaleId : pointSaleId // ignore: cast_nullable_to_non_nullable
as int?,facilityId: freezed == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int?,originalFacilityId: freezed == originalFacilityId ? _self.originalFacilityId : originalFacilityId // ignore: cast_nullable_to_non_nullable
as int?,facilityDisplayText: null == facilityDisplayText ? _self.facilityDisplayText : facilityDisplayText // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,warehouseId: freezed == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int?,warehouseDisplayText: null == warehouseDisplayText ? _self.warehouseDisplayText : warehouseDisplayText // ignore: cast_nullable_to_non_nullable
as String,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
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
