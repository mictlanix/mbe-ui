// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inventory_transfer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$InventoryTransferSummary {

 int get id;/// The origin's facility.
 int get facilityId;/// The origin.
 int get warehouseId;/// The destination.
 int get warehouseToId;/// Null until the transfer is dispatched.
 int? get serial; InventoryTransferStatus get status; int get creatorId; DateTime get createdAt;/// Server-joined names (mbe-api#327–#330), null when the row is gone.
/// The name cells fall back to a per-id lookup when one is null.
 String? get warehouseName; String? get warehouseToName; String? get facilityName; String? get creatorName;
/// Create a copy of InventoryTransferSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InventoryTransferSummaryCopyWith<InventoryTransferSummary> get copyWith => _$InventoryTransferSummaryCopyWithImpl<InventoryTransferSummary>(this as InventoryTransferSummary, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as InventoryTransferSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InventoryTransferSummary&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.facilityId, _this.facilityId) || other.facilityId == _this.facilityId)&&(identical(other.warehouseId, _this.warehouseId) || other.warehouseId == _this.warehouseId)&&(identical(other.warehouseToId, _this.warehouseToId) || other.warehouseToId == _this.warehouseToId)&&(identical(other.serial, _this.serial) || other.serial == _this.serial)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.creatorId, _this.creatorId) || other.creatorId == _this.creatorId)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.warehouseName, _this.warehouseName) || other.warehouseName == _this.warehouseName)&&(identical(other.warehouseToName, _this.warehouseToName) || other.warehouseToName == _this.warehouseToName)&&(identical(other.facilityName, _this.facilityName) || other.facilityName == _this.facilityName)&&(identical(other.creatorName, _this.creatorName) || other.creatorName == _this.creatorName));
}


@override
int get hashCode {
  final _this = this as InventoryTransferSummary;
  return Object.hash(runtimeType,_this.id,_this.facilityId,_this.warehouseId,_this.warehouseToId,_this.serial,_this.status,_this.creatorId,_this.createdAt,_this.warehouseName,_this.warehouseToName,_this.facilityName,_this.creatorName);
}

@override
String toString() {
  final _this = this as InventoryTransferSummary;
  return 'InventoryTransferSummary(id: ${_this.id}, facilityId: ${_this.facilityId}, warehouseId: ${_this.warehouseId}, warehouseToId: ${_this.warehouseToId}, serial: ${_this.serial}, status: ${_this.status}, creatorId: ${_this.creatorId}, createdAt: ${_this.createdAt}, warehouseName: ${_this.warehouseName}, warehouseToName: ${_this.warehouseToName}, facilityName: ${_this.facilityName}, creatorName: ${_this.creatorName})';
}


}

/// @nodoc
abstract mixin class $InventoryTransferSummaryCopyWith<$Res>  {
  factory $InventoryTransferSummaryCopyWith(InventoryTransferSummary value, $Res Function(InventoryTransferSummary) _then) = _$InventoryTransferSummaryCopyWithImpl;
@useResult
$Res call({
 int id, int facilityId, int warehouseId, int warehouseToId, int? serial, InventoryTransferStatus status, int creatorId, DateTime createdAt, String? warehouseName, String? warehouseToName, String? facilityName, String? creatorName
});




}
/// @nodoc
class _$InventoryTransferSummaryCopyWithImpl<$Res>
    implements $InventoryTransferSummaryCopyWith<$Res> {
  _$InventoryTransferSummaryCopyWithImpl(this._self, this._then);

  final InventoryTransferSummary _self;
  final $Res Function(InventoryTransferSummary) _then;

/// Create a copy of InventoryTransferSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? facilityId = null,Object? warehouseId = null,Object? warehouseToId = null,Object? serial = freezed,Object? status = null,Object? creatorId = null,Object? createdAt = null,Object? warehouseName = freezed,Object? warehouseToName = freezed,Object? facilityName = freezed,Object? creatorName = freezed,}) {
  return _then(InventoryTransferSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int,warehouseId: null == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int,warehouseToId: null == warehouseToId ? _self.warehouseToId : warehouseToId // ignore: cast_nullable_to_non_nullable
as int,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InventoryTransferStatus,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,warehouseName: freezed == warehouseName ? _self.warehouseName : warehouseName // ignore: cast_nullable_to_non_nullable
as String?,warehouseToName: freezed == warehouseToName ? _self.warehouseToName : warehouseToName // ignore: cast_nullable_to_non_nullable
as String?,facilityName: freezed == facilityName ? _self.facilityName : facilityName // ignore: cast_nullable_to_non_nullable
as String?,creatorName: freezed == creatorName ? _self.creatorName : creatorName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [InventoryTransferSummary].
extension InventoryTransferSummaryPatterns on InventoryTransferSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InventoryTransferSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InventoryTransferSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InventoryTransferSummary value)  $default,){
final _that = this;
switch (_that) {
case _InventoryTransferSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InventoryTransferSummary value)?  $default,){
final _that = this;
switch (_that) {
case _InventoryTransferSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int facilityId,  int warehouseId,  int warehouseToId,  int? serial,  InventoryTransferStatus status,  int creatorId,  DateTime createdAt,  String? warehouseName,  String? warehouseToName,  String? facilityName,  String? creatorName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InventoryTransferSummary() when $default != null:
return $default(_that.id,_that.facilityId,_that.warehouseId,_that.warehouseToId,_that.serial,_that.status,_that.creatorId,_that.createdAt,_that.warehouseName,_that.warehouseToName,_that.facilityName,_that.creatorName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int facilityId,  int warehouseId,  int warehouseToId,  int? serial,  InventoryTransferStatus status,  int creatorId,  DateTime createdAt,  String? warehouseName,  String? warehouseToName,  String? facilityName,  String? creatorName)  $default,) {final _that = this;
switch (_that) {
case _InventoryTransferSummary():
return $default(_that.id,_that.facilityId,_that.warehouseId,_that.warehouseToId,_that.serial,_that.status,_that.creatorId,_that.createdAt,_that.warehouseName,_that.warehouseToName,_that.facilityName,_that.creatorName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int facilityId,  int warehouseId,  int warehouseToId,  int? serial,  InventoryTransferStatus status,  int creatorId,  DateTime createdAt,  String? warehouseName,  String? warehouseToName,  String? facilityName,  String? creatorName)?  $default,) {final _that = this;
switch (_that) {
case _InventoryTransferSummary() when $default != null:
return $default(_that.id,_that.facilityId,_that.warehouseId,_that.warehouseToId,_that.serial,_that.status,_that.creatorId,_that.createdAt,_that.warehouseName,_that.warehouseToName,_that.facilityName,_that.creatorName);case _:
  return null;

}
}

}

/// @nodoc


class _InventoryTransferSummary implements InventoryTransferSummary {
  const _InventoryTransferSummary({required this.id, required this.facilityId, required this.warehouseId, required this.warehouseToId, this.serial, required this.status, required this.creatorId, required this.createdAt, this.warehouseName, this.warehouseToName, this.facilityName, this.creatorName});
  

@override final  int id;
/// The origin's facility.
@override final  int facilityId;
/// The origin.
@override final  int warehouseId;
/// The destination.
@override final  int warehouseToId;
/// Null until the transfer is dispatched.
@override final  int? serial;
@override final  InventoryTransferStatus status;
@override final  int creatorId;
@override final  DateTime createdAt;
/// Server-joined names (mbe-api#327–#330), null when the row is gone.
/// The name cells fall back to a per-id lookup when one is null.
@override final  String? warehouseName;
@override final  String? warehouseToName;
@override final  String? facilityName;
@override final  String? creatorName;

/// Create a copy of InventoryTransferSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InventoryTransferSummaryCopyWith<_InventoryTransferSummary> get copyWith => __$InventoryTransferSummaryCopyWithImpl<_InventoryTransferSummary>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _InventoryTransferSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.facilityId, facilityId) || other.facilityId == facilityId)&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.warehouseToId, warehouseToId) || other.warehouseToId == warehouseToId)&&(identical(other.serial, serial) || other.serial == serial)&&(identical(other.status, status) || other.status == status)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.warehouseName, warehouseName) || other.warehouseName == warehouseName)&&(identical(other.warehouseToName, warehouseToName) || other.warehouseToName == warehouseToName)&&(identical(other.facilityName, facilityName) || other.facilityName == facilityName)&&(identical(other.creatorName, creatorName) || other.creatorName == creatorName));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,facilityId,warehouseId,warehouseToId,serial,status,creatorId,createdAt,warehouseName,warehouseToName,facilityName,creatorName);
}

@override
String toString() {
    return 'InventoryTransferSummary(id: $id, facilityId: $facilityId, warehouseId: $warehouseId, warehouseToId: $warehouseToId, serial: $serial, status: $status, creatorId: $creatorId, createdAt: $createdAt, warehouseName: $warehouseName, warehouseToName: $warehouseToName, facilityName: $facilityName, creatorName: $creatorName)';
}


}

