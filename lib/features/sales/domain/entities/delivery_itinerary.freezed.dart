// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'delivery_itinerary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ItinerarySummary {

 int get id; DateTime get date; int? get vehicleId; String? get vehicleName; int? get vehicleOperatorId; String? get operatorName; int? get warehouseId; String? get warehouseName; ItineraryStatus get status; DateTime? get departedAt; DateTime? get returnedAt;
/// Create a copy of ItinerarySummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItinerarySummaryCopyWith<ItinerarySummary> get copyWith => _$ItinerarySummaryCopyWithImpl<ItinerarySummary>(this as ItinerarySummary, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ItinerarySummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItinerarySummary&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.vehicleId, _this.vehicleId) || other.vehicleId == _this.vehicleId)&&(identical(other.vehicleName, _this.vehicleName) || other.vehicleName == _this.vehicleName)&&(identical(other.vehicleOperatorId, _this.vehicleOperatorId) || other.vehicleOperatorId == _this.vehicleOperatorId)&&(identical(other.operatorName, _this.operatorName) || other.operatorName == _this.operatorName)&&(identical(other.warehouseId, _this.warehouseId) || other.warehouseId == _this.warehouseId)&&(identical(other.warehouseName, _this.warehouseName) || other.warehouseName == _this.warehouseName)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.departedAt, _this.departedAt) || other.departedAt == _this.departedAt)&&(identical(other.returnedAt, _this.returnedAt) || other.returnedAt == _this.returnedAt));
}


@override
int get hashCode {
  final _this = this as ItinerarySummary;
  return Object.hash(runtimeType,_this.id,_this.date,_this.vehicleId,_this.vehicleName,_this.vehicleOperatorId,_this.operatorName,_this.warehouseId,_this.warehouseName,_this.status,_this.departedAt,_this.returnedAt);
}

@override
String toString() {
  final _this = this as ItinerarySummary;
  return 'ItinerarySummary(id: ${_this.id}, date: ${_this.date}, vehicleId: ${_this.vehicleId}, vehicleName: ${_this.vehicleName}, vehicleOperatorId: ${_this.vehicleOperatorId}, operatorName: ${_this.operatorName}, warehouseId: ${_this.warehouseId}, warehouseName: ${_this.warehouseName}, status: ${_this.status}, departedAt: ${_this.departedAt}, returnedAt: ${_this.returnedAt})';
}


}

/// @nodoc
abstract mixin class $ItinerarySummaryCopyWith<$Res>  {
  factory $ItinerarySummaryCopyWith(ItinerarySummary value, $Res Function(ItinerarySummary) _then) = _$ItinerarySummaryCopyWithImpl;
@useResult
$Res call({
 int id, DateTime date, int? vehicleId, String? vehicleName, int? vehicleOperatorId, String? operatorName, int? warehouseId, String? warehouseName, ItineraryStatus status, DateTime? departedAt, DateTime? returnedAt
});




}
/// @nodoc
class _$ItinerarySummaryCopyWithImpl<$Res>
    implements $ItinerarySummaryCopyWith<$Res> {
  _$ItinerarySummaryCopyWithImpl(this._self, this._then);

  final ItinerarySummary _self;
  final $Res Function(ItinerarySummary) _then;

/// Create a copy of ItinerarySummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? date = null,Object? vehicleId = freezed,Object? vehicleName = freezed,Object? vehicleOperatorId = freezed,Object? operatorName = freezed,Object? warehouseId = freezed,Object? warehouseName = freezed,Object? status = null,Object? departedAt = freezed,Object? returnedAt = freezed,}) {
  return _then(ItinerarySummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,vehicleId: freezed == vehicleId ? _self.vehicleId : vehicleId // ignore: cast_nullable_to_non_nullable
as int?,vehicleName: freezed == vehicleName ? _self.vehicleName : vehicleName // ignore: cast_nullable_to_non_nullable
as String?,vehicleOperatorId: freezed == vehicleOperatorId ? _self.vehicleOperatorId : vehicleOperatorId // ignore: cast_nullable_to_non_nullable
as int?,operatorName: freezed == operatorName ? _self.operatorName : operatorName // ignore: cast_nullable_to_non_nullable
as String?,warehouseId: freezed == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int?,warehouseName: freezed == warehouseName ? _self.warehouseName : warehouseName // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ItineraryStatus,departedAt: freezed == departedAt ? _self.departedAt : departedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,returnedAt: freezed == returnedAt ? _self.returnedAt : returnedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ItinerarySummary].
extension ItinerarySummaryPatterns on ItinerarySummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItinerarySummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItinerarySummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItinerarySummary value)  $default,){
final _that = this;
switch (_that) {
case _ItinerarySummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItinerarySummary value)?  $default,){
final _that = this;
switch (_that) {
case _ItinerarySummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  DateTime date,  int? vehicleId,  String? vehicleName,  int? vehicleOperatorId,  String? operatorName,  int? warehouseId,  String? warehouseName,  ItineraryStatus status,  DateTime? departedAt,  DateTime? returnedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItinerarySummary() when $default != null:
return $default(_that.id,_that.date,_that.vehicleId,_that.vehicleName,_that.vehicleOperatorId,_that.operatorName,_that.warehouseId,_that.warehouseName,_that.status,_that.departedAt,_that.returnedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  DateTime date,  int? vehicleId,  String? vehicleName,  int? vehicleOperatorId,  String? operatorName,  int? warehouseId,  String? warehouseName,  ItineraryStatus status,  DateTime? departedAt,  DateTime? returnedAt)  $default,) {final _that = this;
switch (_that) {
case _ItinerarySummary():
return $default(_that.id,_that.date,_that.vehicleId,_that.vehicleName,_that.vehicleOperatorId,_that.operatorName,_that.warehouseId,_that.warehouseName,_that.status,_that.departedAt,_that.returnedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  DateTime date,  int? vehicleId,  String? vehicleName,  int? vehicleOperatorId,  String? operatorName,  int? warehouseId,  String? warehouseName,  ItineraryStatus status,  DateTime? departedAt,  DateTime? returnedAt)?  $default,) {final _that = this;
switch (_that) {
case _ItinerarySummary() when $default != null:
return $default(_that.id,_that.date,_that.vehicleId,_that.vehicleName,_that.vehicleOperatorId,_that.operatorName,_that.warehouseId,_that.warehouseName,_that.status,_that.departedAt,_that.returnedAt);case _:
  return null;

}
}

}

/// @nodoc


class _ItinerarySummary implements ItinerarySummary {
  const _ItinerarySummary({required this.id, required this.date, this.vehicleId, this.vehicleName, this.vehicleOperatorId, this.operatorName, this.warehouseId, this.warehouseName, required this.status, this.departedAt, this.returnedAt});
  

@override final  int id;
@override final  DateTime date;
@override final  int? vehicleId;
@override final  String? vehicleName;
@override final  int? vehicleOperatorId;
@override final  String? operatorName;
@override final  int? warehouseId;
@override final  String? warehouseName;
@override final  ItineraryStatus status;
@override final  DateTime? departedAt;
@override final  DateTime? returnedAt;

/// Create a copy of ItinerarySummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItinerarySummaryCopyWith<_ItinerarySummary> get copyWith => __$ItinerarySummaryCopyWithImpl<_ItinerarySummary>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItinerarySummary&&(identical(other.id, id) || other.id == id)&&(identical(other.date, date) || other.date == date)&&(identical(other.vehicleId, vehicleId) || other.vehicleId == vehicleId)&&(identical(other.vehicleName, vehicleName) || other.vehicleName == vehicleName)&&(identical(other.vehicleOperatorId, vehicleOperatorId) || other.vehicleOperatorId == vehicleOperatorId)&&(identical(other.operatorName, operatorName) || other.operatorName == operatorName)&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.warehouseName, warehouseName) || other.warehouseName == warehouseName)&&(identical(other.status, status) || other.status == status)&&(identical(other.departedAt, departedAt) || other.departedAt == departedAt)&&(identical(other.returnedAt, returnedAt) || other.returnedAt == returnedAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,date,vehicleId,vehicleName,vehicleOperatorId,operatorName,warehouseId,warehouseName,status,departedAt,returnedAt);
}

@override
String toString() {
    return 'ItinerarySummary(id: $id, date: $date, vehicleId: $vehicleId, vehicleName: $vehicleName, vehicleOperatorId: $vehicleOperatorId, operatorName: $operatorName, warehouseId: $warehouseId, warehouseName: $warehouseName, status: $status, departedAt: $departedAt, returnedAt: $returnedAt)';
}


}

