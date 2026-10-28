//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'linked_document.g.dart';

/// LinkedDocument
///
/// Properties:
/// * [id]
/// * [label]
@BuiltValue()
abstract class LinkedDocument
    implements Built<LinkedDocument, LinkedDocumentBuilder> {
  @BuiltValueField(wireName: r'id')
  int get id;

  @BuiltValueField(wireName: r'label')
  String get label;

  LinkedDocument._();

  factory LinkedDocument([void updates(LinkedDocumentBuilder b)]) =
      _$LinkedDocument;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(LinkedDocumentBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<LinkedDocument> get serializer =>
      _$LinkedDocumentSerializer();
}

class _$LinkedDocumentSerializer
    implements PrimitiveSerializer<LinkedDocument> {
  @override
  final Iterable<Type> types = const [LinkedDocument, _$LinkedDocument];

  @override
  final String wireName = r'LinkedDocument';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    LinkedDocument object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(object.id, specifiedType: const FullType(int));
    yield r'label';
    yield serializers.serialize(
      object.label,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    LinkedDocument object, {
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
    required LinkedDocumentBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.id = valueDes;
          break;
        case r'label':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.label = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  LinkedDocument deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = LinkedDocumentBuilder();
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