/// @nodoc
abstract mixin class _$InventoryTransferSummaryCopyWith<$Res> implements $InventoryTransferSummaryCopyWith<$Res> {
  factory _$InventoryTransferSummaryCopyWith(_InventoryTransferSummary value, $Res Function(_InventoryTransferSummary) _then) = __$InventoryTransferSummaryCopyWithImpl;
@override @useResult
$Res call({
 int id, int facilityId, int warehouseId, int warehouseToId, int? serial, InventoryTransferStatus status, int creatorId, DateTime createdAt, String? warehouseName, String? warehouseToName, String? facilityName, String? creatorName
});




}
/// @nodoc
class __$InventoryTransferSummaryCopyWithImpl<$Res>
    implements _$InventoryTransferSummaryCopyWith<$Res> {
  __$InventoryTransferSummaryCopyWithImpl(this._self, this._then);

  final _InventoryTransferSummary _self;
  final $Res Function(_InventoryTransferSummary) _then;

/// Create a copy of InventoryTransferSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? facilityId = null,Object? warehouseId = null,Object? warehouseToId = null,Object? serial = freezed,Object? status = null,Object? creatorId = null,Object? createdAt = null,Object? warehouseName = freezed,Object? warehouseToName = freezed,Object? facilityName = freezed,Object? creatorName = freezed,}) {
  return _then(_InventoryTransferSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int,warehouseId: null == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int,warehouseToId: null == warehouseToId ? _self.warehouseToId : warehouseToId // ignore: cast_nullable_to_non_nullable
as int,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InventoryTransferStatus,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,warehouseName: freezed == warehouseName ? _self.warehouseName : warehouseName // ignore: cast_nullable_to_non_nullable
as String?,warehouseToName: freezed == warehouseToName ? _self.warehouseToName : warehouseToName // ignore: cast_nullable_to_non_nullable
as String?,facilityName: freezed == facilityName ? _self.facilityName : facilityName // ignore: cast_nullable_to_non_nullable
as String?,creatorName: freezed == creatorName ? _self.creatorName : creatorName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$InventoryTransferLine {

 int get id; int get productId;/// Snapshots from when the line was added.
 String? get productCode; String? get productName;/// Sent.
 Decimal get quantity; Decimal get quantityReceived;/// Zero unless the transfer is in transit.
 Decimal get quantityOutstanding;
/// Create a copy of InventoryTransferLine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InventoryTransferLineCopyWith<InventoryTransferLine> get copyWith => _$InventoryTransferLineCopyWithImpl<InventoryTransferLine>(this as InventoryTransferLine, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as InventoryTransferLine;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InventoryTransferLine&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.productCode, _this.productCode) || other.productCode == _this.productCode)&&(identical(other.productName, _this.productName) || other.productName == _this.productName)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity)&&(identical(other.quantityReceived, _this.quantityReceived) || other.quantityReceived == _this.quantityReceived)&&(identical(other.quantityOutstanding, _this.quantityOutstanding) || other.quantityOutstanding == _this.quantityOutstanding));
}


@override
int get hashCode {
  final _this = this as InventoryTransferLine;
  return Object.hash(runtimeType,_this.id,_this.productId,_this.productCode,_this.productName,_this.quantity,_this.quantityReceived,_this.quantityOutstanding);
}

@override
String toString() {
  final _this = this as InventoryTransferLine;
  return 'InventoryTransferLine(id: ${_this.id}, productId: ${_this.productId}, productCode: ${_this.productCode}, productName: ${_this.productName}, quantity: ${_this.quantity}, quantityReceived: ${_this.quantityReceived}, quantityOutstanding: ${_this.quantityOutstanding})';
}


}

/// @nodoc
abstract mixin class $InventoryTransferLineCopyWith<$Res>  {
  factory $InventoryTransferLineCopyWith(InventoryTransferLine value, $Res Function(InventoryTransferLine) _then) = _$InventoryTransferLineCopyWithImpl;
@useResult
$Res call({
 int id, int productId, String? productCode, String? productName, Decimal quantity, Decimal quantityReceived, Decimal quantityOutstanding
});




}
/// @nodoc
class _$InventoryTransferLineCopyWithImpl<$Res>
    implements $InventoryTransferLineCopyWith<$Res> {
  _$InventoryTransferLineCopyWithImpl(this._self, this._then);

  final InventoryTransferLine _self;
  final $Res Function(InventoryTransferLine) _then;

/// Create a copy of InventoryTransferLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? productId = null,Object? productCode = freezed,Object? productName = freezed,Object? quantity = null,Object? quantityReceived = null,Object? quantityOutstanding = null,}) {
  return _then(InventoryTransferLine(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,productCode: freezed == productCode ? _self.productCode : productCode // ignore: cast_nullable_to_non_nullable
as String?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Decimal,quantityReceived: null == quantityReceived ? _self.quantityReceived : quantityReceived // ignore: cast_nullable_to_non_nullable
as Decimal,quantityOutstanding: null == quantityOutstanding ? _self.quantityOutstanding : quantityOutstanding // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}

}


/// Adds pattern-matching-related methods to [InventoryTransferLine].
extension InventoryTransferLinePatterns on InventoryTransferLine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InventoryTransferLine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InventoryTransferLine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InventoryTransferLine value)  $default,){
final _that = this;
switch (_that) {
case _InventoryTransferLine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InventoryTransferLine value)?  $default,){
final _that = this;
switch (_that) {
case _InventoryTransferLine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int productId,  String? productCode,  String? productName,  Decimal quantity,  Decimal quantityReceived,  Decimal quantityOutstanding)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InventoryTransferLine() when $default != null:
return $default(_that.id,_that.productId,_that.productCode,_that.productName,_that.quantity,_that.quantityReceived,_that.quantityOutstanding);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int productId,  String? productCode,  String? productName,  Decimal quantity,  Decimal quantityReceived,  Decimal quantityOutstanding)  $default,) {final _that = this;
switch (_that) {
case _InventoryTransferLine():
return $default(_that.id,_that.productId,_that.productCode,_that.productName,_that.quantity,_that.quantityReceived,_that.quantityOutstanding);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int productId,  String? productCode,  String? productName,  Decimal quantity,  Decimal quantityReceived,  Decimal quantityOutstanding)?  $default,) {final _that = this;
switch (_that) {
case _InventoryTransferLine() when $default != null:
return $default(_that.id,_that.productId,_that.productCode,_that.productName,_that.quantity,_that.quantityReceived,_that.quantityOutstanding);case _:
  return null;

}
}

}

