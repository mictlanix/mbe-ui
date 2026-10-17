// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pricing_grid_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PricingGridFilter {

 String get search; int get pageIndex; EntityStatus? get status; bool? get stockable; bool? get salable; bool? get purchasable; int? get supplier; List<int> get labels; int? get missingPriceList;
/// Create a copy of PricingGridFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PricingGridFilterCopyWith<PricingGridFilter> get copyWith => _$PricingGridFilterCopyWithImpl<PricingGridFilter>(this as PricingGridFilter, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PricingGridFilter;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PricingGridFilter&&(identical(other.search, _this.search) || other.search == _this.search)&&(identical(other.pageIndex, _this.pageIndex) || other.pageIndex == _this.pageIndex)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.stockable, _this.stockable) || other.stockable == _this.stockable)&&(identical(other.salable, _this.salable) || other.salable == _this.salable)&&(identical(other.purchasable, _this.purchasable) || other.purchasable == _this.purchasable)&&(identical(other.supplier, _this.supplier) || other.supplier == _this.supplier)&&const DeepCollectionEquality().equals(other.labels, _this.labels)&&(identical(other.missingPriceList, _this.missingPriceList) || other.missingPriceList == _this.missingPriceList));
}


@override
int get hashCode {
  final _this = this as PricingGridFilter;
  return Object.hash(runtimeType,_this.search,_this.pageIndex,_this.status,_this.stockable,_this.salable,_this.purchasable,_this.supplier,const DeepCollectionEquality().hash(_this.labels),_this.missingPriceList);
}

@override
String toString() {
  final _this = this as PricingGridFilter;
  return 'PricingGridFilter(search: ${_this.search}, pageIndex: ${_this.pageIndex}, status: ${_this.status}, stockable: ${_this.stockable}, salable: ${_this.salable}, purchasable: ${_this.purchasable}, supplier: ${_this.supplier}, labels: ${_this.labels}, missingPriceList: ${_this.missingPriceList})';
}


}

/// @nodoc
abstract mixin class $PricingGridFilterCopyWith<$Res>  {
  factory $PricingGridFilterCopyWith(PricingGridFilter value, $Res Function(PricingGridFilter) _then) = _$PricingGridFilterCopyWithImpl;
@useResult
$Res call({
 String search, int pageIndex, EntityStatus? status, bool? stockable, bool? salable, bool? purchasable, int? supplier, List<int> labels, int? missingPriceList
});




}
/// @nodoc
class _$PricingGridFilterCopyWithImpl<$Res>
    implements $PricingGridFilterCopyWith<$Res> {
  _$PricingGridFilterCopyWithImpl(this._self, this._then);

  final PricingGridFilter _self;
  final $Res Function(PricingGridFilter) _then;

/// Create a copy of PricingGridFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? search = null,Object? pageIndex = null,Object? status = freezed,Object? stockable = freezed,Object? salable = freezed,Object? purchasable = freezed,Object? supplier = freezed,Object? labels = null,Object? missingPriceList = freezed,}) {
  return _then(PricingGridFilter(
search: null == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus?,stockable: freezed == stockable ? _self.stockable : stockable // ignore: cast_nullable_to_non_nullable
as bool?,salable: freezed == salable ? _self.salable : salable // ignore: cast_nullable_to_non_nullable
as bool?,purchasable: freezed == purchasable ? _self.purchasable : purchasable // ignore: cast_nullable_to_non_nullable
as bool?,supplier: freezed == supplier ? _self.supplier : supplier // ignore: cast_nullable_to_non_nullable
as int?,labels: null == labels ? _self.labels : labels // ignore: cast_nullable_to_non_nullable
as List<int>,missingPriceList: freezed == missingPriceList ? _self.missingPriceList : missingPriceList // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [PricingGridFilter].
extension PricingGridFilterPatterns on PricingGridFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PricingGridFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PricingGridFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PricingGridFilter value)  $default,){
final _that = this;
switch (_that) {
case _PricingGridFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PricingGridFilter value)?  $default,){
final _that = this;
switch (_that) {
case _PricingGridFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String search,  int pageIndex,  EntityStatus? status,  bool? stockable,  bool? salable,  bool? purchasable,  int? supplier,  List<int> labels,  int? missingPriceList)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PricingGridFilter() when $default != null:
return $default(_that.search,_that.pageIndex,_that.status,_that.stockable,_that.salable,_that.purchasable,_that.supplier,_that.labels,_that.missingPriceList);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String search,  int pageIndex,  EntityStatus? status,  bool? stockable,  bool? salable,  bool? purchasable,  int? supplier,  List<int> labels,  int? missingPriceList)  $default,) {final _that = this;
switch (_that) {
case _PricingGridFilter():
return $default(_that.search,_that.pageIndex,_that.status,_that.stockable,_that.salable,_that.purchasable,_that.supplier,_that.labels,_that.missingPriceList);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String search,  int pageIndex,  EntityStatus? status,  bool? stockable,  bool? salable,  bool? purchasable,  int? supplier,  List<int> labels,  int? missingPriceList)?  $default,) {final _that = this;
switch (_that) {
case _PricingGridFilter() when $default != null:
return $default(_that.search,_that.pageIndex,_that.status,_that.stockable,_that.salable,_that.purchasable,_that.supplier,_that.labels,_that.missingPriceList);case _:
  return null;

}
}

}

