// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'price_list_delete_preview.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PriceListDeletePreview {

/// One entry per referencing relation, in the server's order (largest
/// count first). Never re-sorted client-side.
 List<PriceListDeleteCategory> get categories;/// The server's own total, displayed as-is rather than re-summed here
/// (SC-005) — records the deletion *touches*, not records it deletes
/// (FR-004).
 int get total;
/// Create a copy of PriceListDeletePreview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PriceListDeletePreviewCopyWith<PriceListDeletePreview> get copyWith => _$PriceListDeletePreviewCopyWithImpl<PriceListDeletePreview>(this as PriceListDeletePreview, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PriceListDeletePreview;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PriceListDeletePreview&&const DeepCollectionEquality().equals(other.categories, _this.categories)&&(identical(other.total, _this.total) || other.total == _this.total));
}


@override
int get hashCode {
  final _this = this as PriceListDeletePreview;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.categories),_this.total);
}

@override
String toString() {
  final _this = this as PriceListDeletePreview;
  return 'PriceListDeletePreview(categories: ${_this.categories}, total: ${_this.total})';
}


}

/// @nodoc
abstract mixin class $PriceListDeletePreviewCopyWith<$Res>  {
  factory $PriceListDeletePreviewCopyWith(PriceListDeletePreview value, $Res Function(PriceListDeletePreview) _then) = _$PriceListDeletePreviewCopyWithImpl;
@useResult
$Res call({
 List<PriceListDeleteCategory> categories, int total
});




}
/// @nodoc
class _$PriceListDeletePreviewCopyWithImpl<$Res>
    implements $PriceListDeletePreviewCopyWith<$Res> {
  _$PriceListDeletePreviewCopyWithImpl(this._self, this._then);

  final PriceListDeletePreview _self;
  final $Res Function(PriceListDeletePreview) _then;

/// Create a copy of PriceListDeletePreview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? categories = null,Object? total = null,}) {
  return _then(PriceListDeletePreview(
categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<PriceListDeleteCategory>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PriceListDeletePreview].
extension PriceListDeletePreviewPatterns on PriceListDeletePreview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PriceListDeletePreview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PriceListDeletePreview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PriceListDeletePreview value)  $default,){
final _that = this;
switch (_that) {
case _PriceListDeletePreview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PriceListDeletePreview value)?  $default,){
final _that = this;
switch (_that) {
case _PriceListDeletePreview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<PriceListDeleteCategory> categories,  int total)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PriceListDeletePreview() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<PriceListDeleteCategory> categories,  int total)  $default,) {final _that = this;
switch (_that) {
case _PriceListDeletePreview():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<PriceListDeleteCategory> categories,  int total)?  $default,) {final _that = this;
switch (_that) {
case _PriceListDeletePreview() when $default != null:
return $default(_that.categories,_that.total);case _:
  return null;

}
}

}

/// @nodoc


class _PriceListDeletePreview extends PriceListDeletePreview {
  const _PriceListDeletePreview({required  List<PriceListDeleteCategory> categories, required this.total}): _categories = categories,super._();
  

/// One entry per referencing relation, in the server's order (largest
/// count first). Never re-sorted client-side.
 final  List<PriceListDeleteCategory> _categories;
/// One entry per referencing relation, in the server's order (largest
/// count first). Never re-sorted client-side.
@override List<PriceListDeleteCategory> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

/// The server's own total, displayed as-is rather than re-summed here
/// (SC-005) — records the deletion *touches*, not records it deletes
/// (FR-004).
@override final  int total;

/// Create a copy of PriceListDeletePreview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PriceListDeletePreviewCopyWith<_PriceListDeletePreview> get copyWith => __$PriceListDeletePreviewCopyWithImpl<_PriceListDeletePreview>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PriceListDeletePreview&&const DeepCollectionEquality().equals(other.categories, _categories)&&(identical(other.total, total) || other.total == total));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_categories),total);
}

@override
String toString() {
    return 'PriceListDeletePreview(categories: $categories, total: $total)';
}


}

