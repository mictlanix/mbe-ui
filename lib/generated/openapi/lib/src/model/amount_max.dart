//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'amount_max.g.dart';

/// AmountMax
@BuiltValue()
abstract class AmountMax implements Built<AmountMax, AmountMaxBuilder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  AmountMax._();

  factory AmountMax([void updates(AmountMaxBuilder b)]) = _$AmountMax;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AmountMaxBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AmountMax> get serializer => _$AmountMaxSerializer();
}

class _$AmountMaxSerializer implements PrimitiveSerializer<AmountMax> {
  @override
  final Iterable<Type> types = const [AmountMax, _$AmountMax];

  @override
  final String wireName = r'AmountMax';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AmountMax object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    AmountMax object, {
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
  AmountMax deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AmountMaxBuilder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(num), FullType(String)]);
    anyOfDataSrc = serialized;
    result.anyOf =
        serializers.deserialize(anyOfDataSrc, specifiedType: targetType)
            as AnyOf;
    return result.build();
  }
}
