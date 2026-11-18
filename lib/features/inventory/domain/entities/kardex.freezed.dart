// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'kardex.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Kardex {

 int get productId; int get warehouseId;/// Dates, as `DateTime` at midnight.
 DateTime get from; DateTime get to; Decimal get opening; List<KardexMovement> get movements; Decimal get totalIn; Decimal get totalOut; Decimal get closing;
/// Create a copy of Kardex
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KardexCopyWith<Kardex> get copyWith => _$KardexCopyWithImpl<Kardex>(this as Kardex, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Kardex;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Kardex&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.warehouseId, _this.warehouseId) || other.warehouseId == _this.warehouseId)&&(identical(other.from, _this.from) || other.from == _this.from)&&(identical(other.to, _this.to) || other.to == _this.to)&&(identical(other.opening, _this.opening) || other.opening == _this.opening)&&const DeepCollectionEquality().equals(other.movements, _this.movements)&&(identical(other.totalIn, _this.totalIn) || other.totalIn == _this.totalIn)&&(identical(other.totalOut, _this.totalOut) || other.totalOut == _this.totalOut)&&(identical(other.closing, _this.closing) || other.closing == _this.closing));
}


@override
int get hashCode {
  final _this = this as Kardex;
  return Object.hash(runtimeType,_this.productId,_this.warehouseId,_this.from,_this.to,_this.opening,const DeepCollectionEquality().hash(_this.movements),_this.totalIn,_this.totalOut,_this.closing);
}

@override
String toString() {
  final _this = this as Kardex;
  return 'Kardex(productId: ${_this.productId}, warehouseId: ${_this.warehouseId}, from: ${_this.from}, to: ${_this.to}, opening: ${_this.opening}, movements: ${_this.movements}, totalIn: ${_this.totalIn}, totalOut: ${_this.totalOut}, closing: ${_this.closing})';
}


}

/// @nodoc
abstract mixin class $KardexCopyWith<$Res>  {
  factory $KardexCopyWith(Kardex value, $Res Function(Kardex) _then) = _$KardexCopyWithImpl;
@useResult
$Res call({
 int productId, int warehouseId, DateTime from, DateTime to, Decimal opening, List<KardexMovement> movements, Decimal totalIn, Decimal totalOut, Decimal closing
});




}
/// @nodoc
class _$KardexCopyWithImpl<$Res>
    implements $KardexCopyWith<$Res> {
  _$KardexCopyWithImpl(this._self, this._then);

  final Kardex _self;
  final $Res Function(Kardex) _then;

/// Create a copy of Kardex
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? warehouseId = null,Object? from = null,Object? to = null,Object? opening = null,Object? movements = null,Object? totalIn = null,Object? totalOut = null,Object? closing = null,}) {
  return _then(Kardex(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,warehouseId: null == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int,from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime,opening: null == opening ? _self.opening : opening // ignore: cast_nullable_to_non_nullable
as Decimal,movements: null == movements ? _self.movements : movements // ignore: cast_nullable_to_non_nullable
as List<KardexMovement>,totalIn: null == totalIn ? _self.totalIn : totalIn // ignore: cast_nullable_to_non_nullable
as Decimal,totalOut: null == totalOut ? _self.totalOut : totalOut // ignore: cast_nullable_to_non_nullable
as Decimal,closing: null == closing ? _self.closing : closing // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}

}


/// Adds pattern-matching-related methods to [Kardex].
extension KardexPatterns on Kardex {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Kardex value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Kardex() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Kardex value)  $default,){
final _that = this;
switch (_that) {
case _Kardex():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Kardex value)?  $default,){
final _that = this;
switch (_that) {
case _Kardex() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int productId,  int warehouseId,  DateTime from,  DateTime to,  Decimal opening,  List<KardexMovement> movements,  Decimal totalIn,  Decimal totalOut,  Decimal closing)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Kardex() when $default != null:
return $default(_that.productId,_that.warehouseId,_that.from,_that.to,_that.opening,_that.movements,_that.totalIn,_that.totalOut,_that.closing);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int productId,  int warehouseId,  DateTime from,  DateTime to,  Decimal opening,  List<KardexMovement> movements,  Decimal totalIn,  Decimal totalOut,  Decimal closing)  $default,) {final _that = this;
switch (_that) {
case _Kardex():
return $default(_that.productId,_that.warehouseId,_that.from,_that.to,_that.opening,_that.movements,_that.totalIn,_that.totalOut,_that.closing);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int productId,  int warehouseId,  DateTime from,  DateTime to,  Decimal opening,  List<KardexMovement> movements,  Decimal totalIn,  Decimal totalOut,  Decimal closing)?  $default,) {final _that = this;
switch (_that) {
case _Kardex() when $default != null:
return $default(_that.productId,_that.warehouseId,_that.from,_that.to,_that.opening,_that.movements,_that.totalIn,_that.totalOut,_that.closing);case _:
  return null;

}
}

}

