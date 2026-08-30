//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'product_missing_price_facet.g.dart';

/// How many products in the current filter set have no price on this list (#184).  The count a pricing grid's worklist chip renders. `price_list` rather than `label_id` beside it because the two facets answer different questions off the same product set, and a client reads them into different chips.
///
/// Properties:
/// * [priceList]
/// * [missingCount]
@BuiltValue()
abstract class ProductMissingPriceFacet
    implements
        Built<ProductMissingPriceFacet, ProductMissingPriceFacetBuilder> {
  @BuiltValueField(wireName: r'price_list')
  int get priceList;

  @BuiltValueField(wireName: r'missing_count')
  int get missingCount;

  ProductMissingPriceFacet._();

  factory ProductMissingPriceFacet([
    void updates(ProductMissingPriceFacetBuilder b),
  ]) = _$ProductMissingPriceFacet;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProductMissingPriceFacetBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ProductMissingPriceFacet> get serializer =>
      _$ProductMissingPriceFacetSerializer();
}

class _$ProductMissingPriceFacetSerializer
    implements PrimitiveSerializer<ProductMissingPriceFacet> {
  @override
  final Iterable<Type> types = const [
    ProductMissingPriceFacet,
    _$ProductMissingPriceFacet,
  ];

  @override
  final String wireName = r'ProductMissingPriceFacet';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProductMissingPriceFacet object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'price_list';
    yield serializers.serialize(
      object.priceList,
      specifiedType: const FullType(int),
    );
    yield r'missing_count';
    yield serializers.serialize(
      object.missingCount,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ProductMissingPriceFacet object, {
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
    required ProductMissingPriceFacetBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'price_list':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.priceList = valueDes;
          break;
        case r'missing_count':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.missingCount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ProductMissingPriceFacet deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProductMissingPriceFacetBuilder();
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
