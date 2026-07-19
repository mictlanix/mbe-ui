//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'label_response.g.dart';

/// LabelResponse
///
/// Properties:
/// * [labelId]
/// * [name]
/// * [comment]
@BuiltValue()
abstract class LabelResponse
    implements Built<LabelResponse, LabelResponseBuilder> {
  @BuiltValueField(wireName: r'label_id')
  int get labelId;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  LabelResponse._();

  factory LabelResponse([void updates(LabelResponseBuilder b)]) =
      _$LabelResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(LabelResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<LabelResponse> get serializer =>
      _$LabelResponseSerializer();
}

class _$LabelResponseSerializer implements PrimitiveSerializer<LabelResponse> {
  @override
  final Iterable<Type> types = const [LabelResponse, _$LabelResponse];

  @override
  final String wireName = r'LabelResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    LabelResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'label_id';
    yield serializers.serialize(
      object.labelId,
      specifiedType: const FullType(int),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'comment';
    yield object.comment == null
        ? null
        : serializers.serialize(
            object.comment,
            specifiedType: const FullType.nullable(String),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    LabelResponse object, {
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
    required LabelResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'label_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.labelId = valueDes;
          break;
        case r'name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.name = valueDes;
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
  LabelResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = LabelResponseBuilder();
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
