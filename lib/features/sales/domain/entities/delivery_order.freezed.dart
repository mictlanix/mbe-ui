// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'delivery_order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DeliveryOrderSummary {

 int get id; int get facilityId;/// Null on a draft — the server assigns it on confirmation.
 int? get serial; int get customerId; List<int> get salesOrderIds; int? get shipToId; DateTime? get date; int get priority; DeliveryOrderStatus get status; FulfillmentType get type; int? get parentId;
/// Create a copy of DeliveryOrderSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeliveryOrderSummaryCopyWith<DeliveryOrderSummary> get copyWith => _$DeliveryOrderSummaryCopyWithImpl<DeliveryOrderSummary>(this as DeliveryOrderSummary, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DeliveryOrderSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeliveryOrderSummary&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.facilityId, _this.facilityId) || other.facilityId == _this.facilityId)&&(identical(other.serial, _this.serial) || other.serial == _this.serial)&&(identical(other.customerId, _this.customerId) || other.customerId == _this.customerId)&&const DeepCollectionEquality().equals(other.salesOrderIds, _this.salesOrderIds)&&(identical(other.shipToId, _this.shipToId) || other.shipToId == _this.shipToId)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.priority, _this.priority) || other.priority == _this.priority)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.parentId, _this.parentId) || other.parentId == _this.parentId));
}


@override
int get hashCode {
  final _this = this as DeliveryOrderSummary;
  return Object.hash(runtimeType,_this.id,_this.facilityId,_this.serial,_this.customerId,const DeepCollectionEquality().hash(_this.salesOrderIds),_this.shipToId,_this.date,_this.priority,_this.status,_this.type,_this.parentId);
}

@override
String toString() {
  final _this = this as DeliveryOrderSummary;
  return 'DeliveryOrderSummary(id: ${_this.id}, facilityId: ${_this.facilityId}, serial: ${_this.serial}, customerId: ${_this.customerId}, salesOrderIds: ${_this.salesOrderIds}, shipToId: ${_this.shipToId}, date: ${_this.date}, priority: ${_this.priority}, status: ${_this.status}, type: ${_this.type}, parentId: ${_this.parentId})';
}


}

/// @nodoc
abstract mixin class $DeliveryOrderSummaryCopyWith<$Res>  {
  factory $DeliveryOrderSummaryCopyWith(DeliveryOrderSummary value, $Res Function(DeliveryOrderSummary) _then) = _$DeliveryOrderSummaryCopyWithImpl;
@useResult
$Res call({
 int id, int facilityId, int? serial, int customerId, List<int> salesOrderIds, int? shipToId, DateTime? date, int priority, DeliveryOrderStatus status, FulfillmentType type, int? parentId
});




}
/// @nodoc
class _$DeliveryOrderSummaryCopyWithImpl<$Res>
    implements $DeliveryOrderSummaryCopyWith<$Res> {
  _$DeliveryOrderSummaryCopyWithImpl(this._self, this._then);

  final DeliveryOrderSummary _self;
  final $Res Function(DeliveryOrderSummary) _then;

/// Create a copy of DeliveryOrderSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? facilityId = null,Object? serial = freezed,Object? customerId = null,Object? salesOrderIds = null,Object? shipToId = freezed,Object? date = freezed,Object? priority = null,Object? status = null,Object? type = null,Object? parentId = freezed,}) {
  return _then(DeliveryOrderSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as int?,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as int,salesOrderIds: null == salesOrderIds ? _self.salesOrderIds : salesOrderIds // ignore: cast_nullable_to_non_nullable
as List<int>,shipToId: freezed == shipToId ? _self.shipToId : shipToId // ignore: cast_nullable_to_non_nullable
as int?,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime?,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DeliveryOrderStatus,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as FulfillmentType,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [DeliveryOrderSummary].
extension DeliveryOrderSummaryPatterns on DeliveryOrderSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeliveryOrderSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeliveryOrderSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeliveryOrderSummary value)  $default,){
final _that = this;
switch (_that) {
case _DeliveryOrderSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeliveryOrderSummary value)?  $default,){
final _that = this;
switch (_that) {
case _DeliveryOrderSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int facilityId,  int? serial,  int customerId,  List<int> salesOrderIds,  int? shipToId,  DateTime? date,  int priority,  DeliveryOrderStatus status,  FulfillmentType type,  int? parentId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeliveryOrderSummary() when $default != null:
return $default(_that.id,_that.facilityId,_that.serial,_that.customerId,_that.salesOrderIds,_that.shipToId,_that.date,_that.priority,_that.status,_that.type,_that.parentId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int facilityId,  int? serial,  int customerId,  List<int> salesOrderIds,  int? shipToId,  DateTime? date,  int priority,  DeliveryOrderStatus status,  FulfillmentType type,  int? parentId)  $default,) {final _that = this;
switch (_that) {
case _DeliveryOrderSummary():
return $default(_that.id,_that.facilityId,_that.serial,_that.customerId,_that.salesOrderIds,_that.shipToId,_that.date,_that.priority,_that.status,_that.type,_that.parentId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int facilityId,  int? serial,  int customerId,  List<int> salesOrderIds,  int? shipToId,  DateTime? date,  int priority,  DeliveryOrderStatus status,  FulfillmentType type,  int? parentId)?  $default,) {final _that = this;
switch (_that) {
case _DeliveryOrderSummary() when $default != null:
return $default(_that.id,_that.facilityId,_that.serial,_that.customerId,_that.salesOrderIds,_that.shipToId,_that.date,_that.priority,_that.status,_that.type,_that.parentId);case _:
  return null;

}
}

}

/// @nodoc


class _DeliveryOrderSummary implements DeliveryOrderSummary {
  const _DeliveryOrderSummary({required this.id, required this.facilityId, this.serial, required this.customerId,  List<int> salesOrderIds = const <int>[], this.shipToId, this.date, required this.priority, required this.status, required this.type, this.parentId}): _salesOrderIds = salesOrderIds;
  

@override final  int id;
@override final  int facilityId;
/// Null on a draft — the server assigns it on confirmation.
@override final  int? serial;
@override final  int customerId;
 final  List<int> _salesOrderIds;
@override@JsonKey() List<int> get salesOrderIds {
  if (_salesOrderIds is EqualUnmodifiableListView) return _salesOrderIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_salesOrderIds);
}

@override final  int? shipToId;
@override final  DateTime? date;
@override final  int priority;
@override final  DeliveryOrderStatus status;
@override final  FulfillmentType type;
@override final  int? parentId;

/// Create a copy of DeliveryOrderSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeliveryOrderSummaryCopyWith<_DeliveryOrderSummary> get copyWith => __$DeliveryOrderSummaryCopyWithImpl<_DeliveryOrderSummary>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeliveryOrderSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.facilityId, facilityId) || other.facilityId == facilityId)&&(identical(other.serial, serial) || other.serial == serial)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&const DeepCollectionEquality().equals(other.salesOrderIds, _salesOrderIds)&&(identical(other.shipToId, shipToId) || other.shipToId == shipToId)&&(identical(other.date, date) || other.date == date)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.status, status) || other.status == status)&&(identical(other.type, type) || other.type == type)&&(identical(other.parentId, parentId) || other.parentId == parentId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,facilityId,serial,customerId,const DeepCollectionEquality().hash(_salesOrderIds),shipToId,date,priority,status,type,parentId);
}

