// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'label_form_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LabelFormState {

 int? get labelId; String get name; String get comment; bool get loading; bool get submitting; bool get saved; bool get deleted; String? get error; String? get errorDetail; Map<String, String> get fieldErrors;
/// Create a copy of LabelFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LabelFormStateCopyWith<LabelFormState> get copyWith => _$LabelFormStateCopyWithImpl<LabelFormState>(this as LabelFormState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LabelFormState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LabelFormState&&(identical(other.labelId, _this.labelId) || other.labelId == _this.labelId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.comment, _this.comment) || other.comment == _this.comment)&&(identical(other.loading, _this.loading) || other.loading == _this.loading)&&(identical(other.submitting, _this.submitting) || other.submitting == _this.submitting)&&(identical(other.saved, _this.saved) || other.saved == _this.saved)&&(identical(other.deleted, _this.deleted) || other.deleted == _this.deleted)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.errorDetail, _this.errorDetail) || other.errorDetail == _this.errorDetail)&&const DeepCollectionEquality().equals(other.fieldErrors, _this.fieldErrors));
}


@override
int get hashCode {
  final _this = this as LabelFormState;
  return Object.hash(runtimeType,_this.labelId,_this.name,_this.comment,_this.loading,_this.submitting,_this.saved,_this.deleted,_this.error,_this.errorDetail,const DeepCollectionEquality().hash(_this.fieldErrors));
}

@override
String toString() {
  final _this = this as LabelFormState;
  return 'LabelFormState(labelId: ${_this.labelId}, name: ${_this.name}, comment: ${_this.comment}, loading: ${_this.loading}, submitting: ${_this.submitting}, saved: ${_this.saved}, deleted: ${_this.deleted}, error: ${_this.error}, errorDetail: ${_this.errorDetail}, fieldErrors: ${_this.fieldErrors})';
}


}

/// @nodoc
abstract mixin class $LabelFormStateCopyWith<$Res>  {
  factory $LabelFormStateCopyWith(LabelFormState value, $Res Function(LabelFormState) _then) = _$LabelFormStateCopyWithImpl;
@useResult
$Res call({
 int? labelId, String name, String comment, bool loading, bool submitting, bool saved, bool deleted, String? error, String? errorDetail, Map<String, String> fieldErrors
});




}
/// @nodoc
class _$LabelFormStateCopyWithImpl<$Res>
    implements $LabelFormStateCopyWith<$Res> {
  _$LabelFormStateCopyWithImpl(this._self, this._then);

  final LabelFormState _self;
  final $Res Function(LabelFormState) _then;

/// Create a copy of LabelFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? labelId = freezed,Object? name = null,Object? comment = null,Object? loading = null,Object? submitting = null,Object? saved = null,Object? deleted = null,Object? error = freezed,Object? errorDetail = freezed,Object? fieldErrors = null,}) {
  return _then(LabelFormState(
labelId: freezed == labelId ? _self.labelId : labelId // ignore: cast_nullable_to_non_nullable
as int?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
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


/// Adds pattern-matching-related methods to [LabelFormState].
extension LabelFormStatePatterns on LabelFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LabelFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LabelFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LabelFormState value)  $default,){
final _that = this;
switch (_that) {
case _LabelFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LabelFormState value)?  $default,){
final _that = this;
switch (_that) {
case _LabelFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? labelId,  String name,  String comment,  bool loading,  bool submitting,  bool saved,  bool deleted,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LabelFormState() when $default != null:
return $default(_that.labelId,_that.name,_that.comment,_that.loading,_that.submitting,_that.saved,_that.deleted,_that.error,_that.errorDetail,_that.fieldErrors);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? labelId,  String name,  String comment,  bool loading,  bool submitting,  bool saved,  bool deleted,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)  $default,) {final _that = this;
switch (_that) {
case _LabelFormState():
return $default(_that.labelId,_that.name,_that.comment,_that.loading,_that.submitting,_that.saved,_that.deleted,_that.error,_that.errorDetail,_that.fieldErrors);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? labelId,  String name,  String comment,  bool loading,  bool submitting,  bool saved,  bool deleted,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)?  $default,) {final _that = this;
switch (_that) {
case _LabelFormState() when $default != null:
return $default(_that.labelId,_that.name,_that.comment,_that.loading,_that.submitting,_that.saved,_that.deleted,_that.error,_that.errorDetail,_that.fieldErrors);case _:
  return null;

}
}

}

/// @nodoc


class _LabelFormState implements LabelFormState {
  const _LabelFormState({this.labelId, this.name = '', this.comment = '', this.loading = false, this.submitting = false, this.saved = false, this.deleted = false, this.error, this.errorDetail,  Map<String, String> fieldErrors = const <String, String>{}}): _fieldErrors = fieldErrors;
  

@override final  int? labelId;
@override@JsonKey() final  String name;
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


/// Create a copy of LabelFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LabelFormStateCopyWith<_LabelFormState> get copyWith => __$LabelFormStateCopyWithImpl<_LabelFormState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LabelFormState&&(identical(other.labelId, labelId) || other.labelId == labelId)&&(identical(other.name, name) || other.name == name)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.saved, saved) || other.saved == saved)&&(identical(other.deleted, deleted) || other.deleted == deleted)&&(identical(other.error, error) || other.error == error)&&(identical(other.errorDetail, errorDetail) || other.errorDetail == errorDetail)&&const DeepCollectionEquality().equals(other.fieldErrors, _fieldErrors));
}


@override
int get hashCode {
    return Object.hash(runtimeType,labelId,name,comment,loading,submitting,saved,deleted,error,errorDetail,const DeepCollectionEquality().hash(_fieldErrors));
}

@override
String toString() {
    return 'LabelFormState(labelId: $labelId, name: $name, comment: $comment, loading: $loading, submitting: $submitting, saved: $saved, deleted: $deleted, error: $error, errorDetail: $errorDetail, fieldErrors: $fieldErrors)';
}


}

/// @nodoc
abstract mixin class _$LabelFormStateCopyWith<$Res> implements $LabelFormStateCopyWith<$Res> {
  factory _$LabelFormStateCopyWith(_LabelFormState value, $Res Function(_LabelFormState) _then) = __$LabelFormStateCopyWithImpl;
@override @useResult
$Res call({
 int? labelId, String name, String comment, bool loading, bool submitting, bool saved, bool deleted, String? error, String? errorDetail, Map<String, String> fieldErrors
});




}
/// @nodoc
class __$LabelFormStateCopyWithImpl<$Res>
    implements _$LabelFormStateCopyWith<$Res> {
  __$LabelFormStateCopyWithImpl(this._self, this._then);

  final _LabelFormState _self;
  final $Res Function(_LabelFormState) _then;

/// Create a copy of LabelFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? labelId = freezed,Object? name = null,Object? comment = null,Object? loading = null,Object? submitting = null,Object? saved = null,Object? deleted = null,Object? error = freezed,Object? errorDetail = freezed,Object? fieldErrors = null,}) {
  return _then(_LabelFormState(
labelId: freezed == labelId ? _self.labelId : labelId // ignore: cast_nullable_to_non_nullable
as int?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
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
