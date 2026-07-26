// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'merge_preview.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$MergePreview {
  /// One entry per referencing relation, in the server's order (largest
  /// count first).
  List<MergePreviewCategory> get categories =>
      throw _privateConstructorUsedError;

  /// The server's own total. Displayed as-is rather than re-summed here, so
  /// what the operator reads always matches what the backend counted
  /// (SC-006).
  int get total => throw _privateConstructorUsedError;

  /// Create a copy of MergePreview
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MergePreviewCopyWith<MergePreview> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MergePreviewCopyWith<$Res> {
  factory $MergePreviewCopyWith(
    MergePreview value,
    $Res Function(MergePreview) then,
  ) = _$MergePreviewCopyWithImpl<$Res, MergePreview>;
  @useResult
  $Res call({List<MergePreviewCategory> categories, int total});
}

/// @nodoc
class _$MergePreviewCopyWithImpl<$Res, $Val extends MergePreview>
    implements $MergePreviewCopyWith<$Res> {
  _$MergePreviewCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MergePreview
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? categories = null, Object? total = null}) {
    return _then(
      _value.copyWith(
            categories: null == categories
                ? _value.categories
                : categories // ignore: cast_nullable_to_non_nullable
                      as List<MergePreviewCategory>,
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
abstract class _$$MergePreviewImplCopyWith<$Res>
    implements $MergePreviewCopyWith<$Res> {
  factory _$$MergePreviewImplCopyWith(
    _$MergePreviewImpl value,
    $Res Function(_$MergePreviewImpl) then,
  ) = __$$MergePreviewImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<MergePreviewCategory> categories, int total});
}

/// @nodoc
class __$$MergePreviewImplCopyWithImpl<$Res>
    extends _$MergePreviewCopyWithImpl<$Res, _$MergePreviewImpl>
    implements _$$MergePreviewImplCopyWith<$Res> {
  __$$MergePreviewImplCopyWithImpl(
    _$MergePreviewImpl _value,
    $Res Function(_$MergePreviewImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MergePreview
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? categories = null, Object? total = null}) {
    return _then(
      _$MergePreviewImpl(
        categories: null == categories
            ? _value._categories
            : categories // ignore: cast_nullable_to_non_nullable
                  as List<MergePreviewCategory>,
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$MergePreviewImpl extends _MergePreview {
  const _$MergePreviewImpl({
    required final List<MergePreviewCategory> categories,
    required this.total,
  }) : _categories = categories,
       super._();

  /// One entry per referencing relation, in the server's order (largest
  /// count first).
  final List<MergePreviewCategory> _categories;

  /// One entry per referencing relation, in the server's order (largest
  /// count first).
  @override
  List<MergePreviewCategory> get categories {
    if (_categories is EqualUnmodifiableListView) return _categories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categories);
  }

  /// The server's own total. Displayed as-is rather than re-summed here, so
  /// what the operator reads always matches what the backend counted
  /// (SC-006).
  @override
  final int total;

  @override
  String toString() {
    return 'MergePreview(categories: $categories, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MergePreviewImpl &&
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

  /// Create a copy of MergePreview
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MergePreviewImplCopyWith<_$MergePreviewImpl> get copyWith =>
      __$$MergePreviewImplCopyWithImpl<_$MergePreviewImpl>(this, _$identity);
}

abstract class _MergePreview extends MergePreview {
  const factory _MergePreview({
    required final List<MergePreviewCategory> categories,
    required final int total,
  }) = _$MergePreviewImpl;
  const _MergePreview._() : super._();

  /// One entry per referencing relation, in the server's order (largest
  /// count first).
  @override
  List<MergePreviewCategory> get categories;

  /// The server's own total. Displayed as-is rather than re-summed here, so
  /// what the operator reads always matches what the backend counted
  /// (SC-006).
  @override
  int get total;

  /// Create a copy of MergePreview
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MergePreviewImplCopyWith<_$MergePreviewImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$MergePreviewCategory {
  /// The raw `table.column` identifier as mbe-api reports it (e.g.
  /// `sales_order_detail.product`). Kept verbatim: the category set is
  /// derived from mbe-api's mapped metadata and grows whenever a new
  /// foreign key to `product` is added, so the UI resolves a label from
  /// this key rather than relying on a closed enum (research.md §4).
  String get key => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;

  /// Create a copy of MergePreviewCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MergePreviewCategoryCopyWith<MergePreviewCategory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MergePreviewCategoryCopyWith<$Res> {
  factory $MergePreviewCategoryCopyWith(
    MergePreviewCategory value,
    $Res Function(MergePreviewCategory) then,
  ) = _$MergePreviewCategoryCopyWithImpl<$Res, MergePreviewCategory>;
  @useResult
  $Res call({String key, int count});
}

/// @nodoc
class _$MergePreviewCategoryCopyWithImpl<
  $Res,
  $Val extends MergePreviewCategory
>
    implements $MergePreviewCategoryCopyWith<$Res> {
  _$MergePreviewCategoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MergePreviewCategory
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
abstract class _$$MergePreviewCategoryImplCopyWith<$Res>
    implements $MergePreviewCategoryCopyWith<$Res> {
  factory _$$MergePreviewCategoryImplCopyWith(
    _$MergePreviewCategoryImpl value,
    $Res Function(_$MergePreviewCategoryImpl) then,
  ) = __$$MergePreviewCategoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String key, int count});
}

/// @nodoc
class __$$MergePreviewCategoryImplCopyWithImpl<$Res>
    extends _$MergePreviewCategoryCopyWithImpl<$Res, _$MergePreviewCategoryImpl>
    implements _$$MergePreviewCategoryImplCopyWith<$Res> {
  __$$MergePreviewCategoryImplCopyWithImpl(
    _$MergePreviewCategoryImpl _value,
    $Res Function(_$MergePreviewCategoryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MergePreviewCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? key = null, Object? count = null}) {
    return _then(
      _$MergePreviewCategoryImpl(
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

class _$MergePreviewCategoryImpl extends _MergePreviewCategory {
  const _$MergePreviewCategoryImpl({required this.key, required this.count})
    : super._();

  /// The raw `table.column` identifier as mbe-api reports it (e.g.
  /// `sales_order_detail.product`). Kept verbatim: the category set is
  /// derived from mbe-api's mapped metadata and grows whenever a new
  /// foreign key to `product` is added, so the UI resolves a label from
  /// this key rather than relying on a closed enum (research.md §4).
  @override
  final String key;
  @override
  final int count;

  @override
  String toString() {
    return 'MergePreviewCategory(key: $key, count: $count)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MergePreviewCategoryImpl &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.count, count) || other.count == count));
  }

  @override
  int get hashCode => Object.hash(runtimeType, key, count);

  /// Create a copy of MergePreviewCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MergePreviewCategoryImplCopyWith<_$MergePreviewCategoryImpl>
  get copyWith =>
      __$$MergePreviewCategoryImplCopyWithImpl<_$MergePreviewCategoryImpl>(
        this,
        _$identity,
      );
}

abstract class _MergePreviewCategory extends MergePreviewCategory {
  const factory _MergePreviewCategory({
    required final String key,
    required final int count,
  }) = _$MergePreviewCategoryImpl;
  const _MergePreviewCategory._() : super._();

  /// The raw `table.column` identifier as mbe-api reports it (e.g.
  /// `sales_order_detail.product`). Kept verbatim: the category set is
  /// derived from mbe-api's mapped metadata and grows whenever a new
  /// foreign key to `product` is added, so the UI resolves a label from
  /// this key rather than relying on a closed enum (research.md §4).
  @override
  String get key;
  @override
  int get count;

  /// Create a copy of MergePreviewCategory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MergePreviewCategoryImplCopyWith<_$MergePreviewCategoryImpl>
  get copyWith => throw _privateConstructorUsedError;
}
