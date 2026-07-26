//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/payment_terms.dart';
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/document_status.dart';
import 'package:mbe_api_client/src/model/currency_code.dart';
import 'package:mbe_api_client/src/model/sales_quote_line_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sales_quote_response.g.dart';

/// SalesQuoteResponse
///
/// Properties:
/// * [salesQuoteId]
/// * [facility]
/// * [serial]
/// * [salesperson]
/// * [customer]
/// * [paymentTerms]
/// * [date]
/// * [dueDate]
/// * [contact]
/// * [shipTo]
/// * [currency]
/// * [exchangeRate]
/// * [comment]
/// * [status]
/// * [hasExpired]
/// * [lines]
/// * [subtotal]
/// * [taxTotal]
/// * [total]
@BuiltValue()
abstract class SalesQuoteResponse
    implements Built<SalesQuoteResponse, SalesQuoteResponseBuilder> {
  @BuiltValueField(wireName: r'sales_quote_id')
  int get salesQuoteId;

  @BuiltValueField(wireName: r'facility')
  int get facility;

  @BuiltValueField(wireName: r'serial')
  int? get serial;

  @BuiltValueField(wireName: r'salesperson')
  int get salesperson;

  @BuiltValueField(wireName: r'customer')
  int get customer;

  @BuiltValueField(wireName: r'payment_terms')
  PaymentTerms get paymentTerms;
  // enum paymentTermsEnum {  0,  1,  };

  @BuiltValueField(wireName: r'date')
  DateTime get date;

  @BuiltValueField(wireName: r'due_date')
  DateTime get dueDate;

  @BuiltValueField(wireName: r'contact')
  int? get contact;

  @BuiltValueField(wireName: r'ship_to')
  int? get shipTo;

  @BuiltValueField(wireName: r'currency')
  CurrencyCode get currency;
  // enum currencyEnum {  0,  1,  2,  };

  @BuiltValueField(wireName: r'exchange_rate')
  String get exchangeRate;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  @BuiltValueField(wireName: r'status')
  DocumentStatus get status;
  // enum statusEnum {  draft,  completed,  paid,  cancelled,  };

  @BuiltValueField(wireName: r'has_expired')
  bool get hasExpired;

  @BuiltValueField(wireName: r'lines')
  BuiltList<SalesQuoteLineResponse>? get lines;

  @BuiltValueField(wireName: r'subtotal')
  String get subtotal;

  @BuiltValueField(wireName: r'tax_total')
  String get taxTotal;

  @BuiltValueField(wireName: r'total')
  String get total;

  SalesQuoteResponse._();

  factory SalesQuoteResponse([void updates(SalesQuoteResponseBuilder b)]) =
      _$SalesQuoteResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SalesQuoteResponseBuilder b) =>
      b..lines = ListBuilder();

  @BuiltValueSerializer(custom: true)
  static Serializer<SalesQuoteResponse> get serializer =>
      _$SalesQuoteResponseSerializer();
}

class _$SalesQuoteResponseSerializer
    implements PrimitiveSerializer<SalesQuoteResponse> {
  @override
  final Iterable<Type> types = const [SalesQuoteResponse, _$SalesQuoteResponse];

  @override
  final String wireName = r'SalesQuoteResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SalesQuoteResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'sales_quote_id';
    yield serializers.serialize(
      object.salesQuoteId,
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
    yield r'has_expired';
    yield serializers.serialize(
      object.hasExpired,
      specifiedType: const FullType(bool),
    );
    if (object.lines != null) {
      yield r'lines';
      yield serializers.serialize(
        object.lines,
        specifiedType: const FullType(BuiltList, [
          FullType(SalesQuoteLineResponse),
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
    SalesQuoteResponse object, {
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
    required SalesQuoteResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'sales_quote_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.salesQuoteId = valueDes;
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
        case r'has_expired':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )
                  as bool;
          result.hasExpired = valueDes;
          break;
        case r'lines':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltList, [
                      FullType(SalesQuoteLineResponse),
                    ]),
                  )
                  as BuiltList<SalesQuoteLineResponse>;
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
  SalesQuoteResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SalesQuoteResponseBuilder();
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
