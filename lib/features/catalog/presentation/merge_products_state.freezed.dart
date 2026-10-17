// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'merge_products_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MergeProductsState {

/// The "Product" selection — kept after a merge. `null` until chosen.
 ProductListItem? get canonical;/// The "Duplicate" selection — removed after a merge. `null` until
/// chosen.
 ProductListItem? get duplicate;/// `AsyncData` (idle/success), `AsyncLoading` (in-flight), or
/// `AsyncError(AppError)` (failed) — drives the in-flight lock (FR-009)
/// and the error banner (FR-011).
 AsyncValue<void> get submission;/// `true` after a successful [MergeProductsController.submit] call —
/// the screen confirms and returns to the list on this, mirroring
/// `ProductFormState.saved`/`deleted`'s one-shot-flag convention (a
/// plain `submission == AsyncData` can't distinguish "just succeeded"
/// from "never submitted", since idle state starts as `AsyncData(null)`
/// too).
 bool get merged;/// `true` once the operator has acknowledged that the product currently
/// in [duplicate] will be deleted (specs/016 FR-007). Reset to `false`
/// by every mutator that changes [canonical] or [duplicate] — including
/// [MergeProductsController.swap] — so an acknowledgment can never
/// outlive the record it named (FR-008).
 bool get acknowledged;
/// Create a copy of MergeProductsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MergeProductsStateCopyWith<MergeProductsState> get copyWith => _$MergeProductsStateCopyWithImpl<MergeProductsState>(this as MergeProductsState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MergeProductsState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MergeProductsState&&(identical(other.canonical, _this.canonical) || other.canonical == _this.canonical)&&(identical(other.duplicate, _this.duplicate) || other.duplicate == _this.duplicate)&&(identical(other.submission, _this.submission) || other.submission == _this.submission)&&(identical(other.merged, _this.merged) || other.merged == _this.merged)&&(identical(other.acknowledged, _this.acknowledged) || other.acknowledged == _this.acknowledged));
}


@override
int get hashCode {
  final _this = this as MergeProductsState;
  return Object.hash(runtimeType,_this.canonical,_this.duplicate,_this.submission,_this.merged,_this.acknowledged);
}

@override
String toString() {
  final _this = this as MergeProductsState;
  return 'MergeProductsState(canonical: ${_this.canonical}, duplicate: ${_this.duplicate}, submission: ${_this.submission}, merged: ${_this.merged}, acknowledged: ${_this.acknowledged})';
}


}

/// @nodoc
abstract mixin class $MergeProductsStateCopyWith<$Res>  {
  factory $MergeProductsStateCopyWith(MergeProductsState value, $Res Function(MergeProductsState) _then) = _$MergeProductsStateCopyWithImpl;
@useResult
$Res call({
 ProductListItem? canonical, ProductListItem? duplicate, AsyncValue<void> submission, bool merged, bool acknowledged
});


$ProductListItemCopyWith<$Res>? get canonical;$ProductListItemCopyWith<$Res>? get duplicate;

}
/// @nodoc
class _$MergeProductsStateCopyWithImpl<$Res>
    implements $MergeProductsStateCopyWith<$Res> {
  _$MergeProductsStateCopyWithImpl(this._self, this._then);

  final MergeProductsState _self;
  final $Res Function(MergeProductsState) _then;

/// Create a copy of MergeProductsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? canonical = freezed,Object? duplicate = freezed,Object? submission = null,Object? merged = null,Object? acknowledged = null,}) {
  return _then(MergeProductsState(
canonical: freezed == canonical ? _self.canonical : canonical // ignore: cast_nullable_to_non_nullable
as ProductListItem?,duplicate: freezed == duplicate ? _self.duplicate : duplicate // ignore: cast_nullable_to_non_nullable
as ProductListItem?,submission: null == submission ? _self.submission : submission // ignore: cast_nullable_to_non_nullable
as AsyncValue<void>,merged: null == merged ? _self.merged : merged // ignore: cast_nullable_to_non_nullable
as bool,acknowledged: null == acknowledged ? _self.acknowledged : acknowledged // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of MergeProductsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductListItemCopyWith<$Res>? get canonical {
    if (_self.canonical == null) {
    return null;
  }

  return $ProductListItemCopyWith<$Res>(_self.canonical!, (value) {
    return _then(_self.copyWith(canonical: value));
  });
}/// Create a copy of MergeProductsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductListItemCopyWith<$Res>? get duplicate {
    if (_self.duplicate == null) {
    return null;
  }

  return $ProductListItemCopyWith<$Res>(_self.duplicate!, (value) {
    return _then(_self.copyWith(duplicate: value));
  });
}
}


