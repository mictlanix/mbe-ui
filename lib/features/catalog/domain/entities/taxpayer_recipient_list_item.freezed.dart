// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'taxpayer_recipient_list_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TaxpayerRecipientListItem {
  String get taxpayerRecipientId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;

  /// Create a copy of TaxpayerRecipientListItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TaxpayerRecipientListItemCopyWith<TaxpayerRecipientListItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaxpayerRecipientListItemCopyWith<$Res> {
  factory $TaxpayerRecipientListItemCopyWith(
    TaxpayerRecipientListItem value,
    $Res Function(TaxpayerRecipientListItem) then,
  ) = _$TaxpayerRecipientListItemCopyWithImpl<$Res, TaxpayerRecipientListItem>;
  @useResult
  $Res call({String taxpayerRecipientId, String name, String email});
}

/// @nodoc
class _$TaxpayerRecipientListItemCopyWithImpl<
  $Res,
  $Val extends TaxpayerRecipientListItem
>
    implements $TaxpayerRecipientListItemCopyWith<$Res> {
  _$TaxpayerRecipientListItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TaxpayerRecipientListItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? taxpayerRecipientId = null,
    Object? name = null,
    Object? email = null,
  }) {
    return _then(
      _value.copyWith(
            taxpayerRecipientId: null == taxpayerRecipientId
                ? _value.taxpayerRecipientId
                : taxpayerRecipientId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TaxpayerRecipientListItemImplCopyWith<$Res>
    implements $TaxpayerRecipientListItemCopyWith<$Res> {
  factory _$$TaxpayerRecipientListItemImplCopyWith(
    _$TaxpayerRecipientListItemImpl value,
    $Res Function(_$TaxpayerRecipientListItemImpl) then,
  ) = __$$TaxpayerRecipientListItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String taxpayerRecipientId, String name, String email});
}

/// @nodoc
class __$$TaxpayerRecipientListItemImplCopyWithImpl<$Res>
    extends
        _$TaxpayerRecipientListItemCopyWithImpl<
          $Res,
          _$TaxpayerRecipientListItemImpl
        >
    implements _$$TaxpayerRecipientListItemImplCopyWith<$Res> {
  __$$TaxpayerRecipientListItemImplCopyWithImpl(
    _$TaxpayerRecipientListItemImpl _value,
    $Res Function(_$TaxpayerRecipientListItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TaxpayerRecipientListItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? taxpayerRecipientId = null,
    Object? name = null,
    Object? email = null,
  }) {
    return _then(
      _$TaxpayerRecipientListItemImpl(
        taxpayerRecipientId: null == taxpayerRecipientId
            ? _value.taxpayerRecipientId
            : taxpayerRecipientId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$TaxpayerRecipientListItemImpl implements _TaxpayerRecipientListItem {
  const _$TaxpayerRecipientListItemImpl({
    required this.taxpayerRecipientId,
    required this.name,
    required this.email,
  });

  @override
  final String taxpayerRecipientId;
  @override
  final String name;
  @override
  final String email;

  @override
  String toString() {
    return 'TaxpayerRecipientListItem(taxpayerRecipientId: $taxpayerRecipientId, name: $name, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaxpayerRecipientListItemImpl &&
            (identical(other.taxpayerRecipientId, taxpayerRecipientId) ||
                other.taxpayerRecipientId == taxpayerRecipientId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, taxpayerRecipientId, name, email);

  /// Create a copy of TaxpayerRecipientListItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TaxpayerRecipientListItemImplCopyWith<_$TaxpayerRecipientListItemImpl>
  get copyWith =>
      __$$TaxpayerRecipientListItemImplCopyWithImpl<
        _$TaxpayerRecipientListItemImpl
      >(this, _$identity);
}

abstract class _TaxpayerRecipientListItem implements TaxpayerRecipientListItem {
  const factory _TaxpayerRecipientListItem({
    required final String taxpayerRecipientId,
    required final String name,
    required final String email,
  }) = _$TaxpayerRecipientListItemImpl;

  @override
  String get taxpayerRecipientId;
  @override
  String get name;
  @override
  String get email;

  /// Create a copy of TaxpayerRecipientListItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TaxpayerRecipientListItemImplCopyWith<_$TaxpayerRecipientListItemImpl>
  get copyWith => throw _privateConstructorUsedError;
}
