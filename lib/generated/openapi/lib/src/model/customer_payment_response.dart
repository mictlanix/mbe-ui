//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/payment_type.dart';
import 'package:mbe_api_client/src/model/payment_method.dart';
import 'package:mbe_api_client/src/model/currency_code.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'customer_payment_response.g.dart';

/// CustomerPaymentResponse
///
/// Properties:
/// * [customerPaymentId]
/// * [customer]
/// * [amount]
/// * [currency]
/// * [method]
/// * [paymentCharge]
/// * [reference]
/// * [date]
/// * [facility]
/// * [cashSession]
/// * [paymentType]
/// * [verifier]
/// * [unapplied]
@BuiltValue()
abstract class CustomerPaymentResponse
    implements Built<CustomerPaymentResponse, CustomerPaymentResponseBuilder> {
  @BuiltValueField(wireName: r'customer_payment_id')
  int get customerPaymentId;

  @BuiltValueField(wireName: r'customer')
  int get customer;

  @BuiltValueField(wireName: r'amount')
  String get amount;

  @BuiltValueField(wireName: r'currency')
  CurrencyCode get currency;
  // enum currencyEnum {  0,  1,  2,  };

  @BuiltValueField(wireName: r'method')
  PaymentMethod get method;
  // enum methodEnum {  0,  1,  2,  3,  4,  5,  6,  8,  12,  27,  28,  29,  30,  99,  1001,  };

  @BuiltValueField(wireName: r'payment_charge')
  int? get paymentCharge;

  @BuiltValueField(wireName: r'reference')
  String? get reference;

  @BuiltValueField(wireName: r'date')
  DateTime get date;

  @BuiltValueField(wireName: r'facility')
  int get facility;

  @BuiltValueField(wireName: r'cash_session')
  int? get cashSession;

  @BuiltValueField(wireName: r'payment_type')
  PaymentType get paymentType;
  // enum paymentTypeEnum {  0,  1,  2,  3,  4,  5,  };

  @BuiltValueField(wireName: r'verifier')
  int? get verifier;

  @BuiltValueField(wireName: r'unapplied')
  String get unapplied;

  CustomerPaymentResponse._();

  factory CustomerPaymentResponse([
    void updates(CustomerPaymentResponseBuilder b),
  ]) = _$CustomerPaymentResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CustomerPaymentResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CustomerPaymentResponse> get serializer =>
      _$CustomerPaymentResponseSerializer();
}

class _$CustomerPaymentResponseSerializer
    implements PrimitiveSerializer<CustomerPaymentResponse> {
  @override
  final Iterable<Type> types = const [
    CustomerPaymentResponse,
    _$CustomerPaymentResponse,
  ];

  @override
  final String wireName = r'CustomerPaymentResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CustomerPaymentResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'customer_payment_id';
    yield serializers.serialize(
      object.customerPaymentId,
      specifiedType: const FullType(int),
    );
    yield r'customer';
    yield serializers.serialize(
      object.customer,
      specifiedType: const FullType(int),
    );
    yield r'amount';
    yield serializers.serialize(
      object.amount,
      specifiedType: const FullType(String),
    );
    yield r'currency';
    yield serializers.serialize(
      object.currency,
      specifiedType: const FullType(CurrencyCode),
    );
    yield r'method';
    yield serializers.serialize(
      object.method,
      specifiedType: const FullType(PaymentMethod),
    );
    yield r'payment_charge';
    yield object.paymentCharge == null
        ? null
        : serializers.serialize(
            object.paymentCharge,
            specifiedType: const FullType.nullable(int),
          );
    yield r'reference';
    yield object.reference == null
        ? null
        : serializers.serialize(
            object.reference,
            specifiedType: const FullType.nullable(String),
          );
    yield r'date';
    yield serializers.serialize(
      object.date,
      specifiedType: const FullType(DateTime),
    );
    yield r'facility';
    yield serializers.serialize(
      object.facility,
      specifiedType: const FullType(int),
    );
    yield r'cash_session';
    yield object.cashSession == null
        ? null
        : serializers.serialize(
            object.cashSession,
            specifiedType: const FullType.nullable(int),
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
    yield r'unapplied';
    yield serializers.serialize(
      object.unapplied,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CustomerPaymentResponse object, {
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
    required CustomerPaymentResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'customer_payment_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.customerPaymentId = valueDes;
          break;
        case r'customer':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.customer = valueDes;
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
        case r'currency':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(CurrencyCode),
                  )
                  as CurrencyCode;
          result.currency = valueDes;
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
        case r'payment_charge':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.paymentCharge = valueDes;
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
        case r'date':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )
                  as DateTime;
          result.date = valueDes;
          break;
        case r'facility':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.facility = valueDes;
          break;
        case r'cash_session':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.cashSession = valueDes;
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
        case r'unapplied':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.unapplied = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CustomerPaymentResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CustomerPaymentResponseBuilder();
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
