//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/currency_code.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'customer_refund_line_response.g.dart';

/// CustomerRefundLineResponse
///
/// Properties:
/// * [customerRefundDetailId]
/// * [salesOrderDetail]
/// * [product]
/// * [productCode]
/// * [productName]
/// * [quantity]
/// * [price]
/// * [discount]
/// * [taxRate]
/// * [taxIncluded]
/// * [currency]
/// * [warehouse]
/// * [refundableQuantity]
/// * [subtotal]
/// * [taxTotal]
/// * [total]
@BuiltValue()
abstract class CustomerRefundLineResponse
    implements
        Built<CustomerRefundLineResponse, CustomerRefundLineResponseBuilder> {
  @BuiltValueField(wireName: r'customer_refund_detail_id')
  int get customerRefundDetailId;

  @BuiltValueField(wireName: r'sales_order_detail')
  int get salesOrderDetail;

  @BuiltValueField(wireName: r'product')
  int get product;

  @BuiltValueField(wireName: r'product_code')
  String get productCode;

  @BuiltValueField(wireName: r'product_name')
  String get productName;

  @BuiltValueField(wireName: r'quantity')
  String get quantity;

  @BuiltValueField(wireName: r'price')
  String get price;

  @BuiltValueField(wireName: r'discount')
  String get discount;

  @BuiltValueField(wireName: r'tax_rate')
  String get taxRate;

  @BuiltValueField(wireName: r'tax_included')
  bool get taxIncluded;

  @BuiltValueField(wireName: r'currency')
  CurrencyCode get currency;
  // enum currencyEnum {  0,  1,  2,  };

  @BuiltValueField(wireName: r'warehouse')
  int? get warehouse;

  @BuiltValueField(wireName: r'refundable_quantity')
  String get refundableQuantity;

  @BuiltValueField(wireName: r'subtotal')
  String get subtotal;

  @BuiltValueField(wireName: r'tax_total')
  String get taxTotal;

  @BuiltValueField(wireName: r'total')
  String get total;

  CustomerRefundLineResponse._();

  factory CustomerRefundLineResponse([
    void updates(CustomerRefundLineResponseBuilder b),
  ]) = _$CustomerRefundLineResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CustomerRefundLineResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CustomerRefundLineResponse> get serializer =>
      _$CustomerRefundLineResponseSerializer();
}

class _$CustomerRefundLineResponseSerializer
    implements PrimitiveSerializer<CustomerRefundLineResponse> {
  @override
  final Iterable<Type> types = const [
    CustomerRefundLineResponse,
    _$CustomerRefundLineResponse,
  ];

  @override
  final String wireName = r'CustomerRefundLineResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CustomerRefundLineResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'customer_refund_detail_id';
    yield serializers.serialize(
      object.customerRefundDetailId,
      specifiedType: const FullType(int),
    );
    yield r'sales_order_detail';
    yield serializers.serialize(
      object.salesOrderDetail,
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
    yield r'discount';
    yield serializers.serialize(
      object.discount,
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
    yield r'currency';
    yield serializers.serialize(
      object.currency,
      specifiedType: const FullType(CurrencyCode),
    );
    yield r'warehouse';
    yield object.warehouse == null
        ? null
        : serializers.serialize(
            object.warehouse,
            specifiedType: const FullType.nullable(int),
          );
    yield r'refundable_quantity';
    yield serializers.serialize(
      object.refundableQuantity,
      specifiedType: const FullType(String),
    );
    yield r'subtotal';
    yield serializers.serialize(
      object.subtotal,
      specifiedType: const FullType(String),
    );
    yield r'tax_total';
    yield serializers.serialize(
      object.taxTotal,
      specifiedType: const FullType(String),
    );
    yield r'total';
    yield serializers.serialize(
      object.total,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CustomerRefundLineResponse object, {
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
    required CustomerRefundLineResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'customer_refund_detail_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.customerRefundDetailId = valueDes;
          break;
        case r'sales_order_detail':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.salesOrderDetail = valueDes;
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
        case r'discount':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.discount = valueDes;
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
        case r'currency':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(CurrencyCode),
                  )
                  as CurrencyCode;
          result.currency = valueDes;
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
        case r'refundable_quantity':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.refundableQuantity = valueDes;
          break;
        case r'subtotal':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.subtotal = valueDes;
          break;
        case r'tax_total':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.taxTotal = valueDes;
          break;
        case r'total':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.total = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CustomerRefundLineResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CustomerRefundLineResponseBuilder();
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
