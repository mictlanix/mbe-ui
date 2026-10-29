// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'customer_refund.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RefundOutcome {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is RefundOutcome);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'RefundOutcome()';
}


}

/// @nodoc
class $RefundOutcomeCopyWith<$Res>  {
$RefundOutcomeCopyWith(RefundOutcome _, $Res Function(RefundOutcome) __);
}


/// Adds pattern-matching-related methods to [RefundOutcome].
extension RefundOutcomePatterns on RefundOutcome {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( RefundOutcomeCash value)?  cash,TResult Function( RefundOutcomeCreditNote value)?  creditNote,TResult Function( RefundOutcomeUnknown value)?  unknown,required TResult orElse(),}){
final _that = this;
switch (_that) {
case RefundOutcomeCash() when cash != null:
return cash(_that);case RefundOutcomeCreditNote() when creditNote != null:
return creditNote(_that);case RefundOutcomeUnknown() when unknown != null:
return unknown(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( RefundOutcomeCash value)  cash,required TResult Function( RefundOutcomeCreditNote value)  creditNote,required TResult Function( RefundOutcomeUnknown value)  unknown,}){
final _that = this;
switch (_that) {
case RefundOutcomeCash():
return cash(_that);case RefundOutcomeCreditNote():
return creditNote(_that);case RefundOutcomeUnknown():
return unknown(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( RefundOutcomeCash value)?  cash,TResult? Function( RefundOutcomeCreditNote value)?  creditNote,TResult? Function( RefundOutcomeUnknown value)?  unknown,}){
final _that = this;
switch (_that) {
case RefundOutcomeCash() when cash != null:
return cash(_that);case RefundOutcomeCreditNote() when creditNote != null:
return creditNote(_that);case RefundOutcomeUnknown() when unknown != null:
return unknown(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  cash,TResult Function( CreditNote note)?  creditNote,TResult Function()?  unknown,required TResult orElse(),}) {final _that = this;
switch (_that) {
case RefundOutcomeCash() when cash != null:
return cash();case RefundOutcomeCreditNote() when creditNote != null:
return creditNote(_that.note);case RefundOutcomeUnknown() when unknown != null:
return unknown();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  cash,required TResult Function( CreditNote note)  creditNote,required TResult Function()  unknown,}) {final _that = this;
switch (_that) {
case RefundOutcomeCash():
return cash();case RefundOutcomeCreditNote():
return creditNote(_that.note);case RefundOutcomeUnknown():
return unknown();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  cash,TResult? Function( CreditNote note)?  creditNote,TResult? Function()?  unknown,}) {final _that = this;
switch (_that) {
case RefundOutcomeCash() when cash != null:
return cash();case RefundOutcomeCreditNote() when creditNote != null:
return creditNote(_that.note);case RefundOutcomeUnknown() when unknown != null:
return unknown();case _:
  return null;

}
}

}

/// @nodoc


class RefundOutcomeCash implements RefundOutcome {
  const RefundOutcomeCash();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is RefundOutcomeCash);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'RefundOutcome.cash()';
}


}




/// @nodoc


class RefundOutcomeCreditNote implements RefundOutcome {
  const RefundOutcomeCreditNote(this.note);
  

 final  CreditNote note;

/// Create a copy of RefundOutcome
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RefundOutcomeCreditNoteCopyWith<RefundOutcomeCreditNote> get copyWith => _$RefundOutcomeCreditNoteCopyWithImpl<RefundOutcomeCreditNote>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is RefundOutcomeCreditNote&&(identical(other.note, note) || other.note == note));
}


@override
int get hashCode {
    return Object.hash(runtimeType,note);
}

@override
String toString() {
    return 'RefundOutcome.creditNote(note: $note)';
}


}

