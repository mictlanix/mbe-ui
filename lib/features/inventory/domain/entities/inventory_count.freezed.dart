// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inventory_count.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$InventoryCountSummary {

 int get id; int get facilityId; int get warehouseId;/// Null on drafts and cancelled counts. The "Borrador #{id}" text is
/// built by the presentation layer from l10n.
 int? get serial; InventoryDocumentStatus get status; int get creatorId; DateTime get createdAt;
/// Create a copy of InventoryCountSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InventoryCountSummaryCopyWith<InventoryCountSummary> get copyWith => _$InventoryCountSummaryCopyWithImpl<InventoryCountSummary>(this as InventoryCountSummary, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as InventoryCountSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InventoryCountSummary&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.facilityId, _this.facilityId) || other.facilityId == _this.facilityId)&&(identical(other.warehouseId, _this.warehouseId) || other.warehouseId == _this.warehouseId)&&(identical(other.serial, _this.serial) || other.serial == _this.serial)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.creatorId, _this.creatorId) || other.creatorId == _this.creatorId)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}


@override
int get hashCode {
  final _this = this as InventoryCountSummary;
  return Object.hash(runtimeType,_this.id,_this.facilityId,_this.warehouseId,_this.serial,_this.status,_this.creatorId,_this.createdAt);
}

