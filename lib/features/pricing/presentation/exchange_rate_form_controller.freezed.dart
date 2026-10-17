// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exchange_rate_form_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ExchangeRateFormState {

 int? get exchangeRateId; DateTime? get date; String get rate; Currency? get base; Currency? get target; bool get loading; bool get submitting; bool get saved; bool get deleted; String? get error; String? get errorDetail; Map<String, String> get fieldErrors;
/// Create a copy of ExchangeRateFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExchangeRateFormStateCopyWith<ExchangeRateFormState> get copyWith => _$ExchangeRateFormStateCopyWithImpl<ExchangeRateFormState>(this as ExchangeRateFormState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ExchangeRateFormState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExchangeRateFormState&&(identical(other.exchangeRateId, _this.exchangeRateId) || other.exchangeRateId == _this.exchangeRateId)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.rate, _this.rate) || other.rate == _this.rate)&&(identical(other.base, _this.base) || other.base == _this.base)&&(identical(other.target, _this.target) || other.target == _this.target)&&(identical(other.loading, _this.loading) || other.loading == _this.loading)&&(identical(other.submitting, _this.submitting) || other.submitting == _this.submitting)&&(identical(other.saved, _this.saved) || other.saved == _this.saved)&&(identical(other.deleted, _this.deleted) || other.deleted == _this.deleted)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.errorDetail, _this.errorDetail) || other.errorDetail == _this.errorDetail)&&const DeepCollectionEquality().equals(other.fieldErrors, _this.fieldErrors));
}


@override
int get hashCode {
  final _this = this as ExchangeRateFormState;
  return Object.hash(runtimeType,_this.exchangeRateId,_this.date,_this.rate,_this.base,_this.target,_this.loading,_this.submitting,_this.saved,_this.deleted,_this.error,_this.errorDetail,const DeepCollectionEquality().hash(_this.fieldErrors));
}

@override
String toString() {
  final _this = this as ExchangeRateFormState;
  return 'ExchangeRateFormState(exchangeRateId: ${_this.exchangeRateId}, date: ${_this.date}, rate: ${_this.rate}, base: ${_this.base}, target: ${_this.target}, loading: ${_this.loading}, submitting: ${_this.submitting}, saved: ${_this.saved}, deleted: ${_this.deleted}, error: ${_this.error}, errorDetail: ${_this.errorDetail}, fieldErrors: ${_this.fieldErrors})';
}


}

/// @nodoc
abstract mixin class $ExchangeRateFormStateCopyWith<$Res>  {
  factory $ExchangeRateFormStateCopyWith(ExchangeRateFormState value, $Res Function(ExchangeRateFormState) _then) = _$ExchangeRateFormStateCopyWithImpl;
@useResult
$Res call({
 int? exchangeRateId, DateTime? date, String rate, Currency? base, Currency? target, bool loading, bool submitting, bool saved, bool deleted, String? error, String? errorDetail, Map<String, String> fieldErrors
});




}
/// @nodoc
class _$ExchangeRateFormStateCopyWithImpl<$Res>
    implements $ExchangeRateFormStateCopyWith<$Res> {
  _$ExchangeRateFormStateCopyWithImpl(this._self, this._then);

  final ExchangeRateFormState _self;
  final $Res Function(ExchangeRateFormState) _then;

/// Create a copy of ExchangeRateFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? exchangeRateId = freezed,Object? date = freezed,Object? rate = null,Object? base = freezed,Object? target = freezed,Object? loading = null,Object? submitting = null,Object? saved = null,Object? deleted = null,Object? error = freezed,Object? errorDetail = freezed,Object? fieldErrors = null,}) {
  return _then(ExchangeRateFormState(
exchangeRateId: freezed == exchangeRateId ? _self.exchangeRateId : exchangeRateId // ignore: cast_nullable_to_non_nullable
as int?,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime?,rate: null == rate ? _self.rate : rate // ignore: cast_nullable_to_non_nullable
as String,base: freezed == base ? _self.base : base // ignore: cast_nullable_to_non_nullable
as Currency?,target: freezed == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as Currency?,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
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


/// Adds pattern-matching-related methods to [ExchangeRateFormState].
extension ExchangeRateFormStatePatterns on ExchangeRateFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExchangeRateFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExchangeRateFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExchangeRateFormState value)  $default,){
final _that = this;
switch (_that) {
case _ExchangeRateFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExchangeRateFormState value)?  $default,){
final _that = this;
switch (_that) {
case _ExchangeRateFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? exchangeRateId,  DateTime? date,  String rate,  Currency? base,  Currency? target,  bool loading,  bool submitting,  bool saved,  bool deleted,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExchangeRateFormState() when $default != null:
return $default(_that.exchangeRateId,_that.date,_that.rate,_that.base,_that.target,_that.loading,_that.submitting,_that.saved,_that.deleted,_that.error,_that.errorDetail,_that.fieldErrors);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? exchangeRateId,  DateTime? date,  String rate,  Currency? base,  Currency? target,  bool loading,  bool submitting,  bool saved,  bool deleted,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)  $default,) {final _that = this;
switch (_that) {
case _ExchangeRateFormState():
return $default(_that.exchangeRateId,_that.date,_that.rate,_that.base,_that.target,_that.loading,_that.submitting,_that.saved,_that.deleted,_that.error,_that.errorDetail,_that.fieldErrors);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? exchangeRateId,  DateTime? date,  String rate,  Currency? base,  Currency? target,  bool loading,  bool submitting,  bool saved,  bool deleted,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)?  $default,) {final _that = this;
switch (_that) {
case _ExchangeRateFormState() when $default != null:
return $default(_that.exchangeRateId,_that.date,_that.rate,_that.base,_that.target,_that.loading,_that.submitting,_that.saved,_that.deleted,_that.error,_that.errorDetail,_that.fieldErrors);case _:
  return null;

}
}

}

