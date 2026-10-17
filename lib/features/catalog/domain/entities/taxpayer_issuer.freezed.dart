// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'taxpayer_issuer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TaxpayerIssuer {

 String get rfc; String get name; SatCatalogItem? get regime; FiscalCertificationProvider get provider; SatCatalogItem? get postalCode; String? get comment;
/// Create a copy of TaxpayerIssuer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaxpayerIssuerCopyWith<TaxpayerIssuer> get copyWith => _$TaxpayerIssuerCopyWithImpl<TaxpayerIssuer>(this as TaxpayerIssuer, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TaxpayerIssuer;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaxpayerIssuer&&(identical(other.rfc, _this.rfc) || other.rfc == _this.rfc)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.regime, _this.regime) || other.regime == _this.regime)&&(identical(other.provider, _this.provider) || other.provider == _this.provider)&&(identical(other.postalCode, _this.postalCode) || other.postalCode == _this.postalCode)&&(identical(other.comment, _this.comment) || other.comment == _this.comment));
}


@override
int get hashCode {
  final _this = this as TaxpayerIssuer;
  return Object.hash(runtimeType,_this.rfc,_this.name,_this.regime,_this.provider,_this.postalCode,_this.comment);
}

@override
String toString() {
  final _this = this as TaxpayerIssuer;
  return 'TaxpayerIssuer(rfc: ${_this.rfc}, name: ${_this.name}, regime: ${_this.regime}, provider: ${_this.provider}, postalCode: ${_this.postalCode}, comment: ${_this.comment})';
}


}

/// @nodoc
abstract mixin class $TaxpayerIssuerCopyWith<$Res>  {
  factory $TaxpayerIssuerCopyWith(TaxpayerIssuer value, $Res Function(TaxpayerIssuer) _then) = _$TaxpayerIssuerCopyWithImpl;
@useResult
$Res call({
 String rfc, String name, SatCatalogItem? regime, FiscalCertificationProvider provider, SatCatalogItem? postalCode, String? comment
});


$SatCatalogItemCopyWith<$Res>? get regime;$SatCatalogItemCopyWith<$Res>? get postalCode;

}
/// @nodoc
class _$TaxpayerIssuerCopyWithImpl<$Res>
    implements $TaxpayerIssuerCopyWith<$Res> {
  _$TaxpayerIssuerCopyWithImpl(this._self, this._then);

  final TaxpayerIssuer _self;
  final $Res Function(TaxpayerIssuer) _then;

/// Create a copy of TaxpayerIssuer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rfc = null,Object? name = null,Object? regime = freezed,Object? provider = null,Object? postalCode = freezed,Object? comment = freezed,}) {
  return _then(TaxpayerIssuer(
rfc: null == rfc ? _self.rfc : rfc // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,regime: freezed == regime ? _self.regime : regime // ignore: cast_nullable_to_non_nullable
as SatCatalogItem?,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as FiscalCertificationProvider,postalCode: freezed == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as SatCatalogItem?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of TaxpayerIssuer
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SatCatalogItemCopyWith<$Res>? get regime {
    if (_self.regime == null) {
    return null;
  }

  return $SatCatalogItemCopyWith<$Res>(_self.regime!, (value) {
    return _then(_self.copyWith(regime: value));
  });
}/// Create a copy of TaxpayerIssuer
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SatCatalogItemCopyWith<$Res>? get postalCode {
    if (_self.postalCode == null) {
    return null;
  }

  return $SatCatalogItemCopyWith<$Res>(_self.postalCode!, (value) {
    return _then(_self.copyWith(postalCode: value));
  });
}
}


/// Adds pattern-matching-related methods to [TaxpayerIssuer].
extension TaxpayerIssuerPatterns on TaxpayerIssuer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaxpayerIssuer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaxpayerIssuer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaxpayerIssuer value)  $default,){
final _that = this;
switch (_that) {
case _TaxpayerIssuer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaxpayerIssuer value)?  $default,){
final _that = this;
switch (_that) {
case _TaxpayerIssuer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String rfc,  String name,  SatCatalogItem? regime,  FiscalCertificationProvider provider,  SatCatalogItem? postalCode,  String? comment)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaxpayerIssuer() when $default != null:
return $default(_that.rfc,_that.name,_that.regime,_that.provider,_that.postalCode,_that.comment);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String rfc,  String name,  SatCatalogItem? regime,  FiscalCertificationProvider provider,  SatCatalogItem? postalCode,  String? comment)  $default,) {final _that = this;
switch (_that) {
case _TaxpayerIssuer():
return $default(_that.rfc,_that.name,_that.regime,_that.provider,_that.postalCode,_that.comment);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String rfc,  String name,  SatCatalogItem? regime,  FiscalCertificationProvider provider,  SatCatalogItem? postalCode,  String? comment)?  $default,) {final _that = this;
switch (_that) {
case _TaxpayerIssuer() when $default != null:
return $default(_that.rfc,_that.name,_that.regime,_that.provider,_that.postalCode,_that.comment);case _:
  return null;

}
}

}

