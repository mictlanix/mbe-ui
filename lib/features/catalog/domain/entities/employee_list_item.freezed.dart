// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'employee_list_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EmployeeListItem {

 int get employeeId; String get fullName; String get nickname; EntityStatus get status; bool get salesPerson;
/// Create a copy of EmployeeListItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmployeeListItemCopyWith<EmployeeListItem> get copyWith => _$EmployeeListItemCopyWithImpl<EmployeeListItem>(this as EmployeeListItem, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as EmployeeListItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmployeeListItem&&(identical(other.employeeId, _this.employeeId) || other.employeeId == _this.employeeId)&&(identical(other.fullName, _this.fullName) || other.fullName == _this.fullName)&&(identical(other.nickname, _this.nickname) || other.nickname == _this.nickname)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.salesPerson, _this.salesPerson) || other.salesPerson == _this.salesPerson));
}


@override
int get hashCode {
  final _this = this as EmployeeListItem;
  return Object.hash(runtimeType,_this.employeeId,_this.fullName,_this.nickname,_this.status,_this.salesPerson);
}

@override
String toString() {
  final _this = this as EmployeeListItem;
  return 'EmployeeListItem(employeeId: ${_this.employeeId}, fullName: ${_this.fullName}, nickname: ${_this.nickname}, status: ${_this.status}, salesPerson: ${_this.salesPerson})';
}


}

/// @nodoc
abstract mixin class $EmployeeListItemCopyWith<$Res>  {
  factory $EmployeeListItemCopyWith(EmployeeListItem value, $Res Function(EmployeeListItem) _then) = _$EmployeeListItemCopyWithImpl;
@useResult
$Res call({
 int employeeId, String fullName, String nickname, EntityStatus status, bool salesPerson
});




}
/// @nodoc
class _$EmployeeListItemCopyWithImpl<$Res>
    implements $EmployeeListItemCopyWith<$Res> {
  _$EmployeeListItemCopyWithImpl(this._self, this._then);

  final EmployeeListItem _self;
  final $Res Function(EmployeeListItem) _then;

/// Create a copy of EmployeeListItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? employeeId = null,Object? fullName = null,Object? nickname = null,Object? status = null,Object? salesPerson = null,}) {
  return _then(EmployeeListItem(
employeeId: null == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as int,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,nickname: null == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus,salesPerson: null == salesPerson ? _self.salesPerson : salesPerson // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [EmployeeListItem].
extension EmployeeListItemPatterns on EmployeeListItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EmployeeListItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EmployeeListItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EmployeeListItem value)  $default,){
final _that = this;
switch (_that) {
case _EmployeeListItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EmployeeListItem value)?  $default,){
final _that = this;
switch (_that) {
case _EmployeeListItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int employeeId,  String fullName,  String nickname,  EntityStatus status,  bool salesPerson)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EmployeeListItem() when $default != null:
return $default(_that.employeeId,_that.fullName,_that.nickname,_that.status,_that.salesPerson);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int employeeId,  String fullName,  String nickname,  EntityStatus status,  bool salesPerson)  $default,) {final _that = this;
switch (_that) {
case _EmployeeListItem():
return $default(_that.employeeId,_that.fullName,_that.nickname,_that.status,_that.salesPerson);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int employeeId,  String fullName,  String nickname,  EntityStatus status,  bool salesPerson)?  $default,) {final _that = this;
switch (_that) {
case _EmployeeListItem() when $default != null:
return $default(_that.employeeId,_that.fullName,_that.nickname,_that.status,_that.salesPerson);case _:
  return null;

}
}

}

/// @nodoc


class _EmployeeListItem implements EmployeeListItem {
  const _EmployeeListItem({required this.employeeId, required this.fullName, required this.nickname, required this.status, required this.salesPerson});
  

@override final  int employeeId;
@override final  String fullName;
@override final  String nickname;
@override final  EntityStatus status;
@override final  bool salesPerson;

/// Create a copy of EmployeeListItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmployeeListItemCopyWith<_EmployeeListItem> get copyWith => __$EmployeeListItemCopyWithImpl<_EmployeeListItem>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmployeeListItem&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.nickname, nickname) || other.nickname == nickname)&&(identical(other.status, status) || other.status == status)&&(identical(other.salesPerson, salesPerson) || other.salesPerson == salesPerson));
}


@override
int get hashCode {
    return Object.hash(runtimeType,employeeId,fullName,nickname,status,salesPerson);
}

@override
String toString() {
    return 'EmployeeListItem(employeeId: $employeeId, fullName: $fullName, nickname: $nickname, status: $status, salesPerson: $salesPerson)';
}


}

/// @nodoc
abstract mixin class _$EmployeeListItemCopyWith<$Res> implements $EmployeeListItemCopyWith<$Res> {
  factory _$EmployeeListItemCopyWith(_EmployeeListItem value, $Res Function(_EmployeeListItem) _then) = __$EmployeeListItemCopyWithImpl;
@override @useResult
$Res call({
 int employeeId, String fullName, String nickname, EntityStatus status, bool salesPerson
});




}
/// @nodoc
class __$EmployeeListItemCopyWithImpl<$Res>
    implements _$EmployeeListItemCopyWith<$Res> {
  __$EmployeeListItemCopyWithImpl(this._self, this._then);

  final _EmployeeListItem _self;
  final $Res Function(_EmployeeListItem) _then;

/// Create a copy of EmployeeListItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? employeeId = null,Object? fullName = null,Object? nickname = null,Object? status = null,Object? salesPerson = null,}) {
  return _then(_EmployeeListItem(
employeeId: null == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as int,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,nickname: null == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus,salesPerson: null == salesPerson ? _self.salesPerson : salesPerson // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
