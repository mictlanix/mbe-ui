// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'supplier_form_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SupplierFormState {

 int? get supplierId; String get code; String get name; String get zone; String get creditLimit; String get creditDays; String get comment; List<AddressListItem> get addresses; List<Contact> get contacts; List<BankAccount> get bankAccounts; bool get loading; bool get submitting; bool get saved; bool get deleted; String? get error; String? get errorDetail; Map<String, String> get fieldErrors;
/// Create a copy of SupplierFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SupplierFormStateCopyWith<SupplierFormState> get copyWith => _$SupplierFormStateCopyWithImpl<SupplierFormState>(this as SupplierFormState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SupplierFormState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SupplierFormState&&(identical(other.supplierId, _this.supplierId) || other.supplierId == _this.supplierId)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.zone, _this.zone) || other.zone == _this.zone)&&(identical(other.creditLimit, _this.creditLimit) || other.creditLimit == _this.creditLimit)&&(identical(other.creditDays, _this.creditDays) || other.creditDays == _this.creditDays)&&(identical(other.comment, _this.comment) || other.comment == _this.comment)&&const DeepCollectionEquality().equals(other.addresses, _this.addresses)&&const DeepCollectionEquality().equals(other.contacts, _this.contacts)&&const DeepCollectionEquality().equals(other.bankAccounts, _this.bankAccounts)&&(identical(other.loading, _this.loading) || other.loading == _this.loading)&&(identical(other.submitting, _this.submitting) || other.submitting == _this.submitting)&&(identical(other.saved, _this.saved) || other.saved == _this.saved)&&(identical(other.deleted, _this.deleted) || other.deleted == _this.deleted)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.errorDetail, _this.errorDetail) || other.errorDetail == _this.errorDetail)&&const DeepCollectionEquality().equals(other.fieldErrors, _this.fieldErrors));
}


@override
int get hashCode {
  final _this = this as SupplierFormState;
  return Object.hash(runtimeType,_this.supplierId,_this.code,_this.name,_this.zone,_this.creditLimit,_this.creditDays,_this.comment,const DeepCollectionEquality().hash(_this.addresses),const DeepCollectionEquality().hash(_this.contacts),const DeepCollectionEquality().hash(_this.bankAccounts),_this.loading,_this.submitting,_this.saved,_this.deleted,_this.error,_this.errorDetail,const DeepCollectionEquality().hash(_this.fieldErrors));
}

@override
String toString() {
  final _this = this as SupplierFormState;
  return 'SupplierFormState(supplierId: ${_this.supplierId}, code: ${_this.code}, name: ${_this.name}, zone: ${_this.zone}, creditLimit: ${_this.creditLimit}, creditDays: ${_this.creditDays}, comment: ${_this.comment}, addresses: ${_this.addresses}, contacts: ${_this.contacts}, bankAccounts: ${_this.bankAccounts}, loading: ${_this.loading}, submitting: ${_this.submitting}, saved: ${_this.saved}, deleted: ${_this.deleted}, error: ${_this.error}, errorDetail: ${_this.errorDetail}, fieldErrors: ${_this.fieldErrors})';
}


}