/// @nodoc
abstract mixin class $RefundOutcomeCreditNoteCopyWith<$Res> implements $RefundOutcomeCopyWith<$Res> {
  factory $RefundOutcomeCreditNoteCopyWith(RefundOutcomeCreditNote value, $Res Function(RefundOutcomeCreditNote) _then) = _$RefundOutcomeCreditNoteCopyWithImpl;
@useResult
$Res call({
 CreditNote note
});


$CreditNoteCopyWith<$Res> get note;

}
/// @nodoc
class _$RefundOutcomeCreditNoteCopyWithImpl<$Res>
    implements $RefundOutcomeCreditNoteCopyWith<$Res> {
  _$RefundOutcomeCreditNoteCopyWithImpl(this._self, this._then);

  final RefundOutcomeCreditNote _self;
  final $Res Function(RefundOutcomeCreditNote) _then;

/// Create a copy of RefundOutcome
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? note = null,}) {
  return _then(RefundOutcomeCreditNote(
null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as CreditNote,
  ));
}

/// Create a copy of RefundOutcome
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CreditNoteCopyWith<$Res> get note {
  
  return $CreditNoteCopyWith<$Res>(_self.note, (value) {
    return _then(_self.copyWith(note: value));
  });
}
}

/// @nodoc


class RefundOutcomeUnknown implements RefundOutcome {
  const RefundOutcomeUnknown();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is RefundOutcomeUnknown);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'RefundOutcome.unknown()';
}


}




/// @nodoc
mixin _$RefundLine {

 int get id; int get salesOrderLineId; int get productId; String get productCode; String get productName;/// The return quantity.
 String get quantity;/// The stepper's maximum (FR-007).
 String get refundableQuantity; String get price; String get discount; String get taxRate; bool get taxIncluded;/// The return-to warehouse.
 int? get warehouseId; String get subtotal; String get taxTotal; String get total;
/// Create a copy of RefundLine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RefundLineCopyWith<RefundLine> get copyWith => _$RefundLineCopyWithImpl<RefundLine>(this as RefundLine, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as RefundLine;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RefundLine&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.salesOrderLineId, _this.salesOrderLineId) || other.salesOrderLineId == _this.salesOrderLineId)&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.productCode, _this.productCode) || other.productCode == _this.productCode)&&(identical(other.productName, _this.productName) || other.productName == _this.productName)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity)&&(identical(other.refundableQuantity, _this.refundableQuantity) || other.refundableQuantity == _this.refundableQuantity)&&(identical(other.price, _this.price) || other.price == _this.price)&&(identical(other.discount, _this.discount) || other.discount == _this.discount)&&(identical(other.taxRate, _this.taxRate) || other.taxRate == _this.taxRate)&&(identical(other.taxIncluded, _this.taxIncluded) || other.taxIncluded == _this.taxIncluded)&&(identical(other.warehouseId, _this.warehouseId) || other.warehouseId == _this.warehouseId)&&(identical(other.subtotal, _this.subtotal) || other.subtotal == _this.subtotal)&&(identical(other.taxTotal, _this.taxTotal) || other.taxTotal == _this.taxTotal)&&(identical(other.total, _this.total) || other.total == _this.total));
}


@override
int get hashCode {
  final _this = this as RefundLine;
  return Object.hash(runtimeType,_this.id,_this.salesOrderLineId,_this.productId,_this.productCode,_this.productName,_this.quantity,_this.refundableQuantity,_this.price,_this.discount,_this.taxRate,_this.taxIncluded,_this.warehouseId,_this.subtotal,_this.taxTotal,_this.total);
}

@override
String toString() {
  final _this = this as RefundLine;
  return 'RefundLine(id: ${_this.id}, salesOrderLineId: ${_this.salesOrderLineId}, productId: ${_this.productId}, productCode: ${_this.productCode}, productName: ${_this.productName}, quantity: ${_this.quantity}, refundableQuantity: ${_this.refundableQuantity}, price: ${_this.price}, discount: ${_this.discount}, taxRate: ${_this.taxRate}, taxIncluded: ${_this.taxIncluded}, warehouseId: ${_this.warehouseId}, subtotal: ${_this.subtotal}, taxTotal: ${_this.taxTotal}, total: ${_this.total})';
}


}

