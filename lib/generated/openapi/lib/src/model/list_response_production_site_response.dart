//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/production_site_response.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_response_production_site_response.g.dart';

/// ListResponseProductionSiteResponse
///
/// Properties:
/// * [items]
/// * [total]
@BuiltValue()
abstract class ListResponseProductionSiteResponse
    implements
        Built<
          ListResponseProductionSiteResponse,
          ListResponseProductionSiteResponseBuilder
        > {
  @BuiltValueField(wireName: r'items')
  BuiltList<ProductionSiteResponse> get items;

  @BuiltValueField(wireName: r'total')
  int get total;

  ListResponseProductionSiteResponse._();

  factory ListResponseProductionSiteResponse([
    void updates(ListResponseProductionSiteResponseBuilder b),
  ]) = _$ListResponseProductionSiteResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListResponseProductionSiteResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListResponseProductionSiteResponse> get serializer =>
      _$ListResponseProductionSiteResponseSerializer();
}

class _$ListResponseProductionSiteResponseSerializer
    implements PrimitiveSerializer<ListResponseProductionSiteResponse> {
  @override
  final Iterable<Type> types = const [
    ListResponseProductionSiteResponse,
    _$ListResponseProductionSiteResponse,
  ];

  @override
  final String wireName = r'ListResponseProductionSiteResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListResponseProductionSiteResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [
        FullType(ProductionSiteResponse),
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
    ListResponseProductionSiteResponse object, {
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
    required ListResponseProductionSiteResponseBuilder result,
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
                      FullType(ProductionSiteResponse),
                    ]),
                  )
                  as BuiltList<ProductionSiteResponse>;
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
  ListResponseProductionSiteResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListResponseProductionSiteResponseBuilder();
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
