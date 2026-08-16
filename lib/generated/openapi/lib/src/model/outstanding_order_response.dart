//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/currency_code.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'outstanding_order_response.g.dart';

/// OutstandingOrderResponse
///
/// Properties:
/// * [salesOrderId]
/// * [serial]
/// * [customer]
/// * [customerName]
/// * [customerDisplayName]
/// * [date]
/// * [dueDate]
/// * [currency]
/// * [total]
/// * [balance]
@BuiltValue()
abstract class OutstandingOrderResponse
    implements
        Built<OutstandingOrderResponse, OutstandingOrderResponseBuilder> {
  @BuiltValueField(wireName: r'sales_order_id')
  int get salesOrderId;

  @BuiltValueField(wireName: r'serial')
  int? get serial;

  @BuiltValueField(wireName: r'customer')
  int get customer;

  @BuiltValueField(wireName: r'customer_name')
  String? get customerName;

  @BuiltValueField(wireName: r'customer_display_name')
  String? get customerDisplayName;

  @BuiltValueField(wireName: r'date')
  DateTime get date;

  @BuiltValueField(wireName: r'due_date')
  DateTime get dueDate;

  @BuiltValueField(wireName: r'currency')
  CurrencyCode get currency;
  // enum currencyEnum {  0,  1,  2,  };

  @BuiltValueField(wireName: r'total')
  String get total;

  @BuiltValueField(wireName: r'balance')
  String get balance;

  OutstandingOrderResponse._();

  factory OutstandingOrderResponse([
    void updates(OutstandingOrderResponseBuilder b),
  ]) = _$OutstandingOrderResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OutstandingOrderResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OutstandingOrderResponse> get serializer =>
      _$OutstandingOrderResponseSerializer();
}

class _$OutstandingOrderResponseSerializer
    implements PrimitiveSerializer<OutstandingOrderResponse> {
  @override
  final Iterable<Type> types = const [
    OutstandingOrderResponse,
    _$OutstandingOrderResponse,
  ];

  @override
  final String wireName = r'OutstandingOrderResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OutstandingOrderResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'sales_order_id';
    yield serializers.serialize(
      object.salesOrderId,
      specifiedType: const FullType(int),
    );
    yield r'serial';
    yield object.serial == null
        ? null
        : serializers.serialize(
            object.serial,
            specifiedType: const FullType.nullable(int),
          );
    yield r'customer';
    yield serializers.serialize(
      object.customer,
      specifiedType: const FullType(int),
    );
    if (object.customerName != null) {
      yield r'customer_name';
      yield serializers.serialize(
        object.customerName,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.customerDisplayName != null) {
      yield r'customer_display_name';
      yield serializers.serialize(
        object.customerDisplayName,
        specifiedType: const FullType.nullable(String),
      );
    }
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
    yield r'currency';
    yield serializers.serialize(
      object.currency,
      specifiedType: const FullType(CurrencyCode),
    );
    yield r'total';
    yield serializers.serialize(
      object.total,
      specifiedType: const FullType(String),
    );
    yield r'balance';
    yield serializers.serialize(
      object.balance,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OutstandingOrderResponse object, {
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
    required OutstandingOrderResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'sales_order_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.salesOrderId = valueDes;
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
        case r'customer':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.customer = valueDes;
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
        case r'currency':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(CurrencyCode),
                  )
                  as CurrencyCode;
          result.currency = valueDes;
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
        case r'balance':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.balance = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OutstandingOrderResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OutstandingOrderResponseBuilder();
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