/// @nodoc


class _InventoryTransferLine implements InventoryTransferLine {
  const _InventoryTransferLine({required this.id, required this.productId, this.productCode, this.productName, required this.quantity, required this.quantityReceived, required this.quantityOutstanding});
  

@override final  int id;
@override final  int productId;
/// Snapshots from when the line was added.
@override final  String? productCode;
@override final  String? productName;
/// Sent.
@override final  Decimal quantity;
@override final  Decimal quantityReceived;
/// Zero unless the transfer is in transit.
@override final  Decimal quantityOutstanding;

/// Create a copy of InventoryTransferLine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InventoryTransferLineCopyWith<_InventoryTransferLine> get copyWith => __$InventoryTransferLineCopyWithImpl<_InventoryTransferLine>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _InventoryTransferLine&&(identical(other.id, id) || other.id == id)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productCode, productCode) || other.productCode == productCode)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.quantityReceived, quantityReceived) || other.quantityReceived == quantityReceived)&&(identical(other.quantityOutstanding, quantityOutstanding) || other.quantityOutstanding == quantityOutstanding));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,productId,productCode,productName,quantity,quantityReceived,quantityOutstanding);
}

@override
String toString() {
    return 'InventoryTransferLine(id: $id, productId: $productId, productCode: $productCode, productName: $productName, quantity: $quantity, quantityReceived: $quantityReceived, quantityOutstanding: $quantityOutstanding)';
}


}