@override
String toString() {
  final _this = this as InventoryCountSummary;
  return 'InventoryCountSummary(id: ${_this.id}, facilityId: ${_this.facilityId}, warehouseId: ${_this.warehouseId}, serial: ${_this.serial}, status: ${_this.status}, creatorId: ${_this.creatorId}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $InventoryCountSummaryCopyWith<$Res>  {
  factory $InventoryCountSummaryCopyWith(InventoryCountSummary value, $Res Function(InventoryCountSummary) _then) = _$InventoryCountSummaryCopyWithImpl;
@useResult
$Res call({
 int id, int facilityId, int warehouseId, int? serial, InventoryDocumentStatus status, int creatorId, DateTime createdAt
});




}
/// @nodoc
class _$InventoryCountSummaryCopyWithImpl<$Res>
    implements $InventoryCountSummaryCopyWith<$Res> {
  _$InventoryCountSummaryCopyWithImpl(this._self, this._then);

  final InventoryCountSummary _self;
  final $Res Function(InventoryCountSummary) _then;

/// Create a copy of InventoryCountSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? facilityId = null,Object? warehouseId = null,Object? serial = freezed,Object? status = null,Object? creatorId = null,Object? createdAt = null,}) {
  return _then(InventoryCountSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int,warehouseId: null == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InventoryDocumentStatus,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [InventoryCountSummary].
extension InventoryCountSummaryPatterns on InventoryCountSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InventoryCountSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InventoryCountSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InventoryCountSummary value)  $default,){
final _that = this;
switch (_that) {
case _InventoryCountSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InventoryCountSummary value)?  $default,){
final _that = this;
switch (_that) {
case _InventoryCountSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int facilityId,  int warehouseId,  int? serial,  InventoryDocumentStatus status,  int creatorId,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InventoryCountSummary() when $default != null:
return $default(_that.id,_that.facilityId,_that.warehouseId,_that.serial,_that.status,_that.creatorId,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int facilityId,  int warehouseId,  int? serial,  InventoryDocumentStatus status,  int creatorId,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _InventoryCountSummary():
return $default(_that.id,_that.facilityId,_that.warehouseId,_that.serial,_that.status,_that.creatorId,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int facilityId,  int warehouseId,  int? serial,  InventoryDocumentStatus status,  int creatorId,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _InventoryCountSummary() when $default != null:
return $default(_that.id,_that.facilityId,_that.warehouseId,_that.serial,_that.status,_that.creatorId,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _InventoryCountSummary implements InventoryCountSummary {
  const _InventoryCountSummary({required this.id, required this.facilityId, required this.warehouseId, this.serial, required this.status, required this.creatorId, required this.createdAt});
  

@override final  int id;
@override final  int facilityId;
@override final  int warehouseId;
/// Null on drafts and cancelled counts. The "Borrador #{id}" text is
/// built by the presentation layer from l10n.
@override final  int? serial;
@override final  InventoryDocumentStatus status;
@override final  int creatorId;
@override final  DateTime createdAt;

/// Create a copy of InventoryCountSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InventoryCountSummaryCopyWith<_InventoryCountSummary> get copyWith => __$InventoryCountSummaryCopyWithImpl<_InventoryCountSummary>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _InventoryCountSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.facilityId, facilityId) || other.facilityId == facilityId)&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.serial, serial) || other.serial == serial)&&(identical(other.status, status) || other.status == status)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,facilityId,warehouseId,serial,status,creatorId,createdAt);
}

@override
String toString() {
    return 'InventoryCountSummary(id: $id, facilityId: $facilityId, warehouseId: $warehouseId, serial: $serial, status: $status, creatorId: $creatorId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$InventoryCountSummaryCopyWith<$Res> implements $InventoryCountSummaryCopyWith<$Res> {
  factory _$InventoryCountSummaryCopyWith(_InventoryCountSummary value, $Res Function(_InventoryCountSummary) _then) = __$InventoryCountSummaryCopyWithImpl;
@override @useResult
$Res call({
 int id, int facilityId, int warehouseId, int? serial, InventoryDocumentStatus status, int creatorId, DateTime createdAt
});




}
/// @nodoc
class __$InventoryCountSummaryCopyWithImpl<$Res>
    implements _$InventoryCountSummaryCopyWith<$Res> {
  __$InventoryCountSummaryCopyWithImpl(this._self, this._then);

  final _InventoryCountSummary _self;
  final $Res Function(_InventoryCountSummary) _then;

/// Create a copy of InventoryCountSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? facilityId = null,Object? warehouseId = null,Object? serial = freezed,Object? status = null,Object? creatorId = null,Object? createdAt = null,}) {
  return _then(_InventoryCountSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int,warehouseId: null == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InventoryDocumentStatus,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$InventoryCountLine {

 int get id; int get productId;/// Snapshots from when the line was set; empty when the server sends none.
 String get productCode; String get productName;/// Counted, ≥ 0.
 Decimal get quantity;/// Null until the count is completed (drafts are blind, SC-003).
 Decimal? get quantityOnHand;/// Counted minus on hand; null until the count is completed.
 Decimal? get difference;
/// Create a copy of InventoryCountLine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InventoryCountLineCopyWith<InventoryCountLine> get copyWith => _$InventoryCountLineCopyWithImpl<InventoryCountLine>(this as InventoryCountLine, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as InventoryCountLine;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InventoryCountLine&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.productCode, _this.productCode) || other.productCode == _this.productCode)&&(identical(other.productName, _this.productName) || other.productName == _this.productName)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity)&&(identical(other.quantityOnHand, _this.quantityOnHand) || other.quantityOnHand == _this.quantityOnHand)&&(identical(other.difference, _this.difference) || other.difference == _this.difference));
}


@override
int get hashCode {
  final _this = this as InventoryCountLine;
  return Object.hash(runtimeType,_this.id,_this.productId,_this.productCode,_this.productName,_this.quantity,_this.quantityOnHand,_this.difference);
}

@override
String toString() {
  final _this = this as InventoryCountLine;
  return 'InventoryCountLine(id: ${_this.id}, productId: ${_this.productId}, productCode: ${_this.productCode}, productName: ${_this.productName}, quantity: ${_this.quantity}, quantityOnHand: ${_this.quantityOnHand}, difference: ${_this.difference})';
}


}

/// @nodoc
abstract mixin class $InventoryCountLineCopyWith<$Res>  {
  factory $InventoryCountLineCopyWith(InventoryCountLine value, $Res Function(InventoryCountLine) _then) = _$InventoryCountLineCopyWithImpl;
@useResult
$Res call({
 int id, int productId, String productCode, String productName, Decimal quantity, Decimal? quantityOnHand, Decimal? difference
});




}
/// @nodoc
class _$InventoryCountLineCopyWithImpl<$Res>
    implements $InventoryCountLineCopyWith<$Res> {
  _$InventoryCountLineCopyWithImpl(this._self, this._then);

  final InventoryCountLine _self;
  final $Res Function(InventoryCountLine) _then;

/// Create a copy of InventoryCountLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? productId = null,Object? productCode = null,Object? productName = null,Object? quantity = null,Object? quantityOnHand = freezed,Object? difference = freezed,}) {
  return _then(InventoryCountLine(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,productCode: null == productCode ? _self.productCode : productCode // ignore: cast_nullable_to_non_nullable
as String,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Decimal,quantityOnHand: freezed == quantityOnHand ? _self.quantityOnHand : quantityOnHand // ignore: cast_nullable_to_non_nullable
as Decimal?,difference: freezed == difference ? _self.difference : difference // ignore: cast_nullable_to_non_nullable
as Decimal?,
  ));
}

}


/// Adds pattern-matching-related methods to [InventoryCountLine].
extension InventoryCountLinePatterns on InventoryCountLine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InventoryCountLine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InventoryCountLine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InventoryCountLine value)  $default,){
final _that = this;
switch (_that) {
case _InventoryCountLine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InventoryCountLine value)?  $default,){
final _that = this;
switch (_that) {
case _InventoryCountLine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int productId,  String productCode,  String productName,  Decimal quantity,  Decimal? quantityOnHand,  Decimal? difference)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InventoryCountLine() when $default != null:
return $default(_that.id,_that.productId,_that.productCode,_that.productName,_that.quantity,_that.quantityOnHand,_that.difference);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int productId,  String productCode,  String productName,  Decimal quantity,  Decimal? quantityOnHand,  Decimal? difference)  $default,) {final _that = this;
switch (_that) {
case _InventoryCountLine():
return $default(_that.id,_that.productId,_that.productCode,_that.productName,_that.quantity,_that.quantityOnHand,_that.difference);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int productId,  String productCode,  String productName,  Decimal quantity,  Decimal? quantityOnHand,  Decimal? difference)?  $default,) {final _that = this;
switch (_that) {
case _InventoryCountLine() when $default != null:
return $default(_that.id,_that.productId,_that.productCode,_that.productName,_that.quantity,_that.quantityOnHand,_that.difference);case _:
  return null;

}
}

}

/// @nodoc


class _InventoryCountLine implements InventoryCountLine {
  const _InventoryCountLine({required this.id, required this.productId, required this.productCode, required this.productName, required this.quantity, this.quantityOnHand, this.difference});
  

@override final  int id;
@override final  int productId;
/// Snapshots from when the line was set; empty when the server sends none.
@override final  String productCode;
@override final  String productName;
/// Counted, ≥ 0.
@override final  Decimal quantity;
/// Null until the count is completed (drafts are blind, SC-003).
@override final  Decimal? quantityOnHand;
/// Counted minus on hand; null until the count is completed.
@override final  Decimal? difference;

/// Create a copy of InventoryCountLine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InventoryCountLineCopyWith<_InventoryCountLine> get copyWith => __$InventoryCountLineCopyWithImpl<_InventoryCountLine>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _InventoryCountLine&&(identical(other.id, id) || other.id == id)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productCode, productCode) || other.productCode == productCode)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.quantityOnHand, quantityOnHand) || other.quantityOnHand == quantityOnHand)&&(identical(other.difference, difference) || other.difference == difference));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,productId,productCode,productName,quantity,quantityOnHand,difference);
}

@override
String toString() {
    return 'InventoryCountLine(id: $id, productId: $productId, productCode: $productCode, productName: $productName, quantity: $quantity, quantityOnHand: $quantityOnHand, difference: $difference)';
}


}

/// @nodoc
abstract mixin class _$InventoryCountLineCopyWith<$Res> implements $InventoryCountLineCopyWith<$Res> {
  factory _$InventoryCountLineCopyWith(_InventoryCountLine value, $Res Function(_InventoryCountLine) _then) = __$InventoryCountLineCopyWithImpl;
@override @useResult
$Res call({
 int id, int productId, String productCode, String productName, Decimal quantity, Decimal? quantityOnHand, Decimal? difference
});




}
/// @nodoc
class __$InventoryCountLineCopyWithImpl<$Res>
    implements _$InventoryCountLineCopyWith<$Res> {
  __$InventoryCountLineCopyWithImpl(this._self, this._then);

  final _InventoryCountLine _self;
  final $Res Function(_InventoryCountLine) _then;

/// Create a copy of InventoryCountLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? productId = null,Object? productCode = null,Object? productName = null,Object? quantity = null,Object? quantityOnHand = freezed,Object? difference = freezed,}) {
  return _then(_InventoryCountLine(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,productCode: null == productCode ? _self.productCode : productCode // ignore: cast_nullable_to_non_nullable
as String,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Decimal,quantityOnHand: freezed == quantityOnHand ? _self.quantityOnHand : quantityOnHand // ignore: cast_nullable_to_non_nullable
as Decimal?,difference: freezed == difference ? _self.difference : difference // ignore: cast_nullable_to_non_nullable
as Decimal?,
  ));
}


}

