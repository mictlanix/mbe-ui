//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/label_response.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_response_label_response.g.dart';

/// ListResponseLabelResponse
///
/// Properties:
/// * [items]
/// * [total]
@BuiltValue()
abstract class ListResponseLabelResponse
    implements
        Built<ListResponseLabelResponse, ListResponseLabelResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<LabelResponse> get items;

  @BuiltValueField(wireName: r'total')
  int get total;

  ListResponseLabelResponse._();

  factory ListResponseLabelResponse([
    void updates(ListResponseLabelResponseBuilder b),
  ]) = _$ListResponseLabelResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListResponseLabelResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListResponseLabelResponse> get serializer =>
      _$ListResponseLabelResponseSerializer();
}

class _$ListResponseLabelResponseSerializer
    implements PrimitiveSerializer<ListResponseLabelResponse> {
  @override
  final Iterable<Type> types = const [
    ListResponseLabelResponse,
    _$ListResponseLabelResponse,
  ];

  @override
  final String wireName = r'ListResponseLabelResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListResponseLabelResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(LabelResponse)]),
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
    ListResponseLabelResponse object, {
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
    required ListResponseLabelResponseBuilder result,
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
                      FullType(LabelResponse),
                    ]),
                  )
                  as BuiltList<LabelResponse>;
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
  ListResponseLabelResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListResponseLabelResponseBuilder();
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
