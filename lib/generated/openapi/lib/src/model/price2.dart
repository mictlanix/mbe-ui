//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'price2.g.dart';

/// Price2
@BuiltValue()
abstract class Price2 implements Built<Price2, Price2Builder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  Price2._();

  factory Price2([void updates(Price2Builder b)]) = _$Price2;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(Price2Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Price2> get serializer => _$Price2Serializer();
}

class _$Price2Serializer implements PrimitiveSerializer<Price2> {
  @override
  final Iterable<Type> types = const [Price2, _$Price2];

  @override
  final String wireName = r'Price2';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Price2 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    Price2 object, {
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
  Price2 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = Price2Builder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(num), FullType(String)]);
    anyOfDataSrc = serialized;
    result.anyOf =
        serializers.deserialize(anyOfDataSrc, specifiedType: targetType)
            as AnyOf;
    return result.build();
  }
}
