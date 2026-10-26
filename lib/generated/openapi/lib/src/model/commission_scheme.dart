//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'commission_scheme.g.dart';

/// `commission_agent.scheme` (spec 025).
class CommissionScheme extends EnumClass {
  @BuiltValueEnumConst(wireNumber: 1)
  static const CommissionScheme number1 = _$number1;
  @BuiltValueEnumConst(wireNumber: 2)
  static const CommissionScheme number2 = _$number2;

  static Serializer<CommissionScheme> get serializer =>
      _$commissionSchemeSerializer;

  const CommissionScheme._(String name) : super(name);

  static BuiltSet<CommissionScheme> get values => _$values;
  static CommissionScheme valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class CommissionSchemeMixin = Object with _$CommissionSchemeMixin;
