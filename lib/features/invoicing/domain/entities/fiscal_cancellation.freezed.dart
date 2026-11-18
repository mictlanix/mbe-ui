// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fiscal_cancellation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FiscalCancellation {

 int get id; String get reason; String? get substitution; CancellationOutcome get outcome;/// The status string as the server sent it, shown when [outcome] is
/// [CancellationOutcome.unknown].
 String get rawOutcome; String? get pacCode; String? get pacMessage; int get requestedBy; DateTime get requestedAt; DateTime? get answeredAt; DateTime? get resolvedAt;
/// Create a copy of FiscalCancellation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FiscalCancellationCopyWith<FiscalCancellation> get copyWith => _$FiscalCancellationCopyWithImpl<FiscalCancellation>(this as FiscalCancellation, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FiscalCancellation;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FiscalCancellation&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.reason, _this.reason) || other.reason == _this.reason)&&(identical(other.substitution, _this.substitution) || other.substitution == _this.substitution)&&(identical(other.outcome, _this.outcome) || other.outcome == _this.outcome)&&(identical(other.rawOutcome, _this.rawOutcome) || other.rawOutcome == _this.rawOutcome)&&(identical(other.pacCode, _this.pacCode) || other.pacCode == _this.pacCode)&&(identical(other.pacMessage, _this.pacMessage) || other.pacMessage == _this.pacMessage)&&(identical(other.requestedBy, _this.requestedBy) || other.requestedBy == _this.requestedBy)&&(identical(other.requestedAt, _this.requestedAt) || other.requestedAt == _this.requestedAt)&&(identical(other.answeredAt, _this.answeredAt) || other.answeredAt == _this.answeredAt)&&(identical(other.resolvedAt, _this.resolvedAt) || other.resolvedAt == _this.resolvedAt));
}


@override
int get hashCode {
  final _this = this as FiscalCancellation;
  return Object.hash(runtimeType,_this.id,_this.reason,_this.substitution,_this.outcome,_this.rawOutcome,_this.pacCode,_this.pacMessage,_this.requestedBy,_this.requestedAt,_this.answeredAt,_this.resolvedAt);
}

@override
String toString() {
  final _this = this as FiscalCancellation;
  return 'FiscalCancellation(id: ${_this.id}, reason: ${_this.reason}, substitution: ${_this.substitution}, outcome: ${_this.outcome}, rawOutcome: ${_this.rawOutcome}, pacCode: ${_this.pacCode}, pacMessage: ${_this.pacMessage}, requestedBy: ${_this.requestedBy}, requestedAt: ${_this.requestedAt}, answeredAt: ${_this.answeredAt}, resolvedAt: ${_this.resolvedAt})';
}


}

