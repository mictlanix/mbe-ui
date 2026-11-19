// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'delivery_itineraries_filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DeliveryItinerariesFilter {

/// One value, as the server takes one; `null` is every status.
 ItineraryStatus? get status;/// Both ends or neither, as in Pagos and Órdenes de entrega: a half-open or
/// reversed range is dropped by [fromQuery].
 DateTime? get dateFrom; DateTime? get dateTo; int? get vehicleId; int? get operatorId; int? get warehouseId; int get pageIndex;
/// Create a copy of DeliveryItinerariesFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeliveryItinerariesFilterCopyWith<DeliveryItinerariesFilter> get copyWith => _$DeliveryItinerariesFilterCopyWithImpl<DeliveryItinerariesFilter>(this as DeliveryItinerariesFilter, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DeliveryItinerariesFilter;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeliveryItinerariesFilter&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.dateFrom, _this.dateFrom) || other.dateFrom == _this.dateFrom)&&(identical(other.dateTo, _this.dateTo) || other.dateTo == _this.dateTo)&&(identical(other.vehicleId, _this.vehicleId) || other.vehicleId == _this.vehicleId)&&(identical(other.operatorId, _this.operatorId) || other.operatorId == _this.operatorId)&&(identical(other.warehouseId, _this.warehouseId) || other.warehouseId == _this.warehouseId)&&(identical(other.pageIndex, _this.pageIndex) || other.pageIndex == _this.pageIndex));
}


@override
int get hashCode {
  final _this = this as DeliveryItinerariesFilter;
  return Object.hash(runtimeType,_this.status,_this.dateFrom,_this.dateTo,_this.vehicleId,_this.operatorId,_this.warehouseId,_this.pageIndex);
}

@override
String toString() {
  final _this = this as DeliveryItinerariesFilter;
  return 'DeliveryItinerariesFilter(status: ${_this.status}, dateFrom: ${_this.dateFrom}, dateTo: ${_this.dateTo}, vehicleId: ${_this.vehicleId}, operatorId: ${_this.operatorId}, warehouseId: ${_this.warehouseId}, pageIndex: ${_this.pageIndex})';
}


}