/// @nodoc


class _PricingGridFilter implements PricingGridFilter {
  const _PricingGridFilter({this.search = '', this.pageIndex = 0, this.status, this.stockable, this.salable, this.purchasable, this.supplier,  List<int> labels = const <int>[], this.missingPriceList}): _labels = labels;
  

@override@JsonKey() final  String search;
@override@JsonKey() final  int pageIndex;
@override final  EntityStatus? status;
@override final  bool? stockable;
@override final  bool? salable;
@override final  bool? purchasable;
@override final  int? supplier;
 final  List<int> _labels;
@override@JsonKey() List<int> get labels {
  if (_labels is EqualUnmodifiableListView) return _labels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_labels);
}

@override final  int? missingPriceList;

/// Create a copy of PricingGridFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PricingGridFilterCopyWith<_PricingGridFilter> get copyWith => __$PricingGridFilterCopyWithImpl<_PricingGridFilter>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PricingGridFilter&&(identical(other.search, search) || other.search == search)&&(identical(other.pageIndex, pageIndex) || other.pageIndex == pageIndex)&&(identical(other.status, status) || other.status == status)&&(identical(other.stockable, stockable) || other.stockable == stockable)&&(identical(other.salable, salable) || other.salable == salable)&&(identical(other.purchasable, purchasable) || other.purchasable == purchasable)&&(identical(other.supplier, supplier) || other.supplier == supplier)&&const DeepCollectionEquality().equals(other.labels, _labels)&&(identical(other.missingPriceList, missingPriceList) || other.missingPriceList == missingPriceList));
}


@override
int get hashCode {
    return Object.hash(runtimeType,search,pageIndex,status,stockable,salable,purchasable,supplier,const DeepCollectionEquality().hash(_labels),missingPriceList);
}

@override
String toString() {
    return 'PricingGridFilter(search: $search, pageIndex: $pageIndex, status: $status, stockable: $stockable, salable: $salable, purchasable: $purchasable, supplier: $supplier, labels: $labels, missingPriceList: $missingPriceList)';
}


}

