// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pricing_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PricingState {

 int? get productId; String? get productDisplayText; List<ProductPriceRow> get rows; bool get loading; AppError? get error;
/// Create a copy of PricingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PricingStateCopyWith<PricingState> get copyWith => _$PricingStateCopyWithImpl<PricingState>(this as PricingState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PricingState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PricingState&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.productDisplayText, _this.productDisplayText) || other.productDisplayText == _this.productDisplayText)&&const DeepCollectionEquality().equals(other.rows, _this.rows)&&(identical(other.loading, _this.loading) || other.loading == _this.loading)&&(identical(other.error, _this.error) || other.error == _this.error));
}


@override
int get hashCode {
  final _this = this as PricingState;
  return Object.hash(runtimeType,_this.productId,_this.productDisplayText,const DeepCollectionEquality().hash(_this.rows),_this.loading,_this.error);
}

@override
String toString() {
  final _this = this as PricingState;
  return 'PricingState(productId: ${_this.productId}, productDisplayText: ${_this.productDisplayText}, rows: ${_this.rows}, loading: ${_this.loading}, error: ${_this.error})';
}


}

/// @nodoc
abstract mixin class $PricingStateCopyWith<$Res>  {
  factory $PricingStateCopyWith(PricingState value, $Res Function(PricingState) _then) = _$PricingStateCopyWithImpl;
@useResult
$Res call({
 int? productId, String? productDisplayText, List<ProductPriceRow> rows, bool loading, AppError? error
});


$AppErrorCopyWith<$Res>? get error;

}
/// @nodoc
class _$PricingStateCopyWithImpl<$Res>
    implements $PricingStateCopyWith<$Res> {
  _$PricingStateCopyWithImpl(this._self, this._then);

  final PricingState _self;
  final $Res Function(PricingState) _then;

/// Create a copy of PricingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = freezed,Object? productDisplayText = freezed,Object? rows = null,Object? loading = null,Object? error = freezed,}) {
  return _then(PricingState(
productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int?,productDisplayText: freezed == productDisplayText ? _self.productDisplayText : productDisplayText // ignore: cast_nullable_to_non_nullable
as String?,rows: null == rows ? _self.rows : rows // ignore: cast_nullable_to_non_nullable
as List<ProductPriceRow>,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppError?,
  ));
}
/// Create a copy of PricingState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppErrorCopyWith<$Res>? get error {
    if (_self.error == null) {
    return null;
  }

  return $AppErrorCopyWith<$Res>(_self.error!, (value) {
    return _then(_self.copyWith(error: value));
  });
}
}


