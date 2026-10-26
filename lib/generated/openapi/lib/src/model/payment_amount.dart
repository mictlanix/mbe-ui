//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'payment_amount.g.dart';

/// PaymentAmount
@BuiltValue()
abstract class PaymentAmount
    implements Built<PaymentAmount, PaymentAmountBuilder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  PaymentAmount._();

  factory PaymentAmount([void updates(PaymentAmountBuilder b)]) =
      _$PaymentAmount;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PaymentAmountBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PaymentAmount> get serializer =>
      _$PaymentAmountSerializer();
}

class _$PaymentAmountSerializer implements PrimitiveSerializer<PaymentAmount> {
  @override
  final Iterable<Type> types = const [PaymentAmount, _$PaymentAmount];

  @override
  final String wireName = r'PaymentAmount';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PaymentAmount object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    PaymentAmount object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(
      anyOf,
      specifiedType: FullType(
        AnyOf,
        anyOf.types.map((type) => FullType(type)).toList(),
      ),
    )!;
  }

  @override
  PaymentAmount deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PaymentAmountBuilder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(num), FullType(String)]);
    anyOfDataSrc = serialized;
    result.anyOf =
        serializers.deserialize(anyOfDataSrc, specifiedType: targetType)
            as AnyOf;
    return result.build();
  }
}
