//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/credit_note_response.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_response_credit_note_response.g.dart';

/// ListResponseCreditNoteResponse
///
/// Properties:
/// * [items]
/// * [total]
@BuiltValue()
abstract class ListResponseCreditNoteResponse
    implements
        Built<
          ListResponseCreditNoteResponse,
          ListResponseCreditNoteResponseBuilder
        > {
  @BuiltValueField(wireName: r'items')
  BuiltList<CreditNoteResponse> get items;

  @BuiltValueField(wireName: r'total')
  int get total;

  ListResponseCreditNoteResponse._();

  factory ListResponseCreditNoteResponse([
    void updates(ListResponseCreditNoteResponseBuilder b),
  ]) = _$ListResponseCreditNoteResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListResponseCreditNoteResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListResponseCreditNoteResponse> get serializer =>
      _$ListResponseCreditNoteResponseSerializer();
}

class _$ListResponseCreditNoteResponseSerializer
    implements PrimitiveSerializer<ListResponseCreditNoteResponse> {
  @override
  final Iterable<Type> types = const [
    ListResponseCreditNoteResponse,
    _$ListResponseCreditNoteResponse,
  ];

  @override
  final String wireName = r'ListResponseCreditNoteResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListResponseCreditNoteResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(CreditNoteResponse)]),
    );
    yield r'total';
    yield serializers.serialize(
      object.total,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ListResponseCreditNoteResponse object, {
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
    required ListResponseCreditNoteResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltList, [
                      FullType(CreditNoteResponse),
                    ]),
                  )
                  as BuiltList<CreditNoteResponse>;
          result.items.replace(valueDes);
          break;
        case r'total':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.total = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ListResponseCreditNoteResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListResponseCreditNoteResponseBuilder();
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
