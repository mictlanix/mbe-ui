// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'address_inline_create_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AddressInlineCreateState {
  String get street => throw _privateConstructorUsedError;
  String get exteriorNumber => throw _privateConstructorUsedError;
  String get interiorNumber => throw _privateConstructorUsedError;
  String get postalCode => throw _privateConstructorUsedError;
  String get neighborhood => throw _privateConstructorUsedError;
  String get locality => throw _privateConstructorUsedError;
  String get borough => throw _privateConstructorUsedError;
  String get addressState => throw _privateConstructorUsedError;
  String get city => throw _privateConstructorUsedError;
  String get country => throw _privateConstructorUsedError;
  String get nickname => throw _privateConstructorUsedError;
  AddressType? get type => throw _privateConstructorUsedError;
  String get comment => throw _privateConstructorUsedError;
  bool get submitting => throw _privateConstructorUsedError;
  AddressListItem? get created => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  String? get errorDetail => throw _privateConstructorUsedError;
  Map<String, String> get fieldErrors => throw _privateConstructorUsedError;

  /// Create a copy of AddressInlineCreateState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AddressInlineCreateStateCopyWith<AddressInlineCreateState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AddressInlineCreateStateCopyWith<$Res> {
  factory $AddressInlineCreateStateCopyWith(
    AddressInlineCreateState value,
    $Res Function(AddressInlineCreateState) then,
  ) = _$AddressInlineCreateStateCopyWithImpl<$Res, AddressInlineCreateState>;
  @useResult
  $Res call({
    String street,
    String exteriorNumber,
    String interiorNumber,
    String postalCode,
    String neighborhood,
    String locality,
    String borough,
    String addressState,
    String city,
    String country,
    String nickname,
    AddressType? type,
    String comment,
    bool submitting,
    AddressListItem? created,
    String? error,
    String? errorDetail,
    Map<String, String> fieldErrors,
  });

  $AddressListItemCopyWith<$Res>? get created;
}

/// @nodoc
class _$AddressInlineCreateStateCopyWithImpl<
  $Res,
  $Val extends AddressInlineCreateState
