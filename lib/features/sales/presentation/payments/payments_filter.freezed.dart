// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payments_filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PaymentsFilter {

 PaymentsScope get scope; int? get customerId;/// Both ends or neither: a half-open range is dropped by [fromQuery], so
/// the date chip never has to show one.
 DateTime? get dateFrom; DateTime? get dateTo; int? get methodCode;/// Tri-state (FR-007): `null` lists any, `true` only verified, `false`
/// only unverified.
 bool? get verified; int? get cashSessionId;/// A fragment of the payment's reference — all-facilities mode only,
/// where it is the search box. Carried in `ListQuery.search`.
 String? get reference; int get pageIndex;
/// Create a copy of PaymentsFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentsFilterCopyWith<PaymentsFilter> get copyWith => _$PaymentsFilterCopyWithImpl<PaymentsFilter>(this as PaymentsFilter, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PaymentsFilter;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentsFilter&&(identical(other.scope, _this.scope) || other.scope == _this.scope)&&(identical(other.customerId, _this.customerId) || other.customerId == _this.customerId)&&(identical(other.dateFrom, _this.dateFrom) || other.dateFrom == _this.dateFrom)&&(identical(other.dateTo, _this.dateTo) || other.dateTo == _this.dateTo)&&(identical(other.methodCode, _this.methodCode) || other.methodCode == _this.methodCode)&&(identical(other.verified, _this.verified) || other.verified == _this.verified)&&(identical(other.cashSessionId, _this.cashSessionId) || other.cashSessionId == _this.cashSessionId)&&(identical(other.reference, _this.reference) || other.reference == _this.reference)&&(identical(other.pageIndex, _this.pageIndex) || other.pageIndex == _this.pageIndex));
}


@override
int get hashCode {
  final _this = this as PaymentsFilter;
  return Object.hash(runtimeType,_this.scope,_this.customerId,_this.dateFrom,_this.dateTo,_this.methodCode,_this.verified,_this.cashSessionId,_this.reference,_this.pageIndex);
}

@override
String toString() {
  final _this = this as PaymentsFilter;
  return 'PaymentsFilter(scope: ${_this.scope}, customerId: ${_this.customerId}, dateFrom: ${_this.dateFrom}, dateTo: ${_this.dateTo}, methodCode: ${_this.methodCode}, verified: ${_this.verified}, cashSessionId: ${_this.cashSessionId}, reference: ${_this.reference}, pageIndex: ${_this.pageIndex})';
}


}

