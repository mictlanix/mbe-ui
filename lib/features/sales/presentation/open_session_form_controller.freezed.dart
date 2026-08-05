// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'open_session_form_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$OpenSessionFormState {
  int? get cashDrawerId => throw _privateConstructorUsedError;
  String get cashDrawerDisplayText => throw _privateConstructorUsedError;
  String get openingAmount => throw _privateConstructorUsedError;
  bool get submitting => throw _privateConstructorUsedError;
  bool get saved => throw _privateConstructorUsedError;

  /// The other session's id, populated only on a cashier-busy 409
  /// (research.md §4) — the screen uses it to link straight to that
  /// session's detail (FR-010) instead of leaving the open form as the
  /// only path forward.
  int? get blockingSessionId => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  String? get errorDetail => throw _privateConstructorUsedError;
  Map<String, String> get fieldErrors => throw _privateConstructorUsedError;

  /// Create a copy of OpenSessionFormState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OpenSessionFormStateCopyWith<OpenSessionFormState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OpenSessionFormStateCopyWith<$Res> {
  factory $OpenSessionFormStateCopyWith(
    OpenSessionFormState value,
    $Res Function(OpenSessionFormState) then,
  ) = _$OpenSessionFormStateCopyWithImpl<$Res, OpenSessionFormState>;
  @useResult
  $Res call({
    int? cashDrawerId,
    String cashDrawerDisplayText,
    String openingAmount,
    bool submitting,
    bool saved,
    int? blockingSessionId,
    String? error,
    String? errorDetail,
    Map<String, String> fieldErrors,
  });
}

/// @nodoc
class _$OpenSessionFormStateCopyWithImpl<
  $Res,
  $Val extends OpenSessionFormState
