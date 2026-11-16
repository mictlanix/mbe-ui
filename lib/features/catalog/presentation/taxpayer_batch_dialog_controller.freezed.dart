// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'taxpayer_batch_dialog_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TaxpayerBatchDialogState {

/// `create` for a new series; `view` or `edit` for an existing one. The
/// Editar toggle moves `view` to `edit` in place.
 RecordFormMode get mode; String get series; FiscalDocumentKind? get kind; String get templateName; String get logo; String get headerHeight; String get footerHeight; List<TaxpayerBatchAccount> get accounts;/// A stable id per account row, parallel to [accounts], so a row's text
/// fields keep their state when rows are removed or moved.
 List<int> get accountIds; int get nextAccountId;/// Series and kind can't change: the series is in use. Starts as the
/// series' own flag and is set by the server's in-use refusal when
/// another user used the series after the list loaded (research R6).
 bool get locked;/// `true` after the first save attempt, so a blank new dialog doesn't
/// open already showing errors.
 bool get submitted; bool get submitting; bool get done;/// The issuer no longer exists (research R8): the dialog closes and the
/// screen goes back to the issuer list.
 bool get issuerGone;/// A [TaxpayerBatchDialogErrorCode] for the banner headline.
 String? get error;/// The server's refusal, kept as the error itself, never its text, so the
/// message is built when shown and follows the language (§III).
 AppError? get errorCause;/// Server refusals by field key: a validation type or message, or
/// [taxpayerBatchDuplicateSeries].
 Map<String, String> get serverErrors;
/// Create a copy of TaxpayerBatchDialogState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaxpayerBatchDialogStateCopyWith<TaxpayerBatchDialogState> get copyWith => _$TaxpayerBatchDialogStateCopyWithImpl<TaxpayerBatchDialogState>(this as TaxpayerBatchDialogState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TaxpayerBatchDialogState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaxpayerBatchDialogState&&(identical(other.mode, _this.mode) || other.mode == _this.mode)&&(identical(other.series, _this.series) || other.series == _this.series)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.templateName, _this.templateName) || other.templateName == _this.templateName)&&(identical(other.logo, _this.logo) || other.logo == _this.logo)&&(identical(other.headerHeight, _this.headerHeight) || other.headerHeight == _this.headerHeight)&&(identical(other.footerHeight, _this.footerHeight) || other.footerHeight == _this.footerHeight)&&const DeepCollectionEquality().equals(other.accounts, _this.accounts)&&const DeepCollectionEquality().equals(other.accountIds, _this.accountIds)&&(identical(other.nextAccountId, _this.nextAccountId) || other.nextAccountId == _this.nextAccountId)&&(identical(other.locked, _this.locked) || other.locked == _this.locked)&&(identical(other.submitted, _this.submitted) || other.submitted == _this.submitted)&&(identical(other.submitting, _this.submitting) || other.submitting == _this.submitting)&&(identical(other.done, _this.done) || other.done == _this.done)&&(identical(other.issuerGone, _this.issuerGone) || other.issuerGone == _this.issuerGone)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.errorCause, _this.errorCause) || other.errorCause == _this.errorCause)&&const DeepCollectionEquality().equals(other.serverErrors, _this.serverErrors));
}


@override
int get hashCode {
  final _this = this as TaxpayerBatchDialogState;
  return Object.hash(runtimeType,_this.mode,_this.series,_this.kind,_this.templateName,_this.logo,_this.headerHeight,_this.footerHeight,const DeepCollectionEquality().hash(_this.accounts),const DeepCollectionEquality().hash(_this.accountIds),_this.nextAccountId,_this.locked,_this.submitted,_this.submitting,_this.done,_this.issuerGone,_this.error,_this.errorCause,const DeepCollectionEquality().hash(_this.serverErrors));
}