/// @nodoc
mixin _$InventoryCount {

 int get id; int get facilityId; int get warehouseId; int? get serial; InventoryDocumentStatus get status; int get creatorId; DateTime get createdAt;/// An empty string is treated as no note by the mapper.
 String? get comment; int get updaterId; DateTime get updatedAt; List<InventoryCountLine> get lines;
/// Create a copy of InventoryCount
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InventoryCountCopyWith<InventoryCount> get copyWith => _$InventoryCountCopyWithImpl<InventoryCount>(this as InventoryCount, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as InventoryCount;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InventoryCount&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.facilityId, _this.facilityId) || other.facilityId == _this.facilityId)&&(identical(other.warehouseId, _this.warehouseId) || other.warehouseId == _this.warehouseId)&&(identical(other.serial, _this.serial) || other.serial == _this.serial)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.creatorId, _this.creatorId) || other.creatorId == _this.creatorId)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.comment, _this.comment) || other.comment == _this.comment)&&(identical(other.updaterId, _this.updaterId) || other.updaterId == _this.updaterId)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&const DeepCollectionEquality().equals(other.lines, _this.lines));
}


@override
int get hashCode {
  final _this = this as InventoryCount;
  return Object.hash(runtimeType,_this.id,_this.facilityId,_this.warehouseId,_this.serial,_this.status,_this.creatorId,_this.createdAt,_this.comment,_this.updaterId,_this.updatedAt,const DeepCollectionEquality().hash(_this.lines));
}

@override
String toString() {
  final _this = this as InventoryCount;
  return 'InventoryCount(id: ${_this.id}, facilityId: ${_this.facilityId}, warehouseId: ${_this.warehouseId}, serial: ${_this.serial}, status: ${_this.status}, creatorId: ${_this.creatorId}, createdAt: ${_this.createdAt}, comment: ${_this.comment}, updaterId: ${_this.updaterId}, updatedAt: ${_this.updatedAt}, lines: ${_this.lines})';
}


}

/// @nodoc
abstract mixin class $InventoryCountCopyWith<$Res>  {
  factory $InventoryCountCopyWith(InventoryCount value, $Res Function(InventoryCount) _then) = _$InventoryCountCopyWithImpl;
@useResult
$Res call({
 int id, int facilityId, int warehouseId, int? serial, InventoryDocumentStatus status, int creatorId, DateTime createdAt, String? comment, int updaterId, DateTime updatedAt, List<InventoryCountLine> lines
});




}
/// @nodoc
class _$InventoryCountCopyWithImpl<$Res>
    implements $InventoryCountCopyWith<$Res> {
  _$InventoryCountCopyWithImpl(this._self, this._then);

  final InventoryCount _self;
  final $Res Function(InventoryCount) _then;

/// Create a copy of InventoryCount
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? facilityId = null,Object? warehouseId = null,Object? serial = freezed,Object? status = null,Object? creatorId = null,Object? createdAt = null,Object? comment = freezed,Object? updaterId = null,Object? updatedAt = null,Object? lines = null,}) {
  return _then(InventoryCount(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int,warehouseId: null == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InventoryDocumentStatus,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,updaterId: null == updaterId ? _self.updaterId : updaterId // ignore: cast_nullable_to_non_nullable
as int,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<InventoryCountLine>,
  ));
}

}


/// Adds pattern-matching-related methods to [InventoryCount].
extension InventoryCountPatterns on InventoryCount {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InventoryCount value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InventoryCount() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InventoryCount value)  $default,){
final _that = this;
switch (_that) {
case _InventoryCount():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InventoryCount value)?  $default,){
final _that = this;
switch (_that) {
case _InventoryCount() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int facilityId,  int warehouseId,  int? serial,  InventoryDocumentStatus status,  int creatorId,  DateTime createdAt,  String? comment,  int updaterId,  DateTime updatedAt,  List<InventoryCountLine> lines)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InventoryCount() when $default != null:
return $default(_that.id,_that.facilityId,_that.warehouseId,_that.serial,_that.status,_that.creatorId,_that.createdAt,_that.comment,_that.updaterId,_that.updatedAt,_that.lines);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int facilityId,  int warehouseId,  int? serial,  InventoryDocumentStatus status,  int creatorId,  DateTime createdAt,  String? comment,  int updaterId,  DateTime updatedAt,  List<InventoryCountLine> lines)  $default,) {final _that = this;
switch (_that) {
case _InventoryCount():
return $default(_that.id,_that.facilityId,_that.warehouseId,_that.serial,_that.status,_that.creatorId,_that.createdAt,_that.comment,_that.updaterId,_that.updatedAt,_that.lines);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int facilityId,  int warehouseId,  int? serial,  InventoryDocumentStatus status,  int creatorId,  DateTime createdAt,  String? comment,  int updaterId,  DateTime updatedAt,  List<InventoryCountLine> lines)?  $default,) {final _that = this;
switch (_that) {
case _InventoryCount() when $default != null:
return $default(_that.id,_that.facilityId,_that.warehouseId,_that.serial,_that.status,_that.creatorId,_that.createdAt,_that.comment,_that.updaterId,_that.updatedAt,_that.lines);case _:
  return null;

}
}

}

/// @nodoc


class _InventoryCount extends InventoryCount {
  const _InventoryCount({required this.id, required this.facilityId, required this.warehouseId, this.serial, required this.status, required this.creatorId, required this.createdAt, this.comment, required this.updaterId, required this.updatedAt, required  List<InventoryCountLine> lines}): _lines = lines,super._();
  

@override final  int id;
@override final  int facilityId;
@override final  int warehouseId;
@override final  int? serial;
@override final  InventoryDocumentStatus status;
@override final  int creatorId;
@override final  DateTime createdAt;
/// An empty string is treated as no note by the mapper.
@override final  String? comment;
@override final  int updaterId;
@override final  DateTime updatedAt;
 final  List<InventoryCountLine> _lines;
@override List<InventoryCountLine> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}


