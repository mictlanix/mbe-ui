// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fiscal_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FiscalDocumentSummary {

 int get id; int get typeCode; String get version; String? get series;/// Null until the first confirm.
 int? get serial; String get issuerRfc; String? get issuerName; String? get recipientRfc; String? get recipientName;/// Mexico City wall-clock time (spec 043); null on a draft.
 DateTime? get issued; String? get stampUuid; FiscalDocumentStatus get status;/// Null on a draft: the server reads it from the XML.
 Decimal? get total;
/// Create a copy of FiscalDocumentSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FiscalDocumentSummaryCopyWith<FiscalDocumentSummary> get copyWith => _$FiscalDocumentSummaryCopyWithImpl<FiscalDocumentSummary>(this as FiscalDocumentSummary, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FiscalDocumentSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FiscalDocumentSummary&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.typeCode, _this.typeCode) || other.typeCode == _this.typeCode)&&(identical(other.version, _this.version) || other.version == _this.version)&&(identical(other.series, _this.series) || other.series == _this.series)&&(identical(other.serial, _this.serial) || other.serial == _this.serial)&&(identical(other.issuerRfc, _this.issuerRfc) || other.issuerRfc == _this.issuerRfc)&&(identical(other.issuerName, _this.issuerName) || other.issuerName == _this.issuerName)&&(identical(other.recipientRfc, _this.recipientRfc) || other.recipientRfc == _this.recipientRfc)&&(identical(other.recipientName, _this.recipientName) || other.recipientName == _this.recipientName)&&(identical(other.issued, _this.issued) || other.issued == _this.issued)&&(identical(other.stampUuid, _this.stampUuid) || other.stampUuid == _this.stampUuid)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.total, _this.total) || other.total == _this.total));
}


@override
int get hashCode {
  final _this = this as FiscalDocumentSummary;
  return Object.hash(runtimeType,_this.id,_this.typeCode,_this.version,_this.series,_this.serial,_this.issuerRfc,_this.issuerName,_this.recipientRfc,_this.recipientName,_this.issued,_this.stampUuid,_this.status,_this.total);
}

@override
String toString() {
  final _this = this as FiscalDocumentSummary;
  return 'FiscalDocumentSummary(id: ${_this.id}, typeCode: ${_this.typeCode}, version: ${_this.version}, series: ${_this.series}, serial: ${_this.serial}, issuerRfc: ${_this.issuerRfc}, issuerName: ${_this.issuerName}, recipientRfc: ${_this.recipientRfc}, recipientName: ${_this.recipientName}, issued: ${_this.issued}, stampUuid: ${_this.stampUuid}, status: ${_this.status}, total: ${_this.total})';
}


}

/// @nodoc
abstract mixin class $FiscalDocumentSummaryCopyWith<$Res>  {
  factory $FiscalDocumentSummaryCopyWith(FiscalDocumentSummary value, $Res Function(FiscalDocumentSummary) _then) = _$FiscalDocumentSummaryCopyWithImpl;
@useResult
$Res call({
 int id, int typeCode, String version, String? series, int? serial, String issuerRfc, String? issuerName, String? recipientRfc, String? recipientName, DateTime? issued, String? stampUuid, FiscalDocumentStatus status, Decimal? total
});




}
/// @nodoc
class _$FiscalDocumentSummaryCopyWithImpl<$Res>
    implements $FiscalDocumentSummaryCopyWith<$Res> {
  _$FiscalDocumentSummaryCopyWithImpl(this._self, this._then);

  final FiscalDocumentSummary _self;
  final $Res Function(FiscalDocumentSummary) _then;

/// Create a copy of FiscalDocumentSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? typeCode = null,Object? version = null,Object? series = freezed,Object? serial = freezed,Object? issuerRfc = null,Object? issuerName = freezed,Object? recipientRfc = freezed,Object? recipientName = freezed,Object? issued = freezed,Object? stampUuid = freezed,Object? status = null,Object? total = freezed,}) {
  return _then(FiscalDocumentSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,typeCode: null == typeCode ? _self.typeCode : typeCode // ignore: cast_nullable_to_non_nullable
as int,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,series: freezed == series ? _self.series : series // ignore: cast_nullable_to_non_nullable
as String?,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as int?,issuerRfc: null == issuerRfc ? _self.issuerRfc : issuerRfc // ignore: cast_nullable_to_non_nullable
as String,issuerName: freezed == issuerName ? _self.issuerName : issuerName // ignore: cast_nullable_to_non_nullable
as String?,recipientRfc: freezed == recipientRfc ? _self.recipientRfc : recipientRfc // ignore: cast_nullable_to_non_nullable
as String?,recipientName: freezed == recipientName ? _self.recipientName : recipientName // ignore: cast_nullable_to_non_nullable
as String?,issued: freezed == issued ? _self.issued : issued // ignore: cast_nullable_to_non_nullable
as DateTime?,stampUuid: freezed == stampUuid ? _self.stampUuid : stampUuid // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FiscalDocumentStatus,total: freezed == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as Decimal?,
  ));
}

}


/// Adds pattern-matching-related methods to [FiscalDocumentSummary].
extension FiscalDocumentSummaryPatterns on FiscalDocumentSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FiscalDocumentSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FiscalDocumentSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FiscalDocumentSummary value)  $default,){
final _that = this;
switch (_that) {
case _FiscalDocumentSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FiscalDocumentSummary value)?  $default,){
final _that = this;
switch (_that) {
case _FiscalDocumentSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int typeCode,  String version,  String? series,  int? serial,  String issuerRfc,  String? issuerName,  String? recipientRfc,  String? recipientName,  DateTime? issued,  String? stampUuid,  FiscalDocumentStatus status,  Decimal? total)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FiscalDocumentSummary() when $default != null:
return $default(_that.id,_that.typeCode,_that.version,_that.series,_that.serial,_that.issuerRfc,_that.issuerName,_that.recipientRfc,_that.recipientName,_that.issued,_that.stampUuid,_that.status,_that.total);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int typeCode,  String version,  String? series,  int? serial,  String issuerRfc,  String? issuerName,  String? recipientRfc,  String? recipientName,  DateTime? issued,  String? stampUuid,  FiscalDocumentStatus status,  Decimal? total)  $default,) {final _that = this;
switch (_that) {
case _FiscalDocumentSummary():
return $default(_that.id,_that.typeCode,_that.version,_that.series,_that.serial,_that.issuerRfc,_that.issuerName,_that.recipientRfc,_that.recipientName,_that.issued,_that.stampUuid,_that.status,_that.total);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int typeCode,  String version,  String? series,  int? serial,  String issuerRfc,  String? issuerName,  String? recipientRfc,  String? recipientName,  DateTime? issued,  String? stampUuid,  FiscalDocumentStatus status,  Decimal? total)?  $default,) {final _that = this;
switch (_that) {
case _FiscalDocumentSummary() when $default != null:
return $default(_that.id,_that.typeCode,_that.version,_that.series,_that.serial,_that.issuerRfc,_that.issuerName,_that.recipientRfc,_that.recipientName,_that.issued,_that.stampUuid,_that.status,_that.total);case _:
  return null;

}
}

}

/// @nodoc


class _FiscalDocumentSummary extends FiscalDocumentSummary {
  const _FiscalDocumentSummary({required this.id, required this.typeCode, required this.version, this.series, this.serial, required this.issuerRfc, this.issuerName, this.recipientRfc, this.recipientName, this.issued, this.stampUuid, required this.status, this.total}): super._();
  

@override final  int id;
@override final  int typeCode;
@override final  String version;
@override final  String? series;
/// Null until the first confirm.
@override final  int? serial;
@override final  String issuerRfc;
@override final  String? issuerName;
@override final  String? recipientRfc;
@override final  String? recipientName;
/// Mexico City wall-clock time (spec 043); null on a draft.
@override final  DateTime? issued;
@override final  String? stampUuid;
@override final  FiscalDocumentStatus status;
/// Null on a draft: the server reads it from the XML.
@override final  Decimal? total;

/// Create a copy of FiscalDocumentSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FiscalDocumentSummaryCopyWith<_FiscalDocumentSummary> get copyWith => __$FiscalDocumentSummaryCopyWithImpl<_FiscalDocumentSummary>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FiscalDocumentSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.typeCode, typeCode) || other.typeCode == typeCode)&&(identical(other.version, version) || other.version == version)&&(identical(other.series, series) || other.series == series)&&(identical(other.serial, serial) || other.serial == serial)&&(identical(other.issuerRfc, issuerRfc) || other.issuerRfc == issuerRfc)&&(identical(other.issuerName, issuerName) || other.issuerName == issuerName)&&(identical(other.recipientRfc, recipientRfc) || other.recipientRfc == recipientRfc)&&(identical(other.recipientName, recipientName) || other.recipientName == recipientName)&&(identical(other.issued, issued) || other.issued == issued)&&(identical(other.stampUuid, stampUuid) || other.stampUuid == stampUuid)&&(identical(other.status, status) || other.status == status)&&(identical(other.total, total) || other.total == total));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,typeCode,version,series,serial,issuerRfc,issuerName,recipientRfc,recipientName,issued,stampUuid,status,total);
}

@override
String toString() {
    return 'FiscalDocumentSummary(id: $id, typeCode: $typeCode, version: $version, series: $series, serial: $serial, issuerRfc: $issuerRfc, issuerName: $issuerName, recipientRfc: $recipientRfc, recipientName: $recipientName, issued: $issued, stampUuid: $stampUuid, status: $status, total: $total)';
}


}

/// @nodoc
abstract mixin class _$FiscalDocumentSummaryCopyWith<$Res> implements $FiscalDocumentSummaryCopyWith<$Res> {
  factory _$FiscalDocumentSummaryCopyWith(_FiscalDocumentSummary value, $Res Function(_FiscalDocumentSummary) _then) = __$FiscalDocumentSummaryCopyWithImpl;
@override @useResult
$Res call({
 int id, int typeCode, String version, String? series, int? serial, String issuerRfc, String? issuerName, String? recipientRfc, String? recipientName, DateTime? issued, String? stampUuid, FiscalDocumentStatus status, Decimal? total
});




}
/// @nodoc
class __$FiscalDocumentSummaryCopyWithImpl<$Res>
    implements _$FiscalDocumentSummaryCopyWith<$Res> {
  __$FiscalDocumentSummaryCopyWithImpl(this._self, this._then);

  final _FiscalDocumentSummary _self;
  final $Res Function(_FiscalDocumentSummary) _then;

/// Create a copy of FiscalDocumentSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? typeCode = null,Object? version = null,Object? series = freezed,Object? serial = freezed,Object? issuerRfc = null,Object? issuerName = freezed,Object? recipientRfc = freezed,Object? recipientName = freezed,Object? issued = freezed,Object? stampUuid = freezed,Object? status = null,Object? total = freezed,}) {
  return _then(_FiscalDocumentSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,typeCode: null == typeCode ? _self.typeCode : typeCode // ignore: cast_nullable_to_non_nullable
as int,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,series: freezed == series ? _self.series : series // ignore: cast_nullable_to_non_nullable
as String?,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as int?,issuerRfc: null == issuerRfc ? _self.issuerRfc : issuerRfc // ignore: cast_nullable_to_non_nullable
as String,issuerName: freezed == issuerName ? _self.issuerName : issuerName // ignore: cast_nullable_to_non_nullable
as String?,recipientRfc: freezed == recipientRfc ? _self.recipientRfc : recipientRfc // ignore: cast_nullable_to_non_nullable
as String?,recipientName: freezed == recipientName ? _self.recipientName : recipientName // ignore: cast_nullable_to_non_nullable
as String?,issued: freezed == issued ? _self.issued : issued // ignore: cast_nullable_to_non_nullable
as DateTime?,stampUuid: freezed == stampUuid ? _self.stampUuid : stampUuid // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FiscalDocumentStatus,total: freezed == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as Decimal?,
  ));
}


}

