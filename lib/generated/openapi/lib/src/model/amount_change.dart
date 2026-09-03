//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'amount_change.g.dart';

/// AmountChange
@BuiltValue()
abstract class AmountChange
    implements Built<AmountChange, AmountChangeBuilder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  AmountChange._();

  factory AmountChange([void updates(AmountChangeBuilder b)]) = _$AmountChange;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AmountChangeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AmountChange> get serializer => _$AmountChangeSerializer();
}

class _$AmountChangeSerializer implements PrimitiveSerializer<AmountChange> {
  @override
  final Iterable<Type> types = const [AmountChange, _$AmountChange];

  @override
  final String wireName = r'AmountChange';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AmountChange object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    AmountChange object, {
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
  AmountChange deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AmountChangeBuilder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(num), FullType(String)]);
    anyOfDataSrc = serialized;
    result.anyOf =
        serializers.deserialize(anyOfDataSrc, specifiedType: targetType)
            as AnyOf;
    return result.build();
  }
}
