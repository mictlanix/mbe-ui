// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inventory_receipt.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$InventoryReceiptSummary {

 int get id; int get facilityId; int get warehouseId; int? get purchaseOrderId;/// Null until the receipt is confirmed. The "Borrador #{id}" text for a
/// draft is built by the presentation layer from l10n.
 int? get serial; InventoryDocumentStatus get status; int get creatorId; DateTime get createdAt;
/// Create a copy of InventoryReceiptSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InventoryReceiptSummaryCopyWith<InventoryReceiptSummary> get copyWith => _$InventoryReceiptSummaryCopyWithImpl<InventoryReceiptSummary>(this as InventoryReceiptSummary, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as InventoryReceiptSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InventoryReceiptSummary&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.facilityId, _this.facilityId) || other.facilityId == _this.facilityId)&&(identical(other.warehouseId, _this.warehouseId) || other.warehouseId == _this.warehouseId)&&(identical(other.purchaseOrderId, _this.purchaseOrderId) || other.purchaseOrderId == _this.purchaseOrderId)&&(identical(other.serial, _this.serial) || other.serial == _this.serial)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.creatorId, _this.creatorId) || other.creatorId == _this.creatorId)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}


@override
int get hashCode {
  final _this = this as InventoryReceiptSummary;
  return Object.hash(runtimeType,_this.id,_this.facilityId,_this.warehouseId,_this.purchaseOrderId,_this.serial,_this.status,_this.creatorId,_this.createdAt);
}

