// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'purchase_order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PurchaseOrderSummary {

/// The order number.
 int get id; InventoryDocumentStatus get status; int? get supplierId; String? get supplierName;/// The wall-clock value the server holds; the UI shows the date only.
 DateTime? get estimatedReceiptDate; String? get comment; int get creatorId; int get updaterId; DateTime get createdAt; DateTime get modifiedAt; int get lineCount; Decimal get subtotal; Decimal get tax; Decimal get total;
/// Create a copy of PurchaseOrderSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PurchaseOrderSummaryCopyWith<PurchaseOrderSummary> get copyWith => _$PurchaseOrderSummaryCopyWithImpl<PurchaseOrderSummary>(this as PurchaseOrderSummary, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PurchaseOrderSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PurchaseOrderSummary&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.supplierId, _this.supplierId) || other.supplierId == _this.supplierId)&&(identical(other.supplierName, _this.supplierName) || other.supplierName == _this.supplierName)&&(identical(other.estimatedReceiptDate, _this.estimatedReceiptDate) || other.estimatedReceiptDate == _this.estimatedReceiptDate)&&(identical(other.comment, _this.comment) || other.comment == _this.comment)&&(identical(other.creatorId, _this.creatorId) || other.creatorId == _this.creatorId)&&(identical(other.updaterId, _this.updaterId) || other.updaterId == _this.updaterId)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.modifiedAt, _this.modifiedAt) || other.modifiedAt == _this.modifiedAt)&&(identical(other.lineCount, _this.lineCount) || other.lineCount == _this.lineCount)&&(identical(other.subtotal, _this.subtotal) || other.subtotal == _this.subtotal)&&(identical(other.tax, _this.tax) || other.tax == _this.tax)&&(identical(other.total, _this.total) || other.total == _this.total));
}


@override
int get hashCode {
  final _this = this as PurchaseOrderSummary;
  return Object.hash(runtimeType,_this.id,_this.status,_this.supplierId,_this.supplierName,_this.estimatedReceiptDate,_this.comment,_this.creatorId,_this.updaterId,_this.createdAt,_this.modifiedAt,_this.lineCount,_this.subtotal,_this.tax,_this.total);
}

@override
String toString() {
  final _this = this as PurchaseOrderSummary;
  return 'PurchaseOrderSummary(id: ${_this.id}, status: ${_this.status}, supplierId: ${_this.supplierId}, supplierName: ${_this.supplierName}, estimatedReceiptDate: ${_this.estimatedReceiptDate}, comment: ${_this.comment}, creatorId: ${_this.creatorId}, updaterId: ${_this.updaterId}, createdAt: ${_this.createdAt}, modifiedAt: ${_this.modifiedAt}, lineCount: ${_this.lineCount}, subtotal: ${_this.subtotal}, tax: ${_this.tax}, total: ${_this.total})';
}


}

/// @nodoc
abstract mixin class $PurchaseOrderSummaryCopyWith<$Res>  {
  factory $PurchaseOrderSummaryCopyWith(PurchaseOrderSummary value, $Res Function(PurchaseOrderSummary) _then) = _$PurchaseOrderSummaryCopyWithImpl;
@useResult
$Res call({
 int id, InventoryDocumentStatus status, int? supplierId, String? supplierName, DateTime? estimatedReceiptDate, String? comment, int creatorId, int updaterId, DateTime createdAt, DateTime modifiedAt, int lineCount, Decimal subtotal, Decimal tax, Decimal total
});




}
/// @nodoc
class _$PurchaseOrderSummaryCopyWithImpl<$Res>
    implements $PurchaseOrderSummaryCopyWith<$Res> {
  _$PurchaseOrderSummaryCopyWithImpl(this._self, this._then);

  final PurchaseOrderSummary _self;
  final $Res Function(PurchaseOrderSummary) _then;

/// Create a copy of PurchaseOrderSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? status = null,Object? supplierId = freezed,Object? supplierName = freezed,Object? estimatedReceiptDate = freezed,Object? comment = freezed,Object? creatorId = null,Object? updaterId = null,Object? createdAt = null,Object? modifiedAt = null,Object? lineCount = null,Object? subtotal = null,Object? tax = null,Object? total = null,}) {
  return _then(PurchaseOrderSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InventoryDocumentStatus,supplierId: freezed == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as int?,supplierName: freezed == supplierName ? _self.supplierName : supplierName // ignore: cast_nullable_to_non_nullable
as String?,estimatedReceiptDate: freezed == estimatedReceiptDate ? _self.estimatedReceiptDate : estimatedReceiptDate // ignore: cast_nullable_to_non_nullable
as DateTime?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as int,updaterId: null == updaterId ? _self.updaterId : updaterId // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,modifiedAt: null == modifiedAt ? _self.modifiedAt : modifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime,lineCount: null == lineCount ? _self.lineCount : lineCount // ignore: cast_nullable_to_non_nullable
as int,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as Decimal,tax: null == tax ? _self.tax : tax // ignore: cast_nullable_to_non_nullable
as Decimal,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}

}


/// Adds pattern-matching-related methods to [PurchaseOrderSummary].
extension PurchaseOrderSummaryPatterns on PurchaseOrderSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PurchaseOrderSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PurchaseOrderSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PurchaseOrderSummary value)  $default,){
final _that = this;
switch (_that) {
case _PurchaseOrderSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PurchaseOrderSummary value)?  $default,){
final _that = this;
switch (_that) {
case _PurchaseOrderSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  InventoryDocumentStatus status,  int? supplierId,  String? supplierName,  DateTime? estimatedReceiptDate,  String? comment,  int creatorId,  int updaterId,  DateTime createdAt,  DateTime modifiedAt,  int lineCount,  Decimal subtotal,  Decimal tax,  Decimal total)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PurchaseOrderSummary() when $default != null:
return $default(_that.id,_that.status,_that.supplierId,_that.supplierName,_that.estimatedReceiptDate,_that.comment,_that.creatorId,_that.updaterId,_that.createdAt,_that.modifiedAt,_that.lineCount,_that.subtotal,_that.tax,_that.total);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  InventoryDocumentStatus status,  int? supplierId,  String? supplierName,  DateTime? estimatedReceiptDate,  String? comment,  int creatorId,  int updaterId,  DateTime createdAt,  DateTime modifiedAt,  int lineCount,  Decimal subtotal,  Decimal tax,  Decimal total)  $default,) {final _that = this;
switch (_that) {
case _PurchaseOrderSummary():
return $default(_that.id,_that.status,_that.supplierId,_that.supplierName,_that.estimatedReceiptDate,_that.comment,_that.creatorId,_that.updaterId,_that.createdAt,_that.modifiedAt,_that.lineCount,_that.subtotal,_that.tax,_that.total);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  InventoryDocumentStatus status,  int? supplierId,  String? supplierName,  DateTime? estimatedReceiptDate,  String? comment,  int creatorId,  int updaterId,  DateTime createdAt,  DateTime modifiedAt,  int lineCount,  Decimal subtotal,  Decimal tax,  Decimal total)?  $default,) {final _that = this;
switch (_that) {
case _PurchaseOrderSummary() when $default != null:
return $default(_that.id,_that.status,_that.supplierId,_that.supplierName,_that.estimatedReceiptDate,_that.comment,_that.creatorId,_that.updaterId,_that.createdAt,_that.modifiedAt,_that.lineCount,_that.subtotal,_that.tax,_that.total);case _:
  return null;

}
}

}

/// @nodoc


