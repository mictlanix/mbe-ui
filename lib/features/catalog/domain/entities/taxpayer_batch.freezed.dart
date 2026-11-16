// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'taxpayer_batch.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TaxpayerBatchAccount {

 String get bank; String get account; String get clabe; String get currency;
/// Create a copy of TaxpayerBatchAccount
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaxpayerBatchAccountCopyWith<TaxpayerBatchAccount> get copyWith => _$TaxpayerBatchAccountCopyWithImpl<TaxpayerBatchAccount>(this as TaxpayerBatchAccount, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TaxpayerBatchAccount;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaxpayerBatchAccount&&(identical(other.bank, _this.bank) || other.bank == _this.bank)&&(identical(other.account, _this.account) || other.account == _this.account)&&(identical(other.clabe, _this.clabe) || other.clabe == _this.clabe)&&(identical(other.currency, _this.currency) || other.currency == _this.currency));
}


@override
int get hashCode {
  final _this = this as TaxpayerBatchAccount;
  return Object.hash(runtimeType,_this.bank,_this.account,_this.clabe,_this.currency);
}

@override
String toString() {
  final _this = this as TaxpayerBatchAccount;
  return 'TaxpayerBatchAccount(bank: ${_this.bank}, account: ${_this.account}, clabe: ${_this.clabe}, currency: ${_this.currency})';
}


}

/// @nodoc
abstract mixin class $TaxpayerBatchAccountCopyWith<$Res>  {
  factory $TaxpayerBatchAccountCopyWith(TaxpayerBatchAccount value, $Res Function(TaxpayerBatchAccount) _then) = _$TaxpayerBatchAccountCopyWithImpl;
@useResult
$Res call({
 String bank, String account, String clabe, String currency
});




}
/// @nodoc
class _$TaxpayerBatchAccountCopyWithImpl<$Res>
    implements $TaxpayerBatchAccountCopyWith<$Res> {
  _$TaxpayerBatchAccountCopyWithImpl(this._self, this._then);

  final TaxpayerBatchAccount _self;
  final $Res Function(TaxpayerBatchAccount) _then;

/// Create a copy of TaxpayerBatchAccount
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bank = null,Object? account = null,Object? clabe = null,Object? currency = null,}) {
  return _then(TaxpayerBatchAccount(
bank: null == bank ? _self.bank : bank // ignore: cast_nullable_to_non_nullable
as String,account: null == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as String,clabe: null == clabe ? _self.clabe : clabe // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TaxpayerBatchAccount].
extension TaxpayerBatchAccountPatterns on TaxpayerBatchAccount {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaxpayerBatchAccount value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaxpayerBatchAccount() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaxpayerBatchAccount value)  $default,){
final _that = this;
switch (_that) {
case _TaxpayerBatchAccount():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaxpayerBatchAccount value)?  $default,){
final _that = this;
switch (_that) {
case _TaxpayerBatchAccount() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String bank,  String account,  String clabe,  String currency)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaxpayerBatchAccount() when $default != null:
return $default(_that.bank,_that.account,_that.clabe,_that.currency);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String bank,  String account,  String clabe,  String currency)  $default,) {final _that = this;
switch (_that) {
case _TaxpayerBatchAccount():
return $default(_that.bank,_that.account,_that.clabe,_that.currency);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String bank,  String account,  String clabe,  String currency)?  $default,) {final _that = this;
switch (_that) {
case _TaxpayerBatchAccount() when $default != null:
return $default(_that.bank,_that.account,_that.clabe,_that.currency);case _:
  return null;

}
}

}

/// @nodoc


class _TaxpayerBatchAccount extends TaxpayerBatchAccount {
  const _TaxpayerBatchAccount({this.bank = '', this.account = '', this.clabe = '', this.currency = ''}): super._();
  

@override@JsonKey() final  String bank;
@override@JsonKey() final  String account;
@override@JsonKey() final  String clabe;
@override@JsonKey() final  String currency;

/// Create a copy of TaxpayerBatchAccount
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaxpayerBatchAccountCopyWith<_TaxpayerBatchAccount> get copyWith => __$TaxpayerBatchAccountCopyWithImpl<_TaxpayerBatchAccount>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaxpayerBatchAccount&&(identical(other.bank, bank) || other.bank == bank)&&(identical(other.account, account) || other.account == account)&&(identical(other.clabe, clabe) || other.clabe == clabe)&&(identical(other.currency, currency) || other.currency == currency));
}


