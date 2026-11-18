// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stock.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StockRow {

 int get productId;/// Empty when the server sends none.
 String get productCode; String get productName; int get warehouseId; Decimal get onHand; Decimal get reserved; Decimal get available; Decimal get incoming;
/// Create a copy of StockRow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StockRowCopyWith<StockRow> get copyWith => _$StockRowCopyWithImpl<StockRow>(this as StockRow, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as StockRow;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StockRow&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.productCode, _this.productCode) || other.productCode == _this.productCode)&&(identical(other.productName, _this.productName) || other.productName == _this.productName)&&(identical(other.warehouseId, _this.warehouseId) || other.warehouseId == _this.warehouseId)&&(identical(other.onHand, _this.onHand) || other.onHand == _this.onHand)&&(identical(other.reserved, _this.reserved) || other.reserved == _this.reserved)&&(identical(other.available, _this.available) || other.available == _this.available)&&(identical(other.incoming, _this.incoming) || other.incoming == _this.incoming));
}


@override
int get hashCode {
  final _this = this as StockRow;
  return Object.hash(runtimeType,_this.productId,_this.productCode,_this.productName,_this.warehouseId,_this.onHand,_this.reserved,_this.available,_this.incoming);
}

@override
String toString() {
  final _this = this as StockRow;
  return 'StockRow(productId: ${_this.productId}, productCode: ${_this.productCode}, productName: ${_this.productName}, warehouseId: ${_this.warehouseId}, onHand: ${_this.onHand}, reserved: ${_this.reserved}, available: ${_this.available}, incoming: ${_this.incoming})';
}


}

/// @nodoc
abstract mixin class $StockRowCopyWith<$Res>  {
  factory $StockRowCopyWith(StockRow value, $Res Function(StockRow) _then) = _$StockRowCopyWithImpl;
@useResult
$Res call({
 int productId, String productCode, String productName, int warehouseId, Decimal onHand, Decimal reserved, Decimal available, Decimal incoming
});




}
/// @nodoc
class _$StockRowCopyWithImpl<$Res>
    implements $StockRowCopyWith<$Res> {
  _$StockRowCopyWithImpl(this._self, this._then);

  final StockRow _self;
  final $Res Function(StockRow) _then;

/// Create a copy of StockRow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? productCode = null,Object? productName = null,Object? warehouseId = null,Object? onHand = null,Object? reserved = null,Object? available = null,Object? incoming = null,}) {
  return _then(StockRow(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,productCode: null == productCode ? _self.productCode : productCode // ignore: cast_nullable_to_non_nullable
as String,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,warehouseId: null == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int,onHand: null == onHand ? _self.onHand : onHand // ignore: cast_nullable_to_non_nullable
as Decimal,reserved: null == reserved ? _self.reserved : reserved // ignore: cast_nullable_to_non_nullable
as Decimal,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as Decimal,incoming: null == incoming ? _self.incoming : incoming // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}

}


/// Adds pattern-matching-related methods to [StockRow].
extension StockRowPatterns on StockRow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StockRow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StockRow() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StockRow value)  $default,){
final _that = this;
switch (_that) {
case _StockRow():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StockRow value)?  $default,){
final _that = this;
switch (_that) {
case _StockRow() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int productId,  String productCode,  String productName,  int warehouseId,  Decimal onHand,  Decimal reserved,  Decimal available,  Decimal incoming)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StockRow() when $default != null:
return $default(_that.productId,_that.productCode,_that.productName,_that.warehouseId,_that.onHand,_that.reserved,_that.available,_that.incoming);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int productId,  String productCode,  String productName,  int warehouseId,  Decimal onHand,  Decimal reserved,  Decimal available,  Decimal incoming)  $default,) {final _that = this;
switch (_that) {
case _StockRow():
return $default(_that.productId,_that.productCode,_that.productName,_that.warehouseId,_that.onHand,_that.reserved,_that.available,_that.incoming);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int productId,  String productCode,  String productName,  int warehouseId,  Decimal onHand,  Decimal reserved,  Decimal available,  Decimal incoming)?  $default,) {final _that = this;
switch (_that) {
case _StockRow() when $default != null:
return $default(_that.productId,_that.productCode,_that.productName,_that.warehouseId,_that.onHand,_that.reserved,_that.available,_that.incoming);case _:
  return null;

}
}

}