/// @nodoc
abstract mixin class $RefundLineCopyWith<$Res>  {
  factory $RefundLineCopyWith(RefundLine value, $Res Function(RefundLine) _then) = _$RefundLineCopyWithImpl;
@useResult
$Res call({
 int id, int salesOrderLineId, int productId, String productCode, String productName, String quantity, String refundableQuantity, String price, String discount, String taxRate, bool taxIncluded, int? warehouseId, String subtotal, String taxTotal, String total
});




}
/// @nodoc
class _$RefundLineCopyWithImpl<$Res>
    implements $RefundLineCopyWith<$Res> {
  _$RefundLineCopyWithImpl(this._self, this._then);

  final RefundLine _self;
  final $Res Function(RefundLine) _then;

/// Create a copy of RefundLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? salesOrderLineId = null,Object? productId = null,Object? productCode = null,Object? productName = null,Object? quantity = null,Object? refundableQuantity = null,Object? price = null,Object? discount = null,Object? taxRate = null,Object? taxIncluded = null,Object? warehouseId = freezed,Object? subtotal = null,Object? taxTotal = null,Object? total = null,}) {
  return _then(RefundLine(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,salesOrderLineId: null == salesOrderLineId ? _self.salesOrderLineId : salesOrderLineId // ignore: cast_nullable_to_non_nullable
as int,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,productCode: null == productCode ? _self.productCode : productCode // ignore: cast_nullable_to_non_nullable
as String,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as String,refundableQuantity: null == refundableQuantity ? _self.refundableQuantity : refundableQuantity // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as String,discount: null == discount ? _self.discount : discount // ignore: cast_nullable_to_non_nullable
as String,taxRate: null == taxRate ? _self.taxRate : taxRate // ignore: cast_nullable_to_non_nullable
as String,taxIncluded: null == taxIncluded ? _self.taxIncluded : taxIncluded // ignore: cast_nullable_to_non_nullable
as bool,warehouseId: freezed == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int?,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as String,taxTotal: null == taxTotal ? _self.taxTotal : taxTotal // ignore: cast_nullable_to_non_nullable
as String,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RefundLine].
extension RefundLinePatterns on RefundLine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RefundLine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RefundLine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RefundLine value)  $default,){
final _that = this;
switch (_that) {
case _RefundLine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RefundLine value)?  $default,){
final _that = this;
switch (_that) {
case _RefundLine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int salesOrderLineId,  int productId,  String productCode,  String productName,  String quantity,  String refundableQuantity,  String price,  String discount,  String taxRate,  bool taxIncluded,  int? warehouseId,  String subtotal,  String taxTotal,  String total)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RefundLine() when $default != null:
return $default(_that.id,_that.salesOrderLineId,_that.productId,_that.productCode,_that.productName,_that.quantity,_that.refundableQuantity,_that.price,_that.discount,_that.taxRate,_that.taxIncluded,_that.warehouseId,_that.subtotal,_that.taxTotal,_that.total);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int salesOrderLineId,  int productId,  String productCode,  String productName,  String quantity,  String refundableQuantity,  String price,  String discount,  String taxRate,  bool taxIncluded,  int? warehouseId,  String subtotal,  String taxTotal,  String total)  $default,) {final _that = this;
switch (_that) {
case _RefundLine():
return $default(_that.id,_that.salesOrderLineId,_that.productId,_that.productCode,_that.productName,_that.quantity,_that.refundableQuantity,_that.price,_that.discount,_that.taxRate,_that.taxIncluded,_that.warehouseId,_that.subtotal,_that.taxTotal,_that.total);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int salesOrderLineId,  int productId,  String productCode,  String productName,  String quantity,  String refundableQuantity,  String price,  String discount,  String taxRate,  bool taxIncluded,  int? warehouseId,  String subtotal,  String taxTotal,  String total)?  $default,) {final _that = this;
switch (_that) {
case _RefundLine() when $default != null:
return $default(_that.id,_that.salesOrderLineId,_that.productId,_that.productCode,_that.productName,_that.quantity,_that.refundableQuantity,_that.price,_that.discount,_that.taxRate,_that.taxIncluded,_that.warehouseId,_that.subtotal,_that.taxTotal,_that.total);case _:
  return null;

}
}

}

/// @nodoc


