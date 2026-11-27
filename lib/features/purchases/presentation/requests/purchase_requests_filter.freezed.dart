// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'purchase_requests_filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PurchaseRequestsFilter {

/// "Todas" instead of "Mis solicitudes".
 bool get all; PurchaseRequestStatus? get status; int? get facilityId; int? get warehouseId; int? get creatorId;/// Both ends or neither: a half-open or reversed range is dropped.
 DateTime? get from; DateTime? get to;/// The folio search box; numeric only.
 int? get serial; int get pageIndex;
/// Create a copy of PurchaseRequestsFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PurchaseRequestsFilterCopyWith<PurchaseRequestsFilter> get copyWith => _$PurchaseRequestsFilterCopyWithImpl<PurchaseRequestsFilter>(this as PurchaseRequestsFilter, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PurchaseRequestsFilter;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PurchaseRequestsFilter&&(identical(other.all, _this.all) || other.all == _this.all)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.facilityId, _this.facilityId) || other.facilityId == _this.facilityId)&&(identical(other.warehouseId, _this.warehouseId) || other.warehouseId == _this.warehouseId)&&(identical(other.creatorId, _this.creatorId) || other.creatorId == _this.creatorId)&&(identical(other.from, _this.from) || other.from == _this.from)&&(identical(other.to, _this.to) || other.to == _this.to)&&(identical(other.serial, _this.serial) || other.serial == _this.serial)&&(identical(other.pageIndex, _this.pageIndex) || other.pageIndex == _this.pageIndex));
}


@override
int get hashCode {
  final _this = this as PurchaseRequestsFilter;
  return Object.hash(runtimeType,_this.all,_this.status,_this.facilityId,_this.warehouseId,_this.creatorId,_this.from,_this.to,_this.serial,_this.pageIndex);
}

@override
String toString() {
  final _this = this as PurchaseRequestsFilter;
  return 'PurchaseRequestsFilter(all: ${_this.all}, status: ${_this.status}, facilityId: ${_this.facilityId}, warehouseId: ${_this.warehouseId}, creatorId: ${_this.creatorId}, from: ${_this.from}, to: ${_this.to}, serial: ${_this.serial}, pageIndex: ${_this.pageIndex})';
}


}

