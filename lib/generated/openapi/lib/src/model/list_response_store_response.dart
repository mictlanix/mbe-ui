//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/store_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_response_store_response.g.dart';

/// ListResponseStoreResponse
///
/// Properties:
/// * [items] 
/// * [total] 
@BuiltValue()
abstract class ListResponseStoreResponse implements Built<ListResponseStoreResponse, ListResponseStoreResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<StoreResponse> get items;

  @BuiltValueField(wireName: r'total')
  int get total;

  ListResponseStoreResponse._();

  factory ListResponseStoreResponse([void updates(ListResponseStoreResponseBuilder b)]) = _$ListResponseStoreResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListResponseStoreResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListResponseStoreResponse> get serializer => _$ListResponseStoreResponseSerializer();
}

class _$ListResponseStoreResponseSerializer implements PrimitiveSerializer<ListResponseStoreResponse> {
  @override
  final Iterable<Type> types = const [ListResponseStoreResponse, _$ListResponseStoreResponse];

  @override
  final String wireName = r'ListResponseStoreResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListResponseStoreResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(StoreResponse)]),
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
    ListResponseStoreResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ListResponseStoreResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(StoreResponse)]),
          ) as BuiltList<StoreResponse>;
          result.items.replace(valueDes);
          break;
        case r'total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
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
  ListResponseStoreResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListResponseStoreResponseBuilder();
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

