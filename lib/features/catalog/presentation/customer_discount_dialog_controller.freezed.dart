// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'customer_discount_dialog_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CustomerDiscountDialogState {

/// The product picked in add mode. Edit mode never changes the product.
 ProductListItem? get product;/// The field text, as a percentage.
 String get percent;/// `false` until the user edits the field, so a blank new dialog doesn't
/// open already showing an error, and so an untouched edit sends the
/// stored rate back exactly as it was.
 bool get percentDirty; bool get submitting; bool get done; String? get error; String? get errorDetail; Map<String, String> get fieldErrors;
/// Create a copy of CustomerDiscountDialogState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomerDiscountDialogStateCopyWith<CustomerDiscountDialogState> get copyWith => _$CustomerDiscountDialogStateCopyWithImpl<CustomerDiscountDialogState>(this as CustomerDiscountDialogState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CustomerDiscountDialogState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomerDiscountDialogState&&(identical(other.product, _this.product) || other.product == _this.product)&&(identical(other.percent, _this.percent) || other.percent == _this.percent)&&(identical(other.percentDirty, _this.percentDirty) || other.percentDirty == _this.percentDirty)&&(identical(other.submitting, _this.submitting) || other.submitting == _this.submitting)&&(identical(other.done, _this.done) || other.done == _this.done)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.errorDetail, _this.errorDetail) || other.errorDetail == _this.errorDetail)&&const DeepCollectionEquality().equals(other.fieldErrors, _this.fieldErrors));
}


@override
int get hashCode {
  final _this = this as CustomerDiscountDialogState;
  return Object.hash(runtimeType,_this.product,_this.percent,_this.percentDirty,_this.submitting,_this.done,_this.error,_this.errorDetail,const DeepCollectionEquality().hash(_this.fieldErrors));
}

@override
String toString() {
  final _this = this as CustomerDiscountDialogState;
  return 'CustomerDiscountDialogState(product: ${_this.product}, percent: ${_this.percent}, percentDirty: ${_this.percentDirty}, submitting: ${_this.submitting}, done: ${_this.done}, error: ${_this.error}, errorDetail: ${_this.errorDetail}, fieldErrors: ${_this.fieldErrors})';
}


}

/// @nodoc
abstract mixin class $CustomerDiscountDialogStateCopyWith<$Res>  {
  factory $CustomerDiscountDialogStateCopyWith(CustomerDiscountDialogState value, $Res Function(CustomerDiscountDialogState) _then) = _$CustomerDiscountDialogStateCopyWithImpl;
@useResult
$Res call({
 ProductListItem? product, String percent, bool percentDirty, bool submitting, bool done, String? error, String? errorDetail, Map<String, String> fieldErrors
});


$ProductListItemCopyWith<$Res>? get product;

}
/// @nodoc
class _$CustomerDiscountDialogStateCopyWithImpl<$Res>
    implements $CustomerDiscountDialogStateCopyWith<$Res> {
  _$CustomerDiscountDialogStateCopyWithImpl(this._self, this._then);

  final CustomerDiscountDialogState _self;
  final $Res Function(CustomerDiscountDialogState) _then;

/// Create a copy of CustomerDiscountDialogState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? product = freezed,Object? percent = null,Object? percentDirty = null,Object? submitting = null,Object? done = null,Object? error = freezed,Object? errorDetail = freezed,Object? fieldErrors = null,}) {
  return _then(CustomerDiscountDialogState(
product: freezed == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as ProductListItem?,percent: null == percent ? _self.percent : percent // ignore: cast_nullable_to_non_nullable
as String,percentDirty: null == percentDirty ? _self.percentDirty : percentDirty // ignore: cast_nullable_to_non_nullable
as bool,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,done: null == done ? _self.done : done // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,errorDetail: freezed == errorDetail ? _self.errorDetail : errorDetail // ignore: cast_nullable_to_non_nullable
as String?,fieldErrors: null == fieldErrors ? _self.fieldErrors : fieldErrors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}
/// Create a copy of CustomerDiscountDialogState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductListItemCopyWith<$Res>? get product {
    if (_self.product == null) {
    return null;
  }

  return $ProductListItemCopyWith<$Res>(_self.product!, (value) {
    return _then(_self.copyWith(product: value));
  });
}
}


/// Adds pattern-matching-related methods to [CustomerDiscountDialogState].
extension CustomerDiscountDialogStatePatterns on CustomerDiscountDialogState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CustomerDiscountDialogState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CustomerDiscountDialogState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CustomerDiscountDialogState value)  $default,){
final _that = this;
switch (_that) {
case _CustomerDiscountDialogState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CustomerDiscountDialogState value)?  $default,){
final _that = this;
switch (_that) {
case _CustomerDiscountDialogState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ProductListItem? product,  String percent,  bool percentDirty,  bool submitting,  bool done,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CustomerDiscountDialogState() when $default != null:
return $default(_that.product,_that.percent,_that.percentDirty,_that.submitting,_that.done,_that.error,_that.errorDetail,_that.fieldErrors);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ProductListItem? product,  String percent,  bool percentDirty,  bool submitting,  bool done,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)  $default,) {final _that = this;
switch (_that) {
case _CustomerDiscountDialogState():
return $default(_that.product,_that.percent,_that.percentDirty,_that.submitting,_that.done,_that.error,_that.errorDetail,_that.fieldErrors);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ProductListItem? product,  String percent,  bool percentDirty,  bool submitting,  bool done,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)?  $default,) {final _that = this;
switch (_that) {
case _CustomerDiscountDialogState() when $default != null:
return $default(_that.product,_that.percent,_that.percentDirty,_that.submitting,_that.done,_that.error,_that.errorDetail,_that.fieldErrors);case _:
  return null;

}
}

}

