//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'fulfillment_type.g.dart';

class FulfillmentType extends EnumClass {
  /// How goods reach the customer. One vocabulary, one numbering, two columns:  - `sales_order.fulfillment_intent` — what the cashier said, before the sale is confirmed. Any   of the three, or NULL for \"not recorded\" (#170). - `delivery_order.fulfillment_type` — what *that shipment* is. A type, not a status, and   immutable after creation. Never `MIXED`: a shipment is one kind or the other, and a mixed   sale is one that produces a delivery order of each. `create_from_sales_order` refuses it.  `PICKUP` is 0 because it is the ordinary counter sale — 310,609 of 335,763 sales orders, 92.5%, never produced a delivery order at all. Migration 018 renumbered `fulfillment_type` to match, where delivery had been 0 since migration 008 created the column from the legacy `picked_up` boolean.  Not `sales_order.partial_deliveries` (the legacy `DeliveryMode`), which the system writes after a delivery order exists to record how fulfilment turned out, and which has no mixed value. Verified rather than assumed: it is populated on 335,416 of 335,763 legacy rows and NULL on exactly the 347 this API created.
  @BuiltValueEnumConst(wireNumber: 0)
  static const FulfillmentType number0 = _$number0;

  /// How goods reach the customer. One vocabulary, one numbering, two columns:  - `sales_order.fulfillment_intent` — what the cashier said, before the sale is confirmed. Any   of the three, or NULL for \"not recorded\" (#170). - `delivery_order.fulfillment_type` — what *that shipment* is. A type, not a status, and   immutable after creation. Never `MIXED`: a shipment is one kind or the other, and a mixed   sale is one that produces a delivery order of each. `create_from_sales_order` refuses it.  `PICKUP` is 0 because it is the ordinary counter sale — 310,609 of 335,763 sales orders, 92.5%, never produced a delivery order at all. Migration 018 renumbered `fulfillment_type` to match, where delivery had been 0 since migration 008 created the column from the legacy `picked_up` boolean.  Not `sales_order.partial_deliveries` (the legacy `DeliveryMode`), which the system writes after a delivery order exists to record how fulfilment turned out, and which has no mixed value. Verified rather than assumed: it is populated on 335,416 of 335,763 legacy rows and NULL on exactly the 347 this API created.
  @BuiltValueEnumConst(wireNumber: 1)
  static const FulfillmentType number1 = _$number1;

  /// How goods reach the customer. One vocabulary, one numbering, two columns:  - `sales_order.fulfillment_intent` — what the cashier said, before the sale is confirmed. Any   of the three, or NULL for \"not recorded\" (#170). - `delivery_order.fulfillment_type` — what *that shipment* is. A type, not a status, and   immutable after creation. Never `MIXED`: a shipment is one kind or the other, and a mixed   sale is one that produces a delivery order of each. `create_from_sales_order` refuses it.  `PICKUP` is 0 because it is the ordinary counter sale — 310,609 of 335,763 sales orders, 92.5%, never produced a delivery order at all. Migration 018 renumbered `fulfillment_type` to match, where delivery had been 0 since migration 008 created the column from the legacy `picked_up` boolean.  Not `sales_order.partial_deliveries` (the legacy `DeliveryMode`), which the system writes after a delivery order exists to record how fulfilment turned out, and which has no mixed value. Verified rather than assumed: it is populated on 335,416 of 335,763 legacy rows and NULL on exactly the 347 this API created.
  @BuiltValueEnumConst(wireNumber: 2)
  static const FulfillmentType number2 = _$number2;

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