/// @nodoc
abstract mixin class _$ItinerarySummaryCopyWith<$Res> implements $ItinerarySummaryCopyWith<$Res> {
  factory _$ItinerarySummaryCopyWith(_ItinerarySummary value, $Res Function(_ItinerarySummary) _then) = __$ItinerarySummaryCopyWithImpl;
@override @useResult
$Res call({
 int id, DateTime date, int? vehicleId, String? vehicleName, int? vehicleOperatorId, String? operatorName, int? warehouseId, String? warehouseName, ItineraryStatus status, DateTime? departedAt, DateTime? returnedAt
});




}
/// @nodoc
class __$ItinerarySummaryCopyWithImpl<$Res>
    implements _$ItinerarySummaryCopyWith<$Res> {
  __$ItinerarySummaryCopyWithImpl(this._self, this._then);

  final _ItinerarySummary _self;
  final $Res Function(_ItinerarySummary) _then;

/// Create a copy of ItinerarySummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? date = null,Object? vehicleId = freezed,Object? vehicleName = freezed,Object? vehicleOperatorId = freezed,Object? operatorName = freezed,Object? warehouseId = freezed,Object? warehouseName = freezed,Object? status = null,Object? departedAt = freezed,Object? returnedAt = freezed,}) {
  return _then(_ItinerarySummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,vehicleId: freezed == vehicleId ? _self.vehicleId : vehicleId // ignore: cast_nullable_to_non_nullable
as int?,vehicleName: freezed == vehicleName ? _self.vehicleName : vehicleName // ignore: cast_nullable_to_non_nullable
as String?,vehicleOperatorId: freezed == vehicleOperatorId ? _self.vehicleOperatorId : vehicleOperatorId // ignore: cast_nullable_to_non_nullable
as int?,operatorName: freezed == operatorName ? _self.operatorName : operatorName // ignore: cast_nullable_to_non_nullable
as String?,warehouseId: freezed == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int?,warehouseName: freezed == warehouseName ? _self.warehouseName : warehouseName // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ItineraryStatus,departedAt: freezed == departedAt ? _self.departedAt : departedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,returnedAt: freezed == returnedAt ? _self.returnedAt : returnedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc
mixin _$Itinerary {

 int get id; DateTime get date; int? get vehicleId; String? get vehicleName; int? get vehicleOperatorId; String? get operatorName; int? get warehouseId; String? get warehouseName; ItineraryStatus get status; DateTime? get departedAt; DateTime? get returnedAt; String? get comment; List<ItineraryStop> get stops;
/// Create a copy of Itinerary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItineraryCopyWith<Itinerary> get copyWith => _$ItineraryCopyWithImpl<Itinerary>(this as Itinerary, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Itinerary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Itinerary&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.vehicleId, _this.vehicleId) || other.vehicleId == _this.vehicleId)&&(identical(other.vehicleName, _this.vehicleName) || other.vehicleName == _this.vehicleName)&&(identical(other.vehicleOperatorId, _this.vehicleOperatorId) || other.vehicleOperatorId == _this.vehicleOperatorId)&&(identical(other.operatorName, _this.operatorName) || other.operatorName == _this.operatorName)&&(identical(other.warehouseId, _this.warehouseId) || other.warehouseId == _this.warehouseId)&&(identical(other.warehouseName, _this.warehouseName) || other.warehouseName == _this.warehouseName)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.departedAt, _this.departedAt) || other.departedAt == _this.departedAt)&&(identical(other.returnedAt, _this.returnedAt) || other.returnedAt == _this.returnedAt)&&(identical(other.comment, _this.comment) || other.comment == _this.comment)&&const DeepCollectionEquality().equals(other.stops, _this.stops));
}


@override
int get hashCode {
  final _this = this as Itinerary;
  return Object.hash(runtimeType,_this.id,_this.date,_this.vehicleId,_this.vehicleName,_this.vehicleOperatorId,_this.operatorName,_this.warehouseId,_this.warehouseName,_this.status,_this.departedAt,_this.returnedAt,_this.comment,const DeepCollectionEquality().hash(_this.stops));
}

@override
String toString() {
  final _this = this as Itinerary;
  return 'Itinerary(id: ${_this.id}, date: ${_this.date}, vehicleId: ${_this.vehicleId}, vehicleName: ${_this.vehicleName}, vehicleOperatorId: ${_this.vehicleOperatorId}, operatorName: ${_this.operatorName}, warehouseId: ${_this.warehouseId}, warehouseName: ${_this.warehouseName}, status: ${_this.status}, departedAt: ${_this.departedAt}, returnedAt: ${_this.returnedAt}, comment: ${_this.comment}, stops: ${_this.stops})';
}


}

/// @nodoc
abstract mixin class $ItineraryCopyWith<$Res>  {
  factory $ItineraryCopyWith(Itinerary value, $Res Function(Itinerary) _then) = _$ItineraryCopyWithImpl;
@useResult
$Res call({
 int id, DateTime date, int? vehicleId, String? vehicleName, int? vehicleOperatorId, String? operatorName, int? warehouseId, String? warehouseName, ItineraryStatus status, DateTime? departedAt, DateTime? returnedAt, String? comment, List<ItineraryStop> stops
});




}
/// @nodoc
class _$ItineraryCopyWithImpl<$Res>
    implements $ItineraryCopyWith<$Res> {
  _$ItineraryCopyWithImpl(this._self, this._then);

  final Itinerary _self;
  final $Res Function(Itinerary) _then;

/// Create a copy of Itinerary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? date = null,Object? vehicleId = freezed,Object? vehicleName = freezed,Object? vehicleOperatorId = freezed,Object? operatorName = freezed,Object? warehouseId = freezed,Object? warehouseName = freezed,Object? status = null,Object? departedAt = freezed,Object? returnedAt = freezed,Object? comment = freezed,Object? stops = null,}) {
  return _then(Itinerary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,vehicleId: freezed == vehicleId ? _self.vehicleId : vehicleId // ignore: cast_nullable_to_non_nullable
as int?,vehicleName: freezed == vehicleName ? _self.vehicleName : vehicleName // ignore: cast_nullable_to_non_nullable
as String?,vehicleOperatorId: freezed == vehicleOperatorId ? _self.vehicleOperatorId : vehicleOperatorId // ignore: cast_nullable_to_non_nullable
as int?,operatorName: freezed == operatorName ? _self.operatorName : operatorName // ignore: cast_nullable_to_non_nullable
as String?,warehouseId: freezed == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int?,warehouseName: freezed == warehouseName ? _self.warehouseName : warehouseName // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ItineraryStatus,departedAt: freezed == departedAt ? _self.departedAt : departedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,returnedAt: freezed == returnedAt ? _self.returnedAt : returnedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,stops: null == stops ? _self.stops : stops // ignore: cast_nullable_to_non_nullable
as List<ItineraryStop>,
  ));
}

}