/// @nodoc
mixin _$InvoiceLine {

 int get id; int? get productId;/// Non-null when the line came from a sales order.
 int? get orderLineId; String? get productCode; String get productName; String? get satProductKey; String? get unitKey; String? get unitName; Decimal get quantity; Decimal get price;/// A fraction, 0–1.
 Decimal get discountRate;/// 0.16, 0 or -1 (exempt).
 Decimal get taxRate; bool get taxIncluded; String? get comment;
/// Create a copy of InvoiceLine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvoiceLineCopyWith<InvoiceLine> get copyWith => _$InvoiceLineCopyWithImpl<InvoiceLine>(this as InvoiceLine, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as InvoiceLine;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvoiceLine&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.orderLineId, _this.orderLineId) || other.orderLineId == _this.orderLineId)&&(identical(other.productCode, _this.productCode) || other.productCode == _this.productCode)&&(identical(other.productName, _this.productName) || other.productName == _this.productName)&&(identical(other.satProductKey, _this.satProductKey) || other.satProductKey == _this.satProductKey)&&(identical(other.unitKey, _this.unitKey) || other.unitKey == _this.unitKey)&&(identical(other.unitName, _this.unitName) || other.unitName == _this.unitName)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity)&&(identical(other.price, _this.price) || other.price == _this.price)&&(identical(other.discountRate, _this.discountRate) || other.discountRate == _this.discountRate)&&(identical(other.taxRate, _this.taxRate) || other.taxRate == _this.taxRate)&&(identical(other.taxIncluded, _this.taxIncluded) || other.taxIncluded == _this.taxIncluded)&&(identical(other.comment, _this.comment) || other.comment == _this.comment));
}


@override
int get hashCode {
  final _this = this as InvoiceLine;
  return Object.hash(runtimeType,_this.id,_this.productId,_this.orderLineId,_this.productCode,_this.productName,_this.satProductKey,_this.unitKey,_this.unitName,_this.quantity,_this.price,_this.discountRate,_this.taxRate,_this.taxIncluded,_this.comment);
}

@override
String toString() {
  final _this = this as InvoiceLine;
  return 'InvoiceLine(id: ${_this.id}, productId: ${_this.productId}, orderLineId: ${_this.orderLineId}, productCode: ${_this.productCode}, productName: ${_this.productName}, satProductKey: ${_this.satProductKey}, unitKey: ${_this.unitKey}, unitName: ${_this.unitName}, quantity: ${_this.quantity}, price: ${_this.price}, discountRate: ${_this.discountRate}, taxRate: ${_this.taxRate}, taxIncluded: ${_this.taxIncluded}, comment: ${_this.comment})';
}


}

/// @nodoc
abstract mixin class $InvoiceLineCopyWith<$Res>  {
  factory $InvoiceLineCopyWith(InvoiceLine value, $Res Function(InvoiceLine) _then) = _$InvoiceLineCopyWithImpl;
@useResult
$Res call({
 int id, int? productId, int? orderLineId, String? productCode, String productName, String? satProductKey, String? unitKey, String? unitName, Decimal quantity, Decimal price, Decimal discountRate, Decimal taxRate, bool taxIncluded, String? comment
});




}
/// @nodoc
class _$InvoiceLineCopyWithImpl<$Res>
    implements $InvoiceLineCopyWith<$Res> {
  _$InvoiceLineCopyWithImpl(this._self, this._then);

  final InvoiceLine _self;
  final $Res Function(InvoiceLine) _then;

/// Create a copy of InvoiceLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? productId = freezed,Object? orderLineId = freezed,Object? productCode = freezed,Object? productName = null,Object? satProductKey = freezed,Object? unitKey = freezed,Object? unitName = freezed,Object? quantity = null,Object? price = null,Object? discountRate = null,Object? taxRate = null,Object? taxIncluded = null,Object? comment = freezed,}) {
  return _then(InvoiceLine(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int?,orderLineId: freezed == orderLineId ? _self.orderLineId : orderLineId // ignore: cast_nullable_to_non_nullable
as int?,productCode: freezed == productCode ? _self.productCode : productCode // ignore: cast_nullable_to_non_nullable
as String?,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,satProductKey: freezed == satProductKey ? _self.satProductKey : satProductKey // ignore: cast_nullable_to_non_nullable
as String?,unitKey: freezed == unitKey ? _self.unitKey : unitKey // ignore: cast_nullable_to_non_nullable
as String?,unitName: freezed == unitName ? _self.unitName : unitName // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Decimal,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as Decimal,discountRate: null == discountRate ? _self.discountRate : discountRate // ignore: cast_nullable_to_non_nullable
as Decimal,taxRate: null == taxRate ? _self.taxRate : taxRate // ignore: cast_nullable_to_non_nullable
as Decimal,taxIncluded: null == taxIncluded ? _self.taxIncluded : taxIncluded // ignore: cast_nullable_to_non_nullable
as bool,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [InvoiceLine].
extension InvoiceLinePatterns on InvoiceLine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InvoiceLine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InvoiceLine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InvoiceLine value)  $default,){
final _that = this;
switch (_that) {
case _InvoiceLine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InvoiceLine value)?  $default,){
final _that = this;
switch (_that) {
case _InvoiceLine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int? productId,  int? orderLineId,  String? productCode,  String productName,  String? satProductKey,  String? unitKey,  String? unitName,  Decimal quantity,  Decimal price,  Decimal discountRate,  Decimal taxRate,  bool taxIncluded,  String? comment)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InvoiceLine() when $default != null:
return $default(_that.id,_that.productId,_that.orderLineId,_that.productCode,_that.productName,_that.satProductKey,_that.unitKey,_that.unitName,_that.quantity,_that.price,_that.discountRate,_that.taxRate,_that.taxIncluded,_that.comment);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int? productId,  int? orderLineId,  String? productCode,  String productName,  String? satProductKey,  String? unitKey,  String? unitName,  Decimal quantity,  Decimal price,  Decimal discountRate,  Decimal taxRate,  bool taxIncluded,  String? comment)  $default,) {final _that = this;
switch (_that) {
case _InvoiceLine():
return $default(_that.id,_that.productId,_that.orderLineId,_that.productCode,_that.productName,_that.satProductKey,_that.unitKey,_that.unitName,_that.quantity,_that.price,_that.discountRate,_that.taxRate,_that.taxIncluded,_that.comment);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int? productId,  int? orderLineId,  String? productCode,  String productName,  String? satProductKey,  String? unitKey,  String? unitName,  Decimal quantity,  Decimal price,  Decimal discountRate,  Decimal taxRate,  bool taxIncluded,  String? comment)?  $default,) {final _that = this;
switch (_that) {
case _InvoiceLine() when $default != null:
return $default(_that.id,_that.productId,_that.orderLineId,_that.productCode,_that.productName,_that.satProductKey,_that.unitKey,_that.unitName,_that.quantity,_that.price,_that.discountRate,_that.taxRate,_that.taxIncluded,_that.comment);case _:
  return null;

}
}

}

/// @nodoc


class _InvoiceLine extends InvoiceLine {
  const _InvoiceLine({required this.id, this.productId, this.orderLineId, this.productCode, required this.productName, this.satProductKey, this.unitKey, this.unitName, required this.quantity, required this.price, required this.discountRate, required this.taxRate, required this.taxIncluded, this.comment}): super._();
  

@override final  int id;
@override final  int? productId;
/// Non-null when the line came from a sales order.
@override final  int? orderLineId;
@override final  String? productCode;
@override final  String productName;
@override final  String? satProductKey;
@override final  String? unitKey;
@override final  String? unitName;
@override final  Decimal quantity;
@override final  Decimal price;
/// A fraction, 0–1.
@override final  Decimal discountRate;
/// 0.16, 0 or -1 (exempt).
@override final  Decimal taxRate;
@override final  bool taxIncluded;
@override final  String? comment;

/// Create a copy of InvoiceLine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvoiceLineCopyWith<_InvoiceLine> get copyWith => __$InvoiceLineCopyWithImpl<_InvoiceLine>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _InvoiceLine&&(identical(other.id, id) || other.id == id)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.orderLineId, orderLineId) || other.orderLineId == orderLineId)&&(identical(other.productCode, productCode) || other.productCode == productCode)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.satProductKey, satProductKey) || other.satProductKey == satProductKey)&&(identical(other.unitKey, unitKey) || other.unitKey == unitKey)&&(identical(other.unitName, unitName) || other.unitName == unitName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.price, price) || other.price == price)&&(identical(other.discountRate, discountRate) || other.discountRate == discountRate)&&(identical(other.taxRate, taxRate) || other.taxRate == taxRate)&&(identical(other.taxIncluded, taxIncluded) || other.taxIncluded == taxIncluded)&&(identical(other.comment, comment) || other.comment == comment));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,productId,orderLineId,productCode,productName,satProductKey,unitKey,unitName,quantity,price,discountRate,taxRate,taxIncluded,comment);
}

@override
String toString() {
    return 'InvoiceLine(id: $id, productId: $productId, orderLineId: $orderLineId, productCode: $productCode, productName: $productName, satProductKey: $satProductKey, unitKey: $unitKey, unitName: $unitName, quantity: $quantity, price: $price, discountRate: $discountRate, taxRate: $taxRate, taxIncluded: $taxIncluded, comment: $comment)';
}


}

/// @nodoc
abstract mixin class _$InvoiceLineCopyWith<$Res> implements $InvoiceLineCopyWith<$Res> {
  factory _$InvoiceLineCopyWith(_InvoiceLine value, $Res Function(_InvoiceLine) _then) = __$InvoiceLineCopyWithImpl;
@override @useResult
$Res call({
 int id, int? productId, int? orderLineId, String? productCode, String productName, String? satProductKey, String? unitKey, String? unitName, Decimal quantity, Decimal price, Decimal discountRate, Decimal taxRate, bool taxIncluded, String? comment
});




}
/// @nodoc
class __$InvoiceLineCopyWithImpl<$Res>
    implements _$InvoiceLineCopyWith<$Res> {
  __$InvoiceLineCopyWithImpl(this._self, this._then);

  final _InvoiceLine _self;
  final $Res Function(_InvoiceLine) _then;

/// Create a copy of InvoiceLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? productId = freezed,Object? orderLineId = freezed,Object? productCode = freezed,Object? productName = null,Object? satProductKey = freezed,Object? unitKey = freezed,Object? unitName = freezed,Object? quantity = null,Object? price = null,Object? discountRate = null,Object? taxRate = null,Object? taxIncluded = null,Object? comment = freezed,}) {
  return _then(_InvoiceLine(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int?,orderLineId: freezed == orderLineId ? _self.orderLineId : orderLineId // ignore: cast_nullable_to_non_nullable
as int?,productCode: freezed == productCode ? _self.productCode : productCode // ignore: cast_nullable_to_non_nullable
as String?,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,satProductKey: freezed == satProductKey ? _self.satProductKey : satProductKey // ignore: cast_nullable_to_non_nullable
as String?,unitKey: freezed == unitKey ? _self.unitKey : unitKey // ignore: cast_nullable_to_non_nullable
as String?,unitName: freezed == unitName ? _self.unitName : unitName // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Decimal,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as Decimal,discountRate: null == discountRate ? _self.discountRate : discountRate // ignore: cast_nullable_to_non_nullable
as Decimal,taxRate: null == taxRate ? _self.taxRate : taxRate // ignore: cast_nullable_to_non_nullable
as Decimal,taxIncluded: null == taxIncluded ? _self.taxIncluded : taxIncluded // ignore: cast_nullable_to_non_nullable
as bool,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$InvoiceRelation {

 int get id; int get documentId; InvoiceRelationType? get type; String? get stampUuid; String? get series; int? get serial;
/// Create a copy of InvoiceRelation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvoiceRelationCopyWith<InvoiceRelation> get copyWith => _$InvoiceRelationCopyWithImpl<InvoiceRelation>(this as InvoiceRelation, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as InvoiceRelation;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvoiceRelation&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.documentId, _this.documentId) || other.documentId == _this.documentId)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.stampUuid, _this.stampUuid) || other.stampUuid == _this.stampUuid)&&(identical(other.series, _this.series) || other.series == _this.series)&&(identical(other.serial, _this.serial) || other.serial == _this.serial));
}


@override
int get hashCode {
  final _this = this as InvoiceRelation;
  return Object.hash(runtimeType,_this.id,_this.documentId,_this.type,_this.stampUuid,_this.series,_this.serial);
}

@override
String toString() {
  final _this = this as InvoiceRelation;
  return 'InvoiceRelation(id: ${_this.id}, documentId: ${_this.documentId}, type: ${_this.type}, stampUuid: ${_this.stampUuid}, series: ${_this.series}, serial: ${_this.serial})';
}


}

/// @nodoc
abstract mixin class $InvoiceRelationCopyWith<$Res>  {
  factory $InvoiceRelationCopyWith(InvoiceRelation value, $Res Function(InvoiceRelation) _then) = _$InvoiceRelationCopyWithImpl;
@useResult
$Res call({
 int id, int documentId, InvoiceRelationType? type, String? stampUuid, String? series, int? serial
});




}
/// @nodoc
class _$InvoiceRelationCopyWithImpl<$Res>
    implements $InvoiceRelationCopyWith<$Res> {
  _$InvoiceRelationCopyWithImpl(this._self, this._then);

  final InvoiceRelation _self;
  final $Res Function(InvoiceRelation) _then;

/// Create a copy of InvoiceRelation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? documentId = null,Object? type = freezed,Object? stampUuid = freezed,Object? series = freezed,Object? serial = freezed,}) {
  return _then(InvoiceRelation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,documentId: null == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as int,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as InvoiceRelationType?,stampUuid: freezed == stampUuid ? _self.stampUuid : stampUuid // ignore: cast_nullable_to_non_nullable
as String?,series: freezed == series ? _self.series : series // ignore: cast_nullable_to_non_nullable
as String?,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [InvoiceRelation].
extension InvoiceRelationPatterns on InvoiceRelation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InvoiceRelation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InvoiceRelation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InvoiceRelation value)  $default,){
final _that = this;
switch (_that) {
case _InvoiceRelation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InvoiceRelation value)?  $default,){
final _that = this;
switch (_that) {
case _InvoiceRelation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int documentId,  InvoiceRelationType? type,  String? stampUuid,  String? series,  int? serial)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InvoiceRelation() when $default != null:
return $default(_that.id,_that.documentId,_that.type,_that.stampUuid,_that.series,_that.serial);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int documentId,  InvoiceRelationType? type,  String? stampUuid,  String? series,  int? serial)  $default,) {final _that = this;
switch (_that) {
case _InvoiceRelation():
return $default(_that.id,_that.documentId,_that.type,_that.stampUuid,_that.series,_that.serial);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int documentId,  InvoiceRelationType? type,  String? stampUuid,  String? series,  int? serial)?  $default,) {final _that = this;
switch (_that) {
case _InvoiceRelation() when $default != null:
return $default(_that.id,_that.documentId,_that.type,_that.stampUuid,_that.series,_that.serial);case _:
  return null;

}
}

}