@override
String toString() {
    return 'DeliveryOrderSummary(id: $id, facilityId: $facilityId, serial: $serial, customerId: $customerId, salesOrderIds: $salesOrderIds, shipToId: $shipToId, date: $date, priority: $priority, status: $status, type: $type, parentId: $parentId)';
}


}

/// @nodoc
abstract mixin class _$DeliveryOrderSummaryCopyWith<$Res> implements $DeliveryOrderSummaryCopyWith<$Res> {
  factory _$DeliveryOrderSummaryCopyWith(_DeliveryOrderSummary value, $Res Function(_DeliveryOrderSummary) _then) = __$DeliveryOrderSummaryCopyWithImpl;
@override @useResult
$Res call({
 int id, int facilityId, int? serial, int customerId, List<int> salesOrderIds, int? shipToId, DateTime? date, int priority, DeliveryOrderStatus status, FulfillmentType type, int? parentId
});




}
/// @nodoc
class __$DeliveryOrderSummaryCopyWithImpl<$Res>
    implements _$DeliveryOrderSummaryCopyWith<$Res> {
  __$DeliveryOrderSummaryCopyWithImpl(this._self, this._then);

  final _DeliveryOrderSummary _self;
  final $Res Function(_DeliveryOrderSummary) _then;

/// Create a copy of DeliveryOrderSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? facilityId = null,Object? serial = freezed,Object? customerId = null,Object? salesOrderIds = null,Object? shipToId = freezed,Object? date = freezed,Object? priority = null,Object? status = null,Object? type = null,Object? parentId = freezed,}) {
  return _then(_DeliveryOrderSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as int?,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as int,salesOrderIds: null == salesOrderIds ? _self._salesOrderIds : salesOrderIds // ignore: cast_nullable_to_non_nullable
as List<int>,shipToId: freezed == shipToId ? _self.shipToId : shipToId // ignore: cast_nullable_to_non_nullable
as int?,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime?,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DeliveryOrderStatus,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as FulfillmentType,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$DeliveryOrder {

 int get id; int get facilityId; int? get serial; int get customerId; List<int> get salesOrderIds; int? get shipToId; DateTime? get date; int get priority; DeliveryOrderStatus get status; FulfillmentType get type; int? get parentId; int? get contactId; String? get comment; String? get rejectionReason; int? get proofId; DateTime get createdAt; DateTime get modifiedAt; List<DeliveryOrderLine> get lines;
/// Create a copy of DeliveryOrder
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeliveryOrderCopyWith<DeliveryOrder> get copyWith => _$DeliveryOrderCopyWithImpl<DeliveryOrder>(this as DeliveryOrder, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DeliveryOrder;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeliveryOrder&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.facilityId, _this.facilityId) || other.facilityId == _this.facilityId)&&(identical(other.serial, _this.serial) || other.serial == _this.serial)&&(identical(other.customerId, _this.customerId) || other.customerId == _this.customerId)&&const DeepCollectionEquality().equals(other.salesOrderIds, _this.salesOrderIds)&&(identical(other.shipToId, _this.shipToId) || other.shipToId == _this.shipToId)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.priority, _this.priority) || other.priority == _this.priority)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.parentId, _this.parentId) || other.parentId == _this.parentId)&&(identical(other.contactId, _this.contactId) || other.contactId == _this.contactId)&&(identical(other.comment, _this.comment) || other.comment == _this.comment)&&(identical(other.rejectionReason, _this.rejectionReason) || other.rejectionReason == _this.rejectionReason)&&(identical(other.proofId, _this.proofId) || other.proofId == _this.proofId)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.modifiedAt, _this.modifiedAt) || other.modifiedAt == _this.modifiedAt)&&const DeepCollectionEquality().equals(other.lines, _this.lines));
}


