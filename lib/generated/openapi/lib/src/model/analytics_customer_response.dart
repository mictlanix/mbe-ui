//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/date.dart';
import 'package:mbe_api_client/src/model/analytics_query_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'analytics_customer_response.g.dart';

/// AnalyticsCustomerResponse
///
/// Properties:
/// * [asOf] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
/// * [customer]
/// * [customerName]
/// * [start]
/// * [end]
/// * [sales] - Net sales, refunds, collected (payments family) and margin (cost) for the period, with the previous period. Null without the sales family.
/// * [receivable] - Receivable, current and overdue now, by aging bucket. Null without the receivables family.
/// * [topProducts] - The ten products with the most net sales in the period. Null without the sales family.
/// * [lastPurchase] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
/// * [ordersPerMonth] - Orders in the 12 months up to end ÷ 12, two decimals. Sales family.
/// * [creditLimit] - Spec 033's. Receivables family.
/// * [creditUtilization] - Spec 033's: owed across every facility ÷ the limit; null without a limit. Receivables family.
@BuiltValue()
abstract class AnalyticsCustomerResponse
    implements
        Built<AnalyticsCustomerResponse, AnalyticsCustomerResponseBuilder> {
  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'as_of')
  DateTime get asOf;

  @BuiltValueField(wireName: r'customer')
  int get customer;

  @BuiltValueField(wireName: r'customer_name')
  String get customerName;

  @BuiltValueField(wireName: r'start')
  Date get start;

  @BuiltValueField(wireName: r'end')
  Date get end;

  /// Net sales, refunds, collected (payments family) and margin (cost) for the period, with the previous period. Null without the sales family.
  @BuiltValueField(wireName: r'sales')
  AnalyticsQueryResponse? get sales;

  /// Receivable, current and overdue now, by aging bucket. Null without the receivables family.
  @BuiltValueField(wireName: r'receivable')
  AnalyticsQueryResponse? get receivable;

  /// The ten products with the most net sales in the period. Null without the sales family.
  @BuiltValueField(wireName: r'top_products')
  AnalyticsQueryResponse? get topProducts;

  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'last_purchase')
  DateTime? get lastPurchase;

  /// Orders in the 12 months up to end ÷ 12, two decimals. Sales family.
  @BuiltValueField(wireName: r'orders_per_month')
  String? get ordersPerMonth;

  /// Spec 033's. Receivables family.
  @BuiltValueField(wireName: r'credit_limit')
  String? get creditLimit;

  /// Spec 033's: owed across every facility ÷ the limit; null without a limit. Receivables family.
  @BuiltValueField(wireName: r'credit_utilization')
  String? get creditUtilization;

  AnalyticsCustomerResponse._();

  factory AnalyticsCustomerResponse([
    void updates(AnalyticsCustomerResponseBuilder b),
  ]) = _$AnalyticsCustomerResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AnalyticsCustomerResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AnalyticsCustomerResponse> get serializer =>
      _$AnalyticsCustomerResponseSerializer();
}

class _$AnalyticsCustomerResponseSerializer
    implements PrimitiveSerializer<AnalyticsCustomerResponse> {
  @override
  final Iterable<Type> types = const [
    AnalyticsCustomerResponse,
    _$AnalyticsCustomerResponse,
  ];

  @override
  final String wireName = r'AnalyticsCustomerResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AnalyticsCustomerResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'as_of';
    yield serializers.serialize(
      object.asOf,
      specifiedType: const FullType(DateTime),
    );
    yield r'customer';
    yield serializers.serialize(
      object.customer,
      specifiedType: const FullType(int),
    );
    yield r'customer_name';
    yield serializers.serialize(
      object.customerName,
      specifiedType: const FullType(String),
    );
    yield r'start';
    yield serializers.serialize(
      object.start,
      specifiedType: const FullType(Date),
    );
    yield r'end';
    yield serializers.serialize(
      object.end,
      specifiedType: const FullType(Date),
    );
    yield r'sales';
    yield object.sales == null
        ? null
        : serializers.serialize(
            object.sales,
            specifiedType: const FullType.nullable(AnalyticsQueryResponse),
          );
    yield r'receivable';
    yield object.receivable == null
        ? null
        : serializers.serialize(
            object.receivable,
            specifiedType: const FullType.nullable(AnalyticsQueryResponse),
          );
    yield r'top_products';
    yield object.topProducts == null
        ? null
        : serializers.serialize(
            object.topProducts,
            specifiedType: const FullType.nullable(AnalyticsQueryResponse),
          );
    yield r'last_purchase';
    yield object.lastPurchase == null
        ? null
        : serializers.serialize(
            object.lastPurchase,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'orders_per_month';
    yield object.ordersPerMonth == null
        ? null
        : serializers.serialize(
            object.ordersPerMonth,
            specifiedType: const FullType.nullable(String),
          );
    yield r'credit_limit';
    yield object.creditLimit == null
        ? null
        : serializers.serialize(
            object.creditLimit,
            specifiedType: const FullType.nullable(String),
          );
    yield r'credit_utilization';
    yield object.creditUtilization == null
        ? null
        : serializers.serialize(
            object.creditUtilization,
            specifiedType: const FullType.nullable(String),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    AnalyticsCustomerResponse object, {
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
    required AnalyticsCustomerResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'as_of':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )
                  as DateTime;
          result.asOf = valueDes;
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
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.customerName = valueDes;
          break;
        case r'start':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(Date),
                  )
                  as Date;
          result.start = valueDes;
          break;
        case r'end':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(Date),
                  )
                  as Date;
          result.end = valueDes;
          break;
        case r'sales':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(
                      AnalyticsQueryResponse,
                    ),
                  )
                  as AnalyticsQueryResponse?;
          if (valueDes == null) continue;
          result.sales.replace(valueDes);
          break;
        case r'receivable':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(
                      AnalyticsQueryResponse,
                    ),
                  )
                  as AnalyticsQueryResponse?;
          if (valueDes == null) continue;
          result.receivable.replace(valueDes);
          break;
        case r'top_products':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(
                      AnalyticsQueryResponse,
                    ),
                  )
                  as AnalyticsQueryResponse?;
          if (valueDes == null) continue;
          result.topProducts.replace(valueDes);
          break;
        case r'last_purchase':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(DateTime),
                  )
                  as DateTime?;
          if (valueDes == null) continue;
          result.lastPurchase = valueDes;
          break;
        case r'orders_per_month':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.ordersPerMonth = valueDes;
          break;
        case r'credit_limit':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.creditLimit = valueDes;
          break;
        case r'credit_utilization':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.creditUtilization = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AnalyticsCustomerResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AnalyticsCustomerResponseBuilder();
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
