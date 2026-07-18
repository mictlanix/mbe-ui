// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pricing_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$PricingState {
  int? get productId => throw _privateConstructorUsedError;
  String? get productDisplayText => throw _privateConstructorUsedError;
  List<ProductPriceRow> get rows => throw _privateConstructorUsedError;
  bool get loading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of PricingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PricingStateCopyWith<PricingState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PricingStateCopyWith<$Res> {
  factory $PricingStateCopyWith(
    PricingState value,
    $Res Function(PricingState) then,
  ) = _$PricingStateCopyWithImpl<$Res, PricingState>;
  @useResult
  $Res call({
    int? productId,
    String? productDisplayText,
    List<ProductPriceRow> rows,
    bool loading,
    String? error,
  });
}

/// @nodoc
class _$PricingStateCopyWithImpl<$Res, $Val extends PricingState>
    implements $PricingStateCopyWith<$Res> {
  _$PricingStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PricingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = freezed,
    Object? productDisplayText = freezed,
    Object? rows = null,
    Object? loading = null,
    Object? error = freezed,
  }) {
    return _then(
      _value.copyWith(
            productId: freezed == productId
                ? _value.productId
                : productId // ignore: cast_nullable_to_non_nullable
                      as int?,
            productDisplayText: freezed == productDisplayText
                ? _value.productDisplayText
                : productDisplayText // ignore: cast_nullable_to_non_nullable
                      as String?,
            rows: null == rows
                ? _value.rows
                : rows // ignore: cast_nullable_to_non_nullable
                      as List<ProductPriceRow>,
            loading: null == loading
                ? _value.loading
                : loading // ignore: cast_nullable_to_non_nullable
                      as bool,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PricingStateImplCopyWith<$Res>
    implements $PricingStateCopyWith<$Res> {
  factory _$$PricingStateImplCopyWith(
    _$PricingStateImpl value,
    $Res Function(_$PricingStateImpl) then,
  ) = __$$PricingStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? productId,
    String? productDisplayText,
    List<ProductPriceRow> rows,
    bool loading,
    String? error,
  });
}

/// @nodoc
class __$$PricingStateImplCopyWithImpl<$Res>
    extends _$PricingStateCopyWithImpl<$Res, _$PricingStateImpl>
    implements _$$PricingStateImplCopyWith<$Res> {
  __$$PricingStateImplCopyWithImpl(
    _$PricingStateImpl _value,
    $Res Function(_$PricingStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PricingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = freezed,
    Object? productDisplayText = freezed,
    Object? rows = null,
    Object? loading = null,
    Object? error = freezed,
  }) {
    return _then(
      _$PricingStateImpl(
        productId: freezed == productId
            ? _value.productId
            : productId // ignore: cast_nullable_to_non_nullable
                  as int?,
        productDisplayText: freezed == productDisplayText
            ? _value.productDisplayText
            : productDisplayText // ignore: cast_nullable_to_non_nullable
                  as String?,
        rows: null == rows
            ? _value._rows
            : rows // ignore: cast_nullable_to_non_nullable
                  as List<ProductPriceRow>,
        loading: null == loading
            ? _value.loading
            : loading // ignore: cast_nullable_to_non_nullable
                  as bool,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$PricingStateImpl implements _PricingState {
  const _$PricingStateImpl({
    this.productId,
    this.productDisplayText,
    final List<ProductPriceRow> rows = const <ProductPriceRow>[],
    this.loading = false,
    this.error,
  }) : _rows = rows;

  @override
  final int? productId;
  @override
  final String? productDisplayText;
  final List<ProductPriceRow> _rows;
  @override
  @JsonKey()
  List<ProductPriceRow> get rows {
    if (_rows is EqualUnmodifiableListView) return _rows;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_rows);
  }

  @override
  @JsonKey()
  final bool loading;
  @override
  final String? error;

  @override
  String toString() {
    return 'PricingState(productId: $productId, productDisplayText: $productDisplayText, rows: $rows, loading: $loading, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PricingStateImpl &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.productDisplayText, productDisplayText) ||
                other.productDisplayText == productDisplayText) &&
            const DeepCollectionEquality().equals(other._rows, _rows) &&
            (identical(other.loading, loading) || other.loading == loading) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    productId,
    productDisplayText,
    const DeepCollectionEquality().hash(_rows),
    loading,
    error,
  );

  /// Create a copy of PricingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PricingStateImplCopyWith<_$PricingStateImpl> get copyWith =>
      __$$PricingStateImplCopyWithImpl<_$PricingStateImpl>(this, _$identity);
}

abstract class _PricingState implements PricingState {
  const factory _PricingState({
    final int? productId,
    final String? productDisplayText,
    final List<ProductPriceRow> rows,
    final bool loading,
    final String? error,
  }) = _$PricingStateImpl;

  @override
  int? get productId;
  @override
  String? get productDisplayText;
  @override
  List<ProductPriceRow> get rows;
  @override
  bool get loading;
  @override
  String? get error;

  /// Create a copy of PricingState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PricingStateImplCopyWith<_$PricingStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$PricingRowEditState {
  String get price => throw _privateConstructorUsedError;
  String get lowProfit => throw _privateConstructorUsedError;
  String get highProfit => throw _privateConstructorUsedError;
  bool get submitting => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  Map<String, String>? get fieldErrors => throw _privateConstructorUsedError;

  /// Create a copy of PricingRowEditState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PricingRowEditStateCopyWith<PricingRowEditState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PricingRowEditStateCopyWith<$Res> {
  factory $PricingRowEditStateCopyWith(
    PricingRowEditState value,
    $Res Function(PricingRowEditState) then,
  ) = _$PricingRowEditStateCopyWithImpl<$Res, PricingRowEditState>;
  @useResult
  $Res call({
    String price,
    String lowProfit,
    String highProfit,
    bool submitting,
    String? error,
    Map<String, String>? fieldErrors,
  });
}

/// @nodoc
class _$PricingRowEditStateCopyWithImpl<$Res, $Val extends PricingRowEditState>
    implements $PricingRowEditStateCopyWith<$Res> {
  _$PricingRowEditStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PricingRowEditState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? price = null,
    Object? lowProfit = null,
    Object? highProfit = null,
    Object? submitting = null,
    Object? error = freezed,
    Object? fieldErrors = freezed,
  }) {
    return _then(
      _value.copyWith(
            price: null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as String,
            lowProfit: null == lowProfit
                ? _value.lowProfit
                : lowProfit // ignore: cast_nullable_to_non_nullable
                      as String,
            highProfit: null == highProfit
                ? _value.highProfit
                : highProfit // ignore: cast_nullable_to_non_nullable
                      as String,
            submitting: null == submitting
                ? _value.submitting
                : submitting // ignore: cast_nullable_to_non_nullable
                      as bool,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
            fieldErrors: freezed == fieldErrors
                ? _value.fieldErrors
                : fieldErrors // ignore: cast_nullable_to_non_nullable
                      as Map<String, String>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PricingRowEditStateImplCopyWith<$Res>
    implements $PricingRowEditStateCopyWith<$Res> {
  factory _$$PricingRowEditStateImplCopyWith(
    _$PricingRowEditStateImpl value,
    $Res Function(_$PricingRowEditStateImpl) then,
  ) = __$$PricingRowEditStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String price,
    String lowProfit,
    String highProfit,
    bool submitting,
    String? error,
    Map<String, String>? fieldErrors,
  });
}

/// @nodoc
class __$$PricingRowEditStateImplCopyWithImpl<$Res>
    extends _$PricingRowEditStateCopyWithImpl<$Res, _$PricingRowEditStateImpl>
    implements _$$PricingRowEditStateImplCopyWith<$Res> {
  __$$PricingRowEditStateImplCopyWithImpl(
    _$PricingRowEditStateImpl _value,
    $Res Function(_$PricingRowEditStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PricingRowEditState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? price = null,
    Object? lowProfit = null,
    Object? highProfit = null,
    Object? submitting = null,
    Object? error = freezed,
    Object? fieldErrors = freezed,
  }) {
    return _then(
      _$PricingRowEditStateImpl(
        price: null == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as String,
        lowProfit: null == lowProfit
            ? _value.lowProfit
            : lowProfit // ignore: cast_nullable_to_non_nullable
                  as String,
        highProfit: null == highProfit
            ? _value.highProfit
            : highProfit // ignore: cast_nullable_to_non_nullable
                  as String,
        submitting: null == submitting
            ? _value.submitting
            : submitting // ignore: cast_nullable_to_non_nullable
                  as bool,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
        fieldErrors: freezed == fieldErrors
            ? _value._fieldErrors
            : fieldErrors // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>?,
      ),
    );
  }
}

/// @nodoc

class _$PricingRowEditStateImpl implements _PricingRowEditState {
  const _$PricingRowEditStateImpl({
    this.price = '',
    this.lowProfit = '',
    this.highProfit = '',
    this.submitting = false,
    this.error,
    final Map<String, String>? fieldErrors,
  }) : _fieldErrors = fieldErrors;

  @override
  @JsonKey()
  final String price;
  @override
  @JsonKey()
  final String lowProfit;
  @override
  @JsonKey()
  final String highProfit;
  @override
  @JsonKey()
  final bool submitting;
  @override
  final String? error;
  final Map<String, String>? _fieldErrors;
  @override
  Map<String, String>? get fieldErrors {
    final value = _fieldErrors;
    if (value == null) return null;
    if (_fieldErrors is EqualUnmodifiableMapView) return _fieldErrors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'PricingRowEditState(price: $price, lowProfit: $lowProfit, highProfit: $highProfit, submitting: $submitting, error: $error, fieldErrors: $fieldErrors)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PricingRowEditStateImpl &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.lowProfit, lowProfit) ||
                other.lowProfit == lowProfit) &&
            (identical(other.highProfit, highProfit) ||
                other.highProfit == highProfit) &&
            (identical(other.submitting, submitting) ||
                other.submitting == submitting) &&
            (identical(other.error, error) || other.error == error) &&
            const DeepCollectionEquality().equals(
              other._fieldErrors,
              _fieldErrors,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    price,
    lowProfit,
    highProfit,
    submitting,
    error,
    const DeepCollectionEquality().hash(_fieldErrors),
  );

  /// Create a copy of PricingRowEditState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PricingRowEditStateImplCopyWith<_$PricingRowEditStateImpl> get copyWith =>
      __$$PricingRowEditStateImplCopyWithImpl<_$PricingRowEditStateImpl>(
        this,
        _$identity,
      );
}

abstract class _PricingRowEditState implements PricingRowEditState {
  const factory _PricingRowEditState({
    final String price,
    final String lowProfit,
    final String highProfit,
    final bool submitting,
    final String? error,
    final Map<String, String>? fieldErrors,
  }) = _$PricingRowEditStateImpl;

  @override
  String get price;
  @override
  String get lowProfit;
  @override
  String get highProfit;
  @override
  bool get submitting;
  @override
  String? get error;
  @override
  Map<String, String>? get fieldErrors;

  /// Create a copy of PricingRowEditState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PricingRowEditStateImplCopyWith<_$PricingRowEditStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