/// Adds pattern-matching-related methods to [Itinerary].
extension ItineraryPatterns on Itinerary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Itinerary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Itinerary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Itinerary value)  $default,){
final _that = this;
switch (_that) {
case _Itinerary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Itinerary value)?  $default,){
final _that = this;
switch (_that) {
case _Itinerary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  DateTime date,  int? vehicleId,  String? vehicleName,  int? vehicleOperatorId,  String? operatorName,  int? warehouseId,  String? warehouseName,  ItineraryStatus status,  DateTime? departedAt,  DateTime? returnedAt,  String? comment,  List<ItineraryStop> stops)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Itinerary() when $default != null:
return $default(_that.id,_that.date,_that.vehicleId,_that.vehicleName,_that.vehicleOperatorId,_that.operatorName,_that.warehouseId,_that.warehouseName,_that.status,_that.departedAt,_that.returnedAt,_that.comment,_that.stops);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  DateTime date,  int? vehicleId,  String? vehicleName,  int? vehicleOperatorId,  String? operatorName,  int? warehouseId,  String? warehouseName,  ItineraryStatus status,  DateTime? departedAt,  DateTime? returnedAt,  String? comment,  List<ItineraryStop> stops)  $default,) {final _that = this;
switch (_that) {
case _Itinerary():
return $default(_that.id,_that.date,_that.vehicleId,_that.vehicleName,_that.vehicleOperatorId,_that.operatorName,_that.warehouseId,_that.warehouseName,_that.status,_that.departedAt,_that.returnedAt,_that.comment,_that.stops);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  DateTime date,  int? vehicleId,  String? vehicleName,  int? vehicleOperatorId,  String? operatorName,  int? warehouseId,  String? warehouseName,  ItineraryStatus status,  DateTime? departedAt,  DateTime? returnedAt,  String? comment,  List<ItineraryStop> stops)?  $default,) {final _that = this;
switch (_that) {
case _Itinerary() when $default != null:
return $default(_that.id,_that.date,_that.vehicleId,_that.vehicleName,_that.vehicleOperatorId,_that.operatorName,_that.warehouseId,_that.warehouseName,_that.status,_that.departedAt,_that.returnedAt,_that.comment,_that.stops);case _:
  return null;

}
}

}

