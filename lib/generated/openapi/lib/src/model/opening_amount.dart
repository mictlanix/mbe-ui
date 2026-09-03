//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'opening_amount.g.dart';

/// OpeningAmount
@BuiltValue()
abstract class OpeningAmount
    implements Built<OpeningAmount, OpeningAmountBuilder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  OpeningAmount._();

  factory OpeningAmount([void updates(OpeningAmountBuilder b)]) =
      _$OpeningAmount;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OpeningAmountBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OpeningAmount> get serializer =>
      _$OpeningAmountSerializer();
}

class _$OpeningAmountSerializer implements PrimitiveSerializer<OpeningAmount> {
  @override
  final Iterable<Type> types = const [OpeningAmount, _$OpeningAmount];

  @override
  final String wireName = r'OpeningAmount';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OpeningAmount object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    OpeningAmount object, {
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
  OpeningAmount deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpeningAmountBuilder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(num), FullType(String)]);
    anyOfDataSrc = serialized;
    result.anyOf =
        serializers.deserialize(anyOfDataSrc, specifiedType: targetType)
            as AnyOf;
    return result.build();
  }
}
