//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'application_response.g.dart';

/// ApplicationResponse
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
@BuiltValue()
abstract class ApplicationResponse
    implements Built<ApplicationResponse, ApplicationResponseBuilder> {
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

  ApplicationResponse._();

  factory ApplicationResponse([void updates(ApplicationResponseBuilder b)]) =
      _$ApplicationResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ApplicationResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ApplicationResponse> get serializer =>
      _$ApplicationResponseSerializer();
}

class _$ApplicationResponseSerializer
    implements PrimitiveSerializer<ApplicationResponse> {
  @override
  final Iterable<Type> types = const [
    ApplicationResponse,
    _$ApplicationResponse,
  ];

  @override
  final String wireName = r'ApplicationResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ApplicationResponse object, {
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
  }

  @override
  Object serialize(
    Serializers serializers,
    ApplicationResponse object, {
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
    required ApplicationResponseBuilder result,
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ApplicationResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ApplicationResponseBuilder();
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
