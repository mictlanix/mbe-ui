// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'customer_form_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CustomerFormState {

 int? get customerId; String get code; String get name; String get zone; String get creditLimit; String get creditDays; int? get priceListId; String get priceListDisplayText; int? get salespersonId; String get salespersonDisplayText; List<AddressListItem> get addresses; List<Contact> get contacts; List<TaxpayerRecipientListItem> get taxpayers; EntityStatus get status; String get comment; bool get loading; bool get submitting; bool get saved; bool get deleted; String? get error; String? get errorDetail; Map<String, String> get fieldErrors;
/// Create a copy of CustomerFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomerFormStateCopyWith<CustomerFormState> get copyWith => _$CustomerFormStateCopyWithImpl<CustomerFormState>(this as CustomerFormState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CustomerFormState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomerFormState&&(identical(other.customerId, _this.customerId) || other.customerId == _this.customerId)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.zone, _this.zone) || other.zone == _this.zone)&&(identical(other.creditLimit, _this.creditLimit) || other.creditLimit == _this.creditLimit)&&(identical(other.creditDays, _this.creditDays) || other.creditDays == _this.creditDays)&&(identical(other.priceListId, _this.priceListId) || other.priceListId == _this.priceListId)&&(identical(other.priceListDisplayText, _this.priceListDisplayText) || other.priceListDisplayText == _this.priceListDisplayText)&&(identical(other.salespersonId, _this.salespersonId) || other.salespersonId == _this.salespersonId)&&(identical(other.salespersonDisplayText, _this.salespersonDisplayText) || other.salespersonDisplayText == _this.salespersonDisplayText)&&const DeepCollectionEquality().equals(other.addresses, _this.addresses)&&const DeepCollectionEquality().equals(other.contacts, _this.contacts)&&const DeepCollectionEquality().equals(other.taxpayers, _this.taxpayers)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.comment, _this.comment) || other.comment == _this.comment)&&(identical(other.loading, _this.loading) || other.loading == _this.loading)&&(identical(other.submitting, _this.submitting) || other.submitting == _this.submitting)&&(identical(other.saved, _this.saved) || other.saved == _this.saved)&&(identical(other.deleted, _this.deleted) || other.deleted == _this.deleted)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.errorDetail, _this.errorDetail) || other.errorDetail == _this.errorDetail)&&const DeepCollectionEquality().equals(other.fieldErrors, _this.fieldErrors));
}


@override
int get hashCode {
  final _this = this as CustomerFormState;
  return Object.hashAll([runtimeType,_this.customerId,_this.code,_this.name,_this.zone,_this.creditLimit,_this.creditDays,_this.priceListId,_this.priceListDisplayText,_this.salespersonId,_this.salespersonDisplayText,const DeepCollectionEquality().hash(_this.addresses),const DeepCollectionEquality().hash(_this.contacts),const DeepCollectionEquality().hash(_this.taxpayers),_this.status,_this.comment,_this.loading,_this.submitting,_this.saved,_this.deleted,_this.error,_this.errorDetail,const DeepCollectionEquality().hash(_this.fieldErrors)]);
}

@override
String toString() {
  final _this = this as CustomerFormState;
  return 'CustomerFormState(customerId: ${_this.customerId}, code: ${_this.code}, name: ${_this.name}, zone: ${_this.zone}, creditLimit: ${_this.creditLimit}, creditDays: ${_this.creditDays}, priceListId: ${_this.priceListId}, priceListDisplayText: ${_this.priceListDisplayText}, salespersonId: ${_this.salespersonId}, salespersonDisplayText: ${_this.salespersonDisplayText}, addresses: ${_this.addresses}, contacts: ${_this.contacts}, taxpayers: ${_this.taxpayers}, status: ${_this.status}, comment: ${_this.comment}, loading: ${_this.loading}, submitting: ${_this.submitting}, saved: ${_this.saved}, deleted: ${_this.deleted}, error: ${_this.error}, errorDetail: ${_this.errorDetail}, fieldErrors: ${_this.fieldErrors})';
}


}