class _PurchaseOrderSummary implements PurchaseOrderSummary {
  const _PurchaseOrderSummary({required this.id, required this.status, this.supplierId, this.supplierName, this.estimatedReceiptDate, this.comment, required this.creatorId, required this.updaterId, required this.createdAt, required this.modifiedAt, required this.lineCount, required this.subtotal, required this.tax, required this.total});
  

/// The order number.
@override final  int id;
@override final  InventoryDocumentStatus status;
@override final  int? supplierId;
@override final  String? supplierName;
/// The wall-clock value the server holds; the UI shows the date only.
@override final  DateTime? estimatedReceiptDate;
@override final  String? comment;
@override final  int creatorId;
@override final  int updaterId;
@override final  DateTime createdAt;
@override final  DateTime modifiedAt;
@override final  int lineCount;
@override final  Decimal subtotal;
@override final  Decimal tax;
@override final  Decimal total;

/// Create a copy of PurchaseOrderSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PurchaseOrderSummaryCopyWith<_PurchaseOrderSummary> get copyWith => __$PurchaseOrderSummaryCopyWithImpl<_PurchaseOrderSummary>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PurchaseOrderSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.supplierId, supplierId) || other.supplierId == supplierId)&&(identical(other.supplierName, supplierName) || other.supplierName == supplierName)&&(identical(other.estimatedReceiptDate, estimatedReceiptDate) || other.estimatedReceiptDate == estimatedReceiptDate)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.updaterId, updaterId) || other.updaterId == updaterId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.modifiedAt, modifiedAt) || other.modifiedAt == modifiedAt)&&(identical(other.lineCount, lineCount) || other.lineCount == lineCount)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.tax, tax) || other.tax == tax)&&(identical(other.total, total) || other.total == total));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,status,supplierId,supplierName,estimatedReceiptDate,comment,creatorId,updaterId,createdAt,modifiedAt,lineCount,subtotal,tax,total);
}

@override
String toString() {
    return 'PurchaseOrderSummary(id: $id, status: $status, supplierId: $supplierId, supplierName: $supplierName, estimatedReceiptDate: $estimatedReceiptDate, comment: $comment, creatorId: $creatorId, updaterId: $updaterId, createdAt: $createdAt, modifiedAt: $modifiedAt, lineCount: $lineCount, subtotal: $subtotal, tax: $tax, total: $total)';
}


}

/// @nodoc
abstract mixin class _$PurchaseOrderSummaryCopyWith<$Res> implements $PurchaseOrderSummaryCopyWith<$Res> {
  factory _$PurchaseOrderSummaryCopyWith(_PurchaseOrderSummary value, $Res Function(_PurchaseOrderSummary) _then) = __$PurchaseOrderSummaryCopyWithImpl;
@override @useResult
$Res call({
 int id, InventoryDocumentStatus status, int? supplierId, String? supplierName, DateTime? estimatedReceiptDate, String? comment, int creatorId, int updaterId, DateTime createdAt, DateTime modifiedAt, int lineCount, Decimal subtotal, Decimal tax, Decimal total
});




}
/// @nodoc
class __$PurchaseOrderSummaryCopyWithImpl<$Res>
    implements _$PurchaseOrderSummaryCopyWith<$Res> {
  __$PurchaseOrderSummaryCopyWithImpl(this._self, this._then);

  final _PurchaseOrderSummary _self;
  final $Res Function(_PurchaseOrderSummary) _then;

/// Create a copy of PurchaseOrderSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? status = null,Object? supplierId = freezed,Object? supplierName = freezed,Object? estimatedReceiptDate = freezed,Object? comment = freezed,Object? creatorId = null,Object? updaterId = null,Object? createdAt = null,Object? modifiedAt = null,Object? lineCount = null,Object? subtotal = null,Object? tax = null,Object? total = null,}) {
  return _then(_PurchaseOrderSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InventoryDocumentStatus,supplierId: freezed == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as int?,supplierName: freezed == supplierName ? _self.supplierName : supplierName // ignore: cast_nullable_to_non_nullable
as String?,estimatedReceiptDate: freezed == estimatedReceiptDate ? _self.estimatedReceiptDate : estimatedReceiptDate // ignore: cast_nullable_to_non_nullable
as DateTime?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as int,updaterId: null == updaterId ? _self.updaterId : updaterId // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,modifiedAt: null == modifiedAt ? _self.modifiedAt : modifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime,lineCount: null == lineCount ? _self.lineCount : lineCount // ignore: cast_nullable_to_non_nullable
as int,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as Decimal,tax: null == tax ? _self.tax : tax // ignore: cast_nullable_to_non_nullable
as Decimal,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}


}

/// @nodoc
mixin _$PurchaseOrderLine {

 int get id; int get productId; String get productCode; String get productName; int? get warehouseId;/// More than 0, up to 4 decimals.
 Decimal get quantity;/// Unit price before tax, 0 or more, up to 7 decimals.
 Decimal get price;/// A fraction: 0 up to (not including) 1.
 Decimal get taxRate; Decimal get amount;/// The request line this line came from.
 int? get requestLineId; int? get requestId;/// Null on a non-stockable product.
 Decimal? get quantityReceived; Decimal? get quantityPending;
/// Create a copy of PurchaseOrderLine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PurchaseOrderLineCopyWith<PurchaseOrderLine> get copyWith => _$PurchaseOrderLineCopyWithImpl<PurchaseOrderLine>(this as PurchaseOrderLine, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PurchaseOrderLine;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PurchaseOrderLine&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.productCode, _this.productCode) || other.productCode == _this.productCode)&&(identical(other.productName, _this.productName) || other.productName == _this.productName)&&(identical(other.warehouseId, _this.warehouseId) || other.warehouseId == _this.warehouseId)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity)&&(identical(other.price, _this.price) || other.price == _this.price)&&(identical(other.taxRate, _this.taxRate) || other.taxRate == _this.taxRate)&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.requestLineId, _this.requestLineId) || other.requestLineId == _this.requestLineId)&&(identical(other.requestId, _this.requestId) || other.requestId == _this.requestId)&&(identical(other.quantityReceived, _this.quantityReceived) || other.quantityReceived == _this.quantityReceived)&&(identical(other.quantityPending, _this.quantityPending) || other.quantityPending == _this.quantityPending));
}


@override
int get hashCode {
  final _this = this as PurchaseOrderLine;
  return Object.hash(runtimeType,_this.id,_this.productId,_this.productCode,_this.productName,_this.warehouseId,_this.quantity,_this.price,_this.taxRate,_this.amount,_this.requestLineId,_this.requestId,_this.quantityReceived,_this.quantityPending);
}

@override
String toString() {
  final _this = this as PurchaseOrderLine;
  return 'PurchaseOrderLine(id: ${_this.id}, productId: ${_this.productId}, productCode: ${_this.productCode}, productName: ${_this.productName}, warehouseId: ${_this.warehouseId}, quantity: ${_this.quantity}, price: ${_this.price}, taxRate: ${_this.taxRate}, amount: ${_this.amount}, requestLineId: ${_this.requestLineId}, requestId: ${_this.requestId}, quantityReceived: ${_this.quantityReceived}, quantityPending: ${_this.quantityPending})';
}


}

/// @nodoc
abstract mixin class $PurchaseOrderLineCopyWith<$Res>  {
  factory $PurchaseOrderLineCopyWith(PurchaseOrderLine value, $Res Function(PurchaseOrderLine) _then) = _$PurchaseOrderLineCopyWithImpl;
@useResult
$Res call({
 int id, int productId, String productCode, String productName, int? warehouseId, Decimal quantity, Decimal price, Decimal taxRate, Decimal amount, int? requestLineId, int? requestId, Decimal? quantityReceived, Decimal? quantityPending
});




}
/// @nodoc
class _$PurchaseOrderLineCopyWithImpl<$Res>
    implements $PurchaseOrderLineCopyWith<$Res> {
  _$PurchaseOrderLineCopyWithImpl(this._self, this._then);

  final PurchaseOrderLine _self;
  final $Res Function(PurchaseOrderLine) _then;

/// Create a copy of PurchaseOrderLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? productId = null,Object? productCode = null,Object? productName = null,Object? warehouseId = freezed,Object? quantity = null,Object? price = null,Object? taxRate = null,Object? amount = null,Object? requestLineId = freezed,Object? requestId = freezed,Object? quantityReceived = freezed,Object? quantityPending = freezed,}) {
  return _then(PurchaseOrderLine(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,productCode: null == productCode ? _self.productCode : productCode // ignore: cast_nullable_to_non_nullable
as String,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,warehouseId: freezed == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Decimal,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as Decimal,taxRate: null == taxRate ? _self.taxRate : taxRate // ignore: cast_nullable_to_non_nullable
as Decimal,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as Decimal,requestLineId: freezed == requestLineId ? _self.requestLineId : requestLineId // ignore: cast_nullable_to_non_nullable
as int?,requestId: freezed == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as int?,quantityReceived: freezed == quantityReceived ? _self.quantityReceived : quantityReceived // ignore: cast_nullable_to_non_nullable
as Decimal?,quantityPending: freezed == quantityPending ? _self.quantityPending : quantityPending // ignore: cast_nullable_to_non_nullable
as Decimal?,
  ));
}

}


