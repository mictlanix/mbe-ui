//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/payment_terms.dart';
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/sales_order_line_response.dart';
import 'package:mbe_api_client/src/model/document_status.dart';
import 'package:mbe_api_client/src/model/priority.dart';
import 'package:mbe_api_client/src/model/currency_code.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sales_order_response.g.dart';

/// SalesOrderResponse
///
/// Properties:
/// * [salesOrderId]
/// * [facility]
/// * [serial]
/// * [pointSale]
/// * [salesperson]
/// * [customer]
/// * [customerName]
/// * [salesQuote]
/// * [paymentTerms]
/// * [date]
/// * [promiseDate]
/// * [dueDate]
/// * [contact]
/// * [shipTo]
/// * [recipient]
/// * [recipientName]
/// * [currency]
/// * [exchangeRate]
/// * [priority]
/// * [comment]
/// * [status]
/// * [lines]
/// * [subtotal]
/// * [taxTotal]
/// * [total]
/// * [balance]
@BuiltValue()
abstract class SalesOrderResponse
    implements Built<SalesOrderResponse, SalesOrderResponseBuilder> {
  @BuiltValueField(wireName: r'sales_order_id')
  int get salesOrderId;

  @BuiltValueField(wireName: r'facility')
  int get facility;

  @BuiltValueField(wireName: r'serial')
  int? get serial;

  @BuiltValueField(wireName: r'point_sale')
  int get pointSale;

  @BuiltValueField(wireName: r'salesperson')
  int get salesperson;

  @BuiltValueField(wireName: r'customer')
  int get customer;

  @BuiltValueField(wireName: r'customer_name')
  String? get customerName;

  @BuiltValueField(wireName: r'sales_quote')
  int? get salesQuote;

  @BuiltValueField(wireName: r'payment_terms')
  PaymentTerms get paymentTerms;
  // enum paymentTermsEnum {  0,  1,  };

  @BuiltValueField(wireName: r'date')
  DateTime get date;

  @BuiltValueField(wireName: r'promise_date')
  DateTime get promiseDate;

  @BuiltValueField(wireName: r'due_date')
  DateTime get dueDate;

  @BuiltValueField(wireName: r'contact')
  int? get contact;

  @BuiltValueField(wireName: r'ship_to')
  int? get shipTo;

  @BuiltValueField(wireName: r'recipient')
  String? get recipient;

  @BuiltValueField(wireName: r'recipient_name')
  String? get recipientName;

  @BuiltValueField(wireName: r'currency')
  CurrencyCode get currency;
  // enum currencyEnum {  0,  1,  2,  };

  @BuiltValueField(wireName: r'exchange_rate')
  String get exchangeRate;

  @BuiltValueField(wireName: r'priority')
  Priority get priority;
  // enum priorityEnum {  0,  1,  2,  3,  };

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  @BuiltValueField(wireName: r'status')
  DocumentStatus get status;
  // enum statusEnum {  draft,  completed,  paid,  cancelled,  };

  @BuiltValueField(wireName: r'lines')
  BuiltList<SalesOrderLineResponse>? get lines;

  @BuiltValueField(wireName: r'subtotal')
  String get subtotal;

  @BuiltValueField(wireName: r'tax_total')
  String get taxTotal;

  @BuiltValueField(wireName: r'total')
  String get total;

  @BuiltValueField(wireName: r'balance')
  String get balance;

  SalesOrderResponse._();

  factory SalesOrderResponse([void updates(SalesOrderResponseBuilder b)]) =
      _$SalesOrderResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SalesOrderResponseBuilder b) =>
      b..lines = ListBuilder();

  @BuiltValueSerializer(custom: true)
  static Serializer<SalesOrderResponse> get serializer =>
      _$SalesOrderResponseSerializer();
}

