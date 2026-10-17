// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sales_quotes_list_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SalesQuotesFilter {

 SaleStatus? get status; int? get customer; int? get salesperson; String get search; int get pageIndex;
/// Create a copy of SalesQuotesFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SalesQuotesFilterCopyWith<SalesQuotesFilter> get copyWith => _$SalesQuotesFilterCopyWithImpl<SalesQuotesFilter>(this as SalesQuotesFilter, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SalesQuotesFilter;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SalesQuotesFilter&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.customer, _this.customer) || other.customer == _this.customer)&&(identical(other.salesperson, _this.salesperson) || other.salesperson == _this.salesperson)&&(identical(other.search, _this.search) || other.search == _this.search)&&(identical(other.pageIndex, _this.pageIndex) || other.pageIndex == _this.pageIndex));
}


@override
int get hashCode {
  final _this = this as SalesQuotesFilter;
  return Object.hash(runtimeType,_this.status,_this.customer,_this.salesperson,_this.search,_this.pageIndex);
}

@override
String toString() {
  final _this = this as SalesQuotesFilter;
  return 'SalesQuotesFilter(status: ${_this.status}, customer: ${_this.customer}, salesperson: ${_this.salesperson}, search: ${_this.search}, pageIndex: ${_this.pageIndex})';
}


}

/// @nodoc
abstract mixin class $SalesQuotesFilterCopyWith<$Res>  {
  factory $SalesQuotesFilterCopyWith(SalesQuotesFilter value, $Res Function(SalesQuotesFilter) _then) = _$SalesQuotesFilterCopyWithImpl;
@useResult
$Res call({
 SaleStatus? status, int? customer, int? salesperson, String search, int pageIndex
});




}
/// @nodoc
class _$SalesQuotesFilterCopyWithImpl<$Res>
    implements $SalesQuotesFilterCopyWith<$Res> {
  _$SalesQuotesFilterCopyWithImpl(this._self, this._then);

  final SalesQuotesFilter _self;
  final $Res Function(SalesQuotesFilter) _then;

/// Create a copy of SalesQuotesFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = freezed,Object? customer = freezed,Object? salesperson = freezed,Object? search = null,Object? pageIndex = null,}) {
  return _then(SalesQuotesFilter(
status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SaleStatus?,customer: freezed == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as int?,salesperson: freezed == salesperson ? _self.salesperson : salesperson // ignore: cast_nullable_to_non_nullable
as int?,search: null == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SalesQuotesFilter].
extension SalesQuotesFilterPatterns on SalesQuotesFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SalesQuotesFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SalesQuotesFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SalesQuotesFilter value)  $default,){
final _that = this;
switch (_that) {
case _SalesQuotesFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SalesQuotesFilter value)?  $default,){
final _that = this;
switch (_that) {
case _SalesQuotesFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SaleStatus? status,  int? customer,  int? salesperson,  String search,  int pageIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SalesQuotesFilter() when $default != null:
return $default(_that.status,_that.customer,_that.salesperson,_that.search,_that.pageIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SaleStatus? status,  int? customer,  int? salesperson,  String search,  int pageIndex)  $default,) {final _that = this;
switch (_that) {
case _SalesQuotesFilter():
return $default(_that.status,_that.customer,_that.salesperson,_that.search,_that.pageIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SaleStatus? status,  int? customer,  int? salesperson,  String search,  int pageIndex)?  $default,) {final _that = this;
switch (_that) {
case _SalesQuotesFilter() when $default != null:
return $default(_that.status,_that.customer,_that.salesperson,_that.search,_that.pageIndex);case _:
  return null;

}
}

}

/// @nodoc


class _SalesQuotesFilter implements SalesQuotesFilter {
  const _SalesQuotesFilter({this.status, this.customer, this.salesperson, this.search = '', this.pageIndex = 0});
  

@override final  SaleStatus? status;
@override final  int? customer;
@override final  int? salesperson;
@override@JsonKey() final  String search;
@override@JsonKey() final  int pageIndex;

/// Create a copy of SalesQuotesFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SalesQuotesFilterCopyWith<_SalesQuotesFilter> get copyWith => __$SalesQuotesFilterCopyWithImpl<_SalesQuotesFilter>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SalesQuotesFilter&&(identical(other.status, status) || other.status == status)&&(identical(other.customer, customer) || other.customer == customer)&&(identical(other.salesperson, salesperson) || other.salesperson == salesperson)&&(identical(other.search, search) || other.search == search)&&(identical(other.pageIndex, pageIndex) || other.pageIndex == pageIndex));
}


@override
int get hashCode {
    return Object.hash(runtimeType,status,customer,salesperson,search,pageIndex);
}

@override
String toString() {
    return 'SalesQuotesFilter(status: $status, customer: $customer, salesperson: $salesperson, search: $search, pageIndex: $pageIndex)';
}


}

/// @nodoc
abstract mixin class _$SalesQuotesFilterCopyWith<$Res> implements $SalesQuotesFilterCopyWith<$Res> {
  factory _$SalesQuotesFilterCopyWith(_SalesQuotesFilter value, $Res Function(_SalesQuotesFilter) _then) = __$SalesQuotesFilterCopyWithImpl;
@override @useResult
$Res call({
 SaleStatus? status, int? customer, int? salesperson, String search, int pageIndex
});




}
/// @nodoc
class __$SalesQuotesFilterCopyWithImpl<$Res>
    implements _$SalesQuotesFilterCopyWith<$Res> {
  __$SalesQuotesFilterCopyWithImpl(this._self, this._then);

  final _SalesQuotesFilter _self;
  final $Res Function(_SalesQuotesFilter) _then;

/// Create a copy of SalesQuotesFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = freezed,Object? customer = freezed,Object? salesperson = freezed,Object? search = null,Object? pageIndex = null,}) {
  return _then(_SalesQuotesFilter(
status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SaleStatus?,customer: freezed == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as int?,salesperson: freezed == salesperson ? _self.salesperson : salesperson // ignore: cast_nullable_to_non_nullable
as int?,search: null == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