/// @nodoc


class _ExchangeRateFormState implements ExchangeRateFormState {
  const _ExchangeRateFormState({this.exchangeRateId, this.date, this.rate = '', this.base, this.target, this.loading = false, this.submitting = false, this.saved = false, this.deleted = false, this.error, this.errorDetail,  Map<String, String> fieldErrors = const <String, String>{}}): _fieldErrors = fieldErrors;
  

@override final  int? exchangeRateId;
@override final  DateTime? date;
@override@JsonKey() final  String rate;
@override final  Currency? base;
@override final  Currency? target;
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


/// Create a copy of ExchangeRateFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExchangeRateFormStateCopyWith<_ExchangeRateFormState> get copyWith => __$ExchangeRateFormStateCopyWithImpl<_ExchangeRateFormState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExchangeRateFormState&&(identical(other.exchangeRateId, exchangeRateId) || other.exchangeRateId == exchangeRateId)&&(identical(other.date, date) || other.date == date)&&(identical(other.rate, rate) || other.rate == rate)&&(identical(other.base, base) || other.base == base)&&(identical(other.target, target) || other.target == target)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.saved, saved) || other.saved == saved)&&(identical(other.deleted, deleted) || other.deleted == deleted)&&(identical(other.error, error) || other.error == error)&&(identical(other.errorDetail, errorDetail) || other.errorDetail == errorDetail)&&const DeepCollectionEquality().equals(other.fieldErrors, _fieldErrors));
}


@override
int get hashCode {
    return Object.hash(runtimeType,exchangeRateId,date,rate,base,target,loading,submitting,saved,deleted,error,errorDetail,const DeepCollectionEquality().hash(_fieldErrors));
}

@override
String toString() {
    return 'ExchangeRateFormState(exchangeRateId: $exchangeRateId, date: $date, rate: $rate, base: $base, target: $target, loading: $loading, submitting: $submitting, saved: $saved, deleted: $deleted, error: $error, errorDetail: $errorDetail, fieldErrors: $fieldErrors)';
}


}

/// @nodoc
abstract mixin class _$ExchangeRateFormStateCopyWith<$Res> implements $ExchangeRateFormStateCopyWith<$Res> {
  factory _$ExchangeRateFormStateCopyWith(_ExchangeRateFormState value, $Res Function(_ExchangeRateFormState) _then) = __$ExchangeRateFormStateCopyWithImpl;
@override @useResult
$Res call({
 int? exchangeRateId, DateTime? date, String rate, Currency? base, Currency? target, bool loading, bool submitting, bool saved, bool deleted, String? error, String? errorDetail, Map<String, String> fieldErrors
});




}
/// @nodoc
class __$ExchangeRateFormStateCopyWithImpl<$Res>
    implements _$ExchangeRateFormStateCopyWith<$Res> {
  __$ExchangeRateFormStateCopyWithImpl(this._self, this._then);

  final _ExchangeRateFormState _self;
  final $Res Function(_ExchangeRateFormState) _then;

/// Create a copy of ExchangeRateFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? exchangeRateId = freezed,Object? date = freezed,Object? rate = null,Object? base = freezed,Object? target = freezed,Object? loading = null,Object? submitting = null,Object? saved = null,Object? deleted = null,Object? error = freezed,Object? errorDetail = freezed,Object? fieldErrors = null,}) {
  return _then(_ExchangeRateFormState(
exchangeRateId: freezed == exchangeRateId ? _self.exchangeRateId : exchangeRateId // ignore: cast_nullable_to_non_nullable
as int?,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime?,rate: null == rate ? _self.rate : rate // ignore: cast_nullable_to_non_nullable
as String,base: freezed == base ? _self.base : base // ignore: cast_nullable_to_non_nullable
as Currency?,target: freezed == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as Currency?,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
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
