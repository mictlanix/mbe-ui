//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/document_status.dart';
import 'package:mbe_api_client/src/model/currency_code.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'customer_refund_summary.g.dart';

/// CustomerRefundSummary
///
/// Properties:
/// * [customerRefundId]
/// * [salesOrder]
/// * [customer]
/// * [serial]
/// * [date]
/// * [currency]
/// * [status]
/// * [total]
@BuiltValue()
abstract class CustomerRefundSummary
    implements Built<CustomerRefundSummary, CustomerRefundSummaryBuilder> {
  @BuiltValueField(wireName: r'customer_refund_id')
  int get customerRefundId;

  @BuiltValueField(wireName: r'sales_order')
  int get salesOrder;

  @BuiltValueField(wireName: r'customer')
  int? get customer;

  @BuiltValueField(wireName: r'serial')
  int? get serial;

  @BuiltValueField(wireName: r'date')
  DateTime? get date;

  @BuiltValueField(wireName: r'currency')
  CurrencyCode get currency;
  // enum currencyEnum {  0,  1,  2,  };

  @BuiltValueField(wireName: r'status')
  DocumentStatus get status;
  // enum statusEnum {  draft,  completed,  paid,  cancelled,  };

  @BuiltValueField(wireName: r'total')
  String get total;

  CustomerRefundSummary._();

  factory CustomerRefundSummary([
    void updates(CustomerRefundSummaryBuilder b),
  ]) = _$CustomerRefundSummary;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CustomerRefundSummaryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CustomerRefundSummary> get serializer =>
      _$CustomerRefundSummarySerializer();
}

class _$CustomerRefundSummarySerializer
    implements PrimitiveSerializer<CustomerRefundSummary> {
  @override
  final Iterable<Type> types = const [
    CustomerRefundSummary,
    _$CustomerRefundSummary,
  ];

  @override
  final String wireName = r'CustomerRefundSummary';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CustomerRefundSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'customer_refund_id';
    yield serializers.serialize(
      object.customerRefundId,
      specifiedType: const FullType(int),
    );
    yield r'sales_order';
    yield serializers.serialize(
      object.salesOrder,
      specifiedType: const FullType(int),
    );
    yield r'customer';
    yield object.customer == null
        ? null
        : serializers.serialize(
            object.customer,
            specifiedType: const FullType.nullable(int),
          );
    yield r'serial';
    yield object.serial == null
        ? null
        : serializers.serialize(
            object.serial,
            specifiedType: const FullType.nullable(int),
          );
    yield r'date';
    yield object.date == null
        ? null
        : serializers.serialize(
            object.date,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'currency';
    yield serializers.serialize(
      object.currency,
      specifiedType: const FullType(CurrencyCode),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(DocumentStatus),
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
    CustomerRefundSummary object, {
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
    required CustomerRefundSummaryBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'customer_refund_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.customerRefundId = valueDes;
          break;
        case r'sales_order':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.salesOrder = valueDes;
          break;
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
                    specifiedType: const FullType.nullable(DateTime),
                  )
                  as DateTime?;
          if (valueDes == null) continue;
          result.date = valueDes;
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
        case r'status':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DocumentStatus),
                  )
                  as DocumentStatus;
          result.status = valueDes;
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
  CustomerRefundSummary deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CustomerRefundSummaryBuilder();
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
