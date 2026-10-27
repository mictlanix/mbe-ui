// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'credit_note.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CreditNote {

 int get id; int get customerId;/// The order the refund came from.
 int get salesOrderId; int get customerRefundId;/// The backing payment; its id is the ticket number.
 int get customerPaymentId;/// The server's `refunded` figure, shown as sent. It reads 0 on legacy
/// notes until mbe-api#277 ships.
 String get issued;/// What is left to spend, as the server reports it. Never recomputed
/// client-side (spec 056 FR-015).
 String get remaining; DateTime? get date;
/// Create a copy of CreditNote
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreditNoteCopyWith<CreditNote> get copyWith => _$CreditNoteCopyWithImpl<CreditNote>(this as CreditNote, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CreditNote;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreditNote&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.customerId, _this.customerId) || other.customerId == _this.customerId)&&(identical(other.salesOrderId, _this.salesOrderId) || other.salesOrderId == _this.salesOrderId)&&(identical(other.customerRefundId, _this.customerRefundId) || other.customerRefundId == _this.customerRefundId)&&(identical(other.customerPaymentId, _this.customerPaymentId) || other.customerPaymentId == _this.customerPaymentId)&&(identical(other.issued, _this.issued) || other.issued == _this.issued)&&(identical(other.remaining, _this.remaining) || other.remaining == _this.remaining)&&(identical(other.date, _this.date) || other.date == _this.date));
}


@override
int get hashCode {
  final _this = this as CreditNote;
  return Object.hash(runtimeType,_this.id,_this.customerId,_this.salesOrderId,_this.customerRefundId,_this.customerPaymentId,_this.issued,_this.remaining,_this.date);
}

@override
String toString() {
  final _this = this as CreditNote;
  return 'CreditNote(id: ${_this.id}, customerId: ${_this.customerId}, salesOrderId: ${_this.salesOrderId}, customerRefundId: ${_this.customerRefundId}, customerPaymentId: ${_this.customerPaymentId}, issued: ${_this.issued}, remaining: ${_this.remaining}, date: ${_this.date})';
}


}

/// @nodoc
abstract mixin class $CreditNoteCopyWith<$Res>  {
  factory $CreditNoteCopyWith(CreditNote value, $Res Function(CreditNote) _then) = _$CreditNoteCopyWithImpl;
@useResult
$Res call({
 int id, int customerId, int salesOrderId, int customerRefundId, int customerPaymentId, String issued, String remaining, DateTime? date
});




}
/// @nodoc
class _$CreditNoteCopyWithImpl<$Res>
    implements $CreditNoteCopyWith<$Res> {
  _$CreditNoteCopyWithImpl(this._self, this._then);

  final CreditNote _self;
  final $Res Function(CreditNote) _then;

/// Create a copy of CreditNote
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? customerId = null,Object? salesOrderId = null,Object? customerRefundId = null,Object? customerPaymentId = null,Object? issued = null,Object? remaining = null,Object? date = freezed,}) {
  return _then(CreditNote(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as int,salesOrderId: null == salesOrderId ? _self.salesOrderId : salesOrderId // ignore: cast_nullable_to_non_nullable
as int,customerRefundId: null == customerRefundId ? _self.customerRefundId : customerRefundId // ignore: cast_nullable_to_non_nullable
as int,customerPaymentId: null == customerPaymentId ? _self.customerPaymentId : customerPaymentId // ignore: cast_nullable_to_non_nullable
as int,issued: null == issued ? _self.issued : issued // ignore: cast_nullable_to_non_nullable
as String,remaining: null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as String,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreditNote].
extension CreditNotePatterns on CreditNote {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreditNote value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreditNote() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreditNote value)  $default,){
final _that = this;
switch (_that) {
case _CreditNote():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreditNote value)?  $default,){
final _that = this;
switch (_that) {
case _CreditNote() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int customerId,  int salesOrderId,  int customerRefundId,  int customerPaymentId,  String issued,  String remaining,  DateTime? date)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreditNote() when $default != null:
return $default(_that.id,_that.customerId,_that.salesOrderId,_that.customerRefundId,_that.customerPaymentId,_that.issued,_that.remaining,_that.date);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int customerId,  int salesOrderId,  int customerRefundId,  int customerPaymentId,  String issued,  String remaining,  DateTime? date)  $default,) {final _that = this;
switch (_that) {
case _CreditNote():
return $default(_that.id,_that.customerId,_that.salesOrderId,_that.customerRefundId,_that.customerPaymentId,_that.issued,_that.remaining,_that.date);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int customerId,  int salesOrderId,  int customerRefundId,  int customerPaymentId,  String issued,  String remaining,  DateTime? date)?  $default,) {final _that = this;
switch (_that) {
case _CreditNote() when $default != null:
return $default(_that.id,_that.customerId,_that.salesOrderId,_that.customerRefundId,_that.customerPaymentId,_that.issued,_that.remaining,_that.date);case _:
  return null;

}
}

}

