//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/point_sale_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_response_point_sale_response.g.dart';

/// ListResponsePointSaleResponse
///
/// Properties:
/// * [items]
/// * [total]
@BuiltValue()
abstract class ListResponsePointSaleResponse
    implements
        Built<
          ListResponsePointSaleResponse,
          ListResponsePointSaleResponseBuilder
        > {
  @BuiltValueField(wireName: r'items')
  BuiltList<PointSaleResponse> get items;

  @BuiltValueField(wireName: r'total')
  int get total;

  ListResponsePointSaleResponse._();

  factory ListResponsePointSaleResponse([
    void updates(ListResponsePointSaleResponseBuilder b),
  ]) = _$ListResponsePointSaleResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListResponsePointSaleResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListResponsePointSaleResponse> get serializer =>
      _$ListResponsePointSaleResponseSerializer();
}

class _$ListResponsePointSaleResponseSerializer
    implements PrimitiveSerializer<ListResponsePointSaleResponse> {
  @override
  final Iterable<Type> types = const [
    ListResponsePointSaleResponse,
    _$ListResponsePointSaleResponse,
  ];

  @override
  final String wireName = r'ListResponsePointSaleResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListResponsePointSaleResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(PointSaleResponse)]),
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
    ListResponsePointSaleResponse object, {
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
    required ListResponsePointSaleResponseBuilder result,
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
                      FullType(PointSaleResponse),
                    ]),
                  )
                  as BuiltList<PointSaleResponse>;
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
  ListResponsePointSaleResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListResponsePointSaleResponseBuilder();
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
