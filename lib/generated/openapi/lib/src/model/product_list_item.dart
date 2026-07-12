//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/sat_unit_of_measurement_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'product_list_item.g.dart';

/// ProductListItem
///
/// Properties:
/// * [productId] 
/// * [code] 
/// * [name] 
/// * [sku] 
/// * [photo] 
/// * [brand] 
/// * [model] 
/// * [unitOfMeasurement] 
/// * [taxRate] 
/// * [deactivated] 
@BuiltValue()
abstract class ProductListItem implements Built<ProductListItem, ProductListItemBuilder> {
  @BuiltValueField(wireName: r'product_id')
  int get productId;

  @BuiltValueField(wireName: r'code')
  String get code;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'sku')
  String? get sku;

  @BuiltValueField(wireName: r'photo')
  String? get photo;

  @BuiltValueField(wireName: r'brand')
  String? get brand;

  @BuiltValueField(wireName: r'model')
  String? get model;

  @BuiltValueField(wireName: r'unit_of_measurement')
  SatUnitOfMeasurementResponse get unitOfMeasurement;

  @BuiltValueField(wireName: r'tax_rate')
  String get taxRate;

  @BuiltValueField(wireName: r'deactivated')
  bool get deactivated;

  ProductListItem._();

  factory ProductListItem([void updates(ProductListItemBuilder b)]) = _$ProductListItem;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProductListItemBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ProductListItem> get serializer => _$ProductListItemSerializer();
}

class _$ProductListItemSerializer implements PrimitiveSerializer<ProductListItem> {
  @override
  final Iterable<Type> types = const [ProductListItem, _$ProductListItem];

  @override
  final String wireName = r'ProductListItem';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProductListItem object, {
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
    yield r'sku';
    yield object.sku == null ? null : serializers.serialize(
      object.sku,
      specifiedType: const FullType.nullable(String),
    );
    yield r'photo';
    yield object.photo == null ? null : serializers.serialize(
      object.photo,
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
    yield r'unit_of_measurement';
    yield serializers.serialize(
      object.unitOfMeasurement,
      specifiedType: const FullType(SatUnitOfMeasurementResponse),
    );
    yield r'tax_rate';
    yield serializers.serialize(
      object.taxRate,
      specifiedType: const FullType(String),
    );
    yield r'deactivated';
    yield serializers.serialize(
      object.deactivated,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ProductListItem object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ProductListItemBuilder result,
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
        case r'sku':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.sku = valueDes;
          break;
        case r'photo':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.photo = valueDes;
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
        case r'unit_of_measurement':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SatUnitOfMeasurementResponse),
          ) as SatUnitOfMeasurementResponse;
          result.unitOfMeasurement.replace(valueDes);
          break;
        case r'tax_rate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.taxRate = valueDes;
          break;
        case r'deactivated':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.deactivated = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ProductListItem deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProductListItemBuilder();
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