@override
int get hashCode {
  final _this = this as DeliveryOrder;
  return Object.hash(runtimeType,_this.id,_this.facilityId,_this.serial,_this.customerId,const DeepCollectionEquality().hash(_this.salesOrderIds),_this.shipToId,_this.date,_this.priority,_this.status,_this.type,_this.parentId,_this.contactId,_this.comment,_this.rejectionReason,_this.proofId,_this.createdAt,_this.modifiedAt,const DeepCollectionEquality().hash(_this.lines));
}

@override
String toString() {
  final _this = this as DeliveryOrder;
  return 'DeliveryOrder(id: ${_this.id}, facilityId: ${_this.facilityId}, serial: ${_this.serial}, customerId: ${_this.customerId}, salesOrderIds: ${_this.salesOrderIds}, shipToId: ${_this.shipToId}, date: ${_this.date}, priority: ${_this.priority}, status: ${_this.status}, type: ${_this.type}, parentId: ${_this.parentId}, contactId: ${_this.contactId}, comment: ${_this.comment}, rejectionReason: ${_this.rejectionReason}, proofId: ${_this.proofId}, createdAt: ${_this.createdAt}, modifiedAt: ${_this.modifiedAt}, lines: ${_this.lines})';
}


}

/// @nodoc
abstract mixin class $DeliveryOrderCopyWith<$Res>  {
  factory $DeliveryOrderCopyWith(DeliveryOrder value, $Res Function(DeliveryOrder) _then) = _$DeliveryOrderCopyWithImpl;
@useResult
$Res call({
 int id, int facilityId, int? serial, int customerId, List<int> salesOrderIds, int? shipToId, DateTime? date, int priority, DeliveryOrderStatus status, FulfillmentType type, int? parentId, int? contactId, String? comment, String? rejectionReason, int? proofId, DateTime createdAt, DateTime modifiedAt, List<DeliveryOrderLine> lines
});




}
/// @nodoc
class _$DeliveryOrderCopyWithImpl<$Res>
    implements $DeliveryOrderCopyWith<$Res> {
  _$DeliveryOrderCopyWithImpl(this._self, this._then);

  final DeliveryOrder _self;
  final $Res Function(DeliveryOrder) _then;

/// Create a copy of DeliveryOrder
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? facilityId = null,Object? serial = freezed,Object? customerId = null,Object? salesOrderIds = null,Object? shipToId = freezed,Object? date = freezed,Object? priority = null,Object? status = null,Object? type = null,Object? parentId = freezed,Object? contactId = freezed,Object? comment = freezed,Object? rejectionReason = freezed,Object? proofId = freezed,Object? createdAt = null,Object? modifiedAt = null,Object? lines = null,}) {
  return _then(DeliveryOrder(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as int?,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as int,salesOrderIds: null == salesOrderIds ? _self.salesOrderIds : salesOrderIds // ignore: cast_nullable_to_non_nullable
as List<int>,shipToId: freezed == shipToId ? _self.shipToId : shipToId // ignore: cast_nullable_to_non_nullable
as int?,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime?,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DeliveryOrderStatus,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as FulfillmentType,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as int?,contactId: freezed == contactId ? _self.contactId : contactId // ignore: cast_nullable_to_non_nullable
as int?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,proofId: freezed == proofId ? _self.proofId : proofId // ignore: cast_nullable_to_non_nullable
as int?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,modifiedAt: null == modifiedAt ? _self.modifiedAt : modifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<DeliveryOrderLine>,
  ));
}

}


/// Adds pattern-matching-related methods to [DeliveryOrder].
extension DeliveryOrderPatterns on DeliveryOrder {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeliveryOrder value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeliveryOrder() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeliveryOrder value)  $default,){
final _that = this;
switch (_that) {
case _DeliveryOrder():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeliveryOrder value)?  $default,){
final _that = this;
switch (_that) {
case _DeliveryOrder() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int facilityId,  int? serial,  int customerId,  List<int> salesOrderIds,  int? shipToId,  DateTime? date,  int priority,  DeliveryOrderStatus status,  FulfillmentType type,  int? parentId,  int? contactId,  String? comment,  String? rejectionReason,  int? proofId,  DateTime createdAt,  DateTime modifiedAt,  List<DeliveryOrderLine> lines)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeliveryOrder() when $default != null:
return $default(_that.id,_that.facilityId,_that.serial,_that.customerId,_that.salesOrderIds,_that.shipToId,_that.date,_that.priority,_that.status,_that.type,_that.parentId,_that.contactId,_that.comment,_that.rejectionReason,_that.proofId,_that.createdAt,_that.modifiedAt,_that.lines);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int facilityId,  int? serial,  int customerId,  List<int> salesOrderIds,  int? shipToId,  DateTime? date,  int priority,  DeliveryOrderStatus status,  FulfillmentType type,  int? parentId,  int? contactId,  String? comment,  String? rejectionReason,  int? proofId,  DateTime createdAt,  DateTime modifiedAt,  List<DeliveryOrderLine> lines)  $default,) {final _that = this;
switch (_that) {
case _DeliveryOrder():
return $default(_that.id,_that.facilityId,_that.serial,_that.customerId,_that.salesOrderIds,_that.shipToId,_that.date,_that.priority,_that.status,_that.type,_that.parentId,_that.contactId,_that.comment,_that.rejectionReason,_that.proofId,_that.createdAt,_that.modifiedAt,_that.lines);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int facilityId,  int? serial,  int customerId,  List<int> salesOrderIds,  int? shipToId,  DateTime? date,  int priority,  DeliveryOrderStatus status,  FulfillmentType type,  int? parentId,  int? contactId,  String? comment,  String? rejectionReason,  int? proofId,  DateTime createdAt,  DateTime modifiedAt,  List<DeliveryOrderLine> lines)?  $default,) {final _that = this;
switch (_that) {
case _DeliveryOrder() when $default != null:
return $default(_that.id,_that.facilityId,_that.serial,_that.customerId,_that.salesOrderIds,_that.shipToId,_that.date,_that.priority,_that.status,_that.type,_that.parentId,_that.contactId,_that.comment,_that.rejectionReason,_that.proofId,_that.createdAt,_that.modifiedAt,_that.lines);case _:
  return null;

}
}

}

