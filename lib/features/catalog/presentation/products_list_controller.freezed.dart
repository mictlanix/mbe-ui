// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'products_list_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProductFilter {

 String get search; EntityStatus? get status; bool? get stockable; bool? get salable; bool? get purchasable; bool? get perishable; bool? get seriable; bool? get invoiceable; int? get supplier; List<int> get labels; int get pageIndex;
/// Create a copy of ProductFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductFilterCopyWith<ProductFilter> get copyWith => _$ProductFilterCopyWithImpl<ProductFilter>(this as ProductFilter, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ProductFilter;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductFilter&&(identical(other.search, _this.search) || other.search == _this.search)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.stockable, _this.stockable) || other.stockable == _this.stockable)&&(identical(other.salable, _this.salable) || other.salable == _this.salable)&&(identical(other.purchasable, _this.purchasable) || other.purchasable == _this.purchasable)&&(identical(other.perishable, _this.perishable) || other.perishable == _this.perishable)&&(identical(other.seriable, _this.seriable) || other.seriable == _this.seriable)&&(identical(other.invoiceable, _this.invoiceable) || other.invoiceable == _this.invoiceable)&&(identical(other.supplier, _this.supplier) || other.supplier == _this.supplier)&&const DeepCollectionEquality().equals(other.labels, _this.labels)&&(identical(other.pageIndex, _this.pageIndex) || other.pageIndex == _this.pageIndex));
}


@override
int get hashCode {
  final _this = this as ProductFilter;
  return Object.hash(runtimeType,_this.search,_this.status,_this.stockable,_this.salable,_this.purchasable,_this.perishable,_this.seriable,_this.invoiceable,_this.supplier,const DeepCollectionEquality().hash(_this.labels),_this.pageIndex);
}

@override
String toString() {
  final _this = this as ProductFilter;
  return 'ProductFilter(search: ${_this.search}, status: ${_this.status}, stockable: ${_this.stockable}, salable: ${_this.salable}, purchasable: ${_this.purchasable}, perishable: ${_this.perishable}, seriable: ${_this.seriable}, invoiceable: ${_this.invoiceable}, supplier: ${_this.supplier}, labels: ${_this.labels}, pageIndex: ${_this.pageIndex})';
}


}

/// @nodoc
abstract mixin class $ProductFilterCopyWith<$Res>  {
  factory $ProductFilterCopyWith(ProductFilter value, $Res Function(ProductFilter) _then) = _$ProductFilterCopyWithImpl;
@useResult
$Res call({
 String search, EntityStatus? status, bool? stockable, bool? salable, bool? purchasable, bool? perishable, bool? seriable, bool? invoiceable, int? supplier, List<int> labels, int pageIndex
});




}
/// @nodoc
class _$ProductFilterCopyWithImpl<$Res>
    implements $ProductFilterCopyWith<$Res> {
  _$ProductFilterCopyWithImpl(this._self, this._then);

  final ProductFilter _self;
  final $Res Function(ProductFilter) _then;

/// Create a copy of ProductFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? search = null,Object? status = freezed,Object? stockable = freezed,Object? salable = freezed,Object? purchasable = freezed,Object? perishable = freezed,Object? seriable = freezed,Object? invoiceable = freezed,Object? supplier = freezed,Object? labels = null,Object? pageIndex = null,}) {
  return _then(ProductFilter(
search: null == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus?,stockable: freezed == stockable ? _self.stockable : stockable // ignore: cast_nullable_to_non_nullable
as bool?,salable: freezed == salable ? _self.salable : salable // ignore: cast_nullable_to_non_nullable
as bool?,purchasable: freezed == purchasable ? _self.purchasable : purchasable // ignore: cast_nullable_to_non_nullable
as bool?,perishable: freezed == perishable ? _self.perishable : perishable // ignore: cast_nullable_to_non_nullable
as bool?,seriable: freezed == seriable ? _self.seriable : seriable // ignore: cast_nullable_to_non_nullable
as bool?,invoiceable: freezed == invoiceable ? _self.invoiceable : invoiceable // ignore: cast_nullable_to_non_nullable
as bool?,supplier: freezed == supplier ? _self.supplier : supplier // ignore: cast_nullable_to_non_nullable
as int?,labels: null == labels ? _self.labels : labels // ignore: cast_nullable_to_non_nullable
as List<int>,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductFilter].
extension ProductFilterPatterns on ProductFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductFilter value)  $default,){
final _that = this;
switch (_that) {
case _ProductFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductFilter value)?  $default,){
final _that = this;
switch (_that) {
case _ProductFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String search,  EntityStatus? status,  bool? stockable,  bool? salable,  bool? purchasable,  bool? perishable,  bool? seriable,  bool? invoiceable,  int? supplier,  List<int> labels,  int pageIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductFilter() when $default != null:
return $default(_that.search,_that.status,_that.stockable,_that.salable,_that.purchasable,_that.perishable,_that.seriable,_that.invoiceable,_that.supplier,_that.labels,_that.pageIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String search,  EntityStatus? status,  bool? stockable,  bool? salable,  bool? purchasable,  bool? perishable,  bool? seriable,  bool? invoiceable,  int? supplier,  List<int> labels,  int pageIndex)  $default,) {final _that = this;
switch (_that) {
case _ProductFilter():
return $default(_that.search,_that.status,_that.stockable,_that.salable,_that.purchasable,_that.perishable,_that.seriable,_that.invoiceable,_that.supplier,_that.labels,_that.pageIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String search,  EntityStatus? status,  bool? stockable,  bool? salable,  bool? purchasable,  bool? perishable,  bool? seriable,  bool? invoiceable,  int? supplier,  List<int> labels,  int pageIndex)?  $default,) {final _that = this;
switch (_that) {
case _ProductFilter() when $default != null:
return $default(_that.search,_that.status,_that.stockable,_that.salable,_that.purchasable,_that.perishable,_that.seriable,_that.invoiceable,_that.supplier,_that.labels,_that.pageIndex);case _:
  return null;

}
}

}

/// @nodoc


class _ProductFilter implements ProductFilter {
  const _ProductFilter({this.search = '', this.status, this.stockable, this.salable, this.purchasable, this.perishable, this.seriable, this.invoiceable, this.supplier,  List<int> labels = const <int>[], this.pageIndex = 0}): _labels = labels;
  

@override@JsonKey() final  String search;
@override final  EntityStatus? status;
@override final  bool? stockable;
@override final  bool? salable;
@override final  bool? purchasable;
@override final  bool? perishable;
@override final  bool? seriable;
@override final  bool? invoiceable;
@override final  int? supplier;
 final  List<int> _labels;
@override@JsonKey() List<int> get labels {
  if (_labels is EqualUnmodifiableListView) return _labels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_labels);
}

@override@JsonKey() final  int pageIndex;

/// Create a copy of ProductFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductFilterCopyWith<_ProductFilter> get copyWith => __$ProductFilterCopyWithImpl<_ProductFilter>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductFilter&&(identical(other.search, search) || other.search == search)&&(identical(other.status, status) || other.status == status)&&(identical(other.stockable, stockable) || other.stockable == stockable)&&(identical(other.salable, salable) || other.salable == salable)&&(identical(other.purchasable, purchasable) || other.purchasable == purchasable)&&(identical(other.perishable, perishable) || other.perishable == perishable)&&(identical(other.seriable, seriable) || other.seriable == seriable)&&(identical(other.invoiceable, invoiceable) || other.invoiceable == invoiceable)&&(identical(other.supplier, supplier) || other.supplier == supplier)&&const DeepCollectionEquality().equals(other.labels, _labels)&&(identical(other.pageIndex, pageIndex) || other.pageIndex == pageIndex));
}


