// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sale_line.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$SaleLine {
  int get id => throw _privateConstructorUsedError;
  int get product => throw _privateConstructorUsedError;
  String get productCode => throw _privateConstructorUsedError;
  String get productName =>
      throw _privateConstructorUsedError; // The SAT unit's symbol when it has one ("Pza"), else its name
  // ("Pieza") — mbe-api#145. Null for a product with no unit on file.
  String? get unit =>
      throw _privateConstructorUsedError; // The product's photo as a fetchable URL — mbe-api#157, which put it on
  // both shapes a till reads so a resumed sale's own lines are not the blank
  // ones. Already resolved through `resolvePhotoUrl`, so a call site hands it
  // straight to `ProductPhoto`. Null for a product with no photo.
  String? get photo => throw _privateConstructorUsedError;
  String get quantity => throw _privateConstructorUsedError;
  String get cost => throw _privateConstructorUsedError;
  String get price => throw _privateConstructorUsedError;
  String get discountRate => throw _privateConstructorUsedError;
  String get taxRate => throw _privateConstructorUsedError;
  bool get taxIncluded => throw _privateConstructorUsedError;
  int? get warehouse => throw _privateConstructorUsedError;
  String? get comment => throw _privateConstructorUsedError;
  String get subtotal => throw _privateConstructorUsedError;
  String get taxTotal => throw _privateConstructorUsedError;
  String get total =>
      throw _privateConstructorUsedError; // Joined from the most recent product-lookup response for the line's
  // chosen warehouse, not stored on the line itself (data-model.md §2) —
  // advisory only; the authoritative check happens at confirmation
  // (FR-025, FR-026).
  String? get availability => throw _privateConstructorUsedError;

  /// Create a copy of SaleLine
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SaleLineCopyWith<SaleLine> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SaleLineCopyWith<$Res> {
  factory $SaleLineCopyWith(SaleLine value, $Res Function(SaleLine) then) =
      _$SaleLineCopyWithImpl<$Res, SaleLine>;
  @useResult
  $Res call({
    int id,
    int product,
    String productCode,
    String productName,
    String? unit,
    String? photo,
    String quantity,
    String cost,
    String price,
    String discountRate,
    String taxRate,
    bool taxIncluded,
    int? warehouse,
    String? comment,
    String subtotal,
    String taxTotal,
    String total,
    String? availability,
  });
}

/// @nodoc
class _$SaleLineCopyWithImpl<$Res, $Val extends SaleLine>
    implements $SaleLineCopyWith<$Res> {
  _$SaleLineCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SaleLine
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? product = null,
    Object? productCode = null,
    Object? productName = null,
    Object? unit = freezed,
    Object? photo = freezed,
    Object? quantity = null,
    Object? cost = null,
    Object? price = null,
    Object? discountRate = null,
    Object? taxRate = null,
    Object? taxIncluded = null,
    Object? warehouse = freezed,
    Object? comment = freezed,
    Object? subtotal = null,
    Object? taxTotal = null,
    Object? total = null,
    Object? availability = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
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
            unit: freezed == unit
                ? _value.unit
                : unit // ignore: cast_nullable_to_non_nullable
                      as String?,
            photo: freezed == photo
                ? _value.photo
                : photo // ignore: cast_nullable_to_non_nullable
                      as String?,
            quantity: null == quantity
                ? _value.quantity
                : quantity // ignore: cast_nullable_to_non_nullable
                      as String,
            cost: null == cost
                ? _value.cost
                : cost // ignore: cast_nullable_to_non_nullable
                      as String,
            price: null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as String,
            discountRate: null == discountRate
                ? _value.discountRate
                : discountRate // ignore: cast_nullable_to_non_nullable
                      as String,
            taxRate: null == taxRate
                ? _value.taxRate
                : taxRate // ignore: cast_nullable_to_non_nullable
                      as String,
            taxIncluded: null == taxIncluded
                ? _value.taxIncluded
                : taxIncluded // ignore: cast_nullable_to_non_nullable
                      as bool,
            warehouse: freezed == warehouse
                ? _value.warehouse
                : warehouse // ignore: cast_nullable_to_non_nullable
                      as int?,
            comment: freezed == comment
                ? _value.comment
                : comment // ignore: cast_nullable_to_non_nullable
                      as String?,
            subtotal: null == subtotal
                ? _value.subtotal
                : subtotal // ignore: cast_nullable_to_non_nullable
                      as String,
            taxTotal: null == taxTotal
                ? _value.taxTotal
                : taxTotal // ignore: cast_nullable_to_non_nullable
                      as String,
            total: null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as String,
            availability: freezed == availability
                ? _value.availability
                : availability // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SaleLineImplCopyWith<$Res>
    implements $SaleLineCopyWith<$Res> {
  factory _$$SaleLineImplCopyWith(
    _$SaleLineImpl value,
    $Res Function(_$SaleLineImpl) then,
  ) = __$$SaleLineImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    int product,
    String productCode,
    String productName,
    String? unit,
    String? photo,
    String quantity,
    String cost,
    String price,
    String discountRate,
    String taxRate,
    bool taxIncluded,
    int? warehouse,
    String? comment,
    String subtotal,
    String taxTotal,
    String total,
    String? availability,
  });
}

