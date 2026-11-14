//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'cadence.g.dart';

class Cadence extends EnumClass {
  @BuiltValueEnumConst(wireName: r'daily')
  static const Cadence daily = _$daily;
  @BuiltValueEnumConst(wireName: r'weekly')
  static const Cadence weekly = _$weekly;
  @BuiltValueEnumConst(wireName: r'monthly')
  static const Cadence monthly = _$monthly;

  static Serializer<Cadence> get serializer => _$cadenceSerializer;

  const Cadence._(String name) : super(name);

  static BuiltSet<Cadence> get values => _$values;
  static Cadence valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class CadenceMixin = Object with _$CadenceMixin;
