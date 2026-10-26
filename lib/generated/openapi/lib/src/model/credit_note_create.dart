//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'credit_note_create.g.dart';

/// CreditNoteCreate
///
/// Properties:
/// * [invoice]
@BuiltValue()
abstract class CreditNoteCreate
    implements Built<CreditNoteCreate, CreditNoteCreateBuilder> {
  @BuiltValueField(wireName: r'invoice')
  int get invoice;

  CreditNoteCreate._();

  factory CreditNoteCreate([void updates(CreditNoteCreateBuilder b)]) =
      _$CreditNoteCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreditNoteCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreditNoteCreate> get serializer =>
      _$CreditNoteCreateSerializer();
}

class _$CreditNoteCreateSerializer
    implements PrimitiveSerializer<CreditNoteCreate> {
  @override
  final Iterable<Type> types = const [CreditNoteCreate, _$CreditNoteCreate];

  @override
  final String wireName = r'CreditNoteCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreditNoteCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'invoice';
    yield serializers.serialize(
      object.invoice,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CreditNoteCreate object, {
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
    required CreditNoteCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'invoice':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.invoice = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreditNoteCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreditNoteCreateBuilder();
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
