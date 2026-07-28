//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'fulfillment_type.g.dart';

class FulfillmentType extends EnumClass {
  /// `delivery_order.fulfillment_type` — a type, not a status; immutable after creation.
  @BuiltValueEnumConst(wireNumber: 0)
  static const FulfillmentType number0 = _$number0;

  /// `delivery_order.fulfillment_type` — a type, not a status; immutable after creation.
  @BuiltValueEnumConst(wireNumber: 1)
  static const FulfillmentType number1 = _$number1;

  static Serializer<FulfillmentType> get serializer =>
      _$fulfillmentTypeSerializer;

  const FulfillmentType._(String name) : super(name);

  static BuiltSet<FulfillmentType> get values => _$values;
  static FulfillmentType valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class FulfillmentTypeMixin = Object with _$FulfillmentTypeMixin;