/// @nodoc


class _Kardex implements Kardex {
  const _Kardex({required this.productId, required this.warehouseId, required this.from, required this.to, required this.opening, required  List<KardexMovement> movements, required this.totalIn, required this.totalOut, required this.closing}): _movements = movements;
  

@override final  int productId;
@override final  int warehouseId;
/// Dates, as `DateTime` at midnight.
@override final  DateTime from;
@override final  DateTime to;
@override final  Decimal opening;
 final  List<KardexMovement> _movements;
@override List<KardexMovement> get movements {
  if (_movements is EqualUnmodifiableListView) return _movements;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_movements);
}

@override final  Decimal totalIn;
@override final  Decimal totalOut;
@override final  Decimal closing;

/// Create a copy of Kardex
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KardexCopyWith<_Kardex> get copyWith => __$KardexCopyWithImpl<_Kardex>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Kardex&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&(identical(other.opening, opening) || other.opening == opening)&&const DeepCollectionEquality().equals(other.movements, _movements)&&(identical(other.totalIn, totalIn) || other.totalIn == totalIn)&&(identical(other.totalOut, totalOut) || other.totalOut == totalOut)&&(identical(other.closing, closing) || other.closing == closing));
}


@override
int get hashCode {
    return Object.hash(runtimeType,productId,warehouseId,from,to,opening,const DeepCollectionEquality().hash(_movements),totalIn,totalOut,closing);
}

@override
String toString() {
    return 'Kardex(productId: $productId, warehouseId: $warehouseId, from: $from, to: $to, opening: $opening, movements: $movements, totalIn: $totalIn, totalOut: $totalOut, closing: $closing)';
}


}

/// @nodoc
abstract mixin class _$KardexCopyWith<$Res> implements $KardexCopyWith<$Res> {
  factory _$KardexCopyWith(_Kardex value, $Res Function(_Kardex) _then) = __$KardexCopyWithImpl;
@override @useResult
$Res call({
 int productId, int warehouseId, DateTime from, DateTime to, Decimal opening, List<KardexMovement> movements, Decimal totalIn, Decimal totalOut, Decimal closing
});




}
/// @nodoc
class __$KardexCopyWithImpl<$Res>
    implements _$KardexCopyWith<$Res> {
  __$KardexCopyWithImpl(this._self, this._then);

  final _Kardex _self;
  final $Res Function(_Kardex) _then;

/// Create a copy of Kardex
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? warehouseId = null,Object? from = null,Object? to = null,Object? opening = null,Object? movements = null,Object? totalIn = null,Object? totalOut = null,Object? closing = null,}) {
  return _then(_Kardex(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,warehouseId: null == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int,from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime,opening: null == opening ? _self.opening : opening // ignore: cast_nullable_to_non_nullable
as Decimal,movements: null == movements ? _self._movements : movements // ignore: cast_nullable_to_non_nullable
as List<KardexMovement>,totalIn: null == totalIn ? _self.totalIn : totalIn // ignore: cast_nullable_to_non_nullable
as Decimal,totalOut: null == totalOut ? _self.totalOut : totalOut // ignore: cast_nullable_to_non_nullable
as Decimal,closing: null == closing ? _self.closing : closing // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}


}

/// @nodoc
mixin _$KardexMovement {

 int get id;/// Wall-clock time (spec 043).
 DateTime get date;/// The transaction type number.
 int get sourceType;/// The source document's id; 0 means none.
 int get reference; Decimal get quantityIn; Decimal get quantityOut; Decimal get balance; KardexDocumentRef? get document;
/// Create a copy of KardexMovement
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KardexMovementCopyWith<KardexMovement> get copyWith => _$KardexMovementCopyWithImpl<KardexMovement>(this as KardexMovement, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as KardexMovement;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KardexMovement&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.sourceType, _this.sourceType) || other.sourceType == _this.sourceType)&&(identical(other.reference, _this.reference) || other.reference == _this.reference)&&(identical(other.quantityIn, _this.quantityIn) || other.quantityIn == _this.quantityIn)&&(identical(other.quantityOut, _this.quantityOut) || other.quantityOut == _this.quantityOut)&&(identical(other.balance, _this.balance) || other.balance == _this.balance)&&(identical(other.document, _this.document) || other.document == _this.document));
}