/// @nodoc


class _DeliveryOrder extends DeliveryOrder {
  const _DeliveryOrder({required this.id, required this.facilityId, this.serial, required this.customerId,  List<int> salesOrderIds = const <int>[], this.shipToId, this.date, required this.priority, required this.status, required this.type, this.parentId, this.contactId, this.comment, this.rejectionReason, this.proofId, required this.createdAt, required this.modifiedAt,  List<DeliveryOrderLine> lines = const <DeliveryOrderLine>[]}): _salesOrderIds = salesOrderIds,_lines = lines,super._();
  

@override final  int id;
@override final  int facilityId;
@override final  int? serial;
@override final  int customerId;
 final  List<int> _salesOrderIds;
@override@JsonKey() List<int> get salesOrderIds {
  if (_salesOrderIds is EqualUnmodifiableListView) return _salesOrderIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_salesOrderIds);
}

@override final  int? shipToId;
@override final  DateTime? date;
@override final  int priority;
@override final  DeliveryOrderStatus status;
@override final  FulfillmentType type;
@override final  int? parentId;
@override final  int? contactId;
@override final  String? comment;
@override final  String? rejectionReason;
@override final  int? proofId;
@override final  DateTime createdAt;
@override final  DateTime modifiedAt;
 final  List<DeliveryOrderLine> _lines;
@override@JsonKey() List<DeliveryOrderLine> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}


/// Create a copy of DeliveryOrder
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeliveryOrderCopyWith<_DeliveryOrder> get copyWith => __$DeliveryOrderCopyWithImpl<_DeliveryOrder>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeliveryOrder&&(identical(other.id, id) || other.id == id)&&(identical(other.facilityId, facilityId) || other.facilityId == facilityId)&&(identical(other.serial, serial) || other.serial == serial)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&const DeepCollectionEquality().equals(other.salesOrderIds, _salesOrderIds)&&(identical(other.shipToId, shipToId) || other.shipToId == shipToId)&&(identical(other.date, date) || other.date == date)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.status, status) || other.status == status)&&(identical(other.type, type) || other.type == type)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.contactId, contactId) || other.contactId == contactId)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.proofId, proofId) || other.proofId == proofId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.modifiedAt, modifiedAt) || other.modifiedAt == modifiedAt)&&const DeepCollectionEquality().equals(other.lines, _lines));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,facilityId,serial,customerId,const DeepCollectionEquality().hash(_salesOrderIds),shipToId,date,priority,status,type,parentId,contactId,comment,rejectionReason,proofId,createdAt,modifiedAt,const DeepCollectionEquality().hash(_lines));
}

@override
String toString() {
    return 'DeliveryOrder(id: $id, facilityId: $facilityId, serial: $serial, customerId: $customerId, salesOrderIds: $salesOrderIds, shipToId: $shipToId, date: $date, priority: $priority, status: $status, type: $type, parentId: $parentId, contactId: $contactId, comment: $comment, rejectionReason: $rejectionReason, proofId: $proofId, createdAt: $createdAt, modifiedAt: $modifiedAt, lines: $lines)';
}


}

/// @nodoc
abstract mixin class _$DeliveryOrderCopyWith<$Res> implements $DeliveryOrderCopyWith<$Res> {
  factory _$DeliveryOrderCopyWith(_DeliveryOrder value, $Res Function(_DeliveryOrder) _then) = __$DeliveryOrderCopyWithImpl;
@override @useResult
$Res call({
 int id, int facilityId, int? serial, int customerId, List<int> salesOrderIds, int? shipToId, DateTime? date, int priority, DeliveryOrderStatus status, FulfillmentType type, int? parentId, int? contactId, String? comment, String? rejectionReason, int? proofId, DateTime createdAt, DateTime modifiedAt, List<DeliveryOrderLine> lines
});




}
/// @nodoc
class __$DeliveryOrderCopyWithImpl<$Res>
    implements _$DeliveryOrderCopyWith<$Res> {
  __$DeliveryOrderCopyWithImpl(this._self, this._then);

  final _DeliveryOrder _self;
  final $Res Function(_DeliveryOrder) _then;

/// Create a copy of DeliveryOrder
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? facilityId = null,Object? serial = freezed,Object? customerId = null,Object? salesOrderIds = null,Object? shipToId = freezed,Object? date = freezed,Object? priority = null,Object? status = null,Object? type = null,Object? parentId = freezed,Object? contactId = freezed,Object? comment = freezed,Object? rejectionReason = freezed,Object? proofId = freezed,Object? createdAt = null,Object? modifiedAt = null,Object? lines = null,}) {
  return _then(_DeliveryOrder(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as int?,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as int,salesOrderIds: null == salesOrderIds ? _self._salesOrderIds : salesOrderIds // ignore: cast_nullable_to_non_nullable
as List<int>,shipToId: freezed == shipToId ? _self.shipToId : shipToId // ignore: cast_nullable_to_non_nullable
as int?,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime?,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DeliveryOrderStatus,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as FulfillmentType,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as int?,contactId: freezed == contactId ? _self.contactId : contactId // ignore: cast_nullable_to_non_nullable
as int?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,proofId: freezed == proofId ? _self.proofId : proofId // ignore: cast_nullable_to_non_nullable
as int?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,modifiedAt: null == modifiedAt ? _self.modifiedAt : modifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<DeliveryOrderLine>,
  ));
}


}

