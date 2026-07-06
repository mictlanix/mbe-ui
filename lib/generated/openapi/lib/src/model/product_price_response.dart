//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/price_list_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'product_price_response.g.dart';

/// ProductPriceResponse
///
/// Properties:
/// * [productPriceId] 
/// * [product] 
/// * [priceList] 
/// * [price] 
/// * [lowProfit] 
/// * [highProfit] 
@BuiltValue()
abstract class ProductPriceResponse implements Built<ProductPriceResponse, ProductPriceResponseBuilder> {
  @BuiltValueField(wireName: r'product_price_id')
  int get productPriceId;

  @BuiltValueField(wireName: r'product')
  int get product;

  @BuiltValueField(wireName: r'price_list')
  PriceListResponse get priceList;

  @BuiltValueField(wireName: r'price')
  String get price;

  @BuiltValueField(wireName: r'low_profit')
  String get lowProfit;

  @BuiltValueField(wireName: r'high_profit')
  String get highProfit;

  ProductPriceResponse._();

  factory ProductPriceResponse([void updates(ProductPriceResponseBuilder b)]) = _$ProductPriceResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProductPriceResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ProductPriceResponse> get serializer => _$ProductPriceResponseSerializer();
}

class _$ProductPriceResponseSerializer implements PrimitiveSerializer<ProductPriceResponse> {
  @override
  final Iterable<Type> types = const [ProductPriceResponse, _$ProductPriceResponse];

  @override
  final String wireName = r'ProductPriceResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProductPriceResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'product_price_id';
    yield serializers.serialize(
      object.productPriceId,
      specifiedType: const FullType(int),
    );
    yield r'product';
    yield serializers.serialize(
      object.product,
      specifiedType: const FullType(int),
    );
    yield r'price_list';
    yield serializers.serialize(
      object.priceList,
      specifiedType: const FullType(PriceListResponse),
    );
    yield r'price';
    yield serializers.serialize(
      object.price,
      specifiedType: const FullType(String),
    );
    yield r'low_profit';
    yield serializers.serialize(
      object.lowProfit,
      specifiedType: const FullType(String),
    );
    yield r'high_profit';
    yield serializers.serialize(
      object.highProfit,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ProductPriceResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ProductPriceResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'product_price_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.productPriceId = valueDes;
          break;
        case r'product':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.product = valueDes;
          break;
        case r'price_list':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PriceListResponse),
          ) as PriceListResponse;
          result.priceList.replace(valueDes);
          break;
        case r'price':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.price = valueDes;
          break;
        case r'low_profit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.lowProfit = valueDes;
          break;
        case r'high_profit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.highProfit = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ProductPriceResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProductPriceResponseBuilder();
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