/// @nodoc
abstract mixin class _$PricingGridFilterCopyWith<$Res> implements $PricingGridFilterCopyWith<$Res> {
  factory _$PricingGridFilterCopyWith(_PricingGridFilter value, $Res Function(_PricingGridFilter) _then) = __$PricingGridFilterCopyWithImpl;
@override @useResult
$Res call({
 String search, int pageIndex, EntityStatus? status, bool? stockable, bool? salable, bool? purchasable, int? supplier, List<int> labels, int? missingPriceList
});




}
/// @nodoc
class __$PricingGridFilterCopyWithImpl<$Res>
    implements _$PricingGridFilterCopyWith<$Res> {
  __$PricingGridFilterCopyWithImpl(this._self, this._then);

  final _PricingGridFilter _self;
  final $Res Function(_PricingGridFilter) _then;

/// Create a copy of PricingGridFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? search = null,Object? pageIndex = null,Object? status = freezed,Object? stockable = freezed,Object? salable = freezed,Object? purchasable = freezed,Object? supplier = freezed,Object? labels = null,Object? missingPriceList = freezed,}) {
  return _then(_PricingGridFilter(
search: null == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus?,stockable: freezed == stockable ? _self.stockable : stockable // ignore: cast_nullable_to_non_nullable
as bool?,salable: freezed == salable ? _self.salable : salable // ignore: cast_nullable_to_non_nullable
as bool?,purchasable: freezed == purchasable ? _self.purchasable : purchasable // ignore: cast_nullable_to_non_nullable
as bool?,supplier: freezed == supplier ? _self.supplier : supplier // ignore: cast_nullable_to_non_nullable
as int?,labels: null == labels ? _self._labels : labels // ignore: cast_nullable_to_non_nullable
as List<int>,missingPriceList: freezed == missingPriceList ? _self.missingPriceList : missingPriceList // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$RejectedEdit {

 String get typed; String get reason;
/// Create a copy of RejectedEdit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RejectedEditCopyWith<RejectedEdit> get copyWith => _$RejectedEditCopyWithImpl<RejectedEdit>(this as RejectedEdit, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as RejectedEdit;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RejectedEdit&&(identical(other.typed, _this.typed) || other.typed == _this.typed)&&(identical(other.reason, _this.reason) || other.reason == _this.reason));
}


@override
int get hashCode {
  final _this = this as RejectedEdit;
  return Object.hash(runtimeType,_this.typed,_this.reason);
}

@override
String toString() {
  final _this = this as RejectedEdit;
  return 'RejectedEdit(typed: ${_this.typed}, reason: ${_this.reason})';
}


}

/// @nodoc
abstract mixin class $RejectedEditCopyWith<$Res>  {
  factory $RejectedEditCopyWith(RejectedEdit value, $Res Function(RejectedEdit) _then) = _$RejectedEditCopyWithImpl;
@useResult
$Res call({
 String typed, String reason
});




}
/// @nodoc
class _$RejectedEditCopyWithImpl<$Res>
    implements $RejectedEditCopyWith<$Res> {
  _$RejectedEditCopyWithImpl(this._self, this._then);

  final RejectedEdit _self;
  final $Res Function(RejectedEdit) _then;

/// Create a copy of RejectedEdit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? typed = null,Object? reason = null,}) {
  return _then(RejectedEdit(
typed: null == typed ? _self.typed : typed // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RejectedEdit].
extension RejectedEditPatterns on RejectedEdit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RejectedEdit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RejectedEdit() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RejectedEdit value)  $default,){
final _that = this;
switch (_that) {
case _RejectedEdit():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RejectedEdit value)?  $default,){
final _that = this;
switch (_that) {
case _RejectedEdit() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String typed,  String reason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RejectedEdit() when $default != null:
return $default(_that.typed,_that.reason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String typed,  String reason)  $default,) {final _that = this;
switch (_that) {
case _RejectedEdit():
return $default(_that.typed,_that.reason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String typed,  String reason)?  $default,) {final _that = this;
switch (_that) {
case _RejectedEdit() when $default != null:
return $default(_that.typed,_that.reason);case _:
  return null;

}
}

}

/// @nodoc


class _RejectedEdit implements RejectedEdit {
  const _RejectedEdit({required this.typed, required this.reason});
  

@override final  String typed;
@override final  String reason;

/// Create a copy of RejectedEdit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RejectedEditCopyWith<_RejectedEdit> get copyWith => __$RejectedEditCopyWithImpl<_RejectedEdit>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RejectedEdit&&(identical(other.typed, typed) || other.typed == typed)&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode {
    return Object.hash(runtimeType,typed,reason);
}

@override
String toString() {
    return 'RejectedEdit(typed: $typed, reason: $reason)';
}


}

/// @nodoc
abstract mixin class _$RejectedEditCopyWith<$Res> implements $RejectedEditCopyWith<$Res> {
  factory _$RejectedEditCopyWith(_RejectedEdit value, $Res Function(_RejectedEdit) _then) = __$RejectedEditCopyWithImpl;
@override @useResult
$Res call({
 String typed, String reason
});




}
/// @nodoc
class __$RejectedEditCopyWithImpl<$Res>
    implements _$RejectedEditCopyWith<$Res> {
  __$RejectedEditCopyWithImpl(this._self, this._then);

  final _RejectedEdit _self;
  final $Res Function(_RejectedEdit) _then;

/// Create a copy of RejectedEdit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? typed = null,Object? reason = null,}) {
  return _then(_RejectedEdit(
typed: null == typed ? _self.typed : typed // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$PriceWrite {

 PriceCellKey get cell; String? get previous; String get next;
/// Create a copy of PriceWrite
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PriceWriteCopyWith<PriceWrite> get copyWith => _$PriceWriteCopyWithImpl<PriceWrite>(this as PriceWrite, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PriceWrite;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PriceWrite&&(identical(other.cell, _this.cell) || other.cell == _this.cell)&&(identical(other.previous, _this.previous) || other.previous == _this.previous)&&(identical(other.next, _this.next) || other.next == _this.next));
}


@override
int get hashCode {
  final _this = this as PriceWrite;
  return Object.hash(runtimeType,_this.cell,_this.previous,_this.next);
}

@override
String toString() {
  final _this = this as PriceWrite;
  return 'PriceWrite(cell: ${_this.cell}, previous: ${_this.previous}, next: ${_this.next})';
}


}

/// @nodoc
abstract mixin class $PriceWriteCopyWith<$Res>  {
  factory $PriceWriteCopyWith(PriceWrite value, $Res Function(PriceWrite) _then) = _$PriceWriteCopyWithImpl;
@useResult
$Res call({
 PriceCellKey cell, String? previous, String next
});


$PriceCellKeyCopyWith<$Res> get cell;

}
/// @nodoc
class _$PriceWriteCopyWithImpl<$Res>
    implements $PriceWriteCopyWith<$Res> {
  _$PriceWriteCopyWithImpl(this._self, this._then);

  final PriceWrite _self;
  final $Res Function(PriceWrite) _then;

/// Create a copy of PriceWrite
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cell = null,Object? previous = freezed,Object? next = null,}) {
  return _then(PriceWrite(
cell: null == cell ? _self.cell : cell // ignore: cast_nullable_to_non_nullable
as PriceCellKey,previous: freezed == previous ? _self.previous : previous // ignore: cast_nullable_to_non_nullable
as String?,next: null == next ? _self.next : next // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of PriceWrite
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCellKeyCopyWith<$Res> get cell {
  
  return $PriceCellKeyCopyWith<$Res>(_self.cell, (value) {
    return _then(_self.copyWith(cell: value));
  });
}
}


/// Adds pattern-matching-related methods to [PriceWrite].
extension PriceWritePatterns on PriceWrite {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PriceWrite value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PriceWrite() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PriceWrite value)  $default,){
final _that = this;
switch (_that) {
case _PriceWrite():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PriceWrite value)?  $default,){
final _that = this;
switch (_that) {
case _PriceWrite() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PriceCellKey cell,  String? previous,  String next)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PriceWrite() when $default != null:
return $default(_that.cell,_that.previous,_that.next);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PriceCellKey cell,  String? previous,  String next)  $default,) {final _that = this;
switch (_that) {
case _PriceWrite():
return $default(_that.cell,_that.previous,_that.next);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PriceCellKey cell,  String? previous,  String next)?  $default,) {final _that = this;
switch (_that) {
case _PriceWrite() when $default != null:
return $default(_that.cell,_that.previous,_that.next);case _:
  return null;

}
}

}

/// @nodoc


class _PriceWrite implements PriceWrite {
  const _PriceWrite({required this.cell, required this.previous, required this.next});
  

@override final  PriceCellKey cell;
@override final  String? previous;
@override final  String next;

/// Create a copy of PriceWrite
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PriceWriteCopyWith<_PriceWrite> get copyWith => __$PriceWriteCopyWithImpl<_PriceWrite>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PriceWrite&&(identical(other.cell, cell) || other.cell == cell)&&(identical(other.previous, previous) || other.previous == previous)&&(identical(other.next, next) || other.next == next));
}


