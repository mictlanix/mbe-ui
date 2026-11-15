// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pending_deliveries_filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PendingDeliveriesFilter {

 PendingDeliveryPeriod get period; int get pageIndex;
/// Create a copy of PendingDeliveriesFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PendingDeliveriesFilterCopyWith<PendingDeliveriesFilter> get copyWith => _$PendingDeliveriesFilterCopyWithImpl<PendingDeliveriesFilter>(this as PendingDeliveriesFilter, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PendingDeliveriesFilter;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PendingDeliveriesFilter&&(identical(other.period, _this.period) || other.period == _this.period)&&(identical(other.pageIndex, _this.pageIndex) || other.pageIndex == _this.pageIndex));
}


@override
int get hashCode {
  final _this = this as PendingDeliveriesFilter;
  return Object.hash(runtimeType,_this.period,_this.pageIndex);
}

@override
String toString() {
  final _this = this as PendingDeliveriesFilter;
  return 'PendingDeliveriesFilter(period: ${_this.period}, pageIndex: ${_this.pageIndex})';
}


}

/// @nodoc
abstract mixin class $PendingDeliveriesFilterCopyWith<$Res>  {
  factory $PendingDeliveriesFilterCopyWith(PendingDeliveriesFilter value, $Res Function(PendingDeliveriesFilter) _then) = _$PendingDeliveriesFilterCopyWithImpl;
@useResult
$Res call({
 PendingDeliveryPeriod period, int pageIndex
});




}
/// @nodoc
class _$PendingDeliveriesFilterCopyWithImpl<$Res>
    implements $PendingDeliveriesFilterCopyWith<$Res> {
  _$PendingDeliveriesFilterCopyWithImpl(this._self, this._then);

  final PendingDeliveriesFilter _self;
  final $Res Function(PendingDeliveriesFilter) _then;

/// Create a copy of PendingDeliveriesFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? period = null,Object? pageIndex = null,}) {
  return _then(PendingDeliveriesFilter(
period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as PendingDeliveryPeriod,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PendingDeliveriesFilter].
extension PendingDeliveriesFilterPatterns on PendingDeliveriesFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PendingDeliveriesFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PendingDeliveriesFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PendingDeliveriesFilter value)  $default,){
final _that = this;
switch (_that) {
case _PendingDeliveriesFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PendingDeliveriesFilter value)?  $default,){
final _that = this;
switch (_that) {
case _PendingDeliveriesFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PendingDeliveryPeriod period,  int pageIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PendingDeliveriesFilter() when $default != null:
return $default(_that.period,_that.pageIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PendingDeliveryPeriod period,  int pageIndex)  $default,) {final _that = this;
switch (_that) {
case _PendingDeliveriesFilter():
return $default(_that.period,_that.pageIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PendingDeliveryPeriod period,  int pageIndex)?  $default,) {final _that = this;
switch (_that) {
case _PendingDeliveriesFilter() when $default != null:
return $default(_that.period,_that.pageIndex);case _:
  return null;

}
}

}

/// @nodoc


class _PendingDeliveriesFilter extends PendingDeliveriesFilter {
  const _PendingDeliveriesFilter({this.period = PendingDeliveryPeriod.today, this.pageIndex = 0}): super._();
  

@override@JsonKey() final  PendingDeliveryPeriod period;
@override@JsonKey() final  int pageIndex;

/// Create a copy of PendingDeliveriesFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PendingDeliveriesFilterCopyWith<_PendingDeliveriesFilter> get copyWith => __$PendingDeliveriesFilterCopyWithImpl<_PendingDeliveriesFilter>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PendingDeliveriesFilter&&(identical(other.period, period) || other.period == period)&&(identical(other.pageIndex, pageIndex) || other.pageIndex == pageIndex));
}


@override
int get hashCode {
    return Object.hash(runtimeType,period,pageIndex);
}

@override
String toString() {
    return 'PendingDeliveriesFilter(period: $period, pageIndex: $pageIndex)';
}


}

/// @nodoc
abstract mixin class _$PendingDeliveriesFilterCopyWith<$Res> implements $PendingDeliveriesFilterCopyWith<$Res> {
  factory _$PendingDeliveriesFilterCopyWith(_PendingDeliveriesFilter value, $Res Function(_PendingDeliveriesFilter) _then) = __$PendingDeliveriesFilterCopyWithImpl;
@override @useResult
$Res call({
 PendingDeliveryPeriod period, int pageIndex
});




}
/// @nodoc
class __$PendingDeliveriesFilterCopyWithImpl<$Res>
    implements _$PendingDeliveriesFilterCopyWith<$Res> {
  __$PendingDeliveriesFilterCopyWithImpl(this._self, this._then);

  final _PendingDeliveriesFilter _self;
  final $Res Function(_PendingDeliveriesFilter) _then;

/// Create a copy of PendingDeliveriesFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? period = null,Object? pageIndex = null,}) {
  return _then(_PendingDeliveriesFilter(
period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as PendingDeliveryPeriod,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
