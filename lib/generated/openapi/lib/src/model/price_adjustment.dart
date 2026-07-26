//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'price_adjustment.g.dart';

/// PriceAdjustment
@BuiltValue()
abstract class PriceAdjustment
    implements Built<PriceAdjustment, PriceAdjustmentBuilder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  PriceAdjustment._();

  factory PriceAdjustment([void updates(PriceAdjustmentBuilder b)]) =
      _$PriceAdjustment;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PriceAdjustmentBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PriceAdjustment> get serializer =>
      _$PriceAdjustmentSerializer();
}

class _$PriceAdjustmentSerializer
    implements PrimitiveSerializer<PriceAdjustment> {
  @override
  final Iterable<Type> types = const [PriceAdjustment, _$PriceAdjustment];

  @override
  final String wireName = r'PriceAdjustment';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PriceAdjustment object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    PriceAdjustment object, {
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
  PriceAdjustment deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PriceAdjustmentBuilder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(num), FullType(String)]);
    anyOfDataSrc = serialized;
    result.anyOf =
        serializers.deserialize(anyOfDataSrc, specifiedType: targetType)
            as AnyOf;
    return result.build();
  }
}
