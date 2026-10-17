// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$User {

 String get userId; String get email; int? get employeeId; bool get administrator; EntityStatus get status; int get sessionVersion; UserSettings? get settings; List<Privilege> get privileges;/// The profile this account was last provisioned from, if any
/// (024-user-profiles data-model.md §2). Provenance only — never read by
/// `AccessControlService` or any permission decision.
 int? get profileId; String? get profileName;
/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserCopyWith<User> get copyWith => _$UserCopyWithImpl<User>(this as User, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as User;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is User&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.employeeId, _this.employeeId) || other.employeeId == _this.employeeId)&&(identical(other.administrator, _this.administrator) || other.administrator == _this.administrator)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.sessionVersion, _this.sessionVersion) || other.sessionVersion == _this.sessionVersion)&&(identical(other.settings, _this.settings) || other.settings == _this.settings)&&const DeepCollectionEquality().equals(other.privileges, _this.privileges)&&(identical(other.profileId, _this.profileId) || other.profileId == _this.profileId)&&(identical(other.profileName, _this.profileName) || other.profileName == _this.profileName));
}


@override
int get hashCode {
  final _this = this as User;
  return Object.hash(runtimeType,_this.userId,_this.email,_this.employeeId,_this.administrator,_this.status,_this.sessionVersion,_this.settings,const DeepCollectionEquality().hash(_this.privileges),_this.profileId,_this.profileName);
}

@override
String toString() {
  final _this = this as User;
  return 'User(userId: ${_this.userId}, email: ${_this.email}, employeeId: ${_this.employeeId}, administrator: ${_this.administrator}, status: ${_this.status}, sessionVersion: ${_this.sessionVersion}, settings: ${_this.settings}, privileges: ${_this.privileges}, profileId: ${_this.profileId}, profileName: ${_this.profileName})';
}


}

/// @nodoc
abstract mixin class $UserCopyWith<$Res>  {
  factory $UserCopyWith(User value, $Res Function(User) _then) = _$UserCopyWithImpl;
@useResult
$Res call({
 String userId, String email, int? employeeId, bool administrator, EntityStatus status, int sessionVersion, UserSettings? settings, List<Privilege> privileges, int? profileId, String? profileName
});


$UserSettingsCopyWith<$Res>? get settings;

}
/// @nodoc
class _$UserCopyWithImpl<$Res>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._self, this._then);

  final User _self;
  final $Res Function(User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? email = null,Object? employeeId = freezed,Object? administrator = null,Object? status = null,Object? sessionVersion = null,Object? settings = freezed,Object? privileges = null,Object? profileId = freezed,Object? profileName = freezed,}) {
  return _then(User(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,employeeId: freezed == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as int?,administrator: null == administrator ? _self.administrator : administrator // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus,sessionVersion: null == sessionVersion ? _self.sessionVersion : sessionVersion // ignore: cast_nullable_to_non_nullable
as int,settings: freezed == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as UserSettings?,privileges: null == privileges ? _self.privileges : privileges // ignore: cast_nullable_to_non_nullable
as List<Privilege>,profileId: freezed == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as int?,profileName: freezed == profileName ? _self.profileName : profileName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of User
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


/// Adds pattern-matching-related methods to [User].
extension UserPatterns on User {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _User value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _User() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _User value)  $default,){
final _that = this;
switch (_that) {
case _User():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _User value)?  $default,){
final _that = this;
switch (_that) {
case _User() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String email,  int? employeeId,  bool administrator,  EntityStatus status,  int sessionVersion,  UserSettings? settings,  List<Privilege> privileges,  int? profileId,  String? profileName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.userId,_that.email,_that.employeeId,_that.administrator,_that.status,_that.sessionVersion,_that.settings,_that.privileges,_that.profileId,_that.profileName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String email,  int? employeeId,  bool administrator,  EntityStatus status,  int sessionVersion,  UserSettings? settings,  List<Privilege> privileges,  int? profileId,  String? profileName)  $default,) {final _that = this;
switch (_that) {
case _User():
return $default(_that.userId,_that.email,_that.employeeId,_that.administrator,_that.status,_that.sessionVersion,_that.settings,_that.privileges,_that.profileId,_that.profileName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String email,  int? employeeId,  bool administrator,  EntityStatus status,  int sessionVersion,  UserSettings? settings,  List<Privilege> privileges,  int? profileId,  String? profileName)?  $default,) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.userId,_that.email,_that.employeeId,_that.administrator,_that.status,_that.sessionVersion,_that.settings,_that.privileges,_that.profileId,_that.profileName);case _:
  return null;

}
}

}

