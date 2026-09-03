// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pricing_grid_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$PricingGridFilter {
  String get search => throw _privateConstructorUsedError;
  int get pageIndex => throw _privateConstructorUsedError;
  EntityStatus? get status => throw _privateConstructorUsedError;
  bool? get stockable => throw _privateConstructorUsedError;
  bool? get salable => throw _privateConstructorUsedError;
  bool? get purchasable => throw _privateConstructorUsedError;
  int? get supplier => throw _privateConstructorUsedError;
  List<int> get labels => throw _privateConstructorUsedError;
  int? get missingPriceList => throw _privateConstructorUsedError;

  /// Create a copy of PricingGridFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PricingGridFilterCopyWith<PricingGridFilter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PricingGridFilterCopyWith<$Res> {
  factory $PricingGridFilterCopyWith(
    PricingGridFilter value,
    $Res Function(PricingGridFilter) then,
  ) = _$PricingGridFilterCopyWithImpl<$Res, PricingGridFilter>;
  @useResult
  $Res call({
    String search,
    int pageIndex,
    EntityStatus? status,
    bool? stockable,
    bool? salable,
    bool? purchasable,
    int? supplier,
    List<int> labels,
    int? missingPriceList,
  });
}

/// @nodoc
class _$PricingGridFilterCopyWithImpl<$Res, $Val extends PricingGridFilter>
    implements $PricingGridFilterCopyWith<$Res> {
  _$PricingGridFilterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PricingGridFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? search = null,
    Object? pageIndex = null,
    Object? status = freezed,
    Object? stockable = freezed,
    Object? salable = freezed,
    Object? purchasable = freezed,
    Object? supplier = freezed,
    Object? labels = null,
    Object? missingPriceList = freezed,
  }) {
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
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as EntityStatus?,
            stockable: freezed == stockable
                ? _value.stockable
                : stockable // ignore: cast_nullable_to_non_nullable
                      as bool?,
            salable: freezed == salable
                ? _value.salable
                : salable // ignore: cast_nullable_to_non_nullable
                      as bool?,
            purchasable: freezed == purchasable
                ? _value.purchasable
                : purchasable // ignore: cast_nullable_to_non_nullable
                      as bool?,
            supplier: freezed == supplier
                ? _value.supplier
                : supplier // ignore: cast_nullable_to_non_nullable
                      as int?,
            labels: null == labels
                ? _value.labels
                : labels // ignore: cast_nullable_to_non_nullable
                      as List<int>,
            missingPriceList: freezed == missingPriceList
                ? _value.missingPriceList
                : missingPriceList // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PricingGridFilterImplCopyWith<$Res>
    implements $PricingGridFilterCopyWith<$Res> {
  factory _$$PricingGridFilterImplCopyWith(
    _$PricingGridFilterImpl value,
    $Res Function(_$PricingGridFilterImpl) then,
  ) = __$$PricingGridFilterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String search,
    int pageIndex,
    EntityStatus? status,
    bool? stockable,
    bool? salable,
    bool? purchasable,
    int? supplier,
    List<int> labels,
    int? missingPriceList,
  });
}

