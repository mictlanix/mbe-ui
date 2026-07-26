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
  int? get warehouseId => throw _privateConstructorUsedError;
  EntityStatus? get status => throw _privateConstructorUsedError;
  int get pageIndex => throw _privateConstructorUsedError;

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
    int? warehouseId,
    EntityStatus? status,
    int pageIndex,
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
    Object? warehouseId = freezed,
    Object? status = freezed,
    Object? pageIndex = null,
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
            warehouseId: freezed == warehouseId
                ? _value.warehouseId
                : warehouseId // ignore: cast_nullable_to_non_nullable
                      as int?,
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
    int? warehouseId,
    EntityStatus? status,
    int pageIndex,
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
    Object? warehouseId = freezed,
    Object? status = freezed,
    Object? pageIndex = null,
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
        warehouseId: freezed == warehouseId
            ? _value.warehouseId
            : warehouseId // ignore: cast_nullable_to_non_nullable
                  as int?,
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

class _$PointSaleFilterImpl implements _PointSaleFilter {
  const _$PointSaleFilterImpl({
    this.search = '',
    this.facilityId,
    this.warehouseId,
    this.status,
    this.pageIndex = 0,
  });

  @override
  @JsonKey()
  final String search;
  @override
  final int? facilityId;
  @override
  final int? warehouseId;
  @override
  final EntityStatus? status;
  @override
  @JsonKey()
  final int pageIndex;

  @override
  String toString() {
    return 'PointSaleFilter(search: $search, facilityId: $facilityId, warehouseId: $warehouseId, status: $status, pageIndex: $pageIndex)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PointSaleFilterImpl &&
            (identical(other.search, search) || other.search == search) &&
            (identical(other.facilityId, facilityId) ||
                other.facilityId == facilityId) &&
            (identical(other.warehouseId, warehouseId) ||
                other.warehouseId == warehouseId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.pageIndex, pageIndex) ||
                other.pageIndex == pageIndex));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    search,
    facilityId,
    warehouseId,
    status,
    pageIndex,
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
    final int? warehouseId,
    final EntityStatus? status,
    final int pageIndex,
  }) = _$PointSaleFilterImpl;

  @override
  String get search;
  @override
  int? get facilityId;
  @override
  int? get warehouseId;
  @override
  EntityStatus? get status;
  @override
  int get pageIndex;

  /// Create a copy of PointSaleFilter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PointSaleFilterImplCopyWith<_$PointSaleFilterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
