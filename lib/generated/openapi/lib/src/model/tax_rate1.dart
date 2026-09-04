//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'tax_rate1.g.dart';

/// TaxRate1
@BuiltValue()
abstract class TaxRate1 implements Built<TaxRate1, TaxRate1Builder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  TaxRate1._();

  factory TaxRate1([void updates(TaxRate1Builder b)]) = _$TaxRate1;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TaxRate1Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TaxRate1> get serializer => _$TaxRate1Serializer();
}

class _$TaxRate1Serializer implements PrimitiveSerializer<TaxRate1> {
  @override
  final Iterable<Type> types = const [TaxRate1, _$TaxRate1];

  @override
  final String wireName = r'TaxRate1';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TaxRate1 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    TaxRate1 object, {
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
  TaxRate1 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TaxRate1Builder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(num), FullType(String)]);
    anyOfDataSrc = serialized;
    result.anyOf =
        serializers.deserialize(anyOfDataSrc, specifiedType: targetType)
            as AnyOf;
    return result.build();
  }
}