/// @nodoc
mixin _$DeliveryOrderLine {

 int get id; int? get salesOrderDetailId; int get productId; String get productCode; String get productName; int get warehouseId; Decimal get quantity; Decimal get committed; Decimal get delivered; Decimal get returned; Decimal get open;
/// Create a copy of DeliveryOrderLine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeliveryOrderLineCopyWith<DeliveryOrderLine> get copyWith => _$DeliveryOrderLineCopyWithImpl<DeliveryOrderLine>(this as DeliveryOrderLine, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DeliveryOrderLine;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeliveryOrderLine&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.salesOrderDetailId, _this.salesOrderDetailId) || other.salesOrderDetailId == _this.salesOrderDetailId)&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.productCode, _this.productCode) || other.productCode == _this.productCode)&&(identical(other.productName, _this.productName) || other.productName == _this.productName)&&(identical(other.warehouseId, _this.warehouseId) || other.warehouseId == _this.warehouseId)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity)&&(identical(other.committed, _this.committed) || other.committed == _this.committed)&&(identical(other.delivered, _this.delivered) || other.delivered == _this.delivered)&&(identical(other.returned, _this.returned) || other.returned == _this.returned)&&(identical(other.open, _this.open) || other.open == _this.open));
}


@override
int get hashCode {
  final _this = this as DeliveryOrderLine;
  return Object.hash(runtimeType,_this.id,_this.salesOrderDetailId,_this.productId,_this.productCode,_this.productName,_this.warehouseId,_this.quantity,_this.committed,_this.delivered,_this.returned,_this.open);
}

@override
String toString() {
  final _this = this as DeliveryOrderLine;
  return 'DeliveryOrderLine(id: ${_this.id}, salesOrderDetailId: ${_this.salesOrderDetailId}, productId: ${_this.productId}, productCode: ${_this.productCode}, productName: ${_this.productName}, warehouseId: ${_this.warehouseId}, quantity: ${_this.quantity}, committed: ${_this.committed}, delivered: ${_this.delivered}, returned: ${_this.returned}, open: ${_this.open})';
}


}

/// @nodoc
abstract mixin class $DeliveryOrderLineCopyWith<$Res>  {
  factory $DeliveryOrderLineCopyWith(DeliveryOrderLine value, $Res Function(DeliveryOrderLine) _then) = _$DeliveryOrderLineCopyWithImpl;
@useResult
$Res call({
 int id, int? salesOrderDetailId, int productId, String productCode, String productName, int warehouseId, Decimal quantity, Decimal committed, Decimal delivered, Decimal returned, Decimal open
});




}
/// @nodoc
class _$DeliveryOrderLineCopyWithImpl<$Res>
    implements $DeliveryOrderLineCopyWith<$Res> {
  _$DeliveryOrderLineCopyWithImpl(this._self, this._then);

  final DeliveryOrderLine _self;
  final $Res Function(DeliveryOrderLine) _then;

/// Create a copy of DeliveryOrderLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? salesOrderDetailId = freezed,Object? productId = null,Object? productCode = null,Object? productName = null,Object? warehouseId = null,Object? quantity = null,Object? committed = null,Object? delivered = null,Object? returned = null,Object? open = null,}) {
  return _then(DeliveryOrderLine(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,salesOrderDetailId: freezed == salesOrderDetailId ? _self.salesOrderDetailId : salesOrderDetailId // ignore: cast_nullable_to_non_nullable
as int?,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,productCode: null == productCode ? _self.productCode : productCode // ignore: cast_nullable_to_non_nullable
as String,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,warehouseId: null == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Decimal,committed: null == committed ? _self.committed : committed // ignore: cast_nullable_to_non_nullable
as Decimal,delivered: null == delivered ? _self.delivered : delivered // ignore: cast_nullable_to_non_nullable
as Decimal,returned: null == returned ? _self.returned : returned // ignore: cast_nullable_to_non_nullable
as Decimal,open: null == open ? _self.open : open // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}

}


/// Adds pattern-matching-related methods to [DeliveryOrderLine].
extension DeliveryOrderLinePatterns on DeliveryOrderLine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeliveryOrderLine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeliveryOrderLine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeliveryOrderLine value)  $default,){
final _that = this;
switch (_that) {
case _DeliveryOrderLine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeliveryOrderLine value)?  $default,){
final _that = this;
switch (_that) {
case _DeliveryOrderLine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int? salesOrderDetailId,  int productId,  String productCode,  String productName,  int warehouseId,  Decimal quantity,  Decimal committed,  Decimal delivered,  Decimal returned,  Decimal open)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeliveryOrderLine() when $default != null:
return $default(_that.id,_that.salesOrderDetailId,_that.productId,_that.productCode,_that.productName,_that.warehouseId,_that.quantity,_that.committed,_that.delivered,_that.returned,_that.open);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int? salesOrderDetailId,  int productId,  String productCode,  String productName,  int warehouseId,  Decimal quantity,  Decimal committed,  Decimal delivered,  Decimal returned,  Decimal open)  $default,) {final _that = this;
switch (_that) {
case _DeliveryOrderLine():
return $default(_that.id,_that.salesOrderDetailId,_that.productId,_that.productCode,_that.productName,_that.warehouseId,_that.quantity,_that.committed,_that.delivered,_that.returned,_that.open);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int? salesOrderDetailId,  int productId,  String productCode,  String productName,  int warehouseId,  Decimal quantity,  Decimal committed,  Decimal delivered,  Decimal returned,  Decimal open)?  $default,) {final _that = this;
switch (_that) {
case _DeliveryOrderLine() when $default != null:
return $default(_that.id,_that.salesOrderDetailId,_that.productId,_that.productCode,_that.productName,_that.warehouseId,_that.quantity,_that.committed,_that.delivered,_that.returned,_that.open);case _:
  return null;

}
}

}

