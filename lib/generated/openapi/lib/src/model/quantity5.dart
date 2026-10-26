//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'quantity5.g.dart';

/// Quantity5
@BuiltValue()
abstract class Quantity5 implements Built<Quantity5, Quantity5Builder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  Quantity5._();

  factory Quantity5([void updates(Quantity5Builder b)]) = _$Quantity5;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(Quantity5Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Quantity5> get serializer => _$Quantity5Serializer();
}

class _$Quantity5Serializer implements PrimitiveSerializer<Quantity5> {
  @override
  final Iterable<Type> types = const [Quantity5, _$Quantity5];

  @override
  final String wireName = r'Quantity5';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Quantity5 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    Quantity5 object, {
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
  Quantity5 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = Quantity5Builder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(num), FullType(String)]);
    anyOfDataSrc = serialized;
    result.anyOf =
        serializers.deserialize(anyOfDataSrc, specifiedType: targetType)
            as AnyOf;
    return result.build();
  }
}