@override
String toString() {
  final _this = this as InventoryReceiptSummary;
  return 'InventoryReceiptSummary(id: ${_this.id}, facilityId: ${_this.facilityId}, warehouseId: ${_this.warehouseId}, purchaseOrderId: ${_this.purchaseOrderId}, serial: ${_this.serial}, status: ${_this.status}, creatorId: ${_this.creatorId}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $InventoryReceiptSummaryCopyWith<$Res>  {
  factory $InventoryReceiptSummaryCopyWith(InventoryReceiptSummary value, $Res Function(InventoryReceiptSummary) _then) = _$InventoryReceiptSummaryCopyWithImpl;
@useResult
$Res call({
 int id, int facilityId, int warehouseId, int? purchaseOrderId, int? serial, InventoryDocumentStatus status, int creatorId, DateTime createdAt
});




}
/// @nodoc
class _$InventoryReceiptSummaryCopyWithImpl<$Res>
    implements $InventoryReceiptSummaryCopyWith<$Res> {
  _$InventoryReceiptSummaryCopyWithImpl(this._self, this._then);

  final InventoryReceiptSummary _self;
  final $Res Function(InventoryReceiptSummary) _then;

/// Create a copy of InventoryReceiptSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? facilityId = null,Object? warehouseId = null,Object? purchaseOrderId = freezed,Object? serial = freezed,Object? status = null,Object? creatorId = null,Object? createdAt = null,}) {
  return _then(InventoryReceiptSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int,warehouseId: null == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int,purchaseOrderId: freezed == purchaseOrderId ? _self.purchaseOrderId : purchaseOrderId // ignore: cast_nullable_to_non_nullable
as int?,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InventoryDocumentStatus,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [InventoryReceiptSummary].
extension InventoryReceiptSummaryPatterns on InventoryReceiptSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InventoryReceiptSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InventoryReceiptSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InventoryReceiptSummary value)  $default,){
final _that = this;
switch (_that) {
case _InventoryReceiptSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InventoryReceiptSummary value)?  $default,){
final _that = this;
switch (_that) {
case _InventoryReceiptSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int facilityId,  int warehouseId,  int? purchaseOrderId,  int? serial,  InventoryDocumentStatus status,  int creatorId,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InventoryReceiptSummary() when $default != null:
return $default(_that.id,_that.facilityId,_that.warehouseId,_that.purchaseOrderId,_that.serial,_that.status,_that.creatorId,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int facilityId,  int warehouseId,  int? purchaseOrderId,  int? serial,  InventoryDocumentStatus status,  int creatorId,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _InventoryReceiptSummary():
return $default(_that.id,_that.facilityId,_that.warehouseId,_that.purchaseOrderId,_that.serial,_that.status,_that.creatorId,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int facilityId,  int warehouseId,  int? purchaseOrderId,  int? serial,  InventoryDocumentStatus status,  int creatorId,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _InventoryReceiptSummary() when $default != null:
return $default(_that.id,_that.facilityId,_that.warehouseId,_that.purchaseOrderId,_that.serial,_that.status,_that.creatorId,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _InventoryReceiptSummary implements InventoryReceiptSummary {
  const _InventoryReceiptSummary({required this.id, required this.facilityId, required this.warehouseId, this.purchaseOrderId, this.serial, required this.status, required this.creatorId, required this.createdAt});
  

@override final  int id;
@override final  int facilityId;
@override final  int warehouseId;
@override final  int? purchaseOrderId;
/// Null until the receipt is confirmed. The "Borrador #{id}" text for a
/// draft is built by the presentation layer from l10n.
@override final  int? serial;
@override final  InventoryDocumentStatus status;
@override final  int creatorId;
@override final  DateTime createdAt;

/// Create a copy of InventoryReceiptSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InventoryReceiptSummaryCopyWith<_InventoryReceiptSummary> get copyWith => __$InventoryReceiptSummaryCopyWithImpl<_InventoryReceiptSummary>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _InventoryReceiptSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.facilityId, facilityId) || other.facilityId == facilityId)&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.purchaseOrderId, purchaseOrderId) || other.purchaseOrderId == purchaseOrderId)&&(identical(other.serial, serial) || other.serial == serial)&&(identical(other.status, status) || other.status == status)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,facilityId,warehouseId,purchaseOrderId,serial,status,creatorId,createdAt);
}

@override
String toString() {
    return 'InventoryReceiptSummary(id: $id, facilityId: $facilityId, warehouseId: $warehouseId, purchaseOrderId: $purchaseOrderId, serial: $serial, status: $status, creatorId: $creatorId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$InventoryReceiptSummaryCopyWith<$Res> implements $InventoryReceiptSummaryCopyWith<$Res> {
  factory _$InventoryReceiptSummaryCopyWith(_InventoryReceiptSummary value, $Res Function(_InventoryReceiptSummary) _then) = __$InventoryReceiptSummaryCopyWithImpl;
@override @useResult
$Res call({
 int id, int facilityId, int warehouseId, int? purchaseOrderId, int? serial, InventoryDocumentStatus status, int creatorId, DateTime createdAt
});




}
/// @nodoc
class __$InventoryReceiptSummaryCopyWithImpl<$Res>
    implements _$InventoryReceiptSummaryCopyWith<$Res> {
  __$InventoryReceiptSummaryCopyWithImpl(this._self, this._then);

  final _InventoryReceiptSummary _self;
  final $Res Function(_InventoryReceiptSummary) _then;

/// Create a copy of InventoryReceiptSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? facilityId = null,Object? warehouseId = null,Object? purchaseOrderId = freezed,Object? serial = freezed,Object? status = null,Object? creatorId = null,Object? createdAt = null,}) {
  return _then(_InventoryReceiptSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int,warehouseId: null == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int,purchaseOrderId: freezed == purchaseOrderId ? _self.purchaseOrderId : purchaseOrderId // ignore: cast_nullable_to_non_nullable
as int?,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InventoryDocumentStatus,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$InventoryReceiptLine {

 int get id; int get productId;/// Snapshots from when the line was added.
 String? get productCode; String? get productName; Decimal get quantity;/// Null for a line added by hand.
 int? get purchaseOrderLineId;/// Shown only on a linked receipt (0 on a hand-added line).
 Decimal get quantityOrdered; Decimal? get quantityReceivedElsewhere;
/// Create a copy of InventoryReceiptLine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InventoryReceiptLineCopyWith<InventoryReceiptLine> get copyWith => _$InventoryReceiptLineCopyWithImpl<InventoryReceiptLine>(this as InventoryReceiptLine, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as InventoryReceiptLine;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InventoryReceiptLine&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.productCode, _this.productCode) || other.productCode == _this.productCode)&&(identical(other.productName, _this.productName) || other.productName == _this.productName)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity)&&(identical(other.purchaseOrderLineId, _this.purchaseOrderLineId) || other.purchaseOrderLineId == _this.purchaseOrderLineId)&&(identical(other.quantityOrdered, _this.quantityOrdered) || other.quantityOrdered == _this.quantityOrdered)&&(identical(other.quantityReceivedElsewhere, _this.quantityReceivedElsewhere) || other.quantityReceivedElsewhere == _this.quantityReceivedElsewhere));
}


@override
int get hashCode {
  final _this = this as InventoryReceiptLine;
  return Object.hash(runtimeType,_this.id,_this.productId,_this.productCode,_this.productName,_this.quantity,_this.purchaseOrderLineId,_this.quantityOrdered,_this.quantityReceivedElsewhere);
}

@override
String toString() {
  final _this = this as InventoryReceiptLine;
  return 'InventoryReceiptLine(id: ${_this.id}, productId: ${_this.productId}, productCode: ${_this.productCode}, productName: ${_this.productName}, quantity: ${_this.quantity}, purchaseOrderLineId: ${_this.purchaseOrderLineId}, quantityOrdered: ${_this.quantityOrdered}, quantityReceivedElsewhere: ${_this.quantityReceivedElsewhere})';
}


}

/// @nodoc
abstract mixin class $InventoryReceiptLineCopyWith<$Res>  {
  factory $InventoryReceiptLineCopyWith(InventoryReceiptLine value, $Res Function(InventoryReceiptLine) _then) = _$InventoryReceiptLineCopyWithImpl;
@useResult
$Res call({
 int id, int productId, String? productCode, String? productName, Decimal quantity, int? purchaseOrderLineId, Decimal quantityOrdered, Decimal? quantityReceivedElsewhere
});




}
/// @nodoc
class _$InventoryReceiptLineCopyWithImpl<$Res>
    implements $InventoryReceiptLineCopyWith<$Res> {
  _$InventoryReceiptLineCopyWithImpl(this._self, this._then);

  final InventoryReceiptLine _self;
  final $Res Function(InventoryReceiptLine) _then;

/// Create a copy of InventoryReceiptLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? productId = null,Object? productCode = freezed,Object? productName = freezed,Object? quantity = null,Object? purchaseOrderLineId = freezed,Object? quantityOrdered = null,Object? quantityReceivedElsewhere = freezed,}) {
  return _then(InventoryReceiptLine(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,productCode: freezed == productCode ? _self.productCode : productCode // ignore: cast_nullable_to_non_nullable
as String?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Decimal,purchaseOrderLineId: freezed == purchaseOrderLineId ? _self.purchaseOrderLineId : purchaseOrderLineId // ignore: cast_nullable_to_non_nullable
as int?,quantityOrdered: null == quantityOrdered ? _self.quantityOrdered : quantityOrdered // ignore: cast_nullable_to_non_nullable
as Decimal,quantityReceivedElsewhere: freezed == quantityReceivedElsewhere ? _self.quantityReceivedElsewhere : quantityReceivedElsewhere // ignore: cast_nullable_to_non_nullable
as Decimal?,
  ));
}

}


/// Adds pattern-matching-related methods to [InventoryReceiptLine].
extension InventoryReceiptLinePatterns on InventoryReceiptLine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InventoryReceiptLine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InventoryReceiptLine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InventoryReceiptLine value)  $default,){
final _that = this;
switch (_that) {
case _InventoryReceiptLine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InventoryReceiptLine value)?  $default,){
final _that = this;
switch (_that) {
case _InventoryReceiptLine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int productId,  String? productCode,  String? productName,  Decimal quantity,  int? purchaseOrderLineId,  Decimal quantityOrdered,  Decimal? quantityReceivedElsewhere)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InventoryReceiptLine() when $default != null:
return $default(_that.id,_that.productId,_that.productCode,_that.productName,_that.quantity,_that.purchaseOrderLineId,_that.quantityOrdered,_that.quantityReceivedElsewhere);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int productId,  String? productCode,  String? productName,  Decimal quantity,  int? purchaseOrderLineId,  Decimal quantityOrdered,  Decimal? quantityReceivedElsewhere)  $default,) {final _that = this;
switch (_that) {
case _InventoryReceiptLine():
return $default(_that.id,_that.productId,_that.productCode,_that.productName,_that.quantity,_that.purchaseOrderLineId,_that.quantityOrdered,_that.quantityReceivedElsewhere);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int productId,  String? productCode,  String? productName,  Decimal quantity,  int? purchaseOrderLineId,  Decimal quantityOrdered,  Decimal? quantityReceivedElsewhere)?  $default,) {final _that = this;
switch (_that) {
case _InventoryReceiptLine() when $default != null:
return $default(_that.id,_that.productId,_that.productCode,_that.productName,_that.quantity,_that.purchaseOrderLineId,_that.quantityOrdered,_that.quantityReceivedElsewhere);case _:
  return null;

}
}

}

/// @nodoc


class _InventoryReceiptLine implements InventoryReceiptLine {
  const _InventoryReceiptLine({required this.id, required this.productId, this.productCode, this.productName, required this.quantity, this.purchaseOrderLineId, required this.quantityOrdered, this.quantityReceivedElsewhere});
  

@override final  int id;
@override final  int productId;
/// Snapshots from when the line was added.
@override final  String? productCode;
@override final  String? productName;
@override final  Decimal quantity;
/// Null for a line added by hand.
@override final  int? purchaseOrderLineId;
/// Shown only on a linked receipt (0 on a hand-added line).
@override final  Decimal quantityOrdered;
@override final  Decimal? quantityReceivedElsewhere;

/// Create a copy of InventoryReceiptLine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InventoryReceiptLineCopyWith<_InventoryReceiptLine> get copyWith => __$InventoryReceiptLineCopyWithImpl<_InventoryReceiptLine>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _InventoryReceiptLine&&(identical(other.id, id) || other.id == id)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productCode, productCode) || other.productCode == productCode)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.purchaseOrderLineId, purchaseOrderLineId) || other.purchaseOrderLineId == purchaseOrderLineId)&&(identical(other.quantityOrdered, quantityOrdered) || other.quantityOrdered == quantityOrdered)&&(identical(other.quantityReceivedElsewhere, quantityReceivedElsewhere) || other.quantityReceivedElsewhere == quantityReceivedElsewhere));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,productId,productCode,productName,quantity,purchaseOrderLineId,quantityOrdered,quantityReceivedElsewhere);
}

@override
String toString() {
    return 'InventoryReceiptLine(id: $id, productId: $productId, productCode: $productCode, productName: $productName, quantity: $quantity, purchaseOrderLineId: $purchaseOrderLineId, quantityOrdered: $quantityOrdered, quantityReceivedElsewhere: $quantityReceivedElsewhere)';
}


}

