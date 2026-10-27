//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'purchase_order_line.g.dart';

/// PurchaseOrderLine
///
/// Properties:
/// * [purchaseOrderDetailId]
/// * [product]
/// * [productCode]
/// * [productName]
/// * [warehouse]
/// * [quantity]
/// * [price]
/// * [taxRate]
/// * [amount]
/// * [purchaseRequestDetail]
/// * [purchaseRequest]
/// * [quantityReceived]
/// * [quantityPending]
@BuiltValue()
abstract class PurchaseOrderLine
    implements Built<PurchaseOrderLine, PurchaseOrderLineBuilder> {
  @BuiltValueField(wireName: r'purchase_order_detail_id')
  int get purchaseOrderDetailId;

  @BuiltValueField(wireName: r'product')
  int get product;

  @BuiltValueField(wireName: r'product_code')
  String get productCode;

  @BuiltValueField(wireName: r'product_name')
  String get productName;

  @BuiltValueField(wireName: r'warehouse')
  int? get warehouse;

  @BuiltValueField(wireName: r'quantity')
  String get quantity;

  @BuiltValueField(wireName: r'price')
  String get price;

  @BuiltValueField(wireName: r'tax_rate')
  String get taxRate;

  @BuiltValueField(wireName: r'amount')
  String get amount;

  @BuiltValueField(wireName: r'purchase_request_detail')
  int? get purchaseRequestDetail;

  @BuiltValueField(wireName: r'purchase_request')
  int? get purchaseRequest;

  @BuiltValueField(wireName: r'quantity_received')
  String? get quantityReceived;

  @BuiltValueField(wireName: r'quantity_pending')
  String? get quantityPending;

  PurchaseOrderLine._();

  factory PurchaseOrderLine([void updates(PurchaseOrderLineBuilder b)]) =
      _$PurchaseOrderLine;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PurchaseOrderLineBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PurchaseOrderLine> get serializer =>
      _$PurchaseOrderLineSerializer();
}

class _$PurchaseOrderLineSerializer
    implements PrimitiveSerializer<PurchaseOrderLine> {
  @override
  final Iterable<Type> types = const [PurchaseOrderLine, _$PurchaseOrderLine];

  @override
  final String wireName = r'PurchaseOrderLine';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PurchaseOrderLine object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'purchase_order_detail_id';
    yield serializers.serialize(
      object.purchaseOrderDetailId,
      specifiedType: const FullType(int),
    );
    yield r'product';
    yield serializers.serialize(
      object.product,
      specifiedType: const FullType(int),
    );
    yield r'product_code';
    yield serializers.serialize(
      object.productCode,
      specifiedType: const FullType(String),
    );
    yield r'product_name';
    yield serializers.serialize(
      object.productName,
      specifiedType: const FullType(String),
    );
    yield r'warehouse';
    yield object.warehouse == null
        ? null
        : serializers.serialize(
            object.warehouse,
            specifiedType: const FullType.nullable(int),
          );
    yield r'quantity';
    yield serializers.serialize(
      object.quantity,
      specifiedType: const FullType(String),
    );
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
    yield r'amount';
    yield serializers.serialize(
      object.amount,
      specifiedType: const FullType(String),
    );
    yield r'purchase_request_detail';
    yield object.purchaseRequestDetail == null
        ? null
        : serializers.serialize(
            object.purchaseRequestDetail,
            specifiedType: const FullType.nullable(int),
          );
    if (object.purchaseRequest != null) {
      yield r'purchase_request';
      yield serializers.serialize(
        object.purchaseRequest,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.quantityReceived != null) {
      yield r'quantity_received';
      yield serializers.serialize(
        object.quantityReceived,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.quantityPending != null) {
      yield r'quantity_pending';
      yield serializers.serialize(
        object.quantityPending,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PurchaseOrderLine object, {
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
    required PurchaseOrderLineBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'purchase_order_detail_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.purchaseOrderDetailId = valueDes;
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
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.productCode = valueDes;
          break;
        case r'product_name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.productName = valueDes;
          break;
        case r'warehouse':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.warehouse = valueDes;
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
        case r'amount':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.amount = valueDes;
          break;
        case r'purchase_request_detail':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.purchaseRequestDetail = valueDes;
          break;
        case r'purchase_request':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.purchaseRequest = valueDes;
          break;
        case r'quantity_received':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.quantityReceived = valueDes;
          break;
        case r'quantity_pending':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.quantityPending = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PurchaseOrderLine deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PurchaseOrderLineBuilder();
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