/// @nodoc


class _StockRow implements StockRow {
  const _StockRow({required this.productId, required this.productCode, required this.productName, required this.warehouseId, required this.onHand, required this.reserved, required this.available, required this.incoming});
  

@override final  int productId;
/// Empty when the server sends none.
@override final  String productCode;
@override final  String productName;
@override final  int warehouseId;
@override final  Decimal onHand;
@override final  Decimal reserved;
@override final  Decimal available;
@override final  Decimal incoming;

/// Create a copy of StockRow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StockRowCopyWith<_StockRow> get copyWith => __$StockRowCopyWithImpl<_StockRow>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StockRow&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productCode, productCode) || other.productCode == productCode)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.onHand, onHand) || other.onHand == onHand)&&(identical(other.reserved, reserved) || other.reserved == reserved)&&(identical(other.available, available) || other.available == available)&&(identical(other.incoming, incoming) || other.incoming == incoming));
}


@override
int get hashCode {
    return Object.hash(runtimeType,productId,productCode,productName,warehouseId,onHand,reserved,available,incoming);
}

@override
String toString() {
    return 'StockRow(productId: $productId, productCode: $productCode, productName: $productName, warehouseId: $warehouseId, onHand: $onHand, reserved: $reserved, available: $available, incoming: $incoming)';
}


}

/// @nodoc
abstract mixin class _$StockRowCopyWith<$Res> implements $StockRowCopyWith<$Res> {
  factory _$StockRowCopyWith(_StockRow value, $Res Function(_StockRow) _then) = __$StockRowCopyWithImpl;
@override @useResult
$Res call({
 int productId, String productCode, String productName, int warehouseId, Decimal onHand, Decimal reserved, Decimal available, Decimal incoming
});




}
/// @nodoc
class __$StockRowCopyWithImpl<$Res>
    implements _$StockRowCopyWith<$Res> {
  __$StockRowCopyWithImpl(this._self, this._then);

  final _StockRow _self;
  final $Res Function(_StockRow) _then;

/// Create a copy of StockRow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? productCode = null,Object? productName = null,Object? warehouseId = null,Object? onHand = null,Object? reserved = null,Object? available = null,Object? incoming = null,}) {
  return _then(_StockRow(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,productCode: null == productCode ? _self.productCode : productCode // ignore: cast_nullable_to_non_nullable
as String,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,warehouseId: null == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int,onHand: null == onHand ? _self.onHand : onHand // ignore: cast_nullable_to_non_nullable
as Decimal,reserved: null == reserved ? _self.reserved : reserved // ignore: cast_nullable_to_non_nullable
as Decimal,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as Decimal,incoming: null == incoming ? _self.incoming : incoming // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}


}

/// @nodoc
mixin _$StockPage {

 List<StockRow> get items; int get total;
/// Create a copy of StockPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StockPageCopyWith<StockPage> get copyWith => _$StockPageCopyWithImpl<StockPage>(this as StockPage, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as StockPage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StockPage&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.total, _this.total) || other.total == _this.total));
}


@override
int get hashCode {
  final _this = this as StockPage;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.items),_this.total);
}

@override
String toString() {
  final _this = this as StockPage;
  return 'StockPage(items: ${_this.items}, total: ${_this.total})';
}


}

/// @nodoc
abstract mixin class $StockPageCopyWith<$Res>  {
  factory $StockPageCopyWith(StockPage value, $Res Function(StockPage) _then) = _$StockPageCopyWithImpl;
@useResult
$Res call({
 List<StockRow> items, int total
});




}
/// @nodoc
class _$StockPageCopyWithImpl<$Res>
    implements $StockPageCopyWith<$Res> {
  _$StockPageCopyWithImpl(this._self, this._then);

  final StockPage _self;
  final $Res Function(StockPage) _then;

/// Create a copy of StockPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? total = null,}) {
  return _then(StockPage(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<StockRow>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [StockPage].
extension StockPagePatterns on StockPage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StockPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StockPage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StockPage value)  $default,){
final _that = this;
switch (_that) {
case _StockPage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StockPage value)?  $default,){
final _that = this;
switch (_that) {
case _StockPage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<StockRow> items,  int total)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StockPage() when $default != null:
return $default(_that.items,_that.total);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<StockRow> items,  int total)  $default,) {final _that = this;
switch (_that) {
case _StockPage():
return $default(_that.items,_that.total);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<StockRow> items,  int total)?  $default,) {final _that = this;
switch (_that) {
case _StockPage() when $default != null:
return $default(_that.items,_that.total);case _:
  return null;

}
}

}

