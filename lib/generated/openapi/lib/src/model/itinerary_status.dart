//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'itinerary_status.g.dart';

/// `deliveries_itinerary.status` — the trip lifecycle (FR-033a).
class ItineraryStatus extends EnumClass {
  @BuiltValueEnumConst(wireNumber: 0)
  static const ItineraryStatus number0 = _$number0;
  @BuiltValueEnumConst(wireNumber: 1)
  static const ItineraryStatus number1 = _$number1;
  @BuiltValueEnumConst(wireNumber: 2)
  static const ItineraryStatus number2 = _$number2;
  @BuiltValueEnumConst(wireNumber: 3)
  static const ItineraryStatus number3 = _$number3;

  static Serializer<ItineraryStatus> get serializer =>
      _$itineraryStatusSerializer;

  const ItineraryStatus._(String name) : super(name);

  static BuiltSet<ItineraryStatus> get values => _$values;
  static ItineraryStatus valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class ItineraryStatusMixin = Object with _$ItineraryStatusMixin;
