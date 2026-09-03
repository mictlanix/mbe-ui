//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'denomination.g.dart';

/// Denomination
@BuiltValue()
abstract class Denomination
    implements Built<Denomination, DenominationBuilder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  Denomination._();

  factory Denomination([void updates(DenominationBuilder b)]) = _$Denomination;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DenominationBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Denomination> get serializer => _$DenominationSerializer();
}

class _$DenominationSerializer implements PrimitiveSerializer<Denomination> {
  @override
  final Iterable<Type> types = const [Denomination, _$Denomination];

  @override
  final String wireName = r'Denomination';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Denomination object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    Denomination object, {
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
  Denomination deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DenominationBuilder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(num), FullType(String)]);
    anyOfDataSrc = serialized;
    result.anyOf =
        serializers.deserialize(anyOfDataSrc, specifiedType: targetType)
            as AnyOf;
    return result.build();
  }
}
