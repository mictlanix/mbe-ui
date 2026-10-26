//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'amount2.g.dart';

/// Amount2
@BuiltValue()
abstract class Amount2 implements Built<Amount2, Amount2Builder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  Amount2._();

  factory Amount2([void updates(Amount2Builder b)]) = _$Amount2;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(Amount2Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Amount2> get serializer => _$Amount2Serializer();
}

class _$Amount2Serializer implements PrimitiveSerializer<Amount2> {
  @override
  final Iterable<Type> types = const [Amount2, _$Amount2];

  @override
  final String wireName = r'Amount2';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Amount2 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    Amount2 object, {
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
  Amount2 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = Amount2Builder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(num), FullType(String)]);
    anyOfDataSrc = serialized;
    result.anyOf =
        serializers.deserialize(anyOfDataSrc, specifiedType: targetType)
            as AnyOf;
    return result.build();
  }
}
