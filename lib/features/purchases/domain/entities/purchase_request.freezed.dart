// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'purchase_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PurchaseRequestSummary {

 int get id;/// Null until the first submit.
 int? get serial; PurchaseRequestStatus get status; int get warehouseId; int? get facilityId; DateTime get date; String? get comment; int get creatorId; int get updaterId;/// Set on approve, cleared on reject.
 int? get approverId; DateTime? get approvalTime; int get lineCount;
/// Create a copy of PurchaseRequestSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PurchaseRequestSummaryCopyWith<PurchaseRequestSummary> get copyWith => _$PurchaseRequestSummaryCopyWithImpl<PurchaseRequestSummary>(this as PurchaseRequestSummary, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PurchaseRequestSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PurchaseRequestSummary&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.serial, _this.serial) || other.serial == _this.serial)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.warehouseId, _this.warehouseId) || other.warehouseId == _this.warehouseId)&&(identical(other.facilityId, _this.facilityId) || other.facilityId == _this.facilityId)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.comment, _this.comment) || other.comment == _this.comment)&&(identical(other.creatorId, _this.creatorId) || other.creatorId == _this.creatorId)&&(identical(other.updaterId, _this.updaterId) || other.updaterId == _this.updaterId)&&(identical(other.approverId, _this.approverId) || other.approverId == _this.approverId)&&(identical(other.approvalTime, _this.approvalTime) || other.approvalTime == _this.approvalTime)&&(identical(other.lineCount, _this.lineCount) || other.lineCount == _this.lineCount));
}


@override
int get hashCode {
  final _this = this as PurchaseRequestSummary;
  return Object.hash(runtimeType,_this.id,_this.serial,_this.status,_this.warehouseId,_this.facilityId,_this.date,_this.comment,_this.creatorId,_this.updaterId,_this.approverId,_this.approvalTime,_this.lineCount);
}

@override
String toString() {
  final _this = this as PurchaseRequestSummary;
  return 'PurchaseRequestSummary(id: ${_this.id}, serial: ${_this.serial}, status: ${_this.status}, warehouseId: ${_this.warehouseId}, facilityId: ${_this.facilityId}, date: ${_this.date}, comment: ${_this.comment}, creatorId: ${_this.creatorId}, updaterId: ${_this.updaterId}, approverId: ${_this.approverId}, approvalTime: ${_this.approvalTime}, lineCount: ${_this.lineCount})';
}


}