/// @nodoc


class _StockPage implements StockPage {
  const _StockPage({required  List<StockRow> items, required this.total}): _items = items;
  

 final  List<StockRow> _items;
@override List<StockRow> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  int total;

/// Create a copy of StockPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StockPageCopyWith<_StockPage> get copyWith => __$StockPageCopyWithImpl<_StockPage>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StockPage&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.total, total) || other.total == total));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),total);
}

@override
String toString() {
    return 'StockPage(items: $items, total: $total)';
}


}

/// @nodoc
abstract mixin class _$StockPageCopyWith<$Res> implements $StockPageCopyWith<$Res> {
  factory _$StockPageCopyWith(_StockPage value, $Res Function(_StockPage) _then) = __$StockPageCopyWithImpl;
@override @useResult
$Res call({
 List<StockRow> items, int total
});




}
/// @nodoc
class __$StockPageCopyWithImpl<$Res>
    implements _$StockPageCopyWith<$Res> {
  __$StockPageCopyWithImpl(this._self, this._then);

  final _StockPage _self;
  final $Res Function(_StockPage) _then;

/// Create a copy of StockPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? total = null,}) {
  return _then(_StockPage(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<StockRow>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$InTransitStock {

 int get facilityId; int get warehouseId; Decimal get onHand;
/// Create a copy of InTransitStock
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InTransitStockCopyWith<InTransitStock> get copyWith => _$InTransitStockCopyWithImpl<InTransitStock>(this as InTransitStock, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as InTransitStock;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InTransitStock&&(identical(other.facilityId, _this.facilityId) || other.facilityId == _this.facilityId)&&(identical(other.warehouseId, _this.warehouseId) || other.warehouseId == _this.warehouseId)&&(identical(other.onHand, _this.onHand) || other.onHand == _this.onHand));
}


@override
int get hashCode {
  final _this = this as InTransitStock;
  return Object.hash(runtimeType,_this.facilityId,_this.warehouseId,_this.onHand);
}

@override
String toString() {
  final _this = this as InTransitStock;
  return 'InTransitStock(facilityId: ${_this.facilityId}, warehouseId: ${_this.warehouseId}, onHand: ${_this.onHand})';
}


}

/// @nodoc
abstract mixin class $InTransitStockCopyWith<$Res>  {
  factory $InTransitStockCopyWith(InTransitStock value, $Res Function(InTransitStock) _then) = _$InTransitStockCopyWithImpl;
@useResult
$Res call({
 int facilityId, int warehouseId, Decimal onHand
});




}
/// @nodoc
class _$InTransitStockCopyWithImpl<$Res>
    implements $InTransitStockCopyWith<$Res> {
  _$InTransitStockCopyWithImpl(this._self, this._then);

  final InTransitStock _self;
  final $Res Function(InTransitStock) _then;

/// Create a copy of InTransitStock
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? facilityId = null,Object? warehouseId = null,Object? onHand = null,}) {
  return _then(InTransitStock(
facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int,warehouseId: null == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int,onHand: null == onHand ? _self.onHand : onHand // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}

}


/// Adds pattern-matching-related methods to [InTransitStock].
extension InTransitStockPatterns on InTransitStock {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InTransitStock value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InTransitStock() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InTransitStock value)  $default,){
final _that = this;
switch (_that) {
case _InTransitStock():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InTransitStock value)?  $default,){
final _that = this;
switch (_that) {
case _InTransitStock() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int facilityId,  int warehouseId,  Decimal onHand)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InTransitStock() when $default != null:
return $default(_that.facilityId,_that.warehouseId,_that.onHand);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int facilityId,  int warehouseId,  Decimal onHand)  $default,) {final _that = this;
switch (_that) {
case _InTransitStock():
return $default(_that.facilityId,_that.warehouseId,_that.onHand);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int facilityId,  int warehouseId,  Decimal onHand)?  $default,) {final _that = this;
switch (_that) {
case _InTransitStock() when $default != null:
return $default(_that.facilityId,_that.warehouseId,_that.onHand);case _:
  return null;

}
}

}