/// @nodoc
abstract mixin class _$InventoryTransferLineCopyWith<$Res> implements $InventoryTransferLineCopyWith<$Res> {
  factory _$InventoryTransferLineCopyWith(_InventoryTransferLine value, $Res Function(_InventoryTransferLine) _then) = __$InventoryTransferLineCopyWithImpl;
@override @useResult
$Res call({
 int id, int productId, String? productCode, String? productName, Decimal quantity, Decimal quantityReceived, Decimal quantityOutstanding
});




}
/// @nodoc
class __$InventoryTransferLineCopyWithImpl<$Res>
    implements _$InventoryTransferLineCopyWith<$Res> {
  __$InventoryTransferLineCopyWithImpl(this._self, this._then);

  final _InventoryTransferLine _self;
  final $Res Function(_InventoryTransferLine) _then;

/// Create a copy of InventoryTransferLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? productId = null,Object? productCode = freezed,Object? productName = freezed,Object? quantity = null,Object? quantityReceived = null,Object? quantityOutstanding = null,}) {
  return _then(_InventoryTransferLine(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,productCode: freezed == productCode ? _self.productCode : productCode // ignore: cast_nullable_to_non_nullable
as String?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Decimal,quantityReceived: null == quantityReceived ? _self.quantityReceived : quantityReceived // ignore: cast_nullable_to_non_nullable
as Decimal,quantityOutstanding: null == quantityOutstanding ? _self.quantityOutstanding : quantityOutstanding // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}


}

/// @nodoc
mixin _$InventoryTransfer {

 int get id; int get facilityId; int get warehouseId; int get warehouseToId; int? get serial; InventoryTransferStatus get status; int get creatorId; DateTime get createdAt;/// An empty string is treated as no note by the mapper.
 String? get comment; int get updaterId; DateTime get modifiedAt; List<InventoryTransferLine> get lines;
/// Create a copy of InventoryTransfer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InventoryTransferCopyWith<InventoryTransfer> get copyWith => _$InventoryTransferCopyWithImpl<InventoryTransfer>(this as InventoryTransfer, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as InventoryTransfer;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InventoryTransfer&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.facilityId, _this.facilityId) || other.facilityId == _this.facilityId)&&(identical(other.warehouseId, _this.warehouseId) || other.warehouseId == _this.warehouseId)&&(identical(other.warehouseToId, _this.warehouseToId) || other.warehouseToId == _this.warehouseToId)&&(identical(other.serial, _this.serial) || other.serial == _this.serial)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.creatorId, _this.creatorId) || other.creatorId == _this.creatorId)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.comment, _this.comment) || other.comment == _this.comment)&&(identical(other.updaterId, _this.updaterId) || other.updaterId == _this.updaterId)&&(identical(other.modifiedAt, _this.modifiedAt) || other.modifiedAt == _this.modifiedAt)&&const DeepCollectionEquality().equals(other.lines, _this.lines));
}


@override
int get hashCode {
  final _this = this as InventoryTransfer;
  return Object.hash(runtimeType,_this.id,_this.facilityId,_this.warehouseId,_this.warehouseToId,_this.serial,_this.status,_this.creatorId,_this.createdAt,_this.comment,_this.updaterId,_this.modifiedAt,const DeepCollectionEquality().hash(_this.lines));
}

@override
String toString() {
  final _this = this as InventoryTransfer;
  return 'InventoryTransfer(id: ${_this.id}, facilityId: ${_this.facilityId}, warehouseId: ${_this.warehouseId}, warehouseToId: ${_this.warehouseToId}, serial: ${_this.serial}, status: ${_this.status}, creatorId: ${_this.creatorId}, createdAt: ${_this.createdAt}, comment: ${_this.comment}, updaterId: ${_this.updaterId}, modifiedAt: ${_this.modifiedAt}, lines: ${_this.lines})';
}


}

/// @nodoc
abstract mixin class $InventoryTransferCopyWith<$Res>  {
  factory $InventoryTransferCopyWith(InventoryTransfer value, $Res Function(InventoryTransfer) _then) = _$InventoryTransferCopyWithImpl;
@useResult
$Res call({
 int id, int facilityId, int warehouseId, int warehouseToId, int? serial, InventoryTransferStatus status, int creatorId, DateTime createdAt, String? comment, int updaterId, DateTime modifiedAt, List<InventoryTransferLine> lines
});




}
/// @nodoc
class _$InventoryTransferCopyWithImpl<$Res>
    implements $InventoryTransferCopyWith<$Res> {
  _$InventoryTransferCopyWithImpl(this._self, this._then);

  final InventoryTransfer _self;
  final $Res Function(InventoryTransfer) _then;

/// Create a copy of InventoryTransfer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? facilityId = null,Object? warehouseId = null,Object? warehouseToId = null,Object? serial = freezed,Object? status = null,Object? creatorId = null,Object? createdAt = null,Object? comment = freezed,Object? updaterId = null,Object? modifiedAt = null,Object? lines = null,}) {
  return _then(InventoryTransfer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int,warehouseId: null == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int,warehouseToId: null == warehouseToId ? _self.warehouseToId : warehouseToId // ignore: cast_nullable_to_non_nullable
as int,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InventoryTransferStatus,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,updaterId: null == updaterId ? _self.updaterId : updaterId // ignore: cast_nullable_to_non_nullable
as int,modifiedAt: null == modifiedAt ? _self.modifiedAt : modifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<InventoryTransferLine>,
  ));
}

}


/// Adds pattern-matching-related methods to [InventoryTransfer].
extension InventoryTransferPatterns on InventoryTransfer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InventoryTransfer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InventoryTransfer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InventoryTransfer value)  $default,){
final _that = this;
switch (_that) {
case _InventoryTransfer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InventoryTransfer value)?  $default,){
final _that = this;
switch (_that) {
case _InventoryTransfer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int facilityId,  int warehouseId,  int warehouseToId,  int? serial,  InventoryTransferStatus status,  int creatorId,  DateTime createdAt,  String? comment,  int updaterId,  DateTime modifiedAt,  List<InventoryTransferLine> lines)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InventoryTransfer() when $default != null:
return $default(_that.id,_that.facilityId,_that.warehouseId,_that.warehouseToId,_that.serial,_that.status,_that.creatorId,_that.createdAt,_that.comment,_that.updaterId,_that.modifiedAt,_that.lines);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int facilityId,  int warehouseId,  int warehouseToId,  int? serial,  InventoryTransferStatus status,  int creatorId,  DateTime createdAt,  String? comment,  int updaterId,  DateTime modifiedAt,  List<InventoryTransferLine> lines)  $default,) {final _that = this;
switch (_that) {
case _InventoryTransfer():
return $default(_that.id,_that.facilityId,_that.warehouseId,_that.warehouseToId,_that.serial,_that.status,_that.creatorId,_that.createdAt,_that.comment,_that.updaterId,_that.modifiedAt,_that.lines);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int facilityId,  int warehouseId,  int warehouseToId,  int? serial,  InventoryTransferStatus status,  int creatorId,  DateTime createdAt,  String? comment,  int updaterId,  DateTime modifiedAt,  List<InventoryTransferLine> lines)?  $default,) {final _that = this;
switch (_that) {
case _InventoryTransfer() when $default != null:
return $default(_that.id,_that.facilityId,_that.warehouseId,_that.warehouseToId,_that.serial,_that.status,_that.creatorId,_that.createdAt,_that.comment,_that.updaterId,_that.modifiedAt,_that.lines);case _:
  return null;

}
}

}

/// @nodoc


