// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'commission_period.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CommissionMonth {

 int get year; int get month;
/// Create a copy of CommissionMonth
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommissionMonthCopyWith<CommissionMonth> get copyWith => _$CommissionMonthCopyWithImpl<CommissionMonth>(this as CommissionMonth, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CommissionMonth;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommissionMonth&&(identical(other.year, _this.year) || other.year == _this.year)&&(identical(other.month, _this.month) || other.month == _this.month));
}


@override
int get hashCode {
  final _this = this as CommissionMonth;
  return Object.hash(runtimeType,_this.year,_this.month);
}

@override
String toString() {
  final _this = this as CommissionMonth;
  return 'CommissionMonth(year: ${_this.year}, month: ${_this.month})';
}


}

/// @nodoc
abstract mixin class $CommissionMonthCopyWith<$Res>  {
  factory $CommissionMonthCopyWith(CommissionMonth value, $Res Function(CommissionMonth) _then) = _$CommissionMonthCopyWithImpl;
@useResult
$Res call({
 int year, int month
});




}
/// @nodoc
class _$CommissionMonthCopyWithImpl<$Res>
    implements $CommissionMonthCopyWith<$Res> {
  _$CommissionMonthCopyWithImpl(this._self, this._then);

  final CommissionMonth _self;
  final $Res Function(CommissionMonth) _then;

/// Create a copy of CommissionMonth
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? year = null,Object? month = null,}) {
  return _then(CommissionMonth(
year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CommissionMonth].
extension CommissionMonthPatterns on CommissionMonth {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommissionMonth value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommissionMonth() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommissionMonth value)  $default,){
final _that = this;
switch (_that) {
case _CommissionMonth():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommissionMonth value)?  $default,){
final _that = this;
switch (_that) {
case _CommissionMonth() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int year,  int month)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommissionMonth() when $default != null:
return $default(_that.year,_that.month);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int year,  int month)  $default,) {final _that = this;
switch (_that) {
case _CommissionMonth():
return $default(_that.year,_that.month);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int year,  int month)?  $default,) {final _that = this;
switch (_that) {
case _CommissionMonth() when $default != null:
return $default(_that.year,_that.month);case _:
  return null;

}
}

}

/// @nodoc


class _CommissionMonth extends CommissionMonth {
  const _CommissionMonth({required this.year, required this.month}): super._();
  

@override final  int year;
@override final  int month;

/// Create a copy of CommissionMonth
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommissionMonthCopyWith<_CommissionMonth> get copyWith => __$CommissionMonthCopyWithImpl<_CommissionMonth>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommissionMonth&&(identical(other.year, year) || other.year == year)&&(identical(other.month, month) || other.month == month));
}


@override
int get hashCode {
    return Object.hash(runtimeType,year,month);
}

@override
String toString() {
    return 'CommissionMonth(year: $year, month: $month)';
}


}

