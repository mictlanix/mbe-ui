// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sales_quotes_list_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$SalesQuotesFilter {
  SaleStatus? get status => throw _privateConstructorUsedError;
  int? get customer => throw _privateConstructorUsedError;
  int? get salesperson => throw _privateConstructorUsedError;
  String get search => throw _privateConstructorUsedError;
  int get pageIndex => throw _privateConstructorUsedError;

  /// Create a copy of SalesQuotesFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SalesQuotesFilterCopyWith<SalesQuotesFilter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SalesQuotesFilterCopyWith<$Res> {
  factory $SalesQuotesFilterCopyWith(
    SalesQuotesFilter value,
    $Res Function(SalesQuotesFilter) then,
  ) = _$SalesQuotesFilterCopyWithImpl<$Res, SalesQuotesFilter>;
  @useResult
  $Res call({
    SaleStatus? status,
    int? customer,
    int? salesperson,
    String search,
    int pageIndex,
  });
}

/// @nodoc
class _$SalesQuotesFilterCopyWithImpl<$Res, $Val extends SalesQuotesFilter>
    implements $SalesQuotesFilterCopyWith<$Res> {
  _$SalesQuotesFilterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SalesQuotesFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = freezed,
    Object? customer = freezed,
    Object? salesperson = freezed,
    Object? search = null,
    Object? pageIndex = null,
  }) {
    return _then(
      _value.copyWith(
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as SaleStatus?,
            customer: freezed == customer
                ? _value.customer
                : customer // ignore: cast_nullable_to_non_nullable
                      as int?,
            salesperson: freezed == salesperson
                ? _value.salesperson
                : salesperson // ignore: cast_nullable_to_non_nullable
                      as int?,
            search: null == search
                ? _value.search
                : search // ignore: cast_nullable_to_non_nullable
                      as String,
            pageIndex: null == pageIndex
                ? _value.pageIndex
                : pageIndex // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SalesQuotesFilterImplCopyWith<$Res>
    implements $SalesQuotesFilterCopyWith<$Res> {
  factory _$$SalesQuotesFilterImplCopyWith(
    _$SalesQuotesFilterImpl value,
    $Res Function(_$SalesQuotesFilterImpl) then,
  ) = __$$SalesQuotesFilterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    SaleStatus? status,
    int? customer,
    int? salesperson,
    String search,
    int pageIndex,
  });
}

/// @nodoc
class __$$SalesQuotesFilterImplCopyWithImpl<$Res>
    extends _$SalesQuotesFilterCopyWithImpl<$Res, _$SalesQuotesFilterImpl>
    implements _$$SalesQuotesFilterImplCopyWith<$Res> {
  __$$SalesQuotesFilterImplCopyWithImpl(
    _$SalesQuotesFilterImpl _value,
    $Res Function(_$SalesQuotesFilterImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SalesQuotesFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = freezed,
    Object? customer = freezed,
    Object? salesperson = freezed,
    Object? search = null,
    Object? pageIndex = null,
  }) {
    return _then(
      _$SalesQuotesFilterImpl(
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as SaleStatus?,
        customer: freezed == customer
            ? _value.customer
            : customer // ignore: cast_nullable_to_non_nullable
                  as int?,
        salesperson: freezed == salesperson
            ? _value.salesperson
            : salesperson // ignore: cast_nullable_to_non_nullable
                  as int?,
        search: null == search
            ? _value.search
            : search // ignore: cast_nullable_to_non_nullable
                  as String,
        pageIndex: null == pageIndex
            ? _value.pageIndex
            : pageIndex // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$SalesQuotesFilterImpl implements _SalesQuotesFilter {
  const _$SalesQuotesFilterImpl({
    this.status,
    this.customer,
    this.salesperson,
    this.search = '',
    this.pageIndex = 0,
  });

  @override
  final SaleStatus? status;
  @override
  final int? customer;
  @override
  final int? salesperson;
  @override
  @JsonKey()
  final String search;
  @override
  @JsonKey()
  final int pageIndex;

  @override
  String toString() {
    return 'SalesQuotesFilter(status: $status, customer: $customer, salesperson: $salesperson, search: $search, pageIndex: $pageIndex)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SalesQuotesFilterImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.customer, customer) ||
                other.customer == customer) &&
            (identical(other.salesperson, salesperson) ||
                other.salesperson == salesperson) &&
            (identical(other.search, search) || other.search == search) &&
            (identical(other.pageIndex, pageIndex) ||
                other.pageIndex == pageIndex));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    status,
    customer,
    salesperson,
    search,
    pageIndex,
  );

  /// Create a copy of SalesQuotesFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SalesQuotesFilterImplCopyWith<_$SalesQuotesFilterImpl> get copyWith =>
      __$$SalesQuotesFilterImplCopyWithImpl<_$SalesQuotesFilterImpl>(
        this,
        _$identity,
      );
}

abstract class _SalesQuotesFilter implements SalesQuotesFilter {
  const factory _SalesQuotesFilter({
    final SaleStatus? status,
    final int? customer,
    final int? salesperson,
    final String search,
    final int pageIndex,
  }) = _$SalesQuotesFilterImpl;

  @override
  SaleStatus? get status;
  @override
  int? get customer;
  @override
  int? get salesperson;
  @override
  String get search;
  @override
  int get pageIndex;

  /// Create a copy of SalesQuotesFilter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SalesQuotesFilterImplCopyWith<_$SalesQuotesFilterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
