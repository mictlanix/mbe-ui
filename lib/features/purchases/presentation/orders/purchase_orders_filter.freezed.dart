// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'purchase_orders_filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PurchaseOrdersFilter {

/// "Todas" instead of "Mis órdenes".
 bool get all; InventoryDocumentStatus? get status; int? get supplierId; int? get creatorId;/// Both ends or neither: a half-open or reversed range is dropped.
 DateTime? get from; DateTime? get to;/// The order number sent as `id`; null when the box is empty or not a
/// number.
 int? get orderId;/// The search box text as typed, kept even when it is not a number.
 String get search; int get pageIndex;
/// Create a copy of PurchaseOrdersFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PurchaseOrdersFilterCopyWith<PurchaseOrdersFilter> get copyWith => _$PurchaseOrdersFilterCopyWithImpl<PurchaseOrdersFilter>(this as PurchaseOrdersFilter, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PurchaseOrdersFilter;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PurchaseOrdersFilter&&(identical(other.all, _this.all) || other.all == _this.all)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.supplierId, _this.supplierId) || other.supplierId == _this.supplierId)&&(identical(other.creatorId, _this.creatorId) || other.creatorId == _this.creatorId)&&(identical(other.from, _this.from) || other.from == _this.from)&&(identical(other.to, _this.to) || other.to == _this.to)&&(identical(other.orderId, _this.orderId) || other.orderId == _this.orderId)&&(identical(other.search, _this.search) || other.search == _this.search)&&(identical(other.pageIndex, _this.pageIndex) || other.pageIndex == _this.pageIndex));
}


@override
int get hashCode {
  final _this = this as PurchaseOrdersFilter;
  return Object.hash(runtimeType,_this.all,_this.status,_this.supplierId,_this.creatorId,_this.from,_this.to,_this.orderId,_this.search,_this.pageIndex);
}

@override
String toString() {
  final _this = this as PurchaseOrdersFilter;
  return 'PurchaseOrdersFilter(all: ${_this.all}, status: ${_this.status}, supplierId: ${_this.supplierId}, creatorId: ${_this.creatorId}, from: ${_this.from}, to: ${_this.to}, orderId: ${_this.orderId}, search: ${_this.search}, pageIndex: ${_this.pageIndex})';
}


}

