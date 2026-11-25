// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'commission_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CommissionLabel {

 int get id; String get name; Decimal get rate; String? get comment;
/// Create a copy of CommissionLabel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommissionLabelCopyWith<CommissionLabel> get copyWith => _$CommissionLabelCopyWithImpl<CommissionLabel>(this as CommissionLabel, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CommissionLabel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommissionLabel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.rate, _this.rate) || other.rate == _this.rate)&&(identical(other.comment, _this.comment) || other.comment == _this.comment));
}


@override
int get hashCode {
  final _this = this as CommissionLabel;
  return Object.hash(runtimeType,_this.id,_this.name,_this.rate,_this.comment);
}

@override
String toString() {
  final _this = this as CommissionLabel;
  return 'CommissionLabel(id: ${_this.id}, name: ${_this.name}, rate: ${_this.rate}, comment: ${_this.comment})';
}


}

/// @nodoc
abstract mixin class $CommissionLabelCopyWith<$Res>  {
  factory $CommissionLabelCopyWith(CommissionLabel value, $Res Function(CommissionLabel) _then) = _$CommissionLabelCopyWithImpl;
@useResult
$Res call({
 int id, String name, Decimal rate, String? comment
});




}
/// @nodoc
class _$CommissionLabelCopyWithImpl<$Res>
    implements $CommissionLabelCopyWith<$Res> {
  _$CommissionLabelCopyWithImpl(this._self, this._then);

  final CommissionLabel _self;
  final $Res Function(CommissionLabel) _then;

/// Create a copy of CommissionLabel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? rate = null,Object? comment = freezed,}) {
  return _then(CommissionLabel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,rate: null == rate ? _self.rate : rate // ignore: cast_nullable_to_non_nullable
as Decimal,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CommissionLabel].
extension CommissionLabelPatterns on CommissionLabel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommissionLabel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommissionLabel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommissionLabel value)  $default,){
final _that = this;
switch (_that) {
case _CommissionLabel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommissionLabel value)?  $default,){
final _that = this;
switch (_that) {
case _CommissionLabel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  Decimal rate,  String? comment)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommissionLabel() when $default != null:
return $default(_that.id,_that.name,_that.rate,_that.comment);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  Decimal rate,  String? comment)  $default,) {final _that = this;
switch (_that) {
case _CommissionLabel():
return $default(_that.id,_that.name,_that.rate,_that.comment);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  Decimal rate,  String? comment)?  $default,) {final _that = this;
switch (_that) {
case _CommissionLabel() when $default != null:
return $default(_that.id,_that.name,_that.rate,_that.comment);case _:
  return null;

}
}

}

/// @nodoc


class _CommissionLabel implements CommissionLabel {
  const _CommissionLabel({required this.id, required this.name, required this.rate, this.comment});
  

@override final  int id;
@override final  String name;
@override final  Decimal rate;
@override final  String? comment;

/// Create a copy of CommissionLabel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommissionLabelCopyWith<_CommissionLabel> get copyWith => __$CommissionLabelCopyWithImpl<_CommissionLabel>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommissionLabel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.rate, rate) || other.rate == rate)&&(identical(other.comment, comment) || other.comment == comment));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,rate,comment);
}

@override
String toString() {
    return 'CommissionLabel(id: $id, name: $name, rate: $rate, comment: $comment)';
}


}

