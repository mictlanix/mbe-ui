// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'to_purchase_filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ToPurchaseFilter {

 int? get facilityId; int get pageIndex;
/// Create a copy of ToPurchaseFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ToPurchaseFilterCopyWith<ToPurchaseFilter> get copyWith => _$ToPurchaseFilterCopyWithImpl<ToPurchaseFilter>(this as ToPurchaseFilter, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ToPurchaseFilter;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ToPurchaseFilter&&(identical(other.facilityId, _this.facilityId) || other.facilityId == _this.facilityId)&&(identical(other.pageIndex, _this.pageIndex) || other.pageIndex == _this.pageIndex));
}


@override
int get hashCode {
  final _this = this as ToPurchaseFilter;
  return Object.hash(runtimeType,_this.facilityId,_this.pageIndex);
}

@override
String toString() {
  final _this = this as ToPurchaseFilter;
  return 'ToPurchaseFilter(facilityId: ${_this.facilityId}, pageIndex: ${_this.pageIndex})';
}


}

/// @nodoc
abstract mixin class $ToPurchaseFilterCopyWith<$Res>  {
  factory $ToPurchaseFilterCopyWith(ToPurchaseFilter value, $Res Function(ToPurchaseFilter) _then) = _$ToPurchaseFilterCopyWithImpl;
@useResult
$Res call({
 int? facilityId, int pageIndex
});




}
/// @nodoc
class _$ToPurchaseFilterCopyWithImpl<$Res>
    implements $ToPurchaseFilterCopyWith<$Res> {
  _$ToPurchaseFilterCopyWithImpl(this._self, this._then);

  final ToPurchaseFilter _self;
  final $Res Function(ToPurchaseFilter) _then;

/// Create a copy of ToPurchaseFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? facilityId = freezed,Object? pageIndex = null,}) {
  return _then(ToPurchaseFilter(
facilityId: freezed == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int?,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ToPurchaseFilter].
extension ToPurchaseFilterPatterns on ToPurchaseFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ToPurchaseFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ToPurchaseFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ToPurchaseFilter value)  $default,){
final _that = this;
switch (_that) {
case _ToPurchaseFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ToPurchaseFilter value)?  $default,){
final _that = this;
switch (_that) {
case _ToPurchaseFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? facilityId,  int pageIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ToPurchaseFilter() when $default != null:
return $default(_that.facilityId,_that.pageIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? facilityId,  int pageIndex)  $default,) {final _that = this;
switch (_that) {
case _ToPurchaseFilter():
return $default(_that.facilityId,_that.pageIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? facilityId,  int pageIndex)?  $default,) {final _that = this;
switch (_that) {
case _ToPurchaseFilter() when $default != null:
return $default(_that.facilityId,_that.pageIndex);case _:
  return null;

}
}

}

/// @nodoc


class _ToPurchaseFilter extends ToPurchaseFilter {
  const _ToPurchaseFilter({this.facilityId, this.pageIndex = 0}): super._();
  

@override final  int? facilityId;
@override@JsonKey() final  int pageIndex;

/// Create a copy of ToPurchaseFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ToPurchaseFilterCopyWith<_ToPurchaseFilter> get copyWith => __$ToPurchaseFilterCopyWithImpl<_ToPurchaseFilter>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ToPurchaseFilter&&(identical(other.facilityId, facilityId) || other.facilityId == facilityId)&&(identical(other.pageIndex, pageIndex) || other.pageIndex == pageIndex));
}


@override
int get hashCode {
    return Object.hash(runtimeType,facilityId,pageIndex);
}

@override
String toString() {
    return 'ToPurchaseFilter(facilityId: $facilityId, pageIndex: $pageIndex)';
}


}

/// @nodoc
abstract mixin class _$ToPurchaseFilterCopyWith<$Res> implements $ToPurchaseFilterCopyWith<$Res> {
  factory _$ToPurchaseFilterCopyWith(_ToPurchaseFilter value, $Res Function(_ToPurchaseFilter) _then) = __$ToPurchaseFilterCopyWithImpl;
@override @useResult
$Res call({
 int? facilityId, int pageIndex
});




}
/// @nodoc
class __$ToPurchaseFilterCopyWithImpl<$Res>
    implements _$ToPurchaseFilterCopyWith<$Res> {
  __$ToPurchaseFilterCopyWithImpl(this._self, this._then);

  final _ToPurchaseFilter _self;
  final $Res Function(_ToPurchaseFilter) _then;

/// Create a copy of ToPurchaseFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? facilityId = freezed,Object? pageIndex = null,}) {
  return _then(_ToPurchaseFilter(
facilityId: freezed == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int?,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
