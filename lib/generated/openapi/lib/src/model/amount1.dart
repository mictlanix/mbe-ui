//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'amount1.g.dart';

/// Amount1
@BuiltValue()
abstract class Amount1 implements Built<Amount1, Amount1Builder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  Amount1._();

  factory Amount1([void updates(Amount1Builder b)]) = _$Amount1;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(Amount1Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Amount1> get serializer => _$Amount1Serializer();
}

class _$Amount1Serializer implements PrimitiveSerializer<Amount1> {
  @override
  final Iterable<Type> types = const [Amount1, _$Amount1];

  @override
  final String wireName = r'Amount1';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Amount1 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    Amount1 object, {
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
  Amount1 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = Amount1Builder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(num), FullType(String)]);
    anyOfDataSrc = serialized;
    result.anyOf =
        serializers.deserialize(anyOfDataSrc, specifiedType: targetType)
            as AnyOf;
    return result.build();
  }
}