/// @nodoc
abstract mixin class _$CommissionMonthCopyWith<$Res> implements $CommissionMonthCopyWith<$Res> {
  factory _$CommissionMonthCopyWith(_CommissionMonth value, $Res Function(_CommissionMonth) _then) = __$CommissionMonthCopyWithImpl;
@override @useResult
$Res call({
 int year, int month
});




}
/// @nodoc
class __$CommissionMonthCopyWithImpl<$Res>
    implements _$CommissionMonthCopyWith<$Res> {
  __$CommissionMonthCopyWithImpl(this._self, this._then);

  final _CommissionMonth _self;
  final $Res Function(_CommissionMonth) _then;

/// Create a copy of CommissionMonth
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? year = null,Object? month = null,}) {
  return _then(_CommissionMonth(
year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$CommissionPeriodSummary {

 CommissionMonth get month; CommissionPeriodStatus get status;/// Zero for a reopened month.
 Decimal get total; DateTime? get closedAt; DateTime? get paidAt; DateTime? get reopenedAt;/// Employee ids.
 int? get closedBy; int? get paidBy; int? get reopenedBy;
/// Create a copy of CommissionPeriodSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommissionPeriodSummaryCopyWith<CommissionPeriodSummary> get copyWith => _$CommissionPeriodSummaryCopyWithImpl<CommissionPeriodSummary>(this as CommissionPeriodSummary, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CommissionPeriodSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommissionPeriodSummary&&(identical(other.month, _this.month) || other.month == _this.month)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.total, _this.total) || other.total == _this.total)&&(identical(other.closedAt, _this.closedAt) || other.closedAt == _this.closedAt)&&(identical(other.paidAt, _this.paidAt) || other.paidAt == _this.paidAt)&&(identical(other.reopenedAt, _this.reopenedAt) || other.reopenedAt == _this.reopenedAt)&&(identical(other.closedBy, _this.closedBy) || other.closedBy == _this.closedBy)&&(identical(other.paidBy, _this.paidBy) || other.paidBy == _this.paidBy)&&(identical(other.reopenedBy, _this.reopenedBy) || other.reopenedBy == _this.reopenedBy));
}


@override
int get hashCode {
  final _this = this as CommissionPeriodSummary;
  return Object.hash(runtimeType,_this.month,_this.status,_this.total,_this.closedAt,_this.paidAt,_this.reopenedAt,_this.closedBy,_this.paidBy,_this.reopenedBy);
}

@override
String toString() {
  final _this = this as CommissionPeriodSummary;
  return 'CommissionPeriodSummary(month: ${_this.month}, status: ${_this.status}, total: ${_this.total}, closedAt: ${_this.closedAt}, paidAt: ${_this.paidAt}, reopenedAt: ${_this.reopenedAt}, closedBy: ${_this.closedBy}, paidBy: ${_this.paidBy}, reopenedBy: ${_this.reopenedBy})';
}


}

/// @nodoc
abstract mixin class $CommissionPeriodSummaryCopyWith<$Res>  {
  factory $CommissionPeriodSummaryCopyWith(CommissionPeriodSummary value, $Res Function(CommissionPeriodSummary) _then) = _$CommissionPeriodSummaryCopyWithImpl;
@useResult
$Res call({
 CommissionMonth month, CommissionPeriodStatus status, Decimal total, DateTime? closedAt, DateTime? paidAt, DateTime? reopenedAt, int? closedBy, int? paidBy, int? reopenedBy
});


$CommissionMonthCopyWith<$Res> get month;

}
/// @nodoc
class _$CommissionPeriodSummaryCopyWithImpl<$Res>
    implements $CommissionPeriodSummaryCopyWith<$Res> {
  _$CommissionPeriodSummaryCopyWithImpl(this._self, this._then);

  final CommissionPeriodSummary _self;
  final $Res Function(CommissionPeriodSummary) _then;

/// Create a copy of CommissionPeriodSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? month = null,Object? status = null,Object? total = null,Object? closedAt = freezed,Object? paidAt = freezed,Object? reopenedAt = freezed,Object? closedBy = freezed,Object? paidBy = freezed,Object? reopenedBy = freezed,}) {
  return _then(CommissionPeriodSummary(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as CommissionMonth,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CommissionPeriodStatus,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as Decimal,closedAt: freezed == closedAt ? _self.closedAt : closedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reopenedAt: freezed == reopenedAt ? _self.reopenedAt : reopenedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,closedBy: freezed == closedBy ? _self.closedBy : closedBy // ignore: cast_nullable_to_non_nullable
as int?,paidBy: freezed == paidBy ? _self.paidBy : paidBy // ignore: cast_nullable_to_non_nullable
as int?,reopenedBy: freezed == reopenedBy ? _self.reopenedBy : reopenedBy // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}
/// Create a copy of CommissionPeriodSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommissionMonthCopyWith<$Res> get month {
  
  return $CommissionMonthCopyWith<$Res>(_self.month, (value) {
    return _then(_self.copyWith(month: value));
  });
}
}


/// Adds pattern-matching-related methods to [CommissionPeriodSummary].
extension CommissionPeriodSummaryPatterns on CommissionPeriodSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommissionPeriodSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommissionPeriodSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommissionPeriodSummary value)  $default,){
final _that = this;
switch (_that) {
case _CommissionPeriodSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommissionPeriodSummary value)?  $default,){
final _that = this;
switch (_that) {
case _CommissionPeriodSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CommissionMonth month,  CommissionPeriodStatus status,  Decimal total,  DateTime? closedAt,  DateTime? paidAt,  DateTime? reopenedAt,  int? closedBy,  int? paidBy,  int? reopenedBy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommissionPeriodSummary() when $default != null:
return $default(_that.month,_that.status,_that.total,_that.closedAt,_that.paidAt,_that.reopenedAt,_that.closedBy,_that.paidBy,_that.reopenedBy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CommissionMonth month,  CommissionPeriodStatus status,  Decimal total,  DateTime? closedAt,  DateTime? paidAt,  DateTime? reopenedAt,  int? closedBy,  int? paidBy,  int? reopenedBy)  $default,) {final _that = this;
switch (_that) {
case _CommissionPeriodSummary():
return $default(_that.month,_that.status,_that.total,_that.closedAt,_that.paidAt,_that.reopenedAt,_that.closedBy,_that.paidBy,_that.reopenedBy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CommissionMonth month,  CommissionPeriodStatus status,  Decimal total,  DateTime? closedAt,  DateTime? paidAt,  DateTime? reopenedAt,  int? closedBy,  int? paidBy,  int? reopenedBy)?  $default,) {final _that = this;
switch (_that) {
case _CommissionPeriodSummary() when $default != null:
return $default(_that.month,_that.status,_that.total,_that.closedAt,_that.paidAt,_that.reopenedAt,_that.closedBy,_that.paidBy,_that.reopenedBy);case _:
  return null;

}
}

}

/// @nodoc


class _CommissionPeriodSummary implements CommissionPeriodSummary {
  const _CommissionPeriodSummary({required this.month, required this.status, required this.total, this.closedAt, this.paidAt, this.reopenedAt, this.closedBy, this.paidBy, this.reopenedBy});
  

@override final  CommissionMonth month;
@override final  CommissionPeriodStatus status;
/// Zero for a reopened month.
@override final  Decimal total;
@override final  DateTime? closedAt;
@override final  DateTime? paidAt;
@override final  DateTime? reopenedAt;
/// Employee ids.
@override final  int? closedBy;
@override final  int? paidBy;
@override final  int? reopenedBy;

/// Create a copy of CommissionPeriodSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommissionPeriodSummaryCopyWith<_CommissionPeriodSummary> get copyWith => __$CommissionPeriodSummaryCopyWithImpl<_CommissionPeriodSummary>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommissionPeriodSummary&&(identical(other.month, month) || other.month == month)&&(identical(other.status, status) || other.status == status)&&(identical(other.total, total) || other.total == total)&&(identical(other.closedAt, closedAt) || other.closedAt == closedAt)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.reopenedAt, reopenedAt) || other.reopenedAt == reopenedAt)&&(identical(other.closedBy, closedBy) || other.closedBy == closedBy)&&(identical(other.paidBy, paidBy) || other.paidBy == paidBy)&&(identical(other.reopenedBy, reopenedBy) || other.reopenedBy == reopenedBy));
}


@override
int get hashCode {
    return Object.hash(runtimeType,month,status,total,closedAt,paidAt,reopenedAt,closedBy,paidBy,reopenedBy);
}

@override
String toString() {
    return 'CommissionPeriodSummary(month: $month, status: $status, total: $total, closedAt: $closedAt, paidAt: $paidAt, reopenedAt: $reopenedAt, closedBy: $closedBy, paidBy: $paidBy, reopenedBy: $reopenedBy)';
}


}

/// @nodoc
abstract mixin class _$CommissionPeriodSummaryCopyWith<$Res> implements $CommissionPeriodSummaryCopyWith<$Res> {
  factory _$CommissionPeriodSummaryCopyWith(_CommissionPeriodSummary value, $Res Function(_CommissionPeriodSummary) _then) = __$CommissionPeriodSummaryCopyWithImpl;
@override @useResult
$Res call({
 CommissionMonth month, CommissionPeriodStatus status, Decimal total, DateTime? closedAt, DateTime? paidAt, DateTime? reopenedAt, int? closedBy, int? paidBy, int? reopenedBy
});


@override $CommissionMonthCopyWith<$Res> get month;

}
/// @nodoc
class __$CommissionPeriodSummaryCopyWithImpl<$Res>
    implements _$CommissionPeriodSummaryCopyWith<$Res> {
  __$CommissionPeriodSummaryCopyWithImpl(this._self, this._then);

  final _CommissionPeriodSummary _self;
  final $Res Function(_CommissionPeriodSummary) _then;

/// Create a copy of CommissionPeriodSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? month = null,Object? status = null,Object? total = null,Object? closedAt = freezed,Object? paidAt = freezed,Object? reopenedAt = freezed,Object? closedBy = freezed,Object? paidBy = freezed,Object? reopenedBy = freezed,}) {
  return _then(_CommissionPeriodSummary(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as CommissionMonth,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CommissionPeriodStatus,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as Decimal,closedAt: freezed == closedAt ? _self.closedAt : closedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reopenedAt: freezed == reopenedAt ? _self.reopenedAt : reopenedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,closedBy: freezed == closedBy ? _self.closedBy : closedBy // ignore: cast_nullable_to_non_nullable
as int?,paidBy: freezed == paidBy ? _self.paidBy : paidBy // ignore: cast_nullable_to_non_nullable
as int?,reopenedBy: freezed == reopenedBy ? _self.reopenedBy : reopenedBy // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of CommissionPeriodSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommissionMonthCopyWith<$Res> get month {
  
  return $CommissionMonthCopyWith<$Res>(_self.month, (value) {
    return _then(_self.copyWith(month: value));
  });
}
}

/// @nodoc
mixin _$CommissionTotal {

 int get agentId;/// Null means "no label".
 int? get labelId; String? get labelName; int get lines; Decimal get commission;
/// Create a copy of CommissionTotal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommissionTotalCopyWith<CommissionTotal> get copyWith => _$CommissionTotalCopyWithImpl<CommissionTotal>(this as CommissionTotal, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CommissionTotal;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommissionTotal&&(identical(other.agentId, _this.agentId) || other.agentId == _this.agentId)&&(identical(other.labelId, _this.labelId) || other.labelId == _this.labelId)&&(identical(other.labelName, _this.labelName) || other.labelName == _this.labelName)&&(identical(other.lines, _this.lines) || other.lines == _this.lines)&&(identical(other.commission, _this.commission) || other.commission == _this.commission));
}


@override
int get hashCode {
  final _this = this as CommissionTotal;
  return Object.hash(runtimeType,_this.agentId,_this.labelId,_this.labelName,_this.lines,_this.commission);
}

@override
String toString() {
  final _this = this as CommissionTotal;
  return 'CommissionTotal(agentId: ${_this.agentId}, labelId: ${_this.labelId}, labelName: ${_this.labelName}, lines: ${_this.lines}, commission: ${_this.commission})';
}


}

/// @nodoc
abstract mixin class $CommissionTotalCopyWith<$Res>  {
  factory $CommissionTotalCopyWith(CommissionTotal value, $Res Function(CommissionTotal) _then) = _$CommissionTotalCopyWithImpl;
@useResult
$Res call({
 int agentId, int? labelId, String? labelName, int lines, Decimal commission
});




}
/// @nodoc
class _$CommissionTotalCopyWithImpl<$Res>
    implements $CommissionTotalCopyWith<$Res> {
  _$CommissionTotalCopyWithImpl(this._self, this._then);

  final CommissionTotal _self;
  final $Res Function(CommissionTotal) _then;

/// Create a copy of CommissionTotal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? agentId = null,Object? labelId = freezed,Object? labelName = freezed,Object? lines = null,Object? commission = null,}) {
  return _then(CommissionTotal(
agentId: null == agentId ? _self.agentId : agentId // ignore: cast_nullable_to_non_nullable
as int,labelId: freezed == labelId ? _self.labelId : labelId // ignore: cast_nullable_to_non_nullable
as int?,labelName: freezed == labelName ? _self.labelName : labelName // ignore: cast_nullable_to_non_nullable
as String?,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as int,commission: null == commission ? _self.commission : commission // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}

}


/// Adds pattern-matching-related methods to [CommissionTotal].
extension CommissionTotalPatterns on CommissionTotal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommissionTotal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommissionTotal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommissionTotal value)  $default,){
final _that = this;
switch (_that) {
case _CommissionTotal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommissionTotal value)?  $default,){
final _that = this;
switch (_that) {
case _CommissionTotal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int agentId,  int? labelId,  String? labelName,  int lines,  Decimal commission)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommissionTotal() when $default != null:
return $default(_that.agentId,_that.labelId,_that.labelName,_that.lines,_that.commission);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int agentId,  int? labelId,  String? labelName,  int lines,  Decimal commission)  $default,) {final _that = this;
switch (_that) {
case _CommissionTotal():
return $default(_that.agentId,_that.labelId,_that.labelName,_that.lines,_that.commission);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int agentId,  int? labelId,  String? labelName,  int lines,  Decimal commission)?  $default,) {final _that = this;
switch (_that) {
case _CommissionTotal() when $default != null:
return $default(_that.agentId,_that.labelId,_that.labelName,_that.lines,_that.commission);case _:
  return null;

}
}

}

