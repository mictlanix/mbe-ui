// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'supplier_agreement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SupplierAgreement {

 int get supplierAgreementId; int get supplierId; DateTime get start; DateTime get end; String? get comment;
/// Create a copy of SupplierAgreement
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SupplierAgreementCopyWith<SupplierAgreement> get copyWith => _$SupplierAgreementCopyWithImpl<SupplierAgreement>(this as SupplierAgreement, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SupplierAgreement;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SupplierAgreement&&(identical(other.supplierAgreementId, _this.supplierAgreementId) || other.supplierAgreementId == _this.supplierAgreementId)&&(identical(other.supplierId, _this.supplierId) || other.supplierId == _this.supplierId)&&(identical(other.start, _this.start) || other.start == _this.start)&&(identical(other.end, _this.end) || other.end == _this.end)&&(identical(other.comment, _this.comment) || other.comment == _this.comment));
}


@override
int get hashCode {
  final _this = this as SupplierAgreement;
  return Object.hash(runtimeType,_this.supplierAgreementId,_this.supplierId,_this.start,_this.end,_this.comment);
}

@override
String toString() {
  final _this = this as SupplierAgreement;
  return 'SupplierAgreement(supplierAgreementId: ${_this.supplierAgreementId}, supplierId: ${_this.supplierId}, start: ${_this.start}, end: ${_this.end}, comment: ${_this.comment})';
}


}

/// @nodoc
abstract mixin class $SupplierAgreementCopyWith<$Res>  {
  factory $SupplierAgreementCopyWith(SupplierAgreement value, $Res Function(SupplierAgreement) _then) = _$SupplierAgreementCopyWithImpl;
@useResult
$Res call({
 int supplierAgreementId, int supplierId, DateTime start, DateTime end, String? comment
});




}
/// @nodoc
class _$SupplierAgreementCopyWithImpl<$Res>
    implements $SupplierAgreementCopyWith<$Res> {
  _$SupplierAgreementCopyWithImpl(this._self, this._then);

  final SupplierAgreement _self;
  final $Res Function(SupplierAgreement) _then;

/// Create a copy of SupplierAgreement
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? supplierAgreementId = null,Object? supplierId = null,Object? start = null,Object? end = null,Object? comment = freezed,}) {
  return _then(SupplierAgreement(
supplierAgreementId: null == supplierAgreementId ? _self.supplierAgreementId : supplierAgreementId // ignore: cast_nullable_to_non_nullable
as int,supplierId: null == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as int,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as DateTime,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SupplierAgreement].
extension SupplierAgreementPatterns on SupplierAgreement {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SupplierAgreement value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SupplierAgreement() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SupplierAgreement value)  $default,){
final _that = this;
switch (_that) {
case _SupplierAgreement():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SupplierAgreement value)?  $default,){
final _that = this;
switch (_that) {
case _SupplierAgreement() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int supplierAgreementId,  int supplierId,  DateTime start,  DateTime end,  String? comment)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SupplierAgreement() when $default != null:
return $default(_that.supplierAgreementId,_that.supplierId,_that.start,_that.end,_that.comment);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int supplierAgreementId,  int supplierId,  DateTime start,  DateTime end,  String? comment)  $default,) {final _that = this;
switch (_that) {
case _SupplierAgreement():
return $default(_that.supplierAgreementId,_that.supplierId,_that.start,_that.end,_that.comment);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int supplierAgreementId,  int supplierId,  DateTime start,  DateTime end,  String? comment)?  $default,) {final _that = this;
switch (_that) {
case _SupplierAgreement() when $default != null:
return $default(_that.supplierAgreementId,_that.supplierId,_that.start,_that.end,_that.comment);case _:
  return null;

}
}

}

/// @nodoc


class _SupplierAgreement implements SupplierAgreement {
  const _SupplierAgreement({required this.supplierAgreementId, required this.supplierId, required this.start, required this.end, this.comment});
  

@override final  int supplierAgreementId;
@override final  int supplierId;
@override final  DateTime start;
@override final  DateTime end;
@override final  String? comment;

/// Create a copy of SupplierAgreement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SupplierAgreementCopyWith<_SupplierAgreement> get copyWith => __$SupplierAgreementCopyWithImpl<_SupplierAgreement>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SupplierAgreement&&(identical(other.supplierAgreementId, supplierAgreementId) || other.supplierAgreementId == supplierAgreementId)&&(identical(other.supplierId, supplierId) || other.supplierId == supplierId)&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&(identical(other.comment, comment) || other.comment == comment));
}


@override
int get hashCode {
    return Object.hash(runtimeType,supplierAgreementId,supplierId,start,end,comment);
}

@override
String toString() {
    return 'SupplierAgreement(supplierAgreementId: $supplierAgreementId, supplierId: $supplierId, start: $start, end: $end, comment: $comment)';
}


}

/// @nodoc
abstract mixin class _$SupplierAgreementCopyWith<$Res> implements $SupplierAgreementCopyWith<$Res> {
  factory _$SupplierAgreementCopyWith(_SupplierAgreement value, $Res Function(_SupplierAgreement) _then) = __$SupplierAgreementCopyWithImpl;
@override @useResult
$Res call({
 int supplierAgreementId, int supplierId, DateTime start, DateTime end, String? comment
});




}
/// @nodoc
class __$SupplierAgreementCopyWithImpl<$Res>
    implements _$SupplierAgreementCopyWith<$Res> {
  __$SupplierAgreementCopyWithImpl(this._self, this._then);

  final _SupplierAgreement _self;
  final $Res Function(_SupplierAgreement) _then;

/// Create a copy of SupplierAgreement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? supplierAgreementId = null,Object? supplierId = null,Object? start = null,Object? end = null,Object? comment = freezed,}) {
  return _then(_SupplierAgreement(
supplierAgreementId: null == supplierAgreementId ? _self.supplierAgreementId : supplierAgreementId // ignore: cast_nullable_to_non_nullable
as int,supplierId: null == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as int,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as DateTime,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