/// @nodoc
class __$$PricingGridFilterImplCopyWithImpl<$Res>
    extends _$PricingGridFilterCopyWithImpl<$Res, _$PricingGridFilterImpl>
    implements _$$PricingGridFilterImplCopyWith<$Res> {
  __$$PricingGridFilterImplCopyWithImpl(
    _$PricingGridFilterImpl _value,
    $Res Function(_$PricingGridFilterImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PricingGridFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? search = null,
    Object? pageIndex = null,
    Object? status = freezed,
    Object? stockable = freezed,
    Object? salable = freezed,
    Object? purchasable = freezed,
    Object? supplier = freezed,
    Object? labels = null,
    Object? missingPriceList = freezed,
  }) {
    return _then(
      _$PricingGridFilterImpl(
        search: null == search
            ? _value.search
            : search // ignore: cast_nullable_to_non_nullable
                  as String,
        pageIndex: null == pageIndex
            ? _value.pageIndex
            : pageIndex // ignore: cast_nullable_to_non_nullable
                  as int,
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as EntityStatus?,
        stockable: freezed == stockable
            ? _value.stockable
            : stockable // ignore: cast_nullable_to_non_nullable
                  as bool?,
        salable: freezed == salable
            ? _value.salable
            : salable // ignore: cast_nullable_to_non_nullable
                  as bool?,
        purchasable: freezed == purchasable
            ? _value.purchasable
            : purchasable // ignore: cast_nullable_to_non_nullable
                  as bool?,
        supplier: freezed == supplier
            ? _value.supplier
            : supplier // ignore: cast_nullable_to_non_nullable
                  as int?,
        labels: null == labels
            ? _value._labels
            : labels // ignore: cast_nullable_to_non_nullable
                  as List<int>,
        missingPriceList: freezed == missingPriceList
            ? _value.missingPriceList
            : missingPriceList // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc

class _$PricingGridFilterImpl implements _PricingGridFilter {
  const _$PricingGridFilterImpl({
    this.search = '',
    this.pageIndex = 0,
    this.status,
    this.stockable,
    this.salable,
    this.purchasable,
    this.supplier,
    final List<int> labels = const <int>[],
    this.missingPriceList,
  }) : _labels = labels;

  @override
  @JsonKey()
  final String search;
  @override
  @JsonKey()
  final int pageIndex;
  @override
  final EntityStatus? status;
  @override
  final bool? stockable;
  @override
  final bool? salable;
  @override
  final bool? purchasable;
  @override
  final int? supplier;
  final List<int> _labels;
  @override
  @JsonKey()
  List<int> get labels {
    if (_labels is EqualUnmodifiableListView) return _labels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_labels);
  }

  @override
  final int? missingPriceList;

  @override
  String toString() {
    return 'PricingGridFilter(search: $search, pageIndex: $pageIndex, status: $status, stockable: $stockable, salable: $salable, purchasable: $purchasable, supplier: $supplier, labels: $labels, missingPriceList: $missingPriceList)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PricingGridFilterImpl &&
            (identical(other.search, search) || other.search == search) &&
            (identical(other.pageIndex, pageIndex) ||
                other.pageIndex == pageIndex) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.stockable, stockable) ||
                other.stockable == stockable) &&
            (identical(other.salable, salable) || other.salable == salable) &&
            (identical(other.purchasable, purchasable) ||
                other.purchasable == purchasable) &&
            (identical(other.supplier, supplier) ||
                other.supplier == supplier) &&
            const DeepCollectionEquality().equals(other._labels, _labels) &&
            (identical(other.missingPriceList, missingPriceList) ||
                other.missingPriceList == missingPriceList));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    search,
    pageIndex,
    status,
    stockable,
    salable,
    purchasable,
    supplier,
    const DeepCollectionEquality().hash(_labels),
    missingPriceList,
  );

  /// Create a copy of PricingGridFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PricingGridFilterImplCopyWith<_$PricingGridFilterImpl> get copyWith =>
      __$$PricingGridFilterImplCopyWithImpl<_$PricingGridFilterImpl>(
        this,
        _$identity,
      );
}

abstract class _PricingGridFilter implements PricingGridFilter {
  const factory _PricingGridFilter({
    final String search,
    final int pageIndex,
    final EntityStatus? status,
    final bool? stockable,
    final bool? salable,
    final bool? purchasable,
    final int? supplier,
    final List<int> labels,
    final int? missingPriceList,
  }) = _$PricingGridFilterImpl;

  @override
  String get search;
  @override
  int get pageIndex;
  @override
  EntityStatus? get status;
  @override
  bool? get stockable;
  @override
  bool? get salable;
  @override
  bool? get purchasable;
  @override
  int? get supplier;
  @override
  List<int> get labels;
  @override
  int? get missingPriceList;

  /// Create a copy of PricingGridFilter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PricingGridFilterImplCopyWith<_$PricingGridFilterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$RejectedEdit {
  String get typed => throw _privateConstructorUsedError;
  String get reason => throw _privateConstructorUsedError;

