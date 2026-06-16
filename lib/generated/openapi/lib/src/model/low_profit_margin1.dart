//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'low_profit_margin1.g.dart';

/// LowProfitMargin1
@BuiltValue()
abstract class LowProfitMargin1 implements Built<LowProfitMargin1, LowProfitMargin1Builder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  LowProfitMargin1._();

  factory LowProfitMargin1([void updates(LowProfitMargin1Builder b)]) = _$LowProfitMargin1;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(LowProfitMargin1Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<LowProfitMargin1> get serializer => _$LowProfitMargin1Serializer();
}

class _$LowProfitMargin1Serializer implements PrimitiveSerializer<LowProfitMargin1> {
  @override
  final Iterable<Type> types = const [LowProfitMargin1, _$LowProfitMargin1];

  @override
  final String wireName = r'LowProfitMargin1';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    LowProfitMargin1 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
  }

  @override
  Object serialize(
    Serializers serializers,
    LowProfitMargin1 object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(anyOf, specifiedType: FullType(AnyOf, anyOf.valueTypes.map((type) => FullType(type)).toList()))!;
  }

  @override
  LowProfitMargin1 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = LowProfitMargin1Builder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(num), FullType(String), ]);
    anyOfDataSrc = serialized;
    result.anyOf = serializers.deserialize(anyOfDataSrc, specifiedType: targetType) as AnyOf;
    return result.build();
  }
}

