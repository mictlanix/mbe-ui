// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bank_account.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BankAccount {

 int get bankAccountId; String get bankName; String get accountNumber; String? get reference; String? get routingNumber; String? get comment;
/// Create a copy of BankAccount
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BankAccountCopyWith<BankAccount> get copyWith => _$BankAccountCopyWithImpl<BankAccount>(this as BankAccount, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as BankAccount;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BankAccount&&(identical(other.bankAccountId, _this.bankAccountId) || other.bankAccountId == _this.bankAccountId)&&(identical(other.bankName, _this.bankName) || other.bankName == _this.bankName)&&(identical(other.accountNumber, _this.accountNumber) || other.accountNumber == _this.accountNumber)&&(identical(other.reference, _this.reference) || other.reference == _this.reference)&&(identical(other.routingNumber, _this.routingNumber) || other.routingNumber == _this.routingNumber)&&(identical(other.comment, _this.comment) || other.comment == _this.comment));
}


@override
int get hashCode {
  final _this = this as BankAccount;
  return Object.hash(runtimeType,_this.bankAccountId,_this.bankName,_this.accountNumber,_this.reference,_this.routingNumber,_this.comment);
}

@override
String toString() {
  final _this = this as BankAccount;
  return 'BankAccount(bankAccountId: ${_this.bankAccountId}, bankName: ${_this.bankName}, accountNumber: ${_this.accountNumber}, reference: ${_this.reference}, routingNumber: ${_this.routingNumber}, comment: ${_this.comment})';
}


}

/// @nodoc
abstract mixin class $BankAccountCopyWith<$Res>  {
  factory $BankAccountCopyWith(BankAccount value, $Res Function(BankAccount) _then) = _$BankAccountCopyWithImpl;
@useResult
$Res call({
 int bankAccountId, String bankName, String accountNumber, String? reference, String? routingNumber, String? comment
});




}
/// @nodoc
class _$BankAccountCopyWithImpl<$Res>
    implements $BankAccountCopyWith<$Res> {
  _$BankAccountCopyWithImpl(this._self, this._then);

  final BankAccount _self;
  final $Res Function(BankAccount) _then;

/// Create a copy of BankAccount
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bankAccountId = null,Object? bankName = null,Object? accountNumber = null,Object? reference = freezed,Object? routingNumber = freezed,Object? comment = freezed,}) {
  return _then(BankAccount(
bankAccountId: null == bankAccountId ? _self.bankAccountId : bankAccountId // ignore: cast_nullable_to_non_nullable
as int,bankName: null == bankName ? _self.bankName : bankName // ignore: cast_nullable_to_non_nullable
as String,accountNumber: null == accountNumber ? _self.accountNumber : accountNumber // ignore: cast_nullable_to_non_nullable
as String,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,routingNumber: freezed == routingNumber ? _self.routingNumber : routingNumber // ignore: cast_nullable_to_non_nullable
as String?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BankAccount].
extension BankAccountPatterns on BankAccount {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BankAccount value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BankAccount() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BankAccount value)  $default,){
final _that = this;
switch (_that) {
case _BankAccount():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BankAccount value)?  $default,){
final _that = this;
switch (_that) {
case _BankAccount() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int bankAccountId,  String bankName,  String accountNumber,  String? reference,  String? routingNumber,  String? comment)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BankAccount() when $default != null:
return $default(_that.bankAccountId,_that.bankName,_that.accountNumber,_that.reference,_that.routingNumber,_that.comment);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int bankAccountId,  String bankName,  String accountNumber,  String? reference,  String? routingNumber,  String? comment)  $default,) {final _that = this;
switch (_that) {
case _BankAccount():
return $default(_that.bankAccountId,_that.bankName,_that.accountNumber,_that.reference,_that.routingNumber,_that.comment);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int bankAccountId,  String bankName,  String accountNumber,  String? reference,  String? routingNumber,  String? comment)?  $default,) {final _that = this;
switch (_that) {
case _BankAccount() when $default != null:
return $default(_that.bankAccountId,_that.bankName,_that.accountNumber,_that.reference,_that.routingNumber,_that.comment);case _:
  return null;

}
}

}

/// @nodoc


class _BankAccount extends BankAccount {
  const _BankAccount({required this.bankAccountId, required this.bankName, required this.accountNumber, this.reference, this.routingNumber, this.comment}): super._();
  

@override final  int bankAccountId;
@override final  String bankName;
@override final  String accountNumber;
@override final  String? reference;
@override final  String? routingNumber;
@override final  String? comment;

/// Create a copy of BankAccount
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BankAccountCopyWith<_BankAccount> get copyWith => __$BankAccountCopyWithImpl<_BankAccount>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BankAccount&&(identical(other.bankAccountId, bankAccountId) || other.bankAccountId == bankAccountId)&&(identical(other.bankName, bankName) || other.bankName == bankName)&&(identical(other.accountNumber, accountNumber) || other.accountNumber == accountNumber)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.routingNumber, routingNumber) || other.routingNumber == routingNumber)&&(identical(other.comment, comment) || other.comment == comment));
}


@override
int get hashCode {
    return Object.hash(runtimeType,bankAccountId,bankName,accountNumber,reference,routingNumber,comment);
}

@override
String toString() {
    return 'BankAccount(bankAccountId: $bankAccountId, bankName: $bankName, accountNumber: $accountNumber, reference: $reference, routingNumber: $routingNumber, comment: $comment)';
}


}

/// @nodoc
abstract mixin class _$BankAccountCopyWith<$Res> implements $BankAccountCopyWith<$Res> {
  factory _$BankAccountCopyWith(_BankAccount value, $Res Function(_BankAccount) _then) = __$BankAccountCopyWithImpl;
@override @useResult
$Res call({
 int bankAccountId, String bankName, String accountNumber, String? reference, String? routingNumber, String? comment
});




}
/// @nodoc
class __$BankAccountCopyWithImpl<$Res>
    implements _$BankAccountCopyWith<$Res> {
  __$BankAccountCopyWithImpl(this._self, this._then);

  final _BankAccount _self;
  final $Res Function(_BankAccount) _then;

/// Create a copy of BankAccount
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bankAccountId = null,Object? bankName = null,Object? accountNumber = null,Object? reference = freezed,Object? routingNumber = freezed,Object? comment = freezed,}) {
  return _then(_BankAccount(
bankAccountId: null == bankAccountId ? _self.bankAccountId : bankAccountId // ignore: cast_nullable_to_non_nullable
as int,bankName: null == bankName ? _self.bankName : bankName // ignore: cast_nullable_to_non_nullable
as String,accountNumber: null == accountNumber ? _self.accountNumber : accountNumber // ignore: cast_nullable_to_non_nullable
as String,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,routingNumber: freezed == routingNumber ? _self.routingNumber : routingNumber // ignore: cast_nullable_to_non_nullable
as String?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
