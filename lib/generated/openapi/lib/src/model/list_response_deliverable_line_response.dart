//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/deliverable_line_response.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_response_deliverable_line_response.g.dart';

/// ListResponseDeliverableLineResponse
///
/// Properties:
/// * [items]
/// * [total]
@BuiltValue()
abstract class ListResponseDeliverableLineResponse
    implements
        Built<
          ListResponseDeliverableLineResponse,
          ListResponseDeliverableLineResponseBuilder
        > {
  @BuiltValueField(wireName: r'items')
  BuiltList<DeliverableLineResponse> get items;

  @BuiltValueField(wireName: r'total')
  int get total;

  ListResponseDeliverableLineResponse._();

  factory ListResponseDeliverableLineResponse([
    void updates(ListResponseDeliverableLineResponseBuilder b),
  ]) = _$ListResponseDeliverableLineResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListResponseDeliverableLineResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListResponseDeliverableLineResponse> get serializer =>
      _$ListResponseDeliverableLineResponseSerializer();
}

class _$ListResponseDeliverableLineResponseSerializer
    implements PrimitiveSerializer<ListResponseDeliverableLineResponse> {
  @override
  final Iterable<Type> types = const [
    ListResponseDeliverableLineResponse,
    _$ListResponseDeliverableLineResponse,
  ];

  @override
  final String wireName = r'ListResponseDeliverableLineResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListResponseDeliverableLineResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [
        FullType(DeliverableLineResponse),
      ]),
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
    ListResponseDeliverableLineResponse object, {
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
    required ListResponseDeliverableLineResponseBuilder result,
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
                      FullType(DeliverableLineResponse),
                    ]),
                  )
                  as BuiltList<DeliverableLineResponse>;
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
  ListResponseDeliverableLineResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListResponseDeliverableLineResponseBuilder();
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
