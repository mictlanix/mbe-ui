// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_verification_filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VerificationMethodFilter {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is VerificationMethodFilter);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'VerificationMethodFilter()';
}


}

/// @nodoc
class $VerificationMethodFilterCopyWith<$Res>  {
$VerificationMethodFilterCopyWith(VerificationMethodFilter _, $Res Function(VerificationMethodFilter) __);
}


/// Adds pattern-matching-related methods to [VerificationMethodFilter].
extension VerificationMethodFilterPatterns on VerificationMethodFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( VerificationMethodAll value)?  all,TResult Function( VerificationMethodCode value)?  code,required TResult orElse(),}){
final _that = this;
switch (_that) {
case VerificationMethodAll() when all != null:
return all(_that);case VerificationMethodCode() when code != null:
return code(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( VerificationMethodAll value)  all,required TResult Function( VerificationMethodCode value)  code,}){
final _that = this;
switch (_that) {
case VerificationMethodAll():
return all(_that);case VerificationMethodCode():
return code(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( VerificationMethodAll value)?  all,TResult? Function( VerificationMethodCode value)?  code,}){
final _that = this;
switch (_that) {
case VerificationMethodAll() when all != null:
return all(_that);case VerificationMethodCode() when code != null:
return code(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  all,TResult Function( int code)?  code,required TResult orElse(),}) {final _that = this;
switch (_that) {
case VerificationMethodAll() when all != null:
return all();case VerificationMethodCode() when code != null:
return code(_that.code);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  all,required TResult Function( int code)  code,}) {final _that = this;
switch (_that) {
case VerificationMethodAll():
return all();case VerificationMethodCode():
return code(_that.code);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  all,TResult? Function( int code)?  code,}) {final _that = this;
switch (_that) {
case VerificationMethodAll() when all != null:
return all();case VerificationMethodCode() when code != null:
return code(_that.code);case _:
  return null;

}
}

}

/// @nodoc


class VerificationMethodAll implements VerificationMethodFilter {
  const VerificationMethodAll();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is VerificationMethodAll);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'VerificationMethodFilter.all()';
}


}




/// @nodoc


class VerificationMethodCode implements VerificationMethodFilter {
  const VerificationMethodCode(this.code);
  

 final  int code;

/// Create a copy of VerificationMethodFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VerificationMethodCodeCopyWith<VerificationMethodCode> get copyWith => _$VerificationMethodCodeCopyWithImpl<VerificationMethodCode>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is VerificationMethodCode&&(identical(other.code, code) || other.code == code));
}


@override
int get hashCode {
    return Object.hash(runtimeType,code);
}

@override
String toString() {
    return 'VerificationMethodFilter.code(code: $code)';
}


}

