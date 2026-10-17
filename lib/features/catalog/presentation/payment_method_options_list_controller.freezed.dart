// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_method_options_list_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PaymentMethodOptionFilter {

 String get search; int? get facilityId; EntityStatus? get status; int get pageIndex;
/// Create a copy of PaymentMethodOptionFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentMethodOptionFilterCopyWith<PaymentMethodOptionFilter> get copyWith => _$PaymentMethodOptionFilterCopyWithImpl<PaymentMethodOptionFilter>(this as PaymentMethodOptionFilter, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PaymentMethodOptionFilter;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentMethodOptionFilter&&(identical(other.search, _this.search) || other.search == _this.search)&&(identical(other.facilityId, _this.facilityId) || other.facilityId == _this.facilityId)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.pageIndex, _this.pageIndex) || other.pageIndex == _this.pageIndex));
}


@override
int get hashCode {
  final _this = this as PaymentMethodOptionFilter;
  return Object.hash(runtimeType,_this.search,_this.facilityId,_this.status,_this.pageIndex);
}

@override
String toString() {
  final _this = this as PaymentMethodOptionFilter;
  return 'PaymentMethodOptionFilter(search: ${_this.search}, facilityId: ${_this.facilityId}, status: ${_this.status}, pageIndex: ${_this.pageIndex})';
}


}

/// @nodoc
abstract mixin class $PaymentMethodOptionFilterCopyWith<$Res>  {
  factory $PaymentMethodOptionFilterCopyWith(PaymentMethodOptionFilter value, $Res Function(PaymentMethodOptionFilter) _then) = _$PaymentMethodOptionFilterCopyWithImpl;
@useResult
$Res call({
 String search, int? facilityId, EntityStatus? status, int pageIndex
});




}
/// @nodoc
class _$PaymentMethodOptionFilterCopyWithImpl<$Res>
    implements $PaymentMethodOptionFilterCopyWith<$Res> {
  _$PaymentMethodOptionFilterCopyWithImpl(this._self, this._then);

  final PaymentMethodOptionFilter _self;
  final $Res Function(PaymentMethodOptionFilter) _then;

/// Create a copy of PaymentMethodOptionFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? search = null,Object? facilityId = freezed,Object? status = freezed,Object? pageIndex = null,}) {
  return _then(PaymentMethodOptionFilter(
search: null == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String,facilityId: freezed == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus?,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentMethodOptionFilter].
extension PaymentMethodOptionFilterPatterns on PaymentMethodOptionFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentMethodOptionFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentMethodOptionFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentMethodOptionFilter value)  $default,){
final _that = this;
switch (_that) {
case _PaymentMethodOptionFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentMethodOptionFilter value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentMethodOptionFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String search,  int? facilityId,  EntityStatus? status,  int pageIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentMethodOptionFilter() when $default != null:
return $default(_that.search,_that.facilityId,_that.status,_that.pageIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String search,  int? facilityId,  EntityStatus? status,  int pageIndex)  $default,) {final _that = this;
switch (_that) {
case _PaymentMethodOptionFilter():
return $default(_that.search,_that.facilityId,_that.status,_that.pageIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String search,  int? facilityId,  EntityStatus? status,  int pageIndex)?  $default,) {final _that = this;
switch (_that) {
case _PaymentMethodOptionFilter() when $default != null:
return $default(_that.search,_that.facilityId,_that.status,_that.pageIndex);case _:
  return null;

}
}

}

/// @nodoc


class _PaymentMethodOptionFilter implements PaymentMethodOptionFilter {
  const _PaymentMethodOptionFilter({this.search = '', this.facilityId, this.status, this.pageIndex = 0});
  

@override@JsonKey() final  String search;
@override final  int? facilityId;
@override final  EntityStatus? status;
@override@JsonKey() final  int pageIndex;

/// Create a copy of PaymentMethodOptionFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentMethodOptionFilterCopyWith<_PaymentMethodOptionFilter> get copyWith => __$PaymentMethodOptionFilterCopyWithImpl<_PaymentMethodOptionFilter>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentMethodOptionFilter&&(identical(other.search, search) || other.search == search)&&(identical(other.facilityId, facilityId) || other.facilityId == facilityId)&&(identical(other.status, status) || other.status == status)&&(identical(other.pageIndex, pageIndex) || other.pageIndex == pageIndex));
}


@override
int get hashCode {
    return Object.hash(runtimeType,search,facilityId,status,pageIndex);
}

@override
String toString() {
    return 'PaymentMethodOptionFilter(search: $search, facilityId: $facilityId, status: $status, pageIndex: $pageIndex)';
}


}

/// @nodoc
abstract mixin class _$PaymentMethodOptionFilterCopyWith<$Res> implements $PaymentMethodOptionFilterCopyWith<$Res> {
  factory _$PaymentMethodOptionFilterCopyWith(_PaymentMethodOptionFilter value, $Res Function(_PaymentMethodOptionFilter) _then) = __$PaymentMethodOptionFilterCopyWithImpl;
@override @useResult
$Res call({
 String search, int? facilityId, EntityStatus? status, int pageIndex
});




}
/// @nodoc
class __$PaymentMethodOptionFilterCopyWithImpl<$Res>
    implements _$PaymentMethodOptionFilterCopyWith<$Res> {
  __$PaymentMethodOptionFilterCopyWithImpl(this._self, this._then);

  final _PaymentMethodOptionFilter _self;
  final $Res Function(_PaymentMethodOptionFilter) _then;

/// Create a copy of PaymentMethodOptionFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? search = null,Object? facilityId = freezed,Object? status = freezed,Object? pageIndex = null,}) {
  return _then(_PaymentMethodOptionFilter(
search: null == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String,facilityId: freezed == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus?,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
