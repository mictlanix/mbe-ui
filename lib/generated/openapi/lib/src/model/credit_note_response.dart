//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'credit_note_response.g.dart';

/// A credit note is a view over its backing payment (FR-070).  `refunded` is the amount *issued* and is never decremented; `remaining` is derived from the backing payment's non-cancelled applications, so there is no second balance to drift.
///
/// Properties:
/// * [creditNoteId]
/// * [customer]
/// * [salesOrder]
/// * [customerRefund]
/// * [customerPayment]
/// * [refunded]
/// * [remaining]
/// * [cashSession]
/// * [date]
@BuiltValue()
abstract class CreditNoteResponse
    implements Built<CreditNoteResponse, CreditNoteResponseBuilder> {
  @BuiltValueField(wireName: r'credit_note_id')
  int get creditNoteId;

  @BuiltValueField(wireName: r'customer')
  int get customer;

  @BuiltValueField(wireName: r'sales_order')
  int get salesOrder;

  @BuiltValueField(wireName: r'customer_refund')
  int get customerRefund;

  @BuiltValueField(wireName: r'customer_payment')
  int get customerPayment;

  @BuiltValueField(wireName: r'refunded')
  String get refunded;

  @BuiltValueField(wireName: r'remaining')
  String get remaining;

  @BuiltValueField(wireName: r'cash_session')
  int? get cashSession;

  @BuiltValueField(wireName: r'date')
  DateTime? get date;

  CreditNoteResponse._();

  factory CreditNoteResponse([void updates(CreditNoteResponseBuilder b)]) =
      _$CreditNoteResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreditNoteResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreditNoteResponse> get serializer =>
      _$CreditNoteResponseSerializer();
}

class _$CreditNoteResponseSerializer
    implements PrimitiveSerializer<CreditNoteResponse> {
  @override
  final Iterable<Type> types = const [CreditNoteResponse, _$CreditNoteResponse];

  @override
  final String wireName = r'CreditNoteResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreditNoteResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'credit_note_id';
    yield serializers.serialize(
      object.creditNoteId,
      specifiedType: const FullType(int),
    );
    yield r'customer';
    yield serializers.serialize(
      object.customer,
      specifiedType: const FullType(int),
    );
    yield r'sales_order';
    yield serializers.serialize(
      object.salesOrder,
      specifiedType: const FullType(int),
    );
    yield r'customer_refund';
    yield serializers.serialize(
      object.customerRefund,
      specifiedType: const FullType(int),
    );
    yield r'customer_payment';
    yield serializers.serialize(
      object.customerPayment,
      specifiedType: const FullType(int),
    );
    yield r'refunded';
    yield serializers.serialize(
      object.refunded,
      specifiedType: const FullType(String),
    );
    yield r'remaining';
    yield serializers.serialize(
      object.remaining,
      specifiedType: const FullType(String),
    );
    yield r'cash_session';
    yield object.cashSession == null
        ? null
        : serializers.serialize(
            object.cashSession,
            specifiedType: const FullType.nullable(int),
          );
    yield r'date';
    yield object.date == null
        ? null
        : serializers.serialize(
            object.date,
            specifiedType: const FullType.nullable(DateTime),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    CreditNoteResponse object, {
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
    required CreditNoteResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'credit_note_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.creditNoteId = valueDes;
          break;
        case r'customer':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.customer = valueDes;
          break;
        case r'sales_order':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.salesOrder = valueDes;
          break;
        case r'customer_refund':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.customerRefund = valueDes;
          break;
        case r'customer_payment':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.customerPayment = valueDes;
          break;
        case r'refunded':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.refunded = valueDes;
          break;
        case r'remaining':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.remaining = valueDes;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreditNoteResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreditNoteResponseBuilder();
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