/// @nodoc
class __$$SaleLineImplCopyWithImpl<$Res>
    extends _$SaleLineCopyWithImpl<$Res, _$SaleLineImpl>
    implements _$$SaleLineImplCopyWith<$Res> {
  __$$SaleLineImplCopyWithImpl(
    _$SaleLineImpl _value,
    $Res Function(_$SaleLineImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SaleLine
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? product = null,
    Object? productCode = null,
    Object? productName = null,
    Object? unit = freezed,
    Object? photo = freezed,
    Object? quantity = null,
    Object? cost = null,
    Object? price = null,
    Object? discountRate = null,
    Object? taxRate = null,
    Object? taxIncluded = null,
    Object? warehouse = freezed,
    Object? comment = freezed,
    Object? subtotal = null,
    Object? taxTotal = null,
    Object? total = null,
    Object? availability = freezed,
  }) {
    return _then(
      _$SaleLineImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
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
        unit: freezed == unit
            ? _value.unit
            : unit // ignore: cast_nullable_to_non_nullable
                  as String?,
        photo: freezed == photo
            ? _value.photo
            : photo // ignore: cast_nullable_to_non_nullable
                  as String?,
        quantity: null == quantity
            ? _value.quantity
            : quantity // ignore: cast_nullable_to_non_nullable
                  as String,
        cost: null == cost
            ? _value.cost
            : cost // ignore: cast_nullable_to_non_nullable
                  as String,
        price: null == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as String,
        discountRate: null == discountRate
            ? _value.discountRate
            : discountRate // ignore: cast_nullable_to_non_nullable
                  as String,
        taxRate: null == taxRate
            ? _value.taxRate
            : taxRate // ignore: cast_nullable_to_non_nullable
                  as String,
        taxIncluded: null == taxIncluded
            ? _value.taxIncluded
            : taxIncluded // ignore: cast_nullable_to_non_nullable
                  as bool,
        warehouse: freezed == warehouse
            ? _value.warehouse
            : warehouse // ignore: cast_nullable_to_non_nullable
                  as int?,
        comment: freezed == comment
            ? _value.comment
            : comment // ignore: cast_nullable_to_non_nullable
                  as String?,
        subtotal: null == subtotal
            ? _value.subtotal
            : subtotal // ignore: cast_nullable_to_non_nullable
                  as String,
        taxTotal: null == taxTotal
            ? _value.taxTotal
            : taxTotal // ignore: cast_nullable_to_non_nullable
                  as String,
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as String,
        availability: freezed == availability
            ? _value.availability
            : availability // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$SaleLineImpl implements _SaleLine {
  const _$SaleLineImpl({
    required this.id,
    required this.product,
    required this.productCode,
    required this.productName,
    this.unit,
    this.photo,
    required this.quantity,
    required this.cost,
    required this.price,
    required this.discountRate,
    required this.taxRate,
    required this.taxIncluded,
    this.warehouse,
    this.comment,
    required this.subtotal,
    required this.taxTotal,
    required this.total,
    this.availability,
  });

  @override
  final int id;
  @override
  final int product;
  @override
  final String productCode;
  @override
  final String productName;
  // The SAT unit's symbol when it has one ("Pza"), else its name
  // ("Pieza") — mbe-api#145. Null for a product with no unit on file.
  @override
  final String? unit;
  // The product's photo as a fetchable URL — mbe-api#157, which put it on
  // both shapes a till reads so a resumed sale's own lines are not the blank
  // ones. Already resolved through `resolvePhotoUrl`, so a call site hands it
  // straight to `ProductPhoto`. Null for a product with no photo.
  @override
  final String? photo;
  @override
  final String quantity;
  @override
  final String cost;
  @override
  final String price;
  @override
  final String discountRate;
  @override
  final String taxRate;
  @override
  final bool taxIncluded;
  @override
  final int? warehouse;
  @override
  final String? comment;
  @override
  final String subtotal;
  @override
  final String taxTotal;
  @override
  final String total;
  // Joined from the most recent product-lookup response for the line's
  // chosen warehouse, not stored on the line itself (data-model.md §2) —
  // advisory only; the authoritative check happens at confirmation
  // (FR-025, FR-026).
  @override
  final String? availability;

  @override
  String toString() {
    return 'SaleLine(id: $id, product: $product, productCode: $productCode, productName: $productName, unit: $unit, photo: $photo, quantity: $quantity, cost: $cost, price: $price, discountRate: $discountRate, taxRate: $taxRate, taxIncluded: $taxIncluded, warehouse: $warehouse, comment: $comment, subtotal: $subtotal, taxTotal: $taxTotal, total: $total, availability: $availability)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SaleLineImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.product, product) || other.product == product) &&
            (identical(other.productCode, productCode) ||
                other.productCode == productCode) &&
            (identical(other.productName, productName) ||
                other.productName == productName) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.photo, photo) || other.photo == photo) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.cost, cost) || other.cost == cost) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.discountRate, discountRate) ||
                other.discountRate == discountRate) &&
            (identical(other.taxRate, taxRate) || other.taxRate == taxRate) &&
            (identical(other.taxIncluded, taxIncluded) ||
                other.taxIncluded == taxIncluded) &&
            (identical(other.warehouse, warehouse) ||
                other.warehouse == warehouse) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            (identical(other.subtotal, subtotal) ||
                other.subtotal == subtotal) &&
            (identical(other.taxTotal, taxTotal) ||
                other.taxTotal == taxTotal) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.availability, availability) ||
                other.availability == availability));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    product,
    productCode,
    productName,
    unit,
    photo,
    quantity,
    cost,
    price,
    discountRate,
    taxRate,
    taxIncluded,
    warehouse,
    comment,
    subtotal,
    taxTotal,
    total,
    availability,
  );

  /// Create a copy of SaleLine
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SaleLineImplCopyWith<_$SaleLineImpl> get copyWith =>
      __$$SaleLineImplCopyWithImpl<_$SaleLineImpl>(this, _$identity);
}

