// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_form_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProductFormState {

 int? get productId; String get code; String get name; String get sku; String? get brand; String? get model; String? get barCode; String? get location;/// The product's currently-saved photo URL (FR-001), loaded via
/// [loadForEdit]. `null` in create mode until a photo is staged
/// (data-model.md "ProductFormState").
 String? get photo;/// In-memory bytes of a newly-picked image file, staged but not yet
/// uploaded (FR-010 — applies only on save). `null` if nothing has been
/// picked since the form was opened/loaded (data-model.md
/// "ProductFormState").
 Uint8List? get pendingPhotoBytes;/// Original filename of [pendingPhotoBytes], used only for the
/// upload's multipart filename.
 String? get pendingPhotoFilename;/// `true` if the user chose "remove photo" since the form was
/// opened/loaded, and no new photo has been picked since. Mutually
/// exclusive with a non-null [pendingPhotoBytes].
 bool get photoMarkedForRemoval; String get unitOfMeasurementCode; String get unitOfMeasurementDisplayText; String? get satKeyCode; String? get satKeyDisplayText; int? get supplierId; String? get supplierName; List<int> get labelIds; String? get taxRate; Currency get currency; String? get comment; bool get stockable; bool get perishable; bool get seriable; bool get purchasable; bool get salable; bool get invoiceable; bool get loading; bool get submitting; bool get saved;/// `true` after a successful hard [ProductFormController.delete] call
/// (FR-016a) — the screen pops back to the list on this, mirroring
/// [saved].
 bool get deleted; String? get error;/// The server-provided detail behind [error] (e.g. mbe-api's `detail`
/// string on a `404`/`5xx`), shown alongside the localized [error]
/// message since it can't be localized client-side. `null` for
/// client-side-only errors (validation, permission checks).
 String? get errorDetail; Map<String, String> get fieldErrors;
/// Create a copy of ProductFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductFormStateCopyWith<ProductFormState> get copyWith => _$ProductFormStateCopyWithImpl<ProductFormState>(this as ProductFormState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ProductFormState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductFormState&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.sku, _this.sku) || other.sku == _this.sku)&&(identical(other.brand, _this.brand) || other.brand == _this.brand)&&(identical(other.model, _this.model) || other.model == _this.model)&&(identical(other.barCode, _this.barCode) || other.barCode == _this.barCode)&&(identical(other.location, _this.location) || other.location == _this.location)&&(identical(other.photo, _this.photo) || other.photo == _this.photo)&&const DeepCollectionEquality().equals(other.pendingPhotoBytes, _this.pendingPhotoBytes)&&(identical(other.pendingPhotoFilename, _this.pendingPhotoFilename) || other.pendingPhotoFilename == _this.pendingPhotoFilename)&&(identical(other.photoMarkedForRemoval, _this.photoMarkedForRemoval) || other.photoMarkedForRemoval == _this.photoMarkedForRemoval)&&(identical(other.unitOfMeasurementCode, _this.unitOfMeasurementCode) || other.unitOfMeasurementCode == _this.unitOfMeasurementCode)&&(identical(other.unitOfMeasurementDisplayText, _this.unitOfMeasurementDisplayText) || other.unitOfMeasurementDisplayText == _this.unitOfMeasurementDisplayText)&&(identical(other.satKeyCode, _this.satKeyCode) || other.satKeyCode == _this.satKeyCode)&&(identical(other.satKeyDisplayText, _this.satKeyDisplayText) || other.satKeyDisplayText == _this.satKeyDisplayText)&&(identical(other.supplierId, _this.supplierId) || other.supplierId == _this.supplierId)&&(identical(other.supplierName, _this.supplierName) || other.supplierName == _this.supplierName)&&const DeepCollectionEquality().equals(other.labelIds, _this.labelIds)&&(identical(other.taxRate, _this.taxRate) || other.taxRate == _this.taxRate)&&(identical(other.currency, _this.currency) || other.currency == _this.currency)&&(identical(other.comment, _this.comment) || other.comment == _this.comment)&&(identical(other.stockable, _this.stockable) || other.stockable == _this.stockable)&&(identical(other.perishable, _this.perishable) || other.perishable == _this.perishable)&&(identical(other.seriable, _this.seriable) || other.seriable == _this.seriable)&&(identical(other.purchasable, _this.purchasable) || other.purchasable == _this.purchasable)&&(identical(other.salable, _this.salable) || other.salable == _this.salable)&&(identical(other.invoiceable, _this.invoiceable) || other.invoiceable == _this.invoiceable)&&(identical(other.loading, _this.loading) || other.loading == _this.loading)&&(identical(other.submitting, _this.submitting) || other.submitting == _this.submitting)&&(identical(other.saved, _this.saved) || other.saved == _this.saved)&&(identical(other.deleted, _this.deleted) || other.deleted == _this.deleted)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.errorDetail, _this.errorDetail) || other.errorDetail == _this.errorDetail)&&const DeepCollectionEquality().equals(other.fieldErrors, _this.fieldErrors));
}


