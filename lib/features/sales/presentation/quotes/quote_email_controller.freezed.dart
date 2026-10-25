// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quote_email_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RecipientChip {

/// Trimmed, in the case it was entered or stored.
 String get address;/// The contact's or fiscal recipient's name; `null` for a typed address.
 String? get owner; RecipientOrigin get origin;
/// Create a copy of RecipientChip
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecipientChipCopyWith<RecipientChip> get copyWith => _$RecipientChipCopyWithImpl<RecipientChip>(this as RecipientChip, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as RecipientChip;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecipientChip&&(identical(other.address, _this.address) || other.address == _this.address)&&(identical(other.owner, _this.owner) || other.owner == _this.owner)&&(identical(other.origin, _this.origin) || other.origin == _this.origin));
}


@override
int get hashCode {
  final _this = this as RecipientChip;
  return Object.hash(runtimeType,_this.address,_this.owner,_this.origin);
}

@override
String toString() {
  final _this = this as RecipientChip;
  return 'RecipientChip(address: ${_this.address}, owner: ${_this.owner}, origin: ${_this.origin})';
}


}

/// @nodoc
abstract mixin class $RecipientChipCopyWith<$Res>  {
  factory $RecipientChipCopyWith(RecipientChip value, $Res Function(RecipientChip) _then) = _$RecipientChipCopyWithImpl;
@useResult
$Res call({
 String address, String? owner, RecipientOrigin origin
});




}
/// @nodoc
class _$RecipientChipCopyWithImpl<$Res>
    implements $RecipientChipCopyWith<$Res> {
  _$RecipientChipCopyWithImpl(this._self, this._then);

  final RecipientChip _self;
  final $Res Function(RecipientChip) _then;

/// Create a copy of RecipientChip
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? address = null,Object? owner = freezed,Object? origin = null,}) {
  return _then(RecipientChip(
address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,owner: freezed == owner ? _self.owner : owner // ignore: cast_nullable_to_non_nullable
as String?,origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as RecipientOrigin,
  ));
}

}


/// Adds pattern-matching-related methods to [RecipientChip].
extension RecipientChipPatterns on RecipientChip {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecipientChip value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecipientChip() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecipientChip value)  $default,){
final _that = this;
switch (_that) {
case _RecipientChip():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecipientChip value)?  $default,){
final _that = this;
switch (_that) {
case _RecipientChip() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String address,  String? owner,  RecipientOrigin origin)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecipientChip() when $default != null:
return $default(_that.address,_that.owner,_that.origin);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String address,  String? owner,  RecipientOrigin origin)  $default,) {final _that = this;
switch (_that) {
case _RecipientChip():
return $default(_that.address,_that.owner,_that.origin);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String address,  String? owner,  RecipientOrigin origin)?  $default,) {final _that = this;
switch (_that) {
case _RecipientChip() when $default != null:
return $default(_that.address,_that.owner,_that.origin);case _:
  return null;

}
}

}

/// @nodoc


class _RecipientChip extends RecipientChip {
  const _RecipientChip({required this.address, required this.owner, required this.origin}): super._();
  

/// Trimmed, in the case it was entered or stored.
@override final  String address;
/// The contact's or fiscal recipient's name; `null` for a typed address.
@override final  String? owner;
@override final  RecipientOrigin origin;

/// Create a copy of RecipientChip
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecipientChipCopyWith<_RecipientChip> get copyWith => __$RecipientChipCopyWithImpl<_RecipientChip>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecipientChip&&(identical(other.address, address) || other.address == address)&&(identical(other.owner, owner) || other.owner == owner)&&(identical(other.origin, origin) || other.origin == origin));
}


@override
int get hashCode {
    return Object.hash(runtimeType,address,owner,origin);
}

@override
String toString() {
    return 'RecipientChip(address: $address, owner: $owner, origin: $origin)';
}


}

/// @nodoc
abstract mixin class _$RecipientChipCopyWith<$Res> implements $RecipientChipCopyWith<$Res> {
  factory _$RecipientChipCopyWith(_RecipientChip value, $Res Function(_RecipientChip) _then) = __$RecipientChipCopyWithImpl;
@override @useResult
$Res call({
 String address, String? owner, RecipientOrigin origin
});




}
/// @nodoc
class __$RecipientChipCopyWithImpl<$Res>
    implements _$RecipientChipCopyWith<$Res> {
  __$RecipientChipCopyWithImpl(this._self, this._then);

  final _RecipientChip _self;
  final $Res Function(_RecipientChip) _then;

/// Create a copy of RecipientChip
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? address = null,Object? owner = freezed,Object? origin = null,}) {
  return _then(_RecipientChip(
address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,owner: freezed == owner ? _self.owner : owner // ignore: cast_nullable_to_non_nullable
as String?,origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as RecipientOrigin,
  ));
}


}

