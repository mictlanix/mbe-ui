//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/price1.dart';
import 'package:mbe_api_client/src/model/high_profit1.dart';
import 'package:mbe_api_client/src/model/low_profit1.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'product_price_update.g.dart';

/// ProductPriceUpdate
///
/// Properties:
/// * [price]
/// * [lowProfit]
/// * [highProfit]
@BuiltValue()
abstract class ProductPriceUpdate
    implements Built<ProductPriceUpdate, ProductPriceUpdateBuilder> {
  @BuiltValueField(wireName: r'price')
  Price1? get price;

  @BuiltValueField(wireName: r'low_profit')
  LowProfit1? get lowProfit;

  @BuiltValueField(wireName: r'high_profit')
  HighProfit1? get highProfit;

  ProductPriceUpdate._();

  factory ProductPriceUpdate([void updates(ProductPriceUpdateBuilder b)]) =
      _$ProductPriceUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProductPriceUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ProductPriceUpdate> get serializer =>
      _$ProductPriceUpdateSerializer();
}

class _$ProductPriceUpdateSerializer
    implements PrimitiveSerializer<ProductPriceUpdate> {
  @override
  final Iterable<Type> types = const [ProductPriceUpdate, _$ProductPriceUpdate];

  @override
  final String wireName = r'ProductPriceUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProductPriceUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.price != null) {
      yield r'price';
      yield serializers.serialize(
        object.price,
        specifiedType: const FullType.nullable(Price1),
      );
    }
    if (object.lowProfit != null) {
      yield r'low_profit';
      yield serializers.serialize(
        object.lowProfit,
        specifiedType: const FullType.nullable(LowProfit1),
      );
    }
    if (object.highProfit != null) {
      yield r'high_profit';
      yield serializers.serialize(
        object.highProfit,
        specifiedType: const FullType.nullable(HighProfit1),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ProductPriceUpdate object, {
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
    required ProductPriceUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'price':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(Price1),
                  )
                  as Price1?;
          if (valueDes == null) continue;
          result.price.replace(valueDes);
          break;
        case r'low_profit':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(LowProfit1),
                  )
                  as LowProfit1?;
          if (valueDes == null) continue;
          result.lowProfit.replace(valueDes);
          break;
        case r'high_profit':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(HighProfit1),
                  )
                  as HighProfit1?;
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
  ProductPriceUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProductPriceUpdateBuilder();
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
