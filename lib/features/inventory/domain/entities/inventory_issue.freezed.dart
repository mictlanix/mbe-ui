// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inventory_issue.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$InventoryIssueSummary {

 int get id; int get facilityId; int get warehouseId;/// Null until the issue is confirmed. The "Borrador #{id}" text for a
/// draft is built by the presentation layer from l10n.
 int? get serial; InventoryDocumentStatus get status; int get creatorId; DateTime get createdAt;/// Server-joined names (mbe-api#327–#330), null when the row is gone.
/// The name cells fall back to a per-id lookup when one is null.
 String? get warehouseName; String? get facilityName; String? get creatorName;
/// Create a copy of InventoryIssueSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InventoryIssueSummaryCopyWith<InventoryIssueSummary> get copyWith => _$InventoryIssueSummaryCopyWithImpl<InventoryIssueSummary>(this as InventoryIssueSummary, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as InventoryIssueSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InventoryIssueSummary&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.facilityId, _this.facilityId) || other.facilityId == _this.facilityId)&&(identical(other.warehouseId, _this.warehouseId) || other.warehouseId == _this.warehouseId)&&(identical(other.serial, _this.serial) || other.serial == _this.serial)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.creatorId, _this.creatorId) || other.creatorId == _this.creatorId)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.warehouseName, _this.warehouseName) || other.warehouseName == _this.warehouseName)&&(identical(other.facilityName, _this.facilityName) || other.facilityName == _this.facilityName)&&(identical(other.creatorName, _this.creatorName) || other.creatorName == _this.creatorName));
}


@override
int get hashCode {
  final _this = this as InventoryIssueSummary;
  return Object.hash(runtimeType,_this.id,_this.facilityId,_this.warehouseId,_this.serial,_this.status,_this.creatorId,_this.createdAt,_this.warehouseName,_this.facilityName,_this.creatorName);
}

@override
String toString() {
  final _this = this as InventoryIssueSummary;
  return 'InventoryIssueSummary(id: ${_this.id}, facilityId: ${_this.facilityId}, warehouseId: ${_this.warehouseId}, serial: ${_this.serial}, status: ${_this.status}, creatorId: ${_this.creatorId}, createdAt: ${_this.createdAt}, warehouseName: ${_this.warehouseName}, facilityName: ${_this.facilityName}, creatorName: ${_this.creatorName})';
}


}

