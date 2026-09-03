//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'payment_method.g.dart';

/// `customer_payment.method` — SAT forma de pago catalog codes.
class PaymentMethod extends EnumClass {
  @BuiltValueEnumConst(wireNumber: 0)
  static const PaymentMethod number0 = _$number0;
  @BuiltValueEnumConst(wireNumber: 1)
  static const PaymentMethod number1 = _$number1;
  @BuiltValueEnumConst(wireNumber: 2)
  static const PaymentMethod number2 = _$number2;
  @BuiltValueEnumConst(wireNumber: 3)
  static const PaymentMethod number3 = _$number3;
  @BuiltValueEnumConst(wireNumber: 4)
  static const PaymentMethod number4 = _$number4;
  @BuiltValueEnumConst(wireNumber: 5)
  static const PaymentMethod number5 = _$number5;
  @BuiltValueEnumConst(wireNumber: 6)
  static const PaymentMethod number6 = _$number6;
  @BuiltValueEnumConst(wireNumber: 8)
  static const PaymentMethod number8 = _$number8;
  @BuiltValueEnumConst(wireNumber: 12)
  static const PaymentMethod number12 = _$number12;
  @BuiltValueEnumConst(wireNumber: 27)
  static const PaymentMethod number27 = _$number27;
  @BuiltValueEnumConst(wireNumber: 28)
  static const PaymentMethod number28 = _$number28;
  @BuiltValueEnumConst(wireNumber: 29)
  static const PaymentMethod number29 = _$number29;
  @BuiltValueEnumConst(wireNumber: 30)
  static const PaymentMethod number30 = _$number30;
  @BuiltValueEnumConst(wireNumber: 99)
  static const PaymentMethod number99 = _$number99;
  @BuiltValueEnumConst(wireNumber: 1001)
  static const PaymentMethod number1001 = _$number1001;

  static Serializer<PaymentMethod> get serializer => _$paymentMethodSerializer;

  const PaymentMethod._(String name) : super(name);

  static BuiltSet<PaymentMethod> get values => _$values;
  static PaymentMethod valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class PaymentMethodMixin = Object with _$PaymentMethodMixin;
