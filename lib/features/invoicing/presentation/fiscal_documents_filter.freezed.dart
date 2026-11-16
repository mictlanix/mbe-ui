// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fiscal_documents_filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FiscalDocumentsFilter {

/// Folio, UUID, or recipient RFC or name; `null` when empty.
 String? get search; FiscalDocumentStatus? get status;/// The document type code. A code the app doesn't know still applies.
 int? get kind; String? get issuerRfc;/// Both ends or neither: a half-open or reversed range is dropped.
 DateTime? get from; DateTime? get to; int get pageIndex;
/// Create a copy of FiscalDocumentsFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FiscalDocumentsFilterCopyWith<FiscalDocumentsFilter> get copyWith => _$FiscalDocumentsFilterCopyWithImpl<FiscalDocumentsFilter>(this as FiscalDocumentsFilter, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FiscalDocumentsFilter;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FiscalDocumentsFilter&&(identical(other.search, _this.search) || other.search == _this.search)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.issuerRfc, _this.issuerRfc) || other.issuerRfc == _this.issuerRfc)&&(identical(other.from, _this.from) || other.from == _this.from)&&(identical(other.to, _this.to) || other.to == _this.to)&&(identical(other.pageIndex, _this.pageIndex) || other.pageIndex == _this.pageIndex));
}


@override
int get hashCode {
  final _this = this as FiscalDocumentsFilter;
  return Object.hash(runtimeType,_this.search,_this.status,_this.kind,_this.issuerRfc,_this.from,_this.to,_this.pageIndex);
}

@override
String toString() {
  final _this = this as FiscalDocumentsFilter;
  return 'FiscalDocumentsFilter(search: ${_this.search}, status: ${_this.status}, kind: ${_this.kind}, issuerRfc: ${_this.issuerRfc}, from: ${_this.from}, to: ${_this.to}, pageIndex: ${_this.pageIndex})';
}


}