@override
int get hashCode {
  final _this = this as ProductFormState;
  return Object.hashAll([runtimeType,_this.productId,_this.code,_this.name,_this.sku,_this.brand,_this.model,_this.barCode,_this.location,_this.photo,const DeepCollectionEquality().hash(_this.pendingPhotoBytes),_this.pendingPhotoFilename,_this.photoMarkedForRemoval,_this.unitOfMeasurementCode,_this.unitOfMeasurementDisplayText,_this.satKeyCode,_this.satKeyDisplayText,_this.supplierId,_this.supplierName,const DeepCollectionEquality().hash(_this.labelIds),_this.taxRate,_this.currency,_this.comment,_this.stockable,_this.perishable,_this.seriable,_this.purchasable,_this.salable,_this.invoiceable,_this.loading,_this.submitting,_this.saved,_this.deleted,_this.error,_this.errorDetail,const DeepCollectionEquality().hash(_this.fieldErrors)]);
}

@override
String toString() {
  final _this = this as ProductFormState;
  return 'ProductFormState(productId: ${_this.productId}, code: ${_this.code}, name: ${_this.name}, sku: ${_this.sku}, brand: ${_this.brand}, model: ${_this.model}, barCode: ${_this.barCode}, location: ${_this.location}, photo: ${_this.photo}, pendingPhotoBytes: ${_this.pendingPhotoBytes}, pendingPhotoFilename: ${_this.pendingPhotoFilename}, photoMarkedForRemoval: ${_this.photoMarkedForRemoval}, unitOfMeasurementCode: ${_this.unitOfMeasurementCode}, unitOfMeasurementDisplayText: ${_this.unitOfMeasurementDisplayText}, satKeyCode: ${_this.satKeyCode}, satKeyDisplayText: ${_this.satKeyDisplayText}, supplierId: ${_this.supplierId}, supplierName: ${_this.supplierName}, labelIds: ${_this.labelIds}, taxRate: ${_this.taxRate}, currency: ${_this.currency}, comment: ${_this.comment}, stockable: ${_this.stockable}, perishable: ${_this.perishable}, seriable: ${_this.seriable}, purchasable: ${_this.purchasable}, salable: ${_this.salable}, invoiceable: ${_this.invoiceable}, loading: ${_this.loading}, submitting: ${_this.submitting}, saved: ${_this.saved}, deleted: ${_this.deleted}, error: ${_this.error}, errorDetail: ${_this.errorDetail}, fieldErrors: ${_this.fieldErrors})';
}


}