/// Adds pattern-matching-related methods to [PurchaseOrderLine].
extension PurchaseOrderLinePatterns on PurchaseOrderLine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PurchaseOrderLine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PurchaseOrderLine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PurchaseOrderLine value)  $default,){
final _that = this;
switch (_that) {
case _PurchaseOrderLine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PurchaseOrderLine value)?  $default,){
final _that = this;
switch (_that) {
case _PurchaseOrderLine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int productId,  String productCode,  String productName,  int? warehouseId,  Decimal quantity,  Decimal price,  Decimal taxRate,  Decimal amount,  int? requestLineId,  int? requestId,  Decimal? quantityReceived,  Decimal? quantityPending)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PurchaseOrderLine() when $default != null:
return $default(_that.id,_that.productId,_that.productCode,_that.productName,_that.warehouseId,_that.quantity,_that.price,_that.taxRate,_that.amount,_that.requestLineId,_that.requestId,_that.quantityReceived,_that.quantityPending);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int productId,  String productCode,  String productName,  int? warehouseId,  Decimal quantity,  Decimal price,  Decimal taxRate,  Decimal amount,  int? requestLineId,  int? requestId,  Decimal? quantityReceived,  Decimal? quantityPending)  $default,) {final _that = this;
switch (_that) {
case _PurchaseOrderLine():
return $default(_that.id,_that.productId,_that.productCode,_that.productName,_that.warehouseId,_that.quantity,_that.price,_that.taxRate,_that.amount,_that.requestLineId,_that.requestId,_that.quantityReceived,_that.quantityPending);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int productId,  String productCode,  String productName,  int? warehouseId,  Decimal quantity,  Decimal price,  Decimal taxRate,  Decimal amount,  int? requestLineId,  int? requestId,  Decimal? quantityReceived,  Decimal? quantityPending)?  $default,) {final _that = this;
switch (_that) {
case _PurchaseOrderLine() when $default != null:
return $default(_that.id,_that.productId,_that.productCode,_that.productName,_that.warehouseId,_that.quantity,_that.price,_that.taxRate,_that.amount,_that.requestLineId,_that.requestId,_that.quantityReceived,_that.quantityPending);case _:
  return null;

}
}

}

/// @nodoc


class _PurchaseOrderLine implements PurchaseOrderLine {
  const _PurchaseOrderLine({required this.id, required this.productId, required this.productCode, required this.productName, this.warehouseId, required this.quantity, required this.price, required this.taxRate, required this.amount, this.requestLineId, this.requestId, this.quantityReceived, this.quantityPending});
  

@override final  int id;
@override final  int productId;
@override final  String productCode;
@override final  String productName;
@override final  int? warehouseId;
/// More than 0, up to 4 decimals.
@override final  Decimal quantity;
/// Unit price before tax, 0 or more, up to 7 decimals.
@override final  Decimal price;
/// A fraction: 0 up to (not including) 1.
@override final  Decimal taxRate;
@override final  Decimal amount;
/// The request line this line came from.
@override final  int? requestLineId;
@override final  int? requestId;
/// Null on a non-stockable product.
@override final  Decimal? quantityReceived;
@override final  Decimal? quantityPending;

/// Create a copy of PurchaseOrderLine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PurchaseOrderLineCopyWith<_PurchaseOrderLine> get copyWith => __$PurchaseOrderLineCopyWithImpl<_PurchaseOrderLine>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PurchaseOrderLine&&(identical(other.id, id) || other.id == id)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productCode, productCode) || other.productCode == productCode)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.price, price) || other.price == price)&&(identical(other.taxRate, taxRate) || other.taxRate == taxRate)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.requestLineId, requestLineId) || other.requestLineId == requestLineId)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.quantityReceived, quantityReceived) || other.quantityReceived == quantityReceived)&&(identical(other.quantityPending, quantityPending) || other.quantityPending == quantityPending));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,productId,productCode,productName,warehouseId,quantity,price,taxRate,amount,requestLineId,requestId,quantityReceived,quantityPending);
}

@override
String toString() {
    return 'PurchaseOrderLine(id: $id, productId: $productId, productCode: $productCode, productName: $productName, warehouseId: $warehouseId, quantity: $quantity, price: $price, taxRate: $taxRate, amount: $amount, requestLineId: $requestLineId, requestId: $requestId, quantityReceived: $quantityReceived, quantityPending: $quantityPending)';
}


}

/// @nodoc
abstract mixin class _$PurchaseOrderLineCopyWith<$Res> implements $PurchaseOrderLineCopyWith<$Res> {
  factory _$PurchaseOrderLineCopyWith(_PurchaseOrderLine value, $Res Function(_PurchaseOrderLine) _then) = __$PurchaseOrderLineCopyWithImpl;
@override @useResult
$Res call({
 int id, int productId, String productCode, String productName, int? warehouseId, Decimal quantity, Decimal price, Decimal taxRate, Decimal amount, int? requestLineId, int? requestId, Decimal? quantityReceived, Decimal? quantityPending
});




}
/// @nodoc
class __$PurchaseOrderLineCopyWithImpl<$Res>
    implements _$PurchaseOrderLineCopyWith<$Res> {
  __$PurchaseOrderLineCopyWithImpl(this._self, this._then);

  final _PurchaseOrderLine _self;
  final $Res Function(_PurchaseOrderLine) _then;

/// Create a copy of PurchaseOrderLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? productId = null,Object? productCode = null,Object? productName = null,Object? warehouseId = freezed,Object? quantity = null,Object? price = null,Object? taxRate = null,Object? amount = null,Object? requestLineId = freezed,Object? requestId = freezed,Object? quantityReceived = freezed,Object? quantityPending = freezed,}) {
  return _then(_PurchaseOrderLine(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,productCode: null == productCode ? _self.productCode : productCode // ignore: cast_nullable_to_non_nullable
as String,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,warehouseId: freezed == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Decimal,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as Decimal,taxRate: null == taxRate ? _self.taxRate : taxRate // ignore: cast_nullable_to_non_nullable
as Decimal,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as Decimal,requestLineId: freezed == requestLineId ? _self.requestLineId : requestLineId // ignore: cast_nullable_to_non_nullable
as int?,requestId: freezed == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as int?,quantityReceived: freezed == quantityReceived ? _self.quantityReceived : quantityReceived // ignore: cast_nullable_to_non_nullable
as Decimal?,quantityPending: freezed == quantityPending ? _self.quantityPending : quantityPending // ignore: cast_nullable_to_non_nullable
as Decimal?,
  ));
}


}

/// @nodoc
mixin _$OrderReceipt {

 int get id; int get warehouseId; int get facilityId; int get lineCount;
/// Create a copy of OrderReceipt
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderReceiptCopyWith<OrderReceipt> get copyWith => _$OrderReceiptCopyWithImpl<OrderReceipt>(this as OrderReceipt, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as OrderReceipt;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderReceipt&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.warehouseId, _this.warehouseId) || other.warehouseId == _this.warehouseId)&&(identical(other.facilityId, _this.facilityId) || other.facilityId == _this.facilityId)&&(identical(other.lineCount, _this.lineCount) || other.lineCount == _this.lineCount));
}