@override
int get hashCode {
  final _this = this as KardexMovement;
  return Object.hash(runtimeType,_this.id,_this.date,_this.sourceType,_this.reference,_this.quantityIn,_this.quantityOut,_this.balance,_this.document);
}

@override
String toString() {
  final _this = this as KardexMovement;
  return 'KardexMovement(id: ${_this.id}, date: ${_this.date}, sourceType: ${_this.sourceType}, reference: ${_this.reference}, quantityIn: ${_this.quantityIn}, quantityOut: ${_this.quantityOut}, balance: ${_this.balance}, document: ${_this.document})';
}


}

/// @nodoc
abstract mixin class $KardexMovementCopyWith<$Res>  {
  factory $KardexMovementCopyWith(KardexMovement value, $Res Function(KardexMovement) _then) = _$KardexMovementCopyWithImpl;
@useResult
$Res call({
 int id, DateTime date, int sourceType, int reference, Decimal quantityIn, Decimal quantityOut, Decimal balance, KardexDocumentRef? document
});


$KardexDocumentRefCopyWith<$Res>? get document;

}
/// @nodoc
class _$KardexMovementCopyWithImpl<$Res>
    implements $KardexMovementCopyWith<$Res> {
  _$KardexMovementCopyWithImpl(this._self, this._then);

  final KardexMovement _self;
  final $Res Function(KardexMovement) _then;

/// Create a copy of KardexMovement
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? date = null,Object? sourceType = null,Object? reference = null,Object? quantityIn = null,Object? quantityOut = null,Object? balance = null,Object? document = freezed,}) {
  return _then(KardexMovement(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,sourceType: null == sourceType ? _self.sourceType : sourceType // ignore: cast_nullable_to_non_nullable
as int,reference: null == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as int,quantityIn: null == quantityIn ? _self.quantityIn : quantityIn // ignore: cast_nullable_to_non_nullable
as Decimal,quantityOut: null == quantityOut ? _self.quantityOut : quantityOut // ignore: cast_nullable_to_non_nullable
as Decimal,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as Decimal,document: freezed == document ? _self.document : document // ignore: cast_nullable_to_non_nullable
as KardexDocumentRef?,
  ));
}
/// Create a copy of KardexMovement
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$KardexDocumentRefCopyWith<$Res>? get document {
    if (_self.document == null) {
    return null;
  }

  return $KardexDocumentRefCopyWith<$Res>(_self.document!, (value) {
    return _then(_self.copyWith(document: value));
  });
}
}


/// Adds pattern-matching-related methods to [KardexMovement].
extension KardexMovementPatterns on KardexMovement {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KardexMovement value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KardexMovement() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KardexMovement value)  $default,){
final _that = this;
switch (_that) {
case _KardexMovement():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KardexMovement value)?  $default,){
final _that = this;
switch (_that) {
case _KardexMovement() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  DateTime date,  int sourceType,  int reference,  Decimal quantityIn,  Decimal quantityOut,  Decimal balance,  KardexDocumentRef? document)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KardexMovement() when $default != null:
return $default(_that.id,_that.date,_that.sourceType,_that.reference,_that.quantityIn,_that.quantityOut,_that.balance,_that.document);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  DateTime date,  int sourceType,  int reference,  Decimal quantityIn,  Decimal quantityOut,  Decimal balance,  KardexDocumentRef? document)  $default,) {final _that = this;
switch (_that) {
case _KardexMovement():
return $default(_that.id,_that.date,_that.sourceType,_that.reference,_that.quantityIn,_that.quantityOut,_that.balance,_that.document);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  DateTime date,  int sourceType,  int reference,  Decimal quantityIn,  Decimal quantityOut,  Decimal balance,  KardexDocumentRef? document)?  $default,) {final _that = this;
switch (_that) {
case _KardexMovement() when $default != null:
return $default(_that.id,_that.date,_that.sourceType,_that.reference,_that.quantityIn,_that.quantityOut,_that.balance,_that.document);case _:
  return null;

}
}

}

