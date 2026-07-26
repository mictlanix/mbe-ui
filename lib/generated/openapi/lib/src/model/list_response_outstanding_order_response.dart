//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/outstanding_order_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_response_outstanding_order_response.g.dart';

/// ListResponseOutstandingOrderResponse
///
/// Properties:
/// * [items]
/// * [total]
@BuiltValue()
abstract class ListResponseOutstandingOrderResponse
    implements
        Built<
          ListResponseOutstandingOrderResponse,
          ListResponseOutstandingOrderResponseBuilder
        > {
  @BuiltValueField(wireName: r'items')
  BuiltList<OutstandingOrderResponse> get items;

  @BuiltValueField(wireName: r'total')
  int get total;

  ListResponseOutstandingOrderResponse._();

  factory ListResponseOutstandingOrderResponse([
    void updates(ListResponseOutstandingOrderResponseBuilder b),
  ]) = _$ListResponseOutstandingOrderResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListResponseOutstandingOrderResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListResponseOutstandingOrderResponse> get serializer =>
      _$ListResponseOutstandingOrderResponseSerializer();
}

class _$ListResponseOutstandingOrderResponseSerializer
    implements PrimitiveSerializer<ListResponseOutstandingOrderResponse> {
  @override
  final Iterable<Type> types = const [
    ListResponseOutstandingOrderResponse,
    _$ListResponseOutstandingOrderResponse,
  ];

  @override
  final String wireName = r'ListResponseOutstandingOrderResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListResponseOutstandingOrderResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [
        FullType(OutstandingOrderResponse),
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
    ListResponseOutstandingOrderResponse object, {
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
    required ListResponseOutstandingOrderResponseBuilder result,
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
                      FullType(OutstandingOrderResponse),
                    ]),
                  )
                  as BuiltList<OutstandingOrderResponse>;
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
  ListResponseOutstandingOrderResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListResponseOutstandingOrderResponseBuilder();
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