abstract class _SaleLine implements SaleLine {
  const factory _SaleLine({
    required final int id,
    required final int product,
    required final String productCode,
    required final String productName,
    final String? unit,
    final String? photo,
    required final String quantity,
    required final String cost,
    required final String price,
    required final String discountRate,
    required final String taxRate,
    required final bool taxIncluded,
    final int? warehouse,
    final String? comment,
    required final String subtotal,
    required final String taxTotal,
    required final String total,
    final String? availability,
  }) = _$SaleLineImpl;

  @override
  int get id;
  @override
  int get product;
  @override
  String get productCode;
  @override
  String get productName; // The SAT unit's symbol when it has one ("Pza"), else its name
  // ("Pieza") — mbe-api#145. Null for a product with no unit on file.
  @override
  String? get unit; // The product's photo as a fetchable URL — mbe-api#157, which put it on
  // both shapes a till reads so a resumed sale's own lines are not the blank
  // ones. Already resolved through `resolvePhotoUrl`, so a call site hands it
  // straight to `ProductPhoto`. Null for a product with no photo.
  @override
  String? get photo;
  @override
  String get quantity;
  @override
  String get cost;
  @override
  String get price;
  @override
  String get discountRate;
  @override
  String get taxRate;
  @override
  bool get taxIncluded;
  @override
  int? get warehouse;
  @override
  String? get comment;
  @override
  String get subtotal;
  @override
  String get taxTotal;
  @override
  String get total; // Joined from the most recent product-lookup response for the line's
  // chosen warehouse, not stored on the line itself (data-model.md §2) —
  // advisory only; the authoritative check happens at confirmation
  // (FR-025, FR-026).
  @override
  String? get availability;

  /// Create a copy of SaleLine
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SaleLineImplCopyWith<_$SaleLineImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
