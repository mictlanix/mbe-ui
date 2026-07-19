//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/warehouse_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_response_warehouse_response.g.dart';

/// ListResponseWarehouseResponse
///
/// Properties:
/// * [items]
/// * [total]
@BuiltValue()
abstract class ListResponseWarehouseResponse
    implements
        Built<
          ListResponseWarehouseResponse,
          ListResponseWarehouseResponseBuilder
        > {
  @BuiltValueField(wireName: r'items')
  BuiltList<WarehouseResponse> get items;

  @BuiltValueField(wireName: r'total')
  int get total;

  ListResponseWarehouseResponse._();

  factory ListResponseWarehouseResponse([
    void updates(ListResponseWarehouseResponseBuilder b),
  ]) = _$ListResponseWarehouseResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListResponseWarehouseResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListResponseWarehouseResponse> get serializer =>
      _$ListResponseWarehouseResponseSerializer();
}

class _$ListResponseWarehouseResponseSerializer
    implements PrimitiveSerializer<ListResponseWarehouseResponse> {
  @override
  final Iterable<Type> types = const [
    ListResponseWarehouseResponse,
    _$ListResponseWarehouseResponse,
  ];

  @override
  final String wireName = r'ListResponseWarehouseResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListResponseWarehouseResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(WarehouseResponse)]),
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
    ListResponseWarehouseResponse object, {
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
    required ListResponseWarehouseResponseBuilder result,
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
                      FullType(WarehouseResponse),
                    ]),
                  )
                  as BuiltList<WarehouseResponse>;
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
  ListResponseWarehouseResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListResponseWarehouseResponseBuilder();
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
