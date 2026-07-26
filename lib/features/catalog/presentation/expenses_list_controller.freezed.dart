// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'expenses_list_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ExpenseFilter {
  String get search => throw _privateConstructorUsedError;
  int get pageIndex => throw _privateConstructorUsedError;

  /// Create a copy of ExpenseFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExpenseFilterCopyWith<ExpenseFilter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExpenseFilterCopyWith<$Res> {
  factory $ExpenseFilterCopyWith(
    ExpenseFilter value,
    $Res Function(ExpenseFilter) then,
  ) = _$ExpenseFilterCopyWithImpl<$Res, ExpenseFilter>;
  @useResult
  $Res call({String search, int pageIndex});
}

/// @nodoc
class _$ExpenseFilterCopyWithImpl<$Res, $Val extends ExpenseFilter>
    implements $ExpenseFilterCopyWith<$Res> {
  _$ExpenseFilterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExpenseFilter
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
abstract class _$$ExpenseFilterImplCopyWith<$Res>
    implements $ExpenseFilterCopyWith<$Res> {
  factory _$$ExpenseFilterImplCopyWith(
    _$ExpenseFilterImpl value,
    $Res Function(_$ExpenseFilterImpl) then,
  ) = __$$ExpenseFilterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String search, int pageIndex});
}

/// @nodoc
class __$$ExpenseFilterImplCopyWithImpl<$Res>
    extends _$ExpenseFilterCopyWithImpl<$Res, _$ExpenseFilterImpl>
    implements _$$ExpenseFilterImplCopyWith<$Res> {
  __$$ExpenseFilterImplCopyWithImpl(
    _$ExpenseFilterImpl _value,
    $Res Function(_$ExpenseFilterImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExpenseFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? search = null, Object? pageIndex = null}) {
    return _then(
      _$ExpenseFilterImpl(
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

class _$ExpenseFilterImpl implements _ExpenseFilter {
  const _$ExpenseFilterImpl({this.search = '', this.pageIndex = 0});

  @override
  @JsonKey()
  final String search;
  @override
  @JsonKey()
  final int pageIndex;

  @override
  String toString() {
    return 'ExpenseFilter(search: $search, pageIndex: $pageIndex)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExpenseFilterImpl &&
            (identical(other.search, search) || other.search == search) &&
            (identical(other.pageIndex, pageIndex) ||
                other.pageIndex == pageIndex));
  }

  @override
  int get hashCode => Object.hash(runtimeType, search, pageIndex);

  /// Create a copy of ExpenseFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExpenseFilterImplCopyWith<_$ExpenseFilterImpl> get copyWith =>
      __$$ExpenseFilterImplCopyWithImpl<_$ExpenseFilterImpl>(this, _$identity);
}

abstract class _ExpenseFilter implements ExpenseFilter {
  const factory _ExpenseFilter({final String search, final int pageIndex}) =
      _$ExpenseFilterImpl;

  @override
  String get search;
  @override
  int get pageIndex;

  /// Create a copy of ExpenseFilter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExpenseFilterImplCopyWith<_$ExpenseFilterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
