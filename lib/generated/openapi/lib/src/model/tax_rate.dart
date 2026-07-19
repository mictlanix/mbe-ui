//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'tax_rate.g.dart';

/// TaxRate
@BuiltValue()
abstract class TaxRate implements Built<TaxRate, TaxRateBuilder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  TaxRate._();

  factory TaxRate([void updates(TaxRateBuilder b)]) = _$TaxRate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TaxRateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TaxRate> get serializer => _$TaxRateSerializer();
}

class _$TaxRateSerializer implements PrimitiveSerializer<TaxRate> {
  @override
  final Iterable<Type> types = const [TaxRate, _$TaxRate];

  @override
  final String wireName = r'TaxRate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TaxRate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    TaxRate object, {
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
  TaxRate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TaxRateBuilder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(num), FullType(String)]);
    anyOfDataSrc = serialized;
    result.anyOf =
        serializers.deserialize(anyOfDataSrc, specifiedType: targetType)
            as AnyOf;
    return result.build();
  }
}
