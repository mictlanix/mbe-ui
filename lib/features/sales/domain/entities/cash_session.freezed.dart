// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cash_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CashSession {

 int get cashSessionId; int get cashDrawerId; String get cashDrawerName; String get cashDrawerCode;/// The drawer's facility — a session has no facility column of its own,
/// so this is the only way to tell which facility it belongs to (spec 054
/// research R7). `null` only for a hand-built value; `fromResponse` always
/// sets it, and a `null` never counts as the user's facility.
 int? get cashDrawerFacilityId; int get cashierId; String get cashierName; DateTime get start; DateTime? get end; int? get cashSupervisorId; String? get cashSupervisorName; String get openingAmount; List<PaymentMethodTotal> get paymentsByMethod;
/// Create a copy of CashSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CashSessionCopyWith<CashSession> get copyWith => _$CashSessionCopyWithImpl<CashSession>(this as CashSession, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CashSession;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CashSession&&(identical(other.cashSessionId, _this.cashSessionId) || other.cashSessionId == _this.cashSessionId)&&(identical(other.cashDrawerId, _this.cashDrawerId) || other.cashDrawerId == _this.cashDrawerId)&&(identical(other.cashDrawerName, _this.cashDrawerName) || other.cashDrawerName == _this.cashDrawerName)&&(identical(other.cashDrawerCode, _this.cashDrawerCode) || other.cashDrawerCode == _this.cashDrawerCode)&&(identical(other.cashDrawerFacilityId, _this.cashDrawerFacilityId) || other.cashDrawerFacilityId == _this.cashDrawerFacilityId)&&(identical(other.cashierId, _this.cashierId) || other.cashierId == _this.cashierId)&&(identical(other.cashierName, _this.cashierName) || other.cashierName == _this.cashierName)&&(identical(other.start, _this.start) || other.start == _this.start)&&(identical(other.end, _this.end) || other.end == _this.end)&&(identical(other.cashSupervisorId, _this.cashSupervisorId) || other.cashSupervisorId == _this.cashSupervisorId)&&(identical(other.cashSupervisorName, _this.cashSupervisorName) || other.cashSupervisorName == _this.cashSupervisorName)&&(identical(other.openingAmount, _this.openingAmount) || other.openingAmount == _this.openingAmount)&&const DeepCollectionEquality().equals(other.paymentsByMethod, _this.paymentsByMethod));
}


@override
int get hashCode {
  final _this = this as CashSession;
  return Object.hash(runtimeType,_this.cashSessionId,_this.cashDrawerId,_this.cashDrawerName,_this.cashDrawerCode,_this.cashDrawerFacilityId,_this.cashierId,_this.cashierName,_this.start,_this.end,_this.cashSupervisorId,_this.cashSupervisorName,_this.openingAmount,const DeepCollectionEquality().hash(_this.paymentsByMethod));
}

@override
String toString() {
  final _this = this as CashSession;
  return 'CashSession(cashSessionId: ${_this.cashSessionId}, cashDrawerId: ${_this.cashDrawerId}, cashDrawerName: ${_this.cashDrawerName}, cashDrawerCode: ${_this.cashDrawerCode}, cashDrawerFacilityId: ${_this.cashDrawerFacilityId}, cashierId: ${_this.cashierId}, cashierName: ${_this.cashierName}, start: ${_this.start}, end: ${_this.end}, cashSupervisorId: ${_this.cashSupervisorId}, cashSupervisorName: ${_this.cashSupervisorName}, openingAmount: ${_this.openingAmount}, paymentsByMethod: ${_this.paymentsByMethod})';
}


}

