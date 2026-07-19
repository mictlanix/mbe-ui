//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/price.dart';
import 'package:mbe_api_client/src/model/low_profit.dart';
import 'package:mbe_api_client/src/model/high_profit.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'product_price_create.g.dart';

/// ProductPriceCreate
///
/// Properties:
/// * [product]
/// * [priceList]
/// * [price]
/// * [lowProfit]
/// * [highProfit]
@BuiltValue()
abstract class ProductPriceCreate
    implements Built<ProductPriceCreate, ProductPriceCreateBuilder> {
  @BuiltValueField(wireName: r'product')
  int get product;

  @BuiltValueField(wireName: r'price_list')
  int get priceList;

  @BuiltValueField(wireName: r'price')
  Price get price;

  @BuiltValueField(wireName: r'low_profit')
  LowProfit get lowProfit;

  @BuiltValueField(wireName: r'high_profit')
  HighProfit get highProfit;

  ProductPriceCreate._();

  factory ProductPriceCreate([void updates(ProductPriceCreateBuilder b)]) =
      _$ProductPriceCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProductPriceCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ProductPriceCreate> get serializer =>
      _$ProductPriceCreateSerializer();
}

class _$ProductPriceCreateSerializer
    implements PrimitiveSerializer<ProductPriceCreate> {
  @override
  final Iterable<Type> types = const [ProductPriceCreate, _$ProductPriceCreate];

  @override
  final String wireName = r'ProductPriceCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProductPriceCreate object, {
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
    yield r'low_profit';
    yield serializers.serialize(
      object.lowProfit,
      specifiedType: const FullType(LowProfit),
    );
    yield r'high_profit';
    yield serializers.serialize(
      object.highProfit,
      specifiedType: const FullType(HighProfit),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ProductPriceCreate object, {
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
    required ProductPriceCreateBuilder result,
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
                    specifiedType: const FullType(LowProfit),
                  )
                  as LowProfit;
          result.lowProfit.replace(valueDes);
          break;
        case r'high_profit':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(HighProfit),
                  )
                  as HighProfit;
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
  ProductPriceCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProductPriceCreateBuilder();
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