/// @nodoc
abstract mixin class $SupplierFormStateCopyWith<$Res>  {
  factory $SupplierFormStateCopyWith(SupplierFormState value, $Res Function(SupplierFormState) _then) = _$SupplierFormStateCopyWithImpl;
@useResult
$Res call({
 int? supplierId, String code, String name, String zone, String creditLimit, String creditDays, String comment, List<AddressListItem> addresses, List<Contact> contacts, List<BankAccount> bankAccounts, bool loading, bool submitting, bool saved, bool deleted, String? error, String? errorDetail, Map<String, String> fieldErrors
});




}
/// @nodoc
class _$SupplierFormStateCopyWithImpl<$Res>
    implements $SupplierFormStateCopyWith<$Res> {
  _$SupplierFormStateCopyWithImpl(this._self, this._then);

  final SupplierFormState _self;
  final $Res Function(SupplierFormState) _then;

/// Create a copy of SupplierFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? supplierId = freezed,Object? code = null,Object? name = null,Object? zone = null,Object? creditLimit = null,Object? creditDays = null,Object? comment = null,Object? addresses = null,Object? contacts = null,Object? bankAccounts = null,Object? loading = null,Object? submitting = null,Object? saved = null,Object? deleted = null,Object? error = freezed,Object? errorDetail = freezed,Object? fieldErrors = null,}) {
  return _then(SupplierFormState(
supplierId: freezed == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as int?,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,zone: null == zone ? _self.zone : zone // ignore: cast_nullable_to_non_nullable
as String,creditLimit: null == creditLimit ? _self.creditLimit : creditLimit // ignore: cast_nullable_to_non_nullable
as String,creditDays: null == creditDays ? _self.creditDays : creditDays // ignore: cast_nullable_to_non_nullable
as String,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String,addresses: null == addresses ? _self.addresses : addresses // ignore: cast_nullable_to_non_nullable
as List<AddressListItem>,contacts: null == contacts ? _self.contacts : contacts // ignore: cast_nullable_to_non_nullable
as List<Contact>,bankAccounts: null == bankAccounts ? _self.bankAccounts : bankAccounts // ignore: cast_nullable_to_non_nullable
as List<BankAccount>,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as bool,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,errorDetail: freezed == errorDetail ? _self.errorDetail : errorDetail // ignore: cast_nullable_to_non_nullable
as String?,fieldErrors: null == fieldErrors ? _self.fieldErrors : fieldErrors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

}


/// Adds pattern-matching-related methods to [SupplierFormState].
extension SupplierFormStatePatterns on SupplierFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SupplierFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SupplierFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SupplierFormState value)  $default,){
final _that = this;
switch (_that) {
case _SupplierFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SupplierFormState value)?  $default,){
final _that = this;
switch (_that) {
case _SupplierFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? supplierId,  String code,  String name,  String zone,  String creditLimit,  String creditDays,  String comment,  List<AddressListItem> addresses,  List<Contact> contacts,  List<BankAccount> bankAccounts,  bool loading,  bool submitting,  bool saved,  bool deleted,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SupplierFormState() when $default != null:
return $default(_that.supplierId,_that.code,_that.name,_that.zone,_that.creditLimit,_that.creditDays,_that.comment,_that.addresses,_that.contacts,_that.bankAccounts,_that.loading,_that.submitting,_that.saved,_that.deleted,_that.error,_that.errorDetail,_that.fieldErrors);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? supplierId,  String code,  String name,  String zone,  String creditLimit,  String creditDays,  String comment,  List<AddressListItem> addresses,  List<Contact> contacts,  List<BankAccount> bankAccounts,  bool loading,  bool submitting,  bool saved,  bool deleted,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)  $default,) {final _that = this;
switch (_that) {
case _SupplierFormState():
return $default(_that.supplierId,_that.code,_that.name,_that.zone,_that.creditLimit,_that.creditDays,_that.comment,_that.addresses,_that.contacts,_that.bankAccounts,_that.loading,_that.submitting,_that.saved,_that.deleted,_that.error,_that.errorDetail,_that.fieldErrors);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? supplierId,  String code,  String name,  String zone,  String creditLimit,  String creditDays,  String comment,  List<AddressListItem> addresses,  List<Contact> contacts,  List<BankAccount> bankAccounts,  bool loading,  bool submitting,  bool saved,  bool deleted,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)?  $default,) {final _that = this;
switch (_that) {
case _SupplierFormState() when $default != null:
return $default(_that.supplierId,_that.code,_that.name,_that.zone,_that.creditLimit,_that.creditDays,_that.comment,_that.addresses,_that.contacts,_that.bankAccounts,_that.loading,_that.submitting,_that.saved,_that.deleted,_that.error,_that.errorDetail,_that.fieldErrors);case _:
  return null;

}
}

}

/// @nodoc


class _SupplierFormState implements SupplierFormState {
  const _SupplierFormState({this.supplierId, this.code = '', this.name = '', this.zone = '', this.creditLimit = '', this.creditDays = '', this.comment = '',  List<AddressListItem> addresses = const <AddressListItem>[],  List<Contact> contacts = const <Contact>[],  List<BankAccount> bankAccounts = const <BankAccount>[], this.loading = false, this.submitting = false, this.saved = false, this.deleted = false, this.error, this.errorDetail,  Map<String, String> fieldErrors = const <String, String>{}}): _addresses = addresses,_contacts = contacts,_bankAccounts = bankAccounts,_fieldErrors = fieldErrors;
  

@override final  int? supplierId;
@override@JsonKey() final  String code;
@override@JsonKey() final  String name;
@override@JsonKey() final  String zone;
@override@JsonKey() final  String creditLimit;
@override@JsonKey() final  String creditDays;
@override@JsonKey() final  String comment;
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

@override@JsonKey() final  bool loading;
@override@JsonKey() final  bool submitting;
@override@JsonKey() final  bool saved;
@override@JsonKey() final  bool deleted;
@override final  String? error;
@override final  String? errorDetail;
 final  Map<String, String> _fieldErrors;
@override@JsonKey() Map<String, String> get fieldErrors {
  if (_fieldErrors is EqualUnmodifiableMapView) return _fieldErrors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_fieldErrors);
}


