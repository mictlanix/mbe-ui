// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'open_session_form_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OpenSessionFormState {

 int? get cashDrawerId; String get cashDrawerDisplayText; String get openingAmount; bool get submitting; bool get saved;/// The other session's id, populated only on a cashier-busy 409
/// (research.md §4) — the screen uses it to link straight to that
/// session's detail (FR-010) instead of leaving the open form as the
/// only path forward.
 int? get blockingSessionId; String? get error; String? get errorDetail; Map<String, String> get fieldErrors;
/// Create a copy of OpenSessionFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OpenSessionFormStateCopyWith<OpenSessionFormState> get copyWith => _$OpenSessionFormStateCopyWithImpl<OpenSessionFormState>(this as OpenSessionFormState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as OpenSessionFormState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OpenSessionFormState&&(identical(other.cashDrawerId, _this.cashDrawerId) || other.cashDrawerId == _this.cashDrawerId)&&(identical(other.cashDrawerDisplayText, _this.cashDrawerDisplayText) || other.cashDrawerDisplayText == _this.cashDrawerDisplayText)&&(identical(other.openingAmount, _this.openingAmount) || other.openingAmount == _this.openingAmount)&&(identical(other.submitting, _this.submitting) || other.submitting == _this.submitting)&&(identical(other.saved, _this.saved) || other.saved == _this.saved)&&(identical(other.blockingSessionId, _this.blockingSessionId) || other.blockingSessionId == _this.blockingSessionId)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.errorDetail, _this.errorDetail) || other.errorDetail == _this.errorDetail)&&const DeepCollectionEquality().equals(other.fieldErrors, _this.fieldErrors));
}


@override
int get hashCode {
  final _this = this as OpenSessionFormState;
  return Object.hash(runtimeType,_this.cashDrawerId,_this.cashDrawerDisplayText,_this.openingAmount,_this.submitting,_this.saved,_this.blockingSessionId,_this.error,_this.errorDetail,const DeepCollectionEquality().hash(_this.fieldErrors));
}

@override
String toString() {
  final _this = this as OpenSessionFormState;
  return 'OpenSessionFormState(cashDrawerId: ${_this.cashDrawerId}, cashDrawerDisplayText: ${_this.cashDrawerDisplayText}, openingAmount: ${_this.openingAmount}, submitting: ${_this.submitting}, saved: ${_this.saved}, blockingSessionId: ${_this.blockingSessionId}, error: ${_this.error}, errorDetail: ${_this.errorDetail}, fieldErrors: ${_this.fieldErrors})';
}


}

/// @nodoc
abstract mixin class $OpenSessionFormStateCopyWith<$Res>  {
  factory $OpenSessionFormStateCopyWith(OpenSessionFormState value, $Res Function(OpenSessionFormState) _then) = _$OpenSessionFormStateCopyWithImpl;
@useResult
$Res call({
 int? cashDrawerId, String cashDrawerDisplayText, String openingAmount, bool submitting, bool saved, int? blockingSessionId, String? error, String? errorDetail, Map<String, String> fieldErrors
});




}
/// @nodoc
class _$OpenSessionFormStateCopyWithImpl<$Res>
    implements $OpenSessionFormStateCopyWith<$Res> {
  _$OpenSessionFormStateCopyWithImpl(this._self, this._then);

  final OpenSessionFormState _self;
  final $Res Function(OpenSessionFormState) _then;

/// Create a copy of OpenSessionFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cashDrawerId = freezed,Object? cashDrawerDisplayText = null,Object? openingAmount = null,Object? submitting = null,Object? saved = null,Object? blockingSessionId = freezed,Object? error = freezed,Object? errorDetail = freezed,Object? fieldErrors = null,}) {
  return _then(OpenSessionFormState(
cashDrawerId: freezed == cashDrawerId ? _self.cashDrawerId : cashDrawerId // ignore: cast_nullable_to_non_nullable
as int?,cashDrawerDisplayText: null == cashDrawerDisplayText ? _self.cashDrawerDisplayText : cashDrawerDisplayText // ignore: cast_nullable_to_non_nullable
as String,openingAmount: null == openingAmount ? _self.openingAmount : openingAmount // ignore: cast_nullable_to_non_nullable
as String,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as bool,blockingSessionId: freezed == blockingSessionId ? _self.blockingSessionId : blockingSessionId // ignore: cast_nullable_to_non_nullable
as int?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,errorDetail: freezed == errorDetail ? _self.errorDetail : errorDetail // ignore: cast_nullable_to_non_nullable
as String?,fieldErrors: null == fieldErrors ? _self.fieldErrors : fieldErrors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

}


/// Adds pattern-matching-related methods to [OpenSessionFormState].
extension OpenSessionFormStatePatterns on OpenSessionFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OpenSessionFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OpenSessionFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OpenSessionFormState value)  $default,){
final _that = this;
switch (_that) {
case _OpenSessionFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OpenSessionFormState value)?  $default,){
final _that = this;
switch (_that) {
case _OpenSessionFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? cashDrawerId,  String cashDrawerDisplayText,  String openingAmount,  bool submitting,  bool saved,  int? blockingSessionId,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OpenSessionFormState() when $default != null:
return $default(_that.cashDrawerId,_that.cashDrawerDisplayText,_that.openingAmount,_that.submitting,_that.saved,_that.blockingSessionId,_that.error,_that.errorDetail,_that.fieldErrors);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? cashDrawerId,  String cashDrawerDisplayText,  String openingAmount,  bool submitting,  bool saved,  int? blockingSessionId,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)  $default,) {final _that = this;
switch (_that) {
case _OpenSessionFormState():
return $default(_that.cashDrawerId,_that.cashDrawerDisplayText,_that.openingAmount,_that.submitting,_that.saved,_that.blockingSessionId,_that.error,_that.errorDetail,_that.fieldErrors);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? cashDrawerId,  String cashDrawerDisplayText,  String openingAmount,  bool submitting,  bool saved,  int? blockingSessionId,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)?  $default,) {final _that = this;
switch (_that) {
case _OpenSessionFormState() when $default != null:
return $default(_that.cashDrawerId,_that.cashDrawerDisplayText,_that.openingAmount,_that.submitting,_that.saved,_that.blockingSessionId,_that.error,_that.errorDetail,_that.fieldErrors);case _:
  return null;

}
}

}