@override
int get hashCode {
    return Object.hash(runtimeType,bank,account,clabe,currency);
}

@override
String toString() {
    return 'TaxpayerBatchAccount(bank: $bank, account: $account, clabe: $clabe, currency: $currency)';
}


}

/// @nodoc
abstract mixin class _$TaxpayerBatchAccountCopyWith<$Res> implements $TaxpayerBatchAccountCopyWith<$Res> {
  factory _$TaxpayerBatchAccountCopyWith(_TaxpayerBatchAccount value, $Res Function(_TaxpayerBatchAccount) _then) = __$TaxpayerBatchAccountCopyWithImpl;
@override @useResult
$Res call({
 String bank, String account, String clabe, String currency
});




}
/// @nodoc
class __$TaxpayerBatchAccountCopyWithImpl<$Res>
    implements _$TaxpayerBatchAccountCopyWith<$Res> {
  __$TaxpayerBatchAccountCopyWithImpl(this._self, this._then);

  final _TaxpayerBatchAccount _self;
  final $Res Function(_TaxpayerBatchAccount) _then;

/// Create a copy of TaxpayerBatchAccount
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bank = null,Object? account = null,Object? clabe = null,Object? currency = null,}) {
  return _then(_TaxpayerBatchAccount(
bank: null == bank ? _self.bank : bank // ignore: cast_nullable_to_non_nullable
as String,account: null == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as String,clabe: null == clabe ? _self.clabe : clabe // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$TaxpayerBatchTemplate {

 String get name;/// A file name the print service looks up, not an upload. `null` is no
/// logo.
 String? get logo;/// Millimetres, ≥ 0. The API's default is 0.
 int get headerHeight;/// Millimetres, ≥ 0. The API's default is 15.
 int get footerHeight;/// In the order they print.
 List<TaxpayerBatchAccount> get accounts;
/// Create a copy of TaxpayerBatchTemplate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaxpayerBatchTemplateCopyWith<TaxpayerBatchTemplate> get copyWith => _$TaxpayerBatchTemplateCopyWithImpl<TaxpayerBatchTemplate>(this as TaxpayerBatchTemplate, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TaxpayerBatchTemplate;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaxpayerBatchTemplate&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.logo, _this.logo) || other.logo == _this.logo)&&(identical(other.headerHeight, _this.headerHeight) || other.headerHeight == _this.headerHeight)&&(identical(other.footerHeight, _this.footerHeight) || other.footerHeight == _this.footerHeight)&&const DeepCollectionEquality().equals(other.accounts, _this.accounts));
}


@override
int get hashCode {
  final _this = this as TaxpayerBatchTemplate;
  return Object.hash(runtimeType,_this.name,_this.logo,_this.headerHeight,_this.footerHeight,const DeepCollectionEquality().hash(_this.accounts));
}

@override
String toString() {
  final _this = this as TaxpayerBatchTemplate;
  return 'TaxpayerBatchTemplate(name: ${_this.name}, logo: ${_this.logo}, headerHeight: ${_this.headerHeight}, footerHeight: ${_this.footerHeight}, accounts: ${_this.accounts})';
}


}

/// @nodoc
abstract mixin class $TaxpayerBatchTemplateCopyWith<$Res>  {
  factory $TaxpayerBatchTemplateCopyWith(TaxpayerBatchTemplate value, $Res Function(TaxpayerBatchTemplate) _then) = _$TaxpayerBatchTemplateCopyWithImpl;
@useResult
$Res call({
 String name, String? logo, int headerHeight, int footerHeight, List<TaxpayerBatchAccount> accounts
});




}
/// @nodoc
class _$TaxpayerBatchTemplateCopyWithImpl<$Res>
    implements $TaxpayerBatchTemplateCopyWith<$Res> {
  _$TaxpayerBatchTemplateCopyWithImpl(this._self, this._then);

  final TaxpayerBatchTemplate _self;
  final $Res Function(TaxpayerBatchTemplate) _then;

/// Create a copy of TaxpayerBatchTemplate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? logo = freezed,Object? headerHeight = null,Object? footerHeight = null,Object? accounts = null,}) {
  return _then(TaxpayerBatchTemplate(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,logo: freezed == logo ? _self.logo : logo // ignore: cast_nullable_to_non_nullable
as String?,headerHeight: null == headerHeight ? _self.headerHeight : headerHeight // ignore: cast_nullable_to_non_nullable
as int,footerHeight: null == footerHeight ? _self.footerHeight : footerHeight // ignore: cast_nullable_to_non_nullable
as int,accounts: null == accounts ? _self.accounts : accounts // ignore: cast_nullable_to_non_nullable
as List<TaxpayerBatchAccount>,
  ));
}

}


