// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pos_sales_list_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PosSalesFilter {

 DateTime get from; DateTime get to; SaleStatus? get status; String get search; int get pageIndex;
/// Create a copy of PosSalesFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PosSalesFilterCopyWith<PosSalesFilter> get copyWith => _$PosSalesFilterCopyWithImpl<PosSalesFilter>(this as PosSalesFilter, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PosSalesFilter;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PosSalesFilter&&(identical(other.from, _this.from) || other.from == _this.from)&&(identical(other.to, _this.to) || other.to == _this.to)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.search, _this.search) || other.search == _this.search)&&(identical(other.pageIndex, _this.pageIndex) || other.pageIndex == _this.pageIndex));
}


@override
int get hashCode {
  final _this = this as PosSalesFilter;
  return Object.hash(runtimeType,_this.from,_this.to,_this.status,_this.search,_this.pageIndex);
}

@override
String toString() {
  final _this = this as PosSalesFilter;
  return 'PosSalesFilter(from: ${_this.from}, to: ${_this.to}, status: ${_this.status}, search: ${_this.search}, pageIndex: ${_this.pageIndex})';
}


}

/// @nodoc
abstract mixin class $PosSalesFilterCopyWith<$Res>  {
  factory $PosSalesFilterCopyWith(PosSalesFilter value, $Res Function(PosSalesFilter) _then) = _$PosSalesFilterCopyWithImpl;
@useResult
$Res call({
 DateTime from, DateTime to, SaleStatus? status, String search, int pageIndex
});




}
/// @nodoc
class _$PosSalesFilterCopyWithImpl<$Res>
    implements $PosSalesFilterCopyWith<$Res> {
  _$PosSalesFilterCopyWithImpl(this._self, this._then);

  final PosSalesFilter _self;
  final $Res Function(PosSalesFilter) _then;

/// Create a copy of PosSalesFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? from = null,Object? to = null,Object? status = freezed,Object? search = null,Object? pageIndex = null,}) {
  return _then(PosSalesFilter(
from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SaleStatus?,search: null == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PosSalesFilter].
extension PosSalesFilterPatterns on PosSalesFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PosSalesFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PosSalesFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PosSalesFilter value)  $default,){
final _that = this;
switch (_that) {
case _PosSalesFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PosSalesFilter value)?  $default,){
final _that = this;
switch (_that) {
case _PosSalesFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime from,  DateTime to,  SaleStatus? status,  String search,  int pageIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PosSalesFilter() when $default != null:
return $default(_that.from,_that.to,_that.status,_that.search,_that.pageIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime from,  DateTime to,  SaleStatus? status,  String search,  int pageIndex)  $default,) {final _that = this;
switch (_that) {
case _PosSalesFilter():
return $default(_that.from,_that.to,_that.status,_that.search,_that.pageIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime from,  DateTime to,  SaleStatus? status,  String search,  int pageIndex)?  $default,) {final _that = this;
switch (_that) {
case _PosSalesFilter() when $default != null:
return $default(_that.from,_that.to,_that.status,_that.search,_that.pageIndex);case _:
  return null;

}
}

}

/// @nodoc


class _PosSalesFilter implements PosSalesFilter {
  const _PosSalesFilter({required this.from, required this.to, this.status, this.search = '', this.pageIndex = 0});
  

@override final  DateTime from;
@override final  DateTime to;
@override final  SaleStatus? status;
@override@JsonKey() final  String search;
@override@JsonKey() final  int pageIndex;

/// Create a copy of PosSalesFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PosSalesFilterCopyWith<_PosSalesFilter> get copyWith => __$PosSalesFilterCopyWithImpl<_PosSalesFilter>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PosSalesFilter&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&(identical(other.status, status) || other.status == status)&&(identical(other.search, search) || other.search == search)&&(identical(other.pageIndex, pageIndex) || other.pageIndex == pageIndex));
}


@override
int get hashCode {
    return Object.hash(runtimeType,from,to,status,search,pageIndex);
}

@override
String toString() {
    return 'PosSalesFilter(from: $from, to: $to, status: $status, search: $search, pageIndex: $pageIndex)';
}


}

/// @nodoc
abstract mixin class _$PosSalesFilterCopyWith<$Res> implements $PosSalesFilterCopyWith<$Res> {
  factory _$PosSalesFilterCopyWith(_PosSalesFilter value, $Res Function(_PosSalesFilter) _then) = __$PosSalesFilterCopyWithImpl;
@override @useResult
$Res call({
 DateTime from, DateTime to, SaleStatus? status, String search, int pageIndex
});




}
/// @nodoc
class __$PosSalesFilterCopyWithImpl<$Res>
    implements _$PosSalesFilterCopyWith<$Res> {
  __$PosSalesFilterCopyWithImpl(this._self, this._then);

  final _PosSalesFilter _self;
  final $Res Function(_PosSalesFilter) _then;

/// Create a copy of PosSalesFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? from = null,Object? to = null,Object? status = freezed,Object? search = null,Object? pageIndex = null,}) {
  return _then(_PosSalesFilter(
from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SaleStatus?,search: null == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