/// @nodoc
abstract mixin class $CashSessionCopyWith<$Res>  {
  factory $CashSessionCopyWith(CashSession value, $Res Function(CashSession) _then) = _$CashSessionCopyWithImpl;
@useResult
$Res call({
 int cashSessionId, int cashDrawerId, String cashDrawerName, String cashDrawerCode, int? cashDrawerFacilityId, int cashierId, String cashierName, DateTime start, DateTime? end, int? cashSupervisorId, String? cashSupervisorName, String openingAmount, List<PaymentMethodTotal> paymentsByMethod
});




}
/// @nodoc
class _$CashSessionCopyWithImpl<$Res>
    implements $CashSessionCopyWith<$Res> {
  _$CashSessionCopyWithImpl(this._self, this._then);

  final CashSession _self;
  final $Res Function(CashSession) _then;

/// Create a copy of CashSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cashSessionId = null,Object? cashDrawerId = null,Object? cashDrawerName = null,Object? cashDrawerCode = null,Object? cashDrawerFacilityId = freezed,Object? cashierId = null,Object? cashierName = null,Object? start = null,Object? end = freezed,Object? cashSupervisorId = freezed,Object? cashSupervisorName = freezed,Object? openingAmount = null,Object? paymentsByMethod = null,}) {
  return _then(CashSession(
cashSessionId: null == cashSessionId ? _self.cashSessionId : cashSessionId // ignore: cast_nullable_to_non_nullable
as int,cashDrawerId: null == cashDrawerId ? _self.cashDrawerId : cashDrawerId // ignore: cast_nullable_to_non_nullable
as int,cashDrawerName: null == cashDrawerName ? _self.cashDrawerName : cashDrawerName // ignore: cast_nullable_to_non_nullable
as String,cashDrawerCode: null == cashDrawerCode ? _self.cashDrawerCode : cashDrawerCode // ignore: cast_nullable_to_non_nullable
as String,cashDrawerFacilityId: freezed == cashDrawerFacilityId ? _self.cashDrawerFacilityId : cashDrawerFacilityId // ignore: cast_nullable_to_non_nullable
as int?,cashierId: null == cashierId ? _self.cashierId : cashierId // ignore: cast_nullable_to_non_nullable
as int,cashierName: null == cashierName ? _self.cashierName : cashierName // ignore: cast_nullable_to_non_nullable
as String,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime,end: freezed == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as DateTime?,cashSupervisorId: freezed == cashSupervisorId ? _self.cashSupervisorId : cashSupervisorId // ignore: cast_nullable_to_non_nullable
as int?,cashSupervisorName: freezed == cashSupervisorName ? _self.cashSupervisorName : cashSupervisorName // ignore: cast_nullable_to_non_nullable
as String?,openingAmount: null == openingAmount ? _self.openingAmount : openingAmount // ignore: cast_nullable_to_non_nullable
as String,paymentsByMethod: null == paymentsByMethod ? _self.paymentsByMethod : paymentsByMethod // ignore: cast_nullable_to_non_nullable
as List<PaymentMethodTotal>,
  ));
}

}


/// Adds pattern-matching-related methods to [CashSession].
extension CashSessionPatterns on CashSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CashSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CashSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CashSession value)  $default,){
final _that = this;
switch (_that) {
case _CashSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CashSession value)?  $default,){
final _that = this;
switch (_that) {
case _CashSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int cashSessionId,  int cashDrawerId,  String cashDrawerName,  String cashDrawerCode,  int? cashDrawerFacilityId,  int cashierId,  String cashierName,  DateTime start,  DateTime? end,  int? cashSupervisorId,  String? cashSupervisorName,  String openingAmount,  List<PaymentMethodTotal> paymentsByMethod)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CashSession() when $default != null:
return $default(_that.cashSessionId,_that.cashDrawerId,_that.cashDrawerName,_that.cashDrawerCode,_that.cashDrawerFacilityId,_that.cashierId,_that.cashierName,_that.start,_that.end,_that.cashSupervisorId,_that.cashSupervisorName,_that.openingAmount,_that.paymentsByMethod);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int cashSessionId,  int cashDrawerId,  String cashDrawerName,  String cashDrawerCode,  int? cashDrawerFacilityId,  int cashierId,  String cashierName,  DateTime start,  DateTime? end,  int? cashSupervisorId,  String? cashSupervisorName,  String openingAmount,  List<PaymentMethodTotal> paymentsByMethod)  $default,) {final _that = this;
switch (_that) {
case _CashSession():
return $default(_that.cashSessionId,_that.cashDrawerId,_that.cashDrawerName,_that.cashDrawerCode,_that.cashDrawerFacilityId,_that.cashierId,_that.cashierName,_that.start,_that.end,_that.cashSupervisorId,_that.cashSupervisorName,_that.openingAmount,_that.paymentsByMethod);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int cashSessionId,  int cashDrawerId,  String cashDrawerName,  String cashDrawerCode,  int? cashDrawerFacilityId,  int cashierId,  String cashierName,  DateTime start,  DateTime? end,  int? cashSupervisorId,  String? cashSupervisorName,  String openingAmount,  List<PaymentMethodTotal> paymentsByMethod)?  $default,) {final _that = this;
switch (_that) {
case _CashSession() when $default != null:
return $default(_that.cashSessionId,_that.cashDrawerId,_that.cashDrawerName,_that.cashDrawerCode,_that.cashDrawerFacilityId,_that.cashierId,_that.cashierName,_that.start,_that.end,_that.cashSupervisorId,_that.cashSupervisorName,_that.openingAmount,_that.paymentsByMethod);case _:
  return null;

}
}

}

