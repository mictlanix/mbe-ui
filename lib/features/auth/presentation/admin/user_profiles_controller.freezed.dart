// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profiles_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$UserProfileFilter {
  String get search => throw _privateConstructorUsedError;
  EntityStatus? get status => throw _privateConstructorUsedError;
  int get pageIndex => throw _privateConstructorUsedError;

  /// Create a copy of UserProfileFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserProfileFilterCopyWith<UserProfileFilter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProfileFilterCopyWith<$Res> {
  factory $UserProfileFilterCopyWith(
    UserProfileFilter value,
    $Res Function(UserProfileFilter) then,
  ) = _$UserProfileFilterCopyWithImpl<$Res, UserProfileFilter>;
  @useResult
  $Res call({String search, EntityStatus? status, int pageIndex});
}

/// @nodoc
class _$UserProfileFilterCopyWithImpl<$Res, $Val extends UserProfileFilter>
    implements $UserProfileFilterCopyWith<$Res> {
  _$UserProfileFilterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserProfileFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? search = null,
    Object? status = freezed,
    Object? pageIndex = null,
  }) {
    return _then(
      _value.copyWith(
            search: null == search
                ? _value.search
                : search // ignore: cast_nullable_to_non_nullable
                      as String,
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as EntityStatus?,
            pageIndex: null == pageIndex
                ? _value.pageIndex
                : pageIndex // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserProfileFilterImplCopyWith<$Res>
    implements $UserProfileFilterCopyWith<$Res> {
  factory _$$UserProfileFilterImplCopyWith(
    _$UserProfileFilterImpl value,
    $Res Function(_$UserProfileFilterImpl) then,
  ) = __$$UserProfileFilterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String search, EntityStatus? status, int pageIndex});
}

/// @nodoc
class __$$UserProfileFilterImplCopyWithImpl<$Res>
    extends _$UserProfileFilterCopyWithImpl<$Res, _$UserProfileFilterImpl>
    implements _$$UserProfileFilterImplCopyWith<$Res> {
  __$$UserProfileFilterImplCopyWithImpl(
    _$UserProfileFilterImpl _value,
    $Res Function(_$UserProfileFilterImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserProfileFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? search = null,
    Object? status = freezed,
    Object? pageIndex = null,
  }) {
    return _then(
      _$UserProfileFilterImpl(
        search: null == search
            ? _value.search
            : search // ignore: cast_nullable_to_non_nullable
                  as String,
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as EntityStatus?,
        pageIndex: null == pageIndex
            ? _value.pageIndex
            : pageIndex // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$UserProfileFilterImpl implements _UserProfileFilter {
  const _$UserProfileFilterImpl({
    this.search = '',
    this.status,
    this.pageIndex = 0,
  });

  @override
  @JsonKey()
  final String search;
  @override
  final EntityStatus? status;
  @override
  @JsonKey()
  final int pageIndex;

  @override
  String toString() {
    return 'UserProfileFilter(search: $search, status: $status, pageIndex: $pageIndex)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProfileFilterImpl &&
            (identical(other.search, search) || other.search == search) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.pageIndex, pageIndex) ||
                other.pageIndex == pageIndex));
  }

  @override
  int get hashCode => Object.hash(runtimeType, search, status, pageIndex);

  /// Create a copy of UserProfileFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProfileFilterImplCopyWith<_$UserProfileFilterImpl> get copyWith =>
      __$$UserProfileFilterImplCopyWithImpl<_$UserProfileFilterImpl>(
        this,
        _$identity,
      );
}

abstract class _UserProfileFilter implements UserProfileFilter {
  const factory _UserProfileFilter({
    final String search,
    final EntityStatus? status,
    final int pageIndex,
  }) = _$UserProfileFilterImpl;

  @override
  String get search;
  @override
  EntityStatus? get status;
  @override
  int get pageIndex;

  /// Create a copy of UserProfileFilter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserProfileFilterImplCopyWith<_$UserProfileFilterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$UserProfileFormState {
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  EntityStatus get status => throw _privateConstructorUsedError;
  List<Privilege> get privileges => throw _privateConstructorUsedError;
  bool get loading => throw _privateConstructorUsedError;
  bool get submitting => throw _privateConstructorUsedError;
  bool get saved => throw _privateConstructorUsedError;
  bool get deleted => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// The server-provided detail behind [error] (mbe-api's `detail` string
  /// on a `404`/`409`/`5xx`), shown alongside the localized [error]
  /// message since it can't be localized client-side. `null` for a
  /// [ValidationError]'s message (already raw server text stored directly
  /// in `error`).
  String? get errorDetail => throw _privateConstructorUsedError;

  /// Create a copy of UserProfileFormState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserProfileFormStateCopyWith<UserProfileFormState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProfileFormStateCopyWith<$Res> {
  factory $UserProfileFormStateCopyWith(
    UserProfileFormState value,
    $Res Function(UserProfileFormState) then,
  ) = _$UserProfileFormStateCopyWithImpl<$Res, UserProfileFormState>;
  @useResult
  $Res call({
    String name,
    String description,
    EntityStatus status,
    List<Privilege> privileges,
    bool loading,
    bool submitting,
    bool saved,
    bool deleted,
    String? error,
    String? errorDetail,
  });
}

/// @nodoc
class _$UserProfileFormStateCopyWithImpl<
  $Res,
  $Val extends UserProfileFormState
>
    implements $UserProfileFormStateCopyWith<$Res> {
  _$UserProfileFormStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserProfileFormState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = null,
    Object? status = null,
    Object? privileges = null,
    Object? loading = null,
    Object? submitting = null,
    Object? saved = null,
    Object? deleted = null,
    Object? error = freezed,
    Object? errorDetail = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as EntityStatus,
            privileges: null == privileges
                ? _value.privileges
                : privileges // ignore: cast_nullable_to_non_nullable
                      as List<Privilege>,
            loading: null == loading
                ? _value.loading
                : loading // ignore: cast_nullable_to_non_nullable
                      as bool,
            submitting: null == submitting
                ? _value.submitting
                : submitting // ignore: cast_nullable_to_non_nullable
                      as bool,
            saved: null == saved
                ? _value.saved
                : saved // ignore: cast_nullable_to_non_nullable
                      as bool,
            deleted: null == deleted
                ? _value.deleted
                : deleted // ignore: cast_nullable_to_non_nullable
                      as bool,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
            errorDetail: freezed == errorDetail
                ? _value.errorDetail
                : errorDetail // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserProfileFormStateImplCopyWith<$Res>
    implements $UserProfileFormStateCopyWith<$Res> {
  factory _$$UserProfileFormStateImplCopyWith(
    _$UserProfileFormStateImpl value,
    $Res Function(_$UserProfileFormStateImpl) then,
  ) = __$$UserProfileFormStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    String description,
    EntityStatus status,
    List<Privilege> privileges,
    bool loading,
    bool submitting,
    bool saved,
    bool deleted,
    String? error,
    String? errorDetail,
  });
}

