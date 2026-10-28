//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/payment_method.dart';
import 'package:mbe_api_client/src/model/currency_code.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'account_payment.g.dart';

/// AccountPayment
///
/// Properties:
/// * [id]
/// * [serial]
/// * [date] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
/// * [method]
/// * [currency]
/// * [amount]
/// * [unapplied]
@BuiltValue()
abstract class AccountPayment
    implements Built<AccountPayment, AccountPaymentBuilder> {
  @BuiltValueField(wireName: r'id')
  int get id;

  @BuiltValueField(wireName: r'serial')
  int? get serial;

  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'date')
  DateTime get date;

  @BuiltValueField(wireName: r'method')
  PaymentMethod? get method;
  // enum methodEnum {  0,  1,  2,  3,  4,  5,  6,  8,  12,  27,  28,  29,  30,  99,  1001,  };

  @BuiltValueField(wireName: r'currency')
  CurrencyCode get currency;
  // enum currencyEnum {  0,  1,  2,  };

  @BuiltValueField(wireName: r'amount')
  String get amount;

  @BuiltValueField(wireName: r'unapplied')
  String get unapplied;

  AccountPayment._();

  factory AccountPayment([void updates(AccountPaymentBuilder b)]) =
      _$AccountPayment;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AccountPaymentBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AccountPayment> get serializer =>
      _$AccountPaymentSerializer();
}

class _$AccountPaymentSerializer
    implements PrimitiveSerializer<AccountPayment> {
  @override
  final Iterable<Type> types = const [AccountPayment, _$AccountPayment];

  @override
  final String wireName = r'AccountPayment';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AccountPayment object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(object.id, specifiedType: const FullType(int));
    yield r'serial';
    yield object.serial == null
        ? null
        : serializers.serialize(
            object.serial,
            specifiedType: const FullType.nullable(int),
          );
    yield r'date';
    yield serializers.serialize(
      object.date,
      specifiedType: const FullType(DateTime),
    );
    yield r'method';
    yield object.method == null
        ? null
        : serializers.serialize(
            object.method,
            specifiedType: const FullType.nullable(PaymentMethod),
          );
    yield r'currency';
    yield serializers.serialize(
      object.currency,
      specifiedType: const FullType(CurrencyCode),
    );
    yield r'amount';
    yield serializers.serialize(
      object.amount,
      specifiedType: const FullType(String),
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
    AccountPayment object, {
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
    required AccountPaymentBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.id = valueDes;
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
                    specifiedType: const FullType(DateTime),
                  )
                  as DateTime;
          result.date = valueDes;
          break;
        case r'method':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(PaymentMethod),
                  )
                  as PaymentMethod?;
          if (valueDes == null) continue;
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
        case r'amount':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.amount = valueDes;
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
  AccountPayment deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AccountPaymentBuilder();
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
