// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'taxpayer_recipients_list_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TaxpayerRecipientFilter {
  String get search => throw _privateConstructorUsedError;
  int get pageIndex => throw _privateConstructorUsedError;

  /// Create a copy of TaxpayerRecipientFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TaxpayerRecipientFilterCopyWith<TaxpayerRecipientFilter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaxpayerRecipientFilterCopyWith<$Res> {
  factory $TaxpayerRecipientFilterCopyWith(
    TaxpayerRecipientFilter value,
    $Res Function(TaxpayerRecipientFilter) then,
  ) = _$TaxpayerRecipientFilterCopyWithImpl<$Res, TaxpayerRecipientFilter>;
  @useResult
  $Res call({String search, int pageIndex});
}

/// @nodoc
class _$TaxpayerRecipientFilterCopyWithImpl<
  $Res,
  $Val extends TaxpayerRecipientFilter
>
    implements $TaxpayerRecipientFilterCopyWith<$Res> {
  _$TaxpayerRecipientFilterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TaxpayerRecipientFilter
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
abstract class _$$TaxpayerRecipientFilterImplCopyWith<$Res>
    implements $TaxpayerRecipientFilterCopyWith<$Res> {
  factory _$$TaxpayerRecipientFilterImplCopyWith(
    _$TaxpayerRecipientFilterImpl value,
    $Res Function(_$TaxpayerRecipientFilterImpl) then,
  ) = __$$TaxpayerRecipientFilterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String search, int pageIndex});
}

/// @nodoc
class __$$TaxpayerRecipientFilterImplCopyWithImpl<$Res>
    extends
        _$TaxpayerRecipientFilterCopyWithImpl<
          $Res,
          _$TaxpayerRecipientFilterImpl
        >
    implements _$$TaxpayerRecipientFilterImplCopyWith<$Res> {
  __$$TaxpayerRecipientFilterImplCopyWithImpl(
    _$TaxpayerRecipientFilterImpl _value,
    $Res Function(_$TaxpayerRecipientFilterImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TaxpayerRecipientFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? search = null, Object? pageIndex = null}) {
    return _then(
      _$TaxpayerRecipientFilterImpl(
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

class _$TaxpayerRecipientFilterImpl implements _TaxpayerRecipientFilter {
  const _$TaxpayerRecipientFilterImpl({this.search = '', this.pageIndex = 0});

  @override
  @JsonKey()
  final String search;
  @override
  @JsonKey()
  final int pageIndex;

  @override
  String toString() {
    return 'TaxpayerRecipientFilter(search: $search, pageIndex: $pageIndex)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaxpayerRecipientFilterImpl &&
            (identical(other.search, search) || other.search == search) &&
            (identical(other.pageIndex, pageIndex) ||
                other.pageIndex == pageIndex));
  }

  @override
  int get hashCode => Object.hash(runtimeType, search, pageIndex);

  /// Create a copy of TaxpayerRecipientFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TaxpayerRecipientFilterImplCopyWith<_$TaxpayerRecipientFilterImpl>
  get copyWith =>
      __$$TaxpayerRecipientFilterImplCopyWithImpl<
        _$TaxpayerRecipientFilterImpl
      >(this, _$identity);
}

abstract class _TaxpayerRecipientFilter implements TaxpayerRecipientFilter {
  const factory _TaxpayerRecipientFilter({
    final String search,
    final int pageIndex,
  }) = _$TaxpayerRecipientFilterImpl;

  @override
  String get search;
  @override
  int get pageIndex;

  /// Create a copy of TaxpayerRecipientFilter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TaxpayerRecipientFilterImplCopyWith<_$TaxpayerRecipientFilterImpl>
  get copyWith => throw _privateConstructorUsedError;
}