class _InventoryTransfer extends InventoryTransfer {
  const _InventoryTransfer({required this.id, required this.facilityId, required this.warehouseId, required this.warehouseToId, this.serial, required this.status, required this.creatorId, required this.createdAt, this.comment, required this.updaterId, required this.modifiedAt, required  List<InventoryTransferLine> lines}): _lines = lines,super._();
  

@override final  int id;
@override final  int facilityId;
@override final  int warehouseId;
@override final  int warehouseToId;
@override final  int? serial;
@override final  InventoryTransferStatus status;
@override final  int creatorId;
@override final  DateTime createdAt;
/// An empty string is treated as no note by the mapper.
@override final  String? comment;
@override final  int updaterId;
@override final  DateTime modifiedAt;
 final  List<InventoryTransferLine> _lines;
@override List<InventoryTransferLine> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}


/// Create a copy of InventoryTransfer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InventoryTransferCopyWith<_InventoryTransfer> get copyWith => __$InventoryTransferCopyWithImpl<_InventoryTransfer>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _InventoryTransfer&&(identical(other.id, id) || other.id == id)&&(identical(other.facilityId, facilityId) || other.facilityId == facilityId)&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.warehouseToId, warehouseToId) || other.warehouseToId == warehouseToId)&&(identical(other.serial, serial) || other.serial == serial)&&(identical(other.status, status) || other.status == status)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.updaterId, updaterId) || other.updaterId == updaterId)&&(identical(other.modifiedAt, modifiedAt) || other.modifiedAt == modifiedAt)&&const DeepCollectionEquality().equals(other.lines, _lines));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,facilityId,warehouseId,warehouseToId,serial,status,creatorId,createdAt,comment,updaterId,modifiedAt,const DeepCollectionEquality().hash(_lines));
}

@override
String toString() {
    return 'InventoryTransfer(id: $id, facilityId: $facilityId, warehouseId: $warehouseId, warehouseToId: $warehouseToId, serial: $serial, status: $status, creatorId: $creatorId, createdAt: $createdAt, comment: $comment, updaterId: $updaterId, modifiedAt: $modifiedAt, lines: $lines)';
}


}

/// @nodoc
abstract mixin class _$InventoryTransferCopyWith<$Res> implements $InventoryTransferCopyWith<$Res> {
  factory _$InventoryTransferCopyWith(_InventoryTransfer value, $Res Function(_InventoryTransfer) _then) = __$InventoryTransferCopyWithImpl;
@override @useResult
$Res call({
 int id, int facilityId, int warehouseId, int warehouseToId, int? serial, InventoryTransferStatus status, int creatorId, DateTime createdAt, String? comment, int updaterId, DateTime modifiedAt, List<InventoryTransferLine> lines
});




}
/// @nodoc
class __$InventoryTransferCopyWithImpl<$Res>
    implements _$InventoryTransferCopyWith<$Res> {
  __$InventoryTransferCopyWithImpl(this._self, this._then);

  final _InventoryTransfer _self;
  final $Res Function(_InventoryTransfer) _then;

/// Create a copy of InventoryTransfer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? facilityId = null,Object? warehouseId = null,Object? warehouseToId = null,Object? serial = freezed,Object? status = null,Object? creatorId = null,Object? createdAt = null,Object? comment = freezed,Object? updaterId = null,Object? modifiedAt = null,Object? lines = null,}) {
  return _then(_InventoryTransfer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int,warehouseId: null == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int,warehouseToId: null == warehouseToId ? _self.warehouseToId : warehouseToId // ignore: cast_nullable_to_non_nullable
as int,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InventoryTransferStatus,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,updaterId: null == updaterId ? _self.updaterId : updaterId // ignore: cast_nullable_to_non_nullable
as int,modifiedAt: null == modifiedAt ? _self.modifiedAt : modifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<InventoryTransferLine>,
  ));
}


}

/// @nodoc
mixin _$InTransitView {

 int get facilityId; List<InTransitProductTotal> get products; List<InTransitLineItem> get lines;
/// Create a copy of InTransitView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InTransitViewCopyWith<InTransitView> get copyWith => _$InTransitViewCopyWithImpl<InTransitView>(this as InTransitView, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as InTransitView;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InTransitView&&(identical(other.facilityId, _this.facilityId) || other.facilityId == _this.facilityId)&&const DeepCollectionEquality().equals(other.products, _this.products)&&const DeepCollectionEquality().equals(other.lines, _this.lines));
}


@override
int get hashCode {
  final _this = this as InTransitView;
  return Object.hash(runtimeType,_this.facilityId,const DeepCollectionEquality().hash(_this.products),const DeepCollectionEquality().hash(_this.lines));
}

@override
String toString() {
  final _this = this as InTransitView;
  return 'InTransitView(facilityId: ${_this.facilityId}, products: ${_this.products}, lines: ${_this.lines})';
}


}

/// @nodoc
abstract mixin class $InTransitViewCopyWith<$Res>  {
  factory $InTransitViewCopyWith(InTransitView value, $Res Function(InTransitView) _then) = _$InTransitViewCopyWithImpl;
@useResult
$Res call({
 int facilityId, List<InTransitProductTotal> products, List<InTransitLineItem> lines
});




}
/// @nodoc
class _$InTransitViewCopyWithImpl<$Res>
    implements $InTransitViewCopyWith<$Res> {
  _$InTransitViewCopyWithImpl(this._self, this._then);

  final InTransitView _self;
  final $Res Function(InTransitView) _then;

/// Create a copy of InTransitView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? facilityId = null,Object? products = null,Object? lines = null,}) {
  return _then(InTransitView(
facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int,products: null == products ? _self.products : products // ignore: cast_nullable_to_non_nullable
as List<InTransitProductTotal>,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<InTransitLineItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [InTransitView].
extension InTransitViewPatterns on InTransitView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InTransitView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InTransitView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InTransitView value)  $default,){
final _that = this;
switch (_that) {
case _InTransitView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InTransitView value)?  $default,){
final _that = this;
switch (_that) {
case _InTransitView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int facilityId,  List<InTransitProductTotal> products,  List<InTransitLineItem> lines)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InTransitView() when $default != null:
return $default(_that.facilityId,_that.products,_that.lines);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int facilityId,  List<InTransitProductTotal> products,  List<InTransitLineItem> lines)  $default,) {final _that = this;
switch (_that) {
case _InTransitView():
return $default(_that.facilityId,_that.products,_that.lines);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int facilityId,  List<InTransitProductTotal> products,  List<InTransitLineItem> lines)?  $default,) {final _that = this;
switch (_that) {
case _InTransitView() when $default != null:
return $default(_that.facilityId,_that.products,_that.lines);case _:
  return null;

}
}

}

