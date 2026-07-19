//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'high_profit.g.dart';

/// HighProfit
@BuiltValue()
abstract class HighProfit implements Built<HighProfit, HighProfitBuilder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  HighProfit._();

  factory HighProfit([void updates(HighProfitBuilder b)]) = _$HighProfit;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(HighProfitBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<HighProfit> get serializer => _$HighProfitSerializer();
}

class _$HighProfitSerializer implements PrimitiveSerializer<HighProfit> {
  @override
  final Iterable<Type> types = const [HighProfit, _$HighProfit];

  @override
  final String wireName = r'HighProfit';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    HighProfit object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    HighProfit object, {
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
  HighProfit deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = HighProfitBuilder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(num), FullType(String)]);
    anyOfDataSrc = serialized;
    result.anyOf =
        serializers.deserialize(anyOfDataSrc, specifiedType: targetType)
            as AnyOf;
    return result.build();
  }
}
