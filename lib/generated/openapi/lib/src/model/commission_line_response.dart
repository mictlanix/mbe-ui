//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'commission_line_response.g.dart';

/// CommissionLineResponse
///
/// Properties:
/// * [scheme]
/// * [movement]
/// * [salesOrder]
/// * [salesOrderDetail]
/// * [customerRefundDetail]
/// * [orderDate] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
/// * [paidDate] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
/// * [customer]
/// * [customerName]
/// * [product]
/// * [productName]
/// * [label]
/// * [labelName]
/// * [labelRate]
/// * [salesperson]
/// * [orderSalesperson]
/// * [customerSalesperson]
/// * [participation]
/// * [participationName]
/// * [participationRate]
/// * [rate]
/// * [price]
/// * [quantity]
/// * [total]
/// * [fullCommission]
/// * [share]
/// * [commission]
@BuiltValue()
abstract class CommissionLineResponse
    implements Built<CommissionLineResponse, CommissionLineResponseBuilder> {
  @BuiltValueField(wireName: r'scheme')
  int get scheme;

  @BuiltValueField(wireName: r'movement')
  CommissionLineResponseMovementEnum get movement;
  // enum movementEnum {  sale,  refund,  };

  @BuiltValueField(wireName: r'sales_order')
  int get salesOrder;

  @BuiltValueField(wireName: r'sales_order_detail')
  int get salesOrderDetail;

  @BuiltValueField(wireName: r'customer_refund_detail')
  int? get customerRefundDetail;

  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'order_date')
  DateTime get orderDate;

  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'paid_date')
  DateTime get paidDate;

  @BuiltValueField(wireName: r'customer')
  int get customer;

  @BuiltValueField(wireName: r'customer_name')
  String get customerName;

  @BuiltValueField(wireName: r'product')
  int get product;

  @BuiltValueField(wireName: r'product_name')
  String get productName;

  @BuiltValueField(wireName: r'label')
  int? get label;

  @BuiltValueField(wireName: r'label_name')
  String? get labelName;

  @BuiltValueField(wireName: r'label_rate')
  String get labelRate;

  @BuiltValueField(wireName: r'salesperson')
  int get salesperson;

  @BuiltValueField(wireName: r'order_salesperson')
  int get orderSalesperson;

  @BuiltValueField(wireName: r'customer_salesperson')
  int get customerSalesperson;

  @BuiltValueField(wireName: r'participation')
  int get participation;

  @BuiltValueField(wireName: r'participation_name')
  String get participationName;

  @BuiltValueField(wireName: r'participation_rate')
  String get participationRate;

  @BuiltValueField(wireName: r'rate')
  String get rate;

  @BuiltValueField(wireName: r'price')
  String get price;

  @BuiltValueField(wireName: r'quantity')
  String get quantity;

  @BuiltValueField(wireName: r'total')
  String get total;

  @BuiltValueField(wireName: r'full_commission')
  String get fullCommission;

  @BuiltValueField(wireName: r'share')
  String? get share;

  @BuiltValueField(wireName: r'commission')
  String get commission;

  CommissionLineResponse._();

  factory CommissionLineResponse([
    void updates(CommissionLineResponseBuilder b),
  ]) = _$CommissionLineResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CommissionLineResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CommissionLineResponse> get serializer =>
      _$CommissionLineResponseSerializer();
}