@override
String toString() {
  final _this = this as TaxpayerBatchDialogState;
  return 'TaxpayerBatchDialogState(mode: ${_this.mode}, series: ${_this.series}, kind: ${_this.kind}, templateName: ${_this.templateName}, logo: ${_this.logo}, headerHeight: ${_this.headerHeight}, footerHeight: ${_this.footerHeight}, accounts: ${_this.accounts}, accountIds: ${_this.accountIds}, nextAccountId: ${_this.nextAccountId}, locked: ${_this.locked}, submitted: ${_this.submitted}, submitting: ${_this.submitting}, done: ${_this.done}, issuerGone: ${_this.issuerGone}, error: ${_this.error}, errorCause: ${_this.errorCause}, serverErrors: ${_this.serverErrors})';
}


}

/// @nodoc
abstract mixin class $TaxpayerBatchDialogStateCopyWith<$Res>  {
  factory $TaxpayerBatchDialogStateCopyWith(TaxpayerBatchDialogState value, $Res Function(TaxpayerBatchDialogState) _then) = _$TaxpayerBatchDialogStateCopyWithImpl;
@useResult
$Res call({
 RecordFormMode mode, String series, FiscalDocumentKind? kind, String templateName, String logo, String headerHeight, String footerHeight, List<TaxpayerBatchAccount> accounts, List<int> accountIds, int nextAccountId, bool locked, bool submitted, bool submitting, bool done, bool issuerGone, String? error, AppError? errorCause, Map<String, String> serverErrors
});


$AppErrorCopyWith<$Res>? get errorCause;

}
/// @nodoc
class _$TaxpayerBatchDialogStateCopyWithImpl<$Res>
    implements $TaxpayerBatchDialogStateCopyWith<$Res> {
  _$TaxpayerBatchDialogStateCopyWithImpl(this._self, this._then);

  final TaxpayerBatchDialogState _self;
  final $Res Function(TaxpayerBatchDialogState) _then;

/// Create a copy of TaxpayerBatchDialogState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mode = null,Object? series = null,Object? kind = freezed,Object? templateName = null,Object? logo = null,Object? headerHeight = null,Object? footerHeight = null,Object? accounts = null,Object? accountIds = null,Object? nextAccountId = null,Object? locked = null,Object? submitted = null,Object? submitting = null,Object? done = null,Object? issuerGone = null,Object? error = freezed,Object? errorCause = freezed,Object? serverErrors = null,}) {
  return _then(TaxpayerBatchDialogState(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as RecordFormMode,series: null == series ? _self.series : series // ignore: cast_nullable_to_non_nullable
as String,kind: freezed == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as FiscalDocumentKind?,templateName: null == templateName ? _self.templateName : templateName // ignore: cast_nullable_to_non_nullable
as String,logo: null == logo ? _self.logo : logo // ignore: cast_nullable_to_non_nullable
as String,headerHeight: null == headerHeight ? _self.headerHeight : headerHeight // ignore: cast_nullable_to_non_nullable
as String,footerHeight: null == footerHeight ? _self.footerHeight : footerHeight // ignore: cast_nullable_to_non_nullable
as String,accounts: null == accounts ? _self.accounts : accounts // ignore: cast_nullable_to_non_nullable
as List<TaxpayerBatchAccount>,accountIds: null == accountIds ? _self.accountIds : accountIds // ignore: cast_nullable_to_non_nullable
as List<int>,nextAccountId: null == nextAccountId ? _self.nextAccountId : nextAccountId // ignore: cast_nullable_to_non_nullable
as int,locked: null == locked ? _self.locked : locked // ignore: cast_nullable_to_non_nullable
as bool,submitted: null == submitted ? _self.submitted : submitted // ignore: cast_nullable_to_non_nullable
as bool,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,done: null == done ? _self.done : done // ignore: cast_nullable_to_non_nullable
as bool,issuerGone: null == issuerGone ? _self.issuerGone : issuerGone // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,errorCause: freezed == errorCause ? _self.errorCause : errorCause // ignore: cast_nullable_to_non_nullable
as AppError?,serverErrors: null == serverErrors ? _self.serverErrors : serverErrors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}
/// Create a copy of TaxpayerBatchDialogState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppErrorCopyWith<$Res>? get errorCause {
    if (_self.errorCause == null) {
    return null;
  }

  return $AppErrorCopyWith<$Res>(_self.errorCause!, (value) {
    return _then(_self.copyWith(errorCause: value));
  });
}
}