/// @nodoc
abstract mixin class $CustomerFormStateCopyWith<$Res>  {
  factory $CustomerFormStateCopyWith(CustomerFormState value, $Res Function(CustomerFormState) _then) = _$CustomerFormStateCopyWithImpl;
@useResult
$Res call({
 int? customerId, String code, String name, String zone, String creditLimit, String creditDays, int? priceListId, String priceListDisplayText, int? salespersonId, String salespersonDisplayText, List<AddressListItem> addresses, List<Contact> contacts, List<TaxpayerRecipientListItem> taxpayers, EntityStatus status, String comment, bool loading, bool submitting, bool saved, bool deleted, String? error, String? errorDetail, Map<String, String> fieldErrors
});




}
/// @nodoc
class _$CustomerFormStateCopyWithImpl<$Res>
    implements $CustomerFormStateCopyWith<$Res> {
  _$CustomerFormStateCopyWithImpl(this._self, this._then);

  final CustomerFormState _self;
  final $Res Function(CustomerFormState) _then;

/// Create a copy of CustomerFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? customerId = freezed,Object? code = null,Object? name = null,Object? zone = null,Object? creditLimit = null,Object? creditDays = null,Object? priceListId = freezed,Object? priceListDisplayText = null,Object? salespersonId = freezed,Object? salespersonDisplayText = null,Object? addresses = null,Object? contacts = null,Object? taxpayers = null,Object? status = null,Object? comment = null,Object? loading = null,Object? submitting = null,Object? saved = null,Object? deleted = null,Object? error = freezed,Object? errorDetail = freezed,Object? fieldErrors = null,}) {
  return _then(CustomerFormState(
customerId: freezed == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as int?,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,zone: null == zone ? _self.zone : zone // ignore: cast_nullable_to_non_nullable
as String,creditLimit: null == creditLimit ? _self.creditLimit : creditLimit // ignore: cast_nullable_to_non_nullable
as String,creditDays: null == creditDays ? _self.creditDays : creditDays // ignore: cast_nullable_to_non_nullable
as String,priceListId: freezed == priceListId ? _self.priceListId : priceListId // ignore: cast_nullable_to_non_nullable
as int?,priceListDisplayText: null == priceListDisplayText ? _self.priceListDisplayText : priceListDisplayText // ignore: cast_nullable_to_non_nullable
as String,salespersonId: freezed == salespersonId ? _self.salespersonId : salespersonId // ignore: cast_nullable_to_non_nullable
as int?,salespersonDisplayText: null == salespersonDisplayText ? _self.salespersonDisplayText : salespersonDisplayText // ignore: cast_nullable_to_non_nullable
as String,addresses: null == addresses ? _self.addresses : addresses // ignore: cast_nullable_to_non_nullable
as List<AddressListItem>,contacts: null == contacts ? _self.contacts : contacts // ignore: cast_nullable_to_non_nullable
as List<Contact>,taxpayers: null == taxpayers ? _self.taxpayers : taxpayers // ignore: cast_nullable_to_non_nullable
as List<TaxpayerRecipientListItem>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
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


/// Adds pattern-matching-related methods to [CustomerFormState].
extension CustomerFormStatePatterns on CustomerFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CustomerFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CustomerFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CustomerFormState value)  $default,){
final _that = this;
switch (_that) {
case _CustomerFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CustomerFormState value)?  $default,){
final _that = this;
switch (_that) {
case _CustomerFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? customerId,  String code,  String name,  String zone,  String creditLimit,  String creditDays,  int? priceListId,  String priceListDisplayText,  int? salespersonId,  String salespersonDisplayText,  List<AddressListItem> addresses,  List<Contact> contacts,  List<TaxpayerRecipientListItem> taxpayers,  EntityStatus status,  String comment,  bool loading,  bool submitting,  bool saved,  bool deleted,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CustomerFormState() when $default != null:
return $default(_that.customerId,_that.code,_that.name,_that.zone,_that.creditLimit,_that.creditDays,_that.priceListId,_that.priceListDisplayText,_that.salespersonId,_that.salespersonDisplayText,_that.addresses,_that.contacts,_that.taxpayers,_that.status,_that.comment,_that.loading,_that.submitting,_that.saved,_that.deleted,_that.error,_that.errorDetail,_that.fieldErrors);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? customerId,  String code,  String name,  String zone,  String creditLimit,  String creditDays,  int? priceListId,  String priceListDisplayText,  int? salespersonId,  String salespersonDisplayText,  List<AddressListItem> addresses,  List<Contact> contacts,  List<TaxpayerRecipientListItem> taxpayers,  EntityStatus status,  String comment,  bool loading,  bool submitting,  bool saved,  bool deleted,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)  $default,) {final _that = this;
switch (_that) {
case _CustomerFormState():
return $default(_that.customerId,_that.code,_that.name,_that.zone,_that.creditLimit,_that.creditDays,_that.priceListId,_that.priceListDisplayText,_that.salespersonId,_that.salespersonDisplayText,_that.addresses,_that.contacts,_that.taxpayers,_that.status,_that.comment,_that.loading,_that.submitting,_that.saved,_that.deleted,_that.error,_that.errorDetail,_that.fieldErrors);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? customerId,  String code,  String name,  String zone,  String creditLimit,  String creditDays,  int? priceListId,  String priceListDisplayText,  int? salespersonId,  String salespersonDisplayText,  List<AddressListItem> addresses,  List<Contact> contacts,  List<TaxpayerRecipientListItem> taxpayers,  EntityStatus status,  String comment,  bool loading,  bool submitting,  bool saved,  bool deleted,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)?  $default,) {final _that = this;
switch (_that) {
case _CustomerFormState() when $default != null:
return $default(_that.customerId,_that.code,_that.name,_that.zone,_that.creditLimit,_that.creditDays,_that.priceListId,_that.priceListDisplayText,_that.salespersonId,_that.salespersonDisplayText,_that.addresses,_that.contacts,_that.taxpayers,_that.status,_that.comment,_that.loading,_that.submitting,_that.saved,_that.deleted,_that.error,_that.errorDetail,_that.fieldErrors);case _:
  return null;

}
}

}

