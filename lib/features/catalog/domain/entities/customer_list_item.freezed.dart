// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'customer_list_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CustomerListItem {

 int get customerId; String get code; String get name; String? get zone; String get creditLimit; int get creditDays; PriceListRef get priceList; EmployeeRef? get salesperson; EntityStatus get status;
/// Create a copy of CustomerListItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomerListItemCopyWith<CustomerListItem> get copyWith => _$CustomerListItemCopyWithImpl<CustomerListItem>(this as CustomerListItem, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CustomerListItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomerListItem&&(identical(other.customerId, _this.customerId) || other.customerId == _this.customerId)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.zone, _this.zone) || other.zone == _this.zone)&&(identical(other.creditLimit, _this.creditLimit) || other.creditLimit == _this.creditLimit)&&(identical(other.creditDays, _this.creditDays) || other.creditDays == _this.creditDays)&&(identical(other.priceList, _this.priceList) || other.priceList == _this.priceList)&&(identical(other.salesperson, _this.salesperson) || other.salesperson == _this.salesperson)&&(identical(other.status, _this.status) || other.status == _this.status));
}


@override
int get hashCode {
  final _this = this as CustomerListItem;
  return Object.hash(runtimeType,_this.customerId,_this.code,_this.name,_this.zone,_this.creditLimit,_this.creditDays,_this.priceList,_this.salesperson,_this.status);
}

@override
String toString() {
  final _this = this as CustomerListItem;
  return 'CustomerListItem(customerId: ${_this.customerId}, code: ${_this.code}, name: ${_this.name}, zone: ${_this.zone}, creditLimit: ${_this.creditLimit}, creditDays: ${_this.creditDays}, priceList: ${_this.priceList}, salesperson: ${_this.salesperson}, status: ${_this.status})';
}


}

/// @nodoc
abstract mixin class $CustomerListItemCopyWith<$Res>  {
  factory $CustomerListItemCopyWith(CustomerListItem value, $Res Function(CustomerListItem) _then) = _$CustomerListItemCopyWithImpl;
@useResult
$Res call({
 int customerId, String code, String name, String? zone, String creditLimit, int creditDays, PriceListRef priceList, EmployeeRef? salesperson, EntityStatus status
});


$PriceListRefCopyWith<$Res> get priceList;$EmployeeRefCopyWith<$Res>? get salesperson;

}
/// @nodoc
class _$CustomerListItemCopyWithImpl<$Res>
    implements $CustomerListItemCopyWith<$Res> {
  _$CustomerListItemCopyWithImpl(this._self, this._then);

  final CustomerListItem _self;
  final $Res Function(CustomerListItem) _then;

/// Create a copy of CustomerListItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? customerId = null,Object? code = null,Object? name = null,Object? zone = freezed,Object? creditLimit = null,Object? creditDays = null,Object? priceList = null,Object? salesperson = freezed,Object? status = null,}) {
  return _then(CustomerListItem(
customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,zone: freezed == zone ? _self.zone : zone // ignore: cast_nullable_to_non_nullable
as String?,creditLimit: null == creditLimit ? _self.creditLimit : creditLimit // ignore: cast_nullable_to_non_nullable
as String,creditDays: null == creditDays ? _self.creditDays : creditDays // ignore: cast_nullable_to_non_nullable
as int,priceList: null == priceList ? _self.priceList : priceList // ignore: cast_nullable_to_non_nullable
as PriceListRef,salesperson: freezed == salesperson ? _self.salesperson : salesperson // ignore: cast_nullable_to_non_nullable
as EmployeeRef?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus,
  ));
}
/// Create a copy of CustomerListItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceListRefCopyWith<$Res> get priceList {
  
  return $PriceListRefCopyWith<$Res>(_self.priceList, (value) {
    return _then(_self.copyWith(priceList: value));
  });
}/// Create a copy of CustomerListItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EmployeeRefCopyWith<$Res>? get salesperson {
    if (_self.salesperson == null) {
    return null;
  }

  return $EmployeeRefCopyWith<$Res>(_self.salesperson!, (value) {
    return _then(_self.copyWith(salesperson: value));
  });
}
}


