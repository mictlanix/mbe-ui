//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'payment_terms.g.dart';

class PaymentTerms extends EnumClass {
  /// `sales_order.payment_terms`, `sales_quote.payment_terms`.
  @BuiltValueEnumConst(wireNumber: 0)
  static const PaymentTerms number0 = _$number0;

  /// `sales_order.payment_terms`, `sales_quote.payment_terms`.
  @BuiltValueEnumConst(wireNumber: 1)
  static const PaymentTerms number1 = _$number1;

  static Serializer<PaymentTerms> get serializer => _$paymentTermsSerializer;

  const PaymentTerms._(String name) : super(name);

  static BuiltSet<PaymentTerms> get values => _$values;
  static PaymentTerms valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class PaymentTermsMixin = Object with _$PaymentTermsMixin;