/// @nodoc
abstract mixin class _$CommissionLabelCopyWith<$Res> implements $CommissionLabelCopyWith<$Res> {
  factory _$CommissionLabelCopyWith(_CommissionLabel value, $Res Function(_CommissionLabel) _then) = __$CommissionLabelCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, Decimal rate, String? comment
});




}
/// @nodoc
class __$CommissionLabelCopyWithImpl<$Res>
    implements _$CommissionLabelCopyWith<$Res> {
  __$CommissionLabelCopyWithImpl(this._self, this._then);

  final _CommissionLabel _self;
  final $Res Function(_CommissionLabel) _then;

/// Create a copy of CommissionLabel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? rate = null,Object? comment = freezed,}) {
  return _then(_CommissionLabel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,rate: null == rate ? _self.rate : rate // ignore: cast_nullable_to_non_nullable
as Decimal,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$CommissionParticipation {

 int get id; String get name;
/// Create a copy of CommissionParticipation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommissionParticipationCopyWith<CommissionParticipation> get copyWith => _$CommissionParticipationCopyWithImpl<CommissionParticipation>(this as CommissionParticipation, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CommissionParticipation;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommissionParticipation&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name));
}


@override
int get hashCode {
  final _this = this as CommissionParticipation;
  return Object.hash(runtimeType,_this.id,_this.name);
}

@override
String toString() {
  final _this = this as CommissionParticipation;
  return 'CommissionParticipation(id: ${_this.id}, name: ${_this.name})';
}


}

/// @nodoc
abstract mixin class $CommissionParticipationCopyWith<$Res>  {
  factory $CommissionParticipationCopyWith(CommissionParticipation value, $Res Function(CommissionParticipation) _then) = _$CommissionParticipationCopyWithImpl;
@useResult
$Res call({
 int id, String name
});




}
/// @nodoc
class _$CommissionParticipationCopyWithImpl<$Res>
    implements $CommissionParticipationCopyWith<$Res> {
  _$CommissionParticipationCopyWithImpl(this._self, this._then);

  final CommissionParticipation _self;
  final $Res Function(CommissionParticipation) _then;

/// Create a copy of CommissionParticipation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(CommissionParticipation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CommissionParticipation].
extension CommissionParticipationPatterns on CommissionParticipation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommissionParticipation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommissionParticipation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommissionParticipation value)  $default,){
final _that = this;
switch (_that) {
case _CommissionParticipation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommissionParticipation value)?  $default,){
final _that = this;
switch (_that) {
case _CommissionParticipation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommissionParticipation() when $default != null:
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name)  $default,) {final _that = this;
switch (_that) {
case _CommissionParticipation():
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name)?  $default,) {final _that = this;
switch (_that) {
case _CommissionParticipation() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc


class _CommissionParticipation implements CommissionParticipation {
  const _CommissionParticipation({required this.id, required this.name});
  

@override final  int id;
@override final  String name;

/// Create a copy of CommissionParticipation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommissionParticipationCopyWith<_CommissionParticipation> get copyWith => __$CommissionParticipationCopyWithImpl<_CommissionParticipation>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommissionParticipation&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name);
}

@override
String toString() {
    return 'CommissionParticipation(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$CommissionParticipationCopyWith<$Res> implements $CommissionParticipationCopyWith<$Res> {
  factory _$CommissionParticipationCopyWith(_CommissionParticipation value, $Res Function(_CommissionParticipation) _then) = __$CommissionParticipationCopyWithImpl;
@override @useResult
$Res call({
 int id, String name
});




}
/// @nodoc
class __$CommissionParticipationCopyWithImpl<$Res>
    implements _$CommissionParticipationCopyWith<$Res> {
  __$CommissionParticipationCopyWithImpl(this._self, this._then);

  final _CommissionParticipation _self;
  final $Res Function(_CommissionParticipation) _then;

/// Create a copy of CommissionParticipation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_CommissionParticipation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$CommissionAgent {

 int get employeeId; String get name; CommissionScheme get scheme;
/// Create a copy of CommissionAgent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommissionAgentCopyWith<CommissionAgent> get copyWith => _$CommissionAgentCopyWithImpl<CommissionAgent>(this as CommissionAgent, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CommissionAgent;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommissionAgent&&(identical(other.employeeId, _this.employeeId) || other.employeeId == _this.employeeId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.scheme, _this.scheme) || other.scheme == _this.scheme));
}


@override
int get hashCode {
  final _this = this as CommissionAgent;
  return Object.hash(runtimeType,_this.employeeId,_this.name,_this.scheme);
}

@override
String toString() {
  final _this = this as CommissionAgent;
  return 'CommissionAgent(employeeId: ${_this.employeeId}, name: ${_this.name}, scheme: ${_this.scheme})';
}


}

/// @nodoc
abstract mixin class $CommissionAgentCopyWith<$Res>  {
  factory $CommissionAgentCopyWith(CommissionAgent value, $Res Function(CommissionAgent) _then) = _$CommissionAgentCopyWithImpl;
@useResult
$Res call({
 int employeeId, String name, CommissionScheme scheme
});




}
/// @nodoc
class _$CommissionAgentCopyWithImpl<$Res>
    implements $CommissionAgentCopyWith<$Res> {
  _$CommissionAgentCopyWithImpl(this._self, this._then);

  final CommissionAgent _self;
  final $Res Function(CommissionAgent) _then;

/// Create a copy of CommissionAgent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? employeeId = null,Object? name = null,Object? scheme = null,}) {
  return _then(CommissionAgent(
employeeId: null == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,scheme: null == scheme ? _self.scheme : scheme // ignore: cast_nullable_to_non_nullable
as CommissionScheme,
  ));
}

}


