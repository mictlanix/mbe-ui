// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vehicle_operators_list_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$VehicleOperatorFilter {
  String get search => throw _privateConstructorUsedError;
  int? get driverId => throw _privateConstructorUsedError;
  String get driverDisplayText => throw _privateConstructorUsedError;

  /// Create a copy of VehicleOperatorFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VehicleOperatorFilterCopyWith<VehicleOperatorFilter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VehicleOperatorFilterCopyWith<$Res> {
  factory $VehicleOperatorFilterCopyWith(
    VehicleOperatorFilter value,
    $Res Function(VehicleOperatorFilter) then,
  ) = _$VehicleOperatorFilterCopyWithImpl<$Res, VehicleOperatorFilter>;
  @useResult
  $Res call({String search, int? driverId, String driverDisplayText});
}

/// @nodoc
class _$VehicleOperatorFilterCopyWithImpl<
  $Res,
  $Val extends VehicleOperatorFilter
>
    implements $VehicleOperatorFilterCopyWith<$Res> {
  _$VehicleOperatorFilterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VehicleOperatorFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? search = null,
    Object? driverId = freezed,
    Object? driverDisplayText = null,
  }) {
    return _then(
      _value.copyWith(
            search: null == search
                ? _value.search
                : search // ignore: cast_nullable_to_non_nullable
                      as String,
            driverId: freezed == driverId
                ? _value.driverId
                : driverId // ignore: cast_nullable_to_non_nullable
                      as int?,
            driverDisplayText: null == driverDisplayText
                ? _value.driverDisplayText
                : driverDisplayText // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VehicleOperatorFilterImplCopyWith<$Res>
    implements $VehicleOperatorFilterCopyWith<$Res> {
  factory _$$VehicleOperatorFilterImplCopyWith(
    _$VehicleOperatorFilterImpl value,
    $Res Function(_$VehicleOperatorFilterImpl) then,
  ) = __$$VehicleOperatorFilterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String search, int? driverId, String driverDisplayText});
}

/// @nodoc
class __$$VehicleOperatorFilterImplCopyWithImpl<$Res>
    extends
        _$VehicleOperatorFilterCopyWithImpl<$Res, _$VehicleOperatorFilterImpl>
    implements _$$VehicleOperatorFilterImplCopyWith<$Res> {
  __$$VehicleOperatorFilterImplCopyWithImpl(
    _$VehicleOperatorFilterImpl _value,
    $Res Function(_$VehicleOperatorFilterImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VehicleOperatorFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? search = null,
    Object? driverId = freezed,
    Object? driverDisplayText = null,
  }) {
    return _then(
      _$VehicleOperatorFilterImpl(
        search: null == search
            ? _value.search
            : search // ignore: cast_nullable_to_non_nullable
                  as String,
        driverId: freezed == driverId
            ? _value.driverId
            : driverId // ignore: cast_nullable_to_non_nullable
                  as int?,
        driverDisplayText: null == driverDisplayText
            ? _value.driverDisplayText
            : driverDisplayText // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$VehicleOperatorFilterImpl implements _VehicleOperatorFilter {
  const _$VehicleOperatorFilterImpl({
    this.search = '',
    this.driverId,
    this.driverDisplayText = '',
  });

  @override
  @JsonKey()
  final String search;
  @override
  final int? driverId;
  @override
  @JsonKey()
  final String driverDisplayText;

  @override
  String toString() {
    return 'VehicleOperatorFilter(search: $search, driverId: $driverId, driverDisplayText: $driverDisplayText)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VehicleOperatorFilterImpl &&
            (identical(other.search, search) || other.search == search) &&
            (identical(other.driverId, driverId) ||
                other.driverId == driverId) &&
            (identical(other.driverDisplayText, driverDisplayText) ||
                other.driverDisplayText == driverDisplayText));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, search, driverId, driverDisplayText);

  /// Create a copy of VehicleOperatorFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VehicleOperatorFilterImplCopyWith<_$VehicleOperatorFilterImpl>
  get copyWith =>
      __$$VehicleOperatorFilterImplCopyWithImpl<_$VehicleOperatorFilterImpl>(
        this,
        _$identity,
      );
}

abstract class _VehicleOperatorFilter implements VehicleOperatorFilter {
  const factory _VehicleOperatorFilter({
    final String search,
    final int? driverId,
    final String driverDisplayText,
  }) = _$VehicleOperatorFilterImpl;

  @override
  String get search;
  @override
  int? get driverId;
  @override
  String get driverDisplayText;

  /// Create a copy of VehicleOperatorFilter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VehicleOperatorFilterImplCopyWith<_$VehicleOperatorFilterImpl>
  get copyWith => throw _privateConstructorUsedError;
}
