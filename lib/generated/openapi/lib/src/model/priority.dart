//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'priority.g.dart';

class Priority extends EnumClass {
  /// `sales_order.priority`.
  @BuiltValueEnumConst(wireNumber: 0)
  static const Priority number0 = _$number0;

  /// `sales_order.priority`.
  @BuiltValueEnumConst(wireNumber: 1)
  static const Priority number1 = _$number1;

  /// `sales_order.priority`.
  @BuiltValueEnumConst(wireNumber: 2)
  static const Priority number2 = _$number2;

  /// `sales_order.priority`.
  @BuiltValueEnumConst(wireNumber: 3)
  static const Priority number3 = _$number3;

  static Serializer<Priority> get serializer => _$prioritySerializer;

  const Priority._(String name) : super(name);

  static BuiltSet<Priority> get values => _$values;
  static Priority valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class PriorityMixin = Object with _$PriorityMixin;