/// @nodoc


class _InTransitStock implements InTransitStock {
  const _InTransitStock({required this.facilityId, required this.warehouseId, required this.onHand});
  

@override final  int facilityId;
@override final  int warehouseId;
@override final  Decimal onHand;

/// Create a copy of InTransitStock
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InTransitStockCopyWith<_InTransitStock> get copyWith => __$InTransitStockCopyWithImpl<_InTransitStock>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _InTransitStock&&(identical(other.facilityId, facilityId) || other.facilityId == facilityId)&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.onHand, onHand) || other.onHand == onHand));
}


@override
int get hashCode {
    return Object.hash(runtimeType,facilityId,warehouseId,onHand);
}

@override
String toString() {
    return 'InTransitStock(facilityId: $facilityId, warehouseId: $warehouseId, onHand: $onHand)';
}


}

/// @nodoc
abstract mixin class _$InTransitStockCopyWith<$Res> implements $InTransitStockCopyWith<$Res> {
  factory _$InTransitStockCopyWith(_InTransitStock value, $Res Function(_InTransitStock) _then) = __$InTransitStockCopyWithImpl;
@override @useResult
$Res call({
 int facilityId, int warehouseId, Decimal onHand
});




}
/// @nodoc
class __$InTransitStockCopyWithImpl<$Res>
    implements _$InTransitStockCopyWith<$Res> {
  __$InTransitStockCopyWithImpl(this._self, this._then);

  final _InTransitStock _self;
  final $Res Function(_InTransitStock) _then;

/// Create a copy of InTransitStock
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? facilityId = null,Object? warehouseId = null,Object? onHand = null,}) {
  return _then(_InTransitStock(
facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int,warehouseId: null == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int,onHand: null == onHand ? _self.onHand : onHand // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}


}

/// @nodoc
mixin _$ProductStock {

 int get productId; List<StockRow> get warehouses; List<InTransitStock> get inTransit;
/// Create a copy of ProductStock
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductStockCopyWith<ProductStock> get copyWith => _$ProductStockCopyWithImpl<ProductStock>(this as ProductStock, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ProductStock;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductStock&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&const DeepCollectionEquality().equals(other.warehouses, _this.warehouses)&&const DeepCollectionEquality().equals(other.inTransit, _this.inTransit));
}


@override
int get hashCode {
  final _this = this as ProductStock;
  return Object.hash(runtimeType,_this.productId,const DeepCollectionEquality().hash(_this.warehouses),const DeepCollectionEquality().hash(_this.inTransit));
}

@override
String toString() {
  final _this = this as ProductStock;
  return 'ProductStock(productId: ${_this.productId}, warehouses: ${_this.warehouses}, inTransit: ${_this.inTransit})';
}


}

/// @nodoc
abstract mixin class $ProductStockCopyWith<$Res>  {
  factory $ProductStockCopyWith(ProductStock value, $Res Function(ProductStock) _then) = _$ProductStockCopyWithImpl;
@useResult
$Res call({
 int productId, List<StockRow> warehouses, List<InTransitStock> inTransit
});




}
/// @nodoc
class _$ProductStockCopyWithImpl<$Res>
    implements $ProductStockCopyWith<$Res> {
  _$ProductStockCopyWithImpl(this._self, this._then);

  final ProductStock _self;
  final $Res Function(ProductStock) _then;

/// Create a copy of ProductStock
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? warehouses = null,Object? inTransit = null,}) {
  return _then(ProductStock(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,warehouses: null == warehouses ? _self.warehouses : warehouses // ignore: cast_nullable_to_non_nullable
as List<StockRow>,inTransit: null == inTransit ? _self.inTransit : inTransit // ignore: cast_nullable_to_non_nullable
as List<InTransitStock>,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductStock].
extension ProductStockPatterns on ProductStock {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductStock value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductStock() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductStock value)  $default,){
final _that = this;
switch (_that) {
case _ProductStock():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductStock value)?  $default,){
final _that = this;
switch (_that) {
case _ProductStock() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int productId,  List<StockRow> warehouses,  List<InTransitStock> inTransit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductStock() when $default != null:
return $default(_that.productId,_that.warehouses,_that.inTransit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int productId,  List<StockRow> warehouses,  List<InTransitStock> inTransit)  $default,) {final _that = this;
switch (_that) {
case _ProductStock():
return $default(_that.productId,_that.warehouses,_that.inTransit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int productId,  List<StockRow> warehouses,  List<InTransitStock> inTransit)?  $default,) {final _that = this;
switch (_that) {
case _ProductStock() when $default != null:
return $default(_that.productId,_that.warehouses,_that.inTransit);case _:
  return null;

}
}

}

/// @nodoc


class _ProductStock extends ProductStock {
  const _ProductStock({required this.productId, required  List<StockRow> warehouses, required  List<InTransitStock> inTransit}): _warehouses = warehouses,_inTransit = inTransit,super._();
  

@override final  int productId;
 final  List<StockRow> _warehouses;
@override List<StockRow> get warehouses {
  if (_warehouses is EqualUnmodifiableListView) return _warehouses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_warehouses);
}

 final  List<InTransitStock> _inTransit;
@override List<InTransitStock> get inTransit {
  if (_inTransit is EqualUnmodifiableListView) return _inTransit;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_inTransit);
}


/// Create a copy of ProductStock
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductStockCopyWith<_ProductStock> get copyWith => __$ProductStockCopyWithImpl<_ProductStock>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductStock&&(identical(other.productId, productId) || other.productId == productId)&&const DeepCollectionEquality().equals(other.warehouses, _warehouses)&&const DeepCollectionEquality().equals(other.inTransit, _inTransit));
}


