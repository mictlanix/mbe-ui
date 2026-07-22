// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_method_options_list_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$PaymentMethodOptionFilter {
  String get search => throw _privateConstructorUsedError;
  int? get facilityId => throw _privateConstructorUsedError;
  String get facilityDisplayText => throw _privateConstructorUsedError;
  EntityStatus? get status => throw _privateConstructorUsedError;

  /// Create a copy of PaymentMethodOptionFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaymentMethodOptionFilterCopyWith<PaymentMethodOptionFilter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentMethodOptionFilterCopyWith<$Res> {
  factory $PaymentMethodOptionFilterCopyWith(
    PaymentMethodOptionFilter value,
    $Res Function(PaymentMethodOptionFilter) then,
  ) = _$PaymentMethodOptionFilterCopyWithImpl<$Res, PaymentMethodOptionFilter>;
  @useResult
  $Res call({
    String search,
    int? facilityId,
    String facilityDisplayText,
    EntityStatus? status,
  });
}

/// @nodoc
class _$PaymentMethodOptionFilterCopyWithImpl<
  $Res,
  $Val extends PaymentMethodOptionFilter
>
    implements $PaymentMethodOptionFilterCopyWith<$Res> {
  _$PaymentMethodOptionFilterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaymentMethodOptionFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? search = null,
    Object? facilityId = freezed,
    Object? facilityDisplayText = null,
    Object? status = freezed,
  }) {
    return _then(
      _value.copyWith(
            search: null == search
                ? _value.search
                : search // ignore: cast_nullable_to_non_nullable
                      as String,
            facilityId: freezed == facilityId
                ? _value.facilityId
                : facilityId // ignore: cast_nullable_to_non_nullable
                      as int?,
            facilityDisplayText: null == facilityDisplayText
                ? _value.facilityDisplayText
                : facilityDisplayText // ignore: cast_nullable_to_non_nullable
                      as String,
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as EntityStatus?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PaymentMethodOptionFilterImplCopyWith<$Res>
    implements $PaymentMethodOptionFilterCopyWith<$Res> {
  factory _$$PaymentMethodOptionFilterImplCopyWith(
    _$PaymentMethodOptionFilterImpl value,
    $Res Function(_$PaymentMethodOptionFilterImpl) then,
  ) = __$$PaymentMethodOptionFilterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String search,
    int? facilityId,
    String facilityDisplayText,
    EntityStatus? status,
  });
}

/// @nodoc
class __$$PaymentMethodOptionFilterImplCopyWithImpl<$Res>
    extends
        _$PaymentMethodOptionFilterCopyWithImpl<
          $Res,
          _$PaymentMethodOptionFilterImpl
        >
    implements _$$PaymentMethodOptionFilterImplCopyWith<$Res> {
  __$$PaymentMethodOptionFilterImplCopyWithImpl(
    _$PaymentMethodOptionFilterImpl _value,
    $Res Function(_$PaymentMethodOptionFilterImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentMethodOptionFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? search = null,
    Object? facilityId = freezed,
    Object? facilityDisplayText = null,
    Object? status = freezed,
  }) {
    return _then(
      _$PaymentMethodOptionFilterImpl(
        search: null == search
            ? _value.search
            : search // ignore: cast_nullable_to_non_nullable
                  as String,
        facilityId: freezed == facilityId
            ? _value.facilityId
            : facilityId // ignore: cast_nullable_to_non_nullable
                  as int?,
        facilityDisplayText: null == facilityDisplayText
            ? _value.facilityDisplayText
            : facilityDisplayText // ignore: cast_nullable_to_non_nullable
                  as String,
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as EntityStatus?,
      ),
    );
  }
}

/// @nodoc

class _$PaymentMethodOptionFilterImpl implements _PaymentMethodOptionFilter {
  const _$PaymentMethodOptionFilterImpl({
    this.search = '',
    this.facilityId,
    this.facilityDisplayText = '',
    this.status,
  });

  @override
  @JsonKey()
  final String search;
  @override
  final int? facilityId;
  @override
  @JsonKey()
  final String facilityDisplayText;
  @override
  final EntityStatus? status;

  @override
  String toString() {
    return 'PaymentMethodOptionFilter(search: $search, facilityId: $facilityId, facilityDisplayText: $facilityDisplayText, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentMethodOptionFilterImpl &&
            (identical(other.search, search) || other.search == search) &&
            (identical(other.facilityId, facilityId) ||
                other.facilityId == facilityId) &&
            (identical(other.facilityDisplayText, facilityDisplayText) ||
                other.facilityDisplayText == facilityDisplayText) &&
            (identical(other.status, status) || other.status == status));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, search, facilityId, facilityDisplayText, status);

  /// Create a copy of PaymentMethodOptionFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentMethodOptionFilterImplCopyWith<_$PaymentMethodOptionFilterImpl>
  get copyWith =>
      __$$PaymentMethodOptionFilterImplCopyWithImpl<
        _$PaymentMethodOptionFilterImpl
      >(this, _$identity);
}

abstract class _PaymentMethodOptionFilter implements PaymentMethodOptionFilter {
  const factory _PaymentMethodOptionFilter({
    final String search,
    final int? facilityId,
    final String facilityDisplayText,
    final EntityStatus? status,
  }) = _$PaymentMethodOptionFilterImpl;

  @override
  String get search;
  @override
  int? get facilityId;
  @override
  String get facilityDisplayText;
  @override
  EntityStatus? get status;

  /// Create a copy of PaymentMethodOptionFilter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentMethodOptionFilterImplCopyWith<_$PaymentMethodOptionFilterImpl>
  get copyWith => throw _privateConstructorUsedError;
}