@override
int get hashCode {
    return Object.hash(runtimeType,search,status,stockable,salable,purchasable,perishable,seriable,invoiceable,supplier,const DeepCollectionEquality().hash(_labels),pageIndex);
}

@override
String toString() {
    return 'ProductFilter(search: $search, status: $status, stockable: $stockable, salable: $salable, purchasable: $purchasable, perishable: $perishable, seriable: $seriable, invoiceable: $invoiceable, supplier: $supplier, labels: $labels, pageIndex: $pageIndex)';
}


}

/// @nodoc
abstract mixin class _$ProductFilterCopyWith<$Res> implements $ProductFilterCopyWith<$Res> {
  factory _$ProductFilterCopyWith(_ProductFilter value, $Res Function(_ProductFilter) _then) = __$ProductFilterCopyWithImpl;
@override @useResult
$Res call({
 String search, EntityStatus? status, bool? stockable, bool? salable, bool? purchasable, bool? perishable, bool? seriable, bool? invoiceable, int? supplier, List<int> labels, int pageIndex
});




}
/// @nodoc
class __$ProductFilterCopyWithImpl<$Res>
    implements _$ProductFilterCopyWith<$Res> {
  __$ProductFilterCopyWithImpl(this._self, this._then);

  final _ProductFilter _self;
  final $Res Function(_ProductFilter) _then;

/// Create a copy of ProductFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? search = null,Object? status = freezed,Object? stockable = freezed,Object? salable = freezed,Object? purchasable = freezed,Object? perishable = freezed,Object? seriable = freezed,Object? invoiceable = freezed,Object? supplier = freezed,Object? labels = null,Object? pageIndex = null,}) {
  return _then(_ProductFilter(
search: null == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus?,stockable: freezed == stockable ? _self.stockable : stockable // ignore: cast_nullable_to_non_nullable
as bool?,salable: freezed == salable ? _self.salable : salable // ignore: cast_nullable_to_non_nullable
as bool?,purchasable: freezed == purchasable ? _self.purchasable : purchasable // ignore: cast_nullable_to_non_nullable
as bool?,perishable: freezed == perishable ? _self.perishable : perishable // ignore: cast_nullable_to_non_nullable
as bool?,seriable: freezed == seriable ? _self.seriable : seriable // ignore: cast_nullable_to_non_nullable
as bool?,invoiceable: freezed == invoiceable ? _self.invoiceable : invoiceable // ignore: cast_nullable_to_non_nullable
as bool?,supplier: freezed == supplier ? _self.supplier : supplier // ignore: cast_nullable_to_non_nullable
as int?,labels: null == labels ? _self._labels : labels // ignore: cast_nullable_to_non_nullable
as List<int>,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