@override
int get hashCode {
  final _this = this as OrderReceipt;
  return Object.hash(runtimeType,_this.id,_this.warehouseId,_this.facilityId,_this.lineCount);
}

@override
String toString() {
  final _this = this as OrderReceipt;
  return 'OrderReceipt(id: ${_this.id}, warehouseId: ${_this.warehouseId}, facilityId: ${_this.facilityId}, lineCount: ${_this.lineCount})';
}


}

/// @nodoc
abstract mixin class $OrderReceiptCopyWith<$Res>  {
  factory $OrderReceiptCopyWith(OrderReceipt value, $Res Function(OrderReceipt) _then) = _$OrderReceiptCopyWithImpl;
@useResult
$Res call({
 int id, int warehouseId, int facilityId, int lineCount
});




}
/// @nodoc
class _$OrderReceiptCopyWithImpl<$Res>
    implements $OrderReceiptCopyWith<$Res> {
  _$OrderReceiptCopyWithImpl(this._self, this._then);

  final OrderReceipt _self;
  final $Res Function(OrderReceipt) _then;

/// Create a copy of OrderReceipt
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? warehouseId = null,Object? facilityId = null,Object? lineCount = null,}) {
  return _then(OrderReceipt(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,warehouseId: null == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int,facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int,lineCount: null == lineCount ? _self.lineCount : lineCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderReceipt].
extension OrderReceiptPatterns on OrderReceipt {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderReceipt value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderReceipt() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderReceipt value)  $default,){
final _that = this;
switch (_that) {
case _OrderReceipt():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderReceipt value)?  $default,){
final _that = this;
switch (_that) {
case _OrderReceipt() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int warehouseId,  int facilityId,  int lineCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderReceipt() when $default != null:
return $default(_that.id,_that.warehouseId,_that.facilityId,_that.lineCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int warehouseId,  int facilityId,  int lineCount)  $default,) {final _that = this;
switch (_that) {
case _OrderReceipt():
return $default(_that.id,_that.warehouseId,_that.facilityId,_that.lineCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int warehouseId,  int facilityId,  int lineCount)?  $default,) {final _that = this;
switch (_that) {
case _OrderReceipt() when $default != null:
return $default(_that.id,_that.warehouseId,_that.facilityId,_that.lineCount);case _:
  return null;

}
}

}

/// @nodoc


class _OrderReceipt implements OrderReceipt {
  const _OrderReceipt({required this.id, required this.warehouseId, required this.facilityId, required this.lineCount});
  

@override final  int id;
@override final  int warehouseId;
@override final  int facilityId;
@override final  int lineCount;

/// Create a copy of OrderReceipt
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderReceiptCopyWith<_OrderReceipt> get copyWith => __$OrderReceiptCopyWithImpl<_OrderReceipt>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderReceipt&&(identical(other.id, id) || other.id == id)&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.facilityId, facilityId) || other.facilityId == facilityId)&&(identical(other.lineCount, lineCount) || other.lineCount == lineCount));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,warehouseId,facilityId,lineCount);
}

@override
String toString() {
    return 'OrderReceipt(id: $id, warehouseId: $warehouseId, facilityId: $facilityId, lineCount: $lineCount)';
}


}

/// @nodoc
abstract mixin class _$OrderReceiptCopyWith<$Res> implements $OrderReceiptCopyWith<$Res> {
  factory _$OrderReceiptCopyWith(_OrderReceipt value, $Res Function(_OrderReceipt) _then) = __$OrderReceiptCopyWithImpl;
@override @useResult
$Res call({
 int id, int warehouseId, int facilityId, int lineCount
});




}
/// @nodoc
class __$OrderReceiptCopyWithImpl<$Res>
    implements _$OrderReceiptCopyWith<$Res> {
  __$OrderReceiptCopyWithImpl(this._self, this._then);

  final _OrderReceipt _self;
  final $Res Function(_OrderReceipt) _then;

/// Create a copy of OrderReceipt
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? warehouseId = null,Object? facilityId = null,Object? lineCount = null,}) {
  return _then(_OrderReceipt(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,warehouseId: null == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int,facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int,lineCount: null == lineCount ? _self.lineCount : lineCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$PurchaseOrder {

 int get id; InventoryDocumentStatus get status; int? get supplierId; String? get supplierName; DateTime? get estimatedReceiptDate; String? get comment; int get creatorId; int get updaterId; DateTime get createdAt; DateTime get modifiedAt; int get lineCount; Decimal get subtotal; Decimal get tax; Decimal get total; List<PurchaseOrderLine> get lines;/// Only the count of `skipped` is used; the reasons are uncoded
/// (mictlanix/mbe-api#353).
 int get skippedCount;/// Filled only by the confirm response until mictlanix/mbe-api#355.
 List<OrderReceipt> get receipts;
/// Create a copy of PurchaseOrder
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PurchaseOrderCopyWith<PurchaseOrder> get copyWith => _$PurchaseOrderCopyWithImpl<PurchaseOrder>(this as PurchaseOrder, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PurchaseOrder;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PurchaseOrder&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.supplierId, _this.supplierId) || other.supplierId == _this.supplierId)&&(identical(other.supplierName, _this.supplierName) || other.supplierName == _this.supplierName)&&(identical(other.estimatedReceiptDate, _this.estimatedReceiptDate) || other.estimatedReceiptDate == _this.estimatedReceiptDate)&&(identical(other.comment, _this.comment) || other.comment == _this.comment)&&(identical(other.creatorId, _this.creatorId) || other.creatorId == _this.creatorId)&&(identical(other.updaterId, _this.updaterId) || other.updaterId == _this.updaterId)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.modifiedAt, _this.modifiedAt) || other.modifiedAt == _this.modifiedAt)&&(identical(other.lineCount, _this.lineCount) || other.lineCount == _this.lineCount)&&(identical(other.subtotal, _this.subtotal) || other.subtotal == _this.subtotal)&&(identical(other.tax, _this.tax) || other.tax == _this.tax)&&(identical(other.total, _this.total) || other.total == _this.total)&&const DeepCollectionEquality().equals(other.lines, _this.lines)&&(identical(other.skippedCount, _this.skippedCount) || other.skippedCount == _this.skippedCount)&&const DeepCollectionEquality().equals(other.receipts, _this.receipts));
}


@override
int get hashCode {
  final _this = this as PurchaseOrder;
  return Object.hash(runtimeType,_this.id,_this.status,_this.supplierId,_this.supplierName,_this.estimatedReceiptDate,_this.comment,_this.creatorId,_this.updaterId,_this.createdAt,_this.modifiedAt,_this.lineCount,_this.subtotal,_this.tax,_this.total,const DeepCollectionEquality().hash(_this.lines),_this.skippedCount,const DeepCollectionEquality().hash(_this.receipts));
}

@override
String toString() {
  final _this = this as PurchaseOrder;
  return 'PurchaseOrder(id: ${_this.id}, status: ${_this.status}, supplierId: ${_this.supplierId}, supplierName: ${_this.supplierName}, estimatedReceiptDate: ${_this.estimatedReceiptDate}, comment: ${_this.comment}, creatorId: ${_this.creatorId}, updaterId: ${_this.updaterId}, createdAt: ${_this.createdAt}, modifiedAt: ${_this.modifiedAt}, lineCount: ${_this.lineCount}, subtotal: ${_this.subtotal}, tax: ${_this.tax}, total: ${_this.total}, lines: ${_this.lines}, skippedCount: ${_this.skippedCount}, receipts: ${_this.receipts})';
}


}

