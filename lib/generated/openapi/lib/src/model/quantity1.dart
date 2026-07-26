//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'quantity1.g.dart';

/// Quantity1
@BuiltValue()
abstract class Quantity1 implements Built<Quantity1, Quantity1Builder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  Quantity1._();

  factory Quantity1([void updates(Quantity1Builder b)]) = _$Quantity1;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(Quantity1Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Quantity1> get serializer => _$Quantity1Serializer();
}

class _$Quantity1Serializer implements PrimitiveSerializer<Quantity1> {
  @override
  final Iterable<Type> types = const [Quantity1, _$Quantity1];

  @override
  final String wireName = r'Quantity1';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Quantity1 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    Quantity1 object, {
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
  Quantity1 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = Quantity1Builder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(num), FullType(String)]);
    anyOfDataSrc = serialized;
    result.anyOf =
        serializers.deserialize(anyOfDataSrc, specifiedType: targetType)
            as AnyOf;
    return result.build();
  }
}