/// @nodoc
abstract mixin class _$InventoryReceiptLineCopyWith<$Res> implements $InventoryReceiptLineCopyWith<$Res> {
  factory _$InventoryReceiptLineCopyWith(_InventoryReceiptLine value, $Res Function(_InventoryReceiptLine) _then) = __$InventoryReceiptLineCopyWithImpl;
@override @useResult
$Res call({
 int id, int productId, String? productCode, String? productName, Decimal quantity, int? purchaseOrderLineId, Decimal quantityOrdered, Decimal? quantityReceivedElsewhere
});




}
/// @nodoc
class __$InventoryReceiptLineCopyWithImpl<$Res>
    implements _$InventoryReceiptLineCopyWith<$Res> {
  __$InventoryReceiptLineCopyWithImpl(this._self, this._then);

  final _InventoryReceiptLine _self;
  final $Res Function(_InventoryReceiptLine) _then;

/// Create a copy of InventoryReceiptLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? productId = null,Object? productCode = freezed,Object? productName = freezed,Object? quantity = null,Object? purchaseOrderLineId = freezed,Object? quantityOrdered = null,Object? quantityReceivedElsewhere = freezed,}) {
  return _then(_InventoryReceiptLine(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,productCode: freezed == productCode ? _self.productCode : productCode // ignore: cast_nullable_to_non_nullable
as String?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Decimal,purchaseOrderLineId: freezed == purchaseOrderLineId ? _self.purchaseOrderLineId : purchaseOrderLineId // ignore: cast_nullable_to_non_nullable
as int?,quantityOrdered: null == quantityOrdered ? _self.quantityOrdered : quantityOrdered // ignore: cast_nullable_to_non_nullable
as Decimal,quantityReceivedElsewhere: freezed == quantityReceivedElsewhere ? _self.quantityReceivedElsewhere : quantityReceivedElsewhere // ignore: cast_nullable_to_non_nullable
as Decimal?,
  ));
}


}

