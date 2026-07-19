// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'employees_list_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$EmployeeFilter {
  String get search => throw _privateConstructorUsedError;
  bool? get active => throw _privateConstructorUsedError;
  bool? get salesPerson => throw _privateConstructorUsedError;

  /// Create a copy of EmployeeFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EmployeeFilterCopyWith<EmployeeFilter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EmployeeFilterCopyWith<$Res> {
  factory $EmployeeFilterCopyWith(
    EmployeeFilter value,
    $Res Function(EmployeeFilter) then,
  ) = _$EmployeeFilterCopyWithImpl<$Res, EmployeeFilter>;
  @useResult
  $Res call({String search, bool? active, bool? salesPerson});
}

/// @nodoc
class _$EmployeeFilterCopyWithImpl<$Res, $Val extends EmployeeFilter>
    implements $EmployeeFilterCopyWith<$Res> {
  _$EmployeeFilterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EmployeeFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? search = null,
    Object? active = freezed,
    Object? salesPerson = freezed,
  }) {
    return _then(
      _value.copyWith(
            search: null == search
                ? _value.search
                : search // ignore: cast_nullable_to_non_nullable
                      as String,
            active: freezed == active
                ? _value.active
                : active // ignore: cast_nullable_to_non_nullable
                      as bool?,
            salesPerson: freezed == salesPerson
                ? _value.salesPerson
                : salesPerson // ignore: cast_nullable_to_non_nullable
                      as bool?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EmployeeFilterImplCopyWith<$Res>
    implements $EmployeeFilterCopyWith<$Res> {
  factory _$$EmployeeFilterImplCopyWith(
    _$EmployeeFilterImpl value,
    $Res Function(_$EmployeeFilterImpl) then,
  ) = __$$EmployeeFilterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String search, bool? active, bool? salesPerson});
}

/// @nodoc
class __$$EmployeeFilterImplCopyWithImpl<$Res>
    extends _$EmployeeFilterCopyWithImpl<$Res, _$EmployeeFilterImpl>
    implements _$$EmployeeFilterImplCopyWith<$Res> {
  __$$EmployeeFilterImplCopyWithImpl(
    _$EmployeeFilterImpl _value,
    $Res Function(_$EmployeeFilterImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EmployeeFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? search = null,
    Object? active = freezed,
    Object? salesPerson = freezed,
  }) {
    return _then(
      _$EmployeeFilterImpl(
        search: null == search
            ? _value.search
            : search // ignore: cast_nullable_to_non_nullable
                  as String,
        active: freezed == active
            ? _value.active
            : active // ignore: cast_nullable_to_non_nullable
                  as bool?,
        salesPerson: freezed == salesPerson
            ? _value.salesPerson
            : salesPerson // ignore: cast_nullable_to_non_nullable
                  as bool?,
      ),
    );
  }
}

/// @nodoc

class _$EmployeeFilterImpl implements _EmployeeFilter {
  const _$EmployeeFilterImpl({this.search = '', this.active, this.salesPerson});

  @override
  @JsonKey()
  final String search;
  @override
  final bool? active;
  @override
  final bool? salesPerson;

  @override
  String toString() {
    return 'EmployeeFilter(search: $search, active: $active, salesPerson: $salesPerson)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EmployeeFilterImpl &&
            (identical(other.search, search) || other.search == search) &&
            (identical(other.active, active) || other.active == active) &&
            (identical(other.salesPerson, salesPerson) ||
                other.salesPerson == salesPerson));
  }

  @override
  int get hashCode => Object.hash(runtimeType, search, active, salesPerson);

  /// Create a copy of EmployeeFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EmployeeFilterImplCopyWith<_$EmployeeFilterImpl> get copyWith =>
      __$$EmployeeFilterImplCopyWithImpl<_$EmployeeFilterImpl>(
        this,
        _$identity,
      );
}

abstract class _EmployeeFilter implements EmployeeFilter {
  const factory _EmployeeFilter({
    final String search,
    final bool? active,
    final bool? salesPerson,
  }) = _$EmployeeFilterImpl;

  @override
  String get search;
  @override
  bool? get active;
  @override
  bool? get salesPerson;

  /// Create a copy of EmployeeFilter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EmployeeFilterImplCopyWith<_$EmployeeFilterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