/// Adds pattern-matching-related methods to [CommissionAgent].
extension CommissionAgentPatterns on CommissionAgent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommissionAgent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommissionAgent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommissionAgent value)  $default,){
final _that = this;
switch (_that) {
case _CommissionAgent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommissionAgent value)?  $default,){
final _that = this;
switch (_that) {
case _CommissionAgent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int employeeId,  String name,  CommissionScheme scheme)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommissionAgent() when $default != null:
return $default(_that.employeeId,_that.name,_that.scheme);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int employeeId,  String name,  CommissionScheme scheme)  $default,) {final _that = this;
switch (_that) {
case _CommissionAgent():
return $default(_that.employeeId,_that.name,_that.scheme);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int employeeId,  String name,  CommissionScheme scheme)?  $default,) {final _that = this;
switch (_that) {
case _CommissionAgent() when $default != null:
return $default(_that.employeeId,_that.name,_that.scheme);case _:
  return null;

}
}

}

/// @nodoc


class _CommissionAgent implements CommissionAgent {
  const _CommissionAgent({required this.employeeId, required this.name, required this.scheme});
  

@override final  int employeeId;
@override final  String name;
@override final  CommissionScheme scheme;

/// Create a copy of CommissionAgent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommissionAgentCopyWith<_CommissionAgent> get copyWith => __$CommissionAgentCopyWithImpl<_CommissionAgent>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommissionAgent&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.name, name) || other.name == name)&&(identical(other.scheme, scheme) || other.scheme == scheme));
}


@override
int get hashCode {
    return Object.hash(runtimeType,employeeId,name,scheme);
}

@override
String toString() {
    return 'CommissionAgent(employeeId: $employeeId, name: $name, scheme: $scheme)';
}


}

/// @nodoc
abstract mixin class _$CommissionAgentCopyWith<$Res> implements $CommissionAgentCopyWith<$Res> {
  factory _$CommissionAgentCopyWith(_CommissionAgent value, $Res Function(_CommissionAgent) _then) = __$CommissionAgentCopyWithImpl;
@override @useResult
$Res call({
 int employeeId, String name, CommissionScheme scheme
});




}
/// @nodoc
class __$CommissionAgentCopyWithImpl<$Res>
    implements _$CommissionAgentCopyWith<$Res> {
  __$CommissionAgentCopyWithImpl(this._self, this._then);

  final _CommissionAgent _self;
  final $Res Function(_CommissionAgent) _then;

/// Create a copy of CommissionAgent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? employeeId = null,Object? name = null,Object? scheme = null,}) {
  return _then(_CommissionAgent(
employeeId: null == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,scheme: null == scheme ? _self.scheme : scheme // ignore: cast_nullable_to_non_nullable
as CommissionScheme,
  ));
}


}

/// @nodoc
mixin _$CommissionAgentRate {

 int get id; int get agentId; int get labelId; int get participationId; Decimal get share;
/// Create a copy of CommissionAgentRate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommissionAgentRateCopyWith<CommissionAgentRate> get copyWith => _$CommissionAgentRateCopyWithImpl<CommissionAgentRate>(this as CommissionAgentRate, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CommissionAgentRate;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommissionAgentRate&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.agentId, _this.agentId) || other.agentId == _this.agentId)&&(identical(other.labelId, _this.labelId) || other.labelId == _this.labelId)&&(identical(other.participationId, _this.participationId) || other.participationId == _this.participationId)&&(identical(other.share, _this.share) || other.share == _this.share));
}


@override
int get hashCode {
  final _this = this as CommissionAgentRate;
  return Object.hash(runtimeType,_this.id,_this.agentId,_this.labelId,_this.participationId,_this.share);
}

@override
String toString() {
  final _this = this as CommissionAgentRate;
  return 'CommissionAgentRate(id: ${_this.id}, agentId: ${_this.agentId}, labelId: ${_this.labelId}, participationId: ${_this.participationId}, share: ${_this.share})';
}


}

