// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'employee_list_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$EmployeeListItem {
  int get employeeId => throw _privateConstructorUsedError;
  String get fullName => throw _privateConstructorUsedError;
  String get nickname => throw _privateConstructorUsedError;
  EntityStatus get status => throw _privateConstructorUsedError;
  bool get salesPerson => throw _privateConstructorUsedError;

  /// Create a copy of EmployeeListItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EmployeeListItemCopyWith<EmployeeListItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EmployeeListItemCopyWith<$Res> {
  factory $EmployeeListItemCopyWith(
    EmployeeListItem value,
    $Res Function(EmployeeListItem) then,
  ) = _$EmployeeListItemCopyWithImpl<$Res, EmployeeListItem>;
  @useResult
  $Res call({
    int employeeId,
    String fullName,
    String nickname,
    EntityStatus status,
    bool salesPerson,
  });
}

/// @nodoc
class _$EmployeeListItemCopyWithImpl<$Res, $Val extends EmployeeListItem>
    implements $EmployeeListItemCopyWith<$Res> {
  _$EmployeeListItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EmployeeListItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? employeeId = null,
    Object? fullName = null,
    Object? nickname = null,
    Object? status = null,
    Object? salesPerson = null,
  }) {
    return _then(
      _value.copyWith(
            employeeId: null == employeeId
                ? _value.employeeId
                : employeeId // ignore: cast_nullable_to_non_nullable
                      as int,
            fullName: null == fullName
                ? _value.fullName
                : fullName // ignore: cast_nullable_to_non_nullable
                      as String,
            nickname: null == nickname
                ? _value.nickname
                : nickname // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as EntityStatus,
            salesPerson: null == salesPerson
                ? _value.salesPerson
                : salesPerson // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EmployeeListItemImplCopyWith<$Res>
    implements $EmployeeListItemCopyWith<$Res> {
  factory _$$EmployeeListItemImplCopyWith(
    _$EmployeeListItemImpl value,
    $Res Function(_$EmployeeListItemImpl) then,
  ) = __$$EmployeeListItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int employeeId,
    String fullName,
    String nickname,
    EntityStatus status,
    bool salesPerson,
  });
}

/// @nodoc
class __$$EmployeeListItemImplCopyWithImpl<$Res>
    extends _$EmployeeListItemCopyWithImpl<$Res, _$EmployeeListItemImpl>
    implements _$$EmployeeListItemImplCopyWith<$Res> {
  __$$EmployeeListItemImplCopyWithImpl(
    _$EmployeeListItemImpl _value,
    $Res Function(_$EmployeeListItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EmployeeListItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? employeeId = null,
    Object? fullName = null,
    Object? nickname = null,
    Object? status = null,
    Object? salesPerson = null,
  }) {
    return _then(
      _$EmployeeListItemImpl(
        employeeId: null == employeeId
            ? _value.employeeId
            : employeeId // ignore: cast_nullable_to_non_nullable
                  as int,
        fullName: null == fullName
            ? _value.fullName
            : fullName // ignore: cast_nullable_to_non_nullable
                  as String,
        nickname: null == nickname
            ? _value.nickname
            : nickname // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as EntityStatus,
        salesPerson: null == salesPerson
            ? _value.salesPerson
            : salesPerson // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$EmployeeListItemImpl implements _EmployeeListItem {
  const _$EmployeeListItemImpl({
    required this.employeeId,
    required this.fullName,
    required this.nickname,
    required this.status,
    required this.salesPerson,
  });

  @override
  final int employeeId;
  @override
  final String fullName;
  @override
  final String nickname;
  @override
  final EntityStatus status;
  @override
  final bool salesPerson;

  @override
  String toString() {
    return 'EmployeeListItem(employeeId: $employeeId, fullName: $fullName, nickname: $nickname, status: $status, salesPerson: $salesPerson)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EmployeeListItemImpl &&
            (identical(other.employeeId, employeeId) ||
                other.employeeId == employeeId) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.salesPerson, salesPerson) ||
                other.salesPerson == salesPerson));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    employeeId,
    fullName,
    nickname,
    status,
    salesPerson,
  );

  /// Create a copy of EmployeeListItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EmployeeListItemImplCopyWith<_$EmployeeListItemImpl> get copyWith =>
      __$$EmployeeListItemImplCopyWithImpl<_$EmployeeListItemImpl>(
        this,
        _$identity,
      );
}

abstract class _EmployeeListItem implements EmployeeListItem {
  const factory _EmployeeListItem({
    required final int employeeId,
    required final String fullName,
    required final String nickname,
    required final EntityStatus status,
    required final bool salesPerson,
  }) = _$EmployeeListItemImpl;

  @override
  int get employeeId;
  @override
  String get fullName;
  @override
  String get nickname;
  @override
  EntityStatus get status;
  @override
  bool get salesPerson;

  /// Create a copy of EmployeeListItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EmployeeListItemImplCopyWith<_$EmployeeListItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