/// @nodoc
abstract mixin class $VerificationMethodCodeCopyWith<$Res> implements $VerificationMethodFilterCopyWith<$Res> {
  factory $VerificationMethodCodeCopyWith(VerificationMethodCode value, $Res Function(VerificationMethodCode) _then) = _$VerificationMethodCodeCopyWithImpl;
@useResult
$Res call({
 int code
});




}
/// @nodoc
class _$VerificationMethodCodeCopyWithImpl<$Res>
    implements $VerificationMethodCodeCopyWith<$Res> {
  _$VerificationMethodCodeCopyWithImpl(this._self, this._then);

  final VerificationMethodCode _self;
  final $Res Function(VerificationMethodCode) _then;

/// Create a copy of VerificationMethodFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? code = null,}) {
  return _then(VerificationMethodCode(
null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$PaymentVerificationFilter {

/// `null` is every facility.
 int? get facilityId;/// Both ends or neither: a half-open range is dropped by [fromQuery].
 DateTime? get dateFrom; DateTime? get dateTo; VerificationMethodFilter get method;/// Tri-state (mbe-api#310): `null` lists both, `true` only payments
/// rejected at least once, `false` only those never rejected.
 bool? get rejected; int get pageIndex;
/// Create a copy of PaymentVerificationFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentVerificationFilterCopyWith<PaymentVerificationFilter> get copyWith => _$PaymentVerificationFilterCopyWithImpl<PaymentVerificationFilter>(this as PaymentVerificationFilter, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PaymentVerificationFilter;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentVerificationFilter&&(identical(other.facilityId, _this.facilityId) || other.facilityId == _this.facilityId)&&(identical(other.dateFrom, _this.dateFrom) || other.dateFrom == _this.dateFrom)&&(identical(other.dateTo, _this.dateTo) || other.dateTo == _this.dateTo)&&(identical(other.method, _this.method) || other.method == _this.method)&&(identical(other.rejected, _this.rejected) || other.rejected == _this.rejected)&&(identical(other.pageIndex, _this.pageIndex) || other.pageIndex == _this.pageIndex));
}


@override
int get hashCode {
  final _this = this as PaymentVerificationFilter;
  return Object.hash(runtimeType,_this.facilityId,_this.dateFrom,_this.dateTo,_this.method,_this.rejected,_this.pageIndex);
}

@override
String toString() {
  final _this = this as PaymentVerificationFilter;
  return 'PaymentVerificationFilter(facilityId: ${_this.facilityId}, dateFrom: ${_this.dateFrom}, dateTo: ${_this.dateTo}, method: ${_this.method}, rejected: ${_this.rejected}, pageIndex: ${_this.pageIndex})';
}


}

/// @nodoc
abstract mixin class $PaymentVerificationFilterCopyWith<$Res>  {
  factory $PaymentVerificationFilterCopyWith(PaymentVerificationFilter value, $Res Function(PaymentVerificationFilter) _then) = _$PaymentVerificationFilterCopyWithImpl;
@useResult
$Res call({
 int? facilityId, DateTime? dateFrom, DateTime? dateTo, VerificationMethodFilter method, bool? rejected, int pageIndex
});


$VerificationMethodFilterCopyWith<$Res> get method;

}
/// @nodoc
class _$PaymentVerificationFilterCopyWithImpl<$Res>
    implements $PaymentVerificationFilterCopyWith<$Res> {
  _$PaymentVerificationFilterCopyWithImpl(this._self, this._then);

  final PaymentVerificationFilter _self;
  final $Res Function(PaymentVerificationFilter) _then;

/// Create a copy of PaymentVerificationFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? facilityId = freezed,Object? dateFrom = freezed,Object? dateTo = freezed,Object? method = null,Object? rejected = freezed,Object? pageIndex = null,}) {
  return _then(PaymentVerificationFilter(
facilityId: freezed == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int?,dateFrom: freezed == dateFrom ? _self.dateFrom : dateFrom // ignore: cast_nullable_to_non_nullable
as DateTime?,dateTo: freezed == dateTo ? _self.dateTo : dateTo // ignore: cast_nullable_to_non_nullable
as DateTime?,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as VerificationMethodFilter,rejected: freezed == rejected ? _self.rejected : rejected // ignore: cast_nullable_to_non_nullable
as bool?,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of PaymentVerificationFilter
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VerificationMethodFilterCopyWith<$Res> get method {
  
  return $VerificationMethodFilterCopyWith<$Res>(_self.method, (value) {
    return _then(_self.copyWith(method: value));
  });
}
}


/// Adds pattern-matching-related methods to [PaymentVerificationFilter].
extension PaymentVerificationFilterPatterns on PaymentVerificationFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentVerificationFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentVerificationFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentVerificationFilter value)  $default,){
final _that = this;
switch (_that) {
case _PaymentVerificationFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentVerificationFilter value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentVerificationFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? facilityId,  DateTime? dateFrom,  DateTime? dateTo,  VerificationMethodFilter method,  bool? rejected,  int pageIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentVerificationFilter() when $default != null:
return $default(_that.facilityId,_that.dateFrom,_that.dateTo,_that.method,_that.rejected,_that.pageIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? facilityId,  DateTime? dateFrom,  DateTime? dateTo,  VerificationMethodFilter method,  bool? rejected,  int pageIndex)  $default,) {final _that = this;
switch (_that) {
case _PaymentVerificationFilter():
return $default(_that.facilityId,_that.dateFrom,_that.dateTo,_that.method,_that.rejected,_that.pageIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? facilityId,  DateTime? dateFrom,  DateTime? dateTo,  VerificationMethodFilter method,  bool? rejected,  int pageIndex)?  $default,) {final _that = this;
switch (_that) {
case _PaymentVerificationFilter() when $default != null:
return $default(_that.facilityId,_that.dateFrom,_that.dateTo,_that.method,_that.rejected,_that.pageIndex);case _:
  return null;

}
}

}

/// @nodoc


class _PaymentVerificationFilter extends PaymentVerificationFilter {
  const _PaymentVerificationFilter({this.facilityId, this.dateFrom, this.dateTo, this.method = const VerificationMethodFilter.code(verificationDefaultMethodCode), this.rejected, this.pageIndex = 0}): super._();
  

/// `null` is every facility.
@override final  int? facilityId;
/// Both ends or neither: a half-open range is dropped by [fromQuery].
@override final  DateTime? dateFrom;
@override final  DateTime? dateTo;
@override@JsonKey() final  VerificationMethodFilter method;
/// Tri-state (mbe-api#310): `null` lists both, `true` only payments
/// rejected at least once, `false` only those never rejected.
@override final  bool? rejected;
@override@JsonKey() final  int pageIndex;

/// Create a copy of PaymentVerificationFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentVerificationFilterCopyWith<_PaymentVerificationFilter> get copyWith => __$PaymentVerificationFilterCopyWithImpl<_PaymentVerificationFilter>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentVerificationFilter&&(identical(other.facilityId, facilityId) || other.facilityId == facilityId)&&(identical(other.dateFrom, dateFrom) || other.dateFrom == dateFrom)&&(identical(other.dateTo, dateTo) || other.dateTo == dateTo)&&(identical(other.method, method) || other.method == method)&&(identical(other.rejected, rejected) || other.rejected == rejected)&&(identical(other.pageIndex, pageIndex) || other.pageIndex == pageIndex));
}


@override
int get hashCode {
    return Object.hash(runtimeType,facilityId,dateFrom,dateTo,method,rejected,pageIndex);
}

@override
String toString() {
    return 'PaymentVerificationFilter(facilityId: $facilityId, dateFrom: $dateFrom, dateTo: $dateTo, method: $method, rejected: $rejected, pageIndex: $pageIndex)';
}


}

/// @nodoc
abstract mixin class _$PaymentVerificationFilterCopyWith<$Res> implements $PaymentVerificationFilterCopyWith<$Res> {
  factory _$PaymentVerificationFilterCopyWith(_PaymentVerificationFilter value, $Res Function(_PaymentVerificationFilter) _then) = __$PaymentVerificationFilterCopyWithImpl;
@override @useResult
$Res call({
 int? facilityId, DateTime? dateFrom, DateTime? dateTo, VerificationMethodFilter method, bool? rejected, int pageIndex
});


@override $VerificationMethodFilterCopyWith<$Res> get method;

}
/// @nodoc
class __$PaymentVerificationFilterCopyWithImpl<$Res>
    implements _$PaymentVerificationFilterCopyWith<$Res> {
  __$PaymentVerificationFilterCopyWithImpl(this._self, this._then);

  final _PaymentVerificationFilter _self;
  final $Res Function(_PaymentVerificationFilter) _then;

/// Create a copy of PaymentVerificationFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? facilityId = freezed,Object? dateFrom = freezed,Object? dateTo = freezed,Object? method = null,Object? rejected = freezed,Object? pageIndex = null,}) {
  return _then(_PaymentVerificationFilter(
facilityId: freezed == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int?,dateFrom: freezed == dateFrom ? _self.dateFrom : dateFrom // ignore: cast_nullable_to_non_nullable
as DateTime?,dateTo: freezed == dateTo ? _self.dateTo : dateTo // ignore: cast_nullable_to_non_nullable
as DateTime?,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as VerificationMethodFilter,rejected: freezed == rejected ? _self.rejected : rejected // ignore: cast_nullable_to_non_nullable
as bool?,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of PaymentVerificationFilter
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VerificationMethodFilterCopyWith<$Res> get method {
  
  return $VerificationMethodFilterCopyWith<$Res>(_self.method, (value) {
    return _then(_self.copyWith(method: value));
  });
}
}

// dart format on
