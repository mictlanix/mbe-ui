//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'low_profit.g.dart';

/// LowProfit
@BuiltValue()
abstract class LowProfit implements Built<LowProfit, LowProfitBuilder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  LowProfit._();

  factory LowProfit([void updates(LowProfitBuilder b)]) = _$LowProfit;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(LowProfitBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<LowProfit> get serializer => _$LowProfitSerializer();
}

class _$LowProfitSerializer implements PrimitiveSerializer<LowProfit> {
  @override
  final Iterable<Type> types = const [LowProfit, _$LowProfit];

  @override
  final String wireName = r'LowProfit';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    LowProfit object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
  }

  @override
  Object serialize(
    Serializers serializers,
    LowProfit object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(anyOf, specifiedType: FullType(AnyOf, anyOf.valueTypes.map((type) => FullType(type)).toList()))!;
  }

  @override
  LowProfit deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = LowProfitBuilder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(num), FullType(String), ]);
    anyOfDataSrc = serialized;
    result.anyOf = serializers.deserialize(anyOfDataSrc, specifiedType: targetType) as AnyOf;
    return result.build();
  }
}

