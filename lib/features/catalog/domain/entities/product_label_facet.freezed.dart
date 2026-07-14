// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_label_facet.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ProductLabelFacet {
  int get labelId => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;

  /// Create a copy of ProductLabelFacet
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductLabelFacetCopyWith<ProductLabelFacet> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductLabelFacetCopyWith<$Res> {
  factory $ProductLabelFacetCopyWith(
    ProductLabelFacet value,
    $Res Function(ProductLabelFacet) then,
  ) = _$ProductLabelFacetCopyWithImpl<$Res, ProductLabelFacet>;
  @useResult
  $Res call({int labelId, int count});
}

/// @nodoc
class _$ProductLabelFacetCopyWithImpl<$Res, $Val extends ProductLabelFacet>
    implements $ProductLabelFacetCopyWith<$Res> {
  _$ProductLabelFacetCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductLabelFacet
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? labelId = null, Object? count = null}) {
    return _then(
      _value.copyWith(
            labelId: null == labelId
                ? _value.labelId
                : labelId // ignore: cast_nullable_to_non_nullable
                      as int,
            count: null == count
                ? _value.count
                : count // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProductLabelFacetImplCopyWith<$Res>
    implements $ProductLabelFacetCopyWith<$Res> {
  factory _$$ProductLabelFacetImplCopyWith(
    _$ProductLabelFacetImpl value,
    $Res Function(_$ProductLabelFacetImpl) then,
  ) = __$$ProductLabelFacetImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int labelId, int count});
}

/// @nodoc
class __$$ProductLabelFacetImplCopyWithImpl<$Res>
    extends _$ProductLabelFacetCopyWithImpl<$Res, _$ProductLabelFacetImpl>
    implements _$$ProductLabelFacetImplCopyWith<$Res> {
  __$$ProductLabelFacetImplCopyWithImpl(
    _$ProductLabelFacetImpl _value,
    $Res Function(_$ProductLabelFacetImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductLabelFacet
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? labelId = null, Object? count = null}) {
    return _then(
      _$ProductLabelFacetImpl(
        labelId: null == labelId
            ? _value.labelId
            : labelId // ignore: cast_nullable_to_non_nullable
                  as int,
        count: null == count
            ? _value.count
            : count // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$ProductLabelFacetImpl implements _ProductLabelFacet {
  const _$ProductLabelFacetImpl({required this.labelId, required this.count});

  @override
  final int labelId;
  @override
  final int count;

  @override
  String toString() {
    return 'ProductLabelFacet(labelId: $labelId, count: $count)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductLabelFacetImpl &&
            (identical(other.labelId, labelId) || other.labelId == labelId) &&
            (identical(other.count, count) || other.count == count));
  }

  @override
  int get hashCode => Object.hash(runtimeType, labelId, count);

  /// Create a copy of ProductLabelFacet
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductLabelFacetImplCopyWith<_$ProductLabelFacetImpl> get copyWith =>
      __$$ProductLabelFacetImplCopyWithImpl<_$ProductLabelFacetImpl>(
        this,
        _$identity,
      );
}

abstract class _ProductLabelFacet implements ProductLabelFacet {
  const factory _ProductLabelFacet({
    required final int labelId,
    required final int count,
  }) = _$ProductLabelFacetImpl;

  @override
  int get labelId;
  @override
  int get count;

  /// Create a copy of ProductLabelFacet
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductLabelFacetImplCopyWith<_$ProductLabelFacetImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