/// @nodoc
abstract mixin class $FiscalDocumentsFilterCopyWith<$Res>  {
  factory $FiscalDocumentsFilterCopyWith(FiscalDocumentsFilter value, $Res Function(FiscalDocumentsFilter) _then) = _$FiscalDocumentsFilterCopyWithImpl;
@useResult
$Res call({
 String? search, FiscalDocumentStatus? status, int? kind, String? issuerRfc, DateTime? from, DateTime? to, int pageIndex
});




}
/// @nodoc
class _$FiscalDocumentsFilterCopyWithImpl<$Res>
    implements $FiscalDocumentsFilterCopyWith<$Res> {
  _$FiscalDocumentsFilterCopyWithImpl(this._self, this._then);

  final FiscalDocumentsFilter _self;
  final $Res Function(FiscalDocumentsFilter) _then;

/// Create a copy of FiscalDocumentsFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? search = freezed,Object? status = freezed,Object? kind = freezed,Object? issuerRfc = freezed,Object? from = freezed,Object? to = freezed,Object? pageIndex = null,}) {
  return _then(FiscalDocumentsFilter(
search: freezed == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FiscalDocumentStatus?,kind: freezed == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as int?,issuerRfc: freezed == issuerRfc ? _self.issuerRfc : issuerRfc // ignore: cast_nullable_to_non_nullable
as String?,from: freezed == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime?,to: freezed == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime?,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [FiscalDocumentsFilter].
extension FiscalDocumentsFilterPatterns on FiscalDocumentsFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FiscalDocumentsFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FiscalDocumentsFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FiscalDocumentsFilter value)  $default,){
final _that = this;
switch (_that) {
case _FiscalDocumentsFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FiscalDocumentsFilter value)?  $default,){
final _that = this;
switch (_that) {
case _FiscalDocumentsFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? search,  FiscalDocumentStatus? status,  int? kind,  String? issuerRfc,  DateTime? from,  DateTime? to,  int pageIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FiscalDocumentsFilter() when $default != null:
return $default(_that.search,_that.status,_that.kind,_that.issuerRfc,_that.from,_that.to,_that.pageIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? search,  FiscalDocumentStatus? status,  int? kind,  String? issuerRfc,  DateTime? from,  DateTime? to,  int pageIndex)  $default,) {final _that = this;
switch (_that) {
case _FiscalDocumentsFilter():
return $default(_that.search,_that.status,_that.kind,_that.issuerRfc,_that.from,_that.to,_that.pageIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? search,  FiscalDocumentStatus? status,  int? kind,  String? issuerRfc,  DateTime? from,  DateTime? to,  int pageIndex)?  $default,) {final _that = this;
switch (_that) {
case _FiscalDocumentsFilter() when $default != null:
return $default(_that.search,_that.status,_that.kind,_that.issuerRfc,_that.from,_that.to,_that.pageIndex);case _:
  return null;

}
}

}

/// @nodoc


class _FiscalDocumentsFilter extends FiscalDocumentsFilter {
  const _FiscalDocumentsFilter({this.search, this.status, this.kind, this.issuerRfc, this.from, this.to, this.pageIndex = 0}): super._();
  

/// Folio, UUID, or recipient RFC or name; `null` when empty.
@override final  String? search;
@override final  FiscalDocumentStatus? status;
/// The document type code. A code the app doesn't know still applies.
@override final  int? kind;
@override final  String? issuerRfc;
/// Both ends or neither: a half-open or reversed range is dropped.
@override final  DateTime? from;
@override final  DateTime? to;
@override@JsonKey() final  int pageIndex;

/// Create a copy of FiscalDocumentsFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FiscalDocumentsFilterCopyWith<_FiscalDocumentsFilter> get copyWith => __$FiscalDocumentsFilterCopyWithImpl<_FiscalDocumentsFilter>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FiscalDocumentsFilter&&(identical(other.search, search) || other.search == search)&&(identical(other.status, status) || other.status == status)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.issuerRfc, issuerRfc) || other.issuerRfc == issuerRfc)&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&(identical(other.pageIndex, pageIndex) || other.pageIndex == pageIndex));
}


@override
int get hashCode {
    return Object.hash(runtimeType,search,status,kind,issuerRfc,from,to,pageIndex);
}

@override
String toString() {
    return 'FiscalDocumentsFilter(search: $search, status: $status, kind: $kind, issuerRfc: $issuerRfc, from: $from, to: $to, pageIndex: $pageIndex)';
}


}

/// @nodoc
abstract mixin class _$FiscalDocumentsFilterCopyWith<$Res> implements $FiscalDocumentsFilterCopyWith<$Res> {
  factory _$FiscalDocumentsFilterCopyWith(_FiscalDocumentsFilter value, $Res Function(_FiscalDocumentsFilter) _then) = __$FiscalDocumentsFilterCopyWithImpl;
@override @useResult
$Res call({
 String? search, FiscalDocumentStatus? status, int? kind, String? issuerRfc, DateTime? from, DateTime? to, int pageIndex
});




}
/// @nodoc
class __$FiscalDocumentsFilterCopyWithImpl<$Res>
    implements _$FiscalDocumentsFilterCopyWith<$Res> {
  __$FiscalDocumentsFilterCopyWithImpl(this._self, this._then);

  final _FiscalDocumentsFilter _self;
  final $Res Function(_FiscalDocumentsFilter) _then;

/// Create a copy of FiscalDocumentsFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? search = freezed,Object? status = freezed,Object? kind = freezed,Object? issuerRfc = freezed,Object? from = freezed,Object? to = freezed,Object? pageIndex = null,}) {
  return _then(_FiscalDocumentsFilter(
search: freezed == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FiscalDocumentStatus?,kind: freezed == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as int?,issuerRfc: freezed == issuerRfc ? _self.issuerRfc : issuerRfc // ignore: cast_nullable_to_non_nullable
as String?,from: freezed == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime?,to: freezed == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime?,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
