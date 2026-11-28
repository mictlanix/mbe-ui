// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'purchase_order_email_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PurchaseOrderEmailState {

/// Supplier contacts first, then typed addresses.
 List<RecipientChip> get chips;/// The [RecipientChip.key]s the order will go to.
 Set<String> get selected; String get message; EmailSuggestions get suggestions; bool get sending; PurchaseOrderEmailFailure? get failure;/// The error behind [failure], for the banner.
 AppError? get failureError;/// Latches on `purchase_order.not_confirmed`, so closing the dialog tells
/// the detail screen to reload.
 bool get sawNotConfirmed;
/// Create a copy of PurchaseOrderEmailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PurchaseOrderEmailStateCopyWith<PurchaseOrderEmailState> get copyWith => _$PurchaseOrderEmailStateCopyWithImpl<PurchaseOrderEmailState>(this as PurchaseOrderEmailState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PurchaseOrderEmailState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PurchaseOrderEmailState&&const DeepCollectionEquality().equals(other.chips, _this.chips)&&const DeepCollectionEquality().equals(other.selected, _this.selected)&&(identical(other.message, _this.message) || other.message == _this.message)&&(identical(other.suggestions, _this.suggestions) || other.suggestions == _this.suggestions)&&(identical(other.sending, _this.sending) || other.sending == _this.sending)&&(identical(other.failure, _this.failure) || other.failure == _this.failure)&&(identical(other.failureError, _this.failureError) || other.failureError == _this.failureError)&&(identical(other.sawNotConfirmed, _this.sawNotConfirmed) || other.sawNotConfirmed == _this.sawNotConfirmed));
}


@override
int get hashCode {
  final _this = this as PurchaseOrderEmailState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.chips),const DeepCollectionEquality().hash(_this.selected),_this.message,_this.suggestions,_this.sending,_this.failure,_this.failureError,_this.sawNotConfirmed);
}

@override
String toString() {
  final _this = this as PurchaseOrderEmailState;
  return 'PurchaseOrderEmailState(chips: ${_this.chips}, selected: ${_this.selected}, message: ${_this.message}, suggestions: ${_this.suggestions}, sending: ${_this.sending}, failure: ${_this.failure}, failureError: ${_this.failureError}, sawNotConfirmed: ${_this.sawNotConfirmed})';
}


}

/// @nodoc
abstract mixin class $PurchaseOrderEmailStateCopyWith<$Res>  {
  factory $PurchaseOrderEmailStateCopyWith(PurchaseOrderEmailState value, $Res Function(PurchaseOrderEmailState) _then) = _$PurchaseOrderEmailStateCopyWithImpl;
@useResult
$Res call({
 List<RecipientChip> chips, Set<String> selected, String message, EmailSuggestions suggestions, bool sending, PurchaseOrderEmailFailure? failure, AppError? failureError, bool sawNotConfirmed
});


$AppErrorCopyWith<$Res>? get failureError;

}
/// @nodoc
class _$PurchaseOrderEmailStateCopyWithImpl<$Res>
    implements $PurchaseOrderEmailStateCopyWith<$Res> {
  _$PurchaseOrderEmailStateCopyWithImpl(this._self, this._then);

  final PurchaseOrderEmailState _self;
  final $Res Function(PurchaseOrderEmailState) _then;

/// Create a copy of PurchaseOrderEmailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? chips = null,Object? selected = null,Object? message = null,Object? suggestions = null,Object? sending = null,Object? failure = freezed,Object? failureError = freezed,Object? sawNotConfirmed = null,}) {
  return _then(PurchaseOrderEmailState(
chips: null == chips ? _self.chips : chips // ignore: cast_nullable_to_non_nullable
as List<RecipientChip>,selected: null == selected ? _self.selected : selected // ignore: cast_nullable_to_non_nullable
as Set<String>,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,suggestions: null == suggestions ? _self.suggestions : suggestions // ignore: cast_nullable_to_non_nullable
as EmailSuggestions,sending: null == sending ? _self.sending : sending // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as PurchaseOrderEmailFailure?,failureError: freezed == failureError ? _self.failureError : failureError // ignore: cast_nullable_to_non_nullable
as AppError?,sawNotConfirmed: null == sawNotConfirmed ? _self.sawNotConfirmed : sawNotConfirmed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of PurchaseOrderEmailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppErrorCopyWith<$Res>? get failureError {
    if (_self.failureError == null) {
    return null;
  }

  return $AppErrorCopyWith<$Res>(_self.failureError!, (value) {
    return _then(_self.copyWith(failureError: value));
  });
}
}


/// Adds pattern-matching-related methods to [PurchaseOrderEmailState].
extension PurchaseOrderEmailStatePatterns on PurchaseOrderEmailState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PurchaseOrderEmailState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PurchaseOrderEmailState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PurchaseOrderEmailState value)  $default,){
final _that = this;
switch (_that) {
case _PurchaseOrderEmailState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PurchaseOrderEmailState value)?  $default,){
final _that = this;
switch (_that) {
case _PurchaseOrderEmailState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<RecipientChip> chips,  Set<String> selected,  String message,  EmailSuggestions suggestions,  bool sending,  PurchaseOrderEmailFailure? failure,  AppError? failureError,  bool sawNotConfirmed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PurchaseOrderEmailState() when $default != null:
return $default(_that.chips,_that.selected,_that.message,_that.suggestions,_that.sending,_that.failure,_that.failureError,_that.sawNotConfirmed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<RecipientChip> chips,  Set<String> selected,  String message,  EmailSuggestions suggestions,  bool sending,  PurchaseOrderEmailFailure? failure,  AppError? failureError,  bool sawNotConfirmed)  $default,) {final _that = this;
switch (_that) {
case _PurchaseOrderEmailState():
return $default(_that.chips,_that.selected,_that.message,_that.suggestions,_that.sending,_that.failure,_that.failureError,_that.sawNotConfirmed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<RecipientChip> chips,  Set<String> selected,  String message,  EmailSuggestions suggestions,  bool sending,  PurchaseOrderEmailFailure? failure,  AppError? failureError,  bool sawNotConfirmed)?  $default,) {final _that = this;
switch (_that) {
case _PurchaseOrderEmailState() when $default != null:
return $default(_that.chips,_that.selected,_that.message,_that.suggestions,_that.sending,_that.failure,_that.failureError,_that.sawNotConfirmed);case _:
  return null;

}
}

}

/// @nodoc


class _PurchaseOrderEmailState extends PurchaseOrderEmailState {
  const _PurchaseOrderEmailState({ List<RecipientChip> chips = const <RecipientChip>[],  Set<String> selected = const <String>{}, this.message = '', this.suggestions = EmailSuggestions.none, this.sending = false, this.failure, this.failureError, this.sawNotConfirmed = false}): _chips = chips,_selected = selected,super._();
  

/// Supplier contacts first, then typed addresses.
 final  List<RecipientChip> _chips;
/// Supplier contacts first, then typed addresses.
@override@JsonKey() List<RecipientChip> get chips {
  if (_chips is EqualUnmodifiableListView) return _chips;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_chips);
}

/// The [RecipientChip.key]s the order will go to.
 final  Set<String> _selected;
/// The [RecipientChip.key]s the order will go to.
@override@JsonKey() Set<String> get selected {
  if (_selected is EqualUnmodifiableSetView) return _selected;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_selected);
}

