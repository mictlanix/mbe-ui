//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'discount1.g.dart';

/// Discount1
@BuiltValue()
abstract class Discount1 implements Built<Discount1, Discount1Builder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  Discount1._();

  factory Discount1([void updates(Discount1Builder b)]) = _$Discount1;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(Discount1Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Discount1> get serializer => _$Discount1Serializer();
}

class _$Discount1Serializer implements PrimitiveSerializer<Discount1> {
  @override
  final Iterable<Type> types = const [Discount1, _$Discount1];

  @override
  final String wireName = r'Discount1';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Discount1 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    Discount1 object, {
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
  Discount1 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = Discount1Builder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(num), FullType(String)]);
    anyOfDataSrc = serialized;
    result.anyOf =
        serializers.deserialize(anyOfDataSrc, specifiedType: targetType)
            as AnyOf;
    return result.build();
  }
}
