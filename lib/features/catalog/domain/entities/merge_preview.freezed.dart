// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'merge_preview.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MergePreview {

/// One entry per referencing relation, in the server's order (largest
/// count first).
 List<MergePreviewCategory> get categories;/// The server's own total. Displayed as-is rather than re-summed here, so
/// what the operator reads always matches what the backend counted
/// (SC-006).
 int get total;
/// Create a copy of MergePreview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MergePreviewCopyWith<MergePreview> get copyWith => _$MergePreviewCopyWithImpl<MergePreview>(this as MergePreview, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MergePreview;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MergePreview&&const DeepCollectionEquality().equals(other.categories, _this.categories)&&(identical(other.total, _this.total) || other.total == _this.total));
}


@override
int get hashCode {
  final _this = this as MergePreview;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.categories),_this.total);
}

@override
String toString() {
  final _this = this as MergePreview;
  return 'MergePreview(categories: ${_this.categories}, total: ${_this.total})';
}


}

/// @nodoc
abstract mixin class $MergePreviewCopyWith<$Res>  {
  factory $MergePreviewCopyWith(MergePreview value, $Res Function(MergePreview) _then) = _$MergePreviewCopyWithImpl;
@useResult
$Res call({
 List<MergePreviewCategory> categories, int total
});




}
/// @nodoc
class _$MergePreviewCopyWithImpl<$Res>
    implements $MergePreviewCopyWith<$Res> {
  _$MergePreviewCopyWithImpl(this._self, this._then);

  final MergePreview _self;
  final $Res Function(MergePreview) _then;

/// Create a copy of MergePreview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? categories = null,Object? total = null,}) {
  return _then(MergePreview(
categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<MergePreviewCategory>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MergePreview].
extension MergePreviewPatterns on MergePreview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MergePreview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MergePreview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MergePreview value)  $default,){
final _that = this;
switch (_that) {
case _MergePreview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MergePreview value)?  $default,){
final _that = this;
switch (_that) {
case _MergePreview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<MergePreviewCategory> categories,  int total)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MergePreview() when $default != null:
return $default(_that.categories,_that.total);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<MergePreviewCategory> categories,  int total)  $default,) {final _that = this;
switch (_that) {
case _MergePreview():
return $default(_that.categories,_that.total);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<MergePreviewCategory> categories,  int total)?  $default,) {final _that = this;
switch (_that) {
case _MergePreview() when $default != null:
return $default(_that.categories,_that.total);case _:
  return null;

}
}

}

/// @nodoc


class _MergePreview extends MergePreview {
  const _MergePreview({required  List<MergePreviewCategory> categories, required this.total}): _categories = categories,super._();
  

/// One entry per referencing relation, in the server's order (largest
/// count first).
 final  List<MergePreviewCategory> _categories;
/// One entry per referencing relation, in the server's order (largest
/// count first).
@override List<MergePreviewCategory> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

/// The server's own total. Displayed as-is rather than re-summed here, so
/// what the operator reads always matches what the backend counted
/// (SC-006).
@override final  int total;

/// Create a copy of MergePreview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MergePreviewCopyWith<_MergePreview> get copyWith => __$MergePreviewCopyWithImpl<_MergePreview>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MergePreview&&const DeepCollectionEquality().equals(other.categories, _categories)&&(identical(other.total, total) || other.total == total));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_categories),total);
}

@override
String toString() {
    return 'MergePreview(categories: $categories, total: $total)';
}


}

