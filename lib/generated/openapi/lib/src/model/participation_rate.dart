//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'participation_rate.g.dart';

/// ParticipationRate
@BuiltValue()
abstract class ParticipationRate
    implements Built<ParticipationRate, ParticipationRateBuilder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  ParticipationRate._();

  factory ParticipationRate([void updates(ParticipationRateBuilder b)]) =
      _$ParticipationRate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ParticipationRateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ParticipationRate> get serializer =>
      _$ParticipationRateSerializer();
}

class _$ParticipationRateSerializer
    implements PrimitiveSerializer<ParticipationRate> {
  @override
  final Iterable<Type> types = const [ParticipationRate, _$ParticipationRate];

  @override
  final String wireName = r'ParticipationRate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ParticipationRate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    ParticipationRate object, {
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
  ParticipationRate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ParticipationRateBuilder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(num), FullType(String)]);
    anyOfDataSrc = serialized;
    result.anyOf =
        serializers.deserialize(anyOfDataSrc, specifiedType: targetType)
            as AnyOf;
    return result.build();
  }
}
