//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'relative_period.g.dart';

/// A saved view's period, resolved against the day it runs (spec 038, research R14).
class RelativePeriod extends EnumClass {
  @BuiltValueEnumConst(wireName: r'today')
  static const RelativePeriod today = _$today;
  @BuiltValueEnumConst(wireName: r'yesterday')
  static const RelativePeriod yesterday = _$yesterday;
  @BuiltValueEnumConst(wireName: r'this_week')
  static const RelativePeriod thisWeek = _$thisWeek;
  @BuiltValueEnumConst(wireName: r'this_month')
  static const RelativePeriod thisMonth = _$thisMonth;
  @BuiltValueEnumConst(wireName: r'this_quarter')
  static const RelativePeriod thisQuarter = _$thisQuarter;
  @BuiltValueEnumConst(wireName: r'this_year')
  static const RelativePeriod thisYear = _$thisYear;
  @BuiltValueEnumConst(wireName: r'last_week')
  static const RelativePeriod lastWeek = _$lastWeek;
  @BuiltValueEnumConst(wireName: r'last_month')
  static const RelativePeriod lastMonth = _$lastMonth;
  @BuiltValueEnumConst(wireName: r'last_quarter')
  static const RelativePeriod lastQuarter = _$lastQuarter;
  @BuiltValueEnumConst(wireName: r'last_year')
  static const RelativePeriod lastYear = _$lastYear;
  @BuiltValueEnumConst(wireName: r'last_n_days')
  static const RelativePeriod lastNDays = _$lastNDays;
  @BuiltValueEnumConst(wireName: r'fixed')
  static const RelativePeriod fixed = _$fixed;

  static Serializer<RelativePeriod> get serializer =>
      _$relativePeriodSerializer;

  const RelativePeriod._(String name) : super(name);

  static BuiltSet<RelativePeriod> get values => _$values;
  static RelativePeriod valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class RelativePeriodMixin = Object with _$RelativePeriodMixin;
