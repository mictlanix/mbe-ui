//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'high_profit_margin.g.dart';

/// HighProfitMargin
@BuiltValue()
abstract class HighProfitMargin
    implements Built<HighProfitMargin, HighProfitMarginBuilder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  HighProfitMargin._();

  factory HighProfitMargin([void updates(HighProfitMarginBuilder b)]) =
      _$HighProfitMargin;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(HighProfitMarginBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<HighProfitMargin> get serializer =>
      _$HighProfitMarginSerializer();
}

class _$HighProfitMarginSerializer
    implements PrimitiveSerializer<HighProfitMargin> {
  @override
  final Iterable<Type> types = const [HighProfitMargin, _$HighProfitMargin];

  @override
  final String wireName = r'HighProfitMargin';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    HighProfitMargin object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    HighProfitMargin object, {
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
  HighProfitMargin deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = HighProfitMarginBuilder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(num), FullType(String)]);
    anyOfDataSrc = serialized;
    result.anyOf =
        serializers.deserialize(anyOfDataSrc, specifiedType: targetType)
            as AnyOf;
    return result.build();
  }
}