@override
int get hashCode {
    return Object.hash(runtimeType,productId,const DeepCollectionEquality().hash(_warehouses),const DeepCollectionEquality().hash(_inTransit));
}

@override
String toString() {
    return 'ProductStock(productId: $productId, warehouses: $warehouses, inTransit: $inTransit)';
}


}

/// @nodoc
abstract mixin class _$ProductStockCopyWith<$Res> implements $ProductStockCopyWith<$Res> {
  factory _$ProductStockCopyWith(_ProductStock value, $Res Function(_ProductStock) _then) = __$ProductStockCopyWithImpl;
@override @useResult
$Res call({
 int productId, List<StockRow> warehouses, List<InTransitStock> inTransit
});




}
/// @nodoc
class __$ProductStockCopyWithImpl<$Res>
    implements _$ProductStockCopyWith<$Res> {
  __$ProductStockCopyWithImpl(this._self, this._then);

  final _ProductStock _self;
  final $Res Function(_ProductStock) _then;

/// Create a copy of ProductStock
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? warehouses = null,Object? inTransit = null,}) {
  return _then(_ProductStock(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,warehouses: null == warehouses ? _self._warehouses : warehouses // ignore: cast_nullable_to_non_nullable
as List<StockRow>,inTransit: null == inTransit ? _self._inTransit : inTransit // ignore: cast_nullable_to_non_nullable
as List<InTransitStock>,
  ));
}


}

/// @nodoc
mixin _$StockTotals {

 Decimal get onHand; Decimal get reserved; Decimal get available; Decimal get incoming;
/// Create a copy of StockTotals
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StockTotalsCopyWith<StockTotals> get copyWith => _$StockTotalsCopyWithImpl<StockTotals>(this as StockTotals, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as StockTotals;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StockTotals&&(identical(other.onHand, _this.onHand) || other.onHand == _this.onHand)&&(identical(other.reserved, _this.reserved) || other.reserved == _this.reserved)&&(identical(other.available, _this.available) || other.available == _this.available)&&(identical(other.incoming, _this.incoming) || other.incoming == _this.incoming));
}


@override
int get hashCode {
  final _this = this as StockTotals;
  return Object.hash(runtimeType,_this.onHand,_this.reserved,_this.available,_this.incoming);
}

@override
String toString() {
  final _this = this as StockTotals;
  return 'StockTotals(onHand: ${_this.onHand}, reserved: ${_this.reserved}, available: ${_this.available}, incoming: ${_this.incoming})';
}


}