/// @nodoc
class __$$UserProfileFormStateImplCopyWithImpl<$Res>
    extends _$UserProfileFormStateCopyWithImpl<$Res, _$UserProfileFormStateImpl>
    implements _$$UserProfileFormStateImplCopyWith<$Res> {
  __$$UserProfileFormStateImplCopyWithImpl(
    _$UserProfileFormStateImpl _value,
    $Res Function(_$UserProfileFormStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserProfileFormState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = null,
    Object? status = null,
    Object? privileges = null,
    Object? loading = null,
    Object? submitting = null,
    Object? saved = null,
    Object? deleted = null,
    Object? error = freezed,
    Object? errorDetail = freezed,
  }) {
    return _then(
      _$UserProfileFormStateImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as EntityStatus,
        privileges: null == privileges
            ? _value._privileges
            : privileges // ignore: cast_nullable_to_non_nullable
                  as List<Privilege>,
        loading: null == loading
            ? _value.loading
            : loading // ignore: cast_nullable_to_non_nullable
                  as bool,
        submitting: null == submitting
            ? _value.submitting
            : submitting // ignore: cast_nullable_to_non_nullable
                  as bool,
        saved: null == saved
            ? _value.saved
            : saved // ignore: cast_nullable_to_non_nullable
                  as bool,
        deleted: null == deleted
            ? _value.deleted
            : deleted // ignore: cast_nullable_to_non_nullable
                  as bool,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
        errorDetail: freezed == errorDetail
            ? _value.errorDetail
            : errorDetail // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$UserProfileFormStateImpl implements _UserProfileFormState {
  const _$UserProfileFormStateImpl({
    this.name = '',
    this.description = '',
    this.status = EntityStatus.active,
    final List<Privilege> privileges = const <Privilege>[],
    this.loading = false,
    this.submitting = false,
    this.saved = false,
    this.deleted = false,
    this.error,
    this.errorDetail,
  }) : _privileges = privileges;

  @override
  @JsonKey()
  final String name;
  @override
  @JsonKey()
  final String description;
  @override
  @JsonKey()
  final EntityStatus status;
  final List<Privilege> _privileges;
  @override
  @JsonKey()
  List<Privilege> get privileges {
    if (_privileges is EqualUnmodifiableListView) return _privileges;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_privileges);
  }

  @override
  @JsonKey()
  final bool loading;
  @override
  @JsonKey()
  final bool submitting;
  @override
  @JsonKey()
  final bool saved;
  @override
  @JsonKey()
  final bool deleted;
  @override
  final String? error;

  /// The server-provided detail behind [error] (mbe-api's `detail` string
  /// on a `404`/`409`/`5xx`), shown alongside the localized [error]
  /// message since it can't be localized client-side. `null` for a
  /// [ValidationError]'s message (already raw server text stored directly
  /// in `error`).
  @override
  final String? errorDetail;

  @override
  String toString() {
    return 'UserProfileFormState(name: $name, description: $description, status: $status, privileges: $privileges, loading: $loading, submitting: $submitting, saved: $saved, deleted: $deleted, error: $error, errorDetail: $errorDetail)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProfileFormStateImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(
              other._privileges,
              _privileges,
            ) &&
            (identical(other.loading, loading) || other.loading == loading) &&
            (identical(other.submitting, submitting) ||
                other.submitting == submitting) &&
            (identical(other.saved, saved) || other.saved == saved) &&
            (identical(other.deleted, deleted) || other.deleted == deleted) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.errorDetail, errorDetail) ||
                other.errorDetail == errorDetail));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    description,
    status,
    const DeepCollectionEquality().hash(_privileges),
    loading,
    submitting,
    saved,
    deleted,
    error,
    errorDetail,
  );

  /// Create a copy of UserProfileFormState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProfileFormStateImplCopyWith<_$UserProfileFormStateImpl>
  get copyWith =>
      __$$UserProfileFormStateImplCopyWithImpl<_$UserProfileFormStateImpl>(
        this,
        _$identity,
      );
}

abstract class _UserProfileFormState implements UserProfileFormState {
  const factory _UserProfileFormState({
    final String name,
    final String description,
    final EntityStatus status,
    final List<Privilege> privileges,
    final bool loading,
    final bool submitting,
    final bool saved,
    final bool deleted,
    final String? error,
    final String? errorDetail,
  }) = _$UserProfileFormStateImpl;

  @override
  String get name;
  @override
  String get description;
  @override
  EntityStatus get status;
  @override
  List<Privilege> get privileges;
  @override
  bool get loading;
  @override
  bool get submitting;
  @override
  bool get saved;
  @override
  bool get deleted;
  @override
  String? get error;

  /// The server-provided detail behind [error] (mbe-api's `detail` string
  /// on a `404`/`409`/`5xx`), shown alongside the localized [error]
  /// message since it can't be localized client-side. `null` for a
  /// [ValidationError]'s message (already raw server text stored directly
  /// in `error`).
  @override
  String? get errorDetail;

  /// Create a copy of UserProfileFormState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserProfileFormStateImplCopyWith<_$UserProfileFormStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}