/// @nodoc


class _CashSession implements CashSession {
  const _CashSession({required this.cashSessionId, required this.cashDrawerId, required this.cashDrawerName, required this.cashDrawerCode, this.cashDrawerFacilityId, required this.cashierId, required this.cashierName, required this.start, this.end, this.cashSupervisorId, this.cashSupervisorName, required this.openingAmount,  List<PaymentMethodTotal> paymentsByMethod = const <PaymentMethodTotal>[]}): _paymentsByMethod = paymentsByMethod;
  

@override final  int cashSessionId;
@override final  int cashDrawerId;
@override final  String cashDrawerName;
@override final  String cashDrawerCode;
/// The drawer's facility — a session has no facility column of its own,
/// so this is the only way to tell which facility it belongs to (spec 054
/// research R7). `null` only for a hand-built value; `fromResponse` always
/// sets it, and a `null` never counts as the user's facility.
@override final  int? cashDrawerFacilityId;
@override final  int cashierId;
@override final  String cashierName;
@override final  DateTime start;
@override final  DateTime? end;
@override final  int? cashSupervisorId;
@override final  String? cashSupervisorName;
@override final  String openingAmount;
 final  List<PaymentMethodTotal> _paymentsByMethod;
@override@JsonKey() List<PaymentMethodTotal> get paymentsByMethod {
  if (_paymentsByMethod is EqualUnmodifiableListView) return _paymentsByMethod;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_paymentsByMethod);
}


/// Create a copy of CashSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CashSessionCopyWith<_CashSession> get copyWith => __$CashSessionCopyWithImpl<_CashSession>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CashSession&&(identical(other.cashSessionId, cashSessionId) || other.cashSessionId == cashSessionId)&&(identical(other.cashDrawerId, cashDrawerId) || other.cashDrawerId == cashDrawerId)&&(identical(other.cashDrawerName, cashDrawerName) || other.cashDrawerName == cashDrawerName)&&(identical(other.cashDrawerCode, cashDrawerCode) || other.cashDrawerCode == cashDrawerCode)&&(identical(other.cashDrawerFacilityId, cashDrawerFacilityId) || other.cashDrawerFacilityId == cashDrawerFacilityId)&&(identical(other.cashierId, cashierId) || other.cashierId == cashierId)&&(identical(other.cashierName, cashierName) || other.cashierName == cashierName)&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&(identical(other.cashSupervisorId, cashSupervisorId) || other.cashSupervisorId == cashSupervisorId)&&(identical(other.cashSupervisorName, cashSupervisorName) || other.cashSupervisorName == cashSupervisorName)&&(identical(other.openingAmount, openingAmount) || other.openingAmount == openingAmount)&&const DeepCollectionEquality().equals(other.paymentsByMethod, _paymentsByMethod));
}