/// @nodoc
abstract mixin class $DeliveryItinerariesFilterCopyWith<$Res>  {
  factory $DeliveryItinerariesFilterCopyWith(DeliveryItinerariesFilter value, $Res Function(DeliveryItinerariesFilter) _then) = _$DeliveryItinerariesFilterCopyWithImpl;
@useResult
$Res call({
 ItineraryStatus? status, DateTime? dateFrom, DateTime? dateTo, int? vehicleId, int? operatorId, int? warehouseId, int pageIndex
});




}
/// @nodoc
class _$DeliveryItinerariesFilterCopyWithImpl<$Res>
    implements $DeliveryItinerariesFilterCopyWith<$Res> {
  _$DeliveryItinerariesFilterCopyWithImpl(this._self, this._then);

  final DeliveryItinerariesFilter _self;
  final $Res Function(DeliveryItinerariesFilter) _then;

/// Create a copy of DeliveryItinerariesFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = freezed,Object? dateFrom = freezed,Object? dateTo = freezed,Object? vehicleId = freezed,Object? operatorId = freezed,Object? warehouseId = freezed,Object? pageIndex = null,}) {
  return _then(DeliveryItinerariesFilter(
status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ItineraryStatus?,dateFrom: freezed == dateFrom ? _self.dateFrom : dateFrom // ignore: cast_nullable_to_non_nullable
as DateTime?,dateTo: freezed == dateTo ? _self.dateTo : dateTo // ignore: cast_nullable_to_non_nullable
as DateTime?,vehicleId: freezed == vehicleId ? _self.vehicleId : vehicleId // ignore: cast_nullable_to_non_nullable
as int?,operatorId: freezed == operatorId ? _self.operatorId : operatorId // ignore: cast_nullable_to_non_nullable
as int?,warehouseId: freezed == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int?,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DeliveryItinerariesFilter].
extension DeliveryItinerariesFilterPatterns on DeliveryItinerariesFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeliveryItinerariesFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeliveryItinerariesFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeliveryItinerariesFilter value)  $default,){
final _that = this;
switch (_that) {
case _DeliveryItinerariesFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeliveryItinerariesFilter value)?  $default,){
final _that = this;
switch (_that) {
case _DeliveryItinerariesFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ItineraryStatus? status,  DateTime? dateFrom,  DateTime? dateTo,  int? vehicleId,  int? operatorId,  int? warehouseId,  int pageIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeliveryItinerariesFilter() when $default != null:
return $default(_that.status,_that.dateFrom,_that.dateTo,_that.vehicleId,_that.operatorId,_that.warehouseId,_that.pageIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ItineraryStatus? status,  DateTime? dateFrom,  DateTime? dateTo,  int? vehicleId,  int? operatorId,  int? warehouseId,  int pageIndex)  $default,) {final _that = this;
switch (_that) {
case _DeliveryItinerariesFilter():
return $default(_that.status,_that.dateFrom,_that.dateTo,_that.vehicleId,_that.operatorId,_that.warehouseId,_that.pageIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ItineraryStatus? status,  DateTime? dateFrom,  DateTime? dateTo,  int? vehicleId,  int? operatorId,  int? warehouseId,  int pageIndex)?  $default,) {final _that = this;
switch (_that) {
case _DeliveryItinerariesFilter() when $default != null:
return $default(_that.status,_that.dateFrom,_that.dateTo,_that.vehicleId,_that.operatorId,_that.warehouseId,_that.pageIndex);case _:
  return null;

}
}

}

/// @nodoc


class _DeliveryItinerariesFilter extends DeliveryItinerariesFilter {
  const _DeliveryItinerariesFilter({this.status, this.dateFrom, this.dateTo, this.vehicleId, this.operatorId, this.warehouseId, this.pageIndex = 0}): super._();
  

/// One value, as the server takes one; `null` is every status.
@override final  ItineraryStatus? status;
/// Both ends or neither, as in Pagos and Órdenes de entrega: a half-open or
/// reversed range is dropped by [fromQuery].
@override final  DateTime? dateFrom;
@override final  DateTime? dateTo;
@override final  int? vehicleId;
@override final  int? operatorId;
@override final  int? warehouseId;
@override@JsonKey() final  int pageIndex;

/// Create a copy of DeliveryItinerariesFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeliveryItinerariesFilterCopyWith<_DeliveryItinerariesFilter> get copyWith => __$DeliveryItinerariesFilterCopyWithImpl<_DeliveryItinerariesFilter>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeliveryItinerariesFilter&&(identical(other.status, status) || other.status == status)&&(identical(other.dateFrom, dateFrom) || other.dateFrom == dateFrom)&&(identical(other.dateTo, dateTo) || other.dateTo == dateTo)&&(identical(other.vehicleId, vehicleId) || other.vehicleId == vehicleId)&&(identical(other.operatorId, operatorId) || other.operatorId == operatorId)&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.pageIndex, pageIndex) || other.pageIndex == pageIndex));
}


@override
int get hashCode {
    return Object.hash(runtimeType,status,dateFrom,dateTo,vehicleId,operatorId,warehouseId,pageIndex);
}

@override
String toString() {
    return 'DeliveryItinerariesFilter(status: $status, dateFrom: $dateFrom, dateTo: $dateTo, vehicleId: $vehicleId, operatorId: $operatorId, warehouseId: $warehouseId, pageIndex: $pageIndex)';
}


}

/// @nodoc
abstract mixin class _$DeliveryItinerariesFilterCopyWith<$Res> implements $DeliveryItinerariesFilterCopyWith<$Res> {
  factory _$DeliveryItinerariesFilterCopyWith(_DeliveryItinerariesFilter value, $Res Function(_DeliveryItinerariesFilter) _then) = __$DeliveryItinerariesFilterCopyWithImpl;
@override @useResult
$Res call({
 ItineraryStatus? status, DateTime? dateFrom, DateTime? dateTo, int? vehicleId, int? operatorId, int? warehouseId, int pageIndex
});




}
/// @nodoc
class __$DeliveryItinerariesFilterCopyWithImpl<$Res>
    implements _$DeliveryItinerariesFilterCopyWith<$Res> {
  __$DeliveryItinerariesFilterCopyWithImpl(this._self, this._then);

  final _DeliveryItinerariesFilter _self;
  final $Res Function(_DeliveryItinerariesFilter) _then;

/// Create a copy of DeliveryItinerariesFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = freezed,Object? dateFrom = freezed,Object? dateTo = freezed,Object? vehicleId = freezed,Object? operatorId = freezed,Object? warehouseId = freezed,Object? pageIndex = null,}) {
  return _then(_DeliveryItinerariesFilter(
status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ItineraryStatus?,dateFrom: freezed == dateFrom ? _self.dateFrom : dateFrom // ignore: cast_nullable_to_non_nullable
as DateTime?,dateTo: freezed == dateTo ? _self.dateTo : dateTo // ignore: cast_nullable_to_non_nullable
as DateTime?,vehicleId: freezed == vehicleId ? _self.vehicleId : vehicleId // ignore: cast_nullable_to_non_nullable
as int?,operatorId: freezed == operatorId ? _self.operatorId : operatorId // ignore: cast_nullable_to_non_nullable
as int?,warehouseId: freezed == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int?,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