/// @nodoc
mixin _$QuoteEmailState {

/// Contacts, then fiscal recipients, then typed addresses (FR-008).
 List<RecipientChip> get chips;/// The [RecipientChip.key]s the quote will go to — exactly the recipients.
 Set<String> get selected; bool get sending; QuoteEmailFailure? get failure;/// The error behind [failure], for the shared `ErrorBanner`.
 AppError? get failureError;/// Latches on a 409, so closing the dialog tells the screen to refresh
/// (FR-014).
 bool get sawNotSendable;
/// Create a copy of QuoteEmailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuoteEmailStateCopyWith<QuoteEmailState> get copyWith => _$QuoteEmailStateCopyWithImpl<QuoteEmailState>(this as QuoteEmailState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as QuoteEmailState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuoteEmailState&&const DeepCollectionEquality().equals(other.chips, _this.chips)&&const DeepCollectionEquality().equals(other.selected, _this.selected)&&(identical(other.sending, _this.sending) || other.sending == _this.sending)&&(identical(other.failure, _this.failure) || other.failure == _this.failure)&&(identical(other.failureError, _this.failureError) || other.failureError == _this.failureError)&&(identical(other.sawNotSendable, _this.sawNotSendable) || other.sawNotSendable == _this.sawNotSendable));
}


@override
int get hashCode {
  final _this = this as QuoteEmailState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.chips),const DeepCollectionEquality().hash(_this.selected),_this.sending,_this.failure,_this.failureError,_this.sawNotSendable);
}

@override
String toString() {
  final _this = this as QuoteEmailState;
  return 'QuoteEmailState(chips: ${_this.chips}, selected: ${_this.selected}, sending: ${_this.sending}, failure: ${_this.failure}, failureError: ${_this.failureError}, sawNotSendable: ${_this.sawNotSendable})';
}


}

/// @nodoc
abstract mixin class $QuoteEmailStateCopyWith<$Res>  {
  factory $QuoteEmailStateCopyWith(QuoteEmailState value, $Res Function(QuoteEmailState) _then) = _$QuoteEmailStateCopyWithImpl;
@useResult
$Res call({
 List<RecipientChip> chips, Set<String> selected, bool sending, QuoteEmailFailure? failure, AppError? failureError, bool sawNotSendable
});


$AppErrorCopyWith<$Res>? get failureError;

}
/// @nodoc
class _$QuoteEmailStateCopyWithImpl<$Res>
    implements $QuoteEmailStateCopyWith<$Res> {
  _$QuoteEmailStateCopyWithImpl(this._self, this._then);

  final QuoteEmailState _self;
  final $Res Function(QuoteEmailState) _then;

/// Create a copy of QuoteEmailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? chips = null,Object? selected = null,Object? sending = null,Object? failure = freezed,Object? failureError = freezed,Object? sawNotSendable = null,}) {
  return _then(QuoteEmailState(
chips: null == chips ? _self.chips : chips // ignore: cast_nullable_to_non_nullable
as List<RecipientChip>,selected: null == selected ? _self.selected : selected // ignore: cast_nullable_to_non_nullable
as Set<String>,sending: null == sending ? _self.sending : sending // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as QuoteEmailFailure?,failureError: freezed == failureError ? _self.failureError : failureError // ignore: cast_nullable_to_non_nullable
as AppError?,sawNotSendable: null == sawNotSendable ? _self.sawNotSendable : sawNotSendable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of QuoteEmailState
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


/// Adds pattern-matching-related methods to [QuoteEmailState].
extension QuoteEmailStatePatterns on QuoteEmailState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QuoteEmailState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QuoteEmailState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QuoteEmailState value)  $default,){
final _that = this;
switch (_that) {
case _QuoteEmailState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QuoteEmailState value)?  $default,){
final _that = this;
switch (_that) {
case _QuoteEmailState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<RecipientChip> chips,  Set<String> selected,  bool sending,  QuoteEmailFailure? failure,  AppError? failureError,  bool sawNotSendable)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QuoteEmailState() when $default != null:
return $default(_that.chips,_that.selected,_that.sending,_that.failure,_that.failureError,_that.sawNotSendable);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<RecipientChip> chips,  Set<String> selected,  bool sending,  QuoteEmailFailure? failure,  AppError? failureError,  bool sawNotSendable)  $default,) {final _that = this;
switch (_that) {
case _QuoteEmailState():
return $default(_that.chips,_that.selected,_that.sending,_that.failure,_that.failureError,_that.sawNotSendable);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<RecipientChip> chips,  Set<String> selected,  bool sending,  QuoteEmailFailure? failure,  AppError? failureError,  bool sawNotSendable)?  $default,) {final _that = this;
switch (_that) {
case _QuoteEmailState() when $default != null:
return $default(_that.chips,_that.selected,_that.sending,_that.failure,_that.failureError,_that.sawNotSendable);case _:
  return null;

}
}

}