/// @nodoc
abstract mixin class $PurchaseRequestSummaryCopyWith<$Res>  {
  factory $PurchaseRequestSummaryCopyWith(PurchaseRequestSummary value, $Res Function(PurchaseRequestSummary) _then) = _$PurchaseRequestSummaryCopyWithImpl;
@useResult
$Res call({
 int id, int? serial, PurchaseRequestStatus status, int warehouseId, int? facilityId, DateTime date, String? comment, int creatorId, int updaterId, int? approverId, DateTime? approvalTime, int lineCount
});




}
/// @nodoc
class _$PurchaseRequestSummaryCopyWithImpl<$Res>
    implements $PurchaseRequestSummaryCopyWith<$Res> {
  _$PurchaseRequestSummaryCopyWithImpl(this._self, this._then);

  final PurchaseRequestSummary _self;
  final $Res Function(PurchaseRequestSummary) _then;

/// Create a copy of PurchaseRequestSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? serial = freezed,Object? status = null,Object? warehouseId = null,Object? facilityId = freezed,Object? date = null,Object? comment = freezed,Object? creatorId = null,Object? updaterId = null,Object? approverId = freezed,Object? approvalTime = freezed,Object? lineCount = null,}) {
  return _then(PurchaseRequestSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PurchaseRequestStatus,warehouseId: null == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int,facilityId: freezed == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int?,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as int,updaterId: null == updaterId ? _self.updaterId : updaterId // ignore: cast_nullable_to_non_nullable
as int,approverId: freezed == approverId ? _self.approverId : approverId // ignore: cast_nullable_to_non_nullable
as int?,approvalTime: freezed == approvalTime ? _self.approvalTime : approvalTime // ignore: cast_nullable_to_non_nullable
as DateTime?,lineCount: null == lineCount ? _self.lineCount : lineCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PurchaseRequestSummary].
extension PurchaseRequestSummaryPatterns on PurchaseRequestSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PurchaseRequestSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PurchaseRequestSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PurchaseRequestSummary value)  $default,){
final _that = this;
switch (_that) {
case _PurchaseRequestSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PurchaseRequestSummary value)?  $default,){
final _that = this;
switch (_that) {
case _PurchaseRequestSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int? serial,  PurchaseRequestStatus status,  int warehouseId,  int? facilityId,  DateTime date,  String? comment,  int creatorId,  int updaterId,  int? approverId,  DateTime? approvalTime,  int lineCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PurchaseRequestSummary() when $default != null:
return $default(_that.id,_that.serial,_that.status,_that.warehouseId,_that.facilityId,_that.date,_that.comment,_that.creatorId,_that.updaterId,_that.approverId,_that.approvalTime,_that.lineCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int? serial,  PurchaseRequestStatus status,  int warehouseId,  int? facilityId,  DateTime date,  String? comment,  int creatorId,  int updaterId,  int? approverId,  DateTime? approvalTime,  int lineCount)  $default,) {final _that = this;
switch (_that) {
case _PurchaseRequestSummary():
return $default(_that.id,_that.serial,_that.status,_that.warehouseId,_that.facilityId,_that.date,_that.comment,_that.creatorId,_that.updaterId,_that.approverId,_that.approvalTime,_that.lineCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int? serial,  PurchaseRequestStatus status,  int warehouseId,  int? facilityId,  DateTime date,  String? comment,  int creatorId,  int updaterId,  int? approverId,  DateTime? approvalTime,  int lineCount)?  $default,) {final _that = this;
switch (_that) {
case _PurchaseRequestSummary() when $default != null:
return $default(_that.id,_that.serial,_that.status,_that.warehouseId,_that.facilityId,_that.date,_that.comment,_that.creatorId,_that.updaterId,_that.approverId,_that.approvalTime,_that.lineCount);case _:
  return null;

}
}

}

/// @nodoc


class _PurchaseRequestSummary implements PurchaseRequestSummary {
  const _PurchaseRequestSummary({required this.id, this.serial, required this.status, required this.warehouseId, this.facilityId, required this.date, this.comment, required this.creatorId, required this.updaterId, this.approverId, this.approvalTime, required this.lineCount});
  

@override final  int id;
/// Null until the first submit.
@override final  int? serial;
@override final  PurchaseRequestStatus status;
@override final  int warehouseId;
@override final  int? facilityId;
@override final  DateTime date;
@override final  String? comment;
@override final  int creatorId;
@override final  int updaterId;
/// Set on approve, cleared on reject.
@override final  int? approverId;
@override final  DateTime? approvalTime;
@override final  int lineCount;

/// Create a copy of PurchaseRequestSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PurchaseRequestSummaryCopyWith<_PurchaseRequestSummary> get copyWith => __$PurchaseRequestSummaryCopyWithImpl<_PurchaseRequestSummary>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PurchaseRequestSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.serial, serial) || other.serial == serial)&&(identical(other.status, status) || other.status == status)&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.facilityId, facilityId) || other.facilityId == facilityId)&&(identical(other.date, date) || other.date == date)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.updaterId, updaterId) || other.updaterId == updaterId)&&(identical(other.approverId, approverId) || other.approverId == approverId)&&(identical(other.approvalTime, approvalTime) || other.approvalTime == approvalTime)&&(identical(other.lineCount, lineCount) || other.lineCount == lineCount));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,serial,status,warehouseId,facilityId,date,comment,creatorId,updaterId,approverId,approvalTime,lineCount);
}

@override
String toString() {
    return 'PurchaseRequestSummary(id: $id, serial: $serial, status: $status, warehouseId: $warehouseId, facilityId: $facilityId, date: $date, comment: $comment, creatorId: $creatorId, updaterId: $updaterId, approverId: $approverId, approvalTime: $approvalTime, lineCount: $lineCount)';
}


}

