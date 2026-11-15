// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'delivery_orders_filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DeliveryOrdersFilter {

/// The folio search box: digits only, `null` when empty. Carried in
/// `ListQuery.search`, like every other list's search box.
 String? get search; DeliveryOrderStatus? get status;/// "Todas": every status, terminal ones included. Ignored when [status]
/// is set. URL `status=all`.
 bool get everyStatus; FulfillmentType? get type;/// Both ends or neither, as in Pagos: a half-open or reversed range is
/// dropped by [fromQuery].
 DateTime? get dateFrom; DateTime? get dateTo; int? get customerId; int? get salesOrderId;/// Administrators only. Never set for anyone else by [fromQuery], and
/// dropped again by the list controller's fetch (research R3).
 int? get facilityId; int get pageIndex;
/// Create a copy of DeliveryOrdersFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeliveryOrdersFilterCopyWith<DeliveryOrdersFilter> get copyWith => _$DeliveryOrdersFilterCopyWithImpl<DeliveryOrdersFilter>(this as DeliveryOrdersFilter, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DeliveryOrdersFilter;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeliveryOrdersFilter&&(identical(other.search, _this.search) || other.search == _this.search)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.everyStatus, _this.everyStatus) || other.everyStatus == _this.everyStatus)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.dateFrom, _this.dateFrom) || other.dateFrom == _this.dateFrom)&&(identical(other.dateTo, _this.dateTo) || other.dateTo == _this.dateTo)&&(identical(other.customerId, _this.customerId) || other.customerId == _this.customerId)&&(identical(other.salesOrderId, _this.salesOrderId) || other.salesOrderId == _this.salesOrderId)&&(identical(other.facilityId, _this.facilityId) || other.facilityId == _this.facilityId)&&(identical(other.pageIndex, _this.pageIndex) || other.pageIndex == _this.pageIndex));
}


@override
int get hashCode {
  final _this = this as DeliveryOrdersFilter;
  return Object.hash(runtimeType,_this.search,_this.status,_this.everyStatus,_this.type,_this.dateFrom,_this.dateTo,_this.customerId,_this.salesOrderId,_this.facilityId,_this.pageIndex);
}

@override
String toString() {
  final _this = this as DeliveryOrdersFilter;
  return 'DeliveryOrdersFilter(search: ${_this.search}, status: ${_this.status}, everyStatus: ${_this.everyStatus}, type: ${_this.type}, dateFrom: ${_this.dateFrom}, dateTo: ${_this.dateTo}, customerId: ${_this.customerId}, salesOrderId: ${_this.salesOrderId}, facilityId: ${_this.facilityId}, pageIndex: ${_this.pageIndex})';
}


}

