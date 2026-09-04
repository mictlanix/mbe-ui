//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'shortfall_reason.g.dart';

/// `deliveries_itinerary_detail.reason_code` — why a line fell short of what was sent.
class ShortfallReason extends EnumClass {
  @BuiltValueEnumConst(wireNumber: 0)
  static const ShortfallReason number0 = _$number0;
  @BuiltValueEnumConst(wireNumber: 1)
  static const ShortfallReason number1 = _$number1;
  @BuiltValueEnumConst(wireNumber: 2)
  static const ShortfallReason number2 = _$number2;
  @BuiltValueEnumConst(wireNumber: 3)
  static const ShortfallReason number3 = _$number3;
  @BuiltValueEnumConst(wireNumber: 4)
  static const ShortfallReason number4 = _$number4;

  static Serializer<ShortfallReason> get serializer =>
      _$shortfallReasonSerializer;

  const ShortfallReason._(String name) : super(name);

  static BuiltSet<ShortfallReason> get values => _$values;
  static ShortfallReason valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class ShortfallReasonMixin = Object with _$ShortfallReasonMixin;
