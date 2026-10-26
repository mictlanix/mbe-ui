//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/stock_row.dart';
import 'package:mbe_api_client/src/model/in_transit_stock.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'product_stock.g.dart';

/// ProductStock
///
/// Properties:
/// * [product]
/// * [warehouses]
/// * [inTransit]
@BuiltValue()
abstract class ProductStock
    implements Built<ProductStock, ProductStockBuilder> {
  @BuiltValueField(wireName: r'product')
  int get product;

  @BuiltValueField(wireName: r'warehouses')
  BuiltList<StockRow>? get warehouses;

  @BuiltValueField(wireName: r'in_transit')
  BuiltList<InTransitStock>? get inTransit;

  ProductStock._();

  factory ProductStock([void updates(ProductStockBuilder b)]) = _$ProductStock;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProductStockBuilder b) => b
    ..warehouses = ListBuilder()
    ..inTransit = ListBuilder();

  @BuiltValueSerializer(custom: true)
  static Serializer<ProductStock> get serializer => _$ProductStockSerializer();
}

class _$ProductStockSerializer implements PrimitiveSerializer<ProductStock> {
  @override
  final Iterable<Type> types = const [ProductStock, _$ProductStock];

  @override
  final String wireName = r'ProductStock';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProductStock object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'product';
    yield serializers.serialize(
      object.product,
      specifiedType: const FullType(int),
    );
    if (object.warehouses != null) {
      yield r'warehouses';
      yield serializers.serialize(
        object.warehouses,
        specifiedType: const FullType(BuiltList, [FullType(StockRow)]),
      );
    }
    if (object.inTransit != null) {
      yield r'in_transit';
      yield serializers.serialize(
        object.inTransit,
        specifiedType: const FullType(BuiltList, [FullType(InTransitStock)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ProductStock object, {
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
    required ProductStockBuilder result,
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
        case r'warehouses':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(BuiltList, [
                      FullType(StockRow),
                    ]),
                  )
                  as BuiltList<StockRow>?;
          if (valueDes == null) continue;
          result.warehouses.replace(valueDes);
          break;
        case r'in_transit':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(BuiltList, [
                      FullType(InTransitStock),
                    ]),
                  )
                  as BuiltList<InTransitStock>?;
          if (valueDes == null) continue;
          result.inTransit.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ProductStock deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProductStockBuilder();
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
