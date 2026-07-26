//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/payment_terms.dart';
import 'package:mbe_api_client/src/model/currency_code.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sales_quote_update.g.dart';

/// SalesQuoteUpdate
///
/// Properties:
/// * [customer]
/// * [salesperson]
/// * [paymentTerms]
/// * [currency]
/// * [dueDate]
/// * [contact]
/// * [shipTo]
/// * [comment]
@BuiltValue()
abstract class SalesQuoteUpdate
    implements Built<SalesQuoteUpdate, SalesQuoteUpdateBuilder> {
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

  @BuiltValueField(wireName: r'due_date')
  DateTime? get dueDate;

  @BuiltValueField(wireName: r'contact')
  int? get contact;

  @BuiltValueField(wireName: r'ship_to')
  int? get shipTo;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  SalesQuoteUpdate._();

  factory SalesQuoteUpdate([void updates(SalesQuoteUpdateBuilder b)]) =
      _$SalesQuoteUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SalesQuoteUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SalesQuoteUpdate> get serializer =>
      _$SalesQuoteUpdateSerializer();
}

class _$SalesQuoteUpdateSerializer
    implements PrimitiveSerializer<SalesQuoteUpdate> {
  @override
  final Iterable<Type> types = const [SalesQuoteUpdate, _$SalesQuoteUpdate];

  @override
  final String wireName = r'SalesQuoteUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SalesQuoteUpdate object, {
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
    if (object.dueDate != null) {
      yield r'due_date';
      yield serializers.serialize(
        object.dueDate,
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
    SalesQuoteUpdate object, {
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
    required SalesQuoteUpdateBuilder result,
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
        case r'due_date':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(DateTime),
                  )
                  as DateTime?;
          if (valueDes == null) continue;
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
  SalesQuoteUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SalesQuoteUpdateBuilder();
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