/// @nodoc
abstract mixin class _$PurchaseRequestSummaryCopyWith<$Res> implements $PurchaseRequestSummaryCopyWith<$Res> {
  factory _$PurchaseRequestSummaryCopyWith(_PurchaseRequestSummary value, $Res Function(_PurchaseRequestSummary) _then) = __$PurchaseRequestSummaryCopyWithImpl;
@override @useResult
$Res call({
 int id, int? serial, PurchaseRequestStatus status, int warehouseId, int? facilityId, DateTime date, String? comment, int creatorId, int updaterId, int? approverId, DateTime? approvalTime, int lineCount
});




}
/// @nodoc
class __$PurchaseRequestSummaryCopyWithImpl<$Res>
    implements _$PurchaseRequestSummaryCopyWith<$Res> {
  __$PurchaseRequestSummaryCopyWithImpl(this._self, this._then);

  final _PurchaseRequestSummary _self;
  final $Res Function(_PurchaseRequestSummary) _then;

/// Create a copy of PurchaseRequestSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? serial = freezed,Object? status = null,Object? warehouseId = null,Object? facilityId = freezed,Object? date = null,Object? comment = freezed,Object? creatorId = null,Object? updaterId = null,Object? approverId = freezed,Object? approvalTime = freezed,Object? lineCount = null,}) {
  return _then(_PurchaseRequestSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PurchaseRequestStatus,warehouseId: null == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int,facilityId: freezed == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int?,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as int,updaterId: null == updaterId ? _self.updaterId : updaterId // ignore: cast_nullable_to_non_nullable
as int,approverId: freezed == approverId ? _self.approverId : approverId // ignore: cast_nullable_to_non_nullable
as int?,approvalTime: freezed == approvalTime ? _self.approvalTime : approvalTime // ignore: cast_nullable_to_non_nullable
as DateTime?,lineCount: null == lineCount ? _self.lineCount : lineCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$PurchaseRequestLine {

 int get id; int get productId;/// Empty when the server sends none.
 String get productCode; String get productName; Decimal get quantity;/// The line's destination: any facility, never in transit.
 int? get warehouseId;/// The purchase mark.
 bool get toPurchase; int? get minOrderQty;/// The live purchase order holding this line.
 int? get purchaseOrderId; InventoryDocumentStatus? get purchaseOrderStatus;
/// Create a copy of PurchaseRequestLine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PurchaseRequestLineCopyWith<PurchaseRequestLine> get copyWith => _$PurchaseRequestLineCopyWithImpl<PurchaseRequestLine>(this as PurchaseRequestLine, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PurchaseRequestLine;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PurchaseRequestLine&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.productCode, _this.productCode) || other.productCode == _this.productCode)&&(identical(other.productName, _this.productName) || other.productName == _this.productName)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity)&&(identical(other.warehouseId, _this.warehouseId) || other.warehouseId == _this.warehouseId)&&(identical(other.toPurchase, _this.toPurchase) || other.toPurchase == _this.toPurchase)&&(identical(other.minOrderQty, _this.minOrderQty) || other.minOrderQty == _this.minOrderQty)&&(identical(other.purchaseOrderId, _this.purchaseOrderId) || other.purchaseOrderId == _this.purchaseOrderId)&&(identical(other.purchaseOrderStatus, _this.purchaseOrderStatus) || other.purchaseOrderStatus == _this.purchaseOrderStatus));
}


@override
int get hashCode {
  final _this = this as PurchaseRequestLine;
  return Object.hash(runtimeType,_this.id,_this.productId,_this.productCode,_this.productName,_this.quantity,_this.warehouseId,_this.toPurchase,_this.minOrderQty,_this.purchaseOrderId,_this.purchaseOrderStatus);
}

@override
String toString() {
  final _this = this as PurchaseRequestLine;
  return 'PurchaseRequestLine(id: ${_this.id}, productId: ${_this.productId}, productCode: ${_this.productCode}, productName: ${_this.productName}, quantity: ${_this.quantity}, warehouseId: ${_this.warehouseId}, toPurchase: ${_this.toPurchase}, minOrderQty: ${_this.minOrderQty}, purchaseOrderId: ${_this.purchaseOrderId}, purchaseOrderStatus: ${_this.purchaseOrderStatus})';
}


}

/// @nodoc
abstract mixin class $PurchaseRequestLineCopyWith<$Res>  {
  factory $PurchaseRequestLineCopyWith(PurchaseRequestLine value, $Res Function(PurchaseRequestLine) _then) = _$PurchaseRequestLineCopyWithImpl;
@useResult
$Res call({
 int id, int productId, String productCode, String productName, Decimal quantity, int? warehouseId, bool toPurchase, int? minOrderQty, int? purchaseOrderId, InventoryDocumentStatus? purchaseOrderStatus
});




}
/// @nodoc
class _$PurchaseRequestLineCopyWithImpl<$Res>
    implements $PurchaseRequestLineCopyWith<$Res> {
  _$PurchaseRequestLineCopyWithImpl(this._self, this._then);

  final PurchaseRequestLine _self;
  final $Res Function(PurchaseRequestLine) _then;

/// Create a copy of PurchaseRequestLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? productId = null,Object? productCode = null,Object? productName = null,Object? quantity = null,Object? warehouseId = freezed,Object? toPurchase = null,Object? minOrderQty = freezed,Object? purchaseOrderId = freezed,Object? purchaseOrderStatus = freezed,}) {
  return _then(PurchaseRequestLine(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,productCode: null == productCode ? _self.productCode : productCode // ignore: cast_nullable_to_non_nullable
as String,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Decimal,warehouseId: freezed == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int?,toPurchase: null == toPurchase ? _self.toPurchase : toPurchase // ignore: cast_nullable_to_non_nullable
as bool,minOrderQty: freezed == minOrderQty ? _self.minOrderQty : minOrderQty // ignore: cast_nullable_to_non_nullable
as int?,purchaseOrderId: freezed == purchaseOrderId ? _self.purchaseOrderId : purchaseOrderId // ignore: cast_nullable_to_non_nullable
as int?,purchaseOrderStatus: freezed == purchaseOrderStatus ? _self.purchaseOrderStatus : purchaseOrderStatus // ignore: cast_nullable_to_non_nullable
as InventoryDocumentStatus?,
  ));
}

}