/// Create a copy of SupplierFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SupplierFormStateCopyWith<_SupplierFormState> get copyWith => __$SupplierFormStateCopyWithImpl<_SupplierFormState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SupplierFormState&&(identical(other.supplierId, supplierId) || other.supplierId == supplierId)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.zone, zone) || other.zone == zone)&&(identical(other.creditLimit, creditLimit) || other.creditLimit == creditLimit)&&(identical(other.creditDays, creditDays) || other.creditDays == creditDays)&&(identical(other.comment, comment) || other.comment == comment)&&const DeepCollectionEquality().equals(other.addresses, _addresses)&&const DeepCollectionEquality().equals(other.contacts, _contacts)&&const DeepCollectionEquality().equals(other.bankAccounts, _bankAccounts)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.saved, saved) || other.saved == saved)&&(identical(other.deleted, deleted) || other.deleted == deleted)&&(identical(other.error, error) || other.error == error)&&(identical(other.errorDetail, errorDetail) || other.errorDetail == errorDetail)&&const DeepCollectionEquality().equals(other.fieldErrors, _fieldErrors));
}


@override
int get hashCode {
    return Object.hash(runtimeType,supplierId,code,name,zone,creditLimit,creditDays,comment,const DeepCollectionEquality().hash(_addresses),const DeepCollectionEquality().hash(_contacts),const DeepCollectionEquality().hash(_bankAccounts),loading,submitting,saved,deleted,error,errorDetail,const DeepCollectionEquality().hash(_fieldErrors));
}

@override
String toString() {
    return 'SupplierFormState(supplierId: $supplierId, code: $code, name: $name, zone: $zone, creditLimit: $creditLimit, creditDays: $creditDays, comment: $comment, addresses: $addresses, contacts: $contacts, bankAccounts: $bankAccounts, loading: $loading, submitting: $submitting, saved: $saved, deleted: $deleted, error: $error, errorDetail: $errorDetail, fieldErrors: $fieldErrors)';
}


}

/// @nodoc
abstract mixin class _$SupplierFormStateCopyWith<$Res> implements $SupplierFormStateCopyWith<$Res> {
  factory _$SupplierFormStateCopyWith(_SupplierFormState value, $Res Function(_SupplierFormState) _then) = __$SupplierFormStateCopyWithImpl;
@override @useResult
$Res call({
 int? supplierId, String code, String name, String zone, String creditLimit, String creditDays, String comment, List<AddressListItem> addresses, List<Contact> contacts, List<BankAccount> bankAccounts, bool loading, bool submitting, bool saved, bool deleted, String? error, String? errorDetail, Map<String, String> fieldErrors
});




}
/// @nodoc
class __$SupplierFormStateCopyWithImpl<$Res>
    implements _$SupplierFormStateCopyWith<$Res> {
  __$SupplierFormStateCopyWithImpl(this._self, this._then);

  final _SupplierFormState _self;
  final $Res Function(_SupplierFormState) _then;

/// Create a copy of SupplierFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? supplierId = freezed,Object? code = null,Object? name = null,Object? zone = null,Object? creditLimit = null,Object? creditDays = null,Object? comment = null,Object? addresses = null,Object? contacts = null,Object? bankAccounts = null,Object? loading = null,Object? submitting = null,Object? saved = null,Object? deleted = null,Object? error = freezed,Object? errorDetail = freezed,Object? fieldErrors = null,}) {
  return _then(_SupplierFormState(
supplierId: freezed == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as int?,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,zone: null == zone ? _self.zone : zone // ignore: cast_nullable_to_non_nullable
as String,creditLimit: null == creditLimit ? _self.creditLimit : creditLimit // ignore: cast_nullable_to_non_nullable
as String,creditDays: null == creditDays ? _self.creditDays : creditDays // ignore: cast_nullable_to_non_nullable
as String,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String,addresses: null == addresses ? _self._addresses : addresses // ignore: cast_nullable_to_non_nullable
as List<AddressListItem>,contacts: null == contacts ? _self._contacts : contacts // ignore: cast_nullable_to_non_nullable
as List<Contact>,bankAccounts: null == bankAccounts ? _self._bankAccounts : bankAccounts // ignore: cast_nullable_to_non_nullable
as List<BankAccount>,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as bool,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,errorDetail: freezed == errorDetail ? _self.errorDetail : errorDetail // ignore: cast_nullable_to_non_nullable
as String?,fieldErrors: null == fieldErrors ? _self._fieldErrors : fieldErrors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}

// dart format on
