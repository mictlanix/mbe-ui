//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'price1.g.dart';

/// Price1
@BuiltValue()
abstract class Price1 implements Built<Price1, Price1Builder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  Price1._();

  factory Price1([void updates(Price1Builder b)]) = _$Price1;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(Price1Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Price1> get serializer => _$Price1Serializer();
}

class _$Price1Serializer implements PrimitiveSerializer<Price1> {
  @override
  final Iterable<Type> types = const [Price1, _$Price1];

  @override
  final String wireName = r'Price1';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Price1 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
  }

  @override
  Object serialize(
    Serializers serializers,
    Price1 object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(anyOf, specifiedType: FullType(AnyOf, anyOf.valueTypes.map((type) => FullType(type)).toList()))!;
  }

  @override
  Price1 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = Price1Builder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(num), FullType(String), ]);
    anyOfDataSrc = serialized;
    result.anyOf = serializers.deserialize(anyOfDataSrc, specifiedType: targetType) as AnyOf;
    return result.build();
  }
}