@override@JsonKey() final  String message;
@override@JsonKey() final  EmailSuggestions suggestions;
@override@JsonKey() final  bool sending;
@override final  PurchaseOrderEmailFailure? failure;
/// The error behind [failure], for the banner.
@override final  AppError? failureError;
/// Latches on `purchase_order.not_confirmed`, so closing the dialog tells
/// the detail screen to reload.
@override@JsonKey() final  bool sawNotConfirmed;

/// Create a copy of PurchaseOrderEmailState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PurchaseOrderEmailStateCopyWith<_PurchaseOrderEmailState> get copyWith => __$PurchaseOrderEmailStateCopyWithImpl<_PurchaseOrderEmailState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PurchaseOrderEmailState&&const DeepCollectionEquality().equals(other.chips, _chips)&&const DeepCollectionEquality().equals(other.selected, _selected)&&(identical(other.message, message) || other.message == message)&&(identical(other.suggestions, suggestions) || other.suggestions == suggestions)&&(identical(other.sending, sending) || other.sending == sending)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.failureError, failureError) || other.failureError == failureError)&&(identical(other.sawNotConfirmed, sawNotConfirmed) || other.sawNotConfirmed == sawNotConfirmed));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_chips),const DeepCollectionEquality().hash(_selected),message,suggestions,sending,failure,failureError,sawNotConfirmed);
}

@override
String toString() {
    return 'PurchaseOrderEmailState(chips: $chips, selected: $selected, message: $message, suggestions: $suggestions, sending: $sending, failure: $failure, failureError: $failureError, sawNotConfirmed: $sawNotConfirmed)';
}


}

/// @nodoc
abstract mixin class _$PurchaseOrderEmailStateCopyWith<$Res> implements $PurchaseOrderEmailStateCopyWith<$Res> {
  factory _$PurchaseOrderEmailStateCopyWith(_PurchaseOrderEmailState value, $Res Function(_PurchaseOrderEmailState) _then) = __$PurchaseOrderEmailStateCopyWithImpl;
@override @useResult
$Res call({
 List<RecipientChip> chips, Set<String> selected, String message, EmailSuggestions suggestions, bool sending, PurchaseOrderEmailFailure? failure, AppError? failureError, bool sawNotConfirmed
});


@override $AppErrorCopyWith<$Res>? get failureError;

}
/// @nodoc
class __$PurchaseOrderEmailStateCopyWithImpl<$Res>
    implements _$PurchaseOrderEmailStateCopyWith<$Res> {
  __$PurchaseOrderEmailStateCopyWithImpl(this._self, this._then);

  final _PurchaseOrderEmailState _self;
  final $Res Function(_PurchaseOrderEmailState) _then;

/// Create a copy of PurchaseOrderEmailState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? chips = null,Object? selected = null,Object? message = null,Object? suggestions = null,Object? sending = null,Object? failure = freezed,Object? failureError = freezed,Object? sawNotConfirmed = null,}) {
  return _then(_PurchaseOrderEmailState(
chips: null == chips ? _self._chips : chips // ignore: cast_nullable_to_non_nullable
as List<RecipientChip>,selected: null == selected ? _self._selected : selected // ignore: cast_nullable_to_non_nullable
as Set<String>,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,suggestions: null == suggestions ? _self.suggestions : suggestions // ignore: cast_nullable_to_non_nullable
as EmailSuggestions,sending: null == sending ? _self.sending : sending // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as PurchaseOrderEmailFailure?,failureError: freezed == failureError ? _self.failureError : failureError // ignore: cast_nullable_to_non_nullable
as AppError?,sawNotConfirmed: null == sawNotConfirmed ? _self.sawNotConfirmed : sawNotConfirmed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of PurchaseOrderEmailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppErrorCopyWith<$Res>? get failureError {
    if (_self.failureError == null) {
    return null;
  }

  return $AppErrorCopyWith<$Res>(_self.failureError!, (value) {
    return _then(_self.copyWith(failureError: value));
  });
}
}

// dart format on