/// Adds pattern-matching-related methods to [TaxpayerBatchTemplate].
extension TaxpayerBatchTemplatePatterns on TaxpayerBatchTemplate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaxpayerBatchTemplate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaxpayerBatchTemplate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaxpayerBatchTemplate value)  $default,){
final _that = this;
switch (_that) {
case _TaxpayerBatchTemplate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaxpayerBatchTemplate value)?  $default,){
final _that = this;
switch (_that) {
case _TaxpayerBatchTemplate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String? logo,  int headerHeight,  int footerHeight,  List<TaxpayerBatchAccount> accounts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaxpayerBatchTemplate() when $default != null:
return $default(_that.name,_that.logo,_that.headerHeight,_that.footerHeight,_that.accounts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String? logo,  int headerHeight,  int footerHeight,  List<TaxpayerBatchAccount> accounts)  $default,) {final _that = this;
switch (_that) {
case _TaxpayerBatchTemplate():
return $default(_that.name,_that.logo,_that.headerHeight,_that.footerHeight,_that.accounts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String? logo,  int headerHeight,  int footerHeight,  List<TaxpayerBatchAccount> accounts)?  $default,) {final _that = this;
switch (_that) {
case _TaxpayerBatchTemplate() when $default != null:
return $default(_that.name,_that.logo,_that.headerHeight,_that.footerHeight,_that.accounts);case _:
  return null;

}
}

}

/// @nodoc


class _TaxpayerBatchTemplate implements TaxpayerBatchTemplate {
  const _TaxpayerBatchTemplate({required this.name, this.logo, this.headerHeight = 0, this.footerHeight = 15,  List<TaxpayerBatchAccount> accounts = const <TaxpayerBatchAccount>[]}): _accounts = accounts;
  

@override final  String name;
/// A file name the print service looks up, not an upload. `null` is no
/// logo.
@override final  String? logo;
/// Millimetres, ≥ 0. The API's default is 0.
@override@JsonKey() final  int headerHeight;
/// Millimetres, ≥ 0. The API's default is 15.
@override@JsonKey() final  int footerHeight;
/// In the order they print.
 final  List<TaxpayerBatchAccount> _accounts;
/// In the order they print.
@override@JsonKey() List<TaxpayerBatchAccount> get accounts {
  if (_accounts is EqualUnmodifiableListView) return _accounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_accounts);
}


/// Create a copy of TaxpayerBatchTemplate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaxpayerBatchTemplateCopyWith<_TaxpayerBatchTemplate> get copyWith => __$TaxpayerBatchTemplateCopyWithImpl<_TaxpayerBatchTemplate>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaxpayerBatchTemplate&&(identical(other.name, name) || other.name == name)&&(identical(other.logo, logo) || other.logo == logo)&&(identical(other.headerHeight, headerHeight) || other.headerHeight == headerHeight)&&(identical(other.footerHeight, footerHeight) || other.footerHeight == footerHeight)&&const DeepCollectionEquality().equals(other.accounts, _accounts));
}


@override
int get hashCode {
    return Object.hash(runtimeType,name,logo,headerHeight,footerHeight,const DeepCollectionEquality().hash(_accounts));
}

@override
String toString() {
    return 'TaxpayerBatchTemplate(name: $name, logo: $logo, headerHeight: $headerHeight, footerHeight: $footerHeight, accounts: $accounts)';
}


}

