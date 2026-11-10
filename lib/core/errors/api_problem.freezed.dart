// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api_problem.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ApiProblem {

 String get codeName; api.ErrorCode? get code; Map<String, Object?> get params; List<ApiProblemPart> get parts;/// The server's English text: a string `detail`, or `detail.message` for
/// the four dict details that stay until mbe-api's phase 3.
 String? get detail;/// The per-line English prose of today's dict refusals
/// (`detail.lines` / `detail.missing`). Empty once phase 3 moves them to
/// [parts].
 List<String> get detailItems;
/// Create a copy of ApiProblem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiProblemCopyWith<ApiProblem> get copyWith => _$ApiProblemCopyWithImpl<ApiProblem>(this as ApiProblem, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ApiProblem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiProblem&&(identical(other.codeName, _this.codeName) || other.codeName == _this.codeName)&&(identical(other.code, _this.code) || other.code == _this.code)&&const DeepCollectionEquality().equals(other.params, _this.params)&&const DeepCollectionEquality().equals(other.parts, _this.parts)&&(identical(other.detail, _this.detail) || other.detail == _this.detail)&&const DeepCollectionEquality().equals(other.detailItems, _this.detailItems));
}


@override
int get hashCode {
  final _this = this as ApiProblem;
  return Object.hash(runtimeType,_this.codeName,_this.code,const DeepCollectionEquality().hash(_this.params),const DeepCollectionEquality().hash(_this.parts),_this.detail,const DeepCollectionEquality().hash(_this.detailItems));
}

@override
String toString() {
  final _this = this as ApiProblem;
  return 'ApiProblem(codeName: ${_this.codeName}, code: ${_this.code}, params: ${_this.params}, parts: ${_this.parts}, detail: ${_this.detail}, detailItems: ${_this.detailItems})';
}


}

/// @nodoc
abstract mixin class $ApiProblemCopyWith<$Res>  {
  factory $ApiProblemCopyWith(ApiProblem value, $Res Function(ApiProblem) _then) = _$ApiProblemCopyWithImpl;
@useResult
$Res call({
 String codeName, api.ErrorCode? code, Map<String, Object?> params, List<ApiProblemPart> parts, String? detail, List<String> detailItems
});




}
/// @nodoc
class _$ApiProblemCopyWithImpl<$Res>
    implements $ApiProblemCopyWith<$Res> {
  _$ApiProblemCopyWithImpl(this._self, this._then);

  final ApiProblem _self;
  final $Res Function(ApiProblem) _then;

/// Create a copy of ApiProblem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? codeName = null,Object? code = freezed,Object? params = null,Object? parts = null,Object? detail = freezed,Object? detailItems = null,}) {
  return _then(ApiProblem(
codeName: null == codeName ? _self.codeName : codeName // ignore: cast_nullable_to_non_nullable
as String,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as api.ErrorCode?,params: null == params ? _self.params : params // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,parts: null == parts ? _self.parts : parts // ignore: cast_nullable_to_non_nullable
as List<ApiProblemPart>,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String?,detailItems: null == detailItems ? _self.detailItems : detailItems // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ApiProblem].
extension ApiProblemPatterns on ApiProblem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiProblem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiProblem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiProblem value)  $default,){
final _that = this;
switch (_that) {
case _ApiProblem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiProblem value)?  $default,){
final _that = this;
switch (_that) {
case _ApiProblem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String codeName,  api.ErrorCode? code,  Map<String, Object?> params,  List<ApiProblemPart> parts,  String? detail,  List<String> detailItems)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiProblem() when $default != null:
return $default(_that.codeName,_that.code,_that.params,_that.parts,_that.detail,_that.detailItems);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String codeName,  api.ErrorCode? code,  Map<String, Object?> params,  List<ApiProblemPart> parts,  String? detail,  List<String> detailItems)  $default,) {final _that = this;
switch (_that) {
case _ApiProblem():
return $default(_that.codeName,_that.code,_that.params,_that.parts,_that.detail,_that.detailItems);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String codeName,  api.ErrorCode? code,  Map<String, Object?> params,  List<ApiProblemPart> parts,  String? detail,  List<String> detailItems)?  $default,) {final _that = this;
switch (_that) {
case _ApiProblem() when $default != null:
return $default(_that.codeName,_that.code,_that.params,_that.parts,_that.detail,_that.detailItems);case _:
  return null;

}
}

}

/// @nodoc


class _ApiProblem extends ApiProblem {
  const _ApiProblem({required this.codeName, this.code,  Map<String, Object?> params = const <String, Object?>{},  List<ApiProblemPart> parts = const <ApiProblemPart>[], this.detail,  List<String> detailItems = const <String>[]}): _params = params,_parts = parts,_detailItems = detailItems,super._();
  

@override final  String codeName;
@override final  api.ErrorCode? code;
 final  Map<String, Object?> _params;
@override@JsonKey() Map<String, Object?> get params {
  if (_params is EqualUnmodifiableMapView) return _params;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_params);
}

 final  List<ApiProblemPart> _parts;