/// @nodoc


class _Itinerary extends Itinerary {
  const _Itinerary({required this.id, required this.date, this.vehicleId, this.vehicleName, this.vehicleOperatorId, this.operatorName, this.warehouseId, this.warehouseName, required this.status, this.departedAt, this.returnedAt, this.comment,  List<ItineraryStop> stops = const <ItineraryStop>[]}): _stops = stops,super._();
  

@override final  int id;
@override final  DateTime date;
@override final  int? vehicleId;
@override final  String? vehicleName;
@override final  int? vehicleOperatorId;
@override final  String? operatorName;
@override final  int? warehouseId;
@override final  String? warehouseName;
@override final  ItineraryStatus status;
@override final  DateTime? departedAt;
@override final  DateTime? returnedAt;
@override final  String? comment;
 final  List<ItineraryStop> _stops;
@override@JsonKey() List<ItineraryStop> get stops {
  if (_stops is EqualUnmodifiableListView) return _stops;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_stops);
}


/// Create a copy of Itinerary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItineraryCopyWith<_Itinerary> get copyWith => __$ItineraryCopyWithImpl<_Itinerary>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Itinerary&&(identical(other.id, id) || other.id == id)&&(identical(other.date, date) || other.date == date)&&(identical(other.vehicleId, vehicleId) || other.vehicleId == vehicleId)&&(identical(other.vehicleName, vehicleName) || other.vehicleName == vehicleName)&&(identical(other.vehicleOperatorId, vehicleOperatorId) || other.vehicleOperatorId == vehicleOperatorId)&&(identical(other.operatorName, operatorName) || other.operatorName == operatorName)&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.warehouseName, warehouseName) || other.warehouseName == warehouseName)&&(identical(other.status, status) || other.status == status)&&(identical(other.departedAt, departedAt) || other.departedAt == departedAt)&&(identical(other.returnedAt, returnedAt) || other.returnedAt == returnedAt)&&(identical(other.comment, comment) || other.comment == comment)&&const DeepCollectionEquality().equals(other.stops, _stops));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,date,vehicleId,vehicleName,vehicleOperatorId,operatorName,warehouseId,warehouseName,status,departedAt,returnedAt,comment,const DeepCollectionEquality().hash(_stops));
}

@override
String toString() {
    return 'Itinerary(id: $id, date: $date, vehicleId: $vehicleId, vehicleName: $vehicleName, vehicleOperatorId: $vehicleOperatorId, operatorName: $operatorName, warehouseId: $warehouseId, warehouseName: $warehouseName, status: $status, departedAt: $departedAt, returnedAt: $returnedAt, comment: $comment, stops: $stops)';
}


}

/// @nodoc
abstract mixin class _$ItineraryCopyWith<$Res> implements $ItineraryCopyWith<$Res> {
  factory _$ItineraryCopyWith(_Itinerary value, $Res Function(_Itinerary) _then) = __$ItineraryCopyWithImpl;
@override @useResult
$Res call({
 int id, DateTime date, int? vehicleId, String? vehicleName, int? vehicleOperatorId, String? operatorName, int? warehouseId, String? warehouseName, ItineraryStatus status, DateTime? departedAt, DateTime? returnedAt, String? comment, List<ItineraryStop> stops
});




}
/// @nodoc
class __$ItineraryCopyWithImpl<$Res>
    implements _$ItineraryCopyWith<$Res> {
  __$ItineraryCopyWithImpl(this._self, this._then);

  final _Itinerary _self;
  final $Res Function(_Itinerary) _then;

/// Create a copy of Itinerary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? date = null,Object? vehicleId = freezed,Object? vehicleName = freezed,Object? vehicleOperatorId = freezed,Object? operatorName = freezed,Object? warehouseId = freezed,Object? warehouseName = freezed,Object? status = null,Object? departedAt = freezed,Object? returnedAt = freezed,Object? comment = freezed,Object? stops = null,}) {
  return _then(_Itinerary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,vehicleId: freezed == vehicleId ? _self.vehicleId : vehicleId // ignore: cast_nullable_to_non_nullable
as int?,vehicleName: freezed == vehicleName ? _self.vehicleName : vehicleName // ignore: cast_nullable_to_non_nullable
as String?,vehicleOperatorId: freezed == vehicleOperatorId ? _self.vehicleOperatorId : vehicleOperatorId // ignore: cast_nullable_to_non_nullable
as int?,operatorName: freezed == operatorName ? _self.operatorName : operatorName // ignore: cast_nullable_to_non_nullable
as String?,warehouseId: freezed == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int?,warehouseName: freezed == warehouseName ? _self.warehouseName : warehouseName // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ItineraryStatus,departedAt: freezed == departedAt ? _self.departedAt : departedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,returnedAt: freezed == returnedAt ? _self.returnedAt : returnedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,stops: null == stops ? _self._stops : stops // ignore: cast_nullable_to_non_nullable
as List<ItineraryStop>,
  ));
}


}

