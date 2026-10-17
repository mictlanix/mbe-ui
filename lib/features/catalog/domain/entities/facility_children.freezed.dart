// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'facility_children.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FacilityChildren {

 int get facilityId; List<Warehouse> get warehouses; List<PointSale> get pointsOfSale; List<CashDrawer> get cashDrawers; bool get warehousesReadable; bool get pointsOfSaleReadable; bool get cashDrawersReadable;
/// Create a copy of FacilityChildren
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FacilityChildrenCopyWith<FacilityChildren> get copyWith => _$FacilityChildrenCopyWithImpl<FacilityChildren>(this as FacilityChildren, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FacilityChildren;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FacilityChildren&&(identical(other.facilityId, _this.facilityId) || other.facilityId == _this.facilityId)&&const DeepCollectionEquality().equals(other.warehouses, _this.warehouses)&&const DeepCollectionEquality().equals(other.pointsOfSale, _this.pointsOfSale)&&const DeepCollectionEquality().equals(other.cashDrawers, _this.cashDrawers)&&(identical(other.warehousesReadable, _this.warehousesReadable) || other.warehousesReadable == _this.warehousesReadable)&&(identical(other.pointsOfSaleReadable, _this.pointsOfSaleReadable) || other.pointsOfSaleReadable == _this.pointsOfSaleReadable)&&(identical(other.cashDrawersReadable, _this.cashDrawersReadable) || other.cashDrawersReadable == _this.cashDrawersReadable));
}


@override
int get hashCode {
  final _this = this as FacilityChildren;
  return Object.hash(runtimeType,_this.facilityId,const DeepCollectionEquality().hash(_this.warehouses),const DeepCollectionEquality().hash(_this.pointsOfSale),const DeepCollectionEquality().hash(_this.cashDrawers),_this.warehousesReadable,_this.pointsOfSaleReadable,_this.cashDrawersReadable);
}

@override
String toString() {
  final _this = this as FacilityChildren;
  return 'FacilityChildren(facilityId: ${_this.facilityId}, warehouses: ${_this.warehouses}, pointsOfSale: ${_this.pointsOfSale}, cashDrawers: ${_this.cashDrawers}, warehousesReadable: ${_this.warehousesReadable}, pointsOfSaleReadable: ${_this.pointsOfSaleReadable}, cashDrawersReadable: ${_this.cashDrawersReadable})';
}


}

/// @nodoc
abstract mixin class $FacilityChildrenCopyWith<$Res>  {
  factory $FacilityChildrenCopyWith(FacilityChildren value, $Res Function(FacilityChildren) _then) = _$FacilityChildrenCopyWithImpl;
@useResult
$Res call({
 int facilityId, List<Warehouse> warehouses, List<PointSale> pointsOfSale, List<CashDrawer> cashDrawers, bool warehousesReadable, bool pointsOfSaleReadable, bool cashDrawersReadable
});




}
/// @nodoc
class _$FacilityChildrenCopyWithImpl<$Res>
    implements $FacilityChildrenCopyWith<$Res> {
  _$FacilityChildrenCopyWithImpl(this._self, this._then);

  final FacilityChildren _self;
  final $Res Function(FacilityChildren) _then;

/// Create a copy of FacilityChildren
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? facilityId = null,Object? warehouses = null,Object? pointsOfSale = null,Object? cashDrawers = null,Object? warehousesReadable = null,Object? pointsOfSaleReadable = null,Object? cashDrawersReadable = null,}) {
  return _then(FacilityChildren(
facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int,warehouses: null == warehouses ? _self.warehouses : warehouses // ignore: cast_nullable_to_non_nullable
as List<Warehouse>,pointsOfSale: null == pointsOfSale ? _self.pointsOfSale : pointsOfSale // ignore: cast_nullable_to_non_nullable
as List<PointSale>,cashDrawers: null == cashDrawers ? _self.cashDrawers : cashDrawers // ignore: cast_nullable_to_non_nullable
as List<CashDrawer>,warehousesReadable: null == warehousesReadable ? _self.warehousesReadable : warehousesReadable // ignore: cast_nullable_to_non_nullable
as bool,pointsOfSaleReadable: null == pointsOfSaleReadable ? _self.pointsOfSaleReadable : pointsOfSaleReadable // ignore: cast_nullable_to_non_nullable
as bool,cashDrawersReadable: null == cashDrawersReadable ? _self.cashDrawersReadable : cashDrawersReadable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [FacilityChildren].
extension FacilityChildrenPatterns on FacilityChildren {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FacilityChildren value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FacilityChildren() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FacilityChildren value)  $default,){
final _that = this;
switch (_that) {
case _FacilityChildren():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FacilityChildren value)?  $default,){
final _that = this;
switch (_that) {
case _FacilityChildren() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int facilityId,  List<Warehouse> warehouses,  List<PointSale> pointsOfSale,  List<CashDrawer> cashDrawers,  bool warehousesReadable,  bool pointsOfSaleReadable,  bool cashDrawersReadable)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FacilityChildren() when $default != null:
return $default(_that.facilityId,_that.warehouses,_that.pointsOfSale,_that.cashDrawers,_that.warehousesReadable,_that.pointsOfSaleReadable,_that.cashDrawersReadable);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int facilityId,  List<Warehouse> warehouses,  List<PointSale> pointsOfSale,  List<CashDrawer> cashDrawers,  bool warehousesReadable,  bool pointsOfSaleReadable,  bool cashDrawersReadable)  $default,) {final _that = this;
switch (_that) {
case _FacilityChildren():
return $default(_that.facilityId,_that.warehouses,_that.pointsOfSale,_that.cashDrawers,_that.warehousesReadable,_that.pointsOfSaleReadable,_that.cashDrawersReadable);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int facilityId,  List<Warehouse> warehouses,  List<PointSale> pointsOfSale,  List<CashDrawer> cashDrawers,  bool warehousesReadable,  bool pointsOfSaleReadable,  bool cashDrawersReadable)?  $default,) {final _that = this;
switch (_that) {
case _FacilityChildren() when $default != null:
return $default(_that.facilityId,_that.warehouses,_that.pointsOfSale,_that.cashDrawers,_that.warehousesReadable,_that.pointsOfSaleReadable,_that.cashDrawersReadable);case _:
  return null;

}
}

}

