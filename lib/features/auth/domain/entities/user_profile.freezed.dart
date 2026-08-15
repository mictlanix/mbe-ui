// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$UserProfile {
  int get userProfileId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  EntityStatus get status => throw _privateConstructorUsedError;
  List<Privilege> get privileges => throw _privateConstructorUsedError;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserProfileCopyWith<UserProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProfileCopyWith<$Res> {
  factory $UserProfileCopyWith(
    UserProfile value,
    $Res Function(UserProfile) then,
  ) = _$UserProfileCopyWithImpl<$Res, UserProfile>;
  @useResult
  $Res call({
    int userProfileId,
    String name,
    String? description,
    EntityStatus status,
    List<Privilege> privileges,
  });
}

/// @nodoc
class _$UserProfileCopyWithImpl<$Res, $Val extends UserProfile>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userProfileId = null,
    Object? name = null,
    Object? description = freezed,
    Object? status = null,
    Object? privileges = null,
  }) {
    return _then(
      _value.copyWith(
            userProfileId: null == userProfileId
                ? _value.userProfileId
                : userProfileId // ignore: cast_nullable_to_non_nullable
                      as int,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as EntityStatus,
            privileges: null == privileges
                ? _value.privileges
                : privileges // ignore: cast_nullable_to_non_nullable
                      as List<Privilege>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserProfileImplCopyWith<$Res>
    implements $UserProfileCopyWith<$Res> {
  factory _$$UserProfileImplCopyWith(
    _$UserProfileImpl value,
    $Res Function(_$UserProfileImpl) then,
  ) = __$$UserProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int userProfileId,
    String name,
    String? description,
    EntityStatus status,
    List<Privilege> privileges,
  });
}

/// @nodoc
class __$$UserProfileImplCopyWithImpl<$Res>
    extends _$UserProfileCopyWithImpl<$Res, _$UserProfileImpl>
    implements _$$UserProfileImplCopyWith<$Res> {
  __$$UserProfileImplCopyWithImpl(
    _$UserProfileImpl _value,
    $Res Function(_$UserProfileImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userProfileId = null,
    Object? name = null,
    Object? description = freezed,
    Object? status = null,
    Object? privileges = null,
  }) {
    return _then(
      _$UserProfileImpl(
        userProfileId: null == userProfileId
            ? _value.userProfileId
            : userProfileId // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as EntityStatus,
        privileges: null == privileges
            ? _value._privileges
            : privileges // ignore: cast_nullable_to_non_nullable
                  as List<Privilege>,
      ),
    );
  }
}

/// @nodoc

class _$UserProfileImpl implements _UserProfile {
  const _$UserProfileImpl({
    required this.userProfileId,
    required this.name,
    this.description,
    required this.status,
    required final List<Privilege> privileges,
  }) : _privileges = privileges;

  @override
  final int userProfileId;
  @override
  final String name;
  @override
  final String? description;
  @override
  final EntityStatus status;
  final List<Privilege> _privileges;
  @override
  List<Privilege> get privileges {
    if (_privileges is EqualUnmodifiableListView) return _privileges;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_privileges);
  }

  @override
  String toString() {
    return 'UserProfile(userProfileId: $userProfileId, name: $name, description: $description, status: $status, privileges: $privileges)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProfileImpl &&
            (identical(other.userProfileId, userProfileId) ||
                other.userProfileId == userProfileId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(
              other._privileges,
              _privileges,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    userProfileId,
    name,
    description,
    status,
    const DeepCollectionEquality().hash(_privileges),
  );

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      __$$UserProfileImplCopyWithImpl<_$UserProfileImpl>(this, _$identity);
}

abstract class _UserProfile implements UserProfile {
  const factory _UserProfile({
    required final int userProfileId,
    required final String name,
    final String? description,
    required final EntityStatus status,
    required final List<Privilege> privileges,
  }) = _$UserProfileImpl;

  @override
  int get userProfileId;
  @override
  String get name;
  @override
  String? get description;
  @override
  EntityStatus get status;
  @override
  List<Privilege> get privileges;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$UserProfileSummary {
  int get userProfileId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  EntityStatus get status => throw _privateConstructorUsedError;

  /// Create a copy of UserProfileSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserProfileSummaryCopyWith<UserProfileSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProfileSummaryCopyWith<$Res> {
  factory $UserProfileSummaryCopyWith(
    UserProfileSummary value,
    $Res Function(UserProfileSummary) then,
  ) = _$UserProfileSummaryCopyWithImpl<$Res, UserProfileSummary>;
  @useResult
  $Res call({
    int userProfileId,
    String name,
    String? description,
    EntityStatus status,
  });
}

/// @nodoc
class _$UserProfileSummaryCopyWithImpl<$Res, $Val extends UserProfileSummary>
    implements $UserProfileSummaryCopyWith<$Res> {
  _$UserProfileSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserProfileSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userProfileId = null,
    Object? name = null,
    Object? description = freezed,
    Object? status = null,
  }) {
    return _then(
      _value.copyWith(
            userProfileId: null == userProfileId
                ? _value.userProfileId
                : userProfileId // ignore: cast_nullable_to_non_nullable
                      as int,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as EntityStatus,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserProfileSummaryImplCopyWith<$Res>
    implements $UserProfileSummaryCopyWith<$Res> {
  factory _$$UserProfileSummaryImplCopyWith(
    _$UserProfileSummaryImpl value,
    $Res Function(_$UserProfileSummaryImpl) then,
  ) = __$$UserProfileSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int userProfileId,
    String name,
    String? description,
    EntityStatus status,
  });
}

/// @nodoc
class __$$UserProfileSummaryImplCopyWithImpl<$Res>
    extends _$UserProfileSummaryCopyWithImpl<$Res, _$UserProfileSummaryImpl>
    implements _$$UserProfileSummaryImplCopyWith<$Res> {
  __$$UserProfileSummaryImplCopyWithImpl(
    _$UserProfileSummaryImpl _value,
    $Res Function(_$UserProfileSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserProfileSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userProfileId = null,
    Object? name = null,
    Object? description = freezed,
    Object? status = null,
  }) {
    return _then(
      _$UserProfileSummaryImpl(
        userProfileId: null == userProfileId
            ? _value.userProfileId
            : userProfileId // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as EntityStatus,
      ),
    );
  }
}

/// @nodoc

class _$UserProfileSummaryImpl implements _UserProfileSummary {
  const _$UserProfileSummaryImpl({
    required this.userProfileId,
    required this.name,
    this.description,
    required this.status,
  });

  @override
  final int userProfileId;
  @override
  final String name;
  @override
  final String? description;
  @override
  final EntityStatus status;

  @override
  String toString() {
    return 'UserProfileSummary(userProfileId: $userProfileId, name: $name, description: $description, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProfileSummaryImpl &&
            (identical(other.userProfileId, userProfileId) ||
                other.userProfileId == userProfileId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.status, status) || other.status == status));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, userProfileId, name, description, status);

  /// Create a copy of UserProfileSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProfileSummaryImplCopyWith<_$UserProfileSummaryImpl> get copyWith =>
      __$$UserProfileSummaryImplCopyWithImpl<_$UserProfileSummaryImpl>(
        this,
        _$identity,
      );
}

abstract class _UserProfileSummary implements UserProfileSummary {
  const factory _UserProfileSummary({
    required final int userProfileId,
    required final String name,
    final String? description,
    required final EntityStatus status,
  }) = _$UserProfileSummaryImpl;

  @override
  int get userProfileId;
  @override
  String get name;
  @override
  String? get description;
  @override
  EntityStatus get status;

  /// Create a copy of UserProfileSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserProfileSummaryImplCopyWith<_$UserProfileSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
