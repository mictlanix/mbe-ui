// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_error.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AppError {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(List<FieldError> errors) validation,
    required TResult Function(String? message) auth,
    required TResult Function(String? message) notFound,
    required TResult Function(int? statusCode, String? message) server,
    required TResult Function(String? message) network,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(List<FieldError> errors)? validation,
    TResult? Function(String? message)? auth,
    TResult? Function(String? message)? notFound,
    TResult? Function(int? statusCode, String? message)? server,
    TResult? Function(String? message)? network,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(List<FieldError> errors)? validation,
    TResult Function(String? message)? auth,
    TResult Function(String? message)? notFound,
    TResult Function(int? statusCode, String? message)? server,
    TResult Function(String? message)? network,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ValidationError value) validation,
    required TResult Function(AuthError value) auth,
    required TResult Function(NotFoundError value) notFound,
    required TResult Function(ServerError value) server,
    required TResult Function(NetworkError value) network,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ValidationError value)? validation,
    TResult? Function(AuthError value)? auth,
    TResult? Function(NotFoundError value)? notFound,
    TResult? Function(ServerError value)? server,
    TResult? Function(NetworkError value)? network,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ValidationError value)? validation,
    TResult Function(AuthError value)? auth,
    TResult Function(NotFoundError value)? notFound,
    TResult Function(ServerError value)? server,
    TResult Function(NetworkError value)? network,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppErrorCopyWith<$Res> {
  factory $AppErrorCopyWith(AppError value, $Res Function(AppError) then) =
      _$AppErrorCopyWithImpl<$Res, AppError>;
}

/// @nodoc
class _$AppErrorCopyWithImpl<$Res, $Val extends AppError>
    implements $AppErrorCopyWith<$Res> {
  _$AppErrorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$ValidationErrorImplCopyWith<$Res> {
  factory _$$ValidationErrorImplCopyWith(
    _$ValidationErrorImpl value,
    $Res Function(_$ValidationErrorImpl) then,
  ) = __$$ValidationErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<FieldError> errors});
}

/// @nodoc
class __$$ValidationErrorImplCopyWithImpl<$Res>
    extends _$AppErrorCopyWithImpl<$Res, _$ValidationErrorImpl>
    implements _$$ValidationErrorImplCopyWith<$Res> {
  __$$ValidationErrorImplCopyWithImpl(
    _$ValidationErrorImpl _value,
    $Res Function(_$ValidationErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? errors = null}) {
    return _then(
      _$ValidationErrorImpl(
        null == errors
            ? _value._errors
            : errors // ignore: cast_nullable_to_non_nullable
                  as List<FieldError>,
      ),
    );
  }
}

/// @nodoc

class _$ValidationErrorImpl implements ValidationError {
  const _$ValidationErrorImpl(final List<FieldError> errors) : _errors = errors;

  final List<FieldError> _errors;
  @override
  List<FieldError> get errors {
    if (_errors is EqualUnmodifiableListView) return _errors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_errors);
  }

  @override
  String toString() {
    return 'AppError.validation(errors: $errors)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ValidationErrorImpl &&
            const DeepCollectionEquality().equals(other._errors, _errors));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_errors));

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ValidationErrorImplCopyWith<_$ValidationErrorImpl> get copyWith =>
      __$$ValidationErrorImplCopyWithImpl<_$ValidationErrorImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(List<FieldError> errors) validation,
    required TResult Function(String? message) auth,
    required TResult Function(String? message) notFound,
    required TResult Function(int? statusCode, String? message) server,
    required TResult Function(String? message) network,
  }) {
    return validation(errors);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(List<FieldError> errors)? validation,
    TResult? Function(String? message)? auth,
    TResult? Function(String? message)? notFound,
    TResult? Function(int? statusCode, String? message)? server,
    TResult? Function(String? message)? network,
  }) {
    return validation?.call(errors);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(List<FieldError> errors)? validation,
    TResult Function(String? message)? auth,
    TResult Function(String? message)? notFound,
    TResult Function(int? statusCode, String? message)? server,
    TResult Function(String? message)? network,
    required TResult orElse(),
  }) {
    if (validation != null) {
      return validation(errors);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ValidationError value) validation,
    required TResult Function(AuthError value) auth,
    required TResult Function(NotFoundError value) notFound,
    required TResult Function(ServerError value) server,
    required TResult Function(NetworkError value) network,
  }) {
    return validation(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ValidationError value)? validation,
    TResult? Function(AuthError value)? auth,
    TResult? Function(NotFoundError value)? notFound,
    TResult? Function(ServerError value)? server,
    TResult? Function(NetworkError value)? network,
  }) {
    return validation?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ValidationError value)? validation,
    TResult Function(AuthError value)? auth,
    TResult Function(NotFoundError value)? notFound,
    TResult Function(ServerError value)? server,
    TResult Function(NetworkError value)? network,
    required TResult orElse(),
  }) {
    if (validation != null) {
      return validation(this);
    }
    return orElse();
  }
}

