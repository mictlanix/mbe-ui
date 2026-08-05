//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/payment_type.dart';
import 'package:mbe_api_client/src/model/payment_method.dart';
import 'package:mbe_api_client/src/model/currency_code.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'order_application_response.g.dart';

/// An application seen from the order's side, with its payment flattened onto it (#134).  The payment fields are the ones needed to render a row — how it was tendered, what identifies it, and whether verification has passed. `date` stays the application's; the payment's own is `payment_date`, because the two differ whenever a payment is applied later than it was taken.
///
/// Properties:
/// * [salesOrderPaymentId]
/// * [salesOrder]
/// * [customerPayment]
/// * [amount]
/// * [amountChange]
/// * [applier]
/// * [date]
/// * [cancelled]
/// * [method]
/// * [currency]
/// * [reference]
/// * [paymentDate]
/// * [paymentType]
/// * [verifier]
@BuiltValue()
abstract class OrderApplicationResponse
    implements
        Built<OrderApplicationResponse, OrderApplicationResponseBuilder> {
  @BuiltValueField(wireName: r'sales_order_payment_id')
  int get salesOrderPaymentId;

  @BuiltValueField(wireName: r'sales_order')
  int get salesOrder;

  @BuiltValueField(wireName: r'customer_payment')
  int get customerPayment;

  @BuiltValueField(wireName: r'amount')
  String get amount;

  @BuiltValueField(wireName: r'amount_change')
  String get amountChange;

  @BuiltValueField(wireName: r'applier')
  int? get applier;

  @BuiltValueField(wireName: r'date')
  DateTime? get date;

  @BuiltValueField(wireName: r'cancelled')
  bool get cancelled;

  @BuiltValueField(wireName: r'method')
  PaymentMethod get method;
  // enum methodEnum {  0,  1,  2,  3,  4,  5,  6,  8,  12,  27,  28,  29,  30,  99,  1001,  };

  @BuiltValueField(wireName: r'currency')
  CurrencyCode get currency;
  // enum currencyEnum {  0,  1,  2,  };

  @BuiltValueField(wireName: r'reference')
  String? get reference;

  @BuiltValueField(wireName: r'payment_date')
  DateTime get paymentDate;

  @BuiltValueField(wireName: r'payment_type')
  PaymentType get paymentType;
  // enum paymentTypeEnum {  0,  1,  2,  3,  4,  5,  };

  @BuiltValueField(wireName: r'verifier')
  int? get verifier;

  OrderApplicationResponse._();

  factory OrderApplicationResponse([
    void updates(OrderApplicationResponseBuilder b),
  ]) = _$OrderApplicationResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OrderApplicationResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OrderApplicationResponse> get serializer =>
      _$OrderApplicationResponseSerializer();
}

class _$OrderApplicationResponseSerializer
    implements PrimitiveSerializer<OrderApplicationResponse> {
  @override
  final Iterable<Type> types = const [
    OrderApplicationResponse,
    _$OrderApplicationResponse,
  ];

  @override
  final String wireName = r'OrderApplicationResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OrderApplicationResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'sales_order_payment_id';
    yield serializers.serialize(
      object.salesOrderPaymentId,
      specifiedType: const FullType(int),
    );
    yield r'sales_order';
    yield serializers.serialize(
      object.salesOrder,
      specifiedType: const FullType(int),
    );
    yield r'customer_payment';
    yield serializers.serialize(
      object.customerPayment,
      specifiedType: const FullType(int),
    );
    yield r'amount';
    yield serializers.serialize(
      object.amount,
      specifiedType: const FullType(String),
    );
    yield r'amount_change';
    yield serializers.serialize(
      object.amountChange,
      specifiedType: const FullType(String),
    );
    yield r'applier';
    yield object.applier == null
        ? null
        : serializers.serialize(
            object.applier,
            specifiedType: const FullType.nullable(int),
          );
    yield r'date';
    yield object.date == null
        ? null
        : serializers.serialize(
            object.date,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'cancelled';
    yield serializers.serialize(
      object.cancelled,
      specifiedType: const FullType(bool),
    );
    yield r'method';
    yield serializers.serialize(
      object.method,
      specifiedType: const FullType(PaymentMethod),
    );
    yield r'currency';
    yield serializers.serialize(
      object.currency,
      specifiedType: const FullType(CurrencyCode),
    );
    yield r'reference';
    yield object.reference == null
        ? null
        : serializers.serialize(
            object.reference,
            specifiedType: const FullType.nullable(String),
          );
    yield r'payment_date';
    yield serializers.serialize(
      object.paymentDate,
      specifiedType: const FullType(DateTime),
    );
    yield r'payment_type';
    yield serializers.serialize(
      object.paymentType,
      specifiedType: const FullType(PaymentType),
    );
    yield r'verifier';
    yield object.verifier == null
        ? null
        : serializers.serialize(
            object.verifier,
            specifiedType: const FullType.nullable(int),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    OrderApplicationResponse object, {
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
    required OrderApplicationResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'sales_order_payment_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.salesOrderPaymentId = valueDes;
          break;
        case r'sales_order':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.salesOrder = valueDes;
          break;
        case r'customer_payment':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.customerPayment = valueDes;
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
        case r'amount_change':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.amountChange = valueDes;
          break;
        case r'applier':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.applier = valueDes;
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
        case r'cancelled':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )
                  as bool;
          result.cancelled = valueDes;
          break;
        case r'method':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(PaymentMethod),
                  )
                  as PaymentMethod;
          result.method = valueDes;
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
        case r'reference':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.reference = valueDes;
          break;
        case r'payment_date':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )
                  as DateTime;
          result.paymentDate = valueDes;
          break;
        case r'payment_type':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(PaymentType),
                  )
                  as PaymentType;
          result.paymentType = valueDes;
          break;
        case r'verifier':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.verifier = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OrderApplicationResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OrderApplicationResponseBuilder();
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
