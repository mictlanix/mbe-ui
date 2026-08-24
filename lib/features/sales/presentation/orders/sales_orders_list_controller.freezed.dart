// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sales_orders_list_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$SalesOrdersFilter {
  DateTime get from => throw _privateConstructorUsedError;
  DateTime get to => throw _privateConstructorUsedError;
  SaleStatus? get status => throw _privateConstructorUsedError;
  int? get salesperson => throw _privateConstructorUsedError;
  int? get facility => throw _privateConstructorUsedError;
  String get search => throw _privateConstructorUsedError;
  int get pageIndex => throw _privateConstructorUsedError;

  /// Create a copy of SalesOrdersFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SalesOrdersFilterCopyWith<SalesOrdersFilter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SalesOrdersFilterCopyWith<$Res> {
  factory $SalesOrdersFilterCopyWith(
    SalesOrdersFilter value,
    $Res Function(SalesOrdersFilter) then,
  ) = _$SalesOrdersFilterCopyWithImpl<$Res, SalesOrdersFilter>;
  @useResult
  $Res call({
    DateTime from,
    DateTime to,
    SaleStatus? status,
    int? salesperson,
    int? facility,
    String search,
    int pageIndex,
  });
}

/// @nodoc
class _$SalesOrdersFilterCopyWithImpl<$Res, $Val extends SalesOrdersFilter>
    implements $SalesOrdersFilterCopyWith<$Res> {
  _$SalesOrdersFilterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SalesOrdersFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? from = null,
    Object? to = null,
    Object? status = freezed,
    Object? salesperson = freezed,
    Object? facility = freezed,
    Object? search = null,
    Object? pageIndex = null,
  }) {
    return _then(
      _value.copyWith(
            from: null == from
                ? _value.from
                : from // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            to: null == to
                ? _value.to
                : to // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as SaleStatus?,
            salesperson: freezed == salesperson
                ? _value.salesperson
                : salesperson // ignore: cast_nullable_to_non_nullable
                      as int?,
            facility: freezed == facility
                ? _value.facility
                : facility // ignore: cast_nullable_to_non_nullable
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
abstract class _$$SalesOrdersFilterImplCopyWith<$Res>
    implements $SalesOrdersFilterCopyWith<$Res> {
  factory _$$SalesOrdersFilterImplCopyWith(
    _$SalesOrdersFilterImpl value,
    $Res Function(_$SalesOrdersFilterImpl) then,
  ) = __$$SalesOrdersFilterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    DateTime from,
    DateTime to,
    SaleStatus? status,
    int? salesperson,
    int? facility,
    String search,
    int pageIndex,
  });
}

/// @nodoc
class __$$SalesOrdersFilterImplCopyWithImpl<$Res>
    extends _$SalesOrdersFilterCopyWithImpl<$Res, _$SalesOrdersFilterImpl>
    implements _$$SalesOrdersFilterImplCopyWith<$Res> {
  __$$SalesOrdersFilterImplCopyWithImpl(
    _$SalesOrdersFilterImpl _value,
    $Res Function(_$SalesOrdersFilterImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SalesOrdersFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? from = null,
    Object? to = null,
    Object? status = freezed,
    Object? salesperson = freezed,
    Object? facility = freezed,
    Object? search = null,
    Object? pageIndex = null,
  }) {
    return _then(
      _$SalesOrdersFilterImpl(
        from: null == from
            ? _value.from
            : from // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        to: null == to
            ? _value.to
            : to // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as SaleStatus?,
        salesperson: freezed == salesperson
            ? _value.salesperson
            : salesperson // ignore: cast_nullable_to_non_nullable
                  as int?,
        facility: freezed == facility
            ? _value.facility
            : facility // ignore: cast_nullable_to_non_nullable
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

class _$SalesOrdersFilterImpl implements _SalesOrdersFilter {
  const _$SalesOrdersFilterImpl({
    required this.from,
    required this.to,
    this.status,
    this.salesperson,
    this.facility,
    this.search = '',
    this.pageIndex = 0,
  });

  @override
  final DateTime from;
  @override
  final DateTime to;
  @override
  final SaleStatus? status;
  @override
  final int? salesperson;
  @override
  final int? facility;
  @override
  @JsonKey()
  final String search;
  @override
  @JsonKey()
  final int pageIndex;

  @override
  String toString() {
    return 'SalesOrdersFilter(from: $from, to: $to, status: $status, salesperson: $salesperson, facility: $facility, search: $search, pageIndex: $pageIndex)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SalesOrdersFilterImpl &&
            (identical(other.from, from) || other.from == from) &&
            (identical(other.to, to) || other.to == to) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.salesperson, salesperson) ||
                other.salesperson == salesperson) &&
            (identical(other.facility, facility) ||
                other.facility == facility) &&
            (identical(other.search, search) || other.search == search) &&
            (identical(other.pageIndex, pageIndex) ||
                other.pageIndex == pageIndex));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    from,
    to,
    status,
    salesperson,
    facility,
    search,
    pageIndex,
  );

  /// Create a copy of SalesOrdersFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SalesOrdersFilterImplCopyWith<_$SalesOrdersFilterImpl> get copyWith =>
      __$$SalesOrdersFilterImplCopyWithImpl<_$SalesOrdersFilterImpl>(
        this,
        _$identity,
      );
}

abstract class _SalesOrdersFilter implements SalesOrdersFilter {
  const factory _SalesOrdersFilter({
    required final DateTime from,
    required final DateTime to,
    final SaleStatus? status,
    final int? salesperson,
    final int? facility,
    final String search,
    final int pageIndex,
  }) = _$SalesOrdersFilterImpl;

  @override
  DateTime get from;
  @override
  DateTime get to;
  @override
  SaleStatus? get status;
  @override
  int? get salesperson;
  @override
  int? get facility;
  @override
  String get search;
  @override
  int get pageIndex;

  /// Create a copy of SalesOrdersFilter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SalesOrdersFilterImplCopyWith<_$SalesOrdersFilterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