/// @nodoc
abstract mixin class $InventoryIssueSummaryCopyWith<$Res>  {
  factory $InventoryIssueSummaryCopyWith(InventoryIssueSummary value, $Res Function(InventoryIssueSummary) _then) = _$InventoryIssueSummaryCopyWithImpl;
@useResult
$Res call({
 int id, int facilityId, int warehouseId, int? serial, InventoryDocumentStatus status, int creatorId, DateTime createdAt, String? warehouseName, String? facilityName, String? creatorName
});




}
/// @nodoc
class _$InventoryIssueSummaryCopyWithImpl<$Res>
    implements $InventoryIssueSummaryCopyWith<$Res> {
  _$InventoryIssueSummaryCopyWithImpl(this._self, this._then);

  final InventoryIssueSummary _self;
  final $Res Function(InventoryIssueSummary) _then;

/// Create a copy of InventoryIssueSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? facilityId = null,Object? warehouseId = null,Object? serial = freezed,Object? status = null,Object? creatorId = null,Object? createdAt = null,Object? warehouseName = freezed,Object? facilityName = freezed,Object? creatorName = freezed,}) {
  return _then(InventoryIssueSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int,warehouseId: null == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InventoryDocumentStatus,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,warehouseName: freezed == warehouseName ? _self.warehouseName : warehouseName // ignore: cast_nullable_to_non_nullable
as String?,facilityName: freezed == facilityName ? _self.facilityName : facilityName // ignore: cast_nullable_to_non_nullable
as String?,creatorName: freezed == creatorName ? _self.creatorName : creatorName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [InventoryIssueSummary].
extension InventoryIssueSummaryPatterns on InventoryIssueSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InventoryIssueSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InventoryIssueSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InventoryIssueSummary value)  $default,){
final _that = this;
switch (_that) {
case _InventoryIssueSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InventoryIssueSummary value)?  $default,){
final _that = this;
switch (_that) {
case _InventoryIssueSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int facilityId,  int warehouseId,  int? serial,  InventoryDocumentStatus status,  int creatorId,  DateTime createdAt,  String? warehouseName,  String? facilityName,  String? creatorName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InventoryIssueSummary() when $default != null:
return $default(_that.id,_that.facilityId,_that.warehouseId,_that.serial,_that.status,_that.creatorId,_that.createdAt,_that.warehouseName,_that.facilityName,_that.creatorName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int facilityId,  int warehouseId,  int? serial,  InventoryDocumentStatus status,  int creatorId,  DateTime createdAt,  String? warehouseName,  String? facilityName,  String? creatorName)  $default,) {final _that = this;
switch (_that) {
case _InventoryIssueSummary():
return $default(_that.id,_that.facilityId,_that.warehouseId,_that.serial,_that.status,_that.creatorId,_that.createdAt,_that.warehouseName,_that.facilityName,_that.creatorName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int facilityId,  int warehouseId,  int? serial,  InventoryDocumentStatus status,  int creatorId,  DateTime createdAt,  String? warehouseName,  String? facilityName,  String? creatorName)?  $default,) {final _that = this;
switch (_that) {
case _InventoryIssueSummary() when $default != null:
return $default(_that.id,_that.facilityId,_that.warehouseId,_that.serial,_that.status,_that.creatorId,_that.createdAt,_that.warehouseName,_that.facilityName,_that.creatorName);case _:
  return null;

}
}

}

/// @nodoc


class _InventoryIssueSummary implements InventoryIssueSummary {
  const _InventoryIssueSummary({required this.id, required this.facilityId, required this.warehouseId, this.serial, required this.status, required this.creatorId, required this.createdAt, this.warehouseName, this.facilityName, this.creatorName});
  

@override final  int id;
@override final  int facilityId;
@override final  int warehouseId;
/// Null until the issue is confirmed. The "Borrador #{id}" text for a
/// draft is built by the presentation layer from l10n.
@override final  int? serial;
@override final  InventoryDocumentStatus status;
@override final  int creatorId;
@override final  DateTime createdAt;
/// Server-joined names (mbe-api#327–#330), null when the row is gone.
/// The name cells fall back to a per-id lookup when one is null.
@override final  String? warehouseName;
@override final  String? facilityName;
@override final  String? creatorName;

/// Create a copy of InventoryIssueSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InventoryIssueSummaryCopyWith<_InventoryIssueSummary> get copyWith => __$InventoryIssueSummaryCopyWithImpl<_InventoryIssueSummary>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _InventoryIssueSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.facilityId, facilityId) || other.facilityId == facilityId)&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.serial, serial) || other.serial == serial)&&(identical(other.status, status) || other.status == status)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.warehouseName, warehouseName) || other.warehouseName == warehouseName)&&(identical(other.facilityName, facilityName) || other.facilityName == facilityName)&&(identical(other.creatorName, creatorName) || other.creatorName == creatorName));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,facilityId,warehouseId,serial,status,creatorId,createdAt,warehouseName,facilityName,creatorName);
}

@override
String toString() {
    return 'InventoryIssueSummary(id: $id, facilityId: $facilityId, warehouseId: $warehouseId, serial: $serial, status: $status, creatorId: $creatorId, createdAt: $createdAt, warehouseName: $warehouseName, facilityName: $facilityName, creatorName: $creatorName)';
}


}

