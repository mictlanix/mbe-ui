// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'merge_products_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$MergeProductsState {
  /// The "Product" selection — kept after a merge. `null` until chosen.
  ProductListItem? get canonical => throw _privateConstructorUsedError;

  /// The "Duplicate" selection — removed after a merge. `null` until
  /// chosen.
  ProductListItem? get duplicate => throw _privateConstructorUsedError;

  /// `AsyncData` (idle/success), `AsyncLoading` (in-flight), or
  /// `AsyncError(AppError)` (failed) — drives the in-flight lock (FR-009)
  /// and the error banner (FR-011).
  AsyncValue<void> get submission => throw _privateConstructorUsedError;

  /// `true` after a successful [MergeProductsController.submit] call —
  /// the screen confirms and returns to the list on this, mirroring
  /// `ProductFormState.saved`/`deleted`'s one-shot-flag convention (a
  /// plain `submission == AsyncData` can't distinguish "just succeeded"
  /// from "never submitted", since idle state starts as `AsyncData(null)`
  /// too).
  bool get merged => throw _privateConstructorUsedError;

  /// Create a copy of MergeProductsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MergeProductsStateCopyWith<MergeProductsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MergeProductsStateCopyWith<$Res> {
  factory $MergeProductsStateCopyWith(
    MergeProductsState value,
    $Res Function(MergeProductsState) then,
  ) = _$MergeProductsStateCopyWithImpl<$Res, MergeProductsState>;
  @useResult
  $Res call({
    ProductListItem? canonical,
    ProductListItem? duplicate,
    AsyncValue<void> submission,
    bool merged,
  });

  $ProductListItemCopyWith<$Res>? get canonical;
  $ProductListItemCopyWith<$Res>? get duplicate;
}