class _RefundLine implements RefundLine {
  const _RefundLine({required this.id, required this.salesOrderLineId, required this.productId, required this.productCode, required this.productName, required this.quantity, required this.refundableQuantity, required this.price, required this.discount, required this.taxRate, required this.taxIncluded, this.warehouseId, required this.subtotal, required this.taxTotal, required this.total});
  

@override final  int id;
@override final  int salesOrderLineId;
@override final  int productId;
@override final  String productCode;
@override final  String productName;
/// The return quantity.
@override final  String quantity;
/// The stepper's maximum (FR-007).
@override final  String refundableQuantity;
@override final  String price;
@override final  String discount;
@override final  String taxRate;
@override final  bool taxIncluded;
/// The return-to warehouse.
@override final  int? warehouseId;
@override final  String subtotal;
@override final  String taxTotal;
@override final  String total;

/// Create a copy of RefundLine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RefundLineCopyWith<_RefundLine> get copyWith => __$RefundLineCopyWithImpl<_RefundLine>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RefundLine&&(identical(other.id, id) || other.id == id)&&(identical(other.salesOrderLineId, salesOrderLineId) || other.salesOrderLineId == salesOrderLineId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productCode, productCode) || other.productCode == productCode)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.refundableQuantity, refundableQuantity) || other.refundableQuantity == refundableQuantity)&&(identical(other.price, price) || other.price == price)&&(identical(other.discount, discount) || other.discount == discount)&&(identical(other.taxRate, taxRate) || other.taxRate == taxRate)&&(identical(other.taxIncluded, taxIncluded) || other.taxIncluded == taxIncluded)&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.taxTotal, taxTotal) || other.taxTotal == taxTotal)&&(identical(other.total, total) || other.total == total));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,salesOrderLineId,productId,productCode,productName,quantity,refundableQuantity,price,discount,taxRate,taxIncluded,warehouseId,subtotal,taxTotal,total);
}

@override
String toString() {
    return 'RefundLine(id: $id, salesOrderLineId: $salesOrderLineId, productId: $productId, productCode: $productCode, productName: $productName, quantity: $quantity, refundableQuantity: $refundableQuantity, price: $price, discount: $discount, taxRate: $taxRate, taxIncluded: $taxIncluded, warehouseId: $warehouseId, subtotal: $subtotal, taxTotal: $taxTotal, total: $total)';
}


}

/// @nodoc
abstract mixin class _$RefundLineCopyWith<$Res> implements $RefundLineCopyWith<$Res> {
  factory _$RefundLineCopyWith(_RefundLine value, $Res Function(_RefundLine) _then) = __$RefundLineCopyWithImpl;
@override @useResult
$Res call({
 int id, int salesOrderLineId, int productId, String productCode, String productName, String quantity, String refundableQuantity, String price, String discount, String taxRate, bool taxIncluded, int? warehouseId, String subtotal, String taxTotal, String total
});




}
/// @nodoc
class __$RefundLineCopyWithImpl<$Res>
    implements _$RefundLineCopyWith<$Res> {
  __$RefundLineCopyWithImpl(this._self, this._then);

  final _RefundLine _self;
  final $Res Function(_RefundLine) _then;

/// Create a copy of RefundLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? salesOrderLineId = null,Object? productId = null,Object? productCode = null,Object? productName = null,Object? quantity = null,Object? refundableQuantity = null,Object? price = null,Object? discount = null,Object? taxRate = null,Object? taxIncluded = null,Object? warehouseId = freezed,Object? subtotal = null,Object? taxTotal = null,Object? total = null,}) {
  return _then(_RefundLine(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,salesOrderLineId: null == salesOrderLineId ? _self.salesOrderLineId : salesOrderLineId // ignore: cast_nullable_to_non_nullable
as int,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,productCode: null == productCode ? _self.productCode : productCode // ignore: cast_nullable_to_non_nullable
as String,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as String,refundableQuantity: null == refundableQuantity ? _self.refundableQuantity : refundableQuantity // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as String,discount: null == discount ? _self.discount : discount // ignore: cast_nullable_to_non_nullable
as String,taxRate: null == taxRate ? _self.taxRate : taxRate // ignore: cast_nullable_to_non_nullable
as String,taxIncluded: null == taxIncluded ? _self.taxIncluded : taxIncluded // ignore: cast_nullable_to_non_nullable
as bool,warehouseId: freezed == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int?,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as String,taxTotal: null == taxTotal ? _self.taxTotal : taxTotal // ignore: cast_nullable_to_non_nullable
as String,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$CustomerRefund {

 int get id; int get salesOrderId;/// Null means no customer; the payout lookup is not possible then (R6).
 int? get customerId; int get salesPersonId; int get facilityId;/// The folio. Null until confirmed.
 int? get serial;/// Set on confirm.
 DateTime? get date; Currency get currency; RefundStatus get status; List<RefundLine> get lines; String get subtotal; String get taxTotal; String get total;
/// Create a copy of CustomerRefund
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomerRefundCopyWith<CustomerRefund> get copyWith => _$CustomerRefundCopyWithImpl<CustomerRefund>(this as CustomerRefund, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CustomerRefund;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomerRefund&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.salesOrderId, _this.salesOrderId) || other.salesOrderId == _this.salesOrderId)&&(identical(other.customerId, _this.customerId) || other.customerId == _this.customerId)&&(identical(other.salesPersonId, _this.salesPersonId) || other.salesPersonId == _this.salesPersonId)&&(identical(other.facilityId, _this.facilityId) || other.facilityId == _this.facilityId)&&(identical(other.serial, _this.serial) || other.serial == _this.serial)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.currency, _this.currency) || other.currency == _this.currency)&&(identical(other.status, _this.status) || other.status == _this.status)&&const DeepCollectionEquality().equals(other.lines, _this.lines)&&(identical(other.subtotal, _this.subtotal) || other.subtotal == _this.subtotal)&&(identical(other.taxTotal, _this.taxTotal) || other.taxTotal == _this.taxTotal)&&(identical(other.total, _this.total) || other.total == _this.total));
}


