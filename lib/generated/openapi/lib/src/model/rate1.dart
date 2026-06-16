//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'rate1.g.dart';

/// Rate1
@BuiltValue()
abstract class Rate1 implements Built<Rate1, Rate1Builder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  Rate1._();

  factory Rate1([void updates(Rate1Builder b)]) = _$Rate1;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(Rate1Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Rate1> get serializer => _$Rate1Serializer();
}

class _$Rate1Serializer implements PrimitiveSerializer<Rate1> {
  @override
  final Iterable<Type> types = const [Rate1, _$Rate1];

  @override
  final String wireName = r'Rate1';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Rate1 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
  }

  @override
  Object serialize(
    Serializers serializers,
    Rate1 object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(anyOf, specifiedType: FullType(AnyOf, anyOf.valueTypes.map((type) => FullType(type)).toList()))!;
  }

  @override
  Rate1 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = Rate1Builder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(num), FullType(String), ]);
    anyOfDataSrc = serialized;
    result.anyOf = serializers.deserialize(anyOfDataSrc, specifiedType: targetType) as AnyOf;
    return result.build();
  }
}

