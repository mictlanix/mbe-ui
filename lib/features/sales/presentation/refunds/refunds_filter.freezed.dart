// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'refunds_filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RefundsFilter {

 RefundStatus? get status; int? get customerId; int? get salesOrderId; int get pageIndex;
/// Create a copy of RefundsFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RefundsFilterCopyWith<RefundsFilter> get copyWith => _$RefundsFilterCopyWithImpl<RefundsFilter>(this as RefundsFilter, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as RefundsFilter;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RefundsFilter&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.customerId, _this.customerId) || other.customerId == _this.customerId)&&(identical(other.salesOrderId, _this.salesOrderId) || other.salesOrderId == _this.salesOrderId)&&(identical(other.pageIndex, _this.pageIndex) || other.pageIndex == _this.pageIndex));
}


@override
int get hashCode {
  final _this = this as RefundsFilter;
  return Object.hash(runtimeType,_this.status,_this.customerId,_this.salesOrderId,_this.pageIndex);
}

@override
String toString() {
  final _this = this as RefundsFilter;
  return 'RefundsFilter(status: ${_this.status}, customerId: ${_this.customerId}, salesOrderId: ${_this.salesOrderId}, pageIndex: ${_this.pageIndex})';
}


}

/// @nodoc
abstract mixin class $RefundsFilterCopyWith<$Res>  {
  factory $RefundsFilterCopyWith(RefundsFilter value, $Res Function(RefundsFilter) _then) = _$RefundsFilterCopyWithImpl;
@useResult
$Res call({
 RefundStatus? status, int? customerId, int? salesOrderId, int pageIndex
});




}
/// @nodoc
class _$RefundsFilterCopyWithImpl<$Res>
    implements $RefundsFilterCopyWith<$Res> {
  _$RefundsFilterCopyWithImpl(this._self, this._then);

  final RefundsFilter _self;
  final $Res Function(RefundsFilter) _then;

/// Create a copy of RefundsFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = freezed,Object? customerId = freezed,Object? salesOrderId = freezed,Object? pageIndex = null,}) {
  return _then(RefundsFilter(
status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RefundStatus?,customerId: freezed == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as int?,salesOrderId: freezed == salesOrderId ? _self.salesOrderId : salesOrderId // ignore: cast_nullable_to_non_nullable
as int?,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RefundsFilter].
extension RefundsFilterPatterns on RefundsFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RefundsFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RefundsFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RefundsFilter value)  $default,){
final _that = this;
switch (_that) {
case _RefundsFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RefundsFilter value)?  $default,){
final _that = this;
switch (_that) {
case _RefundsFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RefundStatus? status,  int? customerId,  int? salesOrderId,  int pageIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RefundsFilter() when $default != null:
return $default(_that.status,_that.customerId,_that.salesOrderId,_that.pageIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RefundStatus? status,  int? customerId,  int? salesOrderId,  int pageIndex)  $default,) {final _that = this;
switch (_that) {
case _RefundsFilter():
return $default(_that.status,_that.customerId,_that.salesOrderId,_that.pageIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RefundStatus? status,  int? customerId,  int? salesOrderId,  int pageIndex)?  $default,) {final _that = this;
switch (_that) {
case _RefundsFilter() when $default != null:
return $default(_that.status,_that.customerId,_that.salesOrderId,_that.pageIndex);case _:
  return null;

}
}

}

/// @nodoc


class _RefundsFilter extends RefundsFilter {
  const _RefundsFilter({this.status, this.customerId, this.salesOrderId, this.pageIndex = 0}): super._();
  

@override final  RefundStatus? status;
@override final  int? customerId;
@override final  int? salesOrderId;
@override@JsonKey() final  int pageIndex;

/// Create a copy of RefundsFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RefundsFilterCopyWith<_RefundsFilter> get copyWith => __$RefundsFilterCopyWithImpl<_RefundsFilter>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RefundsFilter&&(identical(other.status, status) || other.status == status)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.salesOrderId, salesOrderId) || other.salesOrderId == salesOrderId)&&(identical(other.pageIndex, pageIndex) || other.pageIndex == pageIndex));
}


@override
int get hashCode {
    return Object.hash(runtimeType,status,customerId,salesOrderId,pageIndex);
}

@override
String toString() {
    return 'RefundsFilter(status: $status, customerId: $customerId, salesOrderId: $salesOrderId, pageIndex: $pageIndex)';
}


}

/// @nodoc
abstract mixin class _$RefundsFilterCopyWith<$Res> implements $RefundsFilterCopyWith<$Res> {
  factory _$RefundsFilterCopyWith(_RefundsFilter value, $Res Function(_RefundsFilter) _then) = __$RefundsFilterCopyWithImpl;
@override @useResult
$Res call({
 RefundStatus? status, int? customerId, int? salesOrderId, int pageIndex
});




}
/// @nodoc
class __$RefundsFilterCopyWithImpl<$Res>
    implements _$RefundsFilterCopyWith<$Res> {
  __$RefundsFilterCopyWithImpl(this._self, this._then);

  final _RefundsFilter _self;
  final $Res Function(_RefundsFilter) _then;

/// Create a copy of RefundsFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = freezed,Object? customerId = freezed,Object? salesOrderId = freezed,Object? pageIndex = null,}) {
  return _then(_RefundsFilter(
status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RefundStatus?,customerId: freezed == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as int?,salesOrderId: freezed == salesOrderId ? _self.salesOrderId : salesOrderId // ignore: cast_nullable_to_non_nullable
as int?,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