  /// Create a copy of RejectedEdit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RejectedEditCopyWith<RejectedEdit> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RejectedEditCopyWith<$Res> {
  factory $RejectedEditCopyWith(
    RejectedEdit value,
    $Res Function(RejectedEdit) then,
  ) = _$RejectedEditCopyWithImpl<$Res, RejectedEdit>;
  @useResult
  $Res call({String typed, String reason});
}

/// @nodoc
class _$RejectedEditCopyWithImpl<$Res, $Val extends RejectedEdit>
    implements $RejectedEditCopyWith<$Res> {
  _$RejectedEditCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RejectedEdit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? typed = null, Object? reason = null}) {
    return _then(
      _value.copyWith(
            typed: null == typed
                ? _value.typed
                : typed // ignore: cast_nullable_to_non_nullable
                      as String,
            reason: null == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RejectedEditImplCopyWith<$Res>
    implements $RejectedEditCopyWith<$Res> {
  factory _$$RejectedEditImplCopyWith(
    _$RejectedEditImpl value,
    $Res Function(_$RejectedEditImpl) then,
  ) = __$$RejectedEditImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String typed, String reason});
}

/// @nodoc
class __$$RejectedEditImplCopyWithImpl<$Res>
    extends _$RejectedEditCopyWithImpl<$Res, _$RejectedEditImpl>
    implements _$$RejectedEditImplCopyWith<$Res> {
  __$$RejectedEditImplCopyWithImpl(
    _$RejectedEditImpl _value,
    $Res Function(_$RejectedEditImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RejectedEdit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? typed = null, Object? reason = null}) {
    return _then(
      _$RejectedEditImpl(
        typed: null == typed
            ? _value.typed
            : typed // ignore: cast_nullable_to_non_nullable
                  as String,
        reason: null == reason
            ? _value.reason
            : reason // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$RejectedEditImpl implements _RejectedEdit {
  const _$RejectedEditImpl({required this.typed, required this.reason});

  @override
  final String typed;
  @override
  final String reason;

  @override
  String toString() {
    return 'RejectedEdit(typed: $typed, reason: $reason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RejectedEditImpl &&
            (identical(other.typed, typed) || other.typed == typed) &&
            (identical(other.reason, reason) || other.reason == reason));
  }

  @override
  int get hashCode => Object.hash(runtimeType, typed, reason);

  /// Create a copy of RejectedEdit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RejectedEditImplCopyWith<_$RejectedEditImpl> get copyWith =>
      __$$RejectedEditImplCopyWithImpl<_$RejectedEditImpl>(this, _$identity);
}

abstract class _RejectedEdit implements RejectedEdit {
  const factory _RejectedEdit({
    required final String typed,
    required final String reason,
  }) = _$RejectedEditImpl;

  @override
  String get typed;
  @override
  String get reason;

  /// Create a copy of RejectedEdit
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RejectedEditImplCopyWith<_$RejectedEditImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$PriceWrite {
  PriceCellKey get cell => throw _privateConstructorUsedError;
  String? get previous => throw _privateConstructorUsedError;
  String get next => throw _privateConstructorUsedError;

  /// Create a copy of PriceWrite
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PriceWriteCopyWith<PriceWrite> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PriceWriteCopyWith<$Res> {
  factory $PriceWriteCopyWith(
    PriceWrite value,
    $Res Function(PriceWrite) then,
  ) = _$PriceWriteCopyWithImpl<$Res, PriceWrite>;
  @useResult
  $Res call({PriceCellKey cell, String? previous, String next});

  $PriceCellKeyCopyWith<$Res> get cell;
}

/// @nodoc
class _$PriceWriteCopyWithImpl<$Res, $Val extends PriceWrite>
    implements $PriceWriteCopyWith<$Res> {
  _$PriceWriteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PriceWrite
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cell = null,
    Object? previous = freezed,
    Object? next = null,
  }) {
    return _then(
      _value.copyWith(
            cell: null == cell
                ? _value.cell
                : cell // ignore: cast_nullable_to_non_nullable
                      as PriceCellKey,
            previous: freezed == previous
                ? _value.previous
                : previous // ignore: cast_nullable_to_non_nullable
                      as String?,
            next: null == next
                ? _value.next
                : next // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }

  /// Create a copy of PriceWrite
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PriceCellKeyCopyWith<$Res> get cell {
    return $PriceCellKeyCopyWith<$Res>(_value.cell, (value) {
      return _then(_value.copyWith(cell: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PriceWriteImplCopyWith<$Res>
    implements $PriceWriteCopyWith<$Res> {
  factory _$$PriceWriteImplCopyWith(
    _$PriceWriteImpl value,
    $Res Function(_$PriceWriteImpl) then,
  ) = __$$PriceWriteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({PriceCellKey cell, String? previous, String next});

  @override
  $PriceCellKeyCopyWith<$Res> get cell;
}

/// @nodoc
class __$$PriceWriteImplCopyWithImpl<$Res>
    extends _$PriceWriteCopyWithImpl<$Res, _$PriceWriteImpl>
    implements _$$PriceWriteImplCopyWith<$Res> {
  __$$PriceWriteImplCopyWithImpl(
    _$PriceWriteImpl _value,
    $Res Function(_$PriceWriteImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PriceWrite
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cell = null,
    Object? previous = freezed,
    Object? next = null,
  }) {
    return _then(
      _$PriceWriteImpl(
        cell: null == cell
            ? _value.cell
            : cell // ignore: cast_nullable_to_non_nullable
                  as PriceCellKey,
        previous: freezed == previous
            ? _value.previous
            : previous // ignore: cast_nullable_to_non_nullable
                  as String?,
        next: null == next
            ? _value.next
            : next // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$PriceWriteImpl implements _PriceWrite {
  const _$PriceWriteImpl({
    required this.cell,
    required this.previous,
    required this.next,
  });

  @override
  final PriceCellKey cell;
  @override
  final String? previous;
  @override
  final String next;

  @override
  String toString() {
    return 'PriceWrite(cell: $cell, previous: $previous, next: $next)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PriceWriteImpl &&
            (identical(other.cell, cell) || other.cell == cell) &&
            (identical(other.previous, previous) ||
                other.previous == previous) &&
            (identical(other.next, next) || other.next == next));
  }

  @override
  int get hashCode => Object.hash(runtimeType, cell, previous, next);

  /// Create a copy of PriceWrite
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PriceWriteImplCopyWith<_$PriceWriteImpl> get copyWith =>
      __$$PriceWriteImplCopyWithImpl<_$PriceWriteImpl>(this, _$identity);
}

abstract class _PriceWrite implements PriceWrite {
  const factory _PriceWrite({
    required final PriceCellKey cell,
    required final String? previous,
    required final String next,
  }) = _$PriceWriteImpl;

  @override
  PriceCellKey get cell;
  @override
  String? get previous;
  @override
  String get next;

  /// Create a copy of PriceWrite
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PriceWriteImplCopyWith<_$PriceWriteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$PriceChange {
  PriceChangeKind get kind => throw _privateConstructorUsedError;
  List<PriceWrite> get writes => throw _privateConstructorUsedError;

  /// Create a copy of PriceChange
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PriceChangeCopyWith<PriceChange> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PriceChangeCopyWith<$Res> {
  factory $PriceChangeCopyWith(
    PriceChange value,
    $Res Function(PriceChange) then,
  ) = _$PriceChangeCopyWithImpl<$Res, PriceChange>;
  @useResult
  $Res call({PriceChangeKind kind, List<PriceWrite> writes});
}

/// @nodoc
class _$PriceChangeCopyWithImpl<$Res, $Val extends PriceChange>
    implements $PriceChangeCopyWith<$Res> {
  _$PriceChangeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PriceChange
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? kind = null, Object? writes = null}) {
    return _then(
      _value.copyWith(
            kind: null == kind
                ? _value.kind
                : kind // ignore: cast_nullable_to_non_nullable
                      as PriceChangeKind,
            writes: null == writes
                ? _value.writes
                : writes // ignore: cast_nullable_to_non_nullable
                      as List<PriceWrite>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PriceChangeImplCopyWith<$Res>
    implements $PriceChangeCopyWith<$Res> {
  factory _$$PriceChangeImplCopyWith(
    _$PriceChangeImpl value,
    $Res Function(_$PriceChangeImpl) then,
  ) = __$$PriceChangeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({PriceChangeKind kind, List<PriceWrite> writes});
}

/// @nodoc
class __$$PriceChangeImplCopyWithImpl<$Res>
    extends _$PriceChangeCopyWithImpl<$Res, _$PriceChangeImpl>
    implements _$$PriceChangeImplCopyWith<$Res> {
  __$$PriceChangeImplCopyWithImpl(
    _$PriceChangeImpl _value,
    $Res Function(_$PriceChangeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PriceChange
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? kind = null, Object? writes = null}) {
    return _then(
      _$PriceChangeImpl(
        kind: null == kind
            ? _value.kind
            : kind // ignore: cast_nullable_to_non_nullable
                  as PriceChangeKind,
        writes: null == writes
            ? _value._writes
            : writes // ignore: cast_nullable_to_non_nullable
                  as List<PriceWrite>,
      ),
    );
  }
}

/// @nodoc

class _$PriceChangeImpl implements _PriceChange {
  const _$PriceChangeImpl({
    required this.kind,
    required final List<PriceWrite> writes,
  }) : _writes = writes;

  @override
  final PriceChangeKind kind;
  final List<PriceWrite> _writes;
  @override
  List<PriceWrite> get writes {
    if (_writes is EqualUnmodifiableListView) return _writes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_writes);
  }

  @override
  String toString() {
    return 'PriceChange(kind: $kind, writes: $writes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PriceChangeImpl &&
            (identical(other.kind, kind) || other.kind == kind) &&
            const DeepCollectionEquality().equals(other._writes, _writes));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    kind,
    const DeepCollectionEquality().hash(_writes),
  );

  /// Create a copy of PriceChange
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PriceChangeImplCopyWith<_$PriceChangeImpl> get copyWith =>
      __$$PriceChangeImplCopyWithImpl<_$PriceChangeImpl>(this, _$identity);
}

abstract class _PriceChange implements PriceChange {
  const factory _PriceChange({
    required final PriceChangeKind kind,
    required final List<PriceWrite> writes,
  }) = _$PriceChangeImpl;

  @override
  PriceChangeKind get kind;
  @override
  List<PriceWrite> get writes;

  /// Create a copy of PriceChange
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PriceChangeImplCopyWith<_$PriceChangeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$PricingGridState {
  List<PricingGridRow> get rows => throw _privateConstructorUsedError;
  List<PriceList> get allLists => throw _privateConstructorUsedError;
  CatalogPage<PricingGridRow>? get page => throw _privateConstructorUsedError;

  /// The cell currently open for editing, or `null` when none is.
  PriceCellKey? get active => throw _privateConstructorUsedError;

  /// The typed text of the currently-active cell (data-model.md §3), or
  /// `null` when nothing has been typed since it opened. Set on every
  /// keystroke ([PricingGridController.updateDraft]); cleared whenever
  /// [active] changes or the cell is committed or discarded.
  String? get activeDraft => throw _privateConstructorUsedError;

  /// Cells whose write is in flight (FR-022 "saving").
  Set<PriceCellKey> get inFlight => throw _privateConstructorUsedError;

  /// Cells the server (or client-side parsing) refused (FR-009).
  Map<PriceCellKey, RejectedEdit> get rejected =>
      throw _privateConstructorUsedError;

  /// The value each visible cell held when the current view loaded — the
  /// baseline "revert all" restores to (FR-024), and the source of the
  /// "was X" tooltip and the changed-count in the summary bar.
  Map<PriceCellKey, String?> get baseline => throw _privateConstructorUsedError;

  /// Newest last. One entry per undoable change (FR-016, FR-024).
  List<PriceChange> get history => throw _privateConstructorUsedError;

  /// Create a copy of PricingGridState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PricingGridStateCopyWith<PricingGridState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PricingGridStateCopyWith<$Res> {
  factory $PricingGridStateCopyWith(
    PricingGridState value,
    $Res Function(PricingGridState) then,
  ) = _$PricingGridStateCopyWithImpl<$Res, PricingGridState>;
  @useResult
  $Res call({
    List<PricingGridRow> rows,
    List<PriceList> allLists,
    CatalogPage<PricingGridRow>? page,
    PriceCellKey? active,
    String? activeDraft,
    Set<PriceCellKey> inFlight,
    Map<PriceCellKey, RejectedEdit> rejected,
    Map<PriceCellKey, String?> baseline,
    List<PriceChange> history,
  });

  $PriceCellKeyCopyWith<$Res>? get active;
}

/// @nodoc
class _$PricingGridStateCopyWithImpl<$Res, $Val extends PricingGridState>
    implements $PricingGridStateCopyWith<$Res> {
  _$PricingGridStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PricingGridState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rows = null,
    Object? allLists = null,
    Object? page = freezed,
    Object? active = freezed,
    Object? activeDraft = freezed,
    Object? inFlight = null,
    Object? rejected = null,
    Object? baseline = null,
    Object? history = null,
  }) {
    return _then(
      _value.copyWith(
            rows: null == rows
                ? _value.rows
                : rows // ignore: cast_nullable_to_non_nullable
                      as List<PricingGridRow>,
            allLists: null == allLists
                ? _value.allLists
                : allLists // ignore: cast_nullable_to_non_nullable
                      as List<PriceList>,
            page: freezed == page
                ? _value.page
                : page // ignore: cast_nullable_to_non_nullable
                      as CatalogPage<PricingGridRow>?,
            active: freezed == active
                ? _value.active
                : active // ignore: cast_nullable_to_non_nullable
                      as PriceCellKey?,
            activeDraft: freezed == activeDraft
                ? _value.activeDraft
                : activeDraft // ignore: cast_nullable_to_non_nullable
                      as String?,
            inFlight: null == inFlight
                ? _value.inFlight
                : inFlight // ignore: cast_nullable_to_non_nullable
                      as Set<PriceCellKey>,
            rejected: null == rejected
                ? _value.rejected
                : rejected // ignore: cast_nullable_to_non_nullable
                      as Map<PriceCellKey, RejectedEdit>,
            baseline: null == baseline
                ? _value.baseline
                : baseline // ignore: cast_nullable_to_non_nullable
                      as Map<PriceCellKey, String?>,
            history: null == history
                ? _value.history
                : history // ignore: cast_nullable_to_non_nullable
                      as List<PriceChange>,
          )
          as $Val,
    );
  }

  /// Create a copy of PricingGridState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PriceCellKeyCopyWith<$Res>? get active {
    if (_value.active == null) {
      return null;
    }

    return $PriceCellKeyCopyWith<$Res>(_value.active!, (value) {
      return _then(_value.copyWith(active: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PricingGridStateImplCopyWith<$Res>
    implements $PricingGridStateCopyWith<$Res> {
  factory _$$PricingGridStateImplCopyWith(
    _$PricingGridStateImpl value,
    $Res Function(_$PricingGridStateImpl) then,
  ) = __$$PricingGridStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<PricingGridRow> rows,
    List<PriceList> allLists,
    CatalogPage<PricingGridRow>? page,
    PriceCellKey? active,
    String? activeDraft,
    Set<PriceCellKey> inFlight,
    Map<PriceCellKey, RejectedEdit> rejected,
    Map<PriceCellKey, String?> baseline,
    List<PriceChange> history,
  });

  @override
  $PriceCellKeyCopyWith<$Res>? get active;
}

/// @nodoc
class __$$PricingGridStateImplCopyWithImpl<$Res>
    extends _$PricingGridStateCopyWithImpl<$Res, _$PricingGridStateImpl>
    implements _$$PricingGridStateImplCopyWith<$Res> {
  __$$PricingGridStateImplCopyWithImpl(
    _$PricingGridStateImpl _value,
    $Res Function(_$PricingGridStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PricingGridState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rows = null,
    Object? allLists = null,
    Object? page = freezed,
    Object? active = freezed,
    Object? activeDraft = freezed,
    Object? inFlight = null,
    Object? rejected = null,
    Object? baseline = null,
    Object? history = null,
  }) {
    return _then(
      _$PricingGridStateImpl(
        rows: null == rows
            ? _value._rows
            : rows // ignore: cast_nullable_to_non_nullable
                  as List<PricingGridRow>,
        allLists: null == allLists
            ? _value._allLists
            : allLists // ignore: cast_nullable_to_non_nullable
                  as List<PriceList>,
        page: freezed == page
            ? _value.page
            : page // ignore: cast_nullable_to_non_nullable
                  as CatalogPage<PricingGridRow>?,
        active: freezed == active
            ? _value.active
            : active // ignore: cast_nullable_to_non_nullable
                  as PriceCellKey?,
        activeDraft: freezed == activeDraft
            ? _value.activeDraft
            : activeDraft // ignore: cast_nullable_to_non_nullable
                  as String?,
        inFlight: null == inFlight
            ? _value._inFlight
            : inFlight // ignore: cast_nullable_to_non_nullable
                  as Set<PriceCellKey>,
        rejected: null == rejected
            ? _value._rejected
            : rejected // ignore: cast_nullable_to_non_nullable
                  as Map<PriceCellKey, RejectedEdit>,
        baseline: null == baseline
            ? _value._baseline
            : baseline // ignore: cast_nullable_to_non_nullable
                  as Map<PriceCellKey, String?>,
        history: null == history
            ? _value._history
            : history // ignore: cast_nullable_to_non_nullable
                  as List<PriceChange>,
      ),
    );
  }
}

/// @nodoc

class _$PricingGridStateImpl implements _PricingGridState {
  const _$PricingGridStateImpl({
    final List<PricingGridRow> rows = const <PricingGridRow>[],
    final List<PriceList> allLists = const <PriceList>[],
    this.page,
    this.active,
    this.activeDraft,
    final Set<PriceCellKey> inFlight = const <PriceCellKey>{},
    final Map<PriceCellKey, RejectedEdit> rejected =
        const <PriceCellKey, RejectedEdit>{},
    final Map<PriceCellKey, String?> baseline = const <PriceCellKey, String?>{},
    final List<PriceChange> history = const <PriceChange>[],
  }) : _rows = rows,
       _allLists = allLists,
       _inFlight = inFlight,
       _rejected = rejected,
       _baseline = baseline,
       _history = history;

  final List<PricingGridRow> _rows;
  @override
  @JsonKey()
  List<PricingGridRow> get rows {
    if (_rows is EqualUnmodifiableListView) return _rows;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_rows);
  }

  final List<PriceList> _allLists;
  @override
  @JsonKey()
  List<PriceList> get allLists {
    if (_allLists is EqualUnmodifiableListView) return _allLists;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_allLists);
  }

  @override
  final CatalogPage<PricingGridRow>? page;

  /// The cell currently open for editing, or `null` when none is.
  @override
  final PriceCellKey? active;

  /// The typed text of the currently-active cell (data-model.md §3), or
  /// `null` when nothing has been typed since it opened. Set on every
  /// keystroke ([PricingGridController.updateDraft]); cleared whenever
  /// [active] changes or the cell is committed or discarded.
  @override
  final String? activeDraft;

  /// Cells whose write is in flight (FR-022 "saving").
  final Set<PriceCellKey> _inFlight;

  /// Cells whose write is in flight (FR-022 "saving").
  @override
  @JsonKey()
  Set<PriceCellKey> get inFlight {
    if (_inFlight is EqualUnmodifiableSetView) return _inFlight;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_inFlight);
  }

  /// Cells the server (or client-side parsing) refused (FR-009).
  final Map<PriceCellKey, RejectedEdit> _rejected;

  /// Cells the server (or client-side parsing) refused (FR-009).
  @override
  @JsonKey()
  Map<PriceCellKey, RejectedEdit> get rejected {
    if (_rejected is EqualUnmodifiableMapView) return _rejected;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_rejected);
  }

  /// The value each visible cell held when the current view loaded — the
  /// baseline "revert all" restores to (FR-024), and the source of the
  /// "was X" tooltip and the changed-count in the summary bar.
  final Map<PriceCellKey, String?> _baseline;

  /// The value each visible cell held when the current view loaded — the
  /// baseline "revert all" restores to (FR-024), and the source of the
  /// "was X" tooltip and the changed-count in the summary bar.
  @override
  @JsonKey()
  Map<PriceCellKey, String?> get baseline {
    if (_baseline is EqualUnmodifiableMapView) return _baseline;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_baseline);
  }

  /// Newest last. One entry per undoable change (FR-016, FR-024).
  final List<PriceChange> _history;

  /// Newest last. One entry per undoable change (FR-016, FR-024).
  @override
  @JsonKey()
  List<PriceChange> get history {
    if (_history is EqualUnmodifiableListView) return _history;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_history);
  }

  @override
  String toString() {
    return 'PricingGridState(rows: $rows, allLists: $allLists, page: $page, active: $active, activeDraft: $activeDraft, inFlight: $inFlight, rejected: $rejected, baseline: $baseline, history: $history)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PricingGridStateImpl &&
            const DeepCollectionEquality().equals(other._rows, _rows) &&
            const DeepCollectionEquality().equals(other._allLists, _allLists) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.active, active) || other.active == active) &&
            (identical(other.activeDraft, activeDraft) ||
                other.activeDraft == activeDraft) &&
            const DeepCollectionEquality().equals(other._inFlight, _inFlight) &&
            const DeepCollectionEquality().equals(other._rejected, _rejected) &&
            const DeepCollectionEquality().equals(other._baseline, _baseline) &&
            const DeepCollectionEquality().equals(other._history, _history));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_rows),
    const DeepCollectionEquality().hash(_allLists),
    page,
    active,
    activeDraft,
    const DeepCollectionEquality().hash(_inFlight),
    const DeepCollectionEquality().hash(_rejected),
    const DeepCollectionEquality().hash(_baseline),
    const DeepCollectionEquality().hash(_history),
  );

  /// Create a copy of PricingGridState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PricingGridStateImplCopyWith<_$PricingGridStateImpl> get copyWith =>
      __$$PricingGridStateImplCopyWithImpl<_$PricingGridStateImpl>(
        this,
        _$identity,
      );
}

abstract class _PricingGridState implements PricingGridState {
  const factory _PricingGridState({
    final List<PricingGridRow> rows,
    final List<PriceList> allLists,
    final CatalogPage<PricingGridRow>? page,
    final PriceCellKey? active,
    final String? activeDraft,
    final Set<PriceCellKey> inFlight,
    final Map<PriceCellKey, RejectedEdit> rejected,
    final Map<PriceCellKey, String?> baseline,
    final List<PriceChange> history,
  }) = _$PricingGridStateImpl;

  @override
  List<PricingGridRow> get rows;
  @override
  List<PriceList> get allLists;
  @override
  CatalogPage<PricingGridRow>? get page;

  /// The cell currently open for editing, or `null` when none is.
  @override
  PriceCellKey? get active;

  /// The typed text of the currently-active cell (data-model.md §3), or
  /// `null` when nothing has been typed since it opened. Set on every
  /// keystroke ([PricingGridController.updateDraft]); cleared whenever
  /// [active] changes or the cell is committed or discarded.
  @override
  String? get activeDraft;

  /// Cells whose write is in flight (FR-022 "saving").
  @override
  Set<PriceCellKey> get inFlight;

  /// Cells the server (or client-side parsing) refused (FR-009).
  @override
  Map<PriceCellKey, RejectedEdit> get rejected;

  /// The value each visible cell held when the current view loaded — the
  /// baseline "revert all" restores to (FR-024), and the source of the
  /// "was X" tooltip and the changed-count in the summary bar.
  @override
  Map<PriceCellKey, String?> get baseline;

  /// Newest last. One entry per undoable change (FR-016, FR-024).
  @override
  List<PriceChange> get history;

  /// Create a copy of PricingGridState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PricingGridStateImplCopyWith<_$PricingGridStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
