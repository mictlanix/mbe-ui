// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'taxpayer_issuer_list_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TaxpayerIssuerListItem {

 String get rfc; String? get name;
/// Create a copy of TaxpayerIssuerListItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaxpayerIssuerListItemCopyWith<TaxpayerIssuerListItem> get copyWith => _$TaxpayerIssuerListItemCopyWithImpl<TaxpayerIssuerListItem>(this as TaxpayerIssuerListItem, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TaxpayerIssuerListItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaxpayerIssuerListItem&&(identical(other.rfc, _this.rfc) || other.rfc == _this.rfc)&&(identical(other.name, _this.name) || other.name == _this.name));
}


@override
int get hashCode {
  final _this = this as TaxpayerIssuerListItem;
  return Object.hash(runtimeType,_this.rfc,_this.name);
}

@override
String toString() {
  final _this = this as TaxpayerIssuerListItem;
  return 'TaxpayerIssuerListItem(rfc: ${_this.rfc}, name: ${_this.name})';
}


}

/// @nodoc
abstract mixin class $TaxpayerIssuerListItemCopyWith<$Res>  {
  factory $TaxpayerIssuerListItemCopyWith(TaxpayerIssuerListItem value, $Res Function(TaxpayerIssuerListItem) _then) = _$TaxpayerIssuerListItemCopyWithImpl;
@useResult
$Res call({
 String rfc, String? name
});




}
/// @nodoc
class _$TaxpayerIssuerListItemCopyWithImpl<$Res>
    implements $TaxpayerIssuerListItemCopyWith<$Res> {
  _$TaxpayerIssuerListItemCopyWithImpl(this._self, this._then);

  final TaxpayerIssuerListItem _self;
  final $Res Function(TaxpayerIssuerListItem) _then;

/// Create a copy of TaxpayerIssuerListItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rfc = null,Object? name = freezed,}) {
  return _then(TaxpayerIssuerListItem(
rfc: null == rfc ? _self.rfc : rfc // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TaxpayerIssuerListItem].
extension TaxpayerIssuerListItemPatterns on TaxpayerIssuerListItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaxpayerIssuerListItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaxpayerIssuerListItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaxpayerIssuerListItem value)  $default,){
final _that = this;
switch (_that) {
case _TaxpayerIssuerListItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaxpayerIssuerListItem value)?  $default,){
final _that = this;
switch (_that) {
case _TaxpayerIssuerListItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String rfc,  String? name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaxpayerIssuerListItem() when $default != null:
return $default(_that.rfc,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String rfc,  String? name)  $default,) {final _that = this;
switch (_that) {
case _TaxpayerIssuerListItem():
return $default(_that.rfc,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String rfc,  String? name)?  $default,) {final _that = this;
switch (_that) {
case _TaxpayerIssuerListItem() when $default != null:
return $default(_that.rfc,_that.name);case _:
  return null;

}
}

}

/// @nodoc


class _TaxpayerIssuerListItem implements TaxpayerIssuerListItem {
  const _TaxpayerIssuerListItem({required this.rfc, this.name});
  

@override final  String rfc;
@override final  String? name;

/// Create a copy of TaxpayerIssuerListItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaxpayerIssuerListItemCopyWith<_TaxpayerIssuerListItem> get copyWith => __$TaxpayerIssuerListItemCopyWithImpl<_TaxpayerIssuerListItem>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaxpayerIssuerListItem&&(identical(other.rfc, rfc) || other.rfc == rfc)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode {
    return Object.hash(runtimeType,rfc,name);
}

@override
String toString() {
    return 'TaxpayerIssuerListItem(rfc: $rfc, name: $name)';
}


}

/// @nodoc
abstract mixin class _$TaxpayerIssuerListItemCopyWith<$Res> implements $TaxpayerIssuerListItemCopyWith<$Res> {
  factory _$TaxpayerIssuerListItemCopyWith(_TaxpayerIssuerListItem value, $Res Function(_TaxpayerIssuerListItem) _then) = __$TaxpayerIssuerListItemCopyWithImpl;
@override @useResult
$Res call({
 String rfc, String? name
});




}
/// @nodoc
class __$TaxpayerIssuerListItemCopyWithImpl<$Res>
    implements _$TaxpayerIssuerListItemCopyWith<$Res> {
  __$TaxpayerIssuerListItemCopyWithImpl(this._self, this._then);

  final _TaxpayerIssuerListItem _self;
  final $Res Function(_TaxpayerIssuerListItem) _then;

/// Create a copy of TaxpayerIssuerListItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rfc = null,Object? name = freezed,}) {
  return _then(_TaxpayerIssuerListItem(
rfc: null == rfc ? _self.rfc : rfc // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