/// @nodoc
abstract mixin class $ProductFormStateCopyWith<$Res>  {
  factory $ProductFormStateCopyWith(ProductFormState value, $Res Function(ProductFormState) _then) = _$ProductFormStateCopyWithImpl;
@useResult
$Res call({
 int? productId, String code, String name, String sku, String? brand, String? model, String? barCode, String? location, String? photo, Uint8List? pendingPhotoBytes, String? pendingPhotoFilename, bool photoMarkedForRemoval, String unitOfMeasurementCode, String unitOfMeasurementDisplayText, String? satKeyCode, String? satKeyDisplayText, int? supplierId, String? supplierName, List<int> labelIds, String? taxRate, Currency currency, String? comment, bool stockable, bool perishable, bool seriable, bool purchasable, bool salable, bool invoiceable, bool loading, bool submitting, bool saved, bool deleted, String? error, String? errorDetail, Map<String, String> fieldErrors
});




}
/// @nodoc
class _$ProductFormStateCopyWithImpl<$Res>
    implements $ProductFormStateCopyWith<$Res> {
  _$ProductFormStateCopyWithImpl(this._self, this._then);

  final ProductFormState _self;
  final $Res Function(ProductFormState) _then;

/// Create a copy of ProductFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = freezed,Object? code = null,Object? name = null,Object? sku = null,Object? brand = freezed,Object? model = freezed,Object? barCode = freezed,Object? location = freezed,Object? photo = freezed,Object? pendingPhotoBytes = freezed,Object? pendingPhotoFilename = freezed,Object? photoMarkedForRemoval = null,Object? unitOfMeasurementCode = null,Object? unitOfMeasurementDisplayText = null,Object? satKeyCode = freezed,Object? satKeyDisplayText = freezed,Object? supplierId = freezed,Object? supplierName = freezed,Object? labelIds = null,Object? taxRate = freezed,Object? currency = null,Object? comment = freezed,Object? stockable = null,Object? perishable = null,Object? seriable = null,Object? purchasable = null,Object? salable = null,Object? invoiceable = null,Object? loading = null,Object? submitting = null,Object? saved = null,Object? deleted = null,Object? error = freezed,Object? errorDetail = freezed,Object? fieldErrors = null,}) {
  return _then(ProductFormState(
productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int?,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sku: null == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,barCode: freezed == barCode ? _self.barCode : barCode // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,photo: freezed == photo ? _self.photo : photo // ignore: cast_nullable_to_non_nullable
as String?,pendingPhotoBytes: freezed == pendingPhotoBytes ? _self.pendingPhotoBytes : pendingPhotoBytes // ignore: cast_nullable_to_non_nullable
as Uint8List?,pendingPhotoFilename: freezed == pendingPhotoFilename ? _self.pendingPhotoFilename : pendingPhotoFilename // ignore: cast_nullable_to_non_nullable
as String?,photoMarkedForRemoval: null == photoMarkedForRemoval ? _self.photoMarkedForRemoval : photoMarkedForRemoval // ignore: cast_nullable_to_non_nullable
as bool,unitOfMeasurementCode: null == unitOfMeasurementCode ? _self.unitOfMeasurementCode : unitOfMeasurementCode // ignore: cast_nullable_to_non_nullable
as String,unitOfMeasurementDisplayText: null == unitOfMeasurementDisplayText ? _self.unitOfMeasurementDisplayText : unitOfMeasurementDisplayText // ignore: cast_nullable_to_non_nullable
as String,satKeyCode: freezed == satKeyCode ? _self.satKeyCode : satKeyCode // ignore: cast_nullable_to_non_nullable
as String?,satKeyDisplayText: freezed == satKeyDisplayText ? _self.satKeyDisplayText : satKeyDisplayText // ignore: cast_nullable_to_non_nullable
as String?,supplierId: freezed == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as int?,supplierName: freezed == supplierName ? _self.supplierName : supplierName // ignore: cast_nullable_to_non_nullable
as String?,labelIds: null == labelIds ? _self.labelIds : labelIds // ignore: cast_nullable_to_non_nullable
as List<int>,taxRate: freezed == taxRate ? _self.taxRate : taxRate // ignore: cast_nullable_to_non_nullable
as String?,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as Currency,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,stockable: null == stockable ? _self.stockable : stockable // ignore: cast_nullable_to_non_nullable
as bool,perishable: null == perishable ? _self.perishable : perishable // ignore: cast_nullable_to_non_nullable
as bool,seriable: null == seriable ? _self.seriable : seriable // ignore: cast_nullable_to_non_nullable
as bool,purchasable: null == purchasable ? _self.purchasable : purchasable // ignore: cast_nullable_to_non_nullable
as bool,salable: null == salable ? _self.salable : salable // ignore: cast_nullable_to_non_nullable
as bool,invoiceable: null == invoiceable ? _self.invoiceable : invoiceable // ignore: cast_nullable_to_non_nullable
as bool,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as bool,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,errorDetail: freezed == errorDetail ? _self.errorDetail : errorDetail // ignore: cast_nullable_to_non_nullable
as String?,fieldErrors: null == fieldErrors ? _self.fieldErrors : fieldErrors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductFormState].
extension ProductFormStatePatterns on ProductFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductFormState value)  $default,){
final _that = this;
switch (_that) {
case _ProductFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductFormState value)?  $default,){
final _that = this;
switch (_that) {
case _ProductFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? productId,  String code,  String name,  String sku,  String? brand,  String? model,  String? barCode,  String? location,  String? photo,  Uint8List? pendingPhotoBytes,  String? pendingPhotoFilename,  bool photoMarkedForRemoval,  String unitOfMeasurementCode,  String unitOfMeasurementDisplayText,  String? satKeyCode,  String? satKeyDisplayText,  int? supplierId,  String? supplierName,  List<int> labelIds,  String? taxRate,  Currency currency,  String? comment,  bool stockable,  bool perishable,  bool seriable,  bool purchasable,  bool salable,  bool invoiceable,  bool loading,  bool submitting,  bool saved,  bool deleted,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductFormState() when $default != null:
return $default(_that.productId,_that.code,_that.name,_that.sku,_that.brand,_that.model,_that.barCode,_that.location,_that.photo,_that.pendingPhotoBytes,_that.pendingPhotoFilename,_that.photoMarkedForRemoval,_that.unitOfMeasurementCode,_that.unitOfMeasurementDisplayText,_that.satKeyCode,_that.satKeyDisplayText,_that.supplierId,_that.supplierName,_that.labelIds,_that.taxRate,_that.currency,_that.comment,_that.stockable,_that.perishable,_that.seriable,_that.purchasable,_that.salable,_that.invoiceable,_that.loading,_that.submitting,_that.saved,_that.deleted,_that.error,_that.errorDetail,_that.fieldErrors);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? productId,  String code,  String name,  String sku,  String? brand,  String? model,  String? barCode,  String? location,  String? photo,  Uint8List? pendingPhotoBytes,  String? pendingPhotoFilename,  bool photoMarkedForRemoval,  String unitOfMeasurementCode,  String unitOfMeasurementDisplayText,  String? satKeyCode,  String? satKeyDisplayText,  int? supplierId,  String? supplierName,  List<int> labelIds,  String? taxRate,  Currency currency,  String? comment,  bool stockable,  bool perishable,  bool seriable,  bool purchasable,  bool salable,  bool invoiceable,  bool loading,  bool submitting,  bool saved,  bool deleted,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)  $default,) {final _that = this;
switch (_that) {
case _ProductFormState():
return $default(_that.productId,_that.code,_that.name,_that.sku,_that.brand,_that.model,_that.barCode,_that.location,_that.photo,_that.pendingPhotoBytes,_that.pendingPhotoFilename,_that.photoMarkedForRemoval,_that.unitOfMeasurementCode,_that.unitOfMeasurementDisplayText,_that.satKeyCode,_that.satKeyDisplayText,_that.supplierId,_that.supplierName,_that.labelIds,_that.taxRate,_that.currency,_that.comment,_that.stockable,_that.perishable,_that.seriable,_that.purchasable,_that.salable,_that.invoiceable,_that.loading,_that.submitting,_that.saved,_that.deleted,_that.error,_that.errorDetail,_that.fieldErrors);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? productId,  String code,  String name,  String sku,  String? brand,  String? model,  String? barCode,  String? location,  String? photo,  Uint8List? pendingPhotoBytes,  String? pendingPhotoFilename,  bool photoMarkedForRemoval,  String unitOfMeasurementCode,  String unitOfMeasurementDisplayText,  String? satKeyCode,  String? satKeyDisplayText,  int? supplierId,  String? supplierName,  List<int> labelIds,  String? taxRate,  Currency currency,  String? comment,  bool stockable,  bool perishable,  bool seriable,  bool purchasable,  bool salable,  bool invoiceable,  bool loading,  bool submitting,  bool saved,  bool deleted,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)?  $default,) {final _that = this;
switch (_that) {
case _ProductFormState() when $default != null:
return $default(_that.productId,_that.code,_that.name,_that.sku,_that.brand,_that.model,_that.barCode,_that.location,_that.photo,_that.pendingPhotoBytes,_that.pendingPhotoFilename,_that.photoMarkedForRemoval,_that.unitOfMeasurementCode,_that.unitOfMeasurementDisplayText,_that.satKeyCode,_that.satKeyDisplayText,_that.supplierId,_that.supplierName,_that.labelIds,_that.taxRate,_that.currency,_that.comment,_that.stockable,_that.perishable,_that.seriable,_that.purchasable,_that.salable,_that.invoiceable,_that.loading,_that.submitting,_that.saved,_that.deleted,_that.error,_that.errorDetail,_that.fieldErrors);case _:
  return null;

}
}

}