/// @nodoc


class _User implements User {
  const _User({required this.userId, required this.email, this.employeeId, required this.administrator, required this.status, required this.sessionVersion, this.settings, required  List<Privilege> privileges, this.profileId, this.profileName}): _privileges = privileges;
  

@override final  String userId;
@override final  String email;
@override final  int? employeeId;
@override final  bool administrator;
@override final  EntityStatus status;
@override final  int sessionVersion;
@override final  UserSettings? settings;
 final  List<Privilege> _privileges;
@override List<Privilege> get privileges {
  if (_privileges is EqualUnmodifiableListView) return _privileges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_privileges);
}

/// The profile this account was last provisioned from, if any
/// (024-user-profiles data-model.md §2). Provenance only — never read by
/// `AccessControlService` or any permission decision.
@override final  int? profileId;
@override final  String? profileName;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserCopyWith<_User> get copyWith => __$UserCopyWithImpl<_User>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _User&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.email, email) || other.email == email)&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.administrator, administrator) || other.administrator == administrator)&&(identical(other.status, status) || other.status == status)&&(identical(other.sessionVersion, sessionVersion) || other.sessionVersion == sessionVersion)&&(identical(other.settings, settings) || other.settings == settings)&&const DeepCollectionEquality().equals(other.privileges, _privileges)&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.profileName, profileName) || other.profileName == profileName));
}


@override
int get hashCode {
    return Object.hash(runtimeType,userId,email,employeeId,administrator,status,sessionVersion,settings,const DeepCollectionEquality().hash(_privileges),profileId,profileName);
}

@override
String toString() {
    return 'User(userId: $userId, email: $email, employeeId: $employeeId, administrator: $administrator, status: $status, sessionVersion: $sessionVersion, settings: $settings, privileges: $privileges, profileId: $profileId, profileName: $profileName)';
}


}

/// @nodoc
abstract mixin class _$UserCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$UserCopyWith(_User value, $Res Function(_User) _then) = __$UserCopyWithImpl;
@override @useResult
$Res call({
 String userId, String email, int? employeeId, bool administrator, EntityStatus status, int sessionVersion, UserSettings? settings, List<Privilege> privileges, int? profileId, String? profileName
});