/// @nodoc


class _FacilityChildren implements FacilityChildren {
  const _FacilityChildren({required this.facilityId,  List<Warehouse> warehouses = const <Warehouse>[],  List<PointSale> pointsOfSale = const <PointSale>[],  List<CashDrawer> cashDrawers = const <CashDrawer>[], this.warehousesReadable = false, this.pointsOfSaleReadable = false, this.cashDrawersReadable = false}): _warehouses = warehouses,_pointsOfSale = pointsOfSale,_cashDrawers = cashDrawers;
  

@override final  int facilityId;
 final  List<Warehouse> _warehouses;
@override@JsonKey() List<Warehouse> get warehouses {
  if (_warehouses is EqualUnmodifiableListView) return _warehouses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_warehouses);
}

 final  List<PointSale> _pointsOfSale;
@override@JsonKey() List<PointSale> get pointsOfSale {
  if (_pointsOfSale is EqualUnmodifiableListView) return _pointsOfSale;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pointsOfSale);
}

 final  List<CashDrawer> _cashDrawers;
@override@JsonKey() List<CashDrawer> get cashDrawers {
  if (_cashDrawers is EqualUnmodifiableListView) return _cashDrawers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cashDrawers);
}

@override@JsonKey() final  bool warehousesReadable;
@override@JsonKey() final  bool pointsOfSaleReadable;
@override@JsonKey() final  bool cashDrawersReadable;

/// Create a copy of FacilityChildren
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FacilityChildrenCopyWith<_FacilityChildren> get copyWith => __$FacilityChildrenCopyWithImpl<_FacilityChildren>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FacilityChildren&&(identical(other.facilityId, facilityId) || other.facilityId == facilityId)&&const DeepCollectionEquality().equals(other.warehouses, _warehouses)&&const DeepCollectionEquality().equals(other.pointsOfSale, _pointsOfSale)&&const DeepCollectionEquality().equals(other.cashDrawers, _cashDrawers)&&(identical(other.warehousesReadable, warehousesReadable) || other.warehousesReadable == warehousesReadable)&&(identical(other.pointsOfSaleReadable, pointsOfSaleReadable) || other.pointsOfSaleReadable == pointsOfSaleReadable)&&(identical(other.cashDrawersReadable, cashDrawersReadable) || other.cashDrawersReadable == cashDrawersReadable));
}


@override
int get hashCode {
    return Object.hash(runtimeType,facilityId,const DeepCollectionEquality().hash(_warehouses),const DeepCollectionEquality().hash(_pointsOfSale),const DeepCollectionEquality().hash(_cashDrawers),warehousesReadable,pointsOfSaleReadable,cashDrawersReadable);
}

@override
String toString() {
    return 'FacilityChildren(facilityId: $facilityId, warehouses: $warehouses, pointsOfSale: $pointsOfSale, cashDrawers: $cashDrawers, warehousesReadable: $warehousesReadable, pointsOfSaleReadable: $pointsOfSaleReadable, cashDrawersReadable: $cashDrawersReadable)';
}


}

/// @nodoc
abstract mixin class _$FacilityChildrenCopyWith<$Res> implements $FacilityChildrenCopyWith<$Res> {
  factory _$FacilityChildrenCopyWith(_FacilityChildren value, $Res Function(_FacilityChildren) _then) = __$FacilityChildrenCopyWithImpl;
@override @useResult
$Res call({
 int facilityId, List<Warehouse> warehouses, List<PointSale> pointsOfSale, List<CashDrawer> cashDrawers, bool warehousesReadable, bool pointsOfSaleReadable, bool cashDrawersReadable
});




}
/// @nodoc
class __$FacilityChildrenCopyWithImpl<$Res>
    implements _$FacilityChildrenCopyWith<$Res> {
  __$FacilityChildrenCopyWithImpl(this._self, this._then);

  final _FacilityChildren _self;
  final $Res Function(_FacilityChildren) _then;

/// Create a copy of FacilityChildren
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? facilityId = null,Object? warehouses = null,Object? pointsOfSale = null,Object? cashDrawers = null,Object? warehousesReadable = null,Object? pointsOfSaleReadable = null,Object? cashDrawersReadable = null,}) {
  return _then(_FacilityChildren(
facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int,warehouses: null == warehouses ? _self._warehouses : warehouses // ignore: cast_nullable_to_non_nullable
as List<Warehouse>,pointsOfSale: null == pointsOfSale ? _self._pointsOfSale : pointsOfSale // ignore: cast_nullable_to_non_nullable
as List<PointSale>,cashDrawers: null == cashDrawers ? _self._cashDrawers : cashDrawers // ignore: cast_nullable_to_non_nullable
as List<CashDrawer>,warehousesReadable: null == warehousesReadable ? _self.warehousesReadable : warehousesReadable // ignore: cast_nullable_to_non_nullable
as bool,pointsOfSaleReadable: null == pointsOfSaleReadable ? _self.pointsOfSaleReadable : pointsOfSaleReadable // ignore: cast_nullable_to_non_nullable
as bool,cashDrawersReadable: null == cashDrawersReadable ? _self.cashDrawersReadable : cashDrawersReadable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