/// @nodoc


class _CommissionTotal implements CommissionTotal {
  const _CommissionTotal({required this.agentId, this.labelId, this.labelName, required this.lines, required this.commission});
  

@override final  int agentId;
/// Null means "no label".
@override final  int? labelId;
@override final  String? labelName;
@override final  int lines;
@override final  Decimal commission;

/// Create a copy of CommissionTotal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommissionTotalCopyWith<_CommissionTotal> get copyWith => __$CommissionTotalCopyWithImpl<_CommissionTotal>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommissionTotal&&(identical(other.agentId, agentId) || other.agentId == agentId)&&(identical(other.labelId, labelId) || other.labelId == labelId)&&(identical(other.labelName, labelName) || other.labelName == labelName)&&(identical(other.lines, lines) || other.lines == lines)&&(identical(other.commission, commission) || other.commission == commission));
}


@override
int get hashCode {
    return Object.hash(runtimeType,agentId,labelId,labelName,lines,commission);
}

@override
String toString() {
    return 'CommissionTotal(agentId: $agentId, labelId: $labelId, labelName: $labelName, lines: $lines, commission: $commission)';
}


}

/// @nodoc
abstract mixin class _$CommissionTotalCopyWith<$Res> implements $CommissionTotalCopyWith<$Res> {
  factory _$CommissionTotalCopyWith(_CommissionTotal value, $Res Function(_CommissionTotal) _then) = __$CommissionTotalCopyWithImpl;
@override @useResult
$Res call({
 int agentId, int? labelId, String? labelName, int lines, Decimal commission
});




}
/// @nodoc
class __$CommissionTotalCopyWithImpl<$Res>
    implements _$CommissionTotalCopyWith<$Res> {
  __$CommissionTotalCopyWithImpl(this._self, this._then);

  final _CommissionTotal _self;
  final $Res Function(_CommissionTotal) _then;

/// Create a copy of CommissionTotal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? agentId = null,Object? labelId = freezed,Object? labelName = freezed,Object? lines = null,Object? commission = null,}) {
  return _then(_CommissionTotal(
agentId: null == agentId ? _self.agentId : agentId // ignore: cast_nullable_to_non_nullable
as int,labelId: freezed == labelId ? _self.labelId : labelId // ignore: cast_nullable_to_non_nullable
as int?,labelName: freezed == labelName ? _self.labelName : labelName // ignore: cast_nullable_to_non_nullable
as String?,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as int,commission: null == commission ? _self.commission : commission // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}


}

/// @nodoc
mixin _$CommissionLine {

 CommissionMovement get movement; CommissionScheme get scheme; int get salesOrderId; int get salesOrderDetailId; int? get customerRefundDetailId; DateTime get orderDate; DateTime get paidDate; int get customerId; String get customerName; int get productId; String get productName; int? get labelId; String? get labelName; Decimal get labelRate; int get agentId; int get orderSalespersonId; int get customerSalespersonId; int get participationId; String get participationName; Decimal get participationRate; Decimal get rate; Decimal get price; Decimal get quantity; Decimal get total; Decimal get fullCommission;/// Only for scheme-2 sales.
 Decimal? get share; Decimal get commission;
/// Create a copy of CommissionLine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommissionLineCopyWith<CommissionLine> get copyWith => _$CommissionLineCopyWithImpl<CommissionLine>(this as CommissionLine, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CommissionLine;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommissionLine&&(identical(other.movement, _this.movement) || other.movement == _this.movement)&&(identical(other.scheme, _this.scheme) || other.scheme == _this.scheme)&&(identical(other.salesOrderId, _this.salesOrderId) || other.salesOrderId == _this.salesOrderId)&&(identical(other.salesOrderDetailId, _this.salesOrderDetailId) || other.salesOrderDetailId == _this.salesOrderDetailId)&&(identical(other.customerRefundDetailId, _this.customerRefundDetailId) || other.customerRefundDetailId == _this.customerRefundDetailId)&&(identical(other.orderDate, _this.orderDate) || other.orderDate == _this.orderDate)&&(identical(other.paidDate, _this.paidDate) || other.paidDate == _this.paidDate)&&(identical(other.customerId, _this.customerId) || other.customerId == _this.customerId)&&(identical(other.customerName, _this.customerName) || other.customerName == _this.customerName)&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.productName, _this.productName) || other.productName == _this.productName)&&(identical(other.labelId, _this.labelId) || other.labelId == _this.labelId)&&(identical(other.labelName, _this.labelName) || other.labelName == _this.labelName)&&(identical(other.labelRate, _this.labelRate) || other.labelRate == _this.labelRate)&&(identical(other.agentId, _this.agentId) || other.agentId == _this.agentId)&&(identical(other.orderSalespersonId, _this.orderSalespersonId) || other.orderSalespersonId == _this.orderSalespersonId)&&(identical(other.customerSalespersonId, _this.customerSalespersonId) || other.customerSalespersonId == _this.customerSalespersonId)&&(identical(other.participationId, _this.participationId) || other.participationId == _this.participationId)&&(identical(other.participationName, _this.participationName) || other.participationName == _this.participationName)&&(identical(other.participationRate, _this.participationRate) || other.participationRate == _this.participationRate)&&(identical(other.rate, _this.rate) || other.rate == _this.rate)&&(identical(other.price, _this.price) || other.price == _this.price)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity)&&(identical(other.total, _this.total) || other.total == _this.total)&&(identical(other.fullCommission, _this.fullCommission) || other.fullCommission == _this.fullCommission)&&(identical(other.share, _this.share) || other.share == _this.share)&&(identical(other.commission, _this.commission) || other.commission == _this.commission));
}


@override
int get hashCode {
  final _this = this as CommissionLine;
  return Object.hashAll([runtimeType,_this.movement,_this.scheme,_this.salesOrderId,_this.salesOrderDetailId,_this.customerRefundDetailId,_this.orderDate,_this.paidDate,_this.customerId,_this.customerName,_this.productId,_this.productName,_this.labelId,_this.labelName,_this.labelRate,_this.agentId,_this.orderSalespersonId,_this.customerSalespersonId,_this.participationId,_this.participationName,_this.participationRate,_this.rate,_this.price,_this.quantity,_this.total,_this.fullCommission,_this.share,_this.commission]);
}

@override
String toString() {
  final _this = this as CommissionLine;
  return 'CommissionLine(movement: ${_this.movement}, scheme: ${_this.scheme}, salesOrderId: ${_this.salesOrderId}, salesOrderDetailId: ${_this.salesOrderDetailId}, customerRefundDetailId: ${_this.customerRefundDetailId}, orderDate: ${_this.orderDate}, paidDate: ${_this.paidDate}, customerId: ${_this.customerId}, customerName: ${_this.customerName}, productId: ${_this.productId}, productName: ${_this.productName}, labelId: ${_this.labelId}, labelName: ${_this.labelName}, labelRate: ${_this.labelRate}, agentId: ${_this.agentId}, orderSalespersonId: ${_this.orderSalespersonId}, customerSalespersonId: ${_this.customerSalespersonId}, participationId: ${_this.participationId}, participationName: ${_this.participationName}, participationRate: ${_this.participationRate}, rate: ${_this.rate}, price: ${_this.price}, quantity: ${_this.quantity}, total: ${_this.total}, fullCommission: ${_this.fullCommission}, share: ${_this.share}, commission: ${_this.commission})';
}


}

/// @nodoc
abstract mixin class $CommissionLineCopyWith<$Res>  {
  factory $CommissionLineCopyWith(CommissionLine value, $Res Function(CommissionLine) _then) = _$CommissionLineCopyWithImpl;
@useResult
$Res call({
 CommissionMovement movement, CommissionScheme scheme, int salesOrderId, int salesOrderDetailId, int? customerRefundDetailId, DateTime orderDate, DateTime paidDate, int customerId, String customerName, int productId, String productName, int? labelId, String? labelName, Decimal labelRate, int agentId, int orderSalespersonId, int customerSalespersonId, int participationId, String participationName, Decimal participationRate, Decimal rate, Decimal price, Decimal quantity, Decimal total, Decimal fullCommission, Decimal? share, Decimal commission
});




}
/// @nodoc
class _$CommissionLineCopyWithImpl<$Res>
    implements $CommissionLineCopyWith<$Res> {
  _$CommissionLineCopyWithImpl(this._self, this._then);

  final CommissionLine _self;
  final $Res Function(CommissionLine) _then;

/// Create a copy of CommissionLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? movement = null,Object? scheme = null,Object? salesOrderId = null,Object? salesOrderDetailId = null,Object? customerRefundDetailId = freezed,Object? orderDate = null,Object? paidDate = null,Object? customerId = null,Object? customerName = null,Object? productId = null,Object? productName = null,Object? labelId = freezed,Object? labelName = freezed,Object? labelRate = null,Object? agentId = null,Object? orderSalespersonId = null,Object? customerSalespersonId = null,Object? participationId = null,Object? participationName = null,Object? participationRate = null,Object? rate = null,Object? price = null,Object? quantity = null,Object? total = null,Object? fullCommission = null,Object? share = freezed,Object? commission = null,}) {
  return _then(CommissionLine(
movement: null == movement ? _self.movement : movement // ignore: cast_nullable_to_non_nullable
as CommissionMovement,scheme: null == scheme ? _self.scheme : scheme // ignore: cast_nullable_to_non_nullable
as CommissionScheme,salesOrderId: null == salesOrderId ? _self.salesOrderId : salesOrderId // ignore: cast_nullable_to_non_nullable
as int,salesOrderDetailId: null == salesOrderDetailId ? _self.salesOrderDetailId : salesOrderDetailId // ignore: cast_nullable_to_non_nullable
as int,customerRefundDetailId: freezed == customerRefundDetailId ? _self.customerRefundDetailId : customerRefundDetailId // ignore: cast_nullable_to_non_nullable
as int?,orderDate: null == orderDate ? _self.orderDate : orderDate // ignore: cast_nullable_to_non_nullable
as DateTime,paidDate: null == paidDate ? _self.paidDate : paidDate // ignore: cast_nullable_to_non_nullable
as DateTime,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as int,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,labelId: freezed == labelId ? _self.labelId : labelId // ignore: cast_nullable_to_non_nullable
as int?,labelName: freezed == labelName ? _self.labelName : labelName // ignore: cast_nullable_to_non_nullable
as String?,labelRate: null == labelRate ? _self.labelRate : labelRate // ignore: cast_nullable_to_non_nullable
as Decimal,agentId: null == agentId ? _self.agentId : agentId // ignore: cast_nullable_to_non_nullable
as int,orderSalespersonId: null == orderSalespersonId ? _self.orderSalespersonId : orderSalespersonId // ignore: cast_nullable_to_non_nullable
as int,customerSalespersonId: null == customerSalespersonId ? _self.customerSalespersonId : customerSalespersonId // ignore: cast_nullable_to_non_nullable
as int,participationId: null == participationId ? _self.participationId : participationId // ignore: cast_nullable_to_non_nullable
as int,participationName: null == participationName ? _self.participationName : participationName // ignore: cast_nullable_to_non_nullable
as String,participationRate: null == participationRate ? _self.participationRate : participationRate // ignore: cast_nullable_to_non_nullable
as Decimal,rate: null == rate ? _self.rate : rate // ignore: cast_nullable_to_non_nullable
as Decimal,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as Decimal,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Decimal,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as Decimal,fullCommission: null == fullCommission ? _self.fullCommission : fullCommission // ignore: cast_nullable_to_non_nullable
as Decimal,share: freezed == share ? _self.share : share // ignore: cast_nullable_to_non_nullable
as Decimal?,commission: null == commission ? _self.commission : commission // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}

}


/// Adds pattern-matching-related methods to [CommissionLine].
extension CommissionLinePatterns on CommissionLine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommissionLine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommissionLine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommissionLine value)  $default,){
final _that = this;
switch (_that) {
case _CommissionLine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommissionLine value)?  $default,){
final _that = this;
switch (_that) {
case _CommissionLine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CommissionMovement movement,  CommissionScheme scheme,  int salesOrderId,  int salesOrderDetailId,  int? customerRefundDetailId,  DateTime orderDate,  DateTime paidDate,  int customerId,  String customerName,  int productId,  String productName,  int? labelId,  String? labelName,  Decimal labelRate,  int agentId,  int orderSalespersonId,  int customerSalespersonId,  int participationId,  String participationName,  Decimal participationRate,  Decimal rate,  Decimal price,  Decimal quantity,  Decimal total,  Decimal fullCommission,  Decimal? share,  Decimal commission)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommissionLine() when $default != null:
return $default(_that.movement,_that.scheme,_that.salesOrderId,_that.salesOrderDetailId,_that.customerRefundDetailId,_that.orderDate,_that.paidDate,_that.customerId,_that.customerName,_that.productId,_that.productName,_that.labelId,_that.labelName,_that.labelRate,_that.agentId,_that.orderSalespersonId,_that.customerSalespersonId,_that.participationId,_that.participationName,_that.participationRate,_that.rate,_that.price,_that.quantity,_that.total,_that.fullCommission,_that.share,_that.commission);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CommissionMovement movement,  CommissionScheme scheme,  int salesOrderId,  int salesOrderDetailId,  int? customerRefundDetailId,  DateTime orderDate,  DateTime paidDate,  int customerId,  String customerName,  int productId,  String productName,  int? labelId,  String? labelName,  Decimal labelRate,  int agentId,  int orderSalespersonId,  int customerSalespersonId,  int participationId,  String participationName,  Decimal participationRate,  Decimal rate,  Decimal price,  Decimal quantity,  Decimal total,  Decimal fullCommission,  Decimal? share,  Decimal commission)  $default,) {final _that = this;
switch (_that) {
case _CommissionLine():
return $default(_that.movement,_that.scheme,_that.salesOrderId,_that.salesOrderDetailId,_that.customerRefundDetailId,_that.orderDate,_that.paidDate,_that.customerId,_that.customerName,_that.productId,_that.productName,_that.labelId,_that.labelName,_that.labelRate,_that.agentId,_that.orderSalespersonId,_that.customerSalespersonId,_that.participationId,_that.participationName,_that.participationRate,_that.rate,_that.price,_that.quantity,_that.total,_that.fullCommission,_that.share,_that.commission);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CommissionMovement movement,  CommissionScheme scheme,  int salesOrderId,  int salesOrderDetailId,  int? customerRefundDetailId,  DateTime orderDate,  DateTime paidDate,  int customerId,  String customerName,  int productId,  String productName,  int? labelId,  String? labelName,  Decimal labelRate,  int agentId,  int orderSalespersonId,  int customerSalespersonId,  int participationId,  String participationName,  Decimal participationRate,  Decimal rate,  Decimal price,  Decimal quantity,  Decimal total,  Decimal fullCommission,  Decimal? share,  Decimal commission)?  $default,) {final _that = this;
switch (_that) {
case _CommissionLine() when $default != null:
return $default(_that.movement,_that.scheme,_that.salesOrderId,_that.salesOrderDetailId,_that.customerRefundDetailId,_that.orderDate,_that.paidDate,_that.customerId,_that.customerName,_that.productId,_that.productName,_that.labelId,_that.labelName,_that.labelRate,_that.agentId,_that.orderSalespersonId,_that.customerSalespersonId,_that.participationId,_that.participationName,_that.participationRate,_that.rate,_that.price,_that.quantity,_that.total,_that.fullCommission,_that.share,_that.commission);case _:
  return null;

}
}

}