/// @nodoc
abstract mixin class _$InventoryIssueSummaryCopyWith<$Res> implements $InventoryIssueSummaryCopyWith<$Res> {
  factory _$InventoryIssueSummaryCopyWith(_InventoryIssueSummary value, $Res Function(_InventoryIssueSummary) _then) = __$InventoryIssueSummaryCopyWithImpl;
@override @useResult
$Res call({
 int id, int facilityId, int warehouseId, int? serial, InventoryDocumentStatus status, int creatorId, DateTime createdAt, String? warehouseName, String? facilityName, String? creatorName
});




}
/// @nodoc
class __$InventoryIssueSummaryCopyWithImpl<$Res>
    implements _$InventoryIssueSummaryCopyWith<$Res> {
  __$InventoryIssueSummaryCopyWithImpl(this._self, this._then);

  final _InventoryIssueSummary _self;
  final $Res Function(_InventoryIssueSummary) _then;

/// Create a copy of InventoryIssueSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? facilityId = null,Object? warehouseId = null,Object? serial = freezed,Object? status = null,Object? creatorId = null,Object? createdAt = null,Object? warehouseName = freezed,Object? facilityName = freezed,Object? creatorName = freezed,}) {
  return _then(_InventoryIssueSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int,warehouseId: null == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InventoryDocumentStatus,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,warehouseName: freezed == warehouseName ? _self.warehouseName : warehouseName // ignore: cast_nullable_to_non_nullable
as String?,facilityName: freezed == facilityName ? _self.facilityName : facilityName // ignore: cast_nullable_to_non_nullable
as String?,creatorName: freezed == creatorName ? _self.creatorName : creatorName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$InventoryIssueLine {

 int get id; int get productId;/// Snapshots from when the line was added.
 String? get productCode; String? get productName; Decimal get quantity;
/// Create a copy of InventoryIssueLine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InventoryIssueLineCopyWith<InventoryIssueLine> get copyWith => _$InventoryIssueLineCopyWithImpl<InventoryIssueLine>(this as InventoryIssueLine, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as InventoryIssueLine;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InventoryIssueLine&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.productCode, _this.productCode) || other.productCode == _this.productCode)&&(identical(other.productName, _this.productName) || other.productName == _this.productName)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity));
}


@override
int get hashCode {
  final _this = this as InventoryIssueLine;
  return Object.hash(runtimeType,_this.id,_this.productId,_this.productCode,_this.productName,_this.quantity);
}

@override
String toString() {
  final _this = this as InventoryIssueLine;
  return 'InventoryIssueLine(id: ${_this.id}, productId: ${_this.productId}, productCode: ${_this.productCode}, productName: ${_this.productName}, quantity: ${_this.quantity})';
}


}

/// @nodoc
abstract mixin class $InventoryIssueLineCopyWith<$Res>  {
  factory $InventoryIssueLineCopyWith(InventoryIssueLine value, $Res Function(InventoryIssueLine) _then) = _$InventoryIssueLineCopyWithImpl;
@useResult
$Res call({
 int id, int productId, String? productCode, String? productName, Decimal quantity
});




}
/// @nodoc
class _$InventoryIssueLineCopyWithImpl<$Res>
    implements $InventoryIssueLineCopyWith<$Res> {
  _$InventoryIssueLineCopyWithImpl(this._self, this._then);

  final InventoryIssueLine _self;
  final $Res Function(InventoryIssueLine) _then;

/// Create a copy of InventoryIssueLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? productId = null,Object? productCode = freezed,Object? productName = freezed,Object? quantity = null,}) {
  return _then(InventoryIssueLine(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,productCode: freezed == productCode ? _self.productCode : productCode // ignore: cast_nullable_to_non_nullable
as String?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}

}


/// Adds pattern-matching-related methods to [InventoryIssueLine].
extension InventoryIssueLinePatterns on InventoryIssueLine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InventoryIssueLine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InventoryIssueLine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InventoryIssueLine value)  $default,){
final _that = this;
switch (_that) {
case _InventoryIssueLine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InventoryIssueLine value)?  $default,){
final _that = this;
switch (_that) {
case _InventoryIssueLine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int productId,  String? productCode,  String? productName,  Decimal quantity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InventoryIssueLine() when $default != null:
return $default(_that.id,_that.productId,_that.productCode,_that.productName,_that.quantity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int productId,  String? productCode,  String? productName,  Decimal quantity)  $default,) {final _that = this;
switch (_that) {
case _InventoryIssueLine():
return $default(_that.id,_that.productId,_that.productCode,_that.productName,_that.quantity);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int productId,  String? productCode,  String? productName,  Decimal quantity)?  $default,) {final _that = this;
switch (_that) {
case _InventoryIssueLine() when $default != null:
return $default(_that.id,_that.productId,_that.productCode,_that.productName,_that.quantity);case _:
  return null;

}
}

}