/// @nodoc


class _InTransitView implements InTransitView {
  const _InTransitView({required this.facilityId, required  List<InTransitProductTotal> products, required  List<InTransitLineItem> lines}): _products = products,_lines = lines;
  

@override final  int facilityId;
 final  List<InTransitProductTotal> _products;
@override List<InTransitProductTotal> get products {
  if (_products is EqualUnmodifiableListView) return _products;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_products);
}

 final  List<InTransitLineItem> _lines;
@override List<InTransitLineItem> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}


/// Create a copy of InTransitView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InTransitViewCopyWith<_InTransitView> get copyWith => __$InTransitViewCopyWithImpl<_InTransitView>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _InTransitView&&(identical(other.facilityId, facilityId) || other.facilityId == facilityId)&&const DeepCollectionEquality().equals(other.products, _products)&&const DeepCollectionEquality().equals(other.lines, _lines));
}


@override
int get hashCode {
    return Object.hash(runtimeType,facilityId,const DeepCollectionEquality().hash(_products),const DeepCollectionEquality().hash(_lines));
}

@override
String toString() {
    return 'InTransitView(facilityId: $facilityId, products: $products, lines: $lines)';
}


}

/// @nodoc
abstract mixin class _$InTransitViewCopyWith<$Res> implements $InTransitViewCopyWith<$Res> {
  factory _$InTransitViewCopyWith(_InTransitView value, $Res Function(_InTransitView) _then) = __$InTransitViewCopyWithImpl;
@override @useResult
$Res call({
 int facilityId, List<InTransitProductTotal> products, List<InTransitLineItem> lines
});




}
/// @nodoc
class __$InTransitViewCopyWithImpl<$Res>
    implements _$InTransitViewCopyWith<$Res> {
  __$InTransitViewCopyWithImpl(this._self, this._then);

  final _InTransitView _self;
  final $Res Function(_InTransitView) _then;

/// Create a copy of InTransitView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? facilityId = null,Object? products = null,Object? lines = null,}) {
  return _then(_InTransitView(
facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int,products: null == products ? _self._products : products // ignore: cast_nullable_to_non_nullable
as List<InTransitProductTotal>,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<InTransitLineItem>,
  ));
}


}

/// @nodoc
mixin _$InTransitProductTotal {

 int get productId; String? get productCode; String? get productName; Decimal get quantity;
/// Create a copy of InTransitProductTotal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InTransitProductTotalCopyWith<InTransitProductTotal> get copyWith => _$InTransitProductTotalCopyWithImpl<InTransitProductTotal>(this as InTransitProductTotal, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as InTransitProductTotal;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InTransitProductTotal&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.productCode, _this.productCode) || other.productCode == _this.productCode)&&(identical(other.productName, _this.productName) || other.productName == _this.productName)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity));
}


@override
int get hashCode {
  final _this = this as InTransitProductTotal;
  return Object.hash(runtimeType,_this.productId,_this.productCode,_this.productName,_this.quantity);
}

@override
String toString() {
  final _this = this as InTransitProductTotal;
  return 'InTransitProductTotal(productId: ${_this.productId}, productCode: ${_this.productCode}, productName: ${_this.productName}, quantity: ${_this.quantity})';
}


}

/// @nodoc
abstract mixin class $InTransitProductTotalCopyWith<$Res>  {
  factory $InTransitProductTotalCopyWith(InTransitProductTotal value, $Res Function(InTransitProductTotal) _then) = _$InTransitProductTotalCopyWithImpl;
@useResult
$Res call({
 int productId, String? productCode, String? productName, Decimal quantity
});




}
/// @nodoc
class _$InTransitProductTotalCopyWithImpl<$Res>
    implements $InTransitProductTotalCopyWith<$Res> {
  _$InTransitProductTotalCopyWithImpl(this._self, this._then);

  final InTransitProductTotal _self;
  final $Res Function(InTransitProductTotal) _then;

/// Create a copy of InTransitProductTotal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? productCode = freezed,Object? productName = freezed,Object? quantity = null,}) {
  return _then(InTransitProductTotal(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,productCode: freezed == productCode ? _self.productCode : productCode // ignore: cast_nullable_to_non_nullable
as String?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}

}


/// Adds pattern-matching-related methods to [InTransitProductTotal].
extension InTransitProductTotalPatterns on InTransitProductTotal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InTransitProductTotal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InTransitProductTotal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InTransitProductTotal value)  $default,){
final _that = this;
switch (_that) {
case _InTransitProductTotal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InTransitProductTotal value)?  $default,){
final _that = this;
switch (_that) {
case _InTransitProductTotal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int productId,  String? productCode,  String? productName,  Decimal quantity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InTransitProductTotal() when $default != null:
return $default(_that.productId,_that.productCode,_that.productName,_that.quantity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int productId,  String? productCode,  String? productName,  Decimal quantity)  $default,) {final _that = this;
switch (_that) {
case _InTransitProductTotal():
return $default(_that.productId,_that.productCode,_that.productName,_that.quantity);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int productId,  String? productCode,  String? productName,  Decimal quantity)?  $default,) {final _that = this;
switch (_that) {
case _InTransitProductTotal() when $default != null:
return $default(_that.productId,_that.productCode,_that.productName,_that.quantity);case _:
  return null;

}
}

}

/// @nodoc


class _InTransitProductTotal implements InTransitProductTotal {
  const _InTransitProductTotal({required this.productId, this.productCode, this.productName, required this.quantity});
  

@override final  int productId;
@override final  String? productCode;
@override final  String? productName;
@override final  Decimal quantity;

/// Create a copy of InTransitProductTotal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InTransitProductTotalCopyWith<_InTransitProductTotal> get copyWith => __$InTransitProductTotalCopyWithImpl<_InTransitProductTotal>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _InTransitProductTotal&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productCode, productCode) || other.productCode == productCode)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.quantity, quantity) || other.quantity == quantity));
}


