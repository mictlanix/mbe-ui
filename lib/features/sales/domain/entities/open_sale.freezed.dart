// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'open_sale.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OpenSale {

 int get id; int? get serial;/// The per-document name **override** — mbe's data dictionary calls this
/// column "Override customer name on docs", and mbe-api sets it only
/// from what a client sends. `null` on every ordinary sale, walk-in ones
/// included, which is why it is not the name a row shows on its own
/// (mictlanix/mbe-api#172).
 String? get customerName;/// The customer's own name, joined from the sale's customer by mbe-api
/// (mictlanix/mbe-api#173). This is what a row displays when the sale
/// carries no override — and it is why nothing here has to resolve a
/// customer per row any more.
///
/// Nullable because the field is optional in the schema: a deployment
/// running an mbe-api older than #173 simply omits it, and the row falls
/// back to the override and then to a dash rather than breaking.
 String? get customerDisplayName; String get total; String get balance; SaleStatus get status; DateTime get date;
/// Create a copy of OpenSale
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OpenSaleCopyWith<OpenSale> get copyWith => _$OpenSaleCopyWithImpl<OpenSale>(this as OpenSale, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as OpenSale;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OpenSale&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.serial, _this.serial) || other.serial == _this.serial)&&(identical(other.customerName, _this.customerName) || other.customerName == _this.customerName)&&(identical(other.customerDisplayName, _this.customerDisplayName) || other.customerDisplayName == _this.customerDisplayName)&&(identical(other.total, _this.total) || other.total == _this.total)&&(identical(other.balance, _this.balance) || other.balance == _this.balance)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.date, _this.date) || other.date == _this.date));
}


@override
int get hashCode {
  final _this = this as OpenSale;
  return Object.hash(runtimeType,_this.id,_this.serial,_this.customerName,_this.customerDisplayName,_this.total,_this.balance,_this.status,_this.date);
}

@override
String toString() {
  final _this = this as OpenSale;
  return 'OpenSale(id: ${_this.id}, serial: ${_this.serial}, customerName: ${_this.customerName}, customerDisplayName: ${_this.customerDisplayName}, total: ${_this.total}, balance: ${_this.balance}, status: ${_this.status}, date: ${_this.date})';
}


}

/// @nodoc
abstract mixin class $OpenSaleCopyWith<$Res>  {
  factory $OpenSaleCopyWith(OpenSale value, $Res Function(OpenSale) _then) = _$OpenSaleCopyWithImpl;
@useResult
$Res call({
 int id, int? serial, String? customerName, String? customerDisplayName, String total, String balance, SaleStatus status, DateTime date
});




}
/// @nodoc
class _$OpenSaleCopyWithImpl<$Res>
    implements $OpenSaleCopyWith<$Res> {
  _$OpenSaleCopyWithImpl(this._self, this._then);

  final OpenSale _self;
  final $Res Function(OpenSale) _then;

/// Create a copy of OpenSale
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? serial = freezed,Object? customerName = freezed,Object? customerDisplayName = freezed,Object? total = null,Object? balance = null,Object? status = null,Object? date = null,}) {
  return _then(OpenSale(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as int?,customerName: freezed == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String?,customerDisplayName: freezed == customerDisplayName ? _self.customerDisplayName : customerDisplayName // ignore: cast_nullable_to_non_nullable
as String?,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as String,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SaleStatus,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [OpenSale].
extension OpenSalePatterns on OpenSale {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OpenSale value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OpenSale() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OpenSale value)  $default,){
final _that = this;
switch (_that) {
case _OpenSale():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OpenSale value)?  $default,){
final _that = this;
switch (_that) {
case _OpenSale() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int? serial,  String? customerName,  String? customerDisplayName,  String total,  String balance,  SaleStatus status,  DateTime date)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OpenSale() when $default != null:
return $default(_that.id,_that.serial,_that.customerName,_that.customerDisplayName,_that.total,_that.balance,_that.status,_that.date);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int? serial,  String? customerName,  String? customerDisplayName,  String total,  String balance,  SaleStatus status,  DateTime date)  $default,) {final _that = this;
switch (_that) {
case _OpenSale():
return $default(_that.id,_that.serial,_that.customerName,_that.customerDisplayName,_that.total,_that.balance,_that.status,_that.date);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int? serial,  String? customerName,  String? customerDisplayName,  String total,  String balance,  SaleStatus status,  DateTime date)?  $default,) {final _that = this;
switch (_that) {
case _OpenSale() when $default != null:
return $default(_that.id,_that.serial,_that.customerName,_that.customerDisplayName,_that.total,_that.balance,_that.status,_that.date);case _:
  return null;

}
}

}

