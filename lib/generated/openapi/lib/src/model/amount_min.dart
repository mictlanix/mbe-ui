//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'amount_min.g.dart';

/// AmountMin
@BuiltValue()
abstract class AmountMin implements Built<AmountMin, AmountMinBuilder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  AmountMin._();

  factory AmountMin([void updates(AmountMinBuilder b)]) = _$AmountMin;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AmountMinBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AmountMin> get serializer => _$AmountMinSerializer();
}

class _$AmountMinSerializer implements PrimitiveSerializer<AmountMin> {
  @override
  final Iterable<Type> types = const [AmountMin, _$AmountMin];

  @override
  final String wireName = r'AmountMin';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AmountMin object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    AmountMin object, {
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
  AmountMin deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AmountMinBuilder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(num), FullType(String)]);
    anyOfDataSrc = serialized;
    result.anyOf =
        serializers.deserialize(anyOfDataSrc, specifiedType: targetType)
            as AnyOf;
    return result.build();
  }
}