/// @nodoc


class _TaxpayerIssuer implements TaxpayerIssuer {
  const _TaxpayerIssuer({required this.rfc, required this.name, this.regime, required this.provider, this.postalCode, this.comment});
  

@override final  String rfc;
@override final  String name;
@override final  SatCatalogItem? regime;
@override final  FiscalCertificationProvider provider;
@override final  SatCatalogItem? postalCode;
@override final  String? comment;

/// Create a copy of TaxpayerIssuer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaxpayerIssuerCopyWith<_TaxpayerIssuer> get copyWith => __$TaxpayerIssuerCopyWithImpl<_TaxpayerIssuer>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaxpayerIssuer&&(identical(other.rfc, rfc) || other.rfc == rfc)&&(identical(other.name, name) || other.name == name)&&(identical(other.regime, regime) || other.regime == regime)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.comment, comment) || other.comment == comment));
}


@override
int get hashCode {
    return Object.hash(runtimeType,rfc,name,regime,provider,postalCode,comment);
}

@override
String toString() {
    return 'TaxpayerIssuer(rfc: $rfc, name: $name, regime: $regime, provider: $provider, postalCode: $postalCode, comment: $comment)';
}


}

/// @nodoc
abstract mixin class _$TaxpayerIssuerCopyWith<$Res> implements $TaxpayerIssuerCopyWith<$Res> {
  factory _$TaxpayerIssuerCopyWith(_TaxpayerIssuer value, $Res Function(_TaxpayerIssuer) _then) = __$TaxpayerIssuerCopyWithImpl;
@override @useResult
$Res call({
 String rfc, String name, SatCatalogItem? regime, FiscalCertificationProvider provider, SatCatalogItem? postalCode, String? comment
});


@override $SatCatalogItemCopyWith<$Res>? get regime;@override $SatCatalogItemCopyWith<$Res>? get postalCode;

}
/// @nodoc
class __$TaxpayerIssuerCopyWithImpl<$Res>
    implements _$TaxpayerIssuerCopyWith<$Res> {
  __$TaxpayerIssuerCopyWithImpl(this._self, this._then);

  final _TaxpayerIssuer _self;
  final $Res Function(_TaxpayerIssuer) _then;

/// Create a copy of TaxpayerIssuer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rfc = null,Object? name = null,Object? regime = freezed,Object? provider = null,Object? postalCode = freezed,Object? comment = freezed,}) {
  return _then(_TaxpayerIssuer(
rfc: null == rfc ? _self.rfc : rfc // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,regime: freezed == regime ? _self.regime : regime // ignore: cast_nullable_to_non_nullable
as SatCatalogItem?,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as FiscalCertificationProvider,postalCode: freezed == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as SatCatalogItem?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of TaxpayerIssuer
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SatCatalogItemCopyWith<$Res>? get regime {
    if (_self.regime == null) {
    return null;
  }

  return $SatCatalogItemCopyWith<$Res>(_self.regime!, (value) {
    return _then(_self.copyWith(regime: value));
  });
}/// Create a copy of TaxpayerIssuer
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SatCatalogItemCopyWith<$Res>? get postalCode {
    if (_self.postalCode == null) {
    return null;
  }

  return $SatCatalogItemCopyWith<$Res>(_self.postalCode!, (value) {
    return _then(_self.copyWith(postalCode: value));
  });
}
}

// dart format on