/// @nodoc


class _InventoryIssueLine implements InventoryIssueLine {
  const _InventoryIssueLine({required this.id, required this.productId, this.productCode, this.productName, required this.quantity});
  

@override final  int id;
@override final  int productId;
/// Snapshots from when the line was added.
@override final  String? productCode;
@override final  String? productName;
@override final  Decimal quantity;

/// Create a copy of InventoryIssueLine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InventoryIssueLineCopyWith<_InventoryIssueLine> get copyWith => __$InventoryIssueLineCopyWithImpl<_InventoryIssueLine>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _InventoryIssueLine&&(identical(other.id, id) || other.id == id)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productCode, productCode) || other.productCode == productCode)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.quantity, quantity) || other.quantity == quantity));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,productId,productCode,productName,quantity);
}

@override
String toString() {
    return 'InventoryIssueLine(id: $id, productId: $productId, productCode: $productCode, productName: $productName, quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class _$InventoryIssueLineCopyWith<$Res> implements $InventoryIssueLineCopyWith<$Res> {
  factory _$InventoryIssueLineCopyWith(_InventoryIssueLine value, $Res Function(_InventoryIssueLine) _then) = __$InventoryIssueLineCopyWithImpl;
@override @useResult
$Res call({
 int id, int productId, String? productCode, String? productName, Decimal quantity
});




}
/// @nodoc
class __$InventoryIssueLineCopyWithImpl<$Res>
    implements _$InventoryIssueLineCopyWith<$Res> {
  __$InventoryIssueLineCopyWithImpl(this._self, this._then);

  final _InventoryIssueLine _self;
  final $Res Function(_InventoryIssueLine) _then;

/// Create a copy of InventoryIssueLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? productId = null,Object? productCode = freezed,Object? productName = freezed,Object? quantity = null,}) {
  return _then(_InventoryIssueLine(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,productCode: freezed == productCode ? _self.productCode : productCode // ignore: cast_nullable_to_non_nullable
as String?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}


}

/// @nodoc
mixin _$InventoryIssue {

 int get id; int get facilityId; int get warehouseId; int? get serial; InventoryDocumentStatus get status; int get creatorId; DateTime get createdAt;/// Legacy link only; shown read-only when set (research R7).
 int? get supplierReturnId;/// The reason. An empty string is treated as no note by the mapper.
 String? get comment; int get updaterId; DateTime get modifiedAt; List<InventoryIssueLine> get lines;
/// Create a copy of InventoryIssue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InventoryIssueCopyWith<InventoryIssue> get copyWith => _$InventoryIssueCopyWithImpl<InventoryIssue>(this as InventoryIssue, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as InventoryIssue;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InventoryIssue&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.facilityId, _this.facilityId) || other.facilityId == _this.facilityId)&&(identical(other.warehouseId, _this.warehouseId) || other.warehouseId == _this.warehouseId)&&(identical(other.serial, _this.serial) || other.serial == _this.serial)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.creatorId, _this.creatorId) || other.creatorId == _this.creatorId)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.supplierReturnId, _this.supplierReturnId) || other.supplierReturnId == _this.supplierReturnId)&&(identical(other.comment, _this.comment) || other.comment == _this.comment)&&(identical(other.updaterId, _this.updaterId) || other.updaterId == _this.updaterId)&&(identical(other.modifiedAt, _this.modifiedAt) || other.modifiedAt == _this.modifiedAt)&&const DeepCollectionEquality().equals(other.lines, _this.lines));
}


@override
int get hashCode {
  final _this = this as InventoryIssue;
  return Object.hash(runtimeType,_this.id,_this.facilityId,_this.warehouseId,_this.serial,_this.status,_this.creatorId,_this.createdAt,_this.supplierReturnId,_this.comment,_this.updaterId,_this.modifiedAt,const DeepCollectionEquality().hash(_this.lines));
}

@override
String toString() {
  final _this = this as InventoryIssue;
  return 'InventoryIssue(id: ${_this.id}, facilityId: ${_this.facilityId}, warehouseId: ${_this.warehouseId}, serial: ${_this.serial}, status: ${_this.status}, creatorId: ${_this.creatorId}, createdAt: ${_this.createdAt}, supplierReturnId: ${_this.supplierReturnId}, comment: ${_this.comment}, updaterId: ${_this.updaterId}, modifiedAt: ${_this.modifiedAt}, lines: ${_this.lines})';
}


}