/// @nodoc


class _CustomerDiscountDialogState extends CustomerDiscountDialogState {
  const _CustomerDiscountDialogState({this.product, this.percent = '', this.percentDirty = false, this.submitting = false, this.done = false, this.error, this.errorDetail,  Map<String, String> fieldErrors = const <String, String>{}}): _fieldErrors = fieldErrors,super._();
  

/// The product picked in add mode. Edit mode never changes the product.
@override final  ProductListItem? product;
/// The field text, as a percentage.
@override@JsonKey() final  String percent;
/// `false` until the user edits the field, so a blank new dialog doesn't
/// open already showing an error, and so an untouched edit sends the
/// stored rate back exactly as it was.
@override@JsonKey() final  bool percentDirty;
@override@JsonKey() final  bool submitting;
@override@JsonKey() final  bool done;
@override final  String? error;
@override final  String? errorDetail;
 final  Map<String, String> _fieldErrors;
@override@JsonKey() Map<String, String> get fieldErrors {
  if (_fieldErrors is EqualUnmodifiableMapView) return _fieldErrors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_fieldErrors);
}


/// Create a copy of CustomerDiscountDialogState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomerDiscountDialogStateCopyWith<_CustomerDiscountDialogState> get copyWith => __$CustomerDiscountDialogStateCopyWithImpl<_CustomerDiscountDialogState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CustomerDiscountDialogState&&(identical(other.product, product) || other.product == product)&&(identical(other.percent, percent) || other.percent == percent)&&(identical(other.percentDirty, percentDirty) || other.percentDirty == percentDirty)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.done, done) || other.done == done)&&(identical(other.error, error) || other.error == error)&&(identical(other.errorDetail, errorDetail) || other.errorDetail == errorDetail)&&const DeepCollectionEquality().equals(other.fieldErrors, _fieldErrors));
}


@override
int get hashCode {
    return Object.hash(runtimeType,product,percent,percentDirty,submitting,done,error,errorDetail,const DeepCollectionEquality().hash(_fieldErrors));
}

@override
String toString() {
    return 'CustomerDiscountDialogState(product: $product, percent: $percent, percentDirty: $percentDirty, submitting: $submitting, done: $done, error: $error, errorDetail: $errorDetail, fieldErrors: $fieldErrors)';
}


}

/// @nodoc
abstract mixin class _$CustomerDiscountDialogStateCopyWith<$Res> implements $CustomerDiscountDialogStateCopyWith<$Res> {
  factory _$CustomerDiscountDialogStateCopyWith(_CustomerDiscountDialogState value, $Res Function(_CustomerDiscountDialogState) _then) = __$CustomerDiscountDialogStateCopyWithImpl;
@override @useResult
$Res call({
 ProductListItem? product, String percent, bool percentDirty, bool submitting, bool done, String? error, String? errorDetail, Map<String, String> fieldErrors
});


@override $ProductListItemCopyWith<$Res>? get product;

}
/// @nodoc
class __$CustomerDiscountDialogStateCopyWithImpl<$Res>
    implements _$CustomerDiscountDialogStateCopyWith<$Res> {
  __$CustomerDiscountDialogStateCopyWithImpl(this._self, this._then);

  final _CustomerDiscountDialogState _self;
  final $Res Function(_CustomerDiscountDialogState) _then;

/// Create a copy of CustomerDiscountDialogState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? product = freezed,Object? percent = null,Object? percentDirty = null,Object? submitting = null,Object? done = null,Object? error = freezed,Object? errorDetail = freezed,Object? fieldErrors = null,}) {
  return _then(_CustomerDiscountDialogState(
product: freezed == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as ProductListItem?,percent: null == percent ? _self.percent : percent // ignore: cast_nullable_to_non_nullable
as String,percentDirty: null == percentDirty ? _self.percentDirty : percentDirty // ignore: cast_nullable_to_non_nullable
as bool,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,done: null == done ? _self.done : done // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,errorDetail: freezed == errorDetail ? _self.errorDetail : errorDetail // ignore: cast_nullable_to_non_nullable
as String?,fieldErrors: null == fieldErrors ? _self._fieldErrors : fieldErrors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

/// Create a copy of CustomerDiscountDialogState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductListItemCopyWith<$Res>? get product {
    if (_self.product == null) {
    return null;
  }

  return $ProductListItemCopyWith<$Res>(_self.product!, (value) {
    return _then(_self.copyWith(product: value));
  });
}
}

// dart format on
