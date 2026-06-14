// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'privilege.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Privilege {
  SystemObject get systemObject => throw _privateConstructorUsedError;
  int get rawValue => throw _privateConstructorUsedError;

  /// Create a copy of Privilege
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PrivilegeCopyWith<Privilege> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PrivilegeCopyWith<$Res> {
  factory $PrivilegeCopyWith(Privilege value, $Res Function(Privilege) then) =
      _$PrivilegeCopyWithImpl<$Res, Privilege>;
  @useResult
  $Res call({SystemObject systemObject, int rawValue});
}

/// @nodoc
class _$PrivilegeCopyWithImpl<$Res, $Val extends Privilege>
    implements $PrivilegeCopyWith<$Res> {
  _$PrivilegeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Privilege
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? systemObject = null, Object? rawValue = null}) {
    return _then(
      _value.copyWith(
            systemObject: null == systemObject
                ? _value.systemObject
                : systemObject // ignore: cast_nullable_to_non_nullable
                      as SystemObject,
            rawValue: null == rawValue
                ? _value.rawValue
                : rawValue // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PrivilegeImplCopyWith<$Res>
    implements $PrivilegeCopyWith<$Res> {
  factory _$$PrivilegeImplCopyWith(
    _$PrivilegeImpl value,
    $Res Function(_$PrivilegeImpl) then,
  ) = __$$PrivilegeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({SystemObject systemObject, int rawValue});
}

/// @nodoc
class __$$PrivilegeImplCopyWithImpl<$Res>
    extends _$PrivilegeCopyWithImpl<$Res, _$PrivilegeImpl>
    implements _$$PrivilegeImplCopyWith<$Res> {
  __$$PrivilegeImplCopyWithImpl(
    _$PrivilegeImpl _value,
    $Res Function(_$PrivilegeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Privilege
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? systemObject = null, Object? rawValue = null}) {
    return _then(
      _$PrivilegeImpl(
        systemObject: null == systemObject
            ? _value.systemObject
            : systemObject // ignore: cast_nullable_to_non_nullable
                  as SystemObject,
        rawValue: null == rawValue
            ? _value.rawValue
            : rawValue // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$PrivilegeImpl extends _Privilege {
  const _$PrivilegeImpl({required this.systemObject, required this.rawValue})
    : assert(rawValue >= 0 && rawValue <= 15, 'rawValue must be in 0..15'),
      super._();

  @override
  final SystemObject systemObject;
  @override
  final int rawValue;

  @override
  String toString() {
    return 'Privilege(systemObject: $systemObject, rawValue: $rawValue)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PrivilegeImpl &&
            (identical(other.systemObject, systemObject) ||
                other.systemObject == systemObject) &&
            (identical(other.rawValue, rawValue) ||
                other.rawValue == rawValue));
  }

  @override
  int get hashCode => Object.hash(runtimeType, systemObject, rawValue);

  /// Create a copy of Privilege
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PrivilegeImplCopyWith<_$PrivilegeImpl> get copyWith =>
      __$$PrivilegeImplCopyWithImpl<_$PrivilegeImpl>(this, _$identity);
}

abstract class _Privilege extends Privilege {
  const factory _Privilege({
    required final SystemObject systemObject,
    required final int rawValue,
  }) = _$PrivilegeImpl;
  const _Privilege._() : super._();

  @override
  SystemObject get systemObject;
  @override
  int get rawValue;

  /// Create a copy of Privilege
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PrivilegeImplCopyWith<_$PrivilegeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
