//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'discount_rate.g.dart';

/// DiscountRate
@BuiltValue()
abstract class DiscountRate
    implements Built<DiscountRate, DiscountRateBuilder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  DiscountRate._();

  factory DiscountRate([void updates(DiscountRateBuilder b)]) = _$DiscountRate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DiscountRateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DiscountRate> get serializer => _$DiscountRateSerializer();
}

class _$DiscountRateSerializer implements PrimitiveSerializer<DiscountRate> {
  @override
  final Iterable<Type> types = const [DiscountRate, _$DiscountRate];

  @override
  final String wireName = r'DiscountRate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DiscountRate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    DiscountRate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(
      anyOf,
      specifiedType: FullType(
        AnyOf,
        anyOf.valueTypes.map((type) => FullType(type)).toList(),
      ),
    )!;
  }

  @override
  DiscountRate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DiscountRateBuilder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(num), FullType(String)]);
    anyOfDataSrc = serialized;
    result.anyOf =
        serializers.deserialize(anyOfDataSrc, specifiedType: targetType)
            as AnyOf;
    return result.build();
  }
}
