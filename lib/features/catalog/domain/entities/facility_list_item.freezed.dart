// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'facility_list_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$FacilityListItem {
  int get facilityId => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  FacilityType get type => throw _privateConstructorUsedError;
  EntityStatus get status => throw _privateConstructorUsedError;

  /// Create a copy of FacilityListItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FacilityListItemCopyWith<FacilityListItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FacilityListItemCopyWith<$Res> {
  factory $FacilityListItemCopyWith(
    FacilityListItem value,
    $Res Function(FacilityListItem) then,
  ) = _$FacilityListItemCopyWithImpl<$Res, FacilityListItem>;
  @useResult
  $Res call({
    int facilityId,
    String code,
    String name,
    FacilityType type,
    EntityStatus status,
  });
}

/// @nodoc
class _$FacilityListItemCopyWithImpl<$Res, $Val extends FacilityListItem>
    implements $FacilityListItemCopyWith<$Res> {
  _$FacilityListItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FacilityListItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? facilityId = null,
    Object? code = null,
    Object? name = null,
    Object? type = null,
    Object? status = null,
  }) {
    return _then(
      _value.copyWith(
            facilityId: null == facilityId
                ? _value.facilityId
                : facilityId // ignore: cast_nullable_to_non_nullable
                      as int,
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as FacilityType,
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
abstract class _$$FacilityListItemImplCopyWith<$Res>
    implements $FacilityListItemCopyWith<$Res> {
  factory _$$FacilityListItemImplCopyWith(
    _$FacilityListItemImpl value,
    $Res Function(_$FacilityListItemImpl) then,
  ) = __$$FacilityListItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int facilityId,
    String code,
    String name,
    FacilityType type,
    EntityStatus status,
  });
}

/// @nodoc
class __$$FacilityListItemImplCopyWithImpl<$Res>
    extends _$FacilityListItemCopyWithImpl<$Res, _$FacilityListItemImpl>
    implements _$$FacilityListItemImplCopyWith<$Res> {
  __$$FacilityListItemImplCopyWithImpl(
    _$FacilityListItemImpl _value,
    $Res Function(_$FacilityListItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FacilityListItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? facilityId = null,
    Object? code = null,
    Object? name = null,
    Object? type = null,
    Object? status = null,
  }) {
    return _then(
      _$FacilityListItemImpl(
        facilityId: null == facilityId
            ? _value.facilityId
            : facilityId // ignore: cast_nullable_to_non_nullable
                  as int,
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as FacilityType,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as EntityStatus,
      ),
    );
  }
}

/// @nodoc

class _$FacilityListItemImpl implements _FacilityListItem {
  const _$FacilityListItemImpl({
    required this.facilityId,
    required this.code,
    required this.name,
    required this.type,
    required this.status,
  });

  @override
  final int facilityId;
  @override
  final String code;
  @override
  final String name;
  @override
  final FacilityType type;
  @override
  final EntityStatus status;

  @override
  String toString() {
    return 'FacilityListItem(facilityId: $facilityId, code: $code, name: $name, type: $type, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FacilityListItemImpl &&
            (identical(other.facilityId, facilityId) ||
                other.facilityId == facilityId) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.status, status) || other.status == status));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, facilityId, code, name, type, status);

  /// Create a copy of FacilityListItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FacilityListItemImplCopyWith<_$FacilityListItemImpl> get copyWith =>
      __$$FacilityListItemImplCopyWithImpl<_$FacilityListItemImpl>(
        this,
        _$identity,
      );
}

abstract class _FacilityListItem implements FacilityListItem {
  const factory _FacilityListItem({
    required final int facilityId,
    required final String code,
    required final String name,
    required final FacilityType type,
    required final EntityStatus status,
  }) = _$FacilityListItemImpl;

  @override
  int get facilityId;
  @override
  String get code;
  @override
  String get name;
  @override
  FacilityType get type;
  @override
  EntityStatus get status;

  /// Create a copy of FacilityListItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FacilityListItemImplCopyWith<_$FacilityListItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
