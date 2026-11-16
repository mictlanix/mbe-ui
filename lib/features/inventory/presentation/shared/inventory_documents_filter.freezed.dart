// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inventory_documents_filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$InventoryDocumentsFilter {

 InventoryDocumentStatus? get status; int? get warehouseId; int get pageIndex;
/// Create a copy of InventoryDocumentsFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InventoryDocumentsFilterCopyWith<InventoryDocumentsFilter> get copyWith => _$InventoryDocumentsFilterCopyWithImpl<InventoryDocumentsFilter>(this as InventoryDocumentsFilter, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as InventoryDocumentsFilter;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InventoryDocumentsFilter&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.warehouseId, _this.warehouseId) || other.warehouseId == _this.warehouseId)&&(identical(other.pageIndex, _this.pageIndex) || other.pageIndex == _this.pageIndex));
}


@override
int get hashCode {
  final _this = this as InventoryDocumentsFilter;
  return Object.hash(runtimeType,_this.status,_this.warehouseId,_this.pageIndex);
}

@override
String toString() {
  final _this = this as InventoryDocumentsFilter;
  return 'InventoryDocumentsFilter(status: ${_this.status}, warehouseId: ${_this.warehouseId}, pageIndex: ${_this.pageIndex})';
}


}

/// @nodoc
abstract mixin class $InventoryDocumentsFilterCopyWith<$Res>  {
  factory $InventoryDocumentsFilterCopyWith(InventoryDocumentsFilter value, $Res Function(InventoryDocumentsFilter) _then) = _$InventoryDocumentsFilterCopyWithImpl;
@useResult
$Res call({
 InventoryDocumentStatus? status, int? warehouseId, int pageIndex
});




}
/// @nodoc
class _$InventoryDocumentsFilterCopyWithImpl<$Res>
    implements $InventoryDocumentsFilterCopyWith<$Res> {
  _$InventoryDocumentsFilterCopyWithImpl(this._self, this._then);

  final InventoryDocumentsFilter _self;
  final $Res Function(InventoryDocumentsFilter) _then;

/// Create a copy of InventoryDocumentsFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = freezed,Object? warehouseId = freezed,Object? pageIndex = null,}) {
  return _then(InventoryDocumentsFilter(
status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InventoryDocumentStatus?,warehouseId: freezed == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int?,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [InventoryDocumentsFilter].
extension InventoryDocumentsFilterPatterns on InventoryDocumentsFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InventoryReceiptsFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InventoryReceiptsFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InventoryReceiptsFilter value)  $default,){
final _that = this;
switch (_that) {
case _InventoryReceiptsFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InventoryReceiptsFilter value)?  $default,){
final _that = this;
switch (_that) {
case _InventoryReceiptsFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( InventoryDocumentStatus? status,  int? warehouseId,  int pageIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InventoryReceiptsFilter() when $default != null:
return $default(_that.status,_that.warehouseId,_that.pageIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( InventoryDocumentStatus? status,  int? warehouseId,  int pageIndex)  $default,) {final _that = this;
switch (_that) {
case _InventoryReceiptsFilter():
return $default(_that.status,_that.warehouseId,_that.pageIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( InventoryDocumentStatus? status,  int? warehouseId,  int pageIndex)?  $default,) {final _that = this;
switch (_that) {
case _InventoryReceiptsFilter() when $default != null:
return $default(_that.status,_that.warehouseId,_that.pageIndex);case _:
  return null;

}
}

}

/// @nodoc


class _InventoryReceiptsFilter extends InventoryDocumentsFilter {
  const _InventoryReceiptsFilter({this.status, this.warehouseId, this.pageIndex = 0}): super._();
  

@override final  InventoryDocumentStatus? status;
@override final  int? warehouseId;
@override@JsonKey() final  int pageIndex;

/// Create a copy of InventoryDocumentsFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InventoryReceiptsFilterCopyWith<_InventoryReceiptsFilter> get copyWith => __$InventoryReceiptsFilterCopyWithImpl<_InventoryReceiptsFilter>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _InventoryReceiptsFilter&&(identical(other.status, status) || other.status == status)&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.pageIndex, pageIndex) || other.pageIndex == pageIndex));
}


@override
int get hashCode {
    return Object.hash(runtimeType,status,warehouseId,pageIndex);
}

@override
String toString() {
    return 'InventoryDocumentsFilter(status: $status, warehouseId: $warehouseId, pageIndex: $pageIndex)';
}


}

/// @nodoc
abstract mixin class _$InventoryReceiptsFilterCopyWith<$Res> implements $InventoryDocumentsFilterCopyWith<$Res> {
  factory _$InventoryReceiptsFilterCopyWith(_InventoryReceiptsFilter value, $Res Function(_InventoryReceiptsFilter) _then) = __$InventoryReceiptsFilterCopyWithImpl;
@override @useResult
$Res call({
 InventoryDocumentStatus? status, int? warehouseId, int pageIndex
});




}
/// @nodoc
class __$InventoryReceiptsFilterCopyWithImpl<$Res>
    implements _$InventoryReceiptsFilterCopyWith<$Res> {
  __$InventoryReceiptsFilterCopyWithImpl(this._self, this._then);

  final _InventoryReceiptsFilter _self;
  final $Res Function(_InventoryReceiptsFilter) _then;

/// Create a copy of InventoryDocumentsFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = freezed,Object? warehouseId = freezed,Object? pageIndex = null,}) {
  return _then(_InventoryReceiptsFilter(
status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InventoryDocumentStatus?,warehouseId: freezed == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int?,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