/// Adds pattern-matching-related methods to [PurchaseRequestLine].
extension PurchaseRequestLinePatterns on PurchaseRequestLine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PurchaseRequestLine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PurchaseRequestLine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PurchaseRequestLine value)  $default,){
final _that = this;
switch (_that) {
case _PurchaseRequestLine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PurchaseRequestLine value)?  $default,){
final _that = this;
switch (_that) {
case _PurchaseRequestLine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int productId,  String productCode,  String productName,  Decimal quantity,  int? warehouseId,  bool toPurchase,  int? minOrderQty,  int? purchaseOrderId,  InventoryDocumentStatus? purchaseOrderStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PurchaseRequestLine() when $default != null:
return $default(_that.id,_that.productId,_that.productCode,_that.productName,_that.quantity,_that.warehouseId,_that.toPurchase,_that.minOrderQty,_that.purchaseOrderId,_that.purchaseOrderStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int productId,  String productCode,  String productName,  Decimal quantity,  int? warehouseId,  bool toPurchase,  int? minOrderQty,  int? purchaseOrderId,  InventoryDocumentStatus? purchaseOrderStatus)  $default,) {final _that = this;
switch (_that) {
case _PurchaseRequestLine():
return $default(_that.id,_that.productId,_that.productCode,_that.productName,_that.quantity,_that.warehouseId,_that.toPurchase,_that.minOrderQty,_that.purchaseOrderId,_that.purchaseOrderStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int productId,  String productCode,  String productName,  Decimal quantity,  int? warehouseId,  bool toPurchase,  int? minOrderQty,  int? purchaseOrderId,  InventoryDocumentStatus? purchaseOrderStatus)?  $default,) {final _that = this;
switch (_that) {
case _PurchaseRequestLine() when $default != null:
return $default(_that.id,_that.productId,_that.productCode,_that.productName,_that.quantity,_that.warehouseId,_that.toPurchase,_that.minOrderQty,_that.purchaseOrderId,_that.purchaseOrderStatus);case _:
  return null;

}
}

}

/// @nodoc


class _PurchaseRequestLine implements PurchaseRequestLine {
  const _PurchaseRequestLine({required this.id, required this.productId, required this.productCode, required this.productName, required this.quantity, this.warehouseId, required this.toPurchase, this.minOrderQty, this.purchaseOrderId, this.purchaseOrderStatus});
  

@override final  int id;
@override final  int productId;
/// Empty when the server sends none.
@override final  String productCode;
@override final  String productName;
@override final  Decimal quantity;
/// The line's destination: any facility, never in transit.
@override final  int? warehouseId;
/// The purchase mark.
@override final  bool toPurchase;
@override final  int? minOrderQty;
/// The live purchase order holding this line.
@override final  int? purchaseOrderId;
@override final  InventoryDocumentStatus? purchaseOrderStatus;

/// Create a copy of PurchaseRequestLine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PurchaseRequestLineCopyWith<_PurchaseRequestLine> get copyWith => __$PurchaseRequestLineCopyWithImpl<_PurchaseRequestLine>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PurchaseRequestLine&&(identical(other.id, id) || other.id == id)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productCode, productCode) || other.productCode == productCode)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.toPurchase, toPurchase) || other.toPurchase == toPurchase)&&(identical(other.minOrderQty, minOrderQty) || other.minOrderQty == minOrderQty)&&(identical(other.purchaseOrderId, purchaseOrderId) || other.purchaseOrderId == purchaseOrderId)&&(identical(other.purchaseOrderStatus, purchaseOrderStatus) || other.purchaseOrderStatus == purchaseOrderStatus));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,productId,productCode,productName,quantity,warehouseId,toPurchase,minOrderQty,purchaseOrderId,purchaseOrderStatus);
}

@override
String toString() {
    return 'PurchaseRequestLine(id: $id, productId: $productId, productCode: $productCode, productName: $productName, quantity: $quantity, warehouseId: $warehouseId, toPurchase: $toPurchase, minOrderQty: $minOrderQty, purchaseOrderId: $purchaseOrderId, purchaseOrderStatus: $purchaseOrderStatus)';
}


}

