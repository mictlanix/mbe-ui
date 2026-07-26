//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/payment_terms.dart';
import 'package:mbe_api_client/src/model/priority.dart';
import 'package:mbe_api_client/src/model/currency_code.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sales_order_update.g.dart';

/// SalesOrderUpdate
///
/// Properties:
/// * [customer]
/// * [salesperson]
/// * [paymentTerms]
/// * [currency]
/// * [promiseDate]
/// * [contact]
/// * [shipTo]
/// * [recipient]
/// * [customerName]
/// * [priority]
/// * [comment]
@BuiltValue()
abstract class SalesOrderUpdate
    implements Built<SalesOrderUpdate, SalesOrderUpdateBuilder> {
  @BuiltValueField(wireName: r'customer')
  int? get customer;

  @BuiltValueField(wireName: r'salesperson')
  int? get salesperson;

  @BuiltValueField(wireName: r'payment_terms')
  PaymentTerms? get paymentTerms;
  // enum paymentTermsEnum {  0,  1,  };

  @BuiltValueField(wireName: r'currency')
  CurrencyCode? get currency;
  // enum currencyEnum {  0,  1,  2,  };

  @BuiltValueField(wireName: r'promise_date')
  DateTime? get promiseDate;

  @BuiltValueField(wireName: r'contact')
  int? get contact;

  @BuiltValueField(wireName: r'ship_to')
  int? get shipTo;

  @BuiltValueField(wireName: r'recipient')
  String? get recipient;

  @BuiltValueField(wireName: r'customer_name')
  String? get customerName;

  @BuiltValueField(wireName: r'priority')
  Priority? get priority;
  // enum priorityEnum {  0,  1,  2,  3,  };

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  SalesOrderUpdate._();

  factory SalesOrderUpdate([void updates(SalesOrderUpdateBuilder b)]) =
      _$SalesOrderUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SalesOrderUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SalesOrderUpdate> get serializer =>
      _$SalesOrderUpdateSerializer();
}

class _$SalesOrderUpdateSerializer
    implements PrimitiveSerializer<SalesOrderUpdate> {
  @override
  final Iterable<Type> types = const [SalesOrderUpdate, _$SalesOrderUpdate];

  @override
  final String wireName = r'SalesOrderUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SalesOrderUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.customer != null) {
      yield r'customer';
      yield serializers.serialize(
        object.customer,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.salesperson != null) {
      yield r'salesperson';
      yield serializers.serialize(
        object.salesperson,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.paymentTerms != null) {
      yield r'payment_terms';
      yield serializers.serialize(
        object.paymentTerms,
        specifiedType: const FullType.nullable(PaymentTerms),
      );
    }
    if (object.currency != null) {
      yield r'currency';
      yield serializers.serialize(
        object.currency,
        specifiedType: const FullType.nullable(CurrencyCode),
      );
    }
    if (object.promiseDate != null) {
      yield r'promise_date';
      yield serializers.serialize(
        object.promiseDate,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
    if (object.contact != null) {
      yield r'contact';
      yield serializers.serialize(
        object.contact,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.shipTo != null) {
      yield r'ship_to';
      yield serializers.serialize(
        object.shipTo,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.recipient != null) {
      yield r'recipient';
      yield serializers.serialize(
        object.recipient,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.customerName != null) {
      yield r'customer_name';
      yield serializers.serialize(
        object.customerName,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.priority != null) {
      yield r'priority';
      yield serializers.serialize(
        object.priority,
        specifiedType: const FullType.nullable(Priority),
      );
    }
    if (object.comment != null) {
      yield r'comment';
      yield serializers.serialize(
        object.comment,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SalesOrderUpdate object, {
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
    required SalesOrderUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
        case r'payment_terms':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(PaymentTerms),
                  )
                  as PaymentTerms?;
          if (valueDes == null) continue;
          result.paymentTerms = valueDes;
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
        case r'promise_date':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(DateTime),
                  )
                  as DateTime?;
          if (valueDes == null) continue;
          result.promiseDate = valueDes;
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
        case r'priority':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(Priority),
                  )
                  as Priority?;
          if (valueDes == null) continue;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SalesOrderUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SalesOrderUpdateBuilder();
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