abstract class ValidationError implements AppError {
  const factory ValidationError(final List<FieldError> errors) =
      _$ValidationErrorImpl;

  List<FieldError> get errors;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ValidationErrorImplCopyWith<_$ValidationErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AuthErrorImplCopyWith<$Res> {
  factory _$$AuthErrorImplCopyWith(
    _$AuthErrorImpl value,
    $Res Function(_$AuthErrorImpl) then,
  ) = __$$AuthErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String? message});
}

/// @nodoc
class __$$AuthErrorImplCopyWithImpl<$Res>
    extends _$AppErrorCopyWithImpl<$Res, _$AuthErrorImpl>
    implements _$$AuthErrorImplCopyWith<$Res> {
  __$$AuthErrorImplCopyWithImpl(
    _$AuthErrorImpl _value,
    $Res Function(_$AuthErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = freezed}) {
    return _then(
      _$AuthErrorImpl(
        freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$AuthErrorImpl implements AuthError {
  const _$AuthErrorImpl([this.message]);

  @override
  final String? message;

  @override
  String toString() {
    return 'AppError.auth(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthErrorImplCopyWith<_$AuthErrorImpl> get copyWith =>
      __$$AuthErrorImplCopyWithImpl<_$AuthErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(List<FieldError> errors) validation,
    required TResult Function(String? message) auth,
    required TResult Function(String? message) notFound,
    required TResult Function(int? statusCode, String? message) server,
    required TResult Function(String? message) network,
  }) {
    return auth(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(List<FieldError> errors)? validation,
    TResult? Function(String? message)? auth,
    TResult? Function(String? message)? notFound,
    TResult? Function(int? statusCode, String? message)? server,
    TResult? Function(String? message)? network,
  }) {
    return auth?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(List<FieldError> errors)? validation,
    TResult Function(String? message)? auth,
    TResult Function(String? message)? notFound,
    TResult Function(int? statusCode, String? message)? server,
    TResult Function(String? message)? network,
    required TResult orElse(),
  }) {
    if (auth != null) {
      return auth(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ValidationError value) validation,
    required TResult Function(AuthError value) auth,
    required TResult Function(NotFoundError value) notFound,
    required TResult Function(ServerError value) server,
    required TResult Function(NetworkError value) network,
  }) {
    return auth(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ValidationError value)? validation,
    TResult? Function(AuthError value)? auth,
    TResult? Function(NotFoundError value)? notFound,
    TResult? Function(ServerError value)? server,
    TResult? Function(NetworkError value)? network,
  }) {
    return auth?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ValidationError value)? validation,
    TResult Function(AuthError value)? auth,
    TResult Function(NotFoundError value)? notFound,
    TResult Function(ServerError value)? server,
    TResult Function(NetworkError value)? network,
    required TResult orElse(),
  }) {
    if (auth != null) {
      return auth(this);
    }
    return orElse();
  }
}

abstract class AuthError implements AppError {
  const factory AuthError([final String? message]) = _$AuthErrorImpl;

  String? get message;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthErrorImplCopyWith<_$AuthErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$NotFoundErrorImplCopyWith<$Res> {
  factory _$$NotFoundErrorImplCopyWith(
    _$NotFoundErrorImpl value,
    $Res Function(_$NotFoundErrorImpl) then,
  ) = __$$NotFoundErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String? message});
}

