//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'payment_type.g.dart';

/// `customer_payment.payment_type` — what the payment record represents.  The column is `payment_type`, not `type` as the legacy sales spec claims.
class PaymentType extends EnumClass {
  @BuiltValueEnumConst(wireNumber: 0)
  static const PaymentType number0 = _$number0;
  @BuiltValueEnumConst(wireNumber: 1)
  static const PaymentType number1 = _$number1;
  @BuiltValueEnumConst(wireNumber: 2)
  static const PaymentType number2 = _$number2;
  @BuiltValueEnumConst(wireNumber: 3)
  static const PaymentType number3 = _$number3;
  @BuiltValueEnumConst(wireNumber: 4)
  static const PaymentType number4 = _$number4;
  @BuiltValueEnumConst(wireNumber: 5)
  static const PaymentType number5 = _$number5;

  static Serializer<PaymentType> get serializer => _$paymentTypeSerializer;

  const PaymentType._(String name) : super(name);

  static BuiltSet<PaymentType> get values => _$values;
  static PaymentType valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class PaymentTypeMixin = Object with _$PaymentTypeMixin;