/// @nodoc
abstract mixin class _$PurchaseRequestLineCopyWith<$Res> implements $PurchaseRequestLineCopyWith<$Res> {
  factory _$PurchaseRequestLineCopyWith(_PurchaseRequestLine value, $Res Function(_PurchaseRequestLine) _then) = __$PurchaseRequestLineCopyWithImpl;
@override @useResult
$Res call({
 int id, int productId, String productCode, String productName, Decimal quantity, int? warehouseId, bool toPurchase, int? minOrderQty, int? purchaseOrderId, InventoryDocumentStatus? purchaseOrderStatus
});




}
/// @nodoc
class __$PurchaseRequestLineCopyWithImpl<$Res>
    implements _$PurchaseRequestLineCopyWith<$Res> {
  __$PurchaseRequestLineCopyWithImpl(this._self, this._then);

  final _PurchaseRequestLine _self;
  final $Res Function(_PurchaseRequestLine) _then;

/// Create a copy of PurchaseRequestLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? productId = null,Object? productCode = null,Object? productName = null,Object? quantity = null,Object? warehouseId = freezed,Object? toPurchase = null,Object? minOrderQty = freezed,Object? purchaseOrderId = freezed,Object? purchaseOrderStatus = freezed,}) {
  return _then(_PurchaseRequestLine(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,productCode: null == productCode ? _self.productCode : productCode // ignore: cast_nullable_to_non_nullable
as String,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Decimal,warehouseId: freezed == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int?,toPurchase: null == toPurchase ? _self.toPurchase : toPurchase // ignore: cast_nullable_to_non_nullable
as bool,minOrderQty: freezed == minOrderQty ? _self.minOrderQty : minOrderQty // ignore: cast_nullable_to_non_nullable
as int?,purchaseOrderId: freezed == purchaseOrderId ? _self.purchaseOrderId : purchaseOrderId // ignore: cast_nullable_to_non_nullable
as int?,purchaseOrderStatus: freezed == purchaseOrderStatus ? _self.purchaseOrderStatus : purchaseOrderStatus // ignore: cast_nullable_to_non_nullable
as InventoryDocumentStatus?,
  ));
}


}

/// @nodoc
mixin _$PurchaseRequest {

 int get id; int? get serial; PurchaseRequestStatus get status; int get warehouseId; int? get facilityId; DateTime get date;/// An empty string is treated as no note by the mapper.
 String? get comment; int get creatorId; int get updaterId; int? get approverId; DateTime? get approvalTime; int get lineCount; List<PurchaseRequestLine> get lines;
/// Create a copy of PurchaseRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PurchaseRequestCopyWith<PurchaseRequest> get copyWith => _$PurchaseRequestCopyWithImpl<PurchaseRequest>(this as PurchaseRequest, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PurchaseRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PurchaseRequest&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.serial, _this.serial) || other.serial == _this.serial)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.warehouseId, _this.warehouseId) || other.warehouseId == _this.warehouseId)&&(identical(other.facilityId, _this.facilityId) || other.facilityId == _this.facilityId)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.comment, _this.comment) || other.comment == _this.comment)&&(identical(other.creatorId, _this.creatorId) || other.creatorId == _this.creatorId)&&(identical(other.updaterId, _this.updaterId) || other.updaterId == _this.updaterId)&&(identical(other.approverId, _this.approverId) || other.approverId == _this.approverId)&&(identical(other.approvalTime, _this.approvalTime) || other.approvalTime == _this.approvalTime)&&(identical(other.lineCount, _this.lineCount) || other.lineCount == _this.lineCount)&&const DeepCollectionEquality().equals(other.lines, _this.lines));
}


@override
int get hashCode {
  final _this = this as PurchaseRequest;
  return Object.hash(runtimeType,_this.id,_this.serial,_this.status,_this.warehouseId,_this.facilityId,_this.date,_this.comment,_this.creatorId,_this.updaterId,_this.approverId,_this.approvalTime,_this.lineCount,const DeepCollectionEquality().hash(_this.lines));
}

@override
String toString() {
  final _this = this as PurchaseRequest;
  return 'PurchaseRequest(id: ${_this.id}, serial: ${_this.serial}, status: ${_this.status}, warehouseId: ${_this.warehouseId}, facilityId: ${_this.facilityId}, date: ${_this.date}, comment: ${_this.comment}, creatorId: ${_this.creatorId}, updaterId: ${_this.updaterId}, approverId: ${_this.approverId}, approvalTime: ${_this.approvalTime}, lineCount: ${_this.lineCount}, lines: ${_this.lines})';
}


}