/// @nodoc
mixin _$ItineraryStop {

 int get id; int get sequence; StopOutcome get outcome;/// Set by the server when the stop is closed.
 DateTime? get arrivedAt; int? get proofId; String? get comment; int? get deliveryOrderId; List<int> get deliveryOrderIds; String? get customerName; String? get shipToLabel; List<ItineraryLine> get lines;
/// Create a copy of ItineraryStop
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItineraryStopCopyWith<ItineraryStop> get copyWith => _$ItineraryStopCopyWithImpl<ItineraryStop>(this as ItineraryStop, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ItineraryStop;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItineraryStop&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.sequence, _this.sequence) || other.sequence == _this.sequence)&&(identical(other.outcome, _this.outcome) || other.outcome == _this.outcome)&&(identical(other.arrivedAt, _this.arrivedAt) || other.arrivedAt == _this.arrivedAt)&&(identical(other.proofId, _this.proofId) || other.proofId == _this.proofId)&&(identical(other.comment, _this.comment) || other.comment == _this.comment)&&(identical(other.deliveryOrderId, _this.deliveryOrderId) || other.deliveryOrderId == _this.deliveryOrderId)&&const DeepCollectionEquality().equals(other.deliveryOrderIds, _this.deliveryOrderIds)&&(identical(other.customerName, _this.customerName) || other.customerName == _this.customerName)&&(identical(other.shipToLabel, _this.shipToLabel) || other.shipToLabel == _this.shipToLabel)&&const DeepCollectionEquality().equals(other.lines, _this.lines));
}


@override
int get hashCode {
  final _this = this as ItineraryStop;
  return Object.hash(runtimeType,_this.id,_this.sequence,_this.outcome,_this.arrivedAt,_this.proofId,_this.comment,_this.deliveryOrderId,const DeepCollectionEquality().hash(_this.deliveryOrderIds),_this.customerName,_this.shipToLabel,const DeepCollectionEquality().hash(_this.lines));
}

@override
String toString() {
  final _this = this as ItineraryStop;
  return 'ItineraryStop(id: ${_this.id}, sequence: ${_this.sequence}, outcome: ${_this.outcome}, arrivedAt: ${_this.arrivedAt}, proofId: ${_this.proofId}, comment: ${_this.comment}, deliveryOrderId: ${_this.deliveryOrderId}, deliveryOrderIds: ${_this.deliveryOrderIds}, customerName: ${_this.customerName}, shipToLabel: ${_this.shipToLabel}, lines: ${_this.lines})';
}


}

/// @nodoc
abstract mixin class $ItineraryStopCopyWith<$Res>  {
  factory $ItineraryStopCopyWith(ItineraryStop value, $Res Function(ItineraryStop) _then) = _$ItineraryStopCopyWithImpl;
@useResult
$Res call({
 int id, int sequence, StopOutcome outcome, DateTime? arrivedAt, int? proofId, String? comment, int? deliveryOrderId, List<int> deliveryOrderIds, String? customerName, String? shipToLabel, List<ItineraryLine> lines
});




}
/// @nodoc
class _$ItineraryStopCopyWithImpl<$Res>
    implements $ItineraryStopCopyWith<$Res> {
  _$ItineraryStopCopyWithImpl(this._self, this._then);

  final ItineraryStop _self;
  final $Res Function(ItineraryStop) _then;

/// Create a copy of ItineraryStop
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sequence = null,Object? outcome = null,Object? arrivedAt = freezed,Object? proofId = freezed,Object? comment = freezed,Object? deliveryOrderId = freezed,Object? deliveryOrderIds = null,Object? customerName = freezed,Object? shipToLabel = freezed,Object? lines = null,}) {
  return _then(ItineraryStop(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,sequence: null == sequence ? _self.sequence : sequence // ignore: cast_nullable_to_non_nullable
as int,outcome: null == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as StopOutcome,arrivedAt: freezed == arrivedAt ? _self.arrivedAt : arrivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,proofId: freezed == proofId ? _self.proofId : proofId // ignore: cast_nullable_to_non_nullable
as int?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,deliveryOrderId: freezed == deliveryOrderId ? _self.deliveryOrderId : deliveryOrderId // ignore: cast_nullable_to_non_nullable
as int?,deliveryOrderIds: null == deliveryOrderIds ? _self.deliveryOrderIds : deliveryOrderIds // ignore: cast_nullable_to_non_nullable
as List<int>,customerName: freezed == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String?,shipToLabel: freezed == shipToLabel ? _self.shipToLabel : shipToLabel // ignore: cast_nullable_to_non_nullable
as String?,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<ItineraryLine>,
  ));
}

}