/// @nodoc


class _CustomerFormState implements CustomerFormState {
  const _CustomerFormState({this.customerId, this.code = '', this.name = '', this.zone = '', this.creditLimit = '', this.creditDays = '', this.priceListId, this.priceListDisplayText = '', this.salespersonId, this.salespersonDisplayText = '',  List<AddressListItem> addresses = const <AddressListItem>[],  List<Contact> contacts = const <Contact>[],  List<TaxpayerRecipientListItem> taxpayers = const <TaxpayerRecipientListItem>[], this.status = EntityStatus.active, this.comment = '', this.loading = false, this.submitting = false, this.saved = false, this.deleted = false, this.error, this.errorDetail,  Map<String, String> fieldErrors = const <String, String>{}}): _addresses = addresses,_contacts = contacts,_taxpayers = taxpayers,_fieldErrors = fieldErrors;
  

@override final  int? customerId;
@override@JsonKey() final  String code;
@override@JsonKey() final  String name;
@override@JsonKey() final  String zone;
@override@JsonKey() final  String creditLimit;
@override@JsonKey() final  String creditDays;
@override final  int? priceListId;
@override@JsonKey() final  String priceListDisplayText;
@override final  int? salespersonId;
@override@JsonKey() final  String salespersonDisplayText;
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

 final  List<TaxpayerRecipientListItem> _taxpayers;
@override@JsonKey() List<TaxpayerRecipientListItem> get taxpayers {
  if (_taxpayers is EqualUnmodifiableListView) return _taxpayers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_taxpayers);
}

@override@JsonKey() final  EntityStatus status;
@override@JsonKey() final  String comment;
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


/// Create a copy of CustomerFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomerFormStateCopyWith<_CustomerFormState> get copyWith => __$CustomerFormStateCopyWithImpl<_CustomerFormState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CustomerFormState&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.zone, zone) || other.zone == zone)&&(identical(other.creditLimit, creditLimit) || other.creditLimit == creditLimit)&&(identical(other.creditDays, creditDays) || other.creditDays == creditDays)&&(identical(other.priceListId, priceListId) || other.priceListId == priceListId)&&(identical(other.priceListDisplayText, priceListDisplayText) || other.priceListDisplayText == priceListDisplayText)&&(identical(other.salespersonId, salespersonId) || other.salespersonId == salespersonId)&&(identical(other.salespersonDisplayText, salespersonDisplayText) || other.salespersonDisplayText == salespersonDisplayText)&&const DeepCollectionEquality().equals(other.addresses, _addresses)&&const DeepCollectionEquality().equals(other.contacts, _contacts)&&const DeepCollectionEquality().equals(other.taxpayers, _taxpayers)&&(identical(other.status, status) || other.status == status)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.saved, saved) || other.saved == saved)&&(identical(other.deleted, deleted) || other.deleted == deleted)&&(identical(other.error, error) || other.error == error)&&(identical(other.errorDetail, errorDetail) || other.errorDetail == errorDetail)&&const DeepCollectionEquality().equals(other.fieldErrors, _fieldErrors));
}


