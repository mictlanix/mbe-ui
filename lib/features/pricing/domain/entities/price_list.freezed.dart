// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'price_list.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PriceList {

 int get priceListId; String get name;
/// Create a copy of PriceList
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PriceListCopyWith<PriceList> get copyWith => _$PriceListCopyWithImpl<PriceList>(this as PriceList, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PriceList;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PriceList&&(identical(other.priceListId, _this.priceListId) || other.priceListId == _this.priceListId)&&(identical(other.name, _this.name) || other.name == _this.name));
}


@override
int get hashCode {
  final _this = this as PriceList;
  return Object.hash(runtimeType,_this.priceListId,_this.name);
}

@override
String toString() {
  final _this = this as PriceList;
  return 'PriceList(priceListId: ${_this.priceListId}, name: ${_this.name})';
}


}

/// @nodoc
abstract mixin class $PriceListCopyWith<$Res>  {
  factory $PriceListCopyWith(PriceList value, $Res Function(PriceList) _then) = _$PriceListCopyWithImpl;
@useResult
$Res call({
 int priceListId, String name
});




}
/// @nodoc
class _$PriceListCopyWithImpl<$Res>
    implements $PriceListCopyWith<$Res> {
  _$PriceListCopyWithImpl(this._self, this._then);

  final PriceList _self;
  final $Res Function(PriceList) _then;

/// Create a copy of PriceList
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? priceListId = null,Object? name = null,}) {
  return _then(PriceList(
priceListId: null == priceListId ? _self.priceListId : priceListId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PriceList].
extension PriceListPatterns on PriceList {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PriceList value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PriceList() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PriceList value)  $default,){
final _that = this;
switch (_that) {
case _PriceList():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PriceList value)?  $default,){
final _that = this;
switch (_that) {
case _PriceList() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int priceListId,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PriceList() when $default != null:
return $default(_that.priceListId,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int priceListId,  String name)  $default,) {final _that = this;
switch (_that) {
case _PriceList():
return $default(_that.priceListId,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int priceListId,  String name)?  $default,) {final _that = this;
switch (_that) {
case _PriceList() when $default != null:
return $default(_that.priceListId,_that.name);case _:
  return null;

}
}

}

/// @nodoc


class _PriceList implements PriceList {
  const _PriceList({required this.priceListId, required this.name});
  

@override final  int priceListId;
@override final  String name;

/// Create a copy of PriceList
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PriceListCopyWith<_PriceList> get copyWith => __$PriceListCopyWithImpl<_PriceList>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PriceList&&(identical(other.priceListId, priceListId) || other.priceListId == priceListId)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode {
    return Object.hash(runtimeType,priceListId,name);
}

@override
String toString() {
    return 'PriceList(priceListId: $priceListId, name: $name)';
}


}

/// @nodoc
abstract mixin class _$PriceListCopyWith<$Res> implements $PriceListCopyWith<$Res> {
  factory _$PriceListCopyWith(_PriceList value, $Res Function(_PriceList) _then) = __$PriceListCopyWithImpl;
@override @useResult
$Res call({
 int priceListId, String name
});




}
/// @nodoc
class __$PriceListCopyWithImpl<$Res>
    implements _$PriceListCopyWith<$Res> {
  __$PriceListCopyWithImpl(this._self, this._then);

  final _PriceList _self;
  final $Res Function(_PriceList) _then;

/// Create a copy of PriceList
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? priceListId = null,Object? name = null,}) {
  return _then(_PriceList(
priceListId: null == priceListId ? _self.priceListId : priceListId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
