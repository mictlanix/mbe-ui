//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'discount_rate1.g.dart';

/// DiscountRate1
@BuiltValue()
abstract class DiscountRate1
    implements Built<DiscountRate1, DiscountRate1Builder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  DiscountRate1._();

  factory DiscountRate1([void updates(DiscountRate1Builder b)]) =
      _$DiscountRate1;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DiscountRate1Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DiscountRate1> get serializer =>
      _$DiscountRate1Serializer();
}

class _$DiscountRate1Serializer implements PrimitiveSerializer<DiscountRate1> {
  @override
  final Iterable<Type> types = const [DiscountRate1, _$DiscountRate1];

  @override
  final String wireName = r'DiscountRate1';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DiscountRate1 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    DiscountRate1 object, {
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
  DiscountRate1 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DiscountRate1Builder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(num), FullType(String)]);
    anyOfDataSrc = serialized;
    result.anyOf =
        serializers.deserialize(anyOfDataSrc, specifiedType: targetType)
            as AnyOf;
    return result.build();
  }
}