@override
int get hashCode {
    return Object.hashAll([runtimeType,customerId,code,name,zone,creditLimit,creditDays,priceListId,priceListDisplayText,salespersonId,salespersonDisplayText,const DeepCollectionEquality().hash(_addresses),const DeepCollectionEquality().hash(_contacts),const DeepCollectionEquality().hash(_taxpayers),status,comment,loading,submitting,saved,deleted,error,errorDetail,const DeepCollectionEquality().hash(_fieldErrors)]);
}

@override
String toString() {
    return 'CustomerFormState(customerId: $customerId, code: $code, name: $name, zone: $zone, creditLimit: $creditLimit, creditDays: $creditDays, priceListId: $priceListId, priceListDisplayText: $priceListDisplayText, salespersonId: $salespersonId, salespersonDisplayText: $salespersonDisplayText, addresses: $addresses, contacts: $contacts, taxpayers: $taxpayers, status: $status, comment: $comment, loading: $loading, submitting: $submitting, saved: $saved, deleted: $deleted, error: $error, errorDetail: $errorDetail, fieldErrors: $fieldErrors)';
}


}

/// @nodoc
abstract mixin class _$CustomerFormStateCopyWith<$Res> implements $CustomerFormStateCopyWith<$Res> {
  factory _$CustomerFormStateCopyWith(_CustomerFormState value, $Res Function(_CustomerFormState) _then) = __$CustomerFormStateCopyWithImpl;
@override @useResult
$Res call({
 int? customerId, String code, String name, String zone, String creditLimit, String creditDays, int? priceListId, String priceListDisplayText, int? salespersonId, String salespersonDisplayText, List<AddressListItem> addresses, List<Contact> contacts, List<TaxpayerRecipientListItem> taxpayers, EntityStatus status, String comment, bool loading, bool submitting, bool saved, bool deleted, String? error, String? errorDetail, Map<String, String> fieldErrors
});




}
/// @nodoc
class __$CustomerFormStateCopyWithImpl<$Res>
    implements _$CustomerFormStateCopyWith<$Res> {
  __$CustomerFormStateCopyWithImpl(this._self, this._then);

  final _CustomerFormState _self;
  final $Res Function(_CustomerFormState) _then;

/// Create a copy of CustomerFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? customerId = freezed,Object? code = null,Object? name = null,Object? zone = null,Object? creditLimit = null,Object? creditDays = null,Object? priceListId = freezed,Object? priceListDisplayText = null,Object? salespersonId = freezed,Object? salespersonDisplayText = null,Object? addresses = null,Object? contacts = null,Object? taxpayers = null,Object? status = null,Object? comment = null,Object? loading = null,Object? submitting = null,Object? saved = null,Object? deleted = null,Object? error = freezed,Object? errorDetail = freezed,Object? fieldErrors = null,}) {
  return _then(_CustomerFormState(
customerId: freezed == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as int?,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,zone: null == zone ? _self.zone : zone // ignore: cast_nullable_to_non_nullable
as String,creditLimit: null == creditLimit ? _self.creditLimit : creditLimit // ignore: cast_nullable_to_non_nullable
as String,creditDays: null == creditDays ? _self.creditDays : creditDays // ignore: cast_nullable_to_non_nullable
as String,priceListId: freezed == priceListId ? _self.priceListId : priceListId // ignore: cast_nullable_to_non_nullable
as int?,priceListDisplayText: null == priceListDisplayText ? _self.priceListDisplayText : priceListDisplayText // ignore: cast_nullable_to_non_nullable
as String,salespersonId: freezed == salespersonId ? _self.salespersonId : salespersonId // ignore: cast_nullable_to_non_nullable
as int?,salespersonDisplayText: null == salespersonDisplayText ? _self.salespersonDisplayText : salespersonDisplayText // ignore: cast_nullable_to_non_nullable
as String,addresses: null == addresses ? _self._addresses : addresses // ignore: cast_nullable_to_non_nullable
as List<AddressListItem>,contacts: null == contacts ? _self._contacts : contacts // ignore: cast_nullable_to_non_nullable
as List<Contact>,taxpayers: null == taxpayers ? _self._taxpayers : taxpayers // ignore: cast_nullable_to_non_nullable
as List<TaxpayerRecipientListItem>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
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