/// @nodoc


class _InvoiceRelation implements InvoiceRelation {
  const _InvoiceRelation({required this.id, required this.documentId, this.type, this.stampUuid, this.series, this.serial});
  

@override final  int id;
@override final  int documentId;
@override final  InvoiceRelationType? type;
@override final  String? stampUuid;
@override final  String? series;
@override final  int? serial;

/// Create a copy of InvoiceRelation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvoiceRelationCopyWith<_InvoiceRelation> get copyWith => __$InvoiceRelationCopyWithImpl<_InvoiceRelation>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _InvoiceRelation&&(identical(other.id, id) || other.id == id)&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.type, type) || other.type == type)&&(identical(other.stampUuid, stampUuid) || other.stampUuid == stampUuid)&&(identical(other.series, series) || other.series == series)&&(identical(other.serial, serial) || other.serial == serial));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,documentId,type,stampUuid,series,serial);
}

@override
String toString() {
    return 'InvoiceRelation(id: $id, documentId: $documentId, type: $type, stampUuid: $stampUuid, series: $series, serial: $serial)';
}


}

/// @nodoc
abstract mixin class _$InvoiceRelationCopyWith<$Res> implements $InvoiceRelationCopyWith<$Res> {
  factory _$InvoiceRelationCopyWith(_InvoiceRelation value, $Res Function(_InvoiceRelation) _then) = __$InvoiceRelationCopyWithImpl;
@override @useResult
$Res call({
 int id, int documentId, InvoiceRelationType? type, String? stampUuid, String? series, int? serial
});




}
/// @nodoc
class __$InvoiceRelationCopyWithImpl<$Res>
    implements _$InvoiceRelationCopyWith<$Res> {
  __$InvoiceRelationCopyWithImpl(this._self, this._then);

  final _InvoiceRelation _self;
  final $Res Function(_InvoiceRelation) _then;

/// Create a copy of InvoiceRelation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? documentId = null,Object? type = freezed,Object? stampUuid = freezed,Object? series = freezed,Object? serial = freezed,}) {
  return _then(_InvoiceRelation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,documentId: null == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as int,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as InvoiceRelationType?,stampUuid: freezed == stampUuid ? _self.stampUuid : stampUuid // ignore: cast_nullable_to_non_nullable
as String?,series: freezed == series ? _self.series : series // ignore: cast_nullable_to_non_nullable
as String?,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$PaidInvoice {

/// The id the update and remove routes take.
 int get relationId; int get invoiceId; String? get series; int? get serial; String? get stampUuid; int get installment; Decimal get previousBalance; Decimal get amount; Decimal get remaining;
/// Create a copy of PaidInvoice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaidInvoiceCopyWith<PaidInvoice> get copyWith => _$PaidInvoiceCopyWithImpl<PaidInvoice>(this as PaidInvoice, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PaidInvoice;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaidInvoice&&(identical(other.relationId, _this.relationId) || other.relationId == _this.relationId)&&(identical(other.invoiceId, _this.invoiceId) || other.invoiceId == _this.invoiceId)&&(identical(other.series, _this.series) || other.series == _this.series)&&(identical(other.serial, _this.serial) || other.serial == _this.serial)&&(identical(other.stampUuid, _this.stampUuid) || other.stampUuid == _this.stampUuid)&&(identical(other.installment, _this.installment) || other.installment == _this.installment)&&(identical(other.previousBalance, _this.previousBalance) || other.previousBalance == _this.previousBalance)&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.remaining, _this.remaining) || other.remaining == _this.remaining));
}


@override
int get hashCode {
  final _this = this as PaidInvoice;
  return Object.hash(runtimeType,_this.relationId,_this.invoiceId,_this.series,_this.serial,_this.stampUuid,_this.installment,_this.previousBalance,_this.amount,_this.remaining);
}

@override
String toString() {
  final _this = this as PaidInvoice;
  return 'PaidInvoice(relationId: ${_this.relationId}, invoiceId: ${_this.invoiceId}, series: ${_this.series}, serial: ${_this.serial}, stampUuid: ${_this.stampUuid}, installment: ${_this.installment}, previousBalance: ${_this.previousBalance}, amount: ${_this.amount}, remaining: ${_this.remaining})';
}


}

/// @nodoc
abstract mixin class $PaidInvoiceCopyWith<$Res>  {
  factory $PaidInvoiceCopyWith(PaidInvoice value, $Res Function(PaidInvoice) _then) = _$PaidInvoiceCopyWithImpl;
@useResult
$Res call({
 int relationId, int invoiceId, String? series, int? serial, String? stampUuid, int installment, Decimal previousBalance, Decimal amount, Decimal remaining
});




}
/// @nodoc
class _$PaidInvoiceCopyWithImpl<$Res>
    implements $PaidInvoiceCopyWith<$Res> {
  _$PaidInvoiceCopyWithImpl(this._self, this._then);

  final PaidInvoice _self;
  final $Res Function(PaidInvoice) _then;

/// Create a copy of PaidInvoice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? relationId = null,Object? invoiceId = null,Object? series = freezed,Object? serial = freezed,Object? stampUuid = freezed,Object? installment = null,Object? previousBalance = null,Object? amount = null,Object? remaining = null,}) {
  return _then(PaidInvoice(
relationId: null == relationId ? _self.relationId : relationId // ignore: cast_nullable_to_non_nullable
as int,invoiceId: null == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as int,series: freezed == series ? _self.series : series // ignore: cast_nullable_to_non_nullable
as String?,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as int?,stampUuid: freezed == stampUuid ? _self.stampUuid : stampUuid // ignore: cast_nullable_to_non_nullable
as String?,installment: null == installment ? _self.installment : installment // ignore: cast_nullable_to_non_nullable
as int,previousBalance: null == previousBalance ? _self.previousBalance : previousBalance // ignore: cast_nullable_to_non_nullable
as Decimal,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as Decimal,remaining: null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}

}


/// Adds pattern-matching-related methods to [PaidInvoice].
extension PaidInvoicePatterns on PaidInvoice {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaidInvoice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaidInvoice() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaidInvoice value)  $default,){
final _that = this;
switch (_that) {
case _PaidInvoice():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaidInvoice value)?  $default,){
final _that = this;
switch (_that) {
case _PaidInvoice() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int relationId,  int invoiceId,  String? series,  int? serial,  String? stampUuid,  int installment,  Decimal previousBalance,  Decimal amount,  Decimal remaining)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaidInvoice() when $default != null:
return $default(_that.relationId,_that.invoiceId,_that.series,_that.serial,_that.stampUuid,_that.installment,_that.previousBalance,_that.amount,_that.remaining);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int relationId,  int invoiceId,  String? series,  int? serial,  String? stampUuid,  int installment,  Decimal previousBalance,  Decimal amount,  Decimal remaining)  $default,) {final _that = this;
switch (_that) {
case _PaidInvoice():
return $default(_that.relationId,_that.invoiceId,_that.series,_that.serial,_that.stampUuid,_that.installment,_that.previousBalance,_that.amount,_that.remaining);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int relationId,  int invoiceId,  String? series,  int? serial,  String? stampUuid,  int installment,  Decimal previousBalance,  Decimal amount,  Decimal remaining)?  $default,) {final _that = this;
switch (_that) {
case _PaidInvoice() when $default != null:
return $default(_that.relationId,_that.invoiceId,_that.series,_that.serial,_that.stampUuid,_that.installment,_that.previousBalance,_that.amount,_that.remaining);case _:
  return null;

}
}

}

/// @nodoc


class _PaidInvoice extends PaidInvoice {
  const _PaidInvoice({required this.relationId, required this.invoiceId, this.series, this.serial, this.stampUuid, required this.installment, required this.previousBalance, required this.amount, required this.remaining}): super._();
  

/// The id the update and remove routes take.
@override final  int relationId;
@override final  int invoiceId;
@override final  String? series;
@override final  int? serial;
@override final  String? stampUuid;
@override final  int installment;
@override final  Decimal previousBalance;
@override final  Decimal amount;
@override final  Decimal remaining;

/// Create a copy of PaidInvoice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaidInvoiceCopyWith<_PaidInvoice> get copyWith => __$PaidInvoiceCopyWithImpl<_PaidInvoice>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaidInvoice&&(identical(other.relationId, relationId) || other.relationId == relationId)&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.series, series) || other.series == series)&&(identical(other.serial, serial) || other.serial == serial)&&(identical(other.stampUuid, stampUuid) || other.stampUuid == stampUuid)&&(identical(other.installment, installment) || other.installment == installment)&&(identical(other.previousBalance, previousBalance) || other.previousBalance == previousBalance)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.remaining, remaining) || other.remaining == remaining));
}


@override
int get hashCode {
    return Object.hash(runtimeType,relationId,invoiceId,series,serial,stampUuid,installment,previousBalance,amount,remaining);
}

@override
String toString() {
    return 'PaidInvoice(relationId: $relationId, invoiceId: $invoiceId, series: $series, serial: $serial, stampUuid: $stampUuid, installment: $installment, previousBalance: $previousBalance, amount: $amount, remaining: $remaining)';
}


}