/// @nodoc


class _DeliveryOrderLine implements DeliveryOrderLine {
  const _DeliveryOrderLine({required this.id, this.salesOrderDetailId, required this.productId, required this.productCode, required this.productName, required this.warehouseId, required this.quantity, required this.committed, required this.delivered, required this.returned, required this.open});
  

@override final  int id;
@override final  int? salesOrderDetailId;
@override final  int productId;
@override final  String productCode;
@override final  String productName;
@override final  int warehouseId;
@override final  Decimal quantity;
@override final  Decimal committed;
@override final  Decimal delivered;
@override final  Decimal returned;
@override final  Decimal open;

/// Create a copy of DeliveryOrderLine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeliveryOrderLineCopyWith<_DeliveryOrderLine> get copyWith => __$DeliveryOrderLineCopyWithImpl<_DeliveryOrderLine>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeliveryOrderLine&&(identical(other.id, id) || other.id == id)&&(identical(other.salesOrderDetailId, salesOrderDetailId) || other.salesOrderDetailId == salesOrderDetailId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productCode, productCode) || other.productCode == productCode)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.committed, committed) || other.committed == committed)&&(identical(other.delivered, delivered) || other.delivered == delivered)&&(identical(other.returned, returned) || other.returned == returned)&&(identical(other.open, open) || other.open == open));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,salesOrderDetailId,productId,productCode,productName,warehouseId,quantity,committed,delivered,returned,open);
}

@override
String toString() {
    return 'DeliveryOrderLine(id: $id, salesOrderDetailId: $salesOrderDetailId, productId: $productId, productCode: $productCode, productName: $productName, warehouseId: $warehouseId, quantity: $quantity, committed: $committed, delivered: $delivered, returned: $returned, open: $open)';
}


}

/// @nodoc
abstract mixin class _$DeliveryOrderLineCopyWith<$Res> implements $DeliveryOrderLineCopyWith<$Res> {
  factory _$DeliveryOrderLineCopyWith(_DeliveryOrderLine value, $Res Function(_DeliveryOrderLine) _then) = __$DeliveryOrderLineCopyWithImpl;
@override @useResult
$Res call({
 int id, int? salesOrderDetailId, int productId, String productCode, String productName, int warehouseId, Decimal quantity, Decimal committed, Decimal delivered, Decimal returned, Decimal open
});




}
/// @nodoc
class __$DeliveryOrderLineCopyWithImpl<$Res>
    implements _$DeliveryOrderLineCopyWith<$Res> {
  __$DeliveryOrderLineCopyWithImpl(this._self, this._then);

  final _DeliveryOrderLine _self;
  final $Res Function(_DeliveryOrderLine) _then;

/// Create a copy of DeliveryOrderLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? salesOrderDetailId = freezed,Object? productId = null,Object? productCode = null,Object? productName = null,Object? warehouseId = null,Object? quantity = null,Object? committed = null,Object? delivered = null,Object? returned = null,Object? open = null,}) {
  return _then(_DeliveryOrderLine(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,salesOrderDetailId: freezed == salesOrderDetailId ? _self.salesOrderDetailId : salesOrderDetailId // ignore: cast_nullable_to_non_nullable
as int?,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,productCode: null == productCode ? _self.productCode : productCode // ignore: cast_nullable_to_non_nullable
as String,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,warehouseId: null == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Decimal,committed: null == committed ? _self.committed : committed // ignore: cast_nullable_to_non_nullable
as Decimal,delivered: null == delivered ? _self.delivered : delivered // ignore: cast_nullable_to_non_nullable
as Decimal,returned: null == returned ? _self.returned : returned // ignore: cast_nullable_to_non_nullable
as Decimal,open: null == open ? _self.open : open // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}


}

/// @nodoc
mixin _$DeliveryOrderEvent {

 int get id;/// Null on the creation event.
 DeliveryOrderStatus? get from; DeliveryOrderStatus get to; int get employeeId; DateTime get at; String? get reason;
/// Create a copy of DeliveryOrderEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeliveryOrderEventCopyWith<DeliveryOrderEvent> get copyWith => _$DeliveryOrderEventCopyWithImpl<DeliveryOrderEvent>(this as DeliveryOrderEvent, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DeliveryOrderEvent;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeliveryOrderEvent&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.from, _this.from) || other.from == _this.from)&&(identical(other.to, _this.to) || other.to == _this.to)&&(identical(other.employeeId, _this.employeeId) || other.employeeId == _this.employeeId)&&(identical(other.at, _this.at) || other.at == _this.at)&&(identical(other.reason, _this.reason) || other.reason == _this.reason));
}


@override
int get hashCode {
  final _this = this as DeliveryOrderEvent;
  return Object.hash(runtimeType,_this.id,_this.from,_this.to,_this.employeeId,_this.at,_this.reason);
}

@override
String toString() {
  final _this = this as DeliveryOrderEvent;
  return 'DeliveryOrderEvent(id: ${_this.id}, from: ${_this.from}, to: ${_this.to}, employeeId: ${_this.employeeId}, at: ${_this.at}, reason: ${_this.reason})';
}


}

/// @nodoc
abstract mixin class $DeliveryOrderEventCopyWith<$Res>  {
  factory $DeliveryOrderEventCopyWith(DeliveryOrderEvent value, $Res Function(DeliveryOrderEvent) _then) = _$DeliveryOrderEventCopyWithImpl;
@useResult
$Res call({
 int id, DeliveryOrderStatus? from, DeliveryOrderStatus to, int employeeId, DateTime at, String? reason
});




}
/// @nodoc
class _$DeliveryOrderEventCopyWithImpl<$Res>
    implements $DeliveryOrderEventCopyWith<$Res> {
  _$DeliveryOrderEventCopyWithImpl(this._self, this._then);

  final DeliveryOrderEvent _self;
  final $Res Function(DeliveryOrderEvent) _then;

/// Create a copy of DeliveryOrderEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? from = freezed,Object? to = null,Object? employeeId = null,Object? at = null,Object? reason = freezed,}) {
  return _then(DeliveryOrderEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,from: freezed == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DeliveryOrderStatus?,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DeliveryOrderStatus,employeeId: null == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as int,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DeliveryOrderEvent].
extension DeliveryOrderEventPatterns on DeliveryOrderEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeliveryOrderEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeliveryOrderEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeliveryOrderEvent value)  $default,){
final _that = this;
switch (_that) {
case _DeliveryOrderEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeliveryOrderEvent value)?  $default,){
final _that = this;
switch (_that) {
case _DeliveryOrderEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  DeliveryOrderStatus? from,  DeliveryOrderStatus to,  int employeeId,  DateTime at,  String? reason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeliveryOrderEvent() when $default != null:
return $default(_that.id,_that.from,_that.to,_that.employeeId,_that.at,_that.reason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  DeliveryOrderStatus? from,  DeliveryOrderStatus to,  int employeeId,  DateTime at,  String? reason)  $default,) {final _that = this;
switch (_that) {
case _DeliveryOrderEvent():
return $default(_that.id,_that.from,_that.to,_that.employeeId,_that.at,_that.reason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  DeliveryOrderStatus? from,  DeliveryOrderStatus to,  int employeeId,  DateTime at,  String? reason)?  $default,) {final _that = this;
switch (_that) {
case _DeliveryOrderEvent() when $default != null:
return $default(_that.id,_that.from,_that.to,_that.employeeId,_that.at,_that.reason);case _:
  return null;

}
}

}

/// @nodoc


class _DeliveryOrderEvent implements DeliveryOrderEvent {
  const _DeliveryOrderEvent({required this.id, this.from, required this.to, required this.employeeId, required this.at, this.reason});
  

@override final  int id;
/// Null on the creation event.
@override final  DeliveryOrderStatus? from;
@override final  DeliveryOrderStatus to;
@override final  int employeeId;
@override final  DateTime at;
@override final  String? reason;

/// Create a copy of DeliveryOrderEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeliveryOrderEventCopyWith<_DeliveryOrderEvent> get copyWith => __$DeliveryOrderEventCopyWithImpl<_DeliveryOrderEvent>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeliveryOrderEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.at, at) || other.at == at)&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,from,to,employeeId,at,reason);
}

@override
String toString() {
    return 'DeliveryOrderEvent(id: $id, from: $from, to: $to, employeeId: $employeeId, at: $at, reason: $reason)';
}


}