/// @nodoc


class _ProductFormState implements ProductFormState {
  const _ProductFormState({this.productId, this.code = '', this.name = '', this.sku = '', this.brand, this.model, this.barCode, this.location, this.photo, this.pendingPhotoBytes, this.pendingPhotoFilename, this.photoMarkedForRemoval = false, this.unitOfMeasurementCode = '', this.unitOfMeasurementDisplayText = '', this.satKeyCode, this.satKeyDisplayText, this.supplierId, this.supplierName,  List<int> labelIds = const <int>[], this.taxRate, this.currency = Currency.mxn, this.comment, this.stockable = false, this.perishable = false, this.seriable = false, this.purchasable = false, this.salable = false, this.invoiceable = false, this.loading = false, this.submitting = false, this.saved = false, this.deleted = false, this.error, this.errorDetail,  Map<String, String> fieldErrors = const <String, String>{}}): _labelIds = labelIds,_fieldErrors = fieldErrors;
  

@override final  int? productId;
@override@JsonKey() final  String code;
@override@JsonKey() final  String name;
@override@JsonKey() final  String sku;
@override final  String? brand;
@override final  String? model;
@override final  String? barCode;
@override final  String? location;
/// The product's currently-saved photo URL (FR-001), loaded via
/// [loadForEdit]. `null` in create mode until a photo is staged
/// (data-model.md "ProductFormState").
@override final  String? photo;
/// In-memory bytes of a newly-picked image file, staged but not yet
/// uploaded (FR-010 — applies only on save). `null` if nothing has been
/// picked since the form was opened/loaded (data-model.md
/// "ProductFormState").
@override final  Uint8List? pendingPhotoBytes;
/// Original filename of [pendingPhotoBytes], used only for the
/// upload's multipart filename.
@override final  String? pendingPhotoFilename;
/// `true` if the user chose "remove photo" since the form was
/// opened/loaded, and no new photo has been picked since. Mutually
/// exclusive with a non-null [pendingPhotoBytes].
@override@JsonKey() final  bool photoMarkedForRemoval;
@override@JsonKey() final  String unitOfMeasurementCode;
@override@JsonKey() final  String unitOfMeasurementDisplayText;
@override final  String? satKeyCode;
@override final  String? satKeyDisplayText;
@override final  int? supplierId;
@override final  String? supplierName;
 final  List<int> _labelIds;
@override@JsonKey() List<int> get labelIds {
  if (_labelIds is EqualUnmodifiableListView) return _labelIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_labelIds);
}