/// @nodoc


class _OpenSessionFormState implements OpenSessionFormState {
  const _OpenSessionFormState({this.cashDrawerId, this.cashDrawerDisplayText = '', this.openingAmount = '0', this.submitting = false, this.saved = false, this.blockingSessionId, this.error, this.errorDetail,  Map<String, String> fieldErrors = const <String, String>{}}): _fieldErrors = fieldErrors;
  

@override final  int? cashDrawerId;
@override@JsonKey() final  String cashDrawerDisplayText;
@override@JsonKey() final  String openingAmount;
@override@JsonKey() final  bool submitting;
@override@JsonKey() final  bool saved;
/// The other session's id, populated only on a cashier-busy 409
/// (research.md §4) — the screen uses it to link straight to that
/// session's detail (FR-010) instead of leaving the open form as the
/// only path forward.
@override final  int? blockingSessionId;
@override final  String? error;
@override final  String? errorDetail;
 final  Map<String, String> _fieldErrors;
@override@JsonKey() Map<String, String> get fieldErrors {
  if (_fieldErrors is EqualUnmodifiableMapView) return _fieldErrors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_fieldErrors);
}


/// Create a copy of OpenSessionFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OpenSessionFormStateCopyWith<_OpenSessionFormState> get copyWith => __$OpenSessionFormStateCopyWithImpl<_OpenSessionFormState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OpenSessionFormState&&(identical(other.cashDrawerId, cashDrawerId) || other.cashDrawerId == cashDrawerId)&&(identical(other.cashDrawerDisplayText, cashDrawerDisplayText) || other.cashDrawerDisplayText == cashDrawerDisplayText)&&(identical(other.openingAmount, openingAmount) || other.openingAmount == openingAmount)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.saved, saved) || other.saved == saved)&&(identical(other.blockingSessionId, blockingSessionId) || other.blockingSessionId == blockingSessionId)&&(identical(other.error, error) || other.error == error)&&(identical(other.errorDetail, errorDetail) || other.errorDetail == errorDetail)&&const DeepCollectionEquality().equals(other.fieldErrors, _fieldErrors));
}


@override
int get hashCode {
    return Object.hash(runtimeType,cashDrawerId,cashDrawerDisplayText,openingAmount,submitting,saved,blockingSessionId,error,errorDetail,const DeepCollectionEquality().hash(_fieldErrors));
}

@override
String toString() {
    return 'OpenSessionFormState(cashDrawerId: $cashDrawerId, cashDrawerDisplayText: $cashDrawerDisplayText, openingAmount: $openingAmount, submitting: $submitting, saved: $saved, blockingSessionId: $blockingSessionId, error: $error, errorDetail: $errorDetail, fieldErrors: $fieldErrors)';
}


}

/// @nodoc
abstract mixin class _$OpenSessionFormStateCopyWith<$Res> implements $OpenSessionFormStateCopyWith<$Res> {
  factory _$OpenSessionFormStateCopyWith(_OpenSessionFormState value, $Res Function(_OpenSessionFormState) _then) = __$OpenSessionFormStateCopyWithImpl;
@override @useResult
$Res call({
 int? cashDrawerId, String cashDrawerDisplayText, String openingAmount, bool submitting, bool saved, int? blockingSessionId, String? error, String? errorDetail, Map<String, String> fieldErrors
});




}
/// @nodoc
class __$OpenSessionFormStateCopyWithImpl<$Res>
    implements _$OpenSessionFormStateCopyWith<$Res> {
  __$OpenSessionFormStateCopyWithImpl(this._self, this._then);

  final _OpenSessionFormState _self;
  final $Res Function(_OpenSessionFormState) _then;

/// Create a copy of OpenSessionFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cashDrawerId = freezed,Object? cashDrawerDisplayText = null,Object? openingAmount = null,Object? submitting = null,Object? saved = null,Object? blockingSessionId = freezed,Object? error = freezed,Object? errorDetail = freezed,Object? fieldErrors = null,}) {
  return _then(_OpenSessionFormState(
cashDrawerId: freezed == cashDrawerId ? _self.cashDrawerId : cashDrawerId // ignore: cast_nullable_to_non_nullable
as int?,cashDrawerDisplayText: null == cashDrawerDisplayText ? _self.cashDrawerDisplayText : cashDrawerDisplayText // ignore: cast_nullable_to_non_nullable
as String,openingAmount: null == openingAmount ? _self.openingAmount : openingAmount // ignore: cast_nullable_to_non_nullable
as String,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as bool,blockingSessionId: freezed == blockingSessionId ? _self.blockingSessionId : blockingSessionId // ignore: cast_nullable_to_non_nullable
as int?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,errorDetail: freezed == errorDetail ? _self.errorDetail : errorDetail // ignore: cast_nullable_to_non_nullable
as String?,fieldErrors: null == fieldErrors ? _self._fieldErrors : fieldErrors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}

// dart format on
