// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'customers_list_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CustomerFilter {
  String get search => throw _privateConstructorUsedError;
  bool? get disabled => throw _privateConstructorUsedError;
  int? get priceListId => throw _privateConstructorUsedError;
  String? get priceListDisplayText => throw _privateConstructorUsedError;
  int? get salespersonId => throw _privateConstructorUsedError;
  String? get salespersonDisplayText => throw _privateConstructorUsedError;

  /// Create a copy of CustomerFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CustomerFilterCopyWith<CustomerFilter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomerFilterCopyWith<$Res> {
  factory $CustomerFilterCopyWith(
    CustomerFilter value,
    $Res Function(CustomerFilter) then,
  ) = _$CustomerFilterCopyWithImpl<$Res, CustomerFilter>;
  @useResult
  $Res call({
    String search,
    bool? disabled,
    int? priceListId,
    String? priceListDisplayText,
    int? salespersonId,
    String? salespersonDisplayText,
  });
}

/// @nodoc
class _$CustomerFilterCopyWithImpl<$Res, $Val extends CustomerFilter>
    implements $CustomerFilterCopyWith<$Res> {
  _$CustomerFilterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CustomerFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? search = null,
    Object? disabled = freezed,
    Object? priceListId = freezed,
    Object? priceListDisplayText = freezed,
    Object? salespersonId = freezed,
    Object? salespersonDisplayText = freezed,
  }) {
    return _then(
      _value.copyWith(
            search: null == search
                ? _value.search
                : search // ignore: cast_nullable_to_non_nullable
                      as String,
            disabled: freezed == disabled
                ? _value.disabled
                : disabled // ignore: cast_nullable_to_non_nullable
                      as bool?,
            priceListId: freezed == priceListId
                ? _value.priceListId
                : priceListId // ignore: cast_nullable_to_non_nullable
                      as int?,
            priceListDisplayText: freezed == priceListDisplayText
                ? _value.priceListDisplayText
                : priceListDisplayText // ignore: cast_nullable_to_non_nullable
                      as String?,
            salespersonId: freezed == salespersonId
                ? _value.salespersonId
                : salespersonId // ignore: cast_nullable_to_non_nullable
                      as int?,
            salespersonDisplayText: freezed == salespersonDisplayText
                ? _value.salespersonDisplayText
                : salespersonDisplayText // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CustomerFilterImplCopyWith<$Res>
    implements $CustomerFilterCopyWith<$Res> {
  factory _$$CustomerFilterImplCopyWith(
    _$CustomerFilterImpl value,
    $Res Function(_$CustomerFilterImpl) then,
  ) = __$$CustomerFilterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String search,
    bool? disabled,
    int? priceListId,
    String? priceListDisplayText,
    int? salespersonId,
    String? salespersonDisplayText,
  });
}

/// @nodoc
class __$$CustomerFilterImplCopyWithImpl<$Res>
    extends _$CustomerFilterCopyWithImpl<$Res, _$CustomerFilterImpl>
    implements _$$CustomerFilterImplCopyWith<$Res> {
  __$$CustomerFilterImplCopyWithImpl(
    _$CustomerFilterImpl _value,
    $Res Function(_$CustomerFilterImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CustomerFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? search = null,
    Object? disabled = freezed,
    Object? priceListId = freezed,
    Object? priceListDisplayText = freezed,
    Object? salespersonId = freezed,
    Object? salespersonDisplayText = freezed,
  }) {
    return _then(
      _$CustomerFilterImpl(
        search: null == search
            ? _value.search
            : search // ignore: cast_nullable_to_non_nullable
                  as String,
        disabled: freezed == disabled
            ? _value.disabled
            : disabled // ignore: cast_nullable_to_non_nullable
                  as bool?,
        priceListId: freezed == priceListId
            ? _value.priceListId
            : priceListId // ignore: cast_nullable_to_non_nullable
                  as int?,
        priceListDisplayText: freezed == priceListDisplayText
            ? _value.priceListDisplayText
            : priceListDisplayText // ignore: cast_nullable_to_non_nullable
                  as String?,
        salespersonId: freezed == salespersonId
            ? _value.salespersonId
            : salespersonId // ignore: cast_nullable_to_non_nullable
                  as int?,
        salespersonDisplayText: freezed == salespersonDisplayText
            ? _value.salespersonDisplayText
            : salespersonDisplayText // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$CustomerFilterImpl implements _CustomerFilter {
  const _$CustomerFilterImpl({
    this.search = '',
    this.disabled,
    this.priceListId,
    this.priceListDisplayText,
    this.salespersonId,
    this.salespersonDisplayText,
  });

  @override
  @JsonKey()
  final String search;
  @override
  final bool? disabled;
  @override
  final int? priceListId;
  @override
  final String? priceListDisplayText;
  @override
  final int? salespersonId;
  @override
  final String? salespersonDisplayText;

  @override
  String toString() {
    return 'CustomerFilter(search: $search, disabled: $disabled, priceListId: $priceListId, priceListDisplayText: $priceListDisplayText, salespersonId: $salespersonId, salespersonDisplayText: $salespersonDisplayText)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomerFilterImpl &&
            (identical(other.search, search) || other.search == search) &&
            (identical(other.disabled, disabled) ||
                other.disabled == disabled) &&
            (identical(other.priceListId, priceListId) ||
                other.priceListId == priceListId) &&
            (identical(other.priceListDisplayText, priceListDisplayText) ||
                other.priceListDisplayText == priceListDisplayText) &&
            (identical(other.salespersonId, salespersonId) ||
                other.salespersonId == salespersonId) &&
            (identical(other.salespersonDisplayText, salespersonDisplayText) ||
                other.salespersonDisplayText == salespersonDisplayText));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    search,
    disabled,
    priceListId,
    priceListDisplayText,
    salespersonId,
    salespersonDisplayText,
  );

  /// Create a copy of CustomerFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomerFilterImplCopyWith<_$CustomerFilterImpl> get copyWith =>
      __$$CustomerFilterImplCopyWithImpl<_$CustomerFilterImpl>(
        this,
        _$identity,
      );
}

abstract class _CustomerFilter implements CustomerFilter {
  const factory _CustomerFilter({
    final String search,
    final bool? disabled,
    final int? priceListId,
    final String? priceListDisplayText,
    final int? salespersonId,
    final String? salespersonDisplayText,
  }) = _$CustomerFilterImpl;

  @override
  String get search;
  @override
  bool? get disabled;
  @override
  int? get priceListId;
  @override
  String? get priceListDisplayText;
  @override
  int? get salespersonId;
  @override
  String? get salespersonDisplayText;

  /// Create a copy of CustomerFilter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CustomerFilterImplCopyWith<_$CustomerFilterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