/// @nodoc


class _KardexMovement implements KardexMovement {
  const _KardexMovement({required this.id, required this.date, required this.sourceType, required this.reference, required this.quantityIn, required this.quantityOut, required this.balance, this.document});
  

@override final  int id;
/// Wall-clock time (spec 043).
@override final  DateTime date;
/// The transaction type number.
@override final  int sourceType;
/// The source document's id; 0 means none.
@override final  int reference;
@override final  Decimal quantityIn;
@override final  Decimal quantityOut;
@override final  Decimal balance;
@override final  KardexDocumentRef? document;

/// Create a copy of KardexMovement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KardexMovementCopyWith<_KardexMovement> get copyWith => __$KardexMovementCopyWithImpl<_KardexMovement>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _KardexMovement&&(identical(other.id, id) || other.id == id)&&(identical(other.date, date) || other.date == date)&&(identical(other.sourceType, sourceType) || other.sourceType == sourceType)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.quantityIn, quantityIn) || other.quantityIn == quantityIn)&&(identical(other.quantityOut, quantityOut) || other.quantityOut == quantityOut)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.document, document) || other.document == document));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,date,sourceType,reference,quantityIn,quantityOut,balance,document);
}

@override
String toString() {
    return 'KardexMovement(id: $id, date: $date, sourceType: $sourceType, reference: $reference, quantityIn: $quantityIn, quantityOut: $quantityOut, balance: $balance, document: $document)';
}


}

/// @nodoc
abstract mixin class _$KardexMovementCopyWith<$Res> implements $KardexMovementCopyWith<$Res> {
  factory _$KardexMovementCopyWith(_KardexMovement value, $Res Function(_KardexMovement) _then) = __$KardexMovementCopyWithImpl;
@override @useResult
$Res call({
 int id, DateTime date, int sourceType, int reference, Decimal quantityIn, Decimal quantityOut, Decimal balance, KardexDocumentRef? document
});


@override $KardexDocumentRefCopyWith<$Res>? get document;

}
/// @nodoc
class __$KardexMovementCopyWithImpl<$Res>
    implements _$KardexMovementCopyWith<$Res> {
  __$KardexMovementCopyWithImpl(this._self, this._then);

  final _KardexMovement _self;
  final $Res Function(_KardexMovement) _then;

/// Create a copy of KardexMovement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? date = null,Object? sourceType = null,Object? reference = null,Object? quantityIn = null,Object? quantityOut = null,Object? balance = null,Object? document = freezed,}) {
  return _then(_KardexMovement(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,sourceType: null == sourceType ? _self.sourceType : sourceType // ignore: cast_nullable_to_non_nullable
as int,reference: null == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as int,quantityIn: null == quantityIn ? _self.quantityIn : quantityIn // ignore: cast_nullable_to_non_nullable
as Decimal,quantityOut: null == quantityOut ? _self.quantityOut : quantityOut // ignore: cast_nullable_to_non_nullable
as Decimal,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as Decimal,document: freezed == document ? _self.document : document // ignore: cast_nullable_to_non_nullable
as KardexDocumentRef?,
  ));
}

/// Create a copy of KardexMovement
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$KardexDocumentRefCopyWith<$Res>? get document {
    if (_self.document == null) {
    return null;
  }

  return $KardexDocumentRefCopyWith<$Res>(_self.document!, (value) {
    return _then(_self.copyWith(document: value));
  });
}
}

/// @nodoc
mixin _$KardexDocumentRef {

 int get type; int get id; int? get facilityId; int? get serial;
/// Create a copy of KardexDocumentRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KardexDocumentRefCopyWith<KardexDocumentRef> get copyWith => _$KardexDocumentRefCopyWithImpl<KardexDocumentRef>(this as KardexDocumentRef, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as KardexDocumentRef;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KardexDocumentRef&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.facilityId, _this.facilityId) || other.facilityId == _this.facilityId)&&(identical(other.serial, _this.serial) || other.serial == _this.serial));
}