/// @nodoc
abstract mixin class _$PaidInvoiceCopyWith<$Res> implements $PaidInvoiceCopyWith<$Res> {
  factory _$PaidInvoiceCopyWith(_PaidInvoice value, $Res Function(_PaidInvoice) _then) = __$PaidInvoiceCopyWithImpl;
@override @useResult
$Res call({
 int relationId, int invoiceId, String? series, int? serial, String? stampUuid, int installment, Decimal previousBalance, Decimal amount, Decimal remaining
});




}
/// @nodoc
class __$PaidInvoiceCopyWithImpl<$Res>
    implements _$PaidInvoiceCopyWith<$Res> {
  __$PaidInvoiceCopyWithImpl(this._self, this._then);

  final _PaidInvoice _self;
  final $Res Function(_PaidInvoice) _then;

/// Create a copy of PaidInvoice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? relationId = null,Object? invoiceId = null,Object? series = freezed,Object? serial = freezed,Object? stampUuid = freezed,Object? installment = null,Object? previousBalance = null,Object? amount = null,Object? remaining = null,}) {
  return _then(_PaidInvoice(
relationId: null == relationId ? _self.relationId : relationId // ignore: cast_nullable_to_non_nullable
as int,invoiceId: null == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as int,series: freezed == series ? _self.series : series // ignore: cast_nullable_to_non_nullable
as String?,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as int?,stampUuid: freezed == stampUuid ? _self.stampUuid : stampUuid // ignore: cast_nullable_to_non_nullable
as String?,installment: null == installment ? _self.installment : installment // ignore: cast_nullable_to_non_nullable
as int,previousBalance: null == previousBalance ? _self.previousBalance : previousBalance // ignore: cast_nullable_to_non_nullable
as Decimal,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as Decimal,remaining: null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}


}

/// @nodoc
mixin _$FiscalDocument {

 FiscalDocumentSummary get summary; String? get issuerRegime; String? get issuerRegimeName; int? get customerId; int? get facilityId; String get issuedLocation; String? get taxpayerRegime; String? get taxpayerPostalCode; String? get usage; InvoicePaymentTerms get paymentTerms; int get paymentForm; int get currencyCode; Decimal get exchangeRate; String? get reference; String? get comment; DateTime? get stamped; DateTime? get cancellationDate; String? get cancellationReason;/// The PAC's stamp; `null` before stamping. Legacy-stamped documents have
/// one too.
 FiscalStamp? get stamp;/// When the pending stamp was sent, while the document is stamping.
 DateTime? get stampingSince;/// UUID of the document that replaced this one (cancellation reason 01).
 String? get cancellationSubstitution;/// Every cancellation request, newest first as the server sends them.
 List<FiscalCancellation> get cancellations; List<InvoiceLine> get lines; List<InvoiceRelation> get relations;/// A payment receipt's payment (spec 074): `null` on other types, and on a
/// fresh by-hand receipt until the header is filled.
 DateTime? get paymentDate; Decimal? get paymentAmount; String? get paymentReference;/// The customer payment the receipt came from, when it did.
 int? get customerPaymentId;/// The invoices a receipt pays; empty for any other type.
 List<PaidInvoice> get paidInvoices;
/// Create a copy of FiscalDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FiscalDocumentCopyWith<FiscalDocument> get copyWith => _$FiscalDocumentCopyWithImpl<FiscalDocument>(this as FiscalDocument, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FiscalDocument;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FiscalDocument&&(identical(other.summary, _this.summary) || other.summary == _this.summary)&&(identical(other.issuerRegime, _this.issuerRegime) || other.issuerRegime == _this.issuerRegime)&&(identical(other.issuerRegimeName, _this.issuerRegimeName) || other.issuerRegimeName == _this.issuerRegimeName)&&(identical(other.customerId, _this.customerId) || other.customerId == _this.customerId)&&(identical(other.facilityId, _this.facilityId) || other.facilityId == _this.facilityId)&&(identical(other.issuedLocation, _this.issuedLocation) || other.issuedLocation == _this.issuedLocation)&&(identical(other.taxpayerRegime, _this.taxpayerRegime) || other.taxpayerRegime == _this.taxpayerRegime)&&(identical(other.taxpayerPostalCode, _this.taxpayerPostalCode) || other.taxpayerPostalCode == _this.taxpayerPostalCode)&&(identical(other.usage, _this.usage) || other.usage == _this.usage)&&(identical(other.paymentTerms, _this.paymentTerms) || other.paymentTerms == _this.paymentTerms)&&(identical(other.paymentForm, _this.paymentForm) || other.paymentForm == _this.paymentForm)&&(identical(other.currencyCode, _this.currencyCode) || other.currencyCode == _this.currencyCode)&&(identical(other.exchangeRate, _this.exchangeRate) || other.exchangeRate == _this.exchangeRate)&&(identical(other.reference, _this.reference) || other.reference == _this.reference)&&(identical(other.comment, _this.comment) || other.comment == _this.comment)&&(identical(other.stamped, _this.stamped) || other.stamped == _this.stamped)&&(identical(other.cancellationDate, _this.cancellationDate) || other.cancellationDate == _this.cancellationDate)&&(identical(other.cancellationReason, _this.cancellationReason) || other.cancellationReason == _this.cancellationReason)&&(identical(other.stamp, _this.stamp) || other.stamp == _this.stamp)&&(identical(other.stampingSince, _this.stampingSince) || other.stampingSince == _this.stampingSince)&&(identical(other.cancellationSubstitution, _this.cancellationSubstitution) || other.cancellationSubstitution == _this.cancellationSubstitution)&&const DeepCollectionEquality().equals(other.cancellations, _this.cancellations)&&const DeepCollectionEquality().equals(other.lines, _this.lines)&&const DeepCollectionEquality().equals(other.relations, _this.relations)&&(identical(other.paymentDate, _this.paymentDate) || other.paymentDate == _this.paymentDate)&&(identical(other.paymentAmount, _this.paymentAmount) || other.paymentAmount == _this.paymentAmount)&&(identical(other.paymentReference, _this.paymentReference) || other.paymentReference == _this.paymentReference)&&(identical(other.customerPaymentId, _this.customerPaymentId) || other.customerPaymentId == _this.customerPaymentId)&&const DeepCollectionEquality().equals(other.paidInvoices, _this.paidInvoices));
}


@override
int get hashCode {
  final _this = this as FiscalDocument;
  return Object.hashAll([runtimeType,_this.summary,_this.issuerRegime,_this.issuerRegimeName,_this.customerId,_this.facilityId,_this.issuedLocation,_this.taxpayerRegime,_this.taxpayerPostalCode,_this.usage,_this.paymentTerms,_this.paymentForm,_this.currencyCode,_this.exchangeRate,_this.reference,_this.comment,_this.stamped,_this.cancellationDate,_this.cancellationReason,_this.stamp,_this.stampingSince,_this.cancellationSubstitution,const DeepCollectionEquality().hash(_this.cancellations),const DeepCollectionEquality().hash(_this.lines),const DeepCollectionEquality().hash(_this.relations),_this.paymentDate,_this.paymentAmount,_this.paymentReference,_this.customerPaymentId,const DeepCollectionEquality().hash(_this.paidInvoices)]);
}

@override
String toString() {
  final _this = this as FiscalDocument;
  return 'FiscalDocument(summary: ${_this.summary}, issuerRegime: ${_this.issuerRegime}, issuerRegimeName: ${_this.issuerRegimeName}, customerId: ${_this.customerId}, facilityId: ${_this.facilityId}, issuedLocation: ${_this.issuedLocation}, taxpayerRegime: ${_this.taxpayerRegime}, taxpayerPostalCode: ${_this.taxpayerPostalCode}, usage: ${_this.usage}, paymentTerms: ${_this.paymentTerms}, paymentForm: ${_this.paymentForm}, currencyCode: ${_this.currencyCode}, exchangeRate: ${_this.exchangeRate}, reference: ${_this.reference}, comment: ${_this.comment}, stamped: ${_this.stamped}, cancellationDate: ${_this.cancellationDate}, cancellationReason: ${_this.cancellationReason}, stamp: ${_this.stamp}, stampingSince: ${_this.stampingSince}, cancellationSubstitution: ${_this.cancellationSubstitution}, cancellations: ${_this.cancellations}, lines: ${_this.lines}, relations: ${_this.relations}, paymentDate: ${_this.paymentDate}, paymentAmount: ${_this.paymentAmount}, paymentReference: ${_this.paymentReference}, customerPaymentId: ${_this.customerPaymentId}, paidInvoices: ${_this.paidInvoices})';
}


}

/// @nodoc
abstract mixin class $FiscalDocumentCopyWith<$Res>  {
  factory $FiscalDocumentCopyWith(FiscalDocument value, $Res Function(FiscalDocument) _then) = _$FiscalDocumentCopyWithImpl;
@useResult
$Res call({
 FiscalDocumentSummary summary, String? issuerRegime, String? issuerRegimeName, int? customerId, int? facilityId, String issuedLocation, String? taxpayerRegime, String? taxpayerPostalCode, String? usage, InvoicePaymentTerms paymentTerms, int paymentForm, int currencyCode, Decimal exchangeRate, String? reference, String? comment, DateTime? stamped, DateTime? cancellationDate, String? cancellationReason, FiscalStamp? stamp, DateTime? stampingSince, String? cancellationSubstitution, List<FiscalCancellation> cancellations, List<InvoiceLine> lines, List<InvoiceRelation> relations, DateTime? paymentDate, Decimal? paymentAmount, String? paymentReference, int? customerPaymentId, List<PaidInvoice> paidInvoices
});


$FiscalDocumentSummaryCopyWith<$Res> get summary;$FiscalStampCopyWith<$Res>? get stamp;

}
/// @nodoc
class _$FiscalDocumentCopyWithImpl<$Res>
    implements $FiscalDocumentCopyWith<$Res> {
  _$FiscalDocumentCopyWithImpl(this._self, this._then);

  final FiscalDocument _self;
  final $Res Function(FiscalDocument) _then;

/// Create a copy of FiscalDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? summary = null,Object? issuerRegime = freezed,Object? issuerRegimeName = freezed,Object? customerId = freezed,Object? facilityId = freezed,Object? issuedLocation = null,Object? taxpayerRegime = freezed,Object? taxpayerPostalCode = freezed,Object? usage = freezed,Object? paymentTerms = null,Object? paymentForm = null,Object? currencyCode = null,Object? exchangeRate = null,Object? reference = freezed,Object? comment = freezed,Object? stamped = freezed,Object? cancellationDate = freezed,Object? cancellationReason = freezed,Object? stamp = freezed,Object? stampingSince = freezed,Object? cancellationSubstitution = freezed,Object? cancellations = null,Object? lines = null,Object? relations = null,Object? paymentDate = freezed,Object? paymentAmount = freezed,Object? paymentReference = freezed,Object? customerPaymentId = freezed,Object? paidInvoices = null,}) {
  return _then(FiscalDocument(
summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as FiscalDocumentSummary,issuerRegime: freezed == issuerRegime ? _self.issuerRegime : issuerRegime // ignore: cast_nullable_to_non_nullable
as String?,issuerRegimeName: freezed == issuerRegimeName ? _self.issuerRegimeName : issuerRegimeName // ignore: cast_nullable_to_non_nullable
as String?,customerId: freezed == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as int?,facilityId: freezed == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int?,issuedLocation: null == issuedLocation ? _self.issuedLocation : issuedLocation // ignore: cast_nullable_to_non_nullable
as String,taxpayerRegime: freezed == taxpayerRegime ? _self.taxpayerRegime : taxpayerRegime // ignore: cast_nullable_to_non_nullable
as String?,taxpayerPostalCode: freezed == taxpayerPostalCode ? _self.taxpayerPostalCode : taxpayerPostalCode // ignore: cast_nullable_to_non_nullable
as String?,usage: freezed == usage ? _self.usage : usage // ignore: cast_nullable_to_non_nullable
as String?,paymentTerms: null == paymentTerms ? _self.paymentTerms : paymentTerms // ignore: cast_nullable_to_non_nullable
as InvoicePaymentTerms,paymentForm: null == paymentForm ? _self.paymentForm : paymentForm // ignore: cast_nullable_to_non_nullable
as int,currencyCode: null == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as int,exchangeRate: null == exchangeRate ? _self.exchangeRate : exchangeRate // ignore: cast_nullable_to_non_nullable
as Decimal,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,stamped: freezed == stamped ? _self.stamped : stamped // ignore: cast_nullable_to_non_nullable
as DateTime?,cancellationDate: freezed == cancellationDate ? _self.cancellationDate : cancellationDate // ignore: cast_nullable_to_non_nullable
as DateTime?,cancellationReason: freezed == cancellationReason ? _self.cancellationReason : cancellationReason // ignore: cast_nullable_to_non_nullable
as String?,stamp: freezed == stamp ? _self.stamp : stamp // ignore: cast_nullable_to_non_nullable
as FiscalStamp?,stampingSince: freezed == stampingSince ? _self.stampingSince : stampingSince // ignore: cast_nullable_to_non_nullable
as DateTime?,cancellationSubstitution: freezed == cancellationSubstitution ? _self.cancellationSubstitution : cancellationSubstitution // ignore: cast_nullable_to_non_nullable
as String?,cancellations: null == cancellations ? _self.cancellations : cancellations // ignore: cast_nullable_to_non_nullable
as List<FiscalCancellation>,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<InvoiceLine>,relations: null == relations ? _self.relations : relations // ignore: cast_nullable_to_non_nullable
as List<InvoiceRelation>,paymentDate: freezed == paymentDate ? _self.paymentDate : paymentDate // ignore: cast_nullable_to_non_nullable
as DateTime?,paymentAmount: freezed == paymentAmount ? _self.paymentAmount : paymentAmount // ignore: cast_nullable_to_non_nullable
as Decimal?,paymentReference: freezed == paymentReference ? _self.paymentReference : paymentReference // ignore: cast_nullable_to_non_nullable
as String?,customerPaymentId: freezed == customerPaymentId ? _self.customerPaymentId : customerPaymentId // ignore: cast_nullable_to_non_nullable
as int?,paidInvoices: null == paidInvoices ? _self.paidInvoices : paidInvoices // ignore: cast_nullable_to_non_nullable
as List<PaidInvoice>,
  ));
}
/// Create a copy of FiscalDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FiscalDocumentSummaryCopyWith<$Res> get summary {
  
  return $FiscalDocumentSummaryCopyWith<$Res>(_self.summary, (value) {
    return _then(_self.copyWith(summary: value));
  });
}/// Create a copy of FiscalDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FiscalStampCopyWith<$Res>? get stamp {
    if (_self.stamp == null) {
    return null;
  }

  return $FiscalStampCopyWith<$Res>(_self.stamp!, (value) {
    return _then(_self.copyWith(stamp: value));
  });
}
}