@override final  String? taxRate;
@override@JsonKey() final  Currency currency;
@override final  String? comment;
@override@JsonKey() final  bool stockable;
@override@JsonKey() final  bool perishable;
@override@JsonKey() final  bool seriable;
@override@JsonKey() final  bool purchasable;
@override@JsonKey() final  bool salable;
@override@JsonKey() final  bool invoiceable;
@override@JsonKey() final  bool loading;
@override@JsonKey() final  bool submitting;
@override@JsonKey() final  bool saved;
/// `true` after a successful hard [ProductFormController.delete] call
/// (FR-016a) — the screen pops back to the list on this, mirroring
/// [saved].
@override@JsonKey() final  bool deleted;
@override final  String? error;
/// The server-provided detail behind [error] (e.g. mbe-api's `detail`
/// string on a `404`/`5xx`), shown alongside the localized [error]
/// message since it can't be localized client-side. `null` for
/// client-side-only errors (validation, permission checks).
@override final  String? errorDetail;
 final  Map<String, String> _fieldErrors;
@override@JsonKey() Map<String, String> get fieldErrors {
  if (_fieldErrors is EqualUnmodifiableMapView) return _fieldErrors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_fieldErrors);
}


/// Create a copy of ProductFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductFormStateCopyWith<_ProductFormState> get copyWith => __$ProductFormStateCopyWithImpl<_ProductFormState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductFormState&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.model, model) || other.model == model)&&(identical(other.barCode, barCode) || other.barCode == barCode)&&(identical(other.location, location) || other.location == location)&&(identical(other.photo, photo) || other.photo == photo)&&const DeepCollectionEquality().equals(other.pendingPhotoBytes, pendingPhotoBytes)&&(identical(other.pendingPhotoFilename, pendingPhotoFilename) || other.pendingPhotoFilename == pendingPhotoFilename)&&(identical(other.photoMarkedForRemoval, photoMarkedForRemoval) || other.photoMarkedForRemoval == photoMarkedForRemoval)&&(identical(other.unitOfMeasurementCode, unitOfMeasurementCode) || other.unitOfMeasurementCode == unitOfMeasurementCode)&&(identical(other.unitOfMeasurementDisplayText, unitOfMeasurementDisplayText) || other.unitOfMeasurementDisplayText == unitOfMeasurementDisplayText)&&(identical(other.satKeyCode, satKeyCode) || other.satKeyCode == satKeyCode)&&(identical(other.satKeyDisplayText, satKeyDisplayText) || other.satKeyDisplayText == satKeyDisplayText)&&(identical(other.supplierId, supplierId) || other.supplierId == supplierId)&&(identical(other.supplierName, supplierName) || other.supplierName == supplierName)&&const DeepCollectionEquality().equals(other.labelIds, _labelIds)&&(identical(other.taxRate, taxRate) || other.taxRate == taxRate)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.stockable, stockable) || other.stockable == stockable)&&(identical(other.perishable, perishable) || other.perishable == perishable)&&(identical(other.seriable, seriable) || other.seriable == seriable)&&(identical(other.purchasable, purchasable) || other.purchasable == purchasable)&&(identical(other.salable, salable) || other.salable == salable)&&(identical(other.invoiceable, invoiceable) || other.invoiceable == invoiceable)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.saved, saved) || other.saved == saved)&&(identical(other.deleted, deleted) || other.deleted == deleted)&&(identical(other.error, error) || other.error == error)&&(identical(other.errorDetail, errorDetail) || other.errorDetail == errorDetail)&&const DeepCollectionEquality().equals(other.fieldErrors, _fieldErrors));
}


