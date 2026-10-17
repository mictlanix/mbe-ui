// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'price_list_form_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PriceListFormState {

 int? get priceListId; String get name; bool get loading; bool get submitting; bool get saved; String? get error; String? get errorDetail; Map<String, String> get fieldErrors;
/// Create a copy of PriceListFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PriceListFormStateCopyWith<PriceListFormState> get copyWith => _$PriceListFormStateCopyWithImpl<PriceListFormState>(this as PriceListFormState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PriceListFormState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PriceListFormState&&(identical(other.priceListId, _this.priceListId) || other.priceListId == _this.priceListId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.loading, _this.loading) || other.loading == _this.loading)&&(identical(other.submitting, _this.submitting) || other.submitting == _this.submitting)&&(identical(other.saved, _this.saved) || other.saved == _this.saved)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.errorDetail, _this.errorDetail) || other.errorDetail == _this.errorDetail)&&const DeepCollectionEquality().equals(other.fieldErrors, _this.fieldErrors));
}


@override
int get hashCode {
  final _this = this as PriceListFormState;
  return Object.hash(runtimeType,_this.priceListId,_this.name,_this.loading,_this.submitting,_this.saved,_this.error,_this.errorDetail,const DeepCollectionEquality().hash(_this.fieldErrors));
}

@override
String toString() {
  final _this = this as PriceListFormState;
  return 'PriceListFormState(priceListId: ${_this.priceListId}, name: ${_this.name}, loading: ${_this.loading}, submitting: ${_this.submitting}, saved: ${_this.saved}, error: ${_this.error}, errorDetail: ${_this.errorDetail}, fieldErrors: ${_this.fieldErrors})';
}


}

/// @nodoc
abstract mixin class $PriceListFormStateCopyWith<$Res>  {
  factory $PriceListFormStateCopyWith(PriceListFormState value, $Res Function(PriceListFormState) _then) = _$PriceListFormStateCopyWithImpl;
@useResult
$Res call({
 int? priceListId, String name, bool loading, bool submitting, bool saved, String? error, String? errorDetail, Map<String, String> fieldErrors
});




}
/// @nodoc
class _$PriceListFormStateCopyWithImpl<$Res>
    implements $PriceListFormStateCopyWith<$Res> {
  _$PriceListFormStateCopyWithImpl(this._self, this._then);

  final PriceListFormState _self;
  final $Res Function(PriceListFormState) _then;

/// Create a copy of PriceListFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? priceListId = freezed,Object? name = null,Object? loading = null,Object? submitting = null,Object? saved = null,Object? error = freezed,Object? errorDetail = freezed,Object? fieldErrors = null,}) {
  return _then(PriceListFormState(
priceListId: freezed == priceListId ? _self.priceListId : priceListId // ignore: cast_nullable_to_non_nullable
as int?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,errorDetail: freezed == errorDetail ? _self.errorDetail : errorDetail // ignore: cast_nullable_to_non_nullable
as String?,fieldErrors: null == fieldErrors ? _self.fieldErrors : fieldErrors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

}


/// Adds pattern-matching-related methods to [PriceListFormState].
extension PriceListFormStatePatterns on PriceListFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PriceListFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PriceListFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PriceListFormState value)  $default,){
final _that = this;
switch (_that) {
case _PriceListFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PriceListFormState value)?  $default,){
final _that = this;
switch (_that) {
case _PriceListFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? priceListId,  String name,  bool loading,  bool submitting,  bool saved,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PriceListFormState() when $default != null:
return $default(_that.priceListId,_that.name,_that.loading,_that.submitting,_that.saved,_that.error,_that.errorDetail,_that.fieldErrors);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? priceListId,  String name,  bool loading,  bool submitting,  bool saved,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)  $default,) {final _that = this;
switch (_that) {
case _PriceListFormState():
return $default(_that.priceListId,_that.name,_that.loading,_that.submitting,_that.saved,_that.error,_that.errorDetail,_that.fieldErrors);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? priceListId,  String name,  bool loading,  bool submitting,  bool saved,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)?  $default,) {final _that = this;
switch (_that) {
case _PriceListFormState() when $default != null:
return $default(_that.priceListId,_that.name,_that.loading,_that.submitting,_that.saved,_that.error,_that.errorDetail,_that.fieldErrors);case _:
  return null;

}
}

}

/// @nodoc


class _PriceListFormState implements PriceListFormState {
  const _PriceListFormState({this.priceListId, this.name = '', this.loading = false, this.submitting = false, this.saved = false, this.error, this.errorDetail,  Map<String, String> fieldErrors = const <String, String>{}}): _fieldErrors = fieldErrors;
  

@override final  int? priceListId;
@override@JsonKey() final  String name;
@override@JsonKey() final  bool loading;
@override@JsonKey() final  bool submitting;
@override@JsonKey() final  bool saved;
@override final  String? error;
@override final  String? errorDetail;
 final  Map<String, String> _fieldErrors;
@override@JsonKey() Map<String, String> get fieldErrors {
  if (_fieldErrors is EqualUnmodifiableMapView) return _fieldErrors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_fieldErrors);
}


/// Create a copy of PriceListFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PriceListFormStateCopyWith<_PriceListFormState> get copyWith => __$PriceListFormStateCopyWithImpl<_PriceListFormState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PriceListFormState&&(identical(other.priceListId, priceListId) || other.priceListId == priceListId)&&(identical(other.name, name) || other.name == name)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.saved, saved) || other.saved == saved)&&(identical(other.error, error) || other.error == error)&&(identical(other.errorDetail, errorDetail) || other.errorDetail == errorDetail)&&const DeepCollectionEquality().equals(other.fieldErrors, _fieldErrors));
}


@override
int get hashCode {
    return Object.hash(runtimeType,priceListId,name,loading,submitting,saved,error,errorDetail,const DeepCollectionEquality().hash(_fieldErrors));
}

@override
String toString() {
    return 'PriceListFormState(priceListId: $priceListId, name: $name, loading: $loading, submitting: $submitting, saved: $saved, error: $error, errorDetail: $errorDetail, fieldErrors: $fieldErrors)';
}


}

/// @nodoc
abstract mixin class _$PriceListFormStateCopyWith<$Res> implements $PriceListFormStateCopyWith<$Res> {
  factory _$PriceListFormStateCopyWith(_PriceListFormState value, $Res Function(_PriceListFormState) _then) = __$PriceListFormStateCopyWithImpl;
@override @useResult
$Res call({
 int? priceListId, String name, bool loading, bool submitting, bool saved, String? error, String? errorDetail, Map<String, String> fieldErrors
});




}
/// @nodoc
class __$PriceListFormStateCopyWithImpl<$Res>
    implements _$PriceListFormStateCopyWith<$Res> {
  __$PriceListFormStateCopyWithImpl(this._self, this._then);

  final _PriceListFormState _self;
  final $Res Function(_PriceListFormState) _then;

/// Create a copy of PriceListFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? priceListId = freezed,Object? name = null,Object? loading = null,Object? submitting = null,Object? saved = null,Object? error = freezed,Object? errorDetail = freezed,Object? fieldErrors = null,}) {
  return _then(_PriceListFormState(
priceListId: freezed == priceListId ? _self.priceListId : priceListId // ignore: cast_nullable_to_non_nullable
as int?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,errorDetail: freezed == errorDetail ? _self.errorDetail : errorDetail // ignore: cast_nullable_to_non_nullable
as String?,fieldErrors: null == fieldErrors ? _self._fieldErrors : fieldErrors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}

// dart format on