@override
int get hashCode {
  final _this = this as CustomerRefund;
  return Object.hash(runtimeType,_this.id,_this.salesOrderId,_this.customerId,_this.salesPersonId,_this.facilityId,_this.serial,_this.date,_this.currency,_this.status,const DeepCollectionEquality().hash(_this.lines),_this.subtotal,_this.taxTotal,_this.total);
}

@override
String toString() {
  final _this = this as CustomerRefund;
  return 'CustomerRefund(id: ${_this.id}, salesOrderId: ${_this.salesOrderId}, customerId: ${_this.customerId}, salesPersonId: ${_this.salesPersonId}, facilityId: ${_this.facilityId}, serial: ${_this.serial}, date: ${_this.date}, currency: ${_this.currency}, status: ${_this.status}, lines: ${_this.lines}, subtotal: ${_this.subtotal}, taxTotal: ${_this.taxTotal}, total: ${_this.total})';
}


}

/// @nodoc
abstract mixin class $CustomerRefundCopyWith<$Res>  {
  factory $CustomerRefundCopyWith(CustomerRefund value, $Res Function(CustomerRefund) _then) = _$CustomerRefundCopyWithImpl;
@useResult
$Res call({
 int id, int salesOrderId, int? customerId, int salesPersonId, int facilityId, int? serial, DateTime? date, Currency currency, RefundStatus status, List<RefundLine> lines, String subtotal, String taxTotal, String total
});




}
/// @nodoc
class _$CustomerRefundCopyWithImpl<$Res>
    implements $CustomerRefundCopyWith<$Res> {
  _$CustomerRefundCopyWithImpl(this._self, this._then);

  final CustomerRefund _self;
  final $Res Function(CustomerRefund) _then;

/// Create a copy of CustomerRefund
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? salesOrderId = null,Object? customerId = freezed,Object? salesPersonId = null,Object? facilityId = null,Object? serial = freezed,Object? date = freezed,Object? currency = null,Object? status = null,Object? lines = null,Object? subtotal = null,Object? taxTotal = null,Object? total = null,}) {
  return _then(CustomerRefund(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,salesOrderId: null == salesOrderId ? _self.salesOrderId : salesOrderId // ignore: cast_nullable_to_non_nullable
as int,customerId: freezed == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as int?,salesPersonId: null == salesPersonId ? _self.salesPersonId : salesPersonId // ignore: cast_nullable_to_non_nullable
as int,facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as int?,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime?,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as Currency,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RefundStatus,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<RefundLine>,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as String,taxTotal: null == taxTotal ? _self.taxTotal : taxTotal // ignore: cast_nullable_to_non_nullable
as String,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CustomerRefund].
extension CustomerRefundPatterns on CustomerRefund {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CustomerRefund value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CustomerRefund() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CustomerRefund value)  $default,){
final _that = this;
switch (_that) {
case _CustomerRefund():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CustomerRefund value)?  $default,){
final _that = this;
switch (_that) {
case _CustomerRefund() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int salesOrderId,  int? customerId,  int salesPersonId,  int facilityId,  int? serial,  DateTime? date,  Currency currency,  RefundStatus status,  List<RefundLine> lines,  String subtotal,  String taxTotal,  String total)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CustomerRefund() when $default != null:
return $default(_that.id,_that.salesOrderId,_that.customerId,_that.salesPersonId,_that.facilityId,_that.serial,_that.date,_that.currency,_that.status,_that.lines,_that.subtotal,_that.taxTotal,_that.total);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int salesOrderId,  int? customerId,  int salesPersonId,  int facilityId,  int? serial,  DateTime? date,  Currency currency,  RefundStatus status,  List<RefundLine> lines,  String subtotal,  String taxTotal,  String total)  $default,) {final _that = this;
switch (_that) {
case _CustomerRefund():
return $default(_that.id,_that.salesOrderId,_that.customerId,_that.salesPersonId,_that.facilityId,_that.serial,_that.date,_that.currency,_that.status,_that.lines,_that.subtotal,_that.taxTotal,_that.total);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int salesOrderId,  int? customerId,  int salesPersonId,  int facilityId,  int? serial,  DateTime? date,  Currency currency,  RefundStatus status,  List<RefundLine> lines,  String subtotal,  String taxTotal,  String total)?  $default,) {final _that = this;
switch (_that) {
case _CustomerRefund() when $default != null:
return $default(_that.id,_that.salesOrderId,_that.customerId,_that.salesPersonId,_that.facilityId,_that.serial,_that.date,_that.currency,_that.status,_that.lines,_that.subtotal,_that.taxTotal,_that.total);case _:
  return null;

}
}

}

