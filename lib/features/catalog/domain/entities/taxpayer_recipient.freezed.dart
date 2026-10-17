// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'taxpayer_recipient.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TaxpayerRecipient {

 String get taxpayerRecipientId; String get name; String get email; SatCatalogItem? get postalCode; SatCatalogItem? get regime;
/// Create a copy of TaxpayerRecipient
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaxpayerRecipientCopyWith<TaxpayerRecipient> get copyWith => _$TaxpayerRecipientCopyWithImpl<TaxpayerRecipient>(this as TaxpayerRecipient, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TaxpayerRecipient;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaxpayerRecipient&&(identical(other.taxpayerRecipientId, _this.taxpayerRecipientId) || other.taxpayerRecipientId == _this.taxpayerRecipientId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.postalCode, _this.postalCode) || other.postalCode == _this.postalCode)&&(identical(other.regime, _this.regime) || other.regime == _this.regime));
}


@override
int get hashCode {
  final _this = this as TaxpayerRecipient;
  return Object.hash(runtimeType,_this.taxpayerRecipientId,_this.name,_this.email,_this.postalCode,_this.regime);
}

@override
String toString() {
  final _this = this as TaxpayerRecipient;
  return 'TaxpayerRecipient(taxpayerRecipientId: ${_this.taxpayerRecipientId}, name: ${_this.name}, email: ${_this.email}, postalCode: ${_this.postalCode}, regime: ${_this.regime})';
}


}

/// @nodoc
abstract mixin class $TaxpayerRecipientCopyWith<$Res>  {
  factory $TaxpayerRecipientCopyWith(TaxpayerRecipient value, $Res Function(TaxpayerRecipient) _then) = _$TaxpayerRecipientCopyWithImpl;
@useResult
$Res call({
 String taxpayerRecipientId, String name, String email, SatCatalogItem? postalCode, SatCatalogItem? regime
});


$SatCatalogItemCopyWith<$Res>? get postalCode;$SatCatalogItemCopyWith<$Res>? get regime;

}
/// @nodoc
class _$TaxpayerRecipientCopyWithImpl<$Res>
    implements $TaxpayerRecipientCopyWith<$Res> {
  _$TaxpayerRecipientCopyWithImpl(this._self, this._then);

  final TaxpayerRecipient _self;
  final $Res Function(TaxpayerRecipient) _then;

/// Create a copy of TaxpayerRecipient
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? taxpayerRecipientId = null,Object? name = null,Object? email = null,Object? postalCode = freezed,Object? regime = freezed,}) {
  return _then(TaxpayerRecipient(
taxpayerRecipientId: null == taxpayerRecipientId ? _self.taxpayerRecipientId : taxpayerRecipientId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,postalCode: freezed == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as SatCatalogItem?,regime: freezed == regime ? _self.regime : regime // ignore: cast_nullable_to_non_nullable
as SatCatalogItem?,
  ));
}
/// Create a copy of TaxpayerRecipient
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
}/// Create a copy of TaxpayerRecipient
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
}
}


/// Adds pattern-matching-related methods to [TaxpayerRecipient].
extension TaxpayerRecipientPatterns on TaxpayerRecipient {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaxpayerRecipient value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaxpayerRecipient() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaxpayerRecipient value)  $default,){
final _that = this;
switch (_that) {
case _TaxpayerRecipient():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaxpayerRecipient value)?  $default,){
final _that = this;
switch (_that) {
case _TaxpayerRecipient() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String taxpayerRecipientId,  String name,  String email,  SatCatalogItem? postalCode,  SatCatalogItem? regime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaxpayerRecipient() when $default != null:
return $default(_that.taxpayerRecipientId,_that.name,_that.email,_that.postalCode,_that.regime);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String taxpayerRecipientId,  String name,  String email,  SatCatalogItem? postalCode,  SatCatalogItem? regime)  $default,) {final _that = this;
switch (_that) {
case _TaxpayerRecipient():
return $default(_that.taxpayerRecipientId,_that.name,_that.email,_that.postalCode,_that.regime);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String taxpayerRecipientId,  String name,  String email,  SatCatalogItem? postalCode,  SatCatalogItem? regime)?  $default,) {final _that = this;
switch (_that) {
case _TaxpayerRecipient() when $default != null:
return $default(_that.taxpayerRecipientId,_that.name,_that.email,_that.postalCode,_that.regime);case _:
  return null;

}
}

}

/// @nodoc


class _TaxpayerRecipient implements TaxpayerRecipient {
  const _TaxpayerRecipient({required this.taxpayerRecipientId, required this.name, required this.email, this.postalCode, this.regime});
  

@override final  String taxpayerRecipientId;
@override final  String name;
@override final  String email;
@override final  SatCatalogItem? postalCode;
@override final  SatCatalogItem? regime;

/// Create a copy of TaxpayerRecipient
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaxpayerRecipientCopyWith<_TaxpayerRecipient> get copyWith => __$TaxpayerRecipientCopyWithImpl<_TaxpayerRecipient>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaxpayerRecipient&&(identical(other.taxpayerRecipientId, taxpayerRecipientId) || other.taxpayerRecipientId == taxpayerRecipientId)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.regime, regime) || other.regime == regime));
}


@override
int get hashCode {
    return Object.hash(runtimeType,taxpayerRecipientId,name,email,postalCode,regime);
}

@override
String toString() {
    return 'TaxpayerRecipient(taxpayerRecipientId: $taxpayerRecipientId, name: $name, email: $email, postalCode: $postalCode, regime: $regime)';
}


}

/// @nodoc
abstract mixin class _$TaxpayerRecipientCopyWith<$Res> implements $TaxpayerRecipientCopyWith<$Res> {
  factory _$TaxpayerRecipientCopyWith(_TaxpayerRecipient value, $Res Function(_TaxpayerRecipient) _then) = __$TaxpayerRecipientCopyWithImpl;
@override @useResult
$Res call({
 String taxpayerRecipientId, String name, String email, SatCatalogItem? postalCode, SatCatalogItem? regime
});


@override $SatCatalogItemCopyWith<$Res>? get postalCode;@override $SatCatalogItemCopyWith<$Res>? get regime;

}
/// @nodoc
class __$TaxpayerRecipientCopyWithImpl<$Res>
    implements _$TaxpayerRecipientCopyWith<$Res> {
  __$TaxpayerRecipientCopyWithImpl(this._self, this._then);

  final _TaxpayerRecipient _self;
  final $Res Function(_TaxpayerRecipient) _then;

/// Create a copy of TaxpayerRecipient
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? taxpayerRecipientId = null,Object? name = null,Object? email = null,Object? postalCode = freezed,Object? regime = freezed,}) {
  return _then(_TaxpayerRecipient(
taxpayerRecipientId: null == taxpayerRecipientId ? _self.taxpayerRecipientId : taxpayerRecipientId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,postalCode: freezed == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as SatCatalogItem?,regime: freezed == regime ? _self.regime : regime // ignore: cast_nullable_to_non_nullable
as SatCatalogItem?,
  ));
}

/// Create a copy of TaxpayerRecipient
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
}/// Create a copy of TaxpayerRecipient
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
}
}

// dart format on
