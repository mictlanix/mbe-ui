// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stock_list_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StockQuery {

 int? get warehouseId; String get q; bool get includeZero; int get pageIndex;
/// Create a copy of StockQuery
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StockQueryCopyWith<StockQuery> get copyWith => _$StockQueryCopyWithImpl<StockQuery>(this as StockQuery, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as StockQuery;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StockQuery&&(identical(other.warehouseId, _this.warehouseId) || other.warehouseId == _this.warehouseId)&&(identical(other.q, _this.q) || other.q == _this.q)&&(identical(other.includeZero, _this.includeZero) || other.includeZero == _this.includeZero)&&(identical(other.pageIndex, _this.pageIndex) || other.pageIndex == _this.pageIndex));
}


@override
int get hashCode {
  final _this = this as StockQuery;
  return Object.hash(runtimeType,_this.warehouseId,_this.q,_this.includeZero,_this.pageIndex);
}

@override
String toString() {
  final _this = this as StockQuery;
  return 'StockQuery(warehouseId: ${_this.warehouseId}, q: ${_this.q}, includeZero: ${_this.includeZero}, pageIndex: ${_this.pageIndex})';
}


}

/// @nodoc
abstract mixin class $StockQueryCopyWith<$Res>  {
  factory $StockQueryCopyWith(StockQuery value, $Res Function(StockQuery) _then) = _$StockQueryCopyWithImpl;
@useResult
$Res call({
 int? warehouseId, String q, bool includeZero, int pageIndex
});




}
/// @nodoc
class _$StockQueryCopyWithImpl<$Res>
    implements $StockQueryCopyWith<$Res> {
  _$StockQueryCopyWithImpl(this._self, this._then);

  final StockQuery _self;
  final $Res Function(StockQuery) _then;

/// Create a copy of StockQuery
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? warehouseId = freezed,Object? q = null,Object? includeZero = null,Object? pageIndex = null,}) {
  return _then(StockQuery(
warehouseId: freezed == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int?,q: null == q ? _self.q : q // ignore: cast_nullable_to_non_nullable
as String,includeZero: null == includeZero ? _self.includeZero : includeZero // ignore: cast_nullable_to_non_nullable
as bool,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [StockQuery].
extension StockQueryPatterns on StockQuery {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StockQuery value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StockQuery() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StockQuery value)  $default,){
final _that = this;
switch (_that) {
case _StockQuery():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StockQuery value)?  $default,){
final _that = this;
switch (_that) {
case _StockQuery() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? warehouseId,  String q,  bool includeZero,  int pageIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StockQuery() when $default != null:
return $default(_that.warehouseId,_that.q,_that.includeZero,_that.pageIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? warehouseId,  String q,  bool includeZero,  int pageIndex)  $default,) {final _that = this;
switch (_that) {
case _StockQuery():
return $default(_that.warehouseId,_that.q,_that.includeZero,_that.pageIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? warehouseId,  String q,  bool includeZero,  int pageIndex)?  $default,) {final _that = this;
switch (_that) {
case _StockQuery() when $default != null:
return $default(_that.warehouseId,_that.q,_that.includeZero,_that.pageIndex);case _:
  return null;

}
}

}

/// @nodoc


class _StockQuery extends StockQuery {
  const _StockQuery({this.warehouseId, this.q = '', this.includeZero = false, this.pageIndex = 0}): super._();
  

@override final  int? warehouseId;
@override@JsonKey() final  String q;
@override@JsonKey() final  bool includeZero;
@override@JsonKey() final  int pageIndex;

/// Create a copy of StockQuery
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StockQueryCopyWith<_StockQuery> get copyWith => __$StockQueryCopyWithImpl<_StockQuery>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StockQuery&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.q, q) || other.q == q)&&(identical(other.includeZero, includeZero) || other.includeZero == includeZero)&&(identical(other.pageIndex, pageIndex) || other.pageIndex == pageIndex));
}


@override
int get hashCode {
    return Object.hash(runtimeType,warehouseId,q,includeZero,pageIndex);
}

@override
String toString() {
    return 'StockQuery(warehouseId: $warehouseId, q: $q, includeZero: $includeZero, pageIndex: $pageIndex)';
}


}

/// @nodoc
abstract mixin class _$StockQueryCopyWith<$Res> implements $StockQueryCopyWith<$Res> {
  factory _$StockQueryCopyWith(_StockQuery value, $Res Function(_StockQuery) _then) = __$StockQueryCopyWithImpl;
@override @useResult
$Res call({
 int? warehouseId, String q, bool includeZero, int pageIndex
});




}
/// @nodoc
class __$StockQueryCopyWithImpl<$Res>
    implements _$StockQueryCopyWith<$Res> {
  __$StockQueryCopyWithImpl(this._self, this._then);

  final _StockQuery _self;
  final $Res Function(_StockQuery) _then;

/// Create a copy of StockQuery
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? warehouseId = freezed,Object? q = null,Object? includeZero = null,Object? pageIndex = null,}) {
  return _then(_StockQuery(
warehouseId: freezed == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int?,q: null == q ? _self.q : q // ignore: cast_nullable_to_non_nullable
as String,includeZero: null == includeZero ? _self.includeZero : includeZero // ignore: cast_nullable_to_non_nullable
as bool,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