/// @nodoc
class _$MergeProductsStateCopyWithImpl<$Res, $Val extends MergeProductsState>
    implements $MergeProductsStateCopyWith<$Res> {
  _$MergeProductsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MergeProductsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? canonical = freezed,
    Object? duplicate = freezed,
    Object? submission = null,
    Object? merged = null,
  }) {
    return _then(
      _value.copyWith(
            canonical: freezed == canonical
                ? _value.canonical
                : canonical // ignore: cast_nullable_to_non_nullable
                      as ProductListItem?,
            duplicate: freezed == duplicate
                ? _value.duplicate
                : duplicate // ignore: cast_nullable_to_non_nullable
                      as ProductListItem?,
            submission: null == submission
                ? _value.submission
                : submission // ignore: cast_nullable_to_non_nullable
                      as AsyncValue<void>,
            merged: null == merged
                ? _value.merged
                : merged // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }

  /// Create a copy of MergeProductsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProductListItemCopyWith<$Res>? get canonical {
    if (_value.canonical == null) {
      return null;
    }

    return $ProductListItemCopyWith<$Res>(_value.canonical!, (value) {
      return _then(_value.copyWith(canonical: value) as $Val);
    });
  }

  /// Create a copy of MergeProductsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProductListItemCopyWith<$Res>? get duplicate {
    if (_value.duplicate == null) {
      return null;
    }

    return $ProductListItemCopyWith<$Res>(_value.duplicate!, (value) {
      return _then(_value.copyWith(duplicate: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MergeProductsStateImplCopyWith<$Res>
    implements $MergeProductsStateCopyWith<$Res> {
  factory _$$MergeProductsStateImplCopyWith(
    _$MergeProductsStateImpl value,
    $Res Function(_$MergeProductsStateImpl) then,
  ) = __$$MergeProductsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    ProductListItem? canonical,
    ProductListItem? duplicate,
    AsyncValue<void> submission,
    bool merged,
  });

  @override
  $ProductListItemCopyWith<$Res>? get canonical;
  @override
  $ProductListItemCopyWith<$Res>? get duplicate;
}

/// @nodoc
class __$$MergeProductsStateImplCopyWithImpl<$Res>
    extends _$MergeProductsStateCopyWithImpl<$Res, _$MergeProductsStateImpl>
    implements _$$MergeProductsStateImplCopyWith<$Res> {
  __$$MergeProductsStateImplCopyWithImpl(
    _$MergeProductsStateImpl _value,
    $Res Function(_$MergeProductsStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MergeProductsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? canonical = freezed,
    Object? duplicate = freezed,
    Object? submission = null,
    Object? merged = null,
  }) {
    return _then(
      _$MergeProductsStateImpl(
        canonical: freezed == canonical
            ? _value.canonical
            : canonical // ignore: cast_nullable_to_non_nullable
                  as ProductListItem?,
        duplicate: freezed == duplicate
            ? _value.duplicate
            : duplicate // ignore: cast_nullable_to_non_nullable
                  as ProductListItem?,
        submission: null == submission
            ? _value.submission
            : submission // ignore: cast_nullable_to_non_nullable
                  as AsyncValue<void>,
        merged: null == merged
            ? _value.merged
            : merged // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$MergeProductsStateImpl extends _MergeProductsState {
  const _$MergeProductsStateImpl({
    this.canonical,
    this.duplicate,
    this.submission = const AsyncValue<void>.data(null),
    this.merged = false,
  }) : super._();

  /// The "Product" selection — kept after a merge. `null` until chosen.
  @override
  final ProductListItem? canonical;

  /// The "Duplicate" selection — removed after a merge. `null` until
  /// chosen.
  @override
  final ProductListItem? duplicate;

  /// `AsyncData` (idle/success), `AsyncLoading` (in-flight), or
  /// `AsyncError(AppError)` (failed) — drives the in-flight lock (FR-009)
  /// and the error banner (FR-011).
  @override
  @JsonKey()
  final AsyncValue<void> submission;

  /// `true` after a successful [MergeProductsController.submit] call —
  /// the screen confirms and returns to the list on this, mirroring
  /// `ProductFormState.saved`/`deleted`'s one-shot-flag convention (a
  /// plain `submission == AsyncData` can't distinguish "just succeeded"
  /// from "never submitted", since idle state starts as `AsyncData(null)`
  /// too).
  @override
  @JsonKey()
  final bool merged;

  @override
  String toString() {
    return 'MergeProductsState(canonical: $canonical, duplicate: $duplicate, submission: $submission, merged: $merged)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MergeProductsStateImpl &&
            (identical(other.canonical, canonical) ||
                other.canonical == canonical) &&
            (identical(other.duplicate, duplicate) ||
                other.duplicate == duplicate) &&
            (identical(other.submission, submission) ||
                other.submission == submission) &&
            (identical(other.merged, merged) || other.merged == merged));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, canonical, duplicate, submission, merged);

  /// Create a copy of MergeProductsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MergeProductsStateImplCopyWith<_$MergeProductsStateImpl> get copyWith =>
      __$$MergeProductsStateImplCopyWithImpl<_$MergeProductsStateImpl>(
        this,
        _$identity,
      );
}

abstract class _MergeProductsState extends MergeProductsState {
  const factory _MergeProductsState({
    final ProductListItem? canonical,
    final ProductListItem? duplicate,
    final AsyncValue<void> submission,
    final bool merged,
  }) = _$MergeProductsStateImpl;
  const _MergeProductsState._() : super._();

  /// The "Product" selection — kept after a merge. `null` until chosen.
  @override
  ProductListItem? get canonical;

  /// The "Duplicate" selection — removed after a merge. `null` until
  /// chosen.
  @override
  ProductListItem? get duplicate;

  /// `AsyncData` (idle/success), `AsyncLoading` (in-flight), or
  /// `AsyncError(AppError)` (failed) — drives the in-flight lock (FR-009)
  /// and the error banner (FR-011).
  @override
  AsyncValue<void> get submission;

  /// `true` after a successful [MergeProductsController.submit] call —
  /// the screen confirms and returns to the list on this, mirroring
  /// `ProductFormState.saved`/`deleted`'s one-shot-flag convention (a
  /// plain `submission == AsyncData` can't distinguish "just succeeded"
  /// from "never submitted", since idle state starts as `AsyncData(null)`
  /// too).
  @override
  bool get merged;

  /// Create a copy of MergeProductsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MergeProductsStateImplCopyWith<_$MergeProductsStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
