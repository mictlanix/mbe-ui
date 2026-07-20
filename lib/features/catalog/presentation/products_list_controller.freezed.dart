// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'products_list_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ProductFilter {
  String get search => throw _privateConstructorUsedError;
  EntityStatus? get status => throw _privateConstructorUsedError;
  bool? get stockable => throw _privateConstructorUsedError;
  bool? get salable => throw _privateConstructorUsedError;
  bool? get purchasable => throw _privateConstructorUsedError;
  List<int> get labels => throw _privateConstructorUsedError;

  /// Create a copy of ProductFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductFilterCopyWith<ProductFilter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductFilterCopyWith<$Res> {
  factory $ProductFilterCopyWith(
    ProductFilter value,
    $Res Function(ProductFilter) then,
  ) = _$ProductFilterCopyWithImpl<$Res, ProductFilter>;
  @useResult
  $Res call({
    String search,
    EntityStatus? status,
    bool? stockable,
    bool? salable,
    bool? purchasable,
    List<int> labels,
  });
}

/// @nodoc
class _$ProductFilterCopyWithImpl<$Res, $Val extends ProductFilter>
    implements $ProductFilterCopyWith<$Res> {
  _$ProductFilterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? search = null,
    Object? status = freezed,
    Object? stockable = freezed,
    Object? salable = freezed,
    Object? purchasable = freezed,
    Object? labels = null,
  }) {
    return _then(
      _value.copyWith(
            search: null == search
                ? _value.search
                : search // ignore: cast_nullable_to_non_nullable
                      as String,
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as EntityStatus?,
            stockable: freezed == stockable
                ? _value.stockable
                : stockable // ignore: cast_nullable_to_non_nullable
                      as bool?,
            salable: freezed == salable
                ? _value.salable
                : salable // ignore: cast_nullable_to_non_nullable
                      as bool?,
            purchasable: freezed == purchasable
                ? _value.purchasable
                : purchasable // ignore: cast_nullable_to_non_nullable
                      as bool?,
            labels: null == labels
                ? _value.labels
                : labels // ignore: cast_nullable_to_non_nullable
                      as List<int>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProductFilterImplCopyWith<$Res>
    implements $ProductFilterCopyWith<$Res> {
  factory _$$ProductFilterImplCopyWith(
    _$ProductFilterImpl value,
    $Res Function(_$ProductFilterImpl) then,
  ) = __$$ProductFilterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String search,
    EntityStatus? status,
    bool? stockable,
    bool? salable,
    bool? purchasable,
    List<int> labels,
  });
}

/// @nodoc
class __$$ProductFilterImplCopyWithImpl<$Res>
    extends _$ProductFilterCopyWithImpl<$Res, _$ProductFilterImpl>
    implements _$$ProductFilterImplCopyWith<$Res> {
  __$$ProductFilterImplCopyWithImpl(
    _$ProductFilterImpl _value,
    $Res Function(_$ProductFilterImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? search = null,
    Object? status = freezed,
    Object? stockable = freezed,
    Object? salable = freezed,
    Object? purchasable = freezed,
    Object? labels = null,
  }) {
    return _then(
      _$ProductFilterImpl(
        search: null == search
            ? _value.search
            : search // ignore: cast_nullable_to_non_nullable
                  as String,
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as EntityStatus?,
        stockable: freezed == stockable
            ? _value.stockable
            : stockable // ignore: cast_nullable_to_non_nullable
                  as bool?,
        salable: freezed == salable
            ? _value.salable
            : salable // ignore: cast_nullable_to_non_nullable
                  as bool?,
        purchasable: freezed == purchasable
            ? _value.purchasable
            : purchasable // ignore: cast_nullable_to_non_nullable
                  as bool?,
        labels: null == labels
            ? _value._labels
            : labels // ignore: cast_nullable_to_non_nullable
                  as List<int>,
      ),
    );
  }
}

/// @nodoc

class _$ProductFilterImpl implements _ProductFilter {
  const _$ProductFilterImpl({
    this.search = '',
    this.status,
    this.stockable,
    this.salable,
    this.purchasable,
    final List<int> labels = const <int>[],
  }) : _labels = labels;

  @override
  @JsonKey()
  final String search;
  @override
  final EntityStatus? status;
  @override
  final bool? stockable;
  @override
  final bool? salable;
  @override
  final bool? purchasable;
  final List<int> _labels;
  @override
  @JsonKey()
  List<int> get labels {
    if (_labels is EqualUnmodifiableListView) return _labels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_labels);
  }

  @override
  String toString() {
    return 'ProductFilter(search: $search, status: $status, stockable: $stockable, salable: $salable, purchasable: $purchasable, labels: $labels)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductFilterImpl &&
            (identical(other.search, search) || other.search == search) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.stockable, stockable) ||
                other.stockable == stockable) &&
            (identical(other.salable, salable) || other.salable == salable) &&
            (identical(other.purchasable, purchasable) ||
                other.purchasable == purchasable) &&
            const DeepCollectionEquality().equals(other._labels, _labels));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    search,
    status,
    stockable,
    salable,
    purchasable,
    const DeepCollectionEquality().hash(_labels),
  );

  /// Create a copy of ProductFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductFilterImplCopyWith<_$ProductFilterImpl> get copyWith =>
      __$$ProductFilterImplCopyWithImpl<_$ProductFilterImpl>(this, _$identity);
}

abstract class _ProductFilter implements ProductFilter {
  const factory _ProductFilter({
    final String search,
    final EntityStatus? status,
    final bool? stockable,
    final bool? salable,
    final bool? purchasable,
    final List<int> labels,
  }) = _$ProductFilterImpl;

  @override
  String get search;
  @override
  EntityStatus? get status;
  @override
  bool? get stockable;
  @override
  bool? get salable;
  @override
  bool? get purchasable;
  @override
  List<int> get labels;

  /// Create a copy of ProductFilter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductFilterImplCopyWith<_$ProductFilterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