/// Adds pattern-matching-related methods to [FiscalDocument].
extension FiscalDocumentPatterns on FiscalDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FiscalDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FiscalDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FiscalDocument value)  $default,){
final _that = this;
switch (_that) {
case _FiscalDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FiscalDocument value)?  $default,){
final _that = this;
switch (_that) {
case _FiscalDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FiscalDocumentSummary summary,  String? issuerRegime,  String? issuerRegimeName,  int? customerId,  int? facilityId,  String issuedLocation,  String? taxpayerRegime,  String? taxpayerPostalCode,  String? usage,  InvoicePaymentTerms paymentTerms,  int paymentForm,  int currencyCode,  Decimal exchangeRate,  String? reference,  String? comment,  DateTime? stamped,  DateTime? cancellationDate,  String? cancellationReason,  FiscalStamp? stamp,  DateTime? stampingSince,  String? cancellationSubstitution,  List<FiscalCancellation> cancellations,  List<InvoiceLine> lines,  List<InvoiceRelation> relations,  DateTime? paymentDate,  Decimal? paymentAmount,  String? paymentReference,  int? customerPaymentId,  List<PaidInvoice> paidInvoices)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FiscalDocument() when $default != null:
return $default(_that.summary,_that.issuerRegime,_that.issuerRegimeName,_that.customerId,_that.facilityId,_that.issuedLocation,_that.taxpayerRegime,_that.taxpayerPostalCode,_that.usage,_that.paymentTerms,_that.paymentForm,_that.currencyCode,_that.exchangeRate,_that.reference,_that.comment,_that.stamped,_that.cancellationDate,_that.cancellationReason,_that.stamp,_that.stampingSince,_that.cancellationSubstitution,_that.cancellations,_that.lines,_that.relations,_that.paymentDate,_that.paymentAmount,_that.paymentReference,_that.customerPaymentId,_that.paidInvoices);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FiscalDocumentSummary summary,  String? issuerRegime,  String? issuerRegimeName,  int? customerId,  int? facilityId,  String issuedLocation,  String? taxpayerRegime,  String? taxpayerPostalCode,  String? usage,  InvoicePaymentTerms paymentTerms,  int paymentForm,  int currencyCode,  Decimal exchangeRate,  String? reference,  String? comment,  DateTime? stamped,  DateTime? cancellationDate,  String? cancellationReason,  FiscalStamp? stamp,  DateTime? stampingSince,  String? cancellationSubstitution,  List<FiscalCancellation> cancellations,  List<InvoiceLine> lines,  List<InvoiceRelation> relations,  DateTime? paymentDate,  Decimal? paymentAmount,  String? paymentReference,  int? customerPaymentId,  List<PaidInvoice> paidInvoices)  $default,) {final _that = this;
switch (_that) {
case _FiscalDocument():
return $default(_that.summary,_that.issuerRegime,_that.issuerRegimeName,_that.customerId,_that.facilityId,_that.issuedLocation,_that.taxpayerRegime,_that.taxpayerPostalCode,_that.usage,_that.paymentTerms,_that.paymentForm,_that.currencyCode,_that.exchangeRate,_that.reference,_that.comment,_that.stamped,_that.cancellationDate,_that.cancellationReason,_that.stamp,_that.stampingSince,_that.cancellationSubstitution,_that.cancellations,_that.lines,_that.relations,_that.paymentDate,_that.paymentAmount,_that.paymentReference,_that.customerPaymentId,_that.paidInvoices);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FiscalDocumentSummary summary,  String? issuerRegime,  String? issuerRegimeName,  int? customerId,  int? facilityId,  String issuedLocation,  String? taxpayerRegime,  String? taxpayerPostalCode,  String? usage,  InvoicePaymentTerms paymentTerms,  int paymentForm,  int currencyCode,  Decimal exchangeRate,  String? reference,  String? comment,  DateTime? stamped,  DateTime? cancellationDate,  String? cancellationReason,  FiscalStamp? stamp,  DateTime? stampingSince,  String? cancellationSubstitution,  List<FiscalCancellation> cancellations,  List<InvoiceLine> lines,  List<InvoiceRelation> relations,  DateTime? paymentDate,  Decimal? paymentAmount,  String? paymentReference,  int? customerPaymentId,  List<PaidInvoice> paidInvoices)?  $default,) {final _that = this;
switch (_that) {
case _FiscalDocument() when $default != null:
return $default(_that.summary,_that.issuerRegime,_that.issuerRegimeName,_that.customerId,_that.facilityId,_that.issuedLocation,_that.taxpayerRegime,_that.taxpayerPostalCode,_that.usage,_that.paymentTerms,_that.paymentForm,_that.currencyCode,_that.exchangeRate,_that.reference,_that.comment,_that.stamped,_that.cancellationDate,_that.cancellationReason,_that.stamp,_that.stampingSince,_that.cancellationSubstitution,_that.cancellations,_that.lines,_that.relations,_that.paymentDate,_that.paymentAmount,_that.paymentReference,_that.customerPaymentId,_that.paidInvoices);case _:
  return null;

}
}

}

/// @nodoc


class _FiscalDocument extends FiscalDocument {
  const _FiscalDocument({required this.summary, this.issuerRegime, this.issuerRegimeName, this.customerId, this.facilityId, required this.issuedLocation, this.taxpayerRegime, this.taxpayerPostalCode, this.usage, required this.paymentTerms, required this.paymentForm, required this.currencyCode, required this.exchangeRate, this.reference, this.comment, this.stamped, this.cancellationDate, this.cancellationReason, this.stamp, this.stampingSince, this.cancellationSubstitution,  List<FiscalCancellation> cancellations = const <FiscalCancellation>[],  List<InvoiceLine> lines = const <InvoiceLine>[],  List<InvoiceRelation> relations = const <InvoiceRelation>[], this.paymentDate, this.paymentAmount, this.paymentReference, this.customerPaymentId,  List<PaidInvoice> paidInvoices = const <PaidInvoice>[]}): _cancellations = cancellations,_lines = lines,_relations = relations,_paidInvoices = paidInvoices,super._();
  

@override final  FiscalDocumentSummary summary;
@override final  String? issuerRegime;
@override final  String? issuerRegimeName;
@override final  int? customerId;
@override final  int? facilityId;
@override final  String issuedLocation;
@override final  String? taxpayerRegime;
@override final  String? taxpayerPostalCode;
@override final  String? usage;
@override final  InvoicePaymentTerms paymentTerms;
@override final  int paymentForm;
@override final  int currencyCode;
@override final  Decimal exchangeRate;
@override final  String? reference;
@override final  String? comment;
@override final  DateTime? stamped;
@override final  DateTime? cancellationDate;
@override final  String? cancellationReason;
/// The PAC's stamp; `null` before stamping. Legacy-stamped documents have
/// one too.
@override final  FiscalStamp? stamp;
/// When the pending stamp was sent, while the document is stamping.
@override final  DateTime? stampingSince;
/// UUID of the document that replaced this one (cancellation reason 01).
@override final  String? cancellationSubstitution;
/// Every cancellation request, newest first as the server sends them.
 final  List<FiscalCancellation> _cancellations;
/// Every cancellation request, newest first as the server sends them.
@override@JsonKey() List<FiscalCancellation> get cancellations {
  if (_cancellations is EqualUnmodifiableListView) return _cancellations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cancellations);
}

 final  List<InvoiceLine> _lines;
@override@JsonKey() List<InvoiceLine> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}

 final  List<InvoiceRelation> _relations;
@override@JsonKey() List<InvoiceRelation> get relations {
  if (_relations is EqualUnmodifiableListView) return _relations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_relations);
}

/// A payment receipt's payment (spec 074): `null` on other types, and on a
/// fresh by-hand receipt until the header is filled.
@override final  DateTime? paymentDate;
@override final  Decimal? paymentAmount;
@override final  String? paymentReference;
/// The customer payment the receipt came from, when it did.
@override final  int? customerPaymentId;
/// The invoices a receipt pays; empty for any other type.
 final  List<PaidInvoice> _paidInvoices;
/// The invoices a receipt pays; empty for any other type.
@override@JsonKey() List<PaidInvoice> get paidInvoices {
  if (_paidInvoices is EqualUnmodifiableListView) return _paidInvoices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_paidInvoices);
}


/// Create a copy of FiscalDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FiscalDocumentCopyWith<_FiscalDocument> get copyWith => __$FiscalDocumentCopyWithImpl<_FiscalDocument>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FiscalDocument&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.issuerRegime, issuerRegime) || other.issuerRegime == issuerRegime)&&(identical(other.issuerRegimeName, issuerRegimeName) || other.issuerRegimeName == issuerRegimeName)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.facilityId, facilityId) || other.facilityId == facilityId)&&(identical(other.issuedLocation, issuedLocation) || other.issuedLocation == issuedLocation)&&(identical(other.taxpayerRegime, taxpayerRegime) || other.taxpayerRegime == taxpayerRegime)&&(identical(other.taxpayerPostalCode, taxpayerPostalCode) || other.taxpayerPostalCode == taxpayerPostalCode)&&(identical(other.usage, usage) || other.usage == usage)&&(identical(other.paymentTerms, paymentTerms) || other.paymentTerms == paymentTerms)&&(identical(other.paymentForm, paymentForm) || other.paymentForm == paymentForm)&&(identical(other.currencyCode, currencyCode) || other.currencyCode == currencyCode)&&(identical(other.exchangeRate, exchangeRate) || other.exchangeRate == exchangeRate)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.stamped, stamped) || other.stamped == stamped)&&(identical(other.cancellationDate, cancellationDate) || other.cancellationDate == cancellationDate)&&(identical(other.cancellationReason, cancellationReason) || other.cancellationReason == cancellationReason)&&(identical(other.stamp, stamp) || other.stamp == stamp)&&(identical(other.stampingSince, stampingSince) || other.stampingSince == stampingSince)&&(identical(other.cancellationSubstitution, cancellationSubstitution) || other.cancellationSubstitution == cancellationSubstitution)&&const DeepCollectionEquality().equals(other.cancellations, _cancellations)&&const DeepCollectionEquality().equals(other.lines, _lines)&&const DeepCollectionEquality().equals(other.relations, _relations)&&(identical(other.paymentDate, paymentDate) || other.paymentDate == paymentDate)&&(identical(other.paymentAmount, paymentAmount) || other.paymentAmount == paymentAmount)&&(identical(other.paymentReference, paymentReference) || other.paymentReference == paymentReference)&&(identical(other.customerPaymentId, customerPaymentId) || other.customerPaymentId == customerPaymentId)&&const DeepCollectionEquality().equals(other.paidInvoices, _paidInvoices));
}


@override
int get hashCode {
    return Object.hashAll([runtimeType,summary,issuerRegime,issuerRegimeName,customerId,facilityId,issuedLocation,taxpayerRegime,taxpayerPostalCode,usage,paymentTerms,paymentForm,currencyCode,exchangeRate,reference,comment,stamped,cancellationDate,cancellationReason,stamp,stampingSince,cancellationSubstitution,const DeepCollectionEquality().hash(_cancellations),const DeepCollectionEquality().hash(_lines),const DeepCollectionEquality().hash(_relations),paymentDate,paymentAmount,paymentReference,customerPaymentId,const DeepCollectionEquality().hash(_paidInvoices)]);
}

@override
String toString() {
    return 'FiscalDocument(summary: $summary, issuerRegime: $issuerRegime, issuerRegimeName: $issuerRegimeName, customerId: $customerId, facilityId: $facilityId, issuedLocation: $issuedLocation, taxpayerRegime: $taxpayerRegime, taxpayerPostalCode: $taxpayerPostalCode, usage: $usage, paymentTerms: $paymentTerms, paymentForm: $paymentForm, currencyCode: $currencyCode, exchangeRate: $exchangeRate, reference: $reference, comment: $comment, stamped: $stamped, cancellationDate: $cancellationDate, cancellationReason: $cancellationReason, stamp: $stamp, stampingSince: $stampingSince, cancellationSubstitution: $cancellationSubstitution, cancellations: $cancellations, lines: $lines, relations: $relations, paymentDate: $paymentDate, paymentAmount: $paymentAmount, paymentReference: $paymentReference, customerPaymentId: $customerPaymentId, paidInvoices: $paidInvoices)';
}


}