/// Create a copy of InventoryCount
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InventoryCountCopyWith<_InventoryCount> get copyWith => __$InventoryCountCopyWithImpl<_InventoryCount>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _InventoryCount&&(identical(other.id, id) || other.id == id)&&(identical(other.facilityId, facilityId) || other.facilityId == facilityId)&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.serial, serial) || other.serial == serial)&&(identical(other.status, status) || other.status == status)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.updaterId, updaterId) || other.updaterId == updaterId)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.lines, _lines));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,facilityId,warehouseId,serial,status,creatorId,createdAt,comment,updaterId,updatedAt,const DeepCollectionEquality().hash(_lines));
}

@override
String toString() {
    return 'InventoryCount(id: $id, facilityId: $facilityId, warehouseId: $warehouseId, serial: $serial, status: $status, creatorId: $creatorId, createdAt: $createdAt, comment: $comment, updaterId: $updaterId, updatedAt: $updatedAt, lines: $lines)';
}


}

/// @nodoc
abstract mixin class _$InventoryCountCopyWith<$Res> implements $InventoryCountCopyWith<$Res> {
  factory _$InventoryCountCopyWith(_InventoryCount value, $Res Function(_InventoryCount) _then) = __$InventoryCountCopyWithImpl;
@override @useResult
$Res call({
 int id, int facilityId, int warehouseId, int? serial, InventoryDocumentStatus status, int creatorId, DateTime createdAt, String? comment, int updaterId, DateTime updatedAt, List<InventoryCountLine> lines
});




}
/// @nodoc
class __$InventoryCountCopyWithImpl<$Res>
    implements _$InventoryCountCopyWith<$Res> {
  __$InventoryCountCopyWithImpl(this._self, this._then);

  final _InventoryCount _self;
  final $Res Function(_InventoryCount) _then;

/// Create a copy of InventoryCount
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? facilityId = null,Object? warehouseId = null,Object? serial = freezed,Object? status = null,Object? creatorId = null,Object? createdAt = null,Object? comment = freezed,Object? updaterId = null,Object? updatedAt = null,Object? lines = null,}) {
  return _then(_InventoryCount(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int,warehouseId: null == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InventoryDocumentStatus,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,updaterId: null == updaterId ? _self.updaterId : updaterId // ignore: cast_nullable_to_non_nullable
as int,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<InventoryCountLine>,
  ));
}


}

/// @nodoc
mixin _$NegativeAvailableItem {

 int get productId; String get productCode; Decimal get counted; Decimal get reserved; Decimal get available;
/// Create a copy of NegativeAvailableItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NegativeAvailableItemCopyWith<NegativeAvailableItem> get copyWith => _$NegativeAvailableItemCopyWithImpl<NegativeAvailableItem>(this as NegativeAvailableItem, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as NegativeAvailableItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NegativeAvailableItem&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.productCode, _this.productCode) || other.productCode == _this.productCode)&&(identical(other.counted, _this.counted) || other.counted == _this.counted)&&(identical(other.reserved, _this.reserved) || other.reserved == _this.reserved)&&(identical(other.available, _this.available) || other.available == _this.available));
}


@override
int get hashCode {
  final _this = this as NegativeAvailableItem;
  return Object.hash(runtimeType,_this.productId,_this.productCode,_this.counted,_this.reserved,_this.available);
}

@override
String toString() {
  final _this = this as NegativeAvailableItem;
  return 'NegativeAvailableItem(productId: ${_this.productId}, productCode: ${_this.productCode}, counted: ${_this.counted}, reserved: ${_this.reserved}, available: ${_this.available})';
}


}

/// @nodoc
abstract mixin class $NegativeAvailableItemCopyWith<$Res>  {
  factory $NegativeAvailableItemCopyWith(NegativeAvailableItem value, $Res Function(NegativeAvailableItem) _then) = _$NegativeAvailableItemCopyWithImpl;
@useResult
$Res call({
 int productId, String productCode, Decimal counted, Decimal reserved, Decimal available
});




}
/// @nodoc
class _$NegativeAvailableItemCopyWithImpl<$Res>
    implements $NegativeAvailableItemCopyWith<$Res> {
  _$NegativeAvailableItemCopyWithImpl(this._self, this._then);

  final NegativeAvailableItem _self;
  final $Res Function(NegativeAvailableItem) _then;

/// Create a copy of NegativeAvailableItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? productCode = null,Object? counted = null,Object? reserved = null,Object? available = null,}) {
  return _then(NegativeAvailableItem(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,productCode: null == productCode ? _self.productCode : productCode // ignore: cast_nullable_to_non_nullable
as String,counted: null == counted ? _self.counted : counted // ignore: cast_nullable_to_non_nullable
as Decimal,reserved: null == reserved ? _self.reserved : reserved // ignore: cast_nullable_to_non_nullable
as Decimal,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}

}


/// Adds pattern-matching-related methods to [NegativeAvailableItem].
extension NegativeAvailableItemPatterns on NegativeAvailableItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NegativeAvailableItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NegativeAvailableItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NegativeAvailableItem value)  $default,){
final _that = this;
switch (_that) {
case _NegativeAvailableItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NegativeAvailableItem value)?  $default,){
final _that = this;
switch (_that) {
case _NegativeAvailableItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int productId,  String productCode,  Decimal counted,  Decimal reserved,  Decimal available)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NegativeAvailableItem() when $default != null:
return $default(_that.productId,_that.productCode,_that.counted,_that.reserved,_that.available);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int productId,  String productCode,  Decimal counted,  Decimal reserved,  Decimal available)  $default,) {final _that = this;
switch (_that) {
case _NegativeAvailableItem():
return $default(_that.productId,_that.productCode,_that.counted,_that.reserved,_that.available);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int productId,  String productCode,  Decimal counted,  Decimal reserved,  Decimal available)?  $default,) {final _that = this;
switch (_that) {
case _NegativeAvailableItem() when $default != null:
return $default(_that.productId,_that.productCode,_that.counted,_that.reserved,_that.available);case _:
  return null;

}
}

}

/// @nodoc


class _NegativeAvailableItem implements NegativeAvailableItem {
  const _NegativeAvailableItem({required this.productId, required this.productCode, required this.counted, required this.reserved, required this.available});
  

@override final  int productId;
@override final  String productCode;
@override final  Decimal counted;
@override final  Decimal reserved;
@override final  Decimal available;

/// Create a copy of NegativeAvailableItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NegativeAvailableItemCopyWith<_NegativeAvailableItem> get copyWith => __$NegativeAvailableItemCopyWithImpl<_NegativeAvailableItem>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NegativeAvailableItem&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productCode, productCode) || other.productCode == productCode)&&(identical(other.counted, counted) || other.counted == counted)&&(identical(other.reserved, reserved) || other.reserved == reserved)&&(identical(other.available, available) || other.available == available));
}


