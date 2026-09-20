//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'order_origin.g.dart';

/// `sales_order.origin` — which workflow raised the order (#209).  A back-office order and a register sale are otherwise identical in every readable field: both write the same document through the same endpoints. `point_sale` cannot stand in, and is not a near miss — it is populated on all 335,816 rows because it is derived from the caller when the body omits it, so a back-office user with a register configured stamps the same register a walk-in sale would carry, and it is immutable after create.  `POINT_OF_SALE` is 0 for the reason `FulfillmentType.PICKUP` is: it is the ordinary capture surface. `BACK_OFFICE` covers every order a back-office workflow raised, including the 6,261 converted from a quote — \"converted from a quote\" is a different fact about a different question, and `sales_order.sales_quote` already records it.  NULL is not a member of this vocabulary. It means the origin was never recorded, which is every row predating migration 020 and every order raised by a client that does not say. Nothing infers it: not from the register, not from the customer, not from the fulfilment intent.
class OrderOrigin extends EnumClass {
  @BuiltValueEnumConst(wireNumber: 0)
  static const OrderOrigin number0 = _$number0;
  @BuiltValueEnumConst(wireNumber: 1)
  static const OrderOrigin number1 = _$number1;

  static Serializer<OrderOrigin> get serializer => _$orderOriginSerializer;

  const OrderOrigin._(String name) : super(name);

  static BuiltSet<OrderOrigin> get values => _$values;
  static OrderOrigin valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class OrderOriginMixin = Object with _$OrderOriginMixin;
