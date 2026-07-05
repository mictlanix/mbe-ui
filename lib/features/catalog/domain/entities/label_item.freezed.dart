// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'label_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$LabelItem {
  int get labelId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;

  /// Create a copy of LabelItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LabelItemCopyWith<LabelItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LabelItemCopyWith<$Res> {
  factory $LabelItemCopyWith(LabelItem value, $Res Function(LabelItem) then) =
      _$LabelItemCopyWithImpl<$Res, LabelItem>;
  @useResult
  $Res call({int labelId, String name});
}

/// @nodoc
class _$LabelItemCopyWithImpl<$Res, $Val extends LabelItem>
    implements $LabelItemCopyWith<$Res> {
  _$LabelItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LabelItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? labelId = null, Object? name = null}) {
    return _then(
      _value.copyWith(
            labelId: null == labelId
                ? _value.labelId
                : labelId // ignore: cast_nullable_to_non_nullable
                      as int,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LabelItemImplCopyWith<$Res>
    implements $LabelItemCopyWith<$Res> {
  factory _$$LabelItemImplCopyWith(
    _$LabelItemImpl value,
    $Res Function(_$LabelItemImpl) then,
  ) = __$$LabelItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int labelId, String name});
}

/// @nodoc
class __$$LabelItemImplCopyWithImpl<$Res>
    extends _$LabelItemCopyWithImpl<$Res, _$LabelItemImpl>
    implements _$$LabelItemImplCopyWith<$Res> {
  __$$LabelItemImplCopyWithImpl(
    _$LabelItemImpl _value,
    $Res Function(_$LabelItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LabelItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? labelId = null, Object? name = null}) {
    return _then(
      _$LabelItemImpl(
        labelId: null == labelId
            ? _value.labelId
            : labelId // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$LabelItemImpl implements _LabelItem {
  const _$LabelItemImpl({required this.labelId, required this.name});

  @override
  final int labelId;
  @override
  final String name;

  @override
  String toString() {
    return 'LabelItem(labelId: $labelId, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LabelItemImpl &&
            (identical(other.labelId, labelId) || other.labelId == labelId) &&
            (identical(other.name, name) || other.name == name));
  }

  @override
  int get hashCode => Object.hash(runtimeType, labelId, name);

  /// Create a copy of LabelItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LabelItemImplCopyWith<_$LabelItemImpl> get copyWith =>
      __$$LabelItemImplCopyWithImpl<_$LabelItemImpl>(this, _$identity);
}

abstract class _LabelItem implements LabelItem {
  const factory _LabelItem({
    required final int labelId,
    required final String name,
  }) = _$LabelItemImpl;

  @override
  int get labelId;
  @override
  String get name;

  /// Create a copy of LabelItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LabelItemImplCopyWith<_$LabelItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
