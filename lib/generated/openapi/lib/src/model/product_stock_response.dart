//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'product_stock_response.g.dart';

/// ProductStockResponse
///
/// Properties:
/// * [warehouse]
/// * [warehouseName]
/// * [onHand]
@BuiltValue()
abstract class ProductStockResponse
    implements Built<ProductStockResponse, ProductStockResponseBuilder> {
  @BuiltValueField(wireName: r'warehouse')
  int get warehouse;

  @BuiltValueField(wireName: r'warehouse_name')
  String? get warehouseName;

  @BuiltValueField(wireName: r'on_hand')
  String get onHand;

  ProductStockResponse._();

  factory ProductStockResponse([void updates(ProductStockResponseBuilder b)]) =
      _$ProductStockResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProductStockResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ProductStockResponse> get serializer =>
      _$ProductStockResponseSerializer();
}

class _$ProductStockResponseSerializer
    implements PrimitiveSerializer<ProductStockResponse> {
  @override
  final Iterable<Type> types = const [
    ProductStockResponse,
    _$ProductStockResponse,
  ];

  @override
  final String wireName = r'ProductStockResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProductStockResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'warehouse';
    yield serializers.serialize(
      object.warehouse,
      specifiedType: const FullType(int),
    );
    if (object.warehouseName != null) {
      yield r'warehouse_name';
      yield serializers.serialize(
        object.warehouseName,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'on_hand';
    yield serializers.serialize(
      object.onHand,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ProductStockResponse object, {
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
    required ProductStockResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'warehouse':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.warehouse = valueDes;
          break;
        case r'warehouse_name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.warehouseName = valueDes;
          break;
        case r'on_hand':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.onHand = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ProductStockResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProductStockResponseBuilder();
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