/// @nodoc
abstract mixin class $InventoryIssueCopyWith<$Res>  {
  factory $InventoryIssueCopyWith(InventoryIssue value, $Res Function(InventoryIssue) _then) = _$InventoryIssueCopyWithImpl;
@useResult
$Res call({
 int id, int facilityId, int warehouseId, int? serial, InventoryDocumentStatus status, int creatorId, DateTime createdAt, int? supplierReturnId, String? comment, int updaterId, DateTime modifiedAt, List<InventoryIssueLine> lines
});




}
/// @nodoc
class _$InventoryIssueCopyWithImpl<$Res>
    implements $InventoryIssueCopyWith<$Res> {
  _$InventoryIssueCopyWithImpl(this._self, this._then);

  final InventoryIssue _self;
  final $Res Function(InventoryIssue) _then;

/// Create a copy of InventoryIssue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? facilityId = null,Object? warehouseId = null,Object? serial = freezed,Object? status = null,Object? creatorId = null,Object? createdAt = null,Object? supplierReturnId = freezed,Object? comment = freezed,Object? updaterId = null,Object? modifiedAt = null,Object? lines = null,}) {
  return _then(InventoryIssue(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int,warehouseId: null == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InventoryDocumentStatus,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,supplierReturnId: freezed == supplierReturnId ? _self.supplierReturnId : supplierReturnId // ignore: cast_nullable_to_non_nullable
as int?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,updaterId: null == updaterId ? _self.updaterId : updaterId // ignore: cast_nullable_to_non_nullable
as int,modifiedAt: null == modifiedAt ? _self.modifiedAt : modifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<InventoryIssueLine>,
  ));
}

}


/// Adds pattern-matching-related methods to [InventoryIssue].
extension InventoryIssuePatterns on InventoryIssue {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InventoryIssue value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InventoryIssue() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InventoryIssue value)  $default,){
final _that = this;
switch (_that) {
case _InventoryIssue():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InventoryIssue value)?  $default,){
final _that = this;
switch (_that) {
case _InventoryIssue() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int facilityId,  int warehouseId,  int? serial,  InventoryDocumentStatus status,  int creatorId,  DateTime createdAt,  int? supplierReturnId,  String? comment,  int updaterId,  DateTime modifiedAt,  List<InventoryIssueLine> lines)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InventoryIssue() when $default != null:
return $default(_that.id,_that.facilityId,_that.warehouseId,_that.serial,_that.status,_that.creatorId,_that.createdAt,_that.supplierReturnId,_that.comment,_that.updaterId,_that.modifiedAt,_that.lines);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int facilityId,  int warehouseId,  int? serial,  InventoryDocumentStatus status,  int creatorId,  DateTime createdAt,  int? supplierReturnId,  String? comment,  int updaterId,  DateTime modifiedAt,  List<InventoryIssueLine> lines)  $default,) {final _that = this;
switch (_that) {
case _InventoryIssue():
return $default(_that.id,_that.facilityId,_that.warehouseId,_that.serial,_that.status,_that.creatorId,_that.createdAt,_that.supplierReturnId,_that.comment,_that.updaterId,_that.modifiedAt,_that.lines);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int facilityId,  int warehouseId,  int? serial,  InventoryDocumentStatus status,  int creatorId,  DateTime createdAt,  int? supplierReturnId,  String? comment,  int updaterId,  DateTime modifiedAt,  List<InventoryIssueLine> lines)?  $default,) {final _that = this;
switch (_that) {
case _InventoryIssue() when $default != null:
return $default(_that.id,_that.facilityId,_that.warehouseId,_that.serial,_that.status,_that.creatorId,_that.createdAt,_that.supplierReturnId,_that.comment,_that.updaterId,_that.modifiedAt,_that.lines);case _:
  return null;

}
}

}