/// @nodoc
abstract mixin class $PurchaseRequestsFilterCopyWith<$Res>  {
  factory $PurchaseRequestsFilterCopyWith(PurchaseRequestsFilter value, $Res Function(PurchaseRequestsFilter) _then) = _$PurchaseRequestsFilterCopyWithImpl;
@useResult
$Res call({
 bool all, PurchaseRequestStatus? status, int? facilityId, int? warehouseId, int? creatorId, DateTime? from, DateTime? to, int? serial, int pageIndex
});




}
/// @nodoc
class _$PurchaseRequestsFilterCopyWithImpl<$Res>
    implements $PurchaseRequestsFilterCopyWith<$Res> {
  _$PurchaseRequestsFilterCopyWithImpl(this._self, this._then);

  final PurchaseRequestsFilter _self;
  final $Res Function(PurchaseRequestsFilter) _then;

/// Create a copy of PurchaseRequestsFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? all = null,Object? status = freezed,Object? facilityId = freezed,Object? warehouseId = freezed,Object? creatorId = freezed,Object? from = freezed,Object? to = freezed,Object? serial = freezed,Object? pageIndex = null,}) {
  return _then(PurchaseRequestsFilter(
all: null == all ? _self.all : all // ignore: cast_nullable_to_non_nullable
as bool,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PurchaseRequestStatus?,facilityId: freezed == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int?,warehouseId: freezed == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int?,creatorId: freezed == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as int?,from: freezed == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime?,to: freezed == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime?,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as int?,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PurchaseRequestsFilter].
extension PurchaseRequestsFilterPatterns on PurchaseRequestsFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PurchaseRequestsFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PurchaseRequestsFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PurchaseRequestsFilter value)  $default,){
final _that = this;
switch (_that) {
case _PurchaseRequestsFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PurchaseRequestsFilter value)?  $default,){
final _that = this;
switch (_that) {
case _PurchaseRequestsFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool all,  PurchaseRequestStatus? status,  int? facilityId,  int? warehouseId,  int? creatorId,  DateTime? from,  DateTime? to,  int? serial,  int pageIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PurchaseRequestsFilter() when $default != null:
return $default(_that.all,_that.status,_that.facilityId,_that.warehouseId,_that.creatorId,_that.from,_that.to,_that.serial,_that.pageIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool all,  PurchaseRequestStatus? status,  int? facilityId,  int? warehouseId,  int? creatorId,  DateTime? from,  DateTime? to,  int? serial,  int pageIndex)  $default,) {final _that = this;
switch (_that) {
case _PurchaseRequestsFilter():
return $default(_that.all,_that.status,_that.facilityId,_that.warehouseId,_that.creatorId,_that.from,_that.to,_that.serial,_that.pageIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool all,  PurchaseRequestStatus? status,  int? facilityId,  int? warehouseId,  int? creatorId,  DateTime? from,  DateTime? to,  int? serial,  int pageIndex)?  $default,) {final _that = this;
switch (_that) {
case _PurchaseRequestsFilter() when $default != null:
return $default(_that.all,_that.status,_that.facilityId,_that.warehouseId,_that.creatorId,_that.from,_that.to,_that.serial,_that.pageIndex);case _:
  return null;

}
}

}

/// @nodoc


class _PurchaseRequestsFilter extends PurchaseRequestsFilter {
  const _PurchaseRequestsFilter({this.all = false, this.status, this.facilityId, this.warehouseId, this.creatorId, this.from, this.to, this.serial, this.pageIndex = 0}): super._();
  

/// "Todas" instead of "Mis solicitudes".
@override@JsonKey() final  bool all;
@override final  PurchaseRequestStatus? status;
@override final  int? facilityId;
@override final  int? warehouseId;
@override final  int? creatorId;
/// Both ends or neither: a half-open or reversed range is dropped.
@override final  DateTime? from;
@override final  DateTime? to;
/// The folio search box; numeric only.
@override final  int? serial;
@override@JsonKey() final  int pageIndex;

/// Create a copy of PurchaseRequestsFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PurchaseRequestsFilterCopyWith<_PurchaseRequestsFilter> get copyWith => __$PurchaseRequestsFilterCopyWithImpl<_PurchaseRequestsFilter>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PurchaseRequestsFilter&&(identical(other.all, all) || other.all == all)&&(identical(other.status, status) || other.status == status)&&(identical(other.facilityId, facilityId) || other.facilityId == facilityId)&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&(identical(other.serial, serial) || other.serial == serial)&&(identical(other.pageIndex, pageIndex) || other.pageIndex == pageIndex));
}


@override
int get hashCode {
    return Object.hash(runtimeType,all,status,facilityId,warehouseId,creatorId,from,to,serial,pageIndex);
}

@override
String toString() {
    return 'PurchaseRequestsFilter(all: $all, status: $status, facilityId: $facilityId, warehouseId: $warehouseId, creatorId: $creatorId, from: $from, to: $to, serial: $serial, pageIndex: $pageIndex)';
}


}

/// @nodoc
abstract mixin class _$PurchaseRequestsFilterCopyWith<$Res> implements $PurchaseRequestsFilterCopyWith<$Res> {
  factory _$PurchaseRequestsFilterCopyWith(_PurchaseRequestsFilter value, $Res Function(_PurchaseRequestsFilter) _then) = __$PurchaseRequestsFilterCopyWithImpl;
@override @useResult
$Res call({
 bool all, PurchaseRequestStatus? status, int? facilityId, int? warehouseId, int? creatorId, DateTime? from, DateTime? to, int? serial, int pageIndex
});




}
/// @nodoc
class __$PurchaseRequestsFilterCopyWithImpl<$Res>
    implements _$PurchaseRequestsFilterCopyWith<$Res> {
  __$PurchaseRequestsFilterCopyWithImpl(this._self, this._then);

  final _PurchaseRequestsFilter _self;
  final $Res Function(_PurchaseRequestsFilter) _then;

/// Create a copy of PurchaseRequestsFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? all = null,Object? status = freezed,Object? facilityId = freezed,Object? warehouseId = freezed,Object? creatorId = freezed,Object? from = freezed,Object? to = freezed,Object? serial = freezed,Object? pageIndex = null,}) {
  return _then(_PurchaseRequestsFilter(
all: null == all ? _self.all : all // ignore: cast_nullable_to_non_nullable
as bool,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PurchaseRequestStatus?,facilityId: freezed == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int?,warehouseId: freezed == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int?,creatorId: freezed == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as int?,from: freezed == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime?,to: freezed == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime?,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as int?,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