/// @nodoc
abstract mixin class _$TaxpayerBatchTemplateCopyWith<$Res> implements $TaxpayerBatchTemplateCopyWith<$Res> {
  factory _$TaxpayerBatchTemplateCopyWith(_TaxpayerBatchTemplate value, $Res Function(_TaxpayerBatchTemplate) _then) = __$TaxpayerBatchTemplateCopyWithImpl;
@override @useResult
$Res call({
 String name, String? logo, int headerHeight, int footerHeight, List<TaxpayerBatchAccount> accounts
});




}
/// @nodoc
class __$TaxpayerBatchTemplateCopyWithImpl<$Res>
    implements _$TaxpayerBatchTemplateCopyWith<$Res> {
  __$TaxpayerBatchTemplateCopyWithImpl(this._self, this._then);

  final _TaxpayerBatchTemplate _self;
  final $Res Function(_TaxpayerBatchTemplate) _then;

/// Create a copy of TaxpayerBatchTemplate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? logo = freezed,Object? headerHeight = null,Object? footerHeight = null,Object? accounts = null,}) {
  return _then(_TaxpayerBatchTemplate(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,logo: freezed == logo ? _self.logo : logo // ignore: cast_nullable_to_non_nullable
as String?,headerHeight: null == headerHeight ? _self.headerHeight : headerHeight // ignore: cast_nullable_to_non_nullable
as int,footerHeight: null == footerHeight ? _self.footerHeight : footerHeight // ignore: cast_nullable_to_non_nullable
as int,accounts: null == accounts ? _self._accounts : accounts // ignore: cast_nullable_to_non_nullable
as List<TaxpayerBatchAccount>,
  ));
}


}

/// @nodoc
mixin _$TaxpayerBatch {

 int get taxpayerBatchId;/// The issuer's RFC.
 String get taxpayer;/// The prefix (the API's `batch`): 1–10 characters, unique per issuer.
 String get series;/// The raw API code, kept so a code this app doesn't know still renders.
 int get typeCode;/// `null` for an unknown [typeCode].
 FiscalDocumentKind? get kind; TaxpayerBatchTemplate get template;/// Once any of the issuer's fiscal documents carries the series, its
/// prefix and kind are locked and it can't be deleted (FR-010, FR-014).
 bool get inUse;
/// Create a copy of TaxpayerBatch
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaxpayerBatchCopyWith<TaxpayerBatch> get copyWith => _$TaxpayerBatchCopyWithImpl<TaxpayerBatch>(this as TaxpayerBatch, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TaxpayerBatch;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaxpayerBatch&&(identical(other.taxpayerBatchId, _this.taxpayerBatchId) || other.taxpayerBatchId == _this.taxpayerBatchId)&&(identical(other.taxpayer, _this.taxpayer) || other.taxpayer == _this.taxpayer)&&(identical(other.series, _this.series) || other.series == _this.series)&&(identical(other.typeCode, _this.typeCode) || other.typeCode == _this.typeCode)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.template, _this.template) || other.template == _this.template)&&(identical(other.inUse, _this.inUse) || other.inUse == _this.inUse));
}


@override
int get hashCode {
  final _this = this as TaxpayerBatch;
  return Object.hash(runtimeType,_this.taxpayerBatchId,_this.taxpayer,_this.series,_this.typeCode,_this.kind,_this.template,_this.inUse);
}

@override
String toString() {
  final _this = this as TaxpayerBatch;
  return 'TaxpayerBatch(taxpayerBatchId: ${_this.taxpayerBatchId}, taxpayer: ${_this.taxpayer}, series: ${_this.series}, typeCode: ${_this.typeCode}, kind: ${_this.kind}, template: ${_this.template}, inUse: ${_this.inUse})';
}


}

