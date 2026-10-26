//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'inventory_receipt_line_response.g.dart';

/// InventoryReceiptLineResponse
///
/// Properties:
/// * [receiptDetailId]
/// * [product]
/// * [productCode]
/// * [productName]
/// * [quantity]
/// * [purchaseOrderDetail]
/// * [quantityOrdered]
/// * [quantityReceivedElsewhere]
@BuiltValue()
abstract class InventoryReceiptLineResponse
    implements
        Built<
          InventoryReceiptLineResponse,
          InventoryReceiptLineResponseBuilder
        > {
  @BuiltValueField(wireName: r'receipt_detail_id')
  int get receiptDetailId;

  @BuiltValueField(wireName: r'product')
  int get product;

  @BuiltValueField(wireName: r'product_code')
  String? get productCode;

  @BuiltValueField(wireName: r'product_name')
  String? get productName;

  @BuiltValueField(wireName: r'quantity')
  String get quantity;

  @BuiltValueField(wireName: r'purchase_order_detail')
  int? get purchaseOrderDetail;

  @BuiltValueField(wireName: r'quantity_ordered')
  String get quantityOrdered;

  @BuiltValueField(wireName: r'quantity_received_elsewhere')
  String? get quantityReceivedElsewhere;

  InventoryReceiptLineResponse._();

  factory InventoryReceiptLineResponse([
    void updates(InventoryReceiptLineResponseBuilder b),
  ]) = _$InventoryReceiptLineResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(InventoryReceiptLineResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<InventoryReceiptLineResponse> get serializer =>
      _$InventoryReceiptLineResponseSerializer();
}

class _$InventoryReceiptLineResponseSerializer
    implements PrimitiveSerializer<InventoryReceiptLineResponse> {
  @override
  final Iterable<Type> types = const [
    InventoryReceiptLineResponse,
    _$InventoryReceiptLineResponse,
  ];

  @override
  final String wireName = r'InventoryReceiptLineResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    InventoryReceiptLineResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'receipt_detail_id';
    yield serializers.serialize(
      object.receiptDetailId,
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
    yield r'purchase_order_detail';
    yield object.purchaseOrderDetail == null
        ? null
        : serializers.serialize(
            object.purchaseOrderDetail,
            specifiedType: const FullType.nullable(int),
          );
    yield r'quantity_ordered';
    yield serializers.serialize(
      object.quantityOrdered,
      specifiedType: const FullType(String),
    );
    if (object.quantityReceivedElsewhere != null) {
      yield r'quantity_received_elsewhere';
      yield serializers.serialize(
        object.quantityReceivedElsewhere,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    InventoryReceiptLineResponse object, {
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
    required InventoryReceiptLineResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'receipt_detail_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.receiptDetailId = valueDes;
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
        case r'purchase_order_detail':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.purchaseOrderDetail = valueDes;
          break;
        case r'quantity_ordered':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.quantityOrdered = valueDes;
          break;
        case r'quantity_received_elsewhere':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.quantityReceivedElsewhere = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  InventoryReceiptLineResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = InventoryReceiptLineResponseBuilder();
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