/// @nodoc


class _CommissionLine implements CommissionLine {
  const _CommissionLine({required this.movement, required this.scheme, required this.salesOrderId, required this.salesOrderDetailId, this.customerRefundDetailId, required this.orderDate, required this.paidDate, required this.customerId, required this.customerName, required this.productId, required this.productName, this.labelId, this.labelName, required this.labelRate, required this.agentId, required this.orderSalespersonId, required this.customerSalespersonId, required this.participationId, required this.participationName, required this.participationRate, required this.rate, required this.price, required this.quantity, required this.total, required this.fullCommission, this.share, required this.commission});
  

@override final  CommissionMovement movement;
@override final  CommissionScheme scheme;
@override final  int salesOrderId;
@override final  int salesOrderDetailId;
@override final  int? customerRefundDetailId;
@override final  DateTime orderDate;
@override final  DateTime paidDate;
@override final  int customerId;
@override final  String customerName;
@override final  int productId;
@override final  String productName;
@override final  int? labelId;
@override final  String? labelName;
@override final  Decimal labelRate;
@override final  int agentId;
@override final  int orderSalespersonId;
@override final  int customerSalespersonId;
@override final  int participationId;
@override final  String participationName;
@override final  Decimal participationRate;
@override final  Decimal rate;
@override final  Decimal price;
@override final  Decimal quantity;
@override final  Decimal total;
@override final  Decimal fullCommission;
/// Only for scheme-2 sales.
@override final  Decimal? share;
@override final  Decimal commission;

/// Create a copy of CommissionLine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommissionLineCopyWith<_CommissionLine> get copyWith => __$CommissionLineCopyWithImpl<_CommissionLine>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommissionLine&&(identical(other.movement, movement) || other.movement == movement)&&(identical(other.scheme, scheme) || other.scheme == scheme)&&(identical(other.salesOrderId, salesOrderId) || other.salesOrderId == salesOrderId)&&(identical(other.salesOrderDetailId, salesOrderDetailId) || other.salesOrderDetailId == salesOrderDetailId)&&(identical(other.customerRefundDetailId, customerRefundDetailId) || other.customerRefundDetailId == customerRefundDetailId)&&(identical(other.orderDate, orderDate) || other.orderDate == orderDate)&&(identical(other.paidDate, paidDate) || other.paidDate == paidDate)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.labelId, labelId) || other.labelId == labelId)&&(identical(other.labelName, labelName) || other.labelName == labelName)&&(identical(other.labelRate, labelRate) || other.labelRate == labelRate)&&(identical(other.agentId, agentId) || other.agentId == agentId)&&(identical(other.orderSalespersonId, orderSalespersonId) || other.orderSalespersonId == orderSalespersonId)&&(identical(other.customerSalespersonId, customerSalespersonId) || other.customerSalespersonId == customerSalespersonId)&&(identical(other.participationId, participationId) || other.participationId == participationId)&&(identical(other.participationName, participationName) || other.participationName == participationName)&&(identical(other.participationRate, participationRate) || other.participationRate == participationRate)&&(identical(other.rate, rate) || other.rate == rate)&&(identical(other.price, price) || other.price == price)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.total, total) || other.total == total)&&(identical(other.fullCommission, fullCommission) || other.fullCommission == fullCommission)&&(identical(other.share, share) || other.share == share)&&(identical(other.commission, commission) || other.commission == commission));
}