/// @nodoc
abstract mixin class $CommissionAgentRateCopyWith<$Res>  {
  factory $CommissionAgentRateCopyWith(CommissionAgentRate value, $Res Function(CommissionAgentRate) _then) = _$CommissionAgentRateCopyWithImpl;
@useResult
$Res call({
 int id, int agentId, int labelId, int participationId, Decimal share
});




}
/// @nodoc
class _$CommissionAgentRateCopyWithImpl<$Res>
    implements $CommissionAgentRateCopyWith<$Res> {
  _$CommissionAgentRateCopyWithImpl(this._self, this._then);

  final CommissionAgentRate _self;
  final $Res Function(CommissionAgentRate) _then;

/// Create a copy of CommissionAgentRate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? agentId = null,Object? labelId = null,Object? participationId = null,Object? share = null,}) {
  return _then(CommissionAgentRate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,agentId: null == agentId ? _self.agentId : agentId // ignore: cast_nullable_to_non_nullable
as int,labelId: null == labelId ? _self.labelId : labelId // ignore: cast_nullable_to_non_nullable
as int,participationId: null == participationId ? _self.participationId : participationId // ignore: cast_nullable_to_non_nullable
as int,share: null == share ? _self.share : share // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}

}


/// Adds pattern-matching-related methods to [CommissionAgentRate].
extension CommissionAgentRatePatterns on CommissionAgentRate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommissionAgentRate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommissionAgentRate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommissionAgentRate value)  $default,){
final _that = this;
switch (_that) {
case _CommissionAgentRate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommissionAgentRate value)?  $default,){
final _that = this;
switch (_that) {
case _CommissionAgentRate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int agentId,  int labelId,  int participationId,  Decimal share)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommissionAgentRate() when $default != null:
return $default(_that.id,_that.agentId,_that.labelId,_that.participationId,_that.share);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int agentId,  int labelId,  int participationId,  Decimal share)  $default,) {final _that = this;
switch (_that) {
case _CommissionAgentRate():
return $default(_that.id,_that.agentId,_that.labelId,_that.participationId,_that.share);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int agentId,  int labelId,  int participationId,  Decimal share)?  $default,) {final _that = this;
switch (_that) {
case _CommissionAgentRate() when $default != null:
return $default(_that.id,_that.agentId,_that.labelId,_that.participationId,_that.share);case _:
  return null;

}
}

}

/// @nodoc


class _CommissionAgentRate implements CommissionAgentRate {
  const _CommissionAgentRate({required this.id, required this.agentId, required this.labelId, required this.participationId, required this.share});
  

@override final  int id;
@override final  int agentId;
@override final  int labelId;
@override final  int participationId;
@override final  Decimal share;

/// Create a copy of CommissionAgentRate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommissionAgentRateCopyWith<_CommissionAgentRate> get copyWith => __$CommissionAgentRateCopyWithImpl<_CommissionAgentRate>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommissionAgentRate&&(identical(other.id, id) || other.id == id)&&(identical(other.agentId, agentId) || other.agentId == agentId)&&(identical(other.labelId, labelId) || other.labelId == labelId)&&(identical(other.participationId, participationId) || other.participationId == participationId)&&(identical(other.share, share) || other.share == share));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,agentId,labelId,participationId,share);
}

@override
String toString() {
    return 'CommissionAgentRate(id: $id, agentId: $agentId, labelId: $labelId, participationId: $participationId, share: $share)';
}


}

/// @nodoc
abstract mixin class _$CommissionAgentRateCopyWith<$Res> implements $CommissionAgentRateCopyWith<$Res> {
  factory _$CommissionAgentRateCopyWith(_CommissionAgentRate value, $Res Function(_CommissionAgentRate) _then) = __$CommissionAgentRateCopyWithImpl;
@override @useResult
$Res call({
 int id, int agentId, int labelId, int participationId, Decimal share
});




}
/// @nodoc
class __$CommissionAgentRateCopyWithImpl<$Res>
    implements _$CommissionAgentRateCopyWith<$Res> {
  __$CommissionAgentRateCopyWithImpl(this._self, this._then);

  final _CommissionAgentRate _self;
  final $Res Function(_CommissionAgentRate) _then;

/// Create a copy of CommissionAgentRate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? agentId = null,Object? labelId = null,Object? participationId = null,Object? share = null,}) {
  return _then(_CommissionAgentRate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,agentId: null == agentId ? _self.agentId : agentId // ignore: cast_nullable_to_non_nullable
as int,labelId: null == labelId ? _self.labelId : labelId // ignore: cast_nullable_to_non_nullable
as int,participationId: null == participationId ? _self.participationId : participationId // ignore: cast_nullable_to_non_nullable
as int,share: null == share ? _self.share : share // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}


}

/// @nodoc
mixin _$CommissionProductLabel {

 int get productId; String get productCode; String get productName; int get labelId;
/// Create a copy of CommissionProductLabel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommissionProductLabelCopyWith<CommissionProductLabel> get copyWith => _$CommissionProductLabelCopyWithImpl<CommissionProductLabel>(this as CommissionProductLabel, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CommissionProductLabel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommissionProductLabel&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.productCode, _this.productCode) || other.productCode == _this.productCode)&&(identical(other.productName, _this.productName) || other.productName == _this.productName)&&(identical(other.labelId, _this.labelId) || other.labelId == _this.labelId));
}


@override
int get hashCode {
  final _this = this as CommissionProductLabel;
  return Object.hash(runtimeType,_this.productId,_this.productCode,_this.productName,_this.labelId);
}

@override
String toString() {
  final _this = this as CommissionProductLabel;
  return 'CommissionProductLabel(productId: ${_this.productId}, productCode: ${_this.productCode}, productName: ${_this.productName}, labelId: ${_this.labelId})';
}


}