@override
int get hashCode {
  final _this = this as KardexDocumentRef;
  return Object.hash(runtimeType,_this.type,_this.id,_this.facilityId,_this.serial);
}

@override
String toString() {
  final _this = this as KardexDocumentRef;
  return 'KardexDocumentRef(type: ${_this.type}, id: ${_this.id}, facilityId: ${_this.facilityId}, serial: ${_this.serial})';
}


}

/// @nodoc
abstract mixin class $KardexDocumentRefCopyWith<$Res>  {
  factory $KardexDocumentRefCopyWith(KardexDocumentRef value, $Res Function(KardexDocumentRef) _then) = _$KardexDocumentRefCopyWithImpl;
@useResult
$Res call({
 int type, int id, int? facilityId, int? serial
});




}
/// @nodoc
class _$KardexDocumentRefCopyWithImpl<$Res>
    implements $KardexDocumentRefCopyWith<$Res> {
  _$KardexDocumentRefCopyWithImpl(this._self, this._then);

  final KardexDocumentRef _self;
  final $Res Function(KardexDocumentRef) _then;

/// Create a copy of KardexDocumentRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? id = null,Object? facilityId = freezed,Object? serial = freezed,}) {
  return _then(KardexDocumentRef(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,facilityId: freezed == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int?,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [KardexDocumentRef].
extension KardexDocumentRefPatterns on KardexDocumentRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KardexDocumentRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KardexDocumentRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KardexDocumentRef value)  $default,){
final _that = this;
switch (_that) {
case _KardexDocumentRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KardexDocumentRef value)?  $default,){
final _that = this;
switch (_that) {
case _KardexDocumentRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int type,  int id,  int? facilityId,  int? serial)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KardexDocumentRef() when $default != null:
return $default(_that.type,_that.id,_that.facilityId,_that.serial);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int type,  int id,  int? facilityId,  int? serial)  $default,) {final _that = this;
switch (_that) {
case _KardexDocumentRef():
return $default(_that.type,_that.id,_that.facilityId,_that.serial);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int type,  int id,  int? facilityId,  int? serial)?  $default,) {final _that = this;
switch (_that) {
case _KardexDocumentRef() when $default != null:
return $default(_that.type,_that.id,_that.facilityId,_that.serial);case _:
  return null;

}
}

}

/// @nodoc


class _KardexDocumentRef implements KardexDocumentRef {
  const _KardexDocumentRef({required this.type, required this.id, this.facilityId, this.serial});
  

@override final  int type;
@override final  int id;
@override final  int? facilityId;
@override final  int? serial;

/// Create a copy of KardexDocumentRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KardexDocumentRefCopyWith<_KardexDocumentRef> get copyWith => __$KardexDocumentRefCopyWithImpl<_KardexDocumentRef>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _KardexDocumentRef&&(identical(other.type, type) || other.type == type)&&(identical(other.id, id) || other.id == id)&&(identical(other.facilityId, facilityId) || other.facilityId == facilityId)&&(identical(other.serial, serial) || other.serial == serial));
}


@override
int get hashCode {
    return Object.hash(runtimeType,type,id,facilityId,serial);
}

@override
String toString() {
    return 'KardexDocumentRef(type: $type, id: $id, facilityId: $facilityId, serial: $serial)';
}


}

/// @nodoc
abstract mixin class _$KardexDocumentRefCopyWith<$Res> implements $KardexDocumentRefCopyWith<$Res> {
  factory _$KardexDocumentRefCopyWith(_KardexDocumentRef value, $Res Function(_KardexDocumentRef) _then) = __$KardexDocumentRefCopyWithImpl;
@override @useResult
$Res call({
 int type, int id, int? facilityId, int? serial
});




}
/// @nodoc
class __$KardexDocumentRefCopyWithImpl<$Res>
    implements _$KardexDocumentRefCopyWith<$Res> {
  __$KardexDocumentRefCopyWithImpl(this._self, this._then);

  final _KardexDocumentRef _self;
  final $Res Function(_KardexDocumentRef) _then;

/// Create a copy of KardexDocumentRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? id = null,Object? facilityId = freezed,Object? serial = freezed,}) {
  return _then(_KardexDocumentRef(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,facilityId: freezed == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int?,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
