//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'price_adjustment1.g.dart';

/// PriceAdjustment1
@BuiltValue()
abstract class PriceAdjustment1
    implements Built<PriceAdjustment1, PriceAdjustment1Builder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  PriceAdjustment1._();

  factory PriceAdjustment1([void updates(PriceAdjustment1Builder b)]) =
      _$PriceAdjustment1;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PriceAdjustment1Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PriceAdjustment1> get serializer =>
      _$PriceAdjustment1Serializer();
}

class _$PriceAdjustment1Serializer
    implements PrimitiveSerializer<PriceAdjustment1> {
  @override
  final Iterable<Type> types = const [PriceAdjustment1, _$PriceAdjustment1];

  @override
  final String wireName = r'PriceAdjustment1';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PriceAdjustment1 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    PriceAdjustment1 object, {
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
  PriceAdjustment1 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PriceAdjustment1Builder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(num), FullType(String)]);
    anyOfDataSrc = serialized;
    result.anyOf =
        serializers.deserialize(anyOfDataSrc, specifiedType: targetType)
            as AnyOf;
    return result.build();
  }
}
