//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'quantity2.g.dart';

/// Quantity2
@BuiltValue()
abstract class Quantity2 implements Built<Quantity2, Quantity2Builder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  Quantity2._();

  factory Quantity2([void updates(Quantity2Builder b)]) = _$Quantity2;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(Quantity2Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Quantity2> get serializer => _$Quantity2Serializer();
}

class _$Quantity2Serializer implements PrimitiveSerializer<Quantity2> {
  @override
  final Iterable<Type> types = const [Quantity2, _$Quantity2];

  @override
  final String wireName = r'Quantity2';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Quantity2 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    Quantity2 object, {
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
  Quantity2 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = Quantity2Builder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(num), FullType(String)]);
    anyOfDataSrc = serialized;
    result.anyOf =
        serializers.deserialize(anyOfDataSrc, specifiedType: targetType)
            as AnyOf;
    return result.build();
  }
}
