// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_form_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ProductFormState {
  int? get productId => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get brand => throw _privateConstructorUsedError;
  String? get model => throw _privateConstructorUsedError;
  String? get barCode => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;

  /// The product's currently-saved photo URL (FR-001), loaded via
  /// [loadForEdit]. `null` in create mode until a photo is staged
  /// (data-model.md "ProductFormState").
  String? get photo => throw _privateConstructorUsedError;

  /// In-memory bytes of a newly-picked image file, staged but not yet
  /// uploaded (FR-010 — applies only on save). `null` if nothing has been
  /// picked since the form was opened/loaded (data-model.md
  /// "ProductFormState").
  Uint8List? get pendingPhotoBytes => throw _privateConstructorUsedError;

  /// Original filename of [pendingPhotoBytes], used only for the
  /// upload's multipart filename.
  String? get pendingPhotoFilename => throw _privateConstructorUsedError;

  /// `true` if the user chose "remove photo" since the form was
  /// opened/loaded, and no new photo has been picked since. Mutually
  /// exclusive with a non-null [pendingPhotoBytes].
  bool get photoMarkedForRemoval => throw _privateConstructorUsedError;
  String get unitOfMeasurementCode => throw _privateConstructorUsedError;
  String get unitOfMeasurementDisplayText => throw _privateConstructorUsedError;
  String? get satKeyCode => throw _privateConstructorUsedError;
  String? get satKeyDisplayText => throw _privateConstructorUsedError;
  int? get supplierId => throw _privateConstructorUsedError;
  String? get supplierName => throw _privateConstructorUsedError;
  List<int> get labelIds => throw _privateConstructorUsedError;
  List<ProductPrice> get prices => throw _privateConstructorUsedError;
  String? get taxRate => throw _privateConstructorUsedError;
  String? get comment => throw _privateConstructorUsedError;
  bool get stockable => throw _privateConstructorUsedError;
  bool get perishable => throw _privateConstructorUsedError;
  bool get seriable => throw _privateConstructorUsedError;
  bool get purchasable => throw _privateConstructorUsedError;
  bool get salable => throw _privateConstructorUsedError;
  bool get invoiceable => throw _privateConstructorUsedError;
  bool get deactivated => throw _privateConstructorUsedError;
  bool get loading => throw _privateConstructorUsedError;
  bool get submitting => throw _privateConstructorUsedError;
  bool get saved => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// The server-provided detail behind [error] (e.g. mbe-api's `detail`
  /// string on a `404`/`5xx`), shown alongside the localized [error]
  /// message since it can't be localized client-side. `null` for
  /// client-side-only errors (validation, permission checks).
  String? get errorDetail => throw _privateConstructorUsedError;
  Map<String, String> get fieldErrors => throw _privateConstructorUsedError;

  /// Create a copy of ProductFormState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductFormStateCopyWith<ProductFormState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductFormStateCopyWith<$Res> {
  factory $ProductFormStateCopyWith(
    ProductFormState value,
    $Res Function(ProductFormState) then,
  ) = _$ProductFormStateCopyWithImpl<$Res, ProductFormState>;
  @useResult
  $Res call({
    int? productId,
    String code,
    String name,
    String? brand,
    String? model,
    String? barCode,
    String? location,
    String? photo,
    Uint8List? pendingPhotoBytes,
    String? pendingPhotoFilename,
    bool photoMarkedForRemoval,
    String unitOfMeasurementCode,
    String unitOfMeasurementDisplayText,
    String? satKeyCode,
    String? satKeyDisplayText,
    int? supplierId,
    String? supplierName,
    List<int> labelIds,
    List<ProductPrice> prices,
    String? taxRate,
    String? comment,
    bool stockable,
    bool perishable,
    bool seriable,
    bool purchasable,
    bool salable,
    bool invoiceable,
    bool deactivated,
    bool loading,
    bool submitting,
    bool saved,
    String? error,
    String? errorDetail,
    Map<String, String> fieldErrors,
  });
}

