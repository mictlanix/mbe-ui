//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/label_response.dart';
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/product_price_response.dart';
import 'package:mbe_api_client/src/model/sat_catalog_response.dart';
import 'package:mbe_api_client/src/model/sat_unit_of_measurement_response.dart';
import 'package:mbe_api_client/src/model/supplier_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'product_response.g.dart';

/// ProductResponse
///
/// Properties:
/// * [productId] 
/// * [code] 
/// * [name] 
/// * [photo] 
/// * [sku] 
/// * [brand] 
/// * [model] 
/// * [barCode] 
/// * [location] 
/// * [unitOfMeasurement] 
/// * [key] 
/// * [taxRate] 
/// * [taxIncluded] 
/// * [priceType] 
/// * [currency] 
/// * [minOrderQty] 
/// * [supplier] 
/// * [stockable] 
/// * [perishable] 
/// * [seriable] 
/// * [purchasable] 
/// * [salable] 
/// * [invoiceable] 
/// * [stockVerification] 
/// * [deactivated] 
/// * [comment] 
/// * [prices] 
/// * [labels] 
@BuiltValue()
abstract class ProductResponse implements Built<ProductResponse, ProductResponseBuilder> {
  @BuiltValueField(wireName: r'product_id')
  int get productId;

  @BuiltValueField(wireName: r'code')
  String get code;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'photo')
  String? get photo;

  @BuiltValueField(wireName: r'sku')
  String? get sku;

  @BuiltValueField(wireName: r'brand')
  String? get brand;

  @BuiltValueField(wireName: r'model')
  String? get model;

  @BuiltValueField(wireName: r'bar_code')
  String? get barCode;

  @BuiltValueField(wireName: r'location')
  String? get location;

  @BuiltValueField(wireName: r'unit_of_measurement')
  SatUnitOfMeasurementResponse get unitOfMeasurement;

  @BuiltValueField(wireName: r'key')
  SatCatalogResponse? get key;

  @BuiltValueField(wireName: r'tax_rate')
  String get taxRate;

  @BuiltValueField(wireName: r'tax_included')
  bool get taxIncluded;

  @BuiltValueField(wireName: r'price_type')
  int get priceType;

  @BuiltValueField(wireName: r'currency')
  int get currency;

  @BuiltValueField(wireName: r'min_order_qty')
  int get minOrderQty;

  @BuiltValueField(wireName: r'supplier')
  SupplierResponse? get supplier;

  @BuiltValueField(wireName: r'stockable')
  bool get stockable;

  @BuiltValueField(wireName: r'perishable')
  bool get perishable;

  @BuiltValueField(wireName: r'seriable')
  bool get seriable;

  @BuiltValueField(wireName: r'purchasable')
  bool get purchasable;

  @BuiltValueField(wireName: r'salable')
  bool get salable;

  @BuiltValueField(wireName: r'invoiceable')
  bool get invoiceable;

  @BuiltValueField(wireName: r'stock_verification')
  bool get stockVerification;

  @BuiltValueField(wireName: r'deactivated')
  bool get deactivated;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  @BuiltValueField(wireName: r'prices')
  BuiltList<ProductPriceResponse>? get prices;

  @BuiltValueField(wireName: r'labels')
  BuiltList<LabelResponse>? get labels;

  ProductResponse._();

  factory ProductResponse([void updates(ProductResponseBuilder b)]) = _$ProductResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProductResponseBuilder b) => b
      ..prices = ListBuilder()
      ..labels = ListBuilder();

  @BuiltValueSerializer(custom: true)
  static Serializer<ProductResponse> get serializer => _$ProductResponseSerializer();
}

class _$ProductResponseSerializer implements PrimitiveSerializer<ProductResponse> {
  @override
  final Iterable<Type> types = const [ProductResponse, _$ProductResponse];

