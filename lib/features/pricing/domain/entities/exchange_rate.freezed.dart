// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exchange_rate.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ExchangeRate {

 int get exchangeRateId; DateTime get date; String get rate; int get rawBase; int get rawTarget; Currency? get base; Currency? get target;
/// Create a copy of ExchangeRate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExchangeRateCopyWith<ExchangeRate> get copyWith => _$ExchangeRateCopyWithImpl<ExchangeRate>(this as ExchangeRate, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ExchangeRate;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExchangeRate&&(identical(other.exchangeRateId, _this.exchangeRateId) || other.exchangeRateId == _this.exchangeRateId)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.rate, _this.rate) || other.rate == _this.rate)&&(identical(other.rawBase, _this.rawBase) || other.rawBase == _this.rawBase)&&(identical(other.rawTarget, _this.rawTarget) || other.rawTarget == _this.rawTarget)&&(identical(other.base, _this.base) || other.base == _this.base)&&(identical(other.target, _this.target) || other.target == _this.target));
}


@override
int get hashCode {
  final _this = this as ExchangeRate;
  return Object.hash(runtimeType,_this.exchangeRateId,_this.date,_this.rate,_this.rawBase,_this.rawTarget,_this.base,_this.target);
}

@override
String toString() {
  final _this = this as ExchangeRate;
  return 'ExchangeRate(exchangeRateId: ${_this.exchangeRateId}, date: ${_this.date}, rate: ${_this.rate}, rawBase: ${_this.rawBase}, rawTarget: ${_this.rawTarget}, base: ${_this.base}, target: ${_this.target})';
}


}

/// @nodoc
abstract mixin class $ExchangeRateCopyWith<$Res>  {
  factory $ExchangeRateCopyWith(ExchangeRate value, $Res Function(ExchangeRate) _then) = _$ExchangeRateCopyWithImpl;
@useResult
$Res call({
 int exchangeRateId, DateTime date, String rate, int rawBase, int rawTarget, Currency? base, Currency? target
});




}
/// @nodoc
class _$ExchangeRateCopyWithImpl<$Res>
    implements $ExchangeRateCopyWith<$Res> {
  _$ExchangeRateCopyWithImpl(this._self, this._then);

  final ExchangeRate _self;
  final $Res Function(ExchangeRate) _then;

/// Create a copy of ExchangeRate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? exchangeRateId = null,Object? date = null,Object? rate = null,Object? rawBase = null,Object? rawTarget = null,Object? base = freezed,Object? target = freezed,}) {
  return _then(ExchangeRate(
exchangeRateId: null == exchangeRateId ? _self.exchangeRateId : exchangeRateId // ignore: cast_nullable_to_non_nullable
as int,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,rate: null == rate ? _self.rate : rate // ignore: cast_nullable_to_non_nullable
as String,rawBase: null == rawBase ? _self.rawBase : rawBase // ignore: cast_nullable_to_non_nullable
as int,rawTarget: null == rawTarget ? _self.rawTarget : rawTarget // ignore: cast_nullable_to_non_nullable
as int,base: freezed == base ? _self.base : base // ignore: cast_nullable_to_non_nullable
as Currency?,target: freezed == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as Currency?,
  ));
}

}


