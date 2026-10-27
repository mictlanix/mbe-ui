//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'tax_rate2.g.dart';

/// TaxRate2
@BuiltValue()
abstract class TaxRate2 implements Built<TaxRate2, TaxRate2Builder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  TaxRate2._();

  factory TaxRate2([void updates(TaxRate2Builder b)]) = _$TaxRate2;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TaxRate2Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TaxRate2> get serializer => _$TaxRate2Serializer();
}

class _$TaxRate2Serializer implements PrimitiveSerializer<TaxRate2> {
  @override
  final Iterable<Type> types = const [TaxRate2, _$TaxRate2];

  @override
  final String wireName = r'TaxRate2';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TaxRate2 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    TaxRate2 object, {
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
  TaxRate2 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TaxRate2Builder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(num), FullType(String)]);
    anyOfDataSrc = serialized;
    result.anyOf =
        serializers.deserialize(anyOfDataSrc, specifiedType: targetType)
            as AnyOf;
    return result.build();
  }
}
