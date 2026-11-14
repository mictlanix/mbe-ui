//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/analytics_detail_figures.dart';
import 'package:mbe_api_client/src/model/detail_kind.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'analytics_detail_item.g.dart';

/// AnalyticsDetailItem
///
/// Properties:
/// * [kind]
/// * [id] - sales_order_id | sales_order_detail_id | customer_refund_id | fiscal_document_id | customer_payment_id | product (stock) | lot_serial_tracking_id (movements) | sales_order_detail_id (commission_lines, uninvoiced_lines) | purchase_order_detail_id (purchases)
/// * [documentId] - The document to open: the order for a line, the refund, the fiscal document, the payment, a movement's document; null for stock pairs.
/// * [folio]
/// * [date] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
/// * [facility]
/// * [customer]
/// * [customerName]
/// * [salesperson]
/// * [product]
/// * [productCode]
/// * [productName]
/// * [quantity]
/// * [amount] - Positive: a line's or order's sales amount, a refund's, a credit note's, or a payment's amount in its class; the balance with flag=overdue; with the request's VAT treatment. Null where a kind has no amount (stock, movements).
/// * [cost] - Cost privilege only, absent otherwise; null on uncosted lines. A stock pair's unit cost.
/// * [margin] - Cost privilege only, absent otherwise.
/// * [paymentMethod]
/// * [warehouse] - Stock, movements and purchases.
/// * [figures] - Spec 038 kinds: the kind's own columns.
@BuiltValue()
abstract class AnalyticsDetailItem
    implements Built<AnalyticsDetailItem, AnalyticsDetailItemBuilder> {
  @BuiltValueField(wireName: r'kind')
  DetailKind get kind;
  // enum kindEnum {  orders,  lines,  refunds,  credit_notes,  payments,  stock,  movements,  receivables,  invoices,  uninvoiced_lines,  purchases,  commission_lines,  };

  /// sales_order_id | sales_order_detail_id | customer_refund_id | fiscal_document_id | customer_payment_id | product (stock) | lot_serial_tracking_id (movements) | sales_order_detail_id (commission_lines, uninvoiced_lines) | purchase_order_detail_id (purchases)
  @BuiltValueField(wireName: r'id')
  int get id;

  /// The document to open: the order for a line, the refund, the fiscal document, the payment, a movement's document; null for stock pairs.
  @BuiltValueField(wireName: r'document_id')
  int? get documentId;

  @BuiltValueField(wireName: r'folio')
  String? get folio;

  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'date')
  DateTime? get date;

  @BuiltValueField(wireName: r'facility')
  int? get facility;

  @BuiltValueField(wireName: r'customer')
  int? get customer;

  @BuiltValueField(wireName: r'customer_name')
  String? get customerName;

  @BuiltValueField(wireName: r'salesperson')
  int? get salesperson;

  @BuiltValueField(wireName: r'product')
  int? get product;

  @BuiltValueField(wireName: r'product_code')
  String? get productCode;

  @BuiltValueField(wireName: r'product_name')
  String? get productName;

  @BuiltValueField(wireName: r'quantity')
  String? get quantity;

  /// Positive: a line's or order's sales amount, a refund's, a credit note's, or a payment's amount in its class; the balance with flag=overdue; with the request's VAT treatment. Null where a kind has no amount (stock, movements).
  @BuiltValueField(wireName: r'amount')
  String? get amount;

  /// Cost privilege only, absent otherwise; null on uncosted lines. A stock pair's unit cost.
  @BuiltValueField(wireName: r'cost')
  String? get cost;

  /// Cost privilege only, absent otherwise.
  @BuiltValueField(wireName: r'margin')
  String? get margin;

  @BuiltValueField(wireName: r'payment_method')
  int? get paymentMethod;

  /// Stock, movements and purchases.
  @BuiltValueField(wireName: r'warehouse')
  int? get warehouse;

  /// Spec 038 kinds: the kind's own columns.
  @BuiltValueField(wireName: r'figures')
  AnalyticsDetailFigures? get figures;

  AnalyticsDetailItem._();

  factory AnalyticsDetailItem([void updates(AnalyticsDetailItemBuilder b)]) =
      _$AnalyticsDetailItem;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AnalyticsDetailItemBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AnalyticsDetailItem> get serializer =>
      _$AnalyticsDetailItemSerializer();
}