/// Adds pattern-matching-related methods to [ItineraryStop].
extension ItineraryStopPatterns on ItineraryStop {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItineraryStop value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItineraryStop() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItineraryStop value)  $default,){
final _that = this;
switch (_that) {
case _ItineraryStop():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItineraryStop value)?  $default,){
final _that = this;
switch (_that) {
case _ItineraryStop() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int sequence,  StopOutcome outcome,  DateTime? arrivedAt,  int? proofId,  String? comment,  int? deliveryOrderId,  List<int> deliveryOrderIds,  String? customerName,  String? shipToLabel,  List<ItineraryLine> lines)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItineraryStop() when $default != null:
return $default(_that.id,_that.sequence,_that.outcome,_that.arrivedAt,_that.proofId,_that.comment,_that.deliveryOrderId,_that.deliveryOrderIds,_that.customerName,_that.shipToLabel,_that.lines);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int sequence,  StopOutcome outcome,  DateTime? arrivedAt,  int? proofId,  String? comment,  int? deliveryOrderId,  List<int> deliveryOrderIds,  String? customerName,  String? shipToLabel,  List<ItineraryLine> lines)  $default,) {final _that = this;
switch (_that) {
case _ItineraryStop():
return $default(_that.id,_that.sequence,_that.outcome,_that.arrivedAt,_that.proofId,_that.comment,_that.deliveryOrderId,_that.deliveryOrderIds,_that.customerName,_that.shipToLabel,_that.lines);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int sequence,  StopOutcome outcome,  DateTime? arrivedAt,  int? proofId,  String? comment,  int? deliveryOrderId,  List<int> deliveryOrderIds,  String? customerName,  String? shipToLabel,  List<ItineraryLine> lines)?  $default,) {final _that = this;
switch (_that) {
case _ItineraryStop() when $default != null:
return $default(_that.id,_that.sequence,_that.outcome,_that.arrivedAt,_that.proofId,_that.comment,_that.deliveryOrderId,_that.deliveryOrderIds,_that.customerName,_that.shipToLabel,_that.lines);case _:
  return null;

}
}

}

/// @nodoc


class _ItineraryStop extends ItineraryStop {
  const _ItineraryStop({required this.id, required this.sequence, required this.outcome, this.arrivedAt, this.proofId, this.comment, this.deliveryOrderId,  List<int> deliveryOrderIds = const <int>[], this.customerName, this.shipToLabel,  List<ItineraryLine> lines = const <ItineraryLine>[]}): _deliveryOrderIds = deliveryOrderIds,_lines = lines,super._();
  

@override final  int id;
@override final  int sequence;
@override final  StopOutcome outcome;
/// Set by the server when the stop is closed.
@override final  DateTime? arrivedAt;
@override final  int? proofId;
@override final  String? comment;
@override final  int? deliveryOrderId;
 final  List<int> _deliveryOrderIds;
@override@JsonKey() List<int> get deliveryOrderIds {
  if (_deliveryOrderIds is EqualUnmodifiableListView) return _deliveryOrderIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_deliveryOrderIds);
}

@override final  String? customerName;
@override final  String? shipToLabel;
 final  List<ItineraryLine> _lines;
@override@JsonKey() List<ItineraryLine> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}


/// Create a copy of ItineraryStop
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItineraryStopCopyWith<_ItineraryStop> get copyWith => __$ItineraryStopCopyWithImpl<_ItineraryStop>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItineraryStop&&(identical(other.id, id) || other.id == id)&&(identical(other.sequence, sequence) || other.sequence == sequence)&&(identical(other.outcome, outcome) || other.outcome == outcome)&&(identical(other.arrivedAt, arrivedAt) || other.arrivedAt == arrivedAt)&&(identical(other.proofId, proofId) || other.proofId == proofId)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.deliveryOrderId, deliveryOrderId) || other.deliveryOrderId == deliveryOrderId)&&const DeepCollectionEquality().equals(other.deliveryOrderIds, _deliveryOrderIds)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.shipToLabel, shipToLabel) || other.shipToLabel == shipToLabel)&&const DeepCollectionEquality().equals(other.lines, _lines));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,sequence,outcome,arrivedAt,proofId,comment,deliveryOrderId,const DeepCollectionEquality().hash(_deliveryOrderIds),customerName,shipToLabel,const DeepCollectionEquality().hash(_lines));
}

@override
String toString() {
    return 'ItineraryStop(id: $id, sequence: $sequence, outcome: $outcome, arrivedAt: $arrivedAt, proofId: $proofId, comment: $comment, deliveryOrderId: $deliveryOrderId, deliveryOrderIds: $deliveryOrderIds, customerName: $customerName, shipToLabel: $shipToLabel, lines: $lines)';
}


}

/// @nodoc
abstract mixin class _$ItineraryStopCopyWith<$Res> implements $ItineraryStopCopyWith<$Res> {
  factory _$ItineraryStopCopyWith(_ItineraryStop value, $Res Function(_ItineraryStop) _then) = __$ItineraryStopCopyWithImpl;
@override @useResult
$Res call({
 int id, int sequence, StopOutcome outcome, DateTime? arrivedAt, int? proofId, String? comment, int? deliveryOrderId, List<int> deliveryOrderIds, String? customerName, String? shipToLabel, List<ItineraryLine> lines
});




}
/// @nodoc
class __$ItineraryStopCopyWithImpl<$Res>
    implements _$ItineraryStopCopyWith<$Res> {
  __$ItineraryStopCopyWithImpl(this._self, this._then);

  final _ItineraryStop _self;
  final $Res Function(_ItineraryStop) _then;

/// Create a copy of ItineraryStop
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sequence = null,Object? outcome = null,Object? arrivedAt = freezed,Object? proofId = freezed,Object? comment = freezed,Object? deliveryOrderId = freezed,Object? deliveryOrderIds = null,Object? customerName = freezed,Object? shipToLabel = freezed,Object? lines = null,}) {
  return _then(_ItineraryStop(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,sequence: null == sequence ? _self.sequence : sequence // ignore: cast_nullable_to_non_nullable
as int,outcome: null == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as StopOutcome,arrivedAt: freezed == arrivedAt ? _self.arrivedAt : arrivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,proofId: freezed == proofId ? _self.proofId : proofId // ignore: cast_nullable_to_non_nullable
as int?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,deliveryOrderId: freezed == deliveryOrderId ? _self.deliveryOrderId : deliveryOrderId // ignore: cast_nullable_to_non_nullable
as int?,deliveryOrderIds: null == deliveryOrderIds ? _self._deliveryOrderIds : deliveryOrderIds // ignore: cast_nullable_to_non_nullable
as List<int>,customerName: freezed == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String?,shipToLabel: freezed == shipToLabel ? _self.shipToLabel : shipToLabel // ignore: cast_nullable_to_non_nullable
as String?,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<ItineraryLine>,
  ));
}


}

