// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'approval_queue_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ApprovalQueueFilter {

 int? get facilityId; int get pageIndex;
/// Create a copy of ApprovalQueueFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApprovalQueueFilterCopyWith<ApprovalQueueFilter> get copyWith => _$ApprovalQueueFilterCopyWithImpl<ApprovalQueueFilter>(this as ApprovalQueueFilter, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ApprovalQueueFilter;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApprovalQueueFilter&&(identical(other.facilityId, _this.facilityId) || other.facilityId == _this.facilityId)&&(identical(other.pageIndex, _this.pageIndex) || other.pageIndex == _this.pageIndex));
}


@override
int get hashCode {
  final _this = this as ApprovalQueueFilter;
  return Object.hash(runtimeType,_this.facilityId,_this.pageIndex);
}

@override
String toString() {
  final _this = this as ApprovalQueueFilter;
  return 'ApprovalQueueFilter(facilityId: ${_this.facilityId}, pageIndex: ${_this.pageIndex})';
}


}

/// @nodoc
abstract mixin class $ApprovalQueueFilterCopyWith<$Res>  {
  factory $ApprovalQueueFilterCopyWith(ApprovalQueueFilter value, $Res Function(ApprovalQueueFilter) _then) = _$ApprovalQueueFilterCopyWithImpl;
@useResult
$Res call({
 int? facilityId, int pageIndex
});




}
/// @nodoc
class _$ApprovalQueueFilterCopyWithImpl<$Res>
    implements $ApprovalQueueFilterCopyWith<$Res> {
  _$ApprovalQueueFilterCopyWithImpl(this._self, this._then);

  final ApprovalQueueFilter _self;
  final $Res Function(ApprovalQueueFilter) _then;

/// Create a copy of ApprovalQueueFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? facilityId = freezed,Object? pageIndex = null,}) {
  return _then(ApprovalQueueFilter(
facilityId: freezed == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int?,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ApprovalQueueFilter].
extension ApprovalQueueFilterPatterns on ApprovalQueueFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApprovalQueueFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApprovalQueueFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApprovalQueueFilter value)  $default,){
final _that = this;
switch (_that) {
case _ApprovalQueueFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApprovalQueueFilter value)?  $default,){
final _that = this;
switch (_that) {
case _ApprovalQueueFilter() when $default != null:
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
case _ApprovalQueueFilter() when $default != null:
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
case _ApprovalQueueFilter():
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
case _ApprovalQueueFilter() when $default != null:
return $default(_that.facilityId,_that.pageIndex);case _:
  return null;

}
}

}

/// @nodoc


class _ApprovalQueueFilter extends ApprovalQueueFilter {
  const _ApprovalQueueFilter({this.facilityId, this.pageIndex = 0}): super._();
  

@override final  int? facilityId;
@override@JsonKey() final  int pageIndex;

/// Create a copy of ApprovalQueueFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApprovalQueueFilterCopyWith<_ApprovalQueueFilter> get copyWith => __$ApprovalQueueFilterCopyWithImpl<_ApprovalQueueFilter>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApprovalQueueFilter&&(identical(other.facilityId, facilityId) || other.facilityId == facilityId)&&(identical(other.pageIndex, pageIndex) || other.pageIndex == pageIndex));
}


@override
int get hashCode {
    return Object.hash(runtimeType,facilityId,pageIndex);
}

@override
String toString() {
    return 'ApprovalQueueFilter(facilityId: $facilityId, pageIndex: $pageIndex)';
}


}

/// @nodoc
abstract mixin class _$ApprovalQueueFilterCopyWith<$Res> implements $ApprovalQueueFilterCopyWith<$Res> {
  factory _$ApprovalQueueFilterCopyWith(_ApprovalQueueFilter value, $Res Function(_ApprovalQueueFilter) _then) = __$ApprovalQueueFilterCopyWithImpl;
@override @useResult
$Res call({
 int? facilityId, int pageIndex
});




}
/// @nodoc
class __$ApprovalQueueFilterCopyWithImpl<$Res>
    implements _$ApprovalQueueFilterCopyWith<$Res> {
  __$ApprovalQueueFilterCopyWithImpl(this._self, this._then);

  final _ApprovalQueueFilter _self;
  final $Res Function(_ApprovalQueueFilter) _then;

/// Create a copy of ApprovalQueueFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? facilityId = freezed,Object? pageIndex = null,}) {
  return _then(_ApprovalQueueFilter(
facilityId: freezed == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int?,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