@override
int get hashCode {
    return Object.hash(runtimeType,cell,previous,next);
}

@override
String toString() {
    return 'PriceWrite(cell: $cell, previous: $previous, next: $next)';
}


}

/// @nodoc
abstract mixin class _$PriceWriteCopyWith<$Res> implements $PriceWriteCopyWith<$Res> {
  factory _$PriceWriteCopyWith(_PriceWrite value, $Res Function(_PriceWrite) _then) = __$PriceWriteCopyWithImpl;
@override @useResult
$Res call({
 PriceCellKey cell, String? previous, String next
});


@override $PriceCellKeyCopyWith<$Res> get cell;

}
/// @nodoc
class __$PriceWriteCopyWithImpl<$Res>
    implements _$PriceWriteCopyWith<$Res> {
  __$PriceWriteCopyWithImpl(this._self, this._then);

  final _PriceWrite _self;
  final $Res Function(_PriceWrite) _then;

/// Create a copy of PriceWrite
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cell = null,Object? previous = freezed,Object? next = null,}) {
  return _then(_PriceWrite(
cell: null == cell ? _self.cell : cell // ignore: cast_nullable_to_non_nullable
as PriceCellKey,previous: freezed == previous ? _self.previous : previous // ignore: cast_nullable_to_non_nullable
as String?,next: null == next ? _self.next : next // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of PriceWrite
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCellKeyCopyWith<$Res> get cell {
  
  return $PriceCellKeyCopyWith<$Res>(_self.cell, (value) {
    return _then(_self.copyWith(cell: value));
  });
}
}

/// @nodoc
mixin _$PriceChange {

 PriceChangeKind get kind; List<PriceWrite> get writes;
/// Create a copy of PriceChange
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PriceChangeCopyWith<PriceChange> get copyWith => _$PriceChangeCopyWithImpl<PriceChange>(this as PriceChange, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PriceChange;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PriceChange&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&const DeepCollectionEquality().equals(other.writes, _this.writes));
}


@override
int get hashCode {
  final _this = this as PriceChange;
  return Object.hash(runtimeType,_this.kind,const DeepCollectionEquality().hash(_this.writes));
}

@override
String toString() {
  final _this = this as PriceChange;
  return 'PriceChange(kind: ${_this.kind}, writes: ${_this.writes})';
}


}

/// @nodoc
abstract mixin class $PriceChangeCopyWith<$Res>  {
  factory $PriceChangeCopyWith(PriceChange value, $Res Function(PriceChange) _then) = _$PriceChangeCopyWithImpl;
@useResult
$Res call({
 PriceChangeKind kind, List<PriceWrite> writes
});




}
/// @nodoc
class _$PriceChangeCopyWithImpl<$Res>
    implements $PriceChangeCopyWith<$Res> {
  _$PriceChangeCopyWithImpl(this._self, this._then);

  final PriceChange _self;
  final $Res Function(PriceChange) _then;

/// Create a copy of PriceChange
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? writes = null,}) {
  return _then(PriceChange(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as PriceChangeKind,writes: null == writes ? _self.writes : writes // ignore: cast_nullable_to_non_nullable
as List<PriceWrite>,
  ));
}

}