/// @nodoc
abstract mixin class $TaxpayerBatchCopyWith<$Res>  {
  factory $TaxpayerBatchCopyWith(TaxpayerBatch value, $Res Function(TaxpayerBatch) _then) = _$TaxpayerBatchCopyWithImpl;
@useResult
$Res call({
 int taxpayerBatchId, String taxpayer, String series, int typeCode, FiscalDocumentKind? kind, TaxpayerBatchTemplate template, bool inUse
});


$TaxpayerBatchTemplateCopyWith<$Res> get template;

}
/// @nodoc
class _$TaxpayerBatchCopyWithImpl<$Res>
    implements $TaxpayerBatchCopyWith<$Res> {
  _$TaxpayerBatchCopyWithImpl(this._self, this._then);

  final TaxpayerBatch _self;
  final $Res Function(TaxpayerBatch) _then;

/// Create a copy of TaxpayerBatch
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? taxpayerBatchId = null,Object? taxpayer = null,Object? series = null,Object? typeCode = null,Object? kind = freezed,Object? template = null,Object? inUse = null,}) {
  return _then(TaxpayerBatch(
taxpayerBatchId: null == taxpayerBatchId ? _self.taxpayerBatchId : taxpayerBatchId // ignore: cast_nullable_to_non_nullable
as int,taxpayer: null == taxpayer ? _self.taxpayer : taxpayer // ignore: cast_nullable_to_non_nullable
as String,series: null == series ? _self.series : series // ignore: cast_nullable_to_non_nullable
as String,typeCode: null == typeCode ? _self.typeCode : typeCode // ignore: cast_nullable_to_non_nullable
as int,kind: freezed == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as FiscalDocumentKind?,template: null == template ? _self.template : template // ignore: cast_nullable_to_non_nullable
as TaxpayerBatchTemplate,inUse: null == inUse ? _self.inUse : inUse // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of TaxpayerBatch
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TaxpayerBatchTemplateCopyWith<$Res> get template {
  
  return $TaxpayerBatchTemplateCopyWith<$Res>(_self.template, (value) {
    return _then(_self.copyWith(template: value));
  });
}
}


/// Adds pattern-matching-related methods to [TaxpayerBatch].
extension TaxpayerBatchPatterns on TaxpayerBatch {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaxpayerBatch value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaxpayerBatch() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaxpayerBatch value)  $default,){
final _that = this;
switch (_that) {
case _TaxpayerBatch():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaxpayerBatch value)?  $default,){
final _that = this;
switch (_that) {
case _TaxpayerBatch() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int taxpayerBatchId,  String taxpayer,  String series,  int typeCode,  FiscalDocumentKind? kind,  TaxpayerBatchTemplate template,  bool inUse)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaxpayerBatch() when $default != null:
return $default(_that.taxpayerBatchId,_that.taxpayer,_that.series,_that.typeCode,_that.kind,_that.template,_that.inUse);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int taxpayerBatchId,  String taxpayer,  String series,  int typeCode,  FiscalDocumentKind? kind,  TaxpayerBatchTemplate template,  bool inUse)  $default,) {final _that = this;
switch (_that) {
case _TaxpayerBatch():
return $default(_that.taxpayerBatchId,_that.taxpayer,_that.series,_that.typeCode,_that.kind,_that.template,_that.inUse);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int taxpayerBatchId,  String taxpayer,  String series,  int typeCode,  FiscalDocumentKind? kind,  TaxpayerBatchTemplate template,  bool inUse)?  $default,) {final _that = this;
switch (_that) {
case _TaxpayerBatch() when $default != null:
return $default(_that.taxpayerBatchId,_that.taxpayer,_that.series,_that.typeCode,_that.kind,_that.template,_that.inUse);case _:
  return null;

}
}

}

/// @nodoc


class _TaxpayerBatch implements TaxpayerBatch {
  const _TaxpayerBatch({required this.taxpayerBatchId, required this.taxpayer, required this.series, required this.typeCode, required this.kind, required this.template, required this.inUse});
  

@override final  int taxpayerBatchId;
/// The issuer's RFC.
@override final  String taxpayer;
/// The prefix (the API's `batch`): 1–10 characters, unique per issuer.
@override final  String series;
/// The raw API code, kept so a code this app doesn't know still renders.
@override final  int typeCode;
/// `null` for an unknown [typeCode].
@override final  FiscalDocumentKind? kind;
@override final  TaxpayerBatchTemplate template;
/// Once any of the issuer's fiscal documents carries the series, its
/// prefix and kind are locked and it can't be deleted (FR-010, FR-014).
@override final  bool inUse;

/// Create a copy of TaxpayerBatch
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaxpayerBatchCopyWith<_TaxpayerBatch> get copyWith => __$TaxpayerBatchCopyWithImpl<_TaxpayerBatch>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaxpayerBatch&&(identical(other.taxpayerBatchId, taxpayerBatchId) || other.taxpayerBatchId == taxpayerBatchId)&&(identical(other.taxpayer, taxpayer) || other.taxpayer == taxpayer)&&(identical(other.series, series) || other.series == series)&&(identical(other.typeCode, typeCode) || other.typeCode == typeCode)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.template, template) || other.template == template)&&(identical(other.inUse, inUse) || other.inUse == inUse));
}