@override
int get hashCode {
    return Object.hash(runtimeType,productId,productCode,productName,quantity);
}

@override
String toString() {
    return 'InTransitProductTotal(productId: $productId, productCode: $productCode, productName: $productName, quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class _$InTransitProductTotalCopyWith<$Res> implements $InTransitProductTotalCopyWith<$Res> {
  factory _$InTransitProductTotalCopyWith(_InTransitProductTotal value, $Res Function(_InTransitProductTotal) _then) = __$InTransitProductTotalCopyWithImpl;
@override @useResult
$Res call({
 int productId, String? productCode, String? productName, Decimal quantity
});




}
/// @nodoc
class __$InTransitProductTotalCopyWithImpl<$Res>
    implements _$InTransitProductTotalCopyWith<$Res> {
  __$InTransitProductTotalCopyWithImpl(this._self, this._then);

  final _InTransitProductTotal _self;
  final $Res Function(_InTransitProductTotal) _then;

/// Create a copy of InTransitProductTotal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? productCode = freezed,Object? productName = freezed,Object? quantity = null,}) {
  return _then(_InTransitProductTotal(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,productCode: freezed == productCode ? _self.productCode : productCode // ignore: cast_nullable_to_non_nullable
as String?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}


}

/// @nodoc
mixin _$InTransitLineItem {

 int get transferId; int? get serial; int get warehouseId; int get warehouseToId; int get lineId; int get productId; String? get productCode; String? get productName; Decimal get quantityOutstanding;/// Server-joined names (mbe-api#330), null when the row is gone.
 String? get warehouseName; String? get warehouseToName;
/// Create a copy of InTransitLineItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InTransitLineItemCopyWith<InTransitLineItem> get copyWith => _$InTransitLineItemCopyWithImpl<InTransitLineItem>(this as InTransitLineItem, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as InTransitLineItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InTransitLineItem&&(identical(other.transferId, _this.transferId) || other.transferId == _this.transferId)&&(identical(other.serial, _this.serial) || other.serial == _this.serial)&&(identical(other.warehouseId, _this.warehouseId) || other.warehouseId == _this.warehouseId)&&(identical(other.warehouseToId, _this.warehouseToId) || other.warehouseToId == _this.warehouseToId)&&(identical(other.lineId, _this.lineId) || other.lineId == _this.lineId)&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.productCode, _this.productCode) || other.productCode == _this.productCode)&&(identical(other.productName, _this.productName) || other.productName == _this.productName)&&(identical(other.quantityOutstanding, _this.quantityOutstanding) || other.quantityOutstanding == _this.quantityOutstanding)&&(identical(other.warehouseName, _this.warehouseName) || other.warehouseName == _this.warehouseName)&&(identical(other.warehouseToName, _this.warehouseToName) || other.warehouseToName == _this.warehouseToName));
}


@override
int get hashCode {
  final _this = this as InTransitLineItem;
  return Object.hash(runtimeType,_this.transferId,_this.serial,_this.warehouseId,_this.warehouseToId,_this.lineId,_this.productId,_this.productCode,_this.productName,_this.quantityOutstanding,_this.warehouseName,_this.warehouseToName);
}

@override
String toString() {
  final _this = this as InTransitLineItem;
  return 'InTransitLineItem(transferId: ${_this.transferId}, serial: ${_this.serial}, warehouseId: ${_this.warehouseId}, warehouseToId: ${_this.warehouseToId}, lineId: ${_this.lineId}, productId: ${_this.productId}, productCode: ${_this.productCode}, productName: ${_this.productName}, quantityOutstanding: ${_this.quantityOutstanding}, warehouseName: ${_this.warehouseName}, warehouseToName: ${_this.warehouseToName})';
}


}