/// Adds pattern-matching-related methods to [PriceChange].
extension PriceChangePatterns on PriceChange {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PriceChange value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PriceChange() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PriceChange value)  $default,){
final _that = this;
switch (_that) {
case _PriceChange():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PriceChange value)?  $default,){
final _that = this;
switch (_that) {
case _PriceChange() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PriceChangeKind kind,  List<PriceWrite> writes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PriceChange() when $default != null:
return $default(_that.kind,_that.writes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PriceChangeKind kind,  List<PriceWrite> writes)  $default,) {final _that = this;
switch (_that) {
case _PriceChange():
return $default(_that.kind,_that.writes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PriceChangeKind kind,  List<PriceWrite> writes)?  $default,) {final _that = this;
switch (_that) {
case _PriceChange() when $default != null:
return $default(_that.kind,_that.writes);case _:
  return null;

}
}

}

/// @nodoc


class _PriceChange implements PriceChange {
  const _PriceChange({required this.kind, required  List<PriceWrite> writes}): _writes = writes;
  

@override final  PriceChangeKind kind;
 final  List<PriceWrite> _writes;
@override List<PriceWrite> get writes {
  if (_writes is EqualUnmodifiableListView) return _writes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_writes);
}


/// Create a copy of PriceChange
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PriceChangeCopyWith<_PriceChange> get copyWith => __$PriceChangeCopyWithImpl<_PriceChange>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PriceChange&&(identical(other.kind, kind) || other.kind == kind)&&const DeepCollectionEquality().equals(other.writes, _writes));
}


@override
int get hashCode {
    return Object.hash(runtimeType,kind,const DeepCollectionEquality().hash(_writes));
}

@override
String toString() {
    return 'PriceChange(kind: $kind, writes: $writes)';
}


}

/// @nodoc
abstract mixin class _$PriceChangeCopyWith<$Res> implements $PriceChangeCopyWith<$Res> {
  factory _$PriceChangeCopyWith(_PriceChange value, $Res Function(_PriceChange) _then) = __$PriceChangeCopyWithImpl;
@override @useResult
$Res call({
 PriceChangeKind kind, List<PriceWrite> writes
});




}
/// @nodoc
class __$PriceChangeCopyWithImpl<$Res>
    implements _$PriceChangeCopyWith<$Res> {
  __$PriceChangeCopyWithImpl(this._self, this._then);

  final _PriceChange _self;
  final $Res Function(_PriceChange) _then;

/// Create a copy of PriceChange
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? writes = null,}) {
  return _then(_PriceChange(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as PriceChangeKind,writes: null == writes ? _self._writes : writes // ignore: cast_nullable_to_non_nullable
as List<PriceWrite>,
  ));
}


}

