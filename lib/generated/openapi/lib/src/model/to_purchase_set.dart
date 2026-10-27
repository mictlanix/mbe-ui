//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'to_purchase_set.g.dart';

/// ToPurchaseSet
///
/// Properties:
/// * [toPurchase]
@BuiltValue()
abstract class ToPurchaseSet
    implements Built<ToPurchaseSet, ToPurchaseSetBuilder> {
  @BuiltValueField(wireName: r'to_purchase')
  bool get toPurchase;

  ToPurchaseSet._();

  factory ToPurchaseSet([void updates(ToPurchaseSetBuilder b)]) =
      _$ToPurchaseSet;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ToPurchaseSetBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ToPurchaseSet> get serializer =>
      _$ToPurchaseSetSerializer();
}

class _$ToPurchaseSetSerializer implements PrimitiveSerializer<ToPurchaseSet> {
  @override
  final Iterable<Type> types = const [ToPurchaseSet, _$ToPurchaseSet];

  @override
  final String wireName = r'ToPurchaseSet';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ToPurchaseSet object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'to_purchase';
    yield serializers.serialize(
      object.toPurchase,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ToPurchaseSet object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(
      serializers,
      object,
      specifiedType: specifiedType,
    ).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ToPurchaseSetBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'to_purchase':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )
                  as bool;
          result.toPurchase = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ToPurchaseSet deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ToPurchaseSetBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}
