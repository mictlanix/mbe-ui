// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profiles_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UserProfileFilter {

 String get search; EntityStatus? get status; int get pageIndex;
/// Create a copy of UserProfileFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProfileFilterCopyWith<UserProfileFilter> get copyWith => _$UserProfileFilterCopyWithImpl<UserProfileFilter>(this as UserProfileFilter, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as UserProfileFilter;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProfileFilter&&(identical(other.search, _this.search) || other.search == _this.search)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.pageIndex, _this.pageIndex) || other.pageIndex == _this.pageIndex));
}


@override
int get hashCode {
  final _this = this as UserProfileFilter;
  return Object.hash(runtimeType,_this.search,_this.status,_this.pageIndex);
}

@override
String toString() {
  final _this = this as UserProfileFilter;
  return 'UserProfileFilter(search: ${_this.search}, status: ${_this.status}, pageIndex: ${_this.pageIndex})';
}


}

/// @nodoc
abstract mixin class $UserProfileFilterCopyWith<$Res>  {
  factory $UserProfileFilterCopyWith(UserProfileFilter value, $Res Function(UserProfileFilter) _then) = _$UserProfileFilterCopyWithImpl;
@useResult
$Res call({
 String search, EntityStatus? status, int pageIndex
});




}
/// @nodoc
class _$UserProfileFilterCopyWithImpl<$Res>
    implements $UserProfileFilterCopyWith<$Res> {
  _$UserProfileFilterCopyWithImpl(this._self, this._then);

  final UserProfileFilter _self;
  final $Res Function(UserProfileFilter) _then;

/// Create a copy of UserProfileFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? search = null,Object? status = freezed,Object? pageIndex = null,}) {
  return _then(UserProfileFilter(
search: null == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus?,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [UserProfileFilter].
extension UserProfileFilterPatterns on UserProfileFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserProfileFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserProfileFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserProfileFilter value)  $default,){
final _that = this;
switch (_that) {
case _UserProfileFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserProfileFilter value)?  $default,){
final _that = this;
switch (_that) {
case _UserProfileFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String search,  EntityStatus? status,  int pageIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserProfileFilter() when $default != null:
return $default(_that.search,_that.status,_that.pageIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String search,  EntityStatus? status,  int pageIndex)  $default,) {final _that = this;
switch (_that) {
case _UserProfileFilter():
return $default(_that.search,_that.status,_that.pageIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String search,  EntityStatus? status,  int pageIndex)?  $default,) {final _that = this;
switch (_that) {
case _UserProfileFilter() when $default != null:
return $default(_that.search,_that.status,_that.pageIndex);case _:
  return null;

}
}

}

/// @nodoc


class _UserProfileFilter implements UserProfileFilter {
  const _UserProfileFilter({this.search = '', this.status, this.pageIndex = 0});
  

@override@JsonKey() final  String search;
@override final  EntityStatus? status;
@override@JsonKey() final  int pageIndex;

/// Create a copy of UserProfileFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProfileFilterCopyWith<_UserProfileFilter> get copyWith => __$UserProfileFilterCopyWithImpl<_UserProfileFilter>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProfileFilter&&(identical(other.search, search) || other.search == search)&&(identical(other.status, status) || other.status == status)&&(identical(other.pageIndex, pageIndex) || other.pageIndex == pageIndex));
}


@override
int get hashCode {
    return Object.hash(runtimeType,search,status,pageIndex);
}

@override
String toString() {
    return 'UserProfileFilter(search: $search, status: $status, pageIndex: $pageIndex)';
}


}

/// @nodoc
abstract mixin class _$UserProfileFilterCopyWith<$Res> implements $UserProfileFilterCopyWith<$Res> {
  factory _$UserProfileFilterCopyWith(_UserProfileFilter value, $Res Function(_UserProfileFilter) _then) = __$UserProfileFilterCopyWithImpl;
@override @useResult
$Res call({
 String search, EntityStatus? status, int pageIndex
});




}
/// @nodoc
class __$UserProfileFilterCopyWithImpl<$Res>
    implements _$UserProfileFilterCopyWith<$Res> {
  __$UserProfileFilterCopyWithImpl(this._self, this._then);

  final _UserProfileFilter _self;
  final $Res Function(_UserProfileFilter) _then;

/// Create a copy of UserProfileFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? search = null,Object? status = freezed,Object? pageIndex = null,}) {
  return _then(_UserProfileFilter(
search: null == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus?,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$UserProfileFormState {

 String get name; String get description; EntityStatus get status; List<Privilege> get privileges; bool get loading; bool get submitting; bool get saved; bool get deleted; String? get error;/// The server-provided detail behind [error] (mbe-api's `detail` string
/// on a `404`/`409`/`5xx`), shown alongside the localized [error]
/// message since it can't be localized client-side. `null` for a
/// [ValidationError]'s message (already raw server text stored directly
/// in `error`).
 String? get errorDetail;
/// Create a copy of UserProfileFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProfileFormStateCopyWith<UserProfileFormState> get copyWith => _$UserProfileFormStateCopyWithImpl<UserProfileFormState>(this as UserProfileFormState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as UserProfileFormState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProfileFormState&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.status, _this.status) || other.status == _this.status)&&const DeepCollectionEquality().equals(other.privileges, _this.privileges)&&(identical(other.loading, _this.loading) || other.loading == _this.loading)&&(identical(other.submitting, _this.submitting) || other.submitting == _this.submitting)&&(identical(other.saved, _this.saved) || other.saved == _this.saved)&&(identical(other.deleted, _this.deleted) || other.deleted == _this.deleted)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.errorDetail, _this.errorDetail) || other.errorDetail == _this.errorDetail));
}


@override
int get hashCode {
  final _this = this as UserProfileFormState;
  return Object.hash(runtimeType,_this.name,_this.description,_this.status,const DeepCollectionEquality().hash(_this.privileges),_this.loading,_this.submitting,_this.saved,_this.deleted,_this.error,_this.errorDetail);
}

@override
String toString() {
  final _this = this as UserProfileFormState;
  return 'UserProfileFormState(name: ${_this.name}, description: ${_this.description}, status: ${_this.status}, privileges: ${_this.privileges}, loading: ${_this.loading}, submitting: ${_this.submitting}, saved: ${_this.saved}, deleted: ${_this.deleted}, error: ${_this.error}, errorDetail: ${_this.errorDetail})';
}


}

/// @nodoc
abstract mixin class $UserProfileFormStateCopyWith<$Res>  {
  factory $UserProfileFormStateCopyWith(UserProfileFormState value, $Res Function(UserProfileFormState) _then) = _$UserProfileFormStateCopyWithImpl;
@useResult
$Res call({
 String name, String description, EntityStatus status, List<Privilege> privileges, bool loading, bool submitting, bool saved, bool deleted, String? error, String? errorDetail
});




}
/// @nodoc
class _$UserProfileFormStateCopyWithImpl<$Res>
    implements $UserProfileFormStateCopyWith<$Res> {
  _$UserProfileFormStateCopyWithImpl(this._self, this._then);

  final UserProfileFormState _self;
  final $Res Function(UserProfileFormState) _then;

/// Create a copy of UserProfileFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? description = null,Object? status = null,Object? privileges = null,Object? loading = null,Object? submitting = null,Object? saved = null,Object? deleted = null,Object? error = freezed,Object? errorDetail = freezed,}) {
  return _then(UserProfileFormState(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus,privileges: null == privileges ? _self.privileges : privileges // ignore: cast_nullable_to_non_nullable
as List<Privilege>,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as bool,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,errorDetail: freezed == errorDetail ? _self.errorDetail : errorDetail // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserProfileFormState].
extension UserProfileFormStatePatterns on UserProfileFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserProfileFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserProfileFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserProfileFormState value)  $default,){
final _that = this;
switch (_that) {
case _UserProfileFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserProfileFormState value)?  $default,){
final _that = this;
switch (_that) {
case _UserProfileFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String description,  EntityStatus status,  List<Privilege> privileges,  bool loading,  bool submitting,  bool saved,  bool deleted,  String? error,  String? errorDetail)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserProfileFormState() when $default != null:
return $default(_that.name,_that.description,_that.status,_that.privileges,_that.loading,_that.submitting,_that.saved,_that.deleted,_that.error,_that.errorDetail);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String description,  EntityStatus status,  List<Privilege> privileges,  bool loading,  bool submitting,  bool saved,  bool deleted,  String? error,  String? errorDetail)  $default,) {final _that = this;
switch (_that) {
case _UserProfileFormState():
return $default(_that.name,_that.description,_that.status,_that.privileges,_that.loading,_that.submitting,_that.saved,_that.deleted,_that.error,_that.errorDetail);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String description,  EntityStatus status,  List<Privilege> privileges,  bool loading,  bool submitting,  bool saved,  bool deleted,  String? error,  String? errorDetail)?  $default,) {final _that = this;
switch (_that) {
case _UserProfileFormState() when $default != null:
return $default(_that.name,_that.description,_that.status,_that.privileges,_that.loading,_that.submitting,_that.saved,_that.deleted,_that.error,_that.errorDetail);case _:
  return null;

}
}

}

/// @nodoc


class _UserProfileFormState implements UserProfileFormState {
  const _UserProfileFormState({this.name = '', this.description = '', this.status = EntityStatus.active,  List<Privilege> privileges = const <Privilege>[], this.loading = false, this.submitting = false, this.saved = false, this.deleted = false, this.error, this.errorDetail}): _privileges = privileges;
  

@override@JsonKey() final  String name;
@override@JsonKey() final  String description;
@override@JsonKey() final  EntityStatus status;
 final  List<Privilege> _privileges;
@override@JsonKey() List<Privilege> get privileges {
  if (_privileges is EqualUnmodifiableListView) return _privileges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_privileges);
}

@override@JsonKey() final  bool loading;
@override@JsonKey() final  bool submitting;
@override@JsonKey() final  bool saved;
@override@JsonKey() final  bool deleted;
@override final  String? error;
/// The server-provided detail behind [error] (mbe-api's `detail` string
/// on a `404`/`409`/`5xx`), shown alongside the localized [error]
/// message since it can't be localized client-side. `null` for a
/// [ValidationError]'s message (already raw server text stored directly
/// in `error`).
@override final  String? errorDetail;

/// Create a copy of UserProfileFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProfileFormStateCopyWith<_UserProfileFormState> get copyWith => __$UserProfileFormStateCopyWithImpl<_UserProfileFormState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProfileFormState&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.privileges, _privileges)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.saved, saved) || other.saved == saved)&&(identical(other.deleted, deleted) || other.deleted == deleted)&&(identical(other.error, error) || other.error == error)&&(identical(other.errorDetail, errorDetail) || other.errorDetail == errorDetail));
}


@override
int get hashCode {
    return Object.hash(runtimeType,name,description,status,const DeepCollectionEquality().hash(_privileges),loading,submitting,saved,deleted,error,errorDetail);
}

@override
String toString() {
    return 'UserProfileFormState(name: $name, description: $description, status: $status, privileges: $privileges, loading: $loading, submitting: $submitting, saved: $saved, deleted: $deleted, error: $error, errorDetail: $errorDetail)';
}


}