/// @nodoc
abstract mixin class $PurchaseOrdersFilterCopyWith<$Res>  {
  factory $PurchaseOrdersFilterCopyWith(PurchaseOrdersFilter value, $Res Function(PurchaseOrdersFilter) _then) = _$PurchaseOrdersFilterCopyWithImpl;
@useResult
$Res call({
 bool all, InventoryDocumentStatus? status, int? supplierId, int? creatorId, DateTime? from, DateTime? to, int? orderId, String search, int pageIndex
});




}
/// @nodoc
class _$PurchaseOrdersFilterCopyWithImpl<$Res>
    implements $PurchaseOrdersFilterCopyWith<$Res> {
  _$PurchaseOrdersFilterCopyWithImpl(this._self, this._then);

  final PurchaseOrdersFilter _self;
  final $Res Function(PurchaseOrdersFilter) _then;

/// Create a copy of PurchaseOrdersFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? all = null,Object? status = freezed,Object? supplierId = freezed,Object? creatorId = freezed,Object? from = freezed,Object? to = freezed,Object? orderId = freezed,Object? search = null,Object? pageIndex = null,}) {
  return _then(PurchaseOrdersFilter(
all: null == all ? _self.all : all // ignore: cast_nullable_to_non_nullable
as bool,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InventoryDocumentStatus?,supplierId: freezed == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as int?,creatorId: freezed == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as int?,from: freezed == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime?,to: freezed == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime?,orderId: freezed == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as int?,search: null == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PurchaseOrdersFilter].
extension PurchaseOrdersFilterPatterns on PurchaseOrdersFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PurchaseOrdersFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PurchaseOrdersFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PurchaseOrdersFilter value)  $default,){
final _that = this;
switch (_that) {
case _PurchaseOrdersFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PurchaseOrdersFilter value)?  $default,){
final _that = this;
switch (_that) {
case _PurchaseOrdersFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool all,  InventoryDocumentStatus? status,  int? supplierId,  int? creatorId,  DateTime? from,  DateTime? to,  int? orderId,  String search,  int pageIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PurchaseOrdersFilter() when $default != null:
return $default(_that.all,_that.status,_that.supplierId,_that.creatorId,_that.from,_that.to,_that.orderId,_that.search,_that.pageIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool all,  InventoryDocumentStatus? status,  int? supplierId,  int? creatorId,  DateTime? from,  DateTime? to,  int? orderId,  String search,  int pageIndex)  $default,) {final _that = this;
switch (_that) {
case _PurchaseOrdersFilter():
return $default(_that.all,_that.status,_that.supplierId,_that.creatorId,_that.from,_that.to,_that.orderId,_that.search,_that.pageIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool all,  InventoryDocumentStatus? status,  int? supplierId,  int? creatorId,  DateTime? from,  DateTime? to,  int? orderId,  String search,  int pageIndex)?  $default,) {final _that = this;
switch (_that) {
case _PurchaseOrdersFilter() when $default != null:
return $default(_that.all,_that.status,_that.supplierId,_that.creatorId,_that.from,_that.to,_that.orderId,_that.search,_that.pageIndex);case _:
  return null;

}
}

}

/// @nodoc


class _PurchaseOrdersFilter extends PurchaseOrdersFilter {
  const _PurchaseOrdersFilter({this.all = false, this.status, this.supplierId, this.creatorId, this.from, this.to, this.orderId, this.search = '', this.pageIndex = 0}): super._();
  

/// "Todas" instead of "Mis órdenes".
@override@JsonKey() final  bool all;
@override final  InventoryDocumentStatus? status;
@override final  int? supplierId;
@override final  int? creatorId;
/// Both ends or neither: a half-open or reversed range is dropped.
@override final  DateTime? from;
@override final  DateTime? to;
/// The order number sent as `id`; null when the box is empty or not a
/// number.
@override final  int? orderId;
/// The search box text as typed, kept even when it is not a number.
@override@JsonKey() final  String search;
@override@JsonKey() final  int pageIndex;

/// Create a copy of PurchaseOrdersFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PurchaseOrdersFilterCopyWith<_PurchaseOrdersFilter> get copyWith => __$PurchaseOrdersFilterCopyWithImpl<_PurchaseOrdersFilter>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PurchaseOrdersFilter&&(identical(other.all, all) || other.all == all)&&(identical(other.status, status) || other.status == status)&&(identical(other.supplierId, supplierId) || other.supplierId == supplierId)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.search, search) || other.search == search)&&(identical(other.pageIndex, pageIndex) || other.pageIndex == pageIndex));
}


@override
int get hashCode {
    return Object.hash(runtimeType,all,status,supplierId,creatorId,from,to,orderId,search,pageIndex);
}

@override
String toString() {
    return 'PurchaseOrdersFilter(all: $all, status: $status, supplierId: $supplierId, creatorId: $creatorId, from: $from, to: $to, orderId: $orderId, search: $search, pageIndex: $pageIndex)';
}


}

/// @nodoc
abstract mixin class _$PurchaseOrdersFilterCopyWith<$Res> implements $PurchaseOrdersFilterCopyWith<$Res> {
  factory _$PurchaseOrdersFilterCopyWith(_PurchaseOrdersFilter value, $Res Function(_PurchaseOrdersFilter) _then) = __$PurchaseOrdersFilterCopyWithImpl;
@override @useResult
$Res call({
 bool all, InventoryDocumentStatus? status, int? supplierId, int? creatorId, DateTime? from, DateTime? to, int? orderId, String search, int pageIndex
});




}
/// @nodoc
class __$PurchaseOrdersFilterCopyWithImpl<$Res>
    implements _$PurchaseOrdersFilterCopyWith<$Res> {
  __$PurchaseOrdersFilterCopyWithImpl(this._self, this._then);

  final _PurchaseOrdersFilter _self;
  final $Res Function(_PurchaseOrdersFilter) _then;

/// Create a copy of PurchaseOrdersFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? all = null,Object? status = freezed,Object? supplierId = freezed,Object? creatorId = freezed,Object? from = freezed,Object? to = freezed,Object? orderId = freezed,Object? search = null,Object? pageIndex = null,}) {
  return _then(_PurchaseOrdersFilter(
all: null == all ? _self.all : all // ignore: cast_nullable_to_non_nullable
as bool,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InventoryDocumentStatus?,supplierId: freezed == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as int?,creatorId: freezed == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as int?,from: freezed == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime?,to: freezed == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime?,orderId: freezed == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as int?,search: null == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
