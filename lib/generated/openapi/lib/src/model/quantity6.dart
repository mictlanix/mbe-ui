//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'quantity6.g.dart';

/// Quantity6
@BuiltValue()
abstract class Quantity6 implements Built<Quantity6, Quantity6Builder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  Quantity6._();

  factory Quantity6([void updates(Quantity6Builder b)]) = _$Quantity6;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(Quantity6Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Quantity6> get serializer => _$Quantity6Serializer();
}

class _$Quantity6Serializer implements PrimitiveSerializer<Quantity6> {
  @override
  final Iterable<Type> types = const [Quantity6, _$Quantity6];

  @override
  final String wireName = r'Quantity6';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Quantity6 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    Quantity6 object, {
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
  Quantity6 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = Quantity6Builder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(num), FullType(String)]);
    anyOfDataSrc = serialized;
    result.anyOf =
        serializers.deserialize(anyOfDataSrc, specifiedType: targetType)
            as AnyOf;
    return result.build();
  }
}