/// @nodoc
abstract mixin class $FiscalCancellationCopyWith<$Res>  {
  factory $FiscalCancellationCopyWith(FiscalCancellation value, $Res Function(FiscalCancellation) _then) = _$FiscalCancellationCopyWithImpl;
@useResult
$Res call({
 int id, String reason, String? substitution, CancellationOutcome outcome, String rawOutcome, String? pacCode, String? pacMessage, int requestedBy, DateTime requestedAt, DateTime? answeredAt, DateTime? resolvedAt
});




}
/// @nodoc
class _$FiscalCancellationCopyWithImpl<$Res>
    implements $FiscalCancellationCopyWith<$Res> {
  _$FiscalCancellationCopyWithImpl(this._self, this._then);

  final FiscalCancellation _self;
  final $Res Function(FiscalCancellation) _then;

/// Create a copy of FiscalCancellation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? reason = null,Object? substitution = freezed,Object? outcome = null,Object? rawOutcome = null,Object? pacCode = freezed,Object? pacMessage = freezed,Object? requestedBy = null,Object? requestedAt = null,Object? answeredAt = freezed,Object? resolvedAt = freezed,}) {
  return _then(FiscalCancellation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,substitution: freezed == substitution ? _self.substitution : substitution // ignore: cast_nullable_to_non_nullable
as String?,outcome: null == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as CancellationOutcome,rawOutcome: null == rawOutcome ? _self.rawOutcome : rawOutcome // ignore: cast_nullable_to_non_nullable
as String,pacCode: freezed == pacCode ? _self.pacCode : pacCode // ignore: cast_nullable_to_non_nullable
as String?,pacMessage: freezed == pacMessage ? _self.pacMessage : pacMessage // ignore: cast_nullable_to_non_nullable
as String?,requestedBy: null == requestedBy ? _self.requestedBy : requestedBy // ignore: cast_nullable_to_non_nullable
as int,requestedAt: null == requestedAt ? _self.requestedAt : requestedAt // ignore: cast_nullable_to_non_nullable
as DateTime,answeredAt: freezed == answeredAt ? _self.answeredAt : answeredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [FiscalCancellation].
extension FiscalCancellationPatterns on FiscalCancellation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FiscalCancellation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FiscalCancellation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FiscalCancellation value)  $default,){
final _that = this;
switch (_that) {
case _FiscalCancellation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FiscalCancellation value)?  $default,){
final _that = this;
switch (_that) {
case _FiscalCancellation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String reason,  String? substitution,  CancellationOutcome outcome,  String rawOutcome,  String? pacCode,  String? pacMessage,  int requestedBy,  DateTime requestedAt,  DateTime? answeredAt,  DateTime? resolvedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FiscalCancellation() when $default != null:
return $default(_that.id,_that.reason,_that.substitution,_that.outcome,_that.rawOutcome,_that.pacCode,_that.pacMessage,_that.requestedBy,_that.requestedAt,_that.answeredAt,_that.resolvedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String reason,  String? substitution,  CancellationOutcome outcome,  String rawOutcome,  String? pacCode,  String? pacMessage,  int requestedBy,  DateTime requestedAt,  DateTime? answeredAt,  DateTime? resolvedAt)  $default,) {final _that = this;
switch (_that) {
case _FiscalCancellation():
return $default(_that.id,_that.reason,_that.substitution,_that.outcome,_that.rawOutcome,_that.pacCode,_that.pacMessage,_that.requestedBy,_that.requestedAt,_that.answeredAt,_that.resolvedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String reason,  String? substitution,  CancellationOutcome outcome,  String rawOutcome,  String? pacCode,  String? pacMessage,  int requestedBy,  DateTime requestedAt,  DateTime? answeredAt,  DateTime? resolvedAt)?  $default,) {final _that = this;
switch (_that) {
case _FiscalCancellation() when $default != null:
return $default(_that.id,_that.reason,_that.substitution,_that.outcome,_that.rawOutcome,_that.pacCode,_that.pacMessage,_that.requestedBy,_that.requestedAt,_that.answeredAt,_that.resolvedAt);case _:
  return null;

}
}

}

/// @nodoc


class _FiscalCancellation implements FiscalCancellation {
  const _FiscalCancellation({required this.id, required this.reason, this.substitution, required this.outcome, required this.rawOutcome, this.pacCode, this.pacMessage, required this.requestedBy, required this.requestedAt, this.answeredAt, this.resolvedAt});
  

@override final  int id;
@override final  String reason;
@override final  String? substitution;
@override final  CancellationOutcome outcome;
/// The status string as the server sent it, shown when [outcome] is
/// [CancellationOutcome.unknown].
@override final  String rawOutcome;
@override final  String? pacCode;
@override final  String? pacMessage;
@override final  int requestedBy;
@override final  DateTime requestedAt;
@override final  DateTime? answeredAt;
@override final  DateTime? resolvedAt;

/// Create a copy of FiscalCancellation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FiscalCancellationCopyWith<_FiscalCancellation> get copyWith => __$FiscalCancellationCopyWithImpl<_FiscalCancellation>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FiscalCancellation&&(identical(other.id, id) || other.id == id)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.substitution, substitution) || other.substitution == substitution)&&(identical(other.outcome, outcome) || other.outcome == outcome)&&(identical(other.rawOutcome, rawOutcome) || other.rawOutcome == rawOutcome)&&(identical(other.pacCode, pacCode) || other.pacCode == pacCode)&&(identical(other.pacMessage, pacMessage) || other.pacMessage == pacMessage)&&(identical(other.requestedBy, requestedBy) || other.requestedBy == requestedBy)&&(identical(other.requestedAt, requestedAt) || other.requestedAt == requestedAt)&&(identical(other.answeredAt, answeredAt) || other.answeredAt == answeredAt)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,reason,substitution,outcome,rawOutcome,pacCode,pacMessage,requestedBy,requestedAt,answeredAt,resolvedAt);
}

@override
String toString() {
    return 'FiscalCancellation(id: $id, reason: $reason, substitution: $substitution, outcome: $outcome, rawOutcome: $rawOutcome, pacCode: $pacCode, pacMessage: $pacMessage, requestedBy: $requestedBy, requestedAt: $requestedAt, answeredAt: $answeredAt, resolvedAt: $resolvedAt)';
}


}

/// @nodoc
abstract mixin class _$FiscalCancellationCopyWith<$Res> implements $FiscalCancellationCopyWith<$Res> {
  factory _$FiscalCancellationCopyWith(_FiscalCancellation value, $Res Function(_FiscalCancellation) _then) = __$FiscalCancellationCopyWithImpl;
@override @useResult
$Res call({
 int id, String reason, String? substitution, CancellationOutcome outcome, String rawOutcome, String? pacCode, String? pacMessage, int requestedBy, DateTime requestedAt, DateTime? answeredAt, DateTime? resolvedAt
});




}
/// @nodoc
class __$FiscalCancellationCopyWithImpl<$Res>
    implements _$FiscalCancellationCopyWith<$Res> {
  __$FiscalCancellationCopyWithImpl(this._self, this._then);

  final _FiscalCancellation _self;
  final $Res Function(_FiscalCancellation) _then;

/// Create a copy of FiscalCancellation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? reason = null,Object? substitution = freezed,Object? outcome = null,Object? rawOutcome = null,Object? pacCode = freezed,Object? pacMessage = freezed,Object? requestedBy = null,Object? requestedAt = null,Object? answeredAt = freezed,Object? resolvedAt = freezed,}) {
  return _then(_FiscalCancellation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,substitution: freezed == substitution ? _self.substitution : substitution // ignore: cast_nullable_to_non_nullable
as String?,outcome: null == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as CancellationOutcome,rawOutcome: null == rawOutcome ? _self.rawOutcome : rawOutcome // ignore: cast_nullable_to_non_nullable
as String,pacCode: freezed == pacCode ? _self.pacCode : pacCode // ignore: cast_nullable_to_non_nullable
as String?,pacMessage: freezed == pacMessage ? _self.pacMessage : pacMessage // ignore: cast_nullable_to_non_nullable
as String?,requestedBy: null == requestedBy ? _self.requestedBy : requestedBy // ignore: cast_nullable_to_non_nullable
as int,requestedAt: null == requestedAt ? _self.requestedAt : requestedAt // ignore: cast_nullable_to_non_nullable
as DateTime,answeredAt: freezed == answeredAt ? _self.answeredAt : answeredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
