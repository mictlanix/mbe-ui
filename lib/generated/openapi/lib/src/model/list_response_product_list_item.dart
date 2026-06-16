//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/product_list_item.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_response_product_list_item.g.dart';

/// ListResponseProductListItem
///
/// Properties:
/// * [items] 
/// * [total] 
@BuiltValue()
abstract class ListResponseProductListItem implements Built<ListResponseProductListItem, ListResponseProductListItemBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<ProductListItem> get items;

  @BuiltValueField(wireName: r'total')
  int get total;

  ListResponseProductListItem._();

  factory ListResponseProductListItem([void updates(ListResponseProductListItemBuilder b)]) = _$ListResponseProductListItem;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListResponseProductListItemBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListResponseProductListItem> get serializer => _$ListResponseProductListItemSerializer();
}

class _$ListResponseProductListItemSerializer implements PrimitiveSerializer<ListResponseProductListItem> {
  @override
  final Iterable<Type> types = const [ListResponseProductListItem, _$ListResponseProductListItem];

  @override
  final String wireName = r'ListResponseProductListItem';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListResponseProductListItem object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(ProductListItem)]),
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
    ListResponseProductListItem object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ListResponseProductListItemBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ProductListItem)]),
          ) as BuiltList<ProductListItem>;
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
  ListResponseProductListItem deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListResponseProductListItemBuilder();
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

