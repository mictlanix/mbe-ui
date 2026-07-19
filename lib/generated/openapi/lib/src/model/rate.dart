//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'rate.g.dart';

/// Rate
@BuiltValue()
abstract class Rate implements Built<Rate, RateBuilder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  Rate._();

  factory Rate([void updates(RateBuilder b)]) = _$Rate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Rate> get serializer => _$RateSerializer();
}

class _$RateSerializer implements PrimitiveSerializer<Rate> {
  @override
  final Iterable<Type> types = const [Rate, _$Rate];

  @override
  final String wireName = r'Rate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Rate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    Rate object, {
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
  Rate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RateBuilder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(num), FullType(String)]);
    anyOfDataSrc = serialized;
    result.anyOf =
        serializers.deserialize(anyOfDataSrc, specifiedType: targetType)
            as AnyOf;
    return result.build();
  }
}