/// @nodoc
abstract mixin class $PurchaseOrderCopyWith<$Res>  {
  factory $PurchaseOrderCopyWith(PurchaseOrder value, $Res Function(PurchaseOrder) _then) = _$PurchaseOrderCopyWithImpl;
@useResult
$Res call({
 int id, InventoryDocumentStatus status, int? supplierId, String? supplierName, DateTime? estimatedReceiptDate, String? comment, int creatorId, int updaterId, DateTime createdAt, DateTime modifiedAt, int lineCount, Decimal subtotal, Decimal tax, Decimal total, List<PurchaseOrderLine> lines, int skippedCount, List<OrderReceipt> receipts
});




}
/// @nodoc
class _$PurchaseOrderCopyWithImpl<$Res>
    implements $PurchaseOrderCopyWith<$Res> {
  _$PurchaseOrderCopyWithImpl(this._self, this._then);

  final PurchaseOrder _self;
  final $Res Function(PurchaseOrder) _then;

/// Create a copy of PurchaseOrder
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? status = null,Object? supplierId = freezed,Object? supplierName = freezed,Object? estimatedReceiptDate = freezed,Object? comment = freezed,Object? creatorId = null,Object? updaterId = null,Object? createdAt = null,Object? modifiedAt = null,Object? lineCount = null,Object? subtotal = null,Object? tax = null,Object? total = null,Object? lines = null,Object? skippedCount = null,Object? receipts = null,}) {
  return _then(PurchaseOrder(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InventoryDocumentStatus,supplierId: freezed == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as int?,supplierName: freezed == supplierName ? _self.supplierName : supplierName // ignore: cast_nullable_to_non_nullable
as String?,estimatedReceiptDate: freezed == estimatedReceiptDate ? _self.estimatedReceiptDate : estimatedReceiptDate // ignore: cast_nullable_to_non_nullable
as DateTime?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as int,updaterId: null == updaterId ? _self.updaterId : updaterId // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,modifiedAt: null == modifiedAt ? _self.modifiedAt : modifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime,lineCount: null == lineCount ? _self.lineCount : lineCount // ignore: cast_nullable_to_non_nullable
as int,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as Decimal,tax: null == tax ? _self.tax : tax // ignore: cast_nullable_to_non_nullable
as Decimal,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as Decimal,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<PurchaseOrderLine>,skippedCount: null == skippedCount ? _self.skippedCount : skippedCount // ignore: cast_nullable_to_non_nullable
as int,receipts: null == receipts ? _self.receipts : receipts // ignore: cast_nullable_to_non_nullable
as List<OrderReceipt>,
  ));
}

}


/// Adds pattern-matching-related methods to [PurchaseOrder].
extension PurchaseOrderPatterns on PurchaseOrder {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PurchaseOrder value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PurchaseOrder() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PurchaseOrder value)  $default,){
final _that = this;
switch (_that) {
case _PurchaseOrder():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PurchaseOrder value)?  $default,){
final _that = this;
switch (_that) {
case _PurchaseOrder() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  InventoryDocumentStatus status,  int? supplierId,  String? supplierName,  DateTime? estimatedReceiptDate,  String? comment,  int creatorId,  int updaterId,  DateTime createdAt,  DateTime modifiedAt,  int lineCount,  Decimal subtotal,  Decimal tax,  Decimal total,  List<PurchaseOrderLine> lines,  int skippedCount,  List<OrderReceipt> receipts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PurchaseOrder() when $default != null:
return $default(_that.id,_that.status,_that.supplierId,_that.supplierName,_that.estimatedReceiptDate,_that.comment,_that.creatorId,_that.updaterId,_that.createdAt,_that.modifiedAt,_that.lineCount,_that.subtotal,_that.tax,_that.total,_that.lines,_that.skippedCount,_that.receipts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  InventoryDocumentStatus status,  int? supplierId,  String? supplierName,  DateTime? estimatedReceiptDate,  String? comment,  int creatorId,  int updaterId,  DateTime createdAt,  DateTime modifiedAt,  int lineCount,  Decimal subtotal,  Decimal tax,  Decimal total,  List<PurchaseOrderLine> lines,  int skippedCount,  List<OrderReceipt> receipts)  $default,) {final _that = this;
switch (_that) {
case _PurchaseOrder():
return $default(_that.id,_that.status,_that.supplierId,_that.supplierName,_that.estimatedReceiptDate,_that.comment,_that.creatorId,_that.updaterId,_that.createdAt,_that.modifiedAt,_that.lineCount,_that.subtotal,_that.tax,_that.total,_that.lines,_that.skippedCount,_that.receipts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  InventoryDocumentStatus status,  int? supplierId,  String? supplierName,  DateTime? estimatedReceiptDate,  String? comment,  int creatorId,  int updaterId,  DateTime createdAt,  DateTime modifiedAt,  int lineCount,  Decimal subtotal,  Decimal tax,  Decimal total,  List<PurchaseOrderLine> lines,  int skippedCount,  List<OrderReceipt> receipts)?  $default,) {final _that = this;
switch (_that) {
case _PurchaseOrder() when $default != null:
return $default(_that.id,_that.status,_that.supplierId,_that.supplierName,_that.estimatedReceiptDate,_that.comment,_that.creatorId,_that.updaterId,_that.createdAt,_that.modifiedAt,_that.lineCount,_that.subtotal,_that.tax,_that.total,_that.lines,_that.skippedCount,_that.receipts);case _:
  return null;

}
}

}

/// @nodoc


class _PurchaseOrder implements PurchaseOrder {
  const _PurchaseOrder({required this.id, required this.status, this.supplierId, this.supplierName, this.estimatedReceiptDate, this.comment, required this.creatorId, required this.updaterId, required this.createdAt, required this.modifiedAt, required this.lineCount, required this.subtotal, required this.tax, required this.total, required  List<PurchaseOrderLine> lines, this.skippedCount = 0,  List<OrderReceipt> receipts = const []}): _lines = lines,_receipts = receipts;
  

@override final  int id;
@override final  InventoryDocumentStatus status;
@override final  int? supplierId;
@override final  String? supplierName;
@override final  DateTime? estimatedReceiptDate;
@override final  String? comment;
@override final  int creatorId;
@override final  int updaterId;
@override final  DateTime createdAt;
@override final  DateTime modifiedAt;
@override final  int lineCount;
@override final  Decimal subtotal;
@override final  Decimal tax;
@override final  Decimal total;
 final  List<PurchaseOrderLine> _lines;
@override List<PurchaseOrderLine> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}

/// Only the count of `skipped` is used; the reasons are uncoded
/// (mictlanix/mbe-api#353).
@override@JsonKey() final  int skippedCount;
/// Filled only by the confirm response until mictlanix/mbe-api#355.
 final  List<OrderReceipt> _receipts;
/// Filled only by the confirm response until mictlanix/mbe-api#355.
@override@JsonKey() List<OrderReceipt> get receipts {
  if (_receipts is EqualUnmodifiableListView) return _receipts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_receipts);
}


/// Create a copy of PurchaseOrder
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PurchaseOrderCopyWith<_PurchaseOrder> get copyWith => __$PurchaseOrderCopyWithImpl<_PurchaseOrder>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PurchaseOrder&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.supplierId, supplierId) || other.supplierId == supplierId)&&(identical(other.supplierName, supplierName) || other.supplierName == supplierName)&&(identical(other.estimatedReceiptDate, estimatedReceiptDate) || other.estimatedReceiptDate == estimatedReceiptDate)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.updaterId, updaterId) || other.updaterId == updaterId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.modifiedAt, modifiedAt) || other.modifiedAt == modifiedAt)&&(identical(other.lineCount, lineCount) || other.lineCount == lineCount)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.tax, tax) || other.tax == tax)&&(identical(other.total, total) || other.total == total)&&const DeepCollectionEquality().equals(other.lines, _lines)&&(identical(other.skippedCount, skippedCount) || other.skippedCount == skippedCount)&&const DeepCollectionEquality().equals(other.receipts, _receipts));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,status,supplierId,supplierName,estimatedReceiptDate,comment,creatorId,updaterId,createdAt,modifiedAt,lineCount,subtotal,tax,total,const DeepCollectionEquality().hash(_lines),skippedCount,const DeepCollectionEquality().hash(_receipts));
}

