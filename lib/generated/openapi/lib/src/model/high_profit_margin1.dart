//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'high_profit_margin1.g.dart';

/// HighProfitMargin1
@BuiltValue()
abstract class HighProfitMargin1 implements Built<HighProfitMargin1, HighProfitMargin1Builder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  HighProfitMargin1._();

  factory HighProfitMargin1([void updates(HighProfitMargin1Builder b)]) = _$HighProfitMargin1;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(HighProfitMargin1Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<HighProfitMargin1> get serializer => _$HighProfitMargin1Serializer();
}

class _$HighProfitMargin1Serializer implements PrimitiveSerializer<HighProfitMargin1> {
  @override
  final Iterable<Type> types = const [HighProfitMargin1, _$HighProfitMargin1];

  @override
  final String wireName = r'HighProfitMargin1';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    HighProfitMargin1 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
  }

  @override
  Object serialize(
    Serializers serializers,
    HighProfitMargin1 object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(anyOf, specifiedType: FullType(AnyOf, anyOf.valueTypes.map((type) => FullType(type)).toList()))!;
  }

  @override
  HighProfitMargin1 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = HighProfitMargin1Builder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(num), FullType(String), ]);
    anyOfDataSrc = serialized;
    result.anyOf = serializers.deserialize(anyOfDataSrc, specifiedType: targetType) as AnyOf;
    return result.build();
  }
}