/// @nodoc
class __$$NotFoundErrorImplCopyWithImpl<$Res>
    extends _$AppErrorCopyWithImpl<$Res, _$NotFoundErrorImpl>
    implements _$$NotFoundErrorImplCopyWith<$Res> {
  __$$NotFoundErrorImplCopyWithImpl(
    _$NotFoundErrorImpl _value,
    $Res Function(_$NotFoundErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = freezed}) {
    return _then(
      _$NotFoundErrorImpl(
        freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$NotFoundErrorImpl implements NotFoundError {
  const _$NotFoundErrorImpl([this.message]);

  @override
  final String? message;

  @override
  String toString() {
    return 'AppError.notFound(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotFoundErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotFoundErrorImplCopyWith<_$NotFoundErrorImpl> get copyWith =>
      __$$NotFoundErrorImplCopyWithImpl<_$NotFoundErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(List<FieldError> errors) validation,
    required TResult Function(String? message) auth,
    required TResult Function(String? message) notFound,
    required TResult Function(int? statusCode, String? message) server,
    required TResult Function(String? message) network,
  }) {
    return notFound(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(List<FieldError> errors)? validation,
    TResult? Function(String? message)? auth,
    TResult? Function(String? message)? notFound,
    TResult? Function(int? statusCode, String? message)? server,
    TResult? Function(String? message)? network,
  }) {
    return notFound?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(List<FieldError> errors)? validation,
    TResult Function(String? message)? auth,
    TResult Function(String? message)? notFound,
    TResult Function(int? statusCode, String? message)? server,
    TResult Function(String? message)? network,
    required TResult orElse(),
  }) {
    if (notFound != null) {
      return notFound(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ValidationError value) validation,
    required TResult Function(AuthError value) auth,
    required TResult Function(NotFoundError value) notFound,
    required TResult Function(ServerError value) server,
    required TResult Function(NetworkError value) network,
  }) {
    return notFound(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ValidationError value)? validation,
    TResult? Function(AuthError value)? auth,
    TResult? Function(NotFoundError value)? notFound,
    TResult? Function(ServerError value)? server,
    TResult? Function(NetworkError value)? network,
  }) {
    return notFound?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ValidationError value)? validation,
    TResult Function(AuthError value)? auth,
    TResult Function(NotFoundError value)? notFound,
    TResult Function(ServerError value)? server,
    TResult Function(NetworkError value)? network,
    required TResult orElse(),
  }) {
    if (notFound != null) {
      return notFound(this);
    }
    return orElse();
  }
}

abstract class NotFoundError implements AppError {
  const factory NotFoundError([final String? message]) = _$NotFoundErrorImpl;

  String? get message;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotFoundErrorImplCopyWith<_$NotFoundErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ServerErrorImplCopyWith<$Res> {
  factory _$$ServerErrorImplCopyWith(
    _$ServerErrorImpl value,
    $Res Function(_$ServerErrorImpl) then,
  ) = __$$ServerErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int? statusCode, String? message});
}