/// @nodoc
abstract mixin class $InTransitLineItemCopyWith<$Res>  {
  factory $InTransitLineItemCopyWith(InTransitLineItem value, $Res Function(InTransitLineItem) _then) = _$InTransitLineItemCopyWithImpl;
@useResult
$Res call({
 int transferId, int? serial, int warehouseId, int warehouseToId, int lineId, int productId, String? productCode, String? productName, Decimal quantityOutstanding, String? warehouseName, String? warehouseToName
});




}
/// @nodoc
class _$InTransitLineItemCopyWithImpl<$Res>
    implements $InTransitLineItemCopyWith<$Res> {
  _$InTransitLineItemCopyWithImpl(this._self, this._then);

  final InTransitLineItem _self;
  final $Res Function(InTransitLineItem) _then;

/// Create a copy of InTransitLineItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? transferId = null,Object? serial = freezed,Object? warehouseId = null,Object? warehouseToId = null,Object? lineId = null,Object? productId = null,Object? productCode = freezed,Object? productName = freezed,Object? quantityOutstanding = null,Object? warehouseName = freezed,Object? warehouseToName = freezed,}) {
  return _then(InTransitLineItem(
transferId: null == transferId ? _self.transferId : transferId // ignore: cast_nullable_to_non_nullable
as int,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as int?,warehouseId: null == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int,warehouseToId: null == warehouseToId ? _self.warehouseToId : warehouseToId // ignore: cast_nullable_to_non_nullable
as int,lineId: null == lineId ? _self.lineId : lineId // ignore: cast_nullable_to_non_nullable
as int,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,productCode: freezed == productCode ? _self.productCode : productCode // ignore: cast_nullable_to_non_nullable
as String?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,quantityOutstanding: null == quantityOutstanding ? _self.quantityOutstanding : quantityOutstanding // ignore: cast_nullable_to_non_nullable
as Decimal,warehouseName: freezed == warehouseName ? _self.warehouseName : warehouseName // ignore: cast_nullable_to_non_nullable
as String?,warehouseToName: freezed == warehouseToName ? _self.warehouseToName : warehouseToName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [InTransitLineItem].
extension InTransitLineItemPatterns on InTransitLineItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InTransitLineItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InTransitLineItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InTransitLineItem value)  $default,){
final _that = this;
switch (_that) {
case _InTransitLineItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InTransitLineItem value)?  $default,){
final _that = this;
switch (_that) {
case _InTransitLineItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int transferId,  int? serial,  int warehouseId,  int warehouseToId,  int lineId,  int productId,  String? productCode,  String? productName,  Decimal quantityOutstanding,  String? warehouseName,  String? warehouseToName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InTransitLineItem() when $default != null:
return $default(_that.transferId,_that.serial,_that.warehouseId,_that.warehouseToId,_that.lineId,_that.productId,_that.productCode,_that.productName,_that.quantityOutstanding,_that.warehouseName,_that.warehouseToName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int transferId,  int? serial,  int warehouseId,  int warehouseToId,  int lineId,  int productId,  String? productCode,  String? productName,  Decimal quantityOutstanding,  String? warehouseName,  String? warehouseToName)  $default,) {final _that = this;
switch (_that) {
case _InTransitLineItem():
return $default(_that.transferId,_that.serial,_that.warehouseId,_that.warehouseToId,_that.lineId,_that.productId,_that.productCode,_that.productName,_that.quantityOutstanding,_that.warehouseName,_that.warehouseToName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int transferId,  int? serial,  int warehouseId,  int warehouseToId,  int lineId,  int productId,  String? productCode,  String? productName,  Decimal quantityOutstanding,  String? warehouseName,  String? warehouseToName)?  $default,) {final _that = this;
switch (_that) {
case _InTransitLineItem() when $default != null:
return $default(_that.transferId,_that.serial,_that.warehouseId,_that.warehouseToId,_that.lineId,_that.productId,_that.productCode,_that.productName,_that.quantityOutstanding,_that.warehouseName,_that.warehouseToName);case _:
  return null;

}
}

}

/// @nodoc


class _InTransitLineItem implements InTransitLineItem {
  const _InTransitLineItem({required this.transferId, this.serial, required this.warehouseId, required this.warehouseToId, required this.lineId, required this.productId, this.productCode, this.productName, required this.quantityOutstanding, this.warehouseName, this.warehouseToName});
  

@override final  int transferId;
@override final  int? serial;
@override final  int warehouseId;
@override final  int warehouseToId;
@override final  int lineId;
@override final  int productId;
@override final  String? productCode;
@override final  String? productName;
@override final  Decimal quantityOutstanding;
/// Server-joined names (mbe-api#330), null when the row is gone.
@override final  String? warehouseName;
@override final  String? warehouseToName;

/// Create a copy of InTransitLineItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InTransitLineItemCopyWith<_InTransitLineItem> get copyWith => __$InTransitLineItemCopyWithImpl<_InTransitLineItem>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _InTransitLineItem&&(identical(other.transferId, transferId) || other.transferId == transferId)&&(identical(other.serial, serial) || other.serial == serial)&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.warehouseToId, warehouseToId) || other.warehouseToId == warehouseToId)&&(identical(other.lineId, lineId) || other.lineId == lineId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productCode, productCode) || other.productCode == productCode)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.quantityOutstanding, quantityOutstanding) || other.quantityOutstanding == quantityOutstanding)&&(identical(other.warehouseName, warehouseName) || other.warehouseName == warehouseName)&&(identical(other.warehouseToName, warehouseToName) || other.warehouseToName == warehouseToName));
}


@override
int get hashCode {
    return Object.hash(runtimeType,transferId,serial,warehouseId,warehouseToId,lineId,productId,productCode,productName,quantityOutstanding,warehouseName,warehouseToName);
}

@override
String toString() {
    return 'InTransitLineItem(transferId: $transferId, serial: $serial, warehouseId: $warehouseId, warehouseToId: $warehouseToId, lineId: $lineId, productId: $productId, productCode: $productCode, productName: $productName, quantityOutstanding: $quantityOutstanding, warehouseName: $warehouseName, warehouseToName: $warehouseToName)';
}


}

/// @nodoc
abstract mixin class _$InTransitLineItemCopyWith<$Res> implements $InTransitLineItemCopyWith<$Res> {
  factory _$InTransitLineItemCopyWith(_InTransitLineItem value, $Res Function(_InTransitLineItem) _then) = __$InTransitLineItemCopyWithImpl;
@override @useResult
$Res call({
 int transferId, int? serial, int warehouseId, int warehouseToId, int lineId, int productId, String? productCode, String? productName, Decimal quantityOutstanding, String? warehouseName, String? warehouseToName
});




}
/// @nodoc
class __$InTransitLineItemCopyWithImpl<$Res>
    implements _$InTransitLineItemCopyWith<$Res> {
  __$InTransitLineItemCopyWithImpl(this._self, this._then);

  final _InTransitLineItem _self;
  final $Res Function(_InTransitLineItem) _then;

/// Create a copy of InTransitLineItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? transferId = null,Object? serial = freezed,Object? warehouseId = null,Object? warehouseToId = null,Object? lineId = null,Object? productId = null,Object? productCode = freezed,Object? productName = freezed,Object? quantityOutstanding = null,Object? warehouseName = freezed,Object? warehouseToName = freezed,}) {
  return _then(_InTransitLineItem(
transferId: null == transferId ? _self.transferId : transferId // ignore: cast_nullable_to_non_nullable
as int,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as int?,warehouseId: null == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int,warehouseToId: null == warehouseToId ? _self.warehouseToId : warehouseToId // ignore: cast_nullable_to_non_nullable
as int,lineId: null == lineId ? _self.lineId : lineId // ignore: cast_nullable_to_non_nullable
as int,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,productCode: freezed == productCode ? _self.productCode : productCode // ignore: cast_nullable_to_non_nullable
as String?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,quantityOutstanding: null == quantityOutstanding ? _self.quantityOutstanding : quantityOutstanding // ignore: cast_nullable_to_non_nullable
as Decimal,warehouseName: freezed == warehouseName ? _self.warehouseName : warehouseName // ignore: cast_nullable_to_non_nullable
as String?,warehouseToName: freezed == warehouseToName ? _self.warehouseToName : warehouseToName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
