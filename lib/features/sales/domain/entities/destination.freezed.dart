// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'destination.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Destination {
  int get id => throw _privateConstructorUsedError;
  FulfillmentType get fulfillmentType => throw _privateConstructorUsedError;
  int? get shipTo => throw _privateConstructorUsedError;
  String? get addressSummary => throw _privateConstructorUsedError;
  int? get contact => throw _privateConstructorUsedError;
  String? get contactName => throw _privateConstructorUsedError;
  String? get contactPhone => throw _privateConstructorUsedError;
  DateTime? get date => throw _privateConstructorUsedError;
  String? get comment => throw _privateConstructorUsedError;
  DeliveryOrderStatus get status => throw _privateConstructorUsedError;
  List<DestinationLine> get lines => throw _privateConstructorUsedError;

  /// Create a copy of Destination
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DestinationCopyWith<Destination> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DestinationCopyWith<$Res> {
  factory $DestinationCopyWith(
    Destination value,
    $Res Function(Destination) then,
  ) = _$DestinationCopyWithImpl<$Res, Destination>;
  @useResult
  $Res call({
    int id,
    FulfillmentType fulfillmentType,
    int? shipTo,
    String? addressSummary,
    int? contact,
    String? contactName,
    String? contactPhone,
    DateTime? date,
    String? comment,
    DeliveryOrderStatus status,
    List<DestinationLine> lines,
  });
}

/// @nodoc
class _$DestinationCopyWithImpl<$Res, $Val extends Destination>
    implements $DestinationCopyWith<$Res> {
  _$DestinationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Destination
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fulfillmentType = null,
    Object? shipTo = freezed,
    Object? addressSummary = freezed,
    Object? contact = freezed,
    Object? contactName = freezed,
    Object? contactPhone = freezed,
    Object? date = freezed,
    Object? comment = freezed,
    Object? status = null,
    Object? lines = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            fulfillmentType: null == fulfillmentType
                ? _value.fulfillmentType
                : fulfillmentType // ignore: cast_nullable_to_non_nullable
                      as FulfillmentType,
            shipTo: freezed == shipTo
                ? _value.shipTo
                : shipTo // ignore: cast_nullable_to_non_nullable
                      as int?,
            addressSummary: freezed == addressSummary
                ? _value.addressSummary
                : addressSummary // ignore: cast_nullable_to_non_nullable
                      as String?,
            contact: freezed == contact
                ? _value.contact
                : contact // ignore: cast_nullable_to_non_nullable
                      as int?,
            contactName: freezed == contactName
                ? _value.contactName
                : contactName // ignore: cast_nullable_to_non_nullable
                      as String?,
            contactPhone: freezed == contactPhone
                ? _value.contactPhone
                : contactPhone // ignore: cast_nullable_to_non_nullable
                      as String?,
            date: freezed == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            comment: freezed == comment
                ? _value.comment
                : comment // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as DeliveryOrderStatus,
            lines: null == lines
                ? _value.lines
                : lines // ignore: cast_nullable_to_non_nullable
                      as List<DestinationLine>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DestinationImplCopyWith<$Res>
    implements $DestinationCopyWith<$Res> {
  factory _$$DestinationImplCopyWith(
    _$DestinationImpl value,
    $Res Function(_$DestinationImpl) then,
  ) = __$$DestinationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    FulfillmentType fulfillmentType,
    int? shipTo,
    String? addressSummary,
    int? contact,
    String? contactName,
    String? contactPhone,
    DateTime? date,
    String? comment,
    DeliveryOrderStatus status,
    List<DestinationLine> lines,
  });
}