@override
String toString() {
    return 'PurchaseOrder(id: $id, status: $status, supplierId: $supplierId, supplierName: $supplierName, estimatedReceiptDate: $estimatedReceiptDate, comment: $comment, creatorId: $creatorId, updaterId: $updaterId, createdAt: $createdAt, modifiedAt: $modifiedAt, lineCount: $lineCount, subtotal: $subtotal, tax: $tax, total: $total, lines: $lines, skippedCount: $skippedCount, receipts: $receipts)';
}


}

/// @nodoc
abstract mixin class _$PurchaseOrderCopyWith<$Res> implements $PurchaseOrderCopyWith<$Res> {
  factory _$PurchaseOrderCopyWith(_PurchaseOrder value, $Res Function(_PurchaseOrder) _then) = __$PurchaseOrderCopyWithImpl;
@override @useResult
$Res call({
 int id, InventoryDocumentStatus status, int? supplierId, String? supplierName, DateTime? estimatedReceiptDate, String? comment, int creatorId, int updaterId, DateTime createdAt, DateTime modifiedAt, int lineCount, Decimal subtotal, Decimal tax, Decimal total, List<PurchaseOrderLine> lines, int skippedCount, List<OrderReceipt> receipts
});




}
/// @nodoc
class __$PurchaseOrderCopyWithImpl<$Res>
    implements _$PurchaseOrderCopyWith<$Res> {
  __$PurchaseOrderCopyWithImpl(this._self, this._then);

  final _PurchaseOrder _self;
  final $Res Function(_PurchaseOrder) _then;

/// Create a copy of PurchaseOrder
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? status = null,Object? supplierId = freezed,Object? supplierName = freezed,Object? estimatedReceiptDate = freezed,Object? comment = freezed,Object? creatorId = null,Object? updaterId = null,Object? createdAt = null,Object? modifiedAt = null,Object? lineCount = null,Object? subtotal = null,Object? tax = null,Object? total = null,Object? lines = null,Object? skippedCount = null,Object? receipts = null,}) {
  return _then(_PurchaseOrder(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InventoryDocumentStatus,supplierId: freezed == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as int?,supplierName: freezed == supplierName ? _self.supplierName : supplierName // ignore: cast_nullable_to_non_nullable
as String?,estimatedReceiptDate: freezed == estimatedReceiptDate ? _self.estimatedReceiptDate : estimatedReceiptDate // ignore: cast_nullable_to_non_nullable
as DateTime?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as int,updaterId: null == updaterId ? _self.updaterId : updaterId // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,modifiedAt: null == modifiedAt ? _self.modifiedAt : modifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime,lineCount: null == lineCount ? _self.lineCount : lineCount // ignore: cast_nullable_to_non_nullable
as int,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as Decimal,tax: null == tax ? _self.tax : tax // ignore: cast_nullable_to_non_nullable
as Decimal,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as Decimal,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<PurchaseOrderLine>,skippedCount: null == skippedCount ? _self.skippedCount : skippedCount // ignore: cast_nullable_to_non_nullable
as int,receipts: null == receipts ? _self._receipts : receipts // ignore: cast_nullable_to_non_nullable
as List<OrderReceipt>,
  ));
}


}

/// @nodoc
mixin _$ToPurchaseLine {

 int get requestLineId; int get requestId; int? get serial; int get productId; String get productCode; String? get productName; Decimal get quantity; int get warehouseId;/// 0 means "sin costo".
 Decimal get cost;
/// Create a copy of ToPurchaseLine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ToPurchaseLineCopyWith<ToPurchaseLine> get copyWith => _$ToPurchaseLineCopyWithImpl<ToPurchaseLine>(this as ToPurchaseLine, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ToPurchaseLine;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ToPurchaseLine&&(identical(other.requestLineId, _this.requestLineId) || other.requestLineId == _this.requestLineId)&&(identical(other.requestId, _this.requestId) || other.requestId == _this.requestId)&&(identical(other.serial, _this.serial) || other.serial == _this.serial)&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.productCode, _this.productCode) || other.productCode == _this.productCode)&&(identical(other.productName, _this.productName) || other.productName == _this.productName)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity)&&(identical(other.warehouseId, _this.warehouseId) || other.warehouseId == _this.warehouseId)&&(identical(other.cost, _this.cost) || other.cost == _this.cost));
}


@override
int get hashCode {
  final _this = this as ToPurchaseLine;
  return Object.hash(runtimeType,_this.requestLineId,_this.requestId,_this.serial,_this.productId,_this.productCode,_this.productName,_this.quantity,_this.warehouseId,_this.cost);
}

@override
String toString() {
  final _this = this as ToPurchaseLine;
  return 'ToPurchaseLine(requestLineId: ${_this.requestLineId}, requestId: ${_this.requestId}, serial: ${_this.serial}, productId: ${_this.productId}, productCode: ${_this.productCode}, productName: ${_this.productName}, quantity: ${_this.quantity}, warehouseId: ${_this.warehouseId}, cost: ${_this.cost})';
}


}

/// @nodoc
abstract mixin class $ToPurchaseLineCopyWith<$Res>  {
  factory $ToPurchaseLineCopyWith(ToPurchaseLine value, $Res Function(ToPurchaseLine) _then) = _$ToPurchaseLineCopyWithImpl;
@useResult
$Res call({
 int requestLineId, int requestId, int? serial, int productId, String productCode, String? productName, Decimal quantity, int warehouseId, Decimal cost
});




}
/// @nodoc
class _$ToPurchaseLineCopyWithImpl<$Res>
    implements $ToPurchaseLineCopyWith<$Res> {
  _$ToPurchaseLineCopyWithImpl(this._self, this._then);

  final ToPurchaseLine _self;
  final $Res Function(ToPurchaseLine) _then;

/// Create a copy of ToPurchaseLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? requestLineId = null,Object? requestId = null,Object? serial = freezed,Object? productId = null,Object? productCode = null,Object? productName = freezed,Object? quantity = null,Object? warehouseId = null,Object? cost = null,}) {
  return _then(ToPurchaseLine(
requestLineId: null == requestLineId ? _self.requestLineId : requestLineId // ignore: cast_nullable_to_non_nullable
as int,requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as int,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as int?,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,productCode: null == productCode ? _self.productCode : productCode // ignore: cast_nullable_to_non_nullable
as String,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Decimal,warehouseId: null == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int,cost: null == cost ? _self.cost : cost // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}

}


/// Adds pattern-matching-related methods to [ToPurchaseLine].
extension ToPurchaseLinePatterns on ToPurchaseLine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ToPurchaseLine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ToPurchaseLine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ToPurchaseLine value)  $default,){
final _that = this;
switch (_that) {
case _ToPurchaseLine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ToPurchaseLine value)?  $default,){
final _that = this;
switch (_that) {
case _ToPurchaseLine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int requestLineId,  int requestId,  int? serial,  int productId,  String productCode,  String? productName,  Decimal quantity,  int warehouseId,  Decimal cost)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ToPurchaseLine() when $default != null:
return $default(_that.requestLineId,_that.requestId,_that.serial,_that.productId,_that.productCode,_that.productName,_that.quantity,_that.warehouseId,_that.cost);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int requestLineId,  int requestId,  int? serial,  int productId,  String productCode,  String? productName,  Decimal quantity,  int warehouseId,  Decimal cost)  $default,) {final _that = this;
switch (_that) {
case _ToPurchaseLine():
return $default(_that.requestLineId,_that.requestId,_that.serial,_that.productId,_that.productCode,_that.productName,_that.quantity,_that.warehouseId,_that.cost);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int requestLineId,  int requestId,  int? serial,  int productId,  String productCode,  String? productName,  Decimal quantity,  int warehouseId,  Decimal cost)?  $default,) {final _that = this;
switch (_that) {
case _ToPurchaseLine() when $default != null:
return $default(_that.requestLineId,_that.requestId,_that.serial,_that.productId,_that.productCode,_that.productName,_that.quantity,_that.warehouseId,_that.cost);case _:
  return null;

}
}

}