/// Adds pattern-matching-related methods to [TaxpayerBatchDialogState].
extension TaxpayerBatchDialogStatePatterns on TaxpayerBatchDialogState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaxpayerBatchDialogState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaxpayerBatchDialogState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaxpayerBatchDialogState value)  $default,){
final _that = this;
switch (_that) {
case _TaxpayerBatchDialogState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaxpayerBatchDialogState value)?  $default,){
final _that = this;
switch (_that) {
case _TaxpayerBatchDialogState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RecordFormMode mode,  String series,  FiscalDocumentKind? kind,  String templateName,  String logo,  String headerHeight,  String footerHeight,  List<TaxpayerBatchAccount> accounts,  List<int> accountIds,  int nextAccountId,  bool locked,  bool submitted,  bool submitting,  bool done,  bool issuerGone,  String? error,  AppError? errorCause,  Map<String, String> serverErrors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaxpayerBatchDialogState() when $default != null:
return $default(_that.mode,_that.series,_that.kind,_that.templateName,_that.logo,_that.headerHeight,_that.footerHeight,_that.accounts,_that.accountIds,_that.nextAccountId,_that.locked,_that.submitted,_that.submitting,_that.done,_that.issuerGone,_that.error,_that.errorCause,_that.serverErrors);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RecordFormMode mode,  String series,  FiscalDocumentKind? kind,  String templateName,  String logo,  String headerHeight,  String footerHeight,  List<TaxpayerBatchAccount> accounts,  List<int> accountIds,  int nextAccountId,  bool locked,  bool submitted,  bool submitting,  bool done,  bool issuerGone,  String? error,  AppError? errorCause,  Map<String, String> serverErrors)  $default,) {final _that = this;
switch (_that) {
case _TaxpayerBatchDialogState():
return $default(_that.mode,_that.series,_that.kind,_that.templateName,_that.logo,_that.headerHeight,_that.footerHeight,_that.accounts,_that.accountIds,_that.nextAccountId,_that.locked,_that.submitted,_that.submitting,_that.done,_that.issuerGone,_that.error,_that.errorCause,_that.serverErrors);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RecordFormMode mode,  String series,  FiscalDocumentKind? kind,  String templateName,  String logo,  String headerHeight,  String footerHeight,  List<TaxpayerBatchAccount> accounts,  List<int> accountIds,  int nextAccountId,  bool locked,  bool submitted,  bool submitting,  bool done,  bool issuerGone,  String? error,  AppError? errorCause,  Map<String, String> serverErrors)?  $default,) {final _that = this;
switch (_that) {
case _TaxpayerBatchDialogState() when $default != null:
return $default(_that.mode,_that.series,_that.kind,_that.templateName,_that.logo,_that.headerHeight,_that.footerHeight,_that.accounts,_that.accountIds,_that.nextAccountId,_that.locked,_that.submitted,_that.submitting,_that.done,_that.issuerGone,_that.error,_that.errorCause,_that.serverErrors);case _:
  return null;

}
}

}

/// @nodoc


class _TaxpayerBatchDialogState extends TaxpayerBatchDialogState {
  const _TaxpayerBatchDialogState({required this.mode, this.series = '', this.kind, this.templateName = '', this.logo = '', this.headerHeight = '0', this.footerHeight = '15',  List<TaxpayerBatchAccount> accounts = const <TaxpayerBatchAccount>[],  List<int> accountIds = const <int>[], this.nextAccountId = 0, this.locked = false, this.submitted = false, this.submitting = false, this.done = false, this.issuerGone = false, this.error, this.errorCause,  Map<String, String> serverErrors = const <String, String>{}}): _accounts = accounts,_accountIds = accountIds,_serverErrors = serverErrors,super._();
  

/// `create` for a new series; `view` or `edit` for an existing one. The
/// Editar toggle moves `view` to `edit` in place.
@override final  RecordFormMode mode;
@override@JsonKey() final  String series;
@override final  FiscalDocumentKind? kind;
@override@JsonKey() final  String templateName;
@override@JsonKey() final  String logo;
@override@JsonKey() final  String headerHeight;
@override@JsonKey() final  String footerHeight;
 final  List<TaxpayerBatchAccount> _accounts;
@override@JsonKey() List<TaxpayerBatchAccount> get accounts {
  if (_accounts is EqualUnmodifiableListView) return _accounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_accounts);
}