/// @nodoc
abstract mixin class _$FiscalDocumentCopyWith<$Res> implements $FiscalDocumentCopyWith<$Res> {
  factory _$FiscalDocumentCopyWith(_FiscalDocument value, $Res Function(_FiscalDocument) _then) = __$FiscalDocumentCopyWithImpl;
@override @useResult
$Res call({
 FiscalDocumentSummary summary, String? issuerRegime, String? issuerRegimeName, int? customerId, int? facilityId, String issuedLocation, String? taxpayerRegime, String? taxpayerPostalCode, String? usage, InvoicePaymentTerms paymentTerms, int paymentForm, int currencyCode, Decimal exchangeRate, String? reference, String? comment, DateTime? stamped, DateTime? cancellationDate, String? cancellationReason, FiscalStamp? stamp, DateTime? stampingSince, String? cancellationSubstitution, List<FiscalCancellation> cancellations, List<InvoiceLine> lines, List<InvoiceRelation> relations, DateTime? paymentDate, Decimal? paymentAmount, String? paymentReference, int? customerPaymentId, List<PaidInvoice> paidInvoices
});


@override $FiscalDocumentSummaryCopyWith<$Res> get summary;@override $FiscalStampCopyWith<$Res>? get stamp;

}
/// @nodoc
class __$FiscalDocumentCopyWithImpl<$Res>
    implements _$FiscalDocumentCopyWith<$Res> {
  __$FiscalDocumentCopyWithImpl(this._self, this._then);

  final _FiscalDocument _self;
  final $Res Function(_FiscalDocument) _then;

/// Create a copy of FiscalDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? summary = null,Object? issuerRegime = freezed,Object? issuerRegimeName = freezed,Object? customerId = freezed,Object? facilityId = freezed,Object? issuedLocation = null,Object? taxpayerRegime = freezed,Object? taxpayerPostalCode = freezed,Object? usage = freezed,Object? paymentTerms = null,Object? paymentForm = null,Object? currencyCode = null,Object? exchangeRate = null,Object? reference = freezed,Object? comment = freezed,Object? stamped = freezed,Object? cancellationDate = freezed,Object? cancellationReason = freezed,Object? stamp = freezed,Object? stampingSince = freezed,Object? cancellationSubstitution = freezed,Object? cancellations = null,Object? lines = null,Object? relations = null,Object? paymentDate = freezed,Object? paymentAmount = freezed,Object? paymentReference = freezed,Object? customerPaymentId = freezed,Object? paidInvoices = null,}) {
  return _then(_FiscalDocument(
summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as FiscalDocumentSummary,issuerRegime: freezed == issuerRegime ? _self.issuerRegime : issuerRegime // ignore: cast_nullable_to_non_nullable
as String?,issuerRegimeName: freezed == issuerRegimeName ? _self.issuerRegimeName : issuerRegimeName // ignore: cast_nullable_to_non_nullable
as String?,customerId: freezed == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as int?,facilityId: freezed == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int?,issuedLocation: null == issuedLocation ? _self.issuedLocation : issuedLocation // ignore: cast_nullable_to_non_nullable
as String,taxpayerRegime: freezed == taxpayerRegime ? _self.taxpayerRegime : taxpayerRegime // ignore: cast_nullable_to_non_nullable
as String?,taxpayerPostalCode: freezed == taxpayerPostalCode ? _self.taxpayerPostalCode : taxpayerPostalCode // ignore: cast_nullable_to_non_nullable
as String?,usage: freezed == usage ? _self.usage : usage // ignore: cast_nullable_to_non_nullable
as String?,paymentTerms: null == paymentTerms ? _self.paymentTerms : paymentTerms // ignore: cast_nullable_to_non_nullable
as InvoicePaymentTerms,paymentForm: null == paymentForm ? _self.paymentForm : paymentForm // ignore: cast_nullable_to_non_nullable
as int,currencyCode: null == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as int,exchangeRate: null == exchangeRate ? _self.exchangeRate : exchangeRate // ignore: cast_nullable_to_non_nullable
as Decimal,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,stamped: freezed == stamped ? _self.stamped : stamped // ignore: cast_nullable_to_non_nullable
as DateTime?,cancellationDate: freezed == cancellationDate ? _self.cancellationDate : cancellationDate // ignore: cast_nullable_to_non_nullable
as DateTime?,cancellationReason: freezed == cancellationReason ? _self.cancellationReason : cancellationReason // ignore: cast_nullable_to_non_nullable
as String?,stamp: freezed == stamp ? _self.stamp : stamp // ignore: cast_nullable_to_non_nullable
as FiscalStamp?,stampingSince: freezed == stampingSince ? _self.stampingSince : stampingSince // ignore: cast_nullable_to_non_nullable
as DateTime?,cancellationSubstitution: freezed == cancellationSubstitution ? _self.cancellationSubstitution : cancellationSubstitution // ignore: cast_nullable_to_non_nullable
as String?,cancellations: null == cancellations ? _self._cancellations : cancellations // ignore: cast_nullable_to_non_nullable
as List<FiscalCancellation>,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<InvoiceLine>,relations: null == relations ? _self._relations : relations // ignore: cast_nullable_to_non_nullable
as List<InvoiceRelation>,paymentDate: freezed == paymentDate ? _self.paymentDate : paymentDate // ignore: cast_nullable_to_non_nullable
as DateTime?,paymentAmount: freezed == paymentAmount ? _self.paymentAmount : paymentAmount // ignore: cast_nullable_to_non_nullable
as Decimal?,paymentReference: freezed == paymentReference ? _self.paymentReference : paymentReference // ignore: cast_nullable_to_non_nullable
as String?,customerPaymentId: freezed == customerPaymentId ? _self.customerPaymentId : customerPaymentId // ignore: cast_nullable_to_non_nullable
as int?,paidInvoices: null == paidInvoices ? _self._paidInvoices : paidInvoices // ignore: cast_nullable_to_non_nullable
as List<PaidInvoice>,
  ));
}

/// Create a copy of FiscalDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FiscalDocumentSummaryCopyWith<$Res> get summary {
  
  return $FiscalDocumentSummaryCopyWith<$Res>(_self.summary, (value) {
    return _then(_self.copyWith(summary: value));
  });
}/// Create a copy of FiscalDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FiscalStampCopyWith<$Res>? get stamp {
    if (_self.stamp == null) {
    return null;
  }

  return $FiscalStampCopyWith<$Res>(_self.stamp!, (value) {
    return _then(_self.copyWith(stamp: value));
  });
}
}

/// @nodoc
mixin _$NewInvoice {

 int get customerId; String get recipientRfc;
/// Create a copy of NewInvoice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NewInvoiceCopyWith<NewInvoice> get copyWith => _$NewInvoiceCopyWithImpl<NewInvoice>(this as NewInvoice, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as NewInvoice;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NewInvoice&&(identical(other.customerId, _this.customerId) || other.customerId == _this.customerId)&&(identical(other.recipientRfc, _this.recipientRfc) || other.recipientRfc == _this.recipientRfc));
}


@override
int get hashCode {
  final _this = this as NewInvoice;
  return Object.hash(runtimeType,_this.customerId,_this.recipientRfc);
}

@override
String toString() {
  final _this = this as NewInvoice;
  return 'NewInvoice(customerId: ${_this.customerId}, recipientRfc: ${_this.recipientRfc})';
}


}

/// @nodoc
abstract mixin class $NewInvoiceCopyWith<$Res>  {
  factory $NewInvoiceCopyWith(NewInvoice value, $Res Function(NewInvoice) _then) = _$NewInvoiceCopyWithImpl;
@useResult
$Res call({
 int customerId, String recipientRfc
});




}
/// @nodoc
class _$NewInvoiceCopyWithImpl<$Res>
    implements $NewInvoiceCopyWith<$Res> {
  _$NewInvoiceCopyWithImpl(this._self, this._then);

  final NewInvoice _self;
  final $Res Function(NewInvoice) _then;

/// Create a copy of NewInvoice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? customerId = null,Object? recipientRfc = null,}) {
  return _then(NewInvoice(
customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as int,recipientRfc: null == recipientRfc ? _self.recipientRfc : recipientRfc // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [NewInvoice].
extension NewInvoicePatterns on NewInvoice {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NewInvoice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NewInvoice() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NewInvoice value)  $default,){
final _that = this;
switch (_that) {
case _NewInvoice():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NewInvoice value)?  $default,){
final _that = this;
switch (_that) {
case _NewInvoice() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int customerId,  String recipientRfc)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NewInvoice() when $default != null:
return $default(_that.customerId,_that.recipientRfc);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int customerId,  String recipientRfc)  $default,) {final _that = this;
switch (_that) {
case _NewInvoice():
return $default(_that.customerId,_that.recipientRfc);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int customerId,  String recipientRfc)?  $default,) {final _that = this;
switch (_that) {
case _NewInvoice() when $default != null:
return $default(_that.customerId,_that.recipientRfc);case _:
  return null;

}
}

}

/// @nodoc


class _NewInvoice implements NewInvoice {
  const _NewInvoice({required this.customerId, required this.recipientRfc});
  

@override final  int customerId;
@override final  String recipientRfc;

/// Create a copy of NewInvoice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NewInvoiceCopyWith<_NewInvoice> get copyWith => __$NewInvoiceCopyWithImpl<_NewInvoice>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NewInvoice&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.recipientRfc, recipientRfc) || other.recipientRfc == recipientRfc));
}


@override
int get hashCode {
    return Object.hash(runtimeType,customerId,recipientRfc);
}

@override
String toString() {
    return 'NewInvoice(customerId: $customerId, recipientRfc: $recipientRfc)';
}


}

/// @nodoc
abstract mixin class _$NewInvoiceCopyWith<$Res> implements $NewInvoiceCopyWith<$Res> {
  factory _$NewInvoiceCopyWith(_NewInvoice value, $Res Function(_NewInvoice) _then) = __$NewInvoiceCopyWithImpl;
@override @useResult
$Res call({
 int customerId, String recipientRfc
});




}
/// @nodoc
class __$NewInvoiceCopyWithImpl<$Res>
    implements _$NewInvoiceCopyWith<$Res> {
  __$NewInvoiceCopyWithImpl(this._self, this._then);

  final _NewInvoice _self;
  final $Res Function(_NewInvoice) _then;

/// Create a copy of NewInvoice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? customerId = null,Object? recipientRfc = null,}) {
  return _then(_NewInvoice(
customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as int,recipientRfc: null == recipientRfc ? _self.recipientRfc : recipientRfc // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$NewPaymentReceipt {

 int get customerId; String get recipientRfc; int? get customerPaymentId;
/// Create a copy of NewPaymentReceipt
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NewPaymentReceiptCopyWith<NewPaymentReceipt> get copyWith => _$NewPaymentReceiptCopyWithImpl<NewPaymentReceipt>(this as NewPaymentReceipt, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as NewPaymentReceipt;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NewPaymentReceipt&&(identical(other.customerId, _this.customerId) || other.customerId == _this.customerId)&&(identical(other.recipientRfc, _this.recipientRfc) || other.recipientRfc == _this.recipientRfc)&&(identical(other.customerPaymentId, _this.customerPaymentId) || other.customerPaymentId == _this.customerPaymentId));
}


@override
int get hashCode {
  final _this = this as NewPaymentReceipt;
  return Object.hash(runtimeType,_this.customerId,_this.recipientRfc,_this.customerPaymentId);
}

@override
String toString() {
  final _this = this as NewPaymentReceipt;
  return 'NewPaymentReceipt(customerId: ${_this.customerId}, recipientRfc: ${_this.recipientRfc}, customerPaymentId: ${_this.customerPaymentId})';
}


}

/// @nodoc
abstract mixin class $NewPaymentReceiptCopyWith<$Res>  {
  factory $NewPaymentReceiptCopyWith(NewPaymentReceipt value, $Res Function(NewPaymentReceipt) _then) = _$NewPaymentReceiptCopyWithImpl;
@useResult
$Res call({
 int customerId, String recipientRfc, int? customerPaymentId
});




}
/// @nodoc
class _$NewPaymentReceiptCopyWithImpl<$Res>
    implements $NewPaymentReceiptCopyWith<$Res> {
  _$NewPaymentReceiptCopyWithImpl(this._self, this._then);

  final NewPaymentReceipt _self;
  final $Res Function(NewPaymentReceipt) _then;

/// Create a copy of NewPaymentReceipt
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? customerId = null,Object? recipientRfc = null,Object? customerPaymentId = freezed,}) {
  return _then(NewPaymentReceipt(
customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as int,recipientRfc: null == recipientRfc ? _self.recipientRfc : recipientRfc // ignore: cast_nullable_to_non_nullable
as String,customerPaymentId: freezed == customerPaymentId ? _self.customerPaymentId : customerPaymentId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [NewPaymentReceipt].
extension NewPaymentReceiptPatterns on NewPaymentReceipt {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NewPaymentReceipt value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NewPaymentReceipt() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NewPaymentReceipt value)  $default,){
final _that = this;
switch (_that) {
case _NewPaymentReceipt():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NewPaymentReceipt value)?  $default,){
final _that = this;
switch (_that) {
case _NewPaymentReceipt() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int customerId,  String recipientRfc,  int? customerPaymentId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NewPaymentReceipt() when $default != null:
return $default(_that.customerId,_that.recipientRfc,_that.customerPaymentId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int customerId,  String recipientRfc,  int? customerPaymentId)  $default,) {final _that = this;
switch (_that) {
case _NewPaymentReceipt():
return $default(_that.customerId,_that.recipientRfc,_that.customerPaymentId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int customerId,  String recipientRfc,  int? customerPaymentId)?  $default,) {final _that = this;
switch (_that) {
case _NewPaymentReceipt() when $default != null:
return $default(_that.customerId,_that.recipientRfc,_that.customerPaymentId);case _:
  return null;

}
}

}

/// @nodoc


class _NewPaymentReceipt implements NewPaymentReceipt {
  const _NewPaymentReceipt({required this.customerId, required this.recipientRfc, this.customerPaymentId});
  

@override final  int customerId;
@override final  String recipientRfc;
@override final  int? customerPaymentId;

/// Create a copy of NewPaymentReceipt
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NewPaymentReceiptCopyWith<_NewPaymentReceipt> get copyWith => __$NewPaymentReceiptCopyWithImpl<_NewPaymentReceipt>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NewPaymentReceipt&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.recipientRfc, recipientRfc) || other.recipientRfc == recipientRfc)&&(identical(other.customerPaymentId, customerPaymentId) || other.customerPaymentId == customerPaymentId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,customerId,recipientRfc,customerPaymentId);
}

@override
String toString() {
    return 'NewPaymentReceipt(customerId: $customerId, recipientRfc: $recipientRfc, customerPaymentId: $customerPaymentId)';
}


}