/// @nodoc
abstract mixin class _$MergePreviewCopyWith<$Res> implements $MergePreviewCopyWith<$Res> {
  factory _$MergePreviewCopyWith(_MergePreview value, $Res Function(_MergePreview) _then) = __$MergePreviewCopyWithImpl;
@override @useResult
$Res call({
 List<MergePreviewCategory> categories, int total
});




}
/// @nodoc
class __$MergePreviewCopyWithImpl<$Res>
    implements _$MergePreviewCopyWith<$Res> {
  __$MergePreviewCopyWithImpl(this._self, this._then);

  final _MergePreview _self;
  final $Res Function(_MergePreview) _then;

/// Create a copy of MergePreview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? categories = null,Object? total = null,}) {
  return _then(_MergePreview(
categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<MergePreviewCategory>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$MergePreviewCategory {

/// The raw `table.column` identifier as mbe-api reports it (e.g.
/// `sales_order_detail.product`). Kept verbatim: the category set is
/// derived from mbe-api's mapped metadata and grows whenever a new
/// foreign key to `product` is added, so the UI resolves a label from
/// this key rather than relying on a closed enum (research.md §4).
 String get key; int get count;
/// Create a copy of MergePreviewCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MergePreviewCategoryCopyWith<MergePreviewCategory> get copyWith => _$MergePreviewCategoryCopyWithImpl<MergePreviewCategory>(this as MergePreviewCategory, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MergePreviewCategory;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MergePreviewCategory&&(identical(other.key, _this.key) || other.key == _this.key)&&(identical(other.count, _this.count) || other.count == _this.count));
}


@override
int get hashCode {
  final _this = this as MergePreviewCategory;
  return Object.hash(runtimeType,_this.key,_this.count);
}

@override
String toString() {
  final _this = this as MergePreviewCategory;
  return 'MergePreviewCategory(key: ${_this.key}, count: ${_this.count})';
}


}

/// @nodoc
abstract mixin class $MergePreviewCategoryCopyWith<$Res>  {
  factory $MergePreviewCategoryCopyWith(MergePreviewCategory value, $Res Function(MergePreviewCategory) _then) = _$MergePreviewCategoryCopyWithImpl;
@useResult
$Res call({
 String key, int count
});




}
/// @nodoc
class _$MergePreviewCategoryCopyWithImpl<$Res>
    implements $MergePreviewCategoryCopyWith<$Res> {
  _$MergePreviewCategoryCopyWithImpl(this._self, this._then);

  final MergePreviewCategory _self;
  final $Res Function(MergePreviewCategory) _then;

/// Create a copy of MergePreviewCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? count = null,}) {
  return _then(MergePreviewCategory(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MergePreviewCategory].
extension MergePreviewCategoryPatterns on MergePreviewCategory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MergePreviewCategory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MergePreviewCategory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MergePreviewCategory value)  $default,){
final _that = this;
switch (_that) {
case _MergePreviewCategory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MergePreviewCategory value)?  $default,){
final _that = this;
switch (_that) {
case _MergePreviewCategory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String key,  int count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MergePreviewCategory() when $default != null:
return $default(_that.key,_that.count);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String key,  int count)  $default,) {final _that = this;
switch (_that) {
case _MergePreviewCategory():
return $default(_that.key,_that.count);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String key,  int count)?  $default,) {final _that = this;
switch (_that) {
case _MergePreviewCategory() when $default != null:
return $default(_that.key,_that.count);case _:
  return null;

}
}

}

/// @nodoc


class _MergePreviewCategory extends MergePreviewCategory {
  const _MergePreviewCategory({required this.key, required this.count}): super._();
  

/// The raw `table.column` identifier as mbe-api reports it (e.g.
/// `sales_order_detail.product`). Kept verbatim: the category set is
/// derived from mbe-api's mapped metadata and grows whenever a new
/// foreign key to `product` is added, so the UI resolves a label from
/// this key rather than relying on a closed enum (research.md §4).
@override final  String key;
@override final  int count;

/// Create a copy of MergePreviewCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MergePreviewCategoryCopyWith<_MergePreviewCategory> get copyWith => __$MergePreviewCategoryCopyWithImpl<_MergePreviewCategory>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MergePreviewCategory&&(identical(other.key, key) || other.key == key)&&(identical(other.count, count) || other.count == count));
}


@override
int get hashCode {
    return Object.hash(runtimeType,key,count);
}

@override
String toString() {
    return 'MergePreviewCategory(key: $key, count: $count)';
}


}

/// @nodoc
abstract mixin class _$MergePreviewCategoryCopyWith<$Res> implements $MergePreviewCategoryCopyWith<$Res> {
  factory _$MergePreviewCategoryCopyWith(_MergePreviewCategory value, $Res Function(_MergePreviewCategory) _then) = __$MergePreviewCategoryCopyWithImpl;
@override @useResult
$Res call({
 String key, int count
});




}
/// @nodoc
class __$MergePreviewCategoryCopyWithImpl<$Res>
    implements _$MergePreviewCategoryCopyWith<$Res> {
  __$MergePreviewCategoryCopyWithImpl(this._self, this._then);

  final _MergePreviewCategory _self;
  final $Res Function(_MergePreviewCategory) _then;

/// Create a copy of MergePreviewCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? count = null,}) {
  return _then(_MergePreviewCategory(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
