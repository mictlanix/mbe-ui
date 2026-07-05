//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'low_profit1.g.dart';

/// LowProfit1
@BuiltValue()
abstract class LowProfit1 implements Built<LowProfit1, LowProfit1Builder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  LowProfit1._();

  factory LowProfit1([void updates(LowProfit1Builder b)]) = _$LowProfit1;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(LowProfit1Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<LowProfit1> get serializer => _$LowProfit1Serializer();
}

class _$LowProfit1Serializer implements PrimitiveSerializer<LowProfit1> {
  @override
  final Iterable<Type> types = const [LowProfit1, _$LowProfit1];

  @override
  final String wireName = r'LowProfit1';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    LowProfit1 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
  }

  @override
  Object serialize(
    Serializers serializers,
    LowProfit1 object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(anyOf, specifiedType: FullType(AnyOf, anyOf.valueTypes.map((type) => FullType(type)).toList()))!;
  }

  @override
  LowProfit1 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = LowProfit1Builder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(num), FullType(String), ]);
    anyOfDataSrc = serialized;
    result.anyOf = serializers.deserialize(anyOfDataSrc, specifiedType: targetType) as AnyOf;
    return result.build();
  }
}