/// @nodoc
mixin _$InventoryReceipt {

 int get id; int get facilityId; int get warehouseId; int? get purchaseOrderId; int? get serial; InventoryDocumentStatus get status; int get creatorId; DateTime get createdAt;/// An empty string is treated as no note by the mapper.
 String? get comment; int get updaterId; DateTime get modifiedAt; List<InventoryReceiptLine> get lines;/// Only the count of the server's `warnings[]` is kept; their text is
/// never shown (spec FR-015a).
 int get serverWarningCount;
/// Create a copy of InventoryReceipt
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InventoryReceiptCopyWith<InventoryReceipt> get copyWith => _$InventoryReceiptCopyWithImpl<InventoryReceipt>(this as InventoryReceipt, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as InventoryReceipt;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InventoryReceipt&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.facilityId, _this.facilityId) || other.facilityId == _this.facilityId)&&(identical(other.warehouseId, _this.warehouseId) || other.warehouseId == _this.warehouseId)&&(identical(other.purchaseOrderId, _this.purchaseOrderId) || other.purchaseOrderId == _this.purchaseOrderId)&&(identical(other.serial, _this.serial) || other.serial == _this.serial)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.creatorId, _this.creatorId) || other.creatorId == _this.creatorId)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.comment, _this.comment) || other.comment == _this.comment)&&(identical(other.updaterId, _this.updaterId) || other.updaterId == _this.updaterId)&&(identical(other.modifiedAt, _this.modifiedAt) || other.modifiedAt == _this.modifiedAt)&&const DeepCollectionEquality().equals(other.lines, _this.lines)&&(identical(other.serverWarningCount, _this.serverWarningCount) || other.serverWarningCount == _this.serverWarningCount));
}


