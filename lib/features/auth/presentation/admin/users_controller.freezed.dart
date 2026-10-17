// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'users_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UserFilter {

 String get search; EntityStatus? get status;/// Narrows to accounts provisioned from this profile
/// (024-user-profiles FR-028), decoded from the `profile` facet — the
/// app's own vocabulary for the wire's `profile_id` query parameter,
/// consistent with `cash-drawer`/`cashier` elsewhere in this file's
/// counterparts.
 int? get profileId; int get pageIndex;
/// Create a copy of UserFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserFilterCopyWith<UserFilter> get copyWith => _$UserFilterCopyWithImpl<UserFilter>(this as UserFilter, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as UserFilter;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserFilter&&(identical(other.search, _this.search) || other.search == _this.search)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.profileId, _this.profileId) || other.profileId == _this.profileId)&&(identical(other.pageIndex, _this.pageIndex) || other.pageIndex == _this.pageIndex));
}


@override
int get hashCode {
  final _this = this as UserFilter;
  return Object.hash(runtimeType,_this.search,_this.status,_this.profileId,_this.pageIndex);
}

@override
String toString() {
  final _this = this as UserFilter;
  return 'UserFilter(search: ${_this.search}, status: ${_this.status}, profileId: ${_this.profileId}, pageIndex: ${_this.pageIndex})';
}


}

