//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'credit_limit.g.dart';

/// CreditLimit
@BuiltValue()
abstract class CreditLimit implements Built<CreditLimit, CreditLimitBuilder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  CreditLimit._();

  factory CreditLimit([void updates(CreditLimitBuilder b)]) = _$CreditLimit;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreditLimitBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreditLimit> get serializer => _$CreditLimitSerializer();
}

class _$CreditLimitSerializer implements PrimitiveSerializer<CreditLimit> {
  @override
  final Iterable<Type> types = const [CreditLimit, _$CreditLimit];

  @override
  final String wireName = r'CreditLimit';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreditLimit object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
  }

  @override
  Object serialize(
    Serializers serializers,
    CreditLimit object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(anyOf, specifiedType: FullType(AnyOf, anyOf.valueTypes.map((type) => FullType(type)).toList()))!;
  }

  @override
  CreditLimit deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreditLimitBuilder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(num), FullType(String), ]);
    anyOfDataSrc = serialized;
    result.anyOf = serializers.deserialize(anyOfDataSrc, specifiedType: targetType) as AnyOf;
    return result.build();
  }
}

