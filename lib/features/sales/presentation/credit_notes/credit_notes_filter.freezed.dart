// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'credit_notes_filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CreditNotesFilter {

 int? get customerId;/// Only notes a customer can spend from their balance — mbe-api's
/// `open_only` (FR-011).
 bool get openOnly; int get pageIndex;
/// Create a copy of CreditNotesFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreditNotesFilterCopyWith<CreditNotesFilter> get copyWith => _$CreditNotesFilterCopyWithImpl<CreditNotesFilter>(this as CreditNotesFilter, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CreditNotesFilter;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreditNotesFilter&&(identical(other.customerId, _this.customerId) || other.customerId == _this.customerId)&&(identical(other.openOnly, _this.openOnly) || other.openOnly == _this.openOnly)&&(identical(other.pageIndex, _this.pageIndex) || other.pageIndex == _this.pageIndex));
}


@override
int get hashCode {
  final _this = this as CreditNotesFilter;
  return Object.hash(runtimeType,_this.customerId,_this.openOnly,_this.pageIndex);
}

@override
String toString() {
  final _this = this as CreditNotesFilter;
  return 'CreditNotesFilter(customerId: ${_this.customerId}, openOnly: ${_this.openOnly}, pageIndex: ${_this.pageIndex})';
}


}

/// @nodoc
abstract mixin class $CreditNotesFilterCopyWith<$Res>  {
  factory $CreditNotesFilterCopyWith(CreditNotesFilter value, $Res Function(CreditNotesFilter) _then) = _$CreditNotesFilterCopyWithImpl;
@useResult
$Res call({
 int? customerId, bool openOnly, int pageIndex
});




}
/// @nodoc
class _$CreditNotesFilterCopyWithImpl<$Res>
    implements $CreditNotesFilterCopyWith<$Res> {
  _$CreditNotesFilterCopyWithImpl(this._self, this._then);

  final CreditNotesFilter _self;
  final $Res Function(CreditNotesFilter) _then;

/// Create a copy of CreditNotesFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? customerId = freezed,Object? openOnly = null,Object? pageIndex = null,}) {
  return _then(CreditNotesFilter(
customerId: freezed == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as int?,openOnly: null == openOnly ? _self.openOnly : openOnly // ignore: cast_nullable_to_non_nullable
as bool,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CreditNotesFilter].
extension CreditNotesFilterPatterns on CreditNotesFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreditNotesFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreditNotesFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreditNotesFilter value)  $default,){
final _that = this;
switch (_that) {
case _CreditNotesFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreditNotesFilter value)?  $default,){
final _that = this;
switch (_that) {
case _CreditNotesFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? customerId,  bool openOnly,  int pageIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreditNotesFilter() when $default != null:
return $default(_that.customerId,_that.openOnly,_that.pageIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? customerId,  bool openOnly,  int pageIndex)  $default,) {final _that = this;
switch (_that) {
case _CreditNotesFilter():
return $default(_that.customerId,_that.openOnly,_that.pageIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? customerId,  bool openOnly,  int pageIndex)?  $default,) {final _that = this;
switch (_that) {
case _CreditNotesFilter() when $default != null:
return $default(_that.customerId,_that.openOnly,_that.pageIndex);case _:
  return null;

}
}

}

/// @nodoc


class _CreditNotesFilter extends CreditNotesFilter {
  const _CreditNotesFilter({this.customerId, this.openOnly = false, this.pageIndex = 0}): super._();
  

@override final  int? customerId;
/// Only notes a customer can spend from their balance — mbe-api's
/// `open_only` (FR-011).
@override@JsonKey() final  bool openOnly;
@override@JsonKey() final  int pageIndex;

/// Create a copy of CreditNotesFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreditNotesFilterCopyWith<_CreditNotesFilter> get copyWith => __$CreditNotesFilterCopyWithImpl<_CreditNotesFilter>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreditNotesFilter&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.openOnly, openOnly) || other.openOnly == openOnly)&&(identical(other.pageIndex, pageIndex) || other.pageIndex == pageIndex));
}


@override
int get hashCode {
    return Object.hash(runtimeType,customerId,openOnly,pageIndex);
}

@override
String toString() {
    return 'CreditNotesFilter(customerId: $customerId, openOnly: $openOnly, pageIndex: $pageIndex)';
}


}

/// @nodoc
abstract mixin class _$CreditNotesFilterCopyWith<$Res> implements $CreditNotesFilterCopyWith<$Res> {
  factory _$CreditNotesFilterCopyWith(_CreditNotesFilter value, $Res Function(_CreditNotesFilter) _then) = __$CreditNotesFilterCopyWithImpl;
@override @useResult
$Res call({
 int? customerId, bool openOnly, int pageIndex
});




}
/// @nodoc
class __$CreditNotesFilterCopyWithImpl<$Res>
    implements _$CreditNotesFilterCopyWith<$Res> {
  __$CreditNotesFilterCopyWithImpl(this._self, this._then);

  final _CreditNotesFilter _self;
  final $Res Function(_CreditNotesFilter) _then;

/// Create a copy of CreditNotesFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? customerId = freezed,Object? openOnly = null,Object? pageIndex = null,}) {
  return _then(_CreditNotesFilter(
customerId: freezed == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as int?,openOnly: null == openOnly ? _self.openOnly : openOnly // ignore: cast_nullable_to_non_nullable
as bool,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