@override
int get hashCode {
  final _this = this as InventoryReceipt;
  return Object.hash(runtimeType,_this.id,_this.facilityId,_this.warehouseId,_this.purchaseOrderId,_this.serial,_this.status,_this.creatorId,_this.createdAt,_this.comment,_this.updaterId,_this.modifiedAt,const DeepCollectionEquality().hash(_this.lines),_this.serverWarningCount);
}

@override
String toString() {
  final _this = this as InventoryReceipt;
  return 'InventoryReceipt(id: ${_this.id}, facilityId: ${_this.facilityId}, warehouseId: ${_this.warehouseId}, purchaseOrderId: ${_this.purchaseOrderId}, serial: ${_this.serial}, status: ${_this.status}, creatorId: ${_this.creatorId}, createdAt: ${_this.createdAt}, comment: ${_this.comment}, updaterId: ${_this.updaterId}, modifiedAt: ${_this.modifiedAt}, lines: ${_this.lines}, serverWarningCount: ${_this.serverWarningCount})';
}


}

/// @nodoc
abstract mixin class $InventoryReceiptCopyWith<$Res>  {
  factory $InventoryReceiptCopyWith(InventoryReceipt value, $Res Function(InventoryReceipt) _then) = _$InventoryReceiptCopyWithImpl;
@useResult
$Res call({
 int id, int facilityId, int warehouseId, int? purchaseOrderId, int? serial, InventoryDocumentStatus status, int creatorId, DateTime createdAt, String? comment, int updaterId, DateTime modifiedAt, List<InventoryReceiptLine> lines, int serverWarningCount
});




}
/// @nodoc
class _$InventoryReceiptCopyWithImpl<$Res>
    implements $InventoryReceiptCopyWith<$Res> {
  _$InventoryReceiptCopyWithImpl(this._self, this._then);

  final InventoryReceipt _self;
  final $Res Function(InventoryReceipt) _then;

/// Create a copy of InventoryReceipt
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? facilityId = null,Object? warehouseId = null,Object? purchaseOrderId = freezed,Object? serial = freezed,Object? status = null,Object? creatorId = null,Object? createdAt = null,Object? comment = freezed,Object? updaterId = null,Object? modifiedAt = null,Object? lines = null,Object? serverWarningCount = null,}) {
  return _then(InventoryReceipt(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int,warehouseId: null == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int,purchaseOrderId: freezed == purchaseOrderId ? _self.purchaseOrderId : purchaseOrderId // ignore: cast_nullable_to_non_nullable
as int?,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InventoryDocumentStatus,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,updaterId: null == updaterId ? _self.updaterId : updaterId // ignore: cast_nullable_to_non_nullable
as int,modifiedAt: null == modifiedAt ? _self.modifiedAt : modifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<InventoryReceiptLine>,serverWarningCount: null == serverWarningCount ? _self.serverWarningCount : serverWarningCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [InventoryReceipt].
extension InventoryReceiptPatterns on InventoryReceipt {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InventoryReceipt value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InventoryReceipt() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InventoryReceipt value)  $default,){
final _that = this;
switch (_that) {
case _InventoryReceipt():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InventoryReceipt value)?  $default,){
final _that = this;
switch (_that) {
case _InventoryReceipt() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int facilityId,  int warehouseId,  int? purchaseOrderId,  int? serial,  InventoryDocumentStatus status,  int creatorId,  DateTime createdAt,  String? comment,  int updaterId,  DateTime modifiedAt,  List<InventoryReceiptLine> lines,  int serverWarningCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InventoryReceipt() when $default != null:
return $default(_that.id,_that.facilityId,_that.warehouseId,_that.purchaseOrderId,_that.serial,_that.status,_that.creatorId,_that.createdAt,_that.comment,_that.updaterId,_that.modifiedAt,_that.lines,_that.serverWarningCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int facilityId,  int warehouseId,  int? purchaseOrderId,  int? serial,  InventoryDocumentStatus status,  int creatorId,  DateTime createdAt,  String? comment,  int updaterId,  DateTime modifiedAt,  List<InventoryReceiptLine> lines,  int serverWarningCount)  $default,) {final _that = this;
switch (_that) {
case _InventoryReceipt():
return $default(_that.id,_that.facilityId,_that.warehouseId,_that.purchaseOrderId,_that.serial,_that.status,_that.creatorId,_that.createdAt,_that.comment,_that.updaterId,_that.modifiedAt,_that.lines,_that.serverWarningCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int facilityId,  int warehouseId,  int? purchaseOrderId,  int? serial,  InventoryDocumentStatus status,  int creatorId,  DateTime createdAt,  String? comment,  int updaterId,  DateTime modifiedAt,  List<InventoryReceiptLine> lines,  int serverWarningCount)?  $default,) {final _that = this;
switch (_that) {
case _InventoryReceipt() when $default != null:
return $default(_that.id,_that.facilityId,_that.warehouseId,_that.purchaseOrderId,_that.serial,_that.status,_that.creatorId,_that.createdAt,_that.comment,_that.updaterId,_that.modifiedAt,_that.lines,_that.serverWarningCount);case _:
  return null;

}
}

}

/// @nodoc


class _InventoryReceipt extends InventoryReceipt {
  const _InventoryReceipt({required this.id, required this.facilityId, required this.warehouseId, this.purchaseOrderId, this.serial, required this.status, required this.creatorId, required this.createdAt, this.comment, required this.updaterId, required this.modifiedAt, required  List<InventoryReceiptLine> lines, this.serverWarningCount = 0}): _lines = lines,super._();
  

@override final  int id;
@override final  int facilityId;
@override final  int warehouseId;
@override final  int? purchaseOrderId;
@override final  int? serial;
@override final  InventoryDocumentStatus status;
@override final  int creatorId;
@override final  DateTime createdAt;
/// An empty string is treated as no note by the mapper.
@override final  String? comment;
@override final  int updaterId;
@override final  DateTime modifiedAt;
 final  List<InventoryReceiptLine> _lines;
@override List<InventoryReceiptLine> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}

/// Only the count of the server's `warnings[]` is kept; their text is
/// never shown (spec FR-015a).
@override@JsonKey() final  int serverWarningCount;

/// Create a copy of InventoryReceipt
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InventoryReceiptCopyWith<_InventoryReceipt> get copyWith => __$InventoryReceiptCopyWithImpl<_InventoryReceipt>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _InventoryReceipt&&(identical(other.id, id) || other.id == id)&&(identical(other.facilityId, facilityId) || other.facilityId == facilityId)&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.purchaseOrderId, purchaseOrderId) || other.purchaseOrderId == purchaseOrderId)&&(identical(other.serial, serial) || other.serial == serial)&&(identical(other.status, status) || other.status == status)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.updaterId, updaterId) || other.updaterId == updaterId)&&(identical(other.modifiedAt, modifiedAt) || other.modifiedAt == modifiedAt)&&const DeepCollectionEquality().equals(other.lines, _lines)&&(identical(other.serverWarningCount, serverWarningCount) || other.serverWarningCount == serverWarningCount));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,facilityId,warehouseId,purchaseOrderId,serial,status,creatorId,createdAt,comment,updaterId,modifiedAt,const DeepCollectionEquality().hash(_lines),serverWarningCount);
}