/// A stable id per account row, parallel to [accounts], so a row's text
/// fields keep their state when rows are removed or moved.
 final  List<int> _accountIds;
/// A stable id per account row, parallel to [accounts], so a row's text
/// fields keep their state when rows are removed or moved.
@override@JsonKey() List<int> get accountIds {
  if (_accountIds is EqualUnmodifiableListView) return _accountIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_accountIds);
}

@override@JsonKey() final  int nextAccountId;
/// Series and kind can't change: the series is in use. Starts as the
/// series' own flag and is set by the server's in-use refusal when
/// another user used the series after the list loaded (research R6).
@override@JsonKey() final  bool locked;
/// `true` after the first save attempt, so a blank new dialog doesn't
/// open already showing errors.
@override@JsonKey() final  bool submitted;
@override@JsonKey() final  bool submitting;
@override@JsonKey() final  bool done;
/// The issuer no longer exists (research R8): the dialog closes and the
/// screen goes back to the issuer list.
@override@JsonKey() final  bool issuerGone;
/// A [TaxpayerBatchDialogErrorCode] for the banner headline.
@override final  String? error;
/// The server's refusal, kept as the error itself, never its text, so the
/// message is built when shown and follows the language (§III).
@override final  AppError? errorCause;
/// Server refusals by field key: a validation type or message, or
/// [taxpayerBatchDuplicateSeries].
 final  Map<String, String> _serverErrors;
/// Server refusals by field key: a validation type or message, or
/// [taxpayerBatchDuplicateSeries].
@override@JsonKey() Map<String, String> get serverErrors {
  if (_serverErrors is EqualUnmodifiableMapView) return _serverErrors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_serverErrors);
}


/// Create a copy of TaxpayerBatchDialogState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaxpayerBatchDialogStateCopyWith<_TaxpayerBatchDialogState> get copyWith => __$TaxpayerBatchDialogStateCopyWithImpl<_TaxpayerBatchDialogState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaxpayerBatchDialogState&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.series, series) || other.series == series)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.templateName, templateName) || other.templateName == templateName)&&(identical(other.logo, logo) || other.logo == logo)&&(identical(other.headerHeight, headerHeight) || other.headerHeight == headerHeight)&&(identical(other.footerHeight, footerHeight) || other.footerHeight == footerHeight)&&const DeepCollectionEquality().equals(other.accounts, _accounts)&&const DeepCollectionEquality().equals(other.accountIds, _accountIds)&&(identical(other.nextAccountId, nextAccountId) || other.nextAccountId == nextAccountId)&&(identical(other.locked, locked) || other.locked == locked)&&(identical(other.submitted, submitted) || other.submitted == submitted)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.done, done) || other.done == done)&&(identical(other.issuerGone, issuerGone) || other.issuerGone == issuerGone)&&(identical(other.error, error) || other.error == error)&&(identical(other.errorCause, errorCause) || other.errorCause == errorCause)&&const DeepCollectionEquality().equals(other.serverErrors, _serverErrors));
}


@override
int get hashCode {
    return Object.hash(runtimeType,mode,series,kind,templateName,logo,headerHeight,footerHeight,const DeepCollectionEquality().hash(_accounts),const DeepCollectionEquality().hash(_accountIds),nextAccountId,locked,submitted,submitting,done,issuerGone,error,errorCause,const DeepCollectionEquality().hash(_serverErrors));
}