@override
int get hashCode {
    return Object.hash(runtimeType,productId,productCode,counted,reserved,available);
}

@override
String toString() {
    return 'NegativeAvailableItem(productId: $productId, productCode: $productCode, counted: $counted, reserved: $reserved, available: $available)';
}


}

/// @nodoc
abstract mixin class _$NegativeAvailableItemCopyWith<$Res> implements $NegativeAvailableItemCopyWith<$Res> {
  factory _$NegativeAvailableItemCopyWith(_NegativeAvailableItem value, $Res Function(_NegativeAvailableItem) _then) = __$NegativeAvailableItemCopyWithImpl;
@override @useResult
$Res call({
 int productId, String productCode, Decimal counted, Decimal reserved, Decimal available
});




}
/// @nodoc
class __$NegativeAvailableItemCopyWithImpl<$Res>
    implements _$NegativeAvailableItemCopyWith<$Res> {
  __$NegativeAvailableItemCopyWithImpl(this._self, this._then);

  final _NegativeAvailableItem _self;
  final $Res Function(_NegativeAvailableItem) _then;

/// Create a copy of NegativeAvailableItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? productCode = null,Object? counted = null,Object? reserved = null,Object? available = null,}) {
  return _then(_NegativeAvailableItem(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,productCode: null == productCode ? _self.productCode : productCode // ignore: cast_nullable_to_non_nullable
as String,counted: null == counted ? _self.counted : counted // ignore: cast_nullable_to_non_nullable
as Decimal,reserved: null == reserved ? _self.reserved : reserved // ignore: cast_nullable_to_non_nullable
as Decimal,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}


}

/// @nodoc
mixin _$CorrectedByOtherCountItem {

 int get productId; String get productCode; int get otherCountId; int? get otherCountSerial;
/// Create a copy of CorrectedByOtherCountItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CorrectedByOtherCountItemCopyWith<CorrectedByOtherCountItem> get copyWith => _$CorrectedByOtherCountItemCopyWithImpl<CorrectedByOtherCountItem>(this as CorrectedByOtherCountItem, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CorrectedByOtherCountItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CorrectedByOtherCountItem&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.productCode, _this.productCode) || other.productCode == _this.productCode)&&(identical(other.otherCountId, _this.otherCountId) || other.otherCountId == _this.otherCountId)&&(identical(other.otherCountSerial, _this.otherCountSerial) || other.otherCountSerial == _this.otherCountSerial));
}


@override
int get hashCode {
  final _this = this as CorrectedByOtherCountItem;
  return Object.hash(runtimeType,_this.productId,_this.productCode,_this.otherCountId,_this.otherCountSerial);
}

@override
String toString() {
  final _this = this as CorrectedByOtherCountItem;
  return 'CorrectedByOtherCountItem(productId: ${_this.productId}, productCode: ${_this.productCode}, otherCountId: ${_this.otherCountId}, otherCountSerial: ${_this.otherCountSerial})';
}


}

/// @nodoc
abstract mixin class $CorrectedByOtherCountItemCopyWith<$Res>  {
  factory $CorrectedByOtherCountItemCopyWith(CorrectedByOtherCountItem value, $Res Function(CorrectedByOtherCountItem) _then) = _$CorrectedByOtherCountItemCopyWithImpl;
@useResult
$Res call({
 int productId, String productCode, int otherCountId, int? otherCountSerial
});




}
/// @nodoc
class _$CorrectedByOtherCountItemCopyWithImpl<$Res>
    implements $CorrectedByOtherCountItemCopyWith<$Res> {
  _$CorrectedByOtherCountItemCopyWithImpl(this._self, this._then);

  final CorrectedByOtherCountItem _self;
  final $Res Function(CorrectedByOtherCountItem) _then;

/// Create a copy of CorrectedByOtherCountItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? productCode = null,Object? otherCountId = null,Object? otherCountSerial = freezed,}) {
  return _then(CorrectedByOtherCountItem(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,productCode: null == productCode ? _self.productCode : productCode // ignore: cast_nullable_to_non_nullable
as String,otherCountId: null == otherCountId ? _self.otherCountId : otherCountId // ignore: cast_nullable_to_non_nullable
as int,otherCountSerial: freezed == otherCountSerial ? _self.otherCountSerial : otherCountSerial // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [CorrectedByOtherCountItem].
extension CorrectedByOtherCountItemPatterns on CorrectedByOtherCountItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CorrectedByOtherCountItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CorrectedByOtherCountItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CorrectedByOtherCountItem value)  $default,){
final _that = this;
switch (_that) {
case _CorrectedByOtherCountItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CorrectedByOtherCountItem value)?  $default,){
final _that = this;
switch (_that) {
case _CorrectedByOtherCountItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int productId,  String productCode,  int otherCountId,  int? otherCountSerial)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CorrectedByOtherCountItem() when $default != null:
return $default(_that.productId,_that.productCode,_that.otherCountId,_that.otherCountSerial);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int productId,  String productCode,  int otherCountId,  int? otherCountSerial)  $default,) {final _that = this;
switch (_that) {
case _CorrectedByOtherCountItem():
return $default(_that.productId,_that.productCode,_that.otherCountId,_that.otherCountSerial);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int productId,  String productCode,  int otherCountId,  int? otherCountSerial)?  $default,) {final _that = this;
switch (_that) {
case _CorrectedByOtherCountItem() when $default != null:
return $default(_that.productId,_that.productCode,_that.otherCountId,_that.otherCountSerial);case _:
  return null;

}
}

}

/// @nodoc


class _CorrectedByOtherCountItem implements CorrectedByOtherCountItem {
  const _CorrectedByOtherCountItem({required this.productId, required this.productCode, required this.otherCountId, this.otherCountSerial});
  

@override final  int productId;
@override final  String productCode;
@override final  int otherCountId;
@override final  int? otherCountSerial;

/// Create a copy of CorrectedByOtherCountItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CorrectedByOtherCountItemCopyWith<_CorrectedByOtherCountItem> get copyWith => __$CorrectedByOtherCountItemCopyWithImpl<_CorrectedByOtherCountItem>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CorrectedByOtherCountItem&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productCode, productCode) || other.productCode == productCode)&&(identical(other.otherCountId, otherCountId) || other.otherCountId == otherCountId)&&(identical(other.otherCountSerial, otherCountSerial) || other.otherCountSerial == otherCountSerial));
}


