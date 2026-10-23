// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'supplier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Supplier {

 int get supplierId; String get code; String get name; String? get zone; String get creditLimit; int get creditDays; String? get comment; List<AddressListItem> get addresses; List<Contact> get contacts; List<BankAccount> get bankAccounts;
/// Create a copy of Supplier
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SupplierCopyWith<Supplier> get copyWith => _$SupplierCopyWithImpl<Supplier>(this as Supplier, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Supplier;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Supplier&&(identical(other.supplierId, _this.supplierId) || other.supplierId == _this.supplierId)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.zone, _this.zone) || other.zone == _this.zone)&&(identical(other.creditLimit, _this.creditLimit) || other.creditLimit == _this.creditLimit)&&(identical(other.creditDays, _this.creditDays) || other.creditDays == _this.creditDays)&&(identical(other.comment, _this.comment) || other.comment == _this.comment)&&const DeepCollectionEquality().equals(other.addresses, _this.addresses)&&const DeepCollectionEquality().equals(other.contacts, _this.contacts)&&const DeepCollectionEquality().equals(other.bankAccounts, _this.bankAccounts));
}


@override
int get hashCode {
  final _this = this as Supplier;
  return Object.hash(runtimeType,_this.supplierId,_this.code,_this.name,_this.zone,_this.creditLimit,_this.creditDays,_this.comment,const DeepCollectionEquality().hash(_this.addresses),const DeepCollectionEquality().hash(_this.contacts),const DeepCollectionEquality().hash(_this.bankAccounts));
}

@override
String toString() {
  final _this = this as Supplier;
  return 'Supplier(supplierId: ${_this.supplierId}, code: ${_this.code}, name: ${_this.name}, zone: ${_this.zone}, creditLimit: ${_this.creditLimit}, creditDays: ${_this.creditDays}, comment: ${_this.comment}, addresses: ${_this.addresses}, contacts: ${_this.contacts}, bankAccounts: ${_this.bankAccounts})';
}


}

/// @nodoc
abstract mixin class $SupplierCopyWith<$Res>  {
  factory $SupplierCopyWith(Supplier value, $Res Function(Supplier) _then) = _$SupplierCopyWithImpl;
@useResult
$Res call({
 int supplierId, String code, String name, String? zone, String creditLimit, int creditDays, String? comment, List<AddressListItem> addresses, List<Contact> contacts, List<BankAccount> bankAccounts
});




}
/// @nodoc
class _$SupplierCopyWithImpl<$Res>
    implements $SupplierCopyWith<$Res> {
  _$SupplierCopyWithImpl(this._self, this._then);

  final Supplier _self;
  final $Res Function(Supplier) _then;

/// Create a copy of Supplier
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? supplierId = null,Object? code = null,Object? name = null,Object? zone = freezed,Object? creditLimit = null,Object? creditDays = null,Object? comment = freezed,Object? addresses = null,Object? contacts = null,Object? bankAccounts = null,}) {
  return _then(Supplier(
supplierId: null == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,zone: freezed == zone ? _self.zone : zone // ignore: cast_nullable_to_non_nullable
as String?,creditLimit: null == creditLimit ? _self.creditLimit : creditLimit // ignore: cast_nullable_to_non_nullable
as String,creditDays: null == creditDays ? _self.creditDays : creditDays // ignore: cast_nullable_to_non_nullable
as int,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,addresses: null == addresses ? _self.addresses : addresses // ignore: cast_nullable_to_non_nullable
as List<AddressListItem>,contacts: null == contacts ? _self.contacts : contacts // ignore: cast_nullable_to_non_nullable
as List<Contact>,bankAccounts: null == bankAccounts ? _self.bankAccounts : bankAccounts // ignore: cast_nullable_to_non_nullable
as List<BankAccount>,
  ));
}

}