@override
int get hashCode {
    return Object.hashAll([runtimeType,productId,code,name,sku,brand,model,barCode,location,photo,const DeepCollectionEquality().hash(pendingPhotoBytes),pendingPhotoFilename,photoMarkedForRemoval,unitOfMeasurementCode,unitOfMeasurementDisplayText,satKeyCode,satKeyDisplayText,supplierId,supplierName,const DeepCollectionEquality().hash(_labelIds),taxRate,currency,comment,stockable,perishable,seriable,purchasable,salable,invoiceable,loading,submitting,saved,deleted,error,errorDetail,const DeepCollectionEquality().hash(_fieldErrors)]);
}

@override
String toString() {
    return 'ProductFormState(productId: $productId, code: $code, name: $name, sku: $sku, brand: $brand, model: $model, barCode: $barCode, location: $location, photo: $photo, pendingPhotoBytes: $pendingPhotoBytes, pendingPhotoFilename: $pendingPhotoFilename, photoMarkedForRemoval: $photoMarkedForRemoval, unitOfMeasurementCode: $unitOfMeasurementCode, unitOfMeasurementDisplayText: $unitOfMeasurementDisplayText, satKeyCode: $satKeyCode, satKeyDisplayText: $satKeyDisplayText, supplierId: $supplierId, supplierName: $supplierName, labelIds: $labelIds, taxRate: $taxRate, currency: $currency, comment: $comment, stockable: $stockable, perishable: $perishable, seriable: $seriable, purchasable: $purchasable, salable: $salable, invoiceable: $invoiceable, loading: $loading, submitting: $submitting, saved: $saved, deleted: $deleted, error: $error, errorDetail: $errorDetail, fieldErrors: $fieldErrors)';
}


}

