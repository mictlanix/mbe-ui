//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'inventory_count_line_response.g.dart';

/// InventoryCountLineResponse
///
/// Properties:
/// * [countDetailId]
/// * [product]
/// * [productCode]
/// * [productName]
/// * [quantity]
/// * [quantityOnHand]
/// * [difference]
@BuiltValue()
abstract class InventoryCountLineResponse
    implements
        Built<InventoryCountLineResponse, InventoryCountLineResponseBuilder> {
  @BuiltValueField(wireName: r'count_detail_id')
  int get countDetailId;

  @BuiltValueField(wireName: r'product')
  int get product;

  @BuiltValueField(wireName: r'product_code')
  String? get productCode;

  @BuiltValueField(wireName: r'product_name')
  String? get productName;

  @BuiltValueField(wireName: r'quantity')
  String get quantity;

  @BuiltValueField(wireName: r'quantity_on_hand')
  String? get quantityOnHand;

  @BuiltValueField(wireName: r'difference')
  String? get difference;

  InventoryCountLineResponse._();

  factory InventoryCountLineResponse([
    void updates(InventoryCountLineResponseBuilder b),
  ]) = _$InventoryCountLineResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(InventoryCountLineResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<InventoryCountLineResponse> get serializer =>
      _$InventoryCountLineResponseSerializer();
}

class _$InventoryCountLineResponseSerializer
    implements PrimitiveSerializer<InventoryCountLineResponse> {
  @override
  final Iterable<Type> types = const [
    InventoryCountLineResponse,
    _$InventoryCountLineResponse,
  ];

  @override
  final String wireName = r'InventoryCountLineResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    InventoryCountLineResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'count_detail_id';
    yield serializers.serialize(
      object.countDetailId,
      specifiedType: const FullType(int),
    );
    yield r'product';
    yield serializers.serialize(
      object.product,
      specifiedType: const FullType(int),
    );
    yield r'product_code';
    yield object.productCode == null
        ? null
        : serializers.serialize(
            object.productCode,
            specifiedType: const FullType.nullable(String),
          );
    yield r'product_name';
    yield object.productName == null
        ? null
        : serializers.serialize(
            object.productName,
            specifiedType: const FullType.nullable(String),
          );
    yield r'quantity';
    yield serializers.serialize(
      object.quantity,
      specifiedType: const FullType(String),
    );
    if (object.quantityOnHand != null) {
      yield r'quantity_on_hand';
      yield serializers.serialize(
        object.quantityOnHand,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.difference != null) {
      yield r'difference';
      yield serializers.serialize(
        object.difference,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    InventoryCountLineResponse object, {
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
    required InventoryCountLineResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'count_detail_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.countDetailId = valueDes;
          break;
        case r'product':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.product = valueDes;
          break;
        case r'product_code':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.productCode = valueDes;
          break;
        case r'product_name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.productName = valueDes;
          break;
        case r'quantity':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.quantity = valueDes;
          break;
        case r'quantity_on_hand':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.quantityOnHand = valueDes;
          break;
        case r'difference':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.difference = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  InventoryCountLineResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = InventoryCountLineResponseBuilder();
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
