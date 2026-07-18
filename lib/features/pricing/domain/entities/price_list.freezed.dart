// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'price_list.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$PriceList {
  int get priceListId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get highProfitMargin => throw _privateConstructorUsedError;
  String get lowProfitMargin => throw _privateConstructorUsedError;

  /// Create a copy of PriceList
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PriceListCopyWith<PriceList> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PriceListCopyWith<$Res> {
  factory $PriceListCopyWith(PriceList value, $Res Function(PriceList) then) =
      _$PriceListCopyWithImpl<$Res, PriceList>;
  @useResult
  $Res call({
    int priceListId,
    String name,
    String highProfitMargin,
    String lowProfitMargin,
  });
}

/// @nodoc
class _$PriceListCopyWithImpl<$Res, $Val extends PriceList>
    implements $PriceListCopyWith<$Res> {
  _$PriceListCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PriceList
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? priceListId = null,
    Object? name = null,
    Object? highProfitMargin = null,
    Object? lowProfitMargin = null,
  }) {
    return _then(
      _value.copyWith(
            priceListId: null == priceListId
                ? _value.priceListId
                : priceListId // ignore: cast_nullable_to_non_nullable
                      as int,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            highProfitMargin: null == highProfitMargin
                ? _value.highProfitMargin
                : highProfitMargin // ignore: cast_nullable_to_non_nullable
                      as String,
            lowProfitMargin: null == lowProfitMargin
                ? _value.lowProfitMargin
                : lowProfitMargin // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PriceListImplCopyWith<$Res>
    implements $PriceListCopyWith<$Res> {
  factory _$$PriceListImplCopyWith(
    _$PriceListImpl value,
    $Res Function(_$PriceListImpl) then,
  ) = __$$PriceListImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int priceListId,
    String name,
    String highProfitMargin,
    String lowProfitMargin,
  });
}

/// @nodoc
class __$$PriceListImplCopyWithImpl<$Res>
    extends _$PriceListCopyWithImpl<$Res, _$PriceListImpl>
    implements _$$PriceListImplCopyWith<$Res> {
  __$$PriceListImplCopyWithImpl(
    _$PriceListImpl _value,
    $Res Function(_$PriceListImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PriceList
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? priceListId = null,
    Object? name = null,
    Object? highProfitMargin = null,
    Object? lowProfitMargin = null,
  }) {
    return _then(
      _$PriceListImpl(
        priceListId: null == priceListId
            ? _value.priceListId
            : priceListId // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        highProfitMargin: null == highProfitMargin
            ? _value.highProfitMargin
            : highProfitMargin // ignore: cast_nullable_to_non_nullable
                  as String,
        lowProfitMargin: null == lowProfitMargin
            ? _value.lowProfitMargin
            : lowProfitMargin // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$PriceListImpl implements _PriceList {
  const _$PriceListImpl({
    required this.priceListId,
    required this.name,
    required this.highProfitMargin,
    required this.lowProfitMargin,
  });

  @override
  final int priceListId;
  @override
  final String name;
  @override
  final String highProfitMargin;
  @override
  final String lowProfitMargin;

  @override
  String toString() {
    return 'PriceList(priceListId: $priceListId, name: $name, highProfitMargin: $highProfitMargin, lowProfitMargin: $lowProfitMargin)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PriceListImpl &&
            (identical(other.priceListId, priceListId) ||
                other.priceListId == priceListId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.highProfitMargin, highProfitMargin) ||
                other.highProfitMargin == highProfitMargin) &&
            (identical(other.lowProfitMargin, lowProfitMargin) ||
                other.lowProfitMargin == lowProfitMargin));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    priceListId,
    name,
    highProfitMargin,
    lowProfitMargin,
  );

  /// Create a copy of PriceList
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PriceListImplCopyWith<_$PriceListImpl> get copyWith =>
      __$$PriceListImplCopyWithImpl<_$PriceListImpl>(this, _$identity);
}

abstract class _PriceList implements PriceList {
  const factory _PriceList({
    required final int priceListId,
    required final String name,
    required final String highProfitMargin,
    required final String lowProfitMargin,
  }) = _$PriceListImpl;

  @override
  int get priceListId;
  @override
  String get name;
  @override
  String get highProfitMargin;
  @override
  String get lowProfitMargin;

  /// Create a copy of PriceList
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PriceListImplCopyWith<_$PriceListImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
