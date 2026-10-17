// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exchange_rates_list_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ExchangeRateFilter {

 DateTime? get dateFrom; DateTime? get dateTo; int? get base; int? get target; int get pageIndex;
/// Create a copy of ExchangeRateFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExchangeRateFilterCopyWith<ExchangeRateFilter> get copyWith => _$ExchangeRateFilterCopyWithImpl<ExchangeRateFilter>(this as ExchangeRateFilter, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ExchangeRateFilter;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExchangeRateFilter&&(identical(other.dateFrom, _this.dateFrom) || other.dateFrom == _this.dateFrom)&&(identical(other.dateTo, _this.dateTo) || other.dateTo == _this.dateTo)&&(identical(other.base, _this.base) || other.base == _this.base)&&(identical(other.target, _this.target) || other.target == _this.target)&&(identical(other.pageIndex, _this.pageIndex) || other.pageIndex == _this.pageIndex));
}


@override
int get hashCode {
  final _this = this as ExchangeRateFilter;
  return Object.hash(runtimeType,_this.dateFrom,_this.dateTo,_this.base,_this.target,_this.pageIndex);
}

@override
String toString() {
  final _this = this as ExchangeRateFilter;
  return 'ExchangeRateFilter(dateFrom: ${_this.dateFrom}, dateTo: ${_this.dateTo}, base: ${_this.base}, target: ${_this.target}, pageIndex: ${_this.pageIndex})';
}


}

/// @nodoc
abstract mixin class $ExchangeRateFilterCopyWith<$Res>  {
  factory $ExchangeRateFilterCopyWith(ExchangeRateFilter value, $Res Function(ExchangeRateFilter) _then) = _$ExchangeRateFilterCopyWithImpl;
@useResult
$Res call({
 DateTime? dateFrom, DateTime? dateTo, int? base, int? target, int pageIndex
});




}
/// @nodoc
class _$ExchangeRateFilterCopyWithImpl<$Res>
    implements $ExchangeRateFilterCopyWith<$Res> {
  _$ExchangeRateFilterCopyWithImpl(this._self, this._then);

  final ExchangeRateFilter _self;
  final $Res Function(ExchangeRateFilter) _then;

/// Create a copy of ExchangeRateFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dateFrom = freezed,Object? dateTo = freezed,Object? base = freezed,Object? target = freezed,Object? pageIndex = null,}) {
  return _then(ExchangeRateFilter(
dateFrom: freezed == dateFrom ? _self.dateFrom : dateFrom // ignore: cast_nullable_to_non_nullable
as DateTime?,dateTo: freezed == dateTo ? _self.dateTo : dateTo // ignore: cast_nullable_to_non_nullable
as DateTime?,base: freezed == base ? _self.base : base // ignore: cast_nullable_to_non_nullable
as int?,target: freezed == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as int?,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ExchangeRateFilter].
extension ExchangeRateFilterPatterns on ExchangeRateFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExchangeRateFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExchangeRateFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExchangeRateFilter value)  $default,){
final _that = this;
switch (_that) {
case _ExchangeRateFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExchangeRateFilter value)?  $default,){
final _that = this;
switch (_that) {
case _ExchangeRateFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime? dateFrom,  DateTime? dateTo,  int? base,  int? target,  int pageIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExchangeRateFilter() when $default != null:
return $default(_that.dateFrom,_that.dateTo,_that.base,_that.target,_that.pageIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime? dateFrom,  DateTime? dateTo,  int? base,  int? target,  int pageIndex)  $default,) {final _that = this;
switch (_that) {
case _ExchangeRateFilter():
return $default(_that.dateFrom,_that.dateTo,_that.base,_that.target,_that.pageIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime? dateFrom,  DateTime? dateTo,  int? base,  int? target,  int pageIndex)?  $default,) {final _that = this;
switch (_that) {
case _ExchangeRateFilter() when $default != null:
return $default(_that.dateFrom,_that.dateTo,_that.base,_that.target,_that.pageIndex);case _:
  return null;

}
}

}

/// @nodoc


class _ExchangeRateFilter implements ExchangeRateFilter {
  const _ExchangeRateFilter({this.dateFrom, this.dateTo, this.base, this.target, this.pageIndex = 0});
  

@override final  DateTime? dateFrom;
@override final  DateTime? dateTo;
@override final  int? base;
@override final  int? target;
@override@JsonKey() final  int pageIndex;

/// Create a copy of ExchangeRateFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExchangeRateFilterCopyWith<_ExchangeRateFilter> get copyWith => __$ExchangeRateFilterCopyWithImpl<_ExchangeRateFilter>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExchangeRateFilter&&(identical(other.dateFrom, dateFrom) || other.dateFrom == dateFrom)&&(identical(other.dateTo, dateTo) || other.dateTo == dateTo)&&(identical(other.base, base) || other.base == base)&&(identical(other.target, target) || other.target == target)&&(identical(other.pageIndex, pageIndex) || other.pageIndex == pageIndex));
}


@override
int get hashCode {
    return Object.hash(runtimeType,dateFrom,dateTo,base,target,pageIndex);
}

@override
String toString() {
    return 'ExchangeRateFilter(dateFrom: $dateFrom, dateTo: $dateTo, base: $base, target: $target, pageIndex: $pageIndex)';
}


}

/// @nodoc
abstract mixin class _$ExchangeRateFilterCopyWith<$Res> implements $ExchangeRateFilterCopyWith<$Res> {
  factory _$ExchangeRateFilterCopyWith(_ExchangeRateFilter value, $Res Function(_ExchangeRateFilter) _then) = __$ExchangeRateFilterCopyWithImpl;
@override @useResult
$Res call({
 DateTime? dateFrom, DateTime? dateTo, int? base, int? target, int pageIndex
});




}
/// @nodoc
class __$ExchangeRateFilterCopyWithImpl<$Res>
    implements _$ExchangeRateFilterCopyWith<$Res> {
  __$ExchangeRateFilterCopyWithImpl(this._self, this._then);

  final _ExchangeRateFilter _self;
  final $Res Function(_ExchangeRateFilter) _then;

/// Create a copy of ExchangeRateFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dateFrom = freezed,Object? dateTo = freezed,Object? base = freezed,Object? target = freezed,Object? pageIndex = null,}) {
  return _then(_ExchangeRateFilter(
dateFrom: freezed == dateFrom ? _self.dateFrom : dateFrom // ignore: cast_nullable_to_non_nullable
as DateTime?,dateTo: freezed == dateTo ? _self.dateTo : dateTo // ignore: cast_nullable_to_non_nullable
as DateTime?,base: freezed == base ? _self.base : base // ignore: cast_nullable_to_non_nullable
as int?,target: freezed == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as int?,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