/// @nodoc
abstract mixin class $StockTotalsCopyWith<$Res>  {
  factory $StockTotalsCopyWith(StockTotals value, $Res Function(StockTotals) _then) = _$StockTotalsCopyWithImpl;
@useResult
$Res call({
 Decimal onHand, Decimal reserved, Decimal available, Decimal incoming
});




}
/// @nodoc
class _$StockTotalsCopyWithImpl<$Res>
    implements $StockTotalsCopyWith<$Res> {
  _$StockTotalsCopyWithImpl(this._self, this._then);

  final StockTotals _self;
  final $Res Function(StockTotals) _then;

/// Create a copy of StockTotals
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? onHand = null,Object? reserved = null,Object? available = null,Object? incoming = null,}) {
  return _then(StockTotals(
onHand: null == onHand ? _self.onHand : onHand // ignore: cast_nullable_to_non_nullable
as Decimal,reserved: null == reserved ? _self.reserved : reserved // ignore: cast_nullable_to_non_nullable
as Decimal,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as Decimal,incoming: null == incoming ? _self.incoming : incoming // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}

}


/// Adds pattern-matching-related methods to [StockTotals].
extension StockTotalsPatterns on StockTotals {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StockTotals value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StockTotals() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StockTotals value)  $default,){
final _that = this;
switch (_that) {
case _StockTotals():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StockTotals value)?  $default,){
final _that = this;
switch (_that) {
case _StockTotals() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Decimal onHand,  Decimal reserved,  Decimal available,  Decimal incoming)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StockTotals() when $default != null:
return $default(_that.onHand,_that.reserved,_that.available,_that.incoming);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Decimal onHand,  Decimal reserved,  Decimal available,  Decimal incoming)  $default,) {final _that = this;
switch (_that) {
case _StockTotals():
return $default(_that.onHand,_that.reserved,_that.available,_that.incoming);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Decimal onHand,  Decimal reserved,  Decimal available,  Decimal incoming)?  $default,) {final _that = this;
switch (_that) {
case _StockTotals() when $default != null:
return $default(_that.onHand,_that.reserved,_that.available,_that.incoming);case _:
  return null;

}
}

}

/// @nodoc


class _StockTotals implements StockTotals {
  const _StockTotals({required this.onHand, required this.reserved, required this.available, required this.incoming});
  

@override final  Decimal onHand;
@override final  Decimal reserved;
@override final  Decimal available;
@override final  Decimal incoming;

/// Create a copy of StockTotals
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StockTotalsCopyWith<_StockTotals> get copyWith => __$StockTotalsCopyWithImpl<_StockTotals>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StockTotals&&(identical(other.onHand, onHand) || other.onHand == onHand)&&(identical(other.reserved, reserved) || other.reserved == reserved)&&(identical(other.available, available) || other.available == available)&&(identical(other.incoming, incoming) || other.incoming == incoming));
}


@override
int get hashCode {
    return Object.hash(runtimeType,onHand,reserved,available,incoming);
}

@override
String toString() {
    return 'StockTotals(onHand: $onHand, reserved: $reserved, available: $available, incoming: $incoming)';
}


}

/// @nodoc
abstract mixin class _$StockTotalsCopyWith<$Res> implements $StockTotalsCopyWith<$Res> {
  factory _$StockTotalsCopyWith(_StockTotals value, $Res Function(_StockTotals) _then) = __$StockTotalsCopyWithImpl;
@override @useResult
$Res call({
 Decimal onHand, Decimal reserved, Decimal available, Decimal incoming
});




}
/// @nodoc
class __$StockTotalsCopyWithImpl<$Res>
    implements _$StockTotalsCopyWith<$Res> {
  __$StockTotalsCopyWithImpl(this._self, this._then);

  final _StockTotals _self;
  final $Res Function(_StockTotals) _then;

/// Create a copy of StockTotals
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? onHand = null,Object? reserved = null,Object? available = null,Object? incoming = null,}) {
  return _then(_StockTotals(
onHand: null == onHand ? _self.onHand : onHand // ignore: cast_nullable_to_non_nullable
as Decimal,reserved: null == reserved ? _self.reserved : reserved // ignore: cast_nullable_to_non_nullable
as Decimal,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as Decimal,incoming: null == incoming ? _self.incoming : incoming // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}


}

// dart format on