/// @nodoc


class _CustomerRefund extends CustomerRefund {
  const _CustomerRefund({required this.id, required this.salesOrderId, this.customerId, required this.salesPersonId, required this.facilityId, this.serial, this.date, required this.currency, required this.status,  List<RefundLine> lines = const <RefundLine>[], required this.subtotal, required this.taxTotal, required this.total}): _lines = lines,super._();
  

@override final  int id;
@override final  int salesOrderId;
/// Null means no customer; the payout lookup is not possible then (R6).
@override final  int? customerId;
@override final  int salesPersonId;
@override final  int facilityId;
/// The folio. Null until confirmed.
@override final  int? serial;
/// Set on confirm.
@override final  DateTime? date;
@override final  Currency currency;
@override final  RefundStatus status;
 final  List<RefundLine> _lines;
@override@JsonKey() List<RefundLine> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}

@override final  String subtotal;
@override final  String taxTotal;
@override final  String total;

/// Create a copy of CustomerRefund
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomerRefundCopyWith<_CustomerRefund> get copyWith => __$CustomerRefundCopyWithImpl<_CustomerRefund>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CustomerRefund&&(identical(other.id, id) || other.id == id)&&(identical(other.salesOrderId, salesOrderId) || other.salesOrderId == salesOrderId)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.salesPersonId, salesPersonId) || other.salesPersonId == salesPersonId)&&(identical(other.facilityId, facilityId) || other.facilityId == facilityId)&&(identical(other.serial, serial) || other.serial == serial)&&(identical(other.date, date) || other.date == date)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.lines, _lines)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.taxTotal, taxTotal) || other.taxTotal == taxTotal)&&(identical(other.total, total) || other.total == total));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,salesOrderId,customerId,salesPersonId,facilityId,serial,date,currency,status,const DeepCollectionEquality().hash(_lines),subtotal,taxTotal,total);
}

@override
String toString() {
    return 'CustomerRefund(id: $id, salesOrderId: $salesOrderId, customerId: $customerId, salesPersonId: $salesPersonId, facilityId: $facilityId, serial: $serial, date: $date, currency: $currency, status: $status, lines: $lines, subtotal: $subtotal, taxTotal: $taxTotal, total: $total)';
}


}

