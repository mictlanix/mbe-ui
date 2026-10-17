// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'taxpayer_recipient_list_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TaxpayerRecipientListItem {

 String get taxpayerRecipientId; String get name; String get email;
/// Create a copy of TaxpayerRecipientListItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaxpayerRecipientListItemCopyWith<TaxpayerRecipientListItem> get copyWith => _$TaxpayerRecipientListItemCopyWithImpl<TaxpayerRecipientListItem>(this as TaxpayerRecipientListItem, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TaxpayerRecipientListItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaxpayerRecipientListItem&&(identical(other.taxpayerRecipientId, _this.taxpayerRecipientId) || other.taxpayerRecipientId == _this.taxpayerRecipientId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.email, _this.email) || other.email == _this.email));
}


@override
int get hashCode {
  final _this = this as TaxpayerRecipientListItem;
  return Object.hash(runtimeType,_this.taxpayerRecipientId,_this.name,_this.email);
}

@override
String toString() {
  final _this = this as TaxpayerRecipientListItem;
  return 'TaxpayerRecipientListItem(taxpayerRecipientId: ${_this.taxpayerRecipientId}, name: ${_this.name}, email: ${_this.email})';
}


}

/// @nodoc
abstract mixin class $TaxpayerRecipientListItemCopyWith<$Res>  {
  factory $TaxpayerRecipientListItemCopyWith(TaxpayerRecipientListItem value, $Res Function(TaxpayerRecipientListItem) _then) = _$TaxpayerRecipientListItemCopyWithImpl;
@useResult
$Res call({
 String taxpayerRecipientId, String name, String email
});




}
/// @nodoc
class _$TaxpayerRecipientListItemCopyWithImpl<$Res>
    implements $TaxpayerRecipientListItemCopyWith<$Res> {
  _$TaxpayerRecipientListItemCopyWithImpl(this._self, this._then);

  final TaxpayerRecipientListItem _self;
  final $Res Function(TaxpayerRecipientListItem) _then;

/// Create a copy of TaxpayerRecipientListItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? taxpayerRecipientId = null,Object? name = null,Object? email = null,}) {
  return _then(TaxpayerRecipientListItem(
taxpayerRecipientId: null == taxpayerRecipientId ? _self.taxpayerRecipientId : taxpayerRecipientId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TaxpayerRecipientListItem].
extension TaxpayerRecipientListItemPatterns on TaxpayerRecipientListItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaxpayerRecipientListItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaxpayerRecipientListItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaxpayerRecipientListItem value)  $default,){
final _that = this;
switch (_that) {
case _TaxpayerRecipientListItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaxpayerRecipientListItem value)?  $default,){
final _that = this;
switch (_that) {
case _TaxpayerRecipientListItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String taxpayerRecipientId,  String name,  String email)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaxpayerRecipientListItem() when $default != null:
return $default(_that.taxpayerRecipientId,_that.name,_that.email);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String taxpayerRecipientId,  String name,  String email)  $default,) {final _that = this;
switch (_that) {
case _TaxpayerRecipientListItem():
return $default(_that.taxpayerRecipientId,_that.name,_that.email);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String taxpayerRecipientId,  String name,  String email)?  $default,) {final _that = this;
switch (_that) {
case _TaxpayerRecipientListItem() when $default != null:
return $default(_that.taxpayerRecipientId,_that.name,_that.email);case _:
  return null;

}
}

}

/// @nodoc


class _TaxpayerRecipientListItem implements TaxpayerRecipientListItem {
  const _TaxpayerRecipientListItem({required this.taxpayerRecipientId, required this.name, required this.email});
  

@override final  String taxpayerRecipientId;
@override final  String name;
@override final  String email;

/// Create a copy of TaxpayerRecipientListItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaxpayerRecipientListItemCopyWith<_TaxpayerRecipientListItem> get copyWith => __$TaxpayerRecipientListItemCopyWithImpl<_TaxpayerRecipientListItem>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaxpayerRecipientListItem&&(identical(other.taxpayerRecipientId, taxpayerRecipientId) || other.taxpayerRecipientId == taxpayerRecipientId)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email));
}


@override
int get hashCode {
    return Object.hash(runtimeType,taxpayerRecipientId,name,email);
}

@override
String toString() {
    return 'TaxpayerRecipientListItem(taxpayerRecipientId: $taxpayerRecipientId, name: $name, email: $email)';
}


}

/// @nodoc
abstract mixin class _$TaxpayerRecipientListItemCopyWith<$Res> implements $TaxpayerRecipientListItemCopyWith<$Res> {
  factory _$TaxpayerRecipientListItemCopyWith(_TaxpayerRecipientListItem value, $Res Function(_TaxpayerRecipientListItem) _then) = __$TaxpayerRecipientListItemCopyWithImpl;
@override @useResult
$Res call({
 String taxpayerRecipientId, String name, String email
});




}
/// @nodoc
class __$TaxpayerRecipientListItemCopyWithImpl<$Res>
    implements _$TaxpayerRecipientListItemCopyWith<$Res> {
  __$TaxpayerRecipientListItemCopyWithImpl(this._self, this._then);

  final _TaxpayerRecipientListItem _self;
  final $Res Function(_TaxpayerRecipientListItem) _then;

/// Create a copy of TaxpayerRecipientListItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? taxpayerRecipientId = null,Object? name = null,Object? email = null,}) {
  return _then(_TaxpayerRecipientListItem(
taxpayerRecipientId: null == taxpayerRecipientId ? _self.taxpayerRecipientId : taxpayerRecipientId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