@override
int get hashCode {
    return Object.hash(runtimeType,taxpayerBatchId,taxpayer,series,typeCode,kind,template,inUse);
}

@override
String toString() {
    return 'TaxpayerBatch(taxpayerBatchId: $taxpayerBatchId, taxpayer: $taxpayer, series: $series, typeCode: $typeCode, kind: $kind, template: $template, inUse: $inUse)';
}


}

/// @nodoc
abstract mixin class _$TaxpayerBatchCopyWith<$Res> implements $TaxpayerBatchCopyWith<$Res> {
  factory _$TaxpayerBatchCopyWith(_TaxpayerBatch value, $Res Function(_TaxpayerBatch) _then) = __$TaxpayerBatchCopyWithImpl;
@override @useResult
$Res call({
 int taxpayerBatchId, String taxpayer, String series, int typeCode, FiscalDocumentKind? kind, TaxpayerBatchTemplate template, bool inUse
});


@override $TaxpayerBatchTemplateCopyWith<$Res> get template;

}
/// @nodoc
class __$TaxpayerBatchCopyWithImpl<$Res>
    implements _$TaxpayerBatchCopyWith<$Res> {
  __$TaxpayerBatchCopyWithImpl(this._self, this._then);

  final _TaxpayerBatch _self;
  final $Res Function(_TaxpayerBatch) _then;

/// Create a copy of TaxpayerBatch
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? taxpayerBatchId = null,Object? taxpayer = null,Object? series = null,Object? typeCode = null,Object? kind = freezed,Object? template = null,Object? inUse = null,}) {
  return _then(_TaxpayerBatch(
taxpayerBatchId: null == taxpayerBatchId ? _self.taxpayerBatchId : taxpayerBatchId // ignore: cast_nullable_to_non_nullable
as int,taxpayer: null == taxpayer ? _self.taxpayer : taxpayer // ignore: cast_nullable_to_non_nullable
as String,series: null == series ? _self.series : series // ignore: cast_nullable_to_non_nullable
as String,typeCode: null == typeCode ? _self.typeCode : typeCode // ignore: cast_nullable_to_non_nullable
as int,kind: freezed == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as FiscalDocumentKind?,template: null == template ? _self.template : template // ignore: cast_nullable_to_non_nullable
as TaxpayerBatchTemplate,inUse: null == inUse ? _self.inUse : inUse // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of TaxpayerBatch
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TaxpayerBatchTemplateCopyWith<$Res> get template {
  
  return $TaxpayerBatchTemplateCopyWith<$Res>(_self.template, (value) {
    return _then(_self.copyWith(template: value));
  });
}
}

/// @nodoc
mixin _$TaxpayerBatchDraft {

 String get series; FiscalDocumentKind get kind; TaxpayerBatchTemplate get template;
/// Create a copy of TaxpayerBatchDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaxpayerBatchDraftCopyWith<TaxpayerBatchDraft> get copyWith => _$TaxpayerBatchDraftCopyWithImpl<TaxpayerBatchDraft>(this as TaxpayerBatchDraft, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TaxpayerBatchDraft;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaxpayerBatchDraft&&(identical(other.series, _this.series) || other.series == _this.series)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.template, _this.template) || other.template == _this.template));
}


@override
int get hashCode {
  final _this = this as TaxpayerBatchDraft;
  return Object.hash(runtimeType,_this.series,_this.kind,_this.template);
}

@override
String toString() {
  final _this = this as TaxpayerBatchDraft;
  return 'TaxpayerBatchDraft(series: ${_this.series}, kind: ${_this.kind}, template: ${_this.template})';
}


}

/// @nodoc
abstract mixin class $TaxpayerBatchDraftCopyWith<$Res>  {
  factory $TaxpayerBatchDraftCopyWith(TaxpayerBatchDraft value, $Res Function(TaxpayerBatchDraft) _then) = _$TaxpayerBatchDraftCopyWithImpl;
@useResult
$Res call({
 String series, FiscalDocumentKind kind, TaxpayerBatchTemplate template
});


$TaxpayerBatchTemplateCopyWith<$Res> get template;

}
/// @nodoc
class _$TaxpayerBatchDraftCopyWithImpl<$Res>
    implements $TaxpayerBatchDraftCopyWith<$Res> {
  _$TaxpayerBatchDraftCopyWithImpl(this._self, this._then);

  final TaxpayerBatchDraft _self;
  final $Res Function(TaxpayerBatchDraft) _then;

/// Create a copy of TaxpayerBatchDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? series = null,Object? kind = null,Object? template = null,}) {
  return _then(TaxpayerBatchDraft(
series: null == series ? _self.series : series // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as FiscalDocumentKind,template: null == template ? _self.template : template // ignore: cast_nullable_to_non_nullable
as TaxpayerBatchTemplate,
  ));
}
/// Create a copy of TaxpayerBatchDraft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TaxpayerBatchTemplateCopyWith<$Res> get template {
  
  return $TaxpayerBatchTemplateCopyWith<$Res>(_self.template, (value) {
    return _then(_self.copyWith(template: value));
  });
}
}