  @override
  final String wireName = r'ProductResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProductResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'product_id';
    yield serializers.serialize(
      object.productId,
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
    yield r'photo';
    yield object.photo == null ? null : serializers.serialize(
      object.photo,
      specifiedType: const FullType.nullable(String),
    );
    yield r'sku';
    yield object.sku == null ? null : serializers.serialize(
      object.sku,
      specifiedType: const FullType.nullable(String),
    );
    yield r'brand';
    yield object.brand == null ? null : serializers.serialize(
      object.brand,
      specifiedType: const FullType.nullable(String),
    );
    yield r'model';
    yield object.model == null ? null : serializers.serialize(
      object.model,
      specifiedType: const FullType.nullable(String),
    );
    yield r'bar_code';
    yield object.barCode == null ? null : serializers.serialize(
      object.barCode,
      specifiedType: const FullType.nullable(String),
    );
    yield r'location';
    yield object.location == null ? null : serializers.serialize(
      object.location,
      specifiedType: const FullType.nullable(String),
    );
    yield r'unit_of_measurement';
    yield serializers.serialize(
      object.unitOfMeasurement,
      specifiedType: const FullType(SatUnitOfMeasurementResponse),
    );
    yield r'key';
    yield object.key == null ? null : serializers.serialize(
      object.key,
      specifiedType: const FullType.nullable(SatCatalogResponse),
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
    yield r'price_type';
    yield serializers.serialize(
      object.priceType,
      specifiedType: const FullType(int),
    );
    yield r'currency';
    yield serializers.serialize(
      object.currency,
      specifiedType: const FullType(int),
    );
    yield r'min_order_qty';
    yield serializers.serialize(
      object.minOrderQty,
      specifiedType: const FullType(int),
    );
    yield r'supplier';
    yield object.supplier == null ? null : serializers.serialize(
      object.supplier,
      specifiedType: const FullType.nullable(SupplierResponse),
    );
    yield r'stockable';
    yield serializers.serialize(
      object.stockable,
      specifiedType: const FullType(bool),
    );
    yield r'perishable';
    yield serializers.serialize(
      object.perishable,
      specifiedType: const FullType(bool),
    );
    yield r'seriable';
    yield serializers.serialize(
      object.seriable,
      specifiedType: const FullType(bool),
    );
    yield r'purchasable';
    yield serializers.serialize(
      object.purchasable,
      specifiedType: const FullType(bool),
    );
    yield r'salable';
    yield serializers.serialize(
      object.salable,
      specifiedType: const FullType(bool),
    );
    yield r'invoiceable';
    yield serializers.serialize(
      object.invoiceable,
      specifiedType: const FullType(bool),
    );
    yield r'stock_verification';
    yield serializers.serialize(
      object.stockVerification,
      specifiedType: const FullType(bool),
    );
    yield r'deactivated';
    yield serializers.serialize(
      object.deactivated,
      specifiedType: const FullType(bool),
    );
    yield r'comment';
    yield object.comment == null ? null : serializers.serialize(
      object.comment,
      specifiedType: const FullType.nullable(String),
    );
    if (object.prices != null) {
      yield r'prices';
      yield serializers.serialize(
        object.prices,
        specifiedType: const FullType(BuiltList, [FullType(ProductPriceResponse)]),
      );
    }
    if (object.labels != null) {
      yield r'labels';
      yield serializers.serialize(
        object.labels,
        specifiedType: const FullType(BuiltList, [FullType(LabelResponse)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ProductResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ProductResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'product_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.productId = valueDes;
          break;
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.code = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'photo':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.photo = valueDes;
          break;
        case r'sku':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.sku = valueDes;
          break;
        case r'brand':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.brand = valueDes;
          break;
        case r'model':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.model = valueDes;
          break;
        case r'bar_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.barCode = valueDes;
          break;
        case r'location':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.location = valueDes;
          break;
        case r'unit_of_measurement':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SatUnitOfMeasurementResponse),
          ) as SatUnitOfMeasurementResponse;
          result.unitOfMeasurement.replace(valueDes);
          break;
        case r'key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(SatCatalogResponse),
          ) as SatCatalogResponse?;
          if (valueDes == null) continue;
          result.key.replace(valueDes);
          break;
        case r'tax_rate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.taxRate = valueDes;
          break;
        case r'tax_included':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.taxIncluded = valueDes;
          break;
        case r'price_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.priceType = valueDes;
          break;
        case r'currency':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.currency = valueDes;
          break;
        case r'min_order_qty':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.minOrderQty = valueDes;
          break;
        case r'supplier':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(SupplierResponse),
          ) as SupplierResponse?;
          if (valueDes == null) continue;
          result.supplier.replace(valueDes);
          break;
        case r'stockable':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.stockable = valueDes;
          break;
        case r'perishable':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.perishable = valueDes;
          break;
        case r'seriable':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.seriable = valueDes;
          break;
        case r'purchasable':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.purchasable = valueDes;
          break;
        case r'salable':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.salable = valueDes;
          break;
        case r'invoiceable':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.invoiceable = valueDes;
          break;
        case r'stock_verification':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.stockVerification = valueDes;
          break;
        case r'deactivated':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.deactivated = valueDes;
          break;
        case r'comment':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.comment = valueDes;
          break;
        case r'prices':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ProductPriceResponse)]),
          ) as BuiltList<ProductPriceResponse>;
          result.prices.replace(valueDes);
          break;
        case r'labels':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(LabelResponse)]),
          ) as BuiltList<LabelResponse>;
          result.labels.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ProductResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProductResponseBuilder();
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

