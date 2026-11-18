//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'receiver_answer.g.dart';

/// ReceiverAnswer
///
/// Properties:
/// * [answer]
@BuiltValue()
abstract class ReceiverAnswer
    implements Built<ReceiverAnswer, ReceiverAnswerBuilder> {
  @BuiltValueField(wireName: r'answer')
  ReceiverAnswerAnswerEnum get answer;
  // enum answerEnum {  accept,  reject,  expire,  };

  ReceiverAnswer._();

  factory ReceiverAnswer([void updates(ReceiverAnswerBuilder b)]) =
      _$ReceiverAnswer;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReceiverAnswerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReceiverAnswer> get serializer =>
      _$ReceiverAnswerSerializer();
}

class _$ReceiverAnswerSerializer
    implements PrimitiveSerializer<ReceiverAnswer> {
  @override
  final Iterable<Type> types = const [ReceiverAnswer, _$ReceiverAnswer];

  @override
  final String wireName = r'ReceiverAnswer';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReceiverAnswer object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'answer';
    yield serializers.serialize(
      object.answer,
      specifiedType: const FullType(ReceiverAnswerAnswerEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ReceiverAnswer object, {
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
    required ReceiverAnswerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'answer':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(ReceiverAnswerAnswerEnum),
                  )
                  as ReceiverAnswerAnswerEnum;
          result.answer = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ReceiverAnswer deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReceiverAnswerBuilder();
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

class ReceiverAnswerAnswerEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'accept')
  static const ReceiverAnswerAnswerEnum accept =
      _$receiverAnswerAnswerEnum_accept;
  @BuiltValueEnumConst(wireName: r'reject')
  static const ReceiverAnswerAnswerEnum reject =
      _$receiverAnswerAnswerEnum_reject;
  @BuiltValueEnumConst(wireName: r'expire')
  static const ReceiverAnswerAnswerEnum expire =
      _$receiverAnswerAnswerEnum_expire;

  static Serializer<ReceiverAnswerAnswerEnum> get serializer =>
      _$receiverAnswerAnswerEnumSerializer;

  const ReceiverAnswerAnswerEnum._(String name) : super(name);

  static BuiltSet<ReceiverAnswerAnswerEnum> get values =>
      _$receiverAnswerAnswerEnumValues;
  static ReceiverAnswerAnswerEnum valueOf(String name) =>
      _$receiverAnswerAnswerEnumValueOf(name);
}
