// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cash_sessions_list_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CashSessionFilter {
  int? get cashDrawerId => throw _privateConstructorUsedError;
  int? get cashierId => throw _privateConstructorUsedError;
  CashSessionStatus? get status => throw _privateConstructorUsedError;
  int get pageIndex => throw _privateConstructorUsedError;

  /// Create a copy of CashSessionFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CashSessionFilterCopyWith<CashSessionFilter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CashSessionFilterCopyWith<$Res> {
  factory $CashSessionFilterCopyWith(
    CashSessionFilter value,
    $Res Function(CashSessionFilter) then,
  ) = _$CashSessionFilterCopyWithImpl<$Res, CashSessionFilter>;
  @useResult
  $Res call({
    int? cashDrawerId,
    int? cashierId,
    CashSessionStatus? status,
    int pageIndex,
  });
}

/// @nodoc
class _$CashSessionFilterCopyWithImpl<$Res, $Val extends CashSessionFilter>
    implements $CashSessionFilterCopyWith<$Res> {
  _$CashSessionFilterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CashSessionFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cashDrawerId = freezed,
    Object? cashierId = freezed,
    Object? status = freezed,
    Object? pageIndex = null,
  }) {
    return _then(
      _value.copyWith(
            cashDrawerId: freezed == cashDrawerId
                ? _value.cashDrawerId
                : cashDrawerId // ignore: cast_nullable_to_non_nullable
                      as int?,
            cashierId: freezed == cashierId
                ? _value.cashierId
                : cashierId // ignore: cast_nullable_to_non_nullable
                      as int?,
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as CashSessionStatus?,
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
abstract class _$$CashSessionFilterImplCopyWith<$Res>
    implements $CashSessionFilterCopyWith<$Res> {
  factory _$$CashSessionFilterImplCopyWith(
    _$CashSessionFilterImpl value,
    $Res Function(_$CashSessionFilterImpl) then,
  ) = __$$CashSessionFilterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? cashDrawerId,
    int? cashierId,
    CashSessionStatus? status,
    int pageIndex,
  });
}

/// @nodoc
class __$$CashSessionFilterImplCopyWithImpl<$Res>
    extends _$CashSessionFilterCopyWithImpl<$Res, _$CashSessionFilterImpl>
    implements _$$CashSessionFilterImplCopyWith<$Res> {
  __$$CashSessionFilterImplCopyWithImpl(
    _$CashSessionFilterImpl _value,
    $Res Function(_$CashSessionFilterImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CashSessionFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cashDrawerId = freezed,
    Object? cashierId = freezed,
    Object? status = freezed,
    Object? pageIndex = null,
  }) {
    return _then(
      _$CashSessionFilterImpl(
        cashDrawerId: freezed == cashDrawerId
            ? _value.cashDrawerId
            : cashDrawerId // ignore: cast_nullable_to_non_nullable
                  as int?,
        cashierId: freezed == cashierId
            ? _value.cashierId
            : cashierId // ignore: cast_nullable_to_non_nullable
                  as int?,
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as CashSessionStatus?,
        pageIndex: null == pageIndex
            ? _value.pageIndex
            : pageIndex // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$CashSessionFilterImpl implements _CashSessionFilter {
  const _$CashSessionFilterImpl({
    this.cashDrawerId,
    this.cashierId,
    this.status,
    this.pageIndex = 0,
  });

  @override
  final int? cashDrawerId;
  @override
  final int? cashierId;
  @override
  final CashSessionStatus? status;
  @override
  @JsonKey()
  final int pageIndex;

  @override
  String toString() {
    return 'CashSessionFilter(cashDrawerId: $cashDrawerId, cashierId: $cashierId, status: $status, pageIndex: $pageIndex)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CashSessionFilterImpl &&
            (identical(other.cashDrawerId, cashDrawerId) ||
                other.cashDrawerId == cashDrawerId) &&
            (identical(other.cashierId, cashierId) ||
                other.cashierId == cashierId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.pageIndex, pageIndex) ||
                other.pageIndex == pageIndex));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, cashDrawerId, cashierId, status, pageIndex);

  /// Create a copy of CashSessionFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CashSessionFilterImplCopyWith<_$CashSessionFilterImpl> get copyWith =>
      __$$CashSessionFilterImplCopyWithImpl<_$CashSessionFilterImpl>(
        this,
        _$identity,
      );
}

abstract class _CashSessionFilter implements CashSessionFilter {
  const factory _CashSessionFilter({
    final int? cashDrawerId,
    final int? cashierId,
    final CashSessionStatus? status,
    final int pageIndex,
  }) = _$CashSessionFilterImpl;

  @override
  int? get cashDrawerId;
  @override
  int? get cashierId;
  @override
  CashSessionStatus? get status;
  @override
  int get pageIndex;

  /// Create a copy of CashSessionFilter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CashSessionFilterImplCopyWith<_$CashSessionFilterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