@override
int get hashCode {
    return Object.hashAll([runtimeType,movement,scheme,salesOrderId,salesOrderDetailId,customerRefundDetailId,orderDate,paidDate,customerId,customerName,productId,productName,labelId,labelName,labelRate,agentId,orderSalespersonId,customerSalespersonId,participationId,participationName,participationRate,rate,price,quantity,total,fullCommission,share,commission]);
}

@override
String toString() {
    return 'CommissionLine(movement: $movement, scheme: $scheme, salesOrderId: $salesOrderId, salesOrderDetailId: $salesOrderDetailId, customerRefundDetailId: $customerRefundDetailId, orderDate: $orderDate, paidDate: $paidDate, customerId: $customerId, customerName: $customerName, productId: $productId, productName: $productName, labelId: $labelId, labelName: $labelName, labelRate: $labelRate, agentId: $agentId, orderSalespersonId: $orderSalespersonId, customerSalespersonId: $customerSalespersonId, participationId: $participationId, participationName: $participationName, participationRate: $participationRate, rate: $rate, price: $price, quantity: $quantity, total: $total, fullCommission: $fullCommission, share: $share, commission: $commission)';
}


}

/// @nodoc
abstract mixin class _$CommissionLineCopyWith<$Res> implements $CommissionLineCopyWith<$Res> {
  factory _$CommissionLineCopyWith(_CommissionLine value, $Res Function(_CommissionLine) _then) = __$CommissionLineCopyWithImpl;
@override @useResult
$Res call({
 CommissionMovement movement, CommissionScheme scheme, int salesOrderId, int salesOrderDetailId, int? customerRefundDetailId, DateTime orderDate, DateTime paidDate, int customerId, String customerName, int productId, String productName, int? labelId, String? labelName, Decimal labelRate, int agentId, int orderSalespersonId, int customerSalespersonId, int participationId, String participationName, Decimal participationRate, Decimal rate, Decimal price, Decimal quantity, Decimal total, Decimal fullCommission, Decimal? share, Decimal commission
});




}
/// @nodoc
class __$CommissionLineCopyWithImpl<$Res>
    implements _$CommissionLineCopyWith<$Res> {
  __$CommissionLineCopyWithImpl(this._self, this._then);

  final _CommissionLine _self;
  final $Res Function(_CommissionLine) _then;

/// Create a copy of CommissionLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? movement = null,Object? scheme = null,Object? salesOrderId = null,Object? salesOrderDetailId = null,Object? customerRefundDetailId = freezed,Object? orderDate = null,Object? paidDate = null,Object? customerId = null,Object? customerName = null,Object? productId = null,Object? productName = null,Object? labelId = freezed,Object? labelName = freezed,Object? labelRate = null,Object? agentId = null,Object? orderSalespersonId = null,Object? customerSalespersonId = null,Object? participationId = null,Object? participationName = null,Object? participationRate = null,Object? rate = null,Object? price = null,Object? quantity = null,Object? total = null,Object? fullCommission = null,Object? share = freezed,Object? commission = null,}) {
  return _then(_CommissionLine(
movement: null == movement ? _self.movement : movement // ignore: cast_nullable_to_non_nullable
as CommissionMovement,scheme: null == scheme ? _self.scheme : scheme // ignore: cast_nullable_to_non_nullable
as CommissionScheme,salesOrderId: null == salesOrderId ? _self.salesOrderId : salesOrderId // ignore: cast_nullable_to_non_nullable
as int,salesOrderDetailId: null == salesOrderDetailId ? _self.salesOrderDetailId : salesOrderDetailId // ignore: cast_nullable_to_non_nullable
as int,customerRefundDetailId: freezed == customerRefundDetailId ? _self.customerRefundDetailId : customerRefundDetailId // ignore: cast_nullable_to_non_nullable
as int?,orderDate: null == orderDate ? _self.orderDate : orderDate // ignore: cast_nullable_to_non_nullable
as DateTime,paidDate: null == paidDate ? _self.paidDate : paidDate // ignore: cast_nullable_to_non_nullable
as DateTime,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as int,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,labelId: freezed == labelId ? _self.labelId : labelId // ignore: cast_nullable_to_non_nullable
as int?,labelName: freezed == labelName ? _self.labelName : labelName // ignore: cast_nullable_to_non_nullable
as String?,labelRate: null == labelRate ? _self.labelRate : labelRate // ignore: cast_nullable_to_non_nullable
as Decimal,agentId: null == agentId ? _self.agentId : agentId // ignore: cast_nullable_to_non_nullable
as int,orderSalespersonId: null == orderSalespersonId ? _self.orderSalespersonId : orderSalespersonId // ignore: cast_nullable_to_non_nullable
as int,customerSalespersonId: null == customerSalespersonId ? _self.customerSalespersonId : customerSalespersonId // ignore: cast_nullable_to_non_nullable
as int,participationId: null == participationId ? _self.participationId : participationId // ignore: cast_nullable_to_non_nullable
as int,participationName: null == participationName ? _self.participationName : participationName // ignore: cast_nullable_to_non_nullable
as String,participationRate: null == participationRate ? _self.participationRate : participationRate // ignore: cast_nullable_to_non_nullable
as Decimal,rate: null == rate ? _self.rate : rate // ignore: cast_nullable_to_non_nullable
as Decimal,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as Decimal,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Decimal,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as Decimal,fullCommission: null == fullCommission ? _self.fullCommission : fullCommission // ignore: cast_nullable_to_non_nullable
as Decimal,share: freezed == share ? _self.share : share // ignore: cast_nullable_to_non_nullable
as Decimal?,commission: null == commission ? _self.commission : commission // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}


}

/// @nodoc
mixin _$CommissionPeriod {

 CommissionMonth get month; CommissionPeriodStatus get status; DateTime? get closedAt; DateTime? get paidAt; DateTime? get reopenedAt; int? get closedBy; int? get paidBy; int? get reopenedBy;/// The server's `final`: the figures are stored, not live.
 bool get isFinal; List<CommissionTotal> get totals; List<CommissionLine> get lines;/// The filter the period was read with.
 int? get agentId;
/// Create a copy of CommissionPeriod
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommissionPeriodCopyWith<CommissionPeriod> get copyWith => _$CommissionPeriodCopyWithImpl<CommissionPeriod>(this as CommissionPeriod, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CommissionPeriod;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommissionPeriod&&(identical(other.month, _this.month) || other.month == _this.month)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.closedAt, _this.closedAt) || other.closedAt == _this.closedAt)&&(identical(other.paidAt, _this.paidAt) || other.paidAt == _this.paidAt)&&(identical(other.reopenedAt, _this.reopenedAt) || other.reopenedAt == _this.reopenedAt)&&(identical(other.closedBy, _this.closedBy) || other.closedBy == _this.closedBy)&&(identical(other.paidBy, _this.paidBy) || other.paidBy == _this.paidBy)&&(identical(other.reopenedBy, _this.reopenedBy) || other.reopenedBy == _this.reopenedBy)&&(identical(other.isFinal, _this.isFinal) || other.isFinal == _this.isFinal)&&const DeepCollectionEquality().equals(other.totals, _this.totals)&&const DeepCollectionEquality().equals(other.lines, _this.lines)&&(identical(other.agentId, _this.agentId) || other.agentId == _this.agentId));
}


