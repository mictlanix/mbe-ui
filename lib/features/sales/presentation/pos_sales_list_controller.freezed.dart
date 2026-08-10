// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pos_sales_list_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$PosSalesFilter {
  DateTime get from => throw _privateConstructorUsedError;
  DateTime get to => throw _privateConstructorUsedError;
  SaleStatus? get status => throw _privateConstructorUsedError;
  String get search => throw _privateConstructorUsedError;
  int get pageIndex => throw _privateConstructorUsedError;

  /// Create a copy of PosSalesFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PosSalesFilterCopyWith<PosSalesFilter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PosSalesFilterCopyWith<$Res> {
  factory $PosSalesFilterCopyWith(
    PosSalesFilter value,
    $Res Function(PosSalesFilter) then,
  ) = _$PosSalesFilterCopyWithImpl<$Res, PosSalesFilter>;
  @useResult
  $Res call({
    DateTime from,
    DateTime to,
    SaleStatus? status,
    String search,
    int pageIndex,
  });
}

/// @nodoc
class _$PosSalesFilterCopyWithImpl<$Res, $Val extends PosSalesFilter>
    implements $PosSalesFilterCopyWith<$Res> {
  _$PosSalesFilterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PosSalesFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? from = null,
    Object? to = null,
    Object? status = freezed,
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
abstract class _$$PosSalesFilterImplCopyWith<$Res>
    implements $PosSalesFilterCopyWith<$Res> {
  factory _$$PosSalesFilterImplCopyWith(
    _$PosSalesFilterImpl value,
    $Res Function(_$PosSalesFilterImpl) then,
  ) = __$$PosSalesFilterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    DateTime from,
    DateTime to,
    SaleStatus? status,
    String search,
    int pageIndex,
  });
}

/// @nodoc
class __$$PosSalesFilterImplCopyWithImpl<$Res>
    extends _$PosSalesFilterCopyWithImpl<$Res, _$PosSalesFilterImpl>
    implements _$$PosSalesFilterImplCopyWith<$Res> {
  __$$PosSalesFilterImplCopyWithImpl(
    _$PosSalesFilterImpl _value,
    $Res Function(_$PosSalesFilterImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PosSalesFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? from = null,
    Object? to = null,
    Object? status = freezed,
    Object? search = null,
    Object? pageIndex = null,
  }) {
    return _then(
      _$PosSalesFilterImpl(
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

class _$PosSalesFilterImpl implements _PosSalesFilter {
  const _$PosSalesFilterImpl({
    required this.from,
    required this.to,
    this.status,
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
  @JsonKey()
  final String search;
  @override
  @JsonKey()
  final int pageIndex;

  @override
  String toString() {
    return 'PosSalesFilter(from: $from, to: $to, status: $status, search: $search, pageIndex: $pageIndex)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PosSalesFilterImpl &&
            (identical(other.from, from) || other.from == from) &&
            (identical(other.to, to) || other.to == to) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.search, search) || other.search == search) &&
            (identical(other.pageIndex, pageIndex) ||
                other.pageIndex == pageIndex));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, from, to, status, search, pageIndex);

  /// Create a copy of PosSalesFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PosSalesFilterImplCopyWith<_$PosSalesFilterImpl> get copyWith =>
      __$$PosSalesFilterImplCopyWithImpl<_$PosSalesFilterImpl>(
        this,
        _$identity,
      );
}

abstract class _PosSalesFilter implements PosSalesFilter {
  const factory _PosSalesFilter({
    required final DateTime from,
    required final DateTime to,
    final SaleStatus? status,
    final String search,
    final int pageIndex,
  }) = _$PosSalesFilterImpl;

  @override
  DateTime get from;
  @override
  DateTime get to;
  @override
  SaleStatus? get status;
  @override
  String get search;
  @override
  int get pageIndex;

  /// Create a copy of PosSalesFilter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PosSalesFilterImplCopyWith<_$PosSalesFilterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