class _$CommissionLineResponseSerializer
    implements PrimitiveSerializer<CommissionLineResponse> {
  @override
  final Iterable<Type> types = const [
    CommissionLineResponse,
    _$CommissionLineResponse,
  ];

  @override
  final String wireName = r'CommissionLineResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CommissionLineResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'scheme';
    yield serializers.serialize(
      object.scheme,
      specifiedType: const FullType(int),
    );
    yield r'movement';
    yield serializers.serialize(
      object.movement,
      specifiedType: const FullType(CommissionLineResponseMovementEnum),
    );
    yield r'sales_order';
    yield serializers.serialize(
      object.salesOrder,
      specifiedType: const FullType(int),
    );
    yield r'sales_order_detail';
    yield serializers.serialize(
      object.salesOrderDetail,
      specifiedType: const FullType(int),
    );
    yield r'customer_refund_detail';
    yield object.customerRefundDetail == null
        ? null
        : serializers.serialize(
            object.customerRefundDetail,
            specifiedType: const FullType.nullable(int),
          );
    yield r'order_date';
    yield serializers.serialize(
      object.orderDate,
      specifiedType: const FullType(DateTime),
    );
    yield r'paid_date';
    yield serializers.serialize(
      object.paidDate,
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
    yield r'product';
    yield serializers.serialize(
      object.product,
      specifiedType: const FullType(int),
    );
    yield r'product_name';
    yield serializers.serialize(
      object.productName,
      specifiedType: const FullType(String),
    );
    yield r'label';
    yield object.label == null
        ? null
        : serializers.serialize(
            object.label,
            specifiedType: const FullType.nullable(int),
          );
    yield r'label_name';
    yield object.labelName == null
        ? null
        : serializers.serialize(
            object.labelName,
            specifiedType: const FullType.nullable(String),
          );
    yield r'label_rate';
    yield serializers.serialize(
      object.labelRate,
      specifiedType: const FullType(String),
    );
    yield r'salesperson';
    yield serializers.serialize(
      object.salesperson,
      specifiedType: const FullType(int),
    );
    yield r'order_salesperson';
    yield serializers.serialize(
      object.orderSalesperson,
      specifiedType: const FullType(int),
    );
    yield r'customer_salesperson';
    yield serializers.serialize(
      object.customerSalesperson,
      specifiedType: const FullType(int),
    );
    yield r'participation';
    yield serializers.serialize(
      object.participation,
      specifiedType: const FullType(int),
    );
    yield r'participation_name';
    yield serializers.serialize(
      object.participationName,
      specifiedType: const FullType(String),
    );
    yield r'participation_rate';
    yield serializers.serialize(
      object.participationRate,
      specifiedType: const FullType(String),
    );
    yield r'rate';
    yield serializers.serialize(
      object.rate,
      specifiedType: const FullType(String),
    );
    yield r'price';
    yield serializers.serialize(
      object.price,
      specifiedType: const FullType(String),
    );
    yield r'quantity';
    yield serializers.serialize(
      object.quantity,
      specifiedType: const FullType(String),
    );
    yield r'total';
    yield serializers.serialize(
      object.total,
      specifiedType: const FullType(String),
    );
    yield r'full_commission';
    yield serializers.serialize(
      object.fullCommission,
      specifiedType: const FullType(String),
    );
    yield r'share';
    yield object.share == null
        ? null
        : serializers.serialize(
            object.share,
            specifiedType: const FullType.nullable(String),
          );
    yield r'commission';
    yield serializers.serialize(
      object.commission,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CommissionLineResponse object, {
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
    required CommissionLineResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'scheme':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.scheme = valueDes;
          break;
        case r'movement':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(
                      CommissionLineResponseMovementEnum,
                    ),
                  )
                  as CommissionLineResponseMovementEnum;
          result.movement = valueDes;
          break;
        case r'sales_order':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.salesOrder = valueDes;
          break;
        case r'sales_order_detail':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.salesOrderDetail = valueDes;
          break;
        case r'customer_refund_detail':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.customerRefundDetail = valueDes;
          break;
        case r'order_date':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )
                  as DateTime;
          result.orderDate = valueDes;
          break;
        case r'paid_date':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )
                  as DateTime;
          result.paidDate = valueDes;
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
        case r'product':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.product = valueDes;
          break;
        case r'product_name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.productName = valueDes;
          break;
        case r'label':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.label = valueDes;
          break;
        case r'label_name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.labelName = valueDes;
          break;
        case r'label_rate':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.labelRate = valueDes;
          break;
        case r'salesperson':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.salesperson = valueDes;
          break;
        case r'order_salesperson':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.orderSalesperson = valueDes;
          break;
        case r'customer_salesperson':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.customerSalesperson = valueDes;
          break;
        case r'participation':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.participation = valueDes;
          break;
        case r'participation_name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.participationName = valueDes;
          break;
        case r'participation_rate':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.participationRate = valueDes;
          break;
        case r'rate':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.rate = valueDes;
          break;
        case r'price':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.price = valueDes;
          break;
        case r'quantity':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.quantity = valueDes;
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
        case r'full_commission':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.fullCommission = valueDes;
          break;
        case r'share':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.share = valueDes;
          break;
        case r'commission':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.commission = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CommissionLineResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CommissionLineResponseBuilder();
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

class CommissionLineResponseMovementEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'sale')
  static const CommissionLineResponseMovementEnum sale =
      _$commissionLineResponseMovementEnum_sale;
  @BuiltValueEnumConst(wireName: r'refund')
  static const CommissionLineResponseMovementEnum refund =
      _$commissionLineResponseMovementEnum_refund;

  static Serializer<CommissionLineResponseMovementEnum> get serializer =>
      _$commissionLineResponseMovementEnumSerializer;

  const CommissionLineResponseMovementEnum._(String name) : super(name);

  static BuiltSet<CommissionLineResponseMovementEnum> get values =>
      _$commissionLineResponseMovementEnumValues;
  static CommissionLineResponseMovementEnum valueOf(String name) =>
      _$commissionLineResponseMovementEnumValueOf(name);
}