/// @nodoc
abstract mixin class _$PriceListDeletePreviewCopyWith<$Res> implements $PriceListDeletePreviewCopyWith<$Res> {
  factory _$PriceListDeletePreviewCopyWith(_PriceListDeletePreview value, $Res Function(_PriceListDeletePreview) _then) = __$PriceListDeletePreviewCopyWithImpl;
@override @useResult
$Res call({
 List<PriceListDeleteCategory> categories, int total
});




}
/// @nodoc
class __$PriceListDeletePreviewCopyWithImpl<$Res>
    implements _$PriceListDeletePreviewCopyWith<$Res> {
  __$PriceListDeletePreviewCopyWithImpl(this._self, this._then);

  final _PriceListDeletePreview _self;
  final $Res Function(_PriceListDeletePreview) _then;

/// Create a copy of PriceListDeletePreview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? categories = null,Object? total = null,}) {
  return _then(_PriceListDeletePreview(
categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<PriceListDeleteCategory>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$PriceListDeleteCategory {

/// The raw `table.column` identifier mbe-api reports, kept verbatim so
/// an unrecognized relation still reaches the UI rather than being
/// dropped (FR-005).
 String get key; int get count;
/// Create a copy of PriceListDeleteCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PriceListDeleteCategoryCopyWith<PriceListDeleteCategory> get copyWith => _$PriceListDeleteCategoryCopyWithImpl<PriceListDeleteCategory>(this as PriceListDeleteCategory, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PriceListDeleteCategory;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PriceListDeleteCategory&&(identical(other.key, _this.key) || other.key == _this.key)&&(identical(other.count, _this.count) || other.count == _this.count));
}


@override
int get hashCode {
  final _this = this as PriceListDeleteCategory;
  return Object.hash(runtimeType,_this.key,_this.count);
}

@override
String toString() {
  final _this = this as PriceListDeleteCategory;
  return 'PriceListDeleteCategory(key: ${_this.key}, count: ${_this.count})';
}


}

/// @nodoc
abstract mixin class $PriceListDeleteCategoryCopyWith<$Res>  {
  factory $PriceListDeleteCategoryCopyWith(PriceListDeleteCategory value, $Res Function(PriceListDeleteCategory) _then) = _$PriceListDeleteCategoryCopyWithImpl;
@useResult
$Res call({
 String key, int count
});




}
/// @nodoc
class _$PriceListDeleteCategoryCopyWithImpl<$Res>
    implements $PriceListDeleteCategoryCopyWith<$Res> {
  _$PriceListDeleteCategoryCopyWithImpl(this._self, this._then);

  final PriceListDeleteCategory _self;
  final $Res Function(PriceListDeleteCategory) _then;

/// Create a copy of PriceListDeleteCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? count = null,}) {
  return _then(PriceListDeleteCategory(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PriceListDeleteCategory].
extension PriceListDeleteCategoryPatterns on PriceListDeleteCategory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PriceListDeleteCategory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PriceListDeleteCategory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PriceListDeleteCategory value)  $default,){
final _that = this;
switch (_that) {
case _PriceListDeleteCategory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PriceListDeleteCategory value)?  $default,){
final _that = this;
switch (_that) {
case _PriceListDeleteCategory() when $default != null:
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
case _PriceListDeleteCategory() when $default != null:
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
case _PriceListDeleteCategory():
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
case _PriceListDeleteCategory() when $default != null:
return $default(_that.key,_that.count);case _:
  return null;

}
}

}

/// @nodoc


class _PriceListDeleteCategory extends PriceListDeleteCategory {
  const _PriceListDeleteCategory({required this.key, required this.count}): super._();
  

/// The raw `table.column` identifier mbe-api reports, kept verbatim so
/// an unrecognized relation still reaches the UI rather than being
/// dropped (FR-005).
@override final  String key;
@override final  int count;

/// Create a copy of PriceListDeleteCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PriceListDeleteCategoryCopyWith<_PriceListDeleteCategory> get copyWith => __$PriceListDeleteCategoryCopyWithImpl<_PriceListDeleteCategory>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PriceListDeleteCategory&&(identical(other.key, key) || other.key == key)&&(identical(other.count, count) || other.count == count));
}


@override
int get hashCode {
    return Object.hash(runtimeType,key,count);
}

@override
String toString() {
    return 'PriceListDeleteCategory(key: $key, count: $count)';
}


}

/// @nodoc
abstract mixin class _$PriceListDeleteCategoryCopyWith<$Res> implements $PriceListDeleteCategoryCopyWith<$Res> {
  factory _$PriceListDeleteCategoryCopyWith(_PriceListDeleteCategory value, $Res Function(_PriceListDeleteCategory) _then) = __$PriceListDeleteCategoryCopyWithImpl;
@override @useResult
$Res call({
 String key, int count
});




}
/// @nodoc
class __$PriceListDeleteCategoryCopyWithImpl<$Res>
    implements _$PriceListDeleteCategoryCopyWith<$Res> {
  __$PriceListDeleteCategoryCopyWithImpl(this._self, this._then);

  final _PriceListDeleteCategory _self;
  final $Res Function(_PriceListDeleteCategory) _then;

/// Create a copy of PriceListDeleteCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? count = null,}) {
  return _then(_PriceListDeleteCategory(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
