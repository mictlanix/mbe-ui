// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'outstanding_order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OutstandingOrder {

 int get id; int? get serial; DateTime get date; DateTime get dueDate; Currency get currency; String get total; String get balance;
/// Create a copy of OutstandingOrder
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OutstandingOrderCopyWith<OutstandingOrder> get copyWith => _$OutstandingOrderCopyWithImpl<OutstandingOrder>(this as OutstandingOrder, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as OutstandingOrder;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OutstandingOrder&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.serial, _this.serial) || other.serial == _this.serial)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.dueDate, _this.dueDate) || other.dueDate == _this.dueDate)&&(identical(other.currency, _this.currency) || other.currency == _this.currency)&&(identical(other.total, _this.total) || other.total == _this.total)&&(identical(other.balance, _this.balance) || other.balance == _this.balance));
}


@override
int get hashCode {
  final _this = this as OutstandingOrder;
  return Object.hash(runtimeType,_this.id,_this.serial,_this.date,_this.dueDate,_this.currency,_this.total,_this.balance);
}

@override
String toString() {
  final _this = this as OutstandingOrder;
  return 'OutstandingOrder(id: ${_this.id}, serial: ${_this.serial}, date: ${_this.date}, dueDate: ${_this.dueDate}, currency: ${_this.currency}, total: ${_this.total}, balance: ${_this.balance})';
}


}

/// @nodoc
abstract mixin class $OutstandingOrderCopyWith<$Res>  {
  factory $OutstandingOrderCopyWith(OutstandingOrder value, $Res Function(OutstandingOrder) _then) = _$OutstandingOrderCopyWithImpl;
@useResult
$Res call({
 int id, int? serial, DateTime date, DateTime dueDate, Currency currency, String total, String balance
});




}
/// @nodoc
class _$OutstandingOrderCopyWithImpl<$Res>
    implements $OutstandingOrderCopyWith<$Res> {
  _$OutstandingOrderCopyWithImpl(this._self, this._then);

  final OutstandingOrder _self;
  final $Res Function(OutstandingOrder) _then;

/// Create a copy of OutstandingOrder
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? serial = freezed,Object? date = null,Object? dueDate = null,Object? currency = null,Object? total = null,Object? balance = null,}) {
  return _then(OutstandingOrder(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as int?,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as Currency,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as String,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [OutstandingOrder].
extension OutstandingOrderPatterns on OutstandingOrder {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OutstandingOrder value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OutstandingOrder() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OutstandingOrder value)  $default,){
final _that = this;
switch (_that) {
case _OutstandingOrder():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OutstandingOrder value)?  $default,){
final _that = this;
switch (_that) {
case _OutstandingOrder() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int? serial,  DateTime date,  DateTime dueDate,  Currency currency,  String total,  String balance)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OutstandingOrder() when $default != null:
return $default(_that.id,_that.serial,_that.date,_that.dueDate,_that.currency,_that.total,_that.balance);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int? serial,  DateTime date,  DateTime dueDate,  Currency currency,  String total,  String balance)  $default,) {final _that = this;
switch (_that) {
case _OutstandingOrder():
return $default(_that.id,_that.serial,_that.date,_that.dueDate,_that.currency,_that.total,_that.balance);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int? serial,  DateTime date,  DateTime dueDate,  Currency currency,  String total,  String balance)?  $default,) {final _that = this;
switch (_that) {
case _OutstandingOrder() when $default != null:
return $default(_that.id,_that.serial,_that.date,_that.dueDate,_that.currency,_that.total,_that.balance);case _:
  return null;

}
}

}

/// @nodoc


class _OutstandingOrder implements OutstandingOrder {
  const _OutstandingOrder({required this.id, this.serial, required this.date, required this.dueDate, required this.currency, required this.total, required this.balance});
  

@override final  int id;
@override final  int? serial;
@override final  DateTime date;
@override final  DateTime dueDate;
@override final  Currency currency;
@override final  String total;
@override final  String balance;

/// Create a copy of OutstandingOrder
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OutstandingOrderCopyWith<_OutstandingOrder> get copyWith => __$OutstandingOrderCopyWithImpl<_OutstandingOrder>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OutstandingOrder&&(identical(other.id, id) || other.id == id)&&(identical(other.serial, serial) || other.serial == serial)&&(identical(other.date, date) || other.date == date)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.total, total) || other.total == total)&&(identical(other.balance, balance) || other.balance == balance));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,serial,date,dueDate,currency,total,balance);
}

@override
String toString() {
    return 'OutstandingOrder(id: $id, serial: $serial, date: $date, dueDate: $dueDate, currency: $currency, total: $total, balance: $balance)';
}


}

/// @nodoc
abstract mixin class _$OutstandingOrderCopyWith<$Res> implements $OutstandingOrderCopyWith<$Res> {
  factory _$OutstandingOrderCopyWith(_OutstandingOrder value, $Res Function(_OutstandingOrder) _then) = __$OutstandingOrderCopyWithImpl;
@override @useResult
$Res call({
 int id, int? serial, DateTime date, DateTime dueDate, Currency currency, String total, String balance
});




}
/// @nodoc
class __$OutstandingOrderCopyWithImpl<$Res>
    implements _$OutstandingOrderCopyWith<$Res> {
  __$OutstandingOrderCopyWithImpl(this._self, this._then);

  final _OutstandingOrder _self;
  final $Res Function(_OutstandingOrder) _then;

/// Create a copy of OutstandingOrder
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? serial = freezed,Object? date = null,Object? dueDate = null,Object? currency = null,Object? total = null,Object? balance = null,}) {
  return _then(_OutstandingOrder(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as int?,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as Currency,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as String,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
