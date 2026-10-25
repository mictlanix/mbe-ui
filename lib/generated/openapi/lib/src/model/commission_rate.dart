//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'commission_rate.g.dart';

/// CommissionRate
@BuiltValue()
abstract class CommissionRate
    implements Built<CommissionRate, CommissionRateBuilder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  CommissionRate._();

  factory CommissionRate([void updates(CommissionRateBuilder b)]) =
      _$CommissionRate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CommissionRateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CommissionRate> get serializer =>
      _$CommissionRateSerializer();
}

class _$CommissionRateSerializer
    implements PrimitiveSerializer<CommissionRate> {
  @override
  final Iterable<Type> types = const [CommissionRate, _$CommissionRate];

  @override
  final String wireName = r'CommissionRate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CommissionRate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    CommissionRate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(
      anyOf,
      specifiedType: FullType(
        AnyOf,
        anyOf.types.map((type) => FullType(type)).toList(),
      ),
    )!;
  }

  @override
  CommissionRate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CommissionRateBuilder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(num), FullType(String)]);
    anyOfDataSrc = serialized;
    result.anyOf =
        serializers.deserialize(anyOfDataSrc, specifiedType: targetType)
            as AnyOf;
    return result.build();
  }
}