/// @nodoc
abstract mixin class _$CustomerRefundCopyWith<$Res> implements $CustomerRefundCopyWith<$Res> {
  factory _$CustomerRefundCopyWith(_CustomerRefund value, $Res Function(_CustomerRefund) _then) = __$CustomerRefundCopyWithImpl;
@override @useResult
$Res call({
 int id, int salesOrderId, int? customerId, int salesPersonId, int facilityId, int? serial, DateTime? date, Currency currency, RefundStatus status, List<RefundLine> lines, String subtotal, String taxTotal, String total
});




}
/// @nodoc
class __$CustomerRefundCopyWithImpl<$Res>
    implements _$CustomerRefundCopyWith<$Res> {
  __$CustomerRefundCopyWithImpl(this._self, this._then);

  final _CustomerRefund _self;
  final $Res Function(_CustomerRefund) _then;

/// Create a copy of CustomerRefund
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? salesOrderId = null,Object? customerId = freezed,Object? salesPersonId = null,Object? facilityId = null,Object? serial = freezed,Object? date = freezed,Object? currency = null,Object? status = null,Object? lines = null,Object? subtotal = null,Object? taxTotal = null,Object? total = null,}) {
  return _then(_CustomerRefund(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,salesOrderId: null == salesOrderId ? _self.salesOrderId : salesOrderId // ignore: cast_nullable_to_non_nullable
as int,customerId: freezed == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as int?,salesPersonId: null == salesPersonId ? _self.salesPersonId : salesPersonId // ignore: cast_nullable_to_non_nullable
as int,facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as int?,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime?,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as Currency,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RefundStatus,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<RefundLine>,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as String,taxTotal: null == taxTotal ? _self.taxTotal : taxTotal // ignore: cast_nullable_to_non_nullable
as String,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$CustomerRefundSummary {

 int get id; int get salesOrderId; int? get customerId; int? get serial; DateTime? get date; Currency get currency; RefundStatus get status; String get total;
/// Create a copy of CustomerRefundSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomerRefundSummaryCopyWith<CustomerRefundSummary> get copyWith => _$CustomerRefundSummaryCopyWithImpl<CustomerRefundSummary>(this as CustomerRefundSummary, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CustomerRefundSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomerRefundSummary&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.salesOrderId, _this.salesOrderId) || other.salesOrderId == _this.salesOrderId)&&(identical(other.customerId, _this.customerId) || other.customerId == _this.customerId)&&(identical(other.serial, _this.serial) || other.serial == _this.serial)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.currency, _this.currency) || other.currency == _this.currency)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.total, _this.total) || other.total == _this.total));
}


@override
int get hashCode {
  final _this = this as CustomerRefundSummary;
  return Object.hash(runtimeType,_this.id,_this.salesOrderId,_this.customerId,_this.serial,_this.date,_this.currency,_this.status,_this.total);
}

@override
String toString() {
  final _this = this as CustomerRefundSummary;
  return 'CustomerRefundSummary(id: ${_this.id}, salesOrderId: ${_this.salesOrderId}, customerId: ${_this.customerId}, serial: ${_this.serial}, date: ${_this.date}, currency: ${_this.currency}, status: ${_this.status}, total: ${_this.total})';
}


}

/// @nodoc
abstract mixin class $CustomerRefundSummaryCopyWith<$Res>  {
  factory $CustomerRefundSummaryCopyWith(CustomerRefundSummary value, $Res Function(CustomerRefundSummary) _then) = _$CustomerRefundSummaryCopyWithImpl;
@useResult
$Res call({
 int id, int salesOrderId, int? customerId, int? serial, DateTime? date, Currency currency, RefundStatus status, String total
});




}
/// @nodoc
class _$CustomerRefundSummaryCopyWithImpl<$Res>
    implements $CustomerRefundSummaryCopyWith<$Res> {
  _$CustomerRefundSummaryCopyWithImpl(this._self, this._then);

  final CustomerRefundSummary _self;
  final $Res Function(CustomerRefundSummary) _then;

/// Create a copy of CustomerRefundSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? salesOrderId = null,Object? customerId = freezed,Object? serial = freezed,Object? date = freezed,Object? currency = null,Object? status = null,Object? total = null,}) {
  return _then(CustomerRefundSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,salesOrderId: null == salesOrderId ? _self.salesOrderId : salesOrderId // ignore: cast_nullable_to_non_nullable
as int,customerId: freezed == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as int?,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as int?,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime?,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as Currency,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RefundStatus,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CustomerRefundSummary].
extension CustomerRefundSummaryPatterns on CustomerRefundSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CustomerRefundSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CustomerRefundSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CustomerRefundSummary value)  $default,){
final _that = this;
switch (_that) {
case _CustomerRefundSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CustomerRefundSummary value)?  $default,){
final _that = this;
switch (_that) {
case _CustomerRefundSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int salesOrderId,  int? customerId,  int? serial,  DateTime? date,  Currency currency,  RefundStatus status,  String total)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CustomerRefundSummary() when $default != null:
return $default(_that.id,_that.salesOrderId,_that.customerId,_that.serial,_that.date,_that.currency,_that.status,_that.total);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int salesOrderId,  int? customerId,  int? serial,  DateTime? date,  Currency currency,  RefundStatus status,  String total)  $default,) {final _that = this;
switch (_that) {
case _CustomerRefundSummary():
return $default(_that.id,_that.salesOrderId,_that.customerId,_that.serial,_that.date,_that.currency,_that.status,_that.total);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int salesOrderId,  int? customerId,  int? serial,  DateTime? date,  Currency currency,  RefundStatus status,  String total)?  $default,) {final _that = this;
switch (_that) {
case _CustomerRefundSummary() when $default != null:
return $default(_that.id,_that.salesOrderId,_that.customerId,_that.serial,_that.date,_that.currency,_that.status,_that.total);case _:
  return null;

}
}

}

