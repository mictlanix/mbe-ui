//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'amount3.g.dart';

/// Amount3
@BuiltValue()
abstract class Amount3 implements Built<Amount3, Amount3Builder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  Amount3._();

  factory Amount3([void updates(Amount3Builder b)]) = _$Amount3;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(Amount3Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Amount3> get serializer => _$Amount3Serializer();
}

class _$Amount3Serializer implements PrimitiveSerializer<Amount3> {
  @override
  final Iterable<Type> types = const [Amount3, _$Amount3];

  @override
  final String wireName = r'Amount3';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Amount3 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    Amount3 object, {
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
  Amount3 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = Amount3Builder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(num), FullType(String)]);
    anyOfDataSrc = serialized;
    result.anyOf =
        serializers.deserialize(anyOfDataSrc, specifiedType: targetType)
            as AnyOf;
    return result.build();
  }
}