class _$AnalyticsDetailItemSerializer
    implements PrimitiveSerializer<AnalyticsDetailItem> {
  @override
  final Iterable<Type> types = const [
    AnalyticsDetailItem,
    _$AnalyticsDetailItem,
  ];

  @override
  final String wireName = r'AnalyticsDetailItem';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AnalyticsDetailItem object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(DetailKind),
    );
    yield r'id';
    yield serializers.serialize(object.id, specifiedType: const FullType(int));
    if (object.documentId != null) {
      yield r'document_id';
      yield serializers.serialize(
        object.documentId,
        specifiedType: const FullType.nullable(int),
      );
    }
    yield r'folio';
    yield object.folio == null
        ? null
        : serializers.serialize(
            object.folio,
            specifiedType: const FullType.nullable(String),
          );
    if (object.date != null) {
      yield r'date';
      yield serializers.serialize(
        object.date,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
    if (object.facility != null) {
      yield r'facility';
      yield serializers.serialize(
        object.facility,
        specifiedType: const FullType.nullable(int),
      );
    }
    yield r'customer';
    yield object.customer == null
        ? null
        : serializers.serialize(
            object.customer,
            specifiedType: const FullType.nullable(int),
          );
    yield r'customer_name';
    yield object.customerName == null
        ? null
        : serializers.serialize(
            object.customerName,
            specifiedType: const FullType.nullable(String),
          );
    yield r'salesperson';
    yield object.salesperson == null
        ? null
        : serializers.serialize(
            object.salesperson,
            specifiedType: const FullType.nullable(int),
          );
    yield r'product';
    yield object.product == null
        ? null
        : serializers.serialize(
            object.product,
            specifiedType: const FullType.nullable(int),
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
    yield object.quantity == null
        ? null
        : serializers.serialize(
            object.quantity,
            specifiedType: const FullType.nullable(String),
          );
    if (object.amount != null) {
      yield r'amount';
      yield serializers.serialize(
        object.amount,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.cost != null) {
      yield r'cost';
      yield serializers.serialize(
        object.cost,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.margin != null) {
      yield r'margin';
      yield serializers.serialize(
        object.margin,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'payment_method';
    yield object.paymentMethod == null
        ? null
        : serializers.serialize(
            object.paymentMethod,
            specifiedType: const FullType.nullable(int),
          );
    if (object.warehouse != null) {
      yield r'warehouse';
      yield serializers.serialize(
        object.warehouse,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.figures != null) {
      yield r'figures';
      yield serializers.serialize(
        object.figures,
        specifiedType: const FullType.nullable(AnalyticsDetailFigures),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AnalyticsDetailItem object, {
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
    required AnalyticsDetailItemBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'kind':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DetailKind),
                  )
                  as DetailKind;
          result.kind = valueDes;
          break;
        case r'id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.id = valueDes;
          break;
        case r'document_id':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.documentId = valueDes;
          break;
        case r'folio':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.folio = valueDes;
          break;
        case r'date':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(DateTime),
                  )
                  as DateTime?;
          if (valueDes == null) continue;
          result.date = valueDes;
          break;
        case r'facility':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.facility = valueDes;
          break;
        case r'customer':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.customer = valueDes;
          break;
        case r'customer_name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.customerName = valueDes;
          break;
        case r'salesperson':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.salesperson = valueDes;
          break;
        case r'product':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
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
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.quantity = valueDes;
          break;
        case r'amount':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.amount = valueDes;
          break;
        case r'cost':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.cost = valueDes;
          break;
        case r'margin':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.margin = valueDes;
          break;
        case r'payment_method':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.paymentMethod = valueDes;
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
        case r'figures':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(
                      AnalyticsDetailFigures,
                    ),
                  )
                  as AnalyticsDetailFigures?;
          if (valueDes == null) continue;
          result.figures.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AnalyticsDetailItem deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AnalyticsDetailItemBuilder();
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
