// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'destination_line.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$DestinationLine {
  int get id => throw _privateConstructorUsedError;
  int? get salesOrderDetail => throw _privateConstructorUsedError;
  int get product => throw _privateConstructorUsedError;
  String get productCode => throw _privateConstructorUsedError;
  String get productName => throw _privateConstructorUsedError;
  String get quantity => throw _privateConstructorUsedError;
  int? get warehouse => throw _privateConstructorUsedError;

  /// Create a copy of DestinationLine
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DestinationLineCopyWith<DestinationLine> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DestinationLineCopyWith<$Res> {
  factory $DestinationLineCopyWith(
    DestinationLine value,
    $Res Function(DestinationLine) then,
  ) = _$DestinationLineCopyWithImpl<$Res, DestinationLine>;
  @useResult
  $Res call({
    int id,
    int? salesOrderDetail,
    int product,
    String productCode,
    String productName,
    String quantity,
    int? warehouse,
  });
}

/// @nodoc
class _$DestinationLineCopyWithImpl<$Res, $Val extends DestinationLine>
    implements $DestinationLineCopyWith<$Res> {
  _$DestinationLineCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DestinationLine
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? salesOrderDetail = freezed,
    Object? product = null,
    Object? productCode = null,
    Object? productName = null,
    Object? quantity = null,
    Object? warehouse = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            salesOrderDetail: freezed == salesOrderDetail
                ? _value.salesOrderDetail
                : salesOrderDetail // ignore: cast_nullable_to_non_nullable
                      as int?,
            product: null == product
                ? _value.product
                : product // ignore: cast_nullable_to_non_nullable
                      as int,
            productCode: null == productCode
                ? _value.productCode
                : productCode // ignore: cast_nullable_to_non_nullable
                      as String,
            productName: null == productName
                ? _value.productName
                : productName // ignore: cast_nullable_to_non_nullable
                      as String,
            quantity: null == quantity
                ? _value.quantity
                : quantity // ignore: cast_nullable_to_non_nullable
                      as String,
            warehouse: freezed == warehouse
                ? _value.warehouse
                : warehouse // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DestinationLineImplCopyWith<$Res>
    implements $DestinationLineCopyWith<$Res> {
  factory _$$DestinationLineImplCopyWith(
    _$DestinationLineImpl value,
    $Res Function(_$DestinationLineImpl) then,
  ) = __$$DestinationLineImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    int? salesOrderDetail,
    int product,
    String productCode,
    String productName,
    String quantity,
    int? warehouse,
  });
}

/// @nodoc
class __$$DestinationLineImplCopyWithImpl<$Res>
    extends _$DestinationLineCopyWithImpl<$Res, _$DestinationLineImpl>
    implements _$$DestinationLineImplCopyWith<$Res> {
  __$$DestinationLineImplCopyWithImpl(
    _$DestinationLineImpl _value,
    $Res Function(_$DestinationLineImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DestinationLine
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? salesOrderDetail = freezed,
    Object? product = null,
    Object? productCode = null,
    Object? productName = null,
    Object? quantity = null,
    Object? warehouse = freezed,
  }) {
    return _then(
      _$DestinationLineImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        salesOrderDetail: freezed == salesOrderDetail
            ? _value.salesOrderDetail
            : salesOrderDetail // ignore: cast_nullable_to_non_nullable
                  as int?,
        product: null == product
            ? _value.product
            : product // ignore: cast_nullable_to_non_nullable
                  as int,
        productCode: null == productCode
            ? _value.productCode
            : productCode // ignore: cast_nullable_to_non_nullable
                  as String,
        productName: null == productName
            ? _value.productName
            : productName // ignore: cast_nullable_to_non_nullable
                  as String,
        quantity: null == quantity
            ? _value.quantity
            : quantity // ignore: cast_nullable_to_non_nullable
                  as String,
        warehouse: freezed == warehouse
            ? _value.warehouse
            : warehouse // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc

class _$DestinationLineImpl implements _DestinationLine {
  const _$DestinationLineImpl({
    required this.id,
    this.salesOrderDetail,
    required this.product,
    required this.productCode,
    required this.productName,
    required this.quantity,
    this.warehouse,
  });

  @override
  final int id;
  @override
  final int? salesOrderDetail;
  @override
  final int product;
  @override
  final String productCode;
  @override
  final String productName;
  @override
  final String quantity;
  @override
  final int? warehouse;

  @override
  String toString() {
    return 'DestinationLine(id: $id, salesOrderDetail: $salesOrderDetail, product: $product, productCode: $productCode, productName: $productName, quantity: $quantity, warehouse: $warehouse)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DestinationLineImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.salesOrderDetail, salesOrderDetail) ||
                other.salesOrderDetail == salesOrderDetail) &&
            (identical(other.product, product) || other.product == product) &&
            (identical(other.productCode, productCode) ||
                other.productCode == productCode) &&
            (identical(other.productName, productName) ||
                other.productName == productName) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.warehouse, warehouse) ||
                other.warehouse == warehouse));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    salesOrderDetail,
    product,
    productCode,
    productName,
    quantity,
    warehouse,
  );

  /// Create a copy of DestinationLine
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DestinationLineImplCopyWith<_$DestinationLineImpl> get copyWith =>
      __$$DestinationLineImplCopyWithImpl<_$DestinationLineImpl>(
        this,
        _$identity,
      );
}

abstract class _DestinationLine implements DestinationLine {
  const factory _DestinationLine({
    required final int id,
    final int? salesOrderDetail,
    required final int product,
    required final String productCode,
    required final String productName,
    required final String quantity,
    final int? warehouse,
  }) = _$DestinationLineImpl;

  @override
  int get id;
  @override
  int? get salesOrderDetail;
  @override
  int get product;
  @override
  String get productCode;
  @override
  String get productName;
  @override
  String get quantity;
  @override
  int? get warehouse;

  /// Create a copy of DestinationLine
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DestinationLineImplCopyWith<_$DestinationLineImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