/// @nodoc
mixin _$PricingGridState {

 List<PricingGridRow> get rows; List<PriceList> get allLists; CatalogPage<PricingGridRow>? get page;/// The cell currently open for editing, or `null` when none is.
 PriceCellKey? get active;/// The typed text of the currently-active cell (data-model.md §3), or
/// `null` when nothing has been typed since it opened. Set on every
/// keystroke ([PricingGridController.updateDraft]); cleared whenever
/// [active] changes or the cell is committed or discarded.
 String? get activeDraft;/// Cells whose write is in flight (FR-022 "saving").
 Set<PriceCellKey> get inFlight;/// Cells the server (or client-side parsing) refused (FR-009).
 Map<PriceCellKey, RejectedEdit> get rejected;/// The value each visible cell held when the current view loaded — the
/// baseline "revert all" restores to (FR-024), and the source of the
/// "was X" tooltip and the changed-count in the summary bar.
 Map<PriceCellKey, String?> get baseline;/// Newest last. One entry per undoable change (FR-016, FR-024).
 List<PriceChange> get history;
/// Create a copy of PricingGridState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PricingGridStateCopyWith<PricingGridState> get copyWith => _$PricingGridStateCopyWithImpl<PricingGridState>(this as PricingGridState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PricingGridState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PricingGridState&&const DeepCollectionEquality().equals(other.rows, _this.rows)&&const DeepCollectionEquality().equals(other.allLists, _this.allLists)&&(identical(other.page, _this.page) || other.page == _this.page)&&(identical(other.active, _this.active) || other.active == _this.active)&&(identical(other.activeDraft, _this.activeDraft) || other.activeDraft == _this.activeDraft)&&const DeepCollectionEquality().equals(other.inFlight, _this.inFlight)&&const DeepCollectionEquality().equals(other.rejected, _this.rejected)&&const DeepCollectionEquality().equals(other.baseline, _this.baseline)&&const DeepCollectionEquality().equals(other.history, _this.history));
}


@override
int get hashCode {
  final _this = this as PricingGridState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.rows),const DeepCollectionEquality().hash(_this.allLists),_this.page,_this.active,_this.activeDraft,const DeepCollectionEquality().hash(_this.inFlight),const DeepCollectionEquality().hash(_this.rejected),const DeepCollectionEquality().hash(_this.baseline),const DeepCollectionEquality().hash(_this.history));
}

@override
String toString() {
  final _this = this as PricingGridState;
  return 'PricingGridState(rows: ${_this.rows}, allLists: ${_this.allLists}, page: ${_this.page}, active: ${_this.active}, activeDraft: ${_this.activeDraft}, inFlight: ${_this.inFlight}, rejected: ${_this.rejected}, baseline: ${_this.baseline}, history: ${_this.history})';
}


}

/// @nodoc
abstract mixin class $PricingGridStateCopyWith<$Res>  {
  factory $PricingGridStateCopyWith(PricingGridState value, $Res Function(PricingGridState) _then) = _$PricingGridStateCopyWithImpl;
@useResult
$Res call({
 List<PricingGridRow> rows, List<PriceList> allLists, CatalogPage<PricingGridRow>? page, PriceCellKey? active, String? activeDraft, Set<PriceCellKey> inFlight, Map<PriceCellKey, RejectedEdit> rejected, Map<PriceCellKey, String?> baseline, List<PriceChange> history
});


$PriceCellKeyCopyWith<$Res>? get active;

}
/// @nodoc
class _$PricingGridStateCopyWithImpl<$Res>
    implements $PricingGridStateCopyWith<$Res> {
  _$PricingGridStateCopyWithImpl(this._self, this._then);

  final PricingGridState _self;
  final $Res Function(PricingGridState) _then;

/// Create a copy of PricingGridState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rows = null,Object? allLists = null,Object? page = freezed,Object? active = freezed,Object? activeDraft = freezed,Object? inFlight = null,Object? rejected = null,Object? baseline = null,Object? history = null,}) {
  return _then(PricingGridState(
rows: null == rows ? _self.rows : rows // ignore: cast_nullable_to_non_nullable
as List<PricingGridRow>,allLists: null == allLists ? _self.allLists : allLists // ignore: cast_nullable_to_non_nullable
as List<PriceList>,page: freezed == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as CatalogPage<PricingGridRow>?,active: freezed == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as PriceCellKey?,activeDraft: freezed == activeDraft ? _self.activeDraft : activeDraft // ignore: cast_nullable_to_non_nullable
as String?,inFlight: null == inFlight ? _self.inFlight : inFlight // ignore: cast_nullable_to_non_nullable
as Set<PriceCellKey>,rejected: null == rejected ? _self.rejected : rejected // ignore: cast_nullable_to_non_nullable
as Map<PriceCellKey, RejectedEdit>,baseline: null == baseline ? _self.baseline : baseline // ignore: cast_nullable_to_non_nullable
as Map<PriceCellKey, String?>,history: null == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as List<PriceChange>,
  ));
}
/// Create a copy of PricingGridState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCellKeyCopyWith<$Res>? get active {
    if (_self.active == null) {
    return null;
  }

  return $PriceCellKeyCopyWith<$Res>(_self.active!, (value) {
    return _then(_self.copyWith(active: value));
  });
}
}


