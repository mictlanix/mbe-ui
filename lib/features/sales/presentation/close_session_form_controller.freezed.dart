// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'close_session_form_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CloseSessionFormState {

 int? get cashSessionId; Map<String, int> get quantities; String get countedTotal; String get expectedCash; String get difference; bool get submitting; bool get closed; String? get error; String? get errorDetail; Map<String, String> get fieldErrors;
/// Create a copy of CloseSessionFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CloseSessionFormStateCopyWith<CloseSessionFormState> get copyWith => _$CloseSessionFormStateCopyWithImpl<CloseSessionFormState>(this as CloseSessionFormState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CloseSessionFormState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CloseSessionFormState&&(identical(other.cashSessionId, _this.cashSessionId) || other.cashSessionId == _this.cashSessionId)&&const DeepCollectionEquality().equals(other.quantities, _this.quantities)&&(identical(other.countedTotal, _this.countedTotal) || other.countedTotal == _this.countedTotal)&&(identical(other.expectedCash, _this.expectedCash) || other.expectedCash == _this.expectedCash)&&(identical(other.difference, _this.difference) || other.difference == _this.difference)&&(identical(other.submitting, _this.submitting) || other.submitting == _this.submitting)&&(identical(other.closed, _this.closed) || other.closed == _this.closed)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.errorDetail, _this.errorDetail) || other.errorDetail == _this.errorDetail)&&const DeepCollectionEquality().equals(other.fieldErrors, _this.fieldErrors));
}


@override
int get hashCode {
  final _this = this as CloseSessionFormState;
  return Object.hash(runtimeType,_this.cashSessionId,const DeepCollectionEquality().hash(_this.quantities),_this.countedTotal,_this.expectedCash,_this.difference,_this.submitting,_this.closed,_this.error,_this.errorDetail,const DeepCollectionEquality().hash(_this.fieldErrors));
}

@override
String toString() {
  final _this = this as CloseSessionFormState;
  return 'CloseSessionFormState(cashSessionId: ${_this.cashSessionId}, quantities: ${_this.quantities}, countedTotal: ${_this.countedTotal}, expectedCash: ${_this.expectedCash}, difference: ${_this.difference}, submitting: ${_this.submitting}, closed: ${_this.closed}, error: ${_this.error}, errorDetail: ${_this.errorDetail}, fieldErrors: ${_this.fieldErrors})';
}


}

/// @nodoc
abstract mixin class $CloseSessionFormStateCopyWith<$Res>  {
  factory $CloseSessionFormStateCopyWith(CloseSessionFormState value, $Res Function(CloseSessionFormState) _then) = _$CloseSessionFormStateCopyWithImpl;
@useResult
$Res call({
 int? cashSessionId, Map<String, int> quantities, String countedTotal, String expectedCash, String difference, bool submitting, bool closed, String? error, String? errorDetail, Map<String, String> fieldErrors
});




}
/// @nodoc
class _$CloseSessionFormStateCopyWithImpl<$Res>
    implements $CloseSessionFormStateCopyWith<$Res> {
  _$CloseSessionFormStateCopyWithImpl(this._self, this._then);

  final CloseSessionFormState _self;
  final $Res Function(CloseSessionFormState) _then;

/// Create a copy of CloseSessionFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cashSessionId = freezed,Object? quantities = null,Object? countedTotal = null,Object? expectedCash = null,Object? difference = null,Object? submitting = null,Object? closed = null,Object? error = freezed,Object? errorDetail = freezed,Object? fieldErrors = null,}) {
  return _then(CloseSessionFormState(
cashSessionId: freezed == cashSessionId ? _self.cashSessionId : cashSessionId // ignore: cast_nullable_to_non_nullable
as int?,quantities: null == quantities ? _self.quantities : quantities // ignore: cast_nullable_to_non_nullable
as Map<String, int>,countedTotal: null == countedTotal ? _self.countedTotal : countedTotal // ignore: cast_nullable_to_non_nullable
as String,expectedCash: null == expectedCash ? _self.expectedCash : expectedCash // ignore: cast_nullable_to_non_nullable
as String,difference: null == difference ? _self.difference : difference // ignore: cast_nullable_to_non_nullable
as String,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,closed: null == closed ? _self.closed : closed // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,errorDetail: freezed == errorDetail ? _self.errorDetail : errorDetail // ignore: cast_nullable_to_non_nullable
as String?,fieldErrors: null == fieldErrors ? _self.fieldErrors : fieldErrors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

}


/// Adds pattern-matching-related methods to [CloseSessionFormState].
extension CloseSessionFormStatePatterns on CloseSessionFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CloseSessionFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CloseSessionFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CloseSessionFormState value)  $default,){
final _that = this;
switch (_that) {
case _CloseSessionFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CloseSessionFormState value)?  $default,){
final _that = this;
switch (_that) {
case _CloseSessionFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? cashSessionId,  Map<String, int> quantities,  String countedTotal,  String expectedCash,  String difference,  bool submitting,  bool closed,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CloseSessionFormState() when $default != null:
return $default(_that.cashSessionId,_that.quantities,_that.countedTotal,_that.expectedCash,_that.difference,_that.submitting,_that.closed,_that.error,_that.errorDetail,_that.fieldErrors);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? cashSessionId,  Map<String, int> quantities,  String countedTotal,  String expectedCash,  String difference,  bool submitting,  bool closed,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)  $default,) {final _that = this;
switch (_that) {
case _CloseSessionFormState():
return $default(_that.cashSessionId,_that.quantities,_that.countedTotal,_that.expectedCash,_that.difference,_that.submitting,_that.closed,_that.error,_that.errorDetail,_that.fieldErrors);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? cashSessionId,  Map<String, int> quantities,  String countedTotal,  String expectedCash,  String difference,  bool submitting,  bool closed,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)?  $default,) {final _that = this;
switch (_that) {
case _CloseSessionFormState() when $default != null:
return $default(_that.cashSessionId,_that.quantities,_that.countedTotal,_that.expectedCash,_that.difference,_that.submitting,_that.closed,_that.error,_that.errorDetail,_that.fieldErrors);case _:
  return null;

}
}

}