/// @nodoc
abstract mixin class $DeliveryOrdersFilterCopyWith<$Res>  {
  factory $DeliveryOrdersFilterCopyWith(DeliveryOrdersFilter value, $Res Function(DeliveryOrdersFilter) _then) = _$DeliveryOrdersFilterCopyWithImpl;
@useResult
$Res call({
 String? search, DeliveryOrderStatus? status, bool everyStatus, FulfillmentType? type, DateTime? dateFrom, DateTime? dateTo, int? customerId, int? salesOrderId, int? facilityId, int pageIndex
});




}
/// @nodoc
class _$DeliveryOrdersFilterCopyWithImpl<$Res>
    implements $DeliveryOrdersFilterCopyWith<$Res> {
  _$DeliveryOrdersFilterCopyWithImpl(this._self, this._then);

  final DeliveryOrdersFilter _self;
  final $Res Function(DeliveryOrdersFilter) _then;

/// Create a copy of DeliveryOrdersFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? search = freezed,Object? status = freezed,Object? everyStatus = null,Object? type = freezed,Object? dateFrom = freezed,Object? dateTo = freezed,Object? customerId = freezed,Object? salesOrderId = freezed,Object? facilityId = freezed,Object? pageIndex = null,}) {
  return _then(DeliveryOrdersFilter(
search: freezed == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DeliveryOrderStatus?,everyStatus: null == everyStatus ? _self.everyStatus : everyStatus // ignore: cast_nullable_to_non_nullable
as bool,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as FulfillmentType?,dateFrom: freezed == dateFrom ? _self.dateFrom : dateFrom // ignore: cast_nullable_to_non_nullable
as DateTime?,dateTo: freezed == dateTo ? _self.dateTo : dateTo // ignore: cast_nullable_to_non_nullable
as DateTime?,customerId: freezed == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as int?,salesOrderId: freezed == salesOrderId ? _self.salesOrderId : salesOrderId // ignore: cast_nullable_to_non_nullable
as int?,facilityId: freezed == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int?,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DeliveryOrdersFilter].
extension DeliveryOrdersFilterPatterns on DeliveryOrdersFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeliveryOrdersFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeliveryOrdersFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeliveryOrdersFilter value)  $default,){
final _that = this;
switch (_that) {
case _DeliveryOrdersFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeliveryOrdersFilter value)?  $default,){
final _that = this;
switch (_that) {
case _DeliveryOrdersFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? search,  DeliveryOrderStatus? status,  bool everyStatus,  FulfillmentType? type,  DateTime? dateFrom,  DateTime? dateTo,  int? customerId,  int? salesOrderId,  int? facilityId,  int pageIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeliveryOrdersFilter() when $default != null:
return $default(_that.search,_that.status,_that.everyStatus,_that.type,_that.dateFrom,_that.dateTo,_that.customerId,_that.salesOrderId,_that.facilityId,_that.pageIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? search,  DeliveryOrderStatus? status,  bool everyStatus,  FulfillmentType? type,  DateTime? dateFrom,  DateTime? dateTo,  int? customerId,  int? salesOrderId,  int? facilityId,  int pageIndex)  $default,) {final _that = this;
switch (_that) {
case _DeliveryOrdersFilter():
return $default(_that.search,_that.status,_that.everyStatus,_that.type,_that.dateFrom,_that.dateTo,_that.customerId,_that.salesOrderId,_that.facilityId,_that.pageIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? search,  DeliveryOrderStatus? status,  bool everyStatus,  FulfillmentType? type,  DateTime? dateFrom,  DateTime? dateTo,  int? customerId,  int? salesOrderId,  int? facilityId,  int pageIndex)?  $default,) {final _that = this;
switch (_that) {
case _DeliveryOrdersFilter() when $default != null:
return $default(_that.search,_that.status,_that.everyStatus,_that.type,_that.dateFrom,_that.dateTo,_that.customerId,_that.salesOrderId,_that.facilityId,_that.pageIndex);case _:
  return null;

}
}

}

/// @nodoc


class _DeliveryOrdersFilter extends DeliveryOrdersFilter {
  const _DeliveryOrdersFilter({this.search, this.status, this.everyStatus = false, this.type, this.dateFrom, this.dateTo, this.customerId, this.salesOrderId, this.facilityId, this.pageIndex = 0}): super._();
  

/// The folio search box: digits only, `null` when empty. Carried in
/// `ListQuery.search`, like every other list's search box.
@override final  String? search;
@override final  DeliveryOrderStatus? status;
/// "Todas": every status, terminal ones included. Ignored when [status]
/// is set. URL `status=all`.
@override@JsonKey() final  bool everyStatus;
@override final  FulfillmentType? type;
/// Both ends or neither, as in Pagos: a half-open or reversed range is
/// dropped by [fromQuery].
@override final  DateTime? dateFrom;
@override final  DateTime? dateTo;
@override final  int? customerId;
@override final  int? salesOrderId;
/// Administrators only. Never set for anyone else by [fromQuery], and
/// dropped again by the list controller's fetch (research R3).
@override final  int? facilityId;
@override@JsonKey() final  int pageIndex;

/// Create a copy of DeliveryOrdersFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeliveryOrdersFilterCopyWith<_DeliveryOrdersFilter> get copyWith => __$DeliveryOrdersFilterCopyWithImpl<_DeliveryOrdersFilter>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeliveryOrdersFilter&&(identical(other.search, search) || other.search == search)&&(identical(other.status, status) || other.status == status)&&(identical(other.everyStatus, everyStatus) || other.everyStatus == everyStatus)&&(identical(other.type, type) || other.type == type)&&(identical(other.dateFrom, dateFrom) || other.dateFrom == dateFrom)&&(identical(other.dateTo, dateTo) || other.dateTo == dateTo)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.salesOrderId, salesOrderId) || other.salesOrderId == salesOrderId)&&(identical(other.facilityId, facilityId) || other.facilityId == facilityId)&&(identical(other.pageIndex, pageIndex) || other.pageIndex == pageIndex));
}


@override
int get hashCode {
    return Object.hash(runtimeType,search,status,everyStatus,type,dateFrom,dateTo,customerId,salesOrderId,facilityId,pageIndex);
}

@override
String toString() {
    return 'DeliveryOrdersFilter(search: $search, status: $status, everyStatus: $everyStatus, type: $type, dateFrom: $dateFrom, dateTo: $dateTo, customerId: $customerId, salesOrderId: $salesOrderId, facilityId: $facilityId, pageIndex: $pageIndex)';
}


}

/// @nodoc
abstract mixin class _$DeliveryOrdersFilterCopyWith<$Res> implements $DeliveryOrdersFilterCopyWith<$Res> {
  factory _$DeliveryOrdersFilterCopyWith(_DeliveryOrdersFilter value, $Res Function(_DeliveryOrdersFilter) _then) = __$DeliveryOrdersFilterCopyWithImpl;
@override @useResult
$Res call({
 String? search, DeliveryOrderStatus? status, bool everyStatus, FulfillmentType? type, DateTime? dateFrom, DateTime? dateTo, int? customerId, int? salesOrderId, int? facilityId, int pageIndex
});




}
/// @nodoc
class __$DeliveryOrdersFilterCopyWithImpl<$Res>
    implements _$DeliveryOrdersFilterCopyWith<$Res> {
  __$DeliveryOrdersFilterCopyWithImpl(this._self, this._then);

  final _DeliveryOrdersFilter _self;
  final $Res Function(_DeliveryOrdersFilter) _then;

/// Create a copy of DeliveryOrdersFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? search = freezed,Object? status = freezed,Object? everyStatus = null,Object? type = freezed,Object? dateFrom = freezed,Object? dateTo = freezed,Object? customerId = freezed,Object? salesOrderId = freezed,Object? facilityId = freezed,Object? pageIndex = null,}) {
  return _then(_DeliveryOrdersFilter(
search: freezed == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DeliveryOrderStatus?,everyStatus: null == everyStatus ? _self.everyStatus : everyStatus // ignore: cast_nullable_to_non_nullable
as bool,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as FulfillmentType?,dateFrom: freezed == dateFrom ? _self.dateFrom : dateFrom // ignore: cast_nullable_to_non_nullable
as DateTime?,dateTo: freezed == dateTo ? _self.dateTo : dateTo // ignore: cast_nullable_to_non_nullable
as DateTime?,customerId: freezed == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as int?,salesOrderId: freezed == salesOrderId ? _self.salesOrderId : salesOrderId // ignore: cast_nullable_to_non_nullable
as int?,facilityId: freezed == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int?,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