/// @nodoc
class _$ProductFormStateCopyWithImpl<$Res, $Val extends ProductFormState>
    implements $ProductFormStateCopyWith<$Res> {
  _$ProductFormStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductFormState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = freezed,
    Object? code = null,
    Object? name = null,
    Object? brand = freezed,
    Object? model = freezed,
    Object? barCode = freezed,
    Object? location = freezed,
    Object? photo = freezed,
    Object? pendingPhotoBytes = freezed,
    Object? pendingPhotoFilename = freezed,
    Object? photoMarkedForRemoval = null,
    Object? unitOfMeasurementCode = null,
    Object? unitOfMeasurementDisplayText = null,
    Object? satKeyCode = freezed,
    Object? satKeyDisplayText = freezed,
    Object? supplierId = freezed,
    Object? supplierName = freezed,
    Object? labelIds = null,
    Object? prices = null,
    Object? taxRate = freezed,
    Object? comment = freezed,
    Object? stockable = null,
    Object? perishable = null,
    Object? seriable = null,
    Object? purchasable = null,
    Object? salable = null,
    Object? invoiceable = null,
    Object? deactivated = null,
    Object? loading = null,
    Object? submitting = null,
    Object? saved = null,
    Object? error = freezed,
    Object? errorDetail = freezed,
    Object? fieldErrors = null,
  }) {
    return _then(
      _value.copyWith(
            productId: freezed == productId
                ? _value.productId
                : productId // ignore: cast_nullable_to_non_nullable
                      as int?,
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
            barCode: freezed == barCode
                ? _value.barCode
                : barCode // ignore: cast_nullable_to_non_nullable
                      as String?,
            location: freezed == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as String?,
            photo: freezed == photo
                ? _value.photo
                : photo // ignore: cast_nullable_to_non_nullable
                      as String?,
            pendingPhotoBytes: freezed == pendingPhotoBytes
                ? _value.pendingPhotoBytes
                : pendingPhotoBytes // ignore: cast_nullable_to_non_nullable
                      as Uint8List?,
            pendingPhotoFilename: freezed == pendingPhotoFilename
                ? _value.pendingPhotoFilename
                : pendingPhotoFilename // ignore: cast_nullable_to_non_nullable
                      as String?,
            photoMarkedForRemoval: null == photoMarkedForRemoval
                ? _value.photoMarkedForRemoval
                : photoMarkedForRemoval // ignore: cast_nullable_to_non_nullable
                      as bool,
            unitOfMeasurementCode: null == unitOfMeasurementCode
                ? _value.unitOfMeasurementCode
                : unitOfMeasurementCode // ignore: cast_nullable_to_non_nullable
                      as String,
            unitOfMeasurementDisplayText: null == unitOfMeasurementDisplayText
                ? _value.unitOfMeasurementDisplayText
                : unitOfMeasurementDisplayText // ignore: cast_nullable_to_non_nullable
                      as String,
            satKeyCode: freezed == satKeyCode
                ? _value.satKeyCode
                : satKeyCode // ignore: cast_nullable_to_non_nullable
                      as String?,
            satKeyDisplayText: freezed == satKeyDisplayText
                ? _value.satKeyDisplayText
                : satKeyDisplayText // ignore: cast_nullable_to_non_nullable
                      as String?,
            supplierId: freezed == supplierId
                ? _value.supplierId
                : supplierId // ignore: cast_nullable_to_non_nullable
                      as int?,
            supplierName: freezed == supplierName
                ? _value.supplierName
                : supplierName // ignore: cast_nullable_to_non_nullable
                      as String?,
            labelIds: null == labelIds
                ? _value.labelIds
                : labelIds // ignore: cast_nullable_to_non_nullable
                      as List<int>,
            prices: null == prices
                ? _value.prices
                : prices // ignore: cast_nullable_to_non_nullable
                      as List<ProductPrice>,
            taxRate: freezed == taxRate
                ? _value.taxRate
                : taxRate // ignore: cast_nullable_to_non_nullable
                      as String?,
            comment: freezed == comment
                ? _value.comment
                : comment // ignore: cast_nullable_to_non_nullable
                      as String?,
            stockable: null == stockable
                ? _value.stockable
                : stockable // ignore: cast_nullable_to_non_nullable
                      as bool,
            perishable: null == perishable
                ? _value.perishable
                : perishable // ignore: cast_nullable_to_non_nullable
                      as bool,
            seriable: null == seriable
                ? _value.seriable
                : seriable // ignore: cast_nullable_to_non_nullable
                      as bool,
            purchasable: null == purchasable
                ? _value.purchasable
                : purchasable // ignore: cast_nullable_to_non_nullable
                      as bool,
            salable: null == salable
                ? _value.salable
                : salable // ignore: cast_nullable_to_non_nullable
                      as bool,
            invoiceable: null == invoiceable
                ? _value.invoiceable
                : invoiceable // ignore: cast_nullable_to_non_nullable
                      as bool,
            deactivated: null == deactivated
                ? _value.deactivated
                : deactivated // ignore: cast_nullable_to_non_nullable
                      as bool,
            loading: null == loading
                ? _value.loading
                : loading // ignore: cast_nullable_to_non_nullable
                      as bool,
            submitting: null == submitting
                ? _value.submitting
                : submitting // ignore: cast_nullable_to_non_nullable
                      as bool,
            saved: null == saved
                ? _value.saved
                : saved // ignore: cast_nullable_to_non_nullable
                      as bool,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
            errorDetail: freezed == errorDetail
                ? _value.errorDetail
                : errorDetail // ignore: cast_nullable_to_non_nullable
                      as String?,
            fieldErrors: null == fieldErrors
                ? _value.fieldErrors
                : fieldErrors // ignore: cast_nullable_to_non_nullable
                      as Map<String, String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProductFormStateImplCopyWith<$Res>
    implements $ProductFormStateCopyWith<$Res> {
  factory _$$ProductFormStateImplCopyWith(
    _$ProductFormStateImpl value,
    $Res Function(_$ProductFormStateImpl) then,
  ) = __$$ProductFormStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? productId,
    String code,
    String name,
    String? brand,
    String? model,
    String? barCode,
    String? location,
    String? photo,
    Uint8List? pendingPhotoBytes,
    String? pendingPhotoFilename,
    bool photoMarkedForRemoval,
    String unitOfMeasurementCode,
    String unitOfMeasurementDisplayText,
    String? satKeyCode,
    String? satKeyDisplayText,
    int? supplierId,
    String? supplierName,
    List<int> labelIds,
    List<ProductPrice> prices,
    String? taxRate,
    String? comment,
    bool stockable,
    bool perishable,
    bool seriable,
    bool purchasable,
    bool salable,
    bool invoiceable,
    bool deactivated,
    bool loading,
    bool submitting,
    bool saved,
    String? error,
    String? errorDetail,
    Map<String, String> fieldErrors,
  });
}

/// @nodoc
class __$$ProductFormStateImplCopyWithImpl<$Res>
    extends _$ProductFormStateCopyWithImpl<$Res, _$ProductFormStateImpl>
    implements _$$ProductFormStateImplCopyWith<$Res> {
  __$$ProductFormStateImplCopyWithImpl(
    _$ProductFormStateImpl _value,
    $Res Function(_$ProductFormStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductFormState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = freezed,
    Object? code = null,
    Object? name = null,
    Object? brand = freezed,
    Object? model = freezed,
    Object? barCode = freezed,
    Object? location = freezed,
    Object? photo = freezed,
    Object? pendingPhotoBytes = freezed,
    Object? pendingPhotoFilename = freezed,
    Object? photoMarkedForRemoval = null,
    Object? unitOfMeasurementCode = null,
    Object? unitOfMeasurementDisplayText = null,
    Object? satKeyCode = freezed,
    Object? satKeyDisplayText = freezed,
    Object? supplierId = freezed,
    Object? supplierName = freezed,
    Object? labelIds = null,
    Object? prices = null,
    Object? taxRate = freezed,
    Object? comment = freezed,
    Object? stockable = null,
    Object? perishable = null,
    Object? seriable = null,
    Object? purchasable = null,
    Object? salable = null,
    Object? invoiceable = null,
    Object? deactivated = null,
    Object? loading = null,
    Object? submitting = null,
    Object? saved = null,
    Object? error = freezed,
    Object? errorDetail = freezed,
    Object? fieldErrors = null,
  }) {
    return _then(
      _$ProductFormStateImpl(
        productId: freezed == productId
            ? _value.productId
            : productId // ignore: cast_nullable_to_non_nullable
                  as int?,
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
        barCode: freezed == barCode
            ? _value.barCode
            : barCode // ignore: cast_nullable_to_non_nullable
                  as String?,
        location: freezed == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as String?,
        photo: freezed == photo
            ? _value.photo
            : photo // ignore: cast_nullable_to_non_nullable
                  as String?,
        pendingPhotoBytes: freezed == pendingPhotoBytes
            ? _value.pendingPhotoBytes
            : pendingPhotoBytes // ignore: cast_nullable_to_non_nullable
                  as Uint8List?,
        pendingPhotoFilename: freezed == pendingPhotoFilename
            ? _value.pendingPhotoFilename
            : pendingPhotoFilename // ignore: cast_nullable_to_non_nullable
                  as String?,
        photoMarkedForRemoval: null == photoMarkedForRemoval
            ? _value.photoMarkedForRemoval
            : photoMarkedForRemoval // ignore: cast_nullable_to_non_nullable
                  as bool,
        unitOfMeasurementCode: null == unitOfMeasurementCode
            ? _value.unitOfMeasurementCode
            : unitOfMeasurementCode // ignore: cast_nullable_to_non_nullable
                  as String,
        unitOfMeasurementDisplayText: null == unitOfMeasurementDisplayText
            ? _value.unitOfMeasurementDisplayText
            : unitOfMeasurementDisplayText // ignore: cast_nullable_to_non_nullable
                  as String,
        satKeyCode: freezed == satKeyCode
            ? _value.satKeyCode
            : satKeyCode // ignore: cast_nullable_to_non_nullable
                  as String?,
        satKeyDisplayText: freezed == satKeyDisplayText
            ? _value.satKeyDisplayText
            : satKeyDisplayText // ignore: cast_nullable_to_non_nullable
                  as String?,
        supplierId: freezed == supplierId
            ? _value.supplierId
            : supplierId // ignore: cast_nullable_to_non_nullable
                  as int?,
        supplierName: freezed == supplierName
            ? _value.supplierName
            : supplierName // ignore: cast_nullable_to_non_nullable
                  as String?,
        labelIds: null == labelIds
            ? _value._labelIds
            : labelIds // ignore: cast_nullable_to_non_nullable
                  as List<int>,
        prices: null == prices
            ? _value._prices
            : prices // ignore: cast_nullable_to_non_nullable
                  as List<ProductPrice>,
        taxRate: freezed == taxRate
            ? _value.taxRate
            : taxRate // ignore: cast_nullable_to_non_nullable
                  as String?,
        comment: freezed == comment
            ? _value.comment
            : comment // ignore: cast_nullable_to_non_nullable
                  as String?,
        stockable: null == stockable
            ? _value.stockable
            : stockable // ignore: cast_nullable_to_non_nullable
                  as bool,
        perishable: null == perishable
            ? _value.perishable
            : perishable // ignore: cast_nullable_to_non_nullable
                  as bool,
        seriable: null == seriable
            ? _value.seriable
            : seriable // ignore: cast_nullable_to_non_nullable
                  as bool,
        purchasable: null == purchasable
            ? _value.purchasable
            : purchasable // ignore: cast_nullable_to_non_nullable
                  as bool,
        salable: null == salable
            ? _value.salable
            : salable // ignore: cast_nullable_to_non_nullable
                  as bool,
        invoiceable: null == invoiceable
            ? _value.invoiceable
            : invoiceable // ignore: cast_nullable_to_non_nullable
                  as bool,
        deactivated: null == deactivated
            ? _value.deactivated
            : deactivated // ignore: cast_nullable_to_non_nullable
                  as bool,
        loading: null == loading
            ? _value.loading
            : loading // ignore: cast_nullable_to_non_nullable
                  as bool,
        submitting: null == submitting
            ? _value.submitting
            : submitting // ignore: cast_nullable_to_non_nullable
                  as bool,
        saved: null == saved
            ? _value.saved
            : saved // ignore: cast_nullable_to_non_nullable
                  as bool,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
        errorDetail: freezed == errorDetail
            ? _value.errorDetail
            : errorDetail // ignore: cast_nullable_to_non_nullable
                  as String?,
        fieldErrors: null == fieldErrors
            ? _value._fieldErrors
            : fieldErrors // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>,
      ),
    );
  }
}

/// @nodoc

class _$ProductFormStateImpl implements _ProductFormState {
  const _$ProductFormStateImpl({
    this.productId,
    this.code = '',
    this.name = '',
    this.brand,
    this.model,
    this.barCode,
    this.location,
    this.photo,
    this.pendingPhotoBytes,
    this.pendingPhotoFilename,
    this.photoMarkedForRemoval = false,
    this.unitOfMeasurementCode = '',
    this.unitOfMeasurementDisplayText = '',
    this.satKeyCode,
    this.satKeyDisplayText,
    this.supplierId,
    this.supplierName,
    final List<int> labelIds = const <int>[],
    final List<ProductPrice> prices = const <ProductPrice>[],
    this.taxRate,
    this.comment,
    this.stockable = false,
    this.perishable = false,
    this.seriable = false,
    this.purchasable = false,
    this.salable = false,
    this.invoiceable = false,
    this.deactivated = false,
    this.loading = false,
    this.submitting = false,
    this.saved = false,
    this.error,
    this.errorDetail,
    final Map<String, String> fieldErrors = const <String, String>{},
  }) : _labelIds = labelIds,
       _prices = prices,
       _fieldErrors = fieldErrors;

  @override
  final int? productId;
  @override
  @JsonKey()
  final String code;
  @override
  @JsonKey()
  final String name;
  @override
  final String? brand;
  @override
  final String? model;
  @override
  final String? barCode;
  @override
  final String? location;

  /// The product's currently-saved photo URL (FR-001), loaded via
  /// [loadForEdit]. `null` in create mode until a photo is staged
  /// (data-model.md "ProductFormState").
  @override
  final String? photo;

  /// In-memory bytes of a newly-picked image file, staged but not yet
  /// uploaded (FR-010 — applies only on save). `null` if nothing has been
  /// picked since the form was opened/loaded (data-model.md
  /// "ProductFormState").
  @override
  final Uint8List? pendingPhotoBytes;

  /// Original filename of [pendingPhotoBytes], used only for the
  /// upload's multipart filename.
  @override
  final String? pendingPhotoFilename;

  /// `true` if the user chose "remove photo" since the form was
  /// opened/loaded, and no new photo has been picked since. Mutually
  /// exclusive with a non-null [pendingPhotoBytes].
  @override
  @JsonKey()
  final bool photoMarkedForRemoval;
  @override
  @JsonKey()
  final String unitOfMeasurementCode;
  @override
  @JsonKey()
  final String unitOfMeasurementDisplayText;
  @override
  final String? satKeyCode;
  @override
  final String? satKeyDisplayText;
  @override
  final int? supplierId;
  @override
  final String? supplierName;
  final List<int> _labelIds;
  @override
  @JsonKey()
  List<int> get labelIds {
    if (_labelIds is EqualUnmodifiableListView) return _labelIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_labelIds);
  }

  final List<ProductPrice> _prices;
  @override
  @JsonKey()
  List<ProductPrice> get prices {
    if (_prices is EqualUnmodifiableListView) return _prices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_prices);
  }

  @override
  final String? taxRate;
  @override
  final String? comment;
  @override
  @JsonKey()
  final bool stockable;
  @override
  @JsonKey()
  final bool perishable;
  @override
  @JsonKey()
  final bool seriable;
  @override
  @JsonKey()
  final bool purchasable;
  @override
  @JsonKey()
  final bool salable;
  @override
  @JsonKey()
  final bool invoiceable;
  @override
  @JsonKey()
  final bool deactivated;
  @override
  @JsonKey()
  final bool loading;
  @override
  @JsonKey()
  final bool submitting;
  @override
  @JsonKey()
  final bool saved;
  @override
  final String? error;

  /// The server-provided detail behind [error] (e.g. mbe-api's `detail`
  /// string on a `404`/`5xx`), shown alongside the localized [error]
  /// message since it can't be localized client-side. `null` for
  /// client-side-only errors (validation, permission checks).
  @override
  final String? errorDetail;
  final Map<String, String> _fieldErrors;
  @override
  @JsonKey()
  Map<String, String> get fieldErrors {
    if (_fieldErrors is EqualUnmodifiableMapView) return _fieldErrors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_fieldErrors);
  }

  @override
  String toString() {
    return 'ProductFormState(productId: $productId, code: $code, name: $name, brand: $brand, model: $model, barCode: $barCode, location: $location, photo: $photo, pendingPhotoBytes: $pendingPhotoBytes, pendingPhotoFilename: $pendingPhotoFilename, photoMarkedForRemoval: $photoMarkedForRemoval, unitOfMeasurementCode: $unitOfMeasurementCode, unitOfMeasurementDisplayText: $unitOfMeasurementDisplayText, satKeyCode: $satKeyCode, satKeyDisplayText: $satKeyDisplayText, supplierId: $supplierId, supplierName: $supplierName, labelIds: $labelIds, prices: $prices, taxRate: $taxRate, comment: $comment, stockable: $stockable, perishable: $perishable, seriable: $seriable, purchasable: $purchasable, salable: $salable, invoiceable: $invoiceable, deactivated: $deactivated, loading: $loading, submitting: $submitting, saved: $saved, error: $error, errorDetail: $errorDetail, fieldErrors: $fieldErrors)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductFormStateImpl &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.brand, brand) || other.brand == brand) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.barCode, barCode) || other.barCode == barCode) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.photo, photo) || other.photo == photo) &&
            const DeepCollectionEquality().equals(
              other.pendingPhotoBytes,
              pendingPhotoBytes,
            ) &&
            (identical(other.pendingPhotoFilename, pendingPhotoFilename) ||
                other.pendingPhotoFilename == pendingPhotoFilename) &&
            (identical(other.photoMarkedForRemoval, photoMarkedForRemoval) ||
                other.photoMarkedForRemoval == photoMarkedForRemoval) &&
            (identical(other.unitOfMeasurementCode, unitOfMeasurementCode) ||
                other.unitOfMeasurementCode == unitOfMeasurementCode) &&
            (identical(
                  other.unitOfMeasurementDisplayText,
                  unitOfMeasurementDisplayText,
                ) ||
                other.unitOfMeasurementDisplayText ==
                    unitOfMeasurementDisplayText) &&
            (identical(other.satKeyCode, satKeyCode) ||
                other.satKeyCode == satKeyCode) &&
            (identical(other.satKeyDisplayText, satKeyDisplayText) ||
                other.satKeyDisplayText == satKeyDisplayText) &&
            (identical(other.supplierId, supplierId) ||
                other.supplierId == supplierId) &&
            (identical(other.supplierName, supplierName) ||
                other.supplierName == supplierName) &&
            const DeepCollectionEquality().equals(other._labelIds, _labelIds) &&
            const DeepCollectionEquality().equals(other._prices, _prices) &&
            (identical(other.taxRate, taxRate) || other.taxRate == taxRate) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            (identical(other.stockable, stockable) ||
                other.stockable == stockable) &&
            (identical(other.perishable, perishable) ||
                other.perishable == perishable) &&
            (identical(other.seriable, seriable) ||
                other.seriable == seriable) &&
            (identical(other.purchasable, purchasable) ||
                other.purchasable == purchasable) &&
            (identical(other.salable, salable) || other.salable == salable) &&
            (identical(other.invoiceable, invoiceable) ||
                other.invoiceable == invoiceable) &&
            (identical(other.deactivated, deactivated) ||
                other.deactivated == deactivated) &&
            (identical(other.loading, loading) || other.loading == loading) &&
            (identical(other.submitting, submitting) ||
                other.submitting == submitting) &&
            (identical(other.saved, saved) || other.saved == saved) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.errorDetail, errorDetail) ||
                other.errorDetail == errorDetail) &&
            const DeepCollectionEquality().equals(
              other._fieldErrors,
              _fieldErrors,
            ));
  }

  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    productId,
    code,
    name,
    brand,
    model,
    barCode,
    location,
    photo,
    const DeepCollectionEquality().hash(pendingPhotoBytes),
    pendingPhotoFilename,
    photoMarkedForRemoval,
    unitOfMeasurementCode,
    unitOfMeasurementDisplayText,
    satKeyCode,
    satKeyDisplayText,
    supplierId,
    supplierName,
    const DeepCollectionEquality().hash(_labelIds),
    const DeepCollectionEquality().hash(_prices),
    taxRate,
    comment,
    stockable,
    perishable,
    seriable,
    purchasable,
    salable,
    invoiceable,
    deactivated,
    loading,
    submitting,
    saved,
    error,
    errorDetail,
    const DeepCollectionEquality().hash(_fieldErrors),
  ]);

  /// Create a copy of ProductFormState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductFormStateImplCopyWith<_$ProductFormStateImpl> get copyWith =>
      __$$ProductFormStateImplCopyWithImpl<_$ProductFormStateImpl>(
        this,
        _$identity,
      );
}