@override
int get hashCode {
    return Object.hash(runtimeType,productId,productCode,otherCountId,otherCountSerial);
}

@override
String toString() {
    return 'CorrectedByOtherCountItem(productId: $productId, productCode: $productCode, otherCountId: $otherCountId, otherCountSerial: $otherCountSerial)';
}


}

/// @nodoc
abstract mixin class _$CorrectedByOtherCountItemCopyWith<$Res> implements $CorrectedByOtherCountItemCopyWith<$Res> {
  factory _$CorrectedByOtherCountItemCopyWith(_CorrectedByOtherCountItem value, $Res Function(_CorrectedByOtherCountItem) _then) = __$CorrectedByOtherCountItemCopyWithImpl;
@override @useResult
$Res call({
 int productId, String productCode, int otherCountId, int? otherCountSerial
});




}
/// @nodoc
class __$CorrectedByOtherCountItemCopyWithImpl<$Res>
    implements _$CorrectedByOtherCountItemCopyWith<$Res> {
  __$CorrectedByOtherCountItemCopyWithImpl(this._self, this._then);

  final _CorrectedByOtherCountItem _self;
  final $Res Function(_CorrectedByOtherCountItem) _then;

/// Create a copy of CorrectedByOtherCountItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? productCode = null,Object? otherCountId = null,Object? otherCountSerial = freezed,}) {
  return _then(_CorrectedByOtherCountItem(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,productCode: null == productCode ? _self.productCode : productCode // ignore: cast_nullable_to_non_nullable
as String,otherCountId: null == otherCountId ? _self.otherCountId : otherCountId // ignore: cast_nullable_to_non_nullable
as int,otherCountSerial: freezed == otherCountSerial ? _self.otherCountSerial : otherCountSerial // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$CountWarnings {

 List<NegativeAvailableItem> get negativeAvailable; List<CorrectedByOtherCountItem> get correctedByOtherCounts;
/// Create a copy of CountWarnings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CountWarningsCopyWith<CountWarnings> get copyWith => _$CountWarningsCopyWithImpl<CountWarnings>(this as CountWarnings, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CountWarnings;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CountWarnings&&const DeepCollectionEquality().equals(other.negativeAvailable, _this.negativeAvailable)&&const DeepCollectionEquality().equals(other.correctedByOtherCounts, _this.correctedByOtherCounts));
}


@override
int get hashCode {
  final _this = this as CountWarnings;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.negativeAvailable),const DeepCollectionEquality().hash(_this.correctedByOtherCounts));
}

@override
String toString() {
  final _this = this as CountWarnings;
  return 'CountWarnings(negativeAvailable: ${_this.negativeAvailable}, correctedByOtherCounts: ${_this.correctedByOtherCounts})';
}


}

/// @nodoc
abstract mixin class $CountWarningsCopyWith<$Res>  {
  factory $CountWarningsCopyWith(CountWarnings value, $Res Function(CountWarnings) _then) = _$CountWarningsCopyWithImpl;
@useResult
$Res call({
 List<NegativeAvailableItem> negativeAvailable, List<CorrectedByOtherCountItem> correctedByOtherCounts
});




}
/// @nodoc
class _$CountWarningsCopyWithImpl<$Res>
    implements $CountWarningsCopyWith<$Res> {
  _$CountWarningsCopyWithImpl(this._self, this._then);

  final CountWarnings _self;
  final $Res Function(CountWarnings) _then;

/// Create a copy of CountWarnings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? negativeAvailable = null,Object? correctedByOtherCounts = null,}) {
  return _then(CountWarnings(
negativeAvailable: null == negativeAvailable ? _self.negativeAvailable : negativeAvailable // ignore: cast_nullable_to_non_nullable
as List<NegativeAvailableItem>,correctedByOtherCounts: null == correctedByOtherCounts ? _self.correctedByOtherCounts : correctedByOtherCounts // ignore: cast_nullable_to_non_nullable
as List<CorrectedByOtherCountItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [CountWarnings].
extension CountWarningsPatterns on CountWarnings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CountWarnings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CountWarnings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CountWarnings value)  $default,){
final _that = this;
switch (_that) {
case _CountWarnings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CountWarnings value)?  $default,){
final _that = this;
switch (_that) {
case _CountWarnings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<NegativeAvailableItem> negativeAvailable,  List<CorrectedByOtherCountItem> correctedByOtherCounts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CountWarnings() when $default != null:
return $default(_that.negativeAvailable,_that.correctedByOtherCounts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<NegativeAvailableItem> negativeAvailable,  List<CorrectedByOtherCountItem> correctedByOtherCounts)  $default,) {final _that = this;
switch (_that) {
case _CountWarnings():
return $default(_that.negativeAvailable,_that.correctedByOtherCounts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<NegativeAvailableItem> negativeAvailable,  List<CorrectedByOtherCountItem> correctedByOtherCounts)?  $default,) {final _that = this;
switch (_that) {
case _CountWarnings() when $default != null:
return $default(_that.negativeAvailable,_that.correctedByOtherCounts);case _:
  return null;

}
}

}

/// @nodoc


class _CountWarnings extends CountWarnings {
  const _CountWarnings({ List<NegativeAvailableItem> negativeAvailable = const <NegativeAvailableItem>[],  List<CorrectedByOtherCountItem> correctedByOtherCounts = const <CorrectedByOtherCountItem>[]}): _negativeAvailable = negativeAvailable,_correctedByOtherCounts = correctedByOtherCounts,super._();
  

 final  List<NegativeAvailableItem> _negativeAvailable;
@override@JsonKey() List<NegativeAvailableItem> get negativeAvailable {
  if (_negativeAvailable is EqualUnmodifiableListView) return _negativeAvailable;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_negativeAvailable);
}

 final  List<CorrectedByOtherCountItem> _correctedByOtherCounts;
@override@JsonKey() List<CorrectedByOtherCountItem> get correctedByOtherCounts {
  if (_correctedByOtherCounts is EqualUnmodifiableListView) return _correctedByOtherCounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_correctedByOtherCounts);
}


/// Create a copy of CountWarnings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CountWarningsCopyWith<_CountWarnings> get copyWith => __$CountWarningsCopyWithImpl<_CountWarnings>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CountWarnings&&const DeepCollectionEquality().equals(other.negativeAvailable, _negativeAvailable)&&const DeepCollectionEquality().equals(other.correctedByOtherCounts, _correctedByOtherCounts));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_negativeAvailable),const DeepCollectionEquality().hash(_correctedByOtherCounts));
}