/// @nodoc


class _CloseSessionFormState implements CloseSessionFormState {
  const _CloseSessionFormState({this.cashSessionId,  Map<String, int> quantities = const <String, int>{}, this.countedTotal = '0', this.expectedCash = '0', this.difference = '0', this.submitting = false, this.closed = false, this.error, this.errorDetail,  Map<String, String> fieldErrors = const <String, String>{}}): _quantities = quantities,_fieldErrors = fieldErrors;
  

@override final  int? cashSessionId;
 final  Map<String, int> _quantities;
@override@JsonKey() Map<String, int> get quantities {
  if (_quantities is EqualUnmodifiableMapView) return _quantities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_quantities);
}

@override@JsonKey() final  String countedTotal;
@override@JsonKey() final  String expectedCash;
@override@JsonKey() final  String difference;
@override@JsonKey() final  bool submitting;
@override@JsonKey() final  bool closed;
@override final  String? error;
@override final  String? errorDetail;
 final  Map<String, String> _fieldErrors;
@override@JsonKey() Map<String, String> get fieldErrors {
  if (_fieldErrors is EqualUnmodifiableMapView) return _fieldErrors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_fieldErrors);
}


/// Create a copy of CloseSessionFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CloseSessionFormStateCopyWith<_CloseSessionFormState> get copyWith => __$CloseSessionFormStateCopyWithImpl<_CloseSessionFormState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CloseSessionFormState&&(identical(other.cashSessionId, cashSessionId) || other.cashSessionId == cashSessionId)&&const DeepCollectionEquality().equals(other.quantities, _quantities)&&(identical(other.countedTotal, countedTotal) || other.countedTotal == countedTotal)&&(identical(other.expectedCash, expectedCash) || other.expectedCash == expectedCash)&&(identical(other.difference, difference) || other.difference == difference)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.closed, closed) || other.closed == closed)&&(identical(other.error, error) || other.error == error)&&(identical(other.errorDetail, errorDetail) || other.errorDetail == errorDetail)&&const DeepCollectionEquality().equals(other.fieldErrors, _fieldErrors));
}


@override
int get hashCode {
    return Object.hash(runtimeType,cashSessionId,const DeepCollectionEquality().hash(_quantities),countedTotal,expectedCash,difference,submitting,closed,error,errorDetail,const DeepCollectionEquality().hash(_fieldErrors));
}

@override
String toString() {
    return 'CloseSessionFormState(cashSessionId: $cashSessionId, quantities: $quantities, countedTotal: $countedTotal, expectedCash: $expectedCash, difference: $difference, submitting: $submitting, closed: $closed, error: $error, errorDetail: $errorDetail, fieldErrors: $fieldErrors)';
}


}

/// @nodoc
abstract mixin class _$CloseSessionFormStateCopyWith<$Res> implements $CloseSessionFormStateCopyWith<$Res> {
  factory _$CloseSessionFormStateCopyWith(_CloseSessionFormState value, $Res Function(_CloseSessionFormState) _then) = __$CloseSessionFormStateCopyWithImpl;
@override @useResult
$Res call({
 int? cashSessionId, Map<String, int> quantities, String countedTotal, String expectedCash, String difference, bool submitting, bool closed, String? error, String? errorDetail, Map<String, String> fieldErrors
});




}
/// @nodoc
class __$CloseSessionFormStateCopyWithImpl<$Res>
    implements _$CloseSessionFormStateCopyWith<$Res> {
  __$CloseSessionFormStateCopyWithImpl(this._self, this._then);

  final _CloseSessionFormState _self;
  final $Res Function(_CloseSessionFormState) _then;

/// Create a copy of CloseSessionFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cashSessionId = freezed,Object? quantities = null,Object? countedTotal = null,Object? expectedCash = null,Object? difference = null,Object? submitting = null,Object? closed = null,Object? error = freezed,Object? errorDetail = freezed,Object? fieldErrors = null,}) {
  return _then(_CloseSessionFormState(
cashSessionId: freezed == cashSessionId ? _self.cashSessionId : cashSessionId // ignore: cast_nullable_to_non_nullable
as int?,quantities: null == quantities ? _self._quantities : quantities // ignore: cast_nullable_to_non_nullable
as Map<String, int>,countedTotal: null == countedTotal ? _self.countedTotal : countedTotal // ignore: cast_nullable_to_non_nullable
as String,expectedCash: null == expectedCash ? _self.expectedCash : expectedCash // ignore: cast_nullable_to_non_nullable
as String,difference: null == difference ? _self.difference : difference // ignore: cast_nullable_to_non_nullable
as String,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,closed: null == closed ? _self.closed : closed // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,errorDetail: freezed == errorDetail ? _self.errorDetail : errorDetail // ignore: cast_nullable_to_non_nullable
as String?,fieldErrors: null == fieldErrors ? _self._fieldErrors : fieldErrors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}

// dart format on
