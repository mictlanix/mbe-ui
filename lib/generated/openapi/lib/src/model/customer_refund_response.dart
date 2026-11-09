//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/refund_payout.dart';
import 'package:mbe_api_client/src/model/customer_refund_line_response.dart';
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/document_status.dart';
import 'package:mbe_api_client/src/model/currency_code.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'customer_refund_response.g.dart';

/// CustomerRefundResponse
///
/// Properties:
/// * [customerRefundId]
/// * [salesOrder]
/// * [customer]
/// * [customerDisplayName] - The customer's own name, joined from the customer record. This is the field to render in a list. Null only if the customer row is missing.
/// * [salesPerson]
/// * [facility]
/// * [serial]
/// * [date] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
/// * [currency]
/// * [exchangeRate]
/// * [status]
/// * [payout]
/// * [customerPayment]
/// * [creditNote]
/// * [lines]
/// * [subtotal]
/// * [taxTotal]
/// * [total]
@BuiltValue()
abstract class CustomerRefundResponse
    implements Built<CustomerRefundResponse, CustomerRefundResponseBuilder> {
  @BuiltValueField(wireName: r'customer_refund_id')
  int get customerRefundId;

  @BuiltValueField(wireName: r'sales_order')
  int get salesOrder;

  @BuiltValueField(wireName: r'customer')
  int? get customer;

  /// The customer's own name, joined from the customer record. This is the field to render in a list. Null only if the customer row is missing.
  @BuiltValueField(wireName: r'customer_display_name')
  String? get customerDisplayName;

  @BuiltValueField(wireName: r'sales_person')
  int get salesPerson;

  @BuiltValueField(wireName: r'facility')
  int get facility;

  @BuiltValueField(wireName: r'serial')
  int? get serial;

  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'date')
  DateTime? get date;

  @BuiltValueField(wireName: r'currency')
  CurrencyCode get currency;
  // enum currencyEnum {  0,  1,  2,  };

  @BuiltValueField(wireName: r'exchange_rate')
  String get exchangeRate;

  @BuiltValueField(wireName: r'status')
  DocumentStatus get status;
  // enum statusEnum {  draft,  completed,  paid,  cancelled,  };

  @BuiltValueField(wireName: r'payout')
  RefundPayout? get payout;
  // enum payoutEnum {  cash,  credit_note,  };

  @BuiltValueField(wireName: r'customer_payment')
  int? get customerPayment;

  @BuiltValueField(wireName: r'credit_note')
  int? get creditNote;

  @BuiltValueField(wireName: r'lines')
  BuiltList<CustomerRefundLineResponse>? get lines;

  @BuiltValueField(wireName: r'subtotal')
  String get subtotal;

  @BuiltValueField(wireName: r'tax_total')
  String get taxTotal;

  @BuiltValueField(wireName: r'total')
  String get total;

  CustomerRefundResponse._();

  factory CustomerRefundResponse([
    void updates(CustomerRefundResponseBuilder b),
  ]) = _$CustomerRefundResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CustomerRefundResponseBuilder b) =>
      b..lines = ListBuilder();

  @BuiltValueSerializer(custom: true)
  static Serializer<CustomerRefundResponse> get serializer =>
      _$CustomerRefundResponseSerializer();
}

class _$CustomerRefundResponseSerializer
    implements PrimitiveSerializer<CustomerRefundResponse> {
  @override
  final Iterable<Type> types = const [
    CustomerRefundResponse,
    _$CustomerRefundResponse,
  ];

  @override
  final String wireName = r'CustomerRefundResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CustomerRefundResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'customer_refund_id';
    yield serializers.serialize(
      object.customerRefundId,
      specifiedType: const FullType(int),
    );
    yield r'sales_order';
    yield serializers.serialize(
      object.salesOrder,
      specifiedType: const FullType(int),
    );
    yield r'customer';
    yield object.customer == null
        ? null
        : serializers.serialize(
            object.customer,
            specifiedType: const FullType.nullable(int),
          );
    if (object.customerDisplayName != null) {
      yield r'customer_display_name';
      yield serializers.serialize(
        object.customerDisplayName,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'sales_person';
    yield serializers.serialize(
      object.salesPerson,
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
    yield r'date';
    yield object.date == null
        ? null
        : serializers.serialize(
            object.date,
            specifiedType: const FullType.nullable(DateTime),
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
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(DocumentStatus),
    );
    if (object.payout != null) {
      yield r'payout';
      yield serializers.serialize(
        object.payout,
        specifiedType: const FullType.nullable(RefundPayout),
      );
    }
    if (object.customerPayment != null) {
      yield r'customer_payment';
      yield serializers.serialize(
        object.customerPayment,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.creditNote != null) {
      yield r'credit_note';
      yield serializers.serialize(
        object.creditNote,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.lines != null) {
      yield r'lines';
      yield serializers.serialize(
        object.lines,
        specifiedType: const FullType(BuiltList, [
          FullType(CustomerRefundLineResponse),
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
  }

  @override
  Object serialize(
    Serializers serializers,
    CustomerRefundResponse object, {
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
    required CustomerRefundResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'customer_refund_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.customerRefundId = valueDes;
          break;
        case r'sales_order':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.salesOrder = valueDes;
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
        case r'customer_display_name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.customerDisplayName = valueDes;
          break;
        case r'sales_person':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.salesPerson = valueDes;
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
        case r'status':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DocumentStatus),
                  )
                  as DocumentStatus;
          result.status = valueDes;
          break;
        case r'payout':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(RefundPayout),
                  )
                  as RefundPayout?;
          if (valueDes == null) continue;
          result.payout = valueDes;
          break;
        case r'customer_payment':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.customerPayment = valueDes;
          break;
        case r'credit_note':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.creditNote = valueDes;
          break;
        case r'lines':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(BuiltList, [
                      FullType(CustomerRefundLineResponse),
                    ]),
                  )
                  as BuiltList<CustomerRefundLineResponse>?;
          if (valueDes == null) continue;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CustomerRefundResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CustomerRefundResponseBuilder();
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
