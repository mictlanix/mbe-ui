//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'grain.g.dart';

class Grain extends EnumClass {
  @BuiltValueEnumConst(wireName: r'day')
  static const Grain day = _$day;
  @BuiltValueEnumConst(wireName: r'week')
  static const Grain week = _$week;
  @BuiltValueEnumConst(wireName: r'month')
  static const Grain month = _$month;
  @BuiltValueEnumConst(wireName: r'quarter')
  static const Grain quarter = _$quarter;
  @BuiltValueEnumConst(wireName: r'year')
  static const Grain year = _$year;

  static Serializer<Grain> get serializer => _$grainSerializer;

  const Grain._(String name) : super(name);

  static BuiltSet<Grain> get values => _$values;
  static Grain valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class GrainMixin = Object with _$GrainMixin;