/// @nodoc
abstract mixin class $PurchaseRequestCopyWith<$Res>  {
  factory $PurchaseRequestCopyWith(PurchaseRequest value, $Res Function(PurchaseRequest) _then) = _$PurchaseRequestCopyWithImpl;
@useResult
$Res call({
 int id, int? serial, PurchaseRequestStatus status, int warehouseId, int? facilityId, DateTime date, String? comment, int creatorId, int updaterId, int? approverId, DateTime? approvalTime, int lineCount, List<PurchaseRequestLine> lines
});




}
/// @nodoc
class _$PurchaseRequestCopyWithImpl<$Res>
    implements $PurchaseRequestCopyWith<$Res> {
  _$PurchaseRequestCopyWithImpl(this._self, this._then);

  final PurchaseRequest _self;
  final $Res Function(PurchaseRequest) _then;

/// Create a copy of PurchaseRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? serial = freezed,Object? status = null,Object? warehouseId = null,Object? facilityId = freezed,Object? date = null,Object? comment = freezed,Object? creatorId = null,Object? updaterId = null,Object? approverId = freezed,Object? approvalTime = freezed,Object? lineCount = null,Object? lines = null,}) {
  return _then(PurchaseRequest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PurchaseRequestStatus,warehouseId: null == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int,facilityId: freezed == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int?,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as int,updaterId: null == updaterId ? _self.updaterId : updaterId // ignore: cast_nullable_to_non_nullable
as int,approverId: freezed == approverId ? _self.approverId : approverId // ignore: cast_nullable_to_non_nullable
as int?,approvalTime: freezed == approvalTime ? _self.approvalTime : approvalTime // ignore: cast_nullable_to_non_nullable
as DateTime?,lineCount: null == lineCount ? _self.lineCount : lineCount // ignore: cast_nullable_to_non_nullable
as int,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<PurchaseRequestLine>,
  ));
}

}


/// Adds pattern-matching-related methods to [PurchaseRequest].
extension PurchaseRequestPatterns on PurchaseRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PurchaseRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PurchaseRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PurchaseRequest value)  $default,){
final _that = this;
switch (_that) {
case _PurchaseRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PurchaseRequest value)?  $default,){
final _that = this;
switch (_that) {
case _PurchaseRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int? serial,  PurchaseRequestStatus status,  int warehouseId,  int? facilityId,  DateTime date,  String? comment,  int creatorId,  int updaterId,  int? approverId,  DateTime? approvalTime,  int lineCount,  List<PurchaseRequestLine> lines)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PurchaseRequest() when $default != null:
return $default(_that.id,_that.serial,_that.status,_that.warehouseId,_that.facilityId,_that.date,_that.comment,_that.creatorId,_that.updaterId,_that.approverId,_that.approvalTime,_that.lineCount,_that.lines);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int? serial,  PurchaseRequestStatus status,  int warehouseId,  int? facilityId,  DateTime date,  String? comment,  int creatorId,  int updaterId,  int? approverId,  DateTime? approvalTime,  int lineCount,  List<PurchaseRequestLine> lines)  $default,) {final _that = this;
switch (_that) {
case _PurchaseRequest():
return $default(_that.id,_that.serial,_that.status,_that.warehouseId,_that.facilityId,_that.date,_that.comment,_that.creatorId,_that.updaterId,_that.approverId,_that.approvalTime,_that.lineCount,_that.lines);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int? serial,  PurchaseRequestStatus status,  int warehouseId,  int? facilityId,  DateTime date,  String? comment,  int creatorId,  int updaterId,  int? approverId,  DateTime? approvalTime,  int lineCount,  List<PurchaseRequestLine> lines)?  $default,) {final _that = this;
switch (_that) {
case _PurchaseRequest() when $default != null:
return $default(_that.id,_that.serial,_that.status,_that.warehouseId,_that.facilityId,_that.date,_that.comment,_that.creatorId,_that.updaterId,_that.approverId,_that.approvalTime,_that.lineCount,_that.lines);case _:
  return null;

}
}

}

/// @nodoc


class _PurchaseRequest implements PurchaseRequest {
  const _PurchaseRequest({required this.id, this.serial, required this.status, required this.warehouseId, this.facilityId, required this.date, this.comment, required this.creatorId, required this.updaterId, this.approverId, this.approvalTime, required this.lineCount, required  List<PurchaseRequestLine> lines}): _lines = lines;
  

@override final  int id;
@override final  int? serial;
@override final  PurchaseRequestStatus status;
@override final  int warehouseId;
@override final  int? facilityId;
@override final  DateTime date;
/// An empty string is treated as no note by the mapper.
@override final  String? comment;
@override final  int creatorId;
@override final  int updaterId;
@override final  int? approverId;
@override final  DateTime? approvalTime;
@override final  int lineCount;
 final  List<PurchaseRequestLine> _lines;
@override List<PurchaseRequestLine> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}