/// Adds pattern-matching-related methods to [TaxpayerBatchDraft].
extension TaxpayerBatchDraftPatterns on TaxpayerBatchDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaxpayerBatchDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaxpayerBatchDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaxpayerBatchDraft value)  $default,){
final _that = this;
switch (_that) {
case _TaxpayerBatchDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaxpayerBatchDraft value)?  $default,){
final _that = this;
switch (_that) {
case _TaxpayerBatchDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String series,  FiscalDocumentKind kind,  TaxpayerBatchTemplate template)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaxpayerBatchDraft() when $default != null:
return $default(_that.series,_that.kind,_that.template);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String series,  FiscalDocumentKind kind,  TaxpayerBatchTemplate template)  $default,) {final _that = this;
switch (_that) {
case _TaxpayerBatchDraft():
return $default(_that.series,_that.kind,_that.template);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String series,  FiscalDocumentKind kind,  TaxpayerBatchTemplate template)?  $default,) {final _that = this;
switch (_that) {
case _TaxpayerBatchDraft() when $default != null:
return $default(_that.series,_that.kind,_that.template);case _:
  return null;

}
}

}

/// @nodoc


class _TaxpayerBatchDraft implements TaxpayerBatchDraft {
  const _TaxpayerBatchDraft({required this.series, required this.kind, required this.template});
  

@override final  String series;
@override final  FiscalDocumentKind kind;
@override final  TaxpayerBatchTemplate template;

/// Create a copy of TaxpayerBatchDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaxpayerBatchDraftCopyWith<_TaxpayerBatchDraft> get copyWith => __$TaxpayerBatchDraftCopyWithImpl<_TaxpayerBatchDraft>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaxpayerBatchDraft&&(identical(other.series, series) || other.series == series)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.template, template) || other.template == template));
}


@override
int get hashCode {
    return Object.hash(runtimeType,series,kind,template);
}

@override
String toString() {
    return 'TaxpayerBatchDraft(series: $series, kind: $kind, template: $template)';
}


}

/// @nodoc
abstract mixin class _$TaxpayerBatchDraftCopyWith<$Res> implements $TaxpayerBatchDraftCopyWith<$Res> {
  factory _$TaxpayerBatchDraftCopyWith(_TaxpayerBatchDraft value, $Res Function(_TaxpayerBatchDraft) _then) = __$TaxpayerBatchDraftCopyWithImpl;
@override @useResult
$Res call({
 String series, FiscalDocumentKind kind, TaxpayerBatchTemplate template
});


@override $TaxpayerBatchTemplateCopyWith<$Res> get template;

}
/// @nodoc
class __$TaxpayerBatchDraftCopyWithImpl<$Res>
    implements _$TaxpayerBatchDraftCopyWith<$Res> {
  __$TaxpayerBatchDraftCopyWithImpl(this._self, this._then);

  final _TaxpayerBatchDraft _self;
  final $Res Function(_TaxpayerBatchDraft) _then;

/// Create a copy of TaxpayerBatchDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? series = null,Object? kind = null,Object? template = null,}) {
  return _then(_TaxpayerBatchDraft(
series: null == series ? _self.series : series // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as FiscalDocumentKind,template: null == template ? _self.template : template // ignore: cast_nullable_to_non_nullable
as TaxpayerBatchTemplate,
  ));
}

/// Create a copy of TaxpayerBatchDraft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TaxpayerBatchTemplateCopyWith<$Res> get template {
  
  return $TaxpayerBatchTemplateCopyWith<$Res>(_self.template, (value) {
    return _then(_self.copyWith(template: value));
  });
}
}

// dart format on
