// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'destination.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Destination {

 int get id; FulfillmentType get fulfillmentType; int? get shipTo; String? get addressSummary; int? get contact; String? get contactName; String? get contactPhone; DateTime? get date; String? get comment; DeliveryOrderStatus get status; List<DestinationLine> get lines;
/// Create a copy of Destination
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DestinationCopyWith<Destination> get copyWith => _$DestinationCopyWithImpl<Destination>(this as Destination, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Destination;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Destination&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.fulfillmentType, _this.fulfillmentType) || other.fulfillmentType == _this.fulfillmentType)&&(identical(other.shipTo, _this.shipTo) || other.shipTo == _this.shipTo)&&(identical(other.addressSummary, _this.addressSummary) || other.addressSummary == _this.addressSummary)&&(identical(other.contact, _this.contact) || other.contact == _this.contact)&&(identical(other.contactName, _this.contactName) || other.contactName == _this.contactName)&&(identical(other.contactPhone, _this.contactPhone) || other.contactPhone == _this.contactPhone)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.comment, _this.comment) || other.comment == _this.comment)&&(identical(other.status, _this.status) || other.status == _this.status)&&const DeepCollectionEquality().equals(other.lines, _this.lines));
}


@override
int get hashCode {
  final _this = this as Destination;
  return Object.hash(runtimeType,_this.id,_this.fulfillmentType,_this.shipTo,_this.addressSummary,_this.contact,_this.contactName,_this.contactPhone,_this.date,_this.comment,_this.status,const DeepCollectionEquality().hash(_this.lines));
}

@override
String toString() {
  final _this = this as Destination;
  return 'Destination(id: ${_this.id}, fulfillmentType: ${_this.fulfillmentType}, shipTo: ${_this.shipTo}, addressSummary: ${_this.addressSummary}, contact: ${_this.contact}, contactName: ${_this.contactName}, contactPhone: ${_this.contactPhone}, date: ${_this.date}, comment: ${_this.comment}, status: ${_this.status}, lines: ${_this.lines})';
}


}

/// @nodoc
abstract mixin class $DestinationCopyWith<$Res>  {
  factory $DestinationCopyWith(Destination value, $Res Function(Destination) _then) = _$DestinationCopyWithImpl;
@useResult
$Res call({
 int id, FulfillmentType fulfillmentType, int? shipTo, String? addressSummary, int? contact, String? contactName, String? contactPhone, DateTime? date, String? comment, DeliveryOrderStatus status, List<DestinationLine> lines
});




}
/// @nodoc
class _$DestinationCopyWithImpl<$Res>
    implements $DestinationCopyWith<$Res> {
  _$DestinationCopyWithImpl(this._self, this._then);

  final Destination _self;
  final $Res Function(Destination) _then;

/// Create a copy of Destination
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fulfillmentType = null,Object? shipTo = freezed,Object? addressSummary = freezed,Object? contact = freezed,Object? contactName = freezed,Object? contactPhone = freezed,Object? date = freezed,Object? comment = freezed,Object? status = null,Object? lines = null,}) {
  return _then(Destination(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,fulfillmentType: null == fulfillmentType ? _self.fulfillmentType : fulfillmentType // ignore: cast_nullable_to_non_nullable
as FulfillmentType,shipTo: freezed == shipTo ? _self.shipTo : shipTo // ignore: cast_nullable_to_non_nullable
as int?,addressSummary: freezed == addressSummary ? _self.addressSummary : addressSummary // ignore: cast_nullable_to_non_nullable
as String?,contact: freezed == contact ? _self.contact : contact // ignore: cast_nullable_to_non_nullable
as int?,contactName: freezed == contactName ? _self.contactName : contactName // ignore: cast_nullable_to_non_nullable
as String?,contactPhone: freezed == contactPhone ? _self.contactPhone : contactPhone // ignore: cast_nullable_to_non_nullable
as String?,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DeliveryOrderStatus,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<DestinationLine>,
  ));
}

}


/// Adds pattern-matching-related methods to [Destination].
extension DestinationPatterns on Destination {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Destination value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Destination() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Destination value)  $default,){
final _that = this;
switch (_that) {
case _Destination():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Destination value)?  $default,){
final _that = this;
switch (_that) {
case _Destination() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  FulfillmentType fulfillmentType,  int? shipTo,  String? addressSummary,  int? contact,  String? contactName,  String? contactPhone,  DateTime? date,  String? comment,  DeliveryOrderStatus status,  List<DestinationLine> lines)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Destination() when $default != null:
return $default(_that.id,_that.fulfillmentType,_that.shipTo,_that.addressSummary,_that.contact,_that.contactName,_that.contactPhone,_that.date,_that.comment,_that.status,_that.lines);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  FulfillmentType fulfillmentType,  int? shipTo,  String? addressSummary,  int? contact,  String? contactName,  String? contactPhone,  DateTime? date,  String? comment,  DeliveryOrderStatus status,  List<DestinationLine> lines)  $default,) {final _that = this;
switch (_that) {
case _Destination():
return $default(_that.id,_that.fulfillmentType,_that.shipTo,_that.addressSummary,_that.contact,_that.contactName,_that.contactPhone,_that.date,_that.comment,_that.status,_that.lines);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  FulfillmentType fulfillmentType,  int? shipTo,  String? addressSummary,  int? contact,  String? contactName,  String? contactPhone,  DateTime? date,  String? comment,  DeliveryOrderStatus status,  List<DestinationLine> lines)?  $default,) {final _that = this;
switch (_that) {
case _Destination() when $default != null:
return $default(_that.id,_that.fulfillmentType,_that.shipTo,_that.addressSummary,_that.contact,_that.contactName,_that.contactPhone,_that.date,_that.comment,_that.status,_that.lines);case _:
  return null;

}
}

}