/// @nodoc
abstract mixin class $UserFilterCopyWith<$Res>  {
  factory $UserFilterCopyWith(UserFilter value, $Res Function(UserFilter) _then) = _$UserFilterCopyWithImpl;
@useResult
$Res call({
 String search, EntityStatus? status, int? profileId, int pageIndex
});




}
/// @nodoc
class _$UserFilterCopyWithImpl<$Res>
    implements $UserFilterCopyWith<$Res> {
  _$UserFilterCopyWithImpl(this._self, this._then);

  final UserFilter _self;
  final $Res Function(UserFilter) _then;

/// Create a copy of UserFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? search = null,Object? status = freezed,Object? profileId = freezed,Object? pageIndex = null,}) {
  return _then(UserFilter(
search: null == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus?,profileId: freezed == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as int?,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [UserFilter].
extension UserFilterPatterns on UserFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserFilter value)  $default,){
final _that = this;
switch (_that) {
case _UserFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserFilter value)?  $default,){
final _that = this;
switch (_that) {
case _UserFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String search,  EntityStatus? status,  int? profileId,  int pageIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserFilter() when $default != null:
return $default(_that.search,_that.status,_that.profileId,_that.pageIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String search,  EntityStatus? status,  int? profileId,  int pageIndex)  $default,) {final _that = this;
switch (_that) {
case _UserFilter():
return $default(_that.search,_that.status,_that.profileId,_that.pageIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String search,  EntityStatus? status,  int? profileId,  int pageIndex)?  $default,) {final _that = this;
switch (_that) {
case _UserFilter() when $default != null:
return $default(_that.search,_that.status,_that.profileId,_that.pageIndex);case _:
  return null;

}
}

}

/// @nodoc


class _UserFilter implements UserFilter {
  const _UserFilter({this.search = '', this.status, this.profileId, this.pageIndex = 0});
  

@override@JsonKey() final  String search;
@override final  EntityStatus? status;
/// Narrows to accounts provisioned from this profile
/// (024-user-profiles FR-028), decoded from the `profile` facet — the
/// app's own vocabulary for the wire's `profile_id` query parameter,
/// consistent with `cash-drawer`/`cashier` elsewhere in this file's
/// counterparts.
@override final  int? profileId;
@override@JsonKey() final  int pageIndex;

/// Create a copy of UserFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserFilterCopyWith<_UserFilter> get copyWith => __$UserFilterCopyWithImpl<_UserFilter>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserFilter&&(identical(other.search, search) || other.search == search)&&(identical(other.status, status) || other.status == status)&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.pageIndex, pageIndex) || other.pageIndex == pageIndex));
}


@override
int get hashCode {
    return Object.hash(runtimeType,search,status,profileId,pageIndex);
}

@override
String toString() {
    return 'UserFilter(search: $search, status: $status, profileId: $profileId, pageIndex: $pageIndex)';
}


}

/// @nodoc
abstract mixin class _$UserFilterCopyWith<$Res> implements $UserFilterCopyWith<$Res> {
  factory _$UserFilterCopyWith(_UserFilter value, $Res Function(_UserFilter) _then) = __$UserFilterCopyWithImpl;
@override @useResult
$Res call({
 String search, EntityStatus? status, int? profileId, int pageIndex
});




}
/// @nodoc
class __$UserFilterCopyWithImpl<$Res>
    implements _$UserFilterCopyWith<$Res> {
  __$UserFilterCopyWithImpl(this._self, this._then);

  final _UserFilter _self;
  final $Res Function(_UserFilter) _then;

/// Create a copy of UserFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? search = null,Object? status = freezed,Object? profileId = freezed,Object? pageIndex = null,}) {
  return _then(_UserFilter(
search: null == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus?,profileId: freezed == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as int?,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$UserFormState {

 String get userId; String get password; String get email; int? get employeeId;/// The selected employee's display name, shown in the employee picker.
/// Pre-filled by [UserFormController.loadUser] (resolved via a lookup,
/// since `UserResponse.employeeId` is a bare id with no expansion) and
/// set directly by [UserFormController.employeeSelected] when the user
/// picks a new one.
 String get employeeDisplayText; bool get administrator; EntityStatus get status; List<Privilege> get privileges; UserSettings? get settings; bool get loading; bool get submitting; bool get saved; bool get deleted; String? get error;/// The server-provided detail behind [error] (e.g. mbe-api's `detail`
/// string on a `404`/`5xx`), shown alongside the localized [error]
/// message since it can't be localized client-side. `null` for
/// client-side-only errors and for a [ValidationError]'s message
/// (already raw server text stored directly in `error`).
 String? get errorDetail; String? get recoveryToken; String? get recoveryExpiresAt;/// The profile chosen on the new-user form (create mode), or the
/// profile this account was last provisioned from (edit mode) —
/// (024-user-profiles data-model.md §3). `null` means no profile
/// chosen/recorded.
 int? get profileId;/// Display text for [profileId]: the picker's selection in create mode,
/// or the provenance line's label in edit mode.
 String get profileName;
/// Create a copy of UserFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserFormStateCopyWith<UserFormState> get copyWith => _$UserFormStateCopyWithImpl<UserFormState>(this as UserFormState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as UserFormState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserFormState&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.password, _this.password) || other.password == _this.password)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.employeeId, _this.employeeId) || other.employeeId == _this.employeeId)&&(identical(other.employeeDisplayText, _this.employeeDisplayText) || other.employeeDisplayText == _this.employeeDisplayText)&&(identical(other.administrator, _this.administrator) || other.administrator == _this.administrator)&&(identical(other.status, _this.status) || other.status == _this.status)&&const DeepCollectionEquality().equals(other.privileges, _this.privileges)&&(identical(other.settings, _this.settings) || other.settings == _this.settings)&&(identical(other.loading, _this.loading) || other.loading == _this.loading)&&(identical(other.submitting, _this.submitting) || other.submitting == _this.submitting)&&(identical(other.saved, _this.saved) || other.saved == _this.saved)&&(identical(other.deleted, _this.deleted) || other.deleted == _this.deleted)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.errorDetail, _this.errorDetail) || other.errorDetail == _this.errorDetail)&&(identical(other.recoveryToken, _this.recoveryToken) || other.recoveryToken == _this.recoveryToken)&&(identical(other.recoveryExpiresAt, _this.recoveryExpiresAt) || other.recoveryExpiresAt == _this.recoveryExpiresAt)&&(identical(other.profileId, _this.profileId) || other.profileId == _this.profileId)&&(identical(other.profileName, _this.profileName) || other.profileName == _this.profileName));
}


@override
int get hashCode {
  final _this = this as UserFormState;
  return Object.hashAll([runtimeType,_this.userId,_this.password,_this.email,_this.employeeId,_this.employeeDisplayText,_this.administrator,_this.status,const DeepCollectionEquality().hash(_this.privileges),_this.settings,_this.loading,_this.submitting,_this.saved,_this.deleted,_this.error,_this.errorDetail,_this.recoveryToken,_this.recoveryExpiresAt,_this.profileId,_this.profileName]);
}

@override
String toString() {
  final _this = this as UserFormState;
  return 'UserFormState(userId: ${_this.userId}, password: ${_this.password}, email: ${_this.email}, employeeId: ${_this.employeeId}, employeeDisplayText: ${_this.employeeDisplayText}, administrator: ${_this.administrator}, status: ${_this.status}, privileges: ${_this.privileges}, settings: ${_this.settings}, loading: ${_this.loading}, submitting: ${_this.submitting}, saved: ${_this.saved}, deleted: ${_this.deleted}, error: ${_this.error}, errorDetail: ${_this.errorDetail}, recoveryToken: ${_this.recoveryToken}, recoveryExpiresAt: ${_this.recoveryExpiresAt}, profileId: ${_this.profileId}, profileName: ${_this.profileName})';
}


}

/// @nodoc
abstract mixin class $UserFormStateCopyWith<$Res>  {
  factory $UserFormStateCopyWith(UserFormState value, $Res Function(UserFormState) _then) = _$UserFormStateCopyWithImpl;
@useResult
$Res call({
 String userId, String password, String email, int? employeeId, String employeeDisplayText, bool administrator, EntityStatus status, List<Privilege> privileges, UserSettings? settings, bool loading, bool submitting, bool saved, bool deleted, String? error, String? errorDetail, String? recoveryToken, String? recoveryExpiresAt, int? profileId, String profileName
});


$UserSettingsCopyWith<$Res>? get settings;

}
/// @nodoc
class _$UserFormStateCopyWithImpl<$Res>
    implements $UserFormStateCopyWith<$Res> {
  _$UserFormStateCopyWithImpl(this._self, this._then);

  final UserFormState _self;
  final $Res Function(UserFormState) _then;

/// Create a copy of UserFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? password = null,Object? email = null,Object? employeeId = freezed,Object? employeeDisplayText = null,Object? administrator = null,Object? status = null,Object? privileges = null,Object? settings = freezed,Object? loading = null,Object? submitting = null,Object? saved = null,Object? deleted = null,Object? error = freezed,Object? errorDetail = freezed,Object? recoveryToken = freezed,Object? recoveryExpiresAt = freezed,Object? profileId = freezed,Object? profileName = null,}) {
  return _then(UserFormState(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,employeeId: freezed == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as int?,employeeDisplayText: null == employeeDisplayText ? _self.employeeDisplayText : employeeDisplayText // ignore: cast_nullable_to_non_nullable
as String,administrator: null == administrator ? _self.administrator : administrator // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus,privileges: null == privileges ? _self.privileges : privileges // ignore: cast_nullable_to_non_nullable
as List<Privilege>,settings: freezed == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as UserSettings?,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as bool,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,errorDetail: freezed == errorDetail ? _self.errorDetail : errorDetail // ignore: cast_nullable_to_non_nullable
as String?,recoveryToken: freezed == recoveryToken ? _self.recoveryToken : recoveryToken // ignore: cast_nullable_to_non_nullable
as String?,recoveryExpiresAt: freezed == recoveryExpiresAt ? _self.recoveryExpiresAt : recoveryExpiresAt // ignore: cast_nullable_to_non_nullable
as String?,profileId: freezed == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as int?,profileName: null == profileName ? _self.profileName : profileName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of UserFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserSettingsCopyWith<$Res>? get settings {
    if (_self.settings == null) {
    return null;
  }

  return $UserSettingsCopyWith<$Res>(_self.settings!, (value) {
    return _then(_self.copyWith(settings: value));
  });
}
}


/// Adds pattern-matching-related methods to [UserFormState].
extension UserFormStatePatterns on UserFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserFormState value)  $default,){
final _that = this;
switch (_that) {
case _UserFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserFormState value)?  $default,){
final _that = this;
switch (_that) {
case _UserFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String password,  String email,  int? employeeId,  String employeeDisplayText,  bool administrator,  EntityStatus status,  List<Privilege> privileges,  UserSettings? settings,  bool loading,  bool submitting,  bool saved,  bool deleted,  String? error,  String? errorDetail,  String? recoveryToken,  String? recoveryExpiresAt,  int? profileId,  String profileName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserFormState() when $default != null:
return $default(_that.userId,_that.password,_that.email,_that.employeeId,_that.employeeDisplayText,_that.administrator,_that.status,_that.privileges,_that.settings,_that.loading,_that.submitting,_that.saved,_that.deleted,_that.error,_that.errorDetail,_that.recoveryToken,_that.recoveryExpiresAt,_that.profileId,_that.profileName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String password,  String email,  int? employeeId,  String employeeDisplayText,  bool administrator,  EntityStatus status,  List<Privilege> privileges,  UserSettings? settings,  bool loading,  bool submitting,  bool saved,  bool deleted,  String? error,  String? errorDetail,  String? recoveryToken,  String? recoveryExpiresAt,  int? profileId,  String profileName)  $default,) {final _that = this;
switch (_that) {
case _UserFormState():
return $default(_that.userId,_that.password,_that.email,_that.employeeId,_that.employeeDisplayText,_that.administrator,_that.status,_that.privileges,_that.settings,_that.loading,_that.submitting,_that.saved,_that.deleted,_that.error,_that.errorDetail,_that.recoveryToken,_that.recoveryExpiresAt,_that.profileId,_that.profileName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String password,  String email,  int? employeeId,  String employeeDisplayText,  bool administrator,  EntityStatus status,  List<Privilege> privileges,  UserSettings? settings,  bool loading,  bool submitting,  bool saved,  bool deleted,  String? error,  String? errorDetail,  String? recoveryToken,  String? recoveryExpiresAt,  int? profileId,  String profileName)?  $default,) {final _that = this;
switch (_that) {
case _UserFormState() when $default != null:
return $default(_that.userId,_that.password,_that.email,_that.employeeId,_that.employeeDisplayText,_that.administrator,_that.status,_that.privileges,_that.settings,_that.loading,_that.submitting,_that.saved,_that.deleted,_that.error,_that.errorDetail,_that.recoveryToken,_that.recoveryExpiresAt,_that.profileId,_that.profileName);case _:
  return null;

}
}

}

/// @nodoc


class _UserFormState implements UserFormState {
  const _UserFormState({this.userId = '', this.password = '', this.email = '', this.employeeId, this.employeeDisplayText = '', this.administrator = false, this.status = EntityStatus.active,  List<Privilege> privileges = const <Privilege>[], this.settings, this.loading = false, this.submitting = false, this.saved = false, this.deleted = false, this.error, this.errorDetail, this.recoveryToken, this.recoveryExpiresAt, this.profileId, this.profileName = ''}): _privileges = privileges;
  

@override@JsonKey() final  String userId;
@override@JsonKey() final  String password;
@override@JsonKey() final  String email;
@override final  int? employeeId;
/// The selected employee's display name, shown in the employee picker.
/// Pre-filled by [UserFormController.loadUser] (resolved via a lookup,
/// since `UserResponse.employeeId` is a bare id with no expansion) and
/// set directly by [UserFormController.employeeSelected] when the user
/// picks a new one.
@override@JsonKey() final  String employeeDisplayText;
@override@JsonKey() final  bool administrator;
@override@JsonKey() final  EntityStatus status;
 final  List<Privilege> _privileges;
@override@JsonKey() List<Privilege> get privileges {
  if (_privileges is EqualUnmodifiableListView) return _privileges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_privileges);
}

@override final  UserSettings? settings;
@override@JsonKey() final  bool loading;
@override@JsonKey() final  bool submitting;
@override@JsonKey() final  bool saved;
@override@JsonKey() final  bool deleted;
@override final  String? error;
/// The server-provided detail behind [error] (e.g. mbe-api's `detail`
/// string on a `404`/`5xx`), shown alongside the localized [error]
/// message since it can't be localized client-side. `null` for
/// client-side-only errors and for a [ValidationError]'s message
/// (already raw server text stored directly in `error`).
@override final  String? errorDetail;
@override final  String? recoveryToken;
@override final  String? recoveryExpiresAt;
/// The profile chosen on the new-user form (create mode), or the
/// profile this account was last provisioned from (edit mode) —
/// (024-user-profiles data-model.md §3). `null` means no profile
/// chosen/recorded.
@override final  int? profileId;
/// Display text for [profileId]: the picker's selection in create mode,
/// or the provenance line's label in edit mode.
@override@JsonKey() final  String profileName;

/// Create a copy of UserFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserFormStateCopyWith<_UserFormState> get copyWith => __$UserFormStateCopyWithImpl<_UserFormState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserFormState&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.password, password) || other.password == password)&&(identical(other.email, email) || other.email == email)&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.employeeDisplayText, employeeDisplayText) || other.employeeDisplayText == employeeDisplayText)&&(identical(other.administrator, administrator) || other.administrator == administrator)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.privileges, _privileges)&&(identical(other.settings, settings) || other.settings == settings)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.saved, saved) || other.saved == saved)&&(identical(other.deleted, deleted) || other.deleted == deleted)&&(identical(other.error, error) || other.error == error)&&(identical(other.errorDetail, errorDetail) || other.errorDetail == errorDetail)&&(identical(other.recoveryToken, recoveryToken) || other.recoveryToken == recoveryToken)&&(identical(other.recoveryExpiresAt, recoveryExpiresAt) || other.recoveryExpiresAt == recoveryExpiresAt)&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.profileName, profileName) || other.profileName == profileName));
}


@override
int get hashCode {
    return Object.hashAll([runtimeType,userId,password,email,employeeId,employeeDisplayText,administrator,status,const DeepCollectionEquality().hash(_privileges),settings,loading,submitting,saved,deleted,error,errorDetail,recoveryToken,recoveryExpiresAt,profileId,profileName]);
}

@override
String toString() {
    return 'UserFormState(userId: $userId, password: $password, email: $email, employeeId: $employeeId, employeeDisplayText: $employeeDisplayText, administrator: $administrator, status: $status, privileges: $privileges, settings: $settings, loading: $loading, submitting: $submitting, saved: $saved, deleted: $deleted, error: $error, errorDetail: $errorDetail, recoveryToken: $recoveryToken, recoveryExpiresAt: $recoveryExpiresAt, profileId: $profileId, profileName: $profileName)';
}


}

/// @nodoc
abstract mixin class _$UserFormStateCopyWith<$Res> implements $UserFormStateCopyWith<$Res> {
  factory _$UserFormStateCopyWith(_UserFormState value, $Res Function(_UserFormState) _then) = __$UserFormStateCopyWithImpl;
@override @useResult
$Res call({
 String userId, String password, String email, int? employeeId, String employeeDisplayText, bool administrator, EntityStatus status, List<Privilege> privileges, UserSettings? settings, bool loading, bool submitting, bool saved, bool deleted, String? error, String? errorDetail, String? recoveryToken, String? recoveryExpiresAt, int? profileId, String profileName
});


@override $UserSettingsCopyWith<$Res>? get settings;

}
/// @nodoc
class __$UserFormStateCopyWithImpl<$Res>
    implements _$UserFormStateCopyWith<$Res> {
  __$UserFormStateCopyWithImpl(this._self, this._then);

  final _UserFormState _self;
  final $Res Function(_UserFormState) _then;

/// Create a copy of UserFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? password = null,Object? email = null,Object? employeeId = freezed,Object? employeeDisplayText = null,Object? administrator = null,Object? status = null,Object? privileges = null,Object? settings = freezed,Object? loading = null,Object? submitting = null,Object? saved = null,Object? deleted = null,Object? error = freezed,Object? errorDetail = freezed,Object? recoveryToken = freezed,Object? recoveryExpiresAt = freezed,Object? profileId = freezed,Object? profileName = null,}) {
  return _then(_UserFormState(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,employeeId: freezed == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as int?,employeeDisplayText: null == employeeDisplayText ? _self.employeeDisplayText : employeeDisplayText // ignore: cast_nullable_to_non_nullable
as String,administrator: null == administrator ? _self.administrator : administrator // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus,privileges: null == privileges ? _self._privileges : privileges // ignore: cast_nullable_to_non_nullable
as List<Privilege>,settings: freezed == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as UserSettings?,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as bool,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,errorDetail: freezed == errorDetail ? _self.errorDetail : errorDetail // ignore: cast_nullable_to_non_nullable
as String?,recoveryToken: freezed == recoveryToken ? _self.recoveryToken : recoveryToken // ignore: cast_nullable_to_non_nullable
as String?,recoveryExpiresAt: freezed == recoveryExpiresAt ? _self.recoveryExpiresAt : recoveryExpiresAt // ignore: cast_nullable_to_non_nullable
as String?,profileId: freezed == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as int?,profileName: null == profileName ? _self.profileName : profileName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of UserFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserSettingsCopyWith<$Res>? get settings {
    if (_self.settings == null) {
    return null;
  }

  return $UserSettingsCopyWith<$Res>(_self.settings!, (value) {
    return _then(_self.copyWith(settings: value));
  });
}
}

// dart format on