/// @nodoc
abstract mixin class _$NewPaymentReceiptCopyWith<$Res> implements $NewPaymentReceiptCopyWith<$Res> {
  factory _$NewPaymentReceiptCopyWith(_NewPaymentReceipt value, $Res Function(_NewPaymentReceipt) _then) = __$NewPaymentReceiptCopyWithImpl;
@override @useResult
$Res call({
 int customerId, String recipientRfc, int? customerPaymentId
});




}
/// @nodoc
class __$NewPaymentReceiptCopyWithImpl<$Res>
    implements _$NewPaymentReceiptCopyWith<$Res> {
  __$NewPaymentReceiptCopyWithImpl(this._self, this._then);

  final _NewPaymentReceipt _self;
  final $Res Function(_NewPaymentReceipt) _then;

/// Create a copy of NewPaymentReceipt
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? customerId = null,Object? recipientRfc = null,Object? customerPaymentId = freezed,}) {
  return _then(_NewPaymentReceipt(
customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as int,recipientRfc: null == recipientRfc ? _self.recipientRfc : recipientRfc // ignore: cast_nullable_to_non_nullable
as String,customerPaymentId: freezed == customerPaymentId ? _self.customerPaymentId : customerPaymentId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$InvoiceHeaderPatch {

 String? get recipientRfc; String? get series; String? get usage; InvoicePaymentTerms? get paymentTerms; int? get paymentForm; DateTime? get issued; int? get facilityId; String? get reference; String? get comment;/// A payment receipt's fields (spec 074). The server accepts them only on
/// a receipt, and the invoice fields above only on an invoice or credit
/// note.
 DateTime? get paymentDate; Decimal? get paymentAmount; String? get paymentReference; String? get orderingBank;
/// Create a copy of InvoiceHeaderPatch
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvoiceHeaderPatchCopyWith<InvoiceHeaderPatch> get copyWith => _$InvoiceHeaderPatchCopyWithImpl<InvoiceHeaderPatch>(this as InvoiceHeaderPatch, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as InvoiceHeaderPatch;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvoiceHeaderPatch&&(identical(other.recipientRfc, _this.recipientRfc) || other.recipientRfc == _this.recipientRfc)&&(identical(other.series, _this.series) || other.series == _this.series)&&(identical(other.usage, _this.usage) || other.usage == _this.usage)&&(identical(other.paymentTerms, _this.paymentTerms) || other.paymentTerms == _this.paymentTerms)&&(identical(other.paymentForm, _this.paymentForm) || other.paymentForm == _this.paymentForm)&&(identical(other.issued, _this.issued) || other.issued == _this.issued)&&(identical(other.facilityId, _this.facilityId) || other.facilityId == _this.facilityId)&&(identical(other.reference, _this.reference) || other.reference == _this.reference)&&(identical(other.comment, _this.comment) || other.comment == _this.comment)&&(identical(other.paymentDate, _this.paymentDate) || other.paymentDate == _this.paymentDate)&&(identical(other.paymentAmount, _this.paymentAmount) || other.paymentAmount == _this.paymentAmount)&&(identical(other.paymentReference, _this.paymentReference) || other.paymentReference == _this.paymentReference)&&(identical(other.orderingBank, _this.orderingBank) || other.orderingBank == _this.orderingBank));
}


@override
int get hashCode {
  final _this = this as InvoiceHeaderPatch;
  return Object.hash(runtimeType,_this.recipientRfc,_this.series,_this.usage,_this.paymentTerms,_this.paymentForm,_this.issued,_this.facilityId,_this.reference,_this.comment,_this.paymentDate,_this.paymentAmount,_this.paymentReference,_this.orderingBank);
}

@override
String toString() {
  final _this = this as InvoiceHeaderPatch;
  return 'InvoiceHeaderPatch(recipientRfc: ${_this.recipientRfc}, series: ${_this.series}, usage: ${_this.usage}, paymentTerms: ${_this.paymentTerms}, paymentForm: ${_this.paymentForm}, issued: ${_this.issued}, facilityId: ${_this.facilityId}, reference: ${_this.reference}, comment: ${_this.comment}, paymentDate: ${_this.paymentDate}, paymentAmount: ${_this.paymentAmount}, paymentReference: ${_this.paymentReference}, orderingBank: ${_this.orderingBank})';
}


}

/// @nodoc
abstract mixin class $InvoiceHeaderPatchCopyWith<$Res>  {
  factory $InvoiceHeaderPatchCopyWith(InvoiceHeaderPatch value, $Res Function(InvoiceHeaderPatch) _then) = _$InvoiceHeaderPatchCopyWithImpl;
@useResult
$Res call({
 String? recipientRfc, String? series, String? usage, InvoicePaymentTerms? paymentTerms, int? paymentForm, DateTime? issued, int? facilityId, String? reference, String? comment, DateTime? paymentDate, Decimal? paymentAmount, String? paymentReference, String? orderingBank
});




}
/// @nodoc
class _$InvoiceHeaderPatchCopyWithImpl<$Res>
    implements $InvoiceHeaderPatchCopyWith<$Res> {
  _$InvoiceHeaderPatchCopyWithImpl(this._self, this._then);

  final InvoiceHeaderPatch _self;
  final $Res Function(InvoiceHeaderPatch) _then;

/// Create a copy of InvoiceHeaderPatch
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? recipientRfc = freezed,Object? series = freezed,Object? usage = freezed,Object? paymentTerms = freezed,Object? paymentForm = freezed,Object? issued = freezed,Object? facilityId = freezed,Object? reference = freezed,Object? comment = freezed,Object? paymentDate = freezed,Object? paymentAmount = freezed,Object? paymentReference = freezed,Object? orderingBank = freezed,}) {
  return _then(InvoiceHeaderPatch(
recipientRfc: freezed == recipientRfc ? _self.recipientRfc : recipientRfc // ignore: cast_nullable_to_non_nullable
as String?,series: freezed == series ? _self.series : series // ignore: cast_nullable_to_non_nullable
as String?,usage: freezed == usage ? _self.usage : usage // ignore: cast_nullable_to_non_nullable
as String?,paymentTerms: freezed == paymentTerms ? _self.paymentTerms : paymentTerms // ignore: cast_nullable_to_non_nullable
as InvoicePaymentTerms?,paymentForm: freezed == paymentForm ? _self.paymentForm : paymentForm // ignore: cast_nullable_to_non_nullable
as int?,issued: freezed == issued ? _self.issued : issued // ignore: cast_nullable_to_non_nullable
as DateTime?,facilityId: freezed == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int?,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,paymentDate: freezed == paymentDate ? _self.paymentDate : paymentDate // ignore: cast_nullable_to_non_nullable
as DateTime?,paymentAmount: freezed == paymentAmount ? _self.paymentAmount : paymentAmount // ignore: cast_nullable_to_non_nullable
as Decimal?,paymentReference: freezed == paymentReference ? _self.paymentReference : paymentReference // ignore: cast_nullable_to_non_nullable
as String?,orderingBank: freezed == orderingBank ? _self.orderingBank : orderingBank // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [InvoiceHeaderPatch].
extension InvoiceHeaderPatchPatterns on InvoiceHeaderPatch {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InvoiceHeaderPatch value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InvoiceHeaderPatch() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InvoiceHeaderPatch value)  $default,){
final _that = this;
switch (_that) {
case _InvoiceHeaderPatch():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InvoiceHeaderPatch value)?  $default,){
final _that = this;
switch (_that) {
case _InvoiceHeaderPatch() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? recipientRfc,  String? series,  String? usage,  InvoicePaymentTerms? paymentTerms,  int? paymentForm,  DateTime? issued,  int? facilityId,  String? reference,  String? comment,  DateTime? paymentDate,  Decimal? paymentAmount,  String? paymentReference,  String? orderingBank)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InvoiceHeaderPatch() when $default != null:
return $default(_that.recipientRfc,_that.series,_that.usage,_that.paymentTerms,_that.paymentForm,_that.issued,_that.facilityId,_that.reference,_that.comment,_that.paymentDate,_that.paymentAmount,_that.paymentReference,_that.orderingBank);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? recipientRfc,  String? series,  String? usage,  InvoicePaymentTerms? paymentTerms,  int? paymentForm,  DateTime? issued,  int? facilityId,  String? reference,  String? comment,  DateTime? paymentDate,  Decimal? paymentAmount,  String? paymentReference,  String? orderingBank)  $default,) {final _that = this;
switch (_that) {
case _InvoiceHeaderPatch():
return $default(_that.recipientRfc,_that.series,_that.usage,_that.paymentTerms,_that.paymentForm,_that.issued,_that.facilityId,_that.reference,_that.comment,_that.paymentDate,_that.paymentAmount,_that.paymentReference,_that.orderingBank);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? recipientRfc,  String? series,  String? usage,  InvoicePaymentTerms? paymentTerms,  int? paymentForm,  DateTime? issued,  int? facilityId,  String? reference,  String? comment,  DateTime? paymentDate,  Decimal? paymentAmount,  String? paymentReference,  String? orderingBank)?  $default,) {final _that = this;
switch (_that) {
case _InvoiceHeaderPatch() when $default != null:
return $default(_that.recipientRfc,_that.series,_that.usage,_that.paymentTerms,_that.paymentForm,_that.issued,_that.facilityId,_that.reference,_that.comment,_that.paymentDate,_that.paymentAmount,_that.paymentReference,_that.orderingBank);case _:
  return null;

}
}

}

/// @nodoc


class _InvoiceHeaderPatch implements InvoiceHeaderPatch {
  const _InvoiceHeaderPatch({this.recipientRfc, this.series, this.usage, this.paymentTerms, this.paymentForm, this.issued, this.facilityId, this.reference, this.comment, this.paymentDate, this.paymentAmount, this.paymentReference, this.orderingBank});
  

@override final  String? recipientRfc;
@override final  String? series;
@override final  String? usage;
@override final  InvoicePaymentTerms? paymentTerms;
@override final  int? paymentForm;
@override final  DateTime? issued;
@override final  int? facilityId;
@override final  String? reference;
@override final  String? comment;
/// A payment receipt's fields (spec 074). The server accepts them only on
/// a receipt, and the invoice fields above only on an invoice or credit
/// note.
@override final  DateTime? paymentDate;
@override final  Decimal? paymentAmount;
@override final  String? paymentReference;
@override final  String? orderingBank;

/// Create a copy of InvoiceHeaderPatch
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvoiceHeaderPatchCopyWith<_InvoiceHeaderPatch> get copyWith => __$InvoiceHeaderPatchCopyWithImpl<_InvoiceHeaderPatch>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _InvoiceHeaderPatch&&(identical(other.recipientRfc, recipientRfc) || other.recipientRfc == recipientRfc)&&(identical(other.series, series) || other.series == series)&&(identical(other.usage, usage) || other.usage == usage)&&(identical(other.paymentTerms, paymentTerms) || other.paymentTerms == paymentTerms)&&(identical(other.paymentForm, paymentForm) || other.paymentForm == paymentForm)&&(identical(other.issued, issued) || other.issued == issued)&&(identical(other.facilityId, facilityId) || other.facilityId == facilityId)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.paymentDate, paymentDate) || other.paymentDate == paymentDate)&&(identical(other.paymentAmount, paymentAmount) || other.paymentAmount == paymentAmount)&&(identical(other.paymentReference, paymentReference) || other.paymentReference == paymentReference)&&(identical(other.orderingBank, orderingBank) || other.orderingBank == orderingBank));
}


