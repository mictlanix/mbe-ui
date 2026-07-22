// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'points_of_sale_list_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$PointSaleFilter {
  String get search => throw _privateConstructorUsedError;
  int? get facilityId => throw _privateConstructorUsedError;
  String get facilityDisplayText => throw _privateConstructorUsedError;
  int? get warehouseId => throw _privateConstructorUsedError;
  String get warehouseDisplayText => throw _privateConstructorUsedError;
  EntityStatus? get status => throw _privateConstructorUsedError;

  /// Create a copy of PointSaleFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PointSaleFilterCopyWith<PointSaleFilter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PointSaleFilterCopyWith<$Res> {
  factory $PointSaleFilterCopyWith(
    PointSaleFilter value,
    $Res Function(PointSaleFilter) then,
  ) = _$PointSaleFilterCopyWithImpl<$Res, PointSaleFilter>;
  @useResult
  $Res call({
    String search,
    int? facilityId,
    String facilityDisplayText,
    int? warehouseId,
    String warehouseDisplayText,
    EntityStatus? status,
  });
}

/// @nodoc
class _$PointSaleFilterCopyWithImpl<$Res, $Val extends PointSaleFilter>
    implements $PointSaleFilterCopyWith<$Res> {
  _$PointSaleFilterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PointSaleFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? search = null,
    Object? facilityId = freezed,
    Object? facilityDisplayText = null,
    Object? warehouseId = freezed,
    Object? warehouseDisplayText = null,
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
            warehouseId: freezed == warehouseId
                ? _value.warehouseId
                : warehouseId // ignore: cast_nullable_to_non_nullable
                      as int?,
            warehouseDisplayText: null == warehouseDisplayText
                ? _value.warehouseDisplayText
                : warehouseDisplayText // ignore: cast_nullable_to_non_nullable
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
abstract class _$$PointSaleFilterImplCopyWith<$Res>
    implements $PointSaleFilterCopyWith<$Res> {
  factory _$$PointSaleFilterImplCopyWith(
    _$PointSaleFilterImpl value,
    $Res Function(_$PointSaleFilterImpl) then,
  ) = __$$PointSaleFilterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String search,
    int? facilityId,
    String facilityDisplayText,
    int? warehouseId,
    String warehouseDisplayText,
    EntityStatus? status,
  });
}

/// @nodoc
class __$$PointSaleFilterImplCopyWithImpl<$Res>
    extends _$PointSaleFilterCopyWithImpl<$Res, _$PointSaleFilterImpl>
    implements _$$PointSaleFilterImplCopyWith<$Res> {
  __$$PointSaleFilterImplCopyWithImpl(
    _$PointSaleFilterImpl _value,
    $Res Function(_$PointSaleFilterImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PointSaleFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? search = null,
    Object? facilityId = freezed,
    Object? facilityDisplayText = null,
    Object? warehouseId = freezed,
    Object? warehouseDisplayText = null,
    Object? status = freezed,
  }) {
    return _then(
      _$PointSaleFilterImpl(
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
        warehouseId: freezed == warehouseId
            ? _value.warehouseId
            : warehouseId // ignore: cast_nullable_to_non_nullable
                  as int?,
        warehouseDisplayText: null == warehouseDisplayText
            ? _value.warehouseDisplayText
            : warehouseDisplayText // ignore: cast_nullable_to_non_nullable
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

class _$PointSaleFilterImpl implements _PointSaleFilter {
  const _$PointSaleFilterImpl({
    this.search = '',
    this.facilityId,
    this.facilityDisplayText = '',
    this.warehouseId,
    this.warehouseDisplayText = '',
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
  final int? warehouseId;
  @override
  @JsonKey()
  final String warehouseDisplayText;
  @override
  final EntityStatus? status;

  @override
  String toString() {
    return 'PointSaleFilter(search: $search, facilityId: $facilityId, facilityDisplayText: $facilityDisplayText, warehouseId: $warehouseId, warehouseDisplayText: $warehouseDisplayText, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PointSaleFilterImpl &&
            (identical(other.search, search) || other.search == search) &&
            (identical(other.facilityId, facilityId) ||
                other.facilityId == facilityId) &&
            (identical(other.facilityDisplayText, facilityDisplayText) ||
                other.facilityDisplayText == facilityDisplayText) &&
            (identical(other.warehouseId, warehouseId) ||
                other.warehouseId == warehouseId) &&
            (identical(other.warehouseDisplayText, warehouseDisplayText) ||
                other.warehouseDisplayText == warehouseDisplayText) &&
            (identical(other.status, status) || other.status == status));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    search,
    facilityId,
    facilityDisplayText,
    warehouseId,
    warehouseDisplayText,
    status,
  );

  /// Create a copy of PointSaleFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PointSaleFilterImplCopyWith<_$PointSaleFilterImpl> get copyWith =>
      __$$PointSaleFilterImplCopyWithImpl<_$PointSaleFilterImpl>(
        this,
        _$identity,
      );
}

abstract class _PointSaleFilter implements PointSaleFilter {
  const factory _PointSaleFilter({
    final String search,
    final int? facilityId,
    final String facilityDisplayText,
    final int? warehouseId,
    final String warehouseDisplayText,
    final EntityStatus? status,
  }) = _$PointSaleFilterImpl;

  @override
  String get search;
  @override
  int? get facilityId;
  @override
  String get facilityDisplayText;
  @override
  int? get warehouseId;
  @override
  String get warehouseDisplayText;
  @override
  EntityStatus? get status;

  /// Create a copy of PointSaleFilter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PointSaleFilterImplCopyWith<_$PointSaleFilterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
