//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/sat_catalog_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_response_sat_catalog_response.g.dart';

/// ListResponseSatCatalogResponse
///
/// Properties:
/// * [items] 
/// * [total] 
@BuiltValue()
abstract class ListResponseSatCatalogResponse implements Built<ListResponseSatCatalogResponse, ListResponseSatCatalogResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<SatCatalogResponse> get items;

  @BuiltValueField(wireName: r'total')
  int get total;

  ListResponseSatCatalogResponse._();

  factory ListResponseSatCatalogResponse([void updates(ListResponseSatCatalogResponseBuilder b)]) = _$ListResponseSatCatalogResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListResponseSatCatalogResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListResponseSatCatalogResponse> get serializer => _$ListResponseSatCatalogResponseSerializer();
}

class _$ListResponseSatCatalogResponseSerializer implements PrimitiveSerializer<ListResponseSatCatalogResponse> {
  @override
  final Iterable<Type> types = const [ListResponseSatCatalogResponse, _$ListResponseSatCatalogResponse];

  @override
  final String wireName = r'ListResponseSatCatalogResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListResponseSatCatalogResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(SatCatalogResponse)]),
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
    ListResponseSatCatalogResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ListResponseSatCatalogResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(SatCatalogResponse)]),
          ) as BuiltList<SatCatalogResponse>;
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
  ListResponseSatCatalogResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListResponseSatCatalogResponseBuilder();
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

