// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'customer_list_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CustomerListItem {
  int get customerId => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get zone => throw _privateConstructorUsedError;
  String get creditLimit => throw _privateConstructorUsedError;
  int get creditDays => throw _privateConstructorUsedError;
  PriceListRef get priceList => throw _privateConstructorUsedError;
  EmployeeRef? get salesperson => throw _privateConstructorUsedError;
  bool get disabled => throw _privateConstructorUsedError;

  /// Create a copy of CustomerListItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CustomerListItemCopyWith<CustomerListItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomerListItemCopyWith<$Res> {
  factory $CustomerListItemCopyWith(
    CustomerListItem value,
    $Res Function(CustomerListItem) then,
  ) = _$CustomerListItemCopyWithImpl<$Res, CustomerListItem>;
  @useResult
  $Res call({
    int customerId,
    String code,
    String name,
    String? zone,
    String creditLimit,
    int creditDays,
    PriceListRef priceList,
    EmployeeRef? salesperson,
    bool disabled,
  });

  $PriceListRefCopyWith<$Res> get priceList;
  $EmployeeRefCopyWith<$Res>? get salesperson;
}

/// @nodoc
class _$CustomerListItemCopyWithImpl<$Res, $Val extends CustomerListItem>
    implements $CustomerListItemCopyWith<$Res> {
  _$CustomerListItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CustomerListItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customerId = null,
    Object? code = null,
    Object? name = null,
    Object? zone = freezed,
    Object? creditLimit = null,
    Object? creditDays = null,
    Object? priceList = null,
    Object? salesperson = freezed,
    Object? disabled = null,
  }) {
    return _then(
      _value.copyWith(
            customerId: null == customerId
                ? _value.customerId
                : customerId // ignore: cast_nullable_to_non_nullable
                      as int,
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            zone: freezed == zone
                ? _value.zone
                : zone // ignore: cast_nullable_to_non_nullable
                      as String?,
            creditLimit: null == creditLimit
                ? _value.creditLimit
                : creditLimit // ignore: cast_nullable_to_non_nullable
                      as String,
            creditDays: null == creditDays
                ? _value.creditDays
                : creditDays // ignore: cast_nullable_to_non_nullable
                      as int,
            priceList: null == priceList
                ? _value.priceList
                : priceList // ignore: cast_nullable_to_non_nullable
                      as PriceListRef,
            salesperson: freezed == salesperson
                ? _value.salesperson
                : salesperson // ignore: cast_nullable_to_non_nullable
                      as EmployeeRef?,
            disabled: null == disabled
                ? _value.disabled
                : disabled // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }

  /// Create a copy of CustomerListItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PriceListRefCopyWith<$Res> get priceList {
    return $PriceListRefCopyWith<$Res>(_value.priceList, (value) {
      return _then(_value.copyWith(priceList: value) as $Val);
    });
  }

  /// Create a copy of CustomerListItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $EmployeeRefCopyWith<$Res>? get salesperson {
    if (_value.salesperson == null) {
      return null;
    }

    return $EmployeeRefCopyWith<$Res>(_value.salesperson!, (value) {
      return _then(_value.copyWith(salesperson: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CustomerListItemImplCopyWith<$Res>
    implements $CustomerListItemCopyWith<$Res> {
  factory _$$CustomerListItemImplCopyWith(
    _$CustomerListItemImpl value,
    $Res Function(_$CustomerListItemImpl) then,
  ) = __$$CustomerListItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int customerId,
    String code,
    String name,
    String? zone,
    String creditLimit,
    int creditDays,
    PriceListRef priceList,
    EmployeeRef? salesperson,
    bool disabled,
  });

  @override
  $PriceListRefCopyWith<$Res> get priceList;
  @override
  $EmployeeRefCopyWith<$Res>? get salesperson;
}

/// @nodoc
class __$$CustomerListItemImplCopyWithImpl<$Res>
    extends _$CustomerListItemCopyWithImpl<$Res, _$CustomerListItemImpl>
    implements _$$CustomerListItemImplCopyWith<$Res> {
  __$$CustomerListItemImplCopyWithImpl(
    _$CustomerListItemImpl _value,
    $Res Function(_$CustomerListItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CustomerListItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customerId = null,
    Object? code = null,
    Object? name = null,
    Object? zone = freezed,
    Object? creditLimit = null,
    Object? creditDays = null,
    Object? priceList = null,
    Object? salesperson = freezed,
    Object? disabled = null,
  }) {
    return _then(
      _$CustomerListItemImpl(
        customerId: null == customerId
            ? _value.customerId
            : customerId // ignore: cast_nullable_to_non_nullable
                  as int,
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        zone: freezed == zone
            ? _value.zone
            : zone // ignore: cast_nullable_to_non_nullable
                  as String?,
        creditLimit: null == creditLimit
            ? _value.creditLimit
            : creditLimit // ignore: cast_nullable_to_non_nullable
                  as String,
        creditDays: null == creditDays
            ? _value.creditDays
            : creditDays // ignore: cast_nullable_to_non_nullable
                  as int,
        priceList: null == priceList
            ? _value.priceList
            : priceList // ignore: cast_nullable_to_non_nullable
                  as PriceListRef,
        salesperson: freezed == salesperson
            ? _value.salesperson
            : salesperson // ignore: cast_nullable_to_non_nullable
                  as EmployeeRef?,
        disabled: null == disabled
            ? _value.disabled
            : disabled // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$CustomerListItemImpl implements _CustomerListItem {
  const _$CustomerListItemImpl({
    required this.customerId,
    required this.code,
    required this.name,
    this.zone,
    required this.creditLimit,
    required this.creditDays,
    required this.priceList,
    this.salesperson,
    required this.disabled,
  });

  @override
  final int customerId;
  @override
  final String code;
  @override
  final String name;
  @override
  final String? zone;
  @override
  final String creditLimit;
  @override
  final int creditDays;
  @override
  final PriceListRef priceList;
  @override
  final EmployeeRef? salesperson;
  @override
  final bool disabled;

  @override
  String toString() {
    return 'CustomerListItem(customerId: $customerId, code: $code, name: $name, zone: $zone, creditLimit: $creditLimit, creditDays: $creditDays, priceList: $priceList, salesperson: $salesperson, disabled: $disabled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomerListItemImpl &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.zone, zone) || other.zone == zone) &&
            (identical(other.creditLimit, creditLimit) ||
                other.creditLimit == creditLimit) &&
            (identical(other.creditDays, creditDays) ||
                other.creditDays == creditDays) &&
            (identical(other.priceList, priceList) ||
                other.priceList == priceList) &&
            (identical(other.salesperson, salesperson) ||
                other.salesperson == salesperson) &&
            (identical(other.disabled, disabled) ||
                other.disabled == disabled));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    customerId,
    code,
    name,
    zone,
    creditLimit,
    creditDays,
    priceList,
    salesperson,
    disabled,
  );

  /// Create a copy of CustomerListItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomerListItemImplCopyWith<_$CustomerListItemImpl> get copyWith =>
      __$$CustomerListItemImplCopyWithImpl<_$CustomerListItemImpl>(
        this,
        _$identity,
      );
}

abstract class _CustomerListItem implements CustomerListItem {
  const factory _CustomerListItem({
    required final int customerId,
    required final String code,
    required final String name,
    final String? zone,
    required final String creditLimit,
    required final int creditDays,
    required final PriceListRef priceList,
    final EmployeeRef? salesperson,
    required final bool disabled,
  }) = _$CustomerListItemImpl;

  @override
  int get customerId;
  @override
  String get code;
  @override
  String get name;
  @override
  String? get zone;
  @override
  String get creditLimit;
  @override
  int get creditDays;
  @override
  PriceListRef get priceList;
  @override
  EmployeeRef? get salesperson;
  @override
  bool get disabled;

  /// Create a copy of CustomerListItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CustomerListItemImplCopyWith<_$CustomerListItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
