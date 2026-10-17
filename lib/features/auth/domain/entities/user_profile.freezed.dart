// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UserProfile {

 int get userProfileId; String get name; String? get description; EntityStatus get status; List<Privilege> get privileges;
/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProfileCopyWith<UserProfile> get copyWith => _$UserProfileCopyWithImpl<UserProfile>(this as UserProfile, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as UserProfile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProfile&&(identical(other.userProfileId, _this.userProfileId) || other.userProfileId == _this.userProfileId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.status, _this.status) || other.status == _this.status)&&const DeepCollectionEquality().equals(other.privileges, _this.privileges));
}


@override
int get hashCode {
  final _this = this as UserProfile;
  return Object.hash(runtimeType,_this.userProfileId,_this.name,_this.description,_this.status,const DeepCollectionEquality().hash(_this.privileges));
}

@override
String toString() {
  final _this = this as UserProfile;
  return 'UserProfile(userProfileId: ${_this.userProfileId}, name: ${_this.name}, description: ${_this.description}, status: ${_this.status}, privileges: ${_this.privileges})';
}


}

/// @nodoc
abstract mixin class $UserProfileCopyWith<$Res>  {
  factory $UserProfileCopyWith(UserProfile value, $Res Function(UserProfile) _then) = _$UserProfileCopyWithImpl;
@useResult
$Res call({
 int userProfileId, String name, String? description, EntityStatus status, List<Privilege> privileges
});




}
/// @nodoc
class _$UserProfileCopyWithImpl<$Res>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._self, this._then);

  final UserProfile _self;
  final $Res Function(UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userProfileId = null,Object? name = null,Object? description = freezed,Object? status = null,Object? privileges = null,}) {
  return _then(UserProfile(
userProfileId: null == userProfileId ? _self.userProfileId : userProfileId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus,privileges: null == privileges ? _self.privileges : privileges // ignore: cast_nullable_to_non_nullable
as List<Privilege>,
  ));
}

}


/// Adds pattern-matching-related methods to [UserProfile].
extension UserProfilePatterns on UserProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserProfile value)  $default,){
final _that = this;
switch (_that) {
case _UserProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserProfile value)?  $default,){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int userProfileId,  String name,  String? description,  EntityStatus status,  List<Privilege> privileges)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.userProfileId,_that.name,_that.description,_that.status,_that.privileges);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int userProfileId,  String name,  String? description,  EntityStatus status,  List<Privilege> privileges)  $default,) {final _that = this;
switch (_that) {
case _UserProfile():
return $default(_that.userProfileId,_that.name,_that.description,_that.status,_that.privileges);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int userProfileId,  String name,  String? description,  EntityStatus status,  List<Privilege> privileges)?  $default,) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.userProfileId,_that.name,_that.description,_that.status,_that.privileges);case _:
  return null;

}
}

}

/// @nodoc


class _UserProfile implements UserProfile {
  const _UserProfile({required this.userProfileId, required this.name, this.description, required this.status, required  List<Privilege> privileges}): _privileges = privileges;
  

@override final  int userProfileId;
@override final  String name;
@override final  String? description;
@override final  EntityStatus status;
 final  List<Privilege> _privileges;
@override List<Privilege> get privileges {
  if (_privileges is EqualUnmodifiableListView) return _privileges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_privileges);
}


/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProfileCopyWith<_UserProfile> get copyWith => __$UserProfileCopyWithImpl<_UserProfile>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProfile&&(identical(other.userProfileId, userProfileId) || other.userProfileId == userProfileId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.privileges, _privileges));
}


@override
int get hashCode {
    return Object.hash(runtimeType,userProfileId,name,description,status,const DeepCollectionEquality().hash(_privileges));
}

@override
String toString() {
    return 'UserProfile(userProfileId: $userProfileId, name: $name, description: $description, status: $status, privileges: $privileges)';
}


}

/// @nodoc
abstract mixin class _$UserProfileCopyWith<$Res> implements $UserProfileCopyWith<$Res> {
  factory _$UserProfileCopyWith(_UserProfile value, $Res Function(_UserProfile) _then) = __$UserProfileCopyWithImpl;
@override @useResult
$Res call({
 int userProfileId, String name, String? description, EntityStatus status, List<Privilege> privileges
});




}
/// @nodoc
class __$UserProfileCopyWithImpl<$Res>
    implements _$UserProfileCopyWith<$Res> {
  __$UserProfileCopyWithImpl(this._self, this._then);

  final _UserProfile _self;
  final $Res Function(_UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userProfileId = null,Object? name = null,Object? description = freezed,Object? status = null,Object? privileges = null,}) {
  return _then(_UserProfile(
userProfileId: null == userProfileId ? _self.userProfileId : userProfileId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus,privileges: null == privileges ? _self._privileges : privileges // ignore: cast_nullable_to_non_nullable
as List<Privilege>,
  ));
}


}