/// @nodoc


class _InventoryIssue extends InventoryIssue {
  const _InventoryIssue({required this.id, required this.facilityId, required this.warehouseId, this.serial, required this.status, required this.creatorId, required this.createdAt, this.supplierReturnId, this.comment, required this.updaterId, required this.modifiedAt, required  List<InventoryIssueLine> lines}): _lines = lines,super._();
  

@override final  int id;
@override final  int facilityId;
@override final  int warehouseId;
@override final  int? serial;
@override final  InventoryDocumentStatus status;
@override final  int creatorId;
@override final  DateTime createdAt;
/// Legacy link only; shown read-only when set (research R7).
@override final  int? supplierReturnId;
/// The reason. An empty string is treated as no note by the mapper.
@override final  String? comment;
@override final  int updaterId;
@override final  DateTime modifiedAt;
 final  List<InventoryIssueLine> _lines;
@override List<InventoryIssueLine> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}


/// Create a copy of InventoryIssue
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InventoryIssueCopyWith<_InventoryIssue> get copyWith => __$InventoryIssueCopyWithImpl<_InventoryIssue>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _InventoryIssue&&(identical(other.id, id) || other.id == id)&&(identical(other.facilityId, facilityId) || other.facilityId == facilityId)&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.serial, serial) || other.serial == serial)&&(identical(other.status, status) || other.status == status)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.supplierReturnId, supplierReturnId) || other.supplierReturnId == supplierReturnId)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.updaterId, updaterId) || other.updaterId == updaterId)&&(identical(other.modifiedAt, modifiedAt) || other.modifiedAt == modifiedAt)&&const DeepCollectionEquality().equals(other.lines, _lines));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,facilityId,warehouseId,serial,status,creatorId,createdAt,supplierReturnId,comment,updaterId,modifiedAt,const DeepCollectionEquality().hash(_lines));
}

@override
String toString() {
    return 'InventoryIssue(id: $id, facilityId: $facilityId, warehouseId: $warehouseId, serial: $serial, status: $status, creatorId: $creatorId, createdAt: $createdAt, supplierReturnId: $supplierReturnId, comment: $comment, updaterId: $updaterId, modifiedAt: $modifiedAt, lines: $lines)';
}


}

/// @nodoc
abstract mixin class _$InventoryIssueCopyWith<$Res> implements $InventoryIssueCopyWith<$Res> {
  factory _$InventoryIssueCopyWith(_InventoryIssue value, $Res Function(_InventoryIssue) _then) = __$InventoryIssueCopyWithImpl;
@override @useResult
$Res call({
 int id, int facilityId, int warehouseId, int? serial, InventoryDocumentStatus status, int creatorId, DateTime createdAt, int? supplierReturnId, String? comment, int updaterId, DateTime modifiedAt, List<InventoryIssueLine> lines
});




}
/// @nodoc
class __$InventoryIssueCopyWithImpl<$Res>
    implements _$InventoryIssueCopyWith<$Res> {
  __$InventoryIssueCopyWithImpl(this._self, this._then);

  final _InventoryIssue _self;
  final $Res Function(_InventoryIssue) _then;

/// Create a copy of InventoryIssue
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? facilityId = null,Object? warehouseId = null,Object? serial = freezed,Object? status = null,Object? creatorId = null,Object? createdAt = null,Object? supplierReturnId = freezed,Object? comment = freezed,Object? updaterId = null,Object? modifiedAt = null,Object? lines = null,}) {
  return _then(_InventoryIssue(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int,warehouseId: null == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InventoryDocumentStatus,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,supplierReturnId: freezed == supplierReturnId ? _self.supplierReturnId : supplierReturnId // ignore: cast_nullable_to_non_nullable
as int?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,updaterId: null == updaterId ? _self.updaterId : updaterId // ignore: cast_nullable_to_non_nullable
as int,modifiedAt: null == modifiedAt ? _self.modifiedAt : modifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<InventoryIssueLine>,
  ));
}


}

// dart format on
