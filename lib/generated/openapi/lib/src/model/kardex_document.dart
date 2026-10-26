//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kardex_document.g.dart';

/// KardexDocument
///
/// Properties:
/// * [type]
/// * [id]
/// * [facility]
/// * [serial]
@BuiltValue()
abstract class KardexDocument
    implements Built<KardexDocument, KardexDocumentBuilder> {
  @BuiltValueField(wireName: r'type')
  int get type;

  @BuiltValueField(wireName: r'id')
  int get id;

  @BuiltValueField(wireName: r'facility')
  int? get facility;

  @BuiltValueField(wireName: r'serial')
  int? get serial;

  KardexDocument._();

  factory KardexDocument([void updates(KardexDocumentBuilder b)]) =
      _$KardexDocument;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KardexDocumentBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KardexDocument> get serializer =>
      _$KardexDocumentSerializer();
}

class _$KardexDocumentSerializer
    implements PrimitiveSerializer<KardexDocument> {
  @override
  final Iterable<Type> types = const [KardexDocument, _$KardexDocument];

  @override
  final String wireName = r'KardexDocument';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KardexDocument object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(int),
    );
    yield r'id';
    yield serializers.serialize(object.id, specifiedType: const FullType(int));
    if (object.facility != null) {
      yield r'facility';
      yield serializers.serialize(
        object.facility,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.serial != null) {
      yield r'serial';
      yield serializers.serialize(
        object.serial,
        specifiedType: const FullType.nullable(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    KardexDocument object, {
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
    required KardexDocumentBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'type':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.type = valueDes;
          break;
        case r'id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.id = valueDes;
          break;
        case r'facility':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.facility = valueDes;
          break;
        case r'serial':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.serial = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  KardexDocument deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KardexDocumentBuilder();
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
