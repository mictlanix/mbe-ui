//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'quantity.g.dart';

/// Quantity
@BuiltValue()
abstract class Quantity implements Built<Quantity, QuantityBuilder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  Quantity._();

  factory Quantity([void updates(QuantityBuilder b)]) = _$Quantity;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(QuantityBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Quantity> get serializer => _$QuantitySerializer();
}

class _$QuantitySerializer implements PrimitiveSerializer<Quantity> {
  @override
  final Iterable<Type> types = const [Quantity, _$Quantity];

  @override
  final String wireName = r'Quantity';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Quantity object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    Quantity object, {
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
  Quantity deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = QuantityBuilder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(num), FullType(String)]);
    anyOfDataSrc = serialized;
    result.anyOf =
        serializers.deserialize(anyOfDataSrc, specifiedType: targetType)
            as AnyOf;
    return result.build();
  }
}
