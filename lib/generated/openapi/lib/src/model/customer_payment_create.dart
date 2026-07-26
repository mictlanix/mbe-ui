//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/payment_type.dart';
import 'package:mbe_api_client/src/model/amount.dart';
import 'package:mbe_api_client/src/model/payment_method.dart';
import 'package:mbe_api_client/src/model/currency_code.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'customer_payment_create.g.dart';

/// CustomerPaymentCreate
///
/// Properties:
/// * [customer]
/// * [amount]
/// * [method]
/// * [currency]
/// * [paymentCharge]
/// * [reference]
/// * [date]
/// * [paymentType]
@BuiltValue()
abstract class CustomerPaymentCreate
    implements Built<CustomerPaymentCreate, CustomerPaymentCreateBuilder> {
  @BuiltValueField(wireName: r'customer')
  int get customer;

  @BuiltValueField(wireName: r'amount')
  Amount get amount;

  @BuiltValueField(wireName: r'method')
  PaymentMethod get method;
  // enum methodEnum {  0,  1,  2,  3,  4,  5,  6,  8,  12,  27,  28,  29,  30,  99,  1001,  };

  @BuiltValueField(wireName: r'currency')
  CurrencyCode? get currency;
  // enum currencyEnum {  0,  1,  2,  };

  @BuiltValueField(wireName: r'payment_charge')
  int? get paymentCharge;

  @BuiltValueField(wireName: r'reference')
  String? get reference;

  @BuiltValueField(wireName: r'date')
  DateTime? get date;

  @BuiltValueField(wireName: r'payment_type')
  PaymentType? get paymentType;
  // enum paymentTypeEnum {  0,  1,  2,  3,  4,  5,  };

  CustomerPaymentCreate._();

  factory CustomerPaymentCreate([
    void updates(CustomerPaymentCreateBuilder b),
  ]) = _$CustomerPaymentCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CustomerPaymentCreateBuilder b) =>
      b..paymentType = PaymentType.number1;

  @BuiltValueSerializer(custom: true)
  static Serializer<CustomerPaymentCreate> get serializer =>
      _$CustomerPaymentCreateSerializer();
}

class _$CustomerPaymentCreateSerializer
    implements PrimitiveSerializer<CustomerPaymentCreate> {
  @override
  final Iterable<Type> types = const [
    CustomerPaymentCreate,
    _$CustomerPaymentCreate,
  ];

  @override
  final String wireName = r'CustomerPaymentCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CustomerPaymentCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'customer';
    yield serializers.serialize(
      object.customer,
      specifiedType: const FullType(int),
    );
    yield r'amount';
    yield serializers.serialize(
      object.amount,
      specifiedType: const FullType(Amount),
    );
    yield r'method';
    yield serializers.serialize(
      object.method,
      specifiedType: const FullType(PaymentMethod),
    );
    if (object.currency != null) {
      yield r'currency';
      yield serializers.serialize(
        object.currency,
        specifiedType: const FullType.nullable(CurrencyCode),
      );
    }
    if (object.paymentCharge != null) {
      yield r'payment_charge';
      yield serializers.serialize(
        object.paymentCharge,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.reference != null) {
      yield r'reference';
      yield serializers.serialize(
        object.reference,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.date != null) {
      yield r'date';
      yield serializers.serialize(
        object.date,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
    if (object.paymentType != null) {
      yield r'payment_type';
      yield serializers.serialize(
        object.paymentType,
        specifiedType: const FullType(PaymentType),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CustomerPaymentCreate object, {
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
    required CustomerPaymentCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
                    specifiedType: const FullType(Amount),
                  )
                  as Amount;
          result.amount.replace(valueDes);
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
                    specifiedType: const FullType.nullable(CurrencyCode),
                  )
                  as CurrencyCode?;
          if (valueDes == null) continue;
          result.currency = valueDes;
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
                    specifiedType: const FullType.nullable(DateTime),
                  )
                  as DateTime?;
          if (valueDes == null) continue;
          result.date = valueDes;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CustomerPaymentCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CustomerPaymentCreateBuilder();
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
