// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'address_list_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AddressListItem {
  int get addressId => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  AddressType get type => throw _privateConstructorUsedError;

  /// Create a copy of AddressListItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AddressListItemCopyWith<AddressListItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AddressListItemCopyWith<$Res> {
  factory $AddressListItemCopyWith(
    AddressListItem value,
    $Res Function(AddressListItem) then,
  ) = _$AddressListItemCopyWithImpl<$Res, AddressListItem>;
  @useResult
  $Res call({int addressId, String label, AddressType type});
}

/// @nodoc
class _$AddressListItemCopyWithImpl<$Res, $Val extends AddressListItem>
    implements $AddressListItemCopyWith<$Res> {
  _$AddressListItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AddressListItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? addressId = null,
    Object? label = null,
    Object? type = null,
  }) {
    return _then(
      _value.copyWith(
            addressId: null == addressId
                ? _value.addressId
                : addressId // ignore: cast_nullable_to_non_nullable
                      as int,
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as AddressType,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AddressListItemImplCopyWith<$Res>
    implements $AddressListItemCopyWith<$Res> {
  factory _$$AddressListItemImplCopyWith(
    _$AddressListItemImpl value,
    $Res Function(_$AddressListItemImpl) then,
  ) = __$$AddressListItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int addressId, String label, AddressType type});
}

/// @nodoc
class __$$AddressListItemImplCopyWithImpl<$Res>
    extends _$AddressListItemCopyWithImpl<$Res, _$AddressListItemImpl>
    implements _$$AddressListItemImplCopyWith<$Res> {
  __$$AddressListItemImplCopyWithImpl(
    _$AddressListItemImpl _value,
    $Res Function(_$AddressListItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AddressListItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? addressId = null,
    Object? label = null,
    Object? type = null,
  }) {
    return _then(
      _$AddressListItemImpl(
        addressId: null == addressId
            ? _value.addressId
            : addressId // ignore: cast_nullable_to_non_nullable
                  as int,
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as AddressType,
      ),
    );
  }
}

/// @nodoc

class _$AddressListItemImpl implements _AddressListItem {
  const _$AddressListItemImpl({
    required this.addressId,
    required this.label,
    required this.type,
  });

  @override
  final int addressId;
  @override
  final String label;
  @override
  final AddressType type;

  @override
  String toString() {
    return 'AddressListItem(addressId: $addressId, label: $label, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AddressListItemImpl &&
            (identical(other.addressId, addressId) ||
                other.addressId == addressId) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.type, type) || other.type == type));
  }

  @override
  int get hashCode => Object.hash(runtimeType, addressId, label, type);

  /// Create a copy of AddressListItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AddressListItemImplCopyWith<_$AddressListItemImpl> get copyWith =>
      __$$AddressListItemImplCopyWithImpl<_$AddressListItemImpl>(
        this,
        _$identity,
      );
}

abstract class _AddressListItem implements AddressListItem {
  const factory _AddressListItem({
    required final int addressId,
    required final String label,
    required final AddressType type,
  }) = _$AddressListItemImpl;

  @override
  int get addressId;
  @override
  String get label;
  @override
  AddressType get type;

  /// Create a copy of AddressListItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AddressListItemImplCopyWith<_$AddressListItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
