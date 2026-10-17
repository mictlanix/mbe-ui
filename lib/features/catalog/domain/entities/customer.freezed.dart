// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'customer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PriceListRef {

 int get id; String get name;
/// Create a copy of PriceListRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PriceListRefCopyWith<PriceListRef> get copyWith => _$PriceListRefCopyWithImpl<PriceListRef>(this as PriceListRef, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PriceListRef;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PriceListRef&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name));
}


@override
int get hashCode {
  final _this = this as PriceListRef;
  return Object.hash(runtimeType,_this.id,_this.name);
}

@override
String toString() {
  final _this = this as PriceListRef;
  return 'PriceListRef(id: ${_this.id}, name: ${_this.name})';
}


}

/// @nodoc
abstract mixin class $PriceListRefCopyWith<$Res>  {
  factory $PriceListRefCopyWith(PriceListRef value, $Res Function(PriceListRef) _then) = _$PriceListRefCopyWithImpl;
@useResult
$Res call({
 int id, String name
});




}
/// @nodoc
class _$PriceListRefCopyWithImpl<$Res>
    implements $PriceListRefCopyWith<$Res> {
  _$PriceListRefCopyWithImpl(this._self, this._then);

  final PriceListRef _self;
  final $Res Function(PriceListRef) _then;

/// Create a copy of PriceListRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(PriceListRef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PriceListRef].
extension PriceListRefPatterns on PriceListRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PriceListRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PriceListRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PriceListRef value)  $default,){
final _that = this;
switch (_that) {
case _PriceListRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PriceListRef value)?  $default,){
final _that = this;
switch (_that) {
case _PriceListRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PriceListRef() when $default != null:
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name)  $default,) {final _that = this;
switch (_that) {
case _PriceListRef():
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name)?  $default,) {final _that = this;
switch (_that) {
case _PriceListRef() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc


class _PriceListRef implements PriceListRef {
  const _PriceListRef({required this.id, required this.name});
  

@override final  int id;
@override final  String name;

/// Create a copy of PriceListRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PriceListRefCopyWith<_PriceListRef> get copyWith => __$PriceListRefCopyWithImpl<_PriceListRef>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PriceListRef&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name);
}

@override
String toString() {
    return 'PriceListRef(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$PriceListRefCopyWith<$Res> implements $PriceListRefCopyWith<$Res> {
  factory _$PriceListRefCopyWith(_PriceListRef value, $Res Function(_PriceListRef) _then) = __$PriceListRefCopyWithImpl;
@override @useResult
$Res call({
 int id, String name
});




}
/// @nodoc
class __$PriceListRefCopyWithImpl<$Res>
    implements _$PriceListRefCopyWith<$Res> {
  __$PriceListRefCopyWithImpl(this._self, this._then);

  final _PriceListRef _self;
  final $Res Function(_PriceListRef) _then;

/// Create a copy of PriceListRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_PriceListRef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$EmployeeRef {

 int get id; String get name;
/// Create a copy of EmployeeRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmployeeRefCopyWith<EmployeeRef> get copyWith => _$EmployeeRefCopyWithImpl<EmployeeRef>(this as EmployeeRef, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as EmployeeRef;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmployeeRef&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name));
}


@override
int get hashCode {
  final _this = this as EmployeeRef;
  return Object.hash(runtimeType,_this.id,_this.name);
}

@override
String toString() {
  final _this = this as EmployeeRef;
  return 'EmployeeRef(id: ${_this.id}, name: ${_this.name})';
}


}

/// @nodoc
abstract mixin class $EmployeeRefCopyWith<$Res>  {
  factory $EmployeeRefCopyWith(EmployeeRef value, $Res Function(EmployeeRef) _then) = _$EmployeeRefCopyWithImpl;
@useResult
$Res call({
 int id, String name
});




}
/// @nodoc
class _$EmployeeRefCopyWithImpl<$Res>
    implements $EmployeeRefCopyWith<$Res> {
  _$EmployeeRefCopyWithImpl(this._self, this._then);

  final EmployeeRef _self;
  final $Res Function(EmployeeRef) _then;

/// Create a copy of EmployeeRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(EmployeeRef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [EmployeeRef].
extension EmployeeRefPatterns on EmployeeRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EmployeeRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EmployeeRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EmployeeRef value)  $default,){
final _that = this;
switch (_that) {
case _EmployeeRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EmployeeRef value)?  $default,){
final _that = this;
switch (_that) {
case _EmployeeRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EmployeeRef() when $default != null:
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name)  $default,) {final _that = this;
switch (_that) {
case _EmployeeRef():
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name)?  $default,) {final _that = this;
switch (_that) {
case _EmployeeRef() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc


class _EmployeeRef implements EmployeeRef {
  const _EmployeeRef({required this.id, required this.name});
  

@override final  int id;
@override final  String name;

/// Create a copy of EmployeeRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmployeeRefCopyWith<_EmployeeRef> get copyWith => __$EmployeeRefCopyWithImpl<_EmployeeRef>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmployeeRef&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name);
}

@override
String toString() {
    return 'EmployeeRef(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$EmployeeRefCopyWith<$Res> implements $EmployeeRefCopyWith<$Res> {
  factory _$EmployeeRefCopyWith(_EmployeeRef value, $Res Function(_EmployeeRef) _then) = __$EmployeeRefCopyWithImpl;
@override @useResult
$Res call({
 int id, String name
});




}
/// @nodoc
class __$EmployeeRefCopyWithImpl<$Res>
    implements _$EmployeeRefCopyWith<$Res> {
  __$EmployeeRefCopyWithImpl(this._self, this._then);

  final _EmployeeRef _self;
  final $Res Function(_EmployeeRef) _then;

/// Create a copy of EmployeeRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_EmployeeRef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$Customer {

 int get customerId; String get code; String get name; String? get zone; String get creditLimit; int get creditDays; PriceListRef get priceList; EmployeeRef? get salesperson; EntityStatus get status; String? get comment; List<AddressListItem> get addresses; List<Contact> get contacts; List<TaxpayerRecipient> get taxpayers;
/// Create a copy of Customer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomerCopyWith<Customer> get copyWith => _$CustomerCopyWithImpl<Customer>(this as Customer, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Customer;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Customer&&(identical(other.customerId, _this.customerId) || other.customerId == _this.customerId)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.zone, _this.zone) || other.zone == _this.zone)&&(identical(other.creditLimit, _this.creditLimit) || other.creditLimit == _this.creditLimit)&&(identical(other.creditDays, _this.creditDays) || other.creditDays == _this.creditDays)&&(identical(other.priceList, _this.priceList) || other.priceList == _this.priceList)&&(identical(other.salesperson, _this.salesperson) || other.salesperson == _this.salesperson)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.comment, _this.comment) || other.comment == _this.comment)&&const DeepCollectionEquality().equals(other.addresses, _this.addresses)&&const DeepCollectionEquality().equals(other.contacts, _this.contacts)&&const DeepCollectionEquality().equals(other.taxpayers, _this.taxpayers));
}


@override
int get hashCode {
  final _this = this as Customer;
  return Object.hash(runtimeType,_this.customerId,_this.code,_this.name,_this.zone,_this.creditLimit,_this.creditDays,_this.priceList,_this.salesperson,_this.status,_this.comment,const DeepCollectionEquality().hash(_this.addresses),const DeepCollectionEquality().hash(_this.contacts),const DeepCollectionEquality().hash(_this.taxpayers));
}

@override
String toString() {
  final _this = this as Customer;
  return 'Customer(customerId: ${_this.customerId}, code: ${_this.code}, name: ${_this.name}, zone: ${_this.zone}, creditLimit: ${_this.creditLimit}, creditDays: ${_this.creditDays}, priceList: ${_this.priceList}, salesperson: ${_this.salesperson}, status: ${_this.status}, comment: ${_this.comment}, addresses: ${_this.addresses}, contacts: ${_this.contacts}, taxpayers: ${_this.taxpayers})';
}


}

/// @nodoc
abstract mixin class $CustomerCopyWith<$Res>  {
  factory $CustomerCopyWith(Customer value, $Res Function(Customer) _then) = _$CustomerCopyWithImpl;
@useResult
$Res call({
 int customerId, String code, String name, String? zone, String creditLimit, int creditDays, PriceListRef priceList, EmployeeRef? salesperson, EntityStatus status, String? comment, List<AddressListItem> addresses, List<Contact> contacts, List<TaxpayerRecipient> taxpayers
});


$PriceListRefCopyWith<$Res> get priceList;$EmployeeRefCopyWith<$Res>? get salesperson;

}
/// @nodoc
class _$CustomerCopyWithImpl<$Res>
    implements $CustomerCopyWith<$Res> {
  _$CustomerCopyWithImpl(this._self, this._then);

  final Customer _self;
  final $Res Function(Customer) _then;

/// Create a copy of Customer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? customerId = null,Object? code = null,Object? name = null,Object? zone = freezed,Object? creditLimit = null,Object? creditDays = null,Object? priceList = null,Object? salesperson = freezed,Object? status = null,Object? comment = freezed,Object? addresses = null,Object? contacts = null,Object? taxpayers = null,}) {
  return _then(Customer(
customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,zone: freezed == zone ? _self.zone : zone // ignore: cast_nullable_to_non_nullable
as String?,creditLimit: null == creditLimit ? _self.creditLimit : creditLimit // ignore: cast_nullable_to_non_nullable
as String,creditDays: null == creditDays ? _self.creditDays : creditDays // ignore: cast_nullable_to_non_nullable
as int,priceList: null == priceList ? _self.priceList : priceList // ignore: cast_nullable_to_non_nullable
as PriceListRef,salesperson: freezed == salesperson ? _self.salesperson : salesperson // ignore: cast_nullable_to_non_nullable
as EmployeeRef?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,addresses: null == addresses ? _self.addresses : addresses // ignore: cast_nullable_to_non_nullable
as List<AddressListItem>,contacts: null == contacts ? _self.contacts : contacts // ignore: cast_nullable_to_non_nullable
as List<Contact>,taxpayers: null == taxpayers ? _self.taxpayers : taxpayers // ignore: cast_nullable_to_non_nullable
as List<TaxpayerRecipient>,
  ));
}
/// Create a copy of Customer
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceListRefCopyWith<$Res> get priceList {
  
  return $PriceListRefCopyWith<$Res>(_self.priceList, (value) {
    return _then(_self.copyWith(priceList: value));
  });
}/// Create a copy of Customer
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


/// Adds pattern-matching-related methods to [Customer].
extension CustomerPatterns on Customer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Customer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Customer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Customer value)  $default,){
final _that = this;
switch (_that) {
case _Customer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Customer value)?  $default,){
final _that = this;
switch (_that) {
case _Customer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int customerId,  String code,  String name,  String? zone,  String creditLimit,  int creditDays,  PriceListRef priceList,  EmployeeRef? salesperson,  EntityStatus status,  String? comment,  List<AddressListItem> addresses,  List<Contact> contacts,  List<TaxpayerRecipient> taxpayers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Customer() when $default != null:
return $default(_that.customerId,_that.code,_that.name,_that.zone,_that.creditLimit,_that.creditDays,_that.priceList,_that.salesperson,_that.status,_that.comment,_that.addresses,_that.contacts,_that.taxpayers);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int customerId,  String code,  String name,  String? zone,  String creditLimit,  int creditDays,  PriceListRef priceList,  EmployeeRef? salesperson,  EntityStatus status,  String? comment,  List<AddressListItem> addresses,  List<Contact> contacts,  List<TaxpayerRecipient> taxpayers)  $default,) {final _that = this;
switch (_that) {
case _Customer():
return $default(_that.customerId,_that.code,_that.name,_that.zone,_that.creditLimit,_that.creditDays,_that.priceList,_that.salesperson,_that.status,_that.comment,_that.addresses,_that.contacts,_that.taxpayers);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int customerId,  String code,  String name,  String? zone,  String creditLimit,  int creditDays,  PriceListRef priceList,  EmployeeRef? salesperson,  EntityStatus status,  String? comment,  List<AddressListItem> addresses,  List<Contact> contacts,  List<TaxpayerRecipient> taxpayers)?  $default,) {final _that = this;
switch (_that) {
case _Customer() when $default != null:
return $default(_that.customerId,_that.code,_that.name,_that.zone,_that.creditLimit,_that.creditDays,_that.priceList,_that.salesperson,_that.status,_that.comment,_that.addresses,_that.contacts,_that.taxpayers);case _:
  return null;

}
}

}