/// @nodoc
abstract mixin class $PaymentsFilterCopyWith<$Res>  {
  factory $PaymentsFilterCopyWith(PaymentsFilter value, $Res Function(PaymentsFilter) _then) = _$PaymentsFilterCopyWithImpl;
@useResult
$Res call({
 PaymentsScope scope, int? customerId, DateTime? dateFrom, DateTime? dateTo, int? methodCode, bool? verified, int? cashSessionId, String? reference, int pageIndex
});




}
/// @nodoc
class _$PaymentsFilterCopyWithImpl<$Res>
    implements $PaymentsFilterCopyWith<$Res> {
  _$PaymentsFilterCopyWithImpl(this._self, this._then);

  final PaymentsFilter _self;
  final $Res Function(PaymentsFilter) _then;

/// Create a copy of PaymentsFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? scope = null,Object? customerId = freezed,Object? dateFrom = freezed,Object? dateTo = freezed,Object? methodCode = freezed,Object? verified = freezed,Object? cashSessionId = freezed,Object? reference = freezed,Object? pageIndex = null,}) {
  return _then(PaymentsFilter(
scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as PaymentsScope,customerId: freezed == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as int?,dateFrom: freezed == dateFrom ? _self.dateFrom : dateFrom // ignore: cast_nullable_to_non_nullable
as DateTime?,dateTo: freezed == dateTo ? _self.dateTo : dateTo // ignore: cast_nullable_to_non_nullable
as DateTime?,methodCode: freezed == methodCode ? _self.methodCode : methodCode // ignore: cast_nullable_to_non_nullable
as int?,verified: freezed == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as bool?,cashSessionId: freezed == cashSessionId ? _self.cashSessionId : cashSessionId // ignore: cast_nullable_to_non_nullable
as int?,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentsFilter].
extension PaymentsFilterPatterns on PaymentsFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentsFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentsFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentsFilter value)  $default,){
final _that = this;
switch (_that) {
case _PaymentsFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentsFilter value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentsFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PaymentsScope scope,  int? customerId,  DateTime? dateFrom,  DateTime? dateTo,  int? methodCode,  bool? verified,  int? cashSessionId,  String? reference,  int pageIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentsFilter() when $default != null:
return $default(_that.scope,_that.customerId,_that.dateFrom,_that.dateTo,_that.methodCode,_that.verified,_that.cashSessionId,_that.reference,_that.pageIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PaymentsScope scope,  int? customerId,  DateTime? dateFrom,  DateTime? dateTo,  int? methodCode,  bool? verified,  int? cashSessionId,  String? reference,  int pageIndex)  $default,) {final _that = this;
switch (_that) {
case _PaymentsFilter():
return $default(_that.scope,_that.customerId,_that.dateFrom,_that.dateTo,_that.methodCode,_that.verified,_that.cashSessionId,_that.reference,_that.pageIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PaymentsScope scope,  int? customerId,  DateTime? dateFrom,  DateTime? dateTo,  int? methodCode,  bool? verified,  int? cashSessionId,  String? reference,  int pageIndex)?  $default,) {final _that = this;
switch (_that) {
case _PaymentsFilter() when $default != null:
return $default(_that.scope,_that.customerId,_that.dateFrom,_that.dateTo,_that.methodCode,_that.verified,_that.cashSessionId,_that.reference,_that.pageIndex);case _:
  return null;

}
}

}

/// @nodoc


class _PaymentsFilter extends PaymentsFilter {
  const _PaymentsFilter({this.scope = PaymentsScope.facility, this.customerId, this.dateFrom, this.dateTo, this.methodCode, this.verified, this.cashSessionId, this.reference, this.pageIndex = 0}): super._();
  

@override@JsonKey() final  PaymentsScope scope;
@override final  int? customerId;
/// Both ends or neither: a half-open range is dropped by [fromQuery], so
/// the date chip never has to show one.
@override final  DateTime? dateFrom;
@override final  DateTime? dateTo;
@override final  int? methodCode;
/// Tri-state (FR-007): `null` lists any, `true` only verified, `false`
/// only unverified.
@override final  bool? verified;
@override final  int? cashSessionId;
/// A fragment of the payment's reference — all-facilities mode only,
/// where it is the search box. Carried in `ListQuery.search`.
@override final  String? reference;
@override@JsonKey() final  int pageIndex;

/// Create a copy of PaymentsFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentsFilterCopyWith<_PaymentsFilter> get copyWith => __$PaymentsFilterCopyWithImpl<_PaymentsFilter>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentsFilter&&(identical(other.scope, scope) || other.scope == scope)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.dateFrom, dateFrom) || other.dateFrom == dateFrom)&&(identical(other.dateTo, dateTo) || other.dateTo == dateTo)&&(identical(other.methodCode, methodCode) || other.methodCode == methodCode)&&(identical(other.verified, verified) || other.verified == verified)&&(identical(other.cashSessionId, cashSessionId) || other.cashSessionId == cashSessionId)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.pageIndex, pageIndex) || other.pageIndex == pageIndex));
}


@override
int get hashCode {
    return Object.hash(runtimeType,scope,customerId,dateFrom,dateTo,methodCode,verified,cashSessionId,reference,pageIndex);
}

@override
String toString() {
    return 'PaymentsFilter(scope: $scope, customerId: $customerId, dateFrom: $dateFrom, dateTo: $dateTo, methodCode: $methodCode, verified: $verified, cashSessionId: $cashSessionId, reference: $reference, pageIndex: $pageIndex)';
}


}

/// @nodoc
abstract mixin class _$PaymentsFilterCopyWith<$Res> implements $PaymentsFilterCopyWith<$Res> {
  factory _$PaymentsFilterCopyWith(_PaymentsFilter value, $Res Function(_PaymentsFilter) _then) = __$PaymentsFilterCopyWithImpl;
@override @useResult
$Res call({
 PaymentsScope scope, int? customerId, DateTime? dateFrom, DateTime? dateTo, int? methodCode, bool? verified, int? cashSessionId, String? reference, int pageIndex
});




}
/// @nodoc
class __$PaymentsFilterCopyWithImpl<$Res>
    implements _$PaymentsFilterCopyWith<$Res> {
  __$PaymentsFilterCopyWithImpl(this._self, this._then);

  final _PaymentsFilter _self;
  final $Res Function(_PaymentsFilter) _then;

/// Create a copy of PaymentsFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? scope = null,Object? customerId = freezed,Object? dateFrom = freezed,Object? dateTo = freezed,Object? methodCode = freezed,Object? verified = freezed,Object? cashSessionId = freezed,Object? reference = freezed,Object? pageIndex = null,}) {
  return _then(_PaymentsFilter(
scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as PaymentsScope,customerId: freezed == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as int?,dateFrom: freezed == dateFrom ? _self.dateFrom : dateFrom // ignore: cast_nullable_to_non_nullable
as DateTime?,dateTo: freezed == dateTo ? _self.dateTo : dateTo // ignore: cast_nullable_to_non_nullable
as DateTime?,methodCode: freezed == methodCode ? _self.methodCode : methodCode // ignore: cast_nullable_to_non_nullable
as int?,verified: freezed == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as bool?,cashSessionId: freezed == cashSessionId ? _self.cashSessionId : cashSessionId // ignore: cast_nullable_to_non_nullable
as int?,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
