// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bank_account_inline_create_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BankAccountInlineCreateState {

 String get bankName; String get accountNumber; String get reference; String get routingNumber; String get comment; bool get submitting; BankAccount? get created; String? get error; String? get errorDetail; Map<String, String> get fieldErrors;
/// Create a copy of BankAccountInlineCreateState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BankAccountInlineCreateStateCopyWith<BankAccountInlineCreateState> get copyWith => _$BankAccountInlineCreateStateCopyWithImpl<BankAccountInlineCreateState>(this as BankAccountInlineCreateState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as BankAccountInlineCreateState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BankAccountInlineCreateState&&(identical(other.bankName, _this.bankName) || other.bankName == _this.bankName)&&(identical(other.accountNumber, _this.accountNumber) || other.accountNumber == _this.accountNumber)&&(identical(other.reference, _this.reference) || other.reference == _this.reference)&&(identical(other.routingNumber, _this.routingNumber) || other.routingNumber == _this.routingNumber)&&(identical(other.comment, _this.comment) || other.comment == _this.comment)&&(identical(other.submitting, _this.submitting) || other.submitting == _this.submitting)&&(identical(other.created, _this.created) || other.created == _this.created)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.errorDetail, _this.errorDetail) || other.errorDetail == _this.errorDetail)&&const DeepCollectionEquality().equals(other.fieldErrors, _this.fieldErrors));
}


@override
int get hashCode {
  final _this = this as BankAccountInlineCreateState;
  return Object.hash(runtimeType,_this.bankName,_this.accountNumber,_this.reference,_this.routingNumber,_this.comment,_this.submitting,_this.created,_this.error,_this.errorDetail,const DeepCollectionEquality().hash(_this.fieldErrors));
}

@override
String toString() {
  final _this = this as BankAccountInlineCreateState;
  return 'BankAccountInlineCreateState(bankName: ${_this.bankName}, accountNumber: ${_this.accountNumber}, reference: ${_this.reference}, routingNumber: ${_this.routingNumber}, comment: ${_this.comment}, submitting: ${_this.submitting}, created: ${_this.created}, error: ${_this.error}, errorDetail: ${_this.errorDetail}, fieldErrors: ${_this.fieldErrors})';
}


}

/// @nodoc
abstract mixin class $BankAccountInlineCreateStateCopyWith<$Res>  {
  factory $BankAccountInlineCreateStateCopyWith(BankAccountInlineCreateState value, $Res Function(BankAccountInlineCreateState) _then) = _$BankAccountInlineCreateStateCopyWithImpl;
@useResult
$Res call({
 String bankName, String accountNumber, String reference, String routingNumber, String comment, bool submitting, BankAccount? created, String? error, String? errorDetail, Map<String, String> fieldErrors
});


$BankAccountCopyWith<$Res>? get created;

}
/// @nodoc
class _$BankAccountInlineCreateStateCopyWithImpl<$Res>
    implements $BankAccountInlineCreateStateCopyWith<$Res> {
  _$BankAccountInlineCreateStateCopyWithImpl(this._self, this._then);

  final BankAccountInlineCreateState _self;
  final $Res Function(BankAccountInlineCreateState) _then;

/// Create a copy of BankAccountInlineCreateState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bankName = null,Object? accountNumber = null,Object? reference = null,Object? routingNumber = null,Object? comment = null,Object? submitting = null,Object? created = freezed,Object? error = freezed,Object? errorDetail = freezed,Object? fieldErrors = null,}) {
  return _then(BankAccountInlineCreateState(
bankName: null == bankName ? _self.bankName : bankName // ignore: cast_nullable_to_non_nullable
as String,accountNumber: null == accountNumber ? _self.accountNumber : accountNumber // ignore: cast_nullable_to_non_nullable
as String,reference: null == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String,routingNumber: null == routingNumber ? _self.routingNumber : routingNumber // ignore: cast_nullable_to_non_nullable
as String,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,created: freezed == created ? _self.created : created // ignore: cast_nullable_to_non_nullable
as BankAccount?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,errorDetail: freezed == errorDetail ? _self.errorDetail : errorDetail // ignore: cast_nullable_to_non_nullable
as String?,fieldErrors: null == fieldErrors ? _self.fieldErrors : fieldErrors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}
/// Create a copy of BankAccountInlineCreateState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BankAccountCopyWith<$Res>? get created {
    if (_self.created == null) {
    return null;
  }

  return $BankAccountCopyWith<$Res>(_self.created!, (value) {
    return _then(_self.copyWith(created: value));
  });
}
}


/// Adds pattern-matching-related methods to [BankAccountInlineCreateState].
extension BankAccountInlineCreateStatePatterns on BankAccountInlineCreateState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BankAccountInlineCreateState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BankAccountInlineCreateState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BankAccountInlineCreateState value)  $default,){
final _that = this;
switch (_that) {
case _BankAccountInlineCreateState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BankAccountInlineCreateState value)?  $default,){
final _that = this;
switch (_that) {
case _BankAccountInlineCreateState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String bankName,  String accountNumber,  String reference,  String routingNumber,  String comment,  bool submitting,  BankAccount? created,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BankAccountInlineCreateState() when $default != null:
return $default(_that.bankName,_that.accountNumber,_that.reference,_that.routingNumber,_that.comment,_that.submitting,_that.created,_that.error,_that.errorDetail,_that.fieldErrors);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String bankName,  String accountNumber,  String reference,  String routingNumber,  String comment,  bool submitting,  BankAccount? created,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)  $default,) {final _that = this;
switch (_that) {
case _BankAccountInlineCreateState():
return $default(_that.bankName,_that.accountNumber,_that.reference,_that.routingNumber,_that.comment,_that.submitting,_that.created,_that.error,_that.errorDetail,_that.fieldErrors);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String bankName,  String accountNumber,  String reference,  String routingNumber,  String comment,  bool submitting,  BankAccount? created,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)?  $default,) {final _that = this;
switch (_that) {
case _BankAccountInlineCreateState() when $default != null:
return $default(_that.bankName,_that.accountNumber,_that.reference,_that.routingNumber,_that.comment,_that.submitting,_that.created,_that.error,_that.errorDetail,_that.fieldErrors);case _:
  return null;

}
}

}

