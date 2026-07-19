//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'commission1.g.dart';

/// Commission1
@BuiltValue()
abstract class Commission1 implements Built<Commission1, Commission1Builder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  Commission1._();

  factory Commission1([void updates(Commission1Builder b)]) = _$Commission1;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(Commission1Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Commission1> get serializer => _$Commission1Serializer();
}

class _$Commission1Serializer implements PrimitiveSerializer<Commission1> {
  @override
  final Iterable<Type> types = const [Commission1, _$Commission1];

  @override
  final String wireName = r'Commission1';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Commission1 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    Commission1 object, {
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
  Commission1 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = Commission1Builder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(num), FullType(String)]);
    anyOfDataSrc = serialized;
    result.anyOf =
        serializers.deserialize(anyOfDataSrc, specifiedType: targetType)
            as AnyOf;
    return result.build();
  }
}