@override $UserSettingsCopyWith<$Res>? get settings;

}
/// @nodoc
class __$UserCopyWithImpl<$Res>
    implements _$UserCopyWith<$Res> {
  __$UserCopyWithImpl(this._self, this._then);

  final _User _self;
  final $Res Function(_User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? email = null,Object? employeeId = freezed,Object? administrator = null,Object? status = null,Object? sessionVersion = null,Object? settings = freezed,Object? privileges = null,Object? profileId = freezed,Object? profileName = freezed,}) {
  return _then(_User(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,employeeId: freezed == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as int?,administrator: null == administrator ? _self.administrator : administrator // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus,sessionVersion: null == sessionVersion ? _self.sessionVersion : sessionVersion // ignore: cast_nullable_to_non_nullable
as int,settings: freezed == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as UserSettings?,privileges: null == privileges ? _self._privileges : privileges // ignore: cast_nullable_to_non_nullable
as List<Privilege>,profileId: freezed == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as int?,profileName: freezed == profileName ? _self.profileName : profileName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of User
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

/// @nodoc
mixin _$UserSummary {

 String get userId; String get email; int? get employeeId; bool get administrator; EntityStatus get status;/// The profile this account was last provisioned from, if any
/// (024-user-profiles data-model.md §2). See [User.profileId].
 int? get profileId; String? get profileName;
/// Create a copy of UserSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserSummaryCopyWith<UserSummary> get copyWith => _$UserSummaryCopyWithImpl<UserSummary>(this as UserSummary, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as UserSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserSummary&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.employeeId, _this.employeeId) || other.employeeId == _this.employeeId)&&(identical(other.administrator, _this.administrator) || other.administrator == _this.administrator)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.profileId, _this.profileId) || other.profileId == _this.profileId)&&(identical(other.profileName, _this.profileName) || other.profileName == _this.profileName));
}


@override
int get hashCode {
  final _this = this as UserSummary;
  return Object.hash(runtimeType,_this.userId,_this.email,_this.employeeId,_this.administrator,_this.status,_this.profileId,_this.profileName);
}

@override
String toString() {
  final _this = this as UserSummary;
  return 'UserSummary(userId: ${_this.userId}, email: ${_this.email}, employeeId: ${_this.employeeId}, administrator: ${_this.administrator}, status: ${_this.status}, profileId: ${_this.profileId}, profileName: ${_this.profileName})';
}


}

/// @nodoc
abstract mixin class $UserSummaryCopyWith<$Res>  {
  factory $UserSummaryCopyWith(UserSummary value, $Res Function(UserSummary) _then) = _$UserSummaryCopyWithImpl;
@useResult
$Res call({
 String userId, String email, int? employeeId, bool administrator, EntityStatus status, int? profileId, String? profileName
});




}
/// @nodoc
class _$UserSummaryCopyWithImpl<$Res>
    implements $UserSummaryCopyWith<$Res> {
  _$UserSummaryCopyWithImpl(this._self, this._then);

  final UserSummary _self;
  final $Res Function(UserSummary) _then;

/// Create a copy of UserSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? email = null,Object? employeeId = freezed,Object? administrator = null,Object? status = null,Object? profileId = freezed,Object? profileName = freezed,}) {
  return _then(UserSummary(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,employeeId: freezed == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as int?,administrator: null == administrator ? _self.administrator : administrator // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus,profileId: freezed == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as int?,profileName: freezed == profileName ? _self.profileName : profileName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserSummary].
extension UserSummaryPatterns on UserSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserSummary value)  $default,){
final _that = this;
switch (_that) {
case _UserSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserSummary value)?  $default,){
final _that = this;
switch (_that) {
case _UserSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String email,  int? employeeId,  bool administrator,  EntityStatus status,  int? profileId,  String? profileName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserSummary() when $default != null:
return $default(_that.userId,_that.email,_that.employeeId,_that.administrator,_that.status,_that.profileId,_that.profileName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String email,  int? employeeId,  bool administrator,  EntityStatus status,  int? profileId,  String? profileName)  $default,) {final _that = this;
switch (_that) {
case _UserSummary():
return $default(_that.userId,_that.email,_that.employeeId,_that.administrator,_that.status,_that.profileId,_that.profileName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String email,  int? employeeId,  bool administrator,  EntityStatus status,  int? profileId,  String? profileName)?  $default,) {final _that = this;
switch (_that) {
case _UserSummary() when $default != null:
return $default(_that.userId,_that.email,_that.employeeId,_that.administrator,_that.status,_that.profileId,_that.profileName);case _:
  return null;

}
}

}

/// @nodoc


class _UserSummary implements UserSummary {
  const _UserSummary({required this.userId, required this.email, this.employeeId, required this.administrator, required this.status, this.profileId, this.profileName});
  

@override final  String userId;
@override final  String email;
@override final  int? employeeId;
@override final  bool administrator;
@override final  EntityStatus status;
/// The profile this account was last provisioned from, if any
/// (024-user-profiles data-model.md §2). See [User.profileId].
@override final  int? profileId;
@override final  String? profileName;

/// Create a copy of UserSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserSummaryCopyWith<_UserSummary> get copyWith => __$UserSummaryCopyWithImpl<_UserSummary>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserSummary&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.email, email) || other.email == email)&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.administrator, administrator) || other.administrator == administrator)&&(identical(other.status, status) || other.status == status)&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.profileName, profileName) || other.profileName == profileName));
}


@override
int get hashCode {
    return Object.hash(runtimeType,userId,email,employeeId,administrator,status,profileId,profileName);
}

@override
String toString() {
    return 'UserSummary(userId: $userId, email: $email, employeeId: $employeeId, administrator: $administrator, status: $status, profileId: $profileId, profileName: $profileName)';
}


}

/// @nodoc
abstract mixin class _$UserSummaryCopyWith<$Res> implements $UserSummaryCopyWith<$Res> {
  factory _$UserSummaryCopyWith(_UserSummary value, $Res Function(_UserSummary) _then) = __$UserSummaryCopyWithImpl;
@override @useResult
$Res call({
 String userId, String email, int? employeeId, bool administrator, EntityStatus status, int? profileId, String? profileName
});




}
/// @nodoc
class __$UserSummaryCopyWithImpl<$Res>
    implements _$UserSummaryCopyWith<$Res> {
  __$UserSummaryCopyWithImpl(this._self, this._then);

  final _UserSummary _self;
  final $Res Function(_UserSummary) _then;

/// Create a copy of UserSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? email = null,Object? employeeId = freezed,Object? administrator = null,Object? status = null,Object? profileId = freezed,Object? profileName = freezed,}) {
  return _then(_UserSummary(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,employeeId: freezed == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as int?,administrator: null == administrator ? _self.administrator : administrator // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus,profileId: freezed == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as int?,profileName: freezed == profileName ? _self.profileName : profileName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