@override
int get hashCode {
  final _this = this as CommissionPeriod;
  return Object.hash(runtimeType,_this.month,_this.status,_this.closedAt,_this.paidAt,_this.reopenedAt,_this.closedBy,_this.paidBy,_this.reopenedBy,_this.isFinal,const DeepCollectionEquality().hash(_this.totals),const DeepCollectionEquality().hash(_this.lines),_this.agentId);
}

@override
String toString() {
  final _this = this as CommissionPeriod;
  return 'CommissionPeriod(month: ${_this.month}, status: ${_this.status}, closedAt: ${_this.closedAt}, paidAt: ${_this.paidAt}, reopenedAt: ${_this.reopenedAt}, closedBy: ${_this.closedBy}, paidBy: ${_this.paidBy}, reopenedBy: ${_this.reopenedBy}, isFinal: ${_this.isFinal}, totals: ${_this.totals}, lines: ${_this.lines}, agentId: ${_this.agentId})';
}


}

/// @nodoc
abstract mixin class $CommissionPeriodCopyWith<$Res>  {
  factory $CommissionPeriodCopyWith(CommissionPeriod value, $Res Function(CommissionPeriod) _then) = _$CommissionPeriodCopyWithImpl;
@useResult
$Res call({
 CommissionMonth month, CommissionPeriodStatus status, DateTime? closedAt, DateTime? paidAt, DateTime? reopenedAt, int? closedBy, int? paidBy, int? reopenedBy, bool isFinal, List<CommissionTotal> totals, List<CommissionLine> lines, int? agentId
});


$CommissionMonthCopyWith<$Res> get month;

}
/// @nodoc
class _$CommissionPeriodCopyWithImpl<$Res>
    implements $CommissionPeriodCopyWith<$Res> {
  _$CommissionPeriodCopyWithImpl(this._self, this._then);

  final CommissionPeriod _self;
  final $Res Function(CommissionPeriod) _then;

/// Create a copy of CommissionPeriod
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? month = null,Object? status = null,Object? closedAt = freezed,Object? paidAt = freezed,Object? reopenedAt = freezed,Object? closedBy = freezed,Object? paidBy = freezed,Object? reopenedBy = freezed,Object? isFinal = null,Object? totals = null,Object? lines = null,Object? agentId = freezed,}) {
  return _then(CommissionPeriod(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as CommissionMonth,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CommissionPeriodStatus,closedAt: freezed == closedAt ? _self.closedAt : closedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reopenedAt: freezed == reopenedAt ? _self.reopenedAt : reopenedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,closedBy: freezed == closedBy ? _self.closedBy : closedBy // ignore: cast_nullable_to_non_nullable
as int?,paidBy: freezed == paidBy ? _self.paidBy : paidBy // ignore: cast_nullable_to_non_nullable
as int?,reopenedBy: freezed == reopenedBy ? _self.reopenedBy : reopenedBy // ignore: cast_nullable_to_non_nullable
as int?,isFinal: null == isFinal ? _self.isFinal : isFinal // ignore: cast_nullable_to_non_nullable
as bool,totals: null == totals ? _self.totals : totals // ignore: cast_nullable_to_non_nullable
as List<CommissionTotal>,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<CommissionLine>,agentId: freezed == agentId ? _self.agentId : agentId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}
/// Create a copy of CommissionPeriod
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommissionMonthCopyWith<$Res> get month {
  
  return $CommissionMonthCopyWith<$Res>(_self.month, (value) {
    return _then(_self.copyWith(month: value));
  });
}
}


/// Adds pattern-matching-related methods to [CommissionPeriod].
extension CommissionPeriodPatterns on CommissionPeriod {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommissionPeriod value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommissionPeriod() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommissionPeriod value)  $default,){
final _that = this;
switch (_that) {
case _CommissionPeriod():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommissionPeriod value)?  $default,){
final _that = this;
switch (_that) {
case _CommissionPeriod() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CommissionMonth month,  CommissionPeriodStatus status,  DateTime? closedAt,  DateTime? paidAt,  DateTime? reopenedAt,  int? closedBy,  int? paidBy,  int? reopenedBy,  bool isFinal,  List<CommissionTotal> totals,  List<CommissionLine> lines,  int? agentId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommissionPeriod() when $default != null:
return $default(_that.month,_that.status,_that.closedAt,_that.paidAt,_that.reopenedAt,_that.closedBy,_that.paidBy,_that.reopenedBy,_that.isFinal,_that.totals,_that.lines,_that.agentId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CommissionMonth month,  CommissionPeriodStatus status,  DateTime? closedAt,  DateTime? paidAt,  DateTime? reopenedAt,  int? closedBy,  int? paidBy,  int? reopenedBy,  bool isFinal,  List<CommissionTotal> totals,  List<CommissionLine> lines,  int? agentId)  $default,) {final _that = this;
switch (_that) {
case _CommissionPeriod():
return $default(_that.month,_that.status,_that.closedAt,_that.paidAt,_that.reopenedAt,_that.closedBy,_that.paidBy,_that.reopenedBy,_that.isFinal,_that.totals,_that.lines,_that.agentId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CommissionMonth month,  CommissionPeriodStatus status,  DateTime? closedAt,  DateTime? paidAt,  DateTime? reopenedAt,  int? closedBy,  int? paidBy,  int? reopenedBy,  bool isFinal,  List<CommissionTotal> totals,  List<CommissionLine> lines,  int? agentId)?  $default,) {final _that = this;
switch (_that) {
case _CommissionPeriod() when $default != null:
return $default(_that.month,_that.status,_that.closedAt,_that.paidAt,_that.reopenedAt,_that.closedBy,_that.paidBy,_that.reopenedBy,_that.isFinal,_that.totals,_that.lines,_that.agentId);case _:
  return null;

}
}

}

/// @nodoc


class _CommissionPeriod extends CommissionPeriod {
  const _CommissionPeriod({required this.month, required this.status, this.closedAt, this.paidAt, this.reopenedAt, this.closedBy, this.paidBy, this.reopenedBy, required this.isFinal, required  List<CommissionTotal> totals, required  List<CommissionLine> lines, this.agentId}): _totals = totals,_lines = lines,super._();
  

@override final  CommissionMonth month;
@override final  CommissionPeriodStatus status;
@override final  DateTime? closedAt;
@override final  DateTime? paidAt;
@override final  DateTime? reopenedAt;
@override final  int? closedBy;
@override final  int? paidBy;
@override final  int? reopenedBy;
/// The server's `final`: the figures are stored, not live.
@override final  bool isFinal;
 final  List<CommissionTotal> _totals;
@override List<CommissionTotal> get totals {
  if (_totals is EqualUnmodifiableListView) return _totals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_totals);
}

 final  List<CommissionLine> _lines;
@override List<CommissionLine> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}

