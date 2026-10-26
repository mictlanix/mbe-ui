//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/commission_rate1.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'commission_label_update.g.dart';

/// CommissionLabelUpdate
///
/// Properties:
/// * [name]
/// * [commissionRate]
/// * [comment]
@BuiltValue()
abstract class CommissionLabelUpdate
    implements Built<CommissionLabelUpdate, CommissionLabelUpdateBuilder> {
  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'commission_rate')
  CommissionRate1? get commissionRate;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  CommissionLabelUpdate._();

  factory CommissionLabelUpdate([
    void updates(CommissionLabelUpdateBuilder b),
  ]) = _$CommissionLabelUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CommissionLabelUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CommissionLabelUpdate> get serializer =>
      _$CommissionLabelUpdateSerializer();
}

class _$CommissionLabelUpdateSerializer
    implements PrimitiveSerializer<CommissionLabelUpdate> {
  @override
  final Iterable<Type> types = const [
    CommissionLabelUpdate,
    _$CommissionLabelUpdate,
  ];

  @override
  final String wireName = r'CommissionLabelUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CommissionLabelUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.commissionRate != null) {
      yield r'commission_rate';
      yield serializers.serialize(
        object.commissionRate,
        specifiedType: const FullType.nullable(CommissionRate1),
      );
    }
    if (object.comment != null) {
      yield r'comment';
      yield serializers.serialize(
        object.comment,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CommissionLabelUpdate object, {
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
    required CommissionLabelUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.name = valueDes;
          break;
        case r'commission_rate':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(CommissionRate1),
                  )
                  as CommissionRate1?;
          if (valueDes == null) continue;
          result.commissionRate.replace(valueDes);
          break;
        case r'comment':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.comment = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CommissionLabelUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CommissionLabelUpdateBuilder();
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