@override@JsonKey() List<ApiProblemPart> get parts {
  if (_parts is EqualUnmodifiableListView) return _parts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_parts);
}

/// The server's English text: a string `detail`, or `detail.message` for
/// the four dict details that stay until mbe-api's phase 3.
@override final  String? detail;
/// The per-line English prose of today's dict refusals
/// (`detail.lines` / `detail.missing`). Empty once phase 3 moves them to
/// [parts].
 final  List<String> _detailItems;
/// The per-line English prose of today's dict refusals
/// (`detail.lines` / `detail.missing`). Empty once phase 3 moves them to
/// [parts].
@override@JsonKey() List<String> get detailItems {
  if (_detailItems is EqualUnmodifiableListView) return _detailItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_detailItems);
}


/// Create a copy of ApiProblem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiProblemCopyWith<_ApiProblem> get copyWith => __$ApiProblemCopyWithImpl<_ApiProblem>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiProblem&&(identical(other.codeName, codeName) || other.codeName == codeName)&&(identical(other.code, code) || other.code == code)&&const DeepCollectionEquality().equals(other.params, _params)&&const DeepCollectionEquality().equals(other.parts, _parts)&&(identical(other.detail, detail) || other.detail == detail)&&const DeepCollectionEquality().equals(other.detailItems, _detailItems));
}


@override
int get hashCode {
    return Object.hash(runtimeType,codeName,code,const DeepCollectionEquality().hash(_params),const DeepCollectionEquality().hash(_parts),detail,const DeepCollectionEquality().hash(_detailItems));
}

@override
String toString() {
    return 'ApiProblem(codeName: $codeName, code: $code, params: $params, parts: $parts, detail: $detail, detailItems: $detailItems)';
}


}

/// @nodoc
abstract mixin class _$ApiProblemCopyWith<$Res> implements $ApiProblemCopyWith<$Res> {
  factory _$ApiProblemCopyWith(_ApiProblem value, $Res Function(_ApiProblem) _then) = __$ApiProblemCopyWithImpl;
@override @useResult
$Res call({
 String codeName, api.ErrorCode? code, Map<String, Object?> params, List<ApiProblemPart> parts, String? detail, List<String> detailItems
});




}
/// @nodoc
class __$ApiProblemCopyWithImpl<$Res>
    implements _$ApiProblemCopyWith<$Res> {
  __$ApiProblemCopyWithImpl(this._self, this._then);

  final _ApiProblem _self;
  final $Res Function(_ApiProblem) _then;

/// Create a copy of ApiProblem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? codeName = null,Object? code = freezed,Object? params = null,Object? parts = null,Object? detail = freezed,Object? detailItems = null,}) {
  return _then(_ApiProblem(
codeName: null == codeName ? _self.codeName : codeName // ignore: cast_nullable_to_non_nullable
as String,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as api.ErrorCode?,params: null == params ? _self._params : params // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,parts: null == parts ? _self._parts : parts // ignore: cast_nullable_to_non_nullable
as List<ApiProblemPart>,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String?,detailItems: null == detailItems ? _self._detailItems : detailItems // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc
mixin _$ApiProblemPart {

 String get codeName; api.ErrorCode? get code; Map<String, Object?> get params;/// The item's other keys, kept as sent (the inventory count batch keeps
/// `index`, `product_code` and `reason`).
 Map<String, Object?> get extra;
/// Create a copy of ApiProblemPart
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiProblemPartCopyWith<ApiProblemPart> get copyWith => _$ApiProblemPartCopyWithImpl<ApiProblemPart>(this as ApiProblemPart, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ApiProblemPart;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiProblemPart&&(identical(other.codeName, _this.codeName) || other.codeName == _this.codeName)&&(identical(other.code, _this.code) || other.code == _this.code)&&const DeepCollectionEquality().equals(other.params, _this.params)&&const DeepCollectionEquality().equals(other.extra, _this.extra));
}


@override
int get hashCode {
  final _this = this as ApiProblemPart;
  return Object.hash(runtimeType,_this.codeName,_this.code,const DeepCollectionEquality().hash(_this.params),const DeepCollectionEquality().hash(_this.extra));
}

@override
String toString() {
  final _this = this as ApiProblemPart;
  return 'ApiProblemPart(codeName: ${_this.codeName}, code: ${_this.code}, params: ${_this.params}, extra: ${_this.extra})';
}


}

/// @nodoc
abstract mixin class $ApiProblemPartCopyWith<$Res>  {
  factory $ApiProblemPartCopyWith(ApiProblemPart value, $Res Function(ApiProblemPart) _then) = _$ApiProblemPartCopyWithImpl;
@useResult
$Res call({
 String codeName, api.ErrorCode? code, Map<String, Object?> params, Map<String, Object?> extra
});




}
/// @nodoc
class _$ApiProblemPartCopyWithImpl<$Res>
    implements $ApiProblemPartCopyWith<$Res> {
  _$ApiProblemPartCopyWithImpl(this._self, this._then);

  final ApiProblemPart _self;
  final $Res Function(ApiProblemPart) _then;

/// Create a copy of ApiProblemPart
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? codeName = null,Object? code = freezed,Object? params = null,Object? extra = null,}) {
  return _then(ApiProblemPart(
codeName: null == codeName ? _self.codeName : codeName // ignore: cast_nullable_to_non_nullable
as String,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as api.ErrorCode?,params: null == params ? _self.params : params // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,extra: null == extra ? _self.extra : extra // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [ApiProblemPart].
extension ApiProblemPartPatterns on ApiProblemPart {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiProblemPart value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiProblemPart() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiProblemPart value)  $default,){
final _that = this;
switch (_that) {
case _ApiProblemPart():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiProblemPart value)?  $default,){
final _that = this;
switch (_that) {
case _ApiProblemPart() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String codeName,  api.ErrorCode? code,  Map<String, Object?> params,  Map<String, Object?> extra)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiProblemPart() when $default != null:
return $default(_that.codeName,_that.code,_that.params,_that.extra);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String codeName,  api.ErrorCode? code,  Map<String, Object?> params,  Map<String, Object?> extra)  $default,) {final _that = this;
switch (_that) {
case _ApiProblemPart():
return $default(_that.codeName,_that.code,_that.params,_that.extra);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String codeName,  api.ErrorCode? code,  Map<String, Object?> params,  Map<String, Object?> extra)?  $default,) {final _that = this;
switch (_that) {
case _ApiProblemPart() when $default != null:
return $default(_that.codeName,_that.code,_that.params,_that.extra);case _:
  return null;

}
}

}

/// @nodoc


class _ApiProblemPart extends ApiProblemPart {
  const _ApiProblemPart({this.codeName = '', this.code,  Map<String, Object?> params = const <String, Object?>{},  Map<String, Object?> extra = const <String, Object?>{}}): _params = params,_extra = extra,super._();
  

@override@JsonKey() final  String codeName;
@override final  api.ErrorCode? code;
 final  Map<String, Object?> _params;
@override@JsonKey() Map<String, Object?> get params {
  if (_params is EqualUnmodifiableMapView) return _params;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_params);
}

/// The item's other keys, kept as sent (the inventory count batch keeps
/// `index`, `product_code` and `reason`).
 final  Map<String, Object?> _extra;
/// The item's other keys, kept as sent (the inventory count batch keeps
/// `index`, `product_code` and `reason`).
@override@JsonKey() Map<String, Object?> get extra {
  if (_extra is EqualUnmodifiableMapView) return _extra;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_extra);
}


