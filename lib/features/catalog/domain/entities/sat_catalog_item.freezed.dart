// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sat_catalog_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$SatCatalogItem {
  String get code => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;

  /// Create a copy of SatCatalogItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SatCatalogItemCopyWith<SatCatalogItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SatCatalogItemCopyWith<$Res> {
  factory $SatCatalogItemCopyWith(
    SatCatalogItem value,
    $Res Function(SatCatalogItem) then,
  ) = _$SatCatalogItemCopyWithImpl<$Res, SatCatalogItem>;
  @useResult
  $Res call({String code, String? description});
}

/// @nodoc
class _$SatCatalogItemCopyWithImpl<$Res, $Val extends SatCatalogItem>
    implements $SatCatalogItemCopyWith<$Res> {
  _$SatCatalogItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SatCatalogItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? code = null, Object? description = freezed}) {
    return _then(
      _value.copyWith(
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SatCatalogItemImplCopyWith<$Res>
    implements $SatCatalogItemCopyWith<$Res> {
  factory _$$SatCatalogItemImplCopyWith(
    _$SatCatalogItemImpl value,
    $Res Function(_$SatCatalogItemImpl) then,
  ) = __$$SatCatalogItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String code, String? description});
}

/// @nodoc
class __$$SatCatalogItemImplCopyWithImpl<$Res>
    extends _$SatCatalogItemCopyWithImpl<$Res, _$SatCatalogItemImpl>
    implements _$$SatCatalogItemImplCopyWith<$Res> {
  __$$SatCatalogItemImplCopyWithImpl(
    _$SatCatalogItemImpl _value,
    $Res Function(_$SatCatalogItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SatCatalogItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? code = null, Object? description = freezed}) {
    return _then(
      _$SatCatalogItemImpl(
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$SatCatalogItemImpl implements _SatCatalogItem {
  const _$SatCatalogItemImpl({required this.code, this.description});

  @override
  final String code;
  @override
  final String? description;

  @override
  String toString() {
    return 'SatCatalogItem(code: $code, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SatCatalogItemImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @override
  int get hashCode => Object.hash(runtimeType, code, description);

  /// Create a copy of SatCatalogItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SatCatalogItemImplCopyWith<_$SatCatalogItemImpl> get copyWith =>
      __$$SatCatalogItemImplCopyWithImpl<_$SatCatalogItemImpl>(
        this,
        _$identity,
      );
}

abstract class _SatCatalogItem implements SatCatalogItem {
  const factory _SatCatalogItem({
    required final String code,
    final String? description,
  }) = _$SatCatalogItemImpl;

  @override
  String get code;
  @override
  String? get description;

  /// Create a copy of SatCatalogItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SatCatalogItemImplCopyWith<_$SatCatalogItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