>
    implements $OpenSessionFormStateCopyWith<$Res> {
  _$OpenSessionFormStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OpenSessionFormState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cashDrawerId = freezed,
    Object? cashDrawerDisplayText = null,
    Object? openingAmount = null,
    Object? submitting = null,
    Object? saved = null,
    Object? blockingSessionId = freezed,
    Object? error = freezed,
    Object? errorDetail = freezed,
    Object? fieldErrors = null,
  }) {
    return _then(
      _value.copyWith(
            cashDrawerId: freezed == cashDrawerId
                ? _value.cashDrawerId
                : cashDrawerId // ignore: cast_nullable_to_non_nullable
                      as int?,
            cashDrawerDisplayText: null == cashDrawerDisplayText
                ? _value.cashDrawerDisplayText
                : cashDrawerDisplayText // ignore: cast_nullable_to_non_nullable
                      as String,
            openingAmount: null == openingAmount
                ? _value.openingAmount
                : openingAmount // ignore: cast_nullable_to_non_nullable
                      as String,
            submitting: null == submitting
                ? _value.submitting
                : submitting // ignore: cast_nullable_to_non_nullable
                      as bool,
            saved: null == saved
                ? _value.saved
                : saved // ignore: cast_nullable_to_non_nullable
                      as bool,
            blockingSessionId: freezed == blockingSessionId
                ? _value.blockingSessionId
                : blockingSessionId // ignore: cast_nullable_to_non_nullable
                      as int?,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
            errorDetail: freezed == errorDetail
                ? _value.errorDetail
                : errorDetail // ignore: cast_nullable_to_non_nullable
                      as String?,
            fieldErrors: null == fieldErrors
                ? _value.fieldErrors
                : fieldErrors // ignore: cast_nullable_to_non_nullable
                      as Map<String, String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OpenSessionFormStateImplCopyWith<$Res>
    implements $OpenSessionFormStateCopyWith<$Res> {
  factory _$$OpenSessionFormStateImplCopyWith(
    _$OpenSessionFormStateImpl value,
    $Res Function(_$OpenSessionFormStateImpl) then,
  ) = __$$OpenSessionFormStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? cashDrawerId,
    String cashDrawerDisplayText,
    String openingAmount,
    bool submitting,
    bool saved,
    int? blockingSessionId,
    String? error,
    String? errorDetail,
    Map<String, String> fieldErrors,
  });
}

/// @nodoc
class __$$OpenSessionFormStateImplCopyWithImpl<$Res>
    extends _$OpenSessionFormStateCopyWithImpl<$Res, _$OpenSessionFormStateImpl>
    implements _$$OpenSessionFormStateImplCopyWith<$Res> {
  __$$OpenSessionFormStateImplCopyWithImpl(
    _$OpenSessionFormStateImpl _value,
    $Res Function(_$OpenSessionFormStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OpenSessionFormState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cashDrawerId = freezed,
    Object? cashDrawerDisplayText = null,
    Object? openingAmount = null,
    Object? submitting = null,
    Object? saved = null,
    Object? blockingSessionId = freezed,
    Object? error = freezed,
    Object? errorDetail = freezed,
    Object? fieldErrors = null,
  }) {
    return _then(
      _$OpenSessionFormStateImpl(
        cashDrawerId: freezed == cashDrawerId
            ? _value.cashDrawerId
            : cashDrawerId // ignore: cast_nullable_to_non_nullable
                  as int?,
        cashDrawerDisplayText: null == cashDrawerDisplayText
            ? _value.cashDrawerDisplayText
            : cashDrawerDisplayText // ignore: cast_nullable_to_non_nullable
                  as String,
        openingAmount: null == openingAmount
            ? _value.openingAmount
            : openingAmount // ignore: cast_nullable_to_non_nullable
                  as String,
        submitting: null == submitting
            ? _value.submitting
            : submitting // ignore: cast_nullable_to_non_nullable
                  as bool,
        saved: null == saved
            ? _value.saved
            : saved // ignore: cast_nullable_to_non_nullable
                  as bool,
        blockingSessionId: freezed == blockingSessionId
            ? _value.blockingSessionId
            : blockingSessionId // ignore: cast_nullable_to_non_nullable
                  as int?,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
        errorDetail: freezed == errorDetail
            ? _value.errorDetail
            : errorDetail // ignore: cast_nullable_to_non_nullable
                  as String?,
        fieldErrors: null == fieldErrors
            ? _value._fieldErrors
            : fieldErrors // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>,
      ),
    );
  }
}

/// @nodoc

class _$OpenSessionFormStateImpl implements _OpenSessionFormState {
  const _$OpenSessionFormStateImpl({
    this.cashDrawerId,
    this.cashDrawerDisplayText = '',
    this.openingAmount = '0',
    this.submitting = false,
    this.saved = false,
    this.blockingSessionId,
    this.error,
    this.errorDetail,
    final Map<String, String> fieldErrors = const <String, String>{},
  }) : _fieldErrors = fieldErrors;

  @override
  final int? cashDrawerId;
  @override
  @JsonKey()
  final String cashDrawerDisplayText;
  @override
  @JsonKey()
  final String openingAmount;
  @override
  @JsonKey()
  final bool submitting;
  @override
  @JsonKey()
  final bool saved;

  /// The other session's id, populated only on a cashier-busy 409
  /// (research.md §4) — the screen uses it to link straight to that
  /// session's detail (FR-010) instead of leaving the open form as the
  /// only path forward.
  @override
  final int? blockingSessionId;
  @override
  final String? error;
  @override
  final String? errorDetail;
  final Map<String, String> _fieldErrors;
  @override
  @JsonKey()
  Map<String, String> get fieldErrors {
    if (_fieldErrors is EqualUnmodifiableMapView) return _fieldErrors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_fieldErrors);
  }

  @override
  String toString() {
    return 'OpenSessionFormState(cashDrawerId: $cashDrawerId, cashDrawerDisplayText: $cashDrawerDisplayText, openingAmount: $openingAmount, submitting: $submitting, saved: $saved, blockingSessionId: $blockingSessionId, error: $error, errorDetail: $errorDetail, fieldErrors: $fieldErrors)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OpenSessionFormStateImpl &&
            (identical(other.cashDrawerId, cashDrawerId) ||
                other.cashDrawerId == cashDrawerId) &&
            (identical(other.cashDrawerDisplayText, cashDrawerDisplayText) ||
                other.cashDrawerDisplayText == cashDrawerDisplayText) &&
            (identical(other.openingAmount, openingAmount) ||
                other.openingAmount == openingAmount) &&
            (identical(other.submitting, submitting) ||
                other.submitting == submitting) &&
            (identical(other.saved, saved) || other.saved == saved) &&
            (identical(other.blockingSessionId, blockingSessionId) ||
                other.blockingSessionId == blockingSessionId) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.errorDetail, errorDetail) ||
                other.errorDetail == errorDetail) &&
            const DeepCollectionEquality().equals(
              other._fieldErrors,
              _fieldErrors,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    cashDrawerId,
    cashDrawerDisplayText,
    openingAmount,
    submitting,
    saved,
    blockingSessionId,
    error,
    errorDetail,
    const DeepCollectionEquality().hash(_fieldErrors),
  );

  /// Create a copy of OpenSessionFormState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OpenSessionFormStateImplCopyWith<_$OpenSessionFormStateImpl>
  get copyWith =>
      __$$OpenSessionFormStateImplCopyWithImpl<_$OpenSessionFormStateImpl>(
        this,
        _$identity,
      );
}

abstract class _OpenSessionFormState implements OpenSessionFormState {
  const factory _OpenSessionFormState({
    final int? cashDrawerId,
    final String cashDrawerDisplayText,
    final String openingAmount,
    final bool submitting,
    final bool saved,
    final int? blockingSessionId,
    final String? error,
    final String? errorDetail,
    final Map<String, String> fieldErrors,
  }) = _$OpenSessionFormStateImpl;

  @override
  int? get cashDrawerId;
  @override
  String get cashDrawerDisplayText;
  @override
  String get openingAmount;
  @override
  bool get submitting;
  @override
  bool get saved;

  /// The other session's id, populated only on a cashier-busy 409
  /// (research.md §4) — the screen uses it to link straight to that
  /// session's detail (FR-010) instead of leaving the open form as the
  /// only path forward.
  @override
  int? get blockingSessionId;
  @override
  String? get error;
  @override
  String? get errorDetail;
  @override
  Map<String, String> get fieldErrors;

  /// Create a copy of OpenSessionFormState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OpenSessionFormStateImplCopyWith<_$OpenSessionFormStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}