/// @nodoc


class _QuoteEmailState extends QuoteEmailState {
  const _QuoteEmailState({ List<RecipientChip> chips = const <RecipientChip>[],  Set<String> selected = const <String>{}, this.sending = false, this.failure, this.failureError, this.sawNotSendable = false}): _chips = chips,_selected = selected,super._();
  

/// Contacts, then fiscal recipients, then typed addresses (FR-008).
 final  List<RecipientChip> _chips;
/// Contacts, then fiscal recipients, then typed addresses (FR-008).
@override@JsonKey() List<RecipientChip> get chips {
  if (_chips is EqualUnmodifiableListView) return _chips;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_chips);
}

/// The [RecipientChip.key]s the quote will go to — exactly the recipients.
 final  Set<String> _selected;
/// The [RecipientChip.key]s the quote will go to — exactly the recipients.
@override@JsonKey() Set<String> get selected {
  if (_selected is EqualUnmodifiableSetView) return _selected;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_selected);
}

@override@JsonKey() final  bool sending;
@override final  QuoteEmailFailure? failure;
/// The error behind [failure], for the shared `ErrorBanner`.
@override final  AppError? failureError;
/// Latches on a 409, so closing the dialog tells the screen to refresh
/// (FR-014).
@override@JsonKey() final  bool sawNotSendable;

/// Create a copy of QuoteEmailState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuoteEmailStateCopyWith<_QuoteEmailState> get copyWith => __$QuoteEmailStateCopyWithImpl<_QuoteEmailState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuoteEmailState&&const DeepCollectionEquality().equals(other.chips, _chips)&&const DeepCollectionEquality().equals(other.selected, _selected)&&(identical(other.sending, sending) || other.sending == sending)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.failureError, failureError) || other.failureError == failureError)&&(identical(other.sawNotSendable, sawNotSendable) || other.sawNotSendable == sawNotSendable));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_chips),const DeepCollectionEquality().hash(_selected),sending,failure,failureError,sawNotSendable);
}

@override
String toString() {
    return 'QuoteEmailState(chips: $chips, selected: $selected, sending: $sending, failure: $failure, failureError: $failureError, sawNotSendable: $sawNotSendable)';
}


}

/// @nodoc
abstract mixin class _$QuoteEmailStateCopyWith<$Res> implements $QuoteEmailStateCopyWith<$Res> {
  factory _$QuoteEmailStateCopyWith(_QuoteEmailState value, $Res Function(_QuoteEmailState) _then) = __$QuoteEmailStateCopyWithImpl;
@override @useResult
$Res call({
 List<RecipientChip> chips, Set<String> selected, bool sending, QuoteEmailFailure? failure, AppError? failureError, bool sawNotSendable
});


@override $AppErrorCopyWith<$Res>? get failureError;

}
/// @nodoc
class __$QuoteEmailStateCopyWithImpl<$Res>
    implements _$QuoteEmailStateCopyWith<$Res> {
  __$QuoteEmailStateCopyWithImpl(this._self, this._then);

  final _QuoteEmailState _self;
  final $Res Function(_QuoteEmailState) _then;

/// Create a copy of QuoteEmailState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? chips = null,Object? selected = null,Object? sending = null,Object? failure = freezed,Object? failureError = freezed,Object? sawNotSendable = null,}) {
  return _then(_QuoteEmailState(
chips: null == chips ? _self._chips : chips // ignore: cast_nullable_to_non_nullable
as List<RecipientChip>,selected: null == selected ? _self._selected : selected // ignore: cast_nullable_to_non_nullable
as Set<String>,sending: null == sending ? _self.sending : sending // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as QuoteEmailFailure?,failureError: freezed == failureError ? _self.failureError : failureError // ignore: cast_nullable_to_non_nullable
as AppError?,sawNotSendable: null == sawNotSendable ? _self.sawNotSendable : sawNotSendable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of QuoteEmailState
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