/// Create a copy of PurchaseRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PurchaseRequestCopyWith<_PurchaseRequest> get copyWith => __$PurchaseRequestCopyWithImpl<_PurchaseRequest>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PurchaseRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.serial, serial) || other.serial == serial)&&(identical(other.status, status) || other.status == status)&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.facilityId, facilityId) || other.facilityId == facilityId)&&(identical(other.date, date) || other.date == date)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.updaterId, updaterId) || other.updaterId == updaterId)&&(identical(other.approverId, approverId) || other.approverId == approverId)&&(identical(other.approvalTime, approvalTime) || other.approvalTime == approvalTime)&&(identical(other.lineCount, lineCount) || other.lineCount == lineCount)&&const DeepCollectionEquality().equals(other.lines, _lines));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,serial,status,warehouseId,facilityId,date,comment,creatorId,updaterId,approverId,approvalTime,lineCount,const DeepCollectionEquality().hash(_lines));
}

@override
String toString() {
    return 'PurchaseRequest(id: $id, serial: $serial, status: $status, warehouseId: $warehouseId, facilityId: $facilityId, date: $date, comment: $comment, creatorId: $creatorId, updaterId: $updaterId, approverId: $approverId, approvalTime: $approvalTime, lineCount: $lineCount, lines: $lines)';
}


}

/// @nodoc
abstract mixin class _$PurchaseRequestCopyWith<$Res> implements $PurchaseRequestCopyWith<$Res> {
  factory _$PurchaseRequestCopyWith(_PurchaseRequest value, $Res Function(_PurchaseRequest) _then) = __$PurchaseRequestCopyWithImpl;
@override @useResult
$Res call({
 int id, int? serial, PurchaseRequestStatus status, int warehouseId, int? facilityId, DateTime date, String? comment, int creatorId, int updaterId, int? approverId, DateTime? approvalTime, int lineCount, List<PurchaseRequestLine> lines
});




}
/// @nodoc
class __$PurchaseRequestCopyWithImpl<$Res>
    implements _$PurchaseRequestCopyWith<$Res> {
  __$PurchaseRequestCopyWithImpl(this._self, this._then);

  final _PurchaseRequest _self;
  final $Res Function(_PurchaseRequest) _then;

/// Create a copy of PurchaseRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? serial = freezed,Object? status = null,Object? warehouseId = null,Object? facilityId = freezed,Object? date = null,Object? comment = freezed,Object? creatorId = null,Object? updaterId = null,Object? approverId = freezed,Object? approvalTime = freezed,Object? lineCount = null,Object? lines = null,}) {
  return _then(_PurchaseRequest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PurchaseRequestStatus,warehouseId: null == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int,facilityId: freezed == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int?,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as int,updaterId: null == updaterId ? _self.updaterId : updaterId // ignore: cast_nullable_to_non_nullable
as int,approverId: freezed == approverId ? _self.approverId : approverId // ignore: cast_nullable_to_non_nullable
as int?,approvalTime: freezed == approvalTime ? _self.approvalTime : approvalTime // ignore: cast_nullable_to_non_nullable
as DateTime?,lineCount: null == lineCount ? _self.lineCount : lineCount // ignore: cast_nullable_to_non_nullable
as int,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<PurchaseRequestLine>,
  ));
}


}

/// @nodoc
mixin _$BulkApproveOutcome {

 int get requestId; bool get approved;/// Built from the result's `code` and `params` when refused.
 ApiProblem? get problem;
/// Create a copy of BulkApproveOutcome
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BulkApproveOutcomeCopyWith<BulkApproveOutcome> get copyWith => _$BulkApproveOutcomeCopyWithImpl<BulkApproveOutcome>(this as BulkApproveOutcome, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as BulkApproveOutcome;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BulkApproveOutcome&&(identical(other.requestId, _this.requestId) || other.requestId == _this.requestId)&&(identical(other.approved, _this.approved) || other.approved == _this.approved)&&(identical(other.problem, _this.problem) || other.problem == _this.problem));
}


@override
int get hashCode {
  final _this = this as BulkApproveOutcome;
  return Object.hash(runtimeType,_this.requestId,_this.approved,_this.problem);
}

@override
String toString() {
  final _this = this as BulkApproveOutcome;
  return 'BulkApproveOutcome(requestId: ${_this.requestId}, approved: ${_this.approved}, problem: ${_this.problem})';
}


}