/// @nodoc
class __$$ServerErrorImplCopyWithImpl<$Res>
    extends _$AppErrorCopyWithImpl<$Res, _$ServerErrorImpl>
    implements _$$ServerErrorImplCopyWith<$Res> {
  __$$ServerErrorImplCopyWithImpl(
    _$ServerErrorImpl _value,
    $Res Function(_$ServerErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? statusCode = freezed, Object? message = freezed}) {
    return _then(
      _$ServerErrorImpl(
        statusCode: freezed == statusCode
            ? _value.statusCode
            : statusCode // ignore: cast_nullable_to_non_nullable
                  as int?,
        message: freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$ServerErrorImpl implements ServerError {
  const _$ServerErrorImpl({this.statusCode, this.message});

  @override
  final int? statusCode;
  @override
  final String? message;

  @override
  String toString() {
    return 'AppError.server(statusCode: $statusCode, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServerErrorImpl &&
            (identical(other.statusCode, statusCode) ||
                other.statusCode == statusCode) &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, statusCode, message);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ServerErrorImplCopyWith<_$ServerErrorImpl> get copyWith =>
      __$$ServerErrorImplCopyWithImpl<_$ServerErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(List<FieldError> errors) validation,
    required TResult Function(String? message) auth,
    required TResult Function(String? message) notFound,
    required TResult Function(int? statusCode, String? message) server,
    required TResult Function(String? message) network,
  }) {
    return server(statusCode, message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(List<FieldError> errors)? validation,
    TResult? Function(String? message)? auth,
    TResult? Function(String? message)? notFound,
    TResult? Function(int? statusCode, String? message)? server,
    TResult? Function(String? message)? network,
  }) {
    return server?.call(statusCode, message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(List<FieldError> errors)? validation,
    TResult Function(String? message)? auth,
    TResult Function(String? message)? notFound,
    TResult Function(int? statusCode, String? message)? server,
    TResult Function(String? message)? network,
    required TResult orElse(),
  }) {
    if (server != null) {
      return server(statusCode, message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ValidationError value) validation,
    required TResult Function(AuthError value) auth,
    required TResult Function(NotFoundError value) notFound,
    required TResult Function(ServerError value) server,
    required TResult Function(NetworkError value) network,
  }) {
    return server(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ValidationError value)? validation,
    TResult? Function(AuthError value)? auth,
    TResult? Function(NotFoundError value)? notFound,
    TResult? Function(ServerError value)? server,
    TResult? Function(NetworkError value)? network,
  }) {
    return server?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ValidationError value)? validation,
    TResult Function(AuthError value)? auth,
    TResult Function(NotFoundError value)? notFound,
    TResult Function(ServerError value)? server,
    TResult Function(NetworkError value)? network,
    required TResult orElse(),
  }) {
    if (server != null) {
      return server(this);
    }
    return orElse();
  }
}

abstract class ServerError implements AppError {
  const factory ServerError({final int? statusCode, final String? message}) =
      _$ServerErrorImpl;

  int? get statusCode;
  String? get message;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ServerErrorImplCopyWith<_$ServerErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$NetworkErrorImplCopyWith<$Res> {
  factory _$$NetworkErrorImplCopyWith(
    _$NetworkErrorImpl value,
    $Res Function(_$NetworkErrorImpl) then,
  ) = __$$NetworkErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String? message});
}

/// @nodoc
class __$$NetworkErrorImplCopyWithImpl<$Res>
    extends _$AppErrorCopyWithImpl<$Res, _$NetworkErrorImpl>
    implements _$$NetworkErrorImplCopyWith<$Res> {
  __$$NetworkErrorImplCopyWithImpl(
    _$NetworkErrorImpl _value,
    $Res Function(_$NetworkErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = freezed}) {
    return _then(
      _$NetworkErrorImpl(
        freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$NetworkErrorImpl implements NetworkError {
  const _$NetworkErrorImpl([this.message]);

  @override
  final String? message;

  @override
  String toString() {
    return 'AppError.network(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NetworkErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NetworkErrorImplCopyWith<_$NetworkErrorImpl> get copyWith =>
      __$$NetworkErrorImplCopyWithImpl<_$NetworkErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(List<FieldError> errors) validation,
    required TResult Function(String? message) auth,
    required TResult Function(String? message) notFound,
    required TResult Function(int? statusCode, String? message) server,
    required TResult Function(String? message) network,
  }) {
    return network(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(List<FieldError> errors)? validation,
    TResult? Function(String? message)? auth,
    TResult? Function(String? message)? notFound,
    TResult? Function(int? statusCode, String? message)? server,
    TResult? Function(String? message)? network,
  }) {
    return network?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(List<FieldError> errors)? validation,
    TResult Function(String? message)? auth,
    TResult Function(String? message)? notFound,
    TResult Function(int? statusCode, String? message)? server,
    TResult Function(String? message)? network,
    required TResult orElse(),
  }) {
    if (network != null) {
      return network(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ValidationError value) validation,
    required TResult Function(AuthError value) auth,
    required TResult Function(NotFoundError value) notFound,
    required TResult Function(ServerError value) server,
    required TResult Function(NetworkError value) network,
  }) {
    return network(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ValidationError value)? validation,
    TResult? Function(AuthError value)? auth,
    TResult? Function(NotFoundError value)? notFound,
    TResult? Function(ServerError value)? server,
    TResult? Function(NetworkError value)? network,
  }) {
    return network?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ValidationError value)? validation,
    TResult Function(AuthError value)? auth,
    TResult Function(NotFoundError value)? notFound,
    TResult Function(ServerError value)? server,
    TResult Function(NetworkError value)? network,
    required TResult orElse(),
  }) {
    if (network != null) {
      return network(this);
    }
    return orElse();
  }
}