@override
String toString() {
    return 'CountWarnings(negativeAvailable: $negativeAvailable, correctedByOtherCounts: $correctedByOtherCounts)';
}


}

/// @nodoc
abstract mixin class _$CountWarningsCopyWith<$Res> implements $CountWarningsCopyWith<$Res> {
  factory _$CountWarningsCopyWith(_CountWarnings value, $Res Function(_CountWarnings) _then) = __$CountWarningsCopyWithImpl;
@override @useResult
$Res call({
 List<NegativeAvailableItem> negativeAvailable, List<CorrectedByOtherCountItem> correctedByOtherCounts
});




}
/// @nodoc
class __$CountWarningsCopyWithImpl<$Res>
    implements _$CountWarningsCopyWith<$Res> {
  __$CountWarningsCopyWithImpl(this._self, this._then);

  final _CountWarnings _self;
  final $Res Function(_CountWarnings) _then;

/// Create a copy of CountWarnings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? negativeAvailable = null,Object? correctedByOtherCounts = null,}) {
  return _then(_CountWarnings(
negativeAvailable: null == negativeAvailable ? _self._negativeAvailable : negativeAvailable // ignore: cast_nullable_to_non_nullable
as List<NegativeAvailableItem>,correctedByOtherCounts: null == correctedByOtherCounts ? _self._correctedByOtherCounts : correctedByOtherCounts // ignore: cast_nullable_to_non_nullable
as List<CorrectedByOtherCountItem>,
  ));
}


}

/// @nodoc
mixin _$CountConfirmResult {

 InventoryCount get count; CountWarnings get warnings;
/// Create a copy of CountConfirmResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CountConfirmResultCopyWith<CountConfirmResult> get copyWith => _$CountConfirmResultCopyWithImpl<CountConfirmResult>(this as CountConfirmResult, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CountConfirmResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CountConfirmResult&&(identical(other.count, _this.count) || other.count == _this.count)&&(identical(other.warnings, _this.warnings) || other.warnings == _this.warnings));
}


@override
int get hashCode {
  final _this = this as CountConfirmResult;
  return Object.hash(runtimeType,_this.count,_this.warnings);
}

@override
String toString() {
  final _this = this as CountConfirmResult;
  return 'CountConfirmResult(count: ${_this.count}, warnings: ${_this.warnings})';
}


}

/// @nodoc
abstract mixin class $CountConfirmResultCopyWith<$Res>  {
  factory $CountConfirmResultCopyWith(CountConfirmResult value, $Res Function(CountConfirmResult) _then) = _$CountConfirmResultCopyWithImpl;
@useResult
$Res call({
 InventoryCount count, CountWarnings warnings
});


$InventoryCountCopyWith<$Res> get count;$CountWarningsCopyWith<$Res> get warnings;

}
/// @nodoc
class _$CountConfirmResultCopyWithImpl<$Res>
    implements $CountConfirmResultCopyWith<$Res> {
  _$CountConfirmResultCopyWithImpl(this._self, this._then);

  final CountConfirmResult _self;
  final $Res Function(CountConfirmResult) _then;

/// Create a copy of CountConfirmResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? count = null,Object? warnings = null,}) {
  return _then(CountConfirmResult(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as InventoryCount,warnings: null == warnings ? _self.warnings : warnings // ignore: cast_nullable_to_non_nullable
as CountWarnings,
  ));
}
/// Create a copy of CountConfirmResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InventoryCountCopyWith<$Res> get count {
  
  return $InventoryCountCopyWith<$Res>(_self.count, (value) {
    return _then(_self.copyWith(count: value));
  });
}/// Create a copy of CountConfirmResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CountWarningsCopyWith<$Res> get warnings {
  
  return $CountWarningsCopyWith<$Res>(_self.warnings, (value) {
    return _then(_self.copyWith(warnings: value));
  });
}
}


/// Adds pattern-matching-related methods to [CountConfirmResult].
extension CountConfirmResultPatterns on CountConfirmResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CountConfirmResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CountConfirmResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CountConfirmResult value)  $default,){
final _that = this;
switch (_that) {
case _CountConfirmResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CountConfirmResult value)?  $default,){
final _that = this;
switch (_that) {
case _CountConfirmResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( InventoryCount count,  CountWarnings warnings)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CountConfirmResult() when $default != null:
return $default(_that.count,_that.warnings);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( InventoryCount count,  CountWarnings warnings)  $default,) {final _that = this;
switch (_that) {
case _CountConfirmResult():
return $default(_that.count,_that.warnings);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( InventoryCount count,  CountWarnings warnings)?  $default,) {final _that = this;
switch (_that) {
case _CountConfirmResult() when $default != null:
return $default(_that.count,_that.warnings);case _:
  return null;

}
}

}

/// @nodoc


class _CountConfirmResult implements CountConfirmResult {
  const _CountConfirmResult({required this.count, required this.warnings});
  

@override final  InventoryCount count;
@override final  CountWarnings warnings;

/// Create a copy of CountConfirmResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CountConfirmResultCopyWith<_CountConfirmResult> get copyWith => __$CountConfirmResultCopyWithImpl<_CountConfirmResult>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CountConfirmResult&&(identical(other.count, count) || other.count == count)&&(identical(other.warnings, warnings) || other.warnings == warnings));
}


@override
int get hashCode {
    return Object.hash(runtimeType,count,warnings);
}

@override
String toString() {
    return 'CountConfirmResult(count: $count, warnings: $warnings)';
}


}

/// @nodoc
abstract mixin class _$CountConfirmResultCopyWith<$Res> implements $CountConfirmResultCopyWith<$Res> {
  factory _$CountConfirmResultCopyWith(_CountConfirmResult value, $Res Function(_CountConfirmResult) _then) = __$CountConfirmResultCopyWithImpl;
@override @useResult
$Res call({
 InventoryCount count, CountWarnings warnings
});


@override $InventoryCountCopyWith<$Res> get count;@override $CountWarningsCopyWith<$Res> get warnings;

}
/// @nodoc
class __$CountConfirmResultCopyWithImpl<$Res>
    implements _$CountConfirmResultCopyWith<$Res> {
  __$CountConfirmResultCopyWithImpl(this._self, this._then);

  final _CountConfirmResult _self;
  final $Res Function(_CountConfirmResult) _then;

/// Create a copy of CountConfirmResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? count = null,Object? warnings = null,}) {
  return _then(_CountConfirmResult(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as InventoryCount,warnings: null == warnings ? _self.warnings : warnings // ignore: cast_nullable_to_non_nullable
as CountWarnings,
  ));
}

