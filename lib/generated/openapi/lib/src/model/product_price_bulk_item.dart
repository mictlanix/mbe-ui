//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/price.dart';
import 'package:mbe_api_client/src/model/low_profit.dart';
import 'package:mbe_api_client/src/model/high_profit.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'product_price_bulk_item.g.dart';

/// One cell of the pricing grid, keyed on `(product, price_list)` rather than on a row id.  That key is the `UNIQUE (product, list)` the table already carries, which is what lets one body express both halves of an upsert. A client editing a cell no longer has to pick `POST` against `PUT /{id}` from what its last read said, and no longer loses the race — and a 409 — when someone else priced that product in between (#183).
///
/// Properties:
/// * [product]
/// * [priceList]
/// * [price]
/// * [lowProfit]
/// * [highProfit]
@BuiltValue()
abstract class ProductPriceBulkItem
    implements Built<ProductPriceBulkItem, ProductPriceBulkItemBuilder> {
  @BuiltValueField(wireName: r'product')
  int get product;

  @BuiltValueField(wireName: r'price_list')
  int get priceList;

  @BuiltValueField(wireName: r'price')
  Price get price;

  @Deprecated('lowProfit has been deprecated')
  @BuiltValueField(wireName: r'low_profit')
  LowProfit? get lowProfit;

  @Deprecated('highProfit has been deprecated')
  @BuiltValueField(wireName: r'high_profit')
  HighProfit? get highProfit;

  ProductPriceBulkItem._();

  factory ProductPriceBulkItem([void updates(ProductPriceBulkItemBuilder b)]) =
      _$ProductPriceBulkItem;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProductPriceBulkItemBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ProductPriceBulkItem> get serializer =>
      _$ProductPriceBulkItemSerializer();
}

class _$ProductPriceBulkItemSerializer
    implements PrimitiveSerializer<ProductPriceBulkItem> {
  @override
  final Iterable<Type> types = const [
    ProductPriceBulkItem,
    _$ProductPriceBulkItem,
  ];

  @override
  final String wireName = r'ProductPriceBulkItem';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProductPriceBulkItem object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'product';
    yield serializers.serialize(
      object.product,
      specifiedType: const FullType(int),
    );
    yield r'price_list';
    yield serializers.serialize(
      object.priceList,
      specifiedType: const FullType(int),
    );
    yield r'price';
    yield serializers.serialize(
      object.price,
      specifiedType: const FullType(Price),
    );
    if (object.lowProfit != null) {
      yield r'low_profit';
      yield serializers.serialize(
        object.lowProfit,
        specifiedType: const FullType.nullable(LowProfit),
      );
    }
    if (object.highProfit != null) {
      yield r'high_profit';
      yield serializers.serialize(
        object.highProfit,
        specifiedType: const FullType.nullable(HighProfit),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ProductPriceBulkItem object, {
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
    required ProductPriceBulkItemBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'product':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.product = valueDes;
          break;
        case r'price_list':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.priceList = valueDes;
          break;
        case r'price':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(Price),
                  )
                  as Price;
          result.price.replace(valueDes);
          break;
        case r'low_profit':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(LowProfit),
                  )
                  as LowProfit?;
          if (valueDes == null) continue;
          result.lowProfit.replace(valueDes);
          break;
        case r'high_profit':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(HighProfit),
                  )
                  as HighProfit?;
          if (valueDes == null) continue;
          result.highProfit.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ProductPriceBulkItem deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProductPriceBulkItemBuilder();
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
