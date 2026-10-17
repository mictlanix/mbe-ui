// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'customers_list_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CustomerFilter {

 String get search; EntityStatus? get status; int? get priceListId; int? get salespersonId; int get pageIndex;
/// Create a copy of CustomerFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomerFilterCopyWith<CustomerFilter> get copyWith => _$CustomerFilterCopyWithImpl<CustomerFilter>(this as CustomerFilter, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CustomerFilter;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomerFilter&&(identical(other.search, _this.search) || other.search == _this.search)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.priceListId, _this.priceListId) || other.priceListId == _this.priceListId)&&(identical(other.salespersonId, _this.salespersonId) || other.salespersonId == _this.salespersonId)&&(identical(other.pageIndex, _this.pageIndex) || other.pageIndex == _this.pageIndex));
}


@override
int get hashCode {
  final _this = this as CustomerFilter;
  return Object.hash(runtimeType,_this.search,_this.status,_this.priceListId,_this.salespersonId,_this.pageIndex);
}

@override
String toString() {
  final _this = this as CustomerFilter;
  return 'CustomerFilter(search: ${_this.search}, status: ${_this.status}, priceListId: ${_this.priceListId}, salespersonId: ${_this.salespersonId}, pageIndex: ${_this.pageIndex})';
}


}

/// @nodoc
abstract mixin class $CustomerFilterCopyWith<$Res>  {
  factory $CustomerFilterCopyWith(CustomerFilter value, $Res Function(CustomerFilter) _then) = _$CustomerFilterCopyWithImpl;
@useResult
$Res call({
 String search, EntityStatus? status, int? priceListId, int? salespersonId, int pageIndex
});




}
/// @nodoc
class _$CustomerFilterCopyWithImpl<$Res>
    implements $CustomerFilterCopyWith<$Res> {
  _$CustomerFilterCopyWithImpl(this._self, this._then);

  final CustomerFilter _self;
  final $Res Function(CustomerFilter) _then;

/// Create a copy of CustomerFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? search = null,Object? status = freezed,Object? priceListId = freezed,Object? salespersonId = freezed,Object? pageIndex = null,}) {
  return _then(CustomerFilter(
search: null == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus?,priceListId: freezed == priceListId ? _self.priceListId : priceListId // ignore: cast_nullable_to_non_nullable
as int?,salespersonId: freezed == salespersonId ? _self.salespersonId : salespersonId // ignore: cast_nullable_to_non_nullable
as int?,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CustomerFilter].
extension CustomerFilterPatterns on CustomerFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CustomerFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CustomerFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CustomerFilter value)  $default,){
final _that = this;
switch (_that) {
case _CustomerFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CustomerFilter value)?  $default,){
final _that = this;
switch (_that) {
case _CustomerFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String search,  EntityStatus? status,  int? priceListId,  int? salespersonId,  int pageIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CustomerFilter() when $default != null:
return $default(_that.search,_that.status,_that.priceListId,_that.salespersonId,_that.pageIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String search,  EntityStatus? status,  int? priceListId,  int? salespersonId,  int pageIndex)  $default,) {final _that = this;
switch (_that) {
case _CustomerFilter():
return $default(_that.search,_that.status,_that.priceListId,_that.salespersonId,_that.pageIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String search,  EntityStatus? status,  int? priceListId,  int? salespersonId,  int pageIndex)?  $default,) {final _that = this;
switch (_that) {
case _CustomerFilter() when $default != null:
return $default(_that.search,_that.status,_that.priceListId,_that.salespersonId,_that.pageIndex);case _:
  return null;

}
}

}

/// @nodoc


class _CustomerFilter implements CustomerFilter {
  const _CustomerFilter({this.search = '', this.status, this.priceListId, this.salespersonId, this.pageIndex = 0});
  

@override@JsonKey() final  String search;
@override final  EntityStatus? status;
@override final  int? priceListId;
@override final  int? salespersonId;
@override@JsonKey() final  int pageIndex;

/// Create a copy of CustomerFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomerFilterCopyWith<_CustomerFilter> get copyWith => __$CustomerFilterCopyWithImpl<_CustomerFilter>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CustomerFilter&&(identical(other.search, search) || other.search == search)&&(identical(other.status, status) || other.status == status)&&(identical(other.priceListId, priceListId) || other.priceListId == priceListId)&&(identical(other.salespersonId, salespersonId) || other.salespersonId == salespersonId)&&(identical(other.pageIndex, pageIndex) || other.pageIndex == pageIndex));
}


@override
int get hashCode {
    return Object.hash(runtimeType,search,status,priceListId,salespersonId,pageIndex);
}

@override
String toString() {
    return 'CustomerFilter(search: $search, status: $status, priceListId: $priceListId, salespersonId: $salespersonId, pageIndex: $pageIndex)';
}


}

/// @nodoc
abstract mixin class _$CustomerFilterCopyWith<$Res> implements $CustomerFilterCopyWith<$Res> {
  factory _$CustomerFilterCopyWith(_CustomerFilter value, $Res Function(_CustomerFilter) _then) = __$CustomerFilterCopyWithImpl;
@override @useResult
$Res call({
 String search, EntityStatus? status, int? priceListId, int? salespersonId, int pageIndex
});




}
/// @nodoc
class __$CustomerFilterCopyWithImpl<$Res>
    implements _$CustomerFilterCopyWith<$Res> {
  __$CustomerFilterCopyWithImpl(this._self, this._then);

  final _CustomerFilter _self;
  final $Res Function(_CustomerFilter) _then;

/// Create a copy of CustomerFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? search = null,Object? status = freezed,Object? priceListId = freezed,Object? salespersonId = freezed,Object? pageIndex = null,}) {
  return _then(_CustomerFilter(
search: null == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus?,priceListId: freezed == priceListId ? _self.priceListId : priceListId // ignore: cast_nullable_to_non_nullable
as int?,salespersonId: freezed == salespersonId ? _self.salespersonId : salespersonId // ignore: cast_nullable_to_non_nullable
as int?,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