/// @nodoc


class _CustomerRefundSummary implements CustomerRefundSummary {
  const _CustomerRefundSummary({required this.id, required this.salesOrderId, this.customerId, this.serial, this.date, required this.currency, required this.status, required this.total});
  

@override final  int id;
@override final  int salesOrderId;
@override final  int? customerId;
@override final  int? serial;
@override final  DateTime? date;
@override final  Currency currency;
@override final  RefundStatus status;
@override final  String total;

/// Create a copy of CustomerRefundSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomerRefundSummaryCopyWith<_CustomerRefundSummary> get copyWith => __$CustomerRefundSummaryCopyWithImpl<_CustomerRefundSummary>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CustomerRefundSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.salesOrderId, salesOrderId) || other.salesOrderId == salesOrderId)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.serial, serial) || other.serial == serial)&&(identical(other.date, date) || other.date == date)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.status, status) || other.status == status)&&(identical(other.total, total) || other.total == total));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,salesOrderId,customerId,serial,date,currency,status,total);
}

@override
String toString() {
    return 'CustomerRefundSummary(id: $id, salesOrderId: $salesOrderId, customerId: $customerId, serial: $serial, date: $date, currency: $currency, status: $status, total: $total)';
}


}

/// @nodoc
abstract mixin class _$CustomerRefundSummaryCopyWith<$Res> implements $CustomerRefundSummaryCopyWith<$Res> {
  factory _$CustomerRefundSummaryCopyWith(_CustomerRefundSummary value, $Res Function(_CustomerRefundSummary) _then) = __$CustomerRefundSummaryCopyWithImpl;
@override @useResult
$Res call({
 int id, int salesOrderId, int? customerId, int? serial, DateTime? date, Currency currency, RefundStatus status, String total
});




}
/// @nodoc
class __$CustomerRefundSummaryCopyWithImpl<$Res>
    implements _$CustomerRefundSummaryCopyWith<$Res> {
  __$CustomerRefundSummaryCopyWithImpl(this._self, this._then);

  final _CustomerRefundSummary _self;
  final $Res Function(_CustomerRefundSummary) _then;

/// Create a copy of CustomerRefundSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? salesOrderId = null,Object? customerId = freezed,Object? serial = freezed,Object? date = freezed,Object? currency = null,Object? status = null,Object? total = null,}) {
  return _then(_CustomerRefundSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,salesOrderId: null == salesOrderId ? _self.salesOrderId : salesOrderId // ignore: cast_nullable_to_non_nullable
as int,customerId: freezed == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as int?,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as int?,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime?,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as Currency,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RefundStatus,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
