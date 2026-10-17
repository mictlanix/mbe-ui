// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'denomination_count.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DenominationCount {

 String get denomination; int get quantity;
/// Create a copy of DenominationCount
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DenominationCountCopyWith<DenominationCount> get copyWith => _$DenominationCountCopyWithImpl<DenominationCount>(this as DenominationCount, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DenominationCount;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DenominationCount&&(identical(other.denomination, _this.denomination) || other.denomination == _this.denomination)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity));
}


@override
int get hashCode {
  final _this = this as DenominationCount;
  return Object.hash(runtimeType,_this.denomination,_this.quantity);
}

@override
String toString() {
  final _this = this as DenominationCount;
  return 'DenominationCount(denomination: ${_this.denomination}, quantity: ${_this.quantity})';
}


}

/// @nodoc
abstract mixin class $DenominationCountCopyWith<$Res>  {
  factory $DenominationCountCopyWith(DenominationCount value, $Res Function(DenominationCount) _then) = _$DenominationCountCopyWithImpl;
@useResult
$Res call({
 String denomination, int quantity
});




}
/// @nodoc
class _$DenominationCountCopyWithImpl<$Res>
    implements $DenominationCountCopyWith<$Res> {
  _$DenominationCountCopyWithImpl(this._self, this._then);

  final DenominationCount _self;
  final $Res Function(DenominationCount) _then;

/// Create a copy of DenominationCount
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? denomination = null,Object? quantity = null,}) {
  return _then(DenominationCount(
denomination: null == denomination ? _self.denomination : denomination // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DenominationCount].
extension DenominationCountPatterns on DenominationCount {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DenominationCount value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DenominationCount() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DenominationCount value)  $default,){
final _that = this;
switch (_that) {
case _DenominationCount():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DenominationCount value)?  $default,){
final _that = this;
switch (_that) {
case _DenominationCount() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String denomination,  int quantity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DenominationCount() when $default != null:
return $default(_that.denomination,_that.quantity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String denomination,  int quantity)  $default,) {final _that = this;
switch (_that) {
case _DenominationCount():
return $default(_that.denomination,_that.quantity);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String denomination,  int quantity)?  $default,) {final _that = this;
switch (_that) {
case _DenominationCount() when $default != null:
return $default(_that.denomination,_that.quantity);case _:
  return null;

}
}

}

/// @nodoc


class _DenominationCount implements DenominationCount {
  const _DenominationCount({required this.denomination, required this.quantity});
  

@override final  String denomination;
@override final  int quantity;

/// Create a copy of DenominationCount
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DenominationCountCopyWith<_DenominationCount> get copyWith => __$DenominationCountCopyWithImpl<_DenominationCount>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DenominationCount&&(identical(other.denomination, denomination) || other.denomination == denomination)&&(identical(other.quantity, quantity) || other.quantity == quantity));
}


@override
int get hashCode {
    return Object.hash(runtimeType,denomination,quantity);
}

@override
String toString() {
    return 'DenominationCount(denomination: $denomination, quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class _$DenominationCountCopyWith<$Res> implements $DenominationCountCopyWith<$Res> {
  factory _$DenominationCountCopyWith(_DenominationCount value, $Res Function(_DenominationCount) _then) = __$DenominationCountCopyWithImpl;
@override @useResult
$Res call({
 String denomination, int quantity
});




}
/// @nodoc
class __$DenominationCountCopyWithImpl<$Res>
    implements _$DenominationCountCopyWith<$Res> {
  __$DenominationCountCopyWithImpl(this._self, this._then);

  final _DenominationCount _self;
  final $Res Function(_DenominationCount) _then;

/// Create a copy of DenominationCount
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? denomination = null,Object? quantity = null,}) {
  return _then(_DenominationCount(
denomination: null == denomination ? _self.denomination : denomination // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
