// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'supplier_list_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$SupplierListItem {
  int get supplierId => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;

  /// Create a copy of SupplierListItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SupplierListItemCopyWith<SupplierListItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SupplierListItemCopyWith<$Res> {
  factory $SupplierListItemCopyWith(
    SupplierListItem value,
    $Res Function(SupplierListItem) then,
  ) = _$SupplierListItemCopyWithImpl<$Res, SupplierListItem>;
  @useResult
  $Res call({int supplierId, String code, String name});
}

/// @nodoc
class _$SupplierListItemCopyWithImpl<$Res, $Val extends SupplierListItem>
    implements $SupplierListItemCopyWith<$Res> {
  _$SupplierListItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SupplierListItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? supplierId = null,
    Object? code = null,
    Object? name = null,
  }) {
    return _then(
      _value.copyWith(
            supplierId: null == supplierId
                ? _value.supplierId
                : supplierId // ignore: cast_nullable_to_non_nullable
                      as int,
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SupplierListItemImplCopyWith<$Res>
    implements $SupplierListItemCopyWith<$Res> {
  factory _$$SupplierListItemImplCopyWith(
    _$SupplierListItemImpl value,
    $Res Function(_$SupplierListItemImpl) then,
  ) = __$$SupplierListItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int supplierId, String code, String name});
}

/// @nodoc
class __$$SupplierListItemImplCopyWithImpl<$Res>
    extends _$SupplierListItemCopyWithImpl<$Res, _$SupplierListItemImpl>
    implements _$$SupplierListItemImplCopyWith<$Res> {
  __$$SupplierListItemImplCopyWithImpl(
    _$SupplierListItemImpl _value,
    $Res Function(_$SupplierListItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SupplierListItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? supplierId = null,
    Object? code = null,
    Object? name = null,
  }) {
    return _then(
      _$SupplierListItemImpl(
        supplierId: null == supplierId
            ? _value.supplierId
            : supplierId // ignore: cast_nullable_to_non_nullable
                  as int,
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$SupplierListItemImpl implements _SupplierListItem {
  const _$SupplierListItemImpl({
    required this.supplierId,
    required this.code,
    required this.name,
  });

  @override
  final int supplierId;
  @override
  final String code;
  @override
  final String name;

  @override
  String toString() {
    return 'SupplierListItem(supplierId: $supplierId, code: $code, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SupplierListItemImpl &&
            (identical(other.supplierId, supplierId) ||
                other.supplierId == supplierId) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name));
  }

  @override
  int get hashCode => Object.hash(runtimeType, supplierId, code, name);

  /// Create a copy of SupplierListItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SupplierListItemImplCopyWith<_$SupplierListItemImpl> get copyWith =>
      __$$SupplierListItemImplCopyWithImpl<_$SupplierListItemImpl>(
        this,
        _$identity,
      );
}

abstract class _SupplierListItem implements SupplierListItem {
  const factory _SupplierListItem({
    required final int supplierId,
    required final String code,
    required final String name,
  }) = _$SupplierListItemImpl;

  @override
  int get supplierId;
  @override
  String get code;
  @override
  String get name;

  /// Create a copy of SupplierListItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SupplierListItemImplCopyWith<_$SupplierListItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
