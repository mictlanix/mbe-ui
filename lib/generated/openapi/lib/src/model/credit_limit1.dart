//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'credit_limit1.g.dart';

/// CreditLimit1
@BuiltValue()
abstract class CreditLimit1 implements Built<CreditLimit1, CreditLimit1Builder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  CreditLimit1._();

  factory CreditLimit1([void updates(CreditLimit1Builder b)]) = _$CreditLimit1;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreditLimit1Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreditLimit1> get serializer => _$CreditLimit1Serializer();
}

class _$CreditLimit1Serializer implements PrimitiveSerializer<CreditLimit1> {
  @override
  final Iterable<Type> types = const [CreditLimit1, _$CreditLimit1];

  @override
  final String wireName = r'CreditLimit1';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreditLimit1 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
  }

  @override
  Object serialize(
    Serializers serializers,
    CreditLimit1 object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(anyOf, specifiedType: FullType(AnyOf, anyOf.valueTypes.map((type) => FullType(type)).toList()))!;
  }

  @override
  CreditLimit1 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreditLimit1Builder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(num), FullType(String), ]);
    anyOfDataSrc = serialized;
    result.anyOf = serializers.deserialize(anyOfDataSrc, specifiedType: targetType) as AnyOf;
    return result.build();
  }
}