@override
String toString() {
    return 'InventoryReceipt(id: $id, facilityId: $facilityId, warehouseId: $warehouseId, purchaseOrderId: $purchaseOrderId, serial: $serial, status: $status, creatorId: $creatorId, createdAt: $createdAt, comment: $comment, updaterId: $updaterId, modifiedAt: $modifiedAt, lines: $lines, serverWarningCount: $serverWarningCount)';
}


}

/// @nodoc
abstract mixin class _$InventoryReceiptCopyWith<$Res> implements $InventoryReceiptCopyWith<$Res> {
  factory _$InventoryReceiptCopyWith(_InventoryReceipt value, $Res Function(_InventoryReceipt) _then) = __$InventoryReceiptCopyWithImpl;
@override @useResult
$Res call({
 int id, int facilityId, int warehouseId, int? purchaseOrderId, int? serial, InventoryDocumentStatus status, int creatorId, DateTime createdAt, String? comment, int updaterId, DateTime modifiedAt, List<InventoryReceiptLine> lines, int serverWarningCount
});




}
/// @nodoc
class __$InventoryReceiptCopyWithImpl<$Res>
    implements _$InventoryReceiptCopyWith<$Res> {
  __$InventoryReceiptCopyWithImpl(this._self, this._then);

  final _InventoryReceipt _self;
  final $Res Function(_InventoryReceipt) _then;

/// Create a copy of InventoryReceipt
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? facilityId = null,Object? warehouseId = null,Object? purchaseOrderId = freezed,Object? serial = freezed,Object? status = null,Object? creatorId = null,Object? createdAt = null,Object? comment = freezed,Object? updaterId = null,Object? modifiedAt = null,Object? lines = null,Object? serverWarningCount = null,}) {
  return _then(_InventoryReceipt(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int,warehouseId: null == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int,purchaseOrderId: freezed == purchaseOrderId ? _self.purchaseOrderId : purchaseOrderId // ignore: cast_nullable_to_non_nullable
as int?,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InventoryDocumentStatus,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,updaterId: null == updaterId ? _self.updaterId : updaterId // ignore: cast_nullable_to_non_nullable
as int,modifiedAt: null == modifiedAt ? _self.modifiedAt : modifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<InventoryReceiptLine>,serverWarningCount: null == serverWarningCount ? _self.serverWarningCount : serverWarningCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