abstract class NetworkError implements AppError {
  const factory NetworkError([final String? message]) = _$NetworkErrorImpl;

  String? get message;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NetworkErrorImplCopyWith<_$NetworkErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$FieldError {
  List<String> get loc => throw _privateConstructorUsedError;
  String get msg => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;

  /// Create a copy of FieldError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FieldErrorCopyWith<FieldError> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FieldErrorCopyWith<$Res> {
  factory $FieldErrorCopyWith(
    FieldError value,
    $Res Function(FieldError) then,
  ) = _$FieldErrorCopyWithImpl<$Res, FieldError>;
  @useResult
  $Res call({List<String> loc, String msg, String type});
}

/// @nodoc
class _$FieldErrorCopyWithImpl<$Res, $Val extends FieldError>
    implements $FieldErrorCopyWith<$Res> {
  _$FieldErrorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FieldError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? loc = null, Object? msg = null, Object? type = null}) {
    return _then(
      _value.copyWith(
            loc: null == loc
                ? _value.loc
                : loc // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            msg: null == msg
                ? _value.msg
                : msg // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FieldErrorImplCopyWith<$Res>
    implements $FieldErrorCopyWith<$Res> {
  factory _$$FieldErrorImplCopyWith(
    _$FieldErrorImpl value,
    $Res Function(_$FieldErrorImpl) then,
  ) = __$$FieldErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<String> loc, String msg, String type});
}

/// @nodoc
class __$$FieldErrorImplCopyWithImpl<$Res>
    extends _$FieldErrorCopyWithImpl<$Res, _$FieldErrorImpl>
    implements _$$FieldErrorImplCopyWith<$Res> {
  __$$FieldErrorImplCopyWithImpl(
    _$FieldErrorImpl _value,
    $Res Function(_$FieldErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FieldError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? loc = null, Object? msg = null, Object? type = null}) {
    return _then(
      _$FieldErrorImpl(
        loc: null == loc
            ? _value._loc
            : loc // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        msg: null == msg
            ? _value.msg
            : msg // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$FieldErrorImpl implements _FieldError {
  const _$FieldErrorImpl({
    required final List<String> loc,
    required this.msg,
    required this.type,
  }) : _loc = loc;

  final List<String> _loc;
  @override
  List<String> get loc {
    if (_loc is EqualUnmodifiableListView) return _loc;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_loc);
  }

  @override
  final String msg;
  @override
  final String type;

  @override
  String toString() {
    return 'FieldError(loc: $loc, msg: $msg, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FieldErrorImpl &&
            const DeepCollectionEquality().equals(other._loc, _loc) &&
            (identical(other.msg, msg) || other.msg == msg) &&
            (identical(other.type, type) || other.type == type));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_loc),
    msg,
    type,
  );

  /// Create a copy of FieldError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FieldErrorImplCopyWith<_$FieldErrorImpl> get copyWith =>
      __$$FieldErrorImplCopyWithImpl<_$FieldErrorImpl>(this, _$identity);
}

abstract class _FieldError implements FieldError {
  const factory _FieldError({
    required final List<String> loc,
    required final String msg,
    required final String type,
  }) = _$FieldErrorImpl;

  @override
  List<String> get loc;
  @override
  String get msg;
  @override
  String get type;

  /// Create a copy of FieldError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FieldErrorImplCopyWith<_$FieldErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
