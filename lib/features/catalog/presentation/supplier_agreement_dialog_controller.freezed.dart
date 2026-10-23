// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'supplier_agreement_dialog_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SupplierAgreementDialogState {

 DateTime? get start; DateTime? get end; String get comment; bool get submitting; bool get done; String? get error; String? get errorDetail; Map<String, String> get fieldErrors;
/// Create a copy of SupplierAgreementDialogState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SupplierAgreementDialogStateCopyWith<SupplierAgreementDialogState> get copyWith => _$SupplierAgreementDialogStateCopyWithImpl<SupplierAgreementDialogState>(this as SupplierAgreementDialogState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SupplierAgreementDialogState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SupplierAgreementDialogState&&(identical(other.start, _this.start) || other.start == _this.start)&&(identical(other.end, _this.end) || other.end == _this.end)&&(identical(other.comment, _this.comment) || other.comment == _this.comment)&&(identical(other.submitting, _this.submitting) || other.submitting == _this.submitting)&&(identical(other.done, _this.done) || other.done == _this.done)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.errorDetail, _this.errorDetail) || other.errorDetail == _this.errorDetail)&&const DeepCollectionEquality().equals(other.fieldErrors, _this.fieldErrors));
}


@override
int get hashCode {
  final _this = this as SupplierAgreementDialogState;
  return Object.hash(runtimeType,_this.start,_this.end,_this.comment,_this.submitting,_this.done,_this.error,_this.errorDetail,const DeepCollectionEquality().hash(_this.fieldErrors));
}

@override
String toString() {
  final _this = this as SupplierAgreementDialogState;
  return 'SupplierAgreementDialogState(start: ${_this.start}, end: ${_this.end}, comment: ${_this.comment}, submitting: ${_this.submitting}, done: ${_this.done}, error: ${_this.error}, errorDetail: ${_this.errorDetail}, fieldErrors: ${_this.fieldErrors})';
}


}

/// @nodoc
abstract mixin class $SupplierAgreementDialogStateCopyWith<$Res>  {
  factory $SupplierAgreementDialogStateCopyWith(SupplierAgreementDialogState value, $Res Function(SupplierAgreementDialogState) _then) = _$SupplierAgreementDialogStateCopyWithImpl;
@useResult
$Res call({
 DateTime? start, DateTime? end, String comment, bool submitting, bool done, String? error, String? errorDetail, Map<String, String> fieldErrors
});




}
/// @nodoc
class _$SupplierAgreementDialogStateCopyWithImpl<$Res>
    implements $SupplierAgreementDialogStateCopyWith<$Res> {
  _$SupplierAgreementDialogStateCopyWithImpl(this._self, this._then);

  final SupplierAgreementDialogState _self;
  final $Res Function(SupplierAgreementDialogState) _then;

/// Create a copy of SupplierAgreementDialogState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? start = freezed,Object? end = freezed,Object? comment = null,Object? submitting = null,Object? done = null,Object? error = freezed,Object? errorDetail = freezed,Object? fieldErrors = null,}) {
  return _then(SupplierAgreementDialogState(
start: freezed == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime?,end: freezed == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as DateTime?,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,done: null == done ? _self.done : done // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,errorDetail: freezed == errorDetail ? _self.errorDetail : errorDetail // ignore: cast_nullable_to_non_nullable
as String?,fieldErrors: null == fieldErrors ? _self.fieldErrors : fieldErrors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

}


/// Adds pattern-matching-related methods to [SupplierAgreementDialogState].
extension SupplierAgreementDialogStatePatterns on SupplierAgreementDialogState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SupplierAgreementDialogState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SupplierAgreementDialogState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SupplierAgreementDialogState value)  $default,){
final _that = this;
switch (_that) {
case _SupplierAgreementDialogState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SupplierAgreementDialogState value)?  $default,){
final _that = this;
switch (_that) {
case _SupplierAgreementDialogState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime? start,  DateTime? end,  String comment,  bool submitting,  bool done,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SupplierAgreementDialogState() when $default != null:
return $default(_that.start,_that.end,_that.comment,_that.submitting,_that.done,_that.error,_that.errorDetail,_that.fieldErrors);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime? start,  DateTime? end,  String comment,  bool submitting,  bool done,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)  $default,) {final _that = this;
switch (_that) {
case _SupplierAgreementDialogState():
return $default(_that.start,_that.end,_that.comment,_that.submitting,_that.done,_that.error,_that.errorDetail,_that.fieldErrors);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime? start,  DateTime? end,  String comment,  bool submitting,  bool done,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)?  $default,) {final _that = this;
switch (_that) {
case _SupplierAgreementDialogState() when $default != null:
return $default(_that.start,_that.end,_that.comment,_that.submitting,_that.done,_that.error,_that.errorDetail,_that.fieldErrors);case _:
  return null;

}
}

}