/// Create a copy of ApiProblemPart
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiProblemPartCopyWith<_ApiProblemPart> get copyWith => __$ApiProblemPartCopyWithImpl<_ApiProblemPart>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiProblemPart&&(identical(other.codeName, codeName) || other.codeName == codeName)&&(identical(other.code, code) || other.code == code)&&const DeepCollectionEquality().equals(other.params, _params)&&const DeepCollectionEquality().equals(other.extra, _extra));
}


@override
int get hashCode {
    return Object.hash(runtimeType,codeName,code,const DeepCollectionEquality().hash(_params),const DeepCollectionEquality().hash(_extra));
}

@override
String toString() {
    return 'ApiProblemPart(codeName: $codeName, code: $code, params: $params, extra: $extra)';
}


}

/// @nodoc
abstract mixin class _$ApiProblemPartCopyWith<$Res> implements $ApiProblemPartCopyWith<$Res> {
  factory _$ApiProblemPartCopyWith(_ApiProblemPart value, $Res Function(_ApiProblemPart) _then) = __$ApiProblemPartCopyWithImpl;
@override @useResult
$Res call({
 String codeName, api.ErrorCode? code, Map<String, Object?> params, Map<String, Object?> extra
});




}
/// @nodoc
class __$ApiProblemPartCopyWithImpl<$Res>
    implements _$ApiProblemPartCopyWith<$Res> {
  __$ApiProblemPartCopyWithImpl(this._self, this._then);

  final _ApiProblemPart _self;
  final $Res Function(_ApiProblemPart) _then;

/// Create a copy of ApiProblemPart
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? codeName = null,Object? code = freezed,Object? params = null,Object? extra = null,}) {
  return _then(_ApiProblemPart(
codeName: null == codeName ? _self.codeName : codeName // ignore: cast_nullable_to_non_nullable
as String,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as api.ErrorCode?,params: null == params ? _self._params : params // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,extra: null == extra ? _self._extra : extra // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}


}

// dart format on