/// @nodoc


class _Customer implements Customer {
  const _Customer({required this.customerId, required this.code, required this.name, this.zone, required this.creditLimit, required this.creditDays, required this.priceList, this.salesperson, required this.status, this.comment,  List<AddressListItem> addresses = const <AddressListItem>[],  List<Contact> contacts = const <Contact>[],  List<TaxpayerRecipient> taxpayers = const <TaxpayerRecipient>[]}): _addresses = addresses,_contacts = contacts,_taxpayers = taxpayers;
  

@override final  int customerId;
@override final  String code;
@override final  String name;
@override final  String? zone;
@override final  String creditLimit;
@override final  int creditDays;
@override final  PriceListRef priceList;
@override final  EmployeeRef? salesperson;
@override final  EntityStatus status;
@override final  String? comment;
 final  List<AddressListItem> _addresses;
@override@JsonKey() List<AddressListItem> get addresses {
  if (_addresses is EqualUnmodifiableListView) return _addresses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_addresses);
}

 final  List<Contact> _contacts;
@override@JsonKey() List<Contact> get contacts {
  if (_contacts is EqualUnmodifiableListView) return _contacts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_contacts);
}

 final  List<TaxpayerRecipient> _taxpayers;
@override@JsonKey() List<TaxpayerRecipient> get taxpayers {
  if (_taxpayers is EqualUnmodifiableListView) return _taxpayers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_taxpayers);
}


