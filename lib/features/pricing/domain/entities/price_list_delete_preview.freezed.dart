// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'price_list_delete_preview.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$PriceListDeletePreview {
  /// One entry per referencing relation, in the server's order (largest
  /// count first). Never re-sorted client-side.
  List<PriceListDeleteCategory> get categories =>
      throw _privateConstructorUsedError;

  /// The server's own total, displayed as-is rather than re-summed here
  /// (SC-005) — records the deletion *touches*, not records it deletes
  /// (FR-004).
  int get total => throw _privateConstructorUsedError;

  /// Create a copy of PriceListDeletePreview
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PriceListDeletePreviewCopyWith<PriceListDeletePreview> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PriceListDeletePreviewCopyWith<$Res> {
  factory $PriceListDeletePreviewCopyWith(
    PriceListDeletePreview value,
    $Res Function(PriceListDeletePreview) then,
  ) = _$PriceListDeletePreviewCopyWithImpl<$Res, PriceListDeletePreview>;
  @useResult
  $Res call({List<PriceListDeleteCategory> categories, int total});
}

/// @nodoc
class _$PriceListDeletePreviewCopyWithImpl<
  $Res,
  $Val extends PriceListDeletePreview
>
    implements $PriceListDeletePreviewCopyWith<$Res> {
  _$PriceListDeletePreviewCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PriceListDeletePreview
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? categories = null, Object? total = null}) {
    return _then(
      _value.copyWith(
            categories: null == categories
                ? _value.categories
                : categories // ignore: cast_nullable_to_non_nullable
                      as List<PriceListDeleteCategory>,
            total: null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PriceListDeletePreviewImplCopyWith<$Res>
    implements $PriceListDeletePreviewCopyWith<$Res> {
  factory _$$PriceListDeletePreviewImplCopyWith(
    _$PriceListDeletePreviewImpl value,
    $Res Function(_$PriceListDeletePreviewImpl) then,
  ) = __$$PriceListDeletePreviewImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<PriceListDeleteCategory> categories, int total});
}

/// @nodoc
class __$$PriceListDeletePreviewImplCopyWithImpl<$Res>
    extends
        _$PriceListDeletePreviewCopyWithImpl<$Res, _$PriceListDeletePreviewImpl>
    implements _$$PriceListDeletePreviewImplCopyWith<$Res> {
  __$$PriceListDeletePreviewImplCopyWithImpl(
    _$PriceListDeletePreviewImpl _value,
    $Res Function(_$PriceListDeletePreviewImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PriceListDeletePreview
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? categories = null, Object? total = null}) {
    return _then(
      _$PriceListDeletePreviewImpl(
        categories: null == categories
            ? _value._categories
            : categories // ignore: cast_nullable_to_non_nullable
                  as List<PriceListDeleteCategory>,
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$PriceListDeletePreviewImpl extends _PriceListDeletePreview {
  const _$PriceListDeletePreviewImpl({
    required final List<PriceListDeleteCategory> categories,
    required this.total,
  }) : _categories = categories,
       super._();

  /// One entry per referencing relation, in the server's order (largest
  /// count first). Never re-sorted client-side.
  final List<PriceListDeleteCategory> _categories;

  /// One entry per referencing relation, in the server's order (largest
  /// count first). Never re-sorted client-side.
  @override
  List<PriceListDeleteCategory> get categories {
    if (_categories is EqualUnmodifiableListView) return _categories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categories);
  }

  /// The server's own total, displayed as-is rather than re-summed here
  /// (SC-005) — records the deletion *touches*, not records it deletes
  /// (FR-004).
  @override
  final int total;

  @override
  String toString() {
    return 'PriceListDeletePreview(categories: $categories, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PriceListDeletePreviewImpl &&
            const DeepCollectionEquality().equals(
              other._categories,
              _categories,
            ) &&
            (identical(other.total, total) || other.total == total));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_categories),
    total,
  );

  /// Create a copy of PriceListDeletePreview
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PriceListDeletePreviewImplCopyWith<_$PriceListDeletePreviewImpl>
  get copyWith =>
      __$$PriceListDeletePreviewImplCopyWithImpl<_$PriceListDeletePreviewImpl>(
        this,
        _$identity,
      );
}

abstract class _PriceListDeletePreview extends PriceListDeletePreview {
  const factory _PriceListDeletePreview({
    required final List<PriceListDeleteCategory> categories,
    required final int total,
  }) = _$PriceListDeletePreviewImpl;
  const _PriceListDeletePreview._() : super._();

  /// One entry per referencing relation, in the server's order (largest
  /// count first). Never re-sorted client-side.
  @override
  List<PriceListDeleteCategory> get categories;

  /// The server's own total, displayed as-is rather than re-summed here
  /// (SC-005) — records the deletion *touches*, not records it deletes
  /// (FR-004).
  @override
  int get total;

  /// Create a copy of PriceListDeletePreview
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PriceListDeletePreviewImplCopyWith<_$PriceListDeletePreviewImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$PriceListDeleteCategory {
  /// The raw `table.column` identifier mbe-api reports, kept verbatim so
  /// an unrecognized relation still reaches the UI rather than being
  /// dropped (FR-005).
  String get key => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;

  /// Create a copy of PriceListDeleteCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PriceListDeleteCategoryCopyWith<PriceListDeleteCategory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PriceListDeleteCategoryCopyWith<$Res> {
  factory $PriceListDeleteCategoryCopyWith(
    PriceListDeleteCategory value,
    $Res Function(PriceListDeleteCategory) then,
  ) = _$PriceListDeleteCategoryCopyWithImpl<$Res, PriceListDeleteCategory>;
  @useResult
  $Res call({String key, int count});
}

/// @nodoc
class _$PriceListDeleteCategoryCopyWithImpl<
  $Res,
  $Val extends PriceListDeleteCategory
>
    implements $PriceListDeleteCategoryCopyWith<$Res> {
  _$PriceListDeleteCategoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PriceListDeleteCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? key = null, Object? count = null}) {
    return _then(
      _value.copyWith(
            key: null == key
                ? _value.key
                : key // ignore: cast_nullable_to_non_nullable
                      as String,
            count: null == count
                ? _value.count
                : count // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PriceListDeleteCategoryImplCopyWith<$Res>
    implements $PriceListDeleteCategoryCopyWith<$Res> {
  factory _$$PriceListDeleteCategoryImplCopyWith(
    _$PriceListDeleteCategoryImpl value,
    $Res Function(_$PriceListDeleteCategoryImpl) then,
  ) = __$$PriceListDeleteCategoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String key, int count});
}

/// @nodoc
class __$$PriceListDeleteCategoryImplCopyWithImpl<$Res>
    extends
        _$PriceListDeleteCategoryCopyWithImpl<
          $Res,
          _$PriceListDeleteCategoryImpl
        >
    implements _$$PriceListDeleteCategoryImplCopyWith<$Res> {
  __$$PriceListDeleteCategoryImplCopyWithImpl(
    _$PriceListDeleteCategoryImpl _value,
    $Res Function(_$PriceListDeleteCategoryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PriceListDeleteCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? key = null, Object? count = null}) {
    return _then(
      _$PriceListDeleteCategoryImpl(
        key: null == key
            ? _value.key
            : key // ignore: cast_nullable_to_non_nullable
                  as String,
        count: null == count
            ? _value.count
            : count // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$PriceListDeleteCategoryImpl extends _PriceListDeleteCategory {
  const _$PriceListDeleteCategoryImpl({required this.key, required this.count})
    : super._();

  /// The raw `table.column` identifier mbe-api reports, kept verbatim so
  /// an unrecognized relation still reaches the UI rather than being
  /// dropped (FR-005).
  @override
  final String key;
  @override
  final int count;

  @override
  String toString() {
    return 'PriceListDeleteCategory(key: $key, count: $count)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PriceListDeleteCategoryImpl &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.count, count) || other.count == count));
  }

  @override
  int get hashCode => Object.hash(runtimeType, key, count);

  /// Create a copy of PriceListDeleteCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PriceListDeleteCategoryImplCopyWith<_$PriceListDeleteCategoryImpl>
  get copyWith =>
      __$$PriceListDeleteCategoryImplCopyWithImpl<
        _$PriceListDeleteCategoryImpl
      >(this, _$identity);
}

abstract class _PriceListDeleteCategory extends PriceListDeleteCategory {
  const factory _PriceListDeleteCategory({
    required final String key,
    required final int count,
  }) = _$PriceListDeleteCategoryImpl;
  const _PriceListDeleteCategory._() : super._();

  /// The raw `table.column` identifier mbe-api reports, kept verbatim so
  /// an unrecognized relation still reaches the UI rather than being
  /// dropped (FR-005).
  @override
  String get key;
  @override
  int get count;

  /// Create a copy of PriceListDeleteCategory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PriceListDeleteCategoryImplCopyWith<_$PriceListDeleteCategoryImpl>
  get copyWith => throw _privateConstructorUsedError;
}