class _$SalesOrderResponseSerializer
    implements PrimitiveSerializer<SalesOrderResponse> {
  @override
  final Iterable<Type> types = const [SalesOrderResponse, _$SalesOrderResponse];

  @override
  final String wireName = r'SalesOrderResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SalesOrderResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'sales_order_id';
    yield serializers.serialize(
      object.salesOrderId,
      specifiedType: const FullType(int),
    );
    yield r'facility';
    yield serializers.serialize(
      object.facility,
      specifiedType: const FullType(int),
    );
    yield r'serial';
    yield object.serial == null
        ? null
        : serializers.serialize(
            object.serial,
            specifiedType: const FullType.nullable(int),
          );
    yield r'point_sale';
    yield serializers.serialize(
      object.pointSale,
      specifiedType: const FullType(int),
    );
    yield r'salesperson';
    yield serializers.serialize(
      object.salesperson,
      specifiedType: const FullType(int),
    );
    yield r'customer';
    yield serializers.serialize(
      object.customer,
      specifiedType: const FullType(int),
    );
    yield r'customer_name';
    yield object.customerName == null
        ? null
        : serializers.serialize(
            object.customerName,
            specifiedType: const FullType.nullable(String),
          );
    yield r'sales_quote';
    yield object.salesQuote == null
        ? null
        : serializers.serialize(
            object.salesQuote,
            specifiedType: const FullType.nullable(int),
          );
    yield r'payment_terms';
    yield serializers.serialize(
      object.paymentTerms,
      specifiedType: const FullType(PaymentTerms),
    );
    yield r'date';
    yield serializers.serialize(
      object.date,
      specifiedType: const FullType(DateTime),
    );
    yield r'promise_date';
    yield serializers.serialize(
      object.promiseDate,
      specifiedType: const FullType(DateTime),
    );
    yield r'due_date';
    yield serializers.serialize(
      object.dueDate,
      specifiedType: const FullType(DateTime),
    );
    yield r'contact';
    yield object.contact == null
        ? null
        : serializers.serialize(
            object.contact,
            specifiedType: const FullType.nullable(int),
          );
    yield r'ship_to';
    yield object.shipTo == null
        ? null
        : serializers.serialize(
            object.shipTo,
            specifiedType: const FullType.nullable(int),
          );
    yield r'recipient';
    yield object.recipient == null
        ? null
        : serializers.serialize(
            object.recipient,
            specifiedType: const FullType.nullable(String),
          );
    yield r'recipient_name';
    yield object.recipientName == null
        ? null
        : serializers.serialize(
            object.recipientName,
            specifiedType: const FullType.nullable(String),
          );
    yield r'currency';
    yield serializers.serialize(
      object.currency,
      specifiedType: const FullType(CurrencyCode),
    );
    yield r'exchange_rate';
    yield serializers.serialize(
      object.exchangeRate,
      specifiedType: const FullType(String),
    );
    yield r'priority';
    yield serializers.serialize(
      object.priority,
      specifiedType: const FullType(Priority),
    );
    yield r'comment';
    yield object.comment == null
        ? null
        : serializers.serialize(
            object.comment,
            specifiedType: const FullType.nullable(String),
          );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(DocumentStatus),
    );
    if (object.lines != null) {
      yield r'lines';
      yield serializers.serialize(
        object.lines,
        specifiedType: const FullType(BuiltList, [
          FullType(SalesOrderLineResponse),
        ]),
      );
    }
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
    yield r'balance';
    yield serializers.serialize(
      object.balance,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SalesOrderResponse object, {
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
    required SalesOrderResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'sales_order_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.salesOrderId = valueDes;
          break;
        case r'facility':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.facility = valueDes;
          break;
        case r'serial':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.serial = valueDes;
          break;
        case r'point_sale':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.pointSale = valueDes;
          break;
        case r'salesperson':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.salesperson = valueDes;
          break;
        case r'customer':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
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
        case r'sales_quote':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.salesQuote = valueDes;
          break;
        case r'payment_terms':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(PaymentTerms),
                  )
                  as PaymentTerms;
          result.paymentTerms = valueDes;
          break;
        case r'date':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )
                  as DateTime;
          result.date = valueDes;
          break;
        case r'promise_date':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )
                  as DateTime;
          result.promiseDate = valueDes;
          break;
        case r'due_date':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )
                  as DateTime;
          result.dueDate = valueDes;
          break;
        case r'contact':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.contact = valueDes;
          break;
        case r'ship_to':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.shipTo = valueDes;
          break;
        case r'recipient':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.recipient = valueDes;
          break;
        case r'recipient_name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.recipientName = valueDes;
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
        case r'exchange_rate':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.exchangeRate = valueDes;
          break;
        case r'priority':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(Priority),
                  )
                  as Priority;
          result.priority = valueDes;
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
        case r'status':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DocumentStatus),
                  )
                  as DocumentStatus;
          result.status = valueDes;
          break;
        case r'lines':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltList, [
                      FullType(SalesOrderLineResponse),
                    ]),
                  )
                  as BuiltList<SalesOrderLineResponse>;
          result.lines.replace(valueDes);
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
        case r'balance':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.balance = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SalesOrderResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SalesOrderResponseBuilder();
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
