// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_list_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ProductListItem {
  int get productId => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get brand => throw _privateConstructorUsedError;
  String? get model => throw _privateConstructorUsedError;
  String get unitOfMeasurement => throw _privateConstructorUsedError;
  String get taxRate => throw _privateConstructorUsedError;
  bool get deactivated => throw _privateConstructorUsedError;

  /// Create a copy of ProductListItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductListItemCopyWith<ProductListItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductListItemCopyWith<$Res> {
  factory $ProductListItemCopyWith(
    ProductListItem value,
    $Res Function(ProductListItem) then,
  ) = _$ProductListItemCopyWithImpl<$Res, ProductListItem>;
  @useResult
  $Res call({
    int productId,
    String code,
    String name,
    String? brand,
    String? model,
    String unitOfMeasurement,
    String taxRate,
    bool deactivated,
  });
}

/// @nodoc
class _$ProductListItemCopyWithImpl<$Res, $Val extends ProductListItem>
    implements $ProductListItemCopyWith<$Res> {
  _$ProductListItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductListItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? code = null,
    Object? name = null,
    Object? brand = freezed,
    Object? model = freezed,
    Object? unitOfMeasurement = null,
    Object? taxRate = null,
    Object? deactivated = null,
  }) {
    return _then(
      _value.copyWith(
            productId: null == productId
                ? _value.productId
                : productId // ignore: cast_nullable_to_non_nullable
                      as int,
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            brand: freezed == brand
                ? _value.brand
                : brand // ignore: cast_nullable_to_non_nullable
                      as String?,
            model: freezed == model
                ? _value.model
                : model // ignore: cast_nullable_to_non_nullable
                      as String?,
            unitOfMeasurement: null == unitOfMeasurement
                ? _value.unitOfMeasurement
                : unitOfMeasurement // ignore: cast_nullable_to_non_nullable
                      as String,
            taxRate: null == taxRate
                ? _value.taxRate
                : taxRate // ignore: cast_nullable_to_non_nullable
                      as String,
            deactivated: null == deactivated
                ? _value.deactivated
                : deactivated // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProductListItemImplCopyWith<$Res>
    implements $ProductListItemCopyWith<$Res> {
  factory _$$ProductListItemImplCopyWith(
    _$ProductListItemImpl value,
    $Res Function(_$ProductListItemImpl) then,
  ) = __$$ProductListItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int productId,
    String code,
    String name,
    String? brand,
    String? model,
    String unitOfMeasurement,
    String taxRate,
    bool deactivated,
  });
}

/// @nodoc
class __$$ProductListItemImplCopyWithImpl<$Res>
    extends _$ProductListItemCopyWithImpl<$Res, _$ProductListItemImpl>
    implements _$$ProductListItemImplCopyWith<$Res> {
  __$$ProductListItemImplCopyWithImpl(
    _$ProductListItemImpl _value,
    $Res Function(_$ProductListItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductListItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? code = null,
    Object? name = null,
    Object? brand = freezed,
    Object? model = freezed,
    Object? unitOfMeasurement = null,
    Object? taxRate = null,
    Object? deactivated = null,
  }) {
    return _then(
      _$ProductListItemImpl(
        productId: null == productId
            ? _value.productId
            : productId // ignore: cast_nullable_to_non_nullable
                  as int,
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        brand: freezed == brand
            ? _value.brand
            : brand // ignore: cast_nullable_to_non_nullable
                  as String?,
        model: freezed == model
            ? _value.model
            : model // ignore: cast_nullable_to_non_nullable
                  as String?,
        unitOfMeasurement: null == unitOfMeasurement
            ? _value.unitOfMeasurement
            : unitOfMeasurement // ignore: cast_nullable_to_non_nullable
                  as String,
        taxRate: null == taxRate
            ? _value.taxRate
            : taxRate // ignore: cast_nullable_to_non_nullable
                  as String,
        deactivated: null == deactivated
            ? _value.deactivated
            : deactivated // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$ProductListItemImpl implements _ProductListItem {
  const _$ProductListItemImpl({
    required this.productId,
    required this.code,
    required this.name,
    this.brand,
    this.model,
    required this.unitOfMeasurement,
    required this.taxRate,
    required this.deactivated,
  });

  @override
  final int productId;
  @override
  final String code;
  @override
  final String name;
  @override
  final String? brand;
  @override
  final String? model;
  @override
  final String unitOfMeasurement;
  @override
  final String taxRate;
  @override
  final bool deactivated;

  @override
  String toString() {
    return 'ProductListItem(productId: $productId, code: $code, name: $name, brand: $brand, model: $model, unitOfMeasurement: $unitOfMeasurement, taxRate: $taxRate, deactivated: $deactivated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductListItemImpl &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.brand, brand) || other.brand == brand) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.unitOfMeasurement, unitOfMeasurement) ||
                other.unitOfMeasurement == unitOfMeasurement) &&
            (identical(other.taxRate, taxRate) || other.taxRate == taxRate) &&
            (identical(other.deactivated, deactivated) ||
                other.deactivated == deactivated));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    productId,
    code,
    name,
    brand,
    model,
    unitOfMeasurement,
    taxRate,
    deactivated,
  );

  /// Create a copy of ProductListItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductListItemImplCopyWith<_$ProductListItemImpl> get copyWith =>
      __$$ProductListItemImplCopyWithImpl<_$ProductListItemImpl>(
        this,
        _$identity,
      );
}

abstract class _ProductListItem implements ProductListItem {
  const factory _ProductListItem({
    required final int productId,
    required final String code,
    required final String name,
    final String? brand,
    final String? model,
    required final String unitOfMeasurement,
    required final String taxRate,
    required final bool deactivated,
  }) = _$ProductListItemImpl;

  @override
  int get productId;
  @override
  String get code;
  @override
  String get name;
  @override
  String? get brand;
  @override
  String? get model;
  @override
  String get unitOfMeasurement;
  @override
  String get taxRate;
  @override
  bool get deactivated;

  /// Create a copy of ProductListItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductListItemImplCopyWith<_$ProductListItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
