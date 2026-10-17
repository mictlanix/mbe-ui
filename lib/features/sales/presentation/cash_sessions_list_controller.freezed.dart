// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cash_sessions_list_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CashSessionFilter {

 int? get cashDrawerId; int? get cashierId; CashSessionStatus? get status; int get pageIndex;
/// Create a copy of CashSessionFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CashSessionFilterCopyWith<CashSessionFilter> get copyWith => _$CashSessionFilterCopyWithImpl<CashSessionFilter>(this as CashSessionFilter, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CashSessionFilter;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CashSessionFilter&&(identical(other.cashDrawerId, _this.cashDrawerId) || other.cashDrawerId == _this.cashDrawerId)&&(identical(other.cashierId, _this.cashierId) || other.cashierId == _this.cashierId)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.pageIndex, _this.pageIndex) || other.pageIndex == _this.pageIndex));
}


@override
int get hashCode {
  final _this = this as CashSessionFilter;
  return Object.hash(runtimeType,_this.cashDrawerId,_this.cashierId,_this.status,_this.pageIndex);
}

@override
String toString() {
  final _this = this as CashSessionFilter;
  return 'CashSessionFilter(cashDrawerId: ${_this.cashDrawerId}, cashierId: ${_this.cashierId}, status: ${_this.status}, pageIndex: ${_this.pageIndex})';
}


}

/// @nodoc
abstract mixin class $CashSessionFilterCopyWith<$Res>  {
  factory $CashSessionFilterCopyWith(CashSessionFilter value, $Res Function(CashSessionFilter) _then) = _$CashSessionFilterCopyWithImpl;
@useResult
$Res call({
 int? cashDrawerId, int? cashierId, CashSessionStatus? status, int pageIndex
});




}
/// @nodoc
class _$CashSessionFilterCopyWithImpl<$Res>
    implements $CashSessionFilterCopyWith<$Res> {
  _$CashSessionFilterCopyWithImpl(this._self, this._then);

  final CashSessionFilter _self;
  final $Res Function(CashSessionFilter) _then;

/// Create a copy of CashSessionFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cashDrawerId = freezed,Object? cashierId = freezed,Object? status = freezed,Object? pageIndex = null,}) {
  return _then(CashSessionFilter(
cashDrawerId: freezed == cashDrawerId ? _self.cashDrawerId : cashDrawerId // ignore: cast_nullable_to_non_nullable
as int?,cashierId: freezed == cashierId ? _self.cashierId : cashierId // ignore: cast_nullable_to_non_nullable
as int?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CashSessionStatus?,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CashSessionFilter].
extension CashSessionFilterPatterns on CashSessionFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CashSessionFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CashSessionFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CashSessionFilter value)  $default,){
final _that = this;
switch (_that) {
case _CashSessionFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CashSessionFilter value)?  $default,){
final _that = this;
switch (_that) {
case _CashSessionFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? cashDrawerId,  int? cashierId,  CashSessionStatus? status,  int pageIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CashSessionFilter() when $default != null:
return $default(_that.cashDrawerId,_that.cashierId,_that.status,_that.pageIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? cashDrawerId,  int? cashierId,  CashSessionStatus? status,  int pageIndex)  $default,) {final _that = this;
switch (_that) {
case _CashSessionFilter():
return $default(_that.cashDrawerId,_that.cashierId,_that.status,_that.pageIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? cashDrawerId,  int? cashierId,  CashSessionStatus? status,  int pageIndex)?  $default,) {final _that = this;
switch (_that) {
case _CashSessionFilter() when $default != null:
return $default(_that.cashDrawerId,_that.cashierId,_that.status,_that.pageIndex);case _:
  return null;

}
}

}

/// @nodoc


class _CashSessionFilter implements CashSessionFilter {
  const _CashSessionFilter({this.cashDrawerId, this.cashierId, this.status, this.pageIndex = 0});
  

@override final  int? cashDrawerId;
@override final  int? cashierId;
@override final  CashSessionStatus? status;
@override@JsonKey() final  int pageIndex;

/// Create a copy of CashSessionFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CashSessionFilterCopyWith<_CashSessionFilter> get copyWith => __$CashSessionFilterCopyWithImpl<_CashSessionFilter>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CashSessionFilter&&(identical(other.cashDrawerId, cashDrawerId) || other.cashDrawerId == cashDrawerId)&&(identical(other.cashierId, cashierId) || other.cashierId == cashierId)&&(identical(other.status, status) || other.status == status)&&(identical(other.pageIndex, pageIndex) || other.pageIndex == pageIndex));
}


@override
int get hashCode {
    return Object.hash(runtimeType,cashDrawerId,cashierId,status,pageIndex);
}

@override
String toString() {
    return 'CashSessionFilter(cashDrawerId: $cashDrawerId, cashierId: $cashierId, status: $status, pageIndex: $pageIndex)';
}


}

/// @nodoc
abstract mixin class _$CashSessionFilterCopyWith<$Res> implements $CashSessionFilterCopyWith<$Res> {
  factory _$CashSessionFilterCopyWith(_CashSessionFilter value, $Res Function(_CashSessionFilter) _then) = __$CashSessionFilterCopyWithImpl;
@override @useResult
$Res call({
 int? cashDrawerId, int? cashierId, CashSessionStatus? status, int pageIndex
});




}
/// @nodoc
class __$CashSessionFilterCopyWithImpl<$Res>
    implements _$CashSessionFilterCopyWith<$Res> {
  __$CashSessionFilterCopyWithImpl(this._self, this._then);

  final _CashSessionFilter _self;
  final $Res Function(_CashSessionFilter) _then;

/// Create a copy of CashSessionFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cashDrawerId = freezed,Object? cashierId = freezed,Object? status = freezed,Object? pageIndex = null,}) {
  return _then(_CashSessionFilter(
cashDrawerId: freezed == cashDrawerId ? _self.cashDrawerId : cashDrawerId // ignore: cast_nullable_to_non_nullable
as int?,cashierId: freezed == cashierId ? _self.cashierId : cashierId // ignore: cast_nullable_to_non_nullable
as int?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CashSessionStatus?,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