/// Adds pattern-matching-related methods to [PricingGridState].
extension PricingGridStatePatterns on PricingGridState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PricingGridState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PricingGridState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PricingGridState value)  $default,){
final _that = this;
switch (_that) {
case _PricingGridState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PricingGridState value)?  $default,){
final _that = this;
switch (_that) {
case _PricingGridState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<PricingGridRow> rows,  List<PriceList> allLists,  CatalogPage<PricingGridRow>? page,  PriceCellKey? active,  String? activeDraft,  Set<PriceCellKey> inFlight,  Map<PriceCellKey, RejectedEdit> rejected,  Map<PriceCellKey, String?> baseline,  List<PriceChange> history)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PricingGridState() when $default != null:
return $default(_that.rows,_that.allLists,_that.page,_that.active,_that.activeDraft,_that.inFlight,_that.rejected,_that.baseline,_that.history);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<PricingGridRow> rows,  List<PriceList> allLists,  CatalogPage<PricingGridRow>? page,  PriceCellKey? active,  String? activeDraft,  Set<PriceCellKey> inFlight,  Map<PriceCellKey, RejectedEdit> rejected,  Map<PriceCellKey, String?> baseline,  List<PriceChange> history)  $default,) {final _that = this;
switch (_that) {
case _PricingGridState():
return $default(_that.rows,_that.allLists,_that.page,_that.active,_that.activeDraft,_that.inFlight,_that.rejected,_that.baseline,_that.history);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<PricingGridRow> rows,  List<PriceList> allLists,  CatalogPage<PricingGridRow>? page,  PriceCellKey? active,  String? activeDraft,  Set<PriceCellKey> inFlight,  Map<PriceCellKey, RejectedEdit> rejected,  Map<PriceCellKey, String?> baseline,  List<PriceChange> history)?  $default,) {final _that = this;
switch (_that) {
case _PricingGridState() when $default != null:
return $default(_that.rows,_that.allLists,_that.page,_that.active,_that.activeDraft,_that.inFlight,_that.rejected,_that.baseline,_that.history);case _:
  return null;

}
}

}

/// @nodoc


class _PricingGridState implements PricingGridState {
  const _PricingGridState({ List<PricingGridRow> rows = const <PricingGridRow>[],  List<PriceList> allLists = const <PriceList>[], this.page, this.active, this.activeDraft,  Set<PriceCellKey> inFlight = const <PriceCellKey>{},  Map<PriceCellKey, RejectedEdit> rejected = const <PriceCellKey, RejectedEdit>{},  Map<PriceCellKey, String?> baseline = const <PriceCellKey, String?>{},  List<PriceChange> history = const <PriceChange>[]}): _rows = rows,_allLists = allLists,_inFlight = inFlight,_rejected = rejected,_baseline = baseline,_history = history;
  

 final  List<PricingGridRow> _rows;
@override@JsonKey() List<PricingGridRow> get rows {
  if (_rows is EqualUnmodifiableListView) return _rows;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rows);
}

 final  List<PriceList> _allLists;
@override@JsonKey() List<PriceList> get allLists {
  if (_allLists is EqualUnmodifiableListView) return _allLists;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allLists);
}

@override final  CatalogPage<PricingGridRow>? page;
/// The cell currently open for editing, or `null` when none is.
@override final  PriceCellKey? active;
/// The typed text of the currently-active cell (data-model.md §3), or
/// `null` when nothing has been typed since it opened. Set on every
/// keystroke ([PricingGridController.updateDraft]); cleared whenever
/// [active] changes or the cell is committed or discarded.
@override final  String? activeDraft;
/// Cells whose write is in flight (FR-022 "saving").
 final  Set<PriceCellKey> _inFlight;
/// Cells whose write is in flight (FR-022 "saving").
@override@JsonKey() Set<PriceCellKey> get inFlight {
  if (_inFlight is EqualUnmodifiableSetView) return _inFlight;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_inFlight);
}

/// Cells the server (or client-side parsing) refused (FR-009).
 final  Map<PriceCellKey, RejectedEdit> _rejected;
/// Cells the server (or client-side parsing) refused (FR-009).
@override@JsonKey() Map<PriceCellKey, RejectedEdit> get rejected {
  if (_rejected is EqualUnmodifiableMapView) return _rejected;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_rejected);
}

/// The value each visible cell held when the current view loaded — the
/// baseline "revert all" restores to (FR-024), and the source of the
/// "was X" tooltip and the changed-count in the summary bar.
 final  Map<PriceCellKey, String?> _baseline;