@override
int get hashCode {
    return Object.hash(runtimeType,cashSessionId,cashDrawerId,cashDrawerName,cashDrawerCode,cashDrawerFacilityId,cashierId,cashierName,start,end,cashSupervisorId,cashSupervisorName,openingAmount,const DeepCollectionEquality().hash(_paymentsByMethod));
}

@override
String toString() {
    return 'CashSession(cashSessionId: $cashSessionId, cashDrawerId: $cashDrawerId, cashDrawerName: $cashDrawerName, cashDrawerCode: $cashDrawerCode, cashDrawerFacilityId: $cashDrawerFacilityId, cashierId: $cashierId, cashierName: $cashierName, start: $start, end: $end, cashSupervisorId: $cashSupervisorId, cashSupervisorName: $cashSupervisorName, openingAmount: $openingAmount, paymentsByMethod: $paymentsByMethod)';
}


}

/// @nodoc
abstract mixin class _$CashSessionCopyWith<$Res> implements $CashSessionCopyWith<$Res> {
  factory _$CashSessionCopyWith(_CashSession value, $Res Function(_CashSession) _then) = __$CashSessionCopyWithImpl;
@override @useResult
$Res call({
 int cashSessionId, int cashDrawerId, String cashDrawerName, String cashDrawerCode, int? cashDrawerFacilityId, int cashierId, String cashierName, DateTime start, DateTime? end, int? cashSupervisorId, String? cashSupervisorName, String openingAmount, List<PaymentMethodTotal> paymentsByMethod
});




}
/// @nodoc
class __$CashSessionCopyWithImpl<$Res>
    implements _$CashSessionCopyWith<$Res> {
  __$CashSessionCopyWithImpl(this._self, this._then);

  final _CashSession _self;
  final $Res Function(_CashSession) _then;

/// Create a copy of CashSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cashSessionId = null,Object? cashDrawerId = null,Object? cashDrawerName = null,Object? cashDrawerCode = null,Object? cashDrawerFacilityId = freezed,Object? cashierId = null,Object? cashierName = null,Object? start = null,Object? end = freezed,Object? cashSupervisorId = freezed,Object? cashSupervisorName = freezed,Object? openingAmount = null,Object? paymentsByMethod = null,}) {
  return _then(_CashSession(
cashSessionId: null == cashSessionId ? _self.cashSessionId : cashSessionId // ignore: cast_nullable_to_non_nullable
as int,cashDrawerId: null == cashDrawerId ? _self.cashDrawerId : cashDrawerId // ignore: cast_nullable_to_non_nullable
as int,cashDrawerName: null == cashDrawerName ? _self.cashDrawerName : cashDrawerName // ignore: cast_nullable_to_non_nullable
as String,cashDrawerCode: null == cashDrawerCode ? _self.cashDrawerCode : cashDrawerCode // ignore: cast_nullable_to_non_nullable
as String,cashDrawerFacilityId: freezed == cashDrawerFacilityId ? _self.cashDrawerFacilityId : cashDrawerFacilityId // ignore: cast_nullable_to_non_nullable
as int?,cashierId: null == cashierId ? _self.cashierId : cashierId // ignore: cast_nullable_to_non_nullable
as int,cashierName: null == cashierName ? _self.cashierName : cashierName // ignore: cast_nullable_to_non_nullable
as String,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime,end: freezed == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as DateTime?,cashSupervisorId: freezed == cashSupervisorId ? _self.cashSupervisorId : cashSupervisorId // ignore: cast_nullable_to_non_nullable
as int?,cashSupervisorName: freezed == cashSupervisorName ? _self.cashSupervisorName : cashSupervisorName // ignore: cast_nullable_to_non_nullable
as String?,openingAmount: null == openingAmount ? _self.openingAmount : openingAmount // ignore: cast_nullable_to_non_nullable
as String,paymentsByMethod: null == paymentsByMethod ? _self._paymentsByMethod : paymentsByMethod // ignore: cast_nullable_to_non_nullable
as List<PaymentMethodTotal>,
  ));
}


}

