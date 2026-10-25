// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quote_email.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$QuoteEmailReceipt {

 List<String> get recipients; DateTime get sentAt;
/// Create a copy of QuoteEmailReceipt
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuoteEmailReceiptCopyWith<QuoteEmailReceipt> get copyWith => _$QuoteEmailReceiptCopyWithImpl<QuoteEmailReceipt>(this as QuoteEmailReceipt, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as QuoteEmailReceipt;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuoteEmailReceipt&&const DeepCollectionEquality().equals(other.recipients, _this.recipients)&&(identical(other.sentAt, _this.sentAt) || other.sentAt == _this.sentAt));
}


@override
int get hashCode {
  final _this = this as QuoteEmailReceipt;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.recipients),_this.sentAt);
}

@override
String toString() {
  final _this = this as QuoteEmailReceipt;
  return 'QuoteEmailReceipt(recipients: ${_this.recipients}, sentAt: ${_this.sentAt})';
}


}

/// @nodoc
abstract mixin class $QuoteEmailReceiptCopyWith<$Res>  {
  factory $QuoteEmailReceiptCopyWith(QuoteEmailReceipt value, $Res Function(QuoteEmailReceipt) _then) = _$QuoteEmailReceiptCopyWithImpl;
@useResult
$Res call({
 List<String> recipients, DateTime sentAt
});




}
/// @nodoc
class _$QuoteEmailReceiptCopyWithImpl<$Res>
    implements $QuoteEmailReceiptCopyWith<$Res> {
  _$QuoteEmailReceiptCopyWithImpl(this._self, this._then);

  final QuoteEmailReceipt _self;
  final $Res Function(QuoteEmailReceipt) _then;

/// Create a copy of QuoteEmailReceipt
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? recipients = null,Object? sentAt = null,}) {
  return _then(QuoteEmailReceipt(
recipients: null == recipients ? _self.recipients : recipients // ignore: cast_nullable_to_non_nullable
as List<String>,sentAt: null == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [QuoteEmailReceipt].
extension QuoteEmailReceiptPatterns on QuoteEmailReceipt {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QuoteEmailReceipt value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QuoteEmailReceipt() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QuoteEmailReceipt value)  $default,){
final _that = this;
switch (_that) {
case _QuoteEmailReceipt():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QuoteEmailReceipt value)?  $default,){
final _that = this;
switch (_that) {
case _QuoteEmailReceipt() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> recipients,  DateTime sentAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QuoteEmailReceipt() when $default != null:
return $default(_that.recipients,_that.sentAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> recipients,  DateTime sentAt)  $default,) {final _that = this;
switch (_that) {
case _QuoteEmailReceipt():
return $default(_that.recipients,_that.sentAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> recipients,  DateTime sentAt)?  $default,) {final _that = this;
switch (_that) {
case _QuoteEmailReceipt() when $default != null:
return $default(_that.recipients,_that.sentAt);case _:
  return null;

}
}

}

/// @nodoc


class _QuoteEmailReceipt implements QuoteEmailReceipt {
  const _QuoteEmailReceipt({required  List<String> recipients, required this.sentAt}): _recipients = recipients;
  

 final  List<String> _recipients;
@override List<String> get recipients {
  if (_recipients is EqualUnmodifiableListView) return _recipients;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recipients);
}

@override final  DateTime sentAt;

/// Create a copy of QuoteEmailReceipt
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuoteEmailReceiptCopyWith<_QuoteEmailReceipt> get copyWith => __$QuoteEmailReceiptCopyWithImpl<_QuoteEmailReceipt>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuoteEmailReceipt&&const DeepCollectionEquality().equals(other.recipients, _recipients)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_recipients),sentAt);
}

@override
String toString() {
    return 'QuoteEmailReceipt(recipients: $recipients, sentAt: $sentAt)';
}


}

/// @nodoc
abstract mixin class _$QuoteEmailReceiptCopyWith<$Res> implements $QuoteEmailReceiptCopyWith<$Res> {
  factory _$QuoteEmailReceiptCopyWith(_QuoteEmailReceipt value, $Res Function(_QuoteEmailReceipt) _then) = __$QuoteEmailReceiptCopyWithImpl;
@override @useResult
$Res call({
 List<String> recipients, DateTime sentAt
});




}
/// @nodoc
class __$QuoteEmailReceiptCopyWithImpl<$Res>
    implements _$QuoteEmailReceiptCopyWith<$Res> {
  __$QuoteEmailReceiptCopyWithImpl(this._self, this._then);

  final _QuoteEmailReceipt _self;
  final $Res Function(_QuoteEmailReceipt) _then;

/// Create a copy of QuoteEmailReceipt
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? recipients = null,Object? sentAt = null,}) {
  return _then(_QuoteEmailReceipt(
recipients: null == recipients ? _self._recipients : recipients // ignore: cast_nullable_to_non_nullable
as List<String>,sentAt: null == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
