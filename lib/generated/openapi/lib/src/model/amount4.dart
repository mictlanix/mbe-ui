//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'amount4.g.dart';

/// Amount4
@BuiltValue()
abstract class Amount4 implements Built<Amount4, Amount4Builder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  Amount4._();

  factory Amount4([void updates(Amount4Builder b)]) = _$Amount4;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(Amount4Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Amount4> get serializer => _$Amount4Serializer();
}

class _$Amount4Serializer implements PrimitiveSerializer<Amount4> {
  @override
  final Iterable<Type> types = const [Amount4, _$Amount4];

  @override
  final String wireName = r'Amount4';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Amount4 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    Amount4 object, {
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
  Amount4 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = Amount4Builder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(num), FullType(String)]);
    anyOfDataSrc = serialized;
    result.anyOf =
        serializers.deserialize(anyOfDataSrc, specifiedType: targetType)
            as AnyOf;
    return result.build();
  }
}