/// Adds pattern-matching-related methods to [Supplier].
extension SupplierPatterns on Supplier {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Supplier value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Supplier() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Supplier value)  $default,){
final _that = this;
switch (_that) {
case _Supplier():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Supplier value)?  $default,){
final _that = this;
switch (_that) {
case _Supplier() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int supplierId,  String code,  String name,  String? zone,  String creditLimit,  int creditDays,  String? comment,  List<AddressListItem> addresses,  List<Contact> contacts,  List<BankAccount> bankAccounts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Supplier() when $default != null:
return $default(_that.supplierId,_that.code,_that.name,_that.zone,_that.creditLimit,_that.creditDays,_that.comment,_that.addresses,_that.contacts,_that.bankAccounts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int supplierId,  String code,  String name,  String? zone,  String creditLimit,  int creditDays,  String? comment,  List<AddressListItem> addresses,  List<Contact> contacts,  List<BankAccount> bankAccounts)  $default,) {final _that = this;
switch (_that) {
case _Supplier():
return $default(_that.supplierId,_that.code,_that.name,_that.zone,_that.creditLimit,_that.creditDays,_that.comment,_that.addresses,_that.contacts,_that.bankAccounts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int supplierId,  String code,  String name,  String? zone,  String creditLimit,  int creditDays,  String? comment,  List<AddressListItem> addresses,  List<Contact> contacts,  List<BankAccount> bankAccounts)?  $default,) {final _that = this;
switch (_that) {
case _Supplier() when $default != null:
return $default(_that.supplierId,_that.code,_that.name,_that.zone,_that.creditLimit,_that.creditDays,_that.comment,_that.addresses,_that.contacts,_that.bankAccounts);case _:
  return null;

}
}

}

/// @nodoc


class _Supplier implements Supplier {
  const _Supplier({required this.supplierId, required this.code, required this.name, this.zone, required this.creditLimit, required this.creditDays, this.comment,  List<AddressListItem> addresses = const <AddressListItem>[],  List<Contact> contacts = const <Contact>[],  List<BankAccount> bankAccounts = const <BankAccount>[]}): _addresses = addresses,_contacts = contacts,_bankAccounts = bankAccounts;
  

@override final  int supplierId;
@override final  String code;
@override final  String name;
@override final  String? zone;
@override final  String creditLimit;
@override final  int creditDays;
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

 final  List<BankAccount> _bankAccounts;
@override@JsonKey() List<BankAccount> get bankAccounts {
  if (_bankAccounts is EqualUnmodifiableListView) return _bankAccounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bankAccounts);
}


/// Create a copy of Supplier
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SupplierCopyWith<_Supplier> get copyWith => __$SupplierCopyWithImpl<_Supplier>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Supplier&&(identical(other.supplierId, supplierId) || other.supplierId == supplierId)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.zone, zone) || other.zone == zone)&&(identical(other.creditLimit, creditLimit) || other.creditLimit == creditLimit)&&(identical(other.creditDays, creditDays) || other.creditDays == creditDays)&&(identical(other.comment, comment) || other.comment == comment)&&const DeepCollectionEquality().equals(other.addresses, _addresses)&&const DeepCollectionEquality().equals(other.contacts, _contacts)&&const DeepCollectionEquality().equals(other.bankAccounts, _bankAccounts));
}


@override
int get hashCode {
    return Object.hash(runtimeType,supplierId,code,name,zone,creditLimit,creditDays,comment,const DeepCollectionEquality().hash(_addresses),const DeepCollectionEquality().hash(_contacts),const DeepCollectionEquality().hash(_bankAccounts));
}

@override
String toString() {
    return 'Supplier(supplierId: $supplierId, code: $code, name: $name, zone: $zone, creditLimit: $creditLimit, creditDays: $creditDays, comment: $comment, addresses: $addresses, contacts: $contacts, bankAccounts: $bankAccounts)';
}


}

/// @nodoc
abstract mixin class _$SupplierCopyWith<$Res> implements $SupplierCopyWith<$Res> {
  factory _$SupplierCopyWith(_Supplier value, $Res Function(_Supplier) _then) = __$SupplierCopyWithImpl;
@override @useResult
$Res call({
 int supplierId, String code, String name, String? zone, String creditLimit, int creditDays, String? comment, List<AddressListItem> addresses, List<Contact> contacts, List<BankAccount> bankAccounts
});




}
/// @nodoc
class __$SupplierCopyWithImpl<$Res>
    implements _$SupplierCopyWith<$Res> {
  __$SupplierCopyWithImpl(this._self, this._then);

  final _Supplier _self;
  final $Res Function(_Supplier) _then;

/// Create a copy of Supplier
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? supplierId = null,Object? code = null,Object? name = null,Object? zone = freezed,Object? creditLimit = null,Object? creditDays = null,Object? comment = freezed,Object? addresses = null,Object? contacts = null,Object? bankAccounts = null,}) {
  return _then(_Supplier(
supplierId: null == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,zone: freezed == zone ? _self.zone : zone // ignore: cast_nullable_to_non_nullable
as String?,creditLimit: null == creditLimit ? _self.creditLimit : creditLimit // ignore: cast_nullable_to_non_nullable
as String,creditDays: null == creditDays ? _self.creditDays : creditDays // ignore: cast_nullable_to_non_nullable
as int,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,addresses: null == addresses ? _self._addresses : addresses // ignore: cast_nullable_to_non_nullable
as List<AddressListItem>,contacts: null == contacts ? _self._contacts : contacts // ignore: cast_nullable_to_non_nullable
as List<Contact>,bankAccounts: null == bankAccounts ? _self._bankAccounts : bankAccounts // ignore: cast_nullable_to_non_nullable
as List<BankAccount>,
  ));
}


}

// dart format on
