//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'delivery_order_status.g.dart';

class DeliveryOrderStatus extends EnumClass {
  /// `delivery_order.status` — the v2 delivery lifecycle (spec 012, FR-001).
  @BuiltValueEnumConst(wireNumber: 0)
  static const DeliveryOrderStatus number0 = _$number0;

  /// `delivery_order.status` — the v2 delivery lifecycle (spec 012, FR-001).
  @BuiltValueEnumConst(wireNumber: 1)
  static const DeliveryOrderStatus number1 = _$number1;

  /// `delivery_order.status` — the v2 delivery lifecycle (spec 012, FR-001).
  @BuiltValueEnumConst(wireNumber: 2)
  static const DeliveryOrderStatus number2 = _$number2;

  /// `delivery_order.status` — the v2 delivery lifecycle (spec 012, FR-001).
  @BuiltValueEnumConst(wireNumber: 3)
  static const DeliveryOrderStatus number3 = _$number3;

  /// `delivery_order.status` — the v2 delivery lifecycle (spec 012, FR-001).
  @BuiltValueEnumConst(wireNumber: 4)
  static const DeliveryOrderStatus number4 = _$number4;

  /// `delivery_order.status` — the v2 delivery lifecycle (spec 012, FR-001).
  @BuiltValueEnumConst(wireNumber: 5)
  static const DeliveryOrderStatus number5 = _$number5;

  /// `delivery_order.status` — the v2 delivery lifecycle (spec 012, FR-001).
  @BuiltValueEnumConst(wireNumber: 6)
  static const DeliveryOrderStatus number6 = _$number6;

  /// `delivery_order.status` — the v2 delivery lifecycle (spec 012, FR-001).
  @BuiltValueEnumConst(wireNumber: 7)
  static const DeliveryOrderStatus number7 = _$number7;

  /// `delivery_order.status` — the v2 delivery lifecycle (spec 012, FR-001).
  @BuiltValueEnumConst(wireNumber: 8)
  static const DeliveryOrderStatus number8 = _$number8;

  /// `delivery_order.status` — the v2 delivery lifecycle (spec 012, FR-001).
  @BuiltValueEnumConst(wireNumber: 9)
  static const DeliveryOrderStatus number9 = _$number9;

  /// `delivery_order.status` — the v2 delivery lifecycle (spec 012, FR-001).
  @BuiltValueEnumConst(wireNumber: 10)
  static const DeliveryOrderStatus number10 = _$number10;

  static Serializer<DeliveryOrderStatus> get serializer =>
      _$deliveryOrderStatusSerializer;

  const DeliveryOrderStatus._(String name) : super(name);

  static BuiltSet<DeliveryOrderStatus> get values => _$values;
  static DeliveryOrderStatus valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class DeliveryOrderStatusMixin = Object
    with _$DeliveryOrderStatusMixin;