/// The filter the period was read with.
@override final  int? agentId;

/// Create a copy of CommissionPeriod
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommissionPeriodCopyWith<_CommissionPeriod> get copyWith => __$CommissionPeriodCopyWithImpl<_CommissionPeriod>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommissionPeriod&&(identical(other.month, month) || other.month == month)&&(identical(other.status, status) || other.status == status)&&(identical(other.closedAt, closedAt) || other.closedAt == closedAt)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.reopenedAt, reopenedAt) || other.reopenedAt == reopenedAt)&&(identical(other.closedBy, closedBy) || other.closedBy == closedBy)&&(identical(other.paidBy, paidBy) || other.paidBy == paidBy)&&(identical(other.reopenedBy, reopenedBy) || other.reopenedBy == reopenedBy)&&(identical(other.isFinal, isFinal) || other.isFinal == isFinal)&&const DeepCollectionEquality().equals(other.totals, _totals)&&const DeepCollectionEquality().equals(other.lines, _lines)&&(identical(other.agentId, agentId) || other.agentId == agentId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,month,status,closedAt,paidAt,reopenedAt,closedBy,paidBy,reopenedBy,isFinal,const DeepCollectionEquality().hash(_totals),const DeepCollectionEquality().hash(_lines),agentId);
}

@override
String toString() {
    return 'CommissionPeriod(month: $month, status: $status, closedAt: $closedAt, paidAt: $paidAt, reopenedAt: $reopenedAt, closedBy: $closedBy, paidBy: $paidBy, reopenedBy: $reopenedBy, isFinal: $isFinal, totals: $totals, lines: $lines, agentId: $agentId)';
}


}