/// @nodoc
mixin _$UserProfileSummary {

 int get userProfileId; String get name; String? get description; EntityStatus get status;
/// Create a copy of UserProfileSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProfileSummaryCopyWith<UserProfileSummary> get copyWith => _$UserProfileSummaryCopyWithImpl<UserProfileSummary>(this as UserProfileSummary, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as UserProfileSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProfileSummary&&(identical(other.userProfileId, _this.userProfileId) || other.userProfileId == _this.userProfileId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.status, _this.status) || other.status == _this.status));
}


@override
int get hashCode {
  final _this = this as UserProfileSummary;
  return Object.hash(runtimeType,_this.userProfileId,_this.name,_this.description,_this.status);
}

@override
String toString() {
  final _this = this as UserProfileSummary;
  return 'UserProfileSummary(userProfileId: ${_this.userProfileId}, name: ${_this.name}, description: ${_this.description}, status: ${_this.status})';
}


}

/// @nodoc
abstract mixin class $UserProfileSummaryCopyWith<$Res>  {
  factory $UserProfileSummaryCopyWith(UserProfileSummary value, $Res Function(UserProfileSummary) _then) = _$UserProfileSummaryCopyWithImpl;
@useResult
$Res call({
 int userProfileId, String name, String? description, EntityStatus status
});




}
/// @nodoc
class _$UserProfileSummaryCopyWithImpl<$Res>
    implements $UserProfileSummaryCopyWith<$Res> {
  _$UserProfileSummaryCopyWithImpl(this._self, this._then);

  final UserProfileSummary _self;
  final $Res Function(UserProfileSummary) _then;

/// Create a copy of UserProfileSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userProfileId = null,Object? name = null,Object? description = freezed,Object? status = null,}) {
  return _then(UserProfileSummary(
userProfileId: null == userProfileId ? _self.userProfileId : userProfileId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [UserProfileSummary].
extension UserProfileSummaryPatterns on UserProfileSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserProfileSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserProfileSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserProfileSummary value)  $default,){
final _that = this;
switch (_that) {
case _UserProfileSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserProfileSummary value)?  $default,){
final _that = this;
switch (_that) {
case _UserProfileSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int userProfileId,  String name,  String? description,  EntityStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserProfileSummary() when $default != null:
return $default(_that.userProfileId,_that.name,_that.description,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int userProfileId,  String name,  String? description,  EntityStatus status)  $default,) {final _that = this;
switch (_that) {
case _UserProfileSummary():
return $default(_that.userProfileId,_that.name,_that.description,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int userProfileId,  String name,  String? description,  EntityStatus status)?  $default,) {final _that = this;
switch (_that) {
case _UserProfileSummary() when $default != null:
return $default(_that.userProfileId,_that.name,_that.description,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _UserProfileSummary implements UserProfileSummary {
  const _UserProfileSummary({required this.userProfileId, required this.name, this.description, required this.status});
  

@override final  int userProfileId;
@override final  String name;
@override final  String? description;
@override final  EntityStatus status;

/// Create a copy of UserProfileSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProfileSummaryCopyWith<_UserProfileSummary> get copyWith => __$UserProfileSummaryCopyWithImpl<_UserProfileSummary>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProfileSummary&&(identical(other.userProfileId, userProfileId) || other.userProfileId == userProfileId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode {
    return Object.hash(runtimeType,userProfileId,name,description,status);
}

@override
String toString() {
    return 'UserProfileSummary(userProfileId: $userProfileId, name: $name, description: $description, status: $status)';
}


}

/// @nodoc
abstract mixin class _$UserProfileSummaryCopyWith<$Res> implements $UserProfileSummaryCopyWith<$Res> {
  factory _$UserProfileSummaryCopyWith(_UserProfileSummary value, $Res Function(_UserProfileSummary) _then) = __$UserProfileSummaryCopyWithImpl;
@override @useResult
$Res call({
 int userProfileId, String name, String? description, EntityStatus status
});




}
/// @nodoc
class __$UserProfileSummaryCopyWithImpl<$Res>
    implements _$UserProfileSummaryCopyWith<$Res> {
  __$UserProfileSummaryCopyWithImpl(this._self, this._then);

  final _UserProfileSummary _self;
  final $Res Function(_UserProfileSummary) _then;

/// Create a copy of UserProfileSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userProfileId = null,Object? name = null,Object? description = freezed,Object? status = null,}) {
  return _then(_UserProfileSummary(
userProfileId: null == userProfileId ? _self.userProfileId : userProfileId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus,
  ));
}


}

// dart format on