/// Adds pattern-matching-related methods to [CustomerListItem].
extension CustomerListItemPatterns on CustomerListItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CustomerListItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CustomerListItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CustomerListItem value)  $default,){
final _that = this;
switch (_that) {
case _CustomerListItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CustomerListItem value)?  $default,){
final _that = this;
switch (_that) {
case _CustomerListItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int customerId,  String code,  String name,  String? zone,  String creditLimit,  int creditDays,  PriceListRef priceList,  EmployeeRef? salesperson,  EntityStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CustomerListItem() when $default != null:
return $default(_that.customerId,_that.code,_that.name,_that.zone,_that.creditLimit,_that.creditDays,_that.priceList,_that.salesperson,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int customerId,  String code,  String name,  String? zone,  String creditLimit,  int creditDays,  PriceListRef priceList,  EmployeeRef? salesperson,  EntityStatus status)  $default,) {final _that = this;
switch (_that) {
case _CustomerListItem():
return $default(_that.customerId,_that.code,_that.name,_that.zone,_that.creditLimit,_that.creditDays,_that.priceList,_that.salesperson,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int customerId,  String code,  String name,  String? zone,  String creditLimit,  int creditDays,  PriceListRef priceList,  EmployeeRef? salesperson,  EntityStatus status)?  $default,) {final _that = this;
switch (_that) {
case _CustomerListItem() when $default != null:
return $default(_that.customerId,_that.code,_that.name,_that.zone,_that.creditLimit,_that.creditDays,_that.priceList,_that.salesperson,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _CustomerListItem implements CustomerListItem {
  const _CustomerListItem({required this.customerId, required this.code, required this.name, this.zone, required this.creditLimit, required this.creditDays, required this.priceList, this.salesperson, required this.status});
  

@override final  int customerId;
@override final  String code;
@override final  String name;
@override final  String? zone;
@override final  String creditLimit;
@override final  int creditDays;
@override final  PriceListRef priceList;
@override final  EmployeeRef? salesperson;
@override final  EntityStatus status;

/// Create a copy of CustomerListItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomerListItemCopyWith<_CustomerListItem> get copyWith => __$CustomerListItemCopyWithImpl<_CustomerListItem>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CustomerListItem&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.zone, zone) || other.zone == zone)&&(identical(other.creditLimit, creditLimit) || other.creditLimit == creditLimit)&&(identical(other.creditDays, creditDays) || other.creditDays == creditDays)&&(identical(other.priceList, priceList) || other.priceList == priceList)&&(identical(other.salesperson, salesperson) || other.salesperson == salesperson)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode {
    return Object.hash(runtimeType,customerId,code,name,zone,creditLimit,creditDays,priceList,salesperson,status);
}

@override
String toString() {
    return 'CustomerListItem(customerId: $customerId, code: $code, name: $name, zone: $zone, creditLimit: $creditLimit, creditDays: $creditDays, priceList: $priceList, salesperson: $salesperson, status: $status)';
}


}

/// @nodoc
abstract mixin class _$CustomerListItemCopyWith<$Res> implements $CustomerListItemCopyWith<$Res> {
  factory _$CustomerListItemCopyWith(_CustomerListItem value, $Res Function(_CustomerListItem) _then) = __$CustomerListItemCopyWithImpl;
@override @useResult
$Res call({
 int customerId, String code, String name, String? zone, String creditLimit, int creditDays, PriceListRef priceList, EmployeeRef? salesperson, EntityStatus status
});


@override $PriceListRefCopyWith<$Res> get priceList;@override $EmployeeRefCopyWith<$Res>? get salesperson;

}
/// @nodoc
class __$CustomerListItemCopyWithImpl<$Res>
    implements _$CustomerListItemCopyWith<$Res> {
  __$CustomerListItemCopyWithImpl(this._self, this._then);

  final _CustomerListItem _self;
  final $Res Function(_CustomerListItem) _then;

/// Create a copy of CustomerListItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? customerId = null,Object? code = null,Object? name = null,Object? zone = freezed,Object? creditLimit = null,Object? creditDays = null,Object? priceList = null,Object? salesperson = freezed,Object? status = null,}) {
  return _then(_CustomerListItem(
customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,zone: freezed == zone ? _self.zone : zone // ignore: cast_nullable_to_non_nullable
as String?,creditLimit: null == creditLimit ? _self.creditLimit : creditLimit // ignore: cast_nullable_to_non_nullable
as String,creditDays: null == creditDays ? _self.creditDays : creditDays // ignore: cast_nullable_to_non_nullable
as int,priceList: null == priceList ? _self.priceList : priceList // ignore: cast_nullable_to_non_nullable
as PriceListRef,salesperson: freezed == salesperson ? _self.salesperson : salesperson // ignore: cast_nullable_to_non_nullable
as EmployeeRef?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus,
  ));
}

/// Create a copy of CustomerListItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceListRefCopyWith<$Res> get priceList {
  
  return $PriceListRefCopyWith<$Res>(_self.priceList, (value) {
    return _then(_self.copyWith(priceList: value));
  });
}/// Create a copy of CustomerListItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EmployeeRefCopyWith<$Res>? get salesperson {
    if (_self.salesperson == null) {
    return null;
  }

  return $EmployeeRefCopyWith<$Res>(_self.salesperson!, (value) {
    return _then(_self.copyWith(salesperson: value));
  });
}
}

// dart format on