/// @nodoc


class _ToPurchaseLine implements ToPurchaseLine {
  const _ToPurchaseLine({required this.requestLineId, required this.requestId, this.serial, required this.productId, required this.productCode, this.productName, required this.quantity, required this.warehouseId, required this.cost});
  

@override final  int requestLineId;
@override final  int requestId;
@override final  int? serial;
@override final  int productId;
@override final  String productCode;
@override final  String? productName;
@override final  Decimal quantity;
@override final  int warehouseId;
/// 0 means "sin costo".
@override final  Decimal cost;

/// Create a copy of ToPurchaseLine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ToPurchaseLineCopyWith<_ToPurchaseLine> get copyWith => __$ToPurchaseLineCopyWithImpl<_ToPurchaseLine>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ToPurchaseLine&&(identical(other.requestLineId, requestLineId) || other.requestLineId == requestLineId)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.serial, serial) || other.serial == serial)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productCode, productCode) || other.productCode == productCode)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.cost, cost) || other.cost == cost));
}


@override
int get hashCode {
    return Object.hash(runtimeType,requestLineId,requestId,serial,productId,productCode,productName,quantity,warehouseId,cost);
}

@override
String toString() {
    return 'ToPurchaseLine(requestLineId: $requestLineId, requestId: $requestId, serial: $serial, productId: $productId, productCode: $productCode, productName: $productName, quantity: $quantity, warehouseId: $warehouseId, cost: $cost)';
}


}

/// @nodoc
abstract mixin class _$ToPurchaseLineCopyWith<$Res> implements $ToPurchaseLineCopyWith<$Res> {
  factory _$ToPurchaseLineCopyWith(_ToPurchaseLine value, $Res Function(_ToPurchaseLine) _then) = __$ToPurchaseLineCopyWithImpl;
@override @useResult
$Res call({
 int requestLineId, int requestId, int? serial, int productId, String productCode, String? productName, Decimal quantity, int warehouseId, Decimal cost
});




}
/// @nodoc
class __$ToPurchaseLineCopyWithImpl<$Res>
    implements _$ToPurchaseLineCopyWith<$Res> {
  __$ToPurchaseLineCopyWithImpl(this._self, this._then);

  final _ToPurchaseLine _self;
  final $Res Function(_ToPurchaseLine) _then;

/// Create a copy of ToPurchaseLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? requestLineId = null,Object? requestId = null,Object? serial = freezed,Object? productId = null,Object? productCode = null,Object? productName = freezed,Object? quantity = null,Object? warehouseId = null,Object? cost = null,}) {
  return _then(_ToPurchaseLine(
requestLineId: null == requestLineId ? _self.requestLineId : requestLineId // ignore: cast_nullable_to_non_nullable
as int,requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as int,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as int?,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,productCode: null == productCode ? _self.productCode : productCode // ignore: cast_nullable_to_non_nullable
as String,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Decimal,warehouseId: null == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int,cost: null == cost ? _self.cost : cost // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}


}

/// @nodoc
mixin _$ToPurchaseGroup {

/// Null is "Sin proveedor": no order can be created from it.
 int? get supplierId; String? get supplierName; int get facilityId; int get lineCount; Decimal get estimatedTotal; List<ToPurchaseLine> get lines;
/// Create a copy of ToPurchaseGroup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ToPurchaseGroupCopyWith<ToPurchaseGroup> get copyWith => _$ToPurchaseGroupCopyWithImpl<ToPurchaseGroup>(this as ToPurchaseGroup, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ToPurchaseGroup;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ToPurchaseGroup&&(identical(other.supplierId, _this.supplierId) || other.supplierId == _this.supplierId)&&(identical(other.supplierName, _this.supplierName) || other.supplierName == _this.supplierName)&&(identical(other.facilityId, _this.facilityId) || other.facilityId == _this.facilityId)&&(identical(other.lineCount, _this.lineCount) || other.lineCount == _this.lineCount)&&(identical(other.estimatedTotal, _this.estimatedTotal) || other.estimatedTotal == _this.estimatedTotal)&&const DeepCollectionEquality().equals(other.lines, _this.lines));
}


@override
int get hashCode {
  final _this = this as ToPurchaseGroup;
  return Object.hash(runtimeType,_this.supplierId,_this.supplierName,_this.facilityId,_this.lineCount,_this.estimatedTotal,const DeepCollectionEquality().hash(_this.lines));
}

@override
String toString() {
  final _this = this as ToPurchaseGroup;
  return 'ToPurchaseGroup(supplierId: ${_this.supplierId}, supplierName: ${_this.supplierName}, facilityId: ${_this.facilityId}, lineCount: ${_this.lineCount}, estimatedTotal: ${_this.estimatedTotal}, lines: ${_this.lines})';
}


}

/// @nodoc
abstract mixin class $ToPurchaseGroupCopyWith<$Res>  {
  factory $ToPurchaseGroupCopyWith(ToPurchaseGroup value, $Res Function(ToPurchaseGroup) _then) = _$ToPurchaseGroupCopyWithImpl;
@useResult
$Res call({
 int? supplierId, String? supplierName, int facilityId, int lineCount, Decimal estimatedTotal, List<ToPurchaseLine> lines
});




}
/// @nodoc
class _$ToPurchaseGroupCopyWithImpl<$Res>
    implements $ToPurchaseGroupCopyWith<$Res> {
  _$ToPurchaseGroupCopyWithImpl(this._self, this._then);

  final ToPurchaseGroup _self;
  final $Res Function(ToPurchaseGroup) _then;

/// Create a copy of ToPurchaseGroup
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? supplierId = freezed,Object? supplierName = freezed,Object? facilityId = null,Object? lineCount = null,Object? estimatedTotal = null,Object? lines = null,}) {
  return _then(ToPurchaseGroup(
supplierId: freezed == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as int?,supplierName: freezed == supplierName ? _self.supplierName : supplierName // ignore: cast_nullable_to_non_nullable
as String?,facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int,lineCount: null == lineCount ? _self.lineCount : lineCount // ignore: cast_nullable_to_non_nullable
as int,estimatedTotal: null == estimatedTotal ? _self.estimatedTotal : estimatedTotal // ignore: cast_nullable_to_non_nullable
as Decimal,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<ToPurchaseLine>,
  ));
}

}


/// Adds pattern-matching-related methods to [ToPurchaseGroup].
extension ToPurchaseGroupPatterns on ToPurchaseGroup {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ToPurchaseGroup value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ToPurchaseGroup() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ToPurchaseGroup value)  $default,){
final _that = this;
switch (_that) {
case _ToPurchaseGroup():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ToPurchaseGroup value)?  $default,){
final _that = this;
switch (_that) {
case _ToPurchaseGroup() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? supplierId,  String? supplierName,  int facilityId,  int lineCount,  Decimal estimatedTotal,  List<ToPurchaseLine> lines)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ToPurchaseGroup() when $default != null:
return $default(_that.supplierId,_that.supplierName,_that.facilityId,_that.lineCount,_that.estimatedTotal,_that.lines);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? supplierId,  String? supplierName,  int facilityId,  int lineCount,  Decimal estimatedTotal,  List<ToPurchaseLine> lines)  $default,) {final _that = this;
switch (_that) {
case _ToPurchaseGroup():
return $default(_that.supplierId,_that.supplierName,_that.facilityId,_that.lineCount,_that.estimatedTotal,_that.lines);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? supplierId,  String? supplierName,  int facilityId,  int lineCount,  Decimal estimatedTotal,  List<ToPurchaseLine> lines)?  $default,) {final _that = this;
switch (_that) {
case _ToPurchaseGroup() when $default != null:
return $default(_that.supplierId,_that.supplierName,_that.facilityId,_that.lineCount,_that.estimatedTotal,_that.lines);case _:
  return null;

}
}

}

/// @nodoc