@override
int get hashCode {
    return Object.hash(runtimeType,recipientRfc,series,usage,paymentTerms,paymentForm,issued,facilityId,reference,comment,paymentDate,paymentAmount,paymentReference,orderingBank);
}

@override
String toString() {
    return 'InvoiceHeaderPatch(recipientRfc: $recipientRfc, series: $series, usage: $usage, paymentTerms: $paymentTerms, paymentForm: $paymentForm, issued: $issued, facilityId: $facilityId, reference: $reference, comment: $comment, paymentDate: $paymentDate, paymentAmount: $paymentAmount, paymentReference: $paymentReference, orderingBank: $orderingBank)';
}


}

/// @nodoc
abstract mixin class _$InvoiceHeaderPatchCopyWith<$Res> implements $InvoiceHeaderPatchCopyWith<$Res> {
  factory _$InvoiceHeaderPatchCopyWith(_InvoiceHeaderPatch value, $Res Function(_InvoiceHeaderPatch) _then) = __$InvoiceHeaderPatchCopyWithImpl;
@override @useResult
$Res call({
 String? recipientRfc, String? series, String? usage, InvoicePaymentTerms? paymentTerms, int? paymentForm, DateTime? issued, int? facilityId, String? reference, String? comment, DateTime? paymentDate, Decimal? paymentAmount, String? paymentReference, String? orderingBank
});




}
/// @nodoc
class __$InvoiceHeaderPatchCopyWithImpl<$Res>
    implements _$InvoiceHeaderPatchCopyWith<$Res> {
  __$InvoiceHeaderPatchCopyWithImpl(this._self, this._then);

  final _InvoiceHeaderPatch _self;
  final $Res Function(_InvoiceHeaderPatch) _then;

/// Create a copy of InvoiceHeaderPatch
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? recipientRfc = freezed,Object? series = freezed,Object? usage = freezed,Object? paymentTerms = freezed,Object? paymentForm = freezed,Object? issued = freezed,Object? facilityId = freezed,Object? reference = freezed,Object? comment = freezed,Object? paymentDate = freezed,Object? paymentAmount = freezed,Object? paymentReference = freezed,Object? orderingBank = freezed,}) {
  return _then(_InvoiceHeaderPatch(
recipientRfc: freezed == recipientRfc ? _self.recipientRfc : recipientRfc // ignore: cast_nullable_to_non_nullable
as String?,series: freezed == series ? _self.series : series // ignore: cast_nullable_to_non_nullable
as String?,usage: freezed == usage ? _self.usage : usage // ignore: cast_nullable_to_non_nullable
as String?,paymentTerms: freezed == paymentTerms ? _self.paymentTerms : paymentTerms // ignore: cast_nullable_to_non_nullable
as InvoicePaymentTerms?,paymentForm: freezed == paymentForm ? _self.paymentForm : paymentForm // ignore: cast_nullable_to_non_nullable
as int?,issued: freezed == issued ? _self.issued : issued // ignore: cast_nullable_to_non_nullable
as DateTime?,facilityId: freezed == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int?,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,paymentDate: freezed == paymentDate ? _self.paymentDate : paymentDate // ignore: cast_nullable_to_non_nullable
as DateTime?,paymentAmount: freezed == paymentAmount ? _self.paymentAmount : paymentAmount // ignore: cast_nullable_to_non_nullable
as Decimal?,paymentReference: freezed == paymentReference ? _self.paymentReference : paymentReference // ignore: cast_nullable_to_non_nullable
as String?,orderingBank: freezed == orderingBank ? _self.orderingBank : orderingBank // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$InvoiceLinePatch {

 Decimal? get quantity; Decimal? get price; Decimal? get discountPercent; InvoiceTaxRate? get taxRate; String? get productCode; String? get productName; String? get comment;
/// Create a copy of InvoiceLinePatch
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvoiceLinePatchCopyWith<InvoiceLinePatch> get copyWith => _$InvoiceLinePatchCopyWithImpl<InvoiceLinePatch>(this as InvoiceLinePatch, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as InvoiceLinePatch;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvoiceLinePatch&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity)&&(identical(other.price, _this.price) || other.price == _this.price)&&(identical(other.discountPercent, _this.discountPercent) || other.discountPercent == _this.discountPercent)&&(identical(other.taxRate, _this.taxRate) || other.taxRate == _this.taxRate)&&(identical(other.productCode, _this.productCode) || other.productCode == _this.productCode)&&(identical(other.productName, _this.productName) || other.productName == _this.productName)&&(identical(other.comment, _this.comment) || other.comment == _this.comment));
}


@override
int get hashCode {
  final _this = this as InvoiceLinePatch;
  return Object.hash(runtimeType,_this.quantity,_this.price,_this.discountPercent,_this.taxRate,_this.productCode,_this.productName,_this.comment);
}

@override
String toString() {
  final _this = this as InvoiceLinePatch;
  return 'InvoiceLinePatch(quantity: ${_this.quantity}, price: ${_this.price}, discountPercent: ${_this.discountPercent}, taxRate: ${_this.taxRate}, productCode: ${_this.productCode}, productName: ${_this.productName}, comment: ${_this.comment})';
}


}

/// @nodoc
abstract mixin class $InvoiceLinePatchCopyWith<$Res>  {
  factory $InvoiceLinePatchCopyWith(InvoiceLinePatch value, $Res Function(InvoiceLinePatch) _then) = _$InvoiceLinePatchCopyWithImpl;
@useResult
$Res call({
 Decimal? quantity, Decimal? price, Decimal? discountPercent, InvoiceTaxRate? taxRate, String? productCode, String? productName, String? comment
});




}
/// @nodoc
class _$InvoiceLinePatchCopyWithImpl<$Res>
    implements $InvoiceLinePatchCopyWith<$Res> {
  _$InvoiceLinePatchCopyWithImpl(this._self, this._then);

  final InvoiceLinePatch _self;
  final $Res Function(InvoiceLinePatch) _then;

/// Create a copy of InvoiceLinePatch
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? quantity = freezed,Object? price = freezed,Object? discountPercent = freezed,Object? taxRate = freezed,Object? productCode = freezed,Object? productName = freezed,Object? comment = freezed,}) {
  return _then(InvoiceLinePatch(
quantity: freezed == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Decimal?,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as Decimal?,discountPercent: freezed == discountPercent ? _self.discountPercent : discountPercent // ignore: cast_nullable_to_non_nullable
as Decimal?,taxRate: freezed == taxRate ? _self.taxRate : taxRate // ignore: cast_nullable_to_non_nullable
as InvoiceTaxRate?,productCode: freezed == productCode ? _self.productCode : productCode // ignore: cast_nullable_to_non_nullable
as String?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [InvoiceLinePatch].
extension InvoiceLinePatchPatterns on InvoiceLinePatch {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InvoiceLinePatch value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InvoiceLinePatch() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InvoiceLinePatch value)  $default,){
final _that = this;
switch (_that) {
case _InvoiceLinePatch():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InvoiceLinePatch value)?  $default,){
final _that = this;
switch (_that) {
case _InvoiceLinePatch() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Decimal? quantity,  Decimal? price,  Decimal? discountPercent,  InvoiceTaxRate? taxRate,  String? productCode,  String? productName,  String? comment)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InvoiceLinePatch() when $default != null:
return $default(_that.quantity,_that.price,_that.discountPercent,_that.taxRate,_that.productCode,_that.productName,_that.comment);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Decimal? quantity,  Decimal? price,  Decimal? discountPercent,  InvoiceTaxRate? taxRate,  String? productCode,  String? productName,  String? comment)  $default,) {final _that = this;
switch (_that) {
case _InvoiceLinePatch():
return $default(_that.quantity,_that.price,_that.discountPercent,_that.taxRate,_that.productCode,_that.productName,_that.comment);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Decimal? quantity,  Decimal? price,  Decimal? discountPercent,  InvoiceTaxRate? taxRate,  String? productCode,  String? productName,  String? comment)?  $default,) {final _that = this;
switch (_that) {
case _InvoiceLinePatch() when $default != null:
return $default(_that.quantity,_that.price,_that.discountPercent,_that.taxRate,_that.productCode,_that.productName,_that.comment);case _:
  return null;

}
}

}

/// @nodoc


class _InvoiceLinePatch implements InvoiceLinePatch {
  const _InvoiceLinePatch({this.quantity, this.price, this.discountPercent, this.taxRate, this.productCode, this.productName, this.comment});
  

@override final  Decimal? quantity;
@override final  Decimal? price;
@override final  Decimal? discountPercent;
@override final  InvoiceTaxRate? taxRate;
@override final  String? productCode;
@override final  String? productName;
@override final  String? comment;

/// Create a copy of InvoiceLinePatch
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvoiceLinePatchCopyWith<_InvoiceLinePatch> get copyWith => __$InvoiceLinePatchCopyWithImpl<_InvoiceLinePatch>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _InvoiceLinePatch&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.price, price) || other.price == price)&&(identical(other.discountPercent, discountPercent) || other.discountPercent == discountPercent)&&(identical(other.taxRate, taxRate) || other.taxRate == taxRate)&&(identical(other.productCode, productCode) || other.productCode == productCode)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.comment, comment) || other.comment == comment));
}


@override
int get hashCode {
    return Object.hash(runtimeType,quantity,price,discountPercent,taxRate,productCode,productName,comment);
}

@override
String toString() {
    return 'InvoiceLinePatch(quantity: $quantity, price: $price, discountPercent: $discountPercent, taxRate: $taxRate, productCode: $productCode, productName: $productName, comment: $comment)';
}


}

/// @nodoc
abstract mixin class _$InvoiceLinePatchCopyWith<$Res> implements $InvoiceLinePatchCopyWith<$Res> {
  factory _$InvoiceLinePatchCopyWith(_InvoiceLinePatch value, $Res Function(_InvoiceLinePatch) _then) = __$InvoiceLinePatchCopyWithImpl;
@override @useResult
$Res call({
 Decimal? quantity, Decimal? price, Decimal? discountPercent, InvoiceTaxRate? taxRate, String? productCode, String? productName, String? comment
});




}
/// @nodoc
class __$InvoiceLinePatchCopyWithImpl<$Res>
    implements _$InvoiceLinePatchCopyWith<$Res> {
  __$InvoiceLinePatchCopyWithImpl(this._self, this._then);

  final _InvoiceLinePatch _self;
  final $Res Function(_InvoiceLinePatch) _then;

/// Create a copy of InvoiceLinePatch
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? quantity = freezed,Object? price = freezed,Object? discountPercent = freezed,Object? taxRate = freezed,Object? productCode = freezed,Object? productName = freezed,Object? comment = freezed,}) {
  return _then(_InvoiceLinePatch(
quantity: freezed == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Decimal?,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as Decimal?,discountPercent: freezed == discountPercent ? _self.discountPercent : discountPercent // ignore: cast_nullable_to_non_nullable
as Decimal?,taxRate: freezed == taxRate ? _self.taxRate : taxRate // ignore: cast_nullable_to_non_nullable
as InvoiceTaxRate?,productCode: freezed == productCode ? _self.productCode : productCode // ignore: cast_nullable_to_non_nullable
as String?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
