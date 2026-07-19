//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'commission.g.dart';

/// Commission
@BuiltValue()
abstract class Commission implements Built<Commission, CommissionBuilder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  Commission._();

  factory Commission([void updates(CommissionBuilder b)]) = _$Commission;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CommissionBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Commission> get serializer => _$CommissionSerializer();
}

class _$CommissionSerializer implements PrimitiveSerializer<Commission> {
  @override
  final Iterable<Type> types = const [Commission, _$Commission];

  @override
  final String wireName = r'Commission';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Commission object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    Commission object, {
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
  Commission deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CommissionBuilder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(num), FullType(String)]);
    anyOfDataSrc = serialized;
    result.anyOf =
        serializers.deserialize(anyOfDataSrc, specifiedType: targetType)
            as AnyOf;
    return result.build();
  }
}