/// @nodoc


class _BankAccountInlineCreateState implements BankAccountInlineCreateState {
  const _BankAccountInlineCreateState({this.bankName = '', this.accountNumber = '', this.reference = '', this.routingNumber = '', this.comment = '', this.submitting = false, this.created, this.error, this.errorDetail,  Map<String, String> fieldErrors = const <String, String>{}}): _fieldErrors = fieldErrors;
  

@override@JsonKey() final  String bankName;
@override@JsonKey() final  String accountNumber;
@override@JsonKey() final  String reference;
@override@JsonKey() final  String routingNumber;
@override@JsonKey() final  String comment;
@override@JsonKey() final  bool submitting;
@override final  BankAccount? created;
@override final  String? error;
@override final  String? errorDetail;
 final  Map<String, String> _fieldErrors;
@override@JsonKey() Map<String, String> get fieldErrors {
  if (_fieldErrors is EqualUnmodifiableMapView) return _fieldErrors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_fieldErrors);
}


/// Create a copy of BankAccountInlineCreateState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BankAccountInlineCreateStateCopyWith<_BankAccountInlineCreateState> get copyWith => __$BankAccountInlineCreateStateCopyWithImpl<_BankAccountInlineCreateState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BankAccountInlineCreateState&&(identical(other.bankName, bankName) || other.bankName == bankName)&&(identical(other.accountNumber, accountNumber) || other.accountNumber == accountNumber)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.routingNumber, routingNumber) || other.routingNumber == routingNumber)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.created, created) || other.created == created)&&(identical(other.error, error) || other.error == error)&&(identical(other.errorDetail, errorDetail) || other.errorDetail == errorDetail)&&const DeepCollectionEquality().equals(other.fieldErrors, _fieldErrors));
}


@override
int get hashCode {
    return Object.hash(runtimeType,bankName,accountNumber,reference,routingNumber,comment,submitting,created,error,errorDetail,const DeepCollectionEquality().hash(_fieldErrors));
}

@override
String toString() {
    return 'BankAccountInlineCreateState(bankName: $bankName, accountNumber: $accountNumber, reference: $reference, routingNumber: $routingNumber, comment: $comment, submitting: $submitting, created: $created, error: $error, errorDetail: $errorDetail, fieldErrors: $fieldErrors)';
}


}

/// @nodoc
abstract mixin class _$BankAccountInlineCreateStateCopyWith<$Res> implements $BankAccountInlineCreateStateCopyWith<$Res> {
  factory _$BankAccountInlineCreateStateCopyWith(_BankAccountInlineCreateState value, $Res Function(_BankAccountInlineCreateState) _then) = __$BankAccountInlineCreateStateCopyWithImpl;
@override @useResult
$Res call({
 String bankName, String accountNumber, String reference, String routingNumber, String comment, bool submitting, BankAccount? created, String? error, String? errorDetail, Map<String, String> fieldErrors
});


@override $BankAccountCopyWith<$Res>? get created;

}
/// @nodoc
class __$BankAccountInlineCreateStateCopyWithImpl<$Res>
    implements _$BankAccountInlineCreateStateCopyWith<$Res> {
  __$BankAccountInlineCreateStateCopyWithImpl(this._self, this._then);

  final _BankAccountInlineCreateState _self;
  final $Res Function(_BankAccountInlineCreateState) _then;

/// Create a copy of BankAccountInlineCreateState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bankName = null,Object? accountNumber = null,Object? reference = null,Object? routingNumber = null,Object? comment = null,Object? submitting = null,Object? created = freezed,Object? error = freezed,Object? errorDetail = freezed,Object? fieldErrors = null,}) {
  return _then(_BankAccountInlineCreateState(
bankName: null == bankName ? _self.bankName : bankName // ignore: cast_nullable_to_non_nullable
as String,accountNumber: null == accountNumber ? _self.accountNumber : accountNumber // ignore: cast_nullable_to_non_nullable
as String,reference: null == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String,routingNumber: null == routingNumber ? _self.routingNumber : routingNumber // ignore: cast_nullable_to_non_nullable
as String,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,created: freezed == created ? _self.created : created // ignore: cast_nullable_to_non_nullable
as BankAccount?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,errorDetail: freezed == errorDetail ? _self.errorDetail : errorDetail // ignore: cast_nullable_to_non_nullable
as String?,fieldErrors: null == fieldErrors ? _self._fieldErrors : fieldErrors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

/// Create a copy of BankAccountInlineCreateState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BankAccountCopyWith<$Res>? get created {
    if (_self.created == null) {
    return null;
  }

  return $BankAccountCopyWith<$Res>(_self.created!, (value) {
    return _then(_self.copyWith(created: value));
  });
}
}

// dart format on