/// @nodoc
abstract mixin class _$CommissionPeriodCopyWith<$Res> implements $CommissionPeriodCopyWith<$Res> {
  factory _$CommissionPeriodCopyWith(_CommissionPeriod value, $Res Function(_CommissionPeriod) _then) = __$CommissionPeriodCopyWithImpl;
@override @useResult
$Res call({
 CommissionMonth month, CommissionPeriodStatus status, DateTime? closedAt, DateTime? paidAt, DateTime? reopenedAt, int? closedBy, int? paidBy, int? reopenedBy, bool isFinal, List<CommissionTotal> totals, List<CommissionLine> lines, int? agentId
});


@override $CommissionMonthCopyWith<$Res> get month;

}
/// @nodoc
class __$CommissionPeriodCopyWithImpl<$Res>
    implements _$CommissionPeriodCopyWith<$Res> {
  __$CommissionPeriodCopyWithImpl(this._self, this._then);

  final _CommissionPeriod _self;
  final $Res Function(_CommissionPeriod) _then;

/// Create a copy of CommissionPeriod
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? month = null,Object? status = null,Object? closedAt = freezed,Object? paidAt = freezed,Object? reopenedAt = freezed,Object? closedBy = freezed,Object? paidBy = freezed,Object? reopenedBy = freezed,Object? isFinal = null,Object? totals = null,Object? lines = null,Object? agentId = freezed,}) {
  return _then(_CommissionPeriod(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as CommissionMonth,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CommissionPeriodStatus,closedAt: freezed == closedAt ? _self.closedAt : closedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reopenedAt: freezed == reopenedAt ? _self.reopenedAt : reopenedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,closedBy: freezed == closedBy ? _self.closedBy : closedBy // ignore: cast_nullable_to_non_nullable
as int?,paidBy: freezed == paidBy ? _self.paidBy : paidBy // ignore: cast_nullable_to_non_nullable
as int?,reopenedBy: freezed == reopenedBy ? _self.reopenedBy : reopenedBy // ignore: cast_nullable_to_non_nullable
as int?,isFinal: null == isFinal ? _self.isFinal : isFinal // ignore: cast_nullable_to_non_nullable
as bool,totals: null == totals ? _self._totals : totals // ignore: cast_nullable_to_non_nullable
as List<CommissionTotal>,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<CommissionLine>,agentId: freezed == agentId ? _self.agentId : agentId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of CommissionPeriod
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommissionMonthCopyWith<$Res> get month {
  
  return $CommissionMonthCopyWith<$Res>(_self.month, (value) {
    return _then(_self.copyWith(month: value));
  });
}
}

// dart format on