/// Adds pattern-matching-related methods to [PricingState].
extension PricingStatePatterns on PricingState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PricingState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PricingState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PricingState value)  $default,){
final _that = this;
switch (_that) {
case _PricingState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PricingState value)?  $default,){
final _that = this;
switch (_that) {
case _PricingState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? productId,  String? productDisplayText,  List<ProductPriceRow> rows,  bool loading,  AppError? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PricingState() when $default != null:
return $default(_that.productId,_that.productDisplayText,_that.rows,_that.loading,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? productId,  String? productDisplayText,  List<ProductPriceRow> rows,  bool loading,  AppError? error)  $default,) {final _that = this;
switch (_that) {
case _PricingState():
return $default(_that.productId,_that.productDisplayText,_that.rows,_that.loading,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? productId,  String? productDisplayText,  List<ProductPriceRow> rows,  bool loading,  AppError? error)?  $default,) {final _that = this;
switch (_that) {
case _PricingState() when $default != null:
return $default(_that.productId,_that.productDisplayText,_that.rows,_that.loading,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _PricingState implements PricingState {
  const _PricingState({this.productId, this.productDisplayText,  List<ProductPriceRow> rows = const <ProductPriceRow>[], this.loading = false, this.error}): _rows = rows;
  

@override final  int? productId;
@override final  String? productDisplayText;
 final  List<ProductPriceRow> _rows;
@override@JsonKey() List<ProductPriceRow> get rows {
  if (_rows is EqualUnmodifiableListView) return _rows;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rows);
}

@override@JsonKey() final  bool loading;
@override final  AppError? error;

/// Create a copy of PricingState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PricingStateCopyWith<_PricingState> get copyWith => __$PricingStateCopyWithImpl<_PricingState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PricingState&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productDisplayText, productDisplayText) || other.productDisplayText == productDisplayText)&&const DeepCollectionEquality().equals(other.rows, _rows)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode {
    return Object.hash(runtimeType,productId,productDisplayText,const DeepCollectionEquality().hash(_rows),loading,error);
}

@override
String toString() {
    return 'PricingState(productId: $productId, productDisplayText: $productDisplayText, rows: $rows, loading: $loading, error: $error)';
}


}

/// @nodoc
abstract mixin class _$PricingStateCopyWith<$Res> implements $PricingStateCopyWith<$Res> {
  factory _$PricingStateCopyWith(_PricingState value, $Res Function(_PricingState) _then) = __$PricingStateCopyWithImpl;
@override @useResult
$Res call({
 int? productId, String? productDisplayText, List<ProductPriceRow> rows, bool loading, AppError? error
});


@override $AppErrorCopyWith<$Res>? get error;

}
/// @nodoc
class __$PricingStateCopyWithImpl<$Res>
    implements _$PricingStateCopyWith<$Res> {
  __$PricingStateCopyWithImpl(this._self, this._then);

  final _PricingState _self;
  final $Res Function(_PricingState) _then;

/// Create a copy of PricingState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = freezed,Object? productDisplayText = freezed,Object? rows = null,Object? loading = null,Object? error = freezed,}) {
  return _then(_PricingState(
productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int?,productDisplayText: freezed == productDisplayText ? _self.productDisplayText : productDisplayText // ignore: cast_nullable_to_non_nullable
as String?,rows: null == rows ? _self._rows : rows // ignore: cast_nullable_to_non_nullable
as List<ProductPriceRow>,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppError?,
  ));
}

/// Create a copy of PricingState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppErrorCopyWith<$Res>? get error {
    if (_self.error == null) {
    return null;
  }

  return $AppErrorCopyWith<$Res>(_self.error!, (value) {
    return _then(_self.copyWith(error: value));
  });
}
}

/// @nodoc
mixin _$PricingRowEditState {

 String get price; bool get submitting; String? get error; Map<String, String>? get fieldErrors;
/// Create a copy of PricingRowEditState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PricingRowEditStateCopyWith<PricingRowEditState> get copyWith => _$PricingRowEditStateCopyWithImpl<PricingRowEditState>(this as PricingRowEditState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PricingRowEditState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PricingRowEditState&&(identical(other.price, _this.price) || other.price == _this.price)&&(identical(other.submitting, _this.submitting) || other.submitting == _this.submitting)&&(identical(other.error, _this.error) || other.error == _this.error)&&const DeepCollectionEquality().equals(other.fieldErrors, _this.fieldErrors));
}


@override
int get hashCode {
  final _this = this as PricingRowEditState;
  return Object.hash(runtimeType,_this.price,_this.submitting,_this.error,const DeepCollectionEquality().hash(_this.fieldErrors));
}

@override
String toString() {
  final _this = this as PricingRowEditState;
  return 'PricingRowEditState(price: ${_this.price}, submitting: ${_this.submitting}, error: ${_this.error}, fieldErrors: ${_this.fieldErrors})';
}


}