/// The value each visible cell held when the current view loaded — the
/// baseline "revert all" restores to (FR-024), and the source of the
/// "was X" tooltip and the changed-count in the summary bar.
@override@JsonKey() Map<PriceCellKey, String?> get baseline {
  if (_baseline is EqualUnmodifiableMapView) return _baseline;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_baseline);
}

/// Newest last. One entry per undoable change (FR-016, FR-024).
 final  List<PriceChange> _history;
/// Newest last. One entry per undoable change (FR-016, FR-024).
@override@JsonKey() List<PriceChange> get history {
  if (_history is EqualUnmodifiableListView) return _history;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_history);
}


/// Create a copy of PricingGridState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PricingGridStateCopyWith<_PricingGridState> get copyWith => __$PricingGridStateCopyWithImpl<_PricingGridState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PricingGridState&&const DeepCollectionEquality().equals(other.rows, _rows)&&const DeepCollectionEquality().equals(other.allLists, _allLists)&&(identical(other.page, page) || other.page == page)&&(identical(other.active, active) || other.active == active)&&(identical(other.activeDraft, activeDraft) || other.activeDraft == activeDraft)&&const DeepCollectionEquality().equals(other.inFlight, _inFlight)&&const DeepCollectionEquality().equals(other.rejected, _rejected)&&const DeepCollectionEquality().equals(other.baseline, _baseline)&&const DeepCollectionEquality().equals(other.history, _history));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_rows),const DeepCollectionEquality().hash(_allLists),page,active,activeDraft,const DeepCollectionEquality().hash(_inFlight),const DeepCollectionEquality().hash(_rejected),const DeepCollectionEquality().hash(_baseline),const DeepCollectionEquality().hash(_history));
}

@override
String toString() {
    return 'PricingGridState(rows: $rows, allLists: $allLists, page: $page, active: $active, activeDraft: $activeDraft, inFlight: $inFlight, rejected: $rejected, baseline: $baseline, history: $history)';
}


}

/// @nodoc
abstract mixin class _$PricingGridStateCopyWith<$Res> implements $PricingGridStateCopyWith<$Res> {
  factory _$PricingGridStateCopyWith(_PricingGridState value, $Res Function(_PricingGridState) _then) = __$PricingGridStateCopyWithImpl;
@override @useResult
$Res call({
 List<PricingGridRow> rows, List<PriceList> allLists, CatalogPage<PricingGridRow>? page, PriceCellKey? active, String? activeDraft, Set<PriceCellKey> inFlight, Map<PriceCellKey, RejectedEdit> rejected, Map<PriceCellKey, String?> baseline, List<PriceChange> history
});


@override $PriceCellKeyCopyWith<$Res>? get active;

}
/// @nodoc
class __$PricingGridStateCopyWithImpl<$Res>
    implements _$PricingGridStateCopyWith<$Res> {
  __$PricingGridStateCopyWithImpl(this._self, this._then);

  final _PricingGridState _self;
  final $Res Function(_PricingGridState) _then;

/// Create a copy of PricingGridState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rows = null,Object? allLists = null,Object? page = freezed,Object? active = freezed,Object? activeDraft = freezed,Object? inFlight = null,Object? rejected = null,Object? baseline = null,Object? history = null,}) {
  return _then(_PricingGridState(
rows: null == rows ? _self._rows : rows // ignore: cast_nullable_to_non_nullable
as List<PricingGridRow>,allLists: null == allLists ? _self._allLists : allLists // ignore: cast_nullable_to_non_nullable
as List<PriceList>,page: freezed == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as CatalogPage<PricingGridRow>?,active: freezed == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as PriceCellKey?,activeDraft: freezed == activeDraft ? _self.activeDraft : activeDraft // ignore: cast_nullable_to_non_nullable
as String?,inFlight: null == inFlight ? _self._inFlight : inFlight // ignore: cast_nullable_to_non_nullable
as Set<PriceCellKey>,rejected: null == rejected ? _self._rejected : rejected // ignore: cast_nullable_to_non_nullable
as Map<PriceCellKey, RejectedEdit>,baseline: null == baseline ? _self._baseline : baseline // ignore: cast_nullable_to_non_nullable
as Map<PriceCellKey, String?>,history: null == history ? _self._history : history // ignore: cast_nullable_to_non_nullable
as List<PriceChange>,
  ));
}

/// Create a copy of PricingGridState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCellKeyCopyWith<$Res>? get active {
    if (_self.active == null) {
    return null;
  }

  return $PriceCellKeyCopyWith<$Res>(_self.active!, (value) {
    return _then(_self.copyWith(active: value));
  });
}
}

// dart format on