/// @nodoc


class _SupplierAgreementDialogState extends SupplierAgreementDialogState {
  const _SupplierAgreementDialogState({this.start, this.end, this.comment = '', this.submitting = false, this.done = false, this.error, this.errorDetail,  Map<String, String> fieldErrors = const <String, String>{}}): _fieldErrors = fieldErrors,super._();
  

@override final  DateTime? start;
@override final  DateTime? end;
@override@JsonKey() final  String comment;
@override@JsonKey() final  bool submitting;
@override@JsonKey() final  bool done;
@override final  String? error;
@override final  String? errorDetail;
 final  Map<String, String> _fieldErrors;
@override@JsonKey() Map<String, String> get fieldErrors {
  if (_fieldErrors is EqualUnmodifiableMapView) return _fieldErrors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_fieldErrors);
}


/// Create a copy of SupplierAgreementDialogState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SupplierAgreementDialogStateCopyWith<_SupplierAgreementDialogState> get copyWith => __$SupplierAgreementDialogStateCopyWithImpl<_SupplierAgreementDialogState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SupplierAgreementDialogState&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.done, done) || other.done == done)&&(identical(other.error, error) || other.error == error)&&(identical(other.errorDetail, errorDetail) || other.errorDetail == errorDetail)&&const DeepCollectionEquality().equals(other.fieldErrors, _fieldErrors));
}


@override
int get hashCode {
    return Object.hash(runtimeType,start,end,comment,submitting,done,error,errorDetail,const DeepCollectionEquality().hash(_fieldErrors));
}

@override
String toString() {
    return 'SupplierAgreementDialogState(start: $start, end: $end, comment: $comment, submitting: $submitting, done: $done, error: $error, errorDetail: $errorDetail, fieldErrors: $fieldErrors)';
}


}

/// @nodoc
abstract mixin class _$SupplierAgreementDialogStateCopyWith<$Res> implements $SupplierAgreementDialogStateCopyWith<$Res> {
  factory _$SupplierAgreementDialogStateCopyWith(_SupplierAgreementDialogState value, $Res Function(_SupplierAgreementDialogState) _then) = __$SupplierAgreementDialogStateCopyWithImpl;
@override @useResult
$Res call({
 DateTime? start, DateTime? end, String comment, bool submitting, bool done, String? error, String? errorDetail, Map<String, String> fieldErrors
});




}
/// @nodoc
class __$SupplierAgreementDialogStateCopyWithImpl<$Res>
    implements _$SupplierAgreementDialogStateCopyWith<$Res> {
  __$SupplierAgreementDialogStateCopyWithImpl(this._self, this._then);

  final _SupplierAgreementDialogState _self;
  final $Res Function(_SupplierAgreementDialogState) _then;

/// Create a copy of SupplierAgreementDialogState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? start = freezed,Object? end = freezed,Object? comment = null,Object? submitting = null,Object? done = null,Object? error = freezed,Object? errorDetail = freezed,Object? fieldErrors = null,}) {
  return _then(_SupplierAgreementDialogState(
start: freezed == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime?,end: freezed == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as DateTime?,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,done: null == done ? _self.done : done // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,errorDetail: freezed == errorDetail ? _self.errorDetail : errorDetail // ignore: cast_nullable_to_non_nullable
as String?,fieldErrors: null == fieldErrors ? _self._fieldErrors : fieldErrors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}

// dart format on
