//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'quantity4.g.dart';

/// Quantity4
@BuiltValue()
abstract class Quantity4 implements Built<Quantity4, Quantity4Builder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  Quantity4._();

  factory Quantity4([void updates(Quantity4Builder b)]) = _$Quantity4;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(Quantity4Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Quantity4> get serializer => _$Quantity4Serializer();
}

class _$Quantity4Serializer implements PrimitiveSerializer<Quantity4> {
  @override
  final Iterable<Type> types = const [Quantity4, _$Quantity4];

  @override
  final String wireName = r'Quantity4';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Quantity4 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    Quantity4 object, {
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
  Quantity4 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = Quantity4Builder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(num), FullType(String)]);
    anyOfDataSrc = serialized;
    result.anyOf =
        serializers.deserialize(anyOfDataSrc, specifiedType: targetType)
            as AnyOf;
    return result.build();
  }
}
