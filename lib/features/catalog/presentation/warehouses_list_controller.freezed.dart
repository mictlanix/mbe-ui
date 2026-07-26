// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'warehouses_list_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$WarehouseFilter {
  String get search => throw _privateConstructorUsedError;
  int? get facilityId => throw _privateConstructorUsedError;
  EntityStatus? get status => throw _privateConstructorUsedError;
  int get pageIndex => throw _privateConstructorUsedError;

  /// Create a copy of WarehouseFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WarehouseFilterCopyWith<WarehouseFilter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WarehouseFilterCopyWith<$Res> {
  factory $WarehouseFilterCopyWith(
    WarehouseFilter value,
    $Res Function(WarehouseFilter) then,
  ) = _$WarehouseFilterCopyWithImpl<$Res, WarehouseFilter>;
  @useResult
  $Res call({
    String search,
    int? facilityId,
    EntityStatus? status,
    int pageIndex,
  });
}

/// @nodoc
class _$WarehouseFilterCopyWithImpl<$Res, $Val extends WarehouseFilter>
    implements $WarehouseFilterCopyWith<$Res> {
  _$WarehouseFilterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WarehouseFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? search = null,
    Object? facilityId = freezed,
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
abstract class _$$WarehouseFilterImplCopyWith<$Res>
    implements $WarehouseFilterCopyWith<$Res> {
  factory _$$WarehouseFilterImplCopyWith(
    _$WarehouseFilterImpl value,
    $Res Function(_$WarehouseFilterImpl) then,
  ) = __$$WarehouseFilterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String search,
    int? facilityId,
    EntityStatus? status,
    int pageIndex,
  });
}

/// @nodoc
class __$$WarehouseFilterImplCopyWithImpl<$Res>
    extends _$WarehouseFilterCopyWithImpl<$Res, _$WarehouseFilterImpl>
    implements _$$WarehouseFilterImplCopyWith<$Res> {
  __$$WarehouseFilterImplCopyWithImpl(
    _$WarehouseFilterImpl _value,
    $Res Function(_$WarehouseFilterImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WarehouseFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? search = null,
    Object? facilityId = freezed,
    Object? status = freezed,
    Object? pageIndex = null,
  }) {
    return _then(
      _$WarehouseFilterImpl(
        search: null == search
            ? _value.search
            : search // ignore: cast_nullable_to_non_nullable
                  as String,
        facilityId: freezed == facilityId
            ? _value.facilityId
            : facilityId // ignore: cast_nullable_to_non_nullable
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

class _$WarehouseFilterImpl implements _WarehouseFilter {
  const _$WarehouseFilterImpl({
    this.search = '',
    this.facilityId,
    this.status,
    this.pageIndex = 0,
  });

  @override
  @JsonKey()
  final String search;
  @override
  final int? facilityId;
  @override
  final EntityStatus? status;
  @override
  @JsonKey()
  final int pageIndex;

  @override
  String toString() {
    return 'WarehouseFilter(search: $search, facilityId: $facilityId, status: $status, pageIndex: $pageIndex)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WarehouseFilterImpl &&
            (identical(other.search, search) || other.search == search) &&
            (identical(other.facilityId, facilityId) ||
                other.facilityId == facilityId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.pageIndex, pageIndex) ||
                other.pageIndex == pageIndex));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, search, facilityId, status, pageIndex);

  /// Create a copy of WarehouseFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WarehouseFilterImplCopyWith<_$WarehouseFilterImpl> get copyWith =>
      __$$WarehouseFilterImplCopyWithImpl<_$WarehouseFilterImpl>(
        this,
        _$identity,
      );
}

abstract class _WarehouseFilter implements WarehouseFilter {
  const factory _WarehouseFilter({
    final String search,
    final int? facilityId,
    final EntityStatus? status,
    final int pageIndex,
  }) = _$WarehouseFilterImpl;

  @override
  String get search;
  @override
  int? get facilityId;
  @override
  EntityStatus? get status;
  @override
  int get pageIndex;

  /// Create a copy of WarehouseFilter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WarehouseFilterImplCopyWith<_$WarehouseFilterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