/// @nodoc
abstract mixin class $CommissionProductLabelCopyWith<$Res>  {
  factory $CommissionProductLabelCopyWith(CommissionProductLabel value, $Res Function(CommissionProductLabel) _then) = _$CommissionProductLabelCopyWithImpl;
@useResult
$Res call({
 int productId, String productCode, String productName, int labelId
});




}
/// @nodoc
class _$CommissionProductLabelCopyWithImpl<$Res>
    implements $CommissionProductLabelCopyWith<$Res> {
  _$CommissionProductLabelCopyWithImpl(this._self, this._then);

  final CommissionProductLabel _self;
  final $Res Function(CommissionProductLabel) _then;

/// Create a copy of CommissionProductLabel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? productCode = null,Object? productName = null,Object? labelId = null,}) {
  return _then(CommissionProductLabel(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,productCode: null == productCode ? _self.productCode : productCode // ignore: cast_nullable_to_non_nullable
as String,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,labelId: null == labelId ? _self.labelId : labelId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CommissionProductLabel].
extension CommissionProductLabelPatterns on CommissionProductLabel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommissionProductLabel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommissionProductLabel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommissionProductLabel value)  $default,){
final _that = this;
switch (_that) {
case _CommissionProductLabel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommissionProductLabel value)?  $default,){
final _that = this;
switch (_that) {
case _CommissionProductLabel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int productId,  String productCode,  String productName,  int labelId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommissionProductLabel() when $default != null:
return $default(_that.productId,_that.productCode,_that.productName,_that.labelId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int productId,  String productCode,  String productName,  int labelId)  $default,) {final _that = this;
switch (_that) {
case _CommissionProductLabel():
return $default(_that.productId,_that.productCode,_that.productName,_that.labelId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int productId,  String productCode,  String productName,  int labelId)?  $default,) {final _that = this;
switch (_that) {
case _CommissionProductLabel() when $default != null:
return $default(_that.productId,_that.productCode,_that.productName,_that.labelId);case _:
  return null;

}
}

}

/// @nodoc


class _CommissionProductLabel implements CommissionProductLabel {
  const _CommissionProductLabel({required this.productId, required this.productCode, required this.productName, required this.labelId});
  

@override final  int productId;
@override final  String productCode;
@override final  String productName;
@override final  int labelId;

/// Create a copy of CommissionProductLabel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommissionProductLabelCopyWith<_CommissionProductLabel> get copyWith => __$CommissionProductLabelCopyWithImpl<_CommissionProductLabel>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommissionProductLabel&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productCode, productCode) || other.productCode == productCode)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.labelId, labelId) || other.labelId == labelId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,productId,productCode,productName,labelId);
}

@override
String toString() {
    return 'CommissionProductLabel(productId: $productId, productCode: $productCode, productName: $productName, labelId: $labelId)';
}


}

