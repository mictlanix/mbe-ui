// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cash_drawer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CashDrawer {
  int get cashDrawerId => throw _privateConstructorUsedError;
  int get facilityId => throw _privateConstructorUsedError;
  String get facilityName => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get comment => throw _privateConstructorUsedError;
  EntityStatus get status => throw _privateConstructorUsedError;

  /// Create a copy of CashDrawer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CashDrawerCopyWith<CashDrawer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CashDrawerCopyWith<$Res> {
  factory $CashDrawerCopyWith(
    CashDrawer value,
    $Res Function(CashDrawer) then,
  ) = _$CashDrawerCopyWithImpl<$Res, CashDrawer>;
  @useResult
  $Res call({
    int cashDrawerId,
    int facilityId,
    String facilityName,
    String code,
    String name,
    String? comment,
    EntityStatus status,
  });
}

/// @nodoc
class _$CashDrawerCopyWithImpl<$Res, $Val extends CashDrawer>
    implements $CashDrawerCopyWith<$Res> {
  _$CashDrawerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CashDrawer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cashDrawerId = null,
    Object? facilityId = null,
    Object? facilityName = null,
    Object? code = null,
    Object? name = null,
    Object? comment = freezed,
    Object? status = null,
  }) {
    return _then(
      _value.copyWith(
            cashDrawerId: null == cashDrawerId
                ? _value.cashDrawerId
                : cashDrawerId // ignore: cast_nullable_to_non_nullable
                      as int,
            facilityId: null == facilityId
                ? _value.facilityId
                : facilityId // ignore: cast_nullable_to_non_nullable
                      as int,
            facilityName: null == facilityName
                ? _value.facilityName
                : facilityName // ignore: cast_nullable_to_non_nullable
                      as String,
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            comment: freezed == comment
                ? _value.comment
                : comment // ignore: cast_nullable_to_non_nullable
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
abstract class _$$CashDrawerImplCopyWith<$Res>
    implements $CashDrawerCopyWith<$Res> {
  factory _$$CashDrawerImplCopyWith(
    _$CashDrawerImpl value,
    $Res Function(_$CashDrawerImpl) then,
  ) = __$$CashDrawerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int cashDrawerId,
    int facilityId,
    String facilityName,
    String code,
    String name,
    String? comment,
    EntityStatus status,
  });
}

/// @nodoc
class __$$CashDrawerImplCopyWithImpl<$Res>
    extends _$CashDrawerCopyWithImpl<$Res, _$CashDrawerImpl>
    implements _$$CashDrawerImplCopyWith<$Res> {
  __$$CashDrawerImplCopyWithImpl(
    _$CashDrawerImpl _value,
    $Res Function(_$CashDrawerImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CashDrawer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cashDrawerId = null,
    Object? facilityId = null,
    Object? facilityName = null,
    Object? code = null,
    Object? name = null,
    Object? comment = freezed,
    Object? status = null,
  }) {
    return _then(
      _$CashDrawerImpl(
        cashDrawerId: null == cashDrawerId
            ? _value.cashDrawerId
            : cashDrawerId // ignore: cast_nullable_to_non_nullable
                  as int,
        facilityId: null == facilityId
            ? _value.facilityId
            : facilityId // ignore: cast_nullable_to_non_nullable
                  as int,
        facilityName: null == facilityName
            ? _value.facilityName
            : facilityName // ignore: cast_nullable_to_non_nullable
                  as String,
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        comment: freezed == comment
            ? _value.comment
            : comment // ignore: cast_nullable_to_non_nullable
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

class _$CashDrawerImpl implements _CashDrawer {
  const _$CashDrawerImpl({
    required this.cashDrawerId,
    required this.facilityId,
    required this.facilityName,
    required this.code,
    required this.name,
    this.comment,
    required this.status,
  });

  @override
  final int cashDrawerId;
  @override
  final int facilityId;
  @override
  final String facilityName;
  @override
  final String code;
  @override
  final String name;
  @override
  final String? comment;
  @override
  final EntityStatus status;

  @override
  String toString() {
    return 'CashDrawer(cashDrawerId: $cashDrawerId, facilityId: $facilityId, facilityName: $facilityName, code: $code, name: $name, comment: $comment, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CashDrawerImpl &&
            (identical(other.cashDrawerId, cashDrawerId) ||
                other.cashDrawerId == cashDrawerId) &&
            (identical(other.facilityId, facilityId) ||
                other.facilityId == facilityId) &&
            (identical(other.facilityName, facilityName) ||
                other.facilityName == facilityName) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            (identical(other.status, status) || other.status == status));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    cashDrawerId,
    facilityId,
    facilityName,
    code,
    name,
    comment,
    status,
  );

  /// Create a copy of CashDrawer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CashDrawerImplCopyWith<_$CashDrawerImpl> get copyWith =>
      __$$CashDrawerImplCopyWithImpl<_$CashDrawerImpl>(this, _$identity);
}

abstract class _CashDrawer implements CashDrawer {
  const factory _CashDrawer({
    required final int cashDrawerId,
    required final int facilityId,
    required final String facilityName,
    required final String code,
    required final String name,
    final String? comment,
    required final EntityStatus status,
  }) = _$CashDrawerImpl;

  @override
  int get cashDrawerId;
  @override
  int get facilityId;
  @override
  String get facilityName;
  @override
  String get code;
  @override
  String get name;
  @override
  String? get comment;
  @override
  EntityStatus get status;

  /// Create a copy of CashDrawer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CashDrawerImplCopyWith<_$CashDrawerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