class _ToPurchaseGroup implements ToPurchaseGroup {
  const _ToPurchaseGroup({this.supplierId, this.supplierName, required this.facilityId, required this.lineCount, required this.estimatedTotal, required  List<ToPurchaseLine> lines}): _lines = lines;
  

/// Null is "Sin proveedor": no order can be created from it.
@override final  int? supplierId;
@override final  String? supplierName;
@override final  int facilityId;
@override final  int lineCount;
@override final  Decimal estimatedTotal;
 final  List<ToPurchaseLine> _lines;
@override List<ToPurchaseLine> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}


/// Create a copy of ToPurchaseGroup
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ToPurchaseGroupCopyWith<_ToPurchaseGroup> get copyWith => __$ToPurchaseGroupCopyWithImpl<_ToPurchaseGroup>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ToPurchaseGroup&&(identical(other.supplierId, supplierId) || other.supplierId == supplierId)&&(identical(other.supplierName, supplierName) || other.supplierName == supplierName)&&(identical(other.facilityId, facilityId) || other.facilityId == facilityId)&&(identical(other.lineCount, lineCount) || other.lineCount == lineCount)&&(identical(other.estimatedTotal, estimatedTotal) || other.estimatedTotal == estimatedTotal)&&const DeepCollectionEquality().equals(other.lines, _lines));
}


@override
int get hashCode {
    return Object.hash(runtimeType,supplierId,supplierName,facilityId,lineCount,estimatedTotal,const DeepCollectionEquality().hash(_lines));
}

@override
String toString() {
    return 'ToPurchaseGroup(supplierId: $supplierId, supplierName: $supplierName, facilityId: $facilityId, lineCount: $lineCount, estimatedTotal: $estimatedTotal, lines: $lines)';
}


}

/// @nodoc
abstract mixin class _$ToPurchaseGroupCopyWith<$Res> implements $ToPurchaseGroupCopyWith<$Res> {
  factory _$ToPurchaseGroupCopyWith(_ToPurchaseGroup value, $Res Function(_ToPurchaseGroup) _then) = __$ToPurchaseGroupCopyWithImpl;
@override @useResult
$Res call({
 int? supplierId, String? supplierName, int facilityId, int lineCount, Decimal estimatedTotal, List<ToPurchaseLine> lines
});




}
/// @nodoc
class __$ToPurchaseGroupCopyWithImpl<$Res>
    implements _$ToPurchaseGroupCopyWith<$Res> {
  __$ToPurchaseGroupCopyWithImpl(this._self, this._then);

  final _ToPurchaseGroup _self;
  final $Res Function(_ToPurchaseGroup) _then;

/// Create a copy of ToPurchaseGroup
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? supplierId = freezed,Object? supplierName = freezed,Object? facilityId = null,Object? lineCount = null,Object? estimatedTotal = null,Object? lines = null,}) {
  return _then(_ToPurchaseGroup(
supplierId: freezed == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as int?,supplierName: freezed == supplierName ? _self.supplierName : supplierName // ignore: cast_nullable_to_non_nullable
as String?,facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int,lineCount: null == lineCount ? _self.lineCount : lineCount // ignore: cast_nullable_to_non_nullable
as int,estimatedTotal: null == estimatedTotal ? _self.estimatedTotal : estimatedTotal // ignore: cast_nullable_to_non_nullable
as Decimal,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<ToPurchaseLine>,
  ));
}


}

/// @nodoc
mixin _$OrderEmailReceipt {

 List<String> get recipients; DateTime get sentAt;
/// Create a copy of OrderEmailReceipt
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderEmailReceiptCopyWith<OrderEmailReceipt> get copyWith => _$OrderEmailReceiptCopyWithImpl<OrderEmailReceipt>(this as OrderEmailReceipt, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as OrderEmailReceipt;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderEmailReceipt&&const DeepCollectionEquality().equals(other.recipients, _this.recipients)&&(identical(other.sentAt, _this.sentAt) || other.sentAt == _this.sentAt));
}


@override
int get hashCode {
  final _this = this as OrderEmailReceipt;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.recipients),_this.sentAt);
}

@override
String toString() {
  final _this = this as OrderEmailReceipt;
  return 'OrderEmailReceipt(recipients: ${_this.recipients}, sentAt: ${_this.sentAt})';
}


}

/// @nodoc
abstract mixin class $OrderEmailReceiptCopyWith<$Res>  {
  factory $OrderEmailReceiptCopyWith(OrderEmailReceipt value, $Res Function(OrderEmailReceipt) _then) = _$OrderEmailReceiptCopyWithImpl;
@useResult
$Res call({
 List<String> recipients, DateTime sentAt
});




}
/// @nodoc
class _$OrderEmailReceiptCopyWithImpl<$Res>
    implements $OrderEmailReceiptCopyWith<$Res> {
  _$OrderEmailReceiptCopyWithImpl(this._self, this._then);

  final OrderEmailReceipt _self;
  final $Res Function(OrderEmailReceipt) _then;

/// Create a copy of OrderEmailReceipt
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? recipients = null,Object? sentAt = null,}) {
  return _then(OrderEmailReceipt(
recipients: null == recipients ? _self.recipients : recipients // ignore: cast_nullable_to_non_nullable
as List<String>,sentAt: null == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderEmailReceipt].
extension OrderEmailReceiptPatterns on OrderEmailReceipt {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderEmailReceipt value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderEmailReceipt() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderEmailReceipt value)  $default,){
final _that = this;
switch (_that) {
case _OrderEmailReceipt():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderEmailReceipt value)?  $default,){
final _that = this;
switch (_that) {
case _OrderEmailReceipt() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> recipients,  DateTime sentAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderEmailReceipt() when $default != null:
return $default(_that.recipients,_that.sentAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> recipients,  DateTime sentAt)  $default,) {final _that = this;
switch (_that) {
case _OrderEmailReceipt():
return $default(_that.recipients,_that.sentAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> recipients,  DateTime sentAt)?  $default,) {final _that = this;
switch (_that) {
case _OrderEmailReceipt() when $default != null:
return $default(_that.recipients,_that.sentAt);case _:
  return null;

}
}

}

/// @nodoc


class _OrderEmailReceipt implements OrderEmailReceipt {
  const _OrderEmailReceipt({required  List<String> recipients, required this.sentAt}): _recipients = recipients;
  

 final  List<String> _recipients;
@override List<String> get recipients {
  if (_recipients is EqualUnmodifiableListView) return _recipients;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recipients);
}

@override final  DateTime sentAt;

/// Create a copy of OrderEmailReceipt
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderEmailReceiptCopyWith<_OrderEmailReceipt> get copyWith => __$OrderEmailReceiptCopyWithImpl<_OrderEmailReceipt>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderEmailReceipt&&const DeepCollectionEquality().equals(other.recipients, _recipients)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_recipients),sentAt);
}

@override
String toString() {
    return 'OrderEmailReceipt(recipients: $recipients, sentAt: $sentAt)';
}


}

/// @nodoc
abstract mixin class _$OrderEmailReceiptCopyWith<$Res> implements $OrderEmailReceiptCopyWith<$Res> {
  factory _$OrderEmailReceiptCopyWith(_OrderEmailReceipt value, $Res Function(_OrderEmailReceipt) _then) = __$OrderEmailReceiptCopyWithImpl;
@override @useResult
$Res call({
 List<String> recipients, DateTime sentAt
});




}
/// @nodoc
class __$OrderEmailReceiptCopyWithImpl<$Res>
    implements _$OrderEmailReceiptCopyWith<$Res> {
  __$OrderEmailReceiptCopyWithImpl(this._self, this._then);

  final _OrderEmailReceipt _self;
  final $Res Function(_OrderEmailReceipt) _then;

/// Create a copy of OrderEmailReceipt
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? recipients = null,Object? sentAt = null,}) {
  return _then(_OrderEmailReceipt(
recipients: null == recipients ? _self._recipients : recipients // ignore: cast_nullable_to_non_nullable
as List<String>,sentAt: null == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