/// Create a copy of Customer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomerCopyWith<_Customer> get copyWith => __$CustomerCopyWithImpl<_Customer>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Customer&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.zone, zone) || other.zone == zone)&&(identical(other.creditLimit, creditLimit) || other.creditLimit == creditLimit)&&(identical(other.creditDays, creditDays) || other.creditDays == creditDays)&&(identical(other.priceList, priceList) || other.priceList == priceList)&&(identical(other.salesperson, salesperson) || other.salesperson == salesperson)&&(identical(other.status, status) || other.status == status)&&(identical(other.comment, comment) || other.comment == comment)&&const DeepCollectionEquality().equals(other.addresses, _addresses)&&const DeepCollectionEquality().equals(other.contacts, _contacts)&&const DeepCollectionEquality().equals(other.taxpayers, _taxpayers));
}


@override
int get hashCode {
    return Object.hash(runtimeType,customerId,code,name,zone,creditLimit,creditDays,priceList,salesperson,status,comment,const DeepCollectionEquality().hash(_addresses),const DeepCollectionEquality().hash(_contacts),const DeepCollectionEquality().hash(_taxpayers));
}

@override
String toString() {
    return 'Customer(customerId: $customerId, code: $code, name: $name, zone: $zone, creditLimit: $creditLimit, creditDays: $creditDays, priceList: $priceList, salesperson: $salesperson, status: $status, comment: $comment, addresses: $addresses, contacts: $contacts, taxpayers: $taxpayers)';
}


}