/// @nodoc
abstract mixin class _$ProductFormStateCopyWith<$Res> implements $ProductFormStateCopyWith<$Res> {
  factory _$ProductFormStateCopyWith(_ProductFormState value, $Res Function(_ProductFormState) _then) = __$ProductFormStateCopyWithImpl;
@override @useResult
$Res call({
 int? productId, String code, String name, String sku, String? brand, String? model, String? barCode, String? location, String? photo, Uint8List? pendingPhotoBytes, String? pendingPhotoFilename, bool photoMarkedForRemoval, String unitOfMeasurementCode, String unitOfMeasurementDisplayText, String? satKeyCode, String? satKeyDisplayText, int? supplierId, String? supplierName, List<int> labelIds, String? taxRate, Currency currency, String? comment, bool stockable, bool perishable, bool seriable, bool purchasable, bool salable, bool invoiceable, bool loading, bool submitting, bool saved, bool deleted, String? error, String? errorDetail, Map<String, String> fieldErrors
});




}
/// @nodoc
class __$ProductFormStateCopyWithImpl<$Res>
    implements _$ProductFormStateCopyWith<$Res> {
  __$ProductFormStateCopyWithImpl(this._self, this._then);

  final _ProductFormState _self;
  final $Res Function(_ProductFormState) _then;

/// Create a copy of ProductFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = freezed,Object? code = null,Object? name = null,Object? sku = null,Object? brand = freezed,Object? model = freezed,Object? barCode = freezed,Object? location = freezed,Object? photo = freezed,Object? pendingPhotoBytes = freezed,Object? pendingPhotoFilename = freezed,Object? photoMarkedForRemoval = null,Object? unitOfMeasurementCode = null,Object? unitOfMeasurementDisplayText = null,Object? satKeyCode = freezed,Object? satKeyDisplayText = freezed,Object? supplierId = freezed,Object? supplierName = freezed,Object? labelIds = null,Object? taxRate = freezed,Object? currency = null,Object? comment = freezed,Object? stockable = null,Object? perishable = null,Object? seriable = null,Object? purchasable = null,Object? salable = null,Object? invoiceable = null,Object? loading = null,Object? submitting = null,Object? saved = null,Object? deleted = null,Object? error = freezed,Object? errorDetail = freezed,Object? fieldErrors = null,}) {
  return _then(_ProductFormState(
productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int?,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sku: null == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,barCode: freezed == barCode ? _self.barCode : barCode // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,photo: freezed == photo ? _self.photo : photo // ignore: cast_nullable_to_non_nullable
as String?,pendingPhotoBytes: freezed == pendingPhotoBytes ? _self.pendingPhotoBytes : pendingPhotoBytes // ignore: cast_nullable_to_non_nullable
as Uint8List?,pendingPhotoFilename: freezed == pendingPhotoFilename ? _self.pendingPhotoFilename : pendingPhotoFilename // ignore: cast_nullable_to_non_nullable
as String?,photoMarkedForRemoval: null == photoMarkedForRemoval ? _self.photoMarkedForRemoval : photoMarkedForRemoval // ignore: cast_nullable_to_non_nullable
as bool,unitOfMeasurementCode: null == unitOfMeasurementCode ? _self.unitOfMeasurementCode : unitOfMeasurementCode // ignore: cast_nullable_to_non_nullable
as String,unitOfMeasurementDisplayText: null == unitOfMeasurementDisplayText ? _self.unitOfMeasurementDisplayText : unitOfMeasurementDisplayText // ignore: cast_nullable_to_non_nullable
as String,satKeyCode: freezed == satKeyCode ? _self.satKeyCode : satKeyCode // ignore: cast_nullable_to_non_nullable
as String?,satKeyDisplayText: freezed == satKeyDisplayText ? _self.satKeyDisplayText : satKeyDisplayText // ignore: cast_nullable_to_non_nullable
as String?,supplierId: freezed == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as int?,supplierName: freezed == supplierName ? _self.supplierName : supplierName // ignore: cast_nullable_to_non_nullable
as String?,labelIds: null == labelIds ? _self._labelIds : labelIds // ignore: cast_nullable_to_non_nullable
as List<int>,taxRate: freezed == taxRate ? _self.taxRate : taxRate // ignore: cast_nullable_to_non_nullable
as String?,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as Currency,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,stockable: null == stockable ? _self.stockable : stockable // ignore: cast_nullable_to_non_nullable
as bool,perishable: null == perishable ? _self.perishable : perishable // ignore: cast_nullable_to_non_nullable
as bool,seriable: null == seriable ? _self.seriable : seriable // ignore: cast_nullable_to_non_nullable
as bool,purchasable: null == purchasable ? _self.purchasable : purchasable // ignore: cast_nullable_to_non_nullable
as bool,salable: null == salable ? _self.salable : salable // ignore: cast_nullable_to_non_nullable
as bool,invoiceable: null == invoiceable ? _self.invoiceable : invoiceable // ignore: cast_nullable_to_non_nullable
as bool,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as bool,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,errorDetail: freezed == errorDetail ? _self.errorDetail : errorDetail // ignore: cast_nullable_to_non_nullable
as String?,fieldErrors: null == fieldErrors ? _self._fieldErrors : fieldErrors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}

// dart format on