/// @nodoc


class _Destination extends Destination {
  const _Destination({required this.id, required this.fulfillmentType, this.shipTo, this.addressSummary, this.contact, this.contactName, this.contactPhone, this.date, this.comment, required this.status,  List<DestinationLine> lines = const <DestinationLine>[]}): _lines = lines,super._();
  

@override final  int id;
@override final  FulfillmentType fulfillmentType;
@override final  int? shipTo;
@override final  String? addressSummary;
@override final  int? contact;
@override final  String? contactName;
@override final  String? contactPhone;
@override final  DateTime? date;
@override final  String? comment;
@override final  DeliveryOrderStatus status;
 final  List<DestinationLine> _lines;
@override@JsonKey() List<DestinationLine> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}


/// Create a copy of Destination
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DestinationCopyWith<_Destination> get copyWith => __$DestinationCopyWithImpl<_Destination>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Destination&&(identical(other.id, id) || other.id == id)&&(identical(other.fulfillmentType, fulfillmentType) || other.fulfillmentType == fulfillmentType)&&(identical(other.shipTo, shipTo) || other.shipTo == shipTo)&&(identical(other.addressSummary, addressSummary) || other.addressSummary == addressSummary)&&(identical(other.contact, contact) || other.contact == contact)&&(identical(other.contactName, contactName) || other.contactName == contactName)&&(identical(other.contactPhone, contactPhone) || other.contactPhone == contactPhone)&&(identical(other.date, date) || other.date == date)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.lines, _lines));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,fulfillmentType,shipTo,addressSummary,contact,contactName,contactPhone,date,comment,status,const DeepCollectionEquality().hash(_lines));
}

@override
String toString() {
    return 'Destination(id: $id, fulfillmentType: $fulfillmentType, shipTo: $shipTo, addressSummary: $addressSummary, contact: $contact, contactName: $contactName, contactPhone: $contactPhone, date: $date, comment: $comment, status: $status, lines: $lines)';
}


}

/// @nodoc
abstract mixin class _$DestinationCopyWith<$Res> implements $DestinationCopyWith<$Res> {
  factory _$DestinationCopyWith(_Destination value, $Res Function(_Destination) _then) = __$DestinationCopyWithImpl;
@override @useResult
$Res call({
 int id, FulfillmentType fulfillmentType, int? shipTo, String? addressSummary, int? contact, String? contactName, String? contactPhone, DateTime? date, String? comment, DeliveryOrderStatus status, List<DestinationLine> lines
});




}
/// @nodoc
class __$DestinationCopyWithImpl<$Res>
    implements _$DestinationCopyWith<$Res> {
  __$DestinationCopyWithImpl(this._self, this._then);

  final _Destination _self;
  final $Res Function(_Destination) _then;

/// Create a copy of Destination
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fulfillmentType = null,Object? shipTo = freezed,Object? addressSummary = freezed,Object? contact = freezed,Object? contactName = freezed,Object? contactPhone = freezed,Object? date = freezed,Object? comment = freezed,Object? status = null,Object? lines = null,}) {
  return _then(_Destination(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,fulfillmentType: null == fulfillmentType ? _self.fulfillmentType : fulfillmentType // ignore: cast_nullable_to_non_nullable
as FulfillmentType,shipTo: freezed == shipTo ? _self.shipTo : shipTo // ignore: cast_nullable_to_non_nullable
as int?,addressSummary: freezed == addressSummary ? _self.addressSummary : addressSummary // ignore: cast_nullable_to_non_nullable
as String?,contact: freezed == contact ? _self.contact : contact // ignore: cast_nullable_to_non_nullable
as int?,contactName: freezed == contactName ? _self.contactName : contactName // ignore: cast_nullable_to_non_nullable
as String?,contactPhone: freezed == contactPhone ? _self.contactPhone : contactPhone // ignore: cast_nullable_to_non_nullable
as String?,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DeliveryOrderStatus,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<DestinationLine>,
  ));
}


}

// dart format on