/// @nodoc
mixin _$PaymentMethodTotal {

 int get method; String get total;
/// Create a copy of PaymentMethodTotal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentMethodTotalCopyWith<PaymentMethodTotal> get copyWith => _$PaymentMethodTotalCopyWithImpl<PaymentMethodTotal>(this as PaymentMethodTotal, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PaymentMethodTotal;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentMethodTotal&&(identical(other.method, _this.method) || other.method == _this.method)&&(identical(other.total, _this.total) || other.total == _this.total));
}


@override
int get hashCode {
  final _this = this as PaymentMethodTotal;
  return Object.hash(runtimeType,_this.method,_this.total);
}

@override
String toString() {
  final _this = this as PaymentMethodTotal;
  return 'PaymentMethodTotal(method: ${_this.method}, total: ${_this.total})';
}


}

/// @nodoc
abstract mixin class $PaymentMethodTotalCopyWith<$Res>  {
  factory $PaymentMethodTotalCopyWith(PaymentMethodTotal value, $Res Function(PaymentMethodTotal) _then) = _$PaymentMethodTotalCopyWithImpl;
@useResult
$Res call({
 int method, String total
});




}
/// @nodoc
class _$PaymentMethodTotalCopyWithImpl<$Res>
    implements $PaymentMethodTotalCopyWith<$Res> {
  _$PaymentMethodTotalCopyWithImpl(this._self, this._then);

  final PaymentMethodTotal _self;
  final $Res Function(PaymentMethodTotal) _then;

/// Create a copy of PaymentMethodTotal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? method = null,Object? total = null,}) {
  return _then(PaymentMethodTotal(
method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentMethodTotal].
extension PaymentMethodTotalPatterns on PaymentMethodTotal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentMethodTotal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentMethodTotal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentMethodTotal value)  $default,){
final _that = this;
switch (_that) {
case _PaymentMethodTotal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentMethodTotal value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentMethodTotal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int method,  String total)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentMethodTotal() when $default != null:
return $default(_that.method,_that.total);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int method,  String total)  $default,) {final _that = this;
switch (_that) {
case _PaymentMethodTotal():
return $default(_that.method,_that.total);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int method,  String total)?  $default,) {final _that = this;
switch (_that) {
case _PaymentMethodTotal() when $default != null:
return $default(_that.method,_that.total);case _:
  return null;

}
}

}

/// @nodoc


class _PaymentMethodTotal implements PaymentMethodTotal {
  const _PaymentMethodTotal({required this.method, required this.total});
  

@override final  int method;
@override final  String total;

/// Create a copy of PaymentMethodTotal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentMethodTotalCopyWith<_PaymentMethodTotal> get copyWith => __$PaymentMethodTotalCopyWithImpl<_PaymentMethodTotal>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentMethodTotal&&(identical(other.method, method) || other.method == method)&&(identical(other.total, total) || other.total == total));
}


@override
int get hashCode {
    return Object.hash(runtimeType,method,total);
}

@override
String toString() {
    return 'PaymentMethodTotal(method: $method, total: $total)';
}


}

/// @nodoc
abstract mixin class _$PaymentMethodTotalCopyWith<$Res> implements $PaymentMethodTotalCopyWith<$Res> {
  factory _$PaymentMethodTotalCopyWith(_PaymentMethodTotal value, $Res Function(_PaymentMethodTotal) _then) = __$PaymentMethodTotalCopyWithImpl;
@override @useResult
$Res call({
 int method, String total
});




}
/// @nodoc
class __$PaymentMethodTotalCopyWithImpl<$Res>
    implements _$PaymentMethodTotalCopyWith<$Res> {
  __$PaymentMethodTotalCopyWithImpl(this._self, this._then);

  final _PaymentMethodTotal _self;
  final $Res Function(_PaymentMethodTotal) _then;

/// Create a copy of PaymentMethodTotal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? method = null,Object? total = null,}) {
  return _then(_PaymentMethodTotal(
method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
