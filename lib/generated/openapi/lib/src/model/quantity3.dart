//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'quantity3.g.dart';

/// Quantity3
@BuiltValue()
abstract class Quantity3 implements Built<Quantity3, Quantity3Builder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  Quantity3._();

  factory Quantity3([void updates(Quantity3Builder b)]) = _$Quantity3;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(Quantity3Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Quantity3> get serializer => _$Quantity3Serializer();
}

class _$Quantity3Serializer implements PrimitiveSerializer<Quantity3> {
  @override
  final Iterable<Type> types = const [Quantity3, _$Quantity3];

  @override
  final String wireName = r'Quantity3';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Quantity3 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    Quantity3 object, {
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
  Quantity3 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = Quantity3Builder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(num), FullType(String)]);
    anyOfDataSrc = serialized;
    result.anyOf =
        serializers.deserialize(anyOfDataSrc, specifiedType: targetType)
            as AnyOf;
    return result.build();
  }
}
