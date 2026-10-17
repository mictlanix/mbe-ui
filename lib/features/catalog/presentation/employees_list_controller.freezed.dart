// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'employees_list_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EmployeeFilter {

 String get search; EntityStatus? get status; bool? get salesPerson; int get pageIndex;
/// Create a copy of EmployeeFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmployeeFilterCopyWith<EmployeeFilter> get copyWith => _$EmployeeFilterCopyWithImpl<EmployeeFilter>(this as EmployeeFilter, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as EmployeeFilter;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmployeeFilter&&(identical(other.search, _this.search) || other.search == _this.search)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.salesPerson, _this.salesPerson) || other.salesPerson == _this.salesPerson)&&(identical(other.pageIndex, _this.pageIndex) || other.pageIndex == _this.pageIndex));
}


@override
int get hashCode {
  final _this = this as EmployeeFilter;
  return Object.hash(runtimeType,_this.search,_this.status,_this.salesPerson,_this.pageIndex);
}

@override
String toString() {
  final _this = this as EmployeeFilter;
  return 'EmployeeFilter(search: ${_this.search}, status: ${_this.status}, salesPerson: ${_this.salesPerson}, pageIndex: ${_this.pageIndex})';
}


}

/// @nodoc
abstract mixin class $EmployeeFilterCopyWith<$Res>  {
  factory $EmployeeFilterCopyWith(EmployeeFilter value, $Res Function(EmployeeFilter) _then) = _$EmployeeFilterCopyWithImpl;
@useResult
$Res call({
 String search, EntityStatus? status, bool? salesPerson, int pageIndex
});




}
/// @nodoc
class _$EmployeeFilterCopyWithImpl<$Res>
    implements $EmployeeFilterCopyWith<$Res> {
  _$EmployeeFilterCopyWithImpl(this._self, this._then);

  final EmployeeFilter _self;
  final $Res Function(EmployeeFilter) _then;

/// Create a copy of EmployeeFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? search = null,Object? status = freezed,Object? salesPerson = freezed,Object? pageIndex = null,}) {
  return _then(EmployeeFilter(
search: null == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus?,salesPerson: freezed == salesPerson ? _self.salesPerson : salesPerson // ignore: cast_nullable_to_non_nullable
as bool?,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [EmployeeFilter].
extension EmployeeFilterPatterns on EmployeeFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EmployeeFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EmployeeFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EmployeeFilter value)  $default,){
final _that = this;
switch (_that) {
case _EmployeeFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EmployeeFilter value)?  $default,){
final _that = this;
switch (_that) {
case _EmployeeFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String search,  EntityStatus? status,  bool? salesPerson,  int pageIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EmployeeFilter() when $default != null:
return $default(_that.search,_that.status,_that.salesPerson,_that.pageIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String search,  EntityStatus? status,  bool? salesPerson,  int pageIndex)  $default,) {final _that = this;
switch (_that) {
case _EmployeeFilter():
return $default(_that.search,_that.status,_that.salesPerson,_that.pageIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String search,  EntityStatus? status,  bool? salesPerson,  int pageIndex)?  $default,) {final _that = this;
switch (_that) {
case _EmployeeFilter() when $default != null:
return $default(_that.search,_that.status,_that.salesPerson,_that.pageIndex);case _:
  return null;

}
}

}

/// @nodoc


class _EmployeeFilter implements EmployeeFilter {
  const _EmployeeFilter({this.search = '', this.status, this.salesPerson, this.pageIndex = 0});
  

@override@JsonKey() final  String search;
@override final  EntityStatus? status;
@override final  bool? salesPerson;
@override@JsonKey() final  int pageIndex;

/// Create a copy of EmployeeFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmployeeFilterCopyWith<_EmployeeFilter> get copyWith => __$EmployeeFilterCopyWithImpl<_EmployeeFilter>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmployeeFilter&&(identical(other.search, search) || other.search == search)&&(identical(other.status, status) || other.status == status)&&(identical(other.salesPerson, salesPerson) || other.salesPerson == salesPerson)&&(identical(other.pageIndex, pageIndex) || other.pageIndex == pageIndex));
}


@override
int get hashCode {
    return Object.hash(runtimeType,search,status,salesPerson,pageIndex);
}

@override
String toString() {
    return 'EmployeeFilter(search: $search, status: $status, salesPerson: $salesPerson, pageIndex: $pageIndex)';
}


}

/// @nodoc
abstract mixin class _$EmployeeFilterCopyWith<$Res> implements $EmployeeFilterCopyWith<$Res> {
  factory _$EmployeeFilterCopyWith(_EmployeeFilter value, $Res Function(_EmployeeFilter) _then) = __$EmployeeFilterCopyWithImpl;
@override @useResult
$Res call({
 String search, EntityStatus? status, bool? salesPerson, int pageIndex
});




}
/// @nodoc
class __$EmployeeFilterCopyWithImpl<$Res>
    implements _$EmployeeFilterCopyWith<$Res> {
  __$EmployeeFilterCopyWithImpl(this._self, this._then);

  final _EmployeeFilter _self;
  final $Res Function(_EmployeeFilter) _then;

/// Create a copy of EmployeeFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? search = null,Object? status = freezed,Object? salesPerson = freezed,Object? pageIndex = null,}) {
  return _then(_EmployeeFilter(
search: null == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus?,salesPerson: freezed == salesPerson ? _self.salesPerson : salesPerson // ignore: cast_nullable_to_non_nullable
as bool?,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