/// @nodoc


class _CreditNote extends CreditNote {
  const _CreditNote({required this.id, required this.customerId, required this.salesOrderId, required this.customerRefundId, required this.customerPaymentId, required this.issued, required this.remaining, this.date}): super._();
  

@override final  int id;
@override final  int customerId;
/// The order the refund came from.
@override final  int salesOrderId;
@override final  int customerRefundId;
/// The backing payment; its id is the ticket number.
@override final  int customerPaymentId;
/// The server's `refunded` figure, shown as sent. It reads 0 on legacy
/// notes until mbe-api#277 ships.
@override final  String issued;
/// What is left to spend, as the server reports it. Never recomputed
/// client-side (spec 056 FR-015).
@override final  String remaining;
@override final  DateTime? date;

/// Create a copy of CreditNote
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreditNoteCopyWith<_CreditNote> get copyWith => __$CreditNoteCopyWithImpl<_CreditNote>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreditNote&&(identical(other.id, id) || other.id == id)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.salesOrderId, salesOrderId) || other.salesOrderId == salesOrderId)&&(identical(other.customerRefundId, customerRefundId) || other.customerRefundId == customerRefundId)&&(identical(other.customerPaymentId, customerPaymentId) || other.customerPaymentId == customerPaymentId)&&(identical(other.issued, issued) || other.issued == issued)&&(identical(other.remaining, remaining) || other.remaining == remaining)&&(identical(other.date, date) || other.date == date));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,customerId,salesOrderId,customerRefundId,customerPaymentId,issued,remaining,date);
}

@override
String toString() {
    return 'CreditNote(id: $id, customerId: $customerId, salesOrderId: $salesOrderId, customerRefundId: $customerRefundId, customerPaymentId: $customerPaymentId, issued: $issued, remaining: $remaining, date: $date)';
}


}

/// @nodoc
abstract mixin class _$CreditNoteCopyWith<$Res> implements $CreditNoteCopyWith<$Res> {
  factory _$CreditNoteCopyWith(_CreditNote value, $Res Function(_CreditNote) _then) = __$CreditNoteCopyWithImpl;
@override @useResult
$Res call({
 int id, int customerId, int salesOrderId, int customerRefundId, int customerPaymentId, String issued, String remaining, DateTime? date
});




}
/// @nodoc
class __$CreditNoteCopyWithImpl<$Res>
    implements _$CreditNoteCopyWith<$Res> {
  __$CreditNoteCopyWithImpl(this._self, this._then);

  final _CreditNote _self;
  final $Res Function(_CreditNote) _then;

/// Create a copy of CreditNote
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? customerId = null,Object? salesOrderId = null,Object? customerRefundId = null,Object? customerPaymentId = null,Object? issued = null,Object? remaining = null,Object? date = freezed,}) {
  return _then(_CreditNote(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as int,salesOrderId: null == salesOrderId ? _self.salesOrderId : salesOrderId // ignore: cast_nullable_to_non_nullable
as int,customerRefundId: null == customerRefundId ? _self.customerRefundId : customerRefundId // ignore: cast_nullable_to_non_nullable
as int,customerPaymentId: null == customerPaymentId ? _self.customerPaymentId : customerPaymentId // ignore: cast_nullable_to_non_nullable
as int,issued: null == issued ? _self.issued : issued // ignore: cast_nullable_to_non_nullable
as String,remaining: null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as String,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