/// @nodoc
abstract mixin class _$DeliveryOrderEventCopyWith<$Res> implements $DeliveryOrderEventCopyWith<$Res> {
  factory _$DeliveryOrderEventCopyWith(_DeliveryOrderEvent value, $Res Function(_DeliveryOrderEvent) _then) = __$DeliveryOrderEventCopyWithImpl;
@override @useResult
$Res call({
 int id, DeliveryOrderStatus? from, DeliveryOrderStatus to, int employeeId, DateTime at, String? reason
});




}
/// @nodoc
class __$DeliveryOrderEventCopyWithImpl<$Res>
    implements _$DeliveryOrderEventCopyWith<$Res> {
  __$DeliveryOrderEventCopyWithImpl(this._self, this._then);

  final _DeliveryOrderEvent _self;
  final $Res Function(_DeliveryOrderEvent) _then;

/// Create a copy of DeliveryOrderEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? from = freezed,Object? to = null,Object? employeeId = null,Object? at = null,Object? reason = freezed,}) {
  return _then(_DeliveryOrderEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,from: freezed == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DeliveryOrderStatus?,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DeliveryOrderStatus,employeeId: null == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as int,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$ProofOfDelivery {

 String get receiverName;/// Free text: whatever ID the receiver showed.
 String get receiverIdShown; DateTime get capturedAt; int get capturedBy;
/// Create a copy of ProofOfDelivery
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProofOfDeliveryCopyWith<ProofOfDelivery> get copyWith => _$ProofOfDeliveryCopyWithImpl<ProofOfDelivery>(this as ProofOfDelivery, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ProofOfDelivery;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProofOfDelivery&&(identical(other.receiverName, _this.receiverName) || other.receiverName == _this.receiverName)&&(identical(other.receiverIdShown, _this.receiverIdShown) || other.receiverIdShown == _this.receiverIdShown)&&(identical(other.capturedAt, _this.capturedAt) || other.capturedAt == _this.capturedAt)&&(identical(other.capturedBy, _this.capturedBy) || other.capturedBy == _this.capturedBy));
}


@override
int get hashCode {
  final _this = this as ProofOfDelivery;
  return Object.hash(runtimeType,_this.receiverName,_this.receiverIdShown,_this.capturedAt,_this.capturedBy);
}

@override
String toString() {
  final _this = this as ProofOfDelivery;
  return 'ProofOfDelivery(receiverName: ${_this.receiverName}, receiverIdShown: ${_this.receiverIdShown}, capturedAt: ${_this.capturedAt}, capturedBy: ${_this.capturedBy})';
}


}

/// @nodoc
abstract mixin class $ProofOfDeliveryCopyWith<$Res>  {
  factory $ProofOfDeliveryCopyWith(ProofOfDelivery value, $Res Function(ProofOfDelivery) _then) = _$ProofOfDeliveryCopyWithImpl;
@useResult
$Res call({
 String receiverName, String receiverIdShown, DateTime capturedAt, int capturedBy
});




}
/// @nodoc
class _$ProofOfDeliveryCopyWithImpl<$Res>
    implements $ProofOfDeliveryCopyWith<$Res> {
  _$ProofOfDeliveryCopyWithImpl(this._self, this._then);

  final ProofOfDelivery _self;
  final $Res Function(ProofOfDelivery) _then;

/// Create a copy of ProofOfDelivery
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? receiverName = null,Object? receiverIdShown = null,Object? capturedAt = null,Object? capturedBy = null,}) {
  return _then(ProofOfDelivery(
receiverName: null == receiverName ? _self.receiverName : receiverName // ignore: cast_nullable_to_non_nullable
as String,receiverIdShown: null == receiverIdShown ? _self.receiverIdShown : receiverIdShown // ignore: cast_nullable_to_non_nullable
as String,capturedAt: null == capturedAt ? _self.capturedAt : capturedAt // ignore: cast_nullable_to_non_nullable
as DateTime,capturedBy: null == capturedBy ? _self.capturedBy : capturedBy // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ProofOfDelivery].
extension ProofOfDeliveryPatterns on ProofOfDelivery {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProofOfDelivery value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProofOfDelivery() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProofOfDelivery value)  $default,){
final _that = this;
switch (_that) {
case _ProofOfDelivery():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProofOfDelivery value)?  $default,){
final _that = this;
switch (_that) {
case _ProofOfDelivery() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String receiverName,  String receiverIdShown,  DateTime capturedAt,  int capturedBy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProofOfDelivery() when $default != null:
return $default(_that.receiverName,_that.receiverIdShown,_that.capturedAt,_that.capturedBy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String receiverName,  String receiverIdShown,  DateTime capturedAt,  int capturedBy)  $default,) {final _that = this;
switch (_that) {
case _ProofOfDelivery():
return $default(_that.receiverName,_that.receiverIdShown,_that.capturedAt,_that.capturedBy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String receiverName,  String receiverIdShown,  DateTime capturedAt,  int capturedBy)?  $default,) {final _that = this;
switch (_that) {
case _ProofOfDelivery() when $default != null:
return $default(_that.receiverName,_that.receiverIdShown,_that.capturedAt,_that.capturedBy);case _:
  return null;

}
}

}

/// @nodoc


class _ProofOfDelivery implements ProofOfDelivery {
  const _ProofOfDelivery({required this.receiverName, required this.receiverIdShown, required this.capturedAt, required this.capturedBy});
  

@override final  String receiverName;
/// Free text: whatever ID the receiver showed.
@override final  String receiverIdShown;
@override final  DateTime capturedAt;
@override final  int capturedBy;

/// Create a copy of ProofOfDelivery
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProofOfDeliveryCopyWith<_ProofOfDelivery> get copyWith => __$ProofOfDeliveryCopyWithImpl<_ProofOfDelivery>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProofOfDelivery&&(identical(other.receiverName, receiverName) || other.receiverName == receiverName)&&(identical(other.receiverIdShown, receiverIdShown) || other.receiverIdShown == receiverIdShown)&&(identical(other.capturedAt, capturedAt) || other.capturedAt == capturedAt)&&(identical(other.capturedBy, capturedBy) || other.capturedBy == capturedBy));
}


@override
int get hashCode {
    return Object.hash(runtimeType,receiverName,receiverIdShown,capturedAt,capturedBy);
}

@override
String toString() {
    return 'ProofOfDelivery(receiverName: $receiverName, receiverIdShown: $receiverIdShown, capturedAt: $capturedAt, capturedBy: $capturedBy)';
}


}

/// @nodoc
abstract mixin class _$ProofOfDeliveryCopyWith<$Res> implements $ProofOfDeliveryCopyWith<$Res> {
  factory _$ProofOfDeliveryCopyWith(_ProofOfDelivery value, $Res Function(_ProofOfDelivery) _then) = __$ProofOfDeliveryCopyWithImpl;
@override @useResult
$Res call({
 String receiverName, String receiverIdShown, DateTime capturedAt, int capturedBy
});




}
/// @nodoc
class __$ProofOfDeliveryCopyWithImpl<$Res>
    implements _$ProofOfDeliveryCopyWith<$Res> {
  __$ProofOfDeliveryCopyWithImpl(this._self, this._then);

  final _ProofOfDelivery _self;
  final $Res Function(_ProofOfDelivery) _then;

/// Create a copy of ProofOfDelivery
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? receiverName = null,Object? receiverIdShown = null,Object? capturedAt = null,Object? capturedBy = null,}) {
  return _then(_ProofOfDelivery(
receiverName: null == receiverName ? _self.receiverName : receiverName // ignore: cast_nullable_to_non_nullable
as String,receiverIdShown: null == receiverIdShown ? _self.receiverIdShown : receiverIdShown // ignore: cast_nullable_to_non_nullable
as String,capturedAt: null == capturedAt ? _self.capturedAt : capturedAt // ignore: cast_nullable_to_non_nullable
as DateTime,capturedBy: null == capturedBy ? _self.capturedBy : capturedBy // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
