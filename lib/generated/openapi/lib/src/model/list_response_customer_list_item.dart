//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/customer_list_item.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_response_customer_list_item.g.dart';

/// ListResponseCustomerListItem
///
/// Properties:
/// * [items] 
/// * [total] 
@BuiltValue()
abstract class ListResponseCustomerListItem implements Built<ListResponseCustomerListItem, ListResponseCustomerListItemBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<CustomerListItem> get items;

  @BuiltValueField(wireName: r'total')
  int get total;

  ListResponseCustomerListItem._();

  factory ListResponseCustomerListItem([void updates(ListResponseCustomerListItemBuilder b)]) = _$ListResponseCustomerListItem;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListResponseCustomerListItemBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListResponseCustomerListItem> get serializer => _$ListResponseCustomerListItemSerializer();
}

class _$ListResponseCustomerListItemSerializer implements PrimitiveSerializer<ListResponseCustomerListItem> {
  @override
  final Iterable<Type> types = const [ListResponseCustomerListItem, _$ListResponseCustomerListItem];

  @override
  final String wireName = r'ListResponseCustomerListItem';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListResponseCustomerListItem object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(CustomerListItem)]),
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
    ListResponseCustomerListItem object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ListResponseCustomerListItemBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(CustomerListItem)]),
          ) as BuiltList<CustomerListItem>;
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
  ListResponseCustomerListItem deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListResponseCustomerListItemBuilder();
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