>
    implements $AddressInlineCreateStateCopyWith<$Res> {
  _$AddressInlineCreateStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AddressInlineCreateState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? street = null,
    Object? exteriorNumber = null,
    Object? interiorNumber = null,
    Object? postalCode = null,
    Object? neighborhood = null,
    Object? locality = null,
    Object? borough = null,
    Object? addressState = null,
    Object? city = null,
    Object? country = null,
    Object? nickname = null,
    Object? type = freezed,
    Object? comment = null,
    Object? submitting = null,
    Object? created = freezed,
    Object? error = freezed,
    Object? errorDetail = freezed,
    Object? fieldErrors = null,
  }) {
    return _then(
      _value.copyWith(
            street: null == street
                ? _value.street
                : street // ignore: cast_nullable_to_non_nullable
                      as String,
            exteriorNumber: null == exteriorNumber
                ? _value.exteriorNumber
                : exteriorNumber // ignore: cast_nullable_to_non_nullable
                      as String,
            interiorNumber: null == interiorNumber
                ? _value.interiorNumber
                : interiorNumber // ignore: cast_nullable_to_non_nullable
                      as String,
            postalCode: null == postalCode
                ? _value.postalCode
                : postalCode // ignore: cast_nullable_to_non_nullable
                      as String,
            neighborhood: null == neighborhood
                ? _value.neighborhood
                : neighborhood // ignore: cast_nullable_to_non_nullable
                      as String,
            locality: null == locality
                ? _value.locality
                : locality // ignore: cast_nullable_to_non_nullable
                      as String,
            borough: null == borough
                ? _value.borough
                : borough // ignore: cast_nullable_to_non_nullable
                      as String,
            addressState: null == addressState
                ? _value.addressState
                : addressState // ignore: cast_nullable_to_non_nullable
                      as String,
            city: null == city
                ? _value.city
                : city // ignore: cast_nullable_to_non_nullable
                      as String,
            country: null == country
                ? _value.country
                : country // ignore: cast_nullable_to_non_nullable
                      as String,
            nickname: null == nickname
                ? _value.nickname
                : nickname // ignore: cast_nullable_to_non_nullable
                      as String,
            type: freezed == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as AddressType?,
            comment: null == comment
                ? _value.comment
                : comment // ignore: cast_nullable_to_non_nullable
                      as String,
            submitting: null == submitting
                ? _value.submitting
                : submitting // ignore: cast_nullable_to_non_nullable
                      as bool,
            created: freezed == created
                ? _value.created
                : created // ignore: cast_nullable_to_non_nullable
                      as AddressListItem?,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
            errorDetail: freezed == errorDetail
                ? _value.errorDetail
                : errorDetail // ignore: cast_nullable_to_non_nullable
                      as String?,
            fieldErrors: null == fieldErrors
                ? _value.fieldErrors
                : fieldErrors // ignore: cast_nullable_to_non_nullable
                      as Map<String, String>,
          )
          as $Val,
    );
  }

  /// Create a copy of AddressInlineCreateState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AddressListItemCopyWith<$Res>? get created {
    if (_value.created == null) {
      return null;
    }

    return $AddressListItemCopyWith<$Res>(_value.created!, (value) {
      return _then(_value.copyWith(created: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AddressInlineCreateStateImplCopyWith<$Res>
    implements $AddressInlineCreateStateCopyWith<$Res> {
  factory _$$AddressInlineCreateStateImplCopyWith(
    _$AddressInlineCreateStateImpl value,
    $Res Function(_$AddressInlineCreateStateImpl) then,
  ) = __$$AddressInlineCreateStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String street,
    String exteriorNumber,
    String interiorNumber,
    String postalCode,
    String neighborhood,
    String locality,
    String borough,
    String addressState,
    String city,
    String country,
    String nickname,
    AddressType? type,
    String comment,
    bool submitting,
    AddressListItem? created,
    String? error,
    String? errorDetail,
    Map<String, String> fieldErrors,
  });

  @override
  $AddressListItemCopyWith<$Res>? get created;
}

/// @nodoc
class __$$AddressInlineCreateStateImplCopyWithImpl<$Res>
    extends
        _$AddressInlineCreateStateCopyWithImpl<
          $Res,
          _$AddressInlineCreateStateImpl
        >
    implements _$$AddressInlineCreateStateImplCopyWith<$Res> {
  __$$AddressInlineCreateStateImplCopyWithImpl(
    _$AddressInlineCreateStateImpl _value,
    $Res Function(_$AddressInlineCreateStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AddressInlineCreateState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? street = null,
    Object? exteriorNumber = null,
    Object? interiorNumber = null,
    Object? postalCode = null,
    Object? neighborhood = null,
    Object? locality = null,
    Object? borough = null,
    Object? addressState = null,
    Object? city = null,
    Object? country = null,
    Object? nickname = null,
    Object? type = freezed,
    Object? comment = null,
    Object? submitting = null,
    Object? created = freezed,
    Object? error = freezed,
    Object? errorDetail = freezed,
    Object? fieldErrors = null,
  }) {
    return _then(
      _$AddressInlineCreateStateImpl(
        street: null == street
            ? _value.street
            : street // ignore: cast_nullable_to_non_nullable
                  as String,
        exteriorNumber: null == exteriorNumber
            ? _value.exteriorNumber
            : exteriorNumber // ignore: cast_nullable_to_non_nullable
                  as String,
        interiorNumber: null == interiorNumber
            ? _value.interiorNumber
            : interiorNumber // ignore: cast_nullable_to_non_nullable
                  as String,
        postalCode: null == postalCode
            ? _value.postalCode
            : postalCode // ignore: cast_nullable_to_non_nullable
                  as String,
        neighborhood: null == neighborhood
            ? _value.neighborhood
            : neighborhood // ignore: cast_nullable_to_non_nullable
                  as String,
        locality: null == locality
            ? _value.locality
            : locality // ignore: cast_nullable_to_non_nullable
                  as String,
        borough: null == borough
            ? _value.borough
            : borough // ignore: cast_nullable_to_non_nullable
                  as String,
        addressState: null == addressState
            ? _value.addressState
            : addressState // ignore: cast_nullable_to_non_nullable
                  as String,
        city: null == city
            ? _value.city
            : city // ignore: cast_nullable_to_non_nullable
                  as String,
        country: null == country
            ? _value.country
            : country // ignore: cast_nullable_to_non_nullable
                  as String,
        nickname: null == nickname
            ? _value.nickname
            : nickname // ignore: cast_nullable_to_non_nullable
                  as String,
        type: freezed == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as AddressType?,
        comment: null == comment
            ? _value.comment
            : comment // ignore: cast_nullable_to_non_nullable
                  as String,
        submitting: null == submitting
            ? _value.submitting
            : submitting // ignore: cast_nullable_to_non_nullable
                  as bool,
        created: freezed == created
            ? _value.created
            : created // ignore: cast_nullable_to_non_nullable
                  as AddressListItem?,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
        errorDetail: freezed == errorDetail
            ? _value.errorDetail
            : errorDetail // ignore: cast_nullable_to_non_nullable
                  as String?,
        fieldErrors: null == fieldErrors
            ? _value._fieldErrors
            : fieldErrors // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>,
      ),
    );
  }
}

/// @nodoc

class _$AddressInlineCreateStateImpl implements _AddressInlineCreateState {
  const _$AddressInlineCreateStateImpl({
    this.street = '',
    this.exteriorNumber = '',
    this.interiorNumber = '',
    this.postalCode = '',
    this.neighborhood = '',
    this.locality = '',
    this.borough = '',
    this.addressState = '',
    this.city = '',
    this.country = '',
    this.nickname = '',
    this.type,
    this.comment = '',
    this.submitting = false,
    this.created,
    this.error,
    this.errorDetail,
    final Map<String, String> fieldErrors = const <String, String>{},
  }) : _fieldErrors = fieldErrors;

  @override
  @JsonKey()
  final String street;
  @override
  @JsonKey()
  final String exteriorNumber;
  @override
  @JsonKey()
  final String interiorNumber;
  @override
  @JsonKey()
  final String postalCode;
  @override
  @JsonKey()
  final String neighborhood;
  @override
  @JsonKey()
  final String locality;
  @override
  @JsonKey()
  final String borough;
  @override
  @JsonKey()
  final String addressState;
  @override
  @JsonKey()
  final String city;
  @override
  @JsonKey()
  final String country;
  @override
  @JsonKey()
  final String nickname;
  @override
  final AddressType? type;
  @override
  @JsonKey()
  final String comment;
  @override
  @JsonKey()
  final bool submitting;
  @override
  final AddressListItem? created;
  @override
  final String? error;
  @override
  final String? errorDetail;
  final Map<String, String> _fieldErrors;
  @override
  @JsonKey()
  Map<String, String> get fieldErrors {
    if (_fieldErrors is EqualUnmodifiableMapView) return _fieldErrors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_fieldErrors);
  }

  @override
  String toString() {
    return 'AddressInlineCreateState(street: $street, exteriorNumber: $exteriorNumber, interiorNumber: $interiorNumber, postalCode: $postalCode, neighborhood: $neighborhood, locality: $locality, borough: $borough, addressState: $addressState, city: $city, country: $country, nickname: $nickname, type: $type, comment: $comment, submitting: $submitting, created: $created, error: $error, errorDetail: $errorDetail, fieldErrors: $fieldErrors)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AddressInlineCreateStateImpl &&
            (identical(other.street, street) || other.street == street) &&
            (identical(other.exteriorNumber, exteriorNumber) ||
                other.exteriorNumber == exteriorNumber) &&
            (identical(other.interiorNumber, interiorNumber) ||
                other.interiorNumber == interiorNumber) &&
            (identical(other.postalCode, postalCode) ||
                other.postalCode == postalCode) &&
            (identical(other.neighborhood, neighborhood) ||
                other.neighborhood == neighborhood) &&
            (identical(other.locality, locality) ||
                other.locality == locality) &&
            (identical(other.borough, borough) || other.borough == borough) &&
            (identical(other.addressState, addressState) ||
                other.addressState == addressState) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            (identical(other.submitting, submitting) ||
                other.submitting == submitting) &&
            (identical(other.created, created) || other.created == created) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.errorDetail, errorDetail) ||
                other.errorDetail == errorDetail) &&
            const DeepCollectionEquality().equals(
              other._fieldErrors,
              _fieldErrors,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    street,
    exteriorNumber,
    interiorNumber,
    postalCode,
    neighborhood,
    locality,
    borough,
    addressState,
    city,
    country,
    nickname,
    type,
    comment,
    submitting,
    created,
    error,
    errorDetail,
    const DeepCollectionEquality().hash(_fieldErrors),
  );

  /// Create a copy of AddressInlineCreateState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AddressInlineCreateStateImplCopyWith<_$AddressInlineCreateStateImpl>
  get copyWith =>
      __$$AddressInlineCreateStateImplCopyWithImpl<
        _$AddressInlineCreateStateImpl
      >(this, _$identity);
}