/// @nodoc
abstract mixin class $PricingRowEditStateCopyWith<$Res>  {
  factory $PricingRowEditStateCopyWith(PricingRowEditState value, $Res Function(PricingRowEditState) _then) = _$PricingRowEditStateCopyWithImpl;
@useResult
$Res call({
 String price, bool submitting, String? error, Map<String, String>? fieldErrors
});




}
/// @nodoc
class _$PricingRowEditStateCopyWithImpl<$Res>
    implements $PricingRowEditStateCopyWith<$Res> {
  _$PricingRowEditStateCopyWithImpl(this._self, this._then);

  final PricingRowEditState _self;
  final $Res Function(PricingRowEditState) _then;

/// Create a copy of PricingRowEditState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? price = null,Object? submitting = null,Object? error = freezed,Object? fieldErrors = freezed,}) {
  return _then(PricingRowEditState(
price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as String,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,fieldErrors: freezed == fieldErrors ? _self.fieldErrors : fieldErrors // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [PricingRowEditState].
extension PricingRowEditStatePatterns on PricingRowEditState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PricingRowEditState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PricingRowEditState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PricingRowEditState value)  $default,){
final _that = this;
switch (_that) {
case _PricingRowEditState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PricingRowEditState value)?  $default,){
final _that = this;
switch (_that) {
case _PricingRowEditState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String price,  bool submitting,  String? error,  Map<String, String>? fieldErrors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PricingRowEditState() when $default != null:
return $default(_that.price,_that.submitting,_that.error,_that.fieldErrors);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String price,  bool submitting,  String? error,  Map<String, String>? fieldErrors)  $default,) {final _that = this;
switch (_that) {
case _PricingRowEditState():
return $default(_that.price,_that.submitting,_that.error,_that.fieldErrors);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String price,  bool submitting,  String? error,  Map<String, String>? fieldErrors)?  $default,) {final _that = this;
switch (_that) {
case _PricingRowEditState() when $default != null:
return $default(_that.price,_that.submitting,_that.error,_that.fieldErrors);case _:
  return null;

}
}

}

/// @nodoc


class _PricingRowEditState implements PricingRowEditState {
  const _PricingRowEditState({this.price = '', this.submitting = false, this.error,  Map<String, String>? fieldErrors}): _fieldErrors = fieldErrors;
  

@override@JsonKey() final  String price;
@override@JsonKey() final  bool submitting;
@override final  String? error;
 final  Map<String, String>? _fieldErrors;
@override Map<String, String>? get fieldErrors {
  final value = _fieldErrors;
  if (value == null) return null;
  if (_fieldErrors is EqualUnmodifiableMapView) return _fieldErrors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of PricingRowEditState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PricingRowEditStateCopyWith<_PricingRowEditState> get copyWith => __$PricingRowEditStateCopyWithImpl<_PricingRowEditState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PricingRowEditState&&(identical(other.price, price) || other.price == price)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.error, error) || other.error == error)&&const DeepCollectionEquality().equals(other.fieldErrors, _fieldErrors));
}


@override
int get hashCode {
    return Object.hash(runtimeType,price,submitting,error,const DeepCollectionEquality().hash(_fieldErrors));
}

@override
String toString() {
    return 'PricingRowEditState(price: $price, submitting: $submitting, error: $error, fieldErrors: $fieldErrors)';
}


}

/// @nodoc
abstract mixin class _$PricingRowEditStateCopyWith<$Res> implements $PricingRowEditStateCopyWith<$Res> {
  factory _$PricingRowEditStateCopyWith(_PricingRowEditState value, $Res Function(_PricingRowEditState) _then) = __$PricingRowEditStateCopyWithImpl;
@override @useResult
$Res call({
 String price, bool submitting, String? error, Map<String, String>? fieldErrors
});




}
/// @nodoc
class __$PricingRowEditStateCopyWithImpl<$Res>
    implements _$PricingRowEditStateCopyWith<$Res> {
  __$PricingRowEditStateCopyWithImpl(this._self, this._then);

  final _PricingRowEditState _self;
  final $Res Function(_PricingRowEditState) _then;

/// Create a copy of PricingRowEditState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? price = null,Object? submitting = null,Object? error = freezed,Object? fieldErrors = freezed,}) {
  return _then(_PricingRowEditState(
price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as String,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,fieldErrors: freezed == fieldErrors ? _self._fieldErrors : fieldErrors // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,
  ));
}


}

// dart format on