/// @nodoc
mixin _$ItineraryLine {

 int get id; int get deliveryOrderLineId; int get deliveryOrderId; String get productCode; String get productName; String? get unitSymbol; Decimal get committed; Decimal get sent; Decimal get delivered; Decimal get returned; ShortfallReason? get reason; String? get comment;
/// Create a copy of ItineraryLine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItineraryLineCopyWith<ItineraryLine> get copyWith => _$ItineraryLineCopyWithImpl<ItineraryLine>(this as ItineraryLine, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ItineraryLine;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItineraryLine&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.deliveryOrderLineId, _this.deliveryOrderLineId) || other.deliveryOrderLineId == _this.deliveryOrderLineId)&&(identical(other.deliveryOrderId, _this.deliveryOrderId) || other.deliveryOrderId == _this.deliveryOrderId)&&(identical(other.productCode, _this.productCode) || other.productCode == _this.productCode)&&(identical(other.productName, _this.productName) || other.productName == _this.productName)&&(identical(other.unitSymbol, _this.unitSymbol) || other.unitSymbol == _this.unitSymbol)&&(identical(other.committed, _this.committed) || other.committed == _this.committed)&&(identical(other.sent, _this.sent) || other.sent == _this.sent)&&(identical(other.delivered, _this.delivered) || other.delivered == _this.delivered)&&(identical(other.returned, _this.returned) || other.returned == _this.returned)&&(identical(other.reason, _this.reason) || other.reason == _this.reason)&&(identical(other.comment, _this.comment) || other.comment == _this.comment));
}


@override
int get hashCode {
  final _this = this as ItineraryLine;
  return Object.hash(runtimeType,_this.id,_this.deliveryOrderLineId,_this.deliveryOrderId,_this.productCode,_this.productName,_this.unitSymbol,_this.committed,_this.sent,_this.delivered,_this.returned,_this.reason,_this.comment);
}

@override
String toString() {
  final _this = this as ItineraryLine;
  return 'ItineraryLine(id: ${_this.id}, deliveryOrderLineId: ${_this.deliveryOrderLineId}, deliveryOrderId: ${_this.deliveryOrderId}, productCode: ${_this.productCode}, productName: ${_this.productName}, unitSymbol: ${_this.unitSymbol}, committed: ${_this.committed}, sent: ${_this.sent}, delivered: ${_this.delivered}, returned: ${_this.returned}, reason: ${_this.reason}, comment: ${_this.comment})';
}


}

/// @nodoc
abstract mixin class $ItineraryLineCopyWith<$Res>  {
  factory $ItineraryLineCopyWith(ItineraryLine value, $Res Function(ItineraryLine) _then) = _$ItineraryLineCopyWithImpl;
@useResult
$Res call({
 int id, int deliveryOrderLineId, int deliveryOrderId, String productCode, String productName, String? unitSymbol, Decimal committed, Decimal sent, Decimal delivered, Decimal returned, ShortfallReason? reason, String? comment
});




}
/// @nodoc
class _$ItineraryLineCopyWithImpl<$Res>
    implements $ItineraryLineCopyWith<$Res> {
  _$ItineraryLineCopyWithImpl(this._self, this._then);

  final ItineraryLine _self;
  final $Res Function(ItineraryLine) _then;

/// Create a copy of ItineraryLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? deliveryOrderLineId = null,Object? deliveryOrderId = null,Object? productCode = null,Object? productName = null,Object? unitSymbol = freezed,Object? committed = null,Object? sent = null,Object? delivered = null,Object? returned = null,Object? reason = freezed,Object? comment = freezed,}) {
  return _then(ItineraryLine(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,deliveryOrderLineId: null == deliveryOrderLineId ? _self.deliveryOrderLineId : deliveryOrderLineId // ignore: cast_nullable_to_non_nullable
as int,deliveryOrderId: null == deliveryOrderId ? _self.deliveryOrderId : deliveryOrderId // ignore: cast_nullable_to_non_nullable
as int,productCode: null == productCode ? _self.productCode : productCode // ignore: cast_nullable_to_non_nullable
as String,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,unitSymbol: freezed == unitSymbol ? _self.unitSymbol : unitSymbol // ignore: cast_nullable_to_non_nullable
as String?,committed: null == committed ? _self.committed : committed // ignore: cast_nullable_to_non_nullable
as Decimal,sent: null == sent ? _self.sent : sent // ignore: cast_nullable_to_non_nullable
as Decimal,delivered: null == delivered ? _self.delivered : delivered // ignore: cast_nullable_to_non_nullable
as Decimal,returned: null == returned ? _self.returned : returned // ignore: cast_nullable_to_non_nullable
as Decimal,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as ShortfallReason?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ItineraryLine].
extension ItineraryLinePatterns on ItineraryLine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItineraryLine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItineraryLine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItineraryLine value)  $default,){
final _that = this;
switch (_that) {
case _ItineraryLine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItineraryLine value)?  $default,){
final _that = this;
switch (_that) {
case _ItineraryLine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int deliveryOrderLineId,  int deliveryOrderId,  String productCode,  String productName,  String? unitSymbol,  Decimal committed,  Decimal sent,  Decimal delivered,  Decimal returned,  ShortfallReason? reason,  String? comment)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItineraryLine() when $default != null:
return $default(_that.id,_that.deliveryOrderLineId,_that.deliveryOrderId,_that.productCode,_that.productName,_that.unitSymbol,_that.committed,_that.sent,_that.delivered,_that.returned,_that.reason,_that.comment);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int deliveryOrderLineId,  int deliveryOrderId,  String productCode,  String productName,  String? unitSymbol,  Decimal committed,  Decimal sent,  Decimal delivered,  Decimal returned,  ShortfallReason? reason,  String? comment)  $default,) {final _that = this;
switch (_that) {
case _ItineraryLine():
return $default(_that.id,_that.deliveryOrderLineId,_that.deliveryOrderId,_that.productCode,_that.productName,_that.unitSymbol,_that.committed,_that.sent,_that.delivered,_that.returned,_that.reason,_that.comment);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int deliveryOrderLineId,  int deliveryOrderId,  String productCode,  String productName,  String? unitSymbol,  Decimal committed,  Decimal sent,  Decimal delivered,  Decimal returned,  ShortfallReason? reason,  String? comment)?  $default,) {final _that = this;
switch (_that) {
case _ItineraryLine() when $default != null:
return $default(_that.id,_that.deliveryOrderLineId,_that.deliveryOrderId,_that.productCode,_that.productName,_that.unitSymbol,_that.committed,_that.sent,_that.delivered,_that.returned,_that.reason,_that.comment);case _:
  return null;

}
}

}

