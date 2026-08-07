//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/product_stock_response.dart';
import 'package:mbe_api_client/src/model/sat_unit_of_measurement_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'product_lookup_response.g.dart';

/// ProductLookupResponse
///
/// Properties:
/// * [product]
/// * [code]
/// * [name]
/// * [sku]
/// * [brand]
/// * [model]
/// * [barCode]
/// * [unitOfMeasurement]
/// * [price]
/// * [taxRate]
/// * [taxIncluded]
/// * [minOrderQty]
/// * [stockRequired]
/// * [stockable]
/// * [stock]
@BuiltValue()
abstract class ProductLookupResponse
    implements Built<ProductLookupResponse, ProductLookupResponseBuilder> {
  @BuiltValueField(wireName: r'product')
  int get product;

  @BuiltValueField(wireName: r'code')
  String get code;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'sku')
  String? get sku;

  @BuiltValueField(wireName: r'brand')
  String? get brand;

  @BuiltValueField(wireName: r'model')
  String? get model;

  @BuiltValueField(wireName: r'bar_code')
  String? get barCode;

  @BuiltValueField(wireName: r'unit_of_measurement')
  SatUnitOfMeasurementResponse? get unitOfMeasurement;

  @BuiltValueField(wireName: r'price')
  String get price;

  @BuiltValueField(wireName: r'tax_rate')
  String get taxRate;

  @BuiltValueField(wireName: r'tax_included')
  bool get taxIncluded;

  @BuiltValueField(wireName: r'min_order_qty')
  int get minOrderQty;

  @BuiltValueField(wireName: r'stock_required')
  bool get stockRequired;

  @BuiltValueField(wireName: r'stockable')
  bool get stockable;

  @BuiltValueField(wireName: r'stock')
  BuiltList<ProductStockResponse>? get stock;

  ProductLookupResponse._();

  factory ProductLookupResponse([
    void updates(ProductLookupResponseBuilder b),
  ]) = _$ProductLookupResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProductLookupResponseBuilder b) =>
      b..stock = ListBuilder();

  @BuiltValueSerializer(custom: true)
  static Serializer<ProductLookupResponse> get serializer =>
      _$ProductLookupResponseSerializer();
}

class _$ProductLookupResponseSerializer
    implements PrimitiveSerializer<ProductLookupResponse> {
  @override
  final Iterable<Type> types = const [
    ProductLookupResponse,
    _$ProductLookupResponse,
  ];

  @override
  final String wireName = r'ProductLookupResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProductLookupResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'product';
    yield serializers.serialize(
      object.product,
      specifiedType: const FullType(int),
    );
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'sku';
    yield object.sku == null
        ? null
        : serializers.serialize(
            object.sku,
            specifiedType: const FullType.nullable(String),
          );
    yield r'brand';
    yield object.brand == null
        ? null
        : serializers.serialize(
            object.brand,
            specifiedType: const FullType.nullable(String),
          );
    yield r'model';
    yield object.model == null
        ? null
        : serializers.serialize(
            object.model,
            specifiedType: const FullType.nullable(String),
          );
    yield r'bar_code';
    yield object.barCode == null
        ? null
        : serializers.serialize(
            object.barCode,
            specifiedType: const FullType.nullable(String),
          );
    if (object.unitOfMeasurement != null) {
      yield r'unit_of_measurement';
      yield serializers.serialize(
        object.unitOfMeasurement,
        specifiedType: const FullType.nullable(SatUnitOfMeasurementResponse),
      );
    }
    yield r'price';
    yield serializers.serialize(
      object.price,
      specifiedType: const FullType(String),
    );
    yield r'tax_rate';
    yield serializers.serialize(
      object.taxRate,
      specifiedType: const FullType(String),
    );
    yield r'tax_included';
    yield serializers.serialize(
      object.taxIncluded,
      specifiedType: const FullType(bool),
    );
    yield r'min_order_qty';
    yield serializers.serialize(
      object.minOrderQty,
      specifiedType: const FullType(int),
    );
    yield r'stock_required';
    yield serializers.serialize(
      object.stockRequired,
      specifiedType: const FullType(bool),
    );
    yield r'stockable';
    yield serializers.serialize(
      object.stockable,
      specifiedType: const FullType(bool),
    );
    if (object.stock != null) {
      yield r'stock';
      yield serializers.serialize(
        object.stock,
        specifiedType: const FullType(BuiltList, [
          FullType(ProductStockResponse),
        ]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ProductLookupResponse object, {
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
    required ProductLookupResponseBuilder result,
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
        case r'code':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.code = valueDes;
          break;
        case r'name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.name = valueDes;
          break;
        case r'sku':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.sku = valueDes;
          break;
        case r'brand':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.brand = valueDes;
          break;
        case r'model':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.model = valueDes;
          break;
        case r'bar_code':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.barCode = valueDes;
          break;
        case r'unit_of_measurement':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(
                      SatUnitOfMeasurementResponse,
                    ),
                  )
                  as SatUnitOfMeasurementResponse?;
          if (valueDes == null) continue;
          result.unitOfMeasurement.replace(valueDes);
          break;
        case r'price':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.price = valueDes;
          break;
        case r'tax_rate':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.taxRate = valueDes;
          break;
        case r'tax_included':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )
                  as bool;
          result.taxIncluded = valueDes;
          break;
        case r'min_order_qty':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.minOrderQty = valueDes;
          break;
        case r'stock_required':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )
                  as bool;
          result.stockRequired = valueDes;
          break;
        case r'stockable':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )
                  as bool;
          result.stockable = valueDes;
          break;
        case r'stock':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltList, [
                      FullType(ProductStockResponse),
                    ]),
                  )
                  as BuiltList<ProductStockResponse>;
          result.stock.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ProductLookupResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProductLookupResponseBuilder();
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