@override
String toString() {
    return 'TaxpayerBatchDialogState(mode: $mode, series: $series, kind: $kind, templateName: $templateName, logo: $logo, headerHeight: $headerHeight, footerHeight: $footerHeight, accounts: $accounts, accountIds: $accountIds, nextAccountId: $nextAccountId, locked: $locked, submitted: $submitted, submitting: $submitting, done: $done, issuerGone: $issuerGone, error: $error, errorCause: $errorCause, serverErrors: $serverErrors)';
}


}

/// @nodoc
abstract mixin class _$TaxpayerBatchDialogStateCopyWith<$Res> implements $TaxpayerBatchDialogStateCopyWith<$Res> {
  factory _$TaxpayerBatchDialogStateCopyWith(_TaxpayerBatchDialogState value, $Res Function(_TaxpayerBatchDialogState) _then) = __$TaxpayerBatchDialogStateCopyWithImpl;
@override @useResult
$Res call({
 RecordFormMode mode, String series, FiscalDocumentKind? kind, String templateName, String logo, String headerHeight, String footerHeight, List<TaxpayerBatchAccount> accounts, List<int> accountIds, int nextAccountId, bool locked, bool submitted, bool submitting, bool done, bool issuerGone, String? error, AppError? errorCause, Map<String, String> serverErrors
});


@override $AppErrorCopyWith<$Res>? get errorCause;

}
/// @nodoc
class __$TaxpayerBatchDialogStateCopyWithImpl<$Res>
    implements _$TaxpayerBatchDialogStateCopyWith<$Res> {
  __$TaxpayerBatchDialogStateCopyWithImpl(this._self, this._then);

  final _TaxpayerBatchDialogState _self;
  final $Res Function(_TaxpayerBatchDialogState) _then;

/// Create a copy of TaxpayerBatchDialogState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mode = null,Object? series = null,Object? kind = freezed,Object? templateName = null,Object? logo = null,Object? headerHeight = null,Object? footerHeight = null,Object? accounts = null,Object? accountIds = null,Object? nextAccountId = null,Object? locked = null,Object? submitted = null,Object? submitting = null,Object? done = null,Object? issuerGone = null,Object? error = freezed,Object? errorCause = freezed,Object? serverErrors = null,}) {
  return _then(_TaxpayerBatchDialogState(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as RecordFormMode,series: null == series ? _self.series : series // ignore: cast_nullable_to_non_nullable
as String,kind: freezed == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as FiscalDocumentKind?,templateName: null == templateName ? _self.templateName : templateName // ignore: cast_nullable_to_non_nullable
as String,logo: null == logo ? _self.logo : logo // ignore: cast_nullable_to_non_nullable
as String,headerHeight: null == headerHeight ? _self.headerHeight : headerHeight // ignore: cast_nullable_to_non_nullable
as String,footerHeight: null == footerHeight ? _self.footerHeight : footerHeight // ignore: cast_nullable_to_non_nullable
as String,accounts: null == accounts ? _self._accounts : accounts // ignore: cast_nullable_to_non_nullable
as List<TaxpayerBatchAccount>,accountIds: null == accountIds ? _self._accountIds : accountIds // ignore: cast_nullable_to_non_nullable
as List<int>,nextAccountId: null == nextAccountId ? _self.nextAccountId : nextAccountId // ignore: cast_nullable_to_non_nullable
as int,locked: null == locked ? _self.locked : locked // ignore: cast_nullable_to_non_nullable
as bool,submitted: null == submitted ? _self.submitted : submitted // ignore: cast_nullable_to_non_nullable
as bool,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,done: null == done ? _self.done : done // ignore: cast_nullable_to_non_nullable
as bool,issuerGone: null == issuerGone ? _self.issuerGone : issuerGone // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,errorCause: freezed == errorCause ? _self.errorCause : errorCause // ignore: cast_nullable_to_non_nullable
as AppError?,serverErrors: null == serverErrors ? _self._serverErrors : serverErrors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

/// Create a copy of TaxpayerBatchDialogState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppErrorCopyWith<$Res>? get errorCause {
    if (_self.errorCause == null) {
    return null;
  }

  return $AppErrorCopyWith<$Res>(_self.errorCause!, (value) {
    return _then(_self.copyWith(errorCause: value));
  });
}
}

// dart format on
