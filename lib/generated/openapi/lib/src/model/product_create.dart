//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/tax_rate.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'product_create.g.dart';

/// ProductCreate
///
/// Properties:
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
/// * [supplier]
/// * [stockable]
/// * [perishable]
/// * [seriable]
/// * [purchasable]
/// * [salable]
/// * [invoiceable]
/// * [stockRequired]
/// * [comment]
/// * [labels]
@BuiltValue()
abstract class ProductCreate
    implements Built<ProductCreate, ProductCreateBuilder> {
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
  String get unitOfMeasurement;

  @BuiltValueField(wireName: r'key')
  String? get key;

  @BuiltValueField(wireName: r'tax_rate')
  TaxRate? get taxRate;

  @BuiltValueField(wireName: r'tax_included')
  bool? get taxIncluded;

  @BuiltValueField(wireName: r'price_type')
  int? get priceType;

  @BuiltValueField(wireName: r'currency')
  int? get currency;

  @BuiltValueField(wireName: r'supplier')
  int? get supplier;

  @BuiltValueField(wireName: r'stockable')
  bool? get stockable;

  @BuiltValueField(wireName: r'perishable')
  bool? get perishable;

  @BuiltValueField(wireName: r'seriable')
  bool? get seriable;

  @BuiltValueField(wireName: r'purchasable')
  bool? get purchasable;

  @BuiltValueField(wireName: r'salable')
  bool? get salable;

  @BuiltValueField(wireName: r'invoiceable')
  bool? get invoiceable;

  @BuiltValueField(wireName: r'stock_required')
  bool? get stockRequired;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  @BuiltValueField(wireName: r'labels')
  BuiltList<int>? get labels;

  ProductCreate._();

  factory ProductCreate([void updates(ProductCreateBuilder b)]) =
      _$ProductCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProductCreateBuilder b) => b
    ..currency = 0
    ..stockable = false
    ..perishable = false
    ..seriable = false
    ..purchasable = false
    ..salable = false
    ..invoiceable = false;

  @BuiltValueSerializer(custom: true)
  static Serializer<ProductCreate> get serializer =>
      _$ProductCreateSerializer();
}

class _$ProductCreateSerializer implements PrimitiveSerializer<ProductCreate> {
  @override
  final Iterable<Type> types = const [ProductCreate, _$ProductCreate];

  @override
  final String wireName = r'ProductCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProductCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
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
    if (object.photo != null) {
      yield r'photo';
      yield serializers.serialize(
        object.photo,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.sku != null) {
      yield r'sku';
      yield serializers.serialize(
        object.sku,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.brand != null) {
      yield r'brand';
      yield serializers.serialize(
        object.brand,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.model != null) {
      yield r'model';
      yield serializers.serialize(
        object.model,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.barCode != null) {
      yield r'bar_code';
      yield serializers.serialize(
        object.barCode,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.location != null) {
      yield r'location';
      yield serializers.serialize(
        object.location,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'unit_of_measurement';
    yield serializers.serialize(
      object.unitOfMeasurement,
      specifiedType: const FullType(String),
    );
    if (object.key != null) {
      yield r'key';
      yield serializers.serialize(
        object.key,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.taxRate != null) {
      yield r'tax_rate';
      yield serializers.serialize(
        object.taxRate,
        specifiedType: const FullType.nullable(TaxRate),
      );
    }
    if (object.taxIncluded != null) {
      yield r'tax_included';
      yield serializers.serialize(
        object.taxIncluded,
        specifiedType: const FullType.nullable(bool),
      );
    }
    if (object.priceType != null) {
      yield r'price_type';
      yield serializers.serialize(
        object.priceType,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.currency != null) {
      yield r'currency';
      yield serializers.serialize(
        object.currency,
        specifiedType: const FullType(int),
      );
    }
    if (object.supplier != null) {
      yield r'supplier';
      yield serializers.serialize(
        object.supplier,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.stockable != null) {
      yield r'stockable';
      yield serializers.serialize(
        object.stockable,
        specifiedType: const FullType(bool),
      );
    }
    if (object.perishable != null) {
      yield r'perishable';
      yield serializers.serialize(
        object.perishable,
        specifiedType: const FullType(bool),
      );
    }
    if (object.seriable != null) {
      yield r'seriable';
      yield serializers.serialize(
        object.seriable,
        specifiedType: const FullType(bool),
      );
    }
    if (object.purchasable != null) {
      yield r'purchasable';
      yield serializers.serialize(
        object.purchasable,
        specifiedType: const FullType(bool),
      );
    }
    if (object.salable != null) {
      yield r'salable';
      yield serializers.serialize(
        object.salable,
        specifiedType: const FullType(bool),
      );
    }
    if (object.invoiceable != null) {
      yield r'invoiceable';
      yield serializers.serialize(
        object.invoiceable,
        specifiedType: const FullType(bool),
      );
    }
    if (object.stockRequired != null) {
      yield r'stock_required';
      yield serializers.serialize(
        object.stockRequired,
        specifiedType: const FullType.nullable(bool),
      );
    }
    if (object.comment != null) {
      yield r'comment';
      yield serializers.serialize(
        object.comment,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.labels != null) {
      yield r'labels';
      yield serializers.serialize(
        object.labels,
        specifiedType: const FullType.nullable(BuiltList, [FullType(int)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ProductCreate object, {
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
    required ProductCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
        case r'photo':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.photo = valueDes;
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
        case r'location':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.location = valueDes;
          break;
        case r'unit_of_measurement':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.unitOfMeasurement = valueDes;
          break;
        case r'key':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.key = valueDes;
          break;
        case r'tax_rate':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(TaxRate),
                  )
                  as TaxRate?;
          if (valueDes == null) continue;
          result.taxRate.replace(valueDes);
          break;
        case r'tax_included':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(bool),
                  )
                  as bool?;
          if (valueDes == null) continue;
          result.taxIncluded = valueDes;
          break;
        case r'price_type':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.priceType = valueDes;
          break;
        case r'currency':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.currency = valueDes;
          break;
        case r'supplier':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.supplier = valueDes;
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
        case r'perishable':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )
                  as bool;
          result.perishable = valueDes;
          break;
        case r'seriable':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )
                  as bool;
          result.seriable = valueDes;
          break;
        case r'purchasable':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )
                  as bool;
          result.purchasable = valueDes;
          break;
        case r'salable':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )
                  as bool;
          result.salable = valueDes;
          break;
        case r'invoiceable':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )
                  as bool;
          result.invoiceable = valueDes;
          break;
        case r'stock_required':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(bool),
                  )
                  as bool?;
          if (valueDes == null) continue;
          result.stockRequired = valueDes;
          break;
        case r'comment':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.comment = valueDes;
          break;
        case r'labels':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(BuiltList, [
                      FullType(int),
                    ]),
                  )
                  as BuiltList<int>?;
          if (valueDes == null) continue;
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
  ProductCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProductCreateBuilder();
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
