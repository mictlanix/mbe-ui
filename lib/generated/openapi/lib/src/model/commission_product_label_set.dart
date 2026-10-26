//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'commission_product_label_set.g.dart';

/// CommissionProductLabelSet
///
/// Properties:
/// * [commission]
@BuiltValue()
abstract class CommissionProductLabelSet
    implements
        Built<CommissionProductLabelSet, CommissionProductLabelSetBuilder> {
  @BuiltValueField(wireName: r'commission')
  int get commission;

  CommissionProductLabelSet._();

  factory CommissionProductLabelSet([
    void updates(CommissionProductLabelSetBuilder b),
  ]) = _$CommissionProductLabelSet;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CommissionProductLabelSetBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CommissionProductLabelSet> get serializer =>
      _$CommissionProductLabelSetSerializer();
}

class _$CommissionProductLabelSetSerializer
    implements PrimitiveSerializer<CommissionProductLabelSet> {
  @override
  final Iterable<Type> types = const [
    CommissionProductLabelSet,
    _$CommissionProductLabelSet,
  ];

  @override
  final String wireName = r'CommissionProductLabelSet';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CommissionProductLabelSet object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'commission';
    yield serializers.serialize(
      object.commission,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CommissionProductLabelSet object, {
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
    required CommissionProductLabelSetBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'commission':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.commission = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CommissionProductLabelSet deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CommissionProductLabelSetBuilder();
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