/// @nodoc
abstract mixin class _$UserProfileFormStateCopyWith<$Res> implements $UserProfileFormStateCopyWith<$Res> {
  factory _$UserProfileFormStateCopyWith(_UserProfileFormState value, $Res Function(_UserProfileFormState) _then) = __$UserProfileFormStateCopyWithImpl;
@override @useResult
$Res call({
 String name, String description, EntityStatus status, List<Privilege> privileges, bool loading, bool submitting, bool saved, bool deleted, String? error, String? errorDetail
});




}
/// @nodoc
class __$UserProfileFormStateCopyWithImpl<$Res>
    implements _$UserProfileFormStateCopyWith<$Res> {
  __$UserProfileFormStateCopyWithImpl(this._self, this._then);

  final _UserProfileFormState _self;
  final $Res Function(_UserProfileFormState) _then;

/// Create a copy of UserProfileFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? description = null,Object? status = null,Object? privileges = null,Object? loading = null,Object? submitting = null,Object? saved = null,Object? deleted = null,Object? error = freezed,Object? errorDetail = freezed,}) {
  return _then(_UserProfileFormState(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus,privileges: null == privileges ? _self._privileges : privileges // ignore: cast_nullable_to_non_nullable
as List<Privilege>,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as bool,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,errorDetail: freezed == errorDetail ? _self.errorDetail : errorDetail // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