abstract class _AddressInlineCreateState implements AddressInlineCreateState {
  const factory _AddressInlineCreateState({
    final String street,
    final String exteriorNumber,
    final String interiorNumber,
    final String postalCode,
    final String neighborhood,
    final String locality,
    final String borough,
    final String addressState,
    final String city,
    final String country,
    final String nickname,
    final AddressType? type,
    final String comment,
    final bool submitting,
    final AddressListItem? created,
    final String? error,
    final String? errorDetail,
    final Map<String, String> fieldErrors,
  }) = _$AddressInlineCreateStateImpl;

  @override
  String get street;
  @override
  String get exteriorNumber;
  @override
  String get interiorNumber;
  @override
  String get postalCode;
  @override
  String get neighborhood;
  @override
  String get locality;
  @override
  String get borough;
  @override
  String get addressState;
  @override
  String get city;
  @override
  String get country;
  @override
  String get nickname;
  @override
  AddressType? get type;
  @override
  String get comment;
  @override
  bool get submitting;
  @override
  AddressListItem? get created;
  @override
  String? get error;
  @override
  String? get errorDetail;
  @override
  Map<String, String> get fieldErrors;

  /// Create a copy of AddressInlineCreateState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AddressInlineCreateStateImplCopyWith<_$AddressInlineCreateStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}