abstract class _ProductFormState implements ProductFormState {
  const factory _ProductFormState({
    final int? productId,
    final String code,
    final String name,
    final String? brand,
    final String? model,
    final String? barCode,
    final String? location,
    final String? photo,
    final Uint8List? pendingPhotoBytes,
    final String? pendingPhotoFilename,
    final bool photoMarkedForRemoval,
    final String unitOfMeasurementCode,
    final String unitOfMeasurementDisplayText,
    final String? satKeyCode,
    final String? satKeyDisplayText,
    final int? supplierId,
    final String? supplierName,
    final List<int> labelIds,
    final List<ProductPrice> prices,
    final String? taxRate,
    final String? comment,
    final bool stockable,
    final bool perishable,
    final bool seriable,
    final bool purchasable,
    final bool salable,
    final bool invoiceable,
    final bool deactivated,
    final bool loading,
    final bool submitting,
    final bool saved,
    final String? error,
    final String? errorDetail,
    final Map<String, String> fieldErrors,
  }) = _$ProductFormStateImpl;

  @override
  int? get productId;
  @override
  String get code;
  @override
  String get name;
  @override
  String? get brand;
  @override
  String? get model;
  @override
  String? get barCode;
  @override
  String? get location;

  /// The product's currently-saved photo URL (FR-001), loaded via
  /// [loadForEdit]. `null` in create mode until a photo is staged
  /// (data-model.md "ProductFormState").
  @override
  String? get photo;