/// @nodoc
abstract mixin class _$CommissionProductLabelCopyWith<$Res> implements $CommissionProductLabelCopyWith<$Res> {
  factory _$CommissionProductLabelCopyWith(_CommissionProductLabel value, $Res Function(_CommissionProductLabel) _then) = __$CommissionProductLabelCopyWithImpl;
@override @useResult
$Res call({
 int productId, String productCode, String productName, int labelId
});




}
/// @nodoc
class __$CommissionProductLabelCopyWithImpl<$Res>
    implements _$CommissionProductLabelCopyWith<$Res> {
  __$CommissionProductLabelCopyWithImpl(this._self, this._then);

  final _CommissionProductLabel _self;
  final $Res Function(_CommissionProductLabel) _then;

/// Create a copy of CommissionProductLabel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? productCode = null,Object? productName = null,Object? labelId = null,}) {
  return _then(_CommissionProductLabel(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,productCode: null == productCode ? _self.productCode : productCode // ignore: cast_nullable_to_non_nullable
as String,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,labelId: null == labelId ? _self.labelId : labelId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$CommissionProductLabelPage {

 List<CommissionProductLabel> get items; int get total;
/// Create a copy of CommissionProductLabelPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommissionProductLabelPageCopyWith<CommissionProductLabelPage> get copyWith => _$CommissionProductLabelPageCopyWithImpl<CommissionProductLabelPage>(this as CommissionProductLabelPage, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CommissionProductLabelPage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommissionProductLabelPage&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.total, _this.total) || other.total == _this.total));
}


@override
int get hashCode {
  final _this = this as CommissionProductLabelPage;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.items),_this.total);
}

@override
String toString() {
  final _this = this as CommissionProductLabelPage;
  return 'CommissionProductLabelPage(items: ${_this.items}, total: ${_this.total})';
}


}

/// @nodoc
abstract mixin class $CommissionProductLabelPageCopyWith<$Res>  {
  factory $CommissionProductLabelPageCopyWith(CommissionProductLabelPage value, $Res Function(CommissionProductLabelPage) _then) = _$CommissionProductLabelPageCopyWithImpl;
@useResult
$Res call({
 List<CommissionProductLabel> items, int total
});




}
/// @nodoc
class _$CommissionProductLabelPageCopyWithImpl<$Res>
    implements $CommissionProductLabelPageCopyWith<$Res> {
  _$CommissionProductLabelPageCopyWithImpl(this._self, this._then);

  final CommissionProductLabelPage _self;
  final $Res Function(CommissionProductLabelPage) _then;

/// Create a copy of CommissionProductLabelPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? total = null,}) {
  return _then(CommissionProductLabelPage(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<CommissionProductLabel>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CommissionProductLabelPage].
extension CommissionProductLabelPagePatterns on CommissionProductLabelPage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommissionProductLabelPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommissionProductLabelPage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommissionProductLabelPage value)  $default,){
final _that = this;
switch (_that) {
case _CommissionProductLabelPage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommissionProductLabelPage value)?  $default,){
final _that = this;
switch (_that) {
case _CommissionProductLabelPage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<CommissionProductLabel> items,  int total)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommissionProductLabelPage() when $default != null:
return $default(_that.items,_that.total);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<CommissionProductLabel> items,  int total)  $default,) {final _that = this;
switch (_that) {
case _CommissionProductLabelPage():
return $default(_that.items,_that.total);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<CommissionProductLabel> items,  int total)?  $default,) {final _that = this;
switch (_that) {
case _CommissionProductLabelPage() when $default != null:
return $default(_that.items,_that.total);case _:
  return null;

}
}

}

/// @nodoc


class _CommissionProductLabelPage implements CommissionProductLabelPage {
  const _CommissionProductLabelPage({required  List<CommissionProductLabel> items, required this.total}): _items = items;
  

 final  List<CommissionProductLabel> _items;
@override List<CommissionProductLabel> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  int total;

/// Create a copy of CommissionProductLabelPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommissionProductLabelPageCopyWith<_CommissionProductLabelPage> get copyWith => __$CommissionProductLabelPageCopyWithImpl<_CommissionProductLabelPage>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommissionProductLabelPage&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.total, total) || other.total == total));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),total);
}

@override
String toString() {
    return 'CommissionProductLabelPage(items: $items, total: $total)';
}


}

/// @nodoc
abstract mixin class _$CommissionProductLabelPageCopyWith<$Res> implements $CommissionProductLabelPageCopyWith<$Res> {
  factory _$CommissionProductLabelPageCopyWith(_CommissionProductLabelPage value, $Res Function(_CommissionProductLabelPage) _then) = __$CommissionProductLabelPageCopyWithImpl;
@override @useResult
$Res call({
 List<CommissionProductLabel> items, int total
});




}
/// @nodoc
class __$CommissionProductLabelPageCopyWithImpl<$Res>
    implements _$CommissionProductLabelPageCopyWith<$Res> {
  __$CommissionProductLabelPageCopyWithImpl(this._self, this._then);

  final _CommissionProductLabelPage _self;
  final $Res Function(_CommissionProductLabelPage) _then;

/// Create a copy of CommissionProductLabelPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? total = null,}) {
  return _then(_CommissionProductLabelPage(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<CommissionProductLabel>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
