// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'taxpayer_issuers_list_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TaxpayerIssuerFilter {
  String get search => throw _privateConstructorUsedError;
  int get pageIndex => throw _privateConstructorUsedError;

  /// Create a copy of TaxpayerIssuerFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TaxpayerIssuerFilterCopyWith<TaxpayerIssuerFilter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaxpayerIssuerFilterCopyWith<$Res> {
  factory $TaxpayerIssuerFilterCopyWith(
    TaxpayerIssuerFilter value,
    $Res Function(TaxpayerIssuerFilter) then,
  ) = _$TaxpayerIssuerFilterCopyWithImpl<$Res, TaxpayerIssuerFilter>;
  @useResult
  $Res call({String search, int pageIndex});
}

/// @nodoc
class _$TaxpayerIssuerFilterCopyWithImpl<
  $Res,
  $Val extends TaxpayerIssuerFilter
>
    implements $TaxpayerIssuerFilterCopyWith<$Res> {
  _$TaxpayerIssuerFilterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TaxpayerIssuerFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? search = null, Object? pageIndex = null}) {
    return _then(
      _value.copyWith(
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
abstract class _$$TaxpayerIssuerFilterImplCopyWith<$Res>
    implements $TaxpayerIssuerFilterCopyWith<$Res> {
  factory _$$TaxpayerIssuerFilterImplCopyWith(
    _$TaxpayerIssuerFilterImpl value,
    $Res Function(_$TaxpayerIssuerFilterImpl) then,
  ) = __$$TaxpayerIssuerFilterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String search, int pageIndex});
}

/// @nodoc
class __$$TaxpayerIssuerFilterImplCopyWithImpl<$Res>
    extends _$TaxpayerIssuerFilterCopyWithImpl<$Res, _$TaxpayerIssuerFilterImpl>
    implements _$$TaxpayerIssuerFilterImplCopyWith<$Res> {
  __$$TaxpayerIssuerFilterImplCopyWithImpl(
    _$TaxpayerIssuerFilterImpl _value,
    $Res Function(_$TaxpayerIssuerFilterImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TaxpayerIssuerFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? search = null, Object? pageIndex = null}) {
    return _then(
      _$TaxpayerIssuerFilterImpl(
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

class _$TaxpayerIssuerFilterImpl implements _TaxpayerIssuerFilter {
  const _$TaxpayerIssuerFilterImpl({this.search = '', this.pageIndex = 0});

  @override
  @JsonKey()
  final String search;
  @override
  @JsonKey()
  final int pageIndex;

  @override
  String toString() {
    return 'TaxpayerIssuerFilter(search: $search, pageIndex: $pageIndex)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaxpayerIssuerFilterImpl &&
            (identical(other.search, search) || other.search == search) &&
            (identical(other.pageIndex, pageIndex) ||
                other.pageIndex == pageIndex));
  }

  @override
  int get hashCode => Object.hash(runtimeType, search, pageIndex);

  /// Create a copy of TaxpayerIssuerFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TaxpayerIssuerFilterImplCopyWith<_$TaxpayerIssuerFilterImpl>
  get copyWith =>
      __$$TaxpayerIssuerFilterImplCopyWithImpl<_$TaxpayerIssuerFilterImpl>(
        this,
        _$identity,
      );
}

abstract class _TaxpayerIssuerFilter implements TaxpayerIssuerFilter {
  const factory _TaxpayerIssuerFilter({
    final String search,
    final int pageIndex,
  }) = _$TaxpayerIssuerFilterImpl;

  @override
  String get search;
  @override
  int get pageIndex;

  /// Create a copy of TaxpayerIssuerFilter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TaxpayerIssuerFilterImplCopyWith<_$TaxpayerIssuerFilterImpl>
  get copyWith => throw _privateConstructorUsedError;
}