/// @nodoc
class __$$DestinationImplCopyWithImpl<$Res>
    extends _$DestinationCopyWithImpl<$Res, _$DestinationImpl>
    implements _$$DestinationImplCopyWith<$Res> {
  __$$DestinationImplCopyWithImpl(
    _$DestinationImpl _value,
    $Res Function(_$DestinationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Destination
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fulfillmentType = null,
    Object? shipTo = freezed,
    Object? addressSummary = freezed,
    Object? contact = freezed,
    Object? contactName = freezed,
    Object? contactPhone = freezed,
    Object? date = freezed,
    Object? comment = freezed,
    Object? status = null,
    Object? lines = null,
  }) {
    return _then(
      _$DestinationImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        fulfillmentType: null == fulfillmentType
            ? _value.fulfillmentType
            : fulfillmentType // ignore: cast_nullable_to_non_nullable
                  as FulfillmentType,
        shipTo: freezed == shipTo
            ? _value.shipTo
            : shipTo // ignore: cast_nullable_to_non_nullable
                  as int?,
        addressSummary: freezed == addressSummary
            ? _value.addressSummary
            : addressSummary // ignore: cast_nullable_to_non_nullable
                  as String?,
        contact: freezed == contact
            ? _value.contact
            : contact // ignore: cast_nullable_to_non_nullable
                  as int?,
        contactName: freezed == contactName
            ? _value.contactName
            : contactName // ignore: cast_nullable_to_non_nullable
                  as String?,
        contactPhone: freezed == contactPhone
            ? _value.contactPhone
            : contactPhone // ignore: cast_nullable_to_non_nullable
                  as String?,
        date: freezed == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        comment: freezed == comment
            ? _value.comment
            : comment // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as DeliveryOrderStatus,
        lines: null == lines
            ? _value._lines
            : lines // ignore: cast_nullable_to_non_nullable
                  as List<DestinationLine>,
      ),
    );
  }
}

/// @nodoc

class _$DestinationImpl extends _Destination {
  const _$DestinationImpl({
    required this.id,
    required this.fulfillmentType,
    this.shipTo,
    this.addressSummary,
    this.contact,
    this.contactName,
    this.contactPhone,
    this.date,
    this.comment,
    required this.status,
    final List<DestinationLine> lines = const <DestinationLine>[],
  }) : _lines = lines,
       super._();

  @override
  final int id;
  @override
  final FulfillmentType fulfillmentType;
  @override
  final int? shipTo;
  @override
  final String? addressSummary;
  @override
  final int? contact;
  @override
  final String? contactName;
  @override
  final String? contactPhone;
  @override
  final DateTime? date;
  @override
  final String? comment;
  @override
  final DeliveryOrderStatus status;
  final List<DestinationLine> _lines;
  @override
  @JsonKey()
  List<DestinationLine> get lines {
    if (_lines is EqualUnmodifiableListView) return _lines;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_lines);
  }

  @override
  String toString() {
    return 'Destination(id: $id, fulfillmentType: $fulfillmentType, shipTo: $shipTo, addressSummary: $addressSummary, contact: $contact, contactName: $contactName, contactPhone: $contactPhone, date: $date, comment: $comment, status: $status, lines: $lines)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DestinationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.fulfillmentType, fulfillmentType) ||
                other.fulfillmentType == fulfillmentType) &&
            (identical(other.shipTo, shipTo) || other.shipTo == shipTo) &&
            (identical(other.addressSummary, addressSummary) ||
                other.addressSummary == addressSummary) &&
            (identical(other.contact, contact) || other.contact == contact) &&
            (identical(other.contactName, contactName) ||
                other.contactName == contactName) &&
            (identical(other.contactPhone, contactPhone) ||
                other.contactPhone == contactPhone) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._lines, _lines));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    fulfillmentType,
    shipTo,
    addressSummary,
    contact,
    contactName,
    contactPhone,
    date,
    comment,
    status,
    const DeepCollectionEquality().hash(_lines),
  );

  /// Create a copy of Destination
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DestinationImplCopyWith<_$DestinationImpl> get copyWith =>
      __$$DestinationImplCopyWithImpl<_$DestinationImpl>(this, _$identity);
}

abstract class _Destination extends Destination {
  const factory _Destination({
    required final int id,
    required final FulfillmentType fulfillmentType,
    final int? shipTo,
    final String? addressSummary,
    final int? contact,
    final String? contactName,
    final String? contactPhone,
    final DateTime? date,
    final String? comment,
    required final DeliveryOrderStatus status,
    final List<DestinationLine> lines,
  }) = _$DestinationImpl;
  const _Destination._() : super._();

  @override
  int get id;
  @override
  FulfillmentType get fulfillmentType;
  @override
  int? get shipTo;
  @override
  String? get addressSummary;
  @override
  int? get contact;
  @override
  String? get contactName;
  @override
  String? get contactPhone;
  @override
  DateTime? get date;
  @override
  String? get comment;
  @override
  DeliveryOrderStatus get status;
  @override
  List<DestinationLine> get lines;

  /// Create a copy of Destination
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DestinationImplCopyWith<_$DestinationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
