//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'high_profit1.g.dart';

/// HighProfit1
@BuiltValue()
abstract class HighProfit1 implements Built<HighProfit1, HighProfit1Builder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  HighProfit1._();

  factory HighProfit1([void updates(HighProfit1Builder b)]) = _$HighProfit1;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(HighProfit1Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<HighProfit1> get serializer => _$HighProfit1Serializer();
}

class _$HighProfit1Serializer implements PrimitiveSerializer<HighProfit1> {
  @override
  final Iterable<Type> types = const [HighProfit1, _$HighProfit1];

  @override
  final String wireName = r'HighProfit1';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    HighProfit1 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
  }

  @override
  Object serialize(
    Serializers serializers,
    HighProfit1 object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(anyOf, specifiedType: FullType(AnyOf, anyOf.valueTypes.map((type) => FullType(type)).toList()))!;
  }

  @override
  HighProfit1 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = HighProfit1Builder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(num), FullType(String), ]);
    anyOfDataSrc = serialized;
    result.anyOf = serializers.deserialize(anyOfDataSrc, specifiedType: targetType) as AnyOf;
    return result.build();
  }
}