/// Adds pattern-matching-related methods to [ExchangeRate].
extension ExchangeRatePatterns on ExchangeRate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExchangeRate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExchangeRate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExchangeRate value)  $default,){
final _that = this;
switch (_that) {
case _ExchangeRate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExchangeRate value)?  $default,){
final _that = this;
switch (_that) {
case _ExchangeRate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int exchangeRateId,  DateTime date,  String rate,  int rawBase,  int rawTarget,  Currency? base,  Currency? target)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExchangeRate() when $default != null:
return $default(_that.exchangeRateId,_that.date,_that.rate,_that.rawBase,_that.rawTarget,_that.base,_that.target);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int exchangeRateId,  DateTime date,  String rate,  int rawBase,  int rawTarget,  Currency? base,  Currency? target)  $default,) {final _that = this;
switch (_that) {
case _ExchangeRate():
return $default(_that.exchangeRateId,_that.date,_that.rate,_that.rawBase,_that.rawTarget,_that.base,_that.target);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int exchangeRateId,  DateTime date,  String rate,  int rawBase,  int rawTarget,  Currency? base,  Currency? target)?  $default,) {final _that = this;
switch (_that) {
case _ExchangeRate() when $default != null:
return $default(_that.exchangeRateId,_that.date,_that.rate,_that.rawBase,_that.rawTarget,_that.base,_that.target);case _:
  return null;

}
}

}

/// @nodoc


class _ExchangeRate implements ExchangeRate {
  const _ExchangeRate({required this.exchangeRateId, required this.date, required this.rate, required this.rawBase, required this.rawTarget, this.base, this.target});
  

@override final  int exchangeRateId;
@override final  DateTime date;
@override final  String rate;
@override final  int rawBase;
@override final  int rawTarget;
@override final  Currency? base;
@override final  Currency? target;

/// Create a copy of ExchangeRate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExchangeRateCopyWith<_ExchangeRate> get copyWith => __$ExchangeRateCopyWithImpl<_ExchangeRate>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExchangeRate&&(identical(other.exchangeRateId, exchangeRateId) || other.exchangeRateId == exchangeRateId)&&(identical(other.date, date) || other.date == date)&&(identical(other.rate, rate) || other.rate == rate)&&(identical(other.rawBase, rawBase) || other.rawBase == rawBase)&&(identical(other.rawTarget, rawTarget) || other.rawTarget == rawTarget)&&(identical(other.base, base) || other.base == base)&&(identical(other.target, target) || other.target == target));
}


@override
int get hashCode {
    return Object.hash(runtimeType,exchangeRateId,date,rate,rawBase,rawTarget,base,target);
}

@override
String toString() {
    return 'ExchangeRate(exchangeRateId: $exchangeRateId, date: $date, rate: $rate, rawBase: $rawBase, rawTarget: $rawTarget, base: $base, target: $target)';
}


}

/// @nodoc
abstract mixin class _$ExchangeRateCopyWith<$Res> implements $ExchangeRateCopyWith<$Res> {
  factory _$ExchangeRateCopyWith(_ExchangeRate value, $Res Function(_ExchangeRate) _then) = __$ExchangeRateCopyWithImpl;
@override @useResult
$Res call({
 int exchangeRateId, DateTime date, String rate, int rawBase, int rawTarget, Currency? base, Currency? target
});




}
/// @nodoc
class __$ExchangeRateCopyWithImpl<$Res>
    implements _$ExchangeRateCopyWith<$Res> {
  __$ExchangeRateCopyWithImpl(this._self, this._then);

  final _ExchangeRate _self;
  final $Res Function(_ExchangeRate) _then;

/// Create a copy of ExchangeRate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? exchangeRateId = null,Object? date = null,Object? rate = null,Object? rawBase = null,Object? rawTarget = null,Object? base = freezed,Object? target = freezed,}) {
  return _then(_ExchangeRate(
exchangeRateId: null == exchangeRateId ? _self.exchangeRateId : exchangeRateId // ignore: cast_nullable_to_non_nullable
as int,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,rate: null == rate ? _self.rate : rate // ignore: cast_nullable_to_non_nullable
as String,rawBase: null == rawBase ? _self.rawBase : rawBase // ignore: cast_nullable_to_non_nullable
as int,rawTarget: null == rawTarget ? _self.rawTarget : rawTarget // ignore: cast_nullable_to_non_nullable
as int,base: freezed == base ? _self.base : base // ignore: cast_nullable_to_non_nullable
as Currency?,target: freezed == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as Currency?,
  ));
}


}

// dart format on