/// @nodoc
abstract mixin class $BulkApproveOutcomeCopyWith<$Res>  {
  factory $BulkApproveOutcomeCopyWith(BulkApproveOutcome value, $Res Function(BulkApproveOutcome) _then) = _$BulkApproveOutcomeCopyWithImpl;
@useResult
$Res call({
 int requestId, bool approved, ApiProblem? problem
});


$ApiProblemCopyWith<$Res>? get problem;

}
/// @nodoc
class _$BulkApproveOutcomeCopyWithImpl<$Res>
    implements $BulkApproveOutcomeCopyWith<$Res> {
  _$BulkApproveOutcomeCopyWithImpl(this._self, this._then);

  final BulkApproveOutcome _self;
  final $Res Function(BulkApproveOutcome) _then;

/// Create a copy of BulkApproveOutcome
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? requestId = null,Object? approved = null,Object? problem = freezed,}) {
  return _then(BulkApproveOutcome(
requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as int,approved: null == approved ? _self.approved : approved // ignore: cast_nullable_to_non_nullable
as bool,problem: freezed == problem ? _self.problem : problem // ignore: cast_nullable_to_non_nullable
as ApiProblem?,
  ));
}
/// Create a copy of BulkApproveOutcome
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ApiProblemCopyWith<$Res>? get problem {
    if (_self.problem == null) {
    return null;
  }

  return $ApiProblemCopyWith<$Res>(_self.problem!, (value) {
    return _then(_self.copyWith(problem: value));
  });
}
}


/// Adds pattern-matching-related methods to [BulkApproveOutcome].
extension BulkApproveOutcomePatterns on BulkApproveOutcome {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BulkApproveOutcome value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BulkApproveOutcome() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BulkApproveOutcome value)  $default,){
final _that = this;
switch (_that) {
case _BulkApproveOutcome():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BulkApproveOutcome value)?  $default,){
final _that = this;
switch (_that) {
case _BulkApproveOutcome() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int requestId,  bool approved,  ApiProblem? problem)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BulkApproveOutcome() when $default != null:
return $default(_that.requestId,_that.approved,_that.problem);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int requestId,  bool approved,  ApiProblem? problem)  $default,) {final _that = this;
switch (_that) {
case _BulkApproveOutcome():
return $default(_that.requestId,_that.approved,_that.problem);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int requestId,  bool approved,  ApiProblem? problem)?  $default,) {final _that = this;
switch (_that) {
case _BulkApproveOutcome() when $default != null:
return $default(_that.requestId,_that.approved,_that.problem);case _:
  return null;

}
}

}

/// @nodoc


class _BulkApproveOutcome implements BulkApproveOutcome {
  const _BulkApproveOutcome({required this.requestId, required this.approved, this.problem});
  

@override final  int requestId;
@override final  bool approved;
/// Built from the result's `code` and `params` when refused.
@override final  ApiProblem? problem;

/// Create a copy of BulkApproveOutcome
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BulkApproveOutcomeCopyWith<_BulkApproveOutcome> get copyWith => __$BulkApproveOutcomeCopyWithImpl<_BulkApproveOutcome>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BulkApproveOutcome&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.approved, approved) || other.approved == approved)&&(identical(other.problem, problem) || other.problem == problem));
}


@override
int get hashCode {
    return Object.hash(runtimeType,requestId,approved,problem);
}

@override
String toString() {
    return 'BulkApproveOutcome(requestId: $requestId, approved: $approved, problem: $problem)';
}


}

/// @nodoc
abstract mixin class _$BulkApproveOutcomeCopyWith<$Res> implements $BulkApproveOutcomeCopyWith<$Res> {
  factory _$BulkApproveOutcomeCopyWith(_BulkApproveOutcome value, $Res Function(_BulkApproveOutcome) _then) = __$BulkApproveOutcomeCopyWithImpl;
@override @useResult
$Res call({
 int requestId, bool approved, ApiProblem? problem
});


@override $ApiProblemCopyWith<$Res>? get problem;

}
/// @nodoc
class __$BulkApproveOutcomeCopyWithImpl<$Res>
    implements _$BulkApproveOutcomeCopyWith<$Res> {
  __$BulkApproveOutcomeCopyWithImpl(this._self, this._then);

  final _BulkApproveOutcome _self;
  final $Res Function(_BulkApproveOutcome) _then;

/// Create a copy of BulkApproveOutcome
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? requestId = null,Object? approved = null,Object? problem = freezed,}) {
  return _then(_BulkApproveOutcome(
requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as int,approved: null == approved ? _self.approved : approved // ignore: cast_nullable_to_non_nullable
as bool,problem: freezed == problem ? _self.problem : problem // ignore: cast_nullable_to_non_nullable
as ApiProblem?,
  ));
}

/// Create a copy of BulkApproveOutcome
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ApiProblemCopyWith<$Res>? get problem {
    if (_self.problem == null) {
    return null;
  }

  return $ApiProblemCopyWith<$Res>(_self.problem!, (value) {
    return _then(_self.copyWith(problem: value));
  });
}
}

// dart format on