  /// In-memory bytes of a newly-picked image file, staged but not yet
  /// uploaded (FR-010 — applies only on save). `null` if nothing has been
  /// picked since the form was opened/loaded (data-model.md
  /// "ProductFormState").
  @override
  Uint8List? get pendingPhotoBytes;

  /// Original filename of [pendingPhotoBytes], used only for the
  /// upload's multipart filename.
  @override
  String? get pendingPhotoFilename;

  /// `true` if the user chose "remove photo" since the form was
  /// opened/loaded, and no new photo has been picked since. Mutually
  /// exclusive with a non-null [pendingPhotoBytes].
  @override
  bool get photoMarkedForRemoval;
  @override
  String get unitOfMeasurementCode;
  @override
  String get unitOfMeasurementDisplayText;
  @override
  String? get satKeyCode;
  @override
  String? get satKeyDisplayText;
  @override
  int? get supplierId;
  @override
  String? get supplierName;
  @override
  List<int> get labelIds;
  @override
  List<ProductPrice> get prices;
  @override
  String? get taxRate;
  @override
  String? get comment;
  @override
  bool get stockable;
  @override
  bool get perishable;
  @override
  bool get seriable;
  @override
  bool get purchasable;
  @override
  bool get salable;
  @override
  bool get invoiceable;
  @override
  bool get deactivated;
  @override
  bool get loading;
  @override
  bool get submitting;
  @override
  bool get saved;
  @override
  String? get error;

  /// The server-provided detail behind [error] (e.g. mbe-api's `detail`
  /// string on a `404`/`5xx`), shown alongside the localized [error]
  /// message since it can't be localized client-side. `null` for
  /// client-side-only errors (validation, permission checks).
  @override
  String? get errorDetail;
  @override
  Map<String, String> get fieldErrors;

  /// Create a copy of ProductFormState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductFormStateImplCopyWith<_$ProductFormStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
