//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'low_profit_margin.g.dart';

/// LowProfitMargin
@BuiltValue()
abstract class LowProfitMargin
    implements Built<LowProfitMargin, LowProfitMarginBuilder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  LowProfitMargin._();

  factory LowProfitMargin([void updates(LowProfitMarginBuilder b)]) =
      _$LowProfitMargin;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(LowProfitMarginBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<LowProfitMargin> get serializer =>
      _$LowProfitMarginSerializer();
}

class _$LowProfitMarginSerializer
    implements PrimitiveSerializer<LowProfitMargin> {
  @override
  final Iterable<Type> types = const [LowProfitMargin, _$LowProfitMargin];

  @override
  final String wireName = r'LowProfitMargin';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    LowProfitMargin object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    LowProfitMargin object, {
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
  LowProfitMargin deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = LowProfitMarginBuilder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(num), FullType(String)]);
    anyOfDataSrc = serialized;
    result.anyOf =
        serializers.deserialize(anyOfDataSrc, specifiedType: targetType)
            as AnyOf;
    return result.build();
  }
}
