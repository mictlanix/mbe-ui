//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/document_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'purchase_request_line.g.dart';

/// PurchaseRequestLine
///
/// Properties:
/// * [purchaseRequestDetailId]
/// * [product]
/// * [productCode]
/// * [productName]
/// * [quantity]
/// * [warehouse]
/// * [toPurchase]
/// * [minOrderQty]
/// * [purchaseOrderDetail]
/// * [purchaseOrder]
/// * [purchaseOrderStatus]
@BuiltValue()
abstract class PurchaseRequestLine
    implements Built<PurchaseRequestLine, PurchaseRequestLineBuilder> {
  @BuiltValueField(wireName: r'purchase_request_detail_id')
  int get purchaseRequestDetailId;

  @BuiltValueField(wireName: r'product')
  int get product;

  @BuiltValueField(wireName: r'product_code')
  String? get productCode;

  @BuiltValueField(wireName: r'product_name')
  String? get productName;

  @BuiltValueField(wireName: r'quantity')
  String get quantity;

  @BuiltValueField(wireName: r'warehouse')
  int? get warehouse;

  @BuiltValueField(wireName: r'to_purchase')
  bool get toPurchase;

  @BuiltValueField(wireName: r'min_order_qty')
  int? get minOrderQty;

  @BuiltValueField(wireName: r'purchase_order_detail')
  int? get purchaseOrderDetail;

  @BuiltValueField(wireName: r'purchase_order')
  int? get purchaseOrder;

  @BuiltValueField(wireName: r'purchase_order_status')
  DocumentStatus? get purchaseOrderStatus;
  // enum purchaseOrderStatusEnum {  draft,  completed,  paid,  cancelled,  };

  PurchaseRequestLine._();

  factory PurchaseRequestLine([void updates(PurchaseRequestLineBuilder b)]) =
      _$PurchaseRequestLine;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PurchaseRequestLineBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PurchaseRequestLine> get serializer =>
      _$PurchaseRequestLineSerializer();
}

class _$PurchaseRequestLineSerializer
    implements PrimitiveSerializer<PurchaseRequestLine> {
  @override
  final Iterable<Type> types = const [
    PurchaseRequestLine,
    _$PurchaseRequestLine,
  ];

  @override
  final String wireName = r'PurchaseRequestLine';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PurchaseRequestLine object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'purchase_request_detail_id';
    yield serializers.serialize(
      object.purchaseRequestDetailId,
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
    yield r'warehouse';
    yield object.warehouse == null
        ? null
        : serializers.serialize(
            object.warehouse,
            specifiedType: const FullType.nullable(int),
          );
    yield r'to_purchase';
    yield serializers.serialize(
      object.toPurchase,
      specifiedType: const FullType(bool),
    );
    yield r'min_order_qty';
    yield object.minOrderQty == null
        ? null
        : serializers.serialize(
            object.minOrderQty,
            specifiedType: const FullType.nullable(int),
          );
    if (object.purchaseOrderDetail != null) {
      yield r'purchase_order_detail';
      yield serializers.serialize(
        object.purchaseOrderDetail,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.purchaseOrder != null) {
      yield r'purchase_order';
      yield serializers.serialize(
        object.purchaseOrder,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.purchaseOrderStatus != null) {
      yield r'purchase_order_status';
      yield serializers.serialize(
        object.purchaseOrderStatus,
        specifiedType: const FullType.nullable(DocumentStatus),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PurchaseRequestLine object, {
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
    required PurchaseRequestLineBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'purchase_request_detail_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.purchaseRequestDetailId = valueDes;
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
        case r'to_purchase':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )
                  as bool;
          result.toPurchase = valueDes;
          break;
        case r'min_order_qty':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.minOrderQty = valueDes;
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
        case r'purchase_order':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.purchaseOrder = valueDes;
          break;
        case r'purchase_order_status':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(DocumentStatus),
                  )
                  as DocumentStatus?;
          if (valueDes == null) continue;
          result.purchaseOrderStatus = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PurchaseRequestLine deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PurchaseRequestLineBuilder();
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