/// Create a copy of CountConfirmResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InventoryCountCopyWith<$Res> get count {
  
  return $InventoryCountCopyWith<$Res>(_self.count, (value) {
    return _then(_self.copyWith(count: value));
  });
}/// Create a copy of CountConfirmResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CountWarningsCopyWith<$Res> get warnings {
  
  return $CountWarningsCopyWith<$Res>(_self.warnings, (value) {
    return _then(_self.copyWith(warnings: value));
  });
}
}

/// @nodoc
mixin _$CountLineInput {

 Decimal get quantity;
/// Create a copy of CountLineInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CountLineInputCopyWith<CountLineInput> get copyWith => _$CountLineInputCopyWithImpl<CountLineInput>(this as CountLineInput, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CountLineInput;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CountLineInput&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity));
}


@override
int get hashCode {
  final _this = this as CountLineInput;
  return Object.hash(runtimeType,_this.quantity);
}

@override
String toString() {
  final _this = this as CountLineInput;
  return 'CountLineInput(quantity: ${_this.quantity})';
}


}

/// @nodoc
abstract mixin class $CountLineInputCopyWith<$Res>  {
  factory $CountLineInputCopyWith(CountLineInput value, $Res Function(CountLineInput) _then) = _$CountLineInputCopyWithImpl;
@useResult
$Res call({
 Decimal quantity
});




}
/// @nodoc
class _$CountLineInputCopyWithImpl<$Res>
    implements $CountLineInputCopyWith<$Res> {
  _$CountLineInputCopyWithImpl(this._self, this._then);

  final CountLineInput _self;
  final $Res Function(CountLineInput) _then;

/// Create a copy of CountLineInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? quantity = null,}) {
  return _then(_self.copyWith(
quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}

}


/// Adds pattern-matching-related methods to [CountLineInput].
extension CountLineInputPatterns on CountLineInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CountLineByProduct value)?  byProduct,TResult Function( CountLineByCode value)?  byCode,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CountLineByProduct() when byProduct != null:
return byProduct(_that);case CountLineByCode() when byCode != null:
return byCode(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CountLineByProduct value)  byProduct,required TResult Function( CountLineByCode value)  byCode,}){
final _that = this;
switch (_that) {
case CountLineByProduct():
return byProduct(_that);case CountLineByCode():
return byCode(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CountLineByProduct value)?  byProduct,TResult? Function( CountLineByCode value)?  byCode,}){
final _that = this;
switch (_that) {
case CountLineByProduct() when byProduct != null:
return byProduct(_that);case CountLineByCode() when byCode != null:
return byCode(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int productId,  Decimal quantity)?  byProduct,TResult Function( String code,  Decimal quantity)?  byCode,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CountLineByProduct() when byProduct != null:
return byProduct(_that.productId,_that.quantity);case CountLineByCode() when byCode != null:
return byCode(_that.code,_that.quantity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int productId,  Decimal quantity)  byProduct,required TResult Function( String code,  Decimal quantity)  byCode,}) {final _that = this;
switch (_that) {
case CountLineByProduct():
return byProduct(_that.productId,_that.quantity);case CountLineByCode():
return byCode(_that.code,_that.quantity);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int productId,  Decimal quantity)?  byProduct,TResult? Function( String code,  Decimal quantity)?  byCode,}) {final _that = this;
switch (_that) {
case CountLineByProduct() when byProduct != null:
return byProduct(_that.productId,_that.quantity);case CountLineByCode() when byCode != null:
return byCode(_that.code,_that.quantity);case _:
  return null;

}
}

}

/// @nodoc


class CountLineByProduct implements CountLineInput {
  const CountLineByProduct({required this.productId, required this.quantity});
  

 final  int productId;
@override final  Decimal quantity;

/// Create a copy of CountLineInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CountLineByProductCopyWith<CountLineByProduct> get copyWith => _$CountLineByProductCopyWithImpl<CountLineByProduct>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CountLineByProduct&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.quantity, quantity) || other.quantity == quantity));
}


@override
int get hashCode {
    return Object.hash(runtimeType,productId,quantity);
}

@override
String toString() {
    return 'CountLineInput.byProduct(productId: $productId, quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class $CountLineByProductCopyWith<$Res> implements $CountLineInputCopyWith<$Res> {
  factory $CountLineByProductCopyWith(CountLineByProduct value, $Res Function(CountLineByProduct) _then) = _$CountLineByProductCopyWithImpl;
@override @useResult
$Res call({
 int productId, Decimal quantity
});




}
/// @nodoc
class _$CountLineByProductCopyWithImpl<$Res>
    implements $CountLineByProductCopyWith<$Res> {
  _$CountLineByProductCopyWithImpl(this._self, this._then);

  final CountLineByProduct _self;
  final $Res Function(CountLineByProduct) _then;

/// Create a copy of CountLineInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? quantity = null,}) {
  return _then(CountLineByProduct(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}


}

/// @nodoc


class CountLineByCode implements CountLineInput {
  const CountLineByCode({required this.code, required this.quantity});
  

 final  String code;
@override final  Decimal quantity;

/// Create a copy of CountLineInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CountLineByCodeCopyWith<CountLineByCode> get copyWith => _$CountLineByCodeCopyWithImpl<CountLineByCode>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CountLineByCode&&(identical(other.code, code) || other.code == code)&&(identical(other.quantity, quantity) || other.quantity == quantity));
}


@override
int get hashCode {
    return Object.hash(runtimeType,code,quantity);
}

@override
String toString() {
    return 'CountLineInput.byCode(code: $code, quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class $CountLineByCodeCopyWith<$Res> implements $CountLineInputCopyWith<$Res> {
  factory $CountLineByCodeCopyWith(CountLineByCode value, $Res Function(CountLineByCode) _then) = _$CountLineByCodeCopyWithImpl;
@override @useResult
$Res call({
 String code, Decimal quantity
});




}
/// @nodoc
class _$CountLineByCodeCopyWithImpl<$Res>
    implements $CountLineByCodeCopyWith<$Res> {
  _$CountLineByCodeCopyWithImpl(this._self, this._then);

  final CountLineByCode _self;
  final $Res Function(CountLineByCode) _then;

/// Create a copy of CountLineInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? quantity = null,}) {
  return _then(CountLineByCode(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}


}

// dart format on