/// Adds pattern-matching-related methods to [MergeProductsState].
extension MergeProductsStatePatterns on MergeProductsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MergeProductsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MergeProductsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MergeProductsState value)  $default,){
final _that = this;
switch (_that) {
case _MergeProductsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MergeProductsState value)?  $default,){
final _that = this;
switch (_that) {
case _MergeProductsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ProductListItem? canonical,  ProductListItem? duplicate,  AsyncValue<void> submission,  bool merged,  bool acknowledged)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MergeProductsState() when $default != null:
return $default(_that.canonical,_that.duplicate,_that.submission,_that.merged,_that.acknowledged);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ProductListItem? canonical,  ProductListItem? duplicate,  AsyncValue<void> submission,  bool merged,  bool acknowledged)  $default,) {final _that = this;
switch (_that) {
case _MergeProductsState():
return $default(_that.canonical,_that.duplicate,_that.submission,_that.merged,_that.acknowledged);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ProductListItem? canonical,  ProductListItem? duplicate,  AsyncValue<void> submission,  bool merged,  bool acknowledged)?  $default,) {final _that = this;
switch (_that) {
case _MergeProductsState() when $default != null:
return $default(_that.canonical,_that.duplicate,_that.submission,_that.merged,_that.acknowledged);case _:
  return null;

}
}

}

/// @nodoc


class _MergeProductsState extends MergeProductsState {
  const _MergeProductsState({this.canonical, this.duplicate, this.submission = const AsyncValue<void>.data(null), this.merged = false, this.acknowledged = false}): super._();
  

/// The "Product" selection — kept after a merge. `null` until chosen.
@override final  ProductListItem? canonical;
/// The "Duplicate" selection — removed after a merge. `null` until
/// chosen.
@override final  ProductListItem? duplicate;
/// `AsyncData` (idle/success), `AsyncLoading` (in-flight), or
/// `AsyncError(AppError)` (failed) — drives the in-flight lock (FR-009)
/// and the error banner (FR-011).
@override@JsonKey() final  AsyncValue<void> submission;
/// `true` after a successful [MergeProductsController.submit] call —
/// the screen confirms and returns to the list on this, mirroring
/// `ProductFormState.saved`/`deleted`'s one-shot-flag convention (a
/// plain `submission == AsyncData` can't distinguish "just succeeded"
/// from "never submitted", since idle state starts as `AsyncData(null)`
/// too).
@override@JsonKey() final  bool merged;
/// `true` once the operator has acknowledged that the product currently
/// in [duplicate] will be deleted (specs/016 FR-007). Reset to `false`
/// by every mutator that changes [canonical] or [duplicate] — including
/// [MergeProductsController.swap] — so an acknowledgment can never
/// outlive the record it named (FR-008).
@override@JsonKey() final  bool acknowledged;

/// Create a copy of MergeProductsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MergeProductsStateCopyWith<_MergeProductsState> get copyWith => __$MergeProductsStateCopyWithImpl<_MergeProductsState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MergeProductsState&&(identical(other.canonical, canonical) || other.canonical == canonical)&&(identical(other.duplicate, duplicate) || other.duplicate == duplicate)&&(identical(other.submission, submission) || other.submission == submission)&&(identical(other.merged, merged) || other.merged == merged)&&(identical(other.acknowledged, acknowledged) || other.acknowledged == acknowledged));
}


@override
int get hashCode {
    return Object.hash(runtimeType,canonical,duplicate,submission,merged,acknowledged);
}

@override
String toString() {
    return 'MergeProductsState(canonical: $canonical, duplicate: $duplicate, submission: $submission, merged: $merged, acknowledged: $acknowledged)';
}


}

/// @nodoc
abstract mixin class _$MergeProductsStateCopyWith<$Res> implements $MergeProductsStateCopyWith<$Res> {
  factory _$MergeProductsStateCopyWith(_MergeProductsState value, $Res Function(_MergeProductsState) _then) = __$MergeProductsStateCopyWithImpl;
@override @useResult
$Res call({
 ProductListItem? canonical, ProductListItem? duplicate, AsyncValue<void> submission, bool merged, bool acknowledged
});


@override $ProductListItemCopyWith<$Res>? get canonical;@override $ProductListItemCopyWith<$Res>? get duplicate;

}
/// @nodoc
class __$MergeProductsStateCopyWithImpl<$Res>
    implements _$MergeProductsStateCopyWith<$Res> {
  __$MergeProductsStateCopyWithImpl(this._self, this._then);

  final _MergeProductsState _self;
  final $Res Function(_MergeProductsState) _then;

/// Create a copy of MergeProductsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? canonical = freezed,Object? duplicate = freezed,Object? submission = null,Object? merged = null,Object? acknowledged = null,}) {
  return _then(_MergeProductsState(
canonical: freezed == canonical ? _self.canonical : canonical // ignore: cast_nullable_to_non_nullable
as ProductListItem?,duplicate: freezed == duplicate ? _self.duplicate : duplicate // ignore: cast_nullable_to_non_nullable
as ProductListItem?,submission: null == submission ? _self.submission : submission // ignore: cast_nullable_to_non_nullable
as AsyncValue<void>,merged: null == merged ? _self.merged : merged // ignore: cast_nullable_to_non_nullable
as bool,acknowledged: null == acknowledged ? _self.acknowledged : acknowledged // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of MergeProductsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductListItemCopyWith<$Res>? get canonical {
    if (_self.canonical == null) {
    return null;
  }

  return $ProductListItemCopyWith<$Res>(_self.canonical!, (value) {
    return _then(_self.copyWith(canonical: value));
  });
}/// Create a copy of MergeProductsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductListItemCopyWith<$Res>? get duplicate {
    if (_self.duplicate == null) {
    return null;
  }

  return $ProductListItemCopyWith<$Res>(_self.duplicate!, (value) {
    return _then(_self.copyWith(duplicate: value));
  });
}
}

// dart format on