/// @nodoc


class _ItineraryLine implements ItineraryLine {
  const _ItineraryLine({required this.id, required this.deliveryOrderLineId, required this.deliveryOrderId, required this.productCode, required this.productName, this.unitSymbol, required this.committed, required this.sent, required this.delivered, required this.returned, this.reason, this.comment});
  

@override final  int id;
@override final  int deliveryOrderLineId;
@override final  int deliveryOrderId;
@override final  String productCode;
@override final  String productName;
@override final  String? unitSymbol;
@override final  Decimal committed;
@override final  Decimal sent;
@override final  Decimal delivered;
@override final  Decimal returned;
@override final  ShortfallReason? reason;
@override final  String? comment;

/// Create a copy of ItineraryLine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItineraryLineCopyWith<_ItineraryLine> get copyWith => __$ItineraryLineCopyWithImpl<_ItineraryLine>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItineraryLine&&(identical(other.id, id) || other.id == id)&&(identical(other.deliveryOrderLineId, deliveryOrderLineId) || other.deliveryOrderLineId == deliveryOrderLineId)&&(identical(other.deliveryOrderId, deliveryOrderId) || other.deliveryOrderId == deliveryOrderId)&&(identical(other.productCode, productCode) || other.productCode == productCode)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.unitSymbol, unitSymbol) || other.unitSymbol == unitSymbol)&&(identical(other.committed, committed) || other.committed == committed)&&(identical(other.sent, sent) || other.sent == sent)&&(identical(other.delivered, delivered) || other.delivered == delivered)&&(identical(other.returned, returned) || other.returned == returned)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.comment, comment) || other.comment == comment));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,deliveryOrderLineId,deliveryOrderId,productCode,productName,unitSymbol,committed,sent,delivered,returned,reason,comment);
}

@override
String toString() {
    return 'ItineraryLine(id: $id, deliveryOrderLineId: $deliveryOrderLineId, deliveryOrderId: $deliveryOrderId, productCode: $productCode, productName: $productName, unitSymbol: $unitSymbol, committed: $committed, sent: $sent, delivered: $delivered, returned: $returned, reason: $reason, comment: $comment)';
}


}

/// @nodoc
abstract mixin class _$ItineraryLineCopyWith<$Res> implements $ItineraryLineCopyWith<$Res> {
  factory _$ItineraryLineCopyWith(_ItineraryLine value, $Res Function(_ItineraryLine) _then) = __$ItineraryLineCopyWithImpl;
@override @useResult
$Res call({
 int id, int deliveryOrderLineId, int deliveryOrderId, String productCode, String productName, String? unitSymbol, Decimal committed, Decimal sent, Decimal delivered, Decimal returned, ShortfallReason? reason, String? comment
});




}
/// @nodoc
class __$ItineraryLineCopyWithImpl<$Res>
    implements _$ItineraryLineCopyWith<$Res> {
  __$ItineraryLineCopyWithImpl(this._self, this._then);

  final _ItineraryLine _self;
  final $Res Function(_ItineraryLine) _then;

/// Create a copy of ItineraryLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? deliveryOrderLineId = null,Object? deliveryOrderId = null,Object? productCode = null,Object? productName = null,Object? unitSymbol = freezed,Object? committed = null,Object? sent = null,Object? delivered = null,Object? returned = null,Object? reason = freezed,Object? comment = freezed,}) {
  return _then(_ItineraryLine(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,deliveryOrderLineId: null == deliveryOrderLineId ? _self.deliveryOrderLineId : deliveryOrderLineId // ignore: cast_nullable_to_non_nullable
as int,deliveryOrderId: null == deliveryOrderId ? _self.deliveryOrderId : deliveryOrderId // ignore: cast_nullable_to_non_nullable
as int,productCode: null == productCode ? _self.productCode : productCode // ignore: cast_nullable_to_non_nullable
as String,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,unitSymbol: freezed == unitSymbol ? _self.unitSymbol : unitSymbol // ignore: cast_nullable_to_non_nullable
as String?,committed: null == committed ? _self.committed : committed // ignore: cast_nullable_to_non_nullable
as Decimal,sent: null == sent ? _self.sent : sent // ignore: cast_nullable_to_non_nullable
as Decimal,delivered: null == delivered ? _self.delivered : delivered // ignore: cast_nullable_to_non_nullable
as Decimal,returned: null == returned ? _self.returned : returned // ignore: cast_nullable_to_non_nullable
as Decimal,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as ShortfallReason?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
