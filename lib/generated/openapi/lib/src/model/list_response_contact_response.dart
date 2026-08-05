//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/contact_response.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_response_contact_response.g.dart';

/// ListResponseContactResponse
///
/// Properties:
/// * [items]
/// * [total]
@BuiltValue()
abstract class ListResponseContactResponse
    implements
        Built<ListResponseContactResponse, ListResponseContactResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<ContactResponse> get items;

  @BuiltValueField(wireName: r'total')
  int get total;

  ListResponseContactResponse._();

  factory ListResponseContactResponse([
    void updates(ListResponseContactResponseBuilder b),
  ]) = _$ListResponseContactResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListResponseContactResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListResponseContactResponse> get serializer =>
      _$ListResponseContactResponseSerializer();
}

class _$ListResponseContactResponseSerializer
    implements PrimitiveSerializer<ListResponseContactResponse> {
  @override
  final Iterable<Type> types = const [
    ListResponseContactResponse,
    _$ListResponseContactResponse,
  ];

  @override
  final String wireName = r'ListResponseContactResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListResponseContactResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(ContactResponse)]),
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
    ListResponseContactResponse object, {
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
    required ListResponseContactResponseBuilder result,
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
                      FullType(ContactResponse),
                    ]),
                  )
                  as BuiltList<ContactResponse>;
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
  ListResponseContactResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListResponseContactResponseBuilder();
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
