//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'commission_rate1.g.dart';

/// CommissionRate1
@BuiltValue()
abstract class CommissionRate1
    implements Built<CommissionRate1, CommissionRate1Builder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  CommissionRate1._();

  factory CommissionRate1([void updates(CommissionRate1Builder b)]) =
      _$CommissionRate1;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CommissionRate1Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CommissionRate1> get serializer =>
      _$CommissionRate1Serializer();
}

class _$CommissionRate1Serializer
    implements PrimitiveSerializer<CommissionRate1> {
  @override
  final Iterable<Type> types = const [CommissionRate1, _$CommissionRate1];

  @override
  final String wireName = r'CommissionRate1';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CommissionRate1 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    CommissionRate1 object, {
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
  CommissionRate1 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CommissionRate1Builder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(num), FullType(String)]);
    anyOfDataSrc = serialized;
    result.anyOf =
        serializers.deserialize(anyOfDataSrc, specifiedType: targetType)
            as AnyOf;
    return result.build();
  }
}
