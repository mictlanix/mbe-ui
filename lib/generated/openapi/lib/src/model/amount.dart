//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'amount.g.dart';

/// Amount
@BuiltValue()
abstract class Amount implements Built<Amount, AmountBuilder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  Amount._();

  factory Amount([void updates(AmountBuilder b)]) = _$Amount;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AmountBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Amount> get serializer => _$AmountSerializer();
}

class _$AmountSerializer implements PrimitiveSerializer<Amount> {
  @override
  final Iterable<Type> types = const [Amount, _$Amount];

  @override
  final String wireName = r'Amount';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Amount object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    Amount object, {
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
  Amount deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AmountBuilder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(num), FullType(String)]);
    anyOfDataSrc = serialized;
    result.anyOf =
        serializers.deserialize(anyOfDataSrc, specifiedType: targetType)
            as AnyOf;
    return result.build();
  }
}