/// @nodoc


class _OpenSale implements OpenSale {
  const _OpenSale({required this.id, this.serial, this.customerName, this.customerDisplayName, required this.total, required this.balance, required this.status, required this.date});
  

@override final  int id;
@override final  int? serial;
/// The per-document name **override** — mbe's data dictionary calls this
/// column "Override customer name on docs", and mbe-api sets it only
/// from what a client sends. `null` on every ordinary sale, walk-in ones
/// included, which is why it is not the name a row shows on its own
/// (mictlanix/mbe-api#172).
@override final  String? customerName;
/// The customer's own name, joined from the sale's customer by mbe-api
/// (mictlanix/mbe-api#173). This is what a row displays when the sale
/// carries no override — and it is why nothing here has to resolve a
/// customer per row any more.
///
/// Nullable because the field is optional in the schema: a deployment
/// running an mbe-api older than #173 simply omits it, and the row falls
/// back to the override and then to a dash rather than breaking.
@override final  String? customerDisplayName;
@override final  String total;
@override final  String balance;
@override final  SaleStatus status;
@override final  DateTime date;

/// Create a copy of OpenSale
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OpenSaleCopyWith<_OpenSale> get copyWith => __$OpenSaleCopyWithImpl<_OpenSale>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OpenSale&&(identical(other.id, id) || other.id == id)&&(identical(other.serial, serial) || other.serial == serial)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.customerDisplayName, customerDisplayName) || other.customerDisplayName == customerDisplayName)&&(identical(other.total, total) || other.total == total)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.status, status) || other.status == status)&&(identical(other.date, date) || other.date == date));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,serial,customerName,customerDisplayName,total,balance,status,date);
}

@override
String toString() {
    return 'OpenSale(id: $id, serial: $serial, customerName: $customerName, customerDisplayName: $customerDisplayName, total: $total, balance: $balance, status: $status, date: $date)';
}


}

/// @nodoc
abstract mixin class _$OpenSaleCopyWith<$Res> implements $OpenSaleCopyWith<$Res> {
  factory _$OpenSaleCopyWith(_OpenSale value, $Res Function(_OpenSale) _then) = __$OpenSaleCopyWithImpl;
@override @useResult
$Res call({
 int id, int? serial, String? customerName, String? customerDisplayName, String total, String balance, SaleStatus status, DateTime date
});




}
/// @nodoc
class __$OpenSaleCopyWithImpl<$Res>
    implements _$OpenSaleCopyWith<$Res> {
  __$OpenSaleCopyWithImpl(this._self, this._then);

  final _OpenSale _self;
  final $Res Function(_OpenSale) _then;

/// Create a copy of OpenSale
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? serial = freezed,Object? customerName = freezed,Object? customerDisplayName = freezed,Object? total = null,Object? balance = null,Object? status = null,Object? date = null,}) {
  return _then(_OpenSale(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as int?,customerName: freezed == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String?,customerDisplayName: freezed == customerDisplayName ? _self.customerDisplayName : customerDisplayName // ignore: cast_nullable_to_non_nullable
as String?,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as String,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SaleStatus,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