/// @nodoc
abstract mixin class _$CustomerCopyWith<$Res> implements $CustomerCopyWith<$Res> {
  factory _$CustomerCopyWith(_Customer value, $Res Function(_Customer) _then) = __$CustomerCopyWithImpl;
@override @useResult
$Res call({
 int customerId, String code, String name, String? zone, String creditLimit, int creditDays, PriceListRef priceList, EmployeeRef? salesperson, EntityStatus status, String? comment, List<AddressListItem> addresses, List<Contact> contacts, List<TaxpayerRecipient> taxpayers
});


@override $PriceListRefCopyWith<$Res> get priceList;@override $EmployeeRefCopyWith<$Res>? get salesperson;

}
/// @nodoc
class __$CustomerCopyWithImpl<$Res>
    implements _$CustomerCopyWith<$Res> {
  __$CustomerCopyWithImpl(this._self, this._then);

  final _Customer _self;
  final $Res Function(_Customer) _then;

/// Create a copy of Customer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? customerId = null,Object? code = null,Object? name = null,Object? zone = freezed,Object? creditLimit = null,Object? creditDays = null,Object? priceList = null,Object? salesperson = freezed,Object? status = null,Object? comment = freezed,Object? addresses = null,Object? contacts = null,Object? taxpayers = null,}) {
  return _then(_Customer(
customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,zone: freezed == zone ? _self.zone : zone // ignore: cast_nullable_to_non_nullable
as String?,creditLimit: null == creditLimit ? _self.creditLimit : creditLimit // ignore: cast_nullable_to_non_nullable
as String,creditDays: null == creditDays ? _self.creditDays : creditDays // ignore: cast_nullable_to_non_nullable
as int,priceList: null == priceList ? _self.priceList : priceList // ignore: cast_nullable_to_non_nullable
as PriceListRef,salesperson: freezed == salesperson ? _self.salesperson : salesperson // ignore: cast_nullable_to_non_nullable
as EmployeeRef?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,addresses: null == addresses ? _self._addresses : addresses // ignore: cast_nullable_to_non_nullable
as List<AddressListItem>,contacts: null == contacts ? _self._contacts : contacts // ignore: cast_nullable_to_non_nullable
as List<Contact>,taxpayers: null == taxpayers ? _self._taxpayers : taxpayers // ignore: cast_nullable_to_non_nullable
as List<TaxpayerRecipient>,
  ));
}

/// Create a copy of Customer
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceListRefCopyWith<$Res> get priceList {
  
  return $PriceListRefCopyWith<$Res>(_self.priceList, (value) {
    return _then(_self.copyWith(priceList: value));
  });
}/// Create a copy of Customer
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
